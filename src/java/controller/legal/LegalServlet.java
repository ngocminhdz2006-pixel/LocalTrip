package controller.legal;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "LegalServlet", urlPatterns = {"/privacy", "/terms"})
public class LegalServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        if ("/terms".equals(servletPath)) {
            request.setAttribute("pageTitle", "Terms of Service");
            request.getRequestDispatcher("/WEB-INF/views/legal/terms.jsp").forward(request, response);
        } else {
            request.setAttribute("pageTitle", "Privacy Policy");
            request.getRequestDispatcher("/WEB-INF/views/legal/privacy.jsp").forward(request, response);
        }
    }
}
