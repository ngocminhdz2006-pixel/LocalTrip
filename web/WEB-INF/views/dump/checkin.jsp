<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Ghi nhận ghé thăm" scope="request" />
<c:set var="tripRedesign" value="${true}" scope="request" />

<c:url var="placeDetailUrl" value="/places/detail">
    <c:param name="placeId" value="${place.id}" />
    <c:if test="${not empty selectedTripId}">
        <c:param name="tripId" value="${selectedTripId}" />
    </c:if>
</c:url>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · LƯU GIỮ KỶ NIỆM
            </div>

            <h1 class="mb-2">Ghi nhận ghé thăm</h1>

            <p class="text-white mb-0">
                Lưu một dấu mốc mới trong hành trình khám phá của bạn.
            </p>
        </div>

        <a class="rd-back"
           href="<c:out value='${placeDetailUrl}'/>">
            ← Chi tiết địa điểm
        </a>
    </div>
</section>

<div class="row g-4">
    <div class="col-12 col-lg-4">
        <section class="rd-card">
            <span class="rd-count mb-3">
                Điểm đến của bạn
            </span>

            <h2 class="h4 mb-3">
                <c:out value="${place.name}" />
            </h2>

            <p class="text-muted mb-4">
                <c:out value="${place.address}" />
            </p>

            <div class="border-top pt-3">
                <h3 class="h6 mb-2">Xác nhận vị trí</h3>

                <p class="small text-muted mb-0">
                    Cho phép trình duyệt truy cập vị trí
                    khi bạn xác nhận ghé thăm.
                    LocalTrip lưu tọa độ của lần ghi nhận
                    để xác minh, không theo dõi vị trí liên tục.
                </p>
            </div>
        </section>
    </div>

    <div class="col-12 col-lg-8">
        <section class="rd-card">
            <h2 class="h4 mb-2">Kỷ niệm tại điểm đến</h2>

            <p class="text-muted mb-4">
                Thêm ảnh và cảm nhận để lưu lại trải nghiệm.
            </p>

            <c:if test="${not empty requestScope.errorMessage}">
                <div class="alert alert-warning" role="alert">
                    <c:out value="${requestScope.errorMessage}" />
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty place.latitude
                                or empty place.longitude}">
                        <div class="alert alert-light border mb-0">
                            Địa điểm chưa có tọa độ GPS,
                            nên hiện chưa thể ghi nhận ghé thăm.
                        </div>
                </c:when>

                <c:otherwise>
                    <form id="checkinForm"
                          method="post"
                          enctype="multipart/form-data"
                          action="${pageContext.request.contextPath}/checkin">

                        <input type="hidden"
                               name="csrfToken"
                               value="${sessionScope.travelCsrf}">

                        <input type="hidden"
                               name="placeId"
                               value="${place.id}">

                        <input type="hidden"
                               name="latitude"
                               id="latitude">

                        <input type="hidden"
                               name="longitude"
                               id="longitude">

                        <div class="mb-4">
                            <label class="form-label fw-semibold"
                                   for="checkinTrip">
                                Chuyến đi liên quan
                            </label>

                            <select class="form-select"
                                    id="checkinTrip"
                                    name="tripId">
                                <option value="">Không gắn chuyến đi</option>

                                <c:forEach items="${trips}" var="trip">
                                    <option value="${trip.tripId}"
                                            ${selectedTripId eq trip.tripId ? 'selected' : ''}>
                                        <c:out value="${trip.tripName}" />
                                    </option>
                                </c:forEach>
                            </select>

                            <div class="form-text">
                                Không bắt buộc.
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold"
                                   for="checkinPhoto">
                                Ảnh kỷ niệm
                            </label>

                            <input class="form-control"
                                   type="file"
                                   id="checkinPhoto"
                                   name="photo"
                                   accept="image/jpeg,image/png,image/webp">

                            <div class="form-text">
                                Không bắt buộc. Chọn ảnh JPG, PNG hoặc WEBP,
                                tối đa 5 MB.
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold"
                                   for="checkinNote">
                                Cảm nhận của bạn
                            </label>

                            <textarea class="form-control"
                                      id="checkinNote"
                                      name="note"
                                      maxlength="500"
                                      rows="4"
                                      placeholder="Bạn cảm thấy thế nào khi đến đây?"></textarea>

                            <div class="form-text">
                                Không bắt buộc, tối đa 500 ký tự.
                            </div>
                        </div>

                        <div class="border-top pt-4 mb-4">
                            <div class="form-check mb-3">
                                <input class="form-check-input"
                                       type="checkbox"
                                       id="shareToDump"
                                       name="shareToDump">

                                <label class="form-check-label fw-semibold"
                                       for="shareToDump">
                                    Chia sẻ lần ghé thăm này lên nhật ký
                                </label>
                            </div>

                            <label class="form-label"
                                   for="dumpVisibility">
                                Ai có thể xem bài nhật ký?
                            </label>

                            <select class="form-select"
                                    id="dumpVisibility"
                                    name="dumpVisibility">
                                <option value="FRIENDS">Chỉ bạn bè</option>
                                <option value="PUBLIC">Công khai</option>
                            </select>

                            <div class="form-text">
                                Thiết lập này áp dụng khi bạn chọn
                                chia sẻ lên nhật ký.
                            </div>
                        </div>

                        <button class="btn btn-primary w-100 py-3"
                                id="checkinButton"
                                type="submit">
                            Xác nhận vị trí và ghi nhận ghé thăm
                        </button>

                        <p id="gpsStatus"
                           class="small text-muted mt-3 mb-0"
                           role="status"
                           aria-live="polite">
                        </p>
                    </form>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</div>

