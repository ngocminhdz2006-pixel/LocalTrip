package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    private static final String URL =
        "jdbc:sqlserver://localhost:1433;databaseName=LocalTripDB;encrypt=false;trustServerCertificate=true";

    private static final String USER = "sa";
    private static final String PASSWORD = "12345";

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("SQL Server JDBC Driver not found.", e);
        }

        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            // Khong ghi URL day du/credentials; exception van duoc nem lai cho caller xu ly.
            LOGGER.log(Level.SEVERE, "Cannot connect to SQL Server database LocalTripDB at localhost:1433.", e);
            throw e;
        }
    }

    public static void close(AutoCloseable... resources) {
        if (resources == null) {
            return;
        }

        for (AutoCloseable resource : resources) {
            if (resource != null) {
                try {
                    resource.close();
                } catch (Exception ignored) {
                }
            }
        }
    }
}