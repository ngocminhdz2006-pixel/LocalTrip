package utils;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import model.ItineraryItem;
import model.Trip;
import model.Place;

public final class ItineraryEditValidation {
    private ItineraryEditValidation() { }
    public static void validate(Trip trip, ItineraryItem original, ItineraryItem edited, Place place, Date today) {
        if (!"OWNER".equals(trip.getRole()) || !("PLANNING".equals(trip.getStatus()) || "ONGOING".equals(trip.getStatus())))
            throw new IllegalArgumentException("Only the trip owner can edit activities for planned or ongoing trips.");
        if (!"UPCOMING".equals(original.getActivityStatus())) throw new IllegalArgumentException("Only upcoming activities can be edited.");
        if (original.getVisitDate().before(today)) throw new IllegalArgumentException("Cannot edit activities for past dates.");
        if (edited.getVisitDate().before(today) || edited.getVisitDate().before(trip.getStartDate()) || edited.getVisitDate().after(trip.getEndDate()))
            throw new IllegalArgumentException("Activity date must be within trip duration and not in the past.");
        if (!edited.getEndTime().after(edited.getStartTime())) throw new IllegalArgumentException("End time must be after start time.");
        BigDecimal cost = edited.getEstimatedCost();
        if (cost == null || cost.signum() < 0 || cost.compareTo(new BigDecimal("9999999999999999.99")) > 0 || cost.stripTrailingZeros().scale() > 2)
            throw new IllegalArgumentException("Invalid estimated cost; enter a non-negative number with at most two decimals.");
        if (edited.getNote() != null && edited.getNote().length() > 500) throw new IllegalArgumentException("Note cannot exceed 500 characters.");
        if ("REST".equals(original.getActivityType()) && original.getPlaceId()==0 && edited.getPlaceId()==0) return;
        if (place == null || !place.isActive()) throw new IllegalArgumentException("Destination is no longer active.");
        Time open = place.getOpeningTime(), close = place.getClosingTime();
        boolean overnight = open != null && close != null && close.before(open);
        boolean valid = overnight ? (!edited.getStartTime().before(open) || !edited.getEndTime().after(close))
                : (open == null || !edited.getStartTime().before(open)) && (close == null || !edited.getEndTime().after(close));
        if (!valid) throw new IllegalArgumentException("Activity hours must be within venue operating hours.");
    }
}
