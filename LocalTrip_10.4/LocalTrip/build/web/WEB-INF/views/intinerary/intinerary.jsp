<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Itinerary" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

<div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
    <div>
        <h3 class="mb-1">Itinerary - ${trip.name}</h3>
        <p class="text-muted mb-0">Xem các địa điểm và hành trình dự kiến trực tiếp trên bản đồ.</p>
    </div>
    <a href="${pageContext.request.contextPath}/recommendations?tripId=${trip.id}"
       class="btn btn-outline-secondary btn-sm">← Gợi ý địa điểm</a>
</div>

<c:if test="${param.auto == 'success'}">
    <div class="alert alert-success">
        ✨ Hệ thống đã tự động thêm <strong>${param.count}</strong> địa điểm theo cấu trúc 3 cột mốc/ngày: mỗi cột mốc gồm 1 Food + 1 Cafe + 1 Tham quan/Giải trí/Mua sắm, có xét sở thích nhóm.
    </div>
</c:if>

<c:if test="${param.auto == 'empty'}">
    <div class="alert alert-warning">
        Chưa có đủ dữ liệu sở thích của các thành viên để tự động tạo lịch trình. Hãy để các thành viên chọn Preferences trước.
    </div>
</c:if>

<c:if test="${trip.role == 'OWNER'}">
    <div class="app-card mb-4 itinerary-mode-card">
        <h5 class="mb-2">Chọn cách lập lịch trình</h5>
        <div class="row g-3">
            <div class="col-md-6">
                <div class="border rounded p-3 h-100">
                    <h6>📝 Tự soạn lịch trình</h6>
                    <p class="text-muted small mb-3">Owner tự chọn địa điểm từ danh sách gợi ý và quyết định ngày, giờ, chi phí.</p>
                    <a href="${pageContext.request.contextPath}/recommendations?tripId=${trip.id}" class="btn btn-outline-secondary btn-sm">Chọn địa điểm</a>
                </div>
            </div>
            <div class="col-md-6">
                <div class="border rounded p-3 h-100">
                    <h6>✨ Hệ thống tự xếp lịch</h6>
                    <p class="text-muted small mb-3">Hệ thống tự chia mỗi ngày thành 3 cột mốc (07:00-11:00, 11:00-17:00, 17:00-22:00). Mỗi cột mốc gồm 1 điểm ăn uống, 1 điểm cà phê và 1 điểm tham quan/giải trí/mua sắm, ưu tiên theo sở thích nhóm, rating và ngân sách.</p>
                    <form method="post" action="${pageContext.request.contextPath}/itinerary/auto"
                          onsubmit="return confirm('Tự động xếp lịch theo sở thích nhóm?');">
                        <input type="hidden" name="tripId" value="${trip.id}">
                        <button type="submit" class="btn btn-brand btn-sm">Tạo lịch trình tự động</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</c:if>

<div class="app-card mb-4">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <div>
            <h5 class="mb-1">🗺️ Bản đồ hành trình</h5>
            <small class="text-muted">Chọn ngày để xem các điểm của ngày đó theo đúng thứ tự lịch trình.</small>
        </div>
        <div class="d-flex align-items-center gap-2">
            <label for="mapDayFilter" class="small text-muted mb-0">Ngày:</label>
            <select id="mapDayFilter" class="form-select form-select-sm" style="min-width: 150px">
                <option value="ALL">Tất cả</option>
                <c:forEach var="item" items="${items}">
                    <option value="${item.date}">${item.date}</option>
                </c:forEach>
            </select>
            <span class="badge bg-secondary" id="mapPointCount">0 điểm</span>
        </div>
    </div>

    <div id="mapRouteInfo" class="alert alert-light border py-2 mb-3 d-none"></div>
    <div class="localtrip-map-wrap"><div id="itineraryMap" class="localtrip-map"></div></div>
    <div id="mapEmptyState" class="alert alert-light border mt-3 mb-0 d-none">
        Ngày này chưa có địa điểm nào có latitude/longitude. Hãy cập nhật tọa độ trong Quản lý Places.
    </div>
</div>

