<%@ page contentType="text/html;charset=UTF-8"
          pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"
           uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="en_US" scope="page"/>
<%
    if (session.getAttribute("adminComboStatusToken") == null) {
        session.setAttribute(
                "adminComboStatusToken",
                java.util.UUID.randomUUID().toString()
        );
    }
%>

<c:choose>
    <c:when test="${detailMode}">
        <c:set var="pageTitle"
               value="${selectedCombo.name}"
               scope="request"/>
    </c:when>

    <c:otherwise>
        <c:set var="pageTitle"
               value="Combo Management"
               scope="request"/>
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
    .combo-management-heading {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        margin-bottom: 24px;
    }

    .combo-management-heading h2 {
        margin: 0;
        font-size: 26px;
        font-weight: 700;
    }

    .combo-management-empty {
        padding: 40px 24px;
        text-align: center;
    }

    .combo-management-table {
        padding: 0;
        overflow: hidden;
    }

    .combo-management-table .table {
        min-width: 750px;
        margin-bottom: 0;
    }

    .combo-management-table th,
    .combo-management-table td {
        padding: 16px 20px;
        vertical-align: middle;
        border-color: var(--line);
    }

    .combo-management-table th {
        background: #F6F9F7;
        color: var(--ink2);
        white-space: nowrap;
    }

    .combo-management-status {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 600;
    }

    .combo-management-status.ACTIVE {
        background: var(--mint);
        color: var(--green);
    }

    .combo-management-status.DRAFT {
        background: #FFF0CE;
        color: #805500;
    }

    .combo-management-status.INACTIVE {
        background: #F1F3F2;
        color: var(--ink2);
    }

    .combo-detail-summary {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }

    .combo-detail-summary .rd-card {
        padding: 16px 18px;
    }

    .combo-detail-summary span {
        display: block;
        color: var(--ink2);
        font-size: 13px;
        margin-bottom: 6px;
    }

    .combo-detail-summary strong {
        color: var(--green);
        font-size: 20px;
    }

    .combo-detail-description {
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        color: var(--ink2);
    }

    .combo-detail-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: 14px;
    }

    .combo-detail-tag {
        padding: 4px 10px;
        border-radius: 999px;
        background: var(--mint);
        color: var(--green);
        font-size: 12px;
        font-weight: 600;
    }

    @media (max-width: 700px) {
        .combo-detail-summary {
            grid-template-columns: 1fr;
        }
    }
</style>

