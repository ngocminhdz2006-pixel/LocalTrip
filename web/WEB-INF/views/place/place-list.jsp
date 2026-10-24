<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Explore Places" scope="request"/>
<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<link rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · GO & EXPLORE
            </div>

            <h1 class="mb-2">Explore Destinations</h1>

            <p class="mb-0 text-white">
                Discover exciting places, explore the interactive map, and add spots directly to your itinerary.
            </p>
        </div>

        <a class="rd-back"
           href="${pageContext.request.contextPath}/trips">
            My trips →
        </a>
    </div>
</section>

<c:if test="${not empty param.tripId}">
    <div class="alert d-flex justify-content-between align-items-center mb-4"
         style="background: #e8f4ec; border: 1px solid #86c19a; color: #175b43; border-radius: 12px; padding: 12px 16px;">
        <div style="font-size: 13px;">
            <strong>Adding places to Trip #${fn:escapeXml(param.tripId)}</strong>
            <c:if test="${not empty currentTrip}">
                · <em><c:out value="${currentTrip.name}"/></em>
            </c:if>
            — Browse destinations and tap <strong>"+ Add to Itinerary"</strong>.
        </div>
        <a href="${pageContext.request.contextPath}/itinerary?tripId=${param.tripId}"
           class="btn btn-sm btn-outline-success"
           style="border-color: #175b43; color: #175b43; font-weight: 600; flex-shrink: 0;">
            ← Return to Itinerary
        </a>
    </div>
</c:if>

<div class="rd-card mb-4">
    <h5 class="mb-3">Filter Destinations</h5>

    <form id="placeFilterForm"
          method="get"
          action="${pageContext.request.contextPath}/places">

        <c:if test="${not empty param.tripId}">
            <input type="hidden" name="tripId" value="<c:out value='${param.tripId}'/>"/>
        </c:if>

        <div class="row g-3">
            <div class="col-md-3">
                <label for="filterCity" class="form-label">
                    Province / City
                </label>

                <select id="filterCity"
                        name="city"
                        class="form-select">
                    <option value="">All cities</option>

                    <c:forEach var="city" items="${cities}">
                        <option value="<c:out value='${city}'/>"
                                ${selectedCity == city ? 'selected' : ''}>
                            <c:out value="${city}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-3">
                <label for="filterDistrict" class="form-label">
                    District / Area
                </label>

                <select id="filterDistrict"
                        name="district"
                        class="form-select">
                    <option value="">All areas</option>

                    <c:forEach var="district" items="${districts}">
                        <option value="<c:out value='${district}'/>"
                                ${selectedDistrict == district ? 'selected' : ''}>
                            <c:out value="${district}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-3">
                <label for="filterCategory" class="form-label">
                    Category
                </label>

                <select id="filterCategory"
                        name="categoryId"
                        class="form-select">
                    <option value="">All categories</option>

                    <c:forEach var="category" items="${categories}">
                        <option value="${category.id}"
                                ${selectedCategoryId == category.id ? 'selected' : ''}>
                            <c:out value="${category.name}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-3">
                <label for="filterMaxPrice" class="form-label">
                    Max Price (VND)
                </label>
                <input type="number"
                       id="filterMaxPrice"
                       name="maxPrice"
                       class="form-control"
                       placeholder="e.g. 200000"
                       step="10000"
                       value="<c:out value='${selectedMaxPrice}'/>"/>
            </div>
        </div>

        <div class="d-flex flex-wrap gap-2 mt-3">
            <button type="submit" class="btn btn-primary px-4">
                Apply filters
            </button>

            <a href="${pageContext.request.contextPath}/places<c:if test='${not empty param.tripId}'>?tripId=${param.tripId}</c:if>"
               class="btn btn-outline-secondary">
                Reset filters
            </a>
        </div>
    </form>
</div>

<div class="rd-card mb-4">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
        <div>
            <h5 class="mb-1">Destination Map</h5>
            <small class="text-muted">
                Displaying destinations matching active filters with verified coordinates.
            </small>
        </div>

        <span class="rd-count" id="placeMapCount">
            0 places
        </span>
    </div>

    <div class="localtrip-map-wrap">
        <div id="placeMap"
             class="localtrip-map"
             style="min-height: 400px;">
        </div>
    </div>

    <div id="placeMapEmpty"
         class="alert alert-light border mt-3 mb-0 d-none">
        No destinations with coordinates found for the active filter.
    </div>
</div>

<div id="placeMapData" class="d-none" aria-hidden="true">
    <c:forEach var="place" items="${places}">
        <c:if test="${not empty place.latitude and not empty place.longitude}">
            <span class="place-map-point"
                  data-id="${place.id}"
                  data-name="<c:out value='${place.name}'/>"
                  data-address="<c:out value='${place.address}'/>"
                  data-category="<c:out value='${place.categoryName}'/>"
                  data-lat="${place.latitude}"
                  data-lng="${place.longitude}">
            </span>
        </c:if>
    </c:forEach>
