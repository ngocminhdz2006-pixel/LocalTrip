package controller.itinerary;

import dao.ItineraryDAO;
import dao.PlaceDAO;
import dao.TripDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.*;
import utils.ItineraryEditValidation;
import utils.NotificationService;

@WebServlet("/itinerary/edit")
public class ItineraryEditServlet extends HttpServlet {
    private final TripDAO trips = new TripDAO();
    private final ItineraryDAO itinerary = new ItineraryDAO();
    private final PlaceDAO places = new PlaceDAO();

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { handle(req, resp, false); }
    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { handle(req, resp, true); }

    private void handle(HttpServletRequest req, HttpServletResponse resp, boolean save) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        if (!"USER".equals(user.getRole())) { resp.sendError(403); return; }
        try {
            int tripId = id(req.getParameter("tripId")), itemId = id(req.getParameter("itemId"));
            Trip trip = trips.findByIdForUser(tripId, user.getUserId());
            if (trip == null) { resp.sendError(404); return; }
            if (!"OWNER".equals(trip.getRole()) || !("PLANNING".equals(trip.getStatus()) || "ONGOING".equals(trip.getStatus()))) {
                resp.sendError(403, "You do not have permission to edit activities for this trip."); return;
            }
            ItineraryItem original = null;
            for (ItineraryItem item : itinerary.findByTrip(tripId)) if (item.getItemId() == itemId) original = item;
            if (original == null) { resp.sendError(404, "Activity was removed or replaced. Please reload the itinerary."); return; }
            if(!"UPCOMING".equals(original.getActivityStatus())) { resp.sendError(403,"Only upcoming activities can be edited."); return; }
            boolean restWithoutPlace="REST".equals(original.getActivityType()) && original.getPlaceId()==0;
            req.setAttribute("restWithoutPlace",restWithoutPlace);
            Date today = utils.AppClock.todaySql();
            if (original.getVisitDate().before(today)) { resp.sendError(403, "Cannot edit activities for past dates."); return; }
            List<Place> candidates = places.findForDestination(trip.getDestination());
            if (session.getAttribute("itineraryEditToken") == null) session.setAttribute("itineraryEditToken", UUID.randomUUID().toString());
            req.setAttribute("trip", trip); req.setAttribute("item", original); req.setAttribute("candidates", candidates);
            req.setAttribute("minimumDate", trip.getStartDate().after(today) ? trip.getStartDate() : today);
            if (save) {
                if (!session.getAttribute("itineraryEditToken").equals(req.getParameter("editToken"))) { resp.sendError(403, "Form session expired. Please reload the page."); return; }
                req.setAttribute("submitted", Boolean.TRUE);
                req.setAttribute("revision", req.getParameter("revision"));
                req.setAttribute("submittedPlaceId", 0);
                try {
                    ItineraryItem edited = new ItineraryItem();
                    edited.setItemId(itemId); edited.setTripId(tripId); edited.setPlaceId(restWithoutPlace ? 0 : id(req.getParameter("placeId")));
                    edited.setActivityType(original.getActivityType()); edited.setActivityTitle(original.getActivityTitle());
                    req.setAttribute("submittedPlaceId", edited.getPlaceId());
                    edited.setVisitDate(Date.valueOf(req.getParameter("visitDate")));
                    edited.setStartTime(Time.valueOf(LocalTime.parse(req.getParameter("startTime"))));
                    edited.setEndTime(Time.valueOf(LocalTime.parse(req.getParameter("endTime"))));
                    String costParam = req.getParameter("estimatedCost");
                    edited.setEstimatedCost(costParam != null && !costParam.trim().isEmpty() ? new BigDecimal(costParam.trim()) : original.getEstimatedCost());
                    String note = req.getParameter("note");
                    edited.setNote(note != null ? note.trim() : (original.getNote() != null ? original.getNote() : ""));
                    edited.setLocked(original.isLocked());
                    edited.setSourceType(original.getSourceType());
                    edited.setActivityStatus(original.getActivityStatus());
                    Place selected = null;
                    for (Place place : candidates) if (place.getPlaceId() == edited.getPlaceId()) selected = place;
                    ItineraryEditValidation.validate(trip, original, edited, selected, today);
                    itinerary.updateItemAuthorized(edited, user.getUserId(), req.getParameter("revision"));
                    NotificationService.notifyItineraryChange(tripId, user.getUserId(), itemId, user.getFullName() + " updated an activity in the itinerary for \"" + trip.getName() + "\".");
                    session.setAttribute("successMessage", "Activity updated successfully.");
                    resp.sendRedirect(req.getContextPath() + "/itinerary?tripId=" + tripId); return;
                } catch (IllegalArgumentException ex) { req.setAttribute("error", ex.getMessage()); }
                catch (java.time.DateTimeException ex) { req.setAttribute("error", "Invalid date or time."); }
                catch (NullPointerException ex) { req.setAttribute("error", "Please enter date, time, destination and estimated cost."); }
            } else req.setAttribute("revision", itinerary.revisionForTrip(tripId));
            req.getRequestDispatcher("/WEB-INF/views/intinerary/intinerary-edit.jsp").forward(req, resp);
        } catch (IllegalArgumentException ex) { resp.sendError(400, "Invalid trip or activity ID."); }
        catch (RuntimeException ex) { throw new ServletException("Unable to update activity. Please reload the itinerary.", ex); }
    }
    private int id(String value) { int result = Integer.parseInt(value); if (result <= 0) throw new IllegalArgumentException(); return result; }
}
