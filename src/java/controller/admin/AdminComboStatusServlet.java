package controller.admin;

import dao.ComboTemplateStatusDAO;
import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

@WebServlet("/admin/combos/status")
public class AdminComboStatusServlet extends HttpServlet {

    private final ComboTemplateStatusDAO statusDAO =
            new ComboTemplateStatusDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null ? null
                : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (!"ADMIN".equals(user.getRole())) {
            response.sendError(403);
            return;
        }

        Object expectedToken =
                session.getAttribute("adminComboStatusToken");

        if (expectedToken == null
                || !expectedToken.equals(
                        request.getParameter("csrfToken"))) {
            response.sendError(403,
                    "Form session expired. Please reload the combo page.");
            return;
        }

        int comboId;

        try {
            comboId = Integer.parseInt(request.getParameter("id"));

            if (comboId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid combo ID.");
            return;
        }

        try {
            String newStatus = request.getParameter("newStatus");

            statusDAO.changeStatus(
                    comboId,
                    user.getUserId(),
                    request.getParameter("expectedStatus"),
                    newStatus);

            session.setAttribute("successMessage",
                    "ACTIVE".equals(newStatus)
                    ? "Combo has been activated."
                    : "Combo has been deactivated.");

        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", e.getMessage());

        } catch (RuntimeException e) {
            log("Failed to change combo status.", e);

            session.setAttribute("errorMessage",
                    "Failed to change combo status. "
                    + "Please check database connection.");
        }

        response.sendRedirect(
                request.getContextPath()
                + "/admin/combos/detail?id=" + comboId);
    }
}