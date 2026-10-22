package model;

import java.sql.Timestamp;

public class ComboReview {
    private int reviewId;
    private int comboId;
    private int tripId;
    private int userId;
    private String userName;
    private int rating;
    private String paceFeedback;
    private boolean budgetMatch;
    private String vibeTags;
    private String comment;
    private Timestamp createdAt;

    public ComboReview() {
    }

    public int getReviewId() {
        return reviewId;
    }

    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }

    public int getComboId() {
        return comboId;
    }

    public void setComboId(int comboId) {
        this.comboId = comboId;
    }

    public int getTripId() {
        return tripId;
    }

    public void setTripId(int tripId) {
        this.tripId = tripId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getPaceFeedback() {
        return paceFeedback;
    }

    public void setPaceFeedback(String paceFeedback) {
        this.paceFeedback = paceFeedback;
    }

    public boolean isBudgetMatch() {
        return budgetMatch;
    }

    public void setBudgetMatch(boolean budgetMatch) {
        this.budgetMatch = budgetMatch;
    }

    public String getVibeTags() {
        return vibeTags;
    }

    public void setVibeTags(String vibeTags) {
        this.vibeTags = vibeTags;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
