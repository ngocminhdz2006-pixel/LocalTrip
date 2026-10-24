package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class SettlementTransfer {

    private int paymentId;
    private int fromMemberId;
    private String fromMemberName;
    private int toMemberId;
    private String toMemberName;
    private BigDecimal amount;
    private String status = "PENDING"; // PENDING, SENT, CONFIRMED
    private Timestamp updatedAt;

    public SettlementTransfer() {
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public int getFromMemberId() {
        return fromMemberId;
    }

    public void setFromMemberId(int fromMemberId) {
        this.fromMemberId = fromMemberId;
    }

    public String getFromMemberName() {
        return fromMemberName;
    }

    public void setFromMemberName(String fromMemberName) {
        this.fromMemberName = fromMemberName;
    }

    public int getToMemberId() {
        return toMemberId;
    }

    public void setToMemberId(int toMemberId) {
        this.toMemberId = toMemberId;
    }

    public String getToMemberName() {
        return toMemberName;
    }

    public void setToMemberName(String toMemberName) {
        this.toMemberName = toMemberName;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
