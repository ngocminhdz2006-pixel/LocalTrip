<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Có lỗi xảy ra" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="app-card text-center">
            <div class="display-5 mb-2">⚠️</div>
            <h4 class="mb-2">
                <c:choose>
                    <c:when test="${requestScope['javax.servlet.error.status_code'] == 404}">Không tìm thấy trang</c:when>
                    <c:otherwise>Đã có lỗi xảy ra</c:otherwise>
                </c:choose>
            </h4>
            <p class="text-muted">
                <c:choose>
                    <c:when test="${not empty errorDetail}">${errorDetail}</c:when>
                    <c:when test="${requestScope['javax.servlet.error.status_code'] == 404}">
                        Trang hoặc dữ liệu bạn yêu cầu không tồn tại.
                    </c:when>
                    <c:otherwise>Hệ thống gặp sự cố, vui lòng thử lại sau.</c:otherwise>
                </c:choose>
            </p>
            <div class="d-flex justify-content-center gap-2 mt-3">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-brand">Về Dashboard</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-brand">Về trang đăng nhập</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
