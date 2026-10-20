<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"
           uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="mx-auto" style="max-width:760px">

    <c:url var="editDraftUrl" value="/combos/draft">
        <c:param name="tripId" value="${trip.id}"/>
    </c:url>

    <a href="${editDraftUrl}"
       class="btn btn-outline-secondary btn-sm mb-3">
        Back to editing
    </a>

    <h2>Review your itinerary</h2>

    <p class="text-muted">
        <c:out value="${trip.name}"/>
    </p>

    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger">
            <c:out value="${sessionScope.errorMessage}"/>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <div class="rd-card p-4 mb-3">
        <p class="mb-1">Estimated cost for the group</p>

        <strong class="fs-4">
            <fmt:formatNumber value="${draftTotal}"
                              maxFractionDigits="2"/>
            VND
        </strong>

        <p class="small text-muted mt-2 mb-0">
            ${draftItems.size()} activities in this draft.
        </p>

        <c:if test="${trip.budget != null
                      and trip.budget > 0
                      and draftTotal > trip.budget}">
            <p class="text-warning mt-2 mb-0">
                This draft exceeds the trip budget.
            </p>
        </c:if>
    </div>

    <c:forEach var="item"
               items="${draftItems}"
               varStatus="st">

        <div class="rd-card p-4 mb-3">
            <div class="small text-muted mb-2">
                <fmt:formatDate value="${item.visitDate}"
                                pattern="dd MMM yyyy"/>
                ·
                <fmt:formatDate value="${item.startTime}"
                                pattern="HH:mm"/>
                –
                <fmt:formatDate value="${item.endTime}"
                                pattern="HH:mm"/>
            </div>

            <h3 class="h5">
                ${st.count}.
                <c:out value="${item.activityTitle}"/>
            </h3>

            <c:choose>
                <c:when test="${item.placeId == 0}">
                    <p class="text-muted small">
                        Flexible rest — no fixed place.
                    </p>
                </c:when>

                <c:otherwise>
                    <p>
                        <c:out value="${item.placeName}"/>
                    </p>
                </c:otherwise>
            </c:choose>

            <p class="small mb-0">
                Group cost:
                <fmt:formatNumber value="${item.estimatedCost}"
                                  maxFractionDigits="2"/>
                VND
            </p>

            <c:if test="${not empty item.note}">
                <p class="small mt-2 mb-0"
                   style="white-space:pre-wrap;overflow-wrap:anywhere"><c:out value="${item.note}"/></p>
            </c:if>
        </div>
    </c:forEach>

    <div class="alert alert-warning">
        Confirmation will replace upcoming activities from
        <strong>
            <fmt:formatDate value="${comboDraft.fromDate}"
                            pattern="dd MMM yyyy"/>
        </strong>
        onward.
        Activities in progress, completed activities and cancelled
        history will be preserved.
    </div>

    <form method="post"
          action="${pageContext.request.contextPath}/combos/draft/confirm">

        <input type="hidden"
               name="tripId"
               value="${trip.id}">

        <input type="hidden"
               name="draftToken"
               value="${comboDraft.token}">

        <div class="form-check mb-3">
            <input id="acceptReplacement"
                   class="form-check-input"
                   type="checkbox"
                   name="acceptReplacement"
                   value="yes"
                   required>

            <label for="acceptReplacement"
                   class="form-check-label">
                I agree to replace the upcoming itinerary with this draft.
            </label>
        </div>

        <div class="d-flex flex-wrap gap-2 mb-4">
            <button type="submit" class="btn btn-brand">
                Confirm itinerary
            </button>

            <a href="${editDraftUrl}"
               class="btn btn-outline-secondary">
                Continue editing
            </a>
        </div>
    </form>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>