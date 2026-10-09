package controller.passport;

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

@WebServlet("/passport")
public class PassportServlet extends HttpServlet {
    private final TravelFeatureDAO dao=new TravelFeatureDAO();
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException {
        HttpSession s=req.getSession(false);User user=s==null?null:(User)s.getAttribute("user");if(user==null){resp.sendRedirect(req.getContextPath()+"/login");return;}
        if(s.getAttribute("travelCsrf")==null)s.setAttribute("travelCsrf",UUID.randomUUID().toString());
        int ownerId=user.getUserId();String requested=req.getParameter("userId");if(requested!=null&&!requested.trim().isEmpty()){try{ownerId=Integer.parseInt(requested);if(ownerId<1)throw new NumberFormatException();}catch(NumberFormatException e){resp.sendError(404);return;}}
        boolean own=ownerId==user.getUserId();
        try{if(!dao.canViewPassport(user.getUserId(),ownerId)){resp.sendError(404);return;}req.setAttribute("isOwnPassport",own);req.setAttribute("passportVisibility",dao.getPassportVisibility(ownerId));req.setAttribute("summary",dao.getPassportSummary(ownerId));req.setAttribute("checkIns",dao.getPassportCheckIns(ownerId));req.setAttribute("badges",dao.getBadges(ownerId));req.getRequestDispatcher("/WEB-INF/views/passport/passport.jsp").forward(req,resp);}
        catch(RuntimeException e){throw new ServletException("Không thể tải Travel Passport.",e);}
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException {
        HttpSession s=req.getSession(false);User user=s==null?null:(User)s.getAttribute("user");if(user==null){resp.sendRedirect(req.getContextPath()+"/login");return;}
        Object token=s.getAttribute("travelCsrf");if(!(token instanceof String)||!token.equals(req.getParameter("csrfToken"))){s.setAttribute("errorMessage","Phiên biểu mẫu đã hết hạn.");resp.sendRedirect(req.getContextPath()+"/passport");return;}
        try{dao.setPassportVisibility(user.getUserId(),req.getParameter("visibility"));s.setAttribute("successMessage","Đã cập nhật quyền riêng tư Travel Passport.");}catch(IllegalArgumentException e){s.setAttribute("errorMessage",e.getMessage());}
        resp.sendRedirect(req.getContextPath()+"/passport");
    }
}
