package model;

import java.sql.Timestamp;

public class SimulatedBatchInfo {
    private String batchId;
    private int tripId;
    private String tripName;
    private String scenarioCode;
    private String status;
    private int userCount;
    private String ownerEmail;
    private Timestamp createdAt;

    public String getBatchId() { return batchId; }
    public void setBatchId(String batchId) { this.batchId = batchId; }

    public int getTripId() { return tripId; }
    public void setTripId(int tripId) { this.tripId = tripId; }

    public String getTripName() { return tripName; }
    public void setTripName(String tripName) { this.tripName = tripName; }

    public String getScenarioCode() { return scenarioCode; }
    public void setScenarioCode(String scenarioCode) { this.scenarioCode = scenarioCode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getUserCount() { return userCount; }
    public void setUserCount(int userCount) { this.userCount = userCount; }

    public String getOwnerEmail() { return ownerEmail; }
    public void setOwnerEmail(String ownerEmail) { this.ownerEmail = ownerEmail; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
