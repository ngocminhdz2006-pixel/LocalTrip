package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Set;
import model.ComboTemplate;
import model.ComboTemplate.Activity;

public class ComboTemplateWriteDAO {

    public int createDraft(ComboTemplate combo, int adminId) {
        validateStructure(combo);

        try ( Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);

            try {
                checkAdmin(connection, adminId);
                checkCategories(connection, combo);
                checkPlaces(connection, combo);

                int comboId = insertCombo(connection, combo, adminId);
                insertCategories(connection, comboId, combo);
                insertActivities(connection, comboId, combo);

                connection.commit();
                return comboId;

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
                    "Không thể lưu combo bản nháp.", e);
        }
    }

    public String findEditRevision(int comboId) {
        String sql
                = "SELECT CONVERT(VARCHAR(33), updated_at, 126) AS revision "
                + "FROM dbo.ComboTemplates "
                + "WHERE combo_id = ? AND status IN ('DRAFT', 'INACTIVE')";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, comboId);

            try ( ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("revision") : null;
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể tải phiên bản combo.", e);
        }
    }

    public void updateDraft(
            ComboTemplate combo,
            int adminId,
            String expectedRevision) {

        validateStructure(combo);

        if (combo.getId() <= 0
                || expectedRevision == null
                || expectedRevision.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Thiếu mã hoặc phiên bản combo. Hãy mở lại trang sửa.");
        }

        try ( Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);

            try {
                checkAdmin(connection, adminId);

                String lockSql
                        = "SELECT status, "
                        + "CONVERT(VARCHAR(33), updated_at, 126) AS revision "
                        + "FROM dbo.ComboTemplates WITH (UPDLOCK, HOLDLOCK) "
                        + "WHERE combo_id = ?";

                try ( PreparedStatement ps
                        = connection.prepareStatement(lockSql)) {

                    ps.setInt(1, combo.getId());

                    try ( ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException(
                                    "Không tìm thấy combo.");
                        }

                        String status = rs.getString("status");

                        if (!"DRAFT".equals(status)
                                && !"INACTIVE".equals(status)) {
                            throw new IllegalArgumentException(
                                    "Hãy ngừng sử dụng combo trước khi sửa.");
                        }

                        if (!expectedRevision.equals(
                                rs.getString("revision"))) {
                            throw new IllegalArgumentException(
                                    "Combo đã được sửa hoặc đổi trạng thái "
                                    + "ở nơi khác. Hãy mở lại trang sửa.");
                        }
                    }
                }

                checkCategories(connection, combo);
                checkPlaces(connection, combo);

                String updateSql
                        = "UPDATE dbo.ComboTemplates "
                        + "SET combo_name = ?, description = ?, "
                        + "city_name = ?, district_name = ?, "
                        + "duration_days = ?, status = 'DRAFT', "
                        + "updated_at = SYSDATETIME() "
                        + "WHERE combo_id = ?";

                try ( PreparedStatement ps
                        = connection.prepareStatement(updateSql)) {

                    ps.setString(1, combo.getName().trim());
                    ps.setString(2, combo.getDescription());
                    ps.setString(3, combo.getCityName().trim());
                    ps.setString(4, combo.getDistrictName().trim());
                    ps.setInt(5, combo.getDurationDays());
                    ps.setInt(6, combo.getId());

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                                "Không cập nhật được combo.");
                    }
                }

                try ( PreparedStatement ps = connection.prepareStatement(
                        "DELETE FROM dbo.ComboTemplateCategories "
                        + "WHERE combo_id = ?")) {

                    ps.setInt(1, combo.getId());
                    ps.executeUpdate();
                }

                try ( PreparedStatement ps = connection.prepareStatement(
                        "DELETE FROM dbo.ComboTemplateItems "
                        + "WHERE combo_id = ?")) {

                    ps.setInt(1, combo.getId());
                    ps.executeUpdate();
                }

                insertCategories(connection, combo.getId(), combo);
                insertActivities(connection, combo.getId(), combo);

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
                    "Không thể cập nhật combo bản nháp.", e);
        }
    }

    private void validateStructure(ComboTemplate combo) {
        if (combo == null) {
            throw new IllegalArgumentException("Thiếu thông tin combo.");
        }

        requireText(combo.getName(), 150, "Tên combo");
        requireText(combo.getCityName(), 100, "Tỉnh/thành");
        requireText(combo.getDistrictName(), 100, "Quận/huyện");

        if (combo.getDescription() != null
                && combo.getDescription().length() > 1000) {
            throw new IllegalArgumentException(
                    "Mô tả tối đa 1000 ký tự.");
        }

        if (combo.getDurationDays() < 1
                || combo.getDurationDays() > 14) {
            throw new IllegalArgumentException(
                    "Combo phải có từ 1 đến 14 ngày.");
        }

        if (combo.getCategoryIds().isEmpty()) {
            throw new IllegalArgumentException(
                    "Chọn ít nhất một sở thích.");
        }

        if (combo.getActivities().isEmpty()
                || combo.getActivities().size() > 60) {
            throw new IllegalArgumentException(
                    "Combo phải có từ 1 đến 60 hoạt động.");
        }

        combo.getActivities().sort(
                Comparator.comparingInt(Activity::getDayNumber)
                        .thenComparing(Activity::getStartTime,
                                Comparator.nullsFirst(
                                        Comparator.naturalOrder())));

        Set<Integer> usedPlaces = new HashSet<>();
        int currentDay = -1;
        int order = 0;
        Activity previous = null;

        for (Activity activity : combo.getActivities()) {
            requireText(activity.getTitle(), 200, "Tên hoạt động");

            if (activity.getDayNumber() < 1
                    || activity.getDayNumber() > combo.getDurationDays()) {
                throw new IllegalArgumentException(
                        "Ngày hoạt động phải nằm trong số ngày của combo.");
            }

            String type = activity.getActivityType();
            if (!"VISIT".equals(type) && !"MEAL".equals(type)
                    && !"CAFE".equals(type) && !"REST".equals(type)) {
                throw new IllegalArgumentException(
                        "Loại hoạt động không hợp lệ.");
            }

            if (activity.getStartTime() == null
                    || activity.getEndTime() == null
                    || !activity.getEndTime().after(
                            activity.getStartTime())) {
                throw new IllegalArgumentException(
                        "Giờ kết thúc phải sau giờ bắt đầu.");
            }

            if (activity.getEstimatedCostPerPerson() == null
                    || activity.getEstimatedCostPerPerson().signum() < 0
                    || activity.getEstimatedCostPerPerson().scale() > 2
                    || activity.getEstimatedCostPerPerson().precision()
                    - activity.getEstimatedCostPerPerson().scale() > 16) {
                throw new IllegalArgumentException(
                        "Chi phí không hợp lệ; tối đa hai chữ số thập phân.");
            }

            if (activity.getNote() != null
                    && activity.getNote().length() > 500) {
                throw new IllegalArgumentException(
                        "Ghi chú tối đa 500 ký tự.");
            }

            if (!"REST".equals(type) && activity.getPlaceId() == null) {
                throw new IllegalArgumentException(
                        "Hoạt động tham quan, ăn uống hoặc cà phê phải có địa điểm.");
            }

            if (activity.getPlaceId() != null
                    && !usedPlaces.add(activity.getPlaceId())) {
                throw new IllegalArgumentException(
                        "Một địa điểm không được lặp lại trong combo.");
            }

            if (activity.getDayNumber() != currentDay) {
                currentDay = activity.getDayNumber();
                order = 0;
                previous = null;
            }

            if (previous != null) {
                long gap = java.time.Duration.between(
                        previous.getEndTime().toLocalTime(),
                        activity.getStartTime().toLocalTime()).toMinutes();

                boolean changesPlace
                        = previous.getPlaceId() != null
                        && activity.getPlaceId() != null
                        && !previous.getPlaceId().equals(
                                activity.getPlaceId());

                if (gap < 0 || (changesPlace && gap < 15)) {
                    throw new IllegalArgumentException(
                            "Hoạt động không được trùng giờ; cần ít nhất "
                            + "15 phút giữa hai địa điểm khác nhau.");
                }
            }

            activity.setSortOrder(++order);
            previous = activity;
        }
    }

    private void requireText(String value, int limit, String label) {
        if (value == null || value.trim().isEmpty()
                || value.length() > limit) {
            throw new IllegalArgumentException(
                    label + " bắt buộc và tối đa " + limit + " ký tự.");
        }
    }

    private void checkAdmin(Connection connection, int adminId)
            throws SQLException {

        String sql = "SELECT 1 FROM dbo.Users WITH (HOLDLOCK) "
                + "WHERE user_id = ? AND role = 'ADMIN' AND is_active = 1";

        try ( PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException(
                            "Tài khoản không có quyền quản lý combo.");
                }
            }
        }
    }

    private void checkCategories(
            Connection connection, ComboTemplate combo)
            throws SQLException {

        String sql = "SELECT 1 FROM dbo.Categories WITH (HOLDLOCK) "
                + "WHERE category_id = ?";

        Set<Integer> seen = new HashSet<>();

        try ( PreparedStatement ps = connection.prepareStatement(sql)) {
            for (Integer id : combo.getCategoryIds()) {
                if (id == null || id <= 0 || !seen.add(id)) {
                    throw new IllegalArgumentException(
                            "Danh sách sở thích không hợp lệ.");
                }

                ps.setInt(1, id);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalArgumentException(
                                "Sở thích đã chọn không còn tồn tại.");
                    }
                }
            }
        }
    }

    private void checkPlaces(
            Connection connection, ComboTemplate combo)
            throws SQLException {

        String sql
                = "SELECT p.place_name, p.opening_time, p.closing_time, "
                + "c.category_code "
                + "FROM dbo.Places p WITH (HOLDLOCK) "
                + "JOIN dbo.Categories c ON c.category_id = p.category_id "
                + "WHERE p.place_id = ? AND p.is_active = 1 "
                + "AND p.city_name = ? AND p.district_name = ?";

        try ( PreparedStatement ps = connection.prepareStatement(sql)) {
            for (Activity activity : combo.getActivities()) {
                if (activity.getPlaceId() == null) {
                    continue;
                }

                ps.setInt(1, activity.getPlaceId());
                ps.setString(2, combo.getCityName().trim());
                ps.setString(3, combo.getDistrictName().trim());

                try ( ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalArgumentException(
                                "Địa điểm phải đang sử dụng và thuộc "
                                + "đúng tỉnh/thành, quận/huyện của combo.");
                    }

                    String code = rs.getString("category_code");
                    if (("MEAL".equals(activity.getActivityType())
                            && !"FOOD".equals(code))
                            || ("CAFE".equals(activity.getActivityType())
                            && !"CAFE".equals(code))) {
                        throw new IllegalArgumentException(
                                "Địa điểm ăn uống hoặc cà phê "
                                + "không đúng danh mục.");
                    }

                    java.sql.Time open = rs.getTime("opening_time");
                    java.sql.Time close = rs.getTime("closing_time");

                    if (open == null || close == null
                            || !close.after(open)) {
                        throw new IllegalArgumentException(
                                "Cần giờ mở cửa cùng ngày hợp lệ cho "
                                + rs.getString("place_name") + ".");
                    }

                    if (activity.getStartTime().before(open)
                            || activity.getEndTime().after(close)) {
                        throw new IllegalArgumentException(
                                "Hoạt động nằm ngoài giờ mở cửa của "
                                + rs.getString("place_name") + ".");
                    }
                }
            }
        }
    }

    private int insertCombo(
            Connection connection, ComboTemplate combo, int adminId)
            throws SQLException {

        String sql
                = "INSERT dbo.ComboTemplates "
                + "(combo_name, description, city_name, district_name, "
                + "duration_days, status, created_by) "
                + "VALUES (?, ?, ?, ?, ?, 'DRAFT', ?)";

        try ( PreparedStatement ps = connection.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, combo.getName().trim());
            ps.setString(2, combo.getDescription());
            ps.setString(3, combo.getCityName().trim());
            ps.setString(4, combo.getDistrictName().trim());
            ps.setInt(5, combo.getDurationDays());
            ps.setInt(6, adminId);
            ps.executeUpdate();

            try ( ResultSet rs = ps.getGeneratedKeys()) {
                if (!rs.next()) {
                    throw new SQLException("Không lấy được mã combo.");
                }
                return rs.getInt(1);
            }
        }
    }

    private void insertCategories(
            Connection connection, int comboId, ComboTemplate combo)
            throws SQLException {

        String sql = "INSERT dbo.ComboTemplateCategories "
                + "(combo_id, category_id) VALUES (?, ?)";

        try ( PreparedStatement ps = connection.prepareStatement(sql)) {
            for (Integer categoryId : combo.getCategoryIds()) {
                ps.setInt(1, comboId);
                ps.setInt(2, categoryId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertActivities(
            Connection connection, int comboId, ComboTemplate combo)
            throws SQLException {

        String sql
                = "INSERT dbo.ComboTemplateItems "
                + "(combo_id, day_number, sort_order, activity_type, "
                + "place_id, activity_title, start_time, end_time, "
                + "estimated_cost_per_person, note) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try ( PreparedStatement ps = connection.prepareStatement(sql)) {
            for (Activity activity : combo.getActivities()) {
                ps.setInt(1, comboId);
                ps.setInt(2, activity.getDayNumber());
                ps.setInt(3, activity.getSortOrder());
                ps.setString(4, activity.getActivityType());

                if (activity.getPlaceId() == null) {
                    ps.setNull(5, java.sql.Types.INTEGER);
                } else {
                    ps.setInt(5, activity.getPlaceId());
                }

                ps.setString(6, activity.getTitle());
                ps.setTime(7, activity.getStartTime());
                ps.setTime(8, activity.getEndTime());
                ps.setBigDecimal(9, activity.getEstimatedCostPerPerson());
                ps.setString(10, activity.getNote());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
}
