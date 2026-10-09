<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Lịch trình" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<link rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

<style>
    .itinerary-day-filter {
        display: flex;
        align-items: center;
        flex-wrap: nowrap;
        gap: 10px;
        max-width: 100%;
    }

    .itinerary-day-filter label {
        margin: 0;
        flex: 0 0 auto;
        white-space: nowrap;
        font-size: 14px;
    }

    .itinerary-day-filter .form-select {
        flex: 0 1 170px;
        width: 170px;
        min-width: 110px;
    }

    .itinerary-day-filter .badge {
        flex: 0 0 auto;
        white-space: nowrap;
    }

    .itinerary-leg-filter {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 10px;
    }

    .itinerary-leg-filter label {
        margin: 0;
        flex-shrink: 0;
        white-space: nowrap;
    }

    .itinerary-leg-filter .form-select {
        width: auto;
        max-width: 100%;
    }

    .weather-card {
        border: 1px solid #e9ecef;
        border-radius: 12px;
        padding: 16px;
        height: 100%;
        background: #fff;
    }

    .weather-info-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        padding: 8px 0;
        border-bottom: 1px solid #f1f3f5;
        font-size: 14px;
    }

    .weather-info-row:last-child {
        border-bottom: 0;
        padding-bottom: 0;
    }

    .weather-info-row span {
        color: #6c757d;
    }

    .weather-temp {
        font-size: 20px;
        font-weight: 700;
    }

    .itinerary-table-wrap {
        overflow-x: auto;
    }

    #itineraryMap {
        min-height: 400px;
    }
</style>

<div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
    <div>
        <h3 class="mb-1">
            Lịch trình - <c:out value="${trip.name}"/>
        </h3>
        <p class="text-muted mb-0">
            Xem các địa điểm và hành trình dự kiến trực tiếp trên bản đồ.
        </p>
    </div>

    <a href="${pageContext.request.contextPath}/recommendations?tripId=${trip.id}"
       class="btn btn-outline-secondary btn-sm">
        ← Gợi ý địa điểm
    </a>
</div>

<c:if test="${param.auto == 'success'}">
    <div class="alert alert-success">
        Hệ thống đã tự động thêm
        <strong><c:out value="${param.count}"/></strong>
        địa điểm theo sở thích nhóm, gồm các hoạt động ăn uống,
        cà phê, tham quan, giải trí hoặc mua sắm.
    </div>
</c:if>

<c:if test="${param.auto == 'empty'}">
    <div class="alert alert-warning">
        Chưa có đủ dữ liệu để tự động tạo lịch trình.
        Hãy để các thành viên chọn sở thích trước.
    </div>
</c:if>

<c:if test="${trip.role == 'OWNER'
              and (trip.status == 'PLANNING'
              or trip.status == 'ONGOING')}">
      <div class="app-card mb-4 itinerary-mode-card">
          <h5 class="mb-2">Chọn cách lập lịch trình</h5>

          <div class="row g-3">
              <div class="col-md-6">
                  <div class="border rounded p-3 h-100">
                      <h6>Tự soạn lịch trình</h6>

                      <p class="text-muted small mb-3">
                          Trưởng nhóm tự chọn địa điểm từ danh sách gợi ý
                          và quyết định ngày, giờ, chi phí.
                      </p>

                      <a href="${pageContext.request.contextPath}/recommendations?tripId=${trip.id}"
                         class="btn btn-outline-secondary btn-sm">
                          Chọn địa điểm
                      </a>
                  </div>
              </div>

              <div class="col-md-6">
                  <div class="border rounded p-3 h-100">
                      <h6>Hệ thống tự xếp lịch</h6>

                      <p class="text-muted small mb-3">
                          Hệ thống chia mỗi ngày thành các khung giờ
                          07:00–11:00, 11:00–17:00 và 17:00–22:00.
                          Địa điểm được chọn dựa trên sở thích nhóm,
                          đánh giá và ngân sách.
                      </p>

                      <form method="post"
                            action="${pageContext.request.contextPath}/itinerary/auto"
                            onsubmit="return confirm('Tự động xếp lịch theo sở thích nhóm?');">
                          <input type="hidden"
                                 name="tripId"
                                 value="${trip.id}">

                          <button type="submit"
                                  class="btn btn-brand btn-sm">
                              Tạo lịch trình tự động
                          </button>
                      </form>
                  </div>
              </div>
          </div>
      </div>
