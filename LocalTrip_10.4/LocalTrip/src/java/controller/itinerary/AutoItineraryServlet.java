package controller.itinerary;

import dao.ItineraryDAO;
import dao.RecommendationDAO;
import dao.TripDAO;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.ItineraryItem;
import model.Place;
import model.Recommendation;
import model.Trip;
import model.User;

/**
 * Tự động tạo lịch trình theo nguyên tắc ƯU TIÊN CẤU TRÚC trước, ĐIỂM sau.
 *
 * Mỗi ngày có 3 cột mốc:
 * 07:00-11:00, 11:00-17:00, 17:00-22:00.
 * Mỗi cột mốc ưu tiên đủ 3 loại:
 *   1 FOOD + 1 CAFE + 1 SIGHTSEEING/ENTERTAINMENT/SHOPPING.
 *
 * Chỉ sau khi tìm được các phương án đủ 3 loại mới dùng Recommendation Score
 * (sở thích nhóm 50%, rating 30%, ngân sách 20%) để chọn phương án tốt nhất.
 * Nếu dữ liệu không đủ để tạo đủ 3 cột mốc, hệ thống vẫn cố gắng tạo nhiều
 * cột mốc đầy đủ nhất có thể rồi mới dùng phương án từng phần.
 */
@WebServlet(name = "AutoItineraryServlet", urlPatterns = {"/itinerary/auto"})
public class AutoItineraryServlet extends HttpServlet {

    private static final int FOOD_MINUTES = 60;
    private static final int CAFE_MINUTES = 60;
    private static final int ACTIVITY_MINUTES = 90;
    private static final int BREAK_MINUTES = 15;

    private final TripDAO tripDAO = new TripDAO();
    private final ItineraryDAO itineraryDAO = new ItineraryDAO();
    private final RecommendationDAO recommendationDAO = new RecommendationDAO();

    private static final class Slot {
        final LocalTime start;
        final LocalTime end;

        Slot(LocalTime start, LocalTime end) {
            this.start = start;
            this.end = end;
        }
    }

    private static final class ScheduledPlan {
        Recommendation food;
        Recommendation cafe;
        Recommendation activity;
        LocalTime foodStart;
        LocalTime cafeStart;
        LocalTime activityStart;
        double score;

        boolean isComplete() {
            return food != null && cafe != null && activity != null;
        }

        int count() {
            int count = 0;
            if (food != null) count++;
            if (cafe != null) count++;
            if (activity != null) count++;
            return count;
        }
    }

