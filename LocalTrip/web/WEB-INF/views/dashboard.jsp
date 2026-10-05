<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<<<<<<< HEAD
<%@ page import="java.util.List" %>
<%@ page import="model.Trip" %>
<%@ page import="utils.HtmlUtil" %>
<%
    model.User currentUser = (model.User) session.getAttribute("user");
    Integer tripCount = (Integer) request.getAttribute("tripCount");
    Integer ownerCount = (Integer) request.getAttribute("ownerCount");
    Integer memberCount = (Integer) request.getAttribute("memberCount");
    List<Trip> trips = (List<Trip>) request.getAttribute("trips");
    String dashboardError = (String) request.getAttribute("dashboardError");
%>
<% request.setAttribute("pageTitle", "Tổng quan"); %>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
    <section class="dashboard-hero">
        <div class="hero-copy">
            <span class="eyebrow">LOCALTRIP / SỔ TAY HÀNH TRÌNH</span>
            <h1>Chuyến đi đẹp hơn<br>khi có nhau.</h1>
            <p class="mt-3 mb-0">Xin chào, <strong><%= HtmlUtil.escape(currentUser.getFullName()) %></strong>.<br>Lên kế hoạch, khám phá địa điểm và chia sẻ chi phí cùng nhóm của bạn.</p>
            <div class="hero-actions">
                <a class="btn btn-brand" href="<%= request.getContextPath() %>/trip/create">+ Lên kế hoạch chuyến đi</a>
                <a class="btn btn-outline-secondary" href="<%= request.getContextPath() %>/places">Khám phá địa điểm ↗</a>
            </div>
        </div>
    </section>

    <% if (dashboardError != null) { %>
        <div class="alert alert-warning"><%= HtmlUtil.escape(dashboardError) %></div>
    <% } %>

    <div class="row g-4 mb-4">
        <div class="col-md-4"><div class="card shadow-sm h-100"><div class="card-body"><div class="text-muted">Tổng số Trip</div><div class="display-6 fw-bold"><%= tripCount == null ? 0 : tripCount %></div></div></div></div>
        <div class="col-md-4"><div class="card shadow-sm h-100"><div class="card-body"><div class="text-muted">Trip bạn làm Owner</div><div class="display-6 fw-bold"><%= ownerCount == null ? 0 : ownerCount %></div></div></div></div>
        <div class="col-md-4"><div class="card shadow-sm h-100"><div class="card-body"><div class="text-muted">Trip bạn là Member</div><div class="display-6 fw-bold"><%= memberCount == null ? 0 : memberCount %></div></div></div></div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0">Trip gần đây</h5>
                <a class="btn btn-primary btn-sm" href="<%= request.getContextPath() %>/trip/create">+ Tạo Trip mới</a>
            </div>
            <% if (trips == null || trips.isEmpty()) { %>
                <div class="text-center py-5 text-muted">
                    <div class="fs-1">🧳</div>
                    <p class="mb-0">Bạn chưa có chuyến đi nào.</p>
                </div>
            <% } else { %>
                <div class="list-group list-group-flush">
                <% for (Trip trip : trips) {
                       boolean owner = trip.getOwnerId() == currentUser.getUserId(); %>
                    <div class="list-group-item px-0 d-flex justify-content-between align-items-center">
                        <div>
                            <a class="fw-semibold text-decoration-none" href="<%= request.getContextPath() %>/trip/detail?tripId=<%= trip.getTripId() %>">
                                <%= HtmlUtil.escape(trip.getTripName()) %>
                            </a>
                            <div class="small text-muted">
                                <%= HtmlUtil.escape(trip.getDestination()) %>
                                &nbsp;|&nbsp; <%= trip.getStartDate() %> → <%= trip.getEndDate() %>
                                &nbsp;|&nbsp; <%= trip.getBudget() %> đ
                            </div>
                        </div>
                        <span class="badge <%= owner ? "text-bg-primary" : "text-bg-secondary" %>"><%= owner ? "OWNER" : "MEMBER" %></span>
                    </div>
                <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <h5 class="fw-bold mb-3">Lối tắt</h5>
            <a href="<%= request.getContextPath() %>/places" class="btn btn-outline-secondary me-2">Khám phá địa điểm</a>
            <a href="<%= request.getContextPath() %>/trips" class="btn btn-outline-secondary">My Trips</a>
        </div>
    </div>
=======
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

>>>>>>> 1f8cf38 (Update UI)
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
