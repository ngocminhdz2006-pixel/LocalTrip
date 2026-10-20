<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Trip Expenses" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="vi_VN" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<div class="lt-expense-page" style="max-width: 680px; margin: 0 auto; padding-bottom: 24px;">

    <%-- Tính tổng chi phí của cả chuyến đi --%>
    <c:set var="totalAmount" value="0" />
    <c:forEach var="item" items="${expenses}">
        <c:set var="totalAmount" value="${totalAmount + item.amount}" />
    </c:forEach>

    <%-- 1. Hero Summary Card (Mobile Financial Overview) --%>
    <section class="lt-exp-summary-hero">
        <div class="lt-exp-summary-top">
            <span class="lt-exp-summary-label">Total Group Expenses</span>
            <span style="font-size: 11px; background: rgba(255,255,255,0.18); padding: 2px 8px; border-radius: 20px;">
                ${fn:length(expenses)} expenses
            </span>
        </div>
        
        <h2 class="lt-exp-total-amount">
            <fmt:formatNumber value="${totalAmount}" type="number" maxFractionDigits="0"/> VND
        </h2>

        <div class="lt-exp-summary-stats">
            <div class="lt-exp-stat-item">
                <span>Destination: </span>
                <strong><c:out value="${trip.area}"/></strong>
            </div>
            <div class="lt-exp-stat-item">
                <span>Status: </span>
                <strong><c:out value="${trip.status}"/></strong>
            </div>
        </div>
    </section>

    <%-- 2. Action Buttons (Add Expense + Settlement) --%>
    <div class="lt-exp-actions-row">
        <c:if test="${trip.status == 'PLANNING' or trip.status == 'ONGOING'}">
            <a href="${pageContext.request.contextPath}/expenses/create?tripId=${trip.id}"
               class="lt-exp-btn-add">
                <span>＋</span> Add Expense
            </a>
        </c:if>

        <a href="${pageContext.request.contextPath}/settlement?tripId=${trip.id}"
           class="lt-exp-btn-settle">
            <span>⚖️</span> Settlement
        </a>
    </div>

    <%-- 3. Danh sách expenses dạng Thẻ Di Động --%>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;">
        <h3 style="font-size: 13px; font-weight: 700; color: #143b2d; margin: 0;">
            Expense History (${fn:length(expenses)})
        </h3>
        <span style="font-size: 10px; color: #64748b;">Most recent first</span>
    </div>

    <c:choose>
        <c:when test="${empty expenses}">
            <div class="rd-card rd-expense-empty" style="border-radius: 18px; border: 1px dashed #cbd5e1; text-align: center; padding: 36px 16px;">
                <div style="font-size: 32px; margin-bottom: 8px;">🧾</div>
                <h4 style="font-size: 15px; font-weight: 700; color: #1e293b; margin: 0 0 4px;">No expenses yet</h4>
                <p style="font-size: 11px; color: #64748b; margin: 0;">
                    Tap "+ Add Expense" above to record meals, tickets, or transport costs!
                </p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="lt-exp-card-list">
                <c:forEach var="expense" items="${expenses}">
                    <article class="lt-exp-card">
                        <div class="lt-exp-card-header">
                            <h4 class="lt-exp-desc">
                                <c:out value="${expense.description}"/>
                            </h4>
                            <span class="lt-exp-price">
                                <fmt:formatNumber value="${expense.amount}" type="number" maxFractionDigits="0"/> VND
                            </span>
                        </div>

                        <div class="lt-exp-card-meta">
                            <span class="lt-exp-payer">
                                <span>👤 Payer: <strong><c:out value="${expense.payerName}"/></strong></span>
                            </span>

                            <c:choose>
                                <c:when test="${expense.fromGroupFund}">
                                    <span class="lt-exp-source-tag fund">Group fund</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="lt-exp-source-tag personal">Personal</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div style="font-size: 11px; color: #64748b; margin-top: 6px;">
                            <span>Split among: </span>
                            <span style="color: #334155; font-weight: 500;">
                                <c:forEach var="p" items="${expense.participantNames}" varStatus="st">
                                    <c:out value="${p}"/><c:if test="${!st.last}">, </c:if>
                                </c:forEach>
                            </span>
                        </div>

                        <%-- Chỉnh sửa / Delete (dành cho chủ chuyến đi hoặc người tạo) --%>
                        <c:if test="${trip.role == 'OWNER' || expense.createdBy == sessionScope.user.userId}">
                            <div class="lt-exp-card-actions">
                                <a href="${pageContext.request.contextPath}/expenses/edit?tripId=${trip.id}&amp;expenseId=${expense.id}"
                                   class="lt-exp-btn-sm lt-exp-btn-edit">
                                    Edit
                                </a>

                                <form method="post" action="${pageContext.request.contextPath}/expenses/delete"
                                      onsubmit="return confirm('Are you sure you want to delete this expense?');" style="margin: 0;">
                                    <input type="hidden" name="tripId" value="${trip.id}">
                                    <input type="hidden" name="expenseId" value="${expense.id}">
                                    <button type="submit" class="lt-exp-btn-sm lt-exp-btn-del" style="border: 1px solid #fecdd3;">
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
