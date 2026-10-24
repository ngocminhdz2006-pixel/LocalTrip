package controller.expense;

import dao.ExpenseDAO;
import dao.GroupFundDAO;
import dao.SettlementDAO;
import dao.TripDAO;
import dao.TripMemberDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Expense;
import model.GroupFundSummary;
import model.SettlementBalance;
import model.Trip;
import model.User;

@WebServlet(name = "ExpenseServlet", urlPatterns = {
    "/expenses",
    "/expenses/create",
    "/expenses/delete",
    "/expenses/edit"
})
public class ExpenseServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final TripMemberDAO tripMemberDAO = new TripMemberDAO();
    private final ExpenseDAO expenseDAO = new ExpenseDAO();
    private final GroupFundDAO groupFundDAO = new GroupFundDAO();
    private final SettlementDAO settlementDAO = new SettlementDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User currentUser = getCurrentUser(request, response);

        if (currentUser == null) {
            return;
        }

        try {
            int tripId = parsePositiveInt(
                    request.getParameter("tripId")
            );

            Trip trip = tripDAO.findByIdForUser(
                    tripId,
                    currentUser.getUserId()
            );

            if (trip == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Trip not found or access denied."
                );
                return;
            }

            String path = request.getServletPath();
            if (("/expenses/create".equals(path)
                    || "/expenses/edit".equals(path))
                    && !"PLANNING".equalsIgnoreCase(trip.getStatus())
                    && !"ONGOING".equalsIgnoreCase(trip.getStatus())) {

                request.getSession().setAttribute(
                        "errorMessage",
                        "Cannot modify expenses for a completed or cancelled trip."
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/expenses?tripId=" + tripId
                );
                return;
            }

            if ("/expenses/create".equals(path)) {
                showCreateForm(request, response, trip);
                return;
            }

            if ("/expenses/edit".equals(path)) {
                showEditForm(
                        request,
                        response,
                        currentUser,
                        trip
                );
                return;
            }

            request.setAttribute("trip", trip);
            request.setAttribute(
                    "expenses",
                    expenseDAO.findByTrip(tripId)
            );

            // Summary metrics: Fund balance & Member share balances
            GroupFundSummary fundSummary = groupFundDAO.findSummary(tripId);
            request.setAttribute("fundSummary", fundSummary);

            List<SettlementBalance> memberBalances = settlementDAO.findBalances(tripId);
            request.setAttribute("memberBalances", memberBalances);

            request.getRequestDispatcher(
                    "/WEB-INF/views/expense/expense-list.jsp"
            ).forward(request, response);

        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    e.getMessage()
            );
        } catch (RuntimeException e) {
            throw new ServletException(
                    "Unable to load expense data.",
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

        User currentUser = getCurrentUser(
                request,
                response
        );

        if (currentUser == null) {
            return;
        }

        int tripId;

        try {
            tripId = parsePositiveInt(
                    request.getParameter("tripId")
            );

        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    e.getMessage()
            );
            return;
        }

        try {
            Trip trip = tripDAO.findByIdForUser(
                    tripId,
                    currentUser.getUserId()
            );

            if (trip == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Trip not found or access denied."
                );
                return;
            }

            if ("/expenses/delete".equals(
                    request.getServletPath()
            )) {
                if (!"PLANNING".equalsIgnoreCase(trip.getStatus())
                        && !"ONGOING".equalsIgnoreCase(trip.getStatus())) {

                    request.getSession().setAttribute(
                            "errorMessage",
                            "Cannot modify expenses for a completed or cancelled trip."
                    );

                    response.sendRedirect(
                            request.getContextPath()
                            + "/expenses?tripId=" + tripId
                    );
                    return;
                }

                deleteExpense(
                        request,
                        response,
                        currentUser,
                        trip
                );
                return;
            }

            createExpense(
                    request,
                    response,
                    currentUser,
                    trip
            );

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Unable to save expense.",
                    e
            );
        }
    }

    private void showCreateForm(
            HttpServletRequest request,
            HttpServletResponse response,
            Trip trip
    ) throws ServletException, IOException {

        request.setAttribute("trip", trip);
        request.setAttribute(
                "members",
                tripMemberDAO.findByTrip(
                        trip.getTripId()
                )
        );

        request.getRequestDispatcher(
                "/WEB-INF/views/expense/expense-form.jsp"
            ).forward(request, response);
    }

    private void showEditForm(
            HttpServletRequest request,
            HttpServletResponse response,
            User currentUser,
            Trip trip
    ) throws ServletException, IOException {

        int expenseId;

        try {
            expenseId = parsePositiveInt(
                    request.getParameter("expenseId")
            );
        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid expense ID."
            );
            return;
        }

        Expense expense = expenseDAO.findById(
                trip.getTripId(),
                expenseId
        );

        if (expense == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Expense not found."
            );
            return;
        }

        boolean isOwner = "OWNER".equalsIgnoreCase(
                trip.getRole()
        );

        boolean isCreator = expense.getCreatedBy()
                == currentUser.getUserId();

        if (!isOwner && !isCreator) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to edit this expense."
            );
            return;
        }

        request.setAttribute("trip", trip);
        request.setAttribute("expense", expense);
        request.setAttribute(
                "participantIds",
                expenseDAO.findParticipantIds(
                        trip.getTripId(),
                        expenseId
                )
        );
        request.setAttribute(
                "members",
                tripMemberDAO.findByTrip(trip.getTripId())
        );

        request.getRequestDispatcher(
                "/WEB-INF/views/expense/expense-form.jsp"
        ).forward(request, response);
    }

    private void createExpense(
            HttpServletRequest request,
            HttpServletResponse response,
            User currentUser,
            Trip trip
    ) throws ServletException, IOException {

        String description
                = request.getParameter("description");

        if (description != null) {
            description = description.trim();
        }

        if (description == null
                || description.isEmpty()) {

            forwardFormError(
                    request,
                    response,
                    trip,
                    "Please enter an expense description."
            );
            return;
        }

        if (description.length() > 200) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    "Description must not exceed 200 characters."
            );
            return;
        }

        int payerId;
        BigDecimal amount;

        try {
            payerId = parsePositiveInt(
                    request.getParameter("payerId")
            );

            amount = new BigDecimal(
                    request.getParameter("amount")
            ).setScale(
                    2,
                    RoundingMode.HALF_UP
            );

        } catch (Exception e) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    "Invalid payer or amount."
            );
            return;
        }

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    "Amount must be greater than 0."
            );
            return;
        }

        BigDecimal maximumAmount
                = new BigDecimal("9999999999999999.99");

        if (amount.compareTo(maximumAmount) > 0) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    "Amount is too large."
            );
            return;
        }

        if (!tripMemberDAO.exists(
                trip.getTripId(),
                payerId
        )) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    "Payer does not belong to this trip."
            );
            return;
        }

        String[] participantValues
                = request.getParameterValues(
                        "participantIds"
                );

        if (participantValues == null
                || participantValues.length == 0) {

            forwardFormError(
                    request,
                    response,
                    trip,
                    "Please select at least one participant to split this expense."
            );
            return;
        }

        Set<Integer> participantSet
                = new LinkedHashSet<>();

        try {
            for (String value : participantValues) {
                int participantId
                        = parsePositiveInt(value);

                if (!tripMemberDAO.exists(
                        trip.getTripId(),
                        participantId
                )) {
                    forwardFormError(
                            request,
                            response,
                            trip,
                            "Selected participant does not belong to this trip."
                    );
                    return;
                }

                participantSet.add(participantId);
            }

        } catch (IllegalArgumentException e) {
            forwardFormError(
                    request,
                    response,
                    trip,
                    "Invalid participant selection."
            );
            return;
        }

        boolean fromGroupFund
                = "true".equalsIgnoreCase(
                        request.getParameter(
                                "fromGroupFund"
                        )
                );

        Expense expense = new Expense();

        expense.setTripId(trip.getTripId());
        expense.setPayerId(payerId);
        expense.setCreatedBy(
                currentUser.getUserId()
        );
        expense.setDescription(description);
        expense.setAmount(amount);
        expense.setFromGroupFund(
                fromGroupFund
        );

        List<Integer> participantIds
                = new ArrayList<>(participantSet);

        String editingExpenseId
                = request.getParameter("expenseId");

        if (editingExpenseId != null
                && !editingExpenseId.trim().isEmpty()) {

            int expenseId;

            try {
                expenseId = parsePositiveInt(editingExpenseId);
            } catch (IllegalArgumentException e) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid expense ID."
                );
                return;
            }

            expense.setExpenseId(expenseId);

            boolean updated = expenseDAO.updateAuthorized(
                    expense,
                    participantIds,
                    currentUser.getUserId()
            );

            if (!updated) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You do not have permission to edit this expense."
                );
                return;
            }

        } else {
            int newExpenseId = expenseDAO.create(
                    expense,
                    participantIds
            );

            if (newExpenseId <= 0) {
                forwardFormError(
                        request,
                        response,
                        trip,
                        "Unable to save expense."
                );
                return;
            }
        }

        response.sendRedirect(
                request.getContextPath()
                + "/expenses?tripId="
                + trip.getTripId()
        );
    }

    private void deleteExpense(
            HttpServletRequest request,
            HttpServletResponse response,
            User currentUser,
            Trip trip
    ) throws IOException {

        int expenseId;

        try {
            expenseId = parsePositiveInt(
                    request.getParameter("expenseId")
            );

        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid expense ID."
            );
            return;
        }

        boolean deleted = expenseDAO.deleteAuthorized(
                expenseId,
                trip.getTripId(),
                currentUser.getUserId()
        );

        if (!deleted) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to delete this expense."
            );
            return;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/expenses?tripId="
                + trip.getTripId()
        );
    }

    private void forwardFormError(
            HttpServletRequest request,
            HttpServletResponse response,
            Trip trip,
            String error
    ) throws ServletException, IOException {

        request.setAttribute("trip", trip);
        request.setAttribute("error", error);

        request.setAttribute(
                "members",
                tripMemberDAO.findByTrip(
                        trip.getTripId()
                )
        );

        request.getRequestDispatcher(
                "/WEB-INF/views/expense/expense-form.jsp"
        ).forward(request, response);
    }

    private User getCurrentUser(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        HttpSession session
                = request.getSession(false);

        if (session == null
                || session.getAttribute("user") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return null;
        }

        User currentUser
                = (User) session.getAttribute("user");

        if (!"USER".equalsIgnoreCase(
                currentUser.getRole()
        )) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to access this feature."
            );

            return null;
        }

        return currentUser;
    }

    private int parsePositiveInt(String value) {
        try {
            int number = Integer.parseInt(value);

            if (number <= 0) {
                throw new NumberFormatException();
            }

            return number;

        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Invalid ID."
            );
        }
    }
}
