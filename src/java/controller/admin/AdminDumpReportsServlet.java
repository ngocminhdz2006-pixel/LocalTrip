package controller.admin;

import dao.TravelFeatureDAO;
import java.io.IOException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

@WebServlet("/admin/dump-reports")
public class AdminDumpReportsServlet extends HttpServlet {
    private final TravelFeatureDAO dao=new TravelFeatureDAO();
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException {
        HttpSession s=req.getSession(false);User u=s==null?null:(User)s.getAttribute("user");if(u==null||!"ADMIN".equals(u.getRole())){resp.sendError(403);return;}
        if(s.getAttribute("travelCsrf")==null)s.setAttribute("travelCsrf",UUID.randomUUID().toString());
        req.setAttribute("reports",dao.getPostReports());req.getRequestDispatcher("/WEB-INF/views/admin/dump-reports.jsp").forward(req,resp);
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException {
        HttpSession s=req.getSession(false);User u=s==null?null:(User)s.getAttribute("user");if(u==null||!"ADMIN".equals(u.getRole())){resp.sendError(403);return;}
        Object token=s.getAttribute("travelCsrf");if(!(token instanceof String)||!token.equals(req.getParameter("csrfToken"))){s.setAttribute("errorMessage","Phiên biểu mẫu đã hết hạn.");resp.sendRedirect(req.getContextPath()+"/admin/dump-reports");return;}
        try{dao.updatePostReport(Integer.parseInt(req.getParameter("reportId")),req.getParameter("status"));s.setAttribute("successMessage","Đã cập nhật trạng thái báo cáo.");}catch(IllegalArgumentException e){s.setAttribute("errorMessage",e.getMessage());}
        resp.sendRedirect(req.getContextPath()+"/admin/dump-reports");
    }
}