<c:choose>
    <c:when test="${empty items}">
        <div class="empty-state app-card">
            <div class="empty-icon">🗓️</div>
            <p>Chưa có địa điểm nào trong lịch trình.</p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="app-card p-0">
            <table class="table mb-0 align-middle">
                <thead>
                <tr>
                    <th>Địa điểm</th>
                    <th>Ngày</th>
                    <th>Giờ</th>
                    <th>Ghi chú</th>
                    <th>Chi phí dự kiến</th>
                    <c:if test="${trip.role == 'OWNER'}"><th></th></c:if>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="item" items="${items}" varStatus="status">
                    <tr>
                        <td>
                            <span class="badge bg-light text-dark border me-1">${status.index + 1}</span>
                            ${item.placeName}
                        </td>
                        <td>${item.date}</td>
                        <td>${item.startTime} - ${item.endTime}</td>
                        <td>${item.note}</td>
                        <td><fmt:formatNumber value="${item.estimatedCost}" type="number"/> đ</td>
                        <c:if test="${trip.role == 'OWNER'}">
                            <td>
                                <form method="post"
                                      action="${pageContext.request.contextPath}/itinerary/delete"
                                      onsubmit="return confirmDelete('Xóa địa điểm này khỏi lịch trình?')">
                                    <input type="hidden" name="tripId" value="${trip.id}">
                                    <input type="hidden" name="itemId" value="${item.id}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">Xóa</button>
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
    <p class="text-muted mt-2"><em>Bạn là Member: chỉ Owner mới có thể thêm/xóa mục trong itinerary.</em></p>
</c:if>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<div id="itineraryMapData" class="d-none" aria-hidden="true">
<c:forEach var="item" items="${items}">
    <c:if test="${not empty item.latitude and not empty item.longitude}">
        <span class="itinerary-map-point"
              data-id="${item.placeId}"
              data-name="<c:out value='${item.placeName}'/>"
              data-lat="${item.latitude}"
              data-lng="${item.longitude}"
              data-date="${item.date}"
              data-start="${item.startTime}"
              data-end="${item.endTime}"></span>
    </c:if>
</c:forEach>
</div>

