package controller;

import dao.NotificationDAO;
import dao.TravelFeatureDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Notification;
import model.User;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final TravelFeatureDAO travelDAO = new TravelFeatureDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (session.getAttribute("travelCsrf") == null) {
            session.setAttribute("travelCsrf", UUID.randomUUID().toString());
        }

        int page = 1;
        int limit = 20;
        try {
            String pageParam = req.getParameter("page");
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                page = Math.max(1, Integer.parseInt(pageParam.trim()));
            }
        } catch (NumberFormatException ignored) {
            page = 1;
        }
        int offset = (page - 1) * limit;

        try {
            List<Notification> notifications = notificationDAO.findByUser(user.getUserId(), limit, offset);
            List<Map<String, Object>> friendRequests = travelDAO.getFriendRequests(user.getUserId());
            int unreadDbCount = notificationDAO.countUnread(user.getUserId());
            int totalUnread = unreadDbCount + friendRequests.size();

            session.setAttribute("unreadNotificationCount", totalUnread);

            req.setAttribute("notifications", notifications);
            req.setAttribute("friendRequests", friendRequests);
            req.setAttribute("unreadCount", totalUnread);
            req.setAttribute("currentPage", page);

            req.getRequestDispatcher("/WEB-INF/views/notification/notifications.jsp")
                    .forward(req, resp);
        } catch (RuntimeException e) {
            throw new ServletException("Unable to load notifications.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String sessionCsrf = (String) session.getAttribute("travelCsrf");
        String paramCsrf = req.getParameter("csrfToken");
        if (sessionCsrf == null || !sessionCsrf.equals(paramCsrf)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token.");
            return;
        }

        String action = req.getParameter("action");
        if ("markAllRead".equals(action)) {
            notificationDAO.markAllAsRead(user.getUserId());
            int remaining = travelDAO.getFriendRequests(user.getUserId()).size();
            session.setAttribute("unreadNotificationCount", remaining);

            if (isAjax(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":true,\"unreadCount\":" + remaining + "}");
                return;
            }
        } else if ("markRead".equals(action)) {
            String idStr = req.getParameter("notificationId");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    int notificationId = Integer.parseInt(idStr.trim());
                    // Enforce recipient security: only recipient can mark their own notification as read
                    boolean ok = notificationDAO.markAsRead(notificationId, user.getUserId());
                    if (!ok) {
                        // Not found or not owned by user: ignore/forbidden
                        log("Warning: User " + user.getUserId() + " attempted to mark non-owned notification " + notificationId);
                    }
                } catch (NumberFormatException ignored) {
                }
            }
            int remaining = notificationDAO.countUnread(user.getUserId()) + travelDAO.getFriendRequests(user.getUserId()).size();
            session.setAttribute("unreadNotificationCount", remaining);

            if (isAjax(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":true,\"unreadCount\":" + remaining + "}");
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/notifications");
    }

    private boolean isAjax(HttpServletRequest req) {
        return "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"));
    }
}
