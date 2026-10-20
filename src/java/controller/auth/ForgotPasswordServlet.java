package controller.auth;

import dao.PasswordResetDAO;
import dao.UserDAO;
import java.io.IOException;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.User;
import utils.TokenUtil;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/auth/forgot-password.jsp";

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO resetDAO = new PasswordResetDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Forgot password");
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String cleanEmail = email == null ? "" : email.trim().toLowerCase();

        // Always show the same neutral message to avoid revealing account existence
        String message = "If your email is registered in our system, password reset instructions have been generated.";
        request.setAttribute("successMessage", message);

        if (!cleanEmail.isEmpty()) {
            User user = userDAO.findActiveByEmail(cleanEmail);
            if (user != null) {
                String rawToken = TokenUtil.generateToken();
                long expires = System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(30);
                resetDAO.createToken(user.getUserId(), TokenUtil.sha256(rawToken), expires);

                String resetUrl = request.getScheme() + "://" + request.getServerName()
                        + ":" + request.getServerPort() + request.getContextPath()
                        + "/reset-password?token=" + rawToken;
                System.out.println("[LocalTrip DEV AUTH] Password reset link for " + cleanEmail + ": " + resetUrl);
            }
        }

        request.setAttribute("pageTitle", "Forgot password");
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}