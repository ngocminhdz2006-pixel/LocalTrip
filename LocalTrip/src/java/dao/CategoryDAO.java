package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Category;

public class CategoryDAO {

    public List<Category> findAll() {
        List<Category> categories = new ArrayList<>();

        String sql
                = "SELECT category_id, category_code, category_name "
                + "FROM Categories "
                + "ORDER BY category_name";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql);  ResultSet resultSet
                = statement.executeQuery()) {

            while (resultSet.next()) {
                Category category = new Category();

                category.setCategoryId(
                        resultSet.getInt("category_id")
                );

                category.setCategoryCode(
                        resultSet.getString("category_code")
                );

                category.setCategoryName(
                        resultSet.getString("category_name")
                );

                categories.add(category);
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể tải danh mục địa điểm.",
                    e
            );
        }

        return categories;
    }
}
