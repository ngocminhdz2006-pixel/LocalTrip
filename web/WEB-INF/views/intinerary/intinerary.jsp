<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  

<c:set var="pageTitle" value="Trip Itinerary" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<fmt:setLocale value="en_US" scope="page"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

<div class="lt-itinerary-container">

    <%-- 1. Quick Planning Actions Hub (Add Destinations & Auto-Schedule) --%>
    <div class="lt-itinerary-actions-hub">
        <div class="lt-actions-hub-grid">
            <a href="${pageContext.request.contextPath}/places?tripId=${trip.id}" class="lt-action-hub-btn primary">
                <span class="lt-action-hub-icon">📍</span>
                <div class="lt-action-hub-text">
                    <strong>+ Add Destination</strong>
                    <small>Browse catalog</small>
                </div>
            </a>
            <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
                <a href="${pageContext.request.contextPath}/itinerary/auto?tripId=${trip.id}" class="lt-action-hub-btn secondary">
                    <span class="lt-action-hub-icon">✨</span>
                    <div class="lt-action-hub-text">
                        <strong>✨ AI Auto-Schedule</strong>
                        <small>Group smart generator</small>
                    </div>
                </a>
            </c:if>
            <a href="${pageContext.request.contextPath}/combos?tripId=${trip.id}" class="lt-action-hub-btn secondary">
                <span class="lt-action-hub-icon">🍱</span>
                <div class="lt-action-hub-text">
                    <strong>🍱 Curated Combos</strong>
                    <small>Explore day-plans</small>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/recommendations?tripId=${trip.id}" class="lt-action-hub-btn secondary">
                <span class="lt-action-hub-icon">💡</span>
                <div class="lt-action-hub-text">
                    <strong>💡 Top Suggestions</strong>
                    <small>Group favorites</small>
                </div>
            </a>
        </div>
    </div>

    <%-- 2. Day Tabs Navigation --%>
    <div class="lt-day-tabs-wrap">
        <nav class="lt-day-tabs" id="itineraryDayTabs" aria-label="Itinerary days">
            <button type="button" class="lt-day-tab is-active" data-day="ALL">
                <span>All Days</span>
                <small>Overview</small>
            </button>
        </nav>
    </div>

    <%-- 3. Leaflet Map --%>
    <div class="lt-itinerary-map-card">
        <div id="itineraryMap" class="localtrip-map"></div>
    </div>

    <%-- 4. Daily Legs & Google Maps Directions --%>
    <div class="lt-map-controls-card">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
            <div class="d-flex align-items-center gap-2 flex-grow-1">
                <span style="font-size: 13px; font-weight: 700; color: #143b2d; white-space: nowrap;">🛣️ Route Leg:</span>
                <select id="mapLegFilter" class="form-select form-select-sm" style="max-width: 280px; font-size: 12px; border-radius: 8px;">
                    <option value="ALL">Full day route (All legs)</option>
                </select>
            </div>

            <a id="mapDirectionsLink"
               class="btn btn-sm d-none"
               style="background: #175b43; color: #ffffff; font-size: 12px; font-weight: 600; border-radius: 8px; text-decoration: none; display: inline-flex; align-items: center; gap: 4px;"
               target="_blank"
               rel="noopener noreferrer">
                🗺️ Google Maps Directions ↗
            </a>
        </div>

        <div id="mapRouteInfo" class="lt-route-info-box d-none"></div>
        <div id="mapEmptyState" class="alert alert-light border mt-2 mb-0 d-none" style="font-size: 12px;">
            No GPS coordinates available for this day to draw routes.
        </div>
    </div>

    <%-- Hidden day filter synchronized with Map --%>
    <select id="mapDayFilter" class="d-none" aria-hidden="true">
        <option value="ALL">ALL</option>
        <c:set var="prevMapDate" value=""/>
        <c:forEach var="item" items="${items}">
            <c:if test="${item.date != prevMapDate}">
                <option value="${item.date}">${item.date}</option>
                <c:set var="prevMapDate" value="${item.date}"/>
            </c:if>
        </c:forEach>
    </select>
    <span id="mapPointCount" class="d-none" aria-hidden="true"></span>

    <%-- 5. Timeline List (Cards + Travel Connectors) --%>
    <div class="lt-timeline-list" id="itineraryTimelineList">
        <c:choose>
            <c:when test="${empty items}">
                <div class="app-card text-center p-4" style="background:#ffffff; border:1px dashed #cbd5e1; border-radius:16px;">
                    <p class="text-muted mb-2">No activities scheduled yet.</p>
                    <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
                        <a href="${pageContext.request.contextPath}/places?tripId=${trip.id}" class="btn btn-sm" style="background:#175b43; color:#fff;">
                            + Add First Destination
                        </a>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="item" items="${items}" varStatus="status">
                    <div class="lt-stop-card lt-activity-row" data-activity-date="${item.date}" data-lat="${item.latitude}" data-lng="${item.longitude}">
                        <div class="lt-stop-left">
                            <span class="lt-drag-handle" title="Order">⋮⋮</span>
                            <span class="lt-stop-badge">${status.index + 1}</span>
                            <img src="https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=100&auto=format&fit=crop&q=80"
                                 class="lt-stop-thumb"
                                 alt="<c:out value='${item.placeName}'/>"
                                 loading="lazy" />
                            <div class="lt-stop-info">
                                <div class="lt-stop-time">
                                    <c:choose>
                                        <c:when test="${not empty item.startTime}">
                                            <fmt:formatDate value="${item.startTime}" pattern="HH:mm"/>
                                            <c:if test="${not empty item.endTime}">
                                                – <fmt:formatDate value="${item.endTime}" pattern="HH:mm"/>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>All day</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="lt-stop-name" title="<c:out value='${item.placeName}'/>">
                                    <c:out value="${item.placeName}"/>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-1">
                            <c:if test="${item.activityStatus == 'COMPLETED'}">
                                <span class="badge bg-success-subtle text-success border border-success-subtle" style="font-size:9px;">Done</span>
                            </c:if>
                            <c:if test="${item.activityStatus == 'IN_PROGRESS'}">
                                <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle" style="font-size:9px;">Ongoing</span>
                            </c:if>

                            <%-- One-click Google Maps directions button --%>
                            <c:if test="${not empty item.latitude and not empty item.longitude}">
                                <a class="lt-stop-directions-link"
                                   href="https://www.google.com/maps/dir/?api=1&destination=${item.latitude},${item.longitude}&travelmode=driving"
                                   target="_blank" rel="noopener noreferrer"
                                   title="Google Maps directions to this place">
                                    🧭 Directions
                                </a>
                            </c:if>

                            <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
                                <a class="lt-stop-change-link" href="${pageContext.request.contextPath}/itinerary/edit?tripId=${trip.id}&amp;itemId=${item.id}">
                                    Edit
                                </a>
                            </c:if>
                        </div>
                    </div>

                    <%-- Travel connector between 2 stops --%>
                    <div class="lt-travel-connector lt-connector-row" data-activity-date="${item.date}">
                        <span class="lt-connector-line"></span>
                        <span class="lt-connector-text">🚶 800m • 10 mins walk</span>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>

        <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
            <a id="addDestinationBtn" href="${pageContext.request.contextPath}/places?tripId=${trip.id}" class="lt-add-stop-btn">
                + Add Destination to Itinerary
            </a>
        </c:if>
    </div>

    <%-- 6. Scheduled Weather Forecast --%>
    <div class="lt-card-weather" id="itineraryWeatherCard">
        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
            <div>
                <h3 style="font-size: 15px; font-weight: 700; color: #143b2d; margin: 0; display: flex; align-items: center; gap: 6px;">
                    <span>🌤️</span> Scheduled Weather Forecast
                </h3>
                <span style="font-size: 11px; color: #64748b;">Temperature &amp; precipitation forecast by GPS coordinates and visit hours</span>
            </div>
            <span class="badge" id="weatherStatus" style="background: #e2f5ea; color: #175b43; border: 1px solid #a7f3d0; font-size: 11px; padding: 4px 8px;">
                Loading...
            </span>
        </div>

        <div id="weatherNotice" class="alert alert-light border d-none mb-3" style="font-size: 12px; border-radius: 10px; background: #f8fafc;">
        </div>

        <div class="d-flex align-items-center gap-2 mb-3">
            <label for="weatherDayFilter" style="font-size: 12px; font-weight: 600; color: #334155; margin: 0; white-space: nowrap;">
                Filter by day:
            </label>
            <select id="weatherDayFilter" class="form-select form-select-sm" style="max-width: 200px; font-size: 12px; border-radius: 8px;">
                <option value="ALL">All Days</option>
            </select>
        </div>

        <div id="weatherList" class="row g-2"></div>
    </div>

    <%-- 7. Bottom Action Bar --%>
    <div class="lt-itinerary-footer-bar">
        <div class="lt-group-status-box">
            <span class="lt-group-status-lbl">Itinerary Status</span>
            <c:choose>
                <c:when test="${trip.status == 'ONGOING'}">
                    <span class="lt-group-status-cnt" style="color: #059669;">✓ Confirmed &amp; Ongoing</span>
                </c:when>
                <c:when test="${trip.status == 'COMPLETED'}">
                    <span class="lt-group-status-cnt" style="color: #64748b;">Completed</span>
                </c:when>
                <c:when test="${trip.status == 'CANCELLED'}">
                    <span class="lt-group-status-cnt" style="color: #ef4444;">Cancelled</span>
                </c:when>
                <c:when test="${empty items}">
                    <span class="lt-group-status-cnt" style="color: #f59e0b;">No activities</span>
                </c:when>
                <c:otherwise>
                    <span class="lt-group-status-cnt" style="color: #165b43;">
                        ${fn:length(items)} saved activities
                    </span>
                </c:otherwise>
            </c:choose>
        </div>

        <c:choose>
            <c:when test="${trip.status == 'ONGOING'}">
                <button type="button" class="lt-btn-confirm-action" style="background: #059669; opacity: 0.95;" disabled>
                    ✓ Schedule Active
                </button>
            </c:when>
            <c:when test="${trip.status == 'COMPLETED' or trip.status == 'CANCELLED'}">
                <button type="button" class="lt-btn-confirm-action" style="background: #94a3b8;" disabled>
                    Trip ${trip.status}
                </button>
            </c:when>
            <c:when test="${empty items}">
                <a href="${pageContext.request.contextPath}/places?tripId=${trip.id}" class="lt-btn-confirm-action" style="text-decoration: none; text-align: center; display: inline-flex; align-items: center; justify-content: center;">
                    + Add Places First
                </a>
            </c:when>
            <c:when test="${trip.role == 'OWNER'}">
                <form method="post" action="${pageContext.request.contextPath}/itinerary/confirm" style="margin: 0;"
                      onsubmit="return confirm('Confirm and finalize this itinerary for the entire group?');">
                    <input type="hidden" name="tripId" value="${trip.id}">
                    <button id="confirmItineraryBtn" type="submit" class="lt-btn-confirm-action">
                        ✓ Confirm Itinerary
                    </button>
                </form>
            </c:when>
            <c:otherwise>
                <button type="button" class="lt-btn-confirm-action" style="opacity: 0.75; cursor: default;" title="Only the trip owner can confirm the itinerary" disabled>
                    Awaiting Owner Confirmation
                </button>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%-- GPS coordinates for Leaflet Map & Weather --%>
