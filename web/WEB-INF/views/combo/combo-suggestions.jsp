<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"
           uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="en_US" scope="page"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<style>
    .combo-choice-page {
        max-width: 760px;
        margin: 0 auto;
    }

    .combo-choice-heading {
        margin-bottom: 24px;
    }

    .combo-choice-heading h2 {
        font-size: 26px;
        font-weight: 700;
        margin: 16px 0 8px;
    }

    .combo-choice-card {
        margin-bottom: 20px;
    }

    .combo-choice-card h3 {
        font-size: 21px;
        font-weight: 700;
        margin-bottom: 10px;
    }

    .combo-choice-badge {
        display: inline-block;
        padding: 6px 10px;
        margin-bottom: 14px;
        border-radius: 999px;
        background: var(--mint);
        color: var(--green);
        font-size: 13px;
        font-weight: 600;
    }

    .combo-choice-badge.over {
        background: #FFF0CE;
        color: #805500;
    }

    .combo-choice-description {
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        color: var(--ink2);
    }

    .combo-choice-cost {
        margin-top: 18px;
        padding-top: 16px;
        border-top: 1px solid var(--line);
    }

    .combo-choice-cost strong {
        color: var(--green);
        font-size: 21px;
    }

    .combo-choice-details {
        margin-top: 18px;
    }

    .combo-choice-details summary {
        color: var(--green);
        cursor: pointer;
        font-weight: 600;
    }

    .combo-choice-activity {
        padding: 14px 0;
        border-bottom: 1px solid var(--line);
    }

    .combo-choice-activity:last-child {
        border-bottom: 0;
    }

    .combo-choice-time {
        color: var(--green);
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 6px;
    }

    .combo-choice-empty {
        padding: 36px 24px;
        text-align: center;
    }
</style>

<div class="combo-choice-page">
    <div class="combo-choice-heading">
        <a class="btn btn-outline-secondary btn-sm"
           href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}">
            Back to trip
        </a>

        <h2>Choose a combo</h2>
        <p class="rd-sub">
            <c:out value="${trip.name}"/>
            · <c:out value="${trip.destination}"/>
        </p>
    </div>

    <c:choose>
        <c:when test="${not empty notice}">
            <div class="rd-card">
                <c:out value="${notice}"/>
            </div>
        </c:when>

        <c:otherwise>
            <section class="rd-card mb-4">
                <h3 class="h5">Suggestions for your group</h3>

                <p class="rd-sub mb-2">
                    ${planningDays} days · ${memberCount} members
                </p>

                <p class="small text-muted mb-3">
                    Planning period:
                    <c:out value="${planningStart}"/>
                    –
                    <c:out value="${planningEnd}"/>
                </p>

                <c:if test="${not hasPreferences}">
                    <p class="small text-muted">
                        Your group has not selected preferences yet.
                        Suggestions are currently ordered by budget and cost.
                    </p>
                </c:if>

                <c:if test="${not budgetDefined}">
                    <p class="small text-muted">
                        No positive budget is set.
                        Budget suitability cannot be assessed yet.
                    </p>
                </c:if>

                <c:if test="${ongoing}">
                    <p class="small text-muted">
                        Suggestions cover the remaining dates.
                        Costs are compared with the full trip budget,
                        not the remaining balance.
                    </p>
                </c:if>

                <a class="btn btn-outline-secondary btn-sm"
                   href="${pageContext.request.contextPath}/preferences?tripId=${trip.id}">
                    Update my preferences
                </a>
            </section>

            <c:choose>
                <c:when test="${empty suggestions}">
                    <div class="rd-card combo-choice-empty">
                        <h3 class="h5">No matching combos yet</h3>
                        <p class="rd-sub">
                            <c:out value="${emptyComboReason}"/>
                            </p>
                            <p class="small text-muted mt-3 mb-0">
                                Required: <c:out value="${trip.destination}"/>
                                · ${planningDays} days · active template.
                            </p>
                    </div>
                </c:when>

                <c:otherwise>
                    <c:forEach var="suggestion" items="${suggestions}">
                        <section class="rd-card combo-choice-card">
                            <c:if test="${budgetDefined}">
                                <span class="combo-choice-badge ${suggestion.withinBudget ? '' : 'over'}">
                                    <c:out value="${suggestion.withinBudget
                                                    ? 'Within trip budget'
                                                    : 'Above trip budget'}"/>
                                </span>
                            </c:if>

                            <h3>
                                <c:out value="${suggestion.combo.name}"/>
                            </h3>

                            <p class="combo-choice-description"><c:out value="${suggestion.combo.description}"/></p>

                            <c:choose>
                                <c:when test="${not empty suggestion.matchedPreferences}">
                                    <p class="small">
                                        Matches your group:
                                        <c:out value="${suggestion.matchedPreferences}"/>
                                    </p>
                                </c:when>

                                <c:otherwise>
                                    <p class="small text-muted">
                                        Matches the area and trip duration.
                                        No group preference matches were found.
                                    </p>
                                </c:otherwise>
                            </c:choose>

                            <div class="combo-choice-cost">
                                <strong>
                                    <fmt:formatNumber
                                        value="${suggestion.combo.estimatedCostPerPerson}"
                                        maxFractionDigits="0"/> VND
                                </strong>
                                <span class="small text-muted">per person</span>

                                <p class="small text-muted mt-2 mb-0">
                                    Estimated group total:
                                    <fmt:formatNumber
                                        value="${suggestion.groupCost}"
                                        maxFractionDigits="0"/> VND
                                </p>
                            </div>

                            <details class="combo-choice-details">
                                <summary>View activities</summary>

                                <c:forEach var="activity"
                                           items="${suggestion.combo.activities}">
                                    <div class="combo-choice-activity">
                                        <div class="combo-choice-time">
                                            Day ${activity.dayNumber}
                                            ·
                                            <fmt:formatDate
                                                value="${activity.startTime}"
                                                pattern="HH:mm"/>
                                            –
                                            <fmt:formatDate
                                                value="${activity.endTime}"
                                                pattern="HH:mm"/>
                                        </div>

                                        <strong>
                                            <c:out value="${activity.title}"/>
                                        </strong>

                                        <c:if test="${not empty activity.placeName}">
                                            <div class="small text-muted mt-1">
                                                <c:out value="${activity.placeName}"/>
                                            </div>
                                        </c:if>

                                        <c:if test="${not empty activity.note}">
                                            <p class="small text-muted mt-1 mb-0">
                                                <c:out value="${activity.note}"/>
                                            </p>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </details>
                            <c:choose>
                                <c:when test="${trip.role == 'OWNER'
                                                and trip.status == 'PLANNING'}">
                                        <a class="btn btn-brand w-100 mt-3"
                                           href="${pageContext.request.contextPath}/combos/preview?tripId=${trip.id}&amp;comboId=${suggestion.combo.id}">
                                            Preview this combo
                                        </a>
                                </c:when>

                                <c:otherwise>
                                    <p class="small text-muted mt-3 mb-0">
                                        <c:out value="${trip.role != 'OWNER'
                                                        ? 'The trip leader selects the combo.'
                                                        : 'Replacing an ongoing itinerary will be enabled after activity status support is added.'}"/>
                                    </p>
                                </c:otherwise>
                            </c:choose>
                        </section>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>