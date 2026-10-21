package controller.itinerary;

import dao.ItineraryDAO;
import dao.PlaceDAO;
import dao.TripDAO;
import dao.TripMemberDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.ItineraryItem;
import model.Place;
import model.Trip;
import model.User;

@WebServlet(name = "ItineraryServlet", urlPatterns = {
    "/itinerary",
    "/itinerary/add",
    "/itinerary/delete",
    "/itinerary/confirm"
})
public class ItineraryServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final PlaceDAO placeDAO = new PlaceDAO();
    private final ItineraryDAO itineraryDAO = new ItineraryDAO();
    private final TripMemberDAO tripMemberDAO = new TripMemberDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User currentUser = getCurrentUser(request, response);

        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();

        try {
            if ("/itinerary/add".equals(path)) {
                showAddForm(request, response, currentUser);
                return;
            }

            /*
             * Link trong place-detail.jsp hiện đang truyền placeId
             * trực tiếp tới /itinerary. Nếu có placeId thì chuyển
             * sang form thêm lịch trình.
             */
            if (request.getParameter("placeId") != null) {
                int tripId = parsePositiveInt(
                        request.getParameter("tripId")
                );

                int placeId = parsePositiveInt(
                        request.getParameter("placeId")
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/itinerary/add?tripId=" + tripId
                        + "&placeId=" + placeId
                );
                return;
            }

            showItinerary(request, response, currentUser);

        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    e.getMessage()
            );
        } catch (RuntimeException e) {
            throw new ServletException(
                    "Không thể xử lý lịch trình.",
                    e
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request, response);

        if (currentUser == null) {
            return;
        }

        String path = request.getServletPath();

        try {
            if ("/itinerary/delete".equals(path)) {
                deleteItem(request, response, currentUser);
                return;
            }

            if ("/itinerary/add".equals(path)) {
                addItem(request, response, currentUser);
                return;
            }

            if ("/itinerary/confirm".equals(path)) {
                confirmItinerary(request, response, currentUser);
                return;
            }

            /*
             * Nút "+ Thêm vào Itinerary" trong trang Recommendation
             * đang POST tới /itinerary với tripId và placeId.
             * Chuyển người dùng sang form nhập ngày và giờ.
             */
            int tripId = parsePositiveInt(
                    request.getParameter("tripId")
            );

            int placeId = parsePositiveInt(
                    request.getParameter("placeId")
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/itinerary/add?tripId=" + tripId
                    + "&placeId=" + placeId
            );

        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    e.getMessage()
            );
        } catch (RuntimeException e) {
            throw new ServletException(
                    "Không thể cập nhật lịch trình.",
                    e
            );
        }
    }

    private void confirmItinerary(
            HttpServletRequest request,
            HttpServletResponse response,
            User currentUser
    ) throws ServletException, IOException {

        int tripId = parsePositiveInt(
                request.getParameter("tripId")
        );

        Trip trip = tripDAO.findByIdForUser(
                tripId,
                currentUser.getUserId()
        );

        if (trip == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Trip not found or access denied."
            );
            return;
        }

        if (!"OWNER".equalsIgnoreCase(trip.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only the Trip Lead can confirm the itinerary."
            );
            return;
        }

        if ("COMPLETED".equalsIgnoreCase(trip.getStatus())
                || "CANCELLED".equalsIgnoreCase(trip.getStatus())) {
            request.getSession().setAttribute(
                    "errorMessage",
                    "Cannot confirm itinerary for completed or cancelled trips."
            );
            response.sendRedirect(request.getContextPath() + "/itinerary?tripId=" + tripId);
            return;
        }

        java.util.List<ItineraryItem> items = itineraryDAO.findByTrip(tripId);
        if (items.isEmpty()) {
            request.getSession().setAttribute(
                    "errorMessage",
                    "Please add at least one activity to the itinerary before confirming."
            );
            response.sendRedirect(request.getContextPath() + "/itinerary?tripId=" + tripId);
            return;
        }

        java.time.LocalDate today = java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"));
        java.time.LocalDate startDate = trip.getStartDate().toLocalDate();
        java.time.LocalDate endDate = trip.getEndDate().toLocalDate();

        boolean inDates = !today.isBefore(startDate) && !today.isAfter(endDate);

        if ("PLANNING".equalsIgnoreCase(trip.getStatus())) {
            if (inDates) {
                boolean updated = new dao.TripStatusDAO().changeStatus(
                        tripId,
                        currentUser.getUserId(),
                        "PLANNING",
                        "ONGOING",
                        java.sql.Date.valueOf(today)
                );
                if (updated) {
                    request.getSession().setAttribute(
                            "successMessage",
                            "Itinerary confirmed! The trip is now underway (ONGOING)."
                    );
                } else {
                    request.getSession().setAttribute(
                            "successMessage",
                            "Itinerary confirmed and finalized for the group."
                    );
                }
            } else if (today.isBefore(startDate)) {
                request.getSession().setAttribute(
                        "successMessage",
                        "Itinerary confirmed and finalized! The trip will start on " + startDate + "."
                );
            } else {
                request.getSession().setAttribute(
                        "errorMessage",
                        "The scheduled end date for this trip has already passed."
                );
            }
        } else if ("ONGOING".equalsIgnoreCase(trip.getStatus())) {
            request.getSession().setAttribute(
                    "successMessage",
                    "Itinerary schedule confirmed for ongoing trip."
            );
        }

        response.sendRedirect(request.getContextPath() + "/itinerary?tripId=" + tripId);
    }

    private void showItinerary(
            HttpServletRequest request,
            HttpServletResponse response,
            User currentUser
    ) throws ServletException, IOException {

        int tripId = parsePositiveInt(
                request.getParameter("tripId")
        );

        Trip trip = tripDAO.findByIdForUser(
                tripId,
                currentUser.getUserId()
        );

        if (trip == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Trip not found or access denied."
            );
            return;
        }

        if (request.getSession().getAttribute("autoItineraryToken") == null)
            request.getSession().setAttribute("autoItineraryToken", java.util.UUID.randomUUID().toString());
        if(request.getSession().getAttribute("activityStatusToken")==null)
            request.getSession().setAttribute("activityStatusToken",java.util.UUID.randomUUID().toString());
        request.setAttribute("trip", trip);
        request.setAttribute("members", tripMemberDAO.findByTrip(tripId));
        java.util.List<ItineraryItem> items=itineraryDAO.findByTrip(tripId);
        request.setAttribute("items",items);
        BigDecimal remaining=BigDecimal.ZERO;
        for(ItineraryItem item:items) {
            if(("UPCOMING".equals(item.getActivityStatus()) || "IN_PROGRESS".equals(item.getActivityStatus())) && item.getEstimatedCost()!=null)
                remaining=remaining.add(item.getEstimatedCost());
        }
        request.setAttribute("remainingEstimatedCost",remaining);

        request.getRequestDispatcher(
                "/WEB-INF/views/intinerary/intinerary.jsp"
        ).forward(request, response);
    }

    private void showAddForm(
            HttpServletRequest request,
            HttpServletResponse response,
            User currentUser
    ) throws ServletException, IOException {

        int tripId = parsePositiveInt(
                request.getParameter("tripId")
        );

        int placeId = parsePositiveInt(
                request.getParameter("placeId")
        );

        Trip trip = tripDAO.findByIdForUser(
                tripId,
                currentUser.getUserId()
        );

        if (trip == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Trip not found or access denied."
            );
            return;
        }

        if (!"OWNER".equalsIgnoreCase(trip.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only the trip owner can add items to the itinerary."
            );
            return;
        }
        if (!"PLANNING".equalsIgnoreCase(trip.getStatus())
                && !"ONGOING".equalsIgnoreCase(trip.getStatus())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Cannot modify itinerary of a completed or cancelled trip."
            );
            return;
        }

        if (placeId <= 0) {
            String redirectUrl = request.getContextPath() + "/places?tripId=" + tripId;
            if (trip.getDestination() != null && !trip.getDestination().trim().isEmpty()) {
                redirectUrl += "&city=" + java.net.URLEncoder.encode(trip.getDestination().trim(), "UTF-8");
            }
            response.sendRedirect(redirectUrl);
            return;
        }

        Place place = placeDAO.findById(placeId);

        if (place == null) {
            String redirectUrl = request.getContextPath() + "/places?tripId=" + tripId;
            if (trip.getDestination() != null && !trip.getDestination().trim().isEmpty()) {
                redirectUrl += "&city=" + java.net.URLEncoder.encode(trip.getDestination().trim(), "UTF-8");
            }
            response.sendRedirect(redirectUrl);
            return;
        }

        request.setAttribute("trip", trip);
        request.setAttribute("place", place);

        request.getRequestDispatcher(
                "/WEB-INF/views/intinerary/intinerary-form.jsp"
        ).forward(request, response);
    }

    private void addItem(
            HttpServletRequest request,
            HttpServletResponse response,
            User currentUser
    ) throws ServletException, IOException {

        int tripId = parsePositiveInt(
                request.getParameter("tripId")
        );

        int placeId = parsePositiveInt(
                request.getParameter("placeId")
        );

        Trip trip = tripDAO.findByIdForUser(
                tripId,
                currentUser.getUserId()
        );

        if (trip == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Trip not found or access denied."
            );
            return;
        }

        if (!"OWNER".equalsIgnoreCase(trip.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only the trip owner can add items to the itinerary."
            );
            return;
        }
        if (!"PLANNING".equalsIgnoreCase(trip.getStatus())
                && !"ONGOING".equalsIgnoreCase(trip.getStatus())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Cannot modify itinerary of a completed or cancelled trip."
            );
            return;
        }

        Place place = placeDAO.findById(placeId);

        if (place == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Place not found."
            );
            return;
        }

        Date visitDate;
        Time startTime;
        Time endTime;
        BigDecimal estimatedCost;

        try {
            visitDate = Date.valueOf(
                    request.getParameter("visitDate")
            );

            startTime = parseTime(
                    request.getParameter("startTime")
            );

            endTime = parseTime(
                    request.getParameter("endTime")
            );

            estimatedCost = new BigDecimal(
                    request.getParameter("estimatedCost")
            );

        } catch (Exception e) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    place,
                    "Ngày, giờ hoặc chi phí không hợp lệ."
            );
            return;
        }

        String note = request.getParameter("note");

        if (note != null) {
            note = note.trim();
        }
        java.time.LocalDate today = java.time.LocalDate.now(
                java.time.ZoneId.of("Asia/Ho_Chi_Minh")
        );

        if (visitDate.toLocalDate().isBefore(today)) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    place,
                    "Không thể thêm hoạt động vào ngày đã qua."
            );
            return;
        }
        if (visitDate.before(trip.getStartDate())
                || visitDate.after(trip.getEndDate())) {

            forwardFormError(
                    request,
                    response,
                    trip,
                    place,
                    "Ngày tham quan phải nằm trong thời gian của Trip."
            );
            return;
        }

        if (!endTime.after(startTime)) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    place,
                    "Giờ kết thúc phải sau giờ bắt đầu."
            );
            return;
        }

        if (estimatedCost.compareTo(BigDecimal.ZERO) < 0) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    place,
                    "Chi phí dự kiến không được âm."
            );
            return;
        }

        BigDecimal maximumCost
                = new BigDecimal("9999999999999999.99");

        if (estimatedCost.compareTo(maximumCost) > 0) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    place,
                    "Chi phí dự kiến quá lớn."
            );
            return;
        }

        if (note != null && note.length() > 500) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    place,
                    "Ghi chú không được vượt quá 500 ký tự."
            );
            return;
        }

        if (itineraryDAO.hasTimeConflict(
                tripId,
                visitDate,
                startTime,
                endTime
        )) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    place,
                    "Khoảng thời gian này bị trùng với một hoạt động khác."
            );
            return;
        }

        ItineraryItem item = new ItineraryItem();

        item.setTripId(tripId);
        item.setPlaceId(placeId);
        item.setVisitDate(visitDate);
        item.setStartTime(startTime);
        item.setEndTime(endTime);
        item.setNote(note);
        item.setEstimatedCost(estimatedCost);

        itineraryDAO.add(item);

        response.sendRedirect(
                request.getContextPath()
                + "/itinerary?tripId=" + tripId
        );
    }

    private void deleteItem(
            HttpServletRequest request,
            HttpServletResponse response,
            User currentUser
    ) throws IOException {
        Object token=request.getSession().getAttribute("activityStatusToken");
        if(token==null || !token.equals(request.getParameter("csrfToken"))) { response.sendError(403); return; }


        int tripId = parsePositiveInt(
                request.getParameter("tripId")
        );

        int itemId = parsePositiveInt(
                request.getParameter("itemId")
        );

        Trip trip = tripDAO.findByIdForUser(
                tripId,
                currentUser.getUserId()
        );

        if (trip == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Trip not found or access denied."
            );
            return;
        }

        if (!"OWNER".equalsIgnoreCase(trip.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only the trip owner can delete itinerary items."
            );
            return;
        }
        if (!"PLANNING".equalsIgnoreCase(trip.getStatus())
                && !"ONGOING".equalsIgnoreCase(trip.getStatus())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Cannot modify itinerary of a completed or cancelled trip."
            );
            return;
        }

        itineraryDAO.deleteByOwner(
                itemId,
                tripId,
                currentUser.getUserId()
        );

        response.sendRedirect(
                request.getContextPath()
                + "/itinerary?tripId=" + tripId
        );
    }

    private void forwardFormError(
            HttpServletRequest request,
            HttpServletResponse response,
            Trip trip,
            Place place,
            String error
    ) throws ServletException, IOException {

        request.setAttribute("trip", trip);
        request.setAttribute("place", place);
        request.setAttribute("error", error);

        request.getRequestDispatcher(
                "/WEB-INF/views/intinerary/intinerary-form.jsp"
        ).forward(request, response);
    }

    private User getCurrentUser(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("user") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return null;
        }

        User currentUser
                = (User) session.getAttribute("user");

        if (!"USER".equalsIgnoreCase(currentUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to use this feature."
            );
            return null;
        }

        return currentUser;
    }

    private int parsePositiveInt(String value) {
        try {
            int number = Integer.parseInt(value);

            if (number <= 0) {
                throw new NumberFormatException();
            }

            return number;

        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "ID không hợp lệ."
            );
        }
    }

    private Time parseTime(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException();
        }

        String cleanValue = value.trim();

        if (cleanValue.length() == 5) {
            cleanValue += ":00";
        }

        return Time.valueOf(cleanValue);
    }
}
