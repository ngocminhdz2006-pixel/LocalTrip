package controller;

import dao.TravelFeatureDAO;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private final TravelFeatureDAO dao = new TravelFeatureDAO();

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

        boolean demo = "1".equals(req.getParameter("demo"));
        List<Map<String, Object>> items = new ArrayList<Map<String, Object>>();

        try {
            // Dữ liệu thật: lời mời kết bạn đang chờ
            List<Map<String, Object>> requests = dao.getFriendRequests(user.getUserId());
            for (Map<String, Object> fr : requests) {
                Map<String, Object> n = newItem("FRIEND_REQUEST",
                        String.valueOf(fr.get("fullName")),
                        "sent you a friend request.",
                        timeAgo((Timestamp) fr.get("createdAt")),
                        true, false);
                n.put("friendshipId", fr.get("friendshipId"));
                items.add(n);
            }

            // Dữ liệu mẫu để xem bố cục (chỉ khi có ?demo=1)
            if (demo) {
                if (requests.isEmpty()) {
                    Map<String, Object> n = newItem("FRIEND_REQUEST", "Lan Anh",
                            "sent you a friend request.", "2 hours ago", true, true);
                    n.put("friendshipId", 0);
                    items.add(n);
                }

                Map<String, Object> invite = newItem("TRIP_INVITE", "Hoang Nam",
                        "invited you to a trip.", "5 hours ago", true, true);
                invite.put("tripName", "Explore District 1");
                invite.put("tripDates", "Oct 16 – 18, 2026");
                items.add(invite);

                items.add(newItem("FRIEND_ACCEPTED", "Lan",
                        "accepted your friend request.", "1 day ago", false, true));
            }
        } catch (RuntimeException e) {
            throw new ServletException("Không thể tải thông báo.", e);
        }

        int unreadCount = 0;
        for (Map<String, Object> n : items) {
            if (Boolean.TRUE.equals(n.get("unread"))) {
                unreadCount++;
            }
        }

        req.setAttribute("items", items);
        req.setAttribute("unreadCount", unreadCount);
        req.setAttribute("demo", demo);
        req.getRequestDispatcher("/WEB-INF/views/notification/notifications.jsp")
                .forward(req, resp);
    }

    private static Map<String, Object> newItem(String type, String actorName,
            String text, String timeAgo, boolean unread, boolean demo) {
        Map<String, Object> n = new LinkedHashMap<String, Object>();
        n.put("type", type);
        n.put("actorName", actorName);
        n.put("text", text);
        n.put("timeAgo", timeAgo);
        n.put("unread", unread);
        n.put("demo", demo);
        return n;
    }

    private static String timeAgo(Timestamp t) {
        if (t == null) {
            return "";
        }
        long minutes = (System.currentTimeMillis() - t.getTime()) / 60000L;
        if (minutes < 1) {
            return "Just now";
        }
        if (minutes < 60) {
            return minutes + (minutes == 1 ? " minute ago" : " minutes ago");
        }
        long hours = minutes / 60;
        if (hours < 24) {
            return hours + (hours == 1 ? " hour ago" : " hours ago");
        }
        long days = hours / 24;
        return days + (days == 1 ? " day ago" : " days ago");
    }
}