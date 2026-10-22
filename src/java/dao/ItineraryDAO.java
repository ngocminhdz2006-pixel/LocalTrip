package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import model.ItineraryItem;

public class ItineraryDAO {

    public List<ItineraryItem> findByTrip(int tripId) {
        List<ItineraryItem> items = new ArrayList<>();

        String sql
                = "SELECT i.item_id, i.trip_id, i.place_id, "
                + "COALESCE(i.activity_title,p.place_name) AS place_name, i.activity_type, i.activity_title, i.activity_status, i.visit_date, "
                + "i.start_time, i.end_time, i.note, "
                + "i.estimated_cost, p.latitude, p.longitude, i.created_at "
                + "FROM ItineraryItems i "
                + "LEFT JOIN Places p "
                + "ON p.place_id = i.place_id "
                + "WHERE i.trip_id = ? "
                + "ORDER BY i.visit_date, i.start_time, i.item_id";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, tripId);

            try ( ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    items.add(mapItem(resultSet));
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể tải lịch trình.",
                    e
            );
        }

        return items;
    }

    public void addComboAuthorized(int tripId, int ownerId, List<ItineraryItem> items) {
        if (items.size() != 3) throw new IllegalArgumentException("Combo phải có đủ ba hoạt động.");
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                try (PreparedStatement lock = connection.prepareStatement(
                        "SELECT status, start_date, end_date FROM Trips WITH (UPDLOCK, HOLDLOCK) WHERE trip_id = ? AND owner_id = ?")) {
                    lock.setInt(1, tripId); lock.setInt(2, ownerId);
                    try (ResultSet rs = lock.executeQuery()) {
                        if (!rs.next() || !("PLANNING".equals(rs.getString("status")) || "ONGOING".equals(rs.getString("status"))))
                            throw new IllegalArgumentException("Chuyến đi không còn cho phép chỉnh lịch trình.");
                        Date today = Date.valueOf(java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")));
                        for (ItineraryItem item : items) {
                            if (item.getTripId() != tripId || item.getVisitDate().before(today)
                                    || item.getVisitDate().before(rs.getDate("start_date")) || item.getVisitDate().after(rs.getDate("end_date")))
                                throw new IllegalArgumentException("Ngày áp dụng không còn hợp lệ. Hãy tải lại combo.");
                        }
                    }
                }
                for (ItineraryItem item : items) {
                    try (PreparedStatement check = connection.prepareStatement(
                            "SELECT 1 FROM ItineraryItems WITH (UPDLOCK, HOLDLOCK) WHERE trip_id = ? AND visit_date = ? AND activity_status <> 'CANCELLED' "
                            + "AND (place_id = ? OR (start_time < CAST(? AS TIME) AND end_time > CAST(? AS TIME)))")) {
                        check.setInt(1, tripId); check.setDate(2, item.getVisitDate()); check.setInt(3, item.getPlaceId());
                        check.setString(4, item.getEndTime().toString()); check.setString(5, item.getStartTime().toString());
                        try (ResultSet rs = check.executeQuery()) {
                            if (rs.next()) throw new IllegalArgumentException("Combo bị trùng địa điểm hoặc giờ với lịch đã lưu. Hãy đổi địa điểm hoặc giờ.");
                        }
                    }
                    try (PreparedStatement insert = connection.prepareStatement(
                            "INSERT INTO ItineraryItems (trip_id, place_id, visit_date, start_time, end_time, note, estimated_cost) "
                            + "VALUES (?, ?, ?, CAST(? AS TIME), CAST(? AS TIME), ?, ?)")) {
                        insert.setInt(1, tripId); insert.setInt(2, item.getPlaceId()); insert.setDate(3, item.getVisitDate());
                        insert.setString(4, item.getStartTime().toString()); insert.setString(5, item.getEndTime().toString());
                        insert.setString(6, item.getNote()); insert.setBigDecimal(7, item.getEstimatedCost()); insert.executeUpdate();
                    }
                }
                connection.commit();
            } catch (SQLException | RuntimeException ex) { connection.rollback(); throw ex; }
        } catch (SQLException ex) { throw new RuntimeException("Không thể xác nhận combo. Chưa lưu hoạt động nào.", ex); }
    }

    public String revisionForTrip(int tripId) {
        try (Connection connection = DBContext.getConnection()) { return revision(connection, tripId); }
        catch (SQLException ex) { throw new RuntimeException("Không thể kiểm tra phiên bản lịch trình.", ex); }
    }

    String revision(Connection connection, int tripId) throws SQLException {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            String[] queries = {
                "SELECT owner_id, destination, start_date, end_date, budget, status FROM Trips WHERE trip_id = ?",
                "SELECT item_id, place_id, visit_date, start_time, end_time, note, estimated_cost, activity_type, activity_title, activity_status FROM ItineraryItems WHERE trip_id = ? ORDER BY item_id",
                "SELECT user_id, category_id FROM TripMemberPreferences WHERE trip_id = ? ORDER BY user_id, category_id",
                "SELECT user_id FROM TripMembers WHERE trip_id = ? ORDER BY user_id"
            };
            for (String query : queries) {
                digest.update(query.getBytes(java.nio.charset.StandardCharsets.UTF_8));
                try (PreparedStatement statement = connection.prepareStatement(query)) {
                    statement.setInt(1, tripId);
                    try (ResultSet rs = statement.executeQuery()) {
                        int columns = rs.getMetaData().getColumnCount();
                        while (rs.next()) for (int i = 1; i <= columns; i++) {
                            String value = rs.getString(i);
                            byte[] bytes = value == null ? new byte[0] : value.getBytes(java.nio.charset.StandardCharsets.UTF_8);
                            digest.update((byte) (value == null ? 0 : 1));
                            digest.update(java.nio.ByteBuffer.allocate(4).putInt(bytes.length).array()); digest.update(bytes);
                        }
                    }
                }
            }
            StringBuilder result = new StringBuilder();
            for (byte value : digest.digest()) result.append(String.format("%02x", value & 255));
            return result.toString();
        } catch (java.security.NoSuchAlgorithmException ex) { throw new IllegalStateException(ex); }
    }

    public void replaceFromDraft(int tripId, int ownerId, Date fromDate, String expectedRevision, List<ItineraryItem> items) {
        new ActivityLifecycleDAO().replaceUpcoming(tripId,ownerId,fromDate,expectedRevision,items);
    }

    public void updateItemAuthorized(ItineraryItem edited, int ownerId, String expectedRevision) {
        new ActivityLifecycleDAO().editItem(edited,ownerId,expectedRevision);
    }

    public boolean add(ItineraryItem item) {
        String actType = item.getActivityType() != null && !item.getActivityType().trim().isEmpty()
                ? item.getActivityType().trim() : "VISIT";
        String actTitle = item.getActivityTitle();
        String actStatus = item.getActivityStatus() != null && !item.getActivityStatus().trim().isEmpty()
                ? item.getActivityStatus().trim() : "UPCOMING";

        String sql
                = "INSERT INTO ItineraryItems "
                + "(trip_id, place_id, visit_date, "
                + "start_time, end_time, note, estimated_cost, activity_type, activity_title, activity_status) "
                + "VALUES (?, ?, ?, "
                + "CAST(? AS TIME), CAST(? AS TIME), ?, ?, ?, ?, ?)";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, item.getTripId());
            statement.setInt(2, item.getPlaceId());
            statement.setDate(3, item.getVisitDate());
            statement.setString(4, item.getStartTime().toString());
            statement.setString(5, item.getEndTime().toString());
            statement.setString(6, item.getNote());
            statement.setBigDecimal(
                    7,
                    item.getEstimatedCost()
            );
            statement.setString(8, actType);
            statement.setString(9, actTitle);
            statement.setString(10, actStatus);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Unable to add place to itinerary.",
                    e
            );
        }
    }

    public boolean hasTimeConflict(
            int tripId,
            Date visitDate,
            Time startTime,
            Time endTime
    ) {
        String sql
                = "SELECT 1 "
                + "FROM ItineraryItems "
                + "WHERE trip_id = ? "
                + "AND visit_date = ? AND activity_status <> 'CANCELLED' "
                + "AND start_time < CAST(? AS TIME) "
                + "AND end_time > CAST(? AS TIME)";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, tripId);
            statement.setDate(2, visitDate);
            statement.setString(3, endTime.toString());
            statement.setString(4, startTime.toString());

            try ( ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể kiểm tra thời gian lịch trình.",
                    e
            );
        }
    }

    public boolean deleteByOwner(
            int itemId,
            int tripId,
            int ownerId
    ) {
        new ActivityLifecycleDAO().changeStatus(tripId,itemId,ownerId,"UPCOMING","CANCELLED");
        return true;
    }

    private ItineraryItem mapItem(ResultSet resultSet)
            throws SQLException {

        ItineraryItem item = new ItineraryItem();

        item.setItemId(resultSet.getInt("item_id"));
        item.setTripId(resultSet.getInt("trip_id"));
        item.setPlaceId(resultSet.getInt("place_id"));
        item.setPlaceName(resultSet.getString("place_name"));
        item.setActivityType(resultSet.getString("activity_type"));
        item.setActivityTitle(resultSet.getString("activity_title"));
        item.setActivityStatus(resultSet.getString("activity_status"));
        item.setVisitDate(resultSet.getDate("visit_date"));
        item.setStartTime(resultSet.getTime("start_time"));
        item.setEndTime(resultSet.getTime("end_time"));
        item.setNote(resultSet.getString("note"));
        item.setEstimatedCost(
                resultSet.getBigDecimal("estimated_cost")
        );
        item.setLatitude(
                resultSet.getBigDecimal("latitude")
        );
        item.setLongitude(
                resultSet.getBigDecimal("longitude")
        );
        item.setCreatedAt(
                resultSet.getTimestamp("created_at")
        );

        return item;
    }
}
