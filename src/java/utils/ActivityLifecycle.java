package utils;

/** State transitions are deliberate; clock time never marks an activity complete. */
public final class ActivityLifecycle {
    private ActivityLifecycle() { }
    public static boolean canTransition(String tripStatus, String current, String next) {
        if ("PLANNING".equals(tripStatus)) {
            return "UPCOMING".equals(current) && "CANCELLED".equals(next);
        }
        if (!"ONGOING".equals(tripStatus)) return false;
        return ("UPCOMING".equals(current)
                && ("IN_PROGRESS".equals(next) || "CANCELLED".equals(next)))
                || ("IN_PROGRESS".equals(current)
                && ("COMPLETED".equals(next) || "CANCELLED".equals(next)));
    }
}
