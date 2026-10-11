<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="vi_VN"/>

<c:set var="pageTitle" value="Chia tiền" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<section class="rd-card mb-4">
    <div class="rd-card-heading">
        <div>
            <h2>Chia tiền chuyến đi</h2>
            <p class="rd-sub">
                Đối chiếu số tiền đã trả và phần chi phí
                của từng thành viên.
            </p>
        </div>

        <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
           class="btn btn-outline-secondary">
            Xem chi phí
        </a>
    </div>

    <div class="row g-3">
        <div class="col-12 col-md-4">
            <div class="border rounded-3 p-3 h-100">
                <strong class="text-success">Số dương</strong>
                <p class="rd-sub">
                    Thành viên cần nhận lại tiền.
                </p>
            </div>
        </div>

        <div class="col-12 col-md-4">
            <div class="border rounded-3 p-3 h-100">
                <strong class="text-danger">Số âm</strong>
                <p class="rd-sub">
                    Thành viên cần trả thêm tiền.
                </p>
            </div>
        </div>

        <div class="col-12 col-md-4">
            <div class="border rounded-3 p-3 h-100">
                <strong>Chênh lệch bằng 0</strong>
                <p class="rd-sub">
                    Số tiền đã trả bằng phần chi phí được chia.
                </p>
            </div>
        </div>
    </div>
</section>

<section class="rd-card mb-4">
    <div class="rd-card-heading">
        <div>
            <h2>Chi phí từng thành viên</h2>
            <p class="rd-sub">
                Chênh lệch = Số tiền đã trả − Phần phải trả.
            </p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty balances}">
            <div class="alert alert-info mb-0">
                Chưa có dữ liệu phân chia chi phí để hiển thị.
            </div>
        </c:when>

        <c:otherwise>
            <div class="table-responsive">
                <table class="table mb-0 align-middle">
                    <caption class="visually-hidden">
                        Số tiền đã trả, phần phải trả
                        và chênh lệch của từng thành viên.
                    </caption>

                    <thead>
                        <tr>
                            <th scope="col">Thành viên</th>
                            <th scope="col" class="text-end text-nowrap">
                                Đã trả
                            </th>
                            <th scope="col" class="text-end text-nowrap">
                                Phần phải trả
                            </th>
                            <th scope="col" class="text-end text-nowrap">
                                Chênh lệch
                            </th>
                        </tr>
                    </thead>

                    <tbody>
                        <c:forEach var="b" items="${balances}">
                            <tr>
                                <th scope="row">
                                    <c:out value="${b.memberName}"/>
                                </th>

                                <td class="text-end text-nowrap">
                                    <fmt:formatNumber
                                        value="${b.paid}"
                                        type="number"
                                        maxFractionDigits="2"/> đ
                                </td>

                                <td class="text-end text-nowrap">
                                    <fmt:formatNumber
                                        value="${b.owed}"
                                        type="number"
                                        maxFractionDigits="2"/> đ
                                </td>

                                <td class="text-end text-nowrap">
                                    <c:choose>
                                        <c:when test="${b.balance > 0}">
                                            <strong class="text-success">
                                                +<fmt:formatNumber
                                                    value="${b.balance}"
                                                    type="number"
                                                    maxFractionDigits="2"/> đ
                                            </strong>
                                            <small class="d-block text-muted">
                                                Cần nhận lại
                                            </small>
                                        </c:when>

                                        <c:when test="${b.balance < 0}">
                                            <strong class="text-danger">
                                                <fmt:formatNumber
                                                    value="${b.balance}"
                                                    type="number"
                                                    maxFractionDigits="2"/> đ
                                            </strong>
                                            <small class="d-block text-muted">
                                                Cần trả thêm
                                            </small>
                                        </c:when>

                                        <c:otherwise>
                                            <strong>0 đ</strong>
                                            <small class="d-block text-muted">
                                                Cân bằng
                                            </small>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<section class="rd-card">
    <div class="rd-card-heading">
        <div>
            <h2>Gợi ý chuyển khoản</h2>
            <p class="rd-sub">
                Các khoản chuyển được đề xuất
                theo dữ liệu chi phí hiện tại.
            </p>
        </div>

        <a href="${pageContext.request.contextPath}/group-fund?tripId=${trip.id}"
           class="btn btn-outline-secondary">
            Xem quỹ nhóm
        </a>
    </div>

    <c:choose>
        <c:when test="${empty balances}">
            <div class="alert alert-info mb-0">
                Chưa có dữ liệu để đề xuất chuyển khoản.
            </div>
        </c:when>

        <c:when test="${empty transfers}">
            <div class="alert alert-info mb-0">
                Không có khoản chuyển nào được đề xuất
                theo dữ liệu hiện tại.
            </div>
        </c:when>

        <c:otherwise>
            <ul class="list-unstyled mb-0">
                <c:forEach var="t" items="${transfers}"
                           varStatus="transferStatus">
                    <li class="border rounded-3 p-3
                               ${transferStatus.last ? '' : 'mb-3'}">
                        <div class="d-flex flex-wrap
                                    justify-content-between
                                    align-items-center gap-3">
                            <div>
                                <strong>
                                    <c:out value="${t.fromMemberName}"/>
                                </strong>
                                <span class="text-muted">
                                    trả cho
                                </span>
                                <strong>
                                    <c:out value="${t.toMemberName}"/>
                                </strong>
                            </div>

                            <strong class="text-success text-nowrap">
                                <fmt:formatNumber
                                    value="${t.amount}"
                                    type="number"
                                    maxFractionDigits="2"/> đ
                            </strong>
                        </div>
                    </li>
                </c:forEach>
            </ul>

            <p class="rd-sub mt-3">
                Đây là gợi ý phân chia tiền.
                Trang này không thực hiện chuyển khoản
                và không xác nhận giao dịch đã thanh toán.
            </p>
        </c:otherwise>
    </c:choose>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>