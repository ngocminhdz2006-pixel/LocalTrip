package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.SettlementBalance;
import model.SettlementTransfer;

public class SettlementDAO {

    public List<SettlementBalance> findBalances(
            int tripId
    ) {
        List<SettlementBalance> balances
                = new ArrayList<>();

        // Include the trip owner even if an older/inconsistent database is
        // missing the owner's row in TripMembers. UNION removes duplicates
        // when the owner is already recorded as a trip member.
        String sql
                = "WITH TripParticipants AS ("
                + " SELECT t.trip_id, t.owner_id AS user_id "
                + " FROM Trips t WHERE t.trip_id = ? "
                + " UNION "
                + " SELECT tm.trip_id, tm.user_id "
                + " FROM TripMembers tm WHERE tm.trip_id = ? "
                + ") "
                + "SELECT p.user_id, u.full_name, "
                + "COALESCE(("
                + " SELECT SUM(e.amount) FROM Expenses e "
                + " WHERE e.trip_id = p.trip_id "
                + " AND e.payer_id = p.user_id "
                + " AND e.from_group_fund = 0"
                + "), 0) AS paid, "
                + "COALESCE(("
                + " SELECT SUM(ep.share_amount) "
                + " FROM ExpenseParticipants ep "
                + " INNER JOIN Expenses e ON e.expense_id = ep.expense_id "
                + " WHERE e.trip_id = p.trip_id "
                + " AND ep.user_id = p.user_id "
                + " AND e.from_group_fund = 0"
                + "), 0) AS owed "
                + "FROM TripParticipants p "
                + "INNER JOIN Users u ON u.user_id = p.user_id "
                + "ORDER BY CASE WHEN EXISTS ("
                + " SELECT 1 FROM Trips t WHERE t.trip_id = p.trip_id "
                + " AND t.owner_id = p.user_id"
                + ") THEN 0 ELSE 1 END, u.full_name";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement
                     = connection.prepareStatement(sql)) {

            statement.setInt(1, tripId);
            statement.setInt(2, tripId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    SettlementBalance balance
                            = new SettlementBalance();

                    balance.setMemberId(
                            resultSet.getInt("user_id")
                    );

                    balance.setMemberName(
                            resultSet.getString("full_name")
                    );

                    balance.setPaid(
                            resultSet.getBigDecimal("paid")
                    );

                    balance.setOwed(
                            resultSet.getBigDecimal("owed")
                    );

                    balance.calculateBalance();
                    balances.add(balance);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Unable to calculate member balances.",
                    e
            );
        }

