package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * Flexible Database Context for LocalTrip.
 * 
 * Supports:
 * 1. Tomcat JNDI DataSource (java:comp/env/jdbc/LocalTripDB)
 * 2. Environment Variables & System Properties (DB_HOST, DB_USER, DB_PASSWORD, etc.)
 * 3. Fail-fast validation in production (APP_ENV=production requires explicit DB_PASSWORD)
 * 4. Local development fallback
 */
public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    private static final String JNDI_NAME = "java:comp/env/jdbc/LocalTripDB";
    private static final String DEFAULT_HOST = "localhost";
    private static final String DEFAULT_PORT = "1433";
    private static final String DEFAULT_DB = "LocalTripDB";
    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASSWORD = "12345";

    private static volatile DataSource jndiDataSource = null;
    private static volatile boolean jndiChecked = false;

    private static String getConfig(String key, String defaultValue) {
        String val = System.getenv(key);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }

        val = System.getProperty(key);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }

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

        String host = getConfig("DB_SERVER", getConfig("DB_HOST", DEFAULT_HOST));
        String port = getConfig("DB_PORT", DEFAULT_PORT);
        String dbName = getConfig("DB_NAME", DEFAULT_DB);
        String encrypt = getConfig("DB_ENCRYPT", host.endsWith(".database.windows.net") ? "true" : "false");
        String trustCert = getConfig("DB_TRUST_CERT", "true");

        if (host.contains("\\")) {
            return String.format(
                "jdbc:sqlserver://%s;databaseName=%s;encrypt=%s;trustServerCertificate=%s",
                host, dbName, encrypt, trustCert
            );
        } else {
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

    private static DataSource getJndiDataSource() {
        if (!jndiChecked) {
            synchronized (DBContext.class) {
                if (!jndiChecked) {
                    try {
                        Context initContext = new InitialContext();
                        jndiDataSource = (DataSource) initContext.lookup(JNDI_NAME);
                        LOGGER.info("Successfully resolved JNDI DataSource: " + JNDI_NAME);
                    } catch (NamingException e) {
                        LOGGER.fine("JNDI lookup not available, falling back to direct DriverManager: " + e.getMessage());
                        jndiDataSource = null;
                    } finally {
                        jndiChecked = true;
                    }
                }
            }
        }
        return jndiDataSource;
    }

    public static Connection getConnection() throws SQLException {
        // 1. Try JNDI connection pool first if configured in servlet container
        DataSource ds = getJndiDataSource();
        if (ds != null) {
            try {
                return ds.getConnection();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Failed to obtain connection from JNDI pool, attempting DriverManager fallback.", e);
            }
        }

        // 2. Production fail-fast check: disallow default credentials in production
        String appEnv = getConfig("APP_ENV", "development");
        String rawPassword = System.getenv("DB_PASSWORD");
        if (rawPassword == null) {
            rawPassword = System.getProperty("DB_PASSWORD");
            if (rawPassword == null) {
                rawPassword = System.getProperty("db.password");
            }
        }

        if ("production".equalsIgnoreCase(appEnv)) {
            if (rawPassword == null || rawPassword.trim().isEmpty() || DEFAULT_PASSWORD.equals(rawPassword.trim())) {
                throw new SQLException("CRITICAL: Production environment detected (APP_ENV=production) but DB_PASSWORD is not explicitly provided or is using insecure default.");
            }
        }

        // 3. Fallback to direct JDBC connection
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("SQL Server JDBC Driver not found on classpath.", e);
        }

        String url = getJdbcUrl();
        String user = getUser();
        String pass = getPassword();

        try {
            return DriverManager.getConnection(url, user, pass);
        } catch (SQLException e) {
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
