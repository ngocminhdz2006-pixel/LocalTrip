<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" isErrorPage="true" %>
<%@ page import="utils.HtmlUtil" %>

<%
    request.setAttribute("pageTitle", "Error");
    request.setAttribute("tripRedesign", Boolean.TRUE);

    Object statusObject =
        request.getAttribute("javax.servlet.error.status_code");

    String status = statusObject == null
        ? "" : String.valueOf(statusObject);

    Object detail = request.getAttribute("errorDetail");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="row justify-content-center py-4">
    <div class="col-12 col-md-8 col-lg-6">
        <section class="rd-card text-center">
            <span class="rd-count mb-4">
                LOCALTRIP
            </span>

            <h1 class="h3 mb-3">
                <%= "404".equals(status)
                    ? "Page Not Found"
                    : "Something went wrong" %>
            </h1>

            <p class="text-muted mb-4"
               style="overflow-wrap:anywhere;">
                <% if (detail != null) { %>
                    <%= HtmlUtil.escape(String.valueOf(detail)) %>
                <% } else if ("404".equals(status)) { %>
                    The page or resource you requested could not be found.
                <% } else { %>
                    The system encountered an error. Please try again later.
                <% } %>
            </p>

            <a href="<%= request.getContextPath() %>/login"
               class="btn btn-primary px-4">
                Back to Login
            </a>
        </section>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
