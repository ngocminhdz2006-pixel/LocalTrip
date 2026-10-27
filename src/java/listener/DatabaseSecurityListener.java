package listener;

import dao.DBContext;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import javax.sql.DataSource;

/**
 * Startup listener that validates database security policies before the application serves requests.
 * Enforces production security rules for both JNDI Connection Pool and direct DriverManager fallback:
 * 1. Database password must be explicitly set and cannot be empty or '12345'.
 * 2. Database user cannot be 'sa'.
 * 3. Connection must have encrypt=true and trustServerCertificate=false.
 */
@WebListener
public class DatabaseSecurityListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(DatabaseSecurityListener.class.getName());
    private static final String JNDI_NAME = "java:comp/env/jdbc/LocalTripDB";

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("Executing startup database security verification...");
        validateDatabaseConfiguration();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // No resources to release
    }

    /**
     * Validates database configuration for production and development environments.
     * Throws IllegalStateException when running in production with policy violations.
     */
    public static void validateDatabaseConfiguration() {
        boolean isProduction = DBContext.isProduction();
        List<String> violations = new ArrayList<>();

        DataSource ds = lookupJndiDataSource();
        String user = null;
        String password = null;
        String url = null;
        String encrypt = null;
        String trustCert = null;

        if (ds != null) {
            // JNDI Connection Pool path
            LOGGER.fine("Evaluating JNDI DataSource security configuration...");
            try {
                user = invokeGetter(ds, "getUsername");
                password = invokeGetter(ds, "getPassword");
                url = invokeGetter(ds, "getUrl");
            } catch (Exception ignored) {
            }

            // Probe connection metadata for user and URL if not directly exposed by DataSource bean
            try (Connection conn = ds.getConnection()) {
                DatabaseMetaData meta = conn.getMetaData();
                if (user == null || user.trim().isEmpty()) {
                    user = meta.getUserName();
                }
                if (url == null || url.trim().isEmpty()) {
                    url = meta.getURL();
                }
            } catch (SQLException e) {
                violations.add("Failed to obtain test connection from JNDI pool: " + e.getMessage());
            }

            // In JNDI, if password is not exposed by DataSource bean, inspect DB_PASSWORD environment variable
            if (password == null || password.trim().isEmpty()) {
                password = DBContext.getConfig("DB_PASSWORD", null);
            }
        } else {
            // Direct DriverManager fallback path
            LOGGER.fine("Evaluating direct DriverManager security configuration...");
            user = DBContext.getUser();
            password = DBContext.getPassword();
            url = DBContext.getJdbcUrl();
            encrypt = DBContext.getConfig("DB_ENCRYPT", isProduction ? "true" : "false");
            trustCert = DBContext.getConfig("DB_TRUST_CERT", isProduction ? "false" : "true");
        }

        // Parse URL parameters if encrypt or trustServerCertificate are not explicitly set
        if (url != null) {
            String lowerUrl = url.toLowerCase();
            if (encrypt == null) {
                if (lowerUrl.contains("encrypt=true")) {
                    encrypt = "true";
                } else if (lowerUrl.contains("encrypt=false")) {
                    encrypt = "false";
                }
            }
            if (trustCert == null) {
                if (lowerUrl.contains("trustservercertificate=true")) {
                    trustCert = "true";
                } else if (lowerUrl.contains("trustservercertificate=false")) {
                    trustCert = "false";
                }
            }
        }

        // Check (a): Database password must be explicitly configured and not default "12345"
        if (password == null || password.trim().isEmpty()) {
            violations.add("Database password is not configured (empty or null).");
        } else if ("12345".equals(password.trim())) {
            violations.add("Database password cannot use the insecure default '12345'.");
        }

        // Check (b): Database user must be configured and not "sa"
        if (user == null || user.trim().isEmpty()) {
            violations.add("Database user is not configured (empty or null).");
        } else if ("sa".equalsIgnoreCase(user.trim()) || user.trim().toLowerCase().startsWith("sa@")) {
            violations.add("Database user cannot be 'sa'. Use a dedicated application account (see sql/create_app_user.sql).");
        }

        // Check (c): Connection encryption and trusted server certificate
        if (!"true".equalsIgnoreCase(encrypt)) {
            violations.add("Database connection encryption is disabled (must specify encrypt=true).");
        }
        if (!"false".equalsIgnoreCase(trustCert)) {
            violations.add("Database connection trusts unverified certificates (must specify trustServerCertificate=false).");
        }

        if (!violations.isEmpty()) {
            if (isProduction) {
                String errorMsg = "FATAL: Insecure database configuration detected in production (APP_ENV=production):\n"
                        + " - " + String.join("\n - ", violations);
                LOGGER.log(Level.SEVERE, errorMsg);
                throw new IllegalStateException(errorMsg);
            } else {
                LOGGER.log(Level.WARNING, "[SECURITY WARNING] LocalTrip is running in non-production mode with insecure database defaults:\n - "
                        + String.join("\n - ", violations)
                        + "\nThese settings will be strictly rejected when APP_ENV=production.");
            }
        } else {
            LOGGER.info("Database security verification passed: secure user, password, and encryption confirmed.");
        }
    }

    private static DataSource lookupJndiDataSource() {
        try {
            Context ctx = new InitialContext();
            return (DataSource) ctx.lookup(JNDI_NAME);
        } catch (NamingException e) {
            return null;
        }
    }

    private static String invokeGetter(Object target, String methodName) {
        try {
            Method m = target.getClass().getMethod(methodName);
            Object result = m.invoke(target);
            return result != null ? result.toString() : null;
        } catch (Exception e) {
            return null;
        }
    }
}
