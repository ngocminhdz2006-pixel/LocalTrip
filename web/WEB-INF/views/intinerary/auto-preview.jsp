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
<%-- Trip Pace Selector --%>
<div class="rd-card mb-4" style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 18px;">
    <h3 style="font-size: 14px; font-weight: 700; color: #175b43; margin-bottom: 6px;">Trip Pace (Intensity)</h3>
    <p style="font-size: 12px; color: #64748b; margin-bottom: 12px;">Choose how relaxed or packed your days should be, then regenerate:</p>
    <form method="get" action="${pageContext.request.contextPath}/itinerary/auto" style="display: flex; gap: 12px; flex-wrap: wrap; align-items: center;">
        <input type="hidden" name="tripId" value="${trip.id}">
        <label style="display: inline-flex; align-items: center; gap: 4px; padding: 6px 14px; background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 12px; font-size: 12px; font-weight: 600; cursor: pointer;">
            <input type="radio" name="pace" value="RELAXED" ${selectedPace == 'RELAXED' ? 'checked' : ''} style="accent-color: #175b43;">
            Relaxed 🌿 (2-3 stops/day)
        </label>
        <label style="display: inline-flex; align-items: center; gap: 4px; padding: 6px 14px; background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 12px; font-size: 12px; font-weight: 600; cursor: pointer;">
            <input type="radio" name="pace" value="BALANCED" ${empty selectedPace or selectedPace == 'BALANCED' ? 'checked' : ''} style="accent-color: #175b43;">
            Balanced ⚖️ (3-4 stops/day)
        </label>
        <label style="display: inline-flex; align-items: center; gap: 4px; padding: 6px 14px; background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 12px; font-size: 12px; font-weight: 600; cursor: pointer;">
            <input type="radio" name="pace" value="PACKED" ${selectedPace == 'PACKED' ? 'checked' : ''} style="accent-color: #175b43;">
            Packed ⚡ (4-6 stops/day)
        </label>
        <button type="submit" class="btn btn-sm btn-primary rounded-pill px-3" style="background: #175b43; border-color: #175b43; font-weight: 600;">
            Apply Pace & Regenerate
        </button>
    </form>
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
                        <td>
    <strong><c:out value="${item.placeName}"/></strong>
    <c:if test="${item.locked}">
        <span class="badge" style="background:#fff7ed; color:#c2410c; border:1px solid #fed7aa; font-size:10px; margin-left:4px;">🔒 Pinned (Preserved)</span>
    </c:if>
</td><td><span style="font-size: 12px; color: #15803d; font-weight: 600;"><c:out value="${item.note}"/></span></td>
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
