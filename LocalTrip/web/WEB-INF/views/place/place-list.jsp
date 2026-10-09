<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Khám phá địa điểm" scope="request"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<link rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

<div class="page-intro">
    <span class="eyebrow">ĐI &amp; KHÁM PHÁ</span>
    <h3>Điểm đến cho hành trình tiếp theo</h3>
    <p class="text-muted">
        Tìm địa điểm theo khu vực và sở thích,
        xem thông tin và lên kế hoạch cùng nhóm.
    </p>
</div>

<div class="app-card mb-4">
    <h5 class="mb-3">Lọc địa điểm</h5>

    <form id="placeFilterForm"
          method="get"
          action="${pageContext.request.contextPath}/places">

        <div class="row g-3">
            <div class="col-md-4">
                <label for="filterCity" class="form-label">
                    Tỉnh / Thành phố
                </label>

                <select id="filterCity"
                        name="city"
                        class="form-select">
                    <option value="">Tất cả tỉnh/thành</option>

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
                    Quận / Khu vực
                </label>

                <select id="filterDistrict"
                        name="district"
                        class="form-select">
                    <option value="">Tất cả khu vực</option>

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
                    Danh mục
                </label>

                <select id="filterCategory"
                        name="categoryId"
                        class="form-select">
                    <option value="">Tất cả danh mục</option>

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
            <button type="submit" class="btn btn-brand">
                Lọc địa điểm
            </button>

            <a href="${pageContext.request.contextPath}/places"
               class="btn btn-outline-secondary">
                Xóa bộ lọc
            </a>
        </div>
    </form>
</div>

<div class="app-card mb-4">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
        <div>
            <h5 class="mb-1">Bản đồ địa điểm</h5>
            <small class="text-muted">
                Hiển thị các địa điểm phù hợp với bộ lọc và có tọa độ.
            </small>
        </div>

        <span class="badge bg-secondary" id="placeMapCount">
            0 điểm
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
        Chưa có địa điểm phù hợp có đủ tọa độ để hiển thị.
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
        <div class="empty-state app-card">
            <h5>Chưa tìm thấy địa điểm</h5>
            <p class="text-muted">
                Không có địa điểm phù hợp với bộ lọc.
                Bạn có thể đổi khu vực hoặc danh mục.
            </p>

            <a href="${pageContext.request.contextPath}/places"
               class="btn btn-outline-secondary">
                Xem tất cả địa điểm
            </a>
        </div>
    </c:when>

    <c:otherwise>
        <div class="row g-4">
            <c:forEach var="place" items="${places}">
                <div class="col-md-6 col-lg-4">
                    <div class="app-card h-100 d-flex flex-column mb-0">
                        <div class="d-flex justify-content-between align-items-start gap-2 mb-3">
                            <h5 class="mb-0">
                                <c:out value="${place.name}"/>
                            </h5>

                            <span class="badge bg-secondary flex-shrink-0">
                                ★ <c:out value="${place.rating}"/>
                            </span>
                        </div>

                        <p class="text-muted mb-2">
                            <strong>Danh mục:</strong>
                            <c:out value="${place.categoryName}"/>
                        </p>

                        <p class="text-muted mb-2">
                            <strong>Địa chỉ:</strong>
                            <c:out value="${place.address}"/>
                        </p>

                        <p class="text-muted mb-2">
                            <strong>Giờ hoạt động:</strong>
                            <c:out value="${place.openHours}"/>
                        </p>

                        <p class="mb-4">
                            <strong>Chi phí dự kiến:</strong>
                            <fmt:formatNumber
                                value="${place.estimatedPrice}"
                                type="number"
                                maxFractionDigits="2"/>
                            đ
                        </p>

                        <a href="${pageContext.request.contextPath}/places/detail?placeId=${place.id}"
                           class="btn btn-outline-secondary btn-sm w-100 mt-auto">
                            Xem chi tiết
                        </a>
                    </div>
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

    if (!form || !city || !district) return;

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

    if (!mapElement) return;

    if (typeof L === 'undefined') {
        emptyState.textContent =
            'Không thể tải bản đồ. Hãy kiểm tra kết nối Internet.';
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
        return Number.isFinite(point.lat)
            && Number.isFinite(point.lng)
            && point.lat >= -90
            && point.lat <= 90
            && point.lng >= -180
            && point.lng <= 180;
    });

    countElement.textContent = points.length + ' điểm';

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
            if (failed || activeTiles !== layer) return;

            failed = true;
            loadTileProvider(index + 1);
        });

        layer.on('load', function () {
            if (failed || activeTiles !== layer) return;

            tileStatus.textContent = 'Bản đồ: ' + provider.name;

            setTimeout(function () {
                if (tileStatus.parentNode && activeTiles === layer) {
                    tileStatus.remove();
                }
            }, 2200);
        });

        layer.addTo(map);
    }

    loadTileProvider(0);
    L.control.scale({imperial: false}).addTo(map);

    if (!points.length) {
        emptyState.classList.remove('d-none');
        return;
    }

    const bounds = [];

    points.forEach(function (point) {
        const latLng = [point.lat, point.lng];
        bounds.push(latLng);

        const detailUrl =
            '${pageContext.request.contextPath}/places/detail?placeId='
            + encodeURIComponent(point.id);

        const directionsUrl =
            'https://www.google.com/maps/dir/?api=1'
            + '&destination='
            + encodeURIComponent(point.lat + ',' + point.lng)
            + '&travelmode=driving';

        const markerIcon = L.divIcon({
            className: 'localtrip-map-pin-wrap',
            html:
                '<div class="localtrip-map-pin">'
                + '<span>●</span></div>',
            iconSize: [34, 42],
            iconAnchor: [17, 40],
            popupAnchor: [0, -36]
        });

        const popup =
            '<strong>' + escapeHtml(point.name) + '</strong>'
            + '<br>' + escapeHtml(point.category)
            + '<br>' + escapeHtml(point.address)
            + '<div style="display:flex;flex-direction:column;'
            + 'gap:8px;margin-top:12px;">'
            + '<a href="' + detailUrl + '">'
            + 'Xem chi tiết địa điểm</a>'
            + '<a href="' + directionsUrl + '"'
            + ' target="_blank" rel="noopener noreferrer">'
            + 'Chỉ đường từ vị trí hiện tại ↗</a>'
            + '</div>';

        L.marker(latLng, {icon: markerIcon})
            .addTo(map)
            .bindPopup(popup);
    });

    map.fitBounds(L.latLngBounds(bounds), {
        padding: [30, 30],
        maxZoom: 16
    });

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }
})();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>