        return balances;
    }

    public List<SettlementTransfer> calculateTransfers(
            List<SettlementBalance> balances
    ) {
        List<SettlementTransfer> transfers
                = new ArrayList<>();

        List<SettlementParty> debtors
                = new ArrayList<>();

        List<SettlementParty> creditors
                = new ArrayList<>();

        for (SettlementBalance balance : balances) {
            int comparison = balance.getBalance()
                    .compareTo(BigDecimal.ZERO);

            if (comparison < 0) {
                debtors.add(
                        new SettlementParty(
                                balance.getMemberId(),
                                balance.getMemberName(),
                                balance.getBalance().negate()
                        )
                );

            } else if (comparison > 0) {
                creditors.add(
                        new SettlementParty(
                                balance.getMemberId(),
                                balance.getMemberName(),
                                balance.getBalance()
                        )
                );
            }
        }

        int debtorIndex = 0;
        int creditorIndex = 0;

        while (debtorIndex < debtors.size()
                && creditorIndex < creditors.size()) {

            SettlementParty debtor
                    = debtors.get(debtorIndex);

            SettlementParty creditor
                    = creditors.get(creditorIndex);

            BigDecimal transferAmount
                    = debtor.amount.min(creditor.amount);

            if (transferAmount.compareTo(
                    BigDecimal.ZERO
            ) > 0) {
                SettlementTransfer transfer
                        = new SettlementTransfer();

                transfer.setFromMemberId(
                        debtor.memberId
                );

                transfer.setFromMemberName(
                        debtor.memberName
                );

                transfer.setToMemberId(
                        creditor.memberId
                );

                transfer.setToMemberName(
                        creditor.memberName
                );

                transfer.setAmount(transferAmount);

                transfers.add(transfer);
            }

            debtor.amount = debtor.amount.subtract(
                    transferAmount
            );

            creditor.amount = creditor.amount.subtract(
                    transferAmount
            );

            if (debtor.amount.compareTo(
                    BigDecimal.ZERO
            ) == 0) {
                debtorIndex++;
            }

            if (creditor.amount.compareTo(
                    BigDecimal.ZERO
            ) == 0) {
                creditorIndex++;
            }
        }

        return transfers;
    }

    public void syncAndLoadPaymentStatuses(int tripId, List<SettlementTransfer> transfers) {
        if (transfers == null || transfers.isEmpty()) {
            return;
        }

        String selectSql = "SELECT payment_id, status, updated_at FROM SettlementPayments WHERE trip_id = ? AND from_user_id = ? AND to_user_id = ?";
        String insertSql = "INSERT INTO SettlementPayments (trip_id, from_user_id, to_user_id, amount, status, updated_at) VALUES (?, ?, ?, ?, 'PENDING', SYSDATETIME())";

        try (Connection conn = DBContext.getConnection()) {
            for (SettlementTransfer t : transfers) {
                try (PreparedStatement psSelect = conn.prepareStatement(selectSql)) {
                    psSelect.setInt(1, tripId);
                    psSelect.setInt(2, t.getFromMemberId());
                    psSelect.setInt(3, t.getToMemberId());
                    try (ResultSet rs = psSelect.executeQuery()) {
                        if (rs.next()) {
                            t.setPaymentId(rs.getInt("payment_id"));
                            t.setStatus(rs.getString("status"));
                            t.setUpdatedAt(rs.getTimestamp("updated_at"));
                        } else {
                            try (PreparedStatement psInsert = conn.prepareStatement(insertSql, new String[]{"payment_id"})) {
                                psInsert.setInt(1, tripId);
                                psInsert.setInt(2, t.getFromMemberId());
                                psInsert.setInt(3, t.getToMemberId());
                                psInsert.setBigDecimal(4, t.getAmount());
                                psInsert.executeUpdate();
                                try (ResultSet rsKey = psInsert.getGeneratedKeys()) {
                                    if (rsKey.next()) {
                                        t.setPaymentId(rsKey.getInt(1));
                                    }
                                }
                                t.setStatus("PENDING");
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            // Table might not exist or temporary error - log and proceed with default PENDING
            System.err.println("Notice: SettlementPayments sync fallback: " + e.getMessage());
        }
    }

    public boolean updatePaymentStatus(int paymentId, int tripId, int actingUserId, String newStatus) {
        if (!"PENDING".equalsIgnoreCase(newStatus) && !"SENT".equalsIgnoreCase(newStatus) && !"CONFIRMED".equalsIgnoreCase(newStatus)) {
            return false;
        }

        String sql = "UPDATE SettlementPayments SET status = ?, updated_at = SYSDATETIME() "
                   + "WHERE payment_id = ? AND trip_id = ? "
                   + "AND (from_user_id = ? OR to_user_id = ? OR EXISTS (SELECT 1 FROM Trips WHERE trip_id = ? AND owner_id = ?))";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus.toUpperCase());
            ps.setInt(2, paymentId);
            ps.setInt(3, tripId);
            ps.setInt(4, actingUserId);
            ps.setInt(5, actingUserId);
            ps.setInt(6, tripId);
            ps.setInt(7, actingUserId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Unable to update settlement payment status.", e);
        }
    }

    private static class SettlementParty {

        private final int memberId;
        private final String memberName;
        private BigDecimal amount;

        private SettlementParty(
                int memberId,
                String memberName,
                BigDecimal amount
        ) {
            this.memberId = memberId;
            this.memberName = memberName;
            this.amount = amount;
        }
    }
}