    private static final class DayPlan {
        final List<ScheduledPlan> milestones = new ArrayList<ScheduledPlan>();
        int completeMilestones;
        int scheduledItems;
        double totalScore;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (!"USER".equalsIgnoreCase(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền sử dụng chức năng này.");
            return;
        }

        int tripId;
        try {
            tripId = Integer.parseInt(request.getParameter("tripId"));
            if (tripId <= 0) throw new NumberFormatException();
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Trip ID không hợp lệ.");
            return;
        }

        try {
            Trip trip = tripDAO.findByIdForUser(tripId, currentUser.getUserId());
            if (trip == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Không tìm thấy Trip hoặc bạn không có quyền truy cập.");
                return;
            }
            if (!"OWNER".equalsIgnoreCase(trip.getRole())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Chỉ Owner mới có thể tự động tạo lịch trình.");
                return;
            }

            List<Recommendation> foods = recommendationDAO.findForTripByCategory(tripId, "FOOD");
            List<Recommendation> cafes = recommendationDAO.findForTripByCategory(tripId, "CAFE");
            List<Recommendation> activities = new ArrayList<Recommendation>();
            activities.addAll(recommendationDAO.findForTripByCategory(tripId, "SIGHTSEEING"));
            activities.addAll(recommendationDAO.findForTripByCategory(tripId, "ENTERTAINMENT"));
            activities.addAll(recommendationDAO.findForTripByCategory(tripId, "SHOPPING"));
            sortByScore(activities);

            if (foods.isEmpty() || cafes.isEmpty() || activities.isEmpty()) {
                response.sendRedirect(request.getContextPath()
                        + "/itinerary?tripId=" + tripId + "&auto=empty");
                return;
            }

            List<ItineraryItem> existing = itineraryDAO.findByTrip(tripId);
            Set<Integer> scheduledPlaceIds = new HashSet<Integer>();
            for (ItineraryItem item : existing) {
                scheduledPlaceIds.add(item.getPlaceId());
            }

            Slot[] milestones = {
                new Slot(LocalTime.of(7, 0), LocalTime.of(11, 0)),
                new Slot(LocalTime.of(11, 0), LocalTime.of(17, 0)),
                new Slot(LocalTime.of(17, 0), LocalTime.of(22, 0))
            };

            int added = 0;
            LocalDate currentDate = trip.getStartDate().toLocalDate();
            LocalDate endDate = trip.getEndDate().toLocalDate();

            while (!currentDate.isAfter(endDate)) {
                DayPlan dayPlan = buildBestDayPlan(
                        tripId, currentDate, milestones,
                        foods, cafes, activities, scheduledPlaceIds);

                // Ghi nhận các địa điểm đã chọn trong ngày để không lặp sang ngày sau.
                for (ScheduledPlan plan : dayPlan.milestones) {
                    if (plan == null) continue;

                    if (plan.food != null && addItem(
                            tripId, currentDate, plan.food, plan.foodStart,
                            FOOD_MINUTES, "Bữa ăn - cột mốc " + milestoneLabel(plan))) {
                        scheduledPlaceIds.add(plan.food.getPlace().getId());
                        added++;
                    }

                    if (plan.cafe != null && addItem(
                            tripId, currentDate, plan.cafe, plan.cafeStart,
                            CAFE_MINUTES, "Cà phê - cột mốc " + milestoneLabel(plan))) {
                        scheduledPlaceIds.add(plan.cafe.getPlace().getId());
                        added++;
                    }

                    if (plan.activity != null && addItem(
                            tripId, currentDate, plan.activity, plan.activityStart,
                            ACTIVITY_MINUTES,
                            "Hoạt động " + plan.activity.getPlace().getCategoryName()
                            + " - cột mốc " + milestoneLabel(plan))) {
                        scheduledPlaceIds.add(plan.activity.getPlace().getId());
                        added++;
                    }
                }

                currentDate = currentDate.plusDays(1);
            }

            response.sendRedirect(request.getContextPath()
                    + "/itinerary?tripId=" + tripId
                    + "&auto=success&count=" + added);

        } catch (RuntimeException e) {
            throw new ServletException("Không thể tự động tạo lịch trình.", e);
        }
    }

    /**
     * Tối ưu theo thứ tự:
     * 1) Số cột mốc đủ FOOD + CAFE + ACTIVITY.
     * 2) Tổng số địa điểm được xếp.
     * 3) Tổng Recommendation Score.
     */
    private DayPlan buildBestDayPlan(
            int tripId,
            LocalDate date,
            Slot[] milestones,
            List<Recommendation> foods,
            List<Recommendation> cafes,
            List<Recommendation> activities,
            Set<Integer> globallyScheduled) {

        DayPlan best = new DayPlan();
        searchDayPlans(
                tripId, date, milestones, 0,
                foods, cafes, activities,
                new HashSet<Integer>(globallyScheduled),
                new ArrayList<ScheduledPlan>(),
                best);

        return best;
    }

