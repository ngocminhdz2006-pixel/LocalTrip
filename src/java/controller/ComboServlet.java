package controller;

import dao.ItineraryDAO;
import dao.PlaceDAO;
import dao.TripDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
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

@WebServlet(name = "ComboServlet", urlPatterns = {"/combo"})
public class ComboServlet extends HttpServlet {
    private final TripDAO tripDAO = new TripDAO();
    private final PlaceDAO placeDAO = new PlaceDAO();
    private final ItineraryDAO itineraryDAO = new ItineraryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = requireUser(request, response);
        if (user == null) return;
        try {
            int tripId = positiveInt(request.getParameter("tripId"));
            Trip trip = tripDAO.findByIdForUser(tripId, user.getUserId());
            if (trip == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chuyến đi hoặc bạn không có quyền truy cập.");
                return;
            }
            String profile = normalizeProfile(request.getParameter("profile"));
            Date visitDate = parseDate(request.getParameter("date"), trip.getStartDate());
            if (visitDate == null || visitDate.before(trip.getStartDate()) || visitDate.after(trip.getEndDate())) {
                request.setAttribute("error", "Ngày chọn phải nằm trong khoảng thời gian của chuyến đi.");
                visitDate = trip.getStartDate();
            }
            request.setAttribute("trip", trip);
            request.setAttribute("profile", profile);
            request.setAttribute("visitDate", visitDate.toString());
            request.setAttribute("comboPlaces", buildCombo(profile));
            request.getRequestDispatcher("/WEB-INF/views/combo/combo.jsp").forward(request, response);
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Trip ID hoặc ngày không hợp lệ.");
        } catch (RuntimeException ex) {
            throw new ServletException("Không thể tạo combo địa điểm.", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = requireUser(request, response);
        if (user == null) return;
        try {
            int tripId = positiveInt(request.getParameter("tripId"));
            Trip trip = tripDAO.findByIdForUser(tripId, user.getUserId());
            if (trip == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chuyến đi hoặc bạn không có quyền truy cập.");
                return;
            }
            String profile = normalizeProfile(request.getParameter("profile"));
            Date visitDate = parseDate(request.getParameter("date"), null);
            if (visitDate == null || visitDate.before(trip.getStartDate()) || visitDate.after(trip.getEndDate())) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ngày chọn phải nằm trong khoảng thời gian của chuyến đi.");
                return;
            }
            List<Place> places = buildCombo(profile);
            Time[] starts = {Time.valueOf("08:00:00"), Time.valueOf("11:00:00"), Time.valueOf("15:00:00")};
            Time[] ends = {Time.valueOf("10:00:00"), Time.valueOf("13:00:00"), Time.valueOf("17:00:00")};
            List<ItineraryItem> existing = itineraryDAO.findByTrip(tripId);
            Set<Integer> existingPlaceIds = new HashSet<Integer>();
            for (ItineraryItem item : existing) {
                if (visitDate.equals(item.getVisitDate())) existingPlaceIds.add(item.getPlaceId());
            }
            int added = 0;
            for (int i = 0; i < places.size() && i < 3; i++) {
                Place place = places.get(i);
                if (existingPlaceIds.contains(place.getPlaceId())) continue;
                if (itineraryDAO.hasTimeConflict(tripId, visitDate, starts[i], ends[i])) continue;
                ItineraryItem item = new ItineraryItem();
                item.setTripId(tripId);
                item.setPlaceId(place.getPlaceId());
                item.setVisitDate(visitDate);
                item.setStartTime(starts[i]);
                item.setEndTime(ends[i]);
                item.setNote("Combo " + profileLabel(profile) + " · được thêm từ Combo địa điểm");
                item.setEstimatedCost(place.getEstimatedCost() == null ? BigDecimal.ZERO : place.getEstimatedCost());
                if (itineraryDAO.add(item)) {
                    added++;
                    existingPlaceIds.add(place.getPlaceId());
                }
            }
            String message = added > 0
                    ? "Đã thêm " + added + " địa điểm vào lịch trình. Các địa điểm trùng giờ hoặc đã có trong ngày được bỏ qua."
                    : "Không có địa điểm mới được thêm. Có thể các địa điểm đã có trong ngày hoặc bị trùng giờ.";
            response.sendRedirect(request.getContextPath() + "/combo?tripId=" + tripId
                    + "&profile=" + profile + "&date=" + visitDate.toString()
                    + "&message=" + java.net.URLEncoder.encode(message, "UTF-8"));
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thông tin combo không hợp lệ.");
        } catch (RuntimeException ex) {
            throw new ServletException("Không thể thêm combo vào lịch trình.", ex);
        }
    }

