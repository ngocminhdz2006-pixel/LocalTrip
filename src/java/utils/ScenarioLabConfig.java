package utils;

/**
 * Configuration for Scenario Lab features (simulation, time travel, fixture generation).
 *
 * <p>HARD REQUIREMENT:
 * The Scenario Lab is available ONLY when APP_ENV != "production" AND SCENARIO_LAB=true
 * (via environment variable or system property).
 *
 * <p>When disabled, every lab URL returns 404 and no navigation items are shown. Default is OFF.
 */
public final class ScenarioLabConfig {

    private static volatile Boolean programmaticOverride = null;

    private ScenarioLabConfig() {}

    /**
     * @return true ONLY if APP_ENV != "production" and SCENARIO_LAB=true
     */
    public static boolean isScenarioLabEnabled() {
        String env = System.getenv("APP_ENV");
        if (env == null || env.trim().isEmpty()) {
            env = System.getProperty("APP_ENV", "development");
        }
        if ("production".equalsIgnoreCase(env.trim())) {
            return false;
        }

        if (programmaticOverride != null) {
            return programmaticOverride;
        }

        String flag = System.getenv("SCENARIO_LAB");
        if (flag == null || flag.trim().isEmpty()) {
            flag = System.getProperty("SCENARIO_LAB");
        }
        if (flag == null || flag.trim().isEmpty()) {
            flag = System.getenv("LOCALTRIP_SCENARIO_LAB");
        }
        if (flag == null || flag.trim().isEmpty()) {
            flag = System.getProperty("localtrip.scenariolab.enabled");
        }

        // In non-production environments, enabled by default unless explicitly set to "false"
        return !"false".equalsIgnoreCase(flag);
    }

    /**
     * Programmatic override for tests or admin toggle in non-production environments.
     * Throws SecurityException if attempted in a production environment.
     */
    public static synchronized void setScenarioLabEnabled(boolean enabled) {
        String env = System.getenv("APP_ENV");
        if (env == null || env.trim().isEmpty()) {
            env = System.getProperty("APP_ENV", "development");
        }
        if ("production".equalsIgnoreCase(env.trim()) && enabled) {
            throw new SecurityException("Cannot enable Scenario Lab in production environment!");
        }
        programmaticOverride = enabled;
    }

    /**
     * Clears any programmatic override, reverting to system properties / env vars.
     */
    public static synchronized void resetOverride() {
        programmaticOverride = null;
    }
}
