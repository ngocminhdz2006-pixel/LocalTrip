package controller;

import dao.ComboTemplateDAO;
import dao.PreferenceDAO;
import dao.TripDAO;
import dao.TripMemberDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
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
import model.GroupPreference;
import model.Trip;
import model.TripMember;
import model.User;

@WebServlet("/combos")
public class ComboSuggestionServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final TripMemberDAO memberDAO = new TripMemberDAO();
    private final PreferenceDAO preferenceDAO = new PreferenceDAO();
    private final ComboTemplateDAO comboDAO = new ComboTemplateDAO();

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

        try {
            tripId = Integer.parseInt(
                    request.getParameter("tripId"));

            if (tripId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid trip ID.");
            return;
        }

        try {
            Trip trip = tripDAO.findByIdForUser(
                    tripId, user.getUserId());

            if (trip == null) {
                response.sendError(404);
                return;
            }

            request.setAttribute("trip", trip);
            request.setAttribute("currentTrip", trip);
            request.setAttribute("pageTitle", "Choose a combo");

            List<Map<String, Object>> suggestions = new ArrayList<>();
            request.setAttribute("suggestions", suggestions);

            if (!"PLANNING".equals(trip.getStatus())
                    && !"ONGOING".equals(trip.getStatus())) {
                request.setAttribute("notice",
                        "This trip is closed. New combos are unavailable.");
                showPage(request, response);
                return;
            }

            LocalDate today = LocalDate.now(
                    ZoneId.of("Asia/Ho_Chi_Minh"));

            LocalDate start = trip.getStartDate().toLocalDate();
            LocalDate end = trip.getEndDate().toLocalDate();

            if (today.isAfter(start)) {
                start = today;
            }

            if (start.isAfter(end)) {
                request.setAttribute("notice",
                        "The trip dates have passed. "
                        + "There are no remaining days to plan.");
                showPage(request, response);
                return;
            }

            int days = Math.toIntExact(
                    ChronoUnit.DAYS.between(start, end) + 1);

            Set<Integer> memberIds = new HashSet<>();
            memberIds.add(trip.getOwnerId());

            for (TripMember member : memberDAO.findByTrip(tripId)) {
                memberIds.add(member.getUserId());
            }

            int memberCount = memberIds.size();

            BigDecimal budget = trip.getBudget() == null
                    ? BigDecimal.ZERO : trip.getBudget();

            boolean budgetDefined = budget.signum() > 0;

            List<GroupPreference> preferences =
                    preferenceDAO.findGroupPreferences(tripId);

            boolean hasPreferences = false;

            for (GroupPreference preference : preferences) {
                if (preference.getMemberCount() > 0) {
                    hasPreferences = true;
                    break;
                }
            }

            List<ComboTemplate> candidates =
                    comboDAO.findActiveForDestination(
                            trip.getDestination(), days);

            if (candidates.isEmpty()) {
                Map<String, Integer> availability = comboDAO.availabilityForDestination(trip.getDestination(), days);
                String reason;
                if (availability.get("area") == 0) {
                    reason = "No combo template has been created for this area yet.";
                } else if (availability.get("active") == 0) {
                    reason = "Templates exist for this area, but none have been activated by an admin.";
                } else if (availability.get("exact") == 0) {
                    reason = "Active templates exist, but none cover exactly " + days + " planning days.";
                } else {
                    reason = "Matching templates have no activities or include unavailable places. An admin needs to update them.";
                }
                request.setAttribute("emptyComboReason", reason);
            }

            for (ComboTemplate combo : candidates) {
                int preferenceScore = 0;
                List<String> matchedNames = new ArrayList<>();

                for (GroupPreference preference : preferences) {
                    if (preference.getMemberCount() > 0
                            && combo.getCategoryIds().contains(
                                    preference.getCategoryId())) {

                        preferenceScore += preference.getMemberCount();
                        matchedNames.add(preference.getCategoryName());
                    }
                }

                BigDecimal groupCost =
                        combo.getEstimatedCostPerPerson().multiply(
                                BigDecimal.valueOf(memberCount));

                boolean withinBudget =
                        !budgetDefined || groupCost.compareTo(budget) <= 0;

                Map<String, Object> suggestion = new LinkedHashMap<>();

                suggestion.put("combo", combo);
                suggestion.put("groupCost", groupCost);
                suggestion.put("withinBudget", withinBudget);
                suggestion.put("preferenceScore", preferenceScore);
                suggestion.put("matchedPreferences",
                        String.join(", ", matchedNames));

                suggestions.add(suggestion);
            }

            suggestions.sort((a, b) -> {
                boolean aWithin = (Boolean) a.get("withinBudget");
                boolean bWithin = (Boolean) b.get("withinBudget");

                if (aWithin != bWithin) {
                    return aWithin ? -1 : 1;
                }

                int scoreOrder = Integer.compare(
                        (Integer) b.get("preferenceScore"),
                        (Integer) a.get("preferenceScore"));

                if (scoreOrder != 0) {
                    return scoreOrder;
                }

                int costOrder = ((BigDecimal) a.get("groupCost"))
                        .compareTo((BigDecimal) b.get("groupCost"));

                if (costOrder != 0) {
                    return costOrder;
                }

                return Integer.compare(
                        ((ComboTemplate) a.get("combo")).getId(),
                        ((ComboTemplate) b.get("combo")).getId());
            });

            if (suggestions.size() > 3) {
                suggestions = new ArrayList<>(
                        suggestions.subList(0, 3));
            }

            request.setAttribute("suggestions", suggestions);
            request.setAttribute("memberCount", memberCount);
            request.setAttribute("planningDays", days);
            request.setAttribute("planningStart", start.toString());
            request.setAttribute("planningEnd", end.toString());
            request.setAttribute("budgetDefined", budgetDefined);
            request.setAttribute("hasPreferences", hasPreferences);

            /*
             * Trong chuyến đang đi, chưa tính ngân sách còn lại.
             * Chi phí combo được đối chiếu với ngân sách toàn chuyến.
             */
            request.setAttribute("ongoing",
                    "ONGOING".equals(trip.getStatus()));

            showPage(request, response);

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Không thể tải gợi ý combo.", e);
        }
    }

    private void showPage(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher(
                "/WEB-INF/views/combo/combo-suggestions.jsp")
                .forward(request, response);
    }
}