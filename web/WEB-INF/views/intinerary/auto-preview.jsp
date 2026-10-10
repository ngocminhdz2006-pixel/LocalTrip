<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Xem trước lịch trình mới" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<div class="page-intro">
    <h3>Xem trước lịch trình mới</h3>
    <p>Chuyến đi: <strong><c:out value="${trip.name}"/></strong> · <c:out value="${trip.area}"/></p>
</div>
<div class="alert alert-info">
    Lịch mới được tạo theo sở thích hiện tại của nhóm. Lịch đang lưu chưa thay đổi.
    Khi xác nhận, các hoạt động từ <fmt:formatDate value="${draft.fromDate}" pattern="dd/MM/yyyy"/> trở đi sẽ được thay thế.
    Các ngày đã qua được giữ lại. Bản xem trước có hiệu lực trong 30 phút.
</div>
<div class="row mb-4">
    <div class="col-md-4"><div class="app-card"><strong>${oldItems.size()}</strong> hoạt động đang lưu trong phần sẽ thay thế</div></div>
    <div class="col-md-4"><div class="app-card"><strong>${draft.items.size()}</strong> hoạt động trong lịch mới</div></div>
    <div class="col-md-4"><div class="app-card">Chi phí lịch mới: <strong><fmt:formatNumber value="${draftTotal}" maxFractionDigits="0"/> đ</strong></div></div>
</div>
<div class="app-card mb-4">
    <h5>Lịch trình mới</h5>
    <p class="small text-muted">Kiểm tra ngày, giờ và địa điểm trước khi xác nhận. Ngày không có hoạt động sẽ không có lịch sau khi thay thế.</p>
    <div class="table-responsive"><table class="table">
        <thead><tr><th>Ngày</th><th>Giờ</th><th>Địa điểm</th><th>Hoạt động</th><th>Chi phí</th></tr></thead>
        <tbody><c:forEach var="item" items="${draft.items}"><tr>
            <td><fmt:formatDate value="${item.visitDate}" pattern="dd/MM/yyyy"/></td>
            <td><fmt:formatDate value="${item.startTime}" pattern="HH:mm"/> – <fmt:formatDate value="${item.endTime}" pattern="HH:mm"/></td>
            <td><c:out value="${item.placeName}"/></td><td><c:out value="${item.note}"/></td>
            <td><fmt:formatNumber value="${item.estimatedCost}" maxFractionDigits="0"/> đ</td>
        </tr></c:forEach></tbody>
    </table></div>
</div>
<details class="app-card mb-4"><summary>Xem lịch đang lưu trong phần sẽ thay thế</summary>
    <div class="table-responsive mt-3"><table class="table"><thead><tr><th>Ngày</th><th>Giờ</th><th>Địa điểm</th></tr></thead><tbody>
    <c:forEach var="item" items="${oldItems}"><tr><td><fmt:formatDate value="${item.visitDate}" pattern="dd/MM/yyyy"/></td><td><fmt:formatDate value="${item.startTime}" pattern="HH:mm"/> – <fmt:formatDate value="${item.endTime}" pattern="HH:mm"/></td><td><c:out value="${item.placeName}"/></td></tr></c:forEach>
    </tbody></table></div>
</details>
<form method="post" action="${pageContext.request.contextPath}/itinerary/auto" class="d-flex flex-wrap gap-2 mb-4">
    <input type="hidden" name="tripId" value="${trip.id}">
    <input type="hidden" name="autoToken" value="<c:out value='${sessionScope.autoItineraryToken}'/>">
    <input type="hidden" name="draftToken" value="<c:out value='${draft.token}'/>">
    <button type="submit" name="action" value="confirm" class="btn btn-brand" onclick="return confirm('Thay thế phần lịch từ ngày đã ghi bằng bản xem trước này?');">Xác nhận thay thế lịch cũ</button>
    <button type="submit" name="action" value="cancel" class="btn btn-outline-secondary">Hủy bản xem trước</button>
    <button type="submit" name="action" value="generate" class="btn btn-outline-primary">Tạo lại theo sở thích mới nhất</button>
</form>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