    private void searchDayPlans(
            int tripId,
            LocalDate date,
            Slot[] milestones,
            int milestoneIndex,
            List<Recommendation> foods,
            List<Recommendation> cafes,
            List<Recommendation> activities,
            Set<Integer> usedIds,
            List<ScheduledPlan> current,
            DayPlan best) {

        if (milestoneIndex >= milestones.length) {
            evaluatePlan(current, best);
            return;
        }

        Slot slot = milestones[milestoneIndex];

        // Quan trọng: trước tiên tìm các phương án ĐỦ 3 loại.
        List<ScheduledPlan> completeOptions = buildCompleteOptions(
                tripId, date, slot, foods, cafes, activities, usedIds);

        if (!completeOptions.isEmpty()) {
            // Chỉ giữ một số phương án điểm cao nhất để tránh bùng nổ tổ hợp.
            limitPlans(completeOptions, 12);
            for (ScheduledPlan option : completeOptions) {
                Set<Integer> nextUsed = new HashSet<Integer>(usedIds);
                nextUsed.add(option.food.getPlace().getId());
                nextUsed.add(option.cafe.getPlace().getId());
                nextUsed.add(option.activity.getPlace().getId());

                current.add(option);
                searchDayPlans(tripId, date, milestones, milestoneIndex + 1,
                        foods, cafes, activities, nextUsed, current, best);
                current.remove(current.size() - 1);
            }
        }

        // Nếu không có phương án đủ 3 loại cho cột mốc này,
        // cho phép phương án từng phần để vẫn tận dụng dữ liệu còn lại.
        List<ScheduledPlan> partialOptions = buildBestPartialOptions(
                tripId, date, slot, foods, cafes, activities, usedIds);

        limitPlans(partialOptions, 3);
        for (ScheduledPlan option : partialOptions) {
            Set<Integer> nextUsed = new HashSet<Integer>(usedIds);
            if (option.food != null) nextUsed.add(option.food.getPlace().getId());
            if (option.cafe != null) nextUsed.add(option.cafe.getPlace().getId());
            if (option.activity != null) nextUsed.add(option.activity.getPlace().getId());

            current.add(option);
            searchDayPlans(tripId, date, milestones, milestoneIndex + 1,
                    foods, cafes, activities, nextUsed, current, best);
            current.remove(current.size() - 1);
        }

        // Cũng cho phép bỏ qua cột mốc nếu dữ liệu không đủ,
        // để thuật toán ưu tiên số cột mốc đầy đủ ở các cột mốc còn lại.
        current.add(new ScheduledPlan());
        searchDayPlans(tripId, date, milestones, milestoneIndex + 1,
                foods, cafes, activities, new HashSet<Integer>(usedIds), current, best);
        current.remove(current.size() - 1);
    }

    private List<ScheduledPlan> buildCompleteOptions(
            int tripId,
            LocalDate date,
            Slot slot,
            List<Recommendation> foods,
            List<Recommendation> cafes,
            List<Recommendation> activities,
            Set<Integer> usedIds) {

        List<ScheduledPlan> options = new ArrayList<ScheduledPlan>();

        for (Recommendation food : foods) {
            if (isUsed(food, usedIds)) continue;
            LocalTime foodStart = getValidStart(food, slot.start);
            LocalTime foodEnd = foodStart.plusMinutes(FOOD_MINUTES);
            if (!fits(food, foodStart, foodEnd, slot.end)
                    || hasConflict(tripId, date, foodStart, foodEnd)) continue;

            LocalTime cafeEarliest = foodEnd.plusMinutes(BREAK_MINUTES);
            for (Recommendation cafe : cafes) {
                if (isUsed(cafe, usedIds) || samePlace(food, cafe)) continue;
                LocalTime cafeStart = getValidStart(cafe, cafeEarliest);
                LocalTime cafeEnd = cafeStart.plusMinutes(CAFE_MINUTES);
                if (!fits(cafe, cafeStart, cafeEnd, slot.end)
                        || hasConflict(tripId, date, cafeStart, cafeEnd)) continue;

                LocalTime activityEarliest = cafeEnd.plusMinutes(BREAK_MINUTES);
                for (Recommendation activity : activities) {
                    if (isUsed(activity, usedIds)
                            || samePlace(food, activity)
                            || samePlace(cafe, activity)) continue;

                    LocalTime activityStart = getValidStart(activity, activityEarliest);
                    LocalTime activityEnd = activityStart.plusMinutes(ACTIVITY_MINUTES);
                    if (!fits(activity, activityStart, activityEnd, slot.end)
                            || hasConflict(tripId, date, activityStart, activityEnd)) continue;

                    ScheduledPlan plan = new ScheduledPlan();
                    plan.food = food;
                    plan.cafe = cafe;
                    plan.activity = activity;
                    plan.foodStart = foodStart;
                    plan.cafeStart = cafeStart;
                    plan.activityStart = activityStart;
                    plan.score = food.getScore() + cafe.getScore() + activity.getScore();
                    options.add(plan);
                }
            }
        }

        Collections.sort(options, PLAN_SCORE_DESC);
        return options;
    }