</c:if>

<div class="app-card mb-4">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <div>
            <h5 class="mb-1">Bản đồ hành trình</h5>
            <small class="text-muted">
                Chọn ngày để xem tuyến đường hoặc từng chặng.
            </small>
        </div>

        <div class="itinerary-day-filter">
            <label for="mapDayFilter">Ngày:</label>

            <select id="mapDayFilter"
                    class="form-select form-select-sm">
                <option value="ALL">Tất cả</option>

                <c:set var="previousMapDate" value=""/>

                <c:forEach var="item" items="${items}">
                    <c:if test="${item.date != previousMapDate}">
                        <option value="${item.date}">
                            ${item.date}
                        </option>

                        <c:set var="previousMapDate"
                               value="${item.date}"/>
                    </c:if>
                </c:forEach>
            </select>

            <span class="badge bg-secondary"
                  id="mapPointCount">
                0 điểm
            </span>
        </div>
    </div>

    <div class="itinerary-leg-filter mb-3">
        <label for="mapLegFilter">Chặng:</label>

        <select id="mapLegFilter"
                class="form-select form-select-sm"
                disabled>
            <option value="ALL">Toàn bộ trong ngày</option>
        </select>

        <a id="mapDirectionsLink"
           class="btn btn-outline-primary btn-sm d-none"
           target="_blank"
           rel="noopener noreferrer">
            Mở chỉ đường
        </a>
    </div>

    <div id="mapRouteInfo"
         class="alert alert-light border py-2 mb-3 d-none">
    </div>

    <div class="localtrip-map-wrap">
        <div id="itineraryMap" class="localtrip-map"></div>
    </div>

    <div id="mapEmptyState"
         class="alert alert-light border mt-3 mb-0 d-none">
        Ngày này chưa có địa điểm đủ tọa độ để hiển thị bản đồ.
    </div>
</div>

<div class="app-card mb-4" id="itineraryWeatherCard">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <div>
            <h5 class="mb-1">Thời tiết theo lịch trình</h5>

            <small class="text-muted">
                Dự báo được lấy theo tọa độ và khung giờ của hoạt động.
                Kết quả có thể thay đổi khi gần ngày đi.
            </small>
        </div>

        <span class="badge bg-light text-dark border"
              id="weatherStatus">
            Đang tải...
        </span>
    </div>

    <div id="weatherNotice"
         class="alert alert-light border d-none mb-3">
    </div>
    <div class="d-flex align-items-center flex-wrap gap-2 mb-3">
        <label for="weatherDayFilter" class="mb-0">
            Ngày xem thời tiết
        </label>

        <select id="weatherDayFilter"
                class="form-select"
                style="width: 190px; max-width: 100%;">
            <option value="ALL">Tất cả ngày</option>
        </select>
    </div>  
    <div id="weatherList" class="row g-3"></div>
</div>
<c:if test="${trip.status == 'COMPLETED'
              or trip.status == 'CANCELLED'}">
      <div class="alert alert-info">
          Chuyến đi đã hoàn thành hoặc đã hủy.
          Bạn vẫn có thể xem lịch trình và bản đồ,
          nhưng không thể thay đổi lịch trình.
      </div>
</c:if>

