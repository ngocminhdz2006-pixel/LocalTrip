package model;

import java.math.BigDecimal;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class ComboTemplate {

    private int id;
    private String name;
    private String description;
    private String imageUrl;
    private String cityName;
    private String districtName;
    private int durationDays;
    private String status;
    private int createdBy;

    private BigDecimal estimatedCostPerPerson = BigDecimal.ZERO;
    private List<Integer> categoryIds = new ArrayList<>();
    private List<Activity> activities = new ArrayList<>();

    private double avgRating = 0.0;
    private int reviewCount = 0;
    private int appliedTripsCount = 0;
    private int budgetMatchPercent = 100;
    private String topVibeTags = "";
    private int groupMatchPercent = 0;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getCityName() {
        return cityName;
    }

    public void setCityName(String cityName) {
        this.cityName = cityName;
    }

    public String getDistrictName() {
        return districtName;
    }

    public void setDistrictName(String districtName) {
        this.districtName = districtName;
    }

    public int getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(int durationDays) {
        this.durationDays = durationDays;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public BigDecimal getEstimatedCostPerPerson() {
        return estimatedCostPerPerson;
    }

    public void setEstimatedCostPerPerson(BigDecimal value) {
        this.estimatedCostPerPerson =
                value == null ? BigDecimal.ZERO : value;
    }

    public List<Integer> getCategoryIds() {
        return categoryIds;
    }

    public List<Activity> getActivities() {
        return activities;
    }

    public void setActivities(List<Activity> activities) {
        this.activities = activities;
    }

    public double getAvgRating() {
        return avgRating;
    }

    public void setAvgRating(double avgRating) {
        this.avgRating = avgRating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public int getAppliedTripsCount() {
        return appliedTripsCount;
    }

    public void setAppliedTripsCount(int appliedTripsCount) {
        this.appliedTripsCount = appliedTripsCount;
    }

    public int getBudgetMatchPercent() {
        return budgetMatchPercent;
    }

    public void setBudgetMatchPercent(int budgetMatchPercent) {
        this.budgetMatchPercent = budgetMatchPercent;
    }

    public String getTopVibeTags() {
        return topVibeTags;
    }

    public void setTopVibeTags(String topVibeTags) {
        this.topVibeTags = topVibeTags;
    }

    public int getGroupMatchPercent() {
        return groupMatchPercent;
    }

    public void setGroupMatchPercent(int groupMatchPercent) {
        this.groupMatchPercent = groupMatchPercent;
    }

    public static class Activity {

        private int id;
        private int dayNumber;
        private int sortOrder;
        private String activityType;
        private Integer placeId;
        private String placeName;
        private String title;
        private Time startTime;
        private Time endTime;
        private BigDecimal estimatedCostPerPerson;
        private String note;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public int getDayNumber() {
            return dayNumber;
        }

        public void setDayNumber(int dayNumber) {
            this.dayNumber = dayNumber;
        }

        public int getSortOrder() {
            return sortOrder;
        }

        public void setSortOrder(int sortOrder) {
            this.sortOrder = sortOrder;
        }

        public String getActivityType() {
            return activityType;
        }

        public void setActivityType(String activityType) {
            this.activityType = activityType;
        }

        public Integer getPlaceId() {
            return placeId;
        }

        public void setPlaceId(Integer placeId) {
            this.placeId = placeId;
        }

        public String getPlaceName() {
            return placeName;
        }

        public void setPlaceName(String placeName) {
            this.placeName = placeName;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
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

        public BigDecimal getEstimatedCostPerPerson() {
            return estimatedCostPerPerson;
        }

        public void setEstimatedCostPerPerson(BigDecimal value) {
            this.estimatedCostPerPerson = value;
        }

        public String getNote() {
            return note;
        }

        public void setNote(String note) {
            this.note = note;
        }
    }
}