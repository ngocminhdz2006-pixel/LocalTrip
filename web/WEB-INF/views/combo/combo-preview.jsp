<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"
           uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"
           uri="http://java.sun.com/jsp/jstl/functions" %>

<fmt:setLocale value="en_US" scope="page"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<style>
    .combo-preview-page {
        max-width: 760px;
        margin: 0 auto;
    }

    .combo-preview-heading {
        margin-bottom: 24px;
    }

    .combo-preview-heading h2 {
        margin: 16px 0 8px;
        font-size: 26px;
        font-weight: 700;
    }

    .combo-preview-notice {
        padding: 18px 20px;
        margin-bottom: 20px;
        background: var(--mint);
        border: 1px solid var(--line);
        border-radius: 14px;
        color: var(--ink2);
        line-height: 1.6;
    }

    .combo-preview-summary {
        margin-bottom: 24px;
    }

    .combo-preview-summary strong {
        color: var(--green);
        font-size: 23px;
    }

    .combo-preview-day {
        margin: 26px 0 14px;
        color: var(--green);
        font-size: 18px;
        font-weight: 700;
    }

    .combo-preview-activity {
        margin-bottom: 14px;
    }

    .combo-preview-activity h3 {
        margin: 10px 0;
        font-size: 19px;
        font-weight: 700;
    }

    .combo-preview-time {
        color: var(--green);
        font-weight: 600;
    }

    .combo-preview-type {
        display: inline-block;
        padding: 4px 9px;
        margin-left: 8px;
        background: var(--mint);
        color: var(--green);
        border-radius: 999px;
        font-size: 12px;
    }

    .combo-preview-note {
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        color: var(--ink2);
    }

    .combo-preview-old summary {
        font-weight: 600;
        cursor: pointer;
    }
</style>

