<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Sửa hoạt động" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="vi_VN" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<style>
    .rd-edit-activity {
        max-width: 860px;
        margin: 0 auto;
    }

    .rd-edit-heading {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
    }

    .rd-edit-heading h2 {
        margin: 0 0 8px;
        color: var(--ink);
        font-size: 24px;
        font-weight: 700;
    }

    .rd-edit-notice {
        padding: 16px 20px;
        margin-bottom: 24px;
        color: var(--ink2);
        background: var(--mint);
        border: 1px solid var(--line);
        border-radius: 14px;
        line-height: 1.6;
    }

    .rd-edit-notice strong {
        color: var(--green);
    }

    .rd-edit-activity .form-label {
        color: var(--ink);
        font-weight: 600;
    }

    .rd-edit-activity .form-control,
    .rd-edit-activity .form-select {
        min-height: 46px;
        border-radius: 10px;
    }

    .rd-edit-activity textarea.form-control {
        min-height: 110px;
    }

    .rd-edit-activity .form-text {
        margin-top: 8px;
        color: var(--ink2);
    }

    .rd-edit-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 24px;
        padding-top: 20px;
        border-top: 1px solid var(--line);
    }

    @media (max-width: 600px) {
        .rd-edit-heading h2 {
            font-size: 21px;
        }

        .rd-edit-actions .btn {
            width: 100%;
        }
    }
</style>
<div class="rd-edit-activity">
    <div class="rd-edit-heading">
        <div>
            <h2>Sửa hoạt động</h2>
            <p class="rd-sub">
                Điều chỉnh địa điểm, thời gian và chi phí trong lịch trình.
            </p>
        </div>

        <a href="${pageContext.request.contextPath}/itinerary?tripId=${trip.id}"
           class="btn btn-outline-secondary">
            Quay lại lịch trình
        </a>
    </div>

    <div class="rd-card">
        <div class="rd-edit-notice">
            <strong>Thông tin hoạt động</strong><br>
            Bạn có thể chọn lại địa điểm và cập nhật thời gian.
            Khi đổi địa điểm, hãy kiểm tra lại chi phí dự kiến.
        </div>
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
            <div class="rd-edit-actions">
                <button class="btn btn-brand" type="submit">
                    Lưu thay đổi
                </button>

                <a class="btn btn-outline-secondary"
                   href="${pageContext.request.contextPath}/itinerary?tripId=${trip.id}">
                    Hủy và quay lại
                </a>
            </div>       
        </form>
    </div> <%-- Đóng rd-card --%>
</div> <%-- Đóng rd-edit-activity --%>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
