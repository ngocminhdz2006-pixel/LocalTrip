package model;

import java.util.ArrayList;
import java.util.List;

public class SimulatedScenarioResult {
    private String batchId;
    private String scenarioCode;
    private int tripId;
    private String tripName;
    private String status;
    private String startDate;
    private String endDate;
    private String ownerEmail;
    private List<String> memberEmails = new ArrayList<>();
    private int activityCount;
    private int expenseCount;
    private String message;

    public String getBatchId() { return batchId; }
    public void setBatchId(String batchId) { this.batchId = batchId; }

    public String getScenarioCode() { return scenarioCode; }
    public void setScenarioCode(String scenarioCode) { this.scenarioCode = scenarioCode; }

    public int getTripId() { return tripId; }
    public void setTripId(int tripId) { this.tripId = tripId; }

    public String getTripName() { return tripName; }
    public void setTripName(String tripName) { this.tripName = tripName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }

    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }

    public String getOwnerEmail() { return ownerEmail; }
    public void setOwnerEmail(String ownerEmail) { this.ownerEmail = ownerEmail; }

    public List<String> getMemberEmails() { return memberEmails; }
    public void setMemberEmails(List<String> memberEmails) { this.memberEmails = memberEmails; }

    public int getActivityCount() { return activityCount; }
    public void setActivityCount(int activityCount) { this.activityCount = activityCount; }

    public int getExpenseCount() { return expenseCount; }
    public void setExpenseCount(int expenseCount) { this.expenseCount = expenseCount; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
