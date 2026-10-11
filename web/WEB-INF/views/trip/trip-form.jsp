<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="isEditing" value="${not empty trip}" />
<c:set var="tripRedesign" value="${true}" scope="request" />

<c:choose>
    <c:when test="${isEditing}">
        <c:set var="pageTitle" value="Cập nhật chuyến đi" scope="request" />
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Tạo chuyến đi" scope="request" />
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · LÊN KẾ HOẠCH CÙNG NHAU
            </div>

            <h1 class="mb-2">
                <c:choose>
                    <c:when test="${isEditing}">
                        Cập nhật chuyến đi
                    </c:when>
                    <c:otherwise>
                        Bắt đầu một hành trình mới
                    </c:otherwise>
                </c:choose>
            </h1>

            <p class="mb-0 text-white">
                Chọn thời gian, khu vực và ngân sách cho chuyến đi của nhóm.
            </p>
        </div>

        <c:choose>
            <c:when test="${isEditing}">
                <a class="rd-back"
                   href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}">
                    ← Chi tiết chuyến đi
                </a>
            </c:when>
            <c:otherwise>
                <a class="rd-back"
                   href="${pageContext.request.contextPath}/trips">
                    ← Danh sách chuyến đi
                </a>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<div class="row justify-content-center">
    <div class="col-12 col-lg-8">
        <section class="rd-card mb-4">
            <div class="mb-4">
                <h2 class="h4 mb-2">Thông tin chuyến đi</h2>
                <p class="text-muted mb-0">
                    Các thông tin này giúp nhóm lựa chọn địa điểm
                    và sắp xếp lịch trình phù hợp.
                </p>
            </div>

            <form id="tripForm"
                  method="post"
                  action="${pageContext.request.contextPath}/trip/create">

                <c:if test="${isEditing}">
                    <input type="hidden"
                           name="tripId"
                           value="${trip.id}">
                </c:if>

                <div class="mb-4">
                    <label for="tripName" class="form-label fw-semibold">
                        Tên chuyến đi
                    </label>

                    <input type="text"
                           class="form-control"
                           id="tripName"
                           name="name"
                           value="<c:out value='${trip.name}'/>"
                           placeholder="Ví dụ: Khám phá Quận 1 cùng nhóm"
                           maxlength="150"
                           required>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-12 col-md-6">
                        <label for="startDate" class="form-label fw-semibold">
                            Ngày bắt đầu
                        </label>

                        <input type="date"
                               class="form-control"
                               id="startDate"
                               name="startDate"
                               value="<c:out value='${trip.startDate}'/>"
                               required>
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="endDate" class="form-label fw-semibold">
                            Ngày kết thúc
                        </label>

                        <input type="date"
                               class="form-control"
                               id="endDate"
                               name="endDate"
                               value="<c:out value='${trip.endDate}'/>"
                               required>
                    </div>

                    <div class="col-12">
                        <div class="form-text mt-0">
                            Lịch trình của nhóm sẽ nằm trong khoảng thời gian này.
                        </div>
                    </div>
                </div>

                <div class="mb-4">
                    <label for="tripArea" class="form-label fw-semibold">
                        Khu vực chuyến đi
                    </label>

                    <select class="form-select"
                            id="tripArea"
                            name="area"
                            required>
                        <option value="">Chọn khu vực</option>

                        <c:forEach var="area" items="${tripAreas}">
                            <option value="<c:out value='${area}'/>"
                                    <c:if test="${trip.area == area}">selected</c:if>>
                                <c:out value="${area}" />
                            </option>
                        </c:forEach>
                    </select>

                    <div class="form-text">
                        Gợi ý và lịch trình tự động sẽ chọn địa điểm
                        trong khu vực này.
                    </div>
                </div>

                <div class="mb-4">
                    <label for="tripBudget" class="form-label fw-semibold">
                        Ngân sách dự kiến
                    </label>

                    <div class="input-group">
                        <input type="number"
                               class="form-control"
                               id="tripBudget"
                               name="budget"
                               value="<c:out value='${trip.budget}'/>"
                               placeholder="Ví dụ: 5000000"
                               min="0"
                               step="0.01"
                               aria-describedby="budgetUnit budgetHelp"
                               required>

                        <span class="input-group-text" id="budgetUnit">
                            đồng
                        </span>
                    </div>

                    <div class="form-text" id="budgetHelp">
                        Tổng ngân sách dự kiến cho cả chuyến đi.
                    </div>
                </div>

                <div class="border-top pt-4">
                    <div class="d-flex flex-wrap gap-2">
                        <button type="submit" class="btn btn-primary px-4">
                            <c:choose>
                                <c:when test="${isEditing}">
                                    Lưu thay đổi
                                </c:when>
                                <c:otherwise>
                                    Tạo chuyến đi
                                </c:otherwise>
                            </c:choose>
                        </button>

                        <c:choose>
                            <c:when test="${isEditing}">
                                <a class="btn btn-outline-secondary px-4"
                                   href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}">
                                    Hủy
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a class="btn btn-outline-secondary px-4"
                                   href="${pageContext.request.contextPath}/trips">
                                    Hủy
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </form>
        </section>
    </div>
</div>

<script>
(function () {
    const form = document.getElementById('tripForm');

    if (!form) {
        return;
    }

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

    const today = valueOf('year')
            + '-' + valueOf('month')
            + '-' + valueOf('day');

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