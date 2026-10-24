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
<style>
/* Card Container */
.lt-stop-card {
    display: flex !important;
    flex-direction: column !important;
    padding: 14px 16px 12px 16px !important;
    background: #ffffff !important;
    border: 1.5px solid #d1ded6 !important;
    border-radius: 16px !important;
    box-shadow: 0 2px 8px rgba(20, 59, 45, 0.04) !important;
    transition: transform 0.15s ease, box-shadow 0.15s ease !important;
    margin-bottom: 12px !important;
}
.lt-stop-card:hover {
    box-shadow: 0 4px 12px rgba(20, 59, 45, 0.08) !important;
}

/* Tier 1: Header Row */
.lt-card-tier1 {
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    width: 100% !important;
    gap: 8px !important;
}
.lt-tier1-left {
    display: flex !important;
    align-items: center !important;
    gap: 8px !important;
    min-width: 0 !important;
    flex: 1 !important;
}
.lt-tier1-right {
    display: flex !important;
    align-items: center !important;
    gap: 6px !important;
    flex-shrink: 0 !important;
}
.lt-drag-handle {
    color: #94a3b8 !important;
    font-size: 14px !important;
    cursor: grab !important;
    user-select: none !important;
    flex-shrink: 0 !important;
}
.lt-stop-badge {
    width: 24px !important;
    height: 24px !important;
    border-radius: 50% !important;
    background: #175b43 !important;
    color: #ffffff !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    flex-shrink: 0 !important;
}
.lt-tier1-time {
    font-size: 14px !important;
    font-weight: 800 !important;
    color: #1e293b !important;
    letter-spacing: -0.2px !important;
    white-space: nowrap !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
}
.lt-tier1-duration {
    font-size: 12px !important;
    font-weight: 500 !important;
    color: #64748b !important;
    margin-left: 2px !important;
}
.lt-status-pill {
    padding: 3px 10px !important;
    border-radius: 999px !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    white-space: nowrap !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
}
.lt-status-upcoming {
    background: #e8f5e9 !important;
    color: #166534 !important;
    border: 1px solid #bbf7d0 !important;
}
.lt-status-ongoing {
    background: #fef3c7 !important;
    color: #92400e !important;
    border: 1px solid #fde68a !important;
}
.lt-status-done {
    background: #dcfce7 !important;
    color: #166534 !important;
    border: 1px solid #86efac !important;
}
.lt-status-skipped {
    background: #f1f5f9 !important;
    color: #64748b !important;
    border: 1px solid #cbd5e1 !important;
}
.lt-btn-lock-sq {
    width: 28px !important;
    height: 28px !important;
    border-radius: 8px !important;
    border: 1px solid #e2e8f0 !important;
    background: #f8fafc !important;
    color: #64748b !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    font-size: 13px !important;
    cursor: pointer !important;
    padding: 0 !important;
    text-decoration: none !important;
    transition: all 0.15s ease !important;
}
.lt-btn-lock-sq:hover {
    background: #f1f5f9 !important;
    border-color: #cbd5e1 !important;
}
.lt-btn-lock-sq.is-locked {
    background: #fff7ed !important;
    border-color: #fed7aa !important;
    color: #c2410c !important;
}

/* Tier 2: Card Body */
.lt-card-tier2 {
    display: flex !important;
    align-items: center !important;
    gap: 12px !important;
    margin-top: 10px !important;
    min-width: 0 !important;
    width: 100% !important;
}
.lt-stop-thumb {
    width: 56px !important;
    height: 56px !important;
    border-radius: 12px !important;
    object-fit: cover !important;
    flex-shrink: 0 !important;
    background: #e2e8f0 !important;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06) !important;
}
.lt-card-body-info {
    flex: 1 !important;
    min-width: 0 !important;
    display: flex !important;
    flex-direction: column !important;
    justify-content: center !important;
    gap: 3px !important;
}
.lt-stop-name {
    font-size: 15px !important;
    font-weight: 800 !important;
    color: #143b2d !important;
    line-height: 1.3 !important;
    margin: 0 !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
    display: -webkit-box !important;
    -webkit-line-clamp: 2 !important;
    -webkit-box-orient: vertical !important;
    word-break: break-word !important;
}
.lt-card-meta-row {
    display: flex !important;
    align-items: center !important;
    flex-wrap: wrap !important;
    gap: 6px !important;
    font-size: 12px !important;
}
.lt-meta-cost {
    background: #f1f5f9 !important;
    color: #334155 !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    padding: 2px 8px !important;
    border-radius: 999px !important;
    border: 1px solid #cbd5e1 !important;
    white-space: nowrap !important;
    display: inline-flex !important;
    align-items: center !important;
}
.lt-meta-dot {
    color: #94a3b8 !important;
    font-size: 12px !important;
    display: inline-block !important;
}
.lt-meta-note {
    color: #475569 !important;
    font-size: 11.5px !important;
    font-weight: 600 !important;
    white-space: nowrap !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
    max-width: 210px !important;
}

