package controller;

import dao.ComboTemplateDAO;
import dao.ItineraryDAO;
import dao.PlaceDAO;
import dao.TripDAO;
import dao.TripMemberDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.ComboTemplate;
import model.ItineraryDraft;
import model.ItineraryItem;
import model.ComboTemplate.Activity;
import model.Place;
import model.Trip;
import model.TripMember;
import model.User;

@WebServlet("/combos/preview")
public class ComboPreviewServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final TripMemberDAO memberDAO = new TripMemberDAO();
    private final ComboTemplateDAO comboDAO = new ComboTemplateDAO();
    private final PlaceDAO placeDAO = new PlaceDAO();
    private final ItineraryDAO itineraryDAO = new ItineraryDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = session == null ? null
                : (User) session.getAttribute("user");

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
        int comboId;

        try {
            tripId = positiveInt(request.getParameter("tripId"));
            comboId = positiveInt(request.getParameter("comboId"));
        } catch (IllegalArgumentException e) {
            response.sendError(400, e.getMessage());
            return;
        }

        try {
            Trip trip = tripDAO.findByIdForUser(
                    tripId, user.getUserId());

            if (trip == null) {
                response.sendError(404);
                return;
            }

            if (!"OWNER".equals(trip.getRole())) {
                response.sendError(
                        403, "Only the trip leader can select a combo.");
                return;
            }

            if (!"PLANNING".equals(trip.getStatus())) {
                response.sendError(
                        409, "This preview is available for planning trips.");
                return;
            }

            LocalDate today = utils.AppClock.today();

            LocalDate start = trip.getStartDate().toLocalDate();
            LocalDate end = trip.getEndDate().toLocalDate();

            if (today.isAfter(start)) {
                start = today;
            }

            if (start.isAfter(end)) {
                throw new IllegalArgumentException(
                        "The trip dates have passed.");
            }

            int days = Math.toIntExact(
                    ChronoUnit.DAYS.between(start, end) + 1);

            ComboTemplate selected = null;

            for (ComboTemplate candidate
                    : comboDAO.findActiveForDestination(
                            trip.getDestination(), days)) {

                if (candidate.getId() == comboId) {
                    selected = candidate;
                    break;
                }
            }

            if (selected == null) {
                throw new IllegalArgumentException(
                        "This combo is unavailable or no longer "
                        + "matches the trip area and dates.");
            }

            Map<Integer, Place> places = new HashMap<>();

            for (Place place
                    : placeDAO.findForDestination(trip.getDestination())) {
                places.put(place.getPlaceId(), place);
            }

            Set<Integer> memberIds = new HashSet<>();
            memberIds.add(trip.getOwnerId());

            for (TripMember member : memberDAO.findByTrip(tripId)) {
                memberIds.add(member.getUserId());
            }

            int memberCount = memberIds.size();

            List<Map<String, Object>> activities = new ArrayList<>();
            List<ItineraryItem> draftItems = new ArrayList<>();

// Lấy phiên bản lịch trước khi chuẩn bị bản nháp.
// Khi xác nhận sẽ kiểm tra lại để tránh ghi đè lịch đã thay đổi.
            String itineraryRevision = itineraryDAO.revisionForTrip(tripId);
            for (Activity activity : selected.getActivities()) {
                if (activity.getDayNumber() < 1
                        || activity.getDayNumber() > days) {
                    throw new IllegalArgumentException(
                            "The combo contains an invalid day.");
                }

                if (activity.getStartTime() == null
                        || activity.getEndTime() == null
                        || !activity.getEndTime().after(
                                activity.getStartTime())) {
                    throw new IllegalArgumentException(
                            "The combo contains an invalid time.");
                }

                Place place = null;

                if (activity.getPlaceId() != null) {
                    place = places.get(activity.getPlaceId());

                    if (place == null) {
                        throw new IllegalArgumentException(
                                "A place is no longer available.");
                    }

                    if (place.getOpeningTime() == null
                            || place.getClosingTime() == null
                            || !place.getClosingTime().after(
                                    place.getOpeningTime())
                            || activity.getStartTime().before(
                                    place.getOpeningTime())
                            || activity.getEndTime().after(
                                    place.getClosingTime())) {
                        throw new IllegalArgumentException(
                                "Opening hours have changed for "
                                + place.getPlaceName()
                                + ". Ask an admin to update the combo.");
                    }

                    if (("MEAL".equals(activity.getActivityType())
                            && !"FOOD".equals(place.getCategoryCode()))
                            || ("CAFE".equals(activity.getActivityType())
                            && !"CAFE".equals(place.getCategoryCode()))) {
                        throw new IllegalArgumentException(
                                "A place category no longer matches "
                                + "the combo activity.");
                    }

                } else if (!"REST".equals(activity.getActivityType())) {
                    throw new IllegalArgumentException(
                            "An activity is missing its place.");
                }

                Map<String, Object> row = new LinkedHashMap<>();

                row.put("dayNumber", activity.getDayNumber());
                row.put("date", Date.valueOf(
                        start.plusDays(activity.getDayNumber() - 1)));

                row.put("title", activity.getTitle());
                row.put("activityType", activity.getActivityType());
                row.put("startTime", activity.getStartTime());
                row.put("endTime", activity.getEndTime());
                row.put("placeName",
                        place == null ? null : place.getPlaceName());
                row.put("address",
                        place == null ? null : place.getAddress());
                row.put("costPerPerson",
                        activity.getEstimatedCostPerPerson());
                row.put("note", activity.getNote());

                activities.add(row);
                ItineraryItem draftItem = new ItineraryItem();

                draftItem.setTripId(tripId);
                draftItem.setPlaceId(
                        activity.getPlaceId() == null
                        ? 0 : activity.getPlaceId());

                draftItem.setVisitDate(Date.valueOf(
                        start.plusDays(activity.getDayNumber() - 1)));

                draftItem.setStartTime(activity.getStartTime());
                draftItem.setEndTime(activity.getEndTime());

                draftItem.setActivityType(activity.getActivityType());
                draftItem.setActivityTitle(activity.getTitle());
                draftItem.setActivityStatus("UPCOMING");
                draftItem.setNote(activity.getNote());

// Lịch lưu chi phí dự kiến của cả nhóm.
                BigDecimal costPerPerson
                        = activity.getEstimatedCostPerPerson();

                draftItem.setEstimatedCost(
                        (costPerPerson == null ? BigDecimal.ZERO : costPerPerson)
                                .multiply(BigDecimal.valueOf(memberCount)));

                if (place != null) {
                    draftItem.setPlaceName(place.getPlaceName());
                    draftItem.setLatitude(place.getLatitude());
                    draftItem.setLongitude(place.getLongitude());
                } else {
                    draftItem.setPlaceName(activity.getTitle());
                }

                draftItems.add(draftItem);
            }

            BigDecimal groupCost
                    = selected.getEstimatedCostPerPerson().multiply(
                            BigDecimal.valueOf(memberCount));

            BigDecimal budget = trip.getBudget() == null
                    ? BigDecimal.ZERO : trip.getBudget();
            if (draftItems.isEmpty()) {
                throw new IllegalArgumentException(
                        "This combo does not have activities to generate a draft.");
            }

            ItineraryDraft comboDraft = new ItineraryDraft(
                    tripId,
                    user.getUserId(),
                    Date.valueOf(start),
                    itineraryRevision,
                    draftItems);
            comboDraft.setComboId(selected.getId());

// Tách bản nháp combo khỏi những luồng tạo lịch khác.
// Mỗi chuyến có một bản nháp combo trong phiên đăng nhập.
            session.setAttribute(
                    "comboDraft:" + tripId,
                    comboDraft);

            request.setAttribute("comboDraft", comboDraft);
            request.setAttribute("trip", trip);
            request.setAttribute("currentTrip", trip);
            request.setAttribute("selectedCombo", selected);
            request.setAttribute("comboReviews", comboDAO.getReviewsForCombo(selected.getId()));
            request.setAttribute("previewActivities", activities);
            request.setAttribute("memberCount", memberCount);
            request.setAttribute("groupCost", groupCost);
            request.setAttribute("budgetDefined", budget.signum() > 0);
            request.setAttribute("overBudget",
                    budget.signum() > 0 && groupCost.compareTo(budget) > 0);

            request.setAttribute(
                    "oldItems", itineraryDAO.findByTrip(tripId));

            request.setAttribute("pageTitle", "Preview itinerary");

            request.getRequestDispatcher(
                    "/WEB-INF/views/combo/combo-preview.jsp")
                    .forward(request, response);

        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", e.getMessage());

            response.sendRedirect(
                    request.getContextPath()
                    + "/combos?tripId=" + tripId);

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Unable to preview combo.", e);
        }
    }

    private int positiveInt(String value) {
        try {
            int number = Integer.parseInt(value);

            if (number > 0) {
                return number;
            }
        } catch (NumberFormatException ignored) {
        }

        throw new IllegalArgumentException("Invalid trip or combo ID.");
    }
}
