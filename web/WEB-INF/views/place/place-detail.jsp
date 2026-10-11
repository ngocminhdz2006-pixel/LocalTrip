<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="${place.name}" scope="request" />
<c:set var="tripRedesign" value="${true}" scope="request" />

<c:url var="placesUrl" value="/places" />

<c:url var="itineraryUrl" value="/itinerary">
    <c:param name="tripId" value="${param.tripId}" />
    <c:param name="placeId" value="${place.id}" />
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
                LOCALTRIP · KHÁM PHÁ ĐIỂM ĐẾN
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
            </div>
        </div>

        <a href="<c:out value='${placesUrl}'/>"
           class="rd-back">
            ← Danh sách địa điểm
        </a>
    </div>
</section>

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <section class="rd-card mb-4">
            <h2 class="h4 mb-2">Thông tin địa điểm</h2>

            <p class="text-muted mb-4">
                Xem địa chỉ, giờ hoạt động và chi phí
                trước khi lên kế hoạch ghé thăm.
            </p>

            <div class="border-top pt-3 mb-3">
                <div class="small text-muted mb-1">
                    Địa chỉ
                </div>

                <div class="fw-semibold">
                    <c:choose>
                        <c:when test="${not empty place.address}">
                            <c:out value="${place.address}" />
                        </c:when>
                        <c:otherwise>
                            Chưa cập nhật
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="border-top pt-3 mb-3">
                <div class="small text-muted mb-1">
                    Giờ hoạt động
                </div>

                <div class="fw-semibold">
                    <c:choose>
                        <c:when test="${not empty place.openHours}">
                            <c:out value="${place.openHours}" />
                        </c:when>
                        <c:otherwise>
                            Chưa cập nhật
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="border-top pt-3">
                <div class="small text-muted mb-1">
                    Chi phí dự kiến
                </div>

                <div class="h4 mb-0">
                    <fmt:formatNumber
                        value="${place.estimatedPrice}"
                        type="number"
                        maxFractionDigits="2" />
                    đ
                </div>
            </div>
        </section>

        <section class="rd-card">
            <h2 class="h4 mb-3">Giới thiệu địa điểm</h2>

            <c:choose>
                <c:when test="${not empty place.description}">
                    <div style="white-space: pre-line; overflow-wrap: anywhere;"><c:out value="${place.description}" /></div>
                </c:when>
                <c:otherwise>
                    <p class="text-muted mb-0">
                        Địa điểm này chưa có thông tin giới thiệu.
                    </p>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <div class="col-12 col-lg-4">
        <section class="rd-card">
            <h2 class="h4 mb-2">Khám phá cùng LocalTrip</h2>

            <p class="text-muted mb-4">
                Lên lịch ghé thăm hoặc ghi nhận trải nghiệm
                của bạn tại địa điểm này.
            </p>

            <div class="d-grid gap-3">
                <c:if test="${not empty param.tripId}">
                    <a href="<c:out value='${itineraryUrl}'/>"
                       class="btn btn-primary">
                        + Thêm vào lịch trình
                    </a>
                </c:if>

                <c:choose>
                    <c:when test="${not empty place.latitude
                                    and not empty place.longitude}">
                        <a href="<c:out value='${checkinUrl}'/>"
                           class="btn btn-outline-secondary">
                            Ghi nhận ghé thăm
                        </a>
                    </c:when>

                    <c:otherwise>
                        <button type="button"
                                class="btn btn-outline-secondary"
                                disabled>
                            Chưa hỗ trợ ghi nhận GPS
                        </button>

                        <p class="small text-muted mb-0">
                            Địa điểm chưa có tọa độ để xác nhận
                            vị trí ghé thăm.
                        </p>
                    </c:otherwise>
                </c:choose>

                <a href="<c:out value='${placesUrl}'/>"
                   class="btn btn-outline-secondary">
                    Xem địa điểm khác
                </a>
            </div>
        </section>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>