package controller;

import dao.ItineraryDAO;
import dao.PlaceDAO;
import dao.TripDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
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

@WebServlet("/combo")
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
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Trip not found or access denied.");
                return;
            }
            String profile = normalizeProfile(request.getParameter("profile"));
            Date minimum = minimumDate(trip);
            Date visitDate = parseDate(request.getParameter("date"), minimum);
            if (visitDate == null || visitDate.before(minimum) || visitDate.after(trip.getEndDate())) {
                request.setAttribute("error", "Selected date must be within trip duration.");
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
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid trip ID or date.");
        } catch (RuntimeException ex) {
            throw new ServletException("Unable to generate place combo.", ex);
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
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Trip not found or access denied.");
                return;
            }
            if (!editable(trip)) { response.sendError(403, "Only the trip lead can confirm combos for a planning or ongoing trip."); return; }
            String tokenKey = "comboToken:" + tripId;
            Object expected = request.getSession().getAttribute(tokenKey);
            if (expected == null || !expected.equals(request.getParameter("comboToken"))) {
                response.sendError(403, "Confirmation session expired. Please reload the combo page."); return;
            }
            String profile = normalizeProfile(request.getParameter("profile"));
            Date visitDate = parseDate(request.getParameter("date"), null);
            if (visitDate == null || visitDate.before(minimumDate(trip)) || visitDate.after(trip.getEndDate()))
                throw new IllegalArgumentException("Applied date must be within trip and cannot be in the past.");
            List<Place> candidates = placeDAO.findForDestination(trip.getDestination());
            List<ItineraryItem> draft = new ArrayList<ItineraryItem>();
            Set<Integer> chosenIds = new HashSet<Integer>();
            Time previousEnd = null;
            for (int i = 0; i < 3; i++) {
                int placeId = positiveInt(request.getParameter("placeId" + i));
                Place place = null;
                for (Place candidate : candidates) if (candidate.getPlaceId() == placeId) place = candidate;
                if (place == null || !chosenIds.add(placeId) || !slotMatches(place, i))
                    throw new IllegalArgumentException("Please select three distinct places matching activity types within the trip area.");
                Time from = parseTime(request.getParameter("start" + i));
                Time to = parseTime(request.getParameter("end" + i));
                if (!to.after(from) || (previousEnd != null && from.toLocalTime().isBefore(previousEnd.toLocalTime().plusMinutes(15))))
                    throw new IllegalArgumentException("End time must be after start time; allow at least 15 minutes between activities.");
                if (!withinOpeningHours(place, from, to)) throw new IllegalArgumentException("Time slot falls outside opening hours of " + place.getPlaceName() + ".");
                ItineraryItem item = new ItineraryItem();
                item.setTripId(tripId); item.setPlaceId(placeId); item.setVisitDate(visitDate);
                item.setStartTime(from); item.setEndTime(to);
                item.setEstimatedCost(place.getEstimatedCost() == null ? BigDecimal.ZERO : place.getEstimatedCost());
                item.setNote("Combo " + profileLabel(profile) + " · " + slotLabel(i));
                item.setSourceType("COMBO");
                draft.add(item); previousEnd = to;
            }
            itineraryDAO.addComboAuthorized(tripId, user.getUserId(), draft);
            request.getSession().removeAttribute(tokenKey);
            request.getSession().setAttribute("successMessage", "Combo confirmed! Map and weather will now reflect your updated itinerary.");
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
            throw new ServletException("Unable to add combo to itinerary.", ex);
        }
    }

    private List<Place> buildCombo(final String profile, List<Place> candidates) {
        List<Place> all = new ArrayList<Place>(candidates);
        Collections.sort(all, new Comparator<Place>() {
            @Override public int compare(Place a, Place b) {
                int result = Integer.compare(score(b, profile), score(a, profile));
                return result != 0 ? result : b.getEstimatedCost().compareTo(a.getEstimatedCost());
            }
        });
        List<Place> result = new ArrayList<Place>();
        for (int slot = 0; slot < 3; slot++) {
            Place chosen = null;
            for (Place p : all) {
                if (slotMatches(p, slot) && !result.contains(p)) { chosen = p; break; }
            }
            if (chosen != null) result.add(chosen);
        }
        return result;
    }
    private boolean editable(Trip trip) {
        return "OWNER".equalsIgnoreCase(trip.getRole())
                && ("PLANNING".equalsIgnoreCase(trip.getStatus()) || "ONGOING".equalsIgnoreCase(trip.getStatus()));
    }
    private Date minimumDate(Trip trip) {
        LocalDate today = utils.AppClock.today();
        LocalDate start = trip.getStartDate().toLocalDate();
        return Date.valueOf(start.isAfter(today) ? start : today);
    }
    public static boolean slotMatches(Place place, int slot) {
        if (place == null) return false;
        String code = place.getCategoryCode();
        if (code == null && place.getCategoryName() != null) {
            String label = utils.CategoryUi.label(place.getCategoryName());
            if ("Food & Dining".equals(label)) code = "FOOD";
            else if ("Cafe & Drinks".equals(label)) code = "CAFE";
            else if ("Sightseeing".equals(label)) code = "SIGHTSEEING";
            else if ("Entertainment".equals(label)) code = "ENTERTAINMENT";
            else if ("Shopping".equals(label)) code = "SHOPPING";
        }
        return code != null && (slot == 1 ? "FOOD".equals(code) : slot == 2 ? "CAFE".equals(code)
                : ("SIGHTSEEING".equals(code) || "ENTERTAINMENT".equals(code) || "SHOPPING".equals(code)));
    }
    public static String slotLabel(int slot) {
        return slot == 1 ? "Meal" : slot == 2 ? "Drink & Rest" : "Sightseeing & Experience";
    }
    private Time parseTime(String value) {
        if (value == null || !value.matches("\\d{2}:\\d{2}")) throw new IllegalArgumentException("Invalid time format.");
        try { return Time.valueOf(java.time.LocalTime.parse(value)); }
        catch (RuntimeException ex) { throw new IllegalArgumentException("Invalid time format."); }
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
            score += matches(text, "hoa", "tết", "du xuân", "công viên", "vườn", "đường hoa", "lịch sử", "văn hóa", "tham quan", "flower", "park", "garden", "nature") * 5;
        } else if ("summer".equals(profile)) {
            score += matches(text, "trong nhà", "indoor", "bảo tàng", "trung tâm thương mại", "rạp phim", "cà phê", "cafe", "thủy cung", "giải trí", "mall", "museum") * 5;
        } else if ("autumn".equals(profile)) {
            score += matches(text, "kiến trúc", "bảo tàng", "di tích", "đi bộ", "phố", "cà phê", "cafe", "sông", "văn hóa", "ngắm cảnh", "heritage", "history", "walk") * 5;
        } else {
            score += matches(text, "buổi tối", "đêm", "phố đi bộ", "món nóng", "ẩm thực", "cà phê", "cafe", "ngắm cảnh", "indoor", "trung tâm thương mại", "night", "food", "dining") * 5;
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
        if ("summer".equals(profile)) return "Summer";
        if ("autumn".equals(profile)) return "Autumn";
        if ("winter".equals(profile)) return "Winter";
        return "Spring";
    }
    private Date parseDate(String value, Date fallback) {
        if (value == null || value.trim().isEmpty()) return fallback;
        try { return Date.valueOf(value.trim()); }
        catch (IllegalArgumentException ex) { throw new IllegalArgumentException("Invalid date."); }
    }
    private int positiveInt(String value) {
        try { int id = Integer.parseInt(value); if (id > 0) return id; }
        catch (Exception ignored) { }
        throw new IllegalArgumentException("Invalid ID.");
    }
    private User requireUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!"USER".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to access this feature.");
            return null;
        }
        return user;
    }
}
