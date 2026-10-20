<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  

<c:set var="pageTitle" value="Itinerary" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<fmt:setLocale value="en_US" scope="page"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

<div class="lt-itinerary-container">

    <%-- 1. App-style Mobile Header (‹, Title, •••) --%>
    <div class="lt-itinerary-header">
        <a href="${pageContext.request.contextPath}/trips" class="lt-btn-circle" aria-label="Back to trips">‹</a>
        <h1 class="lt-itinerary-header-title"><c:out value="${trip.name}"/></h1>
        <div class="dropdown">
            <button class="lt-btn-circle" type="button" data-bs-toggle="dropdown" aria-expanded="false" aria-label="More options">•••</button>
            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 rounded-3">
                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}">Trip details</a></li>
                <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/itinerary/add?tripId=${trip.id}">+ Add destination</a></li>
                </c:if>
                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}">Expenses</a></li>
            </ul>
        </div>
    </div>

    <%-- 2. Members Bar & NFC Share --%>
    <div class="lt-itinerary-member-bar">
        <div class="lt-member-cluster">
            <div class="lt-avatar-stack">
                <c:forEach var="m" items="${members}" varStatus="mStatus">
                    <c:if test="${mStatus.index < 3}">
                        <span class="lt-member-avatar" title="<c:out value='${m.fullName}'/>">
                            <c:out value="${fn:substring(m.fullName, 0, 1)}"/>
                        </span>
                    </c:if>
                </c:forEach>
                <c:if test="${empty members}">
                    <span class="lt-member-avatar">M</span>
                    <span class="lt-member-avatar">L</span>
                    <span class="lt-member-avatar">N</span>
                </c:if>
            </div>
            <span class="lt-member-count">
                <c:choose>
                    <c:when test="${not empty members}">${fn:length(members)} members</c:when>
                    <c:otherwise>3 members</c:otherwise>
                </c:choose>
            </span>
        </div>
        <button type="button" class="lt-nfc-share-btn" onclick="shareTripViaNFC()">
            <span>🔗</span> Share trip
        </button>
    </div>

    <%-- 3. Day Tabs --%>
    <div class="lt-day-tabs-wrap">
        <nav class="lt-day-tabs" id="itineraryDayTabs" aria-label="Itinerary days">
            <button type="button" class="lt-day-tab is-active" data-day="ALL">
                <span>All days</span>
                <small>Overview</small>
            </button>
        </nav>
    </div>

    <%-- 4. Leaflet Map --%>
    <div class="lt-itinerary-map-card">
        <div id="itineraryMap" class="localtrip-map"></div>
    </div>

    <%-- Ẩn các control kỹ thuật của Map để Leaflet JS vẫn đọc được mà không vỡ UI --%>
    <select id="mapDayFilter" class="d-none" aria-hidden="true">
        <option value="ALL">All</option>
        <c:set var="prevMapDate" value=""/>
        <c:forEach var="item" items="${items}">
            <c:if test="${item.date != prevMapDate}">
                <option value="${item.date}">${item.date}</option>
                <c:set var="prevMapDate" value="${item.date}"/>
            </c:if>
        </c:forEach>
    </select>
    <select id="mapLegFilter" class="d-none" aria-hidden="true"><option value="ALL">Full day</option></select>
    <div id="mapRouteInfo" class="d-none" aria-hidden="true"></div>
    <a id="mapDirectionsLink" class="d-none" aria-hidden="true"></a>
    <span id="mapPointCount" class="d-none" aria-hidden="true"></span>
    <div id="mapEmptyState" class="d-none" aria-hidden="true"></div>

    <%-- 5. Timeline List (Cards + Travel Connectors) --%>
    <div class="lt-timeline-list" id="itineraryTimelineList">
        <c:choose>
            <c:when test="${empty items}">
                <div class="app-card text-center p-4">
                    <p class="text-muted mb-2">No activities in this itinerary yet.</p>
                    <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
                        <a href="${pageContext.request.contextPath}/itinerary/add?tripId=${trip.id}" class="btn btn-sm btn-brand">
                            + Add first destination
                        </a>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="item" items="${items}" varStatus="status">
                    <div class="lt-stop-card lt-activity-row" data-activity-date="${item.date}" data-lat="${item.latitude}" data-lng="${item.longitude}">
                        <div class="lt-stop-left">
                            <span class="lt-drag-handle" title="Drag to reorder">⋮⋮</span>
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
                            <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
                                <a class="lt-stop-change-link" href="${pageContext.request.contextPath}/itinerary/edit?tripId=${trip.id}&amp;itemId=${item.id}">
                                    Change
                                </a>
                            </c:if>
                        </div>
                    </div>

                    <%-- Chặng di chuyển nối giữa 2 địa điểm --%>
                    <div class="lt-travel-connector lt-connector-row" data-activity-date="${item.date}">
                        <span class="lt-connector-line"></span>
                        <span class="lt-connector-text">🚶 800m • 10 mins walk</span>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>

        <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
            <a id="addDestinationBtn" href="${pageContext.request.contextPath}/itinerary/add?tripId=${trip.id}" class="lt-add-stop-btn">
                + Add destination
            </a>
        </c:if>
    </div>

    <%-- 6. Bottom Action Bar --%>
    <div class="lt-itinerary-footer-bar">
        <div class="lt-group-status-box">
            <span class="lt-group-status-lbl">Itinerary status</span>
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
                    <span class="lt-group-status-cnt" style="color: #f59e0b;">No activities yet</span>
                </c:when>
                <c:otherwise>
                    <span class="lt-group-status-cnt" style="color: #165b43;">
                        ${fn:length(items)} ${fn:length(items) == 1 ? 'activity' : 'activities'} scheduled
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
                    + Add activity first
                </a>
            </c:when>
            <c:when test="${trip.role == 'OWNER'}">
                <form method="post" action="${pageContext.request.contextPath}/itinerary/confirm" style="margin: 0;"
                      onsubmit="return confirm('Confirm and finalize this itinerary schedule for the group?');">
                    <input type="hidden" name="tripId" value="${trip.id}">
                    <button id="confirmItineraryBtn" type="submit" class="lt-btn-confirm-action">
                        ✓ Confirm itinerary
                    </button>
                </form>
            </c:when>
            <c:otherwise>
                <button type="button" class="lt-btn-confirm-action" style="opacity: 0.75; cursor: default;" title="Only the Trip Lead can confirm the itinerary" disabled>
                    Awaiting Trip Lead
                </button>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%-- Dữ liệu tọa độ cho Leaflet Map --%>
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

