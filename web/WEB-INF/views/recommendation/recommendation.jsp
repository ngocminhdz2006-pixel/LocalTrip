<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Place suggestions" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<style>
    .rd-page .rd-tabs a.on {
        background: var(--mint);
        border-radius: 9px 9px 0 0;
    }

    .rd-rec-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 18px;
        margin-top: 22px;
    }

    .rd-rec-card {
        display: flex;
        flex-direction: column;
        gap: 14px;
        min-width: 0;
        padding: 20px;
        border: 1px solid var(--line);
        border-radius: 14px;
        background: #fff;
    }

    .rd-rec-head {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: 12px;
    }

    .rd-page .rd-rec-head h3 {
        font-size: 18px;
        line-height: 1.5;
        margin: 0;
        overflow-wrap: anywhere;
    }

    .rd-rec-score {
        flex-shrink: 0;
        text-align: center;
        background: var(--mint);
        border-radius: 12px;
        padding: 8px 10px;
        color: var(--green);
    }

    .rd-rec-score strong {
        display: block;
        font-size: 20px;
    }

    .rd-rec-score small {
        font-size: 10px;
    }

    .rd-rec-meta {
        font-size: 13px;
        color: var(--ink2);
        line-height: 1.7;
    }

    .rd-rec-meta p + p {
        margin-top: 6px;
    }

    .rd-rec-reason {
        padding: 12px;
        background: #F6F9F7;
        border-radius: 10px;
        font-size: 12px;
        color: var(--ink2);
        line-height: 1.7;
    }

    .rd-rec-reason strong {
        color: var(--green);
    }

    .rd-rec-reason p {
        margin-bottom: 8px;
    }

    .rd-rec-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: auto;
    }

    .rd-rec-actions form {
        margin: 0;
    }

    .rd-rec-guide h2 {
        margin-top: 16px;
    }

    .rd-rec-guide ol {
        padding-left: 22px;
        margin: 20px 0;
        color: var(--ink2);
        font-size: 14px;
        line-height: 1.7;
    }

    .rd-rec-guide li + li {
        margin-top: 12px;
    }

    .rd-rec-links {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-top: 20px;
    }

    .rd-rec-empty {
        padding: 28px 20px;
        margin-top: 20px;
        background: #F6F9F7;
        border: 1px dashed var(--line);
        border-radius: 14px;
    }

    .rd-page .rd-rec-empty h3 {
        font-size: 18px;
        margin-bottom: 10px;
    }

    .rd-rec-empty p {
        font-size: 14px;
        color: var(--ink2);
        line-height: 1.7;
    }

    @media (max-width: 1100px) {
        .rd-rec-grid {
            grid-template-columns: minmax(0, 1fr);
        }
    }

    @media (max-width: 850px) and (min-width: 601px) {
        .rd-rec-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }
    }

    @media (max-width: 600px) {
        .rd-rec-card {
            padding: 16px;
        }

        .rd-rec-actions {
            flex-direction: column;
        }

        .rd-rec-actions form,
        .rd-rec-actions .btn {
            width: 100%;
        }
    }
</style>

<div class="rd-grid">
    <section class="rd-card" aria-labelledby="recommendation-title">
        <div class="rd-card-heading">
            <div>
                <h2 id="recommendation-title">Place Suggestions</h2>
                <p class="rd-sub">
                    Discover places matching your destination area, group preferences, and budget.
                </p>
            </div>

            <span class="rd-count">
                <c:out value="${empty recommendations ? 0 : recommendations.size()}"/>
                places
            </span>
        </div>

        <c:choose>
            <c:when test="${empty recommendations}">
                <div class="rd-rec-empty">
                    <h3>No matching places found</h3>
                    <p>
                        Check your trip area and member preferences to find more curated recommendations.
                    </p>

                    <a href="${pageContext.request.contextPath}/preferences?tripId=${trip.id}"
                       class="btn btn-brand mt-3">
                        Choose my preferences
                    </a>
                </div>
            </c:when>

            <c:otherwise>
                <div class="rd-rec-grid">
                    <c:forEach var="rec" items="${recommendations}">
                        <article class="rd-rec-card">
                            <div class="rd-rec-head">
                                <h3>
                                    <c:out value="${rec.place.name}"/>
                                </h3>

                                <div class="rd-rec-score">
                                    <strong>
                                        <fmt:formatNumber
                                            value="${rec.score}"
                                            maxFractionDigits="0"/>
                                    </strong>
                                    <small>Score</small>
                                </div>
                            </div>

                            <div class="rd-rec-meta">
                                <p>
                                    <c:out value="${rec.place.categoryIcon}"/>
                                    <c:out value="${rec.place.categoryName}"/>
                                </p>

                                <p>
                                    Rating:
                                    <c:out value="${rec.place.rating}"/> / 5
                                </p>

                                <c:if test="${not empty rec.place.address}">
                                    <p>
                                        Address:
                                        <c:out value="${rec.place.address}"/>
                                    </p>
                                </c:if>

                                <p>
                                    Estimated price:
                                    <strong>
                                        <fmt:formatNumber
                                            value="${rec.place.estimatedPrice}"
                                            maxFractionDigits="0"/> VND
                                    </strong>
                                </p>
                            </div>

                            <div class="rd-rec-reason">
                                <p>
                                    <strong>Why suggested?</strong><br>
                                    <c:out value="${rec.reason}"/>
                                </p>

                                <div>
                                    Preference match:
                                    <fmt:formatNumber
                                        value="${rec.preferenceMatch}"
                                        maxFractionDigits="0"/>%
                                </div>

                                <div>
                                    Budget match:
                                    <fmt:formatNumber
                                        value="${rec.budgetMatch}"
                                        maxFractionDigits="0"/>%
                                </div>
                            </div>

                            <div class="rd-rec-actions">
                                <c:if test="${trip.role == 'OWNER'}">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/itinerary">

                                        <input type="hidden"
                                               name="tripId"
                                               value="${trip.id}">

                                        <input type="hidden"
                                               name="placeId"
                                               value="${rec.place.id}">

                                        <button type="submit"
                                                class="btn btn-brand btn-sm">
                                            + Add to itinerary
                                        </button>
                                    </form>
                                </c:if>

                                <a href="${pageContext.request.contextPath}/places/detail?placeId=${rec.place.id}&amp;tripId=${trip.id}"
                                   class="btn btn-outline-secondary btn-sm">
                                    View details
                                </a>
                            </div>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <aside class="rd-card rd-rec-guide"
           aria-labelledby="recommendation-guide-title">

        <span class="rd-count">From preferences to journey</span>

        <h2 id="recommendation-guide-title">
            Select Group Destinations
        </h2>

        <p class="rd-sub">
            Compare recommendation scores, estimated prices, and spot details
            before adding them to your schedule.
        </p>

        <ol>
            <li>Review common preferences submitted by members.</li>
            <li>Select suitable spots for the group.</li>
            <li>
                Trip Lead adds places with dates and times to the itinerary.
            </li>
        </ol>

        <div class="rd-rec-links">
            <a href="${pageContext.request.contextPath}/preferences/group?tripId=${trip.id}"
               class="btn btn-outline-secondary">
                View group preferences
            </a>

            <a href="${pageContext.request.contextPath}/itinerary?tripId=${trip.id}"
               class="btn btn-outline-secondary">
                View itinerary
            </a>
        </div>

        <c:if test="${trip.role != 'OWNER'}">
            <p class="rd-help mt-3">
                You can explore suggestions and discuss with the group.
                The Trip Lead is responsible for adding places to the itinerary.
            </p>
        </c:if>
    </aside>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
