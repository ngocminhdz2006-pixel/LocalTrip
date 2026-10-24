package controller;

import dao.ItineraryDAO;
import dao.TripDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.ItineraryDraft;
import model.ItineraryItem;
import model.Trip;
import model.User;

@WebServlet("/combos/draft/confirm")
public class ComboDraftConfirmServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final ItineraryDAO itineraryDAO = new ItineraryDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        handle(request, response, false);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        handle(request, response, true);
    }

    private void handle(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean confirming)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = session == null
                ? null : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (!"USER".equals(user.getRole())) {
            response.sendError(403);
            return;
        }

        int tripId;

        try {
            tripId = Integer.parseInt(
                    request.getParameter("tripId"));

            if (tripId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400);
            return;
        }

        String draftKey = "comboDraft:" + tripId;

        synchronized (session) {
            Trip trip = tripDAO.findByIdForUser(
                    tripId, user.getUserId());

            if (trip == null) {
                response.sendError(404);
                return;
            }

            if (!"OWNER".equals(trip.getRole())) {
                response.sendError(403);
                return;
            }

            if (!"PLANNING".equals(trip.getStatus())) {
                response.sendError(
                        409, "This trip is no longer in planning.");
                return;
            }

            Object stored = session.getAttribute(draftKey);

            ItineraryDraft draft =
                    stored instanceof ItineraryDraft
                            ? (ItineraryDraft) stored : null;

            if (draft == null || draft.isExpired()
                    || draft.getTripId() != tripId
                    || draft.getOwnerId() != user.getUserId()) {

                session.removeAttribute(draftKey);
                session.setAttribute("errorMessage",
                        "Your draft has expired. Select a combo again.");

                response.sendRedirect(
                        request.getContextPath()
                        + "/combos?tripId=" + tripId);
                return;
            }

            if (!confirming) {
                List<ItineraryItem> existingItems = itineraryDAO.findByTrip(tripId);
                request.setAttribute("existingItems", existingItems);
                request.setAttribute("hasExistingItems", existingItems != null && !existingItems.isEmpty());

                request.setAttribute("trip", trip);
                request.setAttribute("currentTrip", trip);
                request.setAttribute("comboDraft", draft);
                request.setAttribute(
                        "draftItems", draft.getItems());

                request.setAttribute(
                        "draftTotal", draft.totalCost());

                request.setAttribute(
                        "pageTitle", "Confirm itinerary");

                request.getRequestDispatcher(
                        "/WEB-INF/views/combo/combo-draft-confirm.jsp")
                        .forward(request, response);
                return;
            }

            if (!draft.getToken().equals(
                    request.getParameter("draftToken"))) {

                response.sendError(
                        409, "The draft has changed. Reload the review page.");
                return;
            }

            String applyMode = request.getParameter("applyMode");
            if (applyMode == null || applyMode.trim().isEmpty()) {
                applyMode = "REPLACE";
            }

            if ("REPLACE".equalsIgnoreCase(applyMode)
                    && !"yes".equals(request.getParameter("acceptReplacement"))) {

                session.setAttribute("errorMessage",
                        "Please acknowledge replacing the upcoming itinerary.");

                response.sendRedirect(
                        request.getContextPath()
                        + "/combos/draft/confirm?tripId=" + tripId);
                return;
            }

            try {
                for (ItineraryItem item : draft.getItems()) {
                    item.setSourceType("COMBO");
                }

                if ("APPEND".equalsIgnoreCase(applyMode)) {
                    itineraryDAO.appendFromDraft(tripId, user.getUserId(), draft.getItems());
                } else {
                    itineraryDAO.replaceFromDraft(
                            tripId,
                            user.getUserId(),
                            draft.getFromDate(),
                            draft.getRevision(),
                            draft.getItems());
                }

                if (draft.getComboId() > 0) {
                    tripDAO.setAppliedCombo(tripId, draft.getComboId());
                }

                // Remove draft only after successful commit.
                session.removeAttribute(draftKey);

                session.setAttribute("successMessage",
                        "APPEND".equalsIgnoreCase(applyMode)
                                ? "Curated combo activities appended to your itinerary successfully!"
                                : "Your new itinerary from combo has been confirmed.");

                response.sendRedirect(
                        request.getContextPath()
                        + "/itinerary?tripId=" + tripId);

            } catch (IllegalArgumentException e) {
                session.setAttribute(
                        "errorMessage", e.getMessage());

                response.sendRedirect(
                        request.getContextPath()
                        + "/combos/draft/confirm?tripId=" + tripId);

            } catch (RuntimeException e) {
                log("Cannot confirm combo draft", e);

                session.setAttribute("errorMessage",
                        "Unable to save. Your current itinerary is unchanged. "
                        + "Please reload and try again.");

                response.sendRedirect(
                        request.getContextPath()
                        + "/combos/draft/confirm?tripId=" + tripId);
            }
        }
    }
}