<c:choose>
    <c:when test="${empty items}">  
        <div class="empty-state app-card">
            <p>Chưa có địa điểm nào trong lịch trình.</p>
        </div>
    </c:when>

    <c:otherwise>
        <div class="app-card p-0 itinerary-table-wrap">
            <table class="table mb-0 align-middle">
                <thead>
                    <tr>
                        <th>Địa điểm</th>
                        <th>Ngày</th>
                        <th>Giờ</th>
                        <th>Ghi chú</th>
                        <th>Chi phí dự kiến</th>

                        <c:if test="${trip.role == 'OWNER'
                                      and (trip.status == 'PLANNING'
                                      or trip.status == 'ONGOING')}">
                              <th>Thao tác</th>
                              </c:if>
                    </tr>
                </thead>

                <tbody>
                    <c:forEach var="item"
                               items="${items}"
                               varStatus="status">
                        <tr>
                            <td>
                                <span class="badge bg-light text-dark border me-1">
                                    ${status.index + 1}
                                </span>

                                <c:out value="${item.placeName}"/>
                            </td>

                            <td>${item.date}</td>

                            <td>
                                ${item.startTime} - ${item.endTime}
                            </td>

                            <td>
                                <c:out value="${item.note}"/>
                            </td>

                            <td>
                                <fmt:formatNumber
                                    value="${item.estimatedCost}"
                                    type="number"/>
                                đ
                            </td>

                            <c:if test="${trip.role == 'OWNER'
                                          and (trip.status == 'PLANNING'
                                          or trip.status == 'ONGOING')}">
                                  <td>
                                      <form method="post"
                                            action="${pageContext.request.contextPath}/itinerary/delete"
                                            onsubmit="return confirm('Xóa địa điểm này khỏi lịch trình?');">
                                          <input type="hidden"
                                                 name="tripId"
                                                 value="${trip.id}">

                                          <input type="hidden"
                                                 name="itemId"
                                                 value="${item.id}">

                                          <button type="submit"
                                                  class="btn btn-sm btn-outline-danger">
                                              Xóa
                                          </button>
                                      </form>
                                  </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:otherwise>
</c:choose>

<c:if test="${trip.role != 'OWNER'}">
    <p class="text-muted mt-2">
        <em>
            Bạn là thành viên: chỉ trưởng nhóm mới có thể
            thêm hoặc xóa hoạt động trong lịch trình.
        </em>
    </p>
</c:if>

