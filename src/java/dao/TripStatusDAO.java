package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class TripStatusDAO {

    public boolean changeStatus(
            int tripId,
            int ownerId,
            String currentStatus,
            String newStatus,
            Date today) {

        boolean allowed =
                ("PLANNING".equals(currentStatus)
                && ("ONGOING".equals(newStatus)
                || "CANCELLED".equals(newStatus)))
                || ("ONGOING".equals(currentStatus)
                && ("COMPLETED".equals(newStatus)
                || "CANCELLED".equals(newStatus)));

        if (!allowed) {
            return false;
        }

        String sql =
                "UPDATE dbo.Trips SET status = ? "
                + "WHERE trip_id = ? AND owner_id = ? AND status = ? ";

        if ("ONGOING".equals(newStatus)) {
            sql += "AND start_date <= ? AND end_date >= ? "
                    + "AND EXISTS ("
                    + "SELECT 1 FROM dbo.ItineraryItems i "
                    + "WHERE i.trip_id = Trips.trip_id)";
        }

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, newStatus);
            statement.setInt(2, tripId);
            statement.setInt(3, ownerId);
            statement.setString(4, currentStatus);

            if ("ONGOING".equals(newStatus)) {
                statement.setDate(5, today);
                statement.setDate(6, today);
            }

            return statement.executeUpdate() == 1;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể cập nhật trạng thái chuyến đi.", e
            );
        }
    }
}