package filter;

import controller.auth.RememberMeUtil;
import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;
import dao.UserDAO;

/**
 * Authentication + role authorization + remember-me restoration.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    private final UserDAO userDAO = new UserDAO();
    private static final long USER_VERIFY_TTL_MS = 60000L; // 60 seconds session cache

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("X-Content-Type-Options", "nosniff");
        resp.setHeader("X-Frame-Options", "SAMEORIGIN");
        resp.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        String contextPath = req.getContextPath();
        String uri = req.getRequestURI();
        String path = uri.substring(contextPath.length());

        // 1. Fast path for public and static resources: skip remember-me check completely
        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Never auto-login while explicitly logging out.
        if (!"/logout".equals(path)) {
            restoreRememberedUser(req);
        }

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");

        if (user == null) {
            // Only create a session if it's a GET page request that needs a redirect target
            if ("GET".equalsIgnoreCase(req.getMethod())) {
                HttpSession newSession = req.getSession(true);
                newSession.setAttribute("authMessage", "Please sign in to continue.");
                String targetUrl = req.getRequestURI();
                String queryString = req.getQueryString();
                if (queryString != null && !queryString.trim().isEmpty()) {
                    targetUrl += "?" + queryString;
                }
                newSession.setAttribute("redirectAfterLogin", targetUrl);
            }

            resp.sendRedirect(contextPath + "/login");
            return;
        }

        /*
         * Refresh user from database with 60-second session cache
         * to verify active status and role changes without hammering DB on every click.
         */
        try {
            Long lastVerifiedAt = (Long) session.getAttribute("userLastVerifiedAt");
            long now = System.currentTimeMillis();

            if (lastVerifiedAt == null || (now - lastVerifiedAt > USER_VERIFY_TTL_MS)) {
                User freshUser = userDAO.findById(user.getUserId());

                if (freshUser == null || !freshUser.isActive()) {
                    try {
                        RememberMeUtil.revoke(req, resp);
                    } catch (RuntimeException ignored) {
                        // Continue invalidation
                    }

                    session.invalidate();

                    HttpSession newSession = req.getSession(true);
                    newSession.setAttribute(
                            "authMessage",
                            "Your account has been deactivated or no longer exists."
                    );

                    resp.sendRedirect(contextPath + "/login");
                    return;
                }

                // Never store password hash in session
                freshUser.setPasswordHash(null);
                session.setAttribute("user", freshUser);
                session.setAttribute("userLastVerifiedAt", now);
                user = freshUser;
            }

            if (session.getAttribute("travelCsrf") == null) {
                session.setAttribute("travelCsrf", java.util.UUID.randomUUID().toString());
            }

        } catch (RuntimeException e) {
            resp.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE, "Unable to verify authentication status.");
            return;
        }

        boolean adminPath = "/admin".equals(path) || path.startsWith("/admin/");
        boolean userPath = "/user".equals(path) || path.startsWith("/user/");

        if (adminPath && !"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Administrator privilege required.");
            return;
        }

        if (userPath && !"USER".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: User privilege required.");
            return;
        }

        // Enforce CSRF protection for authenticated POST requests
        if ("POST".equalsIgnoreCase(req.getMethod())) {
            String contentType = req.getContentType();
            boolean isMultipart = contentType != null && contentType.toLowerCase().startsWith("multipart/");

            // Multipart requests validate CSRF inside their @MultipartConfig servlets
            if (!isMultipart) {
                String paramToken = req.getParameter("csrfToken");
                Object sessionToken = session.getAttribute("travelCsrf");

                boolean valid = (sessionToken instanceof String && ((String) sessionToken).equals(paramToken))
                        || (paramToken != null && paramToken.equals(session.getAttribute("activityStatusToken")))
                        || (req.getParameter("statusToken") != null && req.getParameter("statusToken").equals(session.getAttribute("tripStatusToken")))
                        || (req.getParameter("deleteToken") != null && req.getParameter("deleteToken").equals(session.getAttribute("tripDeleteToken")))
                        || (req.getParameter("token") != null && req.getParameter("token").equals(session.getAttribute("autoItineraryToken")));

                if (!valid) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF security token.");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    private void restoreRememberedUser(HttpServletRequest request) {
        HttpSession existing = request.getSession(false);
        if (existing != null && existing.getAttribute("user") != null) {
            return;
        }

        try {
            User user = RememberMeUtil.restore(request);
            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
            }

        } catch (RuntimeException ignored) {
            // If the remember-me table is not migrated yet, normal login still works.
        }
    }

    private boolean isPublic(String path) {
        if (path == null || path.isEmpty() || "/".equals(path)) {
            return true;
        }
        if ("/index.jsp".equals(path)) {
            return true;
        }
        if ("/login".equals(path) || "/register".equals(path) || "/logout".equals(path)
                || "/forgot-password".equals(path) || "/reset-password".equals(path)) {
            return true;
        }
        // Public legal and invite routing
        if ("/privacy".equals(path) || "/terms".equals(path) || "/trip/join".equals(path)) {
            return true;
        }
        if ("/manifest.json".equals(path) || "/sw.js".equals(path) || "/offline.html".equals(path) || "/favicon.ico".equals(path)) {
            return true;
        }
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/") || path.startsWith("/assets/")) {
            return true;
        }
        if (path.startsWith("/WEB-INF/")) {
            return true;
        }
        return false;
    }
}
