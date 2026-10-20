package controller.admin;

import dao.CategoryDAO;
import dao.ComboTemplateDAO;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Category;
import model.ComboTemplate;
import model.User;

@WebServlet({
    "/admin/combos",
    "/admin/combos/detail"
})
public class AdminComboServlet extends HttpServlet {

    private final ComboTemplateDAO comboDAO =
            new ComboTemplateDAO();

    private final CategoryDAO categoryDAO =
            new CategoryDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireAdmin(request, response)) {
            return;
        }

        try {
            if ("/admin/combos/detail".equals(
                    request.getServletPath())) {
                showDetail(request, response);
                return;
            }

            request.setAttribute("pageTitle", "Quản lý combo");
            request.setAttribute(
                    "combos", comboDAO.findAllForAdmin());

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/combo-list.jsp")
                    .forward(request, response);

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Không thể tải dữ liệu combo.", e);
        }
    }

    private void showDetail(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int comboId;

        try {
            comboId = Integer.parseInt(
                    request.getParameter("id"));

            if (comboId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400, "Mã combo không hợp lệ.");
            return;
        }

        ComboTemplate combo = comboDAO.findById(comboId);

        if (combo == null) {
            response.sendError(404, "Không tìm thấy combo.");
            return;
        }

        Map<Integer, String> categoryNames = new HashMap<>();

        for (Category category : categoryDAO.findAll()) {
            categoryNames.put(
                    category.getId(), category.getName());
        }

        request.setAttribute("pageTitle", "Chi tiết combo");
        request.setAttribute("selectedCombo", combo);
        request.setAttribute("categoryNames", categoryNames);

        request.getRequestDispatcher(
                "/WEB-INF/views/admin/combo-list.jsp")
                .forward(request, response);
    }

    private boolean requireAdmin(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);

        User user = session == null ? null
                : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return false;
        }

        if (!"ADMIN".equals(user.getRole())) {
            response.sendError(403);
            return false;
        }

        return true;
    }
}