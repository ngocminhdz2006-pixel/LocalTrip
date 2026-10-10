<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Sở thích của tôi" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="vi_VN" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/preferences.css?v=1">

<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<div class="rd-grid rd-preferences">
    <section class="rd-card" aria-labelledby="preferences-title">
        <div class="rd-card-heading">
            <div>
                <h2 id="preferences-title">Sở thích của tôi</h2>
                <p class="rd-sub">
                    Chọn những trải nghiệm bạn muốn có trong chuyến đi này.
                </p>
            </div>

            <span class="rd-count"
                  role="status"
                  aria-live="polite"
                  aria-atomic="true">
                <span id="selectedCount"><c:out value="${empty selectedIds ? 0 : selectedIds.size()}"/></span>
                đã chọn
            </span>
        </div>

        <form method="post"
              action="${pageContext.request.contextPath}/preferences">

            <input type="hidden" name="tripId" value="${trip.id}">

            <c:choose>
                <c:when test="${not empty categories}">
                    <fieldset class="rd-preference-fieldset">
                        <legend class="visually-hidden">
                            Các danh mục sở thích
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
                        <h3>Chưa có danh mục sở thích</h3>
                        <p>
                            Hiện chưa có danh mục để chọn.
                            Bạn có thể xem sở thích nhóm và quay lại sau.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>

            <p class="rd-help mt-3">
                Bạn có thể chọn nhiều danh mục hoặc bỏ chọn
                để cập nhật sở thích đã lưu.
            </p>

            <div class="rd-preference-actions">
                <button type="submit" class="btn btn-brand">
                    Lưu sở thích
                </button>

                <a href="${pageContext.request.contextPath}/preferences/group?tripId=${trip.id}"
                   class="btn btn-outline-secondary">
                    Xem sở thích nhóm
                </a>
            </div>
        </form>
    </section>

    <aside class="rd-card rd-preference-guide"
           aria-labelledby="preference-guide-title">

        <span class="rd-count">Cùng nhau lên kế hoạch</span>

        <h2 id="preference-guide-title">
            Hành trình hợp với cả nhóm
        </h2>

        <p class="rd-sub">
            Sở thích của bạn được tổng hợp cùng các thành viên
            để nhóm tìm những địa điểm phù hợp.
        </p>

        <ol>
            <li>Chọn những trải nghiệm bạn quan tâm.</li>
            <li>Lưu để cập nhật lựa chọn của bạn.</li>
            <li>Xem sở thích nhóm trước khi chọn địa điểm.</li>
        </ol>

        <p class="rd-help">
            Lưu sở thích không thay thế lịch trình đang có.
            Nhóm có thể xem và điều chỉnh lịch trước khi xác nhận.
        </p>
    </aside>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>