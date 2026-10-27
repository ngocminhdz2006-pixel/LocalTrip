package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ComboTemplateStatusDAO {

    public void changeStatus(
            int comboId,
            int adminId,
            String expectedStatus,
            String newStatus) {

        boolean activate =
                "ACTIVE".equals(newStatus)
                && ("DRAFT".equals(expectedStatus)
                    || "INACTIVE".equals(expectedStatus));

        boolean deactivate =
                "INACTIVE".equals(newStatus)
                && "ACTIVE".equals(expectedStatus);

        if (comboId <= 0 || (!activate && !deactivate)) {
            throw new IllegalArgumentException(
                    "Invalid status transition.");
        }

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);

            try {
                checkAdmin(connection, adminId);

                int durationDays = lockCombo(
                        connection, comboId, expectedStatus);

                if (activate) {
                    validateForActivation(
                            connection, comboId, durationDays);
                }

                String sql =
                        "UPDATE dbo.ComboTemplates "
                        /* AUDIT: Modification timestamp must record real wall clock time */ + "SET status = ?, updated_at = SYSDATETIME() "
                        + "WHERE combo_id = ? AND status = ?";

                try (PreparedStatement ps =
                        connection.prepareStatement(sql)) {

                    ps.setString(1, newStatus);
                    ps.setInt(2, comboId);
                    ps.setString(3, expectedStatus);

                    if (ps.executeUpdate() != 1) {
                        throw new IllegalArgumentException(
                                "Combo was modified. Please reload the page.");
                    }
                }

                connection.commit();

            } catch (SQLException | RuntimeException e) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                throw e;
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Failed to change combo status.", e);
        }
    }

    private void checkAdmin(
            Connection connection, int adminId) throws SQLException {

        String sql =
                "SELECT 1 FROM dbo.Users WITH (HOLDLOCK) "
                + "WHERE user_id = ? "
                + "AND role = 'ADMIN' AND is_active = 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, adminId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException(
                            "Account does not have permission to manage combos.");
                }
            }
        }
    }

    private int lockCombo(
            Connection connection,
            int comboId,
            String expectedStatus) throws SQLException {

        String sql =
                "SELECT status, duration_days "
                + "FROM dbo.ComboTemplates WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE combo_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, comboId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException(
                            "Combo not found.");
                }

                if (!expectedStatus.equals(rs.getString("status"))) {
                    throw new IllegalArgumentException(
                            "Combo status has changed. "
                            + "Please reload the page.");
                }

                return rs.getInt("duration_days");
            }
        }
    }

    private void validateForActivation(
            Connection connection,
            int comboId,
            int durationDays) throws SQLException {

        String categorySql =
                "SELECT TOP (1) category_id "
                + "FROM dbo.ComboTemplateCategories WITH (HOLDLOCK) "
                + "WHERE combo_id = ?";

        try (PreparedStatement ps =
                connection.prepareStatement(categorySql)) {

            ps.setInt(1, comboId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException(
                            "Combo requires at least one category tag.");
                }
            }
        }

        String daysSql =
                "SELECT day_number, "
                + "SUM(CASE WHEN activity_type = 'MEAL' "
                + "THEN 1 ELSE 0 END) AS meal_count, "
                + "SUM(CASE WHEN activity_type IN ('REST', 'CAFE') "
                + "THEN 1 ELSE 0 END) AS break_count "
                + "FROM dbo.ComboTemplateItems WITH (HOLDLOCK) "
                + "WHERE combo_id = ? "
                + "GROUP BY day_number "
                + "ORDER BY day_number";

        int expectedDay = 1;

        try (PreparedStatement ps = connection.prepareStatement(daysSql)) {
            ps.setInt(1, comboId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int day = rs.getInt("day_number");

                    if (day != expectedDay || day > durationDays) {
                        throw new IllegalArgumentException(
                                "Combo must have continuous activities "
                                + "from Day 1 to the last day.");
                    }

                    if (rs.getInt("meal_count") < 1) {
                        throw new IllegalArgumentException(
                                "Day " + day
                                + " requires at least one dining activity.");
                    }

                    if (rs.getInt("break_count") < 1) {
                        throw new IllegalArgumentException(
                                "Day " + day
                                + " requires at least one rest or coffee activity.");
                    }

                    expectedDay++;
                }
            }
        }

        if (expectedDay != durationDays + 1) {
            throw new IllegalArgumentException(
                    "Combo does not have enough activities for all days.");
        }

        rejectIfFound(connection, comboId,
                "SELECT TOP (1) i.combo_item_id "
                + "FROM dbo.ComboTemplateItems i WITH (HOLDLOCK) "
                + "JOIN dbo.ComboTemplates c ON c.combo_id = i.combo_id "
                + "LEFT JOIN dbo.Places p WITH (HOLDLOCK) "
                + "ON p.place_id = i.place_id "
                + "LEFT JOIN dbo.Categories cat "
                + "ON cat.category_id = p.category_id "
                + "WHERE i.combo_id = ? AND ("
                + "i.end_time <= i.start_time "
                + "OR NULLIF(LTRIM(RTRIM(i.activity_title)), N'') IS NULL "
                + "OR (i.activity_type <> 'REST' AND i.place_id IS NULL) "
                + "OR (i.place_id IS NOT NULL AND ("
                + "p.place_id IS NULL OR p.is_active = 0 "
                + "OR p.city_name IS NULL OR p.district_name IS NULL "
                + "OR p.city_name <> c.city_name "
                + "OR p.district_name <> c.district_name "
                + "OR p.opening_time IS NULL "
                + "OR p.closing_time IS NULL "
                + "OR p.closing_time <= p.opening_time "
                + "OR i.start_time < p.opening_time "
                + "OR i.end_time > p.closing_time "
                + "OR (i.activity_type = 'MEAL' "
                + "AND cat.category_code <> 'FOOD') "
                + "OR (i.activity_type = 'CAFE' "
                + "AND cat.category_code <> 'CAFE')"
                + "))"
                + ")",
                "Invalid activity: check place, "
                + "region, activity type, and opening hours.");

        rejectIfFound(connection, comboId,
                "SELECT place_id "
                + "FROM dbo.ComboTemplateItems WITH (HOLDLOCK) "
                + "WHERE combo_id = ? AND place_id IS NOT NULL "
                + "GROUP BY place_id HAVING COUNT(*) > 1",
                "Combo has duplicate places.");

        rejectIfFound(connection, comboId,
                "WITH Schedule AS ("
                + " SELECT day_number, start_time, "
                + " LAG(end_time) OVER ("
                + " PARTITION BY day_number "
                + " ORDER BY start_time, combo_item_id"
                + " ) AS previous_end "
                + " FROM dbo.ComboTemplateItems WITH (HOLDLOCK) "
                + " WHERE combo_id = ?"
                + ") "
                + "SELECT TOP (1) day_number FROM Schedule "
                + "WHERE previous_end > start_time",
                "Activities have overlapping times.");

        /*
         * Chỉ xét các điểm có địa điểm.
         * Khoảng nghỉ giữa chúng vẫn được tính vào thời gian đệm.
         */
        rejectIfFound(connection, comboId,
                "WITH PlaceSchedule AS ("
                + " SELECT day_number, start_time, place_id, "
                + " LAG(end_time) OVER ("
                + " PARTITION BY day_number "
                + " ORDER BY start_time, combo_item_id"
                + " ) AS previous_end, "
                + " LAG(place_id) OVER ("
                + " PARTITION BY day_number "
                + " ORDER BY start_time, combo_item_id"
                + " ) AS previous_place "
                + " FROM dbo.ComboTemplateItems WITH (HOLDLOCK) "
                + " WHERE combo_id = ? AND place_id IS NOT NULL"
                + ") "
                + "SELECT TOP (1) day_number FROM PlaceSchedule "
                + "WHERE previous_place <> place_id "
                + "AND DATEDIFF(MINUTE, previous_end, start_time) < 15",
                "At least 15 minutes required between different locations.");
    }

    private void rejectIfFound(
            Connection connection,
            int comboId,
            String sql,
            String message) throws SQLException {

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, comboId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    throw new IllegalArgumentException(message);
                }
            }
        }
    }
}