    private List<ScheduledPlan> buildBestPartialOptions(
            int tripId,
            LocalDate date,
            Slot slot,
            List<Recommendation> foods,
            List<Recommendation> cafes,
            List<Recommendation> activities,
            Set<Integer> usedIds) {

        List<ScheduledPlan> options = new ArrayList<ScheduledPlan>();

        // Từng FOOD.
        for (Recommendation food : foods) {
            if (isUsed(food, usedIds)) continue;
            LocalTime start = getValidStart(food, slot.start);
            LocalTime end = start.plusMinutes(FOOD_MINUTES);
            if (fits(food, start, end, slot.end)
                    && !hasConflict(tripId, date, start, end)) {
                ScheduledPlan plan = new ScheduledPlan();
                plan.food = food;
                plan.foodStart = start;
                plan.score = food.getScore();
                options.add(plan);
            }
        }

        // FOOD + CAFE.
        for (Recommendation food : foods) {
            if (isUsed(food, usedIds)) continue;
            LocalTime foodStart = getValidStart(food, slot.start);
            LocalTime foodEnd = foodStart.plusMinutes(FOOD_MINUTES);
            if (!fits(food, foodStart, foodEnd, slot.end)
                    || hasConflict(tripId, date, foodStart, foodEnd)) continue;

            for (Recommendation cafe : cafes) {
                if (isUsed(cafe, usedIds) || samePlace(food, cafe)) continue;
                LocalTime cafeStart = getValidStart(cafe, foodEnd.plusMinutes(BREAK_MINUTES));
                LocalTime cafeEnd = cafeStart.plusMinutes(CAFE_MINUTES);
                if (!fits(cafe, cafeStart, cafeEnd, slot.end)
                        || hasConflict(tripId, date, cafeStart, cafeEnd)) continue;

                ScheduledPlan plan = new ScheduledPlan();
                plan.food = food;
                plan.cafe = cafe;
                plan.foodStart = foodStart;
                plan.cafeStart = cafeStart;
                plan.score = food.getScore() + cafe.getScore();
                options.add(plan);
            }
        }

        // FOOD + CAFE + ACTIVITY cũng được thêm ở buildCompleteOptions.
        // Ở đây partial chỉ giữ 1-2 loại để không cạnh tranh với phương án đầy đủ.
        Collections.sort(options, PLAN_PRIORITY_DESC);
        return options;
    }

    private boolean isUsed(Recommendation recommendation, Set<Integer> usedIds) {
        return recommendation == null
                || recommendation.getPlace() == null
                || usedIds.contains(recommendation.getPlace().getId());
    }

    private boolean samePlace(Recommendation first, Recommendation second) {
        return first != null && second != null
                && first.getPlace() != null && second.getPlace() != null
                && first.getPlace().getId() == second.getPlace().getId();
    }

    private LocalTime getValidStart(Recommendation recommendation, LocalTime earliest) {
        Place place = recommendation.getPlace();
        if (place == null || place.getOpeningTime() == null) return earliest;
        LocalTime opening = place.getOpeningTime().toLocalTime();
        return opening.isAfter(earliest) ? opening : earliest;
    }

