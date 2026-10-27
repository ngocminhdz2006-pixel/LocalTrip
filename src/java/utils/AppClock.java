package utils;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Centralized clock service for business calendar calculations in LocalTrip.
 *
 * <p>Zone: Asia/Ho_Chi_Minh (+07:00).
 *
 * <p>Default: Real wall clock.
 *
 * <p>In Scenario Lab or integration tests, an offset or mock clock can be set
 * to simulate past or future business dates (e.g. trip start eligibility,
 * itinerary progression, trip ended banners), WITHOUT altering real wall clock
 * security timestamps (token expirations, brute force lockouts, audit logs).
 */
public final class AppClock {

    public static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private static final AtomicReference<Duration> offset =
            new AtomicReference<>(Duration.ZERO);

    private static volatile Clock testClockOverride = null;

    private AppClock() {}

    /**
     * @return the active ZoneId for the application (Asia/Ho_Chi_Minh).
     */
    public static ZoneId zone() {
        return ZONE;
    }

    /**
     * @return the underlying active Clock, taking into account any test override or simulated offset.
     */
    public static Clock clock() {
        Clock test = testClockOverride;
        if (test != null) {
            return test;
        }
        Duration curOffset = offset.get();
        Clock base = Clock.system(ZONE);
        if (curOffset != null && !curOffset.isZero()) {
            return Clock.offset(base, curOffset);
        }
        return base;
    }

    /**
     * @return current business date in Asia/Ho_Chi_Minh.
     */
    public static LocalDate today() {
        return LocalDate.now(clock());
    }

    /**
     * @return current business date as java.sql.Date for PreparedStatement parameters.
     */
    public static Date todaySql() {
        return Date.valueOf(today());
    }

    /**
     * @return current business date-time in Asia/Ho_Chi_Minh.
     */
    public static LocalDateTime now() {
        return LocalDateTime.now(clock());
    }

    /**
     * @return current business date-time as java.sql.Timestamp for PreparedStatement parameters.
     */
    public static Timestamp nowTimestamp() {
        return Timestamp.valueOf(now());
    }

    /**
     * Guarded setter to apply an offset duration.
     * Can only be called when Scenario Lab is enabled via ScenarioLabConfig.
     *
     * @param newOffset the Duration to shift time by (e.g. Duration.ofDays(3)), or Duration.ZERO / null to reset
     * @throws IllegalStateException if Scenario Lab is disabled
     */
    public static void setOffset(Duration newOffset) {
        if (!ScenarioLabConfig.isScenarioLabEnabled()) {
            throw new IllegalStateException("Scenario Lab is disabled. Cannot modify clock offset.");
        }
        offset.set(newOffset == null ? Duration.ZERO : newOffset);
    }

    /**
     * @return the currently configured offset.
     */
    public static Duration getOffset() {
        return offset.get();
    }

    /**
     * Resets offset to Duration.ZERO and clears any test clock override.
     */
    public static void reset() {
        offset.set(Duration.ZERO);
        testClockOverride = null;
    }

    /**
     * Unit test seam to freeze or manipulate time arbitrarily in tests.
     * Package or test scope intended.
     *
     * @param clock mock or fixed Clock, or null to restore normal AppClock behavior
     */
    public static void setClockForTests(Clock clock) {
        testClockOverride = clock;
    }
}
