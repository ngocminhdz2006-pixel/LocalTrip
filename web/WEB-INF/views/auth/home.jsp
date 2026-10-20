<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User,utils.HtmlUtil" %>
<%
    request.setAttribute("pageTitle", "Home");
    User currentUser = (User) session.getAttribute("user");
    String role = currentUser == null ? "" : currentUser.getRole();
%>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="app-card text-center">
            <h2>Welcome to LocalTrip</h2>
            <p class="mt-3 mb-1">Hello, <strong><%= HtmlUtil.escape(currentUser == null ? "" : currentUser.getFullName()) %></strong></p>
            <p>Email: <%= HtmlUtil.escape(currentUser == null ? "" : currentUser.getEmail()) %></p>
            <div class="alert alert-info mt-4"><strong>Current Role:</strong> <%= HtmlUtil.escape(role) %></div>
            <% if ("ADMIN".equals(role)) { %><p>This is the test area for ADMIN accounts.</p>
            <% } else if ("USER".equals(role)) { %><p>This is the test area for USER accounts.</p>
            <% } %>
            <p class="mt-3 text-muted">
                Trip owner status is identified by <code>owner_id</code> and members are managed per trip.
            </p>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-brand mt-3">Log Out</a>
        </div>
    </div>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
