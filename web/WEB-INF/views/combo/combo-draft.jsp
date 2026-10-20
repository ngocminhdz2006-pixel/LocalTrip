<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"
           uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="mx-auto" style="max-width:760px">

    <c:url var="combosUrl" value="/combos">
        <c:param name="tripId" value="${trip.id}"/>
    </c:url>

    <a href="${combosUrl}"
       class="btn btn-outline-secondary btn-sm mb-3">
        Back to combos
    </a>

    <h2>Edit itinerary draft</h2>

    <p class="text-muted">
        <c:out value="${trip.name}"/>
    </p>

    <div class="alert alert-info">
        You are editing a draft.
        Your saved itinerary remains unchanged.
    </div>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger">
            <c:out value="${sessionScope.errorMessage}"/>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">
            <c:out value="${sessionScope.successMessage}"/>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <form method="post"
          action="${pageContext.request.contextPath}/combos/draft">

        <input type="hidden"
               name="tripId"
               value="${trip.id}">

        <input type="hidden"
               name="draftToken"
               value="${comboDraft.token}">
        <c:forEach var="item"
                   items="${draftItems}"
                   varStatus="st">

            <fmt:formatDate var="visitDate"
                            value="${item.visitDate}"
                            pattern="yyyy-MM-dd"/>

            <fmt:formatDate var="startTime"
                            value="${item.startTime}"
                            pattern="HH:mm"/>

            <fmt:formatDate var="endTime"
                            value="${item.endTime}"
                            pattern="HH:mm"/>

            <div class="rd-card p-4 mb-3">

                <h3 class="h5 mb-3">
                    Activity ${st.count}:
                    <c:out value="${item.activityTitle}"/>
                </h3>

                <div class="mb-3">
                    <label for="date-${st.index}"
                           class="form-label">
                        Date
                    </label>

                    <input id="date-${st.index}"
                           type="date"
                           class="form-control"
                           name="visitDate_${st.index}"
                           value="${visitDate}"
                           min="${comboDraft.fromDate}"
                           max="${trip.endDate}"
                           required>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-6">
                        <label for="start-${st.index}"
                               class="form-label">
                            Start time
                        </label>

                        <input id="start-${st.index}"
                               type="time"
                               class="form-control"
                               name="startTime_${st.index}"
                               value="${startTime}"
                               required>
                    </div>

                    <div class="col-6">
                        <label for="end-${st.index}"
                               class="form-label">
                            End time
                        </label>

                        <input id="end-${st.index}"
                               type="time"
                               class="form-control"
                               name="endTime_${st.index}"
                               value="${endTime}"
                               required>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="place-${st.index}"
                           class="form-label">
                        Place
                    </label>

                    <c:choose>
                        <c:when test="${item.activityType == 'REST'
                                        and item.placeId == 0}">
                                <div class="form-control bg-light">
                                    Flexible rest — no fixed place
                                </div>
                        </c:when>

                        <c:otherwise>
                            <select id="place-${st.index}"
                                    name="placeId_${st.index}"
                                    class="form-select"
                                    required>

                                <c:forEach var="place"
                                           items="${places}">

                                    <c:if test="${item.activityType != 'MEAL'
                                                  or place.categoryCode == 'FOOD'}">
                                        <c:if test="${item.activityType != 'CAFE'
                                                      or place.categoryCode == 'CAFE'}">

                                              <option value="${place.placeId}"
                                                      ${place.placeId == item.placeId
                                                        ? 'selected' : ''}>
                                                      <c:out value="${place.placeName}"/>
                                              </option>

                                        </c:if>
                                    </c:if>

                                </c:forEach>
                            </select>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="mb-3">
                    <label for="cost-${st.index}"
                           class="form-label">
                        Estimated cost for the group (VND)
                    </label>

                    <input id="cost-${st.index}"
                           type="number"
                           name="estimatedCost_${st.index}"
                           class="form-control"
                           min="0"
                           step="0.01"
                           value="${item.estimatedCost}"
                           required>
                </div>

                            <div>
                <label for="note-${st.index}"
                       class="form-label">
                    Note
                </label>

                <textarea id="note-${st.index}"
                          name="note_${st.index}"
                          class="form-control"
                          rows="2"
                          maxlength="500"><c:out value="${item.note}"/></textarea>
            </div>

            <div class="form-check mt-3">
                <input id="remove-${st.index}"
                       class="form-check-input"
                       type="checkbox"
                       name="remove_${st.index}"
                       value="yes">

                <label class="form-check-label text-danger"
                       for="remove-${st.index}">
                    Remove this activity when saving
                </label>
            </div>

        </div> <%-- Đóng card hoạt động --%>

    </c:forEach>

    <div class="d-flex flex-wrap gap-2 mb-4">
        <button type="submit" class="btn btn-brand">
            Save draft
        </button>

        <a href="${combosUrl}"
           class="btn btn-outline-secondary">
            Back to combos
        </a>
    </div>

</form>

<c:url var="reviewDraftUrl"
       value="/combos/draft/confirm">
    <c:param name="tripId" value="${trip.id}"/>
</c:url>

<div class="mb-3">
    <a href="${reviewDraftUrl}"
       class="btn btn-outline-secondary">
        Review saved draft
    </a>
</div>

<p class="text-muted small mb-4">
    Save your changes before reviewing.
    The review page shows your most recently saved draft.
</p>

</div> <%-- Đóng khung trang --%>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>