</div>

<c:choose>
    <c:when test="${empty places}">
        <div class="rd-card text-center py-5">
            <h2 class="h4 mb-2">No destinations found</h2>

            <p class="text-muted mb-4">
                No destinations match your active filters. Try expanding your price limit or clearing the area/category filter.
            </p>

            <a href="${pageContext.request.contextPath}/places<c:if test='${not empty param.tripId}'>?tripId=${param.tripId}</c:if>"
               class="btn btn-primary px-4" style="background-color: #175b43; border-color: #175b43;">
                Reset filters
            </a>
        </div>
    </c:when>

    <c:otherwise>
        <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div>
                <h2 class="h4 mb-1">Matching Destinations</h2>
                <p class="text-muted mb-0">
                    Showing <c:out value="${fn:length(places)}"/> places matching your criteria.
                </p>
            </div>
        </div>

        <div class="row g-4">
            <c:forEach var="place" items="${places}">
                <div class="col-12 col-md-6 col-xl-4">
                    <article class="rd-card h-100 d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-start gap-2 mb-2">
                            <span class="rd-count">
                                <c:out value="${place.categoryName}" />
                            </span>

                            <span class="rd-role rd-role-lead flex-shrink-0">
                                ★ <c:out value="${place.rating}" />
                            </span>
                        </div>

                        <c:if test="${not empty groupCategoryIds and groupCategoryIds.contains(place.categoryId)}">
                            <div class="mb-2">
                                <span class="badge d-inline-flex align-items-center gap-1"
                                      style="background: #e8f4ec; color: #175b43; border: 1px solid #86c19a; font-size: 11px; padding: 4px 8px; border-radius: 6px; font-weight: 600;">
                                    🔥 Matches group vibes (<c:out value="${place.categoryName}"/>)
                                </span>
                            </div>
                        </c:if>

                        <h3 class="h5 mb-2">
                            <c:out value="${place.name}" />
                        </h3>

                        <div class="mb-2">
                            <div class="small text-muted mb-1">
                                Address
                            </div>
                            <div class="small text-secondary">
                                <c:out value="${place.address}" />
                            </div>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <div class="small text-muted mb-1">Opening hours</div>
                                <div class="small fw-semibold">
                                    <c:choose>
                                        <c:when test="${not empty place.openHours}">
                                            <c:out value="${place.openHours}" />
                                        </c:when>
                                        <c:otherwise>Flexible</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="small text-muted mb-1">Suggested visit</div>
                                <div class="small fw-semibold text-muted">
                                    ⏱ 60–90 mins
                                </div>
                            </div>
                        </div>

                        <div class="border-top pt-3 mt-auto">
                            <div class="d-flex justify-content-between align-items-center gap-2 mb-3">
                                <span class="small text-muted">
                                    Estimated price
                                </span>

                                <strong style="color: #175b43;">
                                    <fmt:formatNumber
                                        value="${place.estimatedPrice}"
                                        type="number"
                                        maxFractionDigits="0" />
                                    VND
                                </strong>
                            </div>

                            <div class="d-grid gap-2">
                                <button type="button"
                                        class="btn btn-primary w-100 btn-quick-add"
                                        style="background-color: #175b43; border-color: #175b43;"
                                        data-bs-toggle="modal"
                                        data-bs-target="#quickAddModal"
                                        data-place-id="${place.id}"
                                        data-place-name="<c:out value='${place.name}'/>"
                                        data-place-cost="${place.estimatedPrice}">
                                    + Add directly to Itinerary
                                </button>
                                <a href="${pageContext.request.contextPath}/places/detail?placeId=${place.id}<c:if test='${not empty param.tripId}'>&tripId=${param.tripId}</c:if>"
                                   class="btn btn-outline-secondary btn-sm w-100">
                                    View details →
                                </a>
                            </div>
                        </div>
                    </article>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