/* Live Trip Control Sub-bar (Trip ONGOING & Role OWNER) */
.lt-live-activity-bar {
    display: flex !important;
    gap: 8px !important;
    align-items: center !important;
    margin-top: 10px !important;
    padding: 6px 10px !important;
    background: #f8fafc !important;
    border: 1px solid #e2e8f0 !important;
    border-radius: 10px !important;
    width: 100% !important;
    box-sizing: border-box !important;
}
.lt-btn-live-start {
    background: #175b43 !important;
    color: #ffffff !important;
    font-size: 11.5px !important;
    font-weight: 700 !important;
    border-radius: 8px !important;
    height: 32px !important;
    border: none !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 0 12px !important;
}
.lt-btn-live-start:hover {
    background: #124935 !important;
    color: #ffffff !important;
}
.lt-btn-live-complete {
    background: #059669 !important;
    color: #ffffff !important;
    font-size: 11.5px !important;
    font-weight: 700 !important;
    border-radius: 8px !important;
    height: 32px !important;
    border: none !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 0 12px !important;
}
.lt-btn-live-complete:hover {
    background: #047857 !important;
    color: #ffffff !important;
}
.lt-btn-live-skip, .lt-btn-live-extend {
    border: 1px solid #cbd5e1 !important;
    background: #ffffff !important;
    color: #64748b !important;
    font-size: 11.5px !important;
    font-weight: 600 !important;
    border-radius: 8px !important;
    height: 32px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 0 10px !important;
}
.lt-btn-live-skip:hover, .lt-btn-live-extend:hover {
    background: #f1f5f9 !important;
    color: #334155 !important;
}

/* Tier 3: Action Buttons (Strictly 4 equal columns in 1 single row) */
.lt-card-tier3 {
    border-top: 1px dashed #e2e8f0 !important;
    padding-top: 10px !important;
    margin-top: 10px !important;
    display: grid !important;
    grid-template-columns: repeat(4, 1fr) !important;
    gap: 6px !important;
    width: 100% !important;
    box-sizing: border-box !important;
}
.lt-act-btn {
    height: 34px !important;
    background: #f8fafc !important;
    border: 1px solid #cbd5e1 !important;
    border-radius: 10px !important;
    color: #1e293b !important;
    font-size: 11.5px !important;
    font-weight: 700 !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    gap: 4px !important;
    text-decoration: none !important;
    padding: 0 4px !important;
    white-space: nowrap !important;
    transition: all 0.15s ease !important;
    box-sizing: border-box !important;
    width: 100% !important;
    cursor: pointer !important;
}
.lt-act-btn:hover {
    background: #f1f5f9 !important;
    color: #0f172a !important;
    border-color: #94a3b8 !important;
}
.lt-act-btn-checkin {
    background: #ffffff !important;
    border: 1.5px solid #175b43 !important;
    color: #175b43 !important;
}
.lt-act-btn-checkin:hover {
    background: #ecfdf5 !important;
    color: #065f46 !important;
    border-color: #065f46 !important;
}
.lt-act-btn-checked {
    background: #ecfdf5 !important;
    border: 1.5px solid #175b43 !important;
    color: #175b43 !important;
}
.lt-act-btn-checked:hover {
    background: #d1fae5 !important;
    color: #047857 !important;
}
.lt-act-btn.disabled, span.lt-act-btn.disabled {
    opacity: 0.45 !important;
    background: #f8fafc !important;
    border-color: #e2e8f0 !important;
    color: #94a3b8 !important;
    cursor: not-allowed !important;
    pointer-events: none !important;
}
.lt-act-icon {
    font-size: 12px !important;
    line-height: 1 !important;
}

