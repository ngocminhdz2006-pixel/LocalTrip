package controller.admin;

import dao.CategoryDAO;
import dao.ComboTemplateDAO;
import dao.ComboTemplateWriteDAO;
import dao.PlaceDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Time;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.ComboTemplate;
import model.ComboTemplate.Activity;
import model.User;

@WebServlet({
    "/admin/combos/create",
    "/admin/combos/edit"
})
public class AdminComboCreateServlet extends HttpServlet {

    private static final String VIEW =
            "/WEB-INF/views/admin/combo-create.jsp";

    private static final String TOKEN_KEY = "adminComboCreateToken";

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final PlaceDAO placeDAO = new PlaceDAO();
    private final ComboTemplateDAO comboDAO = new ComboTemplateDAO();

    private final ComboTemplateWriteDAO writeDAO =
            new ComboTemplateWriteDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (requireAdmin(request, response) == null) {
            return;
        }

        boolean editing = isEditing(request);
        request.setAttribute("editing", editing);

        try {
            ComboTemplate form;

            if (editing) {
                int id = positiveInt(request.getParameter("id"));

                /*
                 * Lấy phiên bản trước khi đọc nội dung.
                 * Nếu có thay đổi đồng thời, lúc lưu sẽ bị từ chối.
                 */
                String revision = writeDAO.findEditRevision(id);
                form = comboDAO.findById(id);

                if (form == null) {
                    response.sendError(404, "Combo not found.");
                    return;
                }

                if (revision == null
                        || !("DRAFT".equals(form.getStatus())
                        || "INACTIVE".equals(form.getStatus()))) {
                    request.getSession().setAttribute(
                            "errorMessage",
                            "Please deactivate the combo before editing.");

                    response.sendRedirect(
                            request.getContextPath()
                            + "/admin/combos/detail?id=" + id);
                    return;
                }

                request.setAttribute("editRevision", revision);

            } else {
                form = new ComboTemplate();
                form.setDurationDays(1);
            }

            request.setAttribute("form", form);
            showForm(request, response);

        } catch (IllegalArgumentException e) {
            response.sendError(400, e.getMessage());

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Failed to load combo form.", e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User admin = requireAdmin(request, response);
        if (admin == null) {
            return;
        }

        HttpSession session = request.getSession();
        Object expected = session.getAttribute(TOKEN_KEY);

        if (expected == null
                || !expected.equals(request.getParameter("csrfToken"))) {
            response.sendError(403,
                    "Form session expired. Please reload the page.");
            return;
        }

        boolean editing = isEditing(request);
        request.setAttribute("editing", editing);

        ComboTemplate form = new ComboTemplate();
        request.setAttribute("form", form);

        String revision = request.getParameter("revision");
        request.setAttribute("editRevision", revision);

        if (editing) {
            try {
                form.setId(positiveInt(request.getParameter("id")));
            } catch (IllegalArgumentException e) {
                response.sendError(400, e.getMessage());
                return;
            }
        }

        try {
            form.setName(text(request, "name"));
            form.setDescription(text(request, "description"));
            form.setCityName(text(request, "cityName"));
            form.setDistrictName(text(request, "districtName"));

            form.setDurationDays(
                    positiveInt(request.getParameter("durationDays")));

            String[] categories =
                    request.getParameterValues("categoryIds");

            if (categories != null) {
                for (String category : categories) {
                    form.getCategoryIds().add(positiveInt(category));
                }
            }

            String[] days = request.getParameterValues("dayNumber");
            String[] types = request.getParameterValues("activityType");
            String[] places = request.getParameterValues("placeId");
            String[] titles = request.getParameterValues("activityTitle");
            String[] starts = request.getParameterValues("startTime");
            String[] ends = request.getParameterValues("endTime");
            String[] costs = request.getParameterValues("cost");
            String[] notes = request.getParameterValues("note");

            int count = days == null ? 0 : days.length;

            if (count < 1 || count > 60
                    || !sameLength(types, count)
                    || !sameLength(places, count)
                    || !sameLength(titles, count)
                    || !sameLength(starts, count)
                    || !sameLength(ends, count)
                    || !sameLength(costs, count)
                    || !sameLength(notes, count)) {
                throw new IllegalArgumentException(
                        "Invalid activity list.");
            }

            for (int i = 0; i < count; i++) {
                Activity activity = new Activity();

                activity.setDayNumber(positiveInt(days[i]));
                activity.setActivityType(types[i]);

                activity.setPlaceId(
                        places[i].trim().isEmpty()
                                ? null : positiveInt(places[i]));

                activity.setTitle(titles[i].trim());
                activity.setStartTime(parseTime(starts[i]));
                activity.setEndTime(parseTime(ends[i]));

                activity.setEstimatedCostPerPerson(
                        new BigDecimal(costs[i].trim()));

                activity.setNote(notes[i].trim());
                form.getActivities().add(activity);
            }

            int comboId;

            if (editing) {
                writeDAO.updateDraft(
                        form, admin.getUserId(), revision);
                comboId = form.getId();

            } else {
                comboId = writeDAO.createDraft(
                        form, admin.getUserId());
            }

            session.removeAttribute(TOKEN_KEY);

            session.setAttribute("successMessage",
                    editing
                    ? "Combo updated. Please review and activate."
                    : "Draft combo created successfully.");

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/combos/detail?id=" + comboId);

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            showForm(request, response);

        } catch (RuntimeException e) {
            log("Failed to save combo.", e);

            request.setAttribute("error",
                    "Failed to save combo. Please check database connection."
                    );

            showForm(request, response);
        }
    }

    private void showForm(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            HttpSession session = request.getSession();

            if (session.getAttribute(TOKEN_KEY) == null) {
                session.setAttribute(
                        TOKEN_KEY, UUID.randomUUID().toString());
            }

            request.setAttribute("csrfToken",
                    session.getAttribute(TOKEN_KEY));

            request.setAttribute("categories", categoryDAO.findAll());
            request.setAttribute("places", placeDAO.findAll());
            java.util.Map<String, java.util.List<String>> regions =
                    new java.util.LinkedHashMap<>();
            for (String city : placeDAO.findCities()) {
                java.util.List<String> districts = placeDAO.findDistricts(city);
                if (!districts.isEmpty()) regions.put(city, districts);
            }
            request.setAttribute("comboRegions", regions);

            request.setAttribute("pageTitle",
                    isEditing(request)
                    ? "Edit Draft Combo"
                    : "Create Draft Combo");

            request.getRequestDispatcher(VIEW)
                    .forward(request, response);

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Failed to load combo form data.", e);
        }
    }

    private boolean isEditing(HttpServletRequest request) {
        return "/admin/combos/edit".equals(request.getServletPath());
    }

    private User requireAdmin(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);

        User user = session == null ? null
                : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return null;
        }

        if (!"ADMIN".equals(user.getRole())) {
            response.sendError(403);
            return null;
        }

        return user;
    }

    private String text(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }

    private boolean sameLength(String[] values, int count) {
        return values != null && values.length == count;
    }

    private int positiveInt(String value) {
        try {
            int number = Integer.parseInt(value);
            if (number > 0) {
                return number;
            }
        } catch (NumberFormatException ignored) {
        }

        throw new IllegalArgumentException(
                "Invalid duration days or option ID.");
    }

    private Time parseTime(String value) {
        if (value == null || !value.matches("\\d{2}:\\d{2}")) {
            throw new IllegalArgumentException(
                    "Invalid activity time format.");
        }

        try {
            return Time.valueOf(value + ":00");
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(
                    "Invalid activity time format.");
        }
    }
}