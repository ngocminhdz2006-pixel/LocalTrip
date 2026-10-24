package utils;

import java.util.regex.Pattern;

/**
 * Server-side input validation utilities.
 */
public class ValidationUtil {

    public static final int NAME_MAX = 100;   // matches Users.full_name NVARCHAR(100)
    public static final int EMAIL_MAX = 150;  // matches Users.email NVARCHAR(150)
    public static final int PASSWORD_MIN = 6;
    public static final int PASSWORD_MAX = 64;
    public static final int TRIP_NAME_MAX = 150; // matches Trips.trip_name NVARCHAR(150)

    private static final Pattern EMAIL =
            Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    // Allows Unicode letters, marks, digits, spaces, and punctuation: . ' -
    private static final Pattern NAME_PATTERN =
            Pattern.compile("^[\\p{L}\\p{M}0-9 .'\\-]{1,100}$");

    public static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static boolean isValidEmail(String email) {
        return email != null && email.length() <= EMAIL_MAX && EMAIL.matcher(email).matches();
    }

    public static boolean isValidName(String name) {
        if (name == null) {
            return false;
        }
        String trimmed = name.trim();
        return !trimmed.isEmpty() && trimmed.length() <= NAME_MAX && NAME_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidTripName(String name) {
        if (name == null) {
            return false;
        }
        String trimmed = name.trim();
        if (trimmed.isEmpty() || trimmed.length() > TRIP_NAME_MAX) {
            return false;
        }
        // Disallow dangerous characters that could cause script or markup injection
        return !trimmed.contains("<") && !trimmed.contains(">");
    }

    public static boolean isValidPassword(String password) {
        return password != null
                && password.length() >= PASSWORD_MIN
                && password.length() <= PASSWORD_MAX;
    }
}
