package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    private static final String URL =
            "jdbc:sqlserver://localhost:1433;"
            + "databaseName=LocalTripDB;"
            + "encrypt=false;"
            + "trustServerCertificate=true";

    private static final String USER = "sa";

    private static final String PASSWORD =
            "12345";

    static {
        try {
            Class.forName(
                    "com.microsoft.sqlserver.jdbc.SQLServerDriver"
            );
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                    "Khong tim thay SQL Server JDBC Driver",
                    e
            );
        }
    }

    public static Connection getConnection()
            throws SQLException {
        return DriverManager.getConnection(
                URL,
                USER,
                PASSWORD
        );
    }

    public static void close(
            AutoCloseable... resources
    ) {
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