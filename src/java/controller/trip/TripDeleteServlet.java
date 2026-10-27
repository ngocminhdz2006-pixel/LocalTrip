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

        String token = request.getParameter("csrfToken");
        Object expectedToken = session.getAttribute("travelCsrf");

        if (token == null || !token.equals(expectedToken)) {
            response.sendError(
                    403, "Invalid session token. Please reload the page."
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
            response.sendError(400, "Invalid trip ID.");
            return;
        }

        try {
            boolean deleted = tripDAO.deletePlanningTrip(
                    tripId, user.getUserId()
            );

            if (deleted) {
                session.setAttribute(
                        "successMessage",
                        "Trip deleted successfully."
                );
            } else {
                session.setAttribute(
                        "errorMessage",
                        "Cannot delete this trip. "
                        + "Deletion is only available for trips in PLANNING status "
                        + "without any recorded expenses or group fund deposits. "
                        + "If transactions already exist, please Cancel the trip "
                        + "to preserve financial history."
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
                    "Cannot delete trip.", e
            );
        }
    }
}