<div id="itineraryMapData"
     class="d-none"
     aria-hidden="true">
    <c:forEach var="item" items="${items}">
        <c:if test="${not empty item.latitude and not empty item.longitude}">
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
                                                        if (routeInfo) {
                                                            routeInfo.classList.remove('d-none');
                                                            routeInfo.textContent =
                                                                    'Không thể tải bản đồ. Hãy kiểm tra kết nối Internet.';
                                                        }
                                                        return;
                                                    }

                                                    const allPoints = Array.from(
                                                            document.querySelectorAll('.itinerary-map-point')
                                                            ).map(function (element) {
                                                        return {
                                                            id: Number(element.dataset.id),
                                                            name: element.dataset.name || '',
                                                            lat: Number(element.dataset.lat),
                                                            lng: Number(element.dataset.lng),
                                                            date: element.dataset.date || '',
                                                            start: element.dataset.start || '',
                                                            end: element.dataset.end || ''
                                                        };
                                                    });

                                                    const map = L.map(mapElement)
                                                            .setView([10.8231, 106.6297], 11);

                                                    const tileStatus = document.createElement('div');
                                                    tileStatus.className = 'map-tile-status';
                                                    tileStatus.textContent = 'Đang tải bản đồ...';
                                                    mapElement.parentElement.appendChild(tileStatus);

                                                    let activeTiles = null;

                                                    const tileProviders = [
                                                        {
                                                            name: 'Esri',
                                                            url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                                                            options: {
                                                                maxZoom: 19,
                                                                attribution: 'Tiles &copy; Esri'
                                                            }
                                                        },
                                                        {
                                                            name: 'OpenStreetMap',
                                                            url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                            options: {
                                                                maxZoom: 19,
                                                                attribution: '&copy; OpenStreetMap contributors'
                                                            }
                                                        },
                                                        {
                                                            name: 'CARTO',
                                                            url: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                                                            options: {
                                                                maxZoom: 19,
                                                                subdomains: 'abcd',
                                                                attribution:
                                                                        '&copy; OpenStreetMap contributors &copy; CARTO'
                                                            }
                                                        }
                                                    ];

                                                    function loadTileProvider(index) {
                                                        if (index >= tileProviders.length) {
                                                            tileStatus.textContent =
                                                                    'Không thể tải dữ liệu bản đồ. Hãy kiểm tra Internet.';
                                                            tileStatus.classList.add('map-tile-status-error');
                                                            return;
                                                        }

                                                        if (activeTiles) {
                                                            map.removeLayer(activeTiles);
                                                        }

                                                        const provider = tileProviders[index];
                                                        const layer = L.tileLayer(provider.url, provider.options);
                                                        let failed = false;

                                                        activeTiles = layer;
                                                        tileStatus.textContent =
                                                                'Đang tải bản đồ ' + provider.name + '...';

                                                        layer.on('tileerror', function () {
                                                            if (failed || activeTiles !== layer)
                                                                return;

                                                            failed = true;
                                                            loadTileProvider(index + 1);
                                                        });

                                                        layer.on('load', function () {
                                                            if (failed || activeTiles !== layer)
                                                                return;

                                                            tileStatus.textContent = 'Bản đồ: ' + provider.name;

                                                            setTimeout(function () {
                                                                if (tileStatus.parentNode) {
                                                                    tileStatus.remove();
                                                                }
                                                            }, 2200);
                                                        });

                                                        layer.addTo(map);
                                                    }

                                                    loadTileProvider(0);
                                                    L.control.scale({imperial: false}).addTo(map);

                                                    const markersLayer = L.layerGroup().addTo(map);
                                                    const linesLayer = L.layerGroup().addTo(map);

                                                    let requestController = null;
                                                    let renderVersion = 0;

                                                    const seenDates = new Set();

                                                    Array.from(dayFilter.options).forEach(function (option) {
                                                        if (seenDates.has(option.value)) {
                                                            option.remove();
                                                        } else {
                                                            seenDates.add(option.value);
                                                        }
                                                    });

                                                    function escapeHtml(value) {
                                                        return String(value == null ? '' : value)
                                                                .replace(/&/g, '&amp;')
                                                                .replace(/</g, '&lt;')
                                                                .replace(/>/g, '&gt;')
                                                                .replace(/"/g, '&quot;')
                                                                .replace(/'/g, '&#039;');
                                                    }

                                                    function clearMapLayers() {
                                                        directionsLink.textContent = 'Mở chỉ đường';
                                                        if (requestController) {
                                                            requestController.abort();
                                                        }

                                                        requestController = null;
                                                        markersLayer.clearLayers();
                                                        linesLayer.clearLayers();

                                                        routeInfo.classList.add('d-none');
                                                        routeInfo.textContent = '';

                                                        directionsLink.classList.add('d-none');
                                                        directionsLink.removeAttribute('href');
                                                    }

                                                    function pointsForDay(day) {
                                                        return allPoints.filter(function (point) {
                                                            return (day === 'ALL' || point.date === day)
                                                                    && Number.isFinite(point.lat)
                                                                    && Number.isFinite(point.lng);
                                                        }).sort(function (first, second) {
                                                            return (first.date + ' ' + first.start)
                                                                    .localeCompare(second.date + ' ' + second.start);
                                                        });
                                                    }

                                                    function updateLegOptions(day) {
                                                        const points = pointsForDay(day);

                                                        legFilter.replaceChildren(
                                                                new Option('Toàn bộ trong ngày', 'ALL')
                                                                );

                                                        legFilter.disabled = day === 'ALL' || points.length < 2;

                                                        if (day !== 'ALL') {
                                                            for (let i = 0; i < points.length - 1; i++) {
                                                                const label =
                                                                        (i + 1) + ' → ' + (i + 2) + ': '
                                                                        + points[i].name + ' → ' + points[i + 1].name;

                                                                legFilter.add(new Option(label, String(i)));
                                                            }
                                                        }
                                                    }

                                                    function showMapForDay(day) {
                                                        clearMapLayers();

                                                        const version = ++renderVersion;
                                                        emptyState.classList.add('d-none');

                                                        let points = pointsForDay(day);
                                                        const dayPoints = points.slice();

                                                        if (day !== 'ALL' && legFilter.value !== 'ALL') {
                                                            const index = Number(legFilter.value);
                                                            points = points.slice(index, index + 2);
                                                        }

                                                        countElement.textContent = points.length + ' điểm';

                                                        if (!points.length) {
                                                            emptyState.classList.remove('d-none');
                                                            map.setView([10.8231, 106.6297], 11);
                                                            return;
                                                        }

                                                        const latLngs = points.map(function (point) {
                                                            return [point.lat, point.lng];
                                                        });

                                                        points.forEach(function (point, index) {
                                                            const number = day === 'ALL'
                                                                    ? index + 1
                                                                    : dayPoints.indexOf(point) + 1;

                                                            const icon = L.divIcon({
                                                                className: 'localtrip-map-pin-wrap',
                                                                html:
                                                                        '<div class="localtrip-map-pin localtrip-map-pin-number">'
                                                                        + '<span>' + number + '</span></div>',
                                                                iconSize: [34, 42],
                                                                iconAnchor: [17, 40],
                                                                popupAnchor: [0, -36]
                                                            });

                                                            const directionsUrl =
                                                                    'https://www.google.com/maps/dir/?api=1'
                                                                    + '&destination='
                                                                    + encodeURIComponent(point.lat + ',' + point.lng)
                                                                    + '&travelmode=driving';

                                                            const detailUrl =
                                                                    '${pageContext.request.contextPath}/places/detail?placeId='
                                                                    + encodeURIComponent(point.id);

                                                            const popup =
                                                                    '<strong>' + number + '. '
                                                                    + escapeHtml(point.name) + '</strong>'
                                                                    + '<br>' + escapeHtml(point.date)
                                                                    + '<br>' + escapeHtml(point.start)
                                                                    + ' - ' + escapeHtml(point.end)
                                                                    + '<div style="display:flex;flex-direction:column;'
                                                                    + 'gap:8px;margin-top:12px;">'
                                                                    + '<a href="' + detailUrl + '">'
                                                                    + 'Xem chi tiết địa điểm</a>'
                                                                    + '<a href="' + directionsUrl + '"'
                                                                    + ' target="_blank" rel="noopener noreferrer">'
                                                                    + 'Chỉ đường từ vị trí hiện tại ↗</a>'
                                                                    + '</div>';

                                                            L.marker([point.lat, point.lng], {icon: icon})
                                                                    .addTo(markersLayer)
                                                                    .bindPopup(popup);
                                                        });

                                                        map.fitBounds(L.latLngBounds(latLngs), {
                                                            padding: [30, 30],
                                                            maxZoom: 16
                                                        });

                                                        routeInfo.classList.remove('d-none');

                                                        if (day === 'ALL') {
                                                            const groups = new Map();

                                                            points.forEach(function (point) {
                                                                if (!groups.has(point.date)) {
                                                                    groups.set(point.date, []);
                                                                }

                                                                groups.get(point.date).push([point.lat, point.lng]);
                                                            });

                                                            const colors = [
                                                                '#245b48',
                                                                '#1a73e8',
                                                                '#c06721',
                                                                '#8254a0'
                                                            ];

                                                            let colorIndex = 0;

                                                            groups.forEach(function (coordinates) {
                                                                if (coordinates.length > 1) {
                                                                    L.polyline(coordinates, {
                                                                        color: colors[colorIndex % colors.length],
                                                                        weight: 4,
                                                                        dashArray: '8 8'
                                                                    }).addTo(linesLayer);
                                                                }

                                                                colorIndex++;
                                                            });

                                                            routeInfo.textContent =
                                                                    'Các đường nét đứt nối điểm dự kiến riêng từng ngày. '
                                                                    + 'Chọn một ngày để xem tuyến đường hoặc từng chặng.';

                                                            return;
                                                        }

                                                        if (points.length === 1) {
                                                            const destination = points[0];

                                                            directionsLink.href =
                                                                    'https://www.google.com/maps/dir/?api=1'
                                                                    + '&destination='
                                                                    + encodeURIComponent(
                                                                            destination.lat + ',' + destination.lng
                                                                            )
                                                                    + '&travelmode=driving';

                                                            directionsLink.textContent =
                                                                    'Chỉ đường từ vị trí hiện tại';

                                                            directionsLink.classList.remove('d-none');

                                                            routeInfo.textContent =
                                                                    'Lịch trình có một địa điểm. '
                                                                    + 'Bấm chỉ đường để mở Google Maps và chọn '
                                                                    + 'vị trí hiện tại làm điểm xuất phát.';

                                                            return;
                                                        }

                                                        if (legFilter.value !== 'ALL') {
                                                            const first = points[0];
                                                            const last = points[points.length - 1];

                                                            directionsLink.href =
                                                                    'https://www.google.com/maps/dir/?api=1'
                                                                    + '&origin='
                                                                    + encodeURIComponent(first.lat + ',' + first.lng)
                                                                    + '&destination='
                                                                    + encodeURIComponent(last.lat + ',' + last.lng)
                                                                    + '&travelmode=driving';

                                                            directionsLink.classList.remove('d-none');
                                                        }

                                                        const fallback = L.polyline(latLngs, {
                                                            weight: 4,
                                                            dashArray: '8 8',
                                                            opacity: 0.6
                                                        }).addTo(linesLayer);

                                                        routeInfo.textContent = 'Đang tính tuyến đường dự kiến...';

                                                        requestController = new AbortController();

                                                        const coordinates = points.map(function (point) {
                                                            return point.lng + ',' + point.lat;
                                                        }).join(';');

                                                        fetch(
                                                                'https://router.project-osrm.org/route/v1/driving/'
                                                                + coordinates
                                                                + '?overview=full&geometries=geojson',
                                                                {signal: requestController.signal}
                                                        ).then(function (response) {
                                                            if (!response.ok) {
                                                                throw new Error('Không lấy được tuyến đường.');
                                                            }

                                                            return response.json();
                                                        }).then(function (data) {
                                                            if (version !== renderVersion)
                                                                return;

                                                            if (!data.routes || !data.routes.length) {
                                                                throw new Error('Không tìm thấy tuyến đường.');
                                                            }

                                                            const route = data.routes[0];

                                                            linesLayer.removeLayer(fallback);

                                                            const line = L.geoJSON(route.geometry, {
                                                                style: {
                                                                    color: '#1a73e8',
                                                                    weight: 5
                                                                }
                                                            }).addTo(linesLayer);

                                                            routeInfo.textContent =
                                                                    'Tuyến dự kiến: '
                                                                    + (route.distance / 1000).toFixed(1)
                                                                    + ' km · thời gian lái xe khoảng '
                                                                    + Math.round(route.duration / 60)
                                                                    + ' phút.';

                                                            map.fitBounds(line.getBounds(), {
                                                                padding: [30, 30]
                                                            });
                                                        }).catch(function (error) {
                                                            if (error.name === 'AbortError'
                                                                    || version !== renderVersion) {
                                                                return;
                                                            }

                                                            routeInfo.textContent =
                                                                    'Chưa lấy được tuyến đường. '
                                                                    + 'Đang hiển thị đường nối dự kiến giữa các điểm.';
                                                        });
                                                    }

                                                    dayFilter.addEventListener('change', function () {
                                                        updateLegOptions(this.value);
                                                        showMapForDay(this.value);
                                                    });

                                                    legFilter.addEventListener('change', function () {
                                                        showMapForDay(dayFilter.value);
                                                    });

                                                    updateLegOptions(dayFilter.value);
                                                    showMapForDay(dayFilter.value);
                                                })();
