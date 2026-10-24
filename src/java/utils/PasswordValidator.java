package utils;

public final class PasswordValidator {

    private PasswordValidator() {
    }

    public static String validate(String password) {

        if (password == null || password.isEmpty()) {
            return "Password cannot be empty.";
        }

        if (password.length() < 8) {
            return "Password must be at least 8 characters long.";
        }

        if (password.length() > 64) {
            return "Password must not exceed 64 characters.";
        }

        if (!password.matches(".*[A-Z].*")) {
            return "Password must contain at least one uppercase letter.";
        }

        if (!password.matches(".*[a-z].*")) {
            return "Password must contain at least one lowercase letter.";
        }

        if (!password.matches(".*[0-9].*")) {
            return "Password must contain at least one digit.";
        }

        if (!password.matches(".*[^A-Za-z0-9].*")) {
            return "Password must contain at least one special character.";
        }

        return null;
    }
}
