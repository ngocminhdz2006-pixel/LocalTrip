package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import model.GroupPreference;

public class PreferenceDAO {

    public Set<Integer> findSelectedCategoryIds(
            int tripId,
            int userId) {

        Set<Integer> selectedIds = new LinkedHashSet<>();

        String sql
                = "SELECT category_id "
                + "FROM TripMemberPreferences "
                + "WHERE trip_id = ? AND user_id = ? "
                + "ORDER BY category_id";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, tripId);
            statement.setInt(2, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    selectedIds.add(resultSet.getInt("category_id"));
                }
            }

            // Fallback to profile preferences if trip-level preferences not set
            if (selectedIds.isEmpty()) {
                selectedIds = getUserPreferences(userId);
            }

        } catch (SQLException e) {
            throw new RuntimeException("Unable to load travel preferences.", e);
        }

        return selectedIds;
    }

    public void savePreferences(int tripId,
            int userId,
            Set<Integer> categoryIds) {

        String deleteSql
                = "DELETE FROM TripMemberPreferences "
                + "WHERE trip_id = ? AND user_id = ?";

        String insertSql
                = "INSERT INTO TripMemberPreferences "
                + "(trip_id, user_id, category_id) "
                + "VALUES (?, ?, ?)";

        try (Connection connection = DBContext.getConnection()) {

            boolean originalAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);

            try {
                try (PreparedStatement deleteStatement = connection.prepareStatement(deleteSql)) {
                    deleteStatement.setInt(1, tripId);
                    deleteStatement.setInt(2, userId);
                    deleteStatement.executeUpdate();
                }

                if (categoryIds != null && !categoryIds.isEmpty()) {
                    try (PreparedStatement insertStatement = connection.prepareStatement(insertSql)) {
                        for (Integer categoryId : categoryIds) {
                            if (categoryId == null || categoryId <= 0) {
                                continue;
                            }
                            insertStatement.setInt(1, tripId);
                            insertStatement.setInt(2, userId);
                            insertStatement.setInt(3, categoryId);
                            insertStatement.addBatch();
                        }
                        insertStatement.executeBatch();
                    }
                }

                connection.commit();

            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(originalAutoCommit);
            }

        } catch (SQLException e) {
            throw new RuntimeException("Unable to save travel preferences.", e);
        }
    }

    /**
     * Retrieves the user's personal travel preferences from profile.
     */
    public Set<Integer> getUserPreferences(int userId) {
        Set<Integer> result = new LinkedHashSet<>();
        String sql = "SELECT category_id FROM dbo.UserPreferences WHERE user_id = ? ORDER BY category_id";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    result.add(resultSet.getInt("category_id"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Unable to load user profile preferences.", e);
        }

        return result;
    }

    /**
     * Saves user's personal travel preferences in profile (Zero-Click matching).
     */
    public void saveUserPreferences(int userId, List<Integer> categoryIds) {
        String deleteSql = "DELETE FROM dbo.UserPreferences WHERE user_id = ?";
        String insertSql = "INSERT INTO dbo.UserPreferences (user_id, category_id) VALUES (?, ?)";

        try (Connection connection = DBContext.getConnection()) {
            boolean originalAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);

            try {
                try (PreparedStatement deleteStatement = connection.prepareStatement(deleteSql)) {
                    deleteStatement.setInt(1, userId);
                    deleteStatement.executeUpdate();
                }

                if (categoryIds != null && !categoryIds.isEmpty()) {
                    try (PreparedStatement insertStatement = connection.prepareStatement(insertSql)) {
                        for (Integer categoryId : categoryIds) {
                            if (categoryId == null || categoryId <= 0) {
                                continue;
                            }
                            insertStatement.setInt(1, userId);
                            insertStatement.setInt(2, categoryId);
                            insertStatement.addBatch();
                        }
                        insertStatement.executeBatch();
                    }
                }

                connection.commit();
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(originalAutoCommit);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Unable to save user profile preferences.", e);
        }
    }

    public int countTripMembers(int tripId) {
        String sql
                = "SELECT COUNT(DISTINCT user_id) FROM ("
                + "  SELECT owner_id AS user_id FROM Trips WHERE trip_id = ? "
                + "  UNION "
                + "  SELECT user_id FROM TripMembers WHERE trip_id = ?"
                + ") m";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, tripId);
            statement.setInt(2, tripId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("Unable to count trip members.", e);
        }

        return 0;
    }

    public List<GroupPreference> findGroupPreferences(int tripId) {
        List<GroupPreference> result = new ArrayList<>();
        int totalMembers = countTripMembers(tripId);

        // Check if any specific TripMemberPreferences exist for this trip
        boolean hasTripOverrides = false;
        String checkSql = "SELECT TOP 1 1 FROM TripMemberPreferences WHERE trip_id = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement checkStmt = connection.prepareStatement(checkSql)) {
            checkStmt.setInt(1, tripId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                hasTripOverrides = rs.next();
            }
        } catch (SQLException e) {
            // Ignore, proceed with default logic
        }

        String sql;
        if (hasTripOverrides) {
            sql = "SELECT c.category_id, c.category_code, c.category_name, COUNT(DISTINCT p.user_id) AS member_count "
                + "FROM Categories c "
                + "INNER JOIN TripMemberPreferences p ON p.category_id = c.category_id "
                + "WHERE p.trip_id = ? "
                + "GROUP BY c.category_id, c.category_code, c.category_name "
                + "ORDER BY member_count DESC, c.category_name";
        } else {
            // Fallback: Aggregate from UserPreferences across all trip members & owner
            sql = "WITH GroupMembers AS ("
                + "  SELECT owner_id AS user_id FROM dbo.Trips WHERE trip_id = ? "
                + "  UNION "
                + "  SELECT user_id FROM dbo.TripMembers WHERE trip_id = ?"
                + ") "
                + "SELECT c.category_id, c.category_code, c.category_name, COUNT(DISTINCT up.user_id) AS member_count "
                + "FROM dbo.Categories c "
                + "INNER JOIN dbo.UserPreferences up ON up.category_id = c.category_id "
                + "INNER JOIN GroupMembers gm ON gm.user_id = up.user_id "
                + "GROUP BY c.category_id, c.category_code, c.category_name "
                + "ORDER BY member_count DESC, c.category_name";
        }

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, tripId);
            if (!hasTripOverrides) {
                statement.setInt(2, tripId);
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    GroupPreference item = new GroupPreference();
                    item.setCategoryId(resultSet.getInt("category_id"));
                    item.setCategoryCode(resultSet.getString("category_code"));
                    item.setCategoryName(resultSet.getString("category_name"));

                    int memberCount = resultSet.getInt("member_count");
                    item.setMemberCount(memberCount);

                    double percentage = totalMembers <= 0
                            ? 0
                            : memberCount * 100.0 / totalMembers;
                    item.setPercentage(percentage);

                    result.add(item);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("Unable to aggregate group preferences.", e);
        }

        return result;
    }
}
