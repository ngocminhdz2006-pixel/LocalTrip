<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="${place.name}" scope="request" />
<c:set var="tripRedesign" value="${true}" scope="request" />
<fmt:setLocale value="en_US" scope="page"/>

<c:url var="placesUrl" value="/places">
    <c:if test="${not empty param.tripId}">
        <c:param name="tripId" value="${param.tripId}" />
    </c:if>
</c:url>

<c:url var="checkinUrl" value="/checkin">
    <c:param name="placeId" value="${place.id}" />
    <c:if test="${not empty param.tripId}">
        <c:param name="tripId" value="${param.tripId}" />
    </c:if>
</c:url>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · DESTINATION OVERVIEW
            </div>

            <h1 class="mb-3">
                <c:out value="${place.name}" />
            </h1>

            <div class="d-flex flex-wrap align-items-center gap-2">
                <span class="rd-role">
                    <c:out value="${place.categoryName}" />
                </span>

                <span class="rd-role rd-role-lead">
                    ★ <c:out value="${place.rating}" />
                </span>

                <c:if test="${not empty groupCategoryIds and groupCategoryIds.contains(place.categoryId)}">
                    <span class="badge" style="background: #e8f4ec; color: #175b43; border: 1px solid #86c19a; font-size: 12px; padding: 6px 12px; border-radius: 8px; font-weight: 600;">
                        🔥 Matches group vibes (<c:out value="${place.categoryName}"/>)
                    </span>
                </c:if>
            </div>
        </div>

        <a href="<c:out value='${placesUrl}'/>"
           class="rd-back">
            ← Destination list
        </a>
    </div>
</section>

<c:if test="${not empty param.tripId}">
    <div class="alert d-flex justify-content-between align-items-center mb-4"
         style="background: #e8f4ec; border: 1px solid #86c19a; color: #175b43; border-radius: 12px; padding: 12px 16px;">
        <div style="font-size: 13px;">
            <strong>Viewing place for Trip #${fn:escapeXml(param.tripId)}</strong>
            <c:if test="${not empty currentTrip}">
                · <em><c:out value="${currentTrip.name}"/></em>
            </c:if>
        </div>
        <a href="${pageContext.request.contextPath}/itinerary?tripId=${param.tripId}"
           class="btn btn-sm btn-outline-success"
           style="border-color: #175b43; color: #175b43; font-weight: 600; flex-shrink: 0;">
            ← Return to Itinerary
        </a>
    </div>
</c:if>

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <section class="rd-card mb-4">
            <h2 class="h4 mb-2">Place Information</h2>

            <p class="text-muted mb-4">
                View address, operating hours, and reference costs before scheduling a visit.
            </p>

            <div class="border-top pt-3 mb-3">
                <div class="small text-muted mb-1">
                    Address & District
                </div>

                <div class="fw-semibold">
                    <c:choose>
                        <c:when test="${not empty place.address}">
                            <c:out value="${place.address}" />
                        </c:when>
                        <c:otherwise>
                            Not specified
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="border-top pt-3 mb-3">
                <div class="row g-3">
                    <div class="col-6">
                        <div class="small text-muted mb-1">Opening hours</div>
                        <div class="fw-semibold">
                            <c:choose>
                                <c:when test="${not empty place.openHours}">
                                    <c:out value="${place.openHours}" />
                                </c:when>
                                <c:otherwise>
                                    Flexible / Open daily
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="small text-muted mb-1">Suggested visit duration</div>
                        <div class="fw-semibold text-muted">
                            ⏱ 60 – 90 minutes
                        </div>
                    </div>
                </div>
            </div>

            <div class="border-top pt-3">
                <div class="small text-muted mb-1">
                    Estimated reference price
                </div>

                <div class="h4 mb-0" style="color: #175b43;">
                    <fmt:formatNumber
                        value="${place.estimatedPrice}"
                        type="number"
                        maxFractionDigits="0" />
                    VND
                </div>
            </div>
        </section>

        <section class="rd-card">
            <h2 class="h4 mb-3">About this destination</h2>

            <c:choose>
                <c:when test="${not empty place.description}">
                    <div style="white-space: pre-line; overflow-wrap: anywhere;"><c:out value="${place.description}" /></div>
                </c:when>
                <c:otherwise>
                    <p class="text-muted mb-0">
                        No detailed description available for this place yet.
                    </p>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <div class="col-12 col-lg-4">
        <section class="rd-card">
            <h2 class="h4 mb-2">Explore with LocalTrip</h2>

            <p class="text-muted mb-4">
                Schedule a visit or record your check-in at this spot.
            </p>

            <div class="d-grid gap-3">
                <button type="button"
                        class="btn btn-primary"
                        style="background-color: #175b43; border-color: #175b43;"
                        data-bs-toggle="modal"
                        data-bs-target="#quickAddModal">
                    + Add directly to Itinerary
                </button>

                <c:choose>
                    <c:when test="${not empty place.latitude
                                    and not empty place.longitude}">
                        <a href="<c:out value='${checkinUrl}'/>"
                           class="btn btn-outline-secondary">
                            📸 Check in here
                        </a>
                    </c:when>

                    <c:otherwise>
                        <button type="button"
                                class="btn btn-outline-secondary"
                                disabled>
                            GPS check-in unavailable
                        </button>

                        <p class="small text-muted mb-0">
                            This destination lacks coordinates to verify physical location.
                        </p>
                    </c:otherwise>
                </c:choose>

                <a href="<c:out value='${placesUrl}'/>"
                   class="btn btn-outline-secondary">
                    View other destinations
                </a>
            </div>
        </section>
    </div>
