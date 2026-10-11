<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" isErrorPage="true" %>
<%@ page import="utils.HtmlUtil" %>

<%
    request.setAttribute("pageTitle", "Có lỗi xảy ra");
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
                    ? "Không tìm thấy trang"
                    : "Đã có lỗi xảy ra" %>
            </h1>

            <p class="text-muted mb-4"
               style="overflow-wrap:anywhere;">
                <% if (detail != null) { %>
                    <%= HtmlUtil.escape(String.valueOf(detail)) %>
                <% } else if ("404".equals(status)) { %>
                    Trang hoặc dữ liệu bạn yêu cầu không tồn tại.
                <% } else { %>
                    Hệ thống gặp sự cố, vui lòng thử lại sau.
                <% } %>
            </p>

            <a href="<%= request.getContextPath() %>/login"
               class="btn btn-primary px-4">
                Về trang đăng nhập
            </a>
        </section>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>