package controller.auth;

import dao.RememberMeDAO;
import model.User;
import utils.TokenUtil;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.concurrent.TimeUnit;

/** Helper for issuing and clearing the remember-me cookie. */
public final class RememberMeUtil {
    public static final String COOKIE_NAME = "LOCALTRIP_REMEMBER";
    private static final int MAX_AGE_SECONDS = (int) TimeUnit.DAYS.toSeconds(30);
    private static final RememberMeDAO DAO = new RememberMeDAO();

    private RememberMeUtil() { }

    public static boolean isSecure(HttpServletRequest request) {
        if (request == null) {
            return false;
        }
        if (request.isSecure()) {
            return true;
        }
        // Only honor X-Forwarded-Proto from a trusted local reverse proxy (loopback)
        String remoteAddr = request.getRemoteAddr();
        if ("127.0.0.1".equals(remoteAddr) || "0:0:0:0:0:0:0:1".equals(remoteAddr) || "::1".equals(remoteAddr)) {
            String proto = request.getHeader("X-Forwarded-Proto");
            if ("https".equalsIgnoreCase(proto)) {
                return true;
            }
        }
        return false;
    }

    public static void create(HttpServletRequest request, HttpServletResponse response, User user) {
        String rawToken = TokenUtil.generateToken();
        // SECURITY: Persistent login token expiry must track real wall clock time
        // SECURITY: Persistent login token expiry must track real wall clock time
        long expires = System.currentTimeMillis() + TimeUnit.DAYS.toMillis(30);
        DAO.createToken(user.getUserId(), TokenUtil.sha256(rawToken), expires);

        boolean secure = isSecure(request);
        String path = contextCookiePath(request);

        StringBuilder cookieHeader = new StringBuilder();
        cookieHeader.append(COOKIE_NAME).append("=").append(rawToken);
        cookieHeader.append("; Path=").append(path);
        cookieHeader.append("; Max-Age=").append(MAX_AGE_SECONDS);
        cookieHeader.append("; HttpOnly");
        cookieHeader.append("; SameSite=Lax");
        if (secure) {
            cookieHeader.append("; Secure");
        }
        response.addHeader("Set-Cookie", cookieHeader.toString());
    }

    public static User restore(HttpServletRequest request) {
        Cookie cookie = findCookie(request);
        if (cookie == null || cookie.getValue() == null || cookie.getValue().isEmpty()) return null;
        return DAO.findUserByTokenHash(TokenUtil.sha256(cookie.getValue()));
    }

    public static void revoke(HttpServletRequest request, HttpServletResponse response) {
        Cookie cookie = findCookie(request);
        if (cookie != null && cookie.getValue() != null && !cookie.getValue().isEmpty()) {
            DAO.deleteToken(TokenUtil.sha256(cookie.getValue()));
        }
        clearCookie(request, response);
    }

    private static Cookie findCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie cookie : cookies) {
            if (COOKIE_NAME.equals(cookie.getName())) return cookie;
        }
        return null;
    }

    private static void clearCookie(HttpServletRequest request, HttpServletResponse response) {
        boolean secure = isSecure(request);
        String path = contextCookiePath(request);

        StringBuilder cookieHeader = new StringBuilder();
        cookieHeader.append(COOKIE_NAME).append("=");
        cookieHeader.append("; Path=").append(path);
        cookieHeader.append("; Max-Age=0");
        cookieHeader.append("; Expires=Thu, 01 Jan 1970 00:00:00 GMT");
        cookieHeader.append("; HttpOnly");
        cookieHeader.append("; SameSite=Lax");
        if (secure) {
            cookieHeader.append("; Secure");
        }
        response.addHeader("Set-Cookie", cookieHeader.toString());
    }

    private static String contextCookiePath(HttpServletRequest request) {
        String context = request.getContextPath();
        return context == null || context.isEmpty() ? "/" : context;
    }
}
