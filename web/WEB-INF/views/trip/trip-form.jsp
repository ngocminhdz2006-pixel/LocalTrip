<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:choose>
    <c:when test="${not empty trip}">
        <c:set var="pageTitle" value="Cập nhật chuyến đi" scope="request"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Tạo chuyến đi" scope="request"/>
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="app-card">
            <h3 class="mb-2">
                <c:out value="${pageTitle}"/>
            </h3>

            <p class="text-muted mb-4">
                Chọn thời gian, khu vực và ngân sách để bắt đầu lên kế hoạch.
            </p>

            <form id="tripForm"
                  method="post"
                  action="${pageContext.request.contextPath}/trip/create">

                <c:if test="${not empty trip}">
                    <input type="hidden"
                           name="tripId"
                           value="${trip.id}">
                </c:if>

                <div class="mb-3">
                    <label for="tripName" class="form-label">
                        Tên chuyến đi
                    </label>

                    <input id="tripName"
                           type="text"
                           name="name"
                           class="form-control"
                           value="<c:out value='${trip.name}'/>"
                           placeholder="Ví dụ: Cuối tuần khám phá Quận 1"
                           maxlength="150"
                           required>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="startDate" class="form-label">
                            Ngày bắt đầu
                        </label>

                        <input id="startDate"
                               type="date"
                               name="startDate"
                               class="form-control"
                               value="${trip.startDate}"
                               required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="endDate" class="form-label">
                            Ngày kết thúc
                        </label>

                        <input id="endDate"
                               type="date"
                               name="endDate"
                               class="form-control"
                               value="${trip.endDate}"
                               required>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="tripArea" class="form-label">
                        Khu vực chuyến đi
                    </label>

                    <select id="tripArea"
                            name="area"
                            class="form-select"
                            required>
                        <option value="">Chọn khu vực</option>

                        <c:forEach var="area" items="${tripAreas}">
                            <option value="<c:out value='${area}'/>"
                                    ${trip.area == area ? 'selected' : ''}>
                                <c:out value="${area}"/>
                            </option>
                        </c:forEach>
                    </select>

                    <div class="form-text">
                        Gợi ý và lịch trình tự động sẽ chọn địa điểm
                        trong khu vực này.
                    </div>
                </div>

                <div class="mb-4">
                    <label for="tripBudget" class="form-label">
                        Ngân sách dự kiến (đồng)
                    </label>

                    <input id="tripBudget"
                           type="number"
                           name="budget"
                           class="form-control"
                           value="${trip.budget}"
                           min="0"
                           step="0.01"
                           required>

                    <div class="form-text">
                        Tổng ngân sách dự kiến cho chuyến đi.
                    </div>
                </div>

                <div class="d-flex flex-wrap gap-2">
                    <button type="submit" class="btn btn-brand">
                        <c:choose>
                            <c:when test="${not empty trip}">
                                Lưu thay đổi
                            </c:when>
                            <c:otherwise>
                                Tạo chuyến đi
                            </c:otherwise>
                        </c:choose>
                    </button>

                    <c:choose>
                        <c:when test="${not empty trip}">
                            <a href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}"
                               class="btn btn-outline-secondary">
                                Hủy
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/trips"
                               class="btn btn-outline-secondary">
                                Hủy
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        const form = document.getElementById('tripForm');
        if (!form)
            return;

        const start = document.getElementById('startDate');
        const end = document.getElementById('endDate');
        const isEditing = !!form.querySelector('[name="tripId"]');

        const parts = new Intl.DateTimeFormat('en-CA', {
            timeZone: 'Asia/Ho_Chi_Minh',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        }).formatToParts(new Date());

        function valueOf(type) {
            return parts.find(function (part) {
                return part.type === type;
            }).value;
        }

        const today =
                valueOf('year') + '-' +
                valueOf('month') + '-' +
                valueOf('day');

        if (!isEditing) {
            start.min = today;
        }

        function validateDates() {
            start.setCustomValidity('');

            if (!isEditing && start.value && start.value < today) {
                start.setCustomValidity(
                        'Ngày bắt đầu không được trước ngày hôm nay.'
                        );
            }

            end.min = start.value || (isEditing ? '' : today);

            end.setCustomValidity(
                    start.value && end.value && end.value < start.value
                    ? 'Ngày kết thúc không được trước ngày bắt đầu.'
                    : ''
                    );
        }

        start.addEventListener('input', validateDates);
        end.addEventListener('input', validateDates);

        form.addEventListener('submit', function (event) {
            validateDates();

            if (!form.checkValidity()) {
                event.preventDefault();
                form.reportValidity();
            }
        });

        validateDates();
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>