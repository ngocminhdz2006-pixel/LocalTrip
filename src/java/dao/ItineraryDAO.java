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
                + "p.place_name, i.visit_date, "
                + "i.start_time, i.end_time, i.note, "
                + "i.estimated_cost, p.latitude, p.longitude, i.created_at "
                + "FROM ItineraryItems i "
                + "INNER JOIN Places p "
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
                            "SELECT 1 FROM ItineraryItems WITH (UPDLOCK, HOLDLOCK) WHERE trip_id = ? AND visit_date = ? "
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

    private String revision(Connection connection, int tripId) throws SQLException {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            String[] queries = {
                "SELECT owner_id, destination, start_date, end_date, budget, status FROM Trips WHERE trip_id = ?",
                "SELECT item_id, place_id, visit_date, start_time, end_time, note, estimated_cost FROM ItineraryItems WHERE trip_id = ? ORDER BY item_id",
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
        if (items == null || items.isEmpty()) throw new IllegalArgumentException("Bản xem trước trống. Lịch cũ được giữ nguyên.");
        Date today = Date.valueOf(java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")));
        if (fromDate.before(today)) throw new IllegalArgumentException("Ngày đã thay đổi kể từ khi xem trước. Hãy tạo lại lịch mới.");
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false); connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                String destination; Date startDate, endDate;
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT destination, start_date, end_date, status FROM Trips WITH (UPDLOCK, HOLDLOCK) WHERE trip_id = ? AND owner_id = ?")) {
                    statement.setInt(1, tripId); statement.setInt(2, ownerId);
                    try (ResultSet rs = statement.executeQuery()) {
                        if (!rs.next() || !("PLANNING".equals(rs.getString("status")) || "ONGOING".equals(rs.getString("status"))))
                            throw new IllegalArgumentException("Bạn không còn quyền thay thế lịch trình của chuyến đi này.");
                        destination = rs.getString("destination"); startDate = rs.getDate("start_date"); endDate = rs.getDate("end_date");
                    }
                }
                if (!revision(connection, tripId).equals(expectedRevision))
                    throw new IllegalArgumentException("Lịch trình, chuyến đi hoặc sở thích nhóm đã thay đổi. Hãy tạo lại bản xem trước; lịch cũ được giữ nguyên.");
                List<ItineraryItem> ordered = new ArrayList<ItineraryItem>(items);
                ordered.sort(java.util.Comparator.comparing(ItineraryItem::getVisitDate).thenComparing(ItineraryItem::getStartTime));
                ItineraryItem previous = null;
                for (ItineraryItem item : ordered) {
                    if (item.getTripId() != tripId || item.getVisitDate().before(fromDate) || item.getVisitDate().before(startDate)
                            || item.getVisitDate().after(endDate) || !item.getEndTime().after(item.getStartTime()))
                        throw new IllegalArgumentException("Bản xem trước có ngày hoặc giờ không hợp lệ. Hãy tạo lại.");
                    if (previous != null && previous.getVisitDate().equals(item.getVisitDate()) && item.getStartTime().before(previous.getEndTime()))
                        throw new IllegalArgumentException("Bản xem trước có các hoạt động trùng giờ. Lịch cũ được giữ nguyên.");
                    try (PreparedStatement check = connection.prepareStatement(
                            "SELECT opening_time, closing_time FROM Places WHERE place_id = ? AND is_active = 1 AND (district_name + N', ' + city_name) = ?")) {
                        check.setInt(1, item.getPlaceId()); check.setString(2, destination);
                        try (ResultSet rs = check.executeQuery()) {
                            if (!rs.next()) throw new IllegalArgumentException("Một địa điểm không còn hoạt động trong khu vực chuyến đi. Hãy tạo lại lịch.");
                            Time open = rs.getTime("opening_time"), close = rs.getTime("closing_time");
                            boolean overnight = open != null && close != null && close.before(open);
                            boolean valid = overnight ? (!item.getStartTime().before(open) || !item.getEndTime().after(close))
                                    : (open == null || !item.getStartTime().before(open)) && (close == null || !item.getEndTime().after(close));
                            if (!valid) throw new IllegalArgumentException("Giờ mở cửa đã thay đổi hoặc lịch chưa phù hợp. Hãy tạo lại bản xem trước.");
                        }
                    }
                    previous = item;
                }
                try (PreparedStatement delete = connection.prepareStatement("DELETE FROM ItineraryItems WHERE trip_id = ? AND visit_date >= ?")) {
                    delete.setInt(1, tripId); delete.setDate(2, fromDate); delete.executeUpdate();
                }
                try (PreparedStatement insert = connection.prepareStatement(
                        "INSERT INTO ItineraryItems (trip_id, place_id, visit_date, start_time, end_time, note, estimated_cost) VALUES (?, ?, ?, CAST(? AS TIME), CAST(? AS TIME), ?, ?)")) {
                    for (ItineraryItem item : ordered) {
                        insert.setInt(1, tripId); insert.setInt(2, item.getPlaceId()); insert.setDate(3, item.getVisitDate());
                        insert.setString(4, item.getStartTime().toString()); insert.setString(5, item.getEndTime().toString());
                        insert.setString(6, item.getNote()); insert.setBigDecimal(7, item.getEstimatedCost()); insert.executeUpdate();
                    }
                }
                connection.commit();
            } catch (SQLException | RuntimeException ex) { connection.rollback(); throw ex; }
        } catch (SQLException ex) { throw new RuntimeException("Không thể thay thế lịch trình. Thao tác đã được hoàn tác để giữ lịch cũ.", ex); }
    }

    public void updateItemAuthorized(ItineraryItem edited, int ownerId, String expectedRevision) {
        Date today = Date.valueOf(java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")));
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false); connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                model.Trip trip = new model.Trip(); trip.setRole("OWNER");
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT destination, start_date, end_date, status FROM Trips WITH (UPDLOCK, HOLDLOCK) WHERE trip_id = ? AND owner_id = ?")) {
                    statement.setInt(1, edited.getTripId()); statement.setInt(2, ownerId);
                    try (ResultSet rs = statement.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Bạn không còn quyền sửa chuyến đi này.");
                        trip.setDestination(rs.getString("destination")); trip.setStartDate(rs.getDate("start_date"));
                        trip.setEndDate(rs.getDate("end_date")); trip.setStatus(rs.getString("status"));
                    }
                }
                if (!revision(connection, edited.getTripId()).equals(expectedRevision))
                    throw new IllegalArgumentException("Lịch trình hoặc chuyến đi đã thay đổi. Hãy tải lại biểu mẫu trước khi sửa để tránh ghi đè.");
                ItineraryItem original = new ItineraryItem();
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT visit_date FROM ItineraryItems WITH (UPDLOCK, HOLDLOCK) WHERE item_id = ? AND trip_id = ?")) {
                    statement.setInt(1, edited.getItemId()); statement.setInt(2, edited.getTripId());
                    try (ResultSet rs = statement.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Hoạt động đã bị xóa hoặc thay thế. Hãy mở lại lịch trình.");
                        original.setVisitDate(rs.getDate("visit_date"));
                    }
                }
                model.Place place = new model.Place();
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT opening_time, closing_time FROM Places WHERE place_id = ? AND is_active = 1 AND (district_name + N', ' + city_name) = ?")) {
                    statement.setInt(1, edited.getPlaceId()); statement.setString(2, trip.getDestination());
                    try (ResultSet rs = statement.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Địa điểm không còn hoạt động trong khu vực chuyến đi.");
                        place.setActive(true); place.setOpeningTime(rs.getTime("opening_time")); place.setClosingTime(rs.getTime("closing_time"));
                    }
                }
                utils.ItineraryEditValidation.validate(trip, original, edited, place, today);
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT 1 FROM ItineraryItems WITH (UPDLOCK, HOLDLOCK) WHERE trip_id = ? AND item_id <> ? AND visit_date = ? "
                        + "AND start_time < CAST(? AS TIME) AND end_time > CAST(? AS TIME)")) {
                    statement.setInt(1, edited.getTripId()); statement.setInt(2, edited.getItemId()); statement.setDate(3, edited.getVisitDate());
                    statement.setString(4, edited.getEndTime().toString()); statement.setString(5, edited.getStartTime().toString());
                    try (ResultSet rs = statement.executeQuery()) {
                        if (rs.next()) throw new IllegalArgumentException("Giờ hoạt động trùng với một hoạt động khác trong lịch trình.");
                    }
                }
                try (PreparedStatement statement = connection.prepareStatement(
                        "UPDATE ItineraryItems SET place_id = ?, visit_date = ?, start_time = CAST(? AS TIME), end_time = CAST(? AS TIME), note = ?, estimated_cost = ? WHERE item_id = ? AND trip_id = ?")) {
                    statement.setInt(1, edited.getPlaceId()); statement.setDate(2, edited.getVisitDate());
                    statement.setString(3, edited.getStartTime().toString()); statement.setString(4, edited.getEndTime().toString());
                    statement.setString(5, edited.getNote()); statement.setBigDecimal(6, edited.getEstimatedCost());
                    statement.setInt(7, edited.getItemId()); statement.setInt(8, edited.getTripId());
                    if (statement.executeUpdate() != 1) throw new IllegalArgumentException("Không thể cập nhật hoạt động. Hãy tải lại lịch trình.");
                }
                connection.commit();
            } catch (SQLException | RuntimeException ex) { connection.rollback(); throw ex; }
        } catch (SQLException ex) { throw new RuntimeException("Không thể lưu thay đổi. Hoạt động cũ đã được giữ nguyên.", ex); }
    }

    public boolean add(ItineraryItem item) {
        String sql
                = "INSERT INTO ItineraryItems "
                + "(trip_id, place_id, visit_date, "
                + "start_time, end_time, note, estimated_cost) "
                + "VALUES (?, ?, ?, "
                + "CAST(? AS TIME), CAST(? AS TIME), ?, ?)";

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

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể thêm địa điểm vào lịch trình.",
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
                + "AND visit_date = ? "
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
        String sql
                = "DELETE FROM ItineraryItems "
                + "WHERE item_id = ? "
                + "AND trip_id = ? "
                + "AND EXISTS ("
                + "SELECT 1 FROM Trips t "
                + "WHERE t.trip_id = ItineraryItems.trip_id "
                + "AND t.owner_id = ?"
                + ")";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, itemId);
            statement.setInt(2, tripId);
            statement.setInt(3, ownerId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể xóa mục khỏi lịch trình.",
                    e
            );
        }
    }

    private ItineraryItem mapItem(ResultSet resultSet)
            throws SQLException {

        ItineraryItem item = new ItineraryItem();

        item.setItemId(resultSet.getInt("item_id"));
        item.setTripId(resultSet.getInt("trip_id"));
        item.setPlaceId(resultSet.getInt("place_id"));
        item.setPlaceName(resultSet.getString("place_name"));
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
