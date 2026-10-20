<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="${place.name}" scope="request" />
<c:set var="tripRedesign" value="${true}" scope="request" />
<fmt:setLocale value="en_US" scope="page"/>

<c:url var="placesUrl" value="/places" />

<c:url var="itineraryUrl" value="/itinerary/add">
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
                LOCALTRIP · DESTINATION OVERVIEW
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
            ← Destination list
        </a>
    </div>
</section>

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <section class="rd-card mb-4">
            <h2 class="h4 mb-2">Place Information</h2>

            <p class="text-muted mb-4">
                View address, operating hours, and reference costs before scheduling a visit.
            </p>

            <div class="border-top pt-3 mb-3">
                <div class="small text-muted mb-1">
                    Address
                </div>

                <div class="fw-semibold">
                    <c:choose>
                        <c:when test="${not empty place.address}">
                            <c:out value="${place.address}" />
                        </c:when>
                        <c:otherwise>
                            Not specified
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="border-top pt-3 mb-3">
                <div class="small text-muted mb-1">
                    Opening hours
                </div>

                <div class="fw-semibold">
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

            <div class="border-top pt-3">
                <div class="small text-muted mb-1">
                    Estimated reference price
                </div>

                <div class="h4 mb-0">
                    <fmt:formatNumber
                        value="${place.estimatedPrice}"
                        type="number"
                        maxFractionDigits="2" />
                    VND
                </div>
            </div>
        </section>

        <section class="rd-card">
            <h2 class="h4 mb-3">About this destination</h2>

            <c:choose>
                <c:when test="${not empty place.description}">
                    <div style="white-space: pre-line; overflow-wrap: anywhere;"><c:out value="${place.description}" /></div>
                </c:when>
                <c:otherwise>
                    <p class="text-muted mb-0">
                        No description available for this place yet.
                    </p>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <div class="col-12 col-lg-4">
        <section class="rd-card">
            <h2 class="h4 mb-2">Explore with LocalTrip</h2>

            <p class="text-muted mb-4">
                Schedule a visit or record your check-in at this spot.
            </p>

            <div class="d-grid gap-3">
                <c:if test="${not empty param.tripId}">
                    <a href="<c:out value='${itineraryUrl}'/>"
                       class="btn btn-primary">
                        + Add to itinerary
                    </a>
                </c:if>

                <c:choose>
                    <c:when test="${not empty place.latitude
                                    and not empty place.longitude}">
                        <a href="<c:out value='${checkinUrl}'/>"
                           class="btn btn-outline-secondary">
                            Check in here
                        </a>
                    </c:when>

                    <c:otherwise>
                        <button type="button"
                                class="btn btn-outline-secondary"
                                disabled>
                            GPS check-in unavailable
                        </button>

                        <p class="small text-muted mb-0">
                            This destination lacks coordinates to verify physical location.
                        </p>
                    </c:otherwise>
                </c:choose>

                <a href="<c:out value='${placesUrl}'/>"
                   class="btn btn-outline-secondary">
                    View other destinations
                </a>
            </div>
        </section>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
