<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
                Discover exciting places, explore the interactive map, and prepare your group journeys.
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
            <strong>Adding places to Trip #${param.tripId}</strong> — Browse destinations and tap <strong>"+ Add to Trip"</strong>.
        </div>
        <a href="${pageContext.request.contextPath}/trip/detail?tripId=${param.tripId}"
           class="btn btn-sm btn-outline-success"
           style="border-color: #175b43; color: #175b43; font-weight: 600; flex-shrink: 0;">
            ← Return to Trip
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
            <div class="col-md-4">
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

            <div class="col-md-4">
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

            <div class="col-md-4">
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
        </div>

        <div class="d-flex flex-wrap gap-2 mt-3">
            <button type="submit" class="btn btn-primary px-4">
                Apply filters
            </button>

            <a href="${pageContext.request.contextPath}/places"
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
                No destinations match your active filters.
                Try selecting a different area or category.
            </p>

            <a href="${pageContext.request.contextPath}/places"
               class="btn btn-outline-secondary px-4">
                View all places
            </a>
        </div>
    </c:when>

    <c:otherwise>
        <div class="mb-3">
            <h2 class="h4 mb-1">Matching Destinations</h2>
            <p class="text-muted mb-0">
                Explore place details before adding them to your itinerary.
            </p>
        </div>

        <div class="row g-4">
            <c:forEach var="place" items="${places}">
                <div class="col-12 col-md-6 col-xl-4">
                    <article class="rd-card h-100 d-flex flex-column">
                        <div class="d-flex justify-content-between
                             align-items-start gap-3 mb-3">
                            <span class="rd-count">
                                <c:out value="${place.categoryName}" />
                            </span>

                            <span class="rd-role rd-role-lead flex-shrink-0">
                                ★ <c:out value="${place.rating}" />
                            </span>
                        </div>

                        <h3 class="h5 mb-3">
                            <c:out value="${place.name}" />
                        </h3>

                        <div class="mb-3">
                            <div class="small text-muted mb-1">
                                Address
                            </div>

                            <div>
                                <c:out value="${place.address}" />
                            </div>
                        </div>

                        <div class="mb-4">
                            <div class="small text-muted mb-1">
                                Opening hours
                            </div>

                            <div>
                                <c:choose>
                                    <c:when test="${not empty place.openHours}">
                                        <c:out value="${place.openHours}" />
                                    </c:when>
                                    <c:otherwise>
                                        Not specified
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="border-top pt-3 mt-auto">
                            <div class="d-flex justify-content-between
                                 align-items-center gap-2 mb-3">
                                <span class="small text-muted">
                                    Estimated price
                                </span>

                                <strong>
                                    <fmt:formatNumber
                                        value="${place.estimatedPrice}"
                                        type="number"
                                        maxFractionDigits="2" />
                                    VND
                                </strong>
                            </div>

                            <c:choose>
                                <c:when test="${not empty param.tripId}">
                                    <div class="d-grid gap-2">
                                        <a href="${pageContext.request.contextPath}/itinerary/add?tripId=${param.tripId}&placeId=${place.id}"
                                           class="btn btn-primary w-100" style="background-color: #175b43; border-color: #175b43;">
                                            + Add to Trip
                                        </a>
                                        <a href="${pageContext.request.contextPath}/places/detail?placeId=${place.id}&tripId=${param.tripId}"
                                           class="btn btn-outline-secondary btn-sm w-100">
                                            View details →
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/places/detail?placeId=${place.id}"
                                       class="btn btn-outline-secondary w-100">
                                        View details →
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </article>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

<script>
    (function () {
        const form = document.getElementById('placeFilterForm');
        const city = document.getElementById('filterCity');
        const district = document.getElementById('filterDistrict');

        if (!form || !city || !district)
            return;

        city.addEventListener('change', function () {
            district.value = '';
            form.submit();
        });
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
