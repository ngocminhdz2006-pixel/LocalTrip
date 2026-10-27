package controller;

import dao.CategoryDAO;
import dao.PreferenceDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.Category;
import model.User;

@WebServlet("/account")
public class AccountServlet extends HttpServlet {

    private final PreferenceDAO preferenceDAO = new PreferenceDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User user = session == null
                ? null : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (!"USER".equals(user.getRole())) {
            response.sendError(403);
            return;
        }

        // Load travel categories and user's saved preferences
        List<Category> allCategories = categoryDAO.findAll();
        Set<Integer> userCategoryIds = preferenceDAO.getUserPreferences(user.getUserId());

        request.setAttribute("categories", allCategories);
        request.setAttribute("userCategoryIds", userCategoryIds);
        request.setAttribute("pageTitle", "Account Profile");

        request.getRequestDispatcher(
                "/WEB-INF/views/account.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        User user = session == null
                ? null : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("savePreferences".equals(action)) {
            String[] selectedStr = request.getParameterValues("categoryIds");
            List<Integer> categoryIds = new ArrayList<>();
            if (selectedStr != null) {
                for (String s : selectedStr) {
                    try {
                        int id = Integer.parseInt(s.trim());
                        if (id > 0) {
                            categoryIds.add(id);
                        }
                    } catch (NumberFormatException ignored) {
                    }
                }
            }

            preferenceDAO.saveUserPreferences(user.getUserId(), categoryIds);
            session.setAttribute("successMessage", "Travel preferences updated successfully! New trips will now auto-match your taste.");
            response.sendRedirect(request.getContextPath() + "/account");
            return;
        }

        if ("deleteAccount".equals(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String confirmText = request.getParameter("confirmText");

            if (confirmText == null || !"DELETE".equals(confirmText.trim())) {
                session.setAttribute("errorMessage", "Account deletion cancelled: You must type 'DELETE' exactly to confirm.");
                response.sendRedirect(request.getContextPath() + "/account");
                return;
            }

            if (currentPassword == null || currentPassword.isEmpty()) {
                session.setAttribute("errorMessage", "Current password is required to delete your account.");
                response.sendRedirect(request.getContextPath() + "/account");
                return;
            }

            dao.UserDAO userDAO = new dao.UserDAO();
            User freshUser = userDAO.findById(user.getUserId());
            if (freshUser == null || freshUser.getPasswordHash() == null
                    || !utils.PasswordUtil.verify(currentPassword, freshUser.getPasswordHash())) {
                session.setAttribute("errorMessage", "Invalid current password. Account deletion denied.");
                response.sendRedirect(request.getContextPath() + "/account");
                return;
            }

            // Blocking Rule 1: Cannot delete if owner of any trip in PLANNING or ONGOING
            if (userDAO.hasActiveOwnedTrips(user.getUserId())) {
                session.setAttribute("errorMessage", "Cannot delete account: You are the owner of active trip(s) in Planning or Ongoing status. Please transfer ownership or delete those trips first.");
                response.sendRedirect(request.getContextPath() + "/account");
                return;
            }

            // Blocking Rule 2: Cannot delete if pending/sent settlement payments exist
            if (userDAO.hasUnsettledPayments(user.getUserId())) {
                session.setAttribute("errorMessage", "Cannot delete account: You have pending or sent settlement payments in group trips. Please resolve all unsettled balances first.");
                response.sendRedirect(request.getContextPath() + "/account");
                return;
            }

            userDAO.deactivateAndAnonymize(user.getUserId());
            try {
                controller.auth.RememberMeUtil.revoke(request, response);
            } catch (Exception ignored) {
            }
            session.invalidate();
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("authMessage", "Your account has been deleted and deactivated successfully.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/account");
    }
}
