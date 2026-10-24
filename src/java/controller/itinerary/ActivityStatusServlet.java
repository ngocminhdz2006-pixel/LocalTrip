package controller.itinerary;

import dao.ActivityLifecycleDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.User;

@WebServlet({"/itinerary/activity/status", "/itinerary/lock"})
public class ActivityStatusServlet extends HttpServlet {
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session=req.getSession(false);
        User user=session==null?null:(User)session.getAttribute("user");
        if(user==null) { resp.sendRedirect(req.getContextPath()+"/login"); return; }
        if(!"USER".equals(user.getRole())) { resp.sendError(403); return; }
        Object token = session.getAttribute("activityStatusToken");
        Object travelCsrf = session.getAttribute("travelCsrf");
        String paramCsrf = req.getParameter("csrfToken");
        boolean csrfOk = (token != null && token.equals(paramCsrf))
                || (travelCsrf != null && travelCsrf.equals(paramCsrf));
        if (!csrfOk) { resp.sendError(403); return; }
        int tripId,itemId;
        try { tripId=Integer.parseInt(req.getParameter("tripId")); itemId=Integer.parseInt(req.getParameter("itemId")); if(tripId<=0||itemId<=0) throw new NumberFormatException(); }
        catch(NumberFormatException e) { resp.sendError(400); return; }
        try {
            ActivityLifecycleDAO dao=new ActivityLifecycleDAO();
            String action = req.getParameter("action");
            if ("toggleLock".equals(action) || "/itinerary/lock".equals(req.getServletPath())) {
                boolean lockVal = "true".equalsIgnoreCase(req.getParameter("locked")) || "1".equals(req.getParameter("locked"));
                new dao.ItineraryDAO().toggleLock(itemId, tripId, lockVal);
                session.setAttribute("successMessage", lockVal ? "Activity pinned/locked to schedule." : "Activity unlocked.");
            } else if("endTime".equals(action)) {
                String value=req.getParameter("endTime");
                if(value==null || !value.matches("\\d{2}:\\d{2}")) throw new IllegalArgumentException("Invalid end time.");
                java.time.LocalTime time=java.time.LocalTime.parse(value);
                dao.updateRunningEnd(tripId,itemId,user.getUserId(),req.getParameter("expectedEnd"),java.sql.Time.valueOf(time));
            } else {
                dao.changeStatus(tripId,itemId,user.getUserId(),req.getParameter("expectedStatus"),req.getParameter("nextStatus"));
            }
            session.setAttribute("successMessage","Activity status updated successfully.");
        } catch(IllegalArgumentException e) { session.setAttribute("errorMessage",e.getMessage()); }
        catch(java.time.DateTimeException e) { session.setAttribute("errorMessage","Invalid end time."); }
        catch(RuntimeException e) { log("Activity state update failed",e); session.setAttribute("errorMessage","Unable to update activity. Please reload the itinerary."); }
        resp.sendRedirect(req.getContextPath()+"/itinerary?tripId="+tripId);
    }
}
