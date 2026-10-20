<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User,utils.HtmlUtil" %>
<% request.setAttribute("pageTitle", "Access Denied"); %>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<div class="row justify-content-center"><div class="col-md-6"><div class="app-card text-center">
    <div class="display-5 mb-2">🔒</div>
    <h4 class="mb-2">Access Denied</h4>
    <p class="text-muted">You do not have permission to access this page with your current role.</p>
    <a href="<%= request.getContextPath() %>/login" class="btn btn-brand">Return to Login</a>
</div></div></div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
