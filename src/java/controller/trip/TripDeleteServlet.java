package controller.trip;

import dao.TripDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

@WebServlet("/trip/delete")
public class TripDeleteServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();

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

        String token = request.getParameter("deleteToken");
        Object expectedToken = session.getAttribute("tripDeleteToken");

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
            boolean deleted = tripDAO.deletePlanningTrip(
                    tripId, user.getUserId()
            );

            if (deleted) {
                session.setAttribute(
                        "successMessage",
                        "Đã xóa chuyến đi."
                );
            } else {
                session.setAttribute(
                        "errorMessage",
                        "Không thể xóa chuyến đi này. "
                        + "Chức năng xóa chỉ áp dụng cho chuyến đang lên kế hoạch "
                        + "và chưa có khoản chi hoặc tiền đóng quỹ. "
                        + "Nếu đã phát sinh giao dịch, hãy dùng Hủy chuyến đi "
                        + "để giữ lại lịch sử tài chính."
                );
            }

            response.sendRedirect(
                    request.getContextPath() + "/trips"
            );

        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", e.getMessage());

            response.sendRedirect(
                    request.getContextPath() + "/trips"
            );

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Không thể xóa chuyến đi.", e
            );
        }
    }
}
