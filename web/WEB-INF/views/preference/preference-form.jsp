<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="My Preferences" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/preferences.css?v=1">

<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<div class="rd-grid rd-preferences">
    <section class="rd-card" aria-labelledby="preferences-title">
        <div class="rd-card-heading">
            <div>
                <h2 id="preferences-title">My Preferences</h2>
                <p class="rd-sub">
                    Select the travel experiences you want to enjoy on this trip.
                </p>
            </div>

            <span class="rd-count"
                  role="status"
                  aria-live="polite"
                  aria-atomic="true">
                <span id="selectedCount"><c:out value="${empty selectedIds ? 0 : selectedIds.size()}"/></span>
                selected
            </span>
        </div>

        <form method="post"
              action="${pageContext.request.contextPath}/preferences">

            <input type="hidden" name="tripId" value="${trip.id}">

            <c:choose>
                <c:when test="${not empty categories}">
                    <fieldset class="rd-preference-fieldset">
                        <legend class="visually-hidden">
                            Preference categories
                        </legend>

                        <div class="rd-preference-options">
                            <c:forEach var="category" items="${categories}">
                                <div class="rd-preference-option">
                                    <input class="preference-checkbox"
                                           type="checkbox"
                                           name="categoryIds"
                                           value="${category.id}"
                                           id="cat${category.id}"
                                           <c:if test="${not empty selectedIds and selectedIds.contains(category.id)}">checked</c:if>>

                                    <label for="cat${category.id}">
                                        <span class="rd-preference-icon"
                                              aria-hidden="true">
                                            <c:out value="${category.icon}"/>
                                        </span>

                                        <span class="rd-preference-name">
                                            <c:out value="${category.name}"/>
                                        </span>
                                    </label>
                                </div>
                            </c:forEach>
                        </div>
                    </fieldset>
                </c:when>

                <c:otherwise>
                    <div class="rd-preference-empty">
                        <h3>No preference categories available</h3>
                        <p>
                            No categories are currently configured.
                            You can explore group preferences and return later.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>

            <p class="rd-help mt-3">
                You can select multiple categories or deselect
                to update your saved preferences.
            </p>

            <div class="rd-preference-actions">
                <button type="submit" class="btn btn-brand">
                    Save preferences
                </button>

                <a href="${pageContext.request.contextPath}/preferences/group?tripId=${trip.id}"
                   class="btn btn-outline-secondary">
                    View group preferences
                </a>
            </div>
        </form>
    </section>
</div>

<script>
(function() {
    const checkboxes = document.querySelectorAll('.preference-checkbox');
    const counter = document.getElementById('selectedCount');
    if (!counter) return;

    function updateCount() {
        const checked = document.querySelectorAll('.preference-checkbox:checked').length;
        counter.textContent = checked;
    }

    checkboxes.forEach(cb => cb.addEventListener('change', updateCount));
})();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
