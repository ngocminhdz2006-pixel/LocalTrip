package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import model.SettlementBalance;
import model.SettlementTransfer;
import model.SimulatedBatchInfo;
import model.SimulatedScenarioResult;
import utils.AppClock;
import utils.PasswordUtil;

/**
 * Data access and scenario orchestrator for the Scenario Lab.
 *
 * <p>Enforces strict isolation by generating dedicated simulated users
 * (sim_*@sim.localtrip.test) and tagging every generated User and Trip with a sim_batch_id.
 *
 * <p>State transitions execute through production DAOs (TripStatusDAO, ActivityLifecycleDAO,
 * SettlementDAO) ensuring that real business constraints and locks are exercised.
 */
public class ScenarioLabDAO {

    private final TripStatusDAO tripStatusDAO = new TripStatusDAO();
    private final ActivityLifecycleDAO activityLifecycleDAO = new ActivityLifecycleDAO();
    private final SettlementDAO settlementDAO = new SettlementDAO();
    private final AdminAuditLogDAO auditLogDAO = new AdminAuditLogDAO();

    // Default password "123456" hash, computed once for fast fixture generation
    private static final String DEFAULT_SIM_HASH = PasswordUtil.hash("123456");

    public List<SimulatedBatchInfo> listBatches() {
        List<SimulatedBatchInfo> list = new ArrayList<SimulatedBatchInfo>();
        String sql = "SELECT t.sim_batch_id, t.trip_id, t.trip_name, t.status, t.created_at, "
                   + "       u.email AS owner_email, "
                   + "       (SELECT COUNT(*) FROM dbo.Users WHERE sim_batch_id = t.sim_batch_id) AS user_count "
                   + "FROM dbo.Trips t "
                   + "JOIN dbo.Users u ON u.user_id = t.owner_id "
                   + "WHERE t.sim_batch_id IS NOT NULL "
                   + "ORDER BY t.created_at DESC";

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                SimulatedBatchInfo info = new SimulatedBatchInfo();
                info.setBatchId(rs.getString("sim_batch_id"));
                info.setTripId(rs.getInt("trip_id"));
                info.setTripName(rs.getString("trip_name"));
                info.setStatus(rs.getString("status"));
                info.setCreatedAt(rs.getTimestamp("created_at"));
                info.setOwnerEmail(rs.getString("owner_email"));
                info.setUserCount(rs.getInt("user_count"));
                list.add(info);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to list simulated batches", e);
        }
        return list;
    }

    public SimulatedScenarioResult createScenario(String code, int memberCount, int adminUserId) {
        String scenarioCode = code == null ? "A" : code.trim().toUpperCase();
        if (memberCount < 1) memberCount = 1;
        if (memberCount > 6) memberCount = 6;

        String batchTag = UUID.randomUUID().toString().substring(0, 8);
        String batchId = "batch_" + batchTag + "_" + scenarioCode.toLowerCase();

        LocalDate today = AppClock.today();
        SimulatedScenarioResult result = new SimulatedScenarioResult();
        result.setBatchId(batchId);
        result.setScenarioCode(scenarioCode);

        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                // 1. Create simulated owner and members
                int ownerId = createSimUser(c, batchId, "Sim Owner " + scenarioCode, "sim_owner_" + batchTag + "@sim.localtrip.test");
                result.setOwnerEmail("sim_owner_" + batchTag + "@sim.localtrip.test");

                List<Integer> memberIds = new ArrayList<Integer>();
                memberIds.add(ownerId);
                for (int i = 1; i < memberCount; i++) {
                    String memEmail = "sim_member" + i + "_" + batchTag + "@sim.localtrip.test";
                    int memId = createSimUser(c, batchId, "Sim Member " + i + " (" + scenarioCode + ")", memEmail);
                    memberIds.add(memId);
                    result.getMemberEmails().add(memEmail);
                }

                // 2. Build Scenario Fixtures
                LocalDate start;
                LocalDate end;
                String tripName;
                String description;
                BigDecimal budget;

                switch (scenarioCode) {
                    case "B":
                        start = today;
                        end = today.plusDays(2);
                        tripName = "[SIM] B - Planning, ready (" + batchTag + ")";
                        description = "Ready to depart today! Click Start Trip to transition to ONGOING.";
                        budget = new BigDecimal("5000000");
                        break;
                    case "C":
                        start = today.minusDays(1);
                        end = today.plusDays(1);
                        tripName = "[SIM] C - Ongoing, live milestones (" + batchTag + ")";
                        description = "Happening right now! Spans today with live milestone tracking.";
                        budget = new BigDecimal("6000000");
                        break;
                    case "D":
                        start = today.minusDays(3);
                        end = today.minusDays(1);
                        tripName = "[SIM] D - Ongoing, ended (" + batchTag + ")";
                        description = "Scheduled dates have ended while status is still ONGOING. Shows trip-ended banner.";
                        budget = new BigDecimal("3500000");
                        break;
                    case "E":
                        start = today.minusDays(6);
                        end = today.minusDays(2);
                        tripName = "[SIM] E - Completed, settlements (" + batchTag + ")";
                        description = "Completed journey with full expense splits, group fund, and settlements.";
                        budget = new BigDecimal("10000000");
                        break;
                    case "F":
                        start = today.plusDays(3);
                        end = today.plusDays(5);
                        tripName = "[SIM] F - Cancelled (" + batchTag + ")";
                        description = "Cancelled trip prior to departure.";
                        budget = new BigDecimal("2000000");
                        break;
                    case "A":
                    default:
                        start = today.plusDays(7);
                        end = today.plusDays(9);
                        tripName = "[SIM] A - Planning, empty (" + batchTag + ")";
                        description = "Idea phase with 0 activities; ready to add places and companions.";
                        budget = new BigDecimal("2500000");
                        break;
                }

                int tripId = insertTripFixture(c, batchId, ownerId, tripName, "TP. Hồ Chí Minh", start, end, budget, description);
                result.setTripId(tripId);
                result.setTripName(tripName);
                result.setStartDate(start.toString());
                result.setEndDate(end.toString());

                // Add members
                for (int mId : memberIds) {
                    insertTripMember(c, tripId, mId, mId == ownerId ? "OWNER" : "MEMBER");
                }

                // Add member preferences
                for (int mId : memberIds) {
                    insertPreference(c, tripId, mId, 1); // Food
                    insertPreference(c, tripId, mId, 2); // Cafe
                    insertPreference(c, tripId, mId, 3); // Sightseeing
                }

                c.commit(); // Base fixture committed so DAOs can load connection/locks cleanly

                // 3. Populate activities & trigger business rule transitions via real DAOs
                populateScenarioActivitiesAndTransitions(c, scenarioCode, tripId, ownerId, memberIds, start, today, end, result);

            } catch (Exception e) {
                c.rollback();
                throw new RuntimeException("Failed to create scenario " + scenarioCode, e);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Database error in scenario creation", e);
        }

        // Audit log action
        auditLogDAO.log(adminUserId, "SCENARIO_LAB_LOAD", null,
                "Loaded scenario " + scenarioCode + " (tripId=" + result.getTripId() + ", batchId=" + batchId + ")");

        return result;
    }

    private void populateScenarioActivitiesAndTransitions(Connection c, String code, int tripId, int ownerId,
                                                          List<Integer> memberIds, LocalDate start, LocalDate today,
                                                          LocalDate end, SimulatedScenarioResult result) throws SQLException {
        if ("A".equals(code)) {
            result.setStatus("PLANNING");
            result.setActivityCount(0);
            result.setMessage("Scenario A created: Planning trip with 0 activities.");
            return;
        }

        if ("B".equals(code)) {
            List<Integer> itemIds = new ArrayList<Integer>();
            itemIds.add(insertActivity(tripId, 1, start, "08:30", "10:30", "Dinh Độc Lập Tour", 40000, "VISIT"));
            itemIds.add(insertActivity(tripId, 10, start, "11:30", "13:00", "Phở Hòa Pasteur Lunch", 90000, "MEAL"));
            itemIds.add(insertActivity(tripId, 5, start, "14:00", "16:00", "Coffee Break", 90000, "CAFE"));
            itemIds.add(insertActivity(tripId, 2, start, "16:30", "18:00", "Central Post Office Visit", 0, "VISIT"));
            itemIds.add(insertActivity(tripId, 3, start.plusDays(1), "09:00", "11:00", "Notre Dame Cathedral", 0, "VISIT"));
            itemIds.add(insertActivity(tripId, 4, start.plusDays(1), "14:00", "16:30", "Nguyễn Huệ Walking Street", 0, "VISIT"));

            result.setStatus("PLANNING");
            result.setActivityCount(itemIds.size());
            result.setMessage("Scenario B created: Ready to depart today! Click 'Start Trip' in trip details to start.");
            return;
        }

        if ("C".equals(code)) {
            // Day 1 (Yesterday)
            int item1 = insertActivity(tripId, 1, start, "09:00", "11:00", "Dinh Độc Lập", 40000, "VISIT");
            int item2 = insertActivity(tripId, 10, start, "12:00", "13:30", "Phở Hòa Pasteur", 90000, "MEAL");
            int item3 = insertActivity(tripId, 3, start, "15:00", "16:30", "Notre Dame Cathedral", 0, "VISIT");

            // Day 2 (Today)
            int item4 = insertActivity(tripId, 2, today, "09:00", "10:30", "Saigon Central Post Office", 0, "VISIT");
            int item5 = insertActivity(tripId, 5, today, "11:00", "13:00", "The Workshop Coffee Break", 90000, "CAFE");
            int item6 = insertActivity(tripId, 4, today, "18:00", "20:30", "Nguyễn Huệ Walking Street", 0, "VISIT");

            // Day 3 (Tomorrow)
            int item7 = insertActivity(tripId, 8, end, "09:00", "10:30", "Bánh mì Huỳnh Hoa Breakfast", 65000, "MEAL");

            // Transition trip to ONGOING via real TripStatusDAO
            boolean tripStarted = tripStatusDAO.changeStatus(tripId, ownerId, "PLANNING", "ONGOING", AppClock.todaySql());
            if (!tripStarted) {
                throw new IllegalStateException("Failed to transition trip " + tripId + " to ONGOING via TripStatusDAO");
            }

            // Transition activities via real ActivityLifecycleDAO
            // Yesterday items: completed & cancelled
            activityLifecycleDAO.changeStatus(tripId, item1, ownerId, "UPCOMING", "IN_PROGRESS");
            activityLifecycleDAO.changeStatus(tripId, item1, ownerId, "IN_PROGRESS", "COMPLETED");

            activityLifecycleDAO.changeStatus(tripId, item2, ownerId, "UPCOMING", "IN_PROGRESS");
            activityLifecycleDAO.changeStatus(tripId, item2, ownerId, "IN_PROGRESS", "COMPLETED");

            activityLifecycleDAO.changeStatus(tripId, item3, ownerId, "UPCOMING", "CANCELLED");

            // Today items: 1 completed, 1 currently IN_PROGRESS
            activityLifecycleDAO.changeStatus(tripId, item4, ownerId, "UPCOMING", "IN_PROGRESS");
            activityLifecycleDAO.changeStatus(tripId, item4, ownerId, "IN_PROGRESS", "COMPLETED");

            activityLifecycleDAO.changeStatus(tripId, item5, ownerId, "UPCOMING", "IN_PROGRESS"); // Live milestone!

            result.setStatus("ONGOING");
            result.setActivityCount(7);
            result.setMessage("Scenario C created: Ongoing trip with live milestones across all 4 statuses.");
            return;
        }

        if ("D".equals(code)) {
            insertActivity(tripId, 1, start, "09:00", "11:00", "Dinh Độc Lập", 40000, "VISIT");
            insertActivity(tripId, 10, end, "12:00", "13:30", "Phở Hòa Pasteur", 90000, "MEAL");

            // Direct update to ONGOING for ended dates
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE dbo.Trips SET status = 'ONGOING' WHERE trip_id = ?")) {
                ps.setInt(1, tripId);
                ps.executeUpdate();
            }

            result.setStatus("ONGOING");
            result.setActivityCount(2);
            result.setMessage("Scenario D created: Trip dates ended while status is ONGOING (ended-trip banner active).");
            return;
        }

        if ("E".equals(code)) {
            insertActivity(tripId, 1, start, "09:00", "11:30", "Dinh Độc Lập", 40000, "VISIT");
            insertActivity(tripId, 10, start.plusDays(1), "12:00", "13:30", "Phở Hòa Pasteur", 90000, "MEAL");
            insertActivity(tripId, 5, end, "14:00", "16:00", "The Workshop Coffee", 90000, "CAFE");

            // Mark as COMPLETED
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE dbo.Trips SET status = 'COMPLETED' WHERE trip_id = ?")) {
                ps.setInt(1, tripId);
                ps.executeUpdate();
            }

            // Create Group Fund & Expenses
            createExpensesAndSettlements(tripId, ownerId, memberIds);

            result.setStatus("COMPLETED");
            result.setActivityCount(3);
            result.setExpenseCount(2);
            result.setMessage("Scenario E created: Completed trip with group fund, expense splits, and settlement payments.");
            return;
        }

        if ("F".equals(code)) {
            insertActivity(tripId, 1, start, "09:00", "11:00", "Dinh Độc Lập", 40000, "VISIT");
            insertActivity(tripId, 5, start, "14:00", "16:00", "The Workshop Coffee", 90000, "CAFE");

            boolean cancelled = tripStatusDAO.changeStatus(tripId, ownerId, "PLANNING", "CANCELLED", AppClock.todaySql());
            if (!cancelled) {
                try (Connection conn = DBContext.getConnection();
                     PreparedStatement ps = conn.prepareStatement("UPDATE dbo.Trips SET status = 'CANCELLED' WHERE trip_id = ?")) {
                    ps.setInt(1, tripId);
                    ps.executeUpdate();
                }
            }

            result.setStatus("CANCELLED");
            result.setActivityCount(2);
            result.setMessage("Scenario F created: Cancelled trip prior to departure.");
        }
    }

    private void createExpensesAndSettlements(int tripId, int ownerId, List<Integer> memberIds) {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Group Fund Contribution (500,000 VND from owner)
                String fundSql = "INSERT INTO dbo.GroupFundContributions (trip_id, user_id, amount, note, created_by, created_at) "
                               + "VALUES (?, ?, 500000, N'Quỹ chung ban đầu (Initial fund)', ?, SYSDATETIME())";
                try (PreparedStatement ps = conn.prepareStatement(fundSql)) {
                    ps.setInt(1, tripId);
                    ps.setInt(2, ownerId);
                    ps.setInt(3, ownerId);
                    ps.executeUpdate();
                }

                // Expense 1: Paid by Owner (500,000 VND), Equal split
                int exp1Id;
                String exp1Sql = "INSERT INTO dbo.Expenses (trip_id, payer_id, created_by, description, amount, from_group_fund, created_at) "
                               + "VALUES (?, ?, ?, N'Vé tham quan & Hướng dẫn viên (Tour guide & Tickets)', 500000, 0, SYSDATETIME())";
                try (PreparedStatement ps = conn.prepareStatement(exp1Sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, tripId);
                    ps.setInt(2, ownerId);
                    ps.setInt(3, ownerId);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) { rs.next(); exp1Id = rs.getInt(1); }
                }

                BigDecimal split1 = new BigDecimal("500000").divide(new BigDecimal(memberIds.size()), 2, BigDecimal.ROUND_HALF_UP);
                String partSql = "INSERT INTO dbo.ExpenseParticipants (expense_id, user_id, share_amount) VALUES (?, ?, ?)";
                for (int mId : memberIds) {
                    try (PreparedStatement ps = conn.prepareStatement(partSql)) {
                        ps.setInt(1, exp1Id);
                        ps.setInt(2, mId);
                        ps.setBigDecimal(3, split1);
                        ps.executeUpdate();
                    }
                }

                // Expense 2: Paid by Member 1 (if available) or Owner
                int payer2 = memberIds.size() > 1 ? memberIds.get(1) : ownerId;
                int exp2Id;
                String exp2Sql = "INSERT INTO dbo.Expenses (trip_id, payer_id, created_by, description, amount, from_group_fund, created_at) "
                               + "VALUES (?, ?, ?, N'Bữa tối hải sản nướng (Seafood Dinner)', 1000000, 0, SYSDATETIME())";
                try (PreparedStatement ps = conn.prepareStatement(exp2Sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, tripId);
                    ps.setInt(2, payer2);
                    ps.setInt(3, payer2);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) { rs.next(); exp2Id = rs.getInt(1); }
                }

                BigDecimal split2 = new BigDecimal("1000000").divide(new BigDecimal(memberIds.size()), 2, BigDecimal.ROUND_HALF_UP);
                for (int mId : memberIds) {
                    try (PreparedStatement ps = conn.prepareStatement(partSql)) {
                        ps.setInt(1, exp2Id);
                        ps.setInt(2, mId);
                        ps.setBigDecimal(3, split2);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw new RuntimeException("Failed to insert expenses for scenario E", e);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Database error creating expenses", e);
        }

        // Calculate and sync settlements through real SettlementDAO
        try {
            List<SettlementBalance> balances = settlementDAO.findBalances(tripId);
            List<SettlementTransfer> transfers = settlementDAO.calculateTransfers(balances);
            settlementDAO.syncAndLoadPaymentStatuses(tripId, transfers);

            if (!transfers.isEmpty()) {
                SettlementTransfer t1 = transfers.get(0);
                settlementDAO.updatePaymentStatus(t1.getPaymentId(), tripId, t1.getFromMemberId(), "SENT");
                settlementDAO.updatePaymentStatus(t1.getPaymentId(), tripId, t1.getToMemberId(), "CONFIRMED");
            }
            if (transfers.size() > 1) {
                SettlementTransfer t2 = transfers.get(1);
                settlementDAO.updatePaymentStatus(t2.getPaymentId(), tripId, t2.getFromMemberId(), "SENT");
            }
        } catch (Exception ignored) {
            // Settlements can be recalculated at any time by user viewing the settlement page
        }
    }

    private int insertActivity(int tripId, int placeId, LocalDate date, String start, String end,
                               String title, int estCost, String type) {
        String sql = "INSERT INTO dbo.ItineraryItems (trip_id, place_id, visit_date, start_time, end_time, "
                   + "                               activity_title, estimated_cost, activity_type, activity_status, created_at, is_locked, source_type) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'UPCOMING', SYSDATETIME(), 1, 'MANUAL')";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, tripId);
            ps.setInt(2, placeId);
            ps.setDate(3, Date.valueOf(date));
            ps.setTime(4, Time.valueOf(start + ":00"));
            ps.setTime(5, Time.valueOf(end + ":00"));
            ps.setString(6, title);
            ps.setBigDecimal(7, new BigDecimal(estCost));
            ps.setString(8, type);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
            throw new RuntimeException("No generated key for itinerary item");
        } catch (SQLException e) {
            throw new RuntimeException("Failed to insert activity item", e);
        }
    }

    private int createSimUser(Connection c, String batchId, String fullName, String email) throws SQLException {
        String sql = "INSERT INTO dbo.Users (full_name, email, password_hash, role, is_active, sim_batch_id, created_at) "
                   + "VALUES (?, ?, ?, 'USER', 1, ?, SYSDATETIME())";

        try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, DEFAULT_SIM_HASH);
            ps.setString(4, batchId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new RuntimeException("Failed to create simulated user: " + email);
    }

    private int insertTripFixture(Connection c, String batchId, int ownerId, String name, String dest,
                                  LocalDate start, LocalDate end, BigDecimal budget, String desc) throws SQLException {
        String sql = "INSERT INTO dbo.Trips (owner_id, trip_name, destination, start_date, end_date, budget, description, status, sim_batch_id, created_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, 'PLANNING', ?, SYSDATETIME())";

        try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ownerId);
            ps.setString(2, name);
            ps.setString(3, dest);
            ps.setDate(4, Date.valueOf(start));
            ps.setDate(5, Date.valueOf(end));
            ps.setBigDecimal(6, budget);
            ps.setString(7, desc);
            ps.setString(8, batchId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new RuntimeException("Failed to insert trip fixture: " + name);
    }

    private void insertTripMember(Connection c, int tripId, int userId, String role) throws SQLException {
        String sql = "INSERT INTO dbo.TripMembers (trip_id, user_id, member_role, joined_at) VALUES (?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, tripId);
            ps.setInt(2, userId);
            ps.setString(3, role);
            ps.executeUpdate();
        }
    }

    private void insertPreference(Connection c, int tripId, int userId, int catId) throws SQLException {
        String sql = "INSERT INTO dbo.TripMemberPreferences (trip_id, user_id, category_id, created_at) VALUES (?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, tripId);
            ps.setInt(2, userId);
            ps.setInt(3, catId);
            ps.executeUpdate();
        }
    }

    public int purgeBatch(String batchId, int adminUserId) {
        if (batchId == null || batchId.trim().isEmpty()) return 0;
        String bId = batchId.trim();

        String[] purgeSqls = new String[] {
            "DELETE FROM dbo.CheckInImages WHERE checkin_id IN (SELECT checkin_id FROM dbo.CheckIns WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?))",
            "DELETE FROM dbo.CheckIns WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?) OR user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.ExpenseParticipants WHERE expense_id IN (SELECT expense_id FROM dbo.Expenses WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?))",
            "DELETE FROM dbo.Expenses WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.SettlementPayments WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.GroupFundContributions WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.ItineraryItems WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.TripNotes WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.TripInvites WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.TripMemberPreferences WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.TripMembers WHERE trip_id IN (SELECT trip_id FROM dbo.Trips WHERE sim_batch_id = ?) OR user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.PostImages WHERE post_id IN (SELECT post_id FROM dbo.Posts WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?))",
            "DELETE FROM dbo.PostLikes WHERE post_id IN (SELECT post_id FROM dbo.Posts WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)) OR user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.PostComments WHERE post_id IN (SELECT post_id FROM dbo.Posts WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)) OR user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.PostBookmarks WHERE post_id IN (SELECT post_id FROM dbo.Posts WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)) OR user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.PostReports WHERE post_id IN (SELECT post_id FROM dbo.Posts WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)) OR reporter_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.Posts WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.Friendships WHERE requester_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?) OR addressee_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.Notifications WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?) OR actor_user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.TravelPassportSettings WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.UserBadges WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.RememberMeTokens WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.PasswordResetTokens WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.LoginLogs WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE sim_batch_id = ?)",
            "DELETE FROM dbo.Trips WHERE sim_batch_id = ?",
            "DELETE FROM dbo.Users WHERE sim_batch_id = ?"
        };

        int deletedTrips = 0;
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                for (String sql : purgeSqls) {
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        int paramCount = countQuestionMarks(sql);
                        for (int i = 1; i <= paramCount; i++) {
                            ps.setString(i, bId);
                        }
                        int affected = ps.executeUpdate();
                        if (sql.startsWith("DELETE FROM dbo.Trips")) {
                            deletedTrips = affected;
                        }
                    }
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw new RuntimeException("Failed to purge batch: " + bId, e);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Database error purging batch", e);
        }

        auditLogDAO.log(adminUserId, "PURGE_SIM_BATCH", null, "Purged simulated batch " + bId);
        return deletedTrips;
    }

    public int purgeAll(int adminUserId) {
        List<SimulatedBatchInfo> batches = listBatches();
        int total = 0;
        for (SimulatedBatchInfo b : batches) {
            total += purgeBatch(b.getBatchId(), adminUserId);
        }
        auditLogDAO.log(adminUserId, "PURGE_ALL_SIM", null, "Purged all simulated batches (total trips=" + total + ")");
        return total;
    }

    private int countQuestionMarks(String sql) {
        int count = 0;
        for (int i = 0; i < sql.length(); i++) {
            if (sql.charAt(i) == '?') count++;
        }
        return count;
    }
}
