<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chuyến đi của bạn" scope="request"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
    <div class="page-intro mb-0">
        <span class="eyebrow">SỔ TAY HÀNH TRÌNH</span>
        <h3 class="mb-1">Chuyến đi của bạn</h3>
        <p class="text-muted mb-0">
            Quản lý các chuyến đi bạn tạo hoặc tham gia.
        </p>
    </div>

    <a href="${pageContext.request.contextPath}/trip/create"
       class="btn btn-brand">
        + Tạo chuyến đi
    </a>
</div>

<c:choose>
    <c:when test="${empty trips}">
        <div class="empty-state app-card">
            <h5>Bạn chưa có chuyến đi nào</h5>
            <p class="text-muted">
                Tạo chuyến đi đầu tiên để bắt đầu lên kế hoạch.
            </p>

            <a href="${pageContext.request.contextPath}/trip/create"
               class="btn btn-brand">
                + Tạo chuyến đi
            </a>
        </div>
    </c:when>

    <c:otherwise>
        <div class="row g-4">
            <c:forEach var="trip" items="${trips}">
                <div class="col-md-6 col-lg-4">
                    <div class="app-card h-100 d-flex flex-column mb-0">
                        <div class="d-flex justify-content-between align-items-start gap-2 mb-3">
                            <h5 class="mb-0">
                                <c:out value="${trip.name}"/>
                            </h5>

                            <c:choose>
                                <c:when test="${trip.role == 'OWNER'}">
                                    <span class="badge badge-owner flex-shrink-0">
                                        Trưởng nhóm
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-member flex-shrink-0">
                                        Thành viên
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <p class="text-muted mb-2">
                            <strong>Khu vực:</strong>
                            <c:out value="${trip.area}"/>
                        </p>

                        <p class="text-muted mb-2">
                            <strong>Thời gian:</strong>
                            <fmt:formatDate value="${trip.startDate}"
                                            pattern="dd/MM/yyyy"/>
                            –
                            <fmt:formatDate value="${trip.endDate}"
                                            pattern="dd/MM/yyyy"/>
                        </p>

                        <p class="text-muted mb-3">
                            <strong>Ngân sách:</strong>
                            <fmt:formatNumber value="${trip.budget}"
                                              type="number"
                                              maxFractionDigits="2"/>
                            đ
                        </p>

                        <div class="mb-4">
                            <c:choose>
                                <c:when test="${trip.status == 'PLANNING'}">
                                    <span class="badge text-bg-secondary">
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
                        </div>

                        <div class="d-flex flex-wrap gap-2 mt-auto">
                            <a href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}"
                               class="btn btn-brand btn-sm flex-grow-1">
                                Xem chi tiết
                            </a>

                            <c:if test="${trip.role == 'OWNER'
                                          and (trip.status == 'PLANNING'
                                          or trip.status == 'ONGOING')}">
                                  <a href="${pageContext.request.contextPath}/trip/edit?tripId=${trip.id}"
                                     class="btn btn-outline-secondary btn-sm">
                                      Sửa
                                  </a>
                            </c:if>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>