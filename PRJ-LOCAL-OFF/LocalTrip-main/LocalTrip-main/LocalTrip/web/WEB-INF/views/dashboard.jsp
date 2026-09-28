<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Dashboard" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="mb-4">
    <h3 class="mb-1">Xin chào, ${sessionScope.user.fullName} 👋</h3>
    <p class="text-muted mb-0">Đây là tổng quan các chuyến đi của bạn.</p>
</div>

<div class="row mb-2">
    <div class="col-md-4">
        <div class="app-card text-center">
            <div class="fs-2 fw-bold">${tripCount}</div>
            <div class="text-muted">Tổng số Trip</div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="app-card text-center">
            <div class="fs-2 fw-bold">${ownerCount}</div>
            <div class="text-muted">Trip bạn làm Owner</div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="app-card text-center">
            <div class="fs-2 fw-bold">${memberCount}</div>
            <div class="text-muted">Trip bạn là Member</div>
        </div>
    </div>
</div>

<div class="app-card">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="mb-0">Trip gần đây</h5>
        <a href="${pageContext.request.contextPath}/trip/create" class="btn btn-brand btn-sm">+ Tạo Trip mới</a>
    </div>

    <c:choose>
        <c:when test="${empty trips}">
            <div class="empty-state">
                <div class="empty-icon">🧳</div>
                <p class="mb-0">Bạn chưa có chuyến đi nào. Hãy tạo Trip đầu tiên!</p>
            </div>
        </c:when>
        <c:otherwise>
            <ul class="list-group list-group-flush">
                <c:forEach var="trip" items="${trips}">
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div>
                            <a href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}"
                               class="fw-semibold text-decoration-none">${trip.name}</a>
                            <div class="text-muted small">
                                📅 ${trip.startDate} → ${trip.endDate} &nbsp;|&nbsp;
                                💰 <fmt:formatNumber value="${trip.budget}" type="number"/> đ
                            </div>
                        </div>
                        <c:choose>
                            <c:when test="${trip.role == 'OWNER'}">
                                <span class="badge badge-owner">OWNER</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-member">MEMBER</span>
                            </c:otherwise>
                        </c:choose>
                    </li>
                </c:forEach>
            </ul>
            <div class="mt-3">
                <a href="${pageContext.request.contextPath}/trips" class="btn btn-outline-secondary btn-sm">Xem tất cả Trip</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<div class="app-card">
    <h5 class="mb-3">Lối tắt</h5>
    <a href="${pageContext.request.contextPath}/places" class="btn btn-outline-secondary btn-sm me-2">Khám phá địa điểm</a>
    <a href="${pageContext.request.contextPath}/trips" class="btn btn-outline-secondary btn-sm">My Trips</a>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
