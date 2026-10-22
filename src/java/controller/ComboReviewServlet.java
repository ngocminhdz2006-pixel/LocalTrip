package controller;

import dao.ComboTemplateDAO;
import dao.TripDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Trip;
import model.User;

@WebServlet("/combo/review")
public class ComboReviewServlet extends HttpServlet {

    private final ComboTemplateDAO comboDAO = new ComboTemplateDAO();
    private final TripDAO tripDAO = new TripDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        int tripId = 0;
        int comboId = 0;
        try {
            tripId = Integer.parseInt(request.getParameter("tripId"));
            comboId = Integer.parseInt(request.getParameter("comboId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid trip or combo ID.");
            return;
        }

        Trip trip = tripDAO.findByIdForUser(tripId, user.getUserId());
        if (trip == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Trip not found or access denied.");
            return;
        }

        if (!"COMPLETED".equalsIgnoreCase(trip.getStatus())) {
            session.setAttribute("errorMessage", "Reviews can only be submitted after the trip is completed.");
            response.sendRedirect(request.getContextPath() + "/trip/detail?tripId=" + tripId);
            return;
        }

        if (comboDAO.hasUserReviewed(tripId, user.getUserId())) {
            session.setAttribute("errorMessage", "You have already submitted a review for this trip's combo.");
            response.sendRedirect(request.getContextPath() + "/trip/detail?tripId=" + tripId);
            return;
        }

        int rating = 5;
        try {
            rating = Integer.parseInt(request.getParameter("rating"));
            if (rating < 1 || rating > 5) {
                rating = 5;
            }
        } catch (NumberFormatException ignored) {
        }

        String paceFeedback = request.getParameter("paceFeedback");
        if (paceFeedback != null) {
            paceFeedback = paceFeedback.trim().toUpperCase();
            if (!"RELAXED".equals(paceFeedback) && !"BALANCED".equals(paceFeedback) && !"PACKED".equals(paceFeedback)) {
                paceFeedback = "BALANCED";
            }
        } else {
            paceFeedback = "BALANCED";
        }

        String budgetParam = request.getParameter("budgetMatch");
        boolean budgetMatch = !"0".equals(budgetParam) && !"false".equalsIgnoreCase(budgetParam);

        String[] tags = request.getParameterValues("vibeTags");
        String vibeTags = "";
        if (tags != null && tags.length > 0) {
            vibeTags = String.join(", ", tags);
        } else {
            String manualTags = request.getParameter("customVibeTags");
            if (manualTags != null) {
                vibeTags = manualTags.trim();
            }
        }

        String comment = request.getParameter("comment");
        if (comment != null) {
            comment = comment.trim();
            if (comment.length() > 1000) {
                comment = comment.substring(0, 1000);
            }
        }

        try {
            comboDAO.addReview(comboId, tripId, user.getUserId(), rating, paceFeedback, budgetMatch, vibeTags, comment);
            session.setAttribute("successMessage", "Thank you! Your combo review has been shared with the community.");
        } catch (RuntimeException e) {
            session.setAttribute("errorMessage", "Unable to submit review: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/trip/detail?tripId=" + tripId);
    }
}