<div id="itineraryMapData" class="d-none" aria-hidden="true">
    <c:forEach var="item" items="${items}">
        <c:if test="${item.activityStatus != 'CANCELLED' and item.placeId > 0 and not empty item.latitude and not empty item.longitude}">
            <span class="itinerary-map-point"
                  data-id="${item.placeId}"
                  data-name="<c:out value='${item.placeName}'/>"
                  data-lat="${item.latitude}"
                  data-lng="${item.longitude}"
                  data-date="${item.date}"
                  data-start="${item.startTime}"
                  data-end="${item.endTime}">
            </span>
        </c:if>
    </c:forEach>
</div>

<script src="${pageContext.request.contextPath}/js/itinerary-data.js?v=2"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<%-- SCRIPT 1: Map, OSRM Route Calculation & Google Maps Directions --%>
<script>
    (function () {
        const mapElement = document.getElementById('itineraryMap');
        const emptyState = document.getElementById('mapEmptyState');
        const countElement = document.getElementById('mapPointCount');
        const dayFilter = document.getElementById('mapDayFilter');
        const legFilter = document.getElementById('mapLegFilter');
        const routeInfo = document.getElementById('mapRouteInfo');
        const directionsLink = document.getElementById('mapDirectionsLink');

        if (!mapElement || typeof L === 'undefined') {
            return;
        }

        const allPoints = Array.from(document.querySelectorAll('.itinerary-map-point')).map(LocalTripSchedule.readPoint);

        const map = L.map(mapElement, {
            zoomControl: true,
            attributionControl: false
        }).setView([10.8231, 106.6297], 12);

        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19
        }).addTo(map);

        const markersLayer = L.layerGroup().addTo(map);
        const linesLayer = L.layerGroup().addTo(map);
        let requestController = null;
        let renderVersion = 0;

        function clearMapLayers() {
            if (requestController) {
                requestController.abort();
            }
            requestController = null;
            markersLayer.clearLayers();
            linesLayer.clearLayers();

            if (routeInfo) {
                routeInfo.classList.add('d-none');
                routeInfo.innerHTML = '';
            }
            if (directionsLink) {
                directionsLink.classList.add('d-none');
                directionsLink.removeAttribute('href');
            }
        }

        function pointsForDay(day) {
            return LocalTripSchedule.pointsForDay(allPoints, day);
        }

        function updateLegOptions(day) {
            if (!legFilter) return;
            const points = pointsForDay(day);

            legFilter.innerHTML = '<option value="ALL">Full day route (All legs)</option>';
            legFilter.disabled = (day === 'ALL' || points.length < 2);

            if (day !== 'ALL') {
                for (let i = 0; i < points.length - 1; i++) {
                    const label = 'Leg ' + (i + 1) + ': ' + points[i].name + ' → ' + points[i + 1].name;
                    const opt = document.createElement('option');
                    opt.value = String(i);
                    opt.textContent = label;
                    legFilter.appendChild(opt);
                }
            }
        }

        function showMapForDay(day) {
            clearMapLayers();
            const version = ++renderVersion;

            let points = pointsForDay(day);
            const dayPoints = points.slice();

            if (day !== 'ALL' && legFilter && legFilter.value !== 'ALL') {
                const index = Number(legFilter.value);
                points = points.slice(index, index + 2);
            }

            if (countElement) {
                countElement.textContent = points.length + ' stops';
            }

            if (!points.length) {
                if (emptyState) emptyState.classList.remove('d-none');
                map.setView([10.8231, 106.6297], 12);
                return;
            }

            if (emptyState) emptyState.classList.add('d-none');

            const latLngs = points.map(p => [p.lat, p.lng]);

            points.forEach((point, index) => {
                const number = (day === 'ALL') ? (index + 1) : (dayPoints.indexOf(point) + 1);

                const icon = L.divIcon({
                    className: 'lt-map-pin-container',
                    html: '<div class="lt-map-pin">' + number + '</div>',
                    iconSize: [24, 24],
                    iconAnchor: [12, 12]
                });

                const directUrl = 'https://www.google.com/maps/dir/?api=1&destination=' + encodeURIComponent(point.lat + ',' + point.lng) + '&travelmode=driving';

                const popupHtml = '<div style="font-size:12px; line-height:1.4;">'
                                + '<strong>' + number + '. ' + point.name + '</strong><br>'
                                + '<span style="color:#64748b;">' + point.date + (point.start ? ' (' + point.start + ')' : '') + '</span><br>'
                                + '<a href="' + directUrl + '" target="_blank" rel="noopener noreferrer" style="color:#175b43; font-weight:700; text-decoration:none;">🧭 Directions Google Maps ↗</a>'
                                + '</div>';

                L.marker([point.lat, point.lng], {icon: icon})
                    .addTo(markersLayer)
                    .bindPopup(popupHtml);
            });

            map.fitBounds(L.latLngBounds(latLngs), {padding: [30, 30], maxZoom: 16});

            if (routeInfo) routeInfo.classList.remove('d-none');

            // ALL DAYS OVERVIEW
            if (day === 'ALL') {
                const groups = new Map();
                points.forEach(point => {
                    if (!groups.has(point.date)) groups.set(point.date, []);
                    groups.get(point.date).push([point.lat, point.lng]);
                });

                const colors = ['#175b43', '#1a73e8', '#c06721', '#8254a0', '#059669'];
                let cIdx = 0;
                groups.forEach(coords => {
                    if (coords.length > 1) {
                        L.polyline(coords, {
                            color: colors[cIdx % colors.length],
                            weight: 3.5,
                            dashArray: '6, 6'
                        }).addTo(linesLayer);
                    }
                    cIdx++;
                });

                if (directionsLink && points.length > 0) {
                    directionsLink.href = LocalTripSchedule.directionsUrl(points);
                    directionsLink.innerHTML = '🗺️ Full Route Directions (Google Maps) ↗';
                    directionsLink.classList.remove('d-none');
                }

                if (routeInfo) {
                    routeInfo.innerHTML = '🗺️ Showing routes between days. Select a specific day above to view leg details.';
                }
                return;
            }

            // SINGLE STOP
            if (points.length === 1) {
                const dest = points[0];
                if (directionsLink) {
                    directionsLink.href = 'https://www.google.com/maps/dir/?api=1&destination=' + encodeURIComponent(dest.lat + ',' + dest.lng) + '&travelmode=driving';
                    directionsLink.innerHTML = '🗺️ Directions from current location (Google Maps) ↗';
                    directionsLink.classList.remove('d-none');
                }
                if (routeInfo) {
                    routeInfo.innerHTML = '📍 1 stop. Click <strong>Directions</strong> to navigate from your current location with Google Maps.';
                }
                return;
            }

            // MULTIPLE STOPS / SPECIFIC LEG
            if (directionsLink) {
                directionsLink.href = LocalTripSchedule.directionsUrl(points);
                directionsLink.innerHTML = (legFilter && legFilter.value === 'ALL')
                    ? '🗺️ Full Day Directions (Google Maps) ↗'
                    : '🗺️ Leg Directions (Google Maps) ↗';
                directionsLink.classList.remove('d-none');
            }

            const fallback = L.polyline(latLngs, {
                color: '#175b43',
                weight: 4,
                dashArray: '6, 6',
                opacity: 0.6
            }).addTo(linesLayer);

            if (routeInfo) {
                routeInfo.innerHTML = '⏳ Calculating driving distance and duration...';
            }

            requestController = new AbortController();
            const coordinates = points.map(p => p.lng + ',' + p.lat).join(';');

            fetch('https://router.project-osrm.org/route/v1/driving/' + coordinates + '?overview=full&geometries=geojson', {
                signal: requestController.signal
            }).then(resp => {
                if (!resp.ok) throw new Error('OSRM error');
                return resp.json();
            }).then(data => {
                if (version !== renderVersion) return;
                if (!data.routes || !data.routes.length) throw new Error('No route');

                const route = data.routes[0];
                linesLayer.removeLayer(fallback);

                const line = L.geoJSON(route.geometry, {
                    style: {
                        color: '#175b43',
                        weight: 4.5
                    }
                }).addTo(linesLayer);

                const km = (route.distance / 1000).toFixed(1);
                const mins = Math.max(2, Math.round(route.duration / 60));

                if (routeInfo) {
                    const labelPrefix = (legFilter && legFilter.value !== 'ALL') ? 'Selected leg: ' : 'Full day route: ';
                    routeInfo.innerHTML = '🚗 <strong>' + labelPrefix + '</strong>' + km + ' km · approx. <strong>' + mins + ' mins</strong> drive.';
                }

                map.fitBounds(line.getBounds(), {padding: [30, 30]});
            }).catch(err => {
                if (err.name === 'AbortError' || version !== renderVersion) return;
                if (routeInfo) {
                    routeInfo.innerHTML = '🛣️ Showing estimated route between stops.';
                }
            });
        }

        if (dayFilter) {
            dayFilter.addEventListener('change', function () {
                updateLegOptions(this.value);
                showMapForDay(this.value);
            });
        }

        if (legFilter) {
            legFilter.addEventListener('change', function () {
                showMapForDay(dayFilter ? dayFilter.value : 'ALL');
            });
        }

        updateLegOptions('ALL');
        showMapForDay('ALL');

        window.itineraryMapApi = {
            setDay: function(d) {
                if (dayFilter) dayFilter.value = d;
                updateLegOptions(d);
                showMapForDay(d);
            }
        };
    })();
