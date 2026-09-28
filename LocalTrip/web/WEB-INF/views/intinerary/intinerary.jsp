<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Itinerary" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">Itinerary - ${trip.name}</h3>
    <a href="${pageContext.request.contextPath}/recommendations?tripId=${trip.id}"
       class="btn btn-outline-secondary btn-sm">← Từ Recommendation</a>
</div>

<c:choose>
    <c:when test="${empty items}">
        <div class="empty-state app-card">
            <div class="empty-icon">🗓️</div>
            <p>Chưa có địa điểm nào trong lịch trình.</p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="app-card p-0">
            <table class="table mb-0 align-middle">
                <thead>
                <tr>
                    <th>Địa điểm</th>
                    <th>Ngày</th>
                    <th>Giờ</th>
                    <th>Ghi chú</th>
                    <th>Chi phí dự kiến</th>
                    <c:if test="${trip.role == 'OWNER'}"><th></th></c:if>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="item" items="${items}">
                    <tr>
                        <td>${item.placeName}</td>
                        <td>${item.date}</td>
                        <td>${item.startTime} - ${item.endTime}</td>
                        <td>${item.note}</td>
                        <td><fmt:formatNumber value="${item.estimatedCost}" type="number"/> đ</td>
                        <c:if test="${trip.role == 'OWNER'}">
                            <td>
                                <form method="post"
                                      action="${pageContext.request.contextPath}/itinerary/delete"
                                      onsubmit="return confirmDelete('Xóa địa điểm này khỏi lịch trình?')">
                                    <input type="hidden" name="tripId" value="${trip.id}">
                                    <input type="hidden" name="itemId" value="${item.id}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">Xóa</button>
                                </form>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </c:otherwise>
</c:choose>

<c:if test="${trip.role != 'OWNER'}">
    <p class="text-muted mt-2"><em>Bạn là Member: chỉ Owner mới có thể thêm/xóa mục trong itinerary.</em></p>
</c:if>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
