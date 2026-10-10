<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Chi phí" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="vi_VN" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<style>
    .rd-expense-intro {
        margin-bottom: 24px;
    }

    .rd-expense-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        margin-top: 18px;
    }

    .rd-expense-table {
        padding: 0;
        overflow: hidden;
    }

    .rd-expense-table-heading {
        padding: 22px 28px;
        border-bottom: 1px solid var(--line);
    }

    .rd-expense-table-heading h2 {
        margin: 0 0 8px;
        font-size: 20px;
        font-weight: 700;
    }

    .rd-expense-table .table {
        min-width: 850px;
    }

    .rd-expense-table thead th {
        padding: 16px 20px;
        background: #F6F9F7;
        color: var(--ink2);
        font-weight: 600;
        white-space: nowrap;
    }

    .rd-expense-table tbody td {
        padding: 18px 20px;
        border-color: var(--line);
    }

    .rd-expense-table tbody tr:last-child td {
        border-bottom: 0;
    }

    .rd-expense-amount {
        color: var(--green);
        font-weight: 700;
        white-space: nowrap;
    }

    .rd-expense-source {
        display: inline-block;
        padding: 6px 10px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 600;
        white-space: nowrap;
    }

    .rd-expense-source.fund {
        background: var(--mint);
        color: var(--green);
    }

    .rd-expense-source.personal {
        background: #EEF1EF;
        color: var(--ink2);
    }

    .rd-expense-empty {
        padding: 48px 24px;
        text-align: center;
    }

    .rd-expense-empty h2 {
        margin: 16px 0 8px;
        font-size: 20px;
    }

    @media (max-width: 600px) {
        .rd-expense-actions .btn {
            width: 100%;
        }

        .rd-expense-table-heading {
            padding: 18px 20px;
        }
    }
</style>

<section class="rd-card rd-expense-intro">
    <div class="rd-card-heading">
        <div>
            <h2>Chi phí chuyến đi</h2>
            <p class="rd-sub">
                Theo dõi các khoản chi, người thanh toán
                và những thành viên tham gia chia tiền.
            </p>
        </div>

        <span class="rd-count">
            <c:out value="${empty expenses ? 0 : expenses.size()}"/> khoản chi
        </span>
    </div>

    <div class="rd-expense-actions">
        <c:if test="${trip.status == 'PLANNING'
                      or trip.status == 'ONGOING'}">
              <a href="${pageContext.request.contextPath}/expenses/create?tripId=${trip.id}"
                 class="btn btn-brand">
                  + Thêm chi phí
              </a>
        </c:if>

        <a href="${pageContext.request.contextPath}/settlement?tripId=${trip.id}"
           class="btn btn-outline-secondary">
            Xem chia tiền
        </a>
    </div>
</section>

<c:choose>
    <c:when test="${empty expenses}">
        <div class="rd-card rd-expense-empty">
            <div class="empty-icon">🧾</div>
            <h2>Chưa có khoản chi</h2>
            <p class="rd-sub">
                Các khoản chi được thêm sẽ xuất hiện tại đây
                để cả nhóm cùng theo dõi.
            </p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="rd-card rd-expense-table">
            <div class="rd-expense-table-heading">
                <h2>Các khoản chi đã ghi nhận</h2>
                <p class="rd-sub">
                    Chi tiết người trả, số tiền và nguồn thanh toán.
                </p>
            </div>

            <div class="table-responsive">
                <table class="table mb-0 align-middle">
                    <thead>
                        <tr>
                            <th>Mô tả</th>
                            <th>Người trả</th>
                            <th>Số tiền</th>
                            <th>Người tham gia</th>
                            <th>Nguồn</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>

                    <tbody>
                        <c:forEach var="expense" items="${expenses}">
                            <tr>
                                <td>
                                    <c:out value="${expense.description}"/>
                                </td>

                                <td>
                                    <c:out value="${expense.payerName}"/>
                                </td>

                                <td class="rd-expense-amount">
                                    <fmt:formatNumber value="${expense.amount}"
                                                      type="number"
                                                      maxFractionDigits="0"/> đ
                                </td>

                                <td>
                                    <c:forEach var="p"
                                               items="${expense.participantNames}"
                                               varStatus="st">
                                        <c:out value="${p}"/><c:if test="${!st.last}">, </c:if>
                                    </c:forEach>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${expense.fromGroupFund}">
                                            <span class="rd-expense-source fund">
                                                Quỹ nhóm
                                            </span>
                                        </c:when>

                                        <c:otherwise>
                                            <span class="rd-expense-source personal">
                                                Cá nhân
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${trip.role == 'OWNER'
                                                        || expense.createdBy == sessionScope.user.userId}">
                                                <div class="d-flex gap-2 align-items-center flex-wrap">
                                                    <a href="${pageContext.request.contextPath}/expenses/edit?tripId=${trip.id}&amp;expenseId=${expense.id}"
                                                       class="btn btn-sm btn-outline-primary">
                                                        Chỉnh sửa
                                                    </a>

                                                    <form method="post"
                                                          action="${pageContext.request.contextPath}/expenses/delete"
                                                          onsubmit="return confirm('Bạn có chắc muốn xóa khoản chi này?');">
                                                        <input type="hidden"
                                                               name="tripId"
                                                               value="${trip.id}">

                                                        <input type="hidden"
                                                               name="expenseId"
                                                               value="${expense.id}">

                                                        <button type="submit"
                                                                class="btn btn-sm btn-outline-danger">
                                                            Xóa
                                                        </button>
                                                    </form>
                                                </div>
                                        </c:when>

                                        <c:otherwise>
                                            <span class="text-muted">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div> <%-- Đóng table-responsive --%>
        </div> <%-- Đóng rd-expense-table --%>
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>