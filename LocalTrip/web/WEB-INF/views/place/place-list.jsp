<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Places" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<h3 class="mb-3">Địa điểm</h3>

<div class="mb-4">
    <a href="${pageContext.request.contextPath}/places"
       class="category-chip ${empty param.categoryId ? 'active' : ''}">Tất cả</a>
    <c:forEach var="category" items="${categories}">
        <a href="${pageContext.request.contextPath}/places?categoryId=${category.id}"
           class="category-chip ${param.categoryId == category.id ? 'active' : ''}">
            ${category.icon} ${category.name}
        </a>
    </c:forEach>
</div>

<c:choose>
    <c:when test="${empty places}">
        <div class="empty-state app-card">
            <div class="empty-icon">📍</div>
            <p>Không có địa điểm nào trong danh mục này.</p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="row">
            <c:forEach var="place" items="${places}">
                <div class="col-md-6 col-lg-4">
                    <div class="app-card h-100">
                        <div class="d-flex justify-content-between">
                            <h5>${place.name}</h5>
                            <span class="badge bg-secondary">⭐ ${place.rating}</span>
                        </div>
                        <p class="text-muted mb-1">${place.categoryIcon} ${place.categoryName}</p>
                        <p class="text-muted mb-1">📍 ${place.address}</p>
                        <p class="text-muted mb-1">🕒 ${place.openHours}</p>
                        <p class="mb-3">💰 ~${place.estimatedPrice} đ</p>
                        <a href="${pageContext.request.contextPath}/places/detail?placeId=${place.id}"
                           class="btn btn-outline-secondary btn-sm w-100">Xem chi tiết</a>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
