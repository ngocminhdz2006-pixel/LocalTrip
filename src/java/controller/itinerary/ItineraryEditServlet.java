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
                resp.sendError(403, "Bạn không có quyền sửa hoạt động của chuyến đi này."); return;
            }
            ItineraryItem original = null;
            for (ItineraryItem item : itinerary.findByTrip(tripId)) if (item.getItemId() == itemId) original = item;
            if (original == null) { resp.sendError(404, "Hoạt động đã bị xóa hoặc thay thế. Hãy mở lại lịch trình."); return; }
            Date today = Date.valueOf(LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")));
            if (original.getVisitDate().before(today)) { resp.sendError(403, "Không thể sửa hoạt động của ngày đã qua."); return; }
            List<Place> candidates = places.findForDestination(trip.getDestination());
            if (session.getAttribute("itineraryEditToken") == null) session.setAttribute("itineraryEditToken", UUID.randomUUID().toString());
            req.setAttribute("trip", trip); req.setAttribute("item", original); req.setAttribute("candidates", candidates);
            req.setAttribute("minimumDate", trip.getStartDate().after(today) ? trip.getStartDate() : today);
            if (save) {
                if (!session.getAttribute("itineraryEditToken").equals(req.getParameter("editToken"))) { resp.sendError(403, "Phiên biểu mẫu đã hết hạn. Hãy tải lại trang."); return; }
                req.setAttribute("submitted", Boolean.TRUE);
                req.setAttribute("revision", req.getParameter("revision"));
                req.setAttribute("submittedPlaceId", 0);
                try {
                    ItineraryItem edited = new ItineraryItem();
                    edited.setItemId(itemId); edited.setTripId(tripId); edited.setPlaceId(id(req.getParameter("placeId")));
                    req.setAttribute("submittedPlaceId", edited.getPlaceId());
                    edited.setVisitDate(Date.valueOf(req.getParameter("visitDate")));
                    edited.setStartTime(Time.valueOf(LocalTime.parse(req.getParameter("startTime"))));
                    edited.setEndTime(Time.valueOf(LocalTime.parse(req.getParameter("endTime"))));
                    edited.setEstimatedCost(new BigDecimal(req.getParameter("estimatedCost")));
                    String note = req.getParameter("note"); edited.setNote(note == null ? "" : note.trim());
                    Place selected = null;
                    for (Place place : candidates) if (place.getPlaceId() == edited.getPlaceId()) selected = place;
                    ItineraryEditValidation.validate(trip, original, edited, selected, today);
                    itinerary.updateItemAuthorized(edited, user.getUserId(), req.getParameter("revision"));
                    session.setAttribute("successMessage", "Đã cập nhật hoạt động. Bản đồ và thời tiết sử dụng lịch trình mới.");
                    resp.sendRedirect(req.getContextPath() + "/itinerary?tripId=" + tripId); return;
                } catch (IllegalArgumentException ex) { req.setAttribute("error", ex.getMessage()); }
                catch (java.time.DateTimeException ex) { req.setAttribute("error", "Ngày hoặc giờ không hợp lệ."); }
                catch (NullPointerException ex) { req.setAttribute("error", "Vui lòng nhập đầy đủ ngày, giờ, địa điểm và chi phí."); }
            } else req.setAttribute("revision", itinerary.revisionForTrip(tripId));
            req.getRequestDispatcher("/WEB-INF/views/intinerary/intinerary-edit.jsp").forward(req, resp);
        } catch (IllegalArgumentException ex) { resp.sendError(400, "Mã chuyến đi hoặc hoạt động không hợp lệ."); }
        catch (RuntimeException ex) { throw new ServletException("Không thể cập nhật hoạt động. Hãy mở lại lịch trình.", ex); }
    }
    private int id(String value) { int result = Integer.parseInt(value); if (result <= 0) throw new IllegalArgumentException(); return result; }
}