    private boolean fits(Recommendation recommendation,
            LocalTime start, LocalTime end, LocalTime milestoneEnd) {
        Place place = recommendation.getPlace();
        if (place == null || end.isAfter(milestoneEnd)) return false;
        if (place.getClosingTime() != null
                && end.isAfter(place.getClosingTime().toLocalTime())) return false;
        return true;
    }

    private boolean hasConflict(int tripId, LocalDate date,
            LocalTime start, LocalTime end) {
        return itineraryDAO.hasTimeConflict(
                tripId, Date.valueOf(date), Time.valueOf(start), Time.valueOf(end));
    }

    private void evaluatePlan(List<ScheduledPlan> current, DayPlan best) {
        int complete = 0;
        int items = 0;
        double score = 0;

        for (ScheduledPlan plan : current) {
            if (plan == null) continue;
            if (plan.isComplete()) complete++;
            items += plan.count();
            score += plan.score;
        }

        boolean better = complete > best.completeMilestones
                || (complete == best.completeMilestones && items > best.scheduledItems)
                || (complete == best.completeMilestones
                    && items == best.scheduledItems
                    && score > best.totalScore);

        if (better) {
            best.milestones.clear();
            best.milestones.addAll(current);
            best.completeMilestones = complete;
            best.scheduledItems = items;
            best.totalScore = score;
        }
    }

    private void limitPlans(List<ScheduledPlan> plans, int limit) {
        if (plans.size() > limit) {
            plans.subList(limit, plans.size()).clear();
        }
    }

    private boolean addItem(
            int tripId,
            LocalDate date,
            Recommendation recommendation,
            LocalTime start,
            int minutes,
            String note) {

        if (recommendation == null || recommendation.getPlace() == null || start == null) {
            return false;
        }

        LocalTime actualStart = getValidStart(recommendation, start);
        LocalTime actualEnd = actualStart.plusMinutes(minutes);

        ItineraryItem item = new ItineraryItem();
        item.setTripId(tripId);
        item.setPlaceId(recommendation.getPlace().getId());
        item.setVisitDate(Date.valueOf(date));
        item.setStartTime(Time.valueOf(actualStart));
        item.setEndTime(Time.valueOf(actualEnd));
        item.setEstimatedCost(recommendation.getPlace().getEstimatedPrice());
        item.setNote(note + " - ưu tiên đủ cấu trúc cột mốc; điểm phù hợp: "
                + Math.round(recommendation.getScore()) + ".");
        return itineraryDAO.add(item);
    }

    private void sortByScore(List<Recommendation> list) {
        Collections.sort(list, new Comparator<Recommendation>() {
            @Override
            public int compare(Recommendation first, Recommendation second) {
                return Double.compare(second.getScore(), first.getScore());
            }
        });
    }

    private static final Comparator<ScheduledPlan> PLAN_SCORE_DESC =
            new Comparator<ScheduledPlan>() {
                @Override
                public int compare(ScheduledPlan first, ScheduledPlan second) {
                    return Double.compare(second.score, first.score);
                }
            };

    private static final Comparator<ScheduledPlan> PLAN_PRIORITY_DESC =
            new Comparator<ScheduledPlan>() {
                @Override
                public int compare(ScheduledPlan first, ScheduledPlan second) {
                    int countCompare = Integer.compare(second.count(), first.count());
                    if (countCompare != 0) return countCompare;
                    return Double.compare(second.score, first.score);
                }
            };

    private String milestoneLabel(ScheduledPlan plan) {
        if (plan.foodStart == null) return "không xác định";
        LocalTime start = plan.foodStart;
        if (start.isBefore(LocalTime.of(11, 0))) return "07:00 - 11:00";
        if (start.isBefore(LocalTime.of(17, 0))) return "11:00 - 17:00";
        return "17:00 - 22:00";
    }
}
