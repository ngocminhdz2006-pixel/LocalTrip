package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.ComboTemplate;
import model.ComboTemplate.Activity;

public class ComboTemplateDAO {

    private static final String SELECT_COMBO
            = "SELECT c.combo_id, c.combo_name, c.description, "
            + "c.image_url, c.city_name, c.district_name, "
            + "c.duration_days, c.status, c.created_by, "
            + "COALESCE(("
            + " SELECT SUM(i.estimated_cost_per_person) "
            + " FROM dbo.ComboTemplateItems i "
            + " WHERE i.combo_id = c.combo_id"
            + "), 0) AS total_cost "
            + "FROM dbo.ComboTemplates c ";

    /* Chỉ gọi từ chức năng admin đã kiểm tra quyền. */
    public List<ComboTemplate> findAllForAdmin() {
        String sql = SELECT_COMBO
                + "ORDER BY c.updated_at DESC, c.combo_id DESC";

        List<ComboTemplate> result = new ArrayList<>();

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql);  ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {
                result.add(mapCombo(rs));
            }

            return result;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể tải danh sách combo.", e);
        }
    }

    /*
     * Lọc combo đang sử dụng theo đúng khu vực và số ngày.
     * Phần xếp hạng sở thích/ngân sách sẽ làm ở bước tiếp theo.
     */
    public List<ComboTemplate> findActiveCandidates(
            String cityName,
            String districtName,
            int durationDays) {

        if (cityName == null || cityName.trim().isEmpty()
                || districtName == null
                || districtName.trim().isEmpty()
                || durationDays < 1) {
            throw new IllegalArgumentException(
                    "Khu vực hoặc số ngày không hợp lệ.");
        }

        String sql = SELECT_COMBO
                + "WHERE c.status = 'ACTIVE' "
                + "AND c.city_name = ? "
                + "AND c.district_name = ? "
                + "AND c.duration_days = ? "
                + "AND EXISTS ("
                + " SELECT 1 FROM dbo.ComboTemplateItems i "
                + " WHERE i.combo_id = c.combo_id"
                + ") "
                + "AND NOT EXISTS ("
                + " SELECT 1 "
                + " FROM dbo.ComboTemplateItems i "
                + " LEFT JOIN dbo.Places p ON p.place_id = i.place_id "
                + " WHERE i.combo_id = c.combo_id "
                + " AND i.place_id IS NOT NULL "
                + " AND (p.place_id IS NULL OR p.is_active = 0)"
                + ") "
                + "ORDER BY total_cost, c.combo_id";

        List<ComboTemplate> result = new ArrayList<>();

        try ( Connection connection = DBContext.getConnection()) {

            try ( PreparedStatement statement
                    = connection.prepareStatement(sql)) {

                statement.setString(1, cityName.trim());
                statement.setString(2, districtName.trim());
                statement.setInt(3, durationDays);

                try ( ResultSet rs = statement.executeQuery()) {
                    while (rs.next()) {
                        result.add(mapCombo(rs));
                    }
                }
            }

            for (ComboTemplate combo : result) {
                loadCategories(connection, combo);
            }

            return result;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể tải combo phù hợp.", e);
        }
    }

    /*
     * Đọc đầy đủ một combo, kể cả bản nháp/ngừng sử dụng.
     * Servlet phải kiểm tra quyền và trạng thái trước khi cho
     * user chọn hoặc áp dụng combo.
     */
    public ComboTemplate findById(int comboId) {
        if (comboId <= 0) {
            throw new IllegalArgumentException(
                    "Mã combo không hợp lệ.");
        }

        String sql = SELECT_COMBO + "WHERE c.combo_id = ?";

        try ( Connection connection = DBContext.getConnection()) {
            ComboTemplate combo;

            try ( PreparedStatement statement
                    = connection.prepareStatement(sql)) {

                statement.setInt(1, comboId);

                try ( ResultSet rs = statement.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }

                    combo = mapCombo(rs);
                }
            }

            loadCategories(connection, combo);
            loadActivities(connection, combo);

            return combo;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể tải chi tiết combo.", e);
        }
    }

    public List<ComboTemplate> findActiveForDestination(
            String destination, int durationDays) {

        if (destination == null || destination.trim().isEmpty()
                || durationDays < 1) {
            throw new IllegalArgumentException(
                    "Khu vực hoặc số ngày không hợp lệ.");
        }

        String sql = SELECT_COMBO
                + "WHERE c.status = 'ACTIVE' "
                + "AND (c.district_name + N', ' + c.city_name) = ? "
                + "AND c.duration_days = ? "
                + "AND EXISTS ("
                + " SELECT 1 FROM dbo.ComboTemplateItems i "
                + " WHERE i.combo_id = c.combo_id"
                + ") "
                + "AND NOT EXISTS ("
                + " SELECT 1 "
                + " FROM dbo.ComboTemplateItems i "
                + " LEFT JOIN dbo.Places p ON p.place_id = i.place_id "
                + " WHERE i.combo_id = c.combo_id "
                + " AND i.place_id IS NOT NULL "
                + " AND (p.place_id IS NULL OR p.is_active = 0)"
                + ") "
                + "ORDER BY c.combo_id";

        List<ComboTemplate> result = new ArrayList<>();

        try ( Connection connection = DBContext.getConnection()) {
            try ( PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, destination.trim());
                ps.setInt(2, durationDays);

                try ( ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        result.add(mapCombo(rs));
                    }
                }
            }

            for (ComboTemplate combo : result) {
                loadCategories(connection, combo);
                loadActivities(connection, combo);
            }

            return result;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể tải combo mẫu cho chuyến đi.", e);
        }
    }

    public java.util.Map<String, Integer> availabilityForDestination(String destination, int days) {
        java.util.Map<String, Integer> result = new java.util.LinkedHashMap<>();
        String sql = "SELECT c.status, c.duration_days, "
                + "CASE WHEN EXISTS (SELECT 1 FROM dbo.ComboTemplateItems i WHERE i.combo_id=c.combo_id) "
                + "AND NOT EXISTS (SELECT 1 FROM dbo.ComboTemplateItems i LEFT JOIN dbo.Places p ON p.place_id=i.place_id "
                + "WHERE i.combo_id=c.combo_id AND i.place_id IS NOT NULL AND (p.place_id IS NULL OR p.is_active=0)) "
                + "THEN 1 ELSE 0 END AS usable FROM dbo.ComboTemplates c "
                + "WHERE (c.district_name + N', ' + c.city_name)=?";
        int area=0, active=0, exact=0, usable=0;
        try (Connection connection=DBContext.getConnection(); PreparedStatement ps=connection.prepareStatement(sql)) {
            ps.setString(1,destination);
            try (ResultSet rs=ps.executeQuery()) {
                while(rs.next()) {
                    area++;
                    if ("ACTIVE".equals(rs.getString("status"))) {
                        active++;
                        if(rs.getInt("duration_days")==days) {
                            exact++;
                            if(rs.getInt("usable")==1) usable++;
                        }
                    }
                }
            }
        } catch(SQLException e) { throw new RuntimeException("Không thể kiểm tra dữ liệu combo.",e); }
        result.put("area",area); result.put("active",active);
        result.put("exact",exact); result.put("usable",usable);
        return result;
    }

    private void loadCategories(
            Connection connection,
            ComboTemplate combo) throws SQLException {

        String sql
                = "SELECT category_id "
                + "FROM dbo.ComboTemplateCategories "
                + "WHERE combo_id = ? "
                + "ORDER BY category_id";

        try ( PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, combo.getId());

            try ( ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    combo.getCategoryIds().add(
                            rs.getInt("category_id"));
                }
            }
        }
    }

    private void loadActivities(
            Connection connection,
            ComboTemplate combo) throws SQLException {

        String sql
                = "SELECT i.combo_item_id, i.day_number, "
                + "i.sort_order, i.activity_type, "
                + "i.place_id, p.place_name, i.activity_title, "
                + "i.start_time, i.end_time, "
                + "i.estimated_cost_per_person, i.note "
                + "FROM dbo.ComboTemplateItems i "
                + "LEFT JOIN dbo.Places p "
                + "ON p.place_id = i.place_id "
                + "WHERE i.combo_id = ? "
                + "ORDER BY i.day_number, i.sort_order";

        try ( PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, combo.getId());

            try ( ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Activity activity = new Activity();

                    activity.setId(rs.getInt("combo_item_id"));
                    activity.setDayNumber(rs.getInt("day_number"));
                    activity.setSortOrder(rs.getInt("sort_order"));
                    activity.setActivityType(
                            rs.getString("activity_type"));

                    int placeId = rs.getInt("place_id");
                    activity.setPlaceId(
                            rs.wasNull() ? null : placeId);

                    activity.setPlaceName(rs.getString("place_name"));
                    activity.setTitle(rs.getString("activity_title"));
                    activity.setStartTime(rs.getTime("start_time"));
                    activity.setEndTime(rs.getTime("end_time"));

                    activity.setEstimatedCostPerPerson(
                            rs.getBigDecimal(
                                    "estimated_cost_per_person"));

                    activity.setNote(rs.getString("note"));

                    combo.getActivities().add(activity);
                }
            }
        }
    }

    private ComboTemplate mapCombo(ResultSet rs)
            throws SQLException {

        ComboTemplate combo = new ComboTemplate();

        combo.setId(rs.getInt("combo_id"));
        combo.setName(rs.getString("combo_name"));
        combo.setDescription(rs.getString("description"));
        combo.setImageUrl(rs.getString("image_url"));
        combo.setCityName(rs.getString("city_name"));
        combo.setDistrictName(rs.getString("district_name"));
        combo.setDurationDays(rs.getInt("duration_days"));
        combo.setStatus(rs.getString("status"));
        combo.setCreatedBy(rs.getInt("created_by"));
        combo.setEstimatedCostPerPerson(
                rs.getBigDecimal("total_cost"));

        return combo;
    }
}
