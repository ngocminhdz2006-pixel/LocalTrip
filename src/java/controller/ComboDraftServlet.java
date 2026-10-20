package controller;

import dao.PlaceDAO;
import dao.TripDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.ItineraryDraft;
import model.Trip;
import model.User;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.ItineraryItem;
import model.Place;

@WebServlet("/combos/draft")
public class ComboDraftServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final PlaceDAO placeDAO = new PlaceDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = session == null
                ? null : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (!"USER".equals(user.getRole())) {
            response.sendError(403);
            return;
        }

        int tripId;

        try {
            tripId = Integer.parseInt(
                    request.getParameter("tripId"));

            if (tripId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400);
            return;
        }

        Trip trip = tripDAO.findByIdForUser(
                tripId, user.getUserId());

        if (trip == null) {
            response.sendError(404);
            return;
        }

        if (!"OWNER".equals(trip.getRole())) {
            response.sendError(403);
            return;
        }

        if (!"PLANNING".equals(trip.getStatus())) {
            response.sendError(
                    409, "This trip is no longer in planning.");
            return;
        }

        String draftKey = "comboDraft:" + tripId;
        Object stored = session.getAttribute(draftKey);

        ItineraryDraft draft = stored instanceof ItineraryDraft
                ? (ItineraryDraft) stored : null;

        if (draft == null || draft.isExpired()
                || draft.getTripId() != tripId
                || draft.getOwnerId() != user.getUserId()) {

            session.removeAttribute(draftKey);
            session.setAttribute("errorMessage",
                    "Your draft has expired. Please select a combo again.");

            response.sendRedirect(
                    request.getContextPath()
                    + "/combos?tripId=" + tripId);
            return;
        }

        request.setAttribute("trip", trip);
        request.setAttribute("currentTrip", trip);
        request.setAttribute("comboDraft", draft);
        request.setAttribute("draftItems", draft.getItems());

        request.setAttribute("places",
                placeDAO.findForDestination(
                        trip.getDestination()));

        request.setAttribute(
                "pageTitle", "Edit itinerary draft");

        request.getRequestDispatcher(
                "/WEB-INF/views/combo/combo-draft.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null
                ? null : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (!"USER".equals(user.getRole())) {
            response.sendError(403);
            return;
        }

        int tripId;

        try {
            tripId = Integer.parseInt(
                    request.getParameter("tripId"));

            if (tripId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400);
            return;
        }

        Trip trip = tripDAO.findByIdForUser(
                tripId, user.getUserId());

        if (trip == null) {
            response.sendError(404);
            return;
        }

        if (!"OWNER".equals(trip.getRole())) {
            response.sendError(403);
            return;
        }

        if (!"PLANNING".equals(trip.getStatus())) {
            response.sendError(409);
            return;
        }

        String draftKey = "comboDraft:" + tripId;

        // Kiểm tra và thay bản nháp trong cùng một khóa,
        // tránh hai tab lưu đè nhau.
        synchronized (session) {
            Object stored = session.getAttribute(draftKey);

            ItineraryDraft draft = stored instanceof ItineraryDraft
                    ? (ItineraryDraft) stored : null;

            if (draft == null || draft.isExpired()
                    || draft.getTripId() != tripId
                    || draft.getOwnerId() != user.getUserId()) {

                session.removeAttribute(draftKey);
                session.setAttribute("errorMessage",
                        "Your draft has expired. Select a combo again.");

                response.sendRedirect(
                        request.getContextPath()
                        + "/combos?tripId=" + tripId);
                return;
            }

            // Token vừa chống gửi giả, vừa phát hiện bản nháp cũ.
            if (!draft.getToken().equals(
                    request.getParameter("draftToken"))) {

                response.sendError(
                        409, "The draft has changed. Reload this page.");
                return;
            }

            try {
                Map<Integer, Place> availablePlaces = new HashMap<>();

                for (Place place : placeDAO.findForDestination(
                        trip.getDestination())) {
                    availablePlaces.put(place.getPlaceId(), place);
                }

                List<ItineraryItem> originals = draft.getItems();
                List<ItineraryItem> updated = new ArrayList<>();

                LocalDate today = LocalDate.now(
                        ZoneId.of("Asia/Ho_Chi_Minh"));

                for (int i = 0; i < originals.size(); i++) {
                    if ("yes".equals(
                            request.getParameter("remove_" + i))) {
                        continue;
                    }

                    ItineraryItem item = originals.get(i);

                    LocalDate date = LocalDate.parse(
                            required(request, "visitDate_" + i));

                    LocalTime start = LocalTime.parse(
                            required(request, "startTime_" + i));

                    LocalTime end = LocalTime.parse(
                            required(request, "endTime_" + i));

                    if (date.isBefore(today)
                            || date.isBefore(
                                    draft.getFromDate().toLocalDate())
                            || date.isBefore(
                                    trip.getStartDate().toLocalDate())
                            || date.isAfter(
                                    trip.getEndDate().toLocalDate())) {

                        throw new IllegalArgumentException(
                                "Activity " + (i + 1)
                                + ": date is outside the planning period.");
                    }

                    if (!end.isAfter(start)) {
                        throw new IllegalArgumentException(
                                "Activity " + (i + 1)
                                + ": end time must be after start time.");
                    }

                    BigDecimal cost = new BigDecimal(
                            required(request, "estimatedCost_" + i));

                    if (cost.signum() < 0
                            || cost.compareTo(new BigDecimal(
                                    "9999999999999999.99")) > 0
                            || cost.stripTrailingZeros().scale() > 2) {

                        throw new IllegalArgumentException(
                                "Activity " + (i + 1)
                                + ": invalid estimated cost.");
                    }

                    String note = request.getParameter("note_" + i);

                    if (note == null || note.length() > 500) {
                        throw new IllegalArgumentException(
                                "Notes must contain at most 500 characters.");
                    }

                    // Khung nghỉ không có địa điểm giữ nguyên placeId = 0.
                    if (!"REST".equals(item.getActivityType())
                            || item.getPlaceId() != 0) {

                        int placeId = Integer.parseInt(
                                required(request, "placeId_" + i));

                        Place place = availablePlaces.get(placeId);

                        if (place == null || !place.isActive()) {
                            throw new IllegalArgumentException(
                                    "Activity " + (i + 1)
                                    + ": place is no longer available.");
                        }

                        if (("MEAL".equals(item.getActivityType())
                                && !"FOOD".equals(place.getCategoryCode()))
                                || ("CAFE".equals(item.getActivityType())
                                && !"CAFE".equals(place.getCategoryCode()))) {

                            throw new IllegalArgumentException(
                                    "Activity " + (i + 1)
                                    + ": place does not match the activity type.");
                        }

                        if (!withinOpeningHours(place, start, end)) {
                            throw new IllegalArgumentException(
                                    "Activity " + (i + 1)
                                    + ": selected time is outside opening hours.");
                        }

                        item.setPlaceId(placeId);
                        item.setPlaceName(place.getPlaceName());
                        item.setLatitude(place.getLatitude());
                        item.setLongitude(place.getLongitude());

                        // Tránh hiện tên địa điểm cũ sau khi đổi địa điểm.
                        item.setActivityTitle(place.getPlaceName());
                    }

                    item.setVisitDate(Date.valueOf(date));
                    item.setStartTime(Time.valueOf(start));
                    item.setEndTime(Time.valueOf(end));
                    item.setEstimatedCost(cost);
                    item.setNote(note.trim());

                    updated.add(item);
                }

                if (updated.isEmpty()) {
                    throw new IllegalArgumentException(
                            "Keep at least one activity in the draft.");
                }

                updated.sort(
                        Comparator.comparing(ItineraryItem::getVisitDate)
                                .thenComparing(ItineraryItem::getStartTime));

                for (int i = 1; i < updated.size(); i++) {
                    ItineraryItem previous = updated.get(i - 1);
                    ItineraryItem current = updated.get(i);

                    if (!previous.getVisitDate().equals(
                            current.getVisitDate())) {
                        continue;
                    }

                    if (current.getStartTime().before(
                            previous.getEndTime())) {

                        throw new IllegalArgumentException(
                                "Activities overlap. Adjust their times.");
                    }

                    if (previous.getPlaceId() > 0
                            && current.getPlaceId() > 0
                            && previous.getPlaceId() != current.getPlaceId()) {

                        long gap = java.time.Duration.between(
                                previous.getEndTime().toLocalTime(),
                                current.getStartTime().toLocalTime())
                                .toMinutes();

                        if (gap < 15) {
                            throw new IllegalArgumentException(
                                    "Allow at least 15 minutes between different places.");
                        }
                    }
                }

                ItineraryDraft saved = new ItineraryDraft(
                        tripId,
                        user.getUserId(),
                        draft.getFromDate(),
                        draft.getRevision(),
                        updated);

                session.setAttribute(draftKey, saved);
                session.setAttribute("successMessage",
                        "Draft saved. Your current itinerary is unchanged.");

            } catch (java.time.DateTimeException e) {
                session.setAttribute("errorMessage",
                        "Invalid date or time. The draft was not saved.");

            } catch (IllegalArgumentException e) {
                session.setAttribute("errorMessage",
                        e instanceof NumberFormatException
                                ? "Invalid place or cost. The draft was not saved."
                                : e.getMessage());
            }
        }

        response.sendRedirect(
                request.getContextPath()
                + "/combos/draft?tripId=" + tripId);
    }

    private String required(
            HttpServletRequest request, String name) {

        String value = request.getParameter(name);

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Complete all required fields before saving.");
        }

        return value.trim();
    }

    private boolean withinOpeningHours(
            Place place, LocalTime start, LocalTime end) {

        Time opening = place.getOpeningTime();
        Time closing = place.getClosingTime();

        if (opening == null || closing == null) {
            return false;
        }

        LocalTime open = opening.toLocalTime();
        LocalTime close = closing.toLocalTime();

        // Bằng nhau chưa đủ thông tin để coi là mở 24 giờ.
        if (open.equals(close)) {
            return false;
        }

        if (close.isAfter(open)) {
            return !start.isBefore(open) && !end.isAfter(close);
        }

        // Địa điểm mở qua đêm: hoạt động vẫn nằm trong một ngày.
        return !start.isBefore(open) || !end.isAfter(close);
    }
}
