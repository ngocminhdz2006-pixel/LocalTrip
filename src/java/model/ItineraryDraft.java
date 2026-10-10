package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/** A session-local preview; never persisted until the owner confirms it. */
public final class ItineraryDraft {
    private final int tripId, ownerId;
    private final Date fromDate;
    private final String revision, token;
    private final long createdAt;
    private final List<ItineraryItem> items;
    public ItineraryDraft(int tripId, int ownerId, Date fromDate, String revision, List<ItineraryItem> items) {
        this.tripId = tripId; this.ownerId = ownerId; this.fromDate = new Date(fromDate.getTime());
        this.revision = revision; this.token = UUID.randomUUID().toString(); this.createdAt = System.currentTimeMillis();
        this.items = copy(items);
    }
    public int getTripId() { return tripId; }
    public int getOwnerId() { return ownerId; }
    public Date getFromDate() { return new Date(fromDate.getTime()); }
    public String getRevision() { return revision; }
    public String getToken() { return token; }
    public List<ItineraryItem> getItems() { return copy(items); }
    public boolean isExpired() { return System.currentTimeMillis() - createdAt > 30 * 60 * 1000L; }
    public BigDecimal totalCost() {
        BigDecimal total = BigDecimal.ZERO;
        for (ItineraryItem item : items) if (item.getEstimatedCost() != null) total = total.add(item.getEstimatedCost());
        return total;
    }
    private static List<ItineraryItem> copy(List<ItineraryItem> source) {
        List<ItineraryItem> result = new ArrayList<ItineraryItem>();
        for (ItineraryItem item : source) {
            ItineraryItem clone = new ItineraryItem();
            clone.setTripId(item.getTripId()); clone.setPlaceId(item.getPlaceId()); clone.setPlaceName(item.getPlaceName());
            clone.setVisitDate(new Date(item.getVisitDate().getTime()));
            clone.setStartTime(new java.sql.Time(item.getStartTime().getTime()));
            clone.setEndTime(new java.sql.Time(item.getEndTime().getTime()));
            clone.setNote(item.getNote()); clone.setEstimatedCost(item.getEstimatedCost());
            clone.setLatitude(item.getLatitude()); clone.setLongitude(item.getLongitude());
            result.add(clone);
        }
        return result;
    }
}