@media (max-width: 375px) {
    .lt-act-btn {
        font-size: 10.5px !important;
        gap: 2px !important;
        padding: 0 2px !important;
        letter-spacing: -0.3px !important;
    }
}
</style>

<div class="lt-itinerary-container">

    <%-- Flash Messages --%>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show mb-3" role="alert" style="border-radius: 12px; font-size: 13px;">
            <c:out value="${sessionScope.errorMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show mb-3" role="alert" style="border-radius: 12px; font-size: 13px;">
            <c:out value="${sessionScope.successMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <%-- Phase 3: Completion Banner if trip date passed --%>
    <c:if test="${trip.status == 'ONGOING' and isTripEnded}">
        <div class="alert alert-warning d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3 p-3" style="border-radius: 12px; border: 1px solid #fde68a; background: #fffbeb;">
            <div class="d-flex align-items-center gap-2">
                <span style="font-size: 22px;">🏁</span>
                <div>
                    <strong style="color: #92400e; font-size: 13px;">Trip end date has passed!</strong>
                    <div style="color: #b45309; font-size: 12px;">Scheduled dates have concluded. Ready to finalize your trip memories?</div>
                </div>
            </div>
            <c:if test="${trip.role == 'OWNER'}">
                <a href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}" class="btn btn-sm" style="background: #175b43; color: #fff; font-size: 12px; font-weight: 600; border-radius: 8px;">
                    Complete Trip in Trip Details &rarr;
                </a>
            </c:if>
        </div>
    </c:if>

    <%-- Phase 2: Live "Trip Day" Card --%>
    <c:if test="${trip.status == 'ONGOING'}">
        <div class="lt-live-trip-card mb-3 p-3" style="background: linear-gradient(135deg, #f0fdf4 0%, #ffffff 100%); border: 1.5px solid #86efac; border-radius: 14px; box-shadow: 0 2px 8px rgba(23, 91, 67, 0.08);">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2 pb-2 border-bottom" style="border-color: #dcfce7 !important;">
                <div class="d-flex align-items-center gap-2">
                    <c:choose>
                        <c:when test="${liveMode == 'NOW'}">
                            <span class="badge" style="background: #ef4444; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 20px;">
                                &#128308; Happening Now
                            </span>
                        </c:when>
                        <c:when test="${liveMode == 'NEXT'}">
                            <span class="badge" style="background: #0284c7; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 20px;">
                                &#9203; Next Up
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge" style="background: #64748b; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 20px;">
                                &#128203; Trip Status
                            </span>
                        </c:otherwise>
                    </c:choose>
                    <span style="font-size: 12px; font-weight: 700; color: #143b2d;">Live Schedule</span>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <a href="${pageContext.request.contextPath}/expenses/add?tripId=${trip.id}" class="btn btn-sm" style="background: #175b43; color: #fff; font-size: 11px; font-weight: 600; border-radius: 6px; text-decoration: none; padding: 3px 8px;">
                        + Add Expense
                    </a>
                    <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}" class="btn btn-sm btn-outline-secondary" style="font-size: 11px; border-radius: 6px; padding: 3px 8px;">
                        View Expenses
                    </a>
                </div>
            </div>

            <c:choose>
                <c:when test="${not empty liveItem}">
                    <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
                        <div>
                            <div style="font-size: 15px; font-weight: 700; color: #143b2d;">
                                <c:out value="${liveItem.placeName}"/>
                            </div>
                            <div class="text-muted" style="font-size: 12px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                                <span>&#128343;
                                    <c:choose>
                                        <c:when test="${not empty liveItem.startTime}">
                                            <fmt:formatDate value="${liveItem.startTime}" pattern="HH:mm"/>
                                            <c:if test="${not empty liveItem.endTime}">
                                                &ndash; <fmt:formatDate value="${liveItem.endTime}" pattern="HH:mm"/>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>Scheduled for today</c:otherwise>
                                    </c:choose>
                                </span>
                                <c:if test="${not empty liveItem.visitDate}">
                                    <span>&#128197; <fmt:formatDate value="${liveItem.visitDate}" pattern="dd/MM/yyyy"/></span>
                                </c:if>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-1">
                            <c:if test="${not empty liveItem.latitude and not empty liveItem.longitude}">
                                <a class="btn btn-sm"
                                   href="https://www.google.com/maps/dir/?api=1&destination=${liveItem.latitude},${liveItem.longitude}&travelmode=driving"
                                   target="_blank" rel="noopener noreferrer"
                                   style="background: #10b981; color: #fff; font-size: 11px; font-weight: 600; border-radius: 6px; padding: 4px 8px; text-decoration: none;">
                                    &#129517; Directions &nearr;
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-muted mb-2" style="font-size: 13px;">
                        No more activities scheduled for today.
                        <c:if test="${trip.role == 'OWNER'}">
                            <a href="${pageContext.request.contextPath}/places?tripId=${trip.id}" style="color: #175b43; font-weight: 600; text-decoration: underline;">
                                + Add destination
                            </a>
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>

            <%-- Progress Indicator --%>
            <div class="pt-2 border-top" style="border-color: #dcfce7 !important;">
                <div class="d-flex justify-content-between align-items-center" style="font-size: 11px; color: #475569; margin-bottom: 4px;">
                    <span>Today: <strong>${todayCompletedActivities} of ${todayTotalActivities}</strong> completed</span>
                    <span>Trip: <strong>${completedActivities} of ${totalActivities}</strong> completed</span>
                </div>
                <div class="progress" style="height: 6px; border-radius: 3px; background: #e2e8f0;">
                    <c:set var="overallPct" value="${totalActivities > 0 ? (completedActivities * 100 / totalActivities) : 0}"/>
                    <div class="progress-bar" role="progressbar" style="width: ${overallPct}%; background: #175b43;" aria-valuenow="${overallPct}" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
            </div>
        </div>
    </c:if>

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
                <c:set var="prevTimelineDate" value=""/>
                <c:forEach var="item" items="${items}" varStatus="status">
                    <c:if test="${item.date != prevTimelineDate}">
                        <c:set var="prevTimelineDate" value="${item.date}"/>
                        <div class="lt-day-group-header" data-day-group="${item.date}" style="margin: 16px 0 8px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 6px; padding: 4px 0; border-bottom: 2px solid #e2e8f0;">
                            <span style="font-size: 13px; font-weight: 800; color: #175b43;">
                                📅 <fmt:formatDate value="${item.visitDate}" pattern="EEEE, dd/MM/yyyy"/>
                            </span>
                            <c:if test="${packedDays.contains(item.visitDate)}">
                                <span class="badge" style="background: #fef3c7; color: #92400e; border: 1px solid #fde68a; font-size: 10px;">
                                    ⚠️ Packed day (>6 activities) — consider adding rest time
                                </span>
                            </c:if>
                        </div>
                    </c:if>
                    <div class="lt-stop-card lt-activity-row" data-activity-date="${item.date}" data-lat="${item.latitude}" data-lng="${item.longitude}">
                        <%-- TIER 1: Card Header (Drag handle, Order badge, Time on Left; Status, Lock on Right) --%>
                        <div class="lt-card-tier1">
                            <div class="lt-tier1-left">
                                <span class="lt-drag-handle" title="Drag to reorder">⋮⋮</span>
                                <span class="lt-stop-badge">${status.index + 1}</span>
                                <span class="lt-tier1-time">
                                    <c:choose>
                                        <c:when test="${not empty item.startTime}">
                                            🕒 <fmt:formatDate value="${item.startTime}" pattern="HH:mm"/>
                                            <c:if test="${not empty item.endTime}">
                                                – <fmt:formatDate value="${item.endTime}" pattern="HH:mm"/>
                                            </c:if>
                                            <span class="lt-tier1-duration">(${item.durationMinutes} mins)</span>
                                        </c:when>
                                        <c:otherwise>🕒 All day</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="lt-tier1-right">
                                <c:choose>
                                    <c:when test="${item.activityStatus == 'COMPLETED'}">
                                        <span class="lt-status-pill lt-status-done">&#10003; Done</span>
                                    </c:when>
                                    <c:when test="${item.activityStatus == 'IN_PROGRESS'}">
                                        <span class="lt-status-pill lt-status-ongoing">Ongoing</span>
                                    </c:when>
                                    <c:when test="${item.activityStatus == 'CANCELLED'}">
                                        <span class="lt-status-pill lt-status-skipped">Skipped</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="lt-status-pill lt-status-upcoming">Upcoming</span>
                                    </c:otherwise>
                                </c:choose>

                                <c:if test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
                                    <form method="post" action="${pageContext.request.contextPath}/itinerary/lock" style="margin: 0; display: inline-flex;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                        <input type="hidden" name="tripId" value="${trip.id}">
                                        <input type="hidden" name="itemId" value="${item.itemId}">
                                        <input type="hidden" name="locked" value="${item.locked ? 'false' : 'true'}">
                                        <button type="submit" class="lt-btn-lock-sq ${item.locked ? 'is-locked' : ''}"
                                                title="${item.locked ? 'Activity is locked (Pinned). Click to unlock' : 'Pin activity so auto-scheduling keeps it'}">
                                            ${item.locked ? '🔒' : '🔓'}
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${trip.role != 'OWNER' and item.locked}">
                                    <span class="lt-btn-lock-sq is-locked" title="Activity is pinned">🔒</span>
                                </c:if>
                            </div>
                        </div>

                        <%-- TIER 2: Card Body (Left: 56x56 thumbnail, Right: Place name, Cost pill, Cleaned note & tags) --%>
                        <div class="lt-card-tier2">
                            <img src="https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=120&auto=format&fit=crop&q=80"
                                 class="lt-stop-thumb"
                                 alt="<c:out value='${item.placeName}'/>"
                                 loading="lazy" />
                            <div class="lt-card-body-info">
                                <div class="lt-stop-name" title="<c:out value='${item.placeName}'/>">
                                    <c:out value="${item.placeName}"/>
                                </div>
                                <div class="lt-card-meta-row">
                                    <c:if test="${item.estimatedCost != null and item.estimatedCost > 0}">
                                        <span class="lt-meta-cost">
                                            <fmt:formatNumber value="${item.estimatedCost}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                        </span>
                                    </c:if>
                                    <c:set var="displayNote" value="${item.cleanedNote}"/>
                                    <c:if test="${empty displayNote and not empty item.note}">
                                        <c:set var="displayNote" value="${item.note}"/>
                                    </c:if>
                                    <c:if test="${not empty displayNote}">
                                        <c:if test="${item.estimatedCost != null and item.estimatedCost > 0}">
                                            <span class="lt-meta-dot">•</span>
                                        </c:if>
                                        <span class="lt-meta-note" title="<c:out value='${displayNote}'/>">
                                            <c:out value="${displayNote}"/>
                                        </span>
                                    </c:if>
                                    <c:if test="${item.sourceType == 'COMBO'}">
                                        <span class="badge" style="background: #fef3c7; color: #92400e; font-size: 9.5px; border: 1px solid #fde68a;">🍱 Combo</span>
                                    </c:if>
                                    <c:if test="${item.sourceType == 'AI'}">
                                        <span class="badge" style="background: #ecfdf5; color: #065f46; font-size: 9.5px; border: 1px solid #a7f3d0;">✨ AI</span>
                                    </c:if>
                                </div>
                                <c:if test="${not empty itemWarnings[item.itemId]}">
                                    <div class="lt-card-warning" style="margin-top: 3px;">
                                        <span class="badge" style="background: #fffbeb; color: #b45309; border: 1px solid #fcd34d; font-size: 10px;">
                                            ⚠️ <c:out value="${itemWarnings[item.itemId]}"/>
                                        </span>
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <%-- LIVE TRIP CONTROLS: Shown when Trip is ONGOING & User is OWNER --%>
                        <c:if test="${trip.status == 'ONGOING' and trip.role == 'OWNER' and (item.activityStatus == 'UPCOMING' or item.activityStatus == 'IN_PROGRESS')}">
                            <div class="lt-live-activity-bar">
                                <c:choose>
                                    <c:when test="${item.activityStatus == 'UPCOMING'}">
                                        <c:choose>
                                            <c:when test="${hasRunningActivity}">
                                                <button type="button" class="btn btn-sm lt-btn-live-start disabled flex-fill" disabled title="Finish current running activity first.">
                                                    ▶ Start Activity
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="post" action="${pageContext.request.contextPath}/itinerary/activity/status" style="margin: 0; flex: 1;">
                                                    <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                                    <input type="hidden" name="tripId" value="${trip.id}">
                                                    <input type="hidden" name="itemId" value="${item.id}">
                                                    <input type="hidden" name="expectedStatus" value="UPCOMING">
                                                    <input type="hidden" name="nextStatus" value="IN_PROGRESS">
                                                    <button type="submit" class="btn btn-sm lt-btn-live-start w-100">
                                                        ▶ Start Activity
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                        <form method="post" action="${pageContext.request.contextPath}/itinerary/activity/status" style="margin: 0;" onsubmit="return confirm('Skip this activity?');">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                            <input type="hidden" name="tripId" value="${trip.id}">
                                            <input type="hidden" name="itemId" value="${item.id}">
                                            <input type="hidden" name="expectedStatus" value="UPCOMING">
                                            <input type="hidden" name="nextStatus" value="CANCELLED">
                                            <button type="submit" class="btn btn-sm lt-btn-live-skip">
                                                Skip
                                            </button>
                                        </form>
                                    </c:when>

                                    <c:when test="${item.activityStatus == 'IN_PROGRESS'}">
                                        <form method="post" action="${pageContext.request.contextPath}/itinerary/activity/status" style="margin: 0; flex: 1;">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                            <input type="hidden" name="tripId" value="${trip.id}">
                                            <input type="hidden" name="itemId" value="${item.id}">
                                            <input type="hidden" name="expectedStatus" value="IN_PROGRESS">
                                            <input type="hidden" name="nextStatus" value="COMPLETED">
                                            <button type="submit" class="btn btn-sm lt-btn-live-complete w-100">
                                                &#10003; Complete Activity
                                            </button>
                                        </form>
                                        <div class="dropdown">
                                            <button class="btn btn-sm lt-btn-live-extend dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                Extend
                                            </button>
                                            <div class="dropdown-menu dropdown-menu-end p-2 shadow-sm" style="min-width: 170px;">
                                                <form method="post" action="${pageContext.request.contextPath}/itinerary/activity/status" class="m-0">
                                                    <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                                    <input type="hidden" name="tripId" value="${trip.id}">
                                                    <input type="hidden" name="itemId" value="${item.id}">
                                                    <input type="hidden" name="action" value="endTime">
                                                    <input type="hidden" name="expectedEnd" value="${item.endTime}">
                                                    <label class="form-label mb-1" style="font-size: 11px; font-weight: 600;">New End Time</label>
                                                    <input type="time" name="endTime" class="form-control form-control-sm mb-2" required style="font-size: 12px;">
                                                    <button type="submit" class="btn btn-sm w-100" style="background: #175b43; color: #fff; font-size: 11px;">
                                                        Save End Time
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </c:when>
                                </c:choose>
                            </div>
                        </c:if>

                        <%-- TIER 3: Action Buttons (Exactly 4 buttons, uniform 34px height, in a 4-column grid) --%>
                        <div class="lt-card-tier3">
                            <%-- 1. Directions --%>
                            <c:choose>
                                <c:when test="${not empty item.latitude and not empty item.longitude}">
                                    <a class="lt-act-btn"
                                       href="https://www.google.com/maps/dir/?api=1&destination=${item.latitude},${item.longitude}&travelmode=driving"
                                       target="_blank" rel="noopener noreferrer"
                                       title="Google Maps directions to this place">
                                        <span class="lt-act-icon">📍</span> Directions
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a class="lt-act-btn"
                                       href="https://www.google.com/maps/search/?api=1&query=${fn:escapeXml(item.placeName)}"
                                       target="_blank" rel="noopener noreferrer"
                                       title="Search directions on Google Maps">
                                        <span class="lt-act-icon">📍</span> Directions
                                    </a>
                                </c:otherwise>
                            </c:choose>

                            <%-- 2. Check-in --%>
                            <c:choose>
                                <c:when test="${not empty item.placeId and checkedInPlaceIds.contains(item.placeId)}">
                                    <a href="${pageContext.request.contextPath}/passport"
                                       class="lt-act-btn lt-act-btn-checked" title="Already checked in! Click to view passport">
                                        <span class="lt-act-icon">✓</span> Checked In
                                    </a>
                                </c:when>
                                <c:when test="${not empty item.placeId and item.placeId > 0}">
                                    <a href="${pageContext.request.contextPath}/checkin?tripId=${trip.id}&amp;placeId=${item.placeId}"
                                       class="lt-act-btn lt-act-btn-checkin" title="Check-in to this place">
                                        <span class="lt-act-icon">📸</span> Check-in
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="lt-act-btn disabled" title="Custom activity without location check-in">
                                        <span class="lt-act-icon">📸</span> Check-in
                                    </span>
                                </c:otherwise>
                            </c:choose>

                            <%-- 3. Share --%>
                            <c:choose>
                                <c:when test="${not empty item.placeId and item.placeId > 0}">
                                    <a href="${pageContext.request.contextPath}/dump?tripId=${trip.id}&amp;placeId=${item.placeId}"
                                       class="lt-act-btn" title="Share travel memory">
                                        <span class="lt-act-icon">📝</span> Share
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/dump?tripId=${trip.id}"
                                       class="lt-act-btn" title="Share trip memory">
                                        <span class="lt-act-icon">📝</span> Share
                                    </a>
                                </c:otherwise>
                            </c:choose>

                            <%-- 4. Edit --%>
                            <c:choose>
                                <c:when test="${trip.role == 'OWNER' and (trip.status == 'PLANNING' or trip.status == 'ONGOING') and item.activityStatus == 'UPCOMING'}">
                                    <a class="lt-act-btn"
                                       href="${pageContext.request.contextPath}/itinerary/edit?tripId=${trip.id}&amp;itemId=${item.id}"
                                       title="Edit activity details">
                                        <span class="lt-act-icon">✏️</span> Edit
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="lt-act-btn disabled" title="${item.activityStatus != 'UPCOMING' ? 'Only upcoming activities can be edited' : 'Only trip owner can edit'}">
                                        <span class="lt-act-icon">✏️</span> Edit
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- Travel connector between 2 stops --%>
                    <div class="lt-travel-connector lt-connector-row" data-activity-date="${item.date}" style="display: none;">
                        <span class="lt-connector-line"></span>
                        <span class="lt-connector-text"></span>
                    </div>
                </c:forEach>

                <div id="itineraryDayEmptyNotice" class="alert alert-light border text-center p-3 my-2 d-none" style="font-size: 13px; border-radius: 12px; color: #64748b;">
                </div>
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
                <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}" class="lt-btn-confirm-action" style="background: #175b43; color: #ffffff; text-decoration: none; text-align: center; display: inline-flex; align-items: center; justify-content: center; gap: 6px;">
                    &#128179; View &amp; Track Expenses &rarr;
                </a>
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

