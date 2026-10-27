package controller.trip;

import dao.TripDAO;
import dao.TripInviteDAO;
import dao.TripMemberDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Trip;
import model.TripInvite;
import model.User;
import utils.NotificationService;

@WebServlet(name = "TripInviteServlet", urlPatterns = {"/trip/invite", "/trip/join"})
public class TripInviteServlet extends HttpServlet {

    private final TripInviteDAO tripInviteDAO = new TripInviteDAO();
    private final TripDAO tripDAO = new TripDAO();
    private final TripMemberDAO tripMemberDAO = new TripMemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();

        if ("/trip/join".equals(servletPath)) {
            String token = request.getParameter("token");
            if (token == null || token.trim().isEmpty()) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Missing trip invite token.");
                response.sendRedirect(request.getContextPath() + "/trips");
                return;
            }

            TripInvite invite = tripInviteDAO.findByToken(token.trim());
            if (invite == null || invite.isExpired()) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "This invite link is invalid or has expired.");
                response.sendRedirect(request.getContextPath() + "/trips");
                return;
            }

            HttpSession session = request.getSession(false);
            User user = session == null ? null : (User) session.getAttribute("user");

            if (user == null) {
                HttpSession newSession = request.getSession(true);
                newSession.setAttribute("redirectAfterLogin", request.getContextPath() + "/trip/join?token=" + token.trim());
                newSession.setAttribute("authMessage", "Please sign in or create an account to accept the trip invitation.");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            int tripId = invite.getTripId();
            boolean newlyAdded = false;
            if (!tripMemberDAO.exists(tripId, user.getUserId())) {
                newlyAdded = tripMemberDAO.addMember(tripId, user.getUserId());
            }

            Trip trip = tripDAO.findById(tripId);
            String tripName = trip != null ? trip.getName() : "the trip";

            if (newlyAdded && trip != null && trip.getOwnerId() != user.getUserId()) {
                NotificationService.notify(
                        trip.getOwnerId(),
                        user.getUserId(),
                        "TRIP_JOINED",
                        tripId,
                        tripId,
                        user.getFullName() + " joined \"" + tripName + "\" via invite link."
                );
            }

            session.setAttribute("successMessage", "Welcome aboard! You have joined \"" + tripName + "\".");
            response.sendRedirect(request.getContextPath() + "/trip/detail?tripId=" + tripId);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/trips");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String tripIdParam = request.getParameter("tripId");
        if (tripIdParam == null || tripIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/trips");
            return;
        }

        try {
            int tripId = Integer.parseInt(tripIdParam.trim());
            Trip trip = tripDAO.findByIdForUser(tripId, user.getUserId());

            if (trip == null || !"OWNER".equalsIgnoreCase(trip.getRole())) {
                session.setAttribute("errorMessage", "Only the trip owner can manage invite links.");
                response.sendRedirect(request.getContextPath() + "/trip/detail?tripId=" + tripId);
                return;
            }

            tripInviteDAO.createOrRenewInvite(tripId, user.getUserId());
            session.setAttribute("successMessage", "Trip invite link refreshed successfully.");
            response.sendRedirect(request.getContextPath() + "/trip/detail?tripId=" + tripId);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/trips");
        }
    }
}
