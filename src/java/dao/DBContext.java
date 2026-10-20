package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Flexible Database Context for LocalTrip.
 * 
 * Supports dynamic configuration via:
 * 1. Java System Properties (e.g., -Ddb.host=... -Ddb.user=... -Ddb.password=...)
 * 2. Environment Variables (e.g., DB_HOST, DB_USER, DB_PASSWORD, DB_URL)
 * 3. Default fallback (localhost:1433, LocalTripDB, sa / 12345)
 */
public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    private static final String DEFAULT_HOST = "localhost";
    private static final String DEFAULT_PORT = "1433";
    private static final String DEFAULT_DB = "LocalTripDB";
    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASSWORD = "12345";

    private static String getConfig(String key, String defaultValue) {
        // 1. Check OS Environment Variable first for Cloud deployments (e.g. DB_SERVER, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
        String val = System.getenv(key);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }

        // 2. Check System Property with exact key (e.g. -DDB_SERVER=...)
        val = System.getProperty(key);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }

        // 3. Check System Property with dot notation (e.g. -Ddb.server=...)
        String dotKey = key.toLowerCase().replace('_', '.');
        val = System.getProperty(dotKey);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }

        return defaultValue;
    }

    public static String getJdbcUrl() {
        String customUrl = getConfig("DB_URL", null);
        if (customUrl != null) {
            return customUrl;
        }

        // Support both DB_SERVER (Render/Azure) and DB_HOST, fallback to localhost
        String host = getConfig("DB_SERVER", getConfig("DB_HOST", DEFAULT_HOST));
        String port = getConfig("DB_PORT", DEFAULT_PORT);
        String dbName = getConfig("DB_NAME", DEFAULT_DB);
        String encrypt = getConfig("DB_ENCRYPT", host.endsWith(".database.windows.net") ? "true" : "false");
        String trustCert = getConfig("DB_TRUST_CERT", "true");

        if (host.contains("\\")) {
            // Named instance (e.g. localhost\SQLEXPRESS)
            return String.format(
                "jdbc:sqlserver://%s;databaseName=%s;encrypt=%s;trustServerCertificate=%s",
                host, dbName, encrypt, trustCert
            );
        } else {
            // Standard host:port
            return String.format(
                "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=%s;trustServerCertificate=%s",
                host, port, dbName, encrypt, trustCert
            );
        }
    }

    public static String getUser() {
        return getConfig("DB_USER", DEFAULT_USER);
    }

    public static String getPassword() {
        return getConfig("DB_PASSWORD", DEFAULT_PASSWORD);
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("SQL Server JDBC Driver not found.", e);
        }

        String url = getJdbcUrl();
        String user = getUser();
        String pass = getPassword();

        try {
            return DriverManager.getConnection(url, user, pass);
        } catch (SQLException e) {
            // Safe logging: log connection target details without leaking credentials
            String safeHost = getConfig("DB_HOST", DEFAULT_HOST);
            String safeDb = getConfig("DB_NAME", DEFAULT_DB);
            LOGGER.log(Level.SEVERE, 
                String.format("Cannot connect to SQL Server database '%s' at '%s'. Check database status, credentials, and network settings.", safeDb, safeHost), 
                e
            );
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

    /**
     * Self-test helper for developers or presenters to verify database connectivity quickly.
     */
    public static void main(String[] args) {
        System.out.println("=== LocalTrip DB Connectivity Test ===");
        System.out.println("Resolved JDBC URL: " + getJdbcUrl());
        System.out.println("Resolved DB User:  " + getUser());
        try (Connection conn = getConnection()) {
            System.out.println("Result: Connection SUCCESSFUL! Connected database: " + conn.getCatalog());
        } catch (SQLException e) {
            System.err.println("Result: Connection FAILED: " + e.getMessage());
        }
    }
}