<script>
    (function () {
        const form = document.getElementById('checkinForm');

        if (!form) {
            return;
        }

        const status = document.getElementById('gpsStatus');
        const button = document.getElementById('checkinButton');
        const photo = document.getElementById('checkinPhoto');

        form.addEventListener('submit', function (event) {
            event.preventDefault();

            if (button.disabled) {
                return;
            }

            if (!form.reportValidity()) {
                return;
            }

            if (photo.files.length && photo.files[0].size > 5 * 1024 * 1024) {
                status.textContent = 'Ảnh vượt quá 5 MB. Hãy chọn ảnh nhỏ hơn.';
                return;
            }

            if (!navigator.geolocation) {
                status.textContent = 'Trình duyệt này không hỗ trợ lấy vị trí.';
                return;
            }

            button.disabled = true;
            button.textContent = 'Đang xác nhận vị trí...';
            status.textContent = 'Đang lấy vị trí hiện tại của bạn.';

            navigator.geolocation.getCurrentPosition(
                    function (position) {
                        document.getElementById('latitude').value =
                                position.coords.latitude;

                        document.getElementById('longitude').value =
                                position.coords.longitude;

                        status.textContent =
                                'Đã nhận vị trí. Đang gửi yêu cầu ghi nhận ghé thăm.';

                        HTMLFormElement.prototype.submit.call(form);
                    },
                    function (error) {
                        button.disabled = false;
                        button.textContent =
                                'Xác nhận vị trí và ghi nhận ghé thăm';

                        if (error.code === 1) {
                            status.textContent =
                                    'Bạn chưa cấp quyền vị trí. '
                                    + 'Hãy bật quyền vị trí cho trình duyệt rồi thử lại.';
                        } else if (error.code === 3) {
                            status.textContent =
                                    'Lấy vị trí quá thời gian chờ. Hãy thử lại.';
                        } else {
                            status.textContent =
                                    'Không lấy được vị trí. '
                                    + 'Hãy thử ở nơi có tín hiệu tốt hơn.';
                        }
                    },
                    {
                        enableHighAccuracy: true,
                        timeout: 15000,
                        maximumAge: 0
                    }
            );
        });
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>