    private List<Place> buildCombo(final String profile) {
        List<Place> all = placeDAO.findAll();
        Collections.sort(all, new Comparator<Place>() {
            @Override public int compare(Place a, Place b) {
                int score = score(b, profile) - score(a, profile);
                if (score != 0) return score;
                int rating = safeRating(b).compareTo(safeRating(a));
                if (rating != 0) return rating;
                return a.getPlaceName().compareToIgnoreCase(b.getPlaceName());
            }
        });
        List<Place> selected = new ArrayList<Place>();
        Set<Integer> categoryIds = new HashSet<Integer>();
        for (Place place : all) {
            if (selected.size() >= 3) break;
            if (selected.isEmpty() || !categoryIds.contains(place.getCategoryId())) {
                selected.add(place);
                categoryIds.add(place.getCategoryId());
            }
        }
        if (selected.size() < 3) {
            for (Place place : all) {
                if (selected.size() >= 3) break;
                boolean exists = false;
                for (Place chosen : selected) if (chosen.getPlaceId() == place.getPlaceId()) exists = true;
                if (!exists) selected.add(place);
            }
        }
        return selected;
    }

    private int score(Place p, String profile) {
        String tags = safe(p.getSeasonalTags()).toUpperCase(Locale.ROOT);
        String text = (safe(p.getPlaceName()) + " " + safe(p.getCategoryName()) + " "
                + safe(p.getDescription()) + " " + safe(p.getPlaceType())).toLowerCase(Locale.ROOT);
        int score = p.getRating() == null ? 0 : p.getRating().intValue();
        String seasonTag = profile.toUpperCase(Locale.ROOT);
        if (tags.contains(seasonTag)) score += 100;
        if (tags.contains("ALL")) score += 2;
        if ("spring".equals(profile)) {
            score += matches(text, "hoa", "tết", "du xuân", "công viên", "vườn", "đường hoa", "lịch sử", "văn hóa", "tham quan") * 5;
        } else if ("summer".equals(profile)) {
            score += matches(text, "trong nhà", "indoor", "bảo tàng", "trung tâm thương mại", "rạp phim", "cà phê", "cafe", "thủy cung", "giải trí") * 5;
        } else if ("autumn".equals(profile)) {
            score += matches(text, "kiến trúc", "bảo tàng", "di tích", "đi bộ", "phố", "cà phê", "cafe", "sông", "văn hóa", "ngắm cảnh") * 5;
        } else {
            score += matches(text, "buổi tối", "đêm", "phố đi bộ", "món nóng", "ẩm thực", "cà phê", "cafe", "ngắm cảnh", "indoor", "trung tâm thương mại") * 5;
        }
        return score;
    }

    private int matches(String text, String... words) {
        int count = 0;
        for (String word : words) if (text.contains(word)) count++;
        return count;
    }
    private BigDecimal safeRating(Place p) { return p.getRating() == null ? BigDecimal.ZERO : p.getRating(); }
    private String safe(String value) { return value == null ? "" : value; }
    private String normalizeProfile(String value) {
        if ("summer".equalsIgnoreCase(value)) return "summer";
        if ("autumn".equalsIgnoreCase(value)) return "autumn";
        if ("winter".equalsIgnoreCase(value)) return "winter";
        return "spring";
    }
    private String profileLabel(String profile) {
        if ("summer".equals(profile)) return "Mùa hạ";
        if ("autumn".equals(profile)) return "Mùa thu";
        if ("winter".equals(profile)) return "Mùa đông";
        return "Mùa xuân";
    }
    private Date parseDate(String value, Date fallback) {
        if (value == null || value.trim().isEmpty()) return fallback;
        try { return Date.valueOf(value.trim()); }
        catch (IllegalArgumentException ex) { throw new IllegalArgumentException("Ngày không hợp lệ."); }
    }
    private int positiveInt(String value) {
        try { int id = Integer.parseInt(value); if (id > 0) return id; }
        catch (Exception ignored) { }
        throw new IllegalArgumentException("ID không hợp lệ.");
    }
    private User requireUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!"USER".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền sử dụng chức năng này.");
            return null;
        }
        return user;
    }
}
