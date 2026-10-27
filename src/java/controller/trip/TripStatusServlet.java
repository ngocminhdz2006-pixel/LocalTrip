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
import utils.NotificationService;

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

            Date today = utils.AppClock.todaySql();

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
                        "Trip status updated successfully."
                );

                String statusLabel = "updated";
                if ("ONGOING".equalsIgnoreCase(newStatus)) {
                    statusLabel = "started";
                } else if ("COMPLETED".equalsIgnoreCase(newStatus)) {
                    statusLabel = "completed";
                } else if ("CANCELLED".equalsIgnoreCase(newStatus)) {
                    statusLabel = "cancelled";
                }
                String message = "Trip \"" + trip.getName() + "\" has been " + statusLabel + ".";
                NotificationService.notifyTripMembers(tripId, user.getUserId(), "TRIP_STATUS", tripId, message);
            } else {
                session.setAttribute(
                        "errorMessage",
                        "Cannot change trip status. "
                        + "Trips can only be started during the scheduled travel dates "
                        + "and after an itinerary has been added. "
                        + "Completed or cancelled trips cannot change status."
                );
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/trip/detail?tripId=" + tripId
            );

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Cannot update trip status.", e
            );
        }
    }
}
