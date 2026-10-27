package utils;

import dao.NotificationDAO;
import dao.TripMemberDAO;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.TripMember;

public class NotificationService {

    private static final Logger LOGGER = Logger.getLogger(NotificationService.class.getName());
    private static final NotificationDAO notificationDAO = new NotificationDAO();
    private static final TripMemberDAO tripMemberDAO = new TripMemberDAO();

    /**
     * Emits a notification to a specific user.
     * Never notifies the actor about their own action.
     * Catches and logs all errors so the caller's transaction is never failed or rolled back.
     */
    public static void notify(int userId, Integer actorUserId, String type, Integer tripId, Integer refId, String message) {
        if (actorUserId != null && actorUserId == userId) {
            return;
        }
        try {
            notificationDAO.insert(userId, actorUserId, type, tripId, refId, message);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to emit notification to user " + userId + ": " + e.getMessage(), e);
        }
    }

    /**
     * Emits a notification to all members of a trip, excluding the actor.
     */
    public static void notifyTripMembers(int tripId, Integer actorUserId, String type, Integer refId, String message) {
        try {
            List<TripMember> members = tripMemberDAO.findByTrip(tripId);
            for (TripMember m : members) {
                if (actorUserId != null && actorUserId == m.getUserId()) {
                    continue;
                }
                notify(m.getUserId(), actorUserId, type, tripId, refId, message);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to notify members of trip " + tripId + ": " + e.getMessage(), e);
        }
    }

    /**
     * Emits a coalesced itinerary change notification to all trip members (except actor).
     * Coalesces unread notifications within 5 minutes.
     */
    public static void notifyItineraryChange(int tripId, Integer actorUserId, Integer refId, String message) {
        try {
            List<TripMember> members = tripMemberDAO.findByTrip(tripId);
            for (TripMember m : members) {
                if (actorUserId != null && actorUserId == m.getUserId()) {
                    continue;
                }
                try {
                    notificationDAO.coalesceItineraryNotification(m.getUserId(), actorUserId, "ITINERARY_CHANGE", tripId, refId, message, 5);
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Failed to coalesce itinerary notification for user " + m.getUserId() + ": " + e.getMessage(), e);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to notify itinerary change for trip " + tripId + ": " + e.getMessage(), e);
        }
    }
}
