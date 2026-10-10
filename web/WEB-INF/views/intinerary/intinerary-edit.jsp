<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Sửa hoạt động" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<div class="app-card">
    <h3>Sửa hoạt động</h3>
    <p>Chuyến đi: <strong><c:out value="${trip.name}"/></strong> · Khu vực: <c:out value="${trip.area}"/></p>
    <c:if test="${not empty error}"><div class="alert alert-danger" role="alert"><c:out value="${error}"/> <a href="${pageContext.request.contextPath}/itinerary/edit?tripId=${trip.id}&amp;itemId=${item.id}">Tải lại biểu mẫu</a></div></c:if>
    <fmt:formatDate value="${item.startTime}" pattern="HH:mm" var="savedStart"/>
    <fmt:formatDate value="${item.endTime}" pattern="HH:mm" var="savedEnd"/>
    <form method="post" action="${pageContext.request.contextPath}/itinerary/edit">
        <input type="hidden" name="tripId" value="${trip.id}">
        <input type="hidden" name="itemId" value="${item.id}">
        <input type="hidden" name="editToken" value="<c:out value='${sessionScope.itineraryEditToken}'/>">
        <input type="hidden" name="revision" value="<c:out value='${revision}'/>">
        <div class="mb-3"><label class="form-label" for="editPlace">Địa điểm</label>
            <select class="form-select" id="editPlace" name="placeId" required>
                <option value="">Chọn địa điểm trong khu vực chuyến đi</option>
                <c:forEach items="${candidates}" var="place"><option value="${place.id}" ${place.id == (submitted ? submittedPlaceId : item.placeId) ? 'selected' : ''}><c:out value="${place.name}"/> · <c:out value="${place.openHours}"/></option></c:forEach>
            </select>
        </div>
        <div class="row">
            <div class="col-md-4 mb-3"><label class="form-label" for="editDate">Ngày</label><input type="date" class="form-control" id="editDate" name="visitDate" min="${minimumDate}" max="${trip.endDate}" value="<c:out value='${submitted ? param.visitDate : item.visitDate}'/>" required></div>
            <div class="col-md-4 mb-3"><label class="form-label" for="editStart">Bắt đầu</label><input type="time" class="form-control" id="editStart" name="startTime" value="<c:out value='${submitted ? param.startTime : savedStart}'/>" required></div>
            <div class="col-md-4 mb-3"><label class="form-label" for="editEnd">Kết thúc</label><input type="time" class="form-control" id="editEnd" name="endTime" value="<c:out value='${submitted ? param.endTime : savedEnd}'/>" required></div>
        </div>
        <div class="mb-3"><label class="form-label" for="editCost">Chi phí dự kiến (đồng)</label><input type="number" class="form-control" id="editCost" name="estimatedCost" min="0" step="0.01" value="<c:out value='${submitted ? param.estimatedCost : item.estimatedCost}'/>" required><p class="form-text">Đổi địa điểm sẽ giữ chi phí bạn nhập. Hãy điều chỉnh nếu cần.</p></div>
        <div class="mb-3"><label class="form-label" for="editNote">Ghi chú</label><textarea class="form-control" id="editNote" name="note" rows="3" maxlength="500"><c:out value="${submitted ? param.note : item.note}"/></textarea></div>
        <div class="d-flex flex-wrap gap-2"><button class="btn btn-brand" type="submit">Lưu thay đổi</button><a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/itinerary?tripId=${trip.id}">Hủy và quay lại</a></div>
    </form>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