<script src="${pageContext.request.contextPath}/js/itinerary-data.js?v=1"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

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
            zoomControl: false,
            attributionControl: false
        }).setView([10.8231, 106.6297], 12);

        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19
        }).addTo(map);

        const markersLayer = L.layerGroup().addTo(map);
        const linesLayer = L.layerGroup().addTo(map);

        function clearMapLayers() {
            markersLayer.clearLayers();
            linesLayer.clearLayers();
        }

        function pointsForDay(day) {
            return LocalTripSchedule.pointsForDay(allPoints, day);
        }

        function showMapForDay(day) {
            clearMapLayers();
            let points = pointsForDay(day);

            if (!points.length) {
                map.setView([10.8231, 106.6297], 12);
                return;
            }

            const latLngs = points.map(p => [p.lat, p.lng]);

            points.forEach((point, index) => {
                const number = index + 1;
                const icon = L.divIcon({
                    className: 'lt-map-pin-container',
                    html: '<div class="lt-map-pin">' + number + '</div>',
                    iconSize: [22, 22],
                    iconAnchor: [11, 11]
                });

                L.marker([point.lat, point.lng], {icon: icon})
                    .addTo(markersLayer)
                    .bindPopup('<strong>' + number + '. ' + point.name + '</strong>');
            });

            if (latLngs.length > 1) {
                const polyline = L.polyline(latLngs, {
                    color: '#175b43',
                    weight: 3,
                    dashArray: '5, 5'
                }).addTo(linesLayer);
                map.fitBounds(polyline.getBounds(), {padding: [20, 20]});
            } else if (latLngs.length === 1) {
                map.setView(latLngs[0], 14);
            }
        }

        if (dayFilter) {
            dayFilter.addEventListener('change', function () {
                showMapForDay(this.value);
            });
        }

        showMapForDay('ALL');
    })();
</script>

<script>
    (function () {
        const tabs = document.getElementById('itineraryDayTabs');
        if (!tabs) return;

        const rows = Array.from(document.querySelectorAll('.lt-stop-card.lt-activity-row'));
        const connectors = Array.from(document.querySelectorAll('.lt-travel-connector.lt-connector-row'));
        const mapDayFilter = document.getElementById('mapDayFilter');
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
                    addBtn.textContent = '+ Add place to Day ' + (dayIdx > 0 ? dayIdx : '');
                } else {
                    addBtn.textContent = '+ Add destination';
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

            if (mapDayFilter) {
                const optionExists = Array.from(mapDayFilter.options).some(option => option.value === selectedDay);
                mapDayFilter.value = selectedDay === 'ALL' || optionExists ? selectedDay : 'ALL';
                mapDayFilter.dispatchEvent(new Event('change', {bubbles: true}));
            }
        });

        updateConnectorsAndIndices('ALL');
    })();



    function shareTripViaNFC() {
        if (navigator.share) {
            navigator.share({
                title: '${fn:escapeXml(trip.name)} - LocalTrip',
                text: 'Join our trip on LocalTrip!',
                url: window.location.href
            }).catch(() => {});
        } else if (navigator.clipboard) {
            navigator.clipboard.writeText(window.location.href).then(() => {
                alert('Trip link copied to clipboard! Share it with friends or tap an NFC tag.');
            });
        } else {
            alert('Trip link: ' + window.location.href);
        }
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>