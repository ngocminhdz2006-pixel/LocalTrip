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
                    "Thao tác đổi trạng thái không hợp lệ.");
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
                        + "SET status = ?, updated_at = SYSDATETIME() "
                        + "WHERE combo_id = ? AND status = ?";

                try (PreparedStatement ps =
                        connection.prepareStatement(sql)) {

                    ps.setString(1, newStatus);
                    ps.setInt(2, comboId);
                    ps.setString(3, expectedStatus);

                    if (ps.executeUpdate() != 1) {
                        throw new IllegalArgumentException(
                                "Combo đã thay đổi. Hãy tải lại trang.");
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
                    "Không thể đổi trạng thái combo.", e);
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
                            "Tài khoản không có quyền quản lý combo.");
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
                            "Không tìm thấy combo.");
                }

                if (!expectedStatus.equals(rs.getString("status"))) {
                    throw new IllegalArgumentException(
                            "Trạng thái combo đã thay đổi. "
                            + "Hãy tải lại trang.");
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
                            "Combo cần ít nhất một nhãn sở thích.");
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
                                "Combo phải có hoạt động liên tục "
                                + "từ Ngày 1 đến ngày cuối.");
                    }

                    if (rs.getInt("meal_count") < 1) {
                        throw new IllegalArgumentException(
                                "Ngày " + day
                                + " cần ít nhất một hoạt động ăn uống.");
                    }

                    if (rs.getInt("break_count") < 1) {
                        throw new IllegalArgumentException(
                                "Ngày " + day
                                + " cần ít nhất một hoạt động nghỉ hoặc cà phê.");
                    }

                    expectedDay++;
                }
            }
        }

        if (expectedDay != durationDays + 1) {
            throw new IllegalArgumentException(
                    "Combo chưa có đủ hoạt động cho tất cả các ngày.");
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
                "Có hoạt động không hợp lệ: kiểm tra địa điểm, "
                + "khu vực, loại hoạt động và giờ mở cửa.");

        rejectIfFound(connection, comboId,
                "SELECT place_id "
                + "FROM dbo.ComboTemplateItems WITH (HOLDLOCK) "
                + "WHERE combo_id = ? AND place_id IS NOT NULL "
                + "GROUP BY place_id HAVING COUNT(*) > 1",
                "Combo có địa điểm bị lặp lại.");

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
                "Có hoạt động trùng thời gian.");

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
                "Cần ít nhất 15 phút giữa hai địa điểm khác nhau.");
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