</script>

<%-- SCRIPT 2: Day Tabs Navigation & Inter-stop Distance Measurement --%>
<script>
    (function () {
        const tabs = document.getElementById('itineraryDayTabs');
        if (!tabs) return;

        const rows = Array.from(document.querySelectorAll('.lt-stop-card.lt-activity-row'));
        const connectors = Array.from(document.querySelectorAll('.lt-travel-connector.lt-connector-row'));
        const mapDayFilter = document.getElementById('mapDayFilter');
        const weatherDayFilter = document.getElementById('weatherDayFilter');
        const addBtn = document.getElementById('addDestinationBtn');
        const dates = [...new Set(rows.map(row => row.dataset.activityDate).filter(Boolean))];

        dates.forEach((date, index) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'lt-day-tab';
            button.dataset.day = date;

            const parts = date.split('-');
            const dateLabel = parts.length === 3 ? parts[2] + '/' + parts[1] : date;

            button.innerHTML = '<span>Day ' + (index + 1) + '</span><small>• ' + dateLabel + '</small>';
            tabs.appendChild(button);
        });

        function calculateDistance(lat1, lon1, lat2, lon2) {
            if (!lat1 || !lon1 || !lat2 || !lon2) return null;
            const R = 6371e3;
            const phi1 = lat1 * Math.PI / 180;
            const phi2 = lat2 * Math.PI / 180;
            const deltaPhi = (lat2 - lat1) * Math.PI / 180;
            const deltaLambda = (lon2 - lon1) * Math.PI / 180;
            const a = Math.sin(deltaPhi / 2) * Math.sin(deltaPhi / 2) +
                      Math.cos(phi1) * Math.cos(phi2) *
                      Math.sin(deltaLambda / 2) * Math.sin(deltaLambda / 2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            return R * c;
        }

        function updateConnectorsAndIndices(selectedDay) {
            let visibleIndex = 0;
            const visibleRows = [];

            rows.forEach((row) => {
                const match = selectedDay === 'ALL' || row.dataset.activityDate === selectedDay;
                row.style.display = match ? 'flex' : 'none';
                if (match) {
                    visibleIndex++;
                    const badge = row.querySelector('.lt-stop-badge');
                    if (badge) badge.textContent = visibleIndex;
                    visibleRows.push(row);
                }
            });

            connectors.forEach((conn, idx) => {
                const parentRow = rows[idx];
                const nextRow = rows[idx + 1];
                const match = selectedDay === 'ALL' || conn.dataset.activityDate === selectedDay;
                const isLastVisible = parentRow === visibleRows[visibleRows.length - 1];

                if (!match || isLastVisible || !parentRow || parentRow.style.display === 'none') {
                    conn.style.display = 'none';
                } else {
                    conn.style.display = 'flex';
                    const lat1 = parseFloat(parentRow.dataset.lat);
                    const lng1 = parseFloat(parentRow.dataset.lng);
                    const lat2 = nextRow ? parseFloat(nextRow.dataset.lat) : null;
                    const lng2 = nextRow ? parseFloat(nextRow.dataset.lng) : null;
                    const dist = calculateDistance(lat1, lng1, lat2, lng2);
                    const textEl = conn.querySelector('.lt-connector-text');
                    if (textEl) {
                        if (dist && dist > 0) {
                            if (dist < 1000) {
                                const mins = Math.max(3, Math.round(dist / 80));
                                textEl.textContent = '🚶 ' + Math.round(dist) + 'm • ' + mins + ' mins walk';
                            } else {
                                const km = (dist / 1000).toFixed(1);
                                const mins = Math.max(4, Math.round(dist / 350));
                                textEl.textContent = '🚕 ' + km + ' km • ' + mins + ' mins taxi';
                            }
                        } else {
                            textEl.textContent = '🚶 800m • 10 mins walk';
                        }
                    }
                }
            });

            if (addBtn) {
                if (selectedDay !== 'ALL') {
                    const dayIdx = dates.indexOf(selectedDay) + 1;
                    addBtn.textContent = '+ Add Destination to Day ' + (dayIdx > 0 ? dayIdx : '');
                } else {
                    addBtn.textContent = '+ Add Destination to Itinerary';
                }
            }
        }

        tabs.addEventListener('click', event => {
            const button = event.target.closest('[data-day]');
            if (!button) return;

            const selectedDay = button.dataset.day;

            tabs.querySelectorAll('.lt-day-tab').forEach(tab => {
                const active = tab === button;
                tab.classList.toggle('is-active', active);
                tab.setAttribute('aria-pressed', active);
            });

            updateConnectorsAndIndices(selectedDay);

            if (window.itineraryMapApi) {
                window.itineraryMapApi.setDay(selectedDay);
            }

            if (weatherDayFilter) {
                weatherDayFilter.value = selectedDay;
                weatherDayFilter.dispatchEvent(new Event('change', {bubbles: true}));
            }
        });

        updateConnectorsAndIndices('ALL');
    })();