<div class="combo-preview-page">
    <div class="combo-preview-heading">
        <a class="btn btn-outline-secondary btn-sm"
           href="${pageContext.request.contextPath}/combos?tripId=${trip.id}">
            Back to combos
        </a>

        <h2>Preview itinerary</h2>

        <p class="rd-sub">
            <c:out value="${selectedCombo.name}"/>
            · <c:out value="${trip.name}"/>
        </p>
    </div>

    <div class="combo-preview-notice">
        <strong>Your saved itinerary has not changed.</strong><br>
        This preview shows the selected template on your trip dates.
        Editing and confirmation will be added in the next step.
    </div>

    <c:if test="${overBudget}">
        <div class="alert alert-warning" role="alert">
            The estimated group cost is above your trip budget.
        </div>
    </c:if>

    <section class="rd-card combo-preview-summary">
        <p class="rd-sub mb-2">
            ${selectedCombo.durationDays} days · ${memberCount} members
        </p>

        <strong>
            <fmt:formatNumber value="${groupCost}"
                              maxFractionDigits="0"/> VND
        </strong>

        <p class="small text-muted mt-2 mb-0">
            Estimated group total ·
            <fmt:formatNumber
                value="${selectedCombo.estimatedCostPerPerson}"
                maxFractionDigits="0"/> VND per person
        </p>

        <c:if test="${not budgetDefined}">
            <p class="small text-muted mt-2 mb-0">
                No positive budget is set for this trip.
            </p>
        </c:if>

        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 10px; padding-top: 10px; border-top: 1px solid var(--line);">
            <span style="display: inline-flex; align-items: center; gap: 4px; background: #fef3c7; border: 1px solid #fde68a; padding: 2px 8px; border-radius: 12px; font-size: 11.5px; font-weight: 700; color: #b45309;">
                ⭐ <c:out value="${selectedCombo.avgRating > 0 ? selectedCombo.avgRating : 'New'}"/>
                <c:if test="${selectedCombo.reviewCount > 0}">
                    (${selectedCombo.reviewCount} reviews)
                </c:if>
            </span>
            <c:if test="${selectedCombo.reviewCount > 0}">
                <span style="font-size: 11px; color: #475569; background: #f1f5f9; padding: 2px 8px; border-radius: 12px; font-weight: 600;">
                    💰 ${selectedCombo.budgetMatchPercent}% Budget Met
                </span>
            </c:if>
            <c:if test="${selectedCombo.appliedTripsCount > 0}">
                <span style="font-size: 11px; color: #1e40af; background: #eff6ff; padding: 2px 8px; border-radius: 12px; font-weight: 600;">
                    🎯 Chosen by ${selectedCombo.appliedTripsCount} groups
                </span>
            </c:if>
        </div>
    </section>

    <c:set var="previousDay" value="0"/>

    <c:forEach var="activity" items="${previewActivities}">
        <c:if test="${activity.dayNumber != previousDay}">
            <h3 class="combo-preview-day">
                Day ${activity.dayNumber}
                ·
                <fmt:formatDate value="${activity.date}"
                                pattern="dd MMM yyyy"/>
            </h3>

            <c:set var="previousDay" value="${activity.dayNumber}"/>
        </c:if>

        <article class="rd-card combo-preview-activity">
            <div>
                <span class="combo-preview-time">
                    <fmt:formatDate value="${activity.startTime}"
                                    pattern="HH:mm"/>
                    –
                    <fmt:formatDate value="${activity.endTime}"
                                    pattern="HH:mm"/>
                </span>

                <span class="combo-preview-type">
                    <c:choose>
                        <c:when test="${activity.activityType == 'MEAL'}">
                            Meal
                        </c:when>
                        <c:when test="${activity.activityType == 'CAFE'}">
                            Café
                        </c:when>
                        <c:when test="${activity.activityType == 'REST'}">
                            Rest
                        </c:when>
                        <c:otherwise>
                            Visit
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>

            <h3><c:out value="${activity.title}"/></h3>

            <c:choose>
                <c:when test="${not empty activity.placeName}">
                    <p class="mb-1">
                        <c:out value="${activity.placeName}"/>
                    </p>

                    <p class="small text-muted">
                        <c:out value="${activity.address}"/>
                    </p>
                </c:when>

                <c:otherwise>
                    <p class="small text-muted">
                        Flexible rest time — no fixed place.
                    </p>
                </c:otherwise>
            </c:choose>

            <p class="small mb-0">
                Estimated cost:
                <fmt:formatNumber value="${activity.costPerPerson}"
                                  maxFractionDigits="0"/> VND per person
            </p>

            <c:if test="${not empty activity.note}">
                <p class="combo-preview-note small mt-2 mb-0"><c:out value="${activity.note}"/></p>
            </c:if>
        </article>
    </c:forEach>
    <c:url var="draftUrl" value="/combos/draft">
        <c:param name="tripId" value="${trip.id}"/>
    </c:url>

    <%-- Community Reviews for this Combo --%>
    <section class="rd-card mt-4 mb-4">
        <h3 class="h5 mb-2">Traveler Reviews (${fn:length(comboReviews)})</h3>
        <c:choose>
            <c:when test="${empty comboReviews}">
                <p class="small text-muted mb-0">No reviews yet for this combo template. Be the first to try it and share feedback!</p>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 10px;">
                    <c:forEach var="rev" items="${comboReviews}">
                        <div style="padding: 10px; background: #f8fafc; border-radius: 12px; border: 1px solid #e2e8f0;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                <strong><c:out value="${rev.userName}"/></strong>
                                <span style="color: #f59e0b; font-weight: 700;">${rev.rating} ⭐</span>
                            </div>
                            <div style="font-size: 11px; color: #64748b; margin-bottom: 4px;">
                                Pace: <strong>${rev.paceFeedback}</strong> · Budget: <strong>${rev.budgetMatch ? 'Met' : 'Over'}</strong>
                                <c:if test="${not empty rev.vibeTags}"> · Vibes: <em><c:out value="${rev.vibeTags}"/></em></c:if>
                            </div>
                            <c:if test="${not empty rev.comment}">
                                <p style="font-size: 12px; color: #334155; margin: 4px 0 0; line-height: 1.4;"><c:out value="${rev.comment}"/></p>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
    <div class="my-4">
        <a href="${draftUrl}" class="btn btn-brand">
            Edit this draft
        </a>
    </div>
    <details class="rd-card combo-preview-old mt-4 mb-4">
        <summary>View the current saved itinerary</summary>

        <c:choose>
            <c:when test="${empty oldItems}">
                <p class="rd-sub mt-3 mb-0">
                    No activities have been saved yet.
                </p>
            </c:when>

            <c:otherwise>
                <c:forEach var="item" items="${oldItems}">
                    <div class="border-bottom py-3">
                        <div class="small text-muted">
                            <fmt:formatDate value="${item.visitDate}"
                                            pattern="dd MMM yyyy"/>
                            ·
                            <fmt:formatDate value="${item.startTime}"
                                            pattern="HH:mm"/>
                            –
                            <fmt:formatDate value="${item.endTime}"
                                            pattern="HH:mm"/>
                        </div>

                        <strong>
                            <c:out value="${item.placeName}"/>
                        </strong>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </details>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>