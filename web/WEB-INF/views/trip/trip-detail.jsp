<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<fmt:setLocale value="en_US"/>
<c:set var="pageTitle" value="Trip Overview" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<div class="lt-overview-container">

    <%-- 0. Trip Planning Checklist (3 Steps) Wizard (Only shown when trip.status == 'PLANNING') --%>
    <c:if test="${trip.status == 'PLANNING'}">
        <section class="lt-overview-card lt-planning-wizard-card">
            <div class="lt-overview-head" style="margin-bottom: 14px;">
                <div>
                    <h2 class="lt-overview-title" style="display: flex; align-items: center; gap: 8px;">
                        <span>📋</span> Trip Planning Checklist
                    </h2>
                    <span style="font-size: 12px; color: #64748b;">Complete 3 steps to get your trip ready</span>
                </div>
                <c:choose>
                    <c:when test="${itineraryCount > 0}">
                        <span class="lt-step-badge lt-step-badge-ready">✓ Ready to roll</span>
                    </c:when>
                    <c:otherwise>
                        <span class="lt-step-badge lt-step-badge-progress">Step-by-step</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="lt-wizard-steps">
                <%-- STEP 1: Group & Preferences --%>
                <div class="lt-wizard-step-item">
                    <div class="lt-wizard-step-header">
                        <div class="lt-step-circle ${hasUserPreference ? 'is-complete' : 'is-active'}">
                            <c:choose>
                                <c:when test="${hasUserPreference}">✓</c:when>
                                <c:otherwise>1</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="lt-step-meta">
                            <div class="lt-step-title-row">
                                <h3 class="lt-step-title">Step 1: Group & Preferences</h3>
                                <c:choose>
                                    <c:when test="${hasUserPreference}">
                                        <span class="lt-pill-status lt-pill-success">✓ Preferences set</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="lt-pill-status lt-pill-pending">Pending preferences</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <p class="lt-step-desc">
                                ${fn:length(members)} <c:out value="${fn:length(members) > 1 ? 'members joined' : 'member (You)'}"/>. Set dining, activity & budget preferences for group suggestions.
                            </p>
                        </div>
                    </div>
                    <div class="lt-step-action-row">
                        <a href="${pageContext.request.contextPath}/preferences?tripId=${trip.id}" class="lt-btn-step-action">
                            🎯 ${hasUserPreference ? 'Update Travel Preferences' : 'Set Travel Preferences'}
                        </a>
                    </div>
                </div>

                <%-- STEP 2: Build Your Itinerary --%>
                <div class="lt-wizard-step-item">
                    <div class="lt-wizard-step-header">
                        <div class="lt-step-circle ${itineraryCount > 0 ? 'is-complete' : 'is-active'}">
                            <c:choose>
                                <c:when test="${itineraryCount > 0}">✓</c:when>
                                <c:otherwise>2</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="lt-step-meta">
                            <div class="lt-step-title-row">
                                <h3 class="lt-step-title">Step 2: Build Your Itinerary</h3>
                                <c:choose>
                                    <c:when test="${itineraryCount > 0}">
                                        <span class="lt-pill-status lt-pill-success">✓ ${itineraryCount} activities scheduled</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="lt-pill-status lt-pill-warning">Need activities</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <p class="lt-step-desc">
                                Choose how you want to schedule: generate automatically with AI, pick a curated combo, or add places manually.
                            </p>
                        </div>
                    </div>
                    <div class="lt-builder-grid">
                        <a href="${pageContext.request.contextPath}/itinerary/auto?tripId=${trip.id}" class="lt-builder-card">
                            <div class="lt-builder-icon">✨</div>
                            <div class="lt-builder-info">
                                <strong>Auto-Generate Schedule</strong>
                                <span>AI creates a smart schedule from group preferences</span>
                            </div>
                            <span class="lt-builder-arrow">→</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/combos?tripId=${trip.id}" class="lt-builder-card">
                            <div class="lt-builder-icon">🍱</div>
                            <div class="lt-builder-info">
                                <strong>Choose Curated Combo</strong>
                                <span>Explore proven day-plans and vote with friends</span>
                            </div>
                            <span class="lt-builder-arrow">→</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/itinerary/add?tripId=${trip.id}" class="lt-builder-card">
                            <div class="lt-builder-icon">📍</div>
                            <div class="lt-builder-info">
                                <strong>Add Places Manually</strong>
                                <span>Browse local spots and handcraft your itinerary</span>
                            </div>
                            <span class="lt-builder-arrow">→</span>
                        </a>
                    </div>
                </div>

                <%-- STEP 3: Review Map & Start Trip --%>
                <div class="lt-wizard-step-item">
                    <div class="lt-wizard-step-header">
                        <div class="lt-step-circle ${viewCanStart ? 'is-complete' : ''}">
                            3
                        </div>
                        <div class="lt-step-meta">
                            <div class="lt-step-title-row">
                                <h3 class="lt-step-title">Step 3: Review Map & Start Trip</h3>
                                <c:choose>
                                    <c:when test="${viewCanStart}">
                                        <span class="lt-pill-status lt-pill-success">Ready to start</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="lt-pill-status lt-pill-muted">
                                            ${itineraryCount == 0 ? 'Waiting for activities' : 'Awaiting travel date'}
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <p class="lt-step-desc">
                                <c:choose>
                                    <c:when test="${itineraryCount > 0}">
                                        ${itineraryCount} activity/activities scheduled. Review timeline and launch when ready!
                                    </c:when>
                                    <c:otherwise>
                                        No activities added yet. Complete Step 2 first to enable starting the trip.
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>
                    <div class="lt-step-action-row" style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <c:if test="${itineraryCount > 0}">
                            <a href="${pageContext.request.contextPath}/itinerary?tripId=${trip.id}" class="lt-btn-step-action lt-btn-step-outline">
                                🗺️ View Itinerary (${itineraryCount})
                            </a>
                        </c:if>
                        <c:if test="${trip.role == 'OWNER'}">
                            <form method="post" action="${pageContext.request.contextPath}/trip/status"
                                  onsubmit="return confirm('Confirm current itinerary and start trip?');" style="margin: 0;">
                                <input type="hidden" name="tripId" value="${trip.id}">
                                <input type="hidden" name="status" value="ONGOING">
                                <input type="hidden" name="statusToken" value="${sessionScope.tripStatusToken}">
                                <button type="submit" class="lt-btn-step-action lt-btn-step-primary" ${viewCanStart ? '' : 'disabled'}>
                                    🚀 Start trip now
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>
        </section>
    </c:if>

    <%-- 1. Trip Members Card --%>
    <section class="lt-overview-card">
        <div class="lt-overview-head">
            <div>
                <h2 class="lt-overview-title">Trip Members</h2>
                <span style="font-size: 11px; color: #64748b;">Plan itinerary and share expenses together</span>
            </div>
            <span class="lt-overview-badge">${fn:length(members)} members</span>
        </div>

        <c:choose>
            <c:when test="${empty members}">
                <p style="font-size: 12px; color: #64748b; margin: 10px 0;">No member information available.</p>
            </c:when>
            <c:otherwise>
                <div class="lt-members-list">
                    <c:forEach var="member" items="${members}">
                        <div class="lt-member-row">
                            <div class="lt-member-info-wrap">
                                <div class="lt-member-avatar">
                                    <c:out value="${fn:substring(member.fullName, 0, 1)}"/>
                                </div>
                                <div>
                                    <h4 class="lt-member-name"><c:out value="${member.fullName}"/></h4>
                                    <p class="lt-member-email"><c:out value="${member.email}"/></p>
                                </div>
                            </div>

                            <div style="display: flex; align-items: center; gap: 8px;">
                                <c:choose>
                                    <c:when test="${member.role == 'OWNER'}">
                                        <span class="lt-member-tag-owner">Trip owner</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="lt-member-tag-member">Member</span>
                                        <c:if test="${trip.role == 'OWNER'}">
                                            <form method="post" action="${pageContext.request.contextPath}/trip/member/remove"
                                                  onsubmit="return confirm('Remove this member from the trip?');" style="margin: 0;">
                                                <input type="hidden" name="tripId" value="${trip.id}">
                                                <input type="hidden" name="userId" value="${member.userId}">
                                                <button type="submit" class="lt-btn-remove-member" title="Remove member">
                                                    🗑️
                                                </button>
                                            </form>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

        <%-- Form Invite Member by Email (For Trip Owner) --%>
        <c:if test="${trip.role == 'OWNER'}">
            <div style="margin-top: 14px; padding-top: 12px; border-top: 1px dashed #e2e8f0;">
                <span style="font-size: 11px; font-weight: 700; color: #143b2d; display: block; margin-bottom: 6px;">
                    Invite a new member to this trip
                </span>

                <c:if test="${not empty availableFriends}">
                    <div style="margin-bottom: 12px;">
                        <span style="font-size: 11px; color: #64748b; display: block; margin-bottom: 6px;">
                            Quick invite friends (1-tap):
                        </span>
                        <div class="lt-quick-invite-scroll">
                            <c:forEach var="friend" items="${availableFriends}">
                                <div class="lt-quick-friend-chip">
                                    <div class="lt-quick-friend-avatar">
                                        <c:out value="${fn:substring(friend.fullName, 0, 1)}"/>
                                    </div>
                                    <div class="lt-quick-friend-info">
                                        <span class="lt-quick-friend-name"><c:out value="${friend.fullName}"/></span>
                                        <span class="lt-quick-friend-email"><c:out value="${friend.email}"/></span>
                                    </div>
                                    <form method="post" action="${pageContext.request.contextPath}/trip/member/add" style="margin: 0;">
                                        <input type="hidden" name="tripId" value="${trip.id}">
                                        <input type="hidden" name="email" value="${friend.email}">
                                        <button type="submit" class="lt-btn-quick-add" title="Add ${friend.fullName} to trip">
                                            + Add
                                        </button>
                                    </form>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/trip/member/add" style="display: flex; gap: 8px;">
                    <input type="hidden" name="tripId" value="${trip.id}">
                    <input type="email" name="email" class="lt-form-input" style="min-height: 40px; font-size: 12px; flex: 1;"
                           placeholder="Or enter friend's email..." required>
                    <button type="submit" class="lt-btn-action-primary" style="padding: 0 16px; border-radius: 12px; white-space: nowrap;">
                        + Invite
                    </button>
                </form>
            </div>
        </c:if>
    </section>

    <%-- 2. Manage Trip Actions --%>
    <c:choose>
        <c:when test="${trip.role == 'OWNER'}">
            <%
                if (session.getAttribute("tripStatusToken") == null) {
                    session.setAttribute("tripStatusToken", java.util.UUID.randomUUID().toString());
                }
                if (session.getAttribute("tripDeleteToken") == null) {
                    session.setAttribute("tripDeleteToken", java.util.UUID.randomUUID().toString());
                }
            %>

            <section class="lt-overview-card">
                <div class="lt-overview-head">
                    <h2 class="lt-overview-title">Manage Trip</h2>
                    <span style="font-size: 11px; color: #175b43; font-weight: 600;">Status: ${trip.status}</span>
                </div>

                <div class="lt-manage-actions">
                    <c:if test="${trip.status == 'PLANNING' or trip.status == 'ONGOING'}">
                        <a href="${pageContext.request.contextPath}/trip/edit?tripId=${trip.id}" class="lt-btn-manage-secondary">
                            ✏️ Edit trip details
                        </a>
                    </c:if>

                    <c:if test="${trip.status == 'PLANNING'}">
                        <form method="post" action="${pageContext.request.contextPath}/trip/status"
                              onsubmit="return confirm('Confirm current itinerary and start trip?');" style="margin: 0;">
                            <input type="hidden" name="tripId" value="${trip.id}">
                            <input type="hidden" name="status" value="ONGOING">
                            <input type="hidden" name="statusToken" value="${sessionScope.tripStatusToken}">

                            <button type="submit" class="lt-btn-manage-primary" ${viewCanStart ? '' : 'disabled'}>
                                🚀 Start trip now
                            </button>
                        </form>
                        <c:if test="${not viewCanStart}">
                            <p style="font-size: 11px; color: #b45309; margin: 4px 0 0; text-align: center;">
                                <c:out value="${viewStartReason}"/>
                            </p>
                        </c:if>
                    </c:if>

                    <c:if test="${trip.status == 'ONGOING'}">
                        <form method="post" action="${pageContext.request.contextPath}/trip/status"
                              onsubmit="return confirm('Mark trip as completed?');" style="margin: 0;">
                            <input type="hidden" name="tripId" value="${trip.id}">
                            <input type="hidden" name="status" value="COMPLETED">
                            <input type="hidden" name="statusToken" value="${sessionScope.tripStatusToken}">

                            <button type="submit" class="lt-btn-manage-primary" style="background: #047857;">
                                ✓ Mark trip as completed
                            </button>
                        </form>
                    </c:if>
                </div>
            </section>

            <c:if test="${trip.status == 'PLANNING' or trip.status == 'ONGOING'}">
                <section class="lt-overview-card" style="border-color: #fecdd3;">
                    <h3 style="font-size: 13px; font-weight: 700; color: #e11d48; margin: 0 0 6px;">Cancel or Delete Trip</h3>
                    <p style="font-size: 11px; color: #64748b; margin: 0 0 12px;">Cancelling the trip preserves history for group members to view.</p>

                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <form method="post" action="${pageContext.request.contextPath}/trip/status"
                              onsubmit="return confirm('Cancel this trip? Existing data will be preserved.');" style="margin: 0;">
                            <input type="hidden" name="tripId" value="${trip.id}">
                            <input type="hidden" name="status" value="CANCELLED">
                            <input type="hidden" name="statusToken" value="${sessionScope.tripStatusToken}">
                            <button type="submit" class="lt-btn-danger-outline">
                                Cancel trip
                            </button>
                        </form>

                        <c:if test="${trip.role == 'OWNER' and trip.status == 'PLANNING'}">
                            <form method="post" action="${pageContext.request.contextPath}/trip/delete"
                                  onsubmit="return confirm('Permanently delete trip, itinerary, and all associated data?');" style="margin: 0;">
                                <input type="hidden" name="tripId" value="${trip.id}">
                                <input type="hidden" name="deleteToken" value="${sessionScope.tripDeleteToken}">
                                <button type="submit" class="lt-btn-danger-outline" style="background: #fff1f2; border-color: #fda4af;">
                                    Delete trip permanently
                                </button>
                            </form>
                        </c:if>
                    </div>
                </section>
            </c:if>
        </c:when>

        <c:otherwise>
            <section class="lt-overview-card">
                <h2 class="lt-overview-title">Your role</h2>
                <p style="font-size: 12px; color: #64748b; margin: 6px 0 0; line-height: 1.4;">
                    You are participating as a <strong>Member</strong>. You can view itineraries, vote on combos, submit preferences, and split travel expenses. The trip owner manages the itinerary and status.
                </p>
            </section>
        </c:otherwise>
    </c:choose>

