package controller.admin;

import dao.AdminAuditLogDAO;
import dao.CategoryDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Category;

@WebServlet({
    "/admin/categories",
    "/admin/categories/create",
    "/admin/categories/edit",
    "/admin/categories/delete"
})
public class AdminCategoryServlet extends HttpServlet {

    private static final String LIST_VIEW = "/WEB-INF/views/admin/category-list.jsp";
    private static final String FORM_VIEW = "/WEB-INF/views/admin/category-form.jsp";

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final AdminAuditLogDAO auditLogDAO = new AdminAuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/admin/categories/create".equals(path)) {
            showForm(request, response, null);
            return;
        }

        if ("/admin/categories/edit".equals(path)) {
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

        if ("/admin/categories/create".equals(path)) {
            createCategory(request, response);
            return;
        }

        if ("/admin/categories/edit".equals(path)) {
            updateCategory(request, response);
            return;
        }

        if ("/admin/categories/delete".equals(path)) {
            deleteCategory(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        keyword = keyword == null ? "" : keyword.trim();

        try {
            List<Category> categories = categoryDAO.searchAdmin(keyword);
            request.setAttribute("categories", categories);
            request.setAttribute("keyword", keyword);
            request.setAttribute("pageTitle", "Category Management");
            request.getRequestDispatcher(LIST_VIEW).forward(request, response);
        } catch (RuntimeException e) {
            request.setAttribute("categories", java.util.Collections.emptyList());
            request.setAttribute("keyword", keyword);
            request.setAttribute("errorMessage", "Failed to load category list.");
            request.setAttribute("pageTitle", "Category Management");
            request.getRequestDispatcher(LIST_VIEW).forward(request, response);
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int categoryId = parseInt(request.getParameter("id"), -1);
        if (categoryId <= 0) {
            redirectWithMessage(request, response, "Invalid category ID.", true);
            return;
        }

        Category category = categoryDAO.findById(categoryId);
        if (category == null) {
            redirectWithMessage(request, response, "Category not found.", true);
            return;
        }

        showForm(request, response, category);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, Category category)
            throws ServletException, IOException {
        request.setAttribute("item", category);
        request.setAttribute("pageTitle", category == null ? "Add Category" : "Edit Category");
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }

    private void createCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Category category = readForm(request);
        String error = validate(category);

        if (error != null) {
            request.setAttribute("errorMessage", error);
            request.setAttribute("item", category);
            request.setAttribute("pageTitle", "Add Category");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
            return;
        }

        try {
            int id = categoryDAO.insert(category);
            logAction(request, "CREATE_CATEGORY", "Created category #" + id + " - " + category.getCategoryName());
            redirectWithMessage(request, response, "Category created successfully.", false);
        } catch (RuntimeException e) {
            request.setAttribute("errorMessage", "Failed to add category. Category code or name may already exist.");
            request.setAttribute("item", category);
            request.setAttribute("pageTitle", "Add Category");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        }
    }

    private void updateCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int categoryId = parseInt(request.getParameter("categoryId"), -1);
        if (categoryId <= 0) {
            redirectWithMessage(request, response, "Invalid category ID.", true);
            return;
        }

        Category category = readForm(request);
        category.setCategoryId(categoryId);
        String error = validate(category);

        if (error != null) {
            request.setAttribute("errorMessage", error);
            request.setAttribute("item", category);
            request.setAttribute("pageTitle", "Edit Category");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
            return;
        }

        try {
            if (!categoryDAO.update(category)) {
                redirectWithMessage(request, response, "Category not found to update.", true);
                return;
            }
            logAction(request, "UPDATE_CATEGORY", "Updated category #" + categoryId + " - " + category.getCategoryName());
            redirectWithMessage(request, response, "Category updated successfully.", false);
        } catch (RuntimeException e) {
            request.setAttribute("errorMessage", "Failed to update category. Category code or name may already exist.");
            request.setAttribute("item", category);
            request.setAttribute("pageTitle", "Edit Category");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        }
    }

    private void deleteCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int categoryId = parseInt(request.getParameter("id"), -1);
        if (categoryId <= 0) {
            redirectWithMessage(request, response, "Invalid category ID.", true);
            return;
        }

        Category category = categoryDAO.findById(categoryId);
        if (category == null) {
            redirectWithMessage(request, response, "Category not found.", true);
            return;
        }

        if (category.getPlaceCount() > 0) {
            redirectWithMessage(request, response,
                    "Cannot delete category because " + category.getPlaceCount() + " places are assigned to this category. Please reassign those places first.", true);
            return;
        }

        try {
            if (categoryDAO.delete(categoryId)) {
                logAction(request, "DELETE_CATEGORY", "Deleted category #" + categoryId + " - " + category.getCategoryName());
                redirectWithMessage(request, response, "Category deleted successfully.", false);
            } else {
                redirectWithMessage(request, response, "Failed to delete category.", true);
            }
        } catch (RuntimeException e) {
            redirectWithMessage(request, response,
                    "Cannot delete category. It may be referenced in system records.", true);
        }
    }

    private Category readForm(HttpServletRequest request) {
        Category category = new Category();
        category.setCategoryCode(trim(request.getParameter("categoryCode")));
        category.setCategoryName(trim(request.getParameter("categoryName")));
        return category;
    }

    private String validate(Category category) {
        if (category.getCategoryCode() == null || category.getCategoryCode().isEmpty()) {
            return "Category code cannot be empty.";
        }
        if (category.getCategoryCode().length() > 50) {
            return "Category code cannot exceed 50 characters.";
        }
        if (!category.getCategoryCode().matches("[A-Za-z0-9_-]+")) {
            return "Category code may only contain letters, numbers, hyphens, or underscores.";
        }
        if (category.getCategoryName() == null || category.getCategoryName().isEmpty()) {
            return "Category name cannot be empty.";
        }
        if (category.getCategoryName().length() > 100) {
            return "Category name cannot exceed 100 characters.";
        }
        return null;
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private void logAction(HttpServletRequest request, String action, String detail) {
        javax.servlet.http.HttpSession session = request.getSession(false);
        if (session == null) return;
        model.User user = (model.User) session.getAttribute("user");
        if (user != null) {
            auditLogDAO.log(user.getUserId(), action, null, detail);
        }
    }

    private void redirectWithMessage(HttpServletRequest request, HttpServletResponse response,
            String message, boolean error) throws IOException {
        request.getSession().setAttribute(error ? "errorMessage" : "successMessage", message);
        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }
}
