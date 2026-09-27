package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Place;

public class PlaceDAO {

    private static final String SELECT_BASE =
            "SELECT p.place_id, "
            + "p.category_id, "
            + "c.category_name, "
            + "p.place_name, "
            + "p.address, "
            + "p.description, "
            + "p.estimated_cost, "
            + "p.rating, "
            + "p.opening_time, "
            + "p.closing_time, "
            + "p.latitude, "
            + "p.longitude, "
            + "p.place_type, "
            + "p.is_active "
            + "FROM Places p "
            + "JOIN Categories c "
            + "ON p.category_id = c.category_id ";

    public List<Place> findAll() {
        List<Place> places =
                new ArrayList<Place>();

        String sql = SELECT_BASE
                + "WHERE p.is_active = 1 "
                + "ORDER BY p.place_name";

        try (
            Connection connection =
                    DBContext.getConnection();
            PreparedStatement statement =
                    connection.prepareStatement(sql);
            ResultSet resultSet =
                    statement.executeQuery()
        ) {
            while (resultSet.next()) {
                places.add(mapPlace(resultSet));
            }
        } catch (SQLException e) {
            throw new RuntimeException(
                    "Khong the doc danh sach dia diem",
                    e
            );
        }

        return places;
    }

    public List<Place> findByCategory(
            int categoryId
    ) {
        List<Place> places =
                new ArrayList<Place>();

        String sql = SELECT_BASE
                + "WHERE p.is_active = 1 "
                + "AND p.category_id = ? "
                + "ORDER BY p.place_name";

        try (
            Connection connection =
                    DBContext.getConnection();
            PreparedStatement statement =
                    connection.prepareStatement(sql)
        ) {
            statement.setInt(1, categoryId);

            try (
                ResultSet resultSet =
                        statement.executeQuery()
            ) {
                while (resultSet.next()) {
                    places.add(mapPlace(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(
                    "Khong the loc dia diem",
                    e
            );
        }

        return places;
    }

    private Place mapPlace(
            ResultSet resultSet
    ) throws SQLException {

        Place place = new Place();

        place.setPlaceId(
                resultSet.getInt("place_id")
        );

        place.setCategoryId(
                resultSet.getInt("category_id")
        );

        place.setCategoryName(
                resultSet.getString("category_name")
        );

        place.setPlaceName(
                resultSet.getString("place_name")
        );

        place.setAddress(
                resultSet.getString("address")
        );

        place.setDescription(
                resultSet.getString("description")
        );

        place.setEstimatedCost(
                resultSet.getBigDecimal(
                        "estimated_cost"
                )
        );

        place.setRating(
                resultSet.getBigDecimal("rating")
        );

        place.setOpeningTime(
                resultSet.getTime("opening_time")
        );

        place.setClosingTime(
                resultSet.getTime("closing_time")
        );

        place.setLatitude(
                resultSet.getBigDecimal("latitude")
        );

        place.setLongitude(
                resultSet.getBigDecimal("longitude")
        );

        place.setPlaceType(
                resultSet.getString("place_type")
        );

        place.setActive(
                resultSet.getBoolean("is_active")
        );

        return place;
    }
}