package controller.admin;

import dao.AdminAuditLogDAO;
import dao.CategoryDAO;
import dao.PlaceDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Time;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Category;
import model.Place;
import model.User;

@WebServlet({
    "/admin/places",
    "/admin/places/create",
    "/admin/places/edit",
    "/admin/places/toggle"
})
public class AdminPlaceServlet extends HttpServlet {

    private static final String LIST_VIEW = "/WEB-INF/views/admin/place-list.jsp";
    private static final String FORM_VIEW = "/WEB-INF/views/admin/place-form.jsp";

    private final PlaceDAO placeDAO = new PlaceDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final AdminAuditLogDAO auditLogDAO = new AdminAuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/admin/places/create".equals(path)) {
            showForm(request, response, null);
            return;
        }

        if ("/admin/places/edit".equals(path)) {
            showEditForm(request, response);
            return;
        }

        showList(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if ("/admin/places/create".equals(path)) {
            createPlace(request, response);
            return;
        }

        if ("/admin/places/edit".equals(path)) {
            updatePlace(request, response);
            return;
        }

        if ("/admin/places/toggle".equals(path)) {
            togglePlace(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String categoryValue = request.getParameter("categoryId");
        String status = request.getParameter("status");

        keyword = keyword == null ? "" : keyword.trim();
        status = status == null ? "" : status.trim().toUpperCase();

        int categoryId = parseInt(categoryValue, 0);
        if (categoryId < 0) {
            categoryId = 0;
        }
        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            status = "";
        }

        try {
            List<Place> places = placeDAO.searchAdmin(keyword, categoryId, status);
            List<Category> categories = categoryDAO.findAll();

            request.setAttribute("places", places);
            request.setAttribute("categories", categories);
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedCategory", categoryId);
            request.setAttribute("selectedStatus", status);
            request.setAttribute("pageTitle", "Place Management");

            request.getRequestDispatcher(LIST_VIEW).forward(request, response);
        } catch (RuntimeException e) {
            request.setAttribute("errorMessage", "Failed to load place list.");
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedCategory", categoryId);
            request.setAttribute("selectedStatus", status);
            request.setAttribute("categories", categoryDAO.findAll());
            request.getRequestDispatcher(LIST_VIEW).forward(request, response);
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int placeId = parseInt(request.getParameter("id"), -1);
        if (placeId <= 0) {
            redirectError(request, response, "Invalid place ID.");
            return;
        }

        Place place = placeDAO.findByIdAdmin(placeId);
        if (place == null) {
            redirectError(request, response, "Place not found.");
            return;
        }

        showForm(request, response, place);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, Place place)
            throws ServletException, IOException {

        request.setAttribute("categories", categoryDAO.findAll());
        request.setAttribute("item", place);
        request.setAttribute("pageTitle", place == null ? "Add Place" : "Edit Place");
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }

    private void createPlace(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        PlaceFormData data = readForm(request);
        String validationError = validate(data);

        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            request.setAttribute("categories", categoryDAO.findAll());
            request.setAttribute("item", data.toPlace());
            request.setAttribute("pageTitle", "Add Place");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
            return;
        }

        Place place = data.toPlace();
        try {
            int id = placeDAO.insert(place);
            logAction(request, "CREATE_PLACE", "Created place #" + id + " - " + place.getPlaceName());
            redirectSuccess(request, response, "Place created successfully.");
        } catch (RuntimeException e) {
            request.setAttribute("errorMessage", "Failed to add place. Data may be duplicate or invalid.");
            request.setAttribute("categories", categoryDAO.findAll());
            request.setAttribute("item", place);
            request.setAttribute("pageTitle", "Add Place");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        }
    }

    private void updatePlace(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int placeId = parseInt(request.getParameter("placeId"), -1);
        if (placeId <= 0) {
            redirectError(request, response, "Invalid place ID.");
            return;
        }

        PlaceFormData data = readForm(request);
        String validationError = validate(data);
        Place place = data.toPlace();
        place.setPlaceId(placeId);

        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            request.setAttribute("categories", categoryDAO.findAll());
            request.setAttribute("item", place);
            request.setAttribute("pageTitle", "Edit Place");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
            return;
        }

        try {
            if (!placeDAO.update(place)) {
                redirectError(request, response, "Place not found to update.");
                return;
            }
            logAction(request, "UPDATE_PLACE", "Updated place #" + placeId + " - " + place.getPlaceName());
            redirectSuccess(request, response, "Place updated successfully.");
        } catch (RuntimeException e) {
            request.setAttribute("errorMessage", "Failed to update place.");
            request.setAttribute("categories", categoryDAO.findAll());
            request.setAttribute("item", place);
            request.setAttribute("pageTitle", "Edit Place");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        }
    }

    private void togglePlace(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int placeId = parseInt(request.getParameter("id"), -1);
        if (placeId <= 0) {
            redirectError(request, response, "Invalid place ID.");
            return;
        }

        try {
            Place place = placeDAO.findByIdAdmin(placeId);
            if (place == null) {
                redirectError(request, response, "Place not found.");
                return;
            }

            boolean newStatus = !place.isActive();
            if (!placeDAO.setActive(placeId, newStatus)) {
                redirectError(request, response, "Failed to update place status.");
                return;
            }

            String action = newStatus ? "ACTIVATE_PLACE" : "DEACTIVATE_PLACE";
            String statusText = newStatus ? "activated" : "deactivated";
            logAction(request, action, "Successfully " + statusText + " place #" + placeId + " - " + place.getPlaceName());
            redirectSuccess(request, response, newStatus ? "Place activated successfully." : "Place deactivated successfully.");
        } catch (RuntimeException e) {
            redirectError(request, response, "Failed to update place status.");
        }
    }

    private PlaceFormData readForm(HttpServletRequest request) {
        PlaceFormData data = new PlaceFormData();
        data.categoryId = parseInt(request.getParameter("categoryId"), 0);
        data.placeName = trim(request.getParameter("placeName"));
        data.address = trim(request.getParameter("address"));
        data.description = trim(request.getParameter("description"));
        data.estimatedCost = parseDecimal(request.getParameter("estimatedCost"));
        data.rating = parseDecimal(request.getParameter("rating"));
        data.openingTime = parseTime(request.getParameter("openingTime"));
        data.closingTime = parseTime(request.getParameter("closingTime"));
        data.latitude = parseDecimal(request.getParameter("latitude"));
        data.longitude = parseDecimal(request.getParameter("longitude"));
        data.placeType = trim(request.getParameter("placeType"));
        return data;
    }

    private String validate(PlaceFormData data) {
        if (data.categoryId <= 0) return "Please select a category.";
        if (data.placeName.isEmpty()) return "Place name cannot be empty.";
        if (data.placeName.length() > 200) return "Place name cannot exceed 200 characters.";
        if (data.address.isEmpty()) return "Address cannot be empty.";
        if (data.address.length() > 300) return "Address cannot exceed 300 characters.";
        if (data.description.length() > 1000) return "Description cannot exceed 1000 characters.";
        if (data.estimatedCost == null || data.estimatedCost.compareTo(BigDecimal.ZERO) < 0) return "Estimated cost must be greater than or equal to 0.";
        if (data.rating == null || data.rating.compareTo(BigDecimal.ZERO) < 0 || data.rating.compareTo(new BigDecimal("5.00")) > 0) return "Rating must be between 0 and 5.";
        if (data.openingTime != null && data.closingTime != null && data.openingTime.after(data.closingTime)) return "Opening time cannot be after closing time.";
        if (data.latitude != null && (data.latitude.compareTo(new BigDecimal("-90")) < 0 || data.latitude.compareTo(new BigDecimal("90")) > 0)) return "Latitude must be between -90 and 90.";
        if (data.longitude != null && (data.longitude.compareTo(new BigDecimal("-180")) < 0 || data.longitude.compareTo(new BigDecimal("180")) > 0)) return "Longitude must be between -180 and 180.";
        if (!"INDOOR".equals(data.placeType) && !"OUTDOOR".equals(data.placeType)) return "Invalid place type.";
        return null;
    }

    private static String trim(String value) { return value == null ? "" : value.trim(); }

    private int parseInt(String value, int fallback) {
        try { return Integer.parseInt(value); } catch (Exception e) { return fallback; }
    }

    private BigDecimal parseDecimal(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try { return new BigDecimal(value.trim()); } catch (NumberFormatException e) { return null; }
    }

    private Time parseTime(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try { return Time.valueOf(value.trim().length() == 5 ? value.trim() + ":00" : value.trim()); }
        catch (IllegalArgumentException e) { return null; }
    }

    private void logAction(HttpServletRequest request, String action, String detail) {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user != null) auditLogDAO.log(user.getUserId(), action, null, detail);
    }

    private void redirectSuccess(HttpServletRequest request, HttpServletResponse response, String message) throws IOException {
        request.getSession(true).setAttribute("successMessage", message);
        response.sendRedirect(request.getContextPath() + "/admin/places");
    }

    private void redirectError(HttpServletRequest request, HttpServletResponse response, String message) throws IOException {
        request.getSession(true).setAttribute("errorMessage", message);
        response.sendRedirect(request.getContextPath() + "/admin/places");
    }

    private static class PlaceFormData {
        int categoryId;
        String placeName = "";
        String address = "";
        String description = "";
        BigDecimal estimatedCost;
        BigDecimal rating;
        Time openingTime;
        Time closingTime;
        BigDecimal latitude;
        BigDecimal longitude;
        String placeType = "INDOOR";

        Place toPlace() {
            Place p = new Place();
            p.setCategoryId(categoryId);
            p.setPlaceName(placeName);
            p.setAddress(address);
            p.setDescription(description.isEmpty() ? null : description);
            p.setEstimatedCost(estimatedCost == null ? BigDecimal.ZERO : estimatedCost);
            p.setRating(rating == null ? BigDecimal.ZERO : rating);
            p.setOpeningTime(openingTime);
            p.setClosingTime(closingTime);
            p.setLatitude(latitude);
            p.setLongitude(longitude);
            p.setPlaceType(placeType);
            p.setActive(true);
            return p;
        }
    }
}
