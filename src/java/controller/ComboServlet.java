package controller;

import dao.ItineraryDAO;
import dao.PlaceDAO;
import dao.TripDAO;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.UUID;
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
            Date minimum = minimumDate(trip);
            Date visitDate = parseDate(request.getParameter("date"), minimum);
            if (visitDate == null || visitDate.before(minimum) || visitDate.after(trip.getEndDate())) {
                request.setAttribute("error", "Ngày chọn phải nằm trong khoảng thời gian của chuyến đi.");
                visitDate = minimum;
            }
            request.setAttribute("trip", trip);
            request.setAttribute("profile", profile);
            request.setAttribute("visitDate", visitDate.toString());
            List<Place> candidates = placeDAO.findForDestination(trip.getDestination());
            request.setAttribute("comboPlaces", buildCombo(profile, candidates));
            request.setAttribute("comboCandidates", candidates);
            request.setAttribute("comboMinimumDate", minimum.toString());
            request.setAttribute("comboEditable", editable(trip) && !minimum.after(trip.getEndDate()));
            String tokenKey = "comboToken:" + tripId;
            if (request.getSession().getAttribute(tokenKey) == null) request.getSession().setAttribute(tokenKey, UUID.randomUUID().toString());
            request.setAttribute("comboToken", request.getSession().getAttribute(tokenKey));
            Object previousDraft = request.getSession().getAttribute("comboDraft:" + tripId);
            if (previousDraft != null) {
                request.setAttribute("comboDraft", previousDraft);
                request.getSession().removeAttribute("comboDraft:" + tripId);
            }
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
            if (!editable(trip)) { response.sendError(403, "Chỉ trưởng nhóm được xác nhận combo của chuyến đi đang lập kế hoạch hoặc đang diễn ra."); return; }
            String tokenKey = "comboToken:" + tripId;
            Object expected = request.getSession().getAttribute(tokenKey);
            if (expected == null || !expected.equals(request.getParameter("comboToken"))) {
                response.sendError(403, "Phiên xác nhận đã hết hạn. Hãy tải lại trang combo."); return;
            }
            String profile = normalizeProfile(request.getParameter("profile"));
            Date visitDate = parseDate(request.getParameter("date"), null);
            if (visitDate == null || visitDate.before(minimumDate(trip)) || visitDate.after(trip.getEndDate()))
                throw new IllegalArgumentException("Ngày áp dụng phải nằm trong chuyến đi và không được là ngày quá khứ.");
            List<Place> candidates = placeDAO.findForDestination(trip.getDestination());
            List<ItineraryItem> draft = new ArrayList<ItineraryItem>();
            Set<Integer> chosenIds = new HashSet<Integer>();
            Time previousEnd = null;
            for (int i = 0; i < 3; i++) {
                int placeId = positiveInt(request.getParameter("placeId" + i));
                Place place = null;
                for (Place candidate : candidates) if (candidate.getPlaceId() == placeId) place = candidate;
                if (place == null || !chosenIds.add(placeId) || !slotMatches(place, i))
                    throw new IllegalArgumentException("Hãy chọn ba địa điểm khác nhau, đúng loại hoạt động và thuộc khu vực chuyến đi.");
                Time from = parseTime(request.getParameter("start" + i));
                Time to = parseTime(request.getParameter("end" + i));
                if (!to.after(from) || (previousEnd != null && from.toLocalTime().isBefore(previousEnd.toLocalTime().plusMinutes(15))))
                    throw new IllegalArgumentException("Giờ kết thúc phải sau giờ bắt đầu; cần ít nhất 15 phút nghỉ/di chuyển giữa các hoạt động.");
                if (!withinOpeningHours(place, from, to)) throw new IllegalArgumentException("Khung giờ không nằm trong giờ mở cửa của " + place.getPlaceName() + ".");
                ItineraryItem item = new ItineraryItem();
                item.setTripId(tripId); item.setPlaceId(placeId); item.setVisitDate(visitDate);
                item.setStartTime(from); item.setEndTime(to);
                item.setEstimatedCost(place.getEstimatedCost() == null ? BigDecimal.ZERO : place.getEstimatedCost());
                item.setNote("Combo " + profileLabel(profile) + " · " + slotLabel(i));
                draft.add(item); previousEnd = to;
            }
            itineraryDAO.addComboAuthorized(tripId, user.getUserId(), draft);
            request.getSession().removeAttribute(tokenKey);
            request.getSession().setAttribute("successMessage", "Đã xác nhận combo. Bản đồ và thời tiết sẽ dùng lịch trình vừa lưu.");
            response.sendRedirect(request.getContextPath() + "/itinerary?tripId=" + tripId);
        } catch (IllegalArgumentException ex) {
            request.getSession().setAttribute("errorMessage", ex.getMessage());
            java.util.Map<String, String> submitted = new java.util.HashMap<String, String>();
            for (int i = 0; i < 3; i++) {
                submitted.put("placeId" + i, safe(request.getParameter("placeId" + i)));
                submitted.put("start" + i, safe(request.getParameter("start" + i)));
                submitted.put("end" + i, safe(request.getParameter("end" + i)));
            }
            request.getSession().setAttribute("comboDraft:" + request.getParameter("tripId"), submitted);
            response.sendRedirect(request.getContextPath() + "/combo?tripId=" + java.net.URLEncoder.encode(safe(request.getParameter("tripId")), "UTF-8")
                    + "&profile=" + normalizeProfile(request.getParameter("profile"))
                    + "&date=" + java.net.URLEncoder.encode(safe(request.getParameter("date")), "UTF-8"));
        } catch (RuntimeException ex) {
            throw new ServletException("Không thể thêm combo vào lịch trình.", ex);
        }
    }

    private List<Place> buildCombo(final String profile, List<Place> candidates) {
        List<Place> all = new ArrayList<Place>(candidates);
        Collections.sort(all, new Comparator<Place>() {
            @Override public int compare(Place a, Place b) {
                int result = Integer.compare(score(b, profile), score(a, profile));
                return result != 0 ? result : safeRating(b).compareTo(safeRating(a));
            }
        });
        List<Place> selected = new ArrayList<Place>();
        Set<Integer> used = new HashSet<Integer>();
        for (int slot = 0; slot < 3; slot++) {
            for (Place place : all) if (!used.contains(place.getPlaceId()) && slotMatches(place, slot)) {
                selected.add(place); used.add(place.getPlaceId()); break;
            }
        }
        return selected.size() == 3 ? selected : Collections.<Place>emptyList();
    }

    private Date minimumDate(Trip trip) {
        Date today = Date.valueOf(LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")));
        return today.after(trip.getStartDate()) ? today : trip.getStartDate();
    }
    private boolean editable(Trip trip) {
        return "OWNER".equals(trip.getRole()) && ("PLANNING".equals(trip.getStatus()) || "ONGOING".equals(trip.getStatus()));
    }
    public static boolean slotMatches(Place place, int slot) {
        String code = place.getCategoryCode();
        return code != null && (slot == 1 ? "FOOD".equals(code) : slot == 2 ? "CAFE".equals(code)
                : ("SIGHTSEEING".equals(code) || "ENTERTAINMENT".equals(code) || "SHOPPING".equals(code)));
    }
    public static String slotLabel(int slot) {
        return slot == 1 ? "Bữa ăn" : slot == 2 ? "Đồ uống và nghỉ ngơi" : "Tham quan và trải nghiệm";
    }
    private Time parseTime(String value) {
        if (value == null || !value.matches("\\d{2}:\\d{2}")) throw new IllegalArgumentException("Giờ không hợp lệ.");
        try { return Time.valueOf(java.time.LocalTime.parse(value)); }
        catch (RuntimeException ex) { throw new IllegalArgumentException("Giờ không hợp lệ."); }
    }
    private boolean withinOpeningHours(Place place, Time from, Time to) {
        Time open = place.getOpeningTime(), close = place.getClosingTime();
        if (open != null && close != null && close.before(open))
            return !from.before(open) || !to.after(close);
        return (open == null || !from.before(open)) && (close == null || !to.after(close));
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
