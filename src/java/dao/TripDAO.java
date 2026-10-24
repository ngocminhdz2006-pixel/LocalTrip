package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Trip;

public class TripDAO {

    public List<Trip> findByUser(int userId) {
        List<Trip> trips = new ArrayList<>();

        String sql
                = "SELECT t.trip_id, t.owner_id, t.trip_name, "
                + "t.destination, t.start_date, t.end_date, "
                + "t.budget, t.description, t.status, t.created_at, t.applied_combo_id, "
                + "CASE WHEN t.owner_id = ? "
                + "THEN 'OWNER' ELSE tm.member_role END AS user_role "
                + "FROM Trips t "
                + "LEFT JOIN TripMembers tm "
                + "ON tm.trip_id = t.trip_id AND tm.user_id = ? "
                + "WHERE t.owner_id = ? OR tm.user_id IS NOT NULL "
                + "ORDER BY t.created_at DESC, t.trip_id DESC";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setInt(2, userId);
            statement.setInt(3, userId);

            try ( ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    trips.add(mapTrip(resultSet));
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Unable to load trips list.",
                    e
            );
        }

        return trips;
    }

    public Trip findByIdForUser(int tripId, int userId) {

        String sql
                = "SELECT t.trip_id, t.owner_id, t.trip_name, "
                + "t.destination, t.start_date, t.end_date, "
                + "t.budget, t.description, t.status, t.created_at, t.applied_combo_id, "
                + "CASE WHEN t.owner_id = ? "
                + "THEN 'OWNER' ELSE tm.member_role END AS user_role "
                + "FROM Trips t "
                + "LEFT JOIN TripMembers tm "
                + "ON tm.trip_id = t.trip_id AND tm.user_id = ? "
                + "WHERE t.trip_id = ? "
                + "AND (t.owner_id = ? OR tm.user_id IS NOT NULL)";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setInt(2, userId);
            statement.setInt(3, tripId);
            statement.setInt(4, userId);

            try ( ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapTrip(resultSet);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Unable to load trip.",
                    e
            );
        }

        return null;
    }

    public Trip findById(int tripId) {
        String sql = "SELECT trip_id, owner_id, trip_name, destination, start_date, "
                   + "end_date, budget, description, status, created_at, applied_combo_id "
                   + "FROM Trips WHERE trip_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tripId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Trip trip = new Trip();
                    trip.setId(rs.getInt("trip_id"));
                    trip.setOwnerId(rs.getInt("owner_id"));
                    trip.setTripName(rs.getString("trip_name"));
                    trip.setName(rs.getString("trip_name"));
                    trip.setDestination(rs.getString("destination"));
                    trip.setStartDate(rs.getDate("start_date"));
                    trip.setEndDate(rs.getDate("end_date"));
                    trip.setBudget(rs.getBigDecimal("budget"));
                    trip.setDescription(rs.getString("description"));
                    trip.setStatus(rs.getString("status"));
                    trip.setCreatedAt(rs.getTimestamp("created_at"));
                    int comboId = rs.getInt("applied_combo_id");
                    if (!rs.wasNull()) {
                        trip.setAppliedComboId(comboId);
                    }
                    return trip;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Unable to load trip by id: " + tripId, e);
        }
        return null;
    }

    public int create(Trip trip, int ownerId) {

        String insertTrip
                = "INSERT INTO Trips "
                + "(owner_id, trip_name, destination, start_date, "
                + "end_date, budget, description, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        String insertOwner
                = "INSERT INTO TripMembers "
                + "(trip_id, user_id, member_role) "
                + "VALUES (?, ?, 'OWNER')";

        try ( Connection connection = DBContext.getConnection()) {

            boolean originalAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);

            try {
                int tripId;

                try ( PreparedStatement statement
                        = connection.prepareStatement(
                                insertTrip,
                                Statement.RETURN_GENERATED_KEYS
                        )) {

                            statement.setInt(1, ownerId);
                            statement.setString(2, trip.getTripName());
                            statement.setString(3, trip.getDestination());
                            statement.setDate(4, trip.getStartDate());
                            statement.setDate(5, trip.getEndDate());
                            statement.setBigDecimal(6, trip.getBudget());
                            statement.setString(7, trip.getDescription());
                            statement.setString(8, trip.getStatus());

                            if (statement.executeUpdate() == 0) {
                                connection.rollback();
                                return -1;
                            }

                            try ( ResultSet keys
                                    = statement.getGeneratedKeys()) {

                                if (!keys.next()) {
                                    connection.rollback();
                                    return -1;
                                }

                                tripId = keys.getInt(1);
                            }
                        }

                        try ( PreparedStatement statement
                                = connection.prepareStatement(insertOwner)) {

                            statement.setInt(1, tripId);
                            statement.setInt(2, ownerId);
                            statement.executeUpdate();
                        }

                        connection.commit();
                        return tripId;

            } catch (SQLException e) {
                connection.rollback();
                throw e;

            } finally {
                connection.setAutoCommit(originalAutoCommit);
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Unable to create trip.",
                    e
            );
        }
    }

    public boolean updateByOwner(Trip trip, int ownerId) {

        String sql
                = "UPDATE Trips SET "
                + "trip_name = ?, "
                + "destination = ?, "
                + "start_date = ?, "
                + "end_date = ?, "
                + "budget = ?, "
                + "description = ?, "
                + "status = ? "
                + "WHERE trip_id = ? AND owner_id = ?";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setString(1, trip.getTripName());
            statement.setString(2, trip.getDestination());
            statement.setDate(3, trip.getStartDate());
            statement.setDate(4, trip.getEndDate());
            statement.setBigDecimal(5, trip.getBudget());
            statement.setString(6, trip.getDescription());
            statement.setString(7, trip.getStatus());
            statement.setInt(8, trip.getTripId());
            statement.setInt(9, ownerId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Unable to update trip.",
                    e
            );
        }
    }

    public boolean isOwner(int tripId, int userId) {

        String sql
                = "SELECT 1 FROM Trips "
                + "WHERE trip_id = ? AND owner_id = ?";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, tripId);
            statement.setInt(2, userId);

            try ( ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Failed to verify trip ownership.",
                    e
            );
        }
    }

    private Trip mapTrip(ResultSet resultSet)
            throws SQLException {

        Trip trip = new Trip();

        trip.setTripId(resultSet.getInt("trip_id"));
        trip.setOwnerId(resultSet.getInt("owner_id"));
        trip.setTripName(resultSet.getString("trip_name"));
        trip.setDestination(resultSet.getString("destination"));
        trip.setStartDate(resultSet.getDate("start_date"));
        trip.setEndDate(resultSet.getDate("end_date"));
        trip.setBudget(resultSet.getBigDecimal("budget"));
        trip.setDescription(resultSet.getString("description"));
        trip.setStatus(resultSet.getString("status"));
        trip.setCreatedAt(resultSet.getTimestamp("created_at"));
        trip.setRole(resultSet.getString("user_role"));

        try {
            Object comboObj = resultSet.getObject("applied_combo_id");
            if (comboObj instanceof Number) {
                trip.setAppliedComboId(((Number) comboObj).intValue());
            }
        } catch (SQLException ignored) {
        }

        return trip;
    }

    public boolean deletePlanningTrip(int tripId, int ownerId) {
        try ( Connection connection = DBContext.getConnection()) {
            connection.setTransactionIsolation(
                    Connection.TRANSACTION_SERIALIZABLE
            );
            connection.setAutoCommit(false);

            try {
                String checkSql
                        = "SELECT status FROM dbo.Trips "
                        + "WITH (UPDLOCK, HOLDLOCK) "
                        + "WHERE trip_id = ? AND owner_id = ?";
                try ( PreparedStatement statement
                        = connection.prepareStatement(checkSql)) {
                    statement.setInt(1, tripId);
                    statement.setInt(2, ownerId);

                    try ( ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            throw new IllegalArgumentException(
                                    "Trip not found or you lack permission to delete."
                            );
                        }

                        if (!"PLANNING".equals(result.getString("status"))) {
                            throw new IllegalArgumentException(
                                    "Only planning trips can be permanently deleted. "
                                    + "Ongoing, completed, or cancelled trips "
                                    + "are retained for history."
                            );
                        }
                    }
                }

                String financeSql
                        = "SELECT "
                        + "(SELECT COUNT(*) FROM dbo.Expenses "
                        + "WHERE trip_id = ?) AS expense_count, "
                        + "(SELECT COUNT(*) FROM dbo.GroupFundContributions "
                        + "WHERE trip_id = ?) AS contribution_count";

                try ( PreparedStatement statement
                        = connection.prepareStatement(financeSql)) {
                    statement.setInt(1, tripId);
                    statement.setInt(2, tripId);

                    try ( ResultSet result = statement.executeQuery()) {
                        result.next();

                        if (!result.next()) {
                            throw new IllegalArgumentException(
                                    "Trip not found or you lack permission to delete."
                            );
                        }

                        if (!"PLANNING".equals(result.getString("status"))) {
                            throw new IllegalArgumentException(
                                    "Only planning trips can be permanently deleted. "
                                    + "Ongoing, completed, or cancelled trips "
                                    + "are retained for history."
                            );
                        }
                    }
                }

                String[] deleteStatements = {
                    "DELETE FROM dbo.TripMemberPreferences WHERE trip_id = ?",
                    "DELETE FROM dbo.ItineraryItems WHERE trip_id = ?",
                    "DELETE FROM dbo.TripMembers WHERE trip_id = ?",
                    "DELETE FROM dbo.Trips WHERE trip_id = ?"
                };

                for (String sql : deleteStatements) {
                    try ( PreparedStatement statement
                            = connection.prepareStatement(sql)) {
                        statement.setInt(1, tripId);
                        statement.executeUpdate();
                    }
                }

                connection.commit();
                return true;

            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Unable to delete trip.", e
            );
        }
    }
    public void setAppliedCombo(int tripId, Integer comboId) {
        String sql = "UPDATE dbo.Trips SET applied_combo_id = ? WHERE trip_id = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            if (comboId == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, comboId);
            }
            ps.setInt(2, tripId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Unable to update applied combo on trip.", e);
        }
    }
}