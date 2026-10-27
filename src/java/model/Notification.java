package model;

import java.sql.Timestamp;

public class Notification {

    private int notificationId;
    private int userId;
    private Integer actorUserId;
    private String actorName;
    private String type;
    private Integer tripId;
    private String tripName;
    private Integer refId;
    private String message;
    private boolean read;
    private Timestamp createdAt;

    public Notification() {
    }

    public int getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(int notificationId) {
        this.notificationId = notificationId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Integer getActorUserId() {
        return actorUserId;
    }

    public void setActorUserId(Integer actorUserId) {
        this.actorUserId = actorUserId;
    }

    public String getActorName() {
        return actorName != null ? actorName : "LocalTrip";
    }

    public void setActorName(String actorName) {
        this.actorName = actorName;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Integer getTripId() {
        return tripId;
    }

    public void setTripId(Integer tripId) {
        this.tripId = tripId;
    }

    public String getTripName() {
        return tripName;
    }

    public void setTripName(String tripName) {
        this.tripName = tripName;
    }

    public Integer getRefId() {
        return refId;
    }

    public void setRefId(Integer refId) {
        this.refId = refId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getTimeAgo() {
        if (createdAt == null) {
            return "";
        }
        // UI DISPLAY: Relative time display ("minutes ago") tracks real wall clock time
        long minutes = (System.currentTimeMillis() - createdAt.getTime()) / 60000L;
        if (minutes < 1) {
            return "Just now";
        }
        if (minutes < 60) {
            return minutes + (minutes == 1 ? " minute ago" : " minutes ago");
        }
        long hours = minutes / 60;
        if (hours < 24) {
            return hours + (hours == 1 ? " hour ago" : " hours ago");
        }
        long days = hours / 24;
        return days + (days == 1 ? " day ago" : " days ago");
    }

    public String getLink(String contextPath) {
        String base = (contextPath == null || "/".equals(contextPath)) ? "" : contextPath;
        if (type == null) {
            return base + "/trips";
        }
        if ("EXPENSE_ADDED".equals(type) && tripId != null && tripId > 0) {
            return base + "/expenses?tripId=" + tripId;
        }
        if (("PAYMENT_SENT".equals(type) || "PAYMENT_CONFIRMED".equals(type)) && tripId != null && tripId > 0) {
            return base + "/settlement?tripId=" + tripId;
        }
        if ("ITINERARY_CHANGE".equals(type) && tripId != null && tripId > 0) {
            return base + "/itinerary?tripId=" + tripId;
        }
        if (type.startsWith("TRIP_") && tripId != null && tripId > 0) {
            return base + "/trip/detail?tripId=" + tripId;
        }
        if (type.startsWith("FRIEND_")) {
            return base + "/dump";
        }
        if (tripId != null && tripId > 0) {
            return base + "/trip/detail?tripId=" + tripId;
        }
        return base + "/trips";
    }

    public String getIcon() {
        if (type == null) return "🔔";
        if (type.startsWith("TRIP_")) return "🎒";
        if (type.startsWith("FRIEND_")) return "👥";
        if ("EXPENSE_ADDED".equals(type)) return "💸";
        if ("PAYMENT_SENT".equals(type) || "PAYMENT_CONFIRMED".equals(type)) return "💳";
        if ("ITINERARY_CHANGE".equals(type)) return "📅";
        return "🔔";
    }
}
