package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class ItineraryItem {

    private int itemId;
    private int tripId;
    private int placeId;
    private String placeName;
    private Date visitDate;
    private Time startTime;
    private Time endTime;
    private String note;
    private BigDecimal estimatedCost;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private Timestamp createdAt;

    private String activityType = "VISIT";
    private String activityTitle;
    private String activityStatus = "UPCOMING";
    public String getActivityType() { return activityType; }
    public void setActivityType(String value) { activityType=value; }
    public String getActivityTitle() { return activityTitle; }
    public void setActivityTitle(String value) { activityTitle=value; }
    public String getActivityStatus() { return activityStatus; }
    public void setActivityStatus(String value) { activityStatus=value; }
    public String getStatusLabel() {
        if ("IN_PROGRESS".equals(activityStatus)) return "Ongoing";
        if ("COMPLETED".equals(activityStatus)) return "Done";
        if ("CANCELLED".equals(activityStatus)) return "Skipped";
        return "Upcoming";
    }

    public ItineraryItem() {
    }

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public int getId() {
        return itemId;
    }

    public void setId(int id) {
        this.itemId = id;
    }

    public int getTripId() {
        return tripId;
    }

    public void setTripId(int tripId) {
        this.tripId = tripId;
    }

    public int getPlaceId() {
        return placeId;
    }

    public void setPlaceId(int placeId) {
        this.placeId = placeId;
    }

    public String getPlaceName() {
        return placeName;
    }

    public void setPlaceName(String placeName) {
        this.placeName = placeName;
    }

    public Date getVisitDate() {
        return visitDate;
    }

    public void setVisitDate(Date visitDate) {
        this.visitDate = visitDate;
    }

    public Date getDate() {
        return visitDate;
    }

    public void setDate(Date date) {
        this.visitDate = date;
    }

    public Time getStartTime() {
        return startTime;
    }

    public void setStartTime(Time startTime) {
        this.startTime = startTime;
    }

    public Time getEndTime() {
        return endTime;
    }

    public void setEndTime(Time endTime) {
        this.endTime = endTime;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public BigDecimal getEstimatedCost() {
        return estimatedCost;
    }

    public void setEstimatedCost(BigDecimal estimatedCost) {
        this.estimatedCost = estimatedCost;
    }

    public BigDecimal getLatitude() {
        return latitude;
    }

    public void setLatitude(BigDecimal latitude) {
        this.latitude = latitude;
    }

    public BigDecimal getLongitude() {
        return longitude;
    }

    public void setLongitude(BigDecimal longitude) {
        this.longitude = longitude;
    }

    private boolean locked = false;
    private String sourceType = "MANUAL"; // MANUAL, COMBO, AI

    public boolean isLocked() {
        return locked;
    }

    public void setLocked(boolean locked) {
        this.locked = locked;
    }

    public String getSourceType() {
        return sourceType != null ? sourceType : "MANUAL";
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public long getDurationMinutes() {
        if (startTime == null || endTime == null) {
            return 0;
        }
        return Math.max(0, (endTime.getTime() - startTime.getTime()) / 60000L);
    }

    public String getCleanedNote() {
        if (note == null || note.trim().isEmpty()) {
            return "";
        }
        String n = note.trim();
        if (n.contains("structured milestone") || n.contains("match score:")) {
            java.util.regex.Matcher m = java.util.regex.Pattern.compile(
                "^(.*?)(?:\\s*-\\s*Slot\\s*\\d{2}:\\d{2}\\s*-\\s*\\d{2}:\\d{2})?\\s*-\\s*structured milestone;?\\s*match score:\\s*(\\d+)\\.?$",
                java.util.regex.Pattern.CASE_INSENSITIVE).matcher(n);
            if (m.find()) {
                String rawCat = m.group(1).trim();
                if (rawCat.startsWith("Activity (") && rawCat.endsWith(")")) {
                    rawCat = rawCat.substring(10, rawCat.length() - 1);
                }
                String cat = utils.CategoryUi.label(rawCat);
                String score = m.group(2).trim();
                String icon = utils.CategoryUi.icon(rawCat);
                return icon + " " + cat + " • " + score + "% Group Match";
            }
        }
        if (n.contains("Matches group vibe")) {
            java.util.regex.Matcher m2 = java.util.regex.Pattern.compile(
                "Matches group vibe \\((.*?)\\).*?Score:\\s*(\\d+)%",
                java.util.regex.Pattern.CASE_INSENSITIVE).matcher(n);
            if (m2.find()) {
                String rawCat = m2.group(1).trim();
                String cat = utils.CategoryUi.label(rawCat);
                String score = m2.group(2).trim();
                String icon = utils.CategoryUi.icon(rawCat);
                return icon + " " + cat + " • " + score + "% Group Match";
            }
        }
        return n;
    }

    public String getDisplayNote() {
        return getCleanedNote();
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}