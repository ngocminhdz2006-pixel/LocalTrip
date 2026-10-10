<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Sở thích nhóm" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="vi_VN" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/preferences.css?v=1">

<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<style>
    .rd-group-list {
        margin-top: 20px;
    }

    .rd-group-row {
        padding: 18px 0;
        border-top: 1px solid var(--line);
    }

    .rd-group-heading {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        margin-bottom: 12px;
    }

    .rd-group-category {
        display: flex;
        align-items: center;
        gap: 12px;
        min-width: 0;
    }

    .rd-group-category strong {
        font-size: 15px;
        overflow-wrap: anywhere;
    }

    .rd-group-votes {
        font-size: 13px;
        color: var(--ink2);
        text-align: right;
        flex-shrink: 0;
    }

    .rd-group-meter {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .rd-group-meter .progress {
        flex: 1;
        height: 9px;
        background: #EDF2EE;
        border-radius: 99px;
    }

    .rd-group-meter .progress-bar {
        background: var(--green2);
        border-radius: 99px;
    }

    .rd-group-percentage {
        width: 44px;
        text-align: right;
        color: var(--green);
        font-size: 13px;
        font-weight: 600;
    }

    @media (max-width: 520px) {
        .rd-group-heading {
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 8px;
        }

        .rd-group-votes {
            text-align: left;
            margin-left: 52px;
        }
    }
</style>

<div class="rd-grid rd-preferences">
    <section class="rd-card"
             aria-labelledby="group-preferences-title">

        <div class="rd-card-heading">
            <div>
                <h2 id="group-preferences-title">Sở thích nhóm</h2>
                <p class="rd-sub">
                    Những trải nghiệm được các thành viên quan tâm,
                    xếp theo số người chọn.
                </p>
            </div>

            <c:if test="${totalMembers > 0}">
                <span class="rd-count">
                    <c:out value="${totalMembers}"/> thành viên
                </span>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${empty groupPreferences}">
                <div class="rd-preference-empty">
                    <h3>Nhóm chưa có lựa chọn sở thích</h3>
                    <p>
                        Mỗi thành viên có thể chọn sở thích của mình
                        để cùng tìm những địa điểm phù hợp.
                    </p>
                </div>
            </c:when>

            <c:otherwise>
                <div class="rd-group-list">
                    <c:forEach var="gp" items="${groupPreferences}">
                        <c:set var="groupPercentage"
                               value="${gp.percentage < 0 ? 0 : (gp.percentage > 100 ? 100 : gp.percentage)}"/>

                        <div class="rd-group-row">
                            <div class="rd-group-heading">
                                <div class="rd-group-category">
                                    <span class="rd-preference-icon"
                                          aria-hidden="true">
                                        <c:out value="${gp.icon}"/>
                                    </span>

                                    <strong>
                                        <c:out value="${gp.categoryName}"/>
                                    </strong>
                                </div>

                                <span class="rd-group-votes">
                                    <c:out value="${gp.memberCount}"/>

                                    <c:if test="${totalMembers > 0}">
                                        / <c:out value="${totalMembers}"/>
                                    </c:if>

                                    người chọn
                                </span>
                            </div>

                            <div class="rd-group-meter">
                                <div class="progress"
                                     role="progressbar"
                                     aria-label="Tỷ lệ thành viên chọn <c:out value='${gp.categoryName}'/>"
                                     aria-valuenow="${groupPercentage}"
                                     aria-valuemin="0"
                                     aria-valuemax="100">

                                    <div class="progress-bar"
                                         style="width: ${groupPercentage}%;">
                                    </div>
                                </div>

                                <span class="rd-group-percentage">
                                    <fmt:formatNumber
                                        value="${groupPercentage}"
                                        maxFractionDigits="0"/>%
                                </span>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <p class="rd-help mt-3">
                    Mỗi người có thể chọn nhiều danh mục,
                    nên tổng các tỷ lệ có thể lớn hơn 100%.
                </p>
            </c:otherwise>
        </c:choose>

        <div class="rd-preference-actions">
            <a href="${pageContext.request.contextPath}/recommendations?tripId=${trip.id}"
               class="btn btn-brand">
                Xem gợi ý địa điểm
            </a>

            <a href="${pageContext.request.contextPath}/preferences?tripId=${trip.id}"
               class="btn btn-outline-secondary">
                Sửa sở thích của tôi
            </a>
        </div>
    </section>

    <aside class="rd-card rd-preference-guide"
           aria-labelledby="group-guide-title">

        <span class="rd-count">Sở thích chung</span>

        <h2 id="group-guide-title">Cùng chọn trải nghiệm</h2>

        <p class="rd-sub">
            Danh mục có nhiều người chọn giúp nhóm nhận ra
            những trải nghiệm được quan tâm nhất.
        </p>

        <ol>
            <li>Mỗi thành viên chọn và lưu sở thích riêng.</li>
            <li>Nhóm xem số người chọn và tỷ lệ từng danh mục.</li>
            <li>Xem gợi ý địa điểm để cùng lên lịch trình.</li>
        </ol>

        <p class="rd-help">
            Tỷ lệ được tính trên tổng thành viên chuyến đi,
            bao gồm cả người chưa chọn sở thích.
        </p>
    </aside>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>