</script>

<%-- SCRIPT 3: Open-Meteo Weather Forecast --%>
<script>
    (function () {
        const list = document.getElementById('weatherList');
        const status = document.getElementById('weatherStatus');
        const notice = document.getElementById('weatherNotice');
        const dayFilter = document.getElementById('weatherDayFilter');
        const weatherCache = new Map();
        let weatherRenderVersion = 0;

        if (!list || !status || !notice) return;

        const points = Array.from(document.querySelectorAll('.itinerary-map-point')).map(LocalTripSchedule.readPoint);

        function escapeHtml(value) {
            return String(value == null ? '' : value)
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#039;');
        }

        function hourKey(start) { return LocalTripSchedule.hourKey(start); }
        function dateDiffDays(dateString) { return LocalTripSchedule.dateDiffDays(dateString); }

        function formatWeatherDate(value) {
            const parts = value.split('-');
            return parts.length === 3 ? parts[2] + '/' + parts[1] + '/' + parts[0] : value;
        }

        function createCard(point, data) {
            const temperature = data.temperature_2m;
            const rain = data.precipitation_probability;
            let weatherEmoji = '☀️';
            let weatherLabel = 'Clear & Sunny';
            if (rain != null && rain > 50) {
                weatherEmoji = '🌧️';
                weatherLabel = 'Rain expected (' + rain + '%)';
            } else if (rain != null && rain > 20) {
                weatherEmoji = '⛅';
                weatherLabel = 'Partly Cloudy (' + rain + '%)';
            }

            return '<div class="col-12 col-sm-6">'
                    + '<div class="lt-weather-item-card">'
                    + '<div class="d-flex justify-content-between align-items-start mb-2">'
                    + '<div class="fw-bold text-truncate" style="font-size: 13px; color: #143b2d; max-width: 80%;">'
                    + escapeHtml(point.name)
                    + '</div>'
                    + '<span style="font-size: 18px;" title="' + weatherLabel + '">' + weatherEmoji + '</span>'
                    + '</div>'
                    + '<div class="d-flex justify-content-between align-items-center py-1 border-bottom" style="font-size: 12px; border-color: #f1f5f9;">'
                    + '<span style="color: #64748b;">Time</span>'
                    + '<strong style="color: #334155;">' + escapeHtml(formatWeatherDate(point.date)) + ' (' + escapeHtml(point.start) + (point.end ? ' – ' + escapeHtml(point.end) : '') + ')</strong>'
                    + '</div>'
                    + '<div class="d-flex justify-content-between align-items-center py-1 border-bottom" style="font-size: 12px; border-color: #f1f5f9;">'
                    + '<span style="color: #64748b;">Temperature</span>'
                    + '<strong style="color: #175b43; font-size: 14px;">' + (temperature == null ? '--' : Number(temperature).toFixed(0) + '°C') + '</strong>'
                    + '</div>'
                    + '<div class="d-flex justify-content-between align-items-center pt-1" style="font-size: 12px;">'
                    + '<span style="color: #64748b;">Precipitation</span>'
                    + '<strong style="color: ' + (rain > 40 ? '#dc2626' : '#2563eb') + ';">' + (rain == null ? '--' : Number(rain) + '%') + '</strong>'
                    + '</div>'
                    + '</div>'
                    + '</div>';
        }

        function createUnavailableCard(point, message) {
            return '<div class="col-12 col-sm-6">'
                    + '<div class="lt-weather-item-card" style="opacity: 0.85;">'
                    + '<div class="fw-bold text-truncate mb-2" style="font-size: 13px; color: #143b2d;">'
                    + escapeHtml(point.name)
                    + '</div>'
                    + '<div class="d-flex justify-content-between align-items-center py-1 border-bottom" style="font-size: 12px; border-color: #f1f5f9;">'
                    + '<span style="color: #64748b;">Time</span>'
                    + '<strong style="color: #334155;">' + escapeHtml(formatWeatherDate(point.date)) + ' (' + escapeHtml(point.start) + ')</strong>'
                    + '</div>'
                    + '<p class="text-muted small mt-2 mb-0" style="font-size: 11px;">'
                    + escapeHtml(message)
                    + '</p>'
                    + '</div>'
                    + '</div>';
        }

        async function fetchWeather(point) {
            if (!LocalTripSchedule.hasCoordinates(point)) {
                return {unavailable: true, reason: 'Destination has no valid GPS coordinates.'};
            }
            if (!Number.isFinite(dateDiffDays(point.date))) {
                return {unavailable: true, reason: 'Invalid activity date.'};
            }
            const hour = hourKey(point.start);
            if (!hour) {
                return {unavailable: true, reason: 'No valid scheduled time.'};
            }

            const diff = dateDiffDays(point.date);
            if (diff < 0 || diff > 15) {
                return {
                    unavailable: true,
                    reason: diff < 0 ? 'Activity date is in the past.' : 'Trip date is outside the 16-day forecast range.'
                };
            }

            const url = 'https://api.open-meteo.com/v1/forecast'
                      + '?latitude=' + encodeURIComponent(point.lat)
                      + '&longitude=' + encodeURIComponent(point.lng)
                      + '&hourly=temperature_2m,precipitation_probability'
                      + '&timezone=Asia%2FHo_Chi_Minh'
                      + '&start_date=' + encodeURIComponent(point.date)
                      + '&end_date=' + encodeURIComponent(point.date);

            const controller = new AbortController();
            const timeout = setTimeout(() => controller.abort(), 12000);
            let response, data;
            try {
                response = await fetch(url, {signal: controller.signal});
                if (!response.ok) throw new Error('Weather API HTTP Error');
                data = await response.json();
            } finally {
                clearTimeout(timeout);
            }

            const hourly = data.hourly;
            if (!hourly || !Array.isArray(hourly.time)) {
                throw new Error('Weather data unavailable.');
            }

            const index = hourly.time.findIndex(value => value === point.date + 'T' + hour);
            if (index < 0) {
                throw new Error('Forecast hour not found.');
            }

            return {
                temperature_2m: (hourly.temperature_2m ? hourly.temperature_2m[index] : null),
                precipitation_probability: (hourly.precipitation_probability ? hourly.precipitation_probability[index] : null)
            };
        }

        function getCachedWeather(point) {
            const key = [point.lat, point.lng, point.date, hourKey(point.start)].join('|');
            if (!weatherCache.has(key)) {
                const pending = fetchWeather(point).catch(err => {
                    weatherCache.delete(key);
                    throw err;
                });
                weatherCache.set(key, pending);
            }
            return weatherCache.get(key);
        }

        async function loadWeather() {
            const currentVersion = ++weatherRenderVersion;
            const selectedDay = dayFilter ? dayFilter.value : 'ALL';

            const selectedPoints = points.filter(p => selectedDay === 'ALL' || p.date === selectedDay);

            list.innerHTML = '';
            notice.textContent = '';
            notice.classList.add('d-none');

            if (!selectedPoints.length) {
                status.textContent = 'No forecast data';
                notice.classList.remove('d-none');
                notice.textContent = 'No activities with valid coordinates and scheduled time to forecast.';
                return;
            }

            status.textContent = 'Loading weather forecast...';

            let successCount = 0;
            const fragments = [];

            for (const point of selectedPoints) {
                if (currentVersion !== weatherRenderVersion) return;
                try {
                    const data = await getCachedWeather(point);
                    if (currentVersion !== weatherRenderVersion) return;
                    if (data.unavailable) {
                        fragments.push(createUnavailableCard(point, data.reason));
                    } else {
                        successCount++;
                        fragments.push(createCard(point, data));
                    }
                } catch (error) {
                    if (currentVersion !== weatherRenderVersion) return;
                    fragments.push(createUnavailableCard(point, 'Weather unavailable at the moment. Please try again later.'));
                }
            }

            if (currentVersion !== weatherRenderVersion) return;

            list.innerHTML = fragments.join('');
            status.textContent = successCount + '/' + selectedPoints.length + ' stops forecasted';
        }

        // Initialize day filter options for weatherDayFilter
        const dates = [...new Set(points.map(p => p.date).filter(Boolean))];
        dates.forEach((date, idx) => {
            const opt = document.createElement('option');
            opt.value = date;
            opt.textContent = 'Day ' + (idx + 1) + ' (' + formatWeatherDate(date) + ')';
            dayFilter.appendChild(opt);
        });

        dayFilter.addEventListener('change', loadWeather);
        loadWeather();
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