<c:choose>
    <c:when test="${not detailMode}">
        <div class="combo-management-heading">
            <div>
                <h2>Combo Management</h2>
                <p class="rd-sub">
                    Curate and manage recommended day itineraries for travelers.
                </p>
            </div>

            <a class="btn btn-brand"
               href="${pageContext.request.contextPath}/admin/combos/create">
                + Create Combo
            </a>
        </div>

        <c:choose>
            <c:when test="${empty combos}">
                <div class="rd-card combo-management-empty">
                    <h3 class="h5">No combos created yet</h3>
                    <p class="rd-sub">
                        Create the first draft combo with verified local spots and daily schedules.
                    </p>

                    <a class="btn btn-brand"
                       href="${pageContext.request.contextPath}/admin/combos/create">
                        Create First Combo
                    </a>
                </div>
            </c:when>

            <c:otherwise>
                <div class="rd-card combo-management-table">
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead>
                                <tr>
                                    <th>Combo Name</th>
                                    <th>Region</th>
                                    <th>Duration</th>
                                    <th>Cost / Person</th>
                                    <th>Rating & Stats</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="combo" items="${combos}">
                                    <tr>
                                        <td>
                                            <strong>
                                                <c:out value="${combo.name}"/>
                                            </strong>
                                            <div class="small text-muted">
                                                ID #${combo.id}
                                            </div>
                                        </td>

                                        <td>
                                            <c:out value="${combo.districtName}"/>,
                                            <c:out value="${combo.cityName}"/>
                                        </td>

                                        <td>${combo.durationDays} days</td>

                                        <td class="text-nowrap">
                                            <fmt:formatNumber
                                                value="${combo.estimatedCostPerPerson}"
                                                maxFractionDigits="0"/> VND
                                        </td>

                                        <td>
                                            <div style="font-size: 12px; font-weight: 700; color: #b45309;">
                                                ⭐ <c:out value="${combo.avgRating > 0 ? combo.avgRating : 'New'}"/>
                                                <c:if test="${combo.reviewCount > 0}">
                                                    <span style="font-weight: 400; color: #64748b;">(${combo.reviewCount} reviews)</span>
                                                </c:if>
                                            </div>
                                            <div class="small text-muted">
                                                Applied in ${combo.appliedTripsCount} trips
                                            </div>
                                        </td>

                                        <td>
                                            <span class="combo-management-status ${combo.status}">
                                                <c:choose>
                                                    <c:when test="${combo.status == 'ACTIVE'}">
                                                        Active
                                                    </c:when>
                                                    <c:when test="${combo.status == 'INACTIVE'}">
                                                        Inactive
                                                    </c:when>
                                                    <c:otherwise>
                                                        Draft
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>

                                        <td>
                                            <a class="btn btn-sm btn-outline-secondary"
                                               href="${pageContext.request.contextPath}/admin/combos/detail?id=${combo.id}">
                                                View Details
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </c:when>

    <c:otherwise>
        <div class="combo-management-heading">
            <div>
                <h2><c:out value="${selectedCombo.name}"/></h2>
                <p class="rd-sub">
                    Curated Template #${selectedCombo.id}
                </p>
            </div>

            <a class="btn btn-outline-secondary"
               href="${pageContext.request.contextPath}/admin/combos">
                Back to List
            </a>
        </div>

        <div class="combo-detail-summary">
            <div class="rd-card">
                <span>Region</span>
                <strong>
                    <c:out value="${selectedCombo.districtName}"/>,
                    <c:out value="${selectedCombo.cityName}"/>
                </strong>
            </div>

            <div class="rd-card">
                <span>Duration</span>
                <strong>${selectedCombo.durationDays} days</strong>
            </div>

            <div class="rd-card">
                <span>Cost / Person</span>
                <strong>
                    <fmt:formatNumber
                        value="${selectedCombo.estimatedCostPerPerson}"
                        maxFractionDigits="0"/> VND
                </strong>
            </div>

            <div class="rd-card">
                <span>Reviews & Usage</span>
                <strong>⭐ ${selectedCombo.avgRating > 0 ? selectedCombo.avgRating : 'New'}</strong>
                <div class="small text-muted" style="margin-top: 4px;">
                    ${selectedCombo.reviewCount} reviews · ${selectedCombo.appliedTripsCount} trips
                </div>
            </div>
        </div>

        <section class="rd-card mb-4">
            <h3 class="h5 mb-2">Publishing Status</h3>
            <c:if test="${selectedCombo.status == 'DRAFT'
                          or selectedCombo.status == 'INACTIVE'}">
                  <div class="my-3">
                      <a class="btn btn-outline-secondary"
                         href="${pageContext.request.contextPath}/admin/combos/edit?id=${selectedCombo.id}">
                          Edit Combo
                      </a>
                  </div>
            </c:if>
            <c:choose>
                <c:when test="${selectedCombo.status == 'ACTIVE'}">
                    <p class="rd-sub mb-3">
                        Deactivating will exclude this combo from future user recommendations.
                        Existing trips that have already applied this itinerary will retain their activities.
                    </p>

                    <form method="post"
                          action="${pageContext.request.contextPath}/admin/combos/status"
                          onsubmit="return confirm('Deactivate this combo?');">

                        <input type="hidden"
                               name="csrfToken"
                               value="<c:out value='${sessionScope.adminComboStatusToken}'/>">

                        <input type="hidden"
                               name="id"
                               value="${selectedCombo.id}">

                        <input type="hidden"
                               name="expectedStatus"
                               value="${selectedCombo.status}">

                        <input type="hidden"
                               name="newStatus"
                               value="INACTIVE">

                        <button class="btn btn-outline-danger" type="submit">
                            Deactivate Combo
                        </button>
                    </form>
                </c:when>

                <c:otherwise>
                    <p class="rd-sub mb-3">
                        The system validates daily activities, meals, rest intervals, places, and opening hours before activating.
                    </p>

                    <form method="post"
                          action="${pageContext.request.contextPath}/admin/combos/status"
                          onsubmit="return confirm('Validate and activate this combo?');">

                        <input type="hidden"
                               name="csrfToken"
                               value="<c:out value='${sessionScope.adminComboStatusToken}'/>">

                        <input type="hidden"
                               name="id"
                               value="${selectedCombo.id}">

                        <input type="hidden"
                               name="expectedStatus"
                               value="${selectedCombo.status}">

                        <input type="hidden"
                               name="newStatus"
                               value="ACTIVE">

                        <button class="btn btn-brand" type="submit">
                            Validate and Activate
                        </button>
                    </form>
                </c:otherwise>
            </c:choose>
        </section>

        <section class="rd-card mb-4">
            <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                <h3 class="h5 mb-0">Combo Overview</h3>

                <span class="combo-management-status ${selectedCombo.status}">
                    <c:choose>
                        <c:when test="${selectedCombo.status == 'ACTIVE'}">
                            Active
                        </c:when>
                        <c:when test="${selectedCombo.status == 'INACTIVE'}">
                            Inactive
                        </c:when>
                        <c:otherwise>
                            Draft
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>

            <c:choose>
                <c:when test="${not empty selectedCombo.description}">
                    <p class="combo-detail-description"><c:out value="${selectedCombo.description}"/></p>
                </c:when>
                <c:otherwise>
                    <p class="rd-sub">No description provided.</p>
                </c:otherwise>
            </c:choose>

            <div class="combo-detail-tags">
                <c:forEach var="categoryId"
                           items="${selectedCombo.categoryIds}">
                    <span class="combo-detail-tag">
                        <c:out value="${categoryNames[categoryId]}"/>
                    </span>
                </c:forEach>
            </div>
        </section>

        <div class="rd-card mb-3">
            <h3 class="h5 mb-2">Activities by Day</h3>
            <p class="rd-sub">
                Day 1, Day 2… are relative days in the curated template.
                Costs shown are estimated per traveler.
            </p>
        </div>

        <c:choose>
            <c:when test="${empty selectedCombo.activities}">
                <div class="rd-card combo-management-empty">
                    No activities configured in this combo.
                </div>
            </c:when>

            <c:otherwise>
                <div class="rd-card combo-management-table">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Day</th>
                                    <th>Time</th>
                                    <th>Activity</th>
                                    <th>Place</th>
                                    <th>Cost / Person</th>
                                    <th>Notes</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="activity"
                                           items="${selectedCombo.activities}">
                                    <tr>
                                        <td class="text-nowrap">
                                            Day ${activity.dayNumber}
                                        </td>

                                        <td class="text-nowrap">
                                            <fmt:formatDate
                                                value="${activity.startTime}"
                                                pattern="HH:mm"/>
                                            –
                                            <fmt:formatDate
                                                value="${activity.endTime}"
                                                pattern="HH:mm"/>
                                        </td>

                                        <td>
                                            <strong>
                                                <c:out value="${activity.title}"/>
                                            </strong>

                                            <div class="small text-muted">
                                                <c:choose>
                                                    <c:when test="${activity.activityType == 'MEAL'}">
                                                        Dining & Meal
                                                    </c:when>
                                                    <c:when test="${activity.activityType == 'CAFE'}">
                                                        Coffee & Cafe
                                                    </c:when>
                                                    <c:when test="${activity.activityType == 'REST'}">
                                                        Rest & Relaxation
                                                    </c:when>
                                                    <c:otherwise>
                                                        Sightseeing & Visit
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty activity.placeId}">
                                                    <c:out value="${activity.placeName}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">
                                                        No place linked
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-nowrap">
                                            <fmt:formatNumber
                                                value="${activity.estimatedCostPerPerson}"
                                                maxFractionDigits="0"/> VND
                                        </td>

                                        <td>
                                            <c:out value="${activity.note}"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