</script>

<script>
    (function () {
        const list = document.getElementById('weatherList');
        const status = document.getElementById('weatherStatus');
        const notice = document.getElementById('weatherNotice');
        const dayFilter = document.getElementById('weatherDayFilter');
        const weatherCache = new Map();
        let weatherRenderVersion = 0;
        if (!list || !status || !notice)
            return;

        const points = Array.from(
                document.querySelectorAll('.itinerary-map-point')
                ).map(function (element) {
            return {
                name: element.dataset.name || 'Địa điểm',
                lat: Number(element.dataset.lat),
                lng: Number(element.dataset.lng),
                date: element.dataset.date || '',
                start: element.dataset.start || '',
                end: element.dataset.end || ''
            };
        }).filter(function (point) {
            return Number.isFinite(point.lat)
                    && Number.isFinite(point.lng)
                    && point.date
                    && point.start;
        });

        function escapeHtml(value) {
            return String(value == null ? '' : value)
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#039;');
        }

        function hourKey(start) {
            const match = String(start).match(/^(\d{1,2}):(\d{2})/);

            if (!match)
                return null;

            const hour = Number(match[1]);
            const minute = Number(match[2]);

            if (hour > 23 || minute > 59)
                return null;

            return String(hour).padStart(2, '0') + ':00';
        }

        function dateDiffDays(dateString) {
            const target = new Date(dateString + 'T00:00:00');
            const now = new Date();

            const today = new Date(
                    now.getFullYear(),
                    now.getMonth(),
                    now.getDate()
                    );

            return Math.floor((target - today) / 86400000);
        }

        function addNotice(message) {
            notice.classList.remove('d-none');
            notice.textContent = message;
        }

        function createCard(point, data) {
            const temperature = data.temperature_2m;
            const rain = data.precipitation_probability;

            return '<div class="col-md-6 col-xl-4">'
                    + '<div class="weather-card">'
                    + '<div class="fw-semibold mb-3">'
                    + escapeHtml(point.name)
                    + '</div>'
                    + '<div class="weather-info-row">'
                    + '<span>Ngày đi</span>'
                    + '<strong>' + escapeHtml(point.date) + '</strong>'
                    + '</div>'
                    + '<div class="weather-info-row">'
                    + '<span>Khung giờ</span>'
                    + '<strong>'
                    + escapeHtml(point.start) + ' - ' + escapeHtml(point.end)
                    + '</strong>'
                    + '</div>'
                    + '<div class="weather-info-row">'
                    + '<span>Nhiệt độ</span>'
                    + '<strong class="weather-temp">'
                    + (temperature == null
                            ? '--'
                            : Number(temperature).toFixed(0) + '°C')
                    + '</strong>'
                    + '</div>'
                    + '<div class="weather-info-row">'
                    + '<span>Khả năng mưa</span>'
                    + '<strong>'
                    + (rain == null ? '--' : Number(rain) + '%')
                    + '</strong>'
                    + '</div>'
                    + '</div>'
                    + '</div>';
        }

        async function fetchWeather(point) {
            const hour = hourKey(point.start);

            if (!hour) {
                throw new Error('Giờ bắt đầu không hợp lệ.');
            }

            const diff = dateDiffDays(point.date);

            if (diff < 0 || diff > 15) {
                return {
                    unavailable: true,
                    reason: diff < 0
                            ? 'Ngày này đã qua.'
                            : 'Ngày đi còn quá xa nên chưa có dự báo.'
                };
            }

            const url =
                    'https://api.open-meteo.com/v1/forecast'
                    + '?latitude=' + encodeURIComponent(point.lat)
                    + '&longitude=' + encodeURIComponent(point.lng)
                    + '&hourly=temperature_2m,precipitation_probability'
                    + '&timezone=Asia%2FHo_Chi_Minh'
                    + '&start_date=' + encodeURIComponent(point.date)
                    + '&end_date=' + encodeURIComponent(point.date);

            const response = await fetch(url);

            if (!response.ok) {
                throw new Error('Không lấy được dữ liệu thời tiết.');
            }

            const data = await response.json();
            const hourly = data.hourly;

            if (!hourly || !Array.isArray(hourly.time)) {
                throw new Error('Dữ liệu thời tiết không hợp lệ.');
            }

            const index = hourly.time.findIndex(function (value) {
                return value.substring(11, 16) === hour;
            });

            if (index < 0) {
                throw new Error('Không tìm thấy dự báo cho khung giờ.');
            }

            return {
                temperature_2m: hourly.temperature_2m
                        ? hourly.temperature_2m[index]
                        : null,
                precipitation_probability: hourly.precipitation_probability
                        ? hourly.precipitation_probability[index]
                        : null
            };
        }

        function formatWeatherDate(value) {
            const parts = value.split('-');

            return parts.length === 3
                    ? parts[2] + '/' + parts[1] + '/' + parts[0]
                    : value;
        }

        function createUnavailableCard(point, message) {
            return '<div class="col-md-6 col-xl-4">'
                    + '<div class="weather-card">'
                    + '<div class="fw-semibold mb-3">'
                    + escapeHtml(point.name)
                    + '</div>'
                    + '<div class="weather-info-row">'
                    + '<span>Ngày đi</span>'
                    + '<strong>'
                    + escapeHtml(formatWeatherDate(point.date))
                    + '</strong>'
                    + '</div>'
                    + '<div class="weather-info-row">'
                    + '<span>Khung giờ</span>'
                    + '<strong>'
                    + escapeHtml(point.start)
                    + ' - '
                    + escapeHtml(point.end)
                    + '</strong>'
                    + '</div>'
                    + '<p class="text-muted small mt-3 mb-0">'
                    + escapeHtml(message)
                    + '</p>'
                    + '</div>'
                    + '</div>';
        }

        function getCachedWeather(point) {
            const key = [
                point.lat,
                point.lng,
                point.date,
                hourKey(point.start)
            ].join('|');

            if (!weatherCache.has(key)) {
                const pending = fetchWeather(point).catch(function (error) {
                    // Cho phép tải lại nếu lần trước bị lỗi.
                    weatherCache.delete(key);
                    throw error;
                });

                weatherCache.set(key, pending);
            }

            return weatherCache.get(key);
        }

        async function loadWeather() {
            const currentVersion = ++weatherRenderVersion;
            const selectedDay = dayFilter ? dayFilter.value : 'ALL';

            const selectedPoints = points.filter(function (point) {
                return selectedDay === 'ALL' || point.date === selectedDay;
            });

            list.innerHTML = '';
            notice.textContent = '';
            notice.classList.add('d-none');

            if (!selectedPoints.length) {
                status.textContent = 'Chưa có dữ liệu';
                addNotice('Chưa có hoạt động đủ tọa độ, ngày và giờ để hiển thị thời tiết.');
                return;
            }

            status.textContent = 'Đang tải...';

            let successCount = 0;
            let unavailableCount = 0;
            let failedCount = 0;
            const fragments = [];

            for (const point of selectedPoints) {
                // Ngăn kết quả của bộ lọc cũ ghi đè ngày vừa chọn.
                if (currentVersion !== weatherRenderVersion) {
                    return;
                }

                try {
                    const data = await getCachedWeather(point);

                    if (currentVersion !== weatherRenderVersion) {
                        return;
                    }

                    if (data.unavailable) {
                        unavailableCount++;
                        fragments.push(
                                createUnavailableCard(point, data.reason)
                                );
                    } else {
                        successCount++;
                        fragments.push(createCard(point, data));
                    }
                } catch (error) {
                    if (currentVersion !== weatherRenderVersion) {
                        return;
                    }

                    failedCount++;
                    fragments.push(
                            createUnavailableCard(
                                    point,
                                    'Chưa tải được thời tiết. Bạn có thể chọn lại ngày để thử lại.'
                                    )
                            );
                }
            }

            if (currentVersion !== weatherRenderVersion) {
                return;
            }

            list.innerHTML = fragments.join('');
            status.textContent = successCount
                    + '/' + selectedPoints.length
                    + ' hoạt động có dự báo';

            const messages = [];

            if (unavailableCount > 0) {
                messages.push(
                        unavailableCount
                        + ' hoạt động nằm ngoài phạm vi dự báo.'
                        );
            }

            if (failedCount > 0) {
                messages.push(
                        failedCount
                        + ' hoạt động tải thời tiết chưa thành công.'
                        );
            }

            if (messages.length) {
                addNotice(messages.join(' '));
            }
        }

        if (dayFilter) {
            const dates = Array.from(new Set(points.map(function (point) {
                return point.date;
            }))).sort();

            // Giữ lựa chọn "Tất cả ngày", tạo mỗi ngày đúng một lần.
            dayFilter.options.length = 1;

            dates.forEach(function (date) {
                const option = document.createElement('option');
                option.value = date;
                option.textContent = formatWeatherDate(date);
                dayFilter.appendChild(option);
            });

            dayFilter.disabled = dates.length === 0;
            dayFilter.addEventListener('change', loadWeather);
        }

        loadWeather();
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>