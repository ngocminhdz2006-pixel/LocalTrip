package controller.expense;

import dao.SettlementDAO;
import dao.TripDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.SettlementBalance;
import model.SettlementTransfer;
import model.Trip;
import model.User;
import utils.NotificationService;

@WebServlet(name = "SettlementServlet", urlPatterns = {
    "/settlement"
})
public class SettlementServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final SettlementDAO settlementDAO = new SettlementDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        if (!"USER".equalsIgnoreCase(currentUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to access this feature."
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
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid Trip ID."
            );
            return;
        }

        try {
            Trip trip = tripDAO.findByIdForUser(tripId, currentUser.getUserId());

            if (trip == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Trip not found or access denied."
                );
                return;
            }

            List<SettlementBalance> balances = settlementDAO.findBalances(tripId);
            List<SettlementTransfer> transfers = settlementDAO.calculateTransfers(balances);

            // Sync payment status records (PENDING, SENT, CONFIRMED)
            settlementDAO.syncAndLoadPaymentStatuses(tripId, transfers);

            request.setAttribute("trip", trip);
            request.setAttribute("balances", balances);
            request.setAttribute("transfers", transfers);
            request.setAttribute("currentUser", currentUser);

            request.getRequestDispatcher(
                    "/WEB-INF/views/expense/settlement.jsp"
            ).forward(request, response);

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Unable to calculate settlement.",
                    e
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        int tripId = parsePositiveInt(request.getParameter("tripId"));
        int paymentId = parsePositiveInt(request.getParameter("paymentId"));
        String action = request.getParameter("action");

        if (tripId <= 0 || paymentId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid trip or payment ID.");
            return;
        }

        String newStatus = null;
        if ("markSent".equalsIgnoreCase(action)) {
            newStatus = "SENT";
        } else if ("confirmReceived".equalsIgnoreCase(action)) {
            newStatus = "CONFIRMED";
        }

        if (newStatus != null) {
            SettlementTransfer transfer = settlementDAO.findPaymentById(paymentId);
            boolean ok = settlementDAO.updatePaymentStatus(paymentId, tripId, currentUser.getUserId(), newStatus);
            if (ok) {
                session.setAttribute("successMessage", "SENT".equals(newStatus)
                        ? "Payment marked as SENT. Waiting for recipient confirmation."
                        : "Payment confirmed successfully!");

                if (transfer != null) {
                    Trip trip = tripDAO.findById(tripId);
                    String tripName = trip != null ? trip.getName() : "the trip";
                    if ("SENT".equals(newStatus)) {
                        NotificationService.notify(
                                transfer.getToMemberId(),
                                currentUser.getUserId(),
                                "PAYMENT_SENT",
                                tripId,
                                paymentId,
                                currentUser.getFullName() + " marked payment sent. Please confirm you received the settlement payment for \"" + tripName + "\"."
                        );
                    } else if ("CONFIRMED".equals(newStatus)) {
                        NotificationService.notify(
                                transfer.getFromMemberId(),
                                currentUser.getUserId(),
                                "PAYMENT_CONFIRMED",
                                tripId,
                                paymentId,
                                currentUser.getFullName() + " confirmed receipt of your settlement payment for \"" + tripName + "\"."
                        );
                    }
                }
            } else {
                session.setAttribute("errorMessage", "Unable to update payment status. Access denied or invalid state.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/settlement?tripId=" + tripId);
    }

    private int parsePositiveInt(String value) {
        try {
            int number = Integer.parseInt(value);
            return number > 0 ? number : -1;
        } catch (Exception e) {
            return -1;
        }
    }
}
