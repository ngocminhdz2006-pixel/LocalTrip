<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Trip Expenses" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<div class="lt-expense-page" style="max-width: 720px; margin: 0 auto; padding-bottom: 24px;">

    <%-- Success & Error Alerts --%>
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show mb-3" role="alert">
            <c:out value="${sessionScope.successMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show mb-3" role="alert">
            <c:out value="${sessionScope.errorMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <%-- Calculate total expenses --%>
    <c:set var="totalAmount" value="0" />
    <c:forEach var="item" items="${expenses}">
        <c:set var="totalAmount" value="${totalAmount + item.amount}" />
    </c:forEach>

    <%-- 1. Financial Overview Summary Grid --%>
    <section class="lt-exp-summary-hero mb-3" style="background: linear-gradient(135deg, #175b43, #143b2d); border-radius: 18px; padding: 20px; color: white;">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <span style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.85;">TOTAL TRIP SPEND</span>
            <span style="font-size: 11px; background: rgba(255,255,255,0.2); padding: 3px 10px; border-radius: 20px;">
                ${fn:length(expenses)} recorded expenses
            </span>
        </div>
        
        <h2 style="font-size: 28px; font-weight: 800; margin: 0 0 16px;">
            <fmt:formatNumber value="${totalAmount}" type="number" maxFractionDigits="0"/> VND
        </h2>

        <div class="row g-2 pt-2 border-top border-white-50">
            <div class="col-6">
                <span style="font-size: 11px; opacity: 0.8; display: block;">REMAINING BUDGET</span>
                <c:choose>
                    <c:when test="${trip.budget != null and trip.budget > 0}">
                        <c:set var="remBudget" value="${trip.budget - totalAmount}"/>
                        <strong style="font-size: 14px; color: ${remBudget >= 0 ? '#a7f3d0' : '#fecdd3'};">
                            <fmt:formatNumber value="${remBudget}" type="number" maxFractionDigits="0"/> VND
                            <span style="font-size: 10px;">(${remBudget >= 0 ? 'Within' : 'Over'})</span>
                        </strong>
                    </c:when>
                    <c:otherwise>
                        <span style="font-size: 12px; opacity: 0.9;">No budget limit set</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="col-6">
                <span style="font-size: 11px; opacity: 0.8; display: block;">GROUP FUND BALANCE</span>
                <strong style="font-size: 14px; color: #bae6fd;">
                    <c:choose>
                        <c:when test="${not empty fundSummary}">
                            <fmt:formatNumber value="${fundSummary.balance}" type="number" maxFractionDigits="0"/> VND
                        </c:when>
                        <c:otherwise>0 VND</c:otherwise>
                    </c:choose>
                </strong>
            </div>
        </div>
    </section>

    <%-- 2. Sub-Modules Navigation Cards: Settlement & Group Fund --%>
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 16px;">
        <a href="${pageContext.request.contextPath}/settlement?tripId=${trip.id}"
           style="display: flex; align-items: center; gap: 10px; padding: 12px; background: #ffffff; border: 1.5px solid #dce7df; border-radius: 14px; text-decoration: none; transition: all 0.15s ease;">
            <div style="width: 38px; height: 38px; border-radius: 10px; background: #ecfdf5; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0;">
                ⚖️
            </div>
            <div>
                <strong style="display: block; font-size: 13px; color: #143b2d;">2-Way Settlement</strong>
                <span style="font-size: 11px; color: #64748b;">Balances & VietQR</span>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/group-fund?tripId=${trip.id}"
           style="display: flex; align-items: center; gap: 10px; padding: 12px; background: #ffffff; border: 1.5px solid #dce7df; border-radius: 14px; text-decoration: none; transition: all 0.15s ease;">
            <div style="width: 38px; height: 38px; border-radius: 10px; background: #eff6ff; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0;">
                🏦
            </div>
            <div>
                <strong style="display: block; font-size: 13px; color: #1e40af;">Group Fund</strong>
                <span style="font-size: 11px; color: #64748b;">Cash contributions</span>
            </div>
        </a>
    </div>

    <%-- 3. Collapsible Per-Member Share Summary Table --%>
    <c:if test="${not empty memberBalances}">
        <div class="card p-3 mb-4" style="border-radius: 14px; border: 1.5px solid #e2e8f0; background: #ffffff;">
            <details>
                <summary class="fw-bold d-flex justify-content-between align-items-center" style="cursor: pointer; font-size: 13px; color: #143b2d;">
                    <span>👥 Per-Member Share Breakdown (${fn:length(memberBalances)} members)</span>
                    <span class="text-muted small">Tap to expand / collapse ▾</span>
                </summary>
                <div class="table-responsive mt-3">
                    <table class="table table-sm table-bordered align-middle mb-0" style="font-size: 12px;">
                        <thead class="table-light">
                            <tr>
                                <th>Member</th>
                                <th class="text-end">Paid</th>
                                <th class="text-end">Share Owed</th>
                                <th class="text-end">Net Balance</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="mb" items="${memberBalances}">
                                <tr>
                                    <td class="fw-semibold"><c:out value="${mb.memberName}"/></td>
                                    <td class="text-end"><fmt:formatNumber value="${mb.paid}" type="number" maxFractionDigits="0"/> VND</td>
                                    <td class="text-end text-muted"><fmt:formatNumber value="${mb.owed}" type="number" maxFractionDigits="0"/> VND</td>
                                    <td class="text-end fw-bold" style="color: ${mb.balance > 0 ? '#047857' : (mb.balance < 0 ? '#e11d48' : '#64748b')};">
                                        <c:if test="${mb.balance > 0}">+</c:if><fmt:formatNumber value="${mb.balance}" type="number" maxFractionDigits="0"/> VND
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </details>
        </div>
    </c:if>

    <%-- 4. Add Expense Button --%>
    <c:if test="${trip.status == 'PLANNING' or trip.status == 'ONGOING'}">
        <div class="mb-4">
            <a href="${pageContext.request.contextPath}/expenses/create?tripId=${trip.id}"
               class="btn btn-primary w-100 py-2 d-flex align-items-center justify-content-center gap-2"
               style="background-color: #175b43; border-color: #175b43; border-radius: 14px; font-weight: 700; font-size: 14px;">
                <span>＋</span> Add Expense
            </a>
        </div>
    </c:if>

    <%-- 5. Expense Cards List --%>
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 style="font-size: 14px; font-weight: 700; color: #143b2d; margin: 0;">
            Expense History (${fn:length(expenses)})
        </h3>
        <span style="font-size: 11px; color: #64748b;">Most recent first</span>
    </div>

    <c:choose>
        <c:when test="${empty expenses}">
            <div class="rd-card text-center py-5" style="border-radius: 16px; border: 1.5px dashed #cbd5e1; background: #ffffff;">
                <div style="font-size: 36px; margin-bottom: 8px;">🧾</div>
                <h4 style="font-size: 16px; font-weight: 700; color: #1e293b; margin: 0 0 6px;">No expenses logged yet</h4>
                <p style="font-size: 12px; color: #64748b; margin: 0;">
                    Tap "+ Add Expense" above to track meals, transport, or activity tickets!
                </p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="lt-exp-card-list">
                <c:forEach var="expense" items="${expenses}">
                    <article class="lt-exp-card p-3 mb-2" style="background: #ffffff; border: 1.5px solid #e2e8f0; border-radius: 14px;">
                        <div class="d-flex justify-content-between align-items-start gap-2 mb-2">
                            <h4 class="h6 fw-bold mb-0 text-dark">
                                <c:out value="${expense.description}"/>
                            </h4>
                            <span class="fw-bold" style="color: #175b43; font-size: 14px; flex-shrink: 0;">
                                <fmt:formatNumber value="${expense.amount}" type="number" maxFractionDigits="0"/> VND
                            </span>
                        </div>

                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 text-muted small mb-2">
                            <span>👤 Paid by: <strong><c:out value="${expense.payerName}"/></strong></span>

                            <c:choose>
                                <c:when test="${expense.fromGroupFund}">
                                    <span class="badge" style="background: #eff6ff; color: #1e40af; border: 1px solid #bfdbfe; font-size: 10px;">
                                        🏦 Group fund
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge" style="background: #f8fafc; color: #475569; border: 1px solid #e2e8f0; font-size: 10px;">
                                        Personal
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div style="font-size: 11px; color: #64748b; margin-top: 4px;">
                            <span>Split among: </span>
                            <span style="color: #334155; font-weight: 500;">
                                <c:forEach var="p" items="${expense.participantNames}" varStatus="st">
                                    <c:out value="${p}"/><c:if test="${!st.last}">, </c:if>
                                </c:forEach>
                            </span>
                        </div>

                        <c:if test="${trip.role == 'OWNER' || expense.createdBy == sessionScope.user.userId}">
                            <div class="d-flex justify-content-end gap-2 mt-2 pt-2 border-top">
                                <a href="${pageContext.request.contextPath}/expenses/edit?tripId=${trip.id}&amp;expenseId=${expense.id}"
                                   class="btn btn-sm btn-outline-secondary py-1 px-2" style="font-size: 11px;">
                                    Edit
                                </a>

                                <form method="post" action="${pageContext.request.contextPath}/expenses/delete"
                                      onsubmit="return confirm('Are you sure you want to delete this expense?');" style="margin: 0;">
                                    <input type="hidden" name="travelCsrf" value="${sessionScope.travelCsrf}"/>
                                    <input type="hidden" name="tripId" value="${trip.id}">
                                    <input type="hidden" name="expenseId" value="${expense.id}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger py-1 px-2" style="font-size: 11px;">
                                        Delete
                                    </button>
                                </form>
                            </div>
                        </c:if>
                    </article>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
