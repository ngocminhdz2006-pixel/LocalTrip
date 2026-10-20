package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.User;

@WebServlet("/account")
public class AccountServlet extends HttpServlet {

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

        request.setAttribute("pageTitle", "Account");

        request.getRequestDispatcher(
                "/WEB-INF/views/account.jsp")
                .forward(request, response);
    }
}