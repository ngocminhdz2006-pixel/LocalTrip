<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="en_US"/>
<c:set var="pageTitle" value="Group Fund" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<section class="rd-card mb-4">
    <div class="rd-card-heading">
        <div>
            <h2>Trip Group Fund</h2>
            <p class="rd-sub">
                Track member contributions and common expenses deducted from the shared fund.
            </p>
        </div>

        <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
           class="btn btn-outline-secondary">
            Manage expenses
        </a>
    </div>

    <p class="rd-sub">
        Fund Balance = Total Contributed − Total Spent from Fund.
        Only expenses marked as “Paid from group fund”
        are deducted from this balance.
    </p>
</section>

<div class="row g-3 mb-4">
    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <p class="rd-sub">Total Contributed</p>
            <h2 class="mt-2 text-success">
                <fmt:formatNumber value="${fundSummary.totalContributed}"
                                  type="number"
                                  maxFractionDigits="2"/> VND
            </h2>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <p class="rd-sub">Total Spent from Fund</p>
            <h2 class="mt-2">
                <fmt:formatNumber value="${fundSummary.totalSpent}"
                                  type="number"
                                  maxFractionDigits="2"/> VND
            </h2>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <p class="rd-sub">Fund Balance</p>
            <h2 class="mt-2 ${fundSummary.balance < 0 ? 'text-danger' : 'text-success'}">
                <fmt:formatNumber value="${fundSummary.balance}"
                                  type="number"
                                  maxFractionDigits="2"/> VND
            </h2>

            <c:if test="${fundSummary.balance < 0}">
                <p class="small text-danger mt-2 mb-0">
                    Total spent currently exceeds total contributed funds.
                </p>
            </c:if>
        </section>
    </div>
</div>

<c:if test="${trip.role == 'OWNER'}">
    <section class="rd-card mb-4">
        <div class="rd-card-heading">
            <div>
                <h2>Record Contribution</h2>
                <p class="rd-sub">
                    Trip owner records funds received from members.
                    This adds directly to the group fund balance.
                </p>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty memberFundSummaries}">
                <div class="alert alert-info mb-0">
                    No members available to record contributions.
                </div>
            </c:when>

            <c:otherwise>
                <form method="post"
                      action="${pageContext.request.contextPath}/group-fund/contribute"
                      class="row g-3">

                    <input type="hidden" name="tripId" value="${trip.id}">

                    <div class="col-12 col-md-6">
                        <label for="fundMember" class="form-label">
                            Contributing member
                        </label>

                        <select id="fundMember" name="memberId"
                                class="form-select" required>
                            <option value="">Select member</option>

                            <c:forEach var="memberFund"
                                       items="${memberFundSummaries}">
                                <option value="${memberFund.userId}">
                                    <c:out value="${memberFund.memberName}"/>
                                    — ${memberFund.role == 'OWNER' ? 'Trip Lead' : 'Member'}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="fundAmount" class="form-label">
                            Amount (VND)
                        </label>

                        <input id="fundAmount" type="number"
                               name="amount" class="form-control"
                               min="1" step="1" required>
                    </div>

                    <div class="col-12">
                        <label for="fundNote" class="form-label">
                            Note
                        </label>

                        <input id="fundNote" type="text" name="note"
                               maxlength="255" class="form-control"
                               placeholder="e.g. Deposit for trip round 1">
                    </div>

                    <div class="col-12">
                        <button class="btn btn-brand" type="submit">
                            Record contribution
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
            <h2>Member Contributions</h2>
            <p class="rd-sub">
                Total contributed, deposit counts, and latest activity per member.
            </p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty memberFundSummaries}">
            <div class="alert alert-info mb-0">
                No contribution records available yet.
            </div>
        </c:when>

        <c:otherwise>
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <caption class="visually-hidden">
                        Member fund contributions table.
                    </caption>
                    <thead>
                        <tr>
                            <th scope="col">Member</th>
                            <th scope="col">Role</th>
                            <th scope="col" class="text-center text-nowrap">
                                Deposits
                            </th>
                            <th scope="col" class="text-nowrap">
                                Latest deposit
                            </th>
                            <th scope="col" class="text-end text-nowrap">
                                Total contributed
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
                                        ${memberFund.role == 'OWNER' ? 'Trip Lead' : 'Member'}
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
                                                No deposits yet
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="text-end text-nowrap">
                                    <strong class="text-success">
                                        <fmt:formatNumber
                                            value="${memberFund.contributed}"
                                            type="number"
                                            maxFractionDigits="2"/> VND
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
            <h2>Fund Transaction History</h2>
            <p class="rd-sub">
                Detailed logs of all deposits and expenses made through the group fund.
            </p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty fundTransactions}">
            <div class="alert alert-info mb-0">
                No fund transactions yet.
            </div>
        </c:when>

        <c:otherwise>
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <caption class="visually-hidden">
                        Transaction history table.
                    </caption>
                    <thead>
                        <tr>
                            <th scope="col">Date & Time</th>
                            <th scope="col">Type</th>
                            <th scope="col">Member</th>
                            <th scope="col">Description</th>
                            <th scope="col" class="text-end">Amount</th>
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
                                                Deposit
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge text-bg-danger">
                                                Expense
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
                                                          maxFractionDigits="2"/> VND
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
