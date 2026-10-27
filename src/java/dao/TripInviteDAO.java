package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.TripInvite;

public class TripInviteDAO {

    private static final Logger LOGGER = Logger.getLogger(TripInviteDAO.class.getName());

    public TripInvite getActiveInvite(int tripId) {
        String sql = "SELECT invite_id, trip_id, invite_token, created_by, expires_at, is_active, created_at "
                   + "FROM TripInvites "
                   /* SECURITY: Invite link validity check must use real wall clock time */ + "WHERE trip_id = ? AND is_active = 1 AND expires_at > SYSDATETIME() "
                   + "ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tripId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to fetch active invite for trip " + tripId, e);
        }
        return null;
    }

    public TripInvite createOrRenewInvite(int tripId, int createdBy) {
        // Deactivate old invites
        String deactivateSql = "UPDATE TripInvites SET is_active = 0 WHERE trip_id = ?";
        String insertSql = "INSERT INTO TripInvites (trip_id, invite_token, created_by, expires_at, is_active) "
                         + "VALUES (?, ?, ?, ?, 1)";

        String token = UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID().toString().replace("-", "");
        // 30 days validity
        // SECURITY: Invite token expiration must track real wall clock time
        Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + 30L * 24 * 3600 * 1000);

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psDeact = conn.prepareStatement(deactivateSql);
                 PreparedStatement psInsert = conn.prepareStatement(insertSql)) {

                psDeact.setInt(1, tripId);
                psDeact.executeUpdate();

                psInsert.setInt(1, tripId);
                psInsert.setString(2, token);
                psInsert.setInt(3, createdBy);
                psInsert.setTimestamp(4, expiresAt);
                psInsert.executeUpdate();

                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }

            return getActiveInvite(tripId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create or renew trip invite", e);
            return null;
        }
    }

    public TripInvite findByToken(String token) {
        if (token == null || token.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT invite_id, trip_id, invite_token, created_by, expires_at, is_active, created_at "
                   + "FROM TripInvites "
                   /* SECURITY: Invite link lookup must use real wall clock time */ + "WHERE invite_token = ? AND is_active = 1 AND expires_at > SYSDATETIME()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to find trip invite by token: " + token, e);
        }
        return null;
    }

    private TripInvite map(ResultSet rs) throws SQLException {
        TripInvite inv = new TripInvite();
        inv.setInviteId(rs.getInt("invite_id"));
        inv.setTripId(rs.getInt("trip_id"));
        inv.setInviteToken(rs.getString("invite_token"));
        inv.setCreatedBy(rs.getInt("created_by"));
        inv.setExpiresAt(rs.getTimestamp("expires_at"));
        inv.setActive(rs.getBoolean("is_active"));
        inv.setCreatedAt(rs.getTimestamp("created_at"));
        return inv;
    }
}
