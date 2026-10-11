<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="utils.HtmlUtil" %>

<%
    model.User currentUser =
        (model.User) session.getAttribute("user");

    Integer userCount =
        (Integer) request.getAttribute("userCount");

    Integer activeUserCount =
        (Integer) request.getAttribute("activeUserCount");

    Integer tripCount =
        (Integer) request.getAttribute("tripCount");

    Integer placeCount =
        (Integer) request.getAttribute("placeCount");

    Integer categoryCount =
        (Integer) request.getAttribute("categoryCount");

    String dashboardError =
        (String) request.getAttribute("dashboardError");

    request.setAttribute("pageTitle", "Tổng quan quản trị");
    request.setAttribute("tripRedesign", Boolean.TRUE);
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · KHÔNG GIAN QUẢN TRỊ
            </div>

            <h1 class="mb-3">Tổng quan hệ thống</h1>

            <p class="text-white mb-0">
                Xin chào,
                <strong><%= HtmlUtil.escape(currentUser.getFullName()) %></strong>.
                <br>
                Quản lý dữ liệu và theo dõi hoạt động của LocalTrip.
            </p>
        </div>

        <a class="rd-back"
           href="<%= request.getContextPath() %>/admin/audit-logs">
            Nhật ký quản trị →
        </a>
    </div>
</section>

<% if (dashboardError != null) { %>
    <div class="alert alert-warning" role="alert">
        <%= HtmlUtil.escape(dashboardError) %>
    </div>
<% } %>

<div class="row g-3 mb-4">
    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Tổng người dùng
            </div>
            <strong class="h2 d-block mb-0">
                <%= userCount == null ? 0 : userCount %>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Người dùng đang hoạt động
            </div>
            <strong class="h2 d-block mb-0">
                <%= activeUserCount == null ? 0 : activeUserCount %>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Tổng chuyến đi
            </div>
            <strong class="h2 d-block mb-0">
                <%= tripCount == null ? 0 : tripCount %>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-6">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Địa điểm đang hoạt động
            </div>
            <strong class="h2 d-block mb-0">
                <%= placeCount == null ? 0 : placeCount %>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-6">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Danh mục địa điểm
            </div>
            <strong class="h2 d-block mb-0">
                <%= categoryCount == null ? 0 : categoryCount %>
            </strong>
        </section>
    </div>
</div>

<section class="rd-card">
    <h2 class="h4 mb-2">Chức năng quản trị</h2>

    <p class="text-muted mb-4">
        Quản lý người dùng, địa điểm và danh mục;
        kiểm tra lịch sử hoạt động của hệ thống.
    </p>

    <div class="row g-3">
        <div class="col-12 col-md-6 col-lg-4">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/users">
                Quản lý người dùng
            </a>
        </div>

        <div class="col-12 col-md-6 col-lg-4">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/places">
                Quản lý địa điểm
            </a>
        </div>

        <div class="col-12 col-md-6 col-lg-4">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/categories">
                Quản lý danh mục
            </a>
        </div>

        <div class="col-12 col-md-6">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/audit-logs">
                Nhật ký quản trị
            </a>
        </div>

        <div class="col-12 col-md-6">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/login-logs">
                Lịch sử đăng nhập
            </a>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>  