<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<fmt:setLocale value="vi_VN"/>
<c:set var="pageTitle" value="Chuyến đi của bạn" scope="request"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4" aria-labelledby="trips-title">
    <div class="rd-hero-top">
        <div>
            <div class="rd-chips">
                <span class="rd-chip rd-chip-member">
                    Sổ tay hành trình
                </span>
            </div>

            <h1 id="trips-title">Chuyến đi của bạn</h1>

            <p class="mt-3 mb-0">
                Quản lý các chuyến đi bạn tạo hoặc tham gia.
                Cùng lên kế hoạch và chia sẻ những trải nghiệm mới.
            </p>
        </div>

        <a href="${pageContext.request.contextPath}/trip/create"
           class="rd-back">
            + Tạo chuyến đi
        </a>
    </div>
</section>

<div class="d-flex flex-wrap justify-content-between
            align-items-center gap-2 mb-3">
    <h2>Danh sách chuyến đi</h2>
    <span class="rd-count">${fn:length(trips)} chuyến</span>
</div>

<c:choose>
    <c:when test="${empty trips}">
        <section class="rd-card text-center">
            <h2>Bạn chưa có chuyến đi nào</h2>

            <p class="rd-sub mt-2">
                Tạo chuyến đi đầu tiên để chọn điểm đến,
                lên lịch trình và mời bạn bè đồng hành.
            </p>

            <a href="${pageContext.request.contextPath}/trip/create"
               class="btn btn-brand mt-3">
                + Tạo chuyến đi
            </a>
        </section>
    </c:when>

    <c:otherwise>
        <div class="row g-4">
            <c:forEach var="trip" items="${trips}">
                <div class="col-12 col-md-6 col-xl-4">
                    <article class="rd-card h-100 d-flex flex-column">
                        <div class="d-flex flex-wrap gap-2 mb-3">
                            <c:choose>
                                <c:when test="${trip.status == 'PLANNING'}">
                                    <span class="badge text-bg-warning">
                                        Đang lên kế hoạch
                                    </span>
                                </c:when>

                                <c:when test="${trip.status == 'ONGOING'}">
                                    <span class="badge text-bg-primary">
                                        Đang diễn ra
                                    </span>
                                </c:when>

                                <c:when test="${trip.status == 'COMPLETED'}">
                                    <span class="badge text-bg-success">
                                        Đã hoàn thành
                                    </span>
                                </c:when>

                                <c:when test="${trip.status == 'CANCELLED'}">
                                    <span class="badge text-bg-danger">
                                        Đã hủy
                                    </span>
                                </c:when>

                                <c:otherwise>
                                    <span class="badge text-bg-secondary">
                                        Chưa xác định
                                    </span>
                                </c:otherwise>
                            </c:choose>

                            <span class="rd-role ${trip.role == 'OWNER' ? 'rd-role-lead' : ''}">
                                ${trip.role == 'OWNER' ? 'Trưởng nhóm' : 'Thành viên'}
                            </span>
                        </div>

                        <h2 class="mb-3">
                            <c:out value="${trip.name}"/>
                        </h2>

                        <dl class="mb-4">
                            <div class="border-top pt-3 mb-3">
                                <dt class="small text-muted fw-normal">
                                    Khu vực
                                </dt>
                                <dd class="mb-0 mt-1 fw-semibold">
                                    <c:out value="${trip.area}"/>
                                </dd>
                            </div>

                            <div class="mb-3">
                                <dt class="small text-muted fw-normal">
                                    Thời gian
                                </dt>
                                <dd class="mb-0 mt-1">
                                    <fmt:formatDate
                                        value="${trip.startDate}"
                                        pattern="dd/MM/yyyy"/>
                                    –
                                    <fmt:formatDate
                                        value="${trip.endDate}"
                                        pattern="dd/MM/yyyy"/>
                                </dd>
                            </div>

                            <div>
                                <dt class="small text-muted fw-normal">
                                    Ngân sách dự kiến
                                </dt>
                                <dd class="mb-0 mt-1 fw-semibold text-success">
                                    <fmt:formatNumber
                                        value="${trip.budget}"
                                        type="number"
                                        maxFractionDigits="2"/> đ
                                </dd>
                            </div>
                        </dl>

                        <div class="d-flex flex-wrap gap-2
                                    mt-auto border-top pt-3">
                            <a href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}"
                               class="btn btn-brand flex-grow-1">
                                Xem chi tiết
                            </a>

                            <c:if test="${trip.role == 'OWNER'
                                          and (trip.status == 'PLANNING'
                                               or trip.status == 'ONGOING')}">
                                <a href="${pageContext.request.contextPath}/trip/edit?tripId=${trip.id}"
                                   class="btn btn-outline-secondary">
                                    Sửa
                                </a>
                            </c:if>
                        </div>
                    </article>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>