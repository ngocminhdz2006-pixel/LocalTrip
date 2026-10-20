<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<fmt:setLocale value="vi_VN"/>

<c:set var="pageTitle" value="Expense Settlement" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<div class="lt-settle-page" style="max-width: 680px; margin: 0 auto; padding-bottom: 24px;">

    <%-- 1. Header & Navigation Back --%>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px;">
        <div>
            <h2 style="font-size: 16px; font-weight: 700; color: #143b2d; margin: 0;">Balances & Settlement</h2>
            <p style="font-size: 11px; color: #64748b; margin: 2px 0 0;">Net balance = Paid − Share owed</p>
        </div>
        <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
           class="lt-exp-btn-sm lt-exp-btn-edit" style="display: inline-flex; align-items: center; gap: 4px;">
            ← View expenses
        </a>
    </div>

    <%-- 2. Quy ước màu sắc gọn gàng dạng Chips --%>
    <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 6px; margin-bottom: 14px;">
        <div style="background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 12px; padding: 8px 10px; text-align: center;">
            <strong style="color: #047857; font-size: 11px; display: block;">+ Positive</strong>
            <span style="font-size: 9px; color: #065f46;">To receive</span>
        </div>
        <div style="background: #fff1f2; border: 1px solid #fecdd3; border-radius: 12px; padding: 8px 10px; text-align: center;">
            <strong style="color: #e11d48; font-size: 11px; display: block;">− Negative</strong>
            <span style="font-size: 9px; color: #9f1239;">To pay</span>
        </div>
        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 8px 10px; text-align: center;">
            <strong style="color: #475569; font-size: 11px; display: block;">0 VND</strong>
            <span style="font-size: 9px; color: #64748b;">Balanced</span>
        </div>
    </div>

    <%-- 3. Chi phí từng thành viên dạng Cards --%>
    <div style="margin-bottom: 18px;">
        <h3 style="font-size: 13px; font-weight: 700; color: #143b2d; margin: 0 0 10px;">
            Member Balances (${fn:length(balances)})
        </h3>

        <c:choose>
            <c:when test="${empty balances}">
                <div style="background: #ffffff; border: 1px dashed #cbd5e1; border-radius: 14px; padding: 20px; text-align: center;">
                    <p style="font-size: 12px; color: #64748b; margin: 0;">No expense data available to calculate settlement.</p>
                </div>
            </c:when>

            <c:otherwise>
                <div class="lt-settle-balance-list">
                    <c:forEach var="b" items="${balances}">
                        <div class="lt-settle-card">
                            <div class="lt-settle-member-wrap">
                                <div class="lt-settle-avatar">
                                    <c:out value="${fn:substring(b.memberName, 0, 1)}"/>
                                </div>
                                <div>
                                    <h4 class="lt-settle-member-name"><c:out value="${b.memberName}"/></h4>
                                    <p class="lt-settle-sub">
                                        Paid: <fmt:formatNumber value="${b.paid}" type="number" maxFractionDigits="0"/> VND 
                                        • Owed: <fmt:formatNumber value="${b.owed}" type="number" maxFractionDigits="0"/> VND
                                    </p>
                                </div>
                            </div>

                            <div class="lt-settle-amount-tag ${b.balance > 0 ? 'positive' : (b.balance < 0 ? 'negative' : 'zero')}">
                                <span style="font-size: 13px; font-weight: 800; display: block;">
                                    <c:choose>
                                        <c:when test="${b.balance > 0}">
                                            +<fmt:formatNumber value="${b.balance}" type="number" maxFractionDigits="0"/> VND
                                        </c:when>
                                        <c:when test="${b.balance < 0}">
                                            <fmt:formatNumber value="${b.balance}" type="number" maxFractionDigits="0"/> VND
                                        </c:when>
                                        <c:otherwise>0 VND</c:otherwise>
                                    </c:choose>
                                </span>
                                <span style="font-size: 9px; font-weight: 600;">
                                    <c:choose>
                                        <c:when test="${b.balance > 0}">Receives</c:when>
                                        <c:when test="${b.balance < 0}">Owes</c:when>
                                        <c:otherwise>Settled</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- 4. Gợi ý chuyển khoản tối ưu (Transfer Suggestions) --%>
    <div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;">
            <h3 style="font-size: 13px; font-weight: 700; color: #143b2d; margin: 0;">
                Optimal Transfer Suggestions (${fn:length(transfers)})
            </h3>
            <span style="font-size: 10px; color: #047857; font-weight: 600;">Minimum-transaction algorithm</span>
        </div>

        <c:choose>
            <c:when test="${empty transfers}">
                <div style="background: #ffffff; border: 1px dashed #cbd5e1; border-radius: 14px; padding: 20px; text-align: center;">
                    <p style="font-size: 12px; color: #64748b; margin: 0;">All balances are settled! No transfers needed.</p>
                </div>
            </c:when>

            <c:otherwise>
                <div class="lt-settle-transfer-list">
                    <c:forEach var="t" items="${transfers}">
                        <div class="lt-settle-transfer-item">
                            <div style="font-size: 12px; color: #1e293b;">
                                <strong style="color: #0f172a;"><c:out value="${t.fromMemberName}"/></strong>
                                <span class="lt-settle-transfer-arrow">➔ pays ➔</span>
                                <strong style="color: #175b43;"><c:out value="${t.toMemberName}"/></strong>
                            </div>

                            <strong style="font-size: 13px; font-weight: 800; color: #175b43;">
                                <fmt:formatNumber value="${t.amount}" type="number" maxFractionDigits="0"/> VND
                            </strong>
                        </div>
                    </c:forEach>
                </div>

                <p style="font-size: 10px; color: #64748b; margin-top: 10px; text-align: center;">
                    💡 These are automated net transfers. Members can settle directly via bank transfer or e-wallet.
                </p>
            </c:otherwise>
        </c:choose>
    </div>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
