<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="vi_VN"/>
<c:set var="pageTitle" value="Quỹ nhóm" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<section class="rd-card mb-4">
    <div class="rd-card-heading">
        <div>
            <h2>Quỹ chung của chuyến đi</h2>
            <p class="rd-sub">
                Theo dõi tiền thành viên đóng góp và các khoản chi từ quỹ.
            </p>
        </div>

        <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
           class="btn btn-outline-secondary">
            Quản lý chi phí
        </a>
    </div>

    <p class="rd-sub">
        Số dư = Tổng tiền đã đóng − Tổng chi từ quỹ.
        Chỉ các khoản chi được đánh dấu “Chi từ quỹ nhóm”
        mới được trừ vào số dư.
    </p>
</section>

<div class="row g-3 mb-4">
    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <p class="rd-sub">Tổng tiền đã đóng</p>
            <h2 class="mt-2 text-success">
                <fmt:formatNumber value="${fundSummary.totalContributed}"
                                  type="number"
                                  maxFractionDigits="2"/> đ
            </h2>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <p class="rd-sub">Tổng chi từ quỹ</p>
            <h2 class="mt-2">
                <fmt:formatNumber value="${fundSummary.totalSpent}"
                                  type="number"
                                  maxFractionDigits="2"/> đ
            </h2>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <p class="rd-sub">Số dư quỹ</p>
            <h2 class="mt-2 ${fundSummary.balance < 0 ? 'text-danger' : 'text-success'}">
                <fmt:formatNumber value="${fundSummary.balance}"
                                  type="number"
                                  maxFractionDigits="2"/> đ
            </h2>

            <c:if test="${fundSummary.balance < 0}">
                <p class="small text-danger mt-2 mb-0">
                    Tổng chi đang vượt số tiền đã đóng.
                </p>
            </c:if>
        </section>
    </div>
</div>

<c:if test="${trip.role == 'OWNER'}">
    <section class="rd-card mb-4">
        <div class="rd-card-heading">
            <div>
                <h2>Ghi nhận đóng quỹ</h2>
                <p class="rd-sub">
                    Trưởng nhóm ghi nhận tiền đã nhận từ thành viên.
                    Khoản đóng sẽ được cộng vào số dư quỹ.
                </p>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty memberFundSummaries}">
                <div class="alert alert-info mb-0">
                    Chưa có thành viên để ghi nhận đóng quỹ.
                </div>
            </c:when>

            <c:otherwise>
                <form method="post"
                      action="${pageContext.request.contextPath}/group-fund/contribute"
                      class="row g-3">

                    <input type="hidden" name="tripId" value="${trip.id}">

                    <div class="col-12 col-md-6">
                        <label for="fundMember" class="form-label">
                            Thành viên đóng tiền
                        </label>

                        <select id="fundMember" name="memberId"
                                class="form-select" required>
                            <option value="">Chọn thành viên</option>

                            <c:forEach var="memberFund"
                                       items="${memberFundSummaries}">
                                <option value="${memberFund.userId}">
                                    <c:out value="${memberFund.memberName}"/>
                                    — ${memberFund.role == 'OWNER' ? 'Trưởng nhóm' : 'Thành viên'}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="fundAmount" class="form-label">
                            Số tiền (đồng)
                        </label>

                        <input id="fundAmount" type="number"
                               name="amount" class="form-control"
                               min="1" step="1" required>
                    </div>

                    <div class="col-12">
                        <label for="fundNote" class="form-label">
                            Ghi chú
                        </label>

                        <input id="fundNote" type="text" name="note"
                               maxlength="255" class="form-control"
                               placeholder="Ví dụ: Đóng quỹ lần 1">
                    </div>

                    <div class="col-12">
                        <button class="btn btn-brand" type="submit">
                            Ghi nhận đóng quỹ
                        </button>
                    </div>
                </form>
            </c:otherwise>
        </c:choose>
    </section>
</c:if>

<section class="rd-card mb-4">
    <div class="rd-card-heading">
        <div>
            <h2>Đóng góp của thành viên</h2>
            <p class="rd-sub">
                Tổng tiền đóng, số lần đóng và thời điểm gần nhất.
            </p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty memberFundSummaries}">
            <div class="alert alert-info mb-0">
                Chưa có dữ liệu đóng góp của thành viên.
            </div>
        </c:when>

        <c:otherwise>
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <caption class="visually-hidden">
                        Đóng góp vào quỹ của từng thành viên.
                    </caption>
                    <thead>
                        <tr>
                            <th scope="col">Thành viên</th>
                            <th scope="col">Vai trò</th>
                            <th scope="col" class="text-center text-nowrap">
                                Số lần đóng
                            </th>
                            <th scope="col" class="text-nowrap">
                                Lần đóng gần nhất
                            </th>
                            <th scope="col" class="text-end text-nowrap">
                                Tổng đã đóng
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="memberFund"
                                   items="${memberFundSummaries}">
                            <tr>
                                <th scope="row">
                                    <c:out value="${memberFund.memberName}"/>
                                </th>

                                <td>
                                    <span class="rd-role ${memberFund.role == 'OWNER' ? 'rd-role-lead' : ''}">
                                        ${memberFund.role == 'OWNER' ? 'Trưởng nhóm' : 'Thành viên'}
                                    </span>
                                </td>

                                <td class="text-center">
                                    ${memberFund.contributionCount}
                                </td>

                                <td class="text-nowrap">
                                    <c:choose>
                                        <c:when test="${not empty memberFund.lastContributionAt}">
                                            <fmt:formatDate
                                                value="${memberFund.lastContributionAt}"
                                                pattern="dd/MM/yyyy HH:mm"/>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">
                                                Chưa đóng quỹ
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="text-end text-nowrap">
                                    <strong class="text-success">
                                        <fmt:formatNumber
                                            value="${memberFund.contributed}"
                                            type="number"
                                            maxFractionDigits="2"/> đ
                                    </strong>
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
            <h2>Lịch sử giao dịch quỹ</h2>
            <p class="rd-sub">
                Các khoản đóng góp và khoản chi từ quỹ nhóm.
            </p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty fundTransactions}">
            <div class="alert alert-info mb-0">
                Chưa có giao dịch quỹ.
            </div>
        </c:when>

        <c:otherwise>
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <caption class="visually-hidden">
                        Lịch sử đóng góp và chi từ quỹ.
                    </caption>
                    <thead>
                        <tr>
                            <th scope="col">Thời gian</th>
                            <th scope="col">Loại giao dịch</th>
                            <th scope="col">Thành viên</th>
                            <th scope="col">Mô tả</th>
                            <th scope="col" class="text-end">Số tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="tx" items="${fundTransactions}">
                            <tr>
                                <td class="text-nowrap">
                                    <fmt:formatDate value="${tx.createdAt}"
                                                    pattern="dd/MM/yyyy HH:mm"/>
                                </td>

                                <td class="text-nowrap">
                                    <c:choose>
                                        <c:when test="${tx.type == 'CONTRIBUTION'}">
                                            <span class="badge text-bg-success">
                                                Đóng quỹ
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge text-bg-danger">
                                                Chi từ quỹ
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:out value="${tx.memberName}"/>
                                </td>

                                <td>
                                    <c:out value="${tx.description}"/>
                                </td>

                                <td class="text-end text-nowrap">
                                    <strong class="${tx.amount < 0 ? 'text-danger' : 'text-success'}">
                                        <c:if test="${tx.amount > 0}">+</c:if>
                                        <fmt:formatNumber value="${tx.amount}"
                                                          type="number"
                                                          maxFractionDigits="2"/> đ
                                    </strong>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>  