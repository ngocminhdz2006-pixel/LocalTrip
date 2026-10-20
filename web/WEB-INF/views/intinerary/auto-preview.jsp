<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Preview new itinerary" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<style>
    .rd-preview-heading {
        margin-bottom: 24px;
    }

    .rd-preview-heading h2 {
        margin: 0 0 8px;
        color: var(--ink);
        font-size: 24px;
        font-weight: 700;
    }

    .rd-preview-notice {
        padding: 20px;
        margin-bottom: 24px;
        background: var(--mint);
        border: 1px solid var(--line);
        border-radius: 14px;
        color: var(--ink2);
        line-height: 1.7;
    }

    .rd-preview-notice strong {
        color: var(--green);
    }

    .rd-preview-stats {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 16px;
        margin-bottom: 24px;
    }

    .rd-preview-stat {
        padding: 22px;
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 18px;
    }

    .rd-preview-stat span {
        display: block;
        margin-bottom: 10px;
        color: var(--ink2);
        font-size: 14px;
    }

    .rd-preview-stat strong {
        color: var(--green);
        font-size: 26px;
        font-weight: 700;
    }

    .rd-preview-table {
        margin-bottom: 24px;
    }

    .rd-preview-table h2 {
        font-size: 20px;
    }

    .rd-preview-table .table {
        margin-bottom: 0;
    }

    .rd-preview-old summary {
        color: var(--ink);
        font-weight: 600;
        cursor: pointer;
    }

    .rd-preview-confirm {
        margin-bottom: 24px;
    }

    .rd-preview-confirm h2 {
        font-size: 20px;
    }

    .rd-preview-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 20px;
    }

    @media (max-width: 700px) {
        .rd-preview-stats {
            grid-template-columns: 1fr;
        }

        .rd-preview-heading h2 {
            font-size: 21px;
        }

        .rd-preview-actions .btn {
            width: 100%;
        }
    }
</style>
<div class="rd-preview-heading">
    <h2>Preview New Itinerary</h2>
    <p class="rd-sub">
        Review the suggested schedule based on your group's latest preferences before confirming.
    </p>
</div>

<div class="rd-preview-notice">
    <strong>Existing schedule is not modified yet.</strong><br>

    Upon confirmation, activities from
    <strong>
        <fmt:formatDate value="${draft.fromDate}"
                        pattern="dd/MM/yyyy"/>
    </strong>
    onward will be replaced with this new schedule.

    Past days will be preserved.
    This preview remains valid for 30 minutes.
</div>
<div class="rd-preview-stats">
    <div class="rd-preview-stat">
        <span>Current items in affected range</span>
        <strong>
            <c:out value="${oldItems.size()}"/>
        </strong>
    </div>

    <div class="rd-preview-stat">
        <span>Activities in new draft</span>
        <strong>
            <c:out value="${draft.items.size()}"/>
        </strong>
    </div>

    <div class="rd-preview-stat">
        <span>Estimated cost of new draft</span>
        <strong>
            <fmt:formatNumber value="${draftTotal}"
                              maxFractionDigits="0"/> VND
        </strong>
    </div>
</div>
<div class="rd-card rd-preview-table">
    <div class="rd-card-heading">
        <div>
            <h2>New Itinerary</h2>
            <p class="rd-sub">
                Review dates, times, and destinations prior to confirming.
            </p>
        </div>
    </div>
    <div class="table-responsive"><table class="table">
            <thead><tr><th>Date</th><th>Time</th><th>Destination</th><th>Activity note</th><th>Cost</th></tr></thead>
            <tbody><c:forEach var="item" items="${draft.items}"><tr>
                        <td><fmt:formatDate value="${item.visitDate}" pattern="dd/MM/yyyy"/></td>
                        <td><fmt:formatDate value="${item.startTime}" pattern="HH:mm"/> – <fmt:formatDate value="${item.endTime}" pattern="HH:mm"/></td>
                        <td><c:out value="${item.placeName}"/></td><td><c:out value="${item.note}"/></td>
                        <td><fmt:formatNumber value="${item.estimatedCost}" maxFractionDigits="0"/> VND</td>
                    </tr></c:forEach></tbody>
            </table></div>
    </div>
    <details class="rd-card rd-preview-old mb-4"><summary>View existing activities in affected range</summary>
        <div class="table-responsive mt-3"><table class="table"><thead><tr><th>Date</th><th>Time</th><th>Destination</th></tr></thead><tbody>
                <c:forEach var="item" items="${oldItems}"><tr><td><fmt:formatDate value="${item.visitDate}" pattern="dd/MM/yyyy"/></td><td><fmt:formatDate value="${item.startTime}" pattern="HH:mm"/> – <fmt:formatDate value="${item.endTime}" pattern="HH:mm"/></td><td><c:out value="${item.placeName}"/></td></tr></c:forEach>
                </tbody></table></div>
    </details>
    <div class="rd-card rd-preview-confirm">
        <div class="rd-card-heading">
            <div>
                <h2>Confirm Schedule</h2>
                <p class="rd-sub">
                    Confirm to apply this new schedule, or regenerate based on updated preferences.
                </p>
            </div>
        </div>

        <form method="post"
              action="${pageContext.request.contextPath}/itinerary/auto"
        class="rd-preview-actions">

        <input type="hidden"
               name="tripId"
               value="${trip.id}">

        <input type="hidden"
               name="autoToken"
               value="<c:out value='${sessionScope.autoItineraryToken}'/>">

        <input type="hidden"
               name="draftToken"
               value="<c:out value='${draft.token}'/>">

        <button type="submit"
                name="action"
                value="confirm"
                class="btn btn-brand"
                onclick="return confirm('Replace existing schedule with this preview from the indicated date?');">
            Confirm and apply schedule
        </button>

        <button type="submit"
                name="action"
                value="generate"
                class="btn btn-outline-primary">
            Regenerate with latest preferences
        </button>

        <button type="submit"
                name="action"
                value="cancel"
                class="btn btn-outline-secondary">
            Discard preview
        </button>
    </form>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