</div>

<!-- Quick Add Modal -->
<div class="modal fade" id="quickAddModal" tabindex="-1" aria-labelledby="quickAddModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.15);">
            <div class="modal-header" style="background: #175b43; color: white; border-top-left-radius: 16px; border-top-right-radius: 16px;">
                <h5 class="modal-title" id="quickAddModalLabel">Add to Itinerary</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/itinerary/add">
                <input type="hidden" name="travelCsrf" value="${sessionScope.travelCsrf}"/>
                <input type="hidden" name="placeId" value="${place.id}"/>

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-semibold text-muted small mb-1">DESTINATION</label>
                        <div class="h6 fw-bold mb-0 text-dark"><c:out value="${place.name}"/></div>
                    </div>

                    <div class="mb-3">
                        <label for="detailTripSelect" class="form-label fw-semibold">Target Trip</label>
                        <c:choose>
                            <c:when test="${not empty userTrips}">
                                <select id="detailTripSelect" name="tripId" class="form-select" required>
                                    <c:forEach var="t" items="${userTrips}">
                                        <option value="${t.id}"
                                                data-start="${t.startDate}"
                                                ${param.tripId == t.id ? 'selected' : ''}>
                                            <c:out value="${t.name}"/> (${t.startDate} - ${t.endDate})
                                        </option>
                                    </c:forEach>
                                </select>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-warning py-2 mb-0" style="font-size: 13px;">
                                    You don't have any trips yet. <a href="${pageContext.request.contextPath}/trips/create" class="alert-link">Create a trip</a> first.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-12">
                            <label for="detailVisitDate" class="form-label fw-semibold">Visit Date</label>
                            <input type="date" id="detailVisitDate" name="visitDate" class="form-control" required/>
                        </div>
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label for="detailStartTime" class="form-label fw-semibold">Start Time</label>
                            <input type="time" id="detailStartTime" name="startTime" class="form-control" value="09:00" required/>
                        </div>
                        <div class="col-6">
                            <label for="detailEndTime" class="form-label fw-semibold">End Time</label>
                            <input type="time" id="detailEndTime" name="endTime" class="form-control" value="10:30" required/>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="detailEstimatedCost" class="form-label fw-semibold">Estimated Cost (VND)</label>
                        <input type="number" id="detailEstimatedCost" name="estimatedCost" step="1000" class="form-control"
                               value="<fmt:formatNumber value='${place.estimatedPrice}' type='number' maxFractionDigits='0' groupingUsed='false'/>" required/>
                    </div>

                    <div class="mb-2">
                        <label for="detailNote" class="form-label fw-semibold">Notes (Optional)</label>
                        <input type="text" id="detailNote" name="note" class="form-control" placeholder="e.g. Try special dishes, reserve window seats..." maxlength="255"/>
                    </div>
                </div>

                <div class="modal-footer bg-light p-3" style="border-bottom-left-radius: 16px; border-bottom-right-radius: 16px;">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <c:if test="${not empty userTrips}">
                        <button type="submit" class="btn btn-primary px-4" style="background-color: #175b43; border-color: #175b43;">
                            + Add to Itinerary
                        </button>
                    </c:if>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        const tripSelect = document.getElementById('detailTripSelect');
        const dateInput = document.getElementById('detailVisitDate');

        function syncDate() {
            if (tripSelect && tripSelect.selectedOptions.length > 0 && dateInput) {
                const start = tripSelect.selectedOptions[0].getAttribute('data-start');
                if (start && !dateInput.value) {
                    dateInput.value = start;
                }
            }
            if (dateInput && !dateInput.value) {
                dateInput.value = new Date().toISOString().split('T')[0];
            }
        }

        if (tripSelect) {
            tripSelect.addEventListener('change', function () {
                if (this.selectedOptions.length > 0 && dateInput) {
                    const start = this.selectedOptions[0].getAttribute('data-start');
                    if (start) {
                        dateInput.value = start;
                    }
                }
            });
        }
        syncDate();
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