<%-- SCRIPT 2: Day Tabs Navigation & Straight-line Distance Measurement --%>
<script>
    (function () {
        const tabs = document.getElementById('itineraryDayTabs');
        if (!tabs) return;

        const rows = Array.from(document.querySelectorAll('.lt-stop-card.lt-activity-row'));
        const connectors = Array.from(document.querySelectorAll('.lt-travel-connector.lt-connector-row'));
        const emptyDayNotice = document.getElementById('itineraryDayEmptyNotice');
        const mapDayFilter = document.getElementById('mapDayFilter');
        const weatherDayFilter = document.getElementById('weatherDayFilter');
        const addBtn = document.getElementById('addDestinationBtn');

        const tripStatus = '${trip.status}';
        const todayStr = '${todayStr}';
        const tripStartDate = '<fmt:formatDate value="${trip.startDate}" pattern="yyyy-MM-dd"/>';
        const tripEndDate = '<fmt:formatDate value="${trip.endDate}" pattern="yyyy-MM-dd"/>';

        let dates = [...new Set(rows.map(row => row.dataset.activityDate).filter(Boolean))];

        // If ongoing trip and today is in trip date range, ensure today is in dates list
        if (tripStatus === 'ONGOING' && todayStr && tripStartDate && tripEndDate) {
            if (todayStr >= tripStartDate && todayStr <= tripEndDate && !dates.includes(todayStr)) {
                dates.push(todayStr);
                dates.sort();
            }
        }

        dates.forEach((date, index) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'lt-day-tab';
            button.dataset.day = date;

            const parts = date.split('-');
            const dateLabel = parts.length === 3 ? parts[2] + '/' + parts[1] : date;
            const isToday = (date === todayStr);

            button.innerHTML = '<span>Day ' + (index + 1) + (isToday ? ' (Today)' : '') + '</span><small>&bull; ' + dateLabel + '</small>';
            tabs.appendChild(button);
        });

        function calculateDistance(lat1, lon1, lat2, lon2) {
            if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) return null;
            if (isNaN(lat1) || isNaN(lon1) || isNaN(lat2) || isNaN(lon2)) return null;
            const R = 6371e3; // meters
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

            // Empty state notice for filtered day
            if (emptyDayNotice) {
                if (visibleRows.length === 0 && selectedDay !== 'ALL') {
                    emptyDayNotice.classList.remove('d-none');
                    emptyDayNotice.textContent = (selectedDay === todayStr)
                        ? 'No activities scheduled for today.'
                        : 'No activities scheduled for this day.';
                } else {
                    emptyDayNotice.classList.add('d-none');
                }
            }

            // Update connectors between visible stops
            connectors.forEach((conn, idx) => {
                const parentRow = rows[idx];
                const match = selectedDay === 'ALL' || conn.dataset.activityDate === selectedDay;

                if (!match || !parentRow || parentRow.style.display === 'none') {
                    conn.style.display = 'none';
                    return;
                }

                const currentVisibleIdx = visibleRows.indexOf(parentRow);
                const nextRow = (currentVisibleIdx >= 0 && currentVisibleIdx + 1 < visibleRows.length)
                    ? visibleRows[currentVisibleIdx + 1]
                    : null;

                if (!nextRow) {
                    conn.style.display = 'none';
                    return;
                }

                const lat1 = parseFloat(parentRow.dataset.lat);
                const lng1 = parseFloat(parentRow.dataset.lng);
                const lat2 = parseFloat(nextRow.dataset.lat);
                const lng2 = parseFloat(nextRow.dataset.lng);

                const dist = calculateDistance(lat1, lng1, lat2, lng2);
                const textEl = conn.querySelector('.lt-connector-text');

                if (dist != null && dist > 0 && textEl) {
                    conn.style.display = 'flex';
                    const km = (dist / 1000).toFixed(1);
                    textEl.textContent = '~' + km + ' km straight line';
                } else {
                    conn.style.display = 'none';
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

        function selectDayTab(selectedDay) {
            tabs.querySelectorAll('.lt-day-tab').forEach(tab => {
                const active = tab.dataset.day === selectedDay;
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
        }

        tabs.addEventListener('click', event => {
            const button = event.target.closest('[data-day]');
            if (!button) return;
            selectDayTab(button.dataset.day);
        });

        // Determine initial day tab
        let initialDay = 'ALL';
        if (tripStatus === 'ONGOING') {
            if (dates.includes(todayStr)) {
                initialDay = todayStr;
            } else if (dates.length > 0) {
                initialDay = dates[0];
            }
        }

        selectDayTab(initialDay);
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
