<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<<<<<<< HEAD
<%@ page import="model.User,utils.HtmlUtil" %>
<% request.setAttribute("pageTitle", "Không đủ quyền"); %>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<div class="row justify-content-center"><div class="col-md-6"><div class="app-card text-center">
    <div class="display-5 mb-2">🔒</div>
    <h4 class="mb-2">Bạn không có quyền truy cập</h4>
    <p class="text-muted">Bạn không có quyền truy cập URL này với role hiện tại.</p>
    <a href="<%= request.getContextPath() %>/login" class="btn btn-brand">Về trang đăng nhập</a>
</div></div></div>
=======
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Không đủ quyền" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="app-card text-center">
            <div class="display-5 mb-2">🔒</div>
            <h4 class="mb-2">Bạn không có quyền truy cập</h4>
            <p class="text-muted">
                <c:choose>
                    <c:when test="${not empty deniedMessage}">${deniedMessage}</c:when>
                    <c:otherwise>
                        Chỉ Trip Owner mới thực hiện được thao tác này, hoặc bạn không phải thành viên của Trip.
                    </c:otherwise>
                </c:choose>
            </p>
            <div class="d-flex justify-content-center gap-2 mt-3">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-brand">Về Dashboard</a>
                        <a href="${pageContext.request.contextPath}/trips" class="btn btn-outline-secondary">My Trips</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-brand">Đăng nhập</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

>>>>>>> 1f8cf38 (Update UI)
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
