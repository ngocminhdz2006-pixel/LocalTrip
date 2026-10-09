package controller.trip;

import dao.TripDAO;
import dao.TripStatusDAO;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.ZoneId;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Trip;
import model.User;

@WebServlet("/trip/status")
public class TripStatusServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final TripStatusDAO statusDAO = new TripStatusDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null
                ? null
                : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        if (!"USER".equals(user.getRole())) {
            response.sendError(403);
            return;
        }

        String token = request.getParameter("statusToken");
        Object expectedToken = session.getAttribute("tripStatusToken");

        if (token == null || !token.equals(expectedToken)) {
            response.sendError(
                    403, "Phiên thao tác không hợp lệ. Hãy tải lại trang."
            );
            return;
        }

        int tripId;

        try {
            tripId = Integer.parseInt(request.getParameter("tripId"));

            if (tripId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400, "Mã chuyến đi không hợp lệ.");
            return;
        }

        try {
            Trip trip = tripDAO.findByIdForUser(
                    tripId, user.getUserId()
            );

            if (trip == null) {
                response.sendError(404);
                return;
            }

            if (!"OWNER".equals(trip.getRole())) {
                response.sendError(403);
                return;
            }

            String newStatus = request.getParameter("status");

            Date today = Date.valueOf(
                    LocalDate.now(
                            ZoneId.of("Asia/Ho_Chi_Minh")
                    )
            );

            boolean updated = statusDAO.changeStatus(
                    tripId,
                    user.getUserId(),
                    trip.getStatus(),
                    newStatus,
                    today
            );

            if (updated) {
                session.setAttribute(
                        "successMessage",
                        "Đã cập nhật trạng thái chuyến đi."
                );
            } else {
                session.setAttribute(
                        "errorMessage",
                        "Không thể chuyển trạng thái. "
                        + "Chỉ được bắt đầu trong thời gian chuyến đi "
                        + "và khi đã có lịch trình. "
                        + "Chuyến đã hoàn thành hoặc đã hủy "
                        + "không thể chuyển trạng thái."
                );
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/trip/detail?tripId=" + tripId
            );

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Không thể cập nhật trạng thái chuyến đi.", e
            );
        }
    }
}