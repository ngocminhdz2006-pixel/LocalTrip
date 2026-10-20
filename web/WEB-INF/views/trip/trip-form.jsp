<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="isEditing" value="${not empty trip}" />
<c:set var="tripRedesign" value="${true}" scope="request" />

<c:choose>
    <c:when test="${isEditing}">
        <c:set var="pageTitle" value="Update trip" scope="request" />
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Create trip" scope="request" />
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="lt-form-container">

    <%-- 1. Header Navigation Bar --%>
    <div class="lt-form-head-bar">
        <h1 class="lt-form-head-title">
            <c:choose>
                <c:when test="${isEditing}">Update trip</c:when>
                <c:otherwise>Create new trip</c:otherwise>
            </c:choose>
        </h1>

        <c:choose>
            <c:when test="${isEditing}">
                <a class="lt-exp-btn-sm lt-exp-btn-edit"
                   href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}">
                    ← Overview
                </a>
            </c:when>
            <c:otherwise>
                <a class="lt-exp-btn-sm lt-exp-btn-edit"
                   href="${pageContext.request.contextPath}/trips">
                    ← Back to trips
                </a>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- 2. Form Card --%>
    <div class="lt-form-card">
        <p style="font-size: 11px; color: #64748b; margin: 0 0 16px;">
            Plan your dates, destination, and budget together.
        </p>

        <form id="tripForm" method="post" action="${pageContext.request.contextPath}/trip/create">
            <c:if test="${isEditing}">
                <input type="hidden" name="tripId" value="${trip.id}">
            </c:if>

            <%-- Field 1: Trip name --%>
            <div class="lt-form-group">
                <label for="tripName" class="lt-form-label">
                    Trip name <span style="color: #e11d48;">*</span>
                </label>
                <input type="text"
                       class="lt-form-input"
                       id="tripName"
                       name="name"
                       value="<c:out value='${trip.name}'/>"
                       placeholder="e.g. Explore District 1 with friends"
                       maxlength="150"
                       required>
                <div class="lt-form-hint">Choose a memorable name for your trip!</div>
            </div>

            <%-- Field 2: Ngày bắt đầu & Ngày kết thúc --%>
            <div class="lt-form-group">
                <div class="lt-form-date-grid">
                    <div>
                        <label for="startDate" class="lt-form-label">
                            Start date <span style="color: #e11d48;">*</span>
                        </label>
                        <input type="date"
                               class="lt-form-input"
                               id="startDate"
                               name="startDate"
                               value="<c:out value='${trip.startDate}'/>"
                               required>
                    </div>

                    <div>
                        <label for="endDate" class="lt-form-label">
                            End date <span style="color: #e11d48;">*</span>
                        </label>
                        <input type="date"
                               class="lt-form-input"
                               id="endDate"
                               name="endDate"
                               value="<c:out value='${trip.endDate}'/>"
                               required>
                    </div>
                </div>
                <div class="lt-form-hint">Your itinerary days will be scheduled within this range.</div>
            </div>

            <%-- Field 3: Destination Area (Select + Chips gợi ý nhanh 1-chạm) --%>
            <div class="lt-form-group">
                <label for="tripArea" class="lt-form-label">
                    Destination Area <span style="color: #e11d48;">*</span>
                </label>

                <select class="lt-form-input" id="tripArea" name="area" required>
                    <option value="">Select area</option>
                    <c:forEach var="area" items="${tripAreas}">
                        <option value="<c:out value='${area}'/>"
                                <c:if test="${trip.area == area}">selected</c:if>>
                            <c:out value="${area}" />
                        </option>
                    </c:forEach>
                </select>

                <%-- Chips gợi ý nhanh 1-chạm --%>
                <div class="lt-form-hint" style="margin-top: 8px;">Popular areas:</div>
                <div class="lt-area-chips-wrap">
                    <c:forEach var="area" items="${tripAreas}">
                        <span class="lt-area-chip ${trip.area == area ? 'is-selected' : ''}"
                              onclick="selectAreaChip('<c:out value="${area}"/>', this)">
                            📍 <c:out value="${area}"/>
                        </span>
                    </c:forEach>
                </div>
            </div>

            <%-- Field 4: Estimated Budget (Bật bàn phím số inputmode="numeric") --%>
            <div class="lt-form-group">
                <label for="tripBudget" class="lt-form-label">
                    Estimated Budget <span style="color: #e11d48;">*</span>
                </label>
                <div class="lt-budget-wrap">
                    <input type="number"
                           class="lt-form-input"
                           id="tripBudget"
                           name="budget"
                           inputmode="numeric"
                           value="<c:out value='${trip.budget}'/>"
                           placeholder="5000000"
                           min="0"
                           step="1000"
                           required>
                    <span class="lt-budget-unit">VND</span>
                </div>
                <div class="lt-form-hint">Total estimated budget for group planning.</div>
            </div>

            <%-- Form Actions --%>
            <div class="lt-form-actions">
                <button type="submit" class="lt-btn-submit-main">
                    <c:choose>
                        <c:when test="${isEditing}">Save changes</c:when>
                        <c:otherwise>Create trip 🚀</c:otherwise>
                    </c:choose>
                </button>

                <c:choose>
                    <c:when test="${isEditing}">
                        <a class="lt-btn-cancel-main"
                           href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}">
                            Cancel
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="lt-btn-cancel-main"
                           href="${pageContext.request.contextPath}/trips">
                            Cancel
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </form>
    </div>

</div>

<script>
function selectAreaChip(areaVal, chipEl) {
    const select = document.getElementById('tripArea');
    if (select) {
        select.value = areaVal;
    }
    document.querySelectorAll('.lt-area-chip').forEach(function(c) {
        c.classList.remove('is-selected');
    });
    chipEl.classList.add('is-selected');
}

(function () {
    const form = document.getElementById('tripForm');
    if (!form) return;

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

    const today = valueOf('year') + '-' + valueOf('month') + '-' + valueOf('day');

    if (!isEditing && start) {
        start.min = today;
    }

    function validateDates() {
        if (!start || !end) return;
        start.setCustomValidity('');

        if (!isEditing && start.value && start.value < today) {
            start.setCustomValidity('Start date cannot be in the past.');
        }

        end.min = start.value || (isEditing ? '' : today);

        end.setCustomValidity(
            start.value && end.value && end.value < start.value
                ? 'End date cannot be earlier than start date.'
                : ''
        );
    }

    if (start && end) {
        start.addEventListener('input', validateDates);
        end.addEventListener('input', validateDates);
        validateDates();
    }

    form.addEventListener('submit', function (event) {
        validateDates();
        if (!form.checkValidity()) {
            event.preventDefault();
            form.reportValidity();
        }
    });
})();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
