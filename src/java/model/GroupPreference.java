package model;

public class GroupPreference {

    private int categoryId;
    private String categoryCode;
    private String categoryName;
    private int memberCount;
    private double percentage;

    public GroupPreference() {
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getMemberCount() {
        return memberCount;
    }

    public void setMemberCount(int memberCount) {
        this.memberCount = memberCount;
    }

    public double getPercentage() {
        return percentage;
    }

    public void setPercentage(double percentage) {
        this.percentage = percentage;
    }

    public String getIcon() {
        if (categoryCode != null) {
            String code = categoryCode.toUpperCase();
            if ("FOOD".equals(code)) return "🍜";
            if ("CAFE".equals(code)) return "☕";
            if ("SIGHTSEEING".equals(code) || "CULTURE".equals(code)) return "🏛️";
            if ("ENTERTAINMENT".equals(code)) return "🎡";
            if ("SHOPPING".equals(code)) return "🛍️";
            if ("NATURE".equals(code)) return "🌲";
        }

        if (categoryName != null) {
            String lower = categoryName.toLowerCase();
            if (lower.contains("food") || lower.contains("ăn")) return "🍜";
            if (lower.contains("cafe") || lower.contains("cà phê") || lower.contains("coffee")) return "☕";
            if (lower.contains("sightseeing") || lower.contains("tham quan") || lower.contains("culture")) return "🏛️";
            if (lower.contains("entertainment") || lower.contains("giải trí")) return "🎡";
            if (lower.contains("shopping") || lower.contains("mua sắm")) return "🛍️";
            if (lower.contains("nature") || lower.contains("thiên nhiên")) return "🌲";
        }

        return "📍";
    }

    public String getDisplayCategoryName() {
        if (categoryCode != null) {
            String code = categoryCode.toUpperCase();
            if ("FOOD".equals(code)) return "Food & Dining";
            if ("CAFE".equals(code)) return "Cafe & Drinks";
            if ("SIGHTSEEING".equals(code) || "CULTURE".equals(code)) return "Sightseeing";
            if ("ENTERTAINMENT".equals(code)) return "Entertainment";
            if ("SHOPPING".equals(code)) return "Shopping";
            if ("NATURE".equals(code)) return "Nature & Outdoors";
        }

        if (categoryName != null) {
            String lower = categoryName.toLowerCase();
            if (lower.contains("food") || lower.contains("ăn")) return "Food & Dining";
            if (lower.contains("cafe") || lower.contains("cà phê") || lower.contains("coffee")) return "Cafe & Drinks";
            if (lower.contains("sightseeing") || lower.contains("tham quan")) return "Sightseeing";
            if (lower.contains("entertainment") || lower.contains("giải trí")) return "Entertainment";
            if (lower.contains("shopping") || lower.contains("mua sắm")) return "Shopping";
            if (lower.contains("nature") || lower.contains("thiên nhiên")) return "Nature & Outdoors";
            return categoryName.replaceAll("^[🍜☕🏛️🎡🛍️🌲📍🎯\\s]+", "").trim();
        }

        return "General";
    }
}
