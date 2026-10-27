package controller.admin;

import dao.AdminAuditLogDAO;
import dao.ScenarioLabDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.SimulatedBatchInfo;
import model.SimulatedScenarioResult;
import model.User;
import utils.AppClock;
import utils.ScenarioLabConfig;

@WebServlet("/admin/lab")
public class AdminScenarioLabServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/scenario-lab.jsp";
    private final ScenarioLabDAO scenarioLabDAO = new ScenarioLabDAO();
    private final AdminAuditLogDAO auditLogDAO = new AdminAuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // HARD REQUIREMENT 1: 404 when disabled
        if (!ScenarioLabConfig.isScenarioLabEnabled()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<SimulatedBatchInfo> batches = scenarioLabDAO.listBatches();
        request.setAttribute("batches", batches);

        // Simulated date/time info
        request.setAttribute("simToday", AppClock.today());
        request.setAttribute("simNow", AppClock.now());
        request.setAttribute("simOffset", AppClock.getOffset());
        request.setAttribute("isOffsetActive", AppClock.getOffset() != null && !AppClock.getOffset().isZero());

        // Check if there was a flash result from scenario loading
        if (session != null && session.getAttribute("scenarioResult") != null) {
            request.setAttribute("scenarioResult", session.getAttribute("scenarioResult"));
            session.removeAttribute("scenarioResult");
        }

        request.setAttribute("pageTitle", "Scenario Lab");
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // HARD REQUIREMENT 1: 404 when disabled
        if (!ScenarioLabConfig.isScenarioLabEnabled()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "load_scenario": {
                    String scenario = request.getParameter("scenario");
                    int memberCount = 3;
                    try {
                        memberCount = Integer.parseInt(request.getParameter("memberCount"));
                    } catch (NumberFormatException ignored) {}

                    SimulatedScenarioResult res = scenarioLabDAO.createScenario(scenario, memberCount, user.getUserId());
                    if (session != null) {
                        session.setAttribute("scenarioResult", res);
                        session.setAttribute("successMessage", "Successfully generated simulated scenario " + res.getScenarioCode() + "!");
                    }
                    break;
                }

                case "purge_batch": {
                    String batchId = request.getParameter("batchId");
                    int deleted = scenarioLabDAO.purgeBatch(batchId, user.getUserId());
                    if (session != null) {
                        session.setAttribute("successMessage", "Successfully purged batch " + batchId + " (" + deleted + " trip(s) removed).");
                    }
                    break;
                }

                case "purge_all": {
                    int total = scenarioLabDAO.purgeAll(user.getUserId());
                    if (session != null) {
                        session.setAttribute("successMessage", "Purged all simulated data (" + total + " trip(s) removed).");
                    }
                    break;
                }

                default:
                    if (session != null) {
                        session.setAttribute("errorMessage", "Unknown scenario lab action: " + action);
                    }
                    break;
            }
        } catch (Exception e) {
            if (session != null) {
                session.setAttribute("errorMessage", "Error: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/lab");
    }
}
