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

    request.setAttribute("pageTitle", "Admin Dashboard");
    request.setAttribute("tripRedesign", Boolean.TRUE);
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · ADMIN WORKSPACE
            </div>

            <h1 class="mb-3">System Overview</h1>

            <p class="text-white mb-0">
                Welcome back,
                <strong><%= HtmlUtil.escape(currentUser.getFullName()) %></strong>.
                <br>
                Manage data, curate itineraries, and monitor LocalTrip system operations.
            </p>
        </div>

        <a class="rd-back"
           href="<%= request.getContextPath() %>/admin/audit-logs">
            Admin Audit Logs →
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
                Total Users
            </div>
            <strong class="h2 d-block mb-0">
                <%= userCount == null ? 0 : userCount %>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Active Users
            </div>
            <strong class="h2 d-block mb-0">
                <%= activeUserCount == null ? 0 : activeUserCount %>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Total Trips
            </div>
            <strong class="h2 d-block mb-0">
                <%= tripCount == null ? 0 : tripCount %>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-6">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Active Places
            </div>
            <strong class="h2 d-block mb-0">
                <%= placeCount == null ? 0 : placeCount %>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-6">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Place Categories
            </div>
            <strong class="h2 d-block mb-0">
                <%= categoryCount == null ? 0 : categoryCount %>
            </strong>
        </section>
    </div>
</div>

<section class="rd-card">
    <h2 class="h4 mb-2">Administrative Modules</h2>

    <p class="text-muted mb-4">
        Manage users, places, categories, combos, and system audit history.
    </p>

    <div class="row g-3">
        <div class="col-12 col-md-6 col-lg-4">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/users">
                User Management
            </a>
        </div>

        <div class="col-12 col-md-6 col-lg-4">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/places">
                Place Management
            </a>
        </div>

        <div class="col-12 col-md-6 col-lg-4">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/categories">
                Category Management
            </a>
        </div>

        <div class="col-12 col-md-6">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/audit-logs">
                Admin Audit Logs
            </a>
        </div>

        <div class="col-12 col-md-6">
            <a class="btn btn-outline-secondary w-100 py-3"
               href="<%= request.getContextPath() %>/admin/login-logs">
                Login History
            </a>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>  