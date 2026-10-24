package controller.auth;

import dao.PasswordResetDAO;
import model.User;
import utils.PasswordUtil;
import utils.ValidationUtil;
import utils.PasswordValidator;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Validates a reset token and sets a new password.
 */
@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/auth/reset-password.jsp";
    private final PasswordResetDAO resetDAO = new PasswordResetDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        User user = token == null ? null : resetDAO.findUserByValidToken(utils.TokenUtil.sha256(token));
        if (user == null) {
            request.setAttribute("errorMessage", "The password reset link is invalid or has expired.");
        } else {
            request.setAttribute("token", token);
        }
        request.setAttribute("pageTitle", "Reset password");
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        if (token == null || token.trim().isEmpty()) {
            forwardError(request, response, "The password reset link is invalid.", null);
            return;
        }
        String passwordError = PasswordValidator.validate(password);

        if (passwordError != null) {
            forwardError(
                    request,
                    response,
                    passwordError,
                    token
            );
            return;
        }
        if (!password.equals(confirm)) {
            forwardError(request, response, "Password confirmation does not match.", token);
            return;
        }

        String tokenHash = utils.TokenUtil.sha256(token);
        User user = resetDAO.findUserByValidToken(tokenHash);
        if (user == null) {
            forwardError(request, response, "The password reset link is invalid or has expired.", null);
            return;
        }

        boolean success = resetDAO.resetPassword(tokenHash, PasswordUtil.hash(password));
        if (!success) {
            forwardError(request, response, "Unable to reset password. Please request a new link.", null);
            return;
        }

        // A password change invalidates existing remember-me sessions for this account.
        new dao.RememberMeDAO().deleteAllForUser(user.getUserId());
        request.setAttribute("successMessage", "Password reset successful. You can now sign in with your new password.");
        request.setAttribute("pageTitle", "Reset password");
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private void forwardError(HttpServletRequest request, HttpServletResponse response,
            String message, String token)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.setAttribute("token", token);
        request.setAttribute("pageTitle", "Reset password");
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
