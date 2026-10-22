<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Check in" scope="request" />
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
                LOCALTRIP · CAPTURE MEMORIES
            </div>

            <h1 class="mb-2">Place Check-in</h1>

            <p class="text-white mb-0">
                Log a new milestone in your journey of exploration.
            </p>
        </div>

        <a class="rd-back"
           href="<c:out value='${placeDetailUrl}'/>">
            ← Destination details
        </a>
    </div>
</section>

<div class="row g-4">
    <div class="col-12 col-lg-4">
        <section class="rd-card">
            <span class="rd-count mb-3">
                Your Destination
            </span>

            <h2 class="h4 mb-3">
                <c:out value="${place.name}" />
            </h2>

            <p class="text-muted mb-4">
                <c:out value="${place.address}" />
            </p>

            <div class="border-top pt-3">
                <h3 class="h6 mb-2">Location Verification</h3>

                <p class="small text-muted mb-0">
                    Allow browser location access when confirming your check-in.
                    LocalTrip records coordinates once for verification and does not track you continuously.
                </p>
            </div>
        </section>
    </div>

    <div class="col-12 col-lg-8">
        <section class="rd-card">
            <h2 class="h4 mb-2">Destination Memories</h2>

            <p class="text-muted mb-4">
                Add photos and personal reflections to preserve your experience.
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
                            This destination lacks GPS coordinates, so check-ins are not currently supported.
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
                                Related trip
                            </label>

                            <select class="form-select"
                                    id="checkinTrip"
                                    name="tripId">
                                <option value="">No tagged trip</option>

                                <c:forEach items="${trips}" var="trip">
                                    <option value="${trip.tripId}"
                                            ${selectedTripId eq trip.tripId ? 'selected' : ''}>
                                        <c:out value="${trip.tripName}" />
                                    </option>
                                </c:forEach>
                            </select>

                            <div class="form-text">
                                Optional.
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold"
                                   for="checkinPhoto">
                                Memory photo
                            </label>

                            <input class="form-control"
                                   type="file"
                                   id="checkinPhoto"
                                   name="photo"
                                   accept="image/jpeg,image/png,image/webp">

                            <div class="form-text">
                                Optional. Choose a JPG, PNG or WEBP image under 5 MB.
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold"
                                   for="checkinNote">
                                Your thoughts
                            </label>

                            <textarea class="form-control"
                                      id="checkinNote"
                                      name="note"
                                      maxlength="500"
                                      rows="4"
                                      placeholder="How was your experience here?"></textarea>

                            <div class="form-text">
                                Optional, max 500 characters.
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
                                    Share this visit to the community feed
                                </label>
                            </div>

                            <label class="form-label"
                                   for="dumpVisibility">
                                Visibility
                            </label>

                            <select class="form-select"
                                    id="dumpVisibility"
                                    name="dumpVisibility">
                                <option value="FRIENDS">Friends only</option>
                                <option value="PUBLIC">Public</option>
                            </select>

                            <div class="form-text">
                                Applies when sharing this check-in to the feed.
                            </div>
                        </div>

                        <button class="btn btn-primary w-100 py-3"
                                id="checkinButton"
                                type="submit">
                            Confirm location & check in
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
                status.textContent = 'Photo exceeds 5 MB. Please select a smaller image.';
                return;
            }

            if (!navigator.geolocation) {
                status.textContent = 'Geolocation is not supported by this browser.';
                return;
            }

            button.disabled = true;
            button.textContent = 'Verifying location...';
            status.textContent = 'Acquiring your current GPS location.';

            navigator.geolocation.getCurrentPosition(
                    function (position) {
                        document.getElementById('latitude').value =
                                position.coords.latitude;

                        document.getElementById('longitude').value =
                                position.coords.longitude;

                        status.textContent =
                                'Location verified. Submitting check-in...';

                        HTMLFormElement.prototype.submit.call(form);
                    },
                    function (error) {
                        button.disabled = false;
                        button.textContent =
                                'Confirm location & check in';

                        if (error.code === 1) {
                            status.textContent =
                                    'Location permission denied. '
                                    + 'Please enable location services for your browser and try again.';
                        } else if (error.code === 3) {
                            status.textContent =
                                    'Location request timed out. Please try again.';
                        } else {
                            status.textContent =
                                    'Unable to determine location. '
                                    + 'Please try in an open area with stronger signal.';
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

<script src="${pageContext.request.contextPath}/js/image-compressor.js"></script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