<!-- Quick Add to Itinerary Modal -->
<div class="modal fade" id="quickAddModal" tabindex="-1" aria-labelledby="quickAddModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.15);">
            <div class="modal-header" style="background: #175b43; color: white; border-top-left-radius: 16px; border-top-right-radius: 16px;">
                <h5 class="modal-title" id="quickAddModalLabel">Add to Itinerary</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/itinerary/add">
                <input type="hidden" name="travelCsrf" value="${sessionScope.travelCsrf}"/>
                <input type="hidden" id="modalPlaceId" name="placeId" value=""/>

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-semibold text-muted small mb-1">DESTINATION</label>
                        <div id="modalPlaceName" class="h6 fw-bold mb-0 text-dark"></div>
                    </div>

                    <div class="mb-3">
                        <label for="modalTripSelect" class="form-label fw-semibold">Target Trip</label>
                        <c:choose>
                            <c:when test="${not empty userTrips}">
                                <select id="modalTripSelect" name="tripId" class="form-select" required>
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
                            <label for="modalVisitDate" class="form-label fw-semibold">Visit Date</label>
                            <input type="date" id="modalVisitDate" name="visitDate" class="form-control" required/>
                        </div>
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label for="modalStartTime" class="form-label fw-semibold">Start Time</label>
                            <input type="time" id="modalStartTime" name="startTime" class="form-control" value="09:00" required/>
                        </div>
                        <div class="col-6">
                            <label for="modalEndTime" class="form-label fw-semibold">End Time</label>
                            <input type="time" id="modalEndTime" name="endTime" class="form-control" value="10:30" required/>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="modalEstimatedCost" class="form-label fw-semibold">Estimated Cost (VND)</label>
                        <input type="number" id="modalEstimatedCost" name="estimatedCost" step="1000" class="form-control" value="0" required/>
                    </div>

                    <div class="mb-2">
                        <label for="modalNote" class="form-label fw-semibold">Notes (Optional)</label>
                        <input type="text" id="modalNote" name="note" class="form-control" placeholder="e.g. Try special dishes, reserve window seats..." maxlength="255"/>
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
        const form = document.getElementById('placeFilterForm');
        const city = document.getElementById('filterCity');
        const district = document.getElementById('filterDistrict');

        if (form && city && district) {
            city.addEventListener('change', function () {
                district.value = '';
                form.submit();
            });
        }

        // Quick Add Modal Wiring
        const quickAddModal = document.getElementById('quickAddModal');
        if (quickAddModal) {
            quickAddModal.addEventListener('show.bs.modal', function (event) {
                const button = event.relatedTarget;
                if (!button) return;

                const placeId = button.getAttribute('data-place-id');
                const placeName = button.getAttribute('data-place-name');
                const placeCost = button.getAttribute('data-place-cost') || '0';

                document.getElementById('modalPlaceId').value = placeId;
                document.getElementById('modalPlaceName').textContent = placeName;
                document.getElementById('modalEstimatedCost').value = Math.round(Number(placeCost));

                // Auto set date from selected trip if available
                const tripSelect = document.getElementById('modalTripSelect');
                const dateInput = document.getElementById('modalVisitDate');
                if (tripSelect && tripSelect.selectedOptions.length > 0 && dateInput) {
                    const start = tripSelect.selectedOptions[0].getAttribute('data-start');
                    if (start && !dateInput.value) {
                        dateInput.value = start;
                    }
                }
                if (dateInput && !dateInput.value) {
                    const today = new Date().toISOString().split('T')[0];
                    dateInput.value = today;
                }
            });

            const tripSelect = document.getElementById('modalTripSelect');
            if (tripSelect) {
                tripSelect.addEventListener('change', function () {
                    const dateInput = document.getElementById('modalVisitDate');
                    if (this.selectedOptions.length > 0 && dateInput) {
                        const start = this.selectedOptions[0].getAttribute('data-start');
                        if (start) {
                            dateInput.value = start;
                        }
                    }
                });
            }
        }
    })();
</script>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
    (function () {
        const mapElement = document.getElementById('placeMap');
        const emptyState = document.getElementById('placeMapEmpty');
        const countElement = document.getElementById('placeMapCount');

        if (!mapElement)
            return;

        if (typeof L === 'undefined') {
            emptyState.textContent =
                    'Unable to load map. Please check your internet connection.';
            emptyState.classList.remove('d-none');
            return;
        }

        const points = Array.from(
                document.querySelectorAll('.place-map-point')
                ).map(function (element) {
            return {
                id: Number(element.dataset.id),
                name: element.dataset.name || '',
                address: element.dataset.address || '',
                category: element.dataset.category || '',
                lat: Number(element.dataset.lat),
                lng: Number(element.dataset.lng)
            };
        }).filter(function (point) {
            return Number.isFinite(point.lat) && Number.isFinite(point.lng);
        });

        countElement.textContent = points.length + ' places';

        if (points.length === 0) {
            emptyState.classList.remove('d-none');
            return;
        }

        emptyState.classList.add('d-none');

        const map = L.map(mapElement, {
            zoomControl: true
        });

        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; OpenStreetMap contributors'
        }).addTo(map);

        const bounds = [];

        points.forEach(function (point) {
            const latLng = [point.lat, point.lng];
            bounds.push(latLng);

            const popupContent =
                    '<div style="min-width: 180px;">' +
                    '<strong>' + point.name + '</strong><br>' +
                    '<small style="color: #666;">' + point.category + '</small><br>' +
                    '<small>' + point.address + '</small><br>' +
                    '<a href="${pageContext.request.contextPath}/places/detail?placeId=' + point.id + '" style="font-size: 12px; font-weight: 600; color: #175b43;">View details →</a>' +
                    '</div>';

            L.marker(latLng).addTo(map).bindPopup(popupContent);
        });

        if (bounds.length === 1) {
            map.setView(bounds[0], 14);
        } else if (bounds.length > 1) {
            map.fitBounds(bounds, {padding: [30, 30]});
        }
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
