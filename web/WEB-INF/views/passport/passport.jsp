<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Travel Passport" scope="request" />
<c:set var="tripRedesign" value="${true}" scope="request" />
<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · JOURNEY MILESTONES
            </div>

            <h1 class="mb-2">Travel Passport</h1>

            <p class="text-white mb-0">
                Every verified check-in is a memorable milestone in your personal exploration story.
            </p>
        </div>

        <a class="rd-back"
           href="${pageContext.request.contextPath}/places">
            Explore destinations →
        </a>
    </div>
</section>

<c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger" role="alert">
        <c:out value="${sessionScope.errorMessage}" />
    </div>
    <c:remove var="errorMessage" scope="session" />
</c:if>

<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success" role="status">
        <c:out value="${sessionScope.successMessage}" />
    </div>
    <c:remove var="successMessage" scope="session" />
</c:if>

<c:if test="${isOwnPassport}">
    <section class="rd-card mb-4">
        <form method="post"
              action="${pageContext.request.contextPath}/passport"
              class="row g-3 align-items-center">

            <input type="hidden"
                   name="csrfToken"
                   value="${sessionScope.travelCsrf}">

            <div class="col-12 col-lg-7">
                <h2 class="h5 mb-2">Passport Privacy</h2>

                <p class="text-muted small mb-0">
                    By default, only you can see this passport. When set to public, anyone with the link can view your milestones.
                </p>
            </div>

            <div class="col-12 col-lg-5">
                <div class="d-flex gap-2">
                    <label for="passportVisibility"
                           class="visually-hidden">
                        Passport privacy
                    </label>

                    <select id="passportVisibility"
                            class="form-select"
                            name="visibility">
                        <option value="PRIVATE"
                                ${passportVisibility eq 'PRIVATE' ? 'selected' : ''}>
                            Only me
                        </option>

                        <option value="PUBLIC"
                                ${passportVisibility eq 'PUBLIC' ? 'selected' : ''}>
                            Public
                        </option>
                    </select>

                    <button class="btn btn-primary"
                            type="submit">
                        Save
                    </button>
                </div>
            </div>
        </form>
    </section>
</c:if>

<div class="row g-3 mb-4">
    <div class="col-6 col-lg-3">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Unique Destinations
            </div>
            <strong class="h2 d-block mb-0">
                <c:out value="${summary.placeCount}" />
            </strong>
        </section>
    </div>

    <div class="col-6 col-lg-3">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Verified Check-ins
            </div>
            <strong class="h2 d-block mb-0">
                <c:out value="${summary.checkInCount}" />
            </strong>
        </section>
    </div>

    <div class="col-6 col-lg-3">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Earned Badges
            </div>
            <strong class="h2 d-block mb-0">
                <c:out value="${summary.badgeCount}" />
            </strong>
        </section>
    </div>

    <div class="col-6 col-lg-3">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Visits with Photos
            </div>
            <strong class="h2 d-block mb-0">
                <c:out value="${summary.photoCount}" />
            </strong>
        </section>
    </div>
</div>

<div class="row g-4">
    <div class="col-12 col-lg-7">
        <section class="rd-card">
            <div class="d-flex justify-content-between
                        align-items-center flex-wrap gap-2 mb-4">
                <h2 class="h4 mb-0">Exploration Log</h2>
                <span class="small text-muted">Newest first</span>
            </div>

            <c:choose>
                <c:when test="${empty checkIns}">
                    <div class="border-top pt-4">
                        <h3 class="h5 mb-2">No check-in milestones yet</h3>

                        <p class="text-muted mb-0">
                            <c:choose>
                                <c:when test="${isOwnPassport}">
                                    Open any destination with GPS coordinates and select Check In to begin your story.
                                </c:when>
                                <c:otherwise>
                                    This passport does not have check-in history yet.
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </c:when>

                <c:otherwise>
                    <c:forEach items="${checkIns}" var="item">
                        <div class="border-top py-3">
                            <div class="d-flex justify-content-between
                                        align-items-start flex-wrap gap-2 mb-2">
                                <h3 class="h5 mb-0">
                                    <c:out value="${item.placeName}" />
                                </h3>

                                <span class="small text-muted">
                                    <fmt:formatDate
                                        value="${item.checkInTime}"
                                        pattern="dd/MM/yyyy HH:mm" />
                                </span>
                            </div>

                            <p class="small text-muted mb-2">
                                <c:out value="${item.categoryName}" />
                                ·
                                <c:out value="${item.address}" />
                            </p>

                            <c:if test="${not empty item.note}">
                                <p class="mb-2"
                                   style="white-space:pre-line;overflow-wrap:anywhere;"><c:out value="${item.note}" /></p>
                            </c:if>

                            <c:if test="${item.hasPhoto}">
                                <span class="rd-count">Photo attached</span>

                                <c:if test="${isOwnPassport
                                                and not empty item.imageId}">
                                    <a href="${pageContext.request.contextPath}/checkin/image?id=${item.imageId}"
                                       target="_blank"
                                       rel="noopener noreferrer"
                                       class="small ms-2">
                                        View photo →
                                    </a>
                                </c:if>
                            </c:if>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <div class="col-12 col-lg-5">
        <section class="rd-card">
            <h2 class="h4 mb-2">Discovery Badges</h2>

            <p class="small text-muted mb-4">
                Badges are awarded automatically following verified check-ins. Each place counts once toward unique place achievements.
            </p>

            <c:if test="${empty badges}">
                <p class="text-muted mb-0">
                    No badges available yet.
                </p>
            </c:if>

            <c:forEach items="${badges}" var="badge">
                <c:set var="badgePercent" value="${0}" />

                <c:if test="${badge.threshold > 0}">
                    <c:set var="badgePercent"
                           value="${badge.progress * 100 / badge.threshold}" />
                </c:if>

                <c:if test="${badgePercent > 100}">
                    <c:set var="badgePercent" value="${100}" />
                </c:if>

                <c:if test="${badgePercent < 0}">
                    <c:set var="badgePercent" value="${0}" />
                </c:if>

                <div class="border-top py-3">
                    <div class="d-flex justify-content-between
                                align-items-start gap-2 mb-2">
                        <strong>
                            <c:out value="${badge.icon}" />
                            <c:out value="${badge.badgeName}" />
                        </strong>

                        <c:choose>
                            <c:when test="${badge.earned}">
                                <span class="rd-count flex-shrink-0">
                                    Unlocked
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="rd-role flex-shrink-0">
                                    Locked
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <p class="small text-muted mb-3">
                        <c:out value="${badge.description}" />
                    </p>

                    <div class="progress"
                         role="progressbar"
                         aria-label="Badge progress: <c:out value='${badge.badgeName}'/>"
                         aria-valuenow="${badgePercent}"
                         aria-valuemin="0"
                         aria-valuemax="100"
                         style="height:8px;">
                        <div class="progress-bar"
                             style="width:${badgePercent}%;background:var(--green);">
                        </div>
                    </div>

                    <div class="small text-muted mt-2">
                        <c:choose>
                            <c:when test="${badge.earned}">
                                Completed
                            </c:when>
                            <c:otherwise>
                                <c:out value="${badge.progress}" /> /
                                <c:out value="${badge.threshold}" />
                                progress
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </section>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