<script>
(function () {
    const mapElement = document.getElementById('itineraryMap');
    const emptyState = document.getElementById('mapEmptyState');
    const countElement = document.getElementById('mapPointCount');
    const dayFilter = document.getElementById('mapDayFilter');
    const routeInfo = document.getElementById('mapRouteInfo');

    if (!mapElement || typeof L === 'undefined') return;

    const allPoints = Array.from(document.querySelectorAll('.itinerary-map-point')).map(function (el) {
        return {
            id: Number(el.dataset.id),
            name: el.dataset.name || '',
            lat: Number(el.dataset.lat),
            lng: Number(el.dataset.lng),
            date: el.dataset.date || '',
            start: el.dataset.start || '',
            end: el.dataset.end || ''
        };
    });

    const map = L.map(mapElement).setView([10.8231, 106.6297], 11);
    const tileStatus = document.createElement('div');
    tileStatus.className = 'map-tile-status';
    tileStatus.textContent = 'Đang tải bản đồ...';
    mapElement.parentElement.appendChild(tileStatus);

    let activeTiles = null;
    let tileProviderIndex = 0;
    const tileProviders = [
        {
            name: 'Esri World Street Map',
            url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            options: { maxZoom: 19, attribution: 'Tiles &copy; Esri' }
        },
        {
            name: 'OpenStreetMap',
            url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            options: { maxZoom: 19, attribution: '&copy; OpenStreetMap contributors' }
        },
        {
            name: 'CARTO Voyager',
            url: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
            options: { maxZoom: 19, subdomains: 'abcd', attribution: '&copy; OpenStreetMap contributors &copy; CARTO' }
        }
    ];

    function loadTileProvider(index) {
        if (index >= tileProviders.length) {
            tileStatus.textContent = 'Không thể tải dữ liệu bản đồ. Hãy kiểm tra kết nối Internet.';
            tileStatus.classList.add('map-tile-status-error');
            return;
        }
        tileProviderIndex = index;
        const provider = tileProviders[index];
        if (activeTiles) map.removeLayer(activeTiles);
        tileStatus.textContent = 'Đang tải bản đồ ' + provider.name + '...';
        activeTiles = L.tileLayer(provider.url, provider.options);
        let hadTileError = false;
        activeTiles.on('tileerror', function () {
            if (hadTileError) return;
            hadTileError = true;
            loadTileProvider(index + 1);
        });
        activeTiles.on('load', function () {
            tileStatus.textContent = 'Bản đồ: ' + provider.name;
            setTimeout(function () { if (tileStatus.parentNode) tileStatus.remove(); }, 2200);
        });
        activeTiles.addTo(map);
    }

    loadTileProvider(0);
    L.control.scale({ imperial: false }).addTo(map);

    let markersLayer = L.layerGroup().addTo(map);
    let fallbackLine = null;
    let routeLine = null;

    function clearMapLayers() {
        markersLayer.clearLayers();
        if (fallbackLine) {
            map.removeLayer(fallbackLine);
            fallbackLine = null;
        }
        if (routeLine) {
            map.removeLayer(routeLine);
            routeLine = null;
        }
        routeInfo.classList.add('d-none');
        routeInfo.textContent = '';
    }

    function showMapForDay(day) {
        clearMapLayers();
        emptyState.classList.add('d-none');

        const points = allPoints.filter(function (point) {
            return day === 'ALL' || point.date === day;
        });

        countElement.textContent = points.length + ' điểm';

        if (points.length === 0) {
            map.setView([10.8231, 106.6297], 11);
            emptyState.classList.remove('d-none');
            return;
        }

        const latLngs = [];
        points.forEach(function (point, index) {
            const latLng = [point.lat, point.lng];
            latLngs.push(latLng);

            const detailUrl = '${pageContext.request.contextPath}/places/detail?placeId=' + point.id;
            const popup = '<strong>' + (index + 1) + '. ' + escapeHtml(point.name) + '</strong>' +
                    '<br>' + escapeHtml(point.date) +
                    '<br>' + escapeHtml(point.start) + ' - ' + escapeHtml(point.end) +
                    '<br><a href="' + detailUrl + '">Xem chi tiết địa điểm</a>';

            const markerIcon = L.divIcon({
                className: 'localtrip-map-pin-wrap',
                html: '<div class=\"localtrip-map-pin localtrip-map-pin-number\"><span>' + (index + 1) + '</span></div>',
                iconSize: [34, 42],
                iconAnchor: [17, 40],
                popupAnchor: [0, -36]
            });
            L.marker(latLng, { icon: markerIcon }).addTo(markersLayer).bindPopup(popup);
        });

        fallbackLine = L.polyline(latLngs, {
            weight: 4,
            opacity: 0.55,
            dashArray: '8 8'
        }).addTo(map);

        map.fitBounds(L.latLngBounds(latLngs), {padding: [30, 30]});

        if (points.length < 2) return;

        const coordinates = points.map(function (point) {
            return point.lng + ',' + point.lat;
        }).join(';');

        routeInfo.textContent = 'Đang tính tuyến đường dự kiến...';
        routeInfo.classList.remove('d-none');

        fetch('https://router.project-osrm.org/route/v1/driving/' + coordinates +
              '?overview=full&geometries=geojson')
            .then(function (response) {
                if (!response.ok) throw new Error('Routing service unavailable');
                return response.json();
            })
            .then(function (data) {
                if (!data.routes || !data.routes.length) throw new Error('No route');

                const route = data.routes[0];
                routeLine = L.geoJSON(route.geometry, {
                    style: {weight: 5, opacity: 0.9, color: '#1a73e8'}
                }).addTo(map);

                if (fallbackLine) {
                    map.removeLayer(fallbackLine);
                    fallbackLine = null;
                }

                const distanceKm = (route.distance / 1000).toFixed(1);
                const durationMin = Math.round(route.duration / 60);
                const hours = Math.floor(durationMin / 60);
                const minutes = durationMin % 60;
                const durationText = hours > 0
                        ? hours + ' giờ ' + minutes + ' phút'
                        : minutes + ' phút';

                routeInfo.textContent = 'Tuyến dự kiến: ' + distanceKm +
                        ' km · thời gian lái xe khoảng ' + durationText + '.';
                map.fitBounds(routeLine.getBounds(), {padding: [30, 30]});
            })
            .catch(function () {
                routeInfo.textContent = 'Không lấy được tuyến đường thực tế. Bản đồ đang hiển thị đường nối dự kiến giữa các điểm.';
            });
    }

    function escapeHtml(value) {
        return String(value)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
    }

    dayFilter.addEventListener('change', function () {
        showMapForDay(this.value);
    });

    showMapForDay('ALL');
})();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
