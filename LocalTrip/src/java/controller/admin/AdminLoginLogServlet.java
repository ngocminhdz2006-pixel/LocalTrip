package controller.admin;

import dao.LoginLogDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminLoginLogServlet",
        urlPatterns = {"/admin/login-logs"})
public class AdminLoginLogServlet extends HttpServlet {

    private static final String VIEW
            = "/WEB-INF/views/admin/login-log-list.jsp";

    private static final int MAX_LOGS = 100;

    private final LoginLogDAO loginLogDAO
            = new LoginLogDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String emailKeyword = request.getParameter("email");
        String result = request.getParameter("result");

        request.setAttribute(
                "emailKeyword",
                emailKeyword == null ? "" : emailKeyword.trim()
        );

        request.setAttribute(
                "selectedResult",
                result == null ? "" : result
        );

        request.setAttribute(
                "loginLogs",
                loginLogDAO.searchRecent(
                        emailKeyword,
                        result,
                        MAX_LOGS
                )
        );

        request.getRequestDispatcher(VIEW)
                .forward(request, response);
    }
}
