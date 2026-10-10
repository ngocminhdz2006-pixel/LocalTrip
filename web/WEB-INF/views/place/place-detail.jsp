<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="${place.name}" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="app-card">
            <div class="d-flex justify-content-between align-items-start">
                <h3>${place.name}</h3>
                <span class="badge bg-secondary">⭐ ${place.rating}</span>
            </div>
            <p class="text-muted mb-1">${place.categoryIcon} ${place.categoryName}</p>
            <hr>
            <p>📍 <strong>Địa chỉ:</strong> ${place.address}</p>
            <p>🕒 <strong>Giờ hoạt động:</strong> ${place.openHours}</p>
            <p>💰 <strong>Mức giá dự kiến:</strong> ${place.estimatedPrice} đ</p>
            <c:if test="${not empty place.description}">
                <p>${place.description}</p>
            </c:if>

            <div class="d-flex gap-2 mt-3">
                <a href="${pageContext.request.contextPath}/places" class="btn btn-outline-secondary">← Quay lại danh sách</a>
                <c:if test="${not empty param.tripId}">
                    <a href="${pageContext.request.contextPath}/itinerary?tripId=${param.tripId}&placeId=${place.id}"
                       class="btn btn-brand">+ Thêm vào Lịch trình</a>
                </c:if>
                <c:choose>
                    <c:when test="${not empty place.latitude and not empty place.longitude}">
                        <c:choose>
                            <c:when test="${not empty param.tripId}"><a href="${pageContext.request.contextPath}/checkin?placeId=${place.id}&amp;tripId=${param.tripId}" class="btn btn-brand">📍 Ghi nhận ghé thăm tại đây</a></c:when>
                            <c:otherwise><a href="${pageContext.request.contextPath}/checkin?placeId=${place.id}" class="btn btn-brand">📍 Ghi nhận ghé thăm tại đây</a></c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <button type="button" class="btn btn-outline-secondary" disabled title="Địa điểm chưa có tọa độ GPS">📍 Chưa hỗ trợ Ghi nhận ghé thăm GPS</button>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
