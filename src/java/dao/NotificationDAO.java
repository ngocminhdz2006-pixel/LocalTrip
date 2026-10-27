package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import model.Notification;

public class NotificationDAO {

    public boolean insert(int userId, Integer actorUserId, String type, Integer tripId, Integer refId, String message) {
        String sql = "INSERT INTO dbo.Notifications (user_id, actor_user_id, type, trip_id, ref_id, message, is_read, created_at) "
                   /* AUDIT: Notification dispatch timestamp must record real wall clock time */ + "VALUES (?, ?, ?, ?, ?, ?, 0, SYSDATETIME())";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            if (actorUserId != null && actorUserId > 0) {
                ps.setInt(2, actorUserId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, type);
            if (tripId != null && tripId > 0) {
                ps.setInt(4, tripId);
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            if (refId != null && refId > 0) {
                ps.setInt(5, refId);
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setString(6, message);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to insert notification for user " + userId, e);
        }
    }

    public boolean coalesceItineraryNotification(int userId, Integer actorUserId, String type, int tripId, Integer refId, String message, int windowMinutes) {
        String findSql = "SELECT TOP 1 notification_id FROM dbo.Notifications "
                       + "WHERE user_id = ? AND trip_id = ? AND type = ? AND is_read = 0 "
                       /* SECURITY: Notification deduplication window must track real wall clock time */ + "AND created_at >= DATEADD(minute, -?, SYSDATETIME()) "
                       + "ORDER BY created_at DESC";

        /* AUDIT: Notification update timestamp must record real wall clock time */ String updateSql = "UPDATE dbo.Notifications SET message = ?, actor_user_id = ?, ref_id = ?, created_at = SYSDATETIME() "
                         + "WHERE notification_id = ?";

        try (Connection con = DBContext.getConnection()) {
            Integer existingId = null;
            try (PreparedStatement ps = con.prepareStatement(findSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, tripId);
                ps.setString(3, type);
                ps.setInt(4, windowMinutes > 0 ? windowMinutes : 5);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt(1);
                    }
                }
            }

            if (existingId != null && existingId > 0) {
                try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                    ps.setString(1, message);
                    if (actorUserId != null && actorUserId > 0) {
                        ps.setInt(2, actorUserId);
                    } else {
                        ps.setNull(2, Types.INTEGER);
                    }
                    if (refId != null && refId > 0) {
                        ps.setInt(3, refId);
                    } else {
                        ps.setNull(3, Types.INTEGER);
                    }
                    ps.setInt(4, existingId);
                    return ps.executeUpdate() > 0;
                }
            } else {
                return insert(userId, actorUserId, type, tripId, refId, message);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to coalesce notification for user " + userId, e);
        }
    }

    public List<Notification> findByUser(int userId, int limit, int offset) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT n.notification_id, n.user_id, n.actor_user_id, u.full_name AS actor_name, "
                   + "       n.type, n.trip_id, t.trip_name, n.ref_id, n.message, n.is_read, n.created_at "
                   + "FROM dbo.Notifications n "
                   + "LEFT JOIN dbo.Users u ON u.user_id = n.actor_user_id "
                   + "LEFT JOIN dbo.Trips t ON t.trip_id = n.trip_id "
                   + "WHERE n.user_id = ? "
                   + "ORDER BY n.created_at DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, Math.max(0, offset));
            ps.setInt(3, limit > 0 ? limit : 20);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setNotificationId(rs.getInt("notification_id"));
                    n.setUserId(rs.getInt("user_id"));
                    int actorId = rs.getInt("actor_user_id");
                    n.setActorUserId(rs.wasNull() ? null : actorId);
                    n.setActorName(rs.getString("actor_name"));
                    n.setType(rs.getString("type"));
                    int tripId = rs.getInt("trip_id");
                    n.setTripId(rs.wasNull() ? null : tripId);
                    n.setTripName(rs.getString("trip_name"));
                    int refId = rs.getInt("ref_id");
                    n.setRefId(rs.wasNull() ? null : refId);
                    n.setMessage(rs.getString("message"));
                    n.setRead(rs.getBoolean("is_read"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to load notifications for user " + userId, e);
        }
        return list;
    }

    public int countUnread(int userId) {
        String sql = "SELECT COUNT(1) FROM dbo.Notifications WHERE user_id = ? AND is_read = 0";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            return 0;
        }
    }

    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE dbo.Notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to mark notification as read", e);
        }
    }

    public int markAllAsRead(int userId) {
        String sql = "UPDATE dbo.Notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to mark all notifications as read", e);
        }
    }
}
