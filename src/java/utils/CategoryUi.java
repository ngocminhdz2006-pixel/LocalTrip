package utils;

import java.text.Normalizer;
import java.util.Locale;

/**
 * Standardized category UI mapping helper for LocalTrip.
 * Maps category codes (and fallback names) to uniform English display labels and emojis.
 */
public final class CategoryUi {

    private CategoryUi() {}

    /**
     * Resolves the standardized emoji icon for a category code or name.
     *
     * @param codeOrName category code (FOOD, CAFE, SIGHTSEEING, etc.) or legacy name
     * @return emoji icon string
     */
    public static String icon(String codeOrName) {
        String key = normalize(codeOrName);
        if (key.isEmpty()) {
            return "📍";
        }

        if (key.equals("FOOD") || key.contains("AN UONG") || key.contains("AM THUC")) {
            return "🍜";
        }
        if (key.equals("CAFE") || key.contains("CA PHE") || key.contains("DRINK")) {
            return "☕";
        }
        if (key.equals("SIGHTSEEING") || key.contains("THAM QUAN") || key.contains("VAN HOA") || key.contains("THIEN NHIEN")) {
            return "🏛️";
        }
        if (key.equals("ENTERTAINMENT") || key.contains("GIAI TRI")) {
            return "🎡";
        }
        if (key.equals("SHOPPING") || key.contains("MUA SAM")) {
            return "🛍️";
        }

        return "📍";
    }

    /**
     * Resolves the standardized English display label for a category code or name.
     *
     * @param codeOrName category code or legacy name
     * @return English label (Food & Dining, Cafe & Drinks, Sightseeing, Entertainment, Shopping, Other)
     */
    public static String label(String codeOrName) {
        String key = normalize(codeOrName);
        if (key.isEmpty()) {
            return "Other";
        }

        if (key.equals("FOOD") || key.contains("AN UONG") || key.contains("AM THUC")) {
            return "Food & Dining";
        }
        if (key.equals("CAFE") || key.contains("CA PHE") || key.contains("DRINK")) {
            return "Cafe & Drinks";
        }
        if (key.equals("SIGHTSEEING") || key.contains("THAM QUAN") || key.contains("VAN HOA") || key.contains("THIEN NHIEN")) {
            return "Sightseeing";
        }
        if (key.equals("ENTERTAINMENT") || key.contains("GIAI TRI")) {
            return "Entertainment";
        }
        if (key.equals("SHOPPING") || key.contains("MUA SAM")) {
            return "Shopping";
        }

        return "Other";
    }

    private static String normalize(String str) {
        if (str == null) return "";
        String trimmed = str.trim().toUpperCase(Locale.ROOT);
        // Strip accents for robust fallback matching against Vietnamese strings
        String decomposed = Normalizer.normalize(trimmed, Normalizer.Form.NFD);
        return decomposed.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    }
}