</div>

<style>
    /* Planning Wizard Styles */
    .lt-planning-wizard-card {
        border-color: #bbf7d0;
        background: linear-gradient(180deg, #f7fdf9 0%, #ffffff 100%);
    }
    .lt-step-badge {
        font-size: 11px;
        font-weight: 700;
        padding: 4px 10px;
        border-radius: 999px;
        text-transform: uppercase;
        letter-spacing: 0.03em;
    }
    .lt-step-badge-progress {
        background: #fef3c7;
        color: #92400e;
    }
    .lt-step-badge-ready {
        background: #dcfce7;
        color: #166534;
    }
    .lt-wizard-steps {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }
    .lt-wizard-step-item {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        padding: 14px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03);
    }
    .lt-wizard-step-header {
        display: flex;
        align-items: flex-start;
        gap: 12px;
    }
    .lt-step-circle {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: #f1f5f9;
        color: #64748b;
        font-weight: 800;
        font-size: 13px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        border: 1.5px solid #cbd5e1;
    }
    .lt-step-circle.is-active {
        background: #e4f0e8;
        color: #175b43;
        border-color: #175b43;
    }
    .lt-step-circle.is-complete {
        background: #175b43;
        color: #ffffff;
        border-color: #175b43;
    }
    .lt-step-meta {
        flex: 1;
        min-width: 0;
    }
    .lt-step-title-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        flex-wrap: wrap;
        margin-bottom: 4px;
    }
    .lt-step-title {
        font-size: 13.5px;
        font-weight: 700;
        color: #143b2d;
        margin: 0;
    }
    .lt-pill-status {
        font-size: 10.5px;
        font-weight: 700;
        padding: 2px 8px;
        border-radius: 999px;
    }
    .lt-pill-success {
        background: #dcfce7;
        color: #166534;
    }
    .lt-pill-warning {
        background: #fef3c7;
        color: #92400e;
    }
    .lt-pill-pending {
        background: #f1f5f9;
        color: #475569;
    }
    .lt-pill-muted {
        background: #f8fafc;
        color: #94a3b8;
    }
    .lt-step-desc {
        font-size: 11.5px;
        color: #64748b;
        margin: 0;
        line-height: 1.45;
    }
    .lt-step-action-row {
        margin-top: 12px;
        padding-top: 10px;
        border-top: 1px dashed #f1f5f9;
    }
    .lt-btn-step-action {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 9px 16px;
        border-radius: 10px;
        font-size: 12px;
        font-weight: 700;
        text-decoration: none;
        cursor: pointer;
        transition: all 0.2s ease;
        border: none;
    }
    .lt-btn-step-action:not(.lt-btn-step-primary):not(.lt-btn-step-outline) {
        background: #175b43;
        color: #ffffff;
    }
    .lt-btn-step-action:not(.lt-btn-step-primary):not(.lt-btn-step-outline):hover {
        background: #143b2d;
    }
    .lt-btn-step-primary {
        background: #175b43;
        color: #ffffff;
    }
    .lt-btn-step-primary:hover:not(:disabled) {
        background: #143b2d;
    }
    .lt-btn-step-primary:disabled {
        background: #cbd5e1;
        cursor: not-allowed;
    }
    .lt-btn-step-outline {
        background: #f8fafc;
        color: #175b43;
        border: 1px solid #cbd5e1;
    }
    .lt-btn-step-outline:hover {
        background: #f1f5f9;
        border-color: #94a3b8;
    }

    /* Builder 3 Cards Grid */
    .lt-builder-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 10px;
        margin-top: 12px;
    }
    .lt-builder-card {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 12px;
        border: 1.5px solid #e2e8f0;
        border-radius: 12px;
        background: #ffffff;
        text-decoration: none;
        color: inherit;
        transition: all 0.2s ease;
    }
    .lt-builder-card:hover {
        border-color: #175b43;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(23, 91, 67, 0.08);
    }
    .lt-builder-icon {
        font-size: 22px;
        width: 38px;
        height: 38px;
        border-radius: 10px;
        background: #f0fdf4;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .lt-builder-info {
        flex: 1;
        min-width: 0;
    }
    .lt-builder-info strong {
        display: block;
        font-size: 12px;
        font-weight: 700;
        color: #143b2d;
        margin-bottom: 2px;
    }
    .lt-builder-info span {
        display: block;
        font-size: 10.5px;
        color: #64748b;
        line-height: 1.35;
    }
    .lt-builder-arrow {
        font-size: 14px;
        font-weight: bold;
        color: #94a3b8;
        transition: transform 0.2s ease, color 0.2s ease;
    }
    .lt-builder-card:hover .lt-builder-arrow {
        color: #175b43;
        transform: translateX(3px);
    }

    /* Quick Friends Horizontal Scroll */
    .lt-quick-invite-scroll {
        display: flex;
        gap: 10px;
        overflow-x: auto;
        padding-bottom: 6px;
        -webkit-overflow-scrolling: touch;
        scrollbar-width: thin;
    }
    .lt-quick-friend-chip {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 6px 10px;
        border: 1px solid #dce7df;
        border-radius: 999px;
        background: #f8fafc;
        white-space: nowrap;
        flex-shrink: 0;
    }
    .lt-quick-friend-avatar {
        width: 26px;
        height: 26px;
        border-radius: 50%;
        background: #175b43;
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 11px;
        font-weight: 700;
    }
    .lt-quick-friend-info {
        display: flex;
        flex-direction: column;
        line-height: 1.2;
    }
    .lt-quick-friend-name {
        font-size: 11px;
        font-weight: 700;
        color: #143b2d;
    }
    .lt-quick-friend-email {
        font-size: 9.5px;
        color: #64748b;
        max-width: 110px;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .lt-btn-quick-add {
        border: none;
        background: #175b43;
        color: #ffffff;
        font-size: 11px;
        font-weight: 700;
        padding: 4px 10px;
        border-radius: 999px;
        cursor: pointer;
        transition: background 0.15s ease;
    }
    .lt-btn-quick-add:hover {
        background: #143b2d;
    }
</style>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
