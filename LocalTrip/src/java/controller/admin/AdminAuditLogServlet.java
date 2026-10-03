package controller.admin;

import dao.AdminAuditLogDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin/audit-logs")
public class AdminAuditLogServlet extends HttpServlet {

    private static final String VIEW =
            "/WEB-INF/views/admin/audit-log-list.jsp";

    private static final int MAX_LOGS = 100;

    private final AdminAuditLogDAO auditLogDAO =
            new AdminAuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.setAttribute(
                    "logs",
                    auditLogDAO.findRecent(MAX_LOGS)
            );

            request.setAttribute(
                    "pageTitle",
                    "Nhật ký quản trị"
            );

        } catch (RuntimeException e) {
            request.setAttribute(
                    "errorMessage",
                    "Không thể tải nhật ký quản trị."
            );
        }

        request.getRequestDispatcher(VIEW)
                .forward(request, response);
    }
}