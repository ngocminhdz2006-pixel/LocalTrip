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

    <%-- 0. Quick Start Hub (When itinerary is empty) --%>
    <c:if test="${itineraryCount == 0 and (trip.status == 'PLANNING' or trip.status == 'ONGOING')}">
        <section class="lt-overview-card" style="background: linear-gradient(135deg, #143b2d 0%, #175b43 100%); color: #ffffff; padding: 20px; border-radius: 20px; margin-bottom: 16px;">
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                <span style="font-size: 20px;">🚀</span>
                <h2 style="font-size: 16px; font-weight: 800; margin: 0; color: #ffffff;">Quick Start Hub</h2>
            </div>
            <p style="font-size: 12px; color: #d1fae5; margin: 0 0 16px; line-height: 1.45;">
                Your itinerary is currently empty. Get your trip ready in seconds with curated day-combos or intelligent AI scheduling:
            </p>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                <a href="${pageContext.request.contextPath}/combos?tripId=${trip.id}"
                   style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 6px; padding: 14px 10px; background: #ffffff; color: #143b2d; border-radius: 14px; text-decoration: none; font-weight: 800; font-size: 12.5px; text-align: center; box-shadow: 0 4px 10px rgba(0,0,0,0.12); transition: transform 0.15s ease;">
                    <span style="font-size: 24px;">🍱</span>
                    <span>Choose Curated Combo</span>
                    <span style="font-size: 10px; color: #175b43; font-weight: 600;">(Auto-matches group vibe)</span>
                </a>
                <a href="${pageContext.request.contextPath}/itinerary/auto?tripId=${trip.id}"
                   style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 6px; padding: 14px 10px; background: rgba(255,255,255,0.15); color: #ffffff; border: 1.5px solid rgba(255,255,255,0.4); border-radius: 14px; text-decoration: none; font-weight: 800; font-size: 12.5px; text-align: center; transition: background 0.15s ease;">
                    <span style="font-size: 24px;">✨</span>
                    <span>AI Auto-Schedule</span>
                    <span style="font-size: 10px; color: #a7f3d0; font-weight: 600;">(Hourly smart draft)</span>
                </a>
            </div>
        </section>
    </c:if>

    <%-- Post-Trip Combo Review Section --%>
    <c:if test="${trip.status == 'COMPLETED' and not empty trip.appliedComboId and trip.appliedComboId > 0}">
        <section class="lt-overview-card" style="margin-bottom: 16px; border: 1.5px solid #bbf7d0; background: #f0fdf4;">
            <div class="lt-overview-head" style="margin-bottom: 10px;">
                <div>
                    <h2 class="lt-overview-title" style="color: #143b2d; display: flex; align-items: center; gap: 6px;">
                        <span>⭐</span> Post-Trip Combo Review
                    </h2>
                    <span style="font-size: 11px; color: #64748b;">Help the community evaluate this recommended combo</span>
                </div>
            </div>

            <c:choose>
                <c:when test="${hasReviewedAppliedCombo}">
                    <div style="display: flex; align-items: center; gap: 8px; padding: 12px; background: #dcfce7; border-radius: 12px; color: #166534; font-size: 12.5px; font-weight: 700;">
                        <span>✓</span> You have reviewed this combo for this trip. Thank you for your feedback!
                    </div>
                </c:when>
                <c:otherwise>
                    <form method="post" action="${pageContext.request.contextPath}/combo/review" style="display: flex; flex-direction: column; gap: 12px;">
                        <input type="hidden" name="tripId" value="${trip.id}">
                        <input type="hidden" name="comboId" value="${trip.appliedComboId}">

                        <div>
                            <label style="display: block; font-size: 11.5px; font-weight: 700; color: #143b2d; margin-bottom: 4px;">Overall Rating (1 - 5 Stars):</label>
                            <div style="display: flex; gap: 10px;">
                                <c:forEach var="star" begin="1" end="5">
                                    <label style="cursor: pointer; display: flex; align-items: center; gap: 3px; font-size: 13px; font-weight: 700; color: #b45309;">
                                        <input type="radio" name="rating" value="${star}" ${star == 5 ? 'checked' : ''} style="accent-color: #f59e0b;">
                                        ${star} ⭐
                                    </label>
                                </c:forEach>
                            </div>
                        </div>

                        <div>
                            <label style="display: block; font-size: 11.5px; font-weight: 700; color: #143b2d; margin-bottom: 4px;">Pace Feedback:</label>
                            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 6px;">
                                <label style="display: flex; align-items: center; justify-content: center; gap: 4px; padding: 8px; background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; font-size: 11px; font-weight: 600; cursor: pointer;">
                                    <input type="radio" name="paceFeedback" value="RELAXED" style="accent-color: #175b43;"> Relaxed 🌿
                                </label>
                                <label style="display: flex; align-items: center; justify-content: center; gap: 4px; padding: 8px; background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; font-size: 11px; font-weight: 600; cursor: pointer;">
                                    <input type="radio" name="paceFeedback" value="BALANCED" checked style="accent-color: #175b43;"> Balanced ⚖️
                                </label>
                                <label style="display: flex; align-items: center; justify-content: center; gap: 4px; padding: 8px; background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; font-size: 11px; font-weight: 600; cursor: pointer;">
                                    <input type="radio" name="paceFeedback" value="PACKED" style="accent-color: #175b43;"> Packed ⚡
                                </label>
                            </div>
                        </div>

                        <div>
                            <label style="display: block; font-size: 11.5px; font-weight: 700; color: #143b2d; margin-bottom: 4px;">Budget Accuracy:</label>
                            <div style="display: flex; gap: 12px;">
                                <label style="display: flex; align-items: center; gap: 4px; font-size: 12px; font-weight: 600; cursor: pointer;">
                                    <input type="radio" name="budgetMatch" value="1" checked style="accent-color: #175b43;"> ✓ Within expected budget
                                </label>
                                <label style="display: flex; align-items: center; gap: 4px; font-size: 12px; font-weight: 600; cursor: pointer;">
                                    <input type="radio" name="budgetMatch" value="0" style="accent-color: #e11d48;"> ✕ Over budget
                                </label>
                            </div>
                        </div>

                        <div>
                            <label style="display: block; font-size: 11.5px; font-weight: 700; color: #143b2d; margin-bottom: 4px;">Vibe Tags:</label>
                            <div style="display: flex; flex-wrap: wrap; gap: 6px;">
                                <c:forTokens var="tag" items="Couples,Friends,Great Food,Nature & Chill,Instagrammable,Nightlife,Budget-friendly" delims=",">
                                    <label style="display: inline-flex; align-items: center; gap: 4px; padding: 4px 10px; background: #ffffff; border: 1px solid #d1d5db; border-radius: 16px; font-size: 11px; cursor: pointer;">
                                        <input type="checkbox" name="vibeTags" value="${tag}" style="accent-color: #175b43;"> ${tag}
                                    </label>
                                </c:forTokens>
                            </div>
                        </div>

                        <div>
                            <label style="display: block; font-size: 11.5px; font-weight: 700; color: #143b2d; margin-bottom: 4px;">Detailed Review:</label>
                            <textarea name="comment" class="lt-form-input" style="min-height: 70px; font-size: 12px; width: 100%; border-radius: 10px;"
                                      placeholder="Share highlights, tips, or what future travelers should know..."></textarea>
                        </div>

                        <button type="submit" class="lt-btn-action-primary" style="padding: 12px; border-radius: 12px; font-weight: 700; font-size: 13px;">
                            ⭐ Submit Combo Review
                        </button>
                    </form>
                </c:otherwise>
            </c:choose>
        </section>
    </c:if>

    <%-- 0. Trip Planning Checklist (3 Steps) Wizard (Only shown when trip.status == 'PLANNING') --%>
    <%-- UNIFIED DASHBOARD: Trip Progress & Next Steps --%>
    <section class="lt-overview-card lt-planning-wizard-card" style="margin-bottom: 16px;">
        <div class="lt-overview-head" style="margin-bottom: 14px;">
            <div>
                <h2 class="lt-overview-title" style="display: flex; align-items: center; gap: 8px;">
                    <span>🧭</span> Trip Progress & Next Steps
                </h2>
                <span style="font-size: 12px; color: #64748b;">Complete setup to launch your journey smoothly</span>
            </div>
            <c:choose>
                <c:when test="${trip.status == 'ONGOING'}">
                    <span class="lt-step-badge lt-step-badge-ready" style="background:#d1fae5; color:#065f46;">🚀 Trip Active</span>
                </c:when>
                <c:when test="${trip.status == 'COMPLETED'}">
                    <span class="lt-step-badge lt-step-badge-ready" style="background:#e0e7ff; color:#3730a3;">✓ Completed</span>
                </c:when>
                <c:when test="${viewCanStart}">
                    <span class="lt-step-badge lt-step-badge-ready">✓ Ready to launch</span>
                </c:when>
                <c:otherwise>
                    <span class="lt-step-badge lt-step-badge-progress">In Planning</span>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="lt-wizard-steps">
            <%-- STEP 1: Invite Companions & Sync Vibes --%>
            <div class="lt-wizard-step-item">
                <div class="lt-wizard-step-header">
                    <div class="lt-step-circle ${fn:length(members) > 0 ? 'is-complete' : 'is-active'}">
                        ✓
                    </div>
                    <div class="lt-step-meta" style="flex: 1;">
                        <div class="lt-step-title-row">
                            <h3 class="lt-step-title">Step 1: Invite Companions & Sync Vibes</h3>
                            <span class="lt-pill-status lt-pill-success">${fn:length(members)} traveler(s) connected</span>
                        </div>
                        <p class="lt-step-desc" style="margin-bottom: 8px;">
                            Calculated automatically from ${fn:length(members)} members' profile preferences — 
                            <a href="${pageContext.request.contextPath}/account" style="color: #175b43; font-weight: 700; text-decoration: underline;">
                                [Edit my vibes in Account]
                            </a>
                        </p>

                        <%-- Group Matched Vibes Tags --%>
                        <c:choose>
                            <c:when test="${not empty groupMatchedPrefs}">
                                <div style="display: flex; flex-wrap: wrap; gap: 6px; margin: 4px 0 10px;">
                                    <c:forEach var="gp" items="${groupMatchedPrefs}">
                                        <div style="display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 16px; font-size: 11.5px; font-weight: 700; color: #143b2d;">
                                            <span>🎯 <c:out value="${gp.categoryName}"/></span>
                                            <span style="font-size: 9.5px; background: #175b43; color: #ffffff; padding: 1px 5px; border-radius: 8px;">
                                                <fmt:formatNumber value="${gp.percentage}" maxFractionDigits="0"/>%
                                            </span>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p style="font-size: 11px; color: #64748b; margin: 4px 0 8px; font-style: italic;">
                                    No common tastes found yet. Add members or update personal preferences in Account.
                                </p>
                            </c:otherwise>
                        </c:choose>

                        <%-- Invite Share Action Row --%>
                        <c:if test="${not empty tripInvite}">
                            <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 6px;">
                                <button type="button" class="lt-btn-step-action" style="background: #175b43; color: #fff; border: none; font-size: 11.5px; padding: 6px 12px;" onclick="copyTripInviteLink('${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/trip/join?token=${tripInvite.inviteToken}')">
                                    📋 Copy Invite Link
                                </button>
                                <button type="button" class="lt-btn-step-action lt-btn-step-outline" style="font-size: 11.5px; padding: 6px 12px;" onclick="openTripQrModal('${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/trip/join?token=${tripInvite.inviteToken}')">
                                    📲 Invite QR
                                </button>
                                <c:if test="${trip.role == 'OWNER'}">
                                    <form method="post" action="${pageContext.request.contextPath}/trip/invite" style="margin:0;">
                                        <input type="hidden" name="tripId" value="${trip.id}">
                                        <button type="submit" class="btn btn-link btn-sm text-secondary text-decoration-none" style="font-size: 11px;" title="Revoke and generate a fresh invite link">
                                            🔄 Refresh link
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <%-- STEP 2: Build Your Schedule --%>
            <div class="lt-wizard-step-item">
                <div class="lt-wizard-step-header">
                    <div class="lt-step-circle ${itineraryCount > 0 ? 'is-complete' : 'is-active'}">
                        <c:choose>
                            <c:when test="${itineraryCount > 0}">✓</c:when>
                            <c:otherwise>2</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="lt-step-meta" style="flex: 1;">
                        <div class="lt-step-title-row">
                            <h3 class="lt-step-title">Step 2: Build Your Schedule</h3>
                            <c:choose>
                                <c:when test="${itineraryCount > 0}">
                                    <span class="lt-pill-status lt-pill-success">✓ ${itineraryCount} activities scheduled</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="lt-pill-status lt-pill-warning">Schedule empty</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <p class="lt-step-desc">
                            <c:choose>
                                <c:when test="${itineraryCount > 0}">
                                    You have ${itineraryCount} activities planned across travel days. You can fine-tune stops or review map routes.
                                </c:when>
                                <c:otherwise>
                                    Choose how to craft your itinerary: apply an expert curated combo, auto-generate with AI, or handpick local spots.
                                </c:otherwise>
                            </c:choose>
                        </p>

                        <c:choose>
                            <c:when test="${itineraryCount == 0}">
                                <div class="lt-builder-grid">
                                    <a href="${pageContext.request.contextPath}/combos?tripId=${trip.id}" class="lt-builder-card">
                                        <div class="lt-builder-icon">🍱</div>
                                        <div class="lt-builder-info">
                                            <strong>Apply Curated Combo</strong>
                                            <span>Explore proven day-plans crafted by local experts</span>
                                        </div>
                                        <span class="lt-builder-arrow">→</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/itinerary/auto?tripId=${trip.id}" class="lt-builder-card">
                                        <div class="lt-builder-icon">✨</div>
                                        <div class="lt-builder-info">
                                            <strong>AI Auto-Schedule</strong>
                                            <span>Generate optimized timeline from group tastes & pace</span>
                                        </div>
                                        <span class="lt-builder-arrow">→</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/places?tripId=${trip.id}" class="lt-builder-card">
                                        <div class="lt-builder-icon">📍</div>
                                        <div class="lt-builder-info">
                                            <strong>Browse & Add Places</strong>
                                            <span>Search verified attractions and add directly</span>
                                        </div>
                                        <span class="lt-builder-arrow">→</span>
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px;">
                                    <a href="${pageContext.request.contextPath}/itinerary?tripId=${trip.id}" class="lt-btn-step-action lt-btn-step-primary" style="background: #175b43 !important; color: #ffffff !important; text-decoration: none;">
                                        🗺️ View & Manage Itinerary (${itineraryCount})
                                    </a>
                                    <a href="${pageContext.request.contextPath}/places?tripId=${trip.id}" class="lt-btn-step-action lt-btn-step-outline" style="color: #175b43 !important; text-decoration: none;">
                                        + Add More Places
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <%-- STEP 3: Launch & Track Expenses --%>
            <div class="lt-wizard-step-item">
                <div class="lt-wizard-step-header">
                    <div class="lt-step-circle ${viewCanStart || trip.status == 'ONGOING' || trip.status == 'COMPLETED' ? 'is-complete' : ''}">
                        3
                    </div>
                    <div class="lt-step-meta" style="flex: 1;">
                        <div class="lt-step-title-row">
                            <h3 class="lt-step-title">Step 3: Launch & Track Expenses</h3>
                            <c:choose>
                                <c:when test="${trip.status == 'ONGOING'}">
                                    <span class="lt-pill-status lt-pill-success">Live & Tracking</span>
                                </c:when>
                                <c:when test="${trip.status == 'COMPLETED'}">
                                    <span class="lt-pill-status lt-pill-success">Finalized</span>
                                </c:when>
                                <c:when test="${viewCanStart}">
                                    <span class="lt-pill-status lt-pill-success">Ready to launch</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="lt-pill-status lt-pill-muted">
                                        ${itineraryCount == 0 ? 'Requires activities' : 'Awaiting start date'}
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <p class="lt-step-desc">
                            <c:choose>
                                <c:when test="${trip.status == 'ONGOING'}">
                                    Trip is in progress! Check in at locations, update activity milestones, and log shared expenses for VietQR split.
                                </c:when>
                                <c:when test="${viewCanStart}">
                                    All prerequisites met! Schedule is confirmed and dates are active. Launch the live experience now.
                                </c:when>
                                <c:otherwise>
                                    Condition to start: Requires at least 1 non-cancelled activity and current date must be between 
                                    <fmt:formatDate value="${trip.startDate}" pattern="dd/MM/yyyy"/> and <fmt:formatDate value="${trip.endDate}" pattern="dd/MM/yyyy"/>.
                                </c:otherwise>
                            </c:choose>
                        </p>

                        <c:if test="${trip.status == 'PLANNING' and trip.role == 'OWNER'}">
                            <div class="lt-step-action-row" style="margin-top: 8px;">
                                <form method="post" action="${pageContext.request.contextPath}/trip/status"
                                      onsubmit="return confirm('Launch this trip live now? You will be able to track live activity milestones and check-ins.');" style="margin: 0;">
                                    <input type="hidden" name="tripId" value="${trip.id}">
                                    <input type="hidden" name="status" value="ONGOING">
                                    <input type="hidden" name="statusToken" value="${sessionScope.tripStatusToken}">
                                    <button type="submit" class="lt-btn-step-action lt-btn-step-primary" ${viewCanStart ? '' : 'disabled'}>
                                        🚀 Start Trip Now
                                    </button>
                                </form>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </section>

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
                                        <span class="lt-member-tag-owner" title="Owner: Full control over itinerary, members, and status">Owner · Full control</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="lt-member-tag-member" title="Member: Collaborator - can suggest spots, add discussion notes, log expenses, and check in">Member · Collaborator</span>
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
                                        <button type="submit" class="lt-btn-quick-add" title="Add ${fn:escapeXml(friend.fullName)} to trip">
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

    
    <%-- 2. Trip Discussion & Quick Notes Card --%>
    <section class="lt-overview-card" style="margin-bottom: 16px;">
        <div class="lt-overview-head">
            <div>
                <h2 class="lt-overview-title" style="display: flex; align-items: center; gap: 6px;">
                    <span>💬</span> Trip Discussion & Notes
                </h2>
                <span style="font-size: 11px; color: #64748b;">Keep questions, recommendations, and decisions in one place</span>
            </div>
            <span class="lt-overview-badge">${fn:length(tripNotes)} note(s)</span>
        </div>

        <c:choose>
            <c:when test="${empty tripNotes}">
                <p style="font-size: 12px; color: #64748b; margin: 10px 0; font-style: italic;">
                    No notes posted yet. Start the conversation with your travel buddies below!
                </p>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 8px; margin: 12px 0 16px; max-height: 280px; overflow-y: auto;">
                    <c:forEach var="n" items="${tripNotes}">
                        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 10px 14px; position: relative;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                <strong style="font-size: 12px; color: #175b43;"><c:out value="${n.userName}"/></strong>
                                <span style="font-size: 10px; color: #94a3b8;">
                                    <fmt:formatDate value="${n.createdAt}" pattern="dd/MM HH:mm"/>
                                </span>
                            </div>
                            <p style="font-size: 12.5px; color: #334155; margin: 0; line-height: 1.45; word-break: break-word;">
                                <c:out value="${n.noteText}"/>
                            </p>
                            <c:if test="${n.userId == sessionScope.user.userId or trip.role == 'OWNER'}">
                                <form method="post" action="${pageContext.request.contextPath}/trip/note" style="margin: 4px 0 0; text-align: right;" onsubmit="return confirm('Delete this note?');">
                                    <input type="hidden" name="tripId" value="${trip.id}">
                                    <input type="hidden" name="noteId" value="${n.noteId}">
                                    <input type="hidden" name="noteAction" value="delete">
                                    <button type="submit" class="btn btn-link btn-sm text-danger p-0 text-decoration-none" style="font-size: 10px;">
                                        Delete
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

        <form method="post" action="${pageContext.request.contextPath}/trip/note" style="display: flex; gap: 8px; margin-top: 8px;">
            <input type="hidden" name="tripId" value="${trip.id}">
            <input type="hidden" name="noteAction" value="add">
            <input type="text" name="noteText" class="lt-form-input" style="min-height: 38px; font-size: 12px; flex: 1; border-radius: 10px;"
                   placeholder="Write a quick note or idea for the group..." maxlength="1000" required>
            <button type="submit" class="lt-btn-action-primary" style="padding: 0 16px; border-radius: 10px; font-size: 12px; font-weight: 700; white-space: nowrap;">
                Post
            </button>
        </form>
    </section>

    <%-- 3. Manage Trip Actions --%>
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
                              onsubmit="var count = ${incompleteActivityCount != null ? incompleteActivityCount : 0}; if (count > 0) { return confirm('You still have ' + count + ' incomplete activity/activities in this itinerary. Completing the trip will finalize it. Are you sure you want to finish the trip?'); } return confirm('Mark trip as completed?');" style="margin: 0;">
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
                <section class="lt-overview-card" style="border-color: #fecdd3; background: #fffcfc;">
                    <h3 style="font-size: 13.5px; font-weight: 700; color: #991b1b; margin: 0 0 6px;">Cancel or Delete Trip</h3>
                    
                    <div style="display: flex; flex-direction: column; gap: 14px; margin-top: 10px;">
                        <div style="background: #ffffff; border: 1px solid #fee2e2; border-radius: 10px; padding: 10px 12px;">
                            <strong style="font-size: 12px; color: #991b1b; display: block; margin-bottom: 2px;">Option 1: Cancel Trip</strong>
                            <p style="font-size: 11px; color: #64748b; margin: 0 0 8px; line-height: 1.4;">
                                Changes trip status to <strong>CANCELLED</strong>. Preserves all schedules, checked-in spots, and expense settlements so companions can still review history.
                            </p>
                            <form method="post" action="${pageContext.request.contextPath}/trip/status"
                                  onsubmit="return confirm('Cancel this trip? Its itinerary and expense records will remain available for history.');" style="margin: 0;">
                                <input type="hidden" name="tripId" value="${trip.id}">
                                <input type="hidden" name="status" value="CANCELLED">
                                <input type="hidden" name="statusToken" value="${sessionScope.tripStatusToken}">
                                <button type="submit" class="lt-btn-danger-outline" style="font-size: 12px; padding: 6px 14px;">
                                    Cancel trip
                                </button>
                            </form>
                        </div>

                        <c:if test="${trip.role == 'OWNER' and trip.status == 'PLANNING'}">
                            <div style="background: #ffffff; border: 1px solid #fecdd3; border-radius: 10px; padding: 10px 12px;">
                                <strong style="font-size: 12px; color: #b91c1c; display: block; margin-bottom: 2px;">Option 2: Delete Permanently</strong>
                                <p style="font-size: 11px; color: #64748b; margin: 0 0 8px; line-height: 1.4;">
                                    Permanently wipes this trip, its items, and member associations. Only permitted while in <strong>PLANNING</strong> phase. Cannot be undone.
                                </p>
                                <form method="post" action="${pageContext.request.contextPath}/trip/delete"
                                      onsubmit="return confirm('PERMANENT DELETION: Are you sure you want to permanently delete this trip and all its data? This cannot be undone.');" style="margin: 0;">
                                    <input type="hidden" name="tripId" value="${trip.id}">
                                    <input type="hidden" name="deleteToken" value="${sessionScope.tripDeleteToken}">
                                    <button type="submit" class="lt-btn-danger-outline" style="background: #fee2e2; border-color: #f87171; color: #991b1b; font-size: 12px; padding: 6px 14px;">
                                        Delete trip permanently
                                    </button>
                                </form>
                            </div>
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

<%-- Trip Invite QR Modal --%>
<div id="tripQrModal" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 9999; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
    <div style="background: #fff; border-radius: 20px; padding: 24px; max-width: 320px; width: 90%; text-align: center; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
        <h3 style="font-size: 16px; font-weight: 800; color: #175b43; margin-bottom: 4px;">Join "${fn:escapeXml(trip.name)}"</h3>
        <p style="font-size: 11.5px; color: #64748b; margin-bottom: 14px;">Scan with phone camera or QR reader to join this trip instantly</p>
        <div id="tripQrContainer" style="display: flex; justify-content: center; margin-bottom: 14px;"></div>
        <button type="button" class="btn btn-secondary btn-sm rounded-pill px-4" onclick="closeTripQrModal()">Close</button>
    </div>
</div>

<script>
function copyTripInviteLink(url) {
    if (navigator.clipboard) {
        navigator.clipboard.writeText(url).then(function() {
            if (typeof showLocalTripToast === 'function') {
                showLocalTripToast('Trip invite link copied to clipboard!', 'success');
            } else {
                alert('Trip invite link copied to clipboard!');
            }
        });
    } else {
        prompt('Copy invite link:', url);
    }
}
function openTripQrModal(url) {
    var modal = document.getElementById('tripQrModal');
    var container = document.getElementById('tripQrContainer');
    if (modal && container) {
        container.innerHTML = '<img src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=' + encodeURIComponent(url) + '" alt="Trip QR Code" style="width:180px;height:180px;border-radius:12px;border:1px solid #e2e8f0;">';
        modal.style.display = 'flex';
    }
}
function closeTripQrModal() {
    var modal = document.getElementById('tripQrModal');
    if (modal) modal.style.display = 'none';
}
</script>

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
    .lt-btn-step-primary,
    a.lt-btn-step-primary,
    a.lt-btn-step-primary:link,
    a.lt-btn-step-primary:visited,
    button.lt-btn-step-primary {
        background: #175b43 !important;
        color: #ffffff !important;
        text-decoration: none !important;
    }
    .lt-btn-step-primary:hover:not(:disabled),
    a.lt-btn-step-primary:hover,
    button.lt-btn-step-primary:hover:not(:disabled) {
        background: #143b2d !important;
        color: #ffffff !important;
        text-decoration: none !important;
    }
    .lt-btn-step-primary:disabled,
    button.lt-btn-step-primary:disabled {
        background: #cbd5e1 !important;
        color: #64748b !important;
        cursor: not-allowed;
    }
    .lt-btn-step-outline,
    a.lt-btn-step-outline,
    a.lt-btn-step-outline:link,
    a.lt-btn-step-outline:visited,
    button.lt-btn-step-outline {
        background: #f8fafc !important;
        color: #175b43 !important;
        border: 1.5px solid #cbd5e1 !important;
        text-decoration: none !important;
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
