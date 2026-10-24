<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<fmt:setLocale value="en_US" scope="page"/>

<c:set var="pageTitle" value="Expense Settlement" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<div class="lt-settle-page" style="max-width: 720px; margin: 0 auto; padding-bottom: 24px;">

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

    <%-- 1. Header & Navigation Back --%>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px;">
        <div>
            <h2 style="font-size: 18px; font-weight: 700; color: #143b2d; margin: 0;">Balances & 2-Way Settlement</h2>
            <p style="font-size: 12px; color: #64748b; margin: 2px 0 0;">Net balance = Paid − Share owed · Two-way verification</p>
        </div>
        <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
           class="lt-exp-btn-sm lt-exp-btn-edit" style="display: inline-flex; align-items: center; gap: 4px;">
            ← View expenses
        </a>
    </div>

    <%-- 2. Quy ước màu sắc dạng Chips --%>
    <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; margin-bottom: 16px;">
        <div style="background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 12px; padding: 10px; text-align: center;">
            <strong style="color: #047857; font-size: 12px; display: block;">+ Positive</strong>
            <span style="font-size: 11px; color: #065f46;">To receive</span>
        </div>
        <div style="background: #fff1f2; border: 1px solid #fecdd3; border-radius: 12px; padding: 10px; text-align: center;">
            <strong style="color: #e11d48; font-size: 12px; display: block;">− Negative</strong>
            <span style="font-size: 11px; color: #9f1239;">To pay</span>
        </div>
        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 10px; text-align: center;">
            <strong style="color: #475569; font-size: 12px; display: block;">0 VND</strong>
            <span style="font-size: 11px; color: #64748b;">Balanced</span>
        </div>
    </div>

    <%-- 3. Chi phí từng thành viên dạng Cards --%>
    <div style="margin-bottom: 20px;">
        <h3 style="font-size: 14px; font-weight: 700; color: #143b2d; margin: 0 0 10px;">
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
                                <span style="font-size: 10px; font-weight: 600;">
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

    <%-- 4. Gợi ý chuyển khoản tối ưu (Transfer Suggestions with 2-Way Settlement Confirmation) --%>
    <div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;">
            <h3 style="font-size: 14px; font-weight: 700; color: #143b2d; margin: 0;">
                Optimal Transfers & Status (${fn:length(transfers)})
            </h3>
            <span style="font-size: 11px; color: #047857; font-weight: 600;">2-Way Verified</span>
        </div>

        <c:choose>
            <c:when test="${empty transfers}">
                <div style="background: #ffffff; border: 1px dashed #cbd5e1; border-radius: 14px; padding: 24px; text-align: center;">
                    <span style="font-size: 28px;">🎉</span>
                    <h5 class="fw-bold mt-2 mb-1" style="color: #143b2d;">All balances are settled!</h5>
                    <p style="font-size: 12px; color: #64748b; margin: 0;">No outstanding transfers needed for this trip.</p>
                </div>
            </c:when>

            <c:otherwise>
                <div class="lt-settle-transfer-list">
                    <c:forEach var="t" items="${transfers}">
                        <div class="lt-settle-transfer-item p-3 mb-2" style="background: #ffffff; border: 1.5px solid #e2e8f0; border-radius: 14px; display: flex; flex-direction: column; gap: 8px;">
                            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                                <div style="font-size: 13px; color: #1e293b;">
                                    <strong style="color: #0f172a;"><c:out value="${t.fromMemberName}"/></strong>
                                    <span class="lt-settle-transfer-arrow" style="color: #64748b; margin: 0 4px;">➔ owes ➔</span>
                                    <strong style="color: #175b43;"><c:out value="${t.toMemberName}"/></strong>
                                </div>

                                <strong style="font-size: 14px; font-weight: 800; color: #175b43;">
                                    <fmt:formatNumber value="${t.amount}" type="number" maxFractionDigits="0"/> VND
                                </strong>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; border-top: 1px solid #f1f5f9; padding-top: 8px;">
                                <div>
                                    <c:choose>
                                        <c:when test="${t.status == 'CONFIRMED'}">
                                            <span class="badge" style="background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; font-size: 11px; padding: 5px 9px;">
                                                ✓ CONFIRMED
                                            </span>
                                        </c:when>
                                        <c:when test="${t.status == 'SENT'}">
                                            <span class="badge" style="background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; font-size: 11px; padding: 5px 9px;">
                                                ⏳ SENT (Awaiting Recipient)
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge" style="background: #fef3c7; color: #b45309; border: 1px solid #fde68a; font-size: 11px; padding: 5px 9px;">
                                                PROPOSED
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div style="display: flex; align-items: center; gap: 6px; flex-wrap: wrap;">
                                    <button type="button" class="lt-btn-vietqr"
                                            onclick="openVietQrModal('<c:out value="${t.fromMemberName}" escapeXml="true"/>', '<c:out value="${t.toMemberName}" escapeXml="true"/>', ${t.amount})">
                                        📲 VietQR
                                    </button>

                                    <%-- Payer action: Mark Sent --%>
                                    <c:if test="${(sessionScope.user.userId == t.fromMemberId || trip.role == 'OWNER') && t.status == 'PENDING'}">
                                        <form method="post" action="${pageContext.request.contextPath}/settlement" style="margin: 0;">
                                            <input type="hidden" name="tripId" value="${trip.id}"/>
                                            <input type="hidden" name="paymentId" value="${t.paymentId}"/>
                                            <input type="hidden" name="action" value="markSent"/>
                                            <button type="submit" class="btn btn-sm btn-outline-primary" style="font-size: 11px; font-weight: 600; padding: 4px 10px; border-radius: 8px;">
                                                ✓ I Have Paid
                                            </button>
                                        </form>
                                    </c:if>

                                    <%-- Recipient or Owner action: Confirm Received --%>
                                    <c:if test="${(sessionScope.user.userId == t.toMemberId || trip.role == 'OWNER') && (t.status == 'SENT' || t.status == 'PENDING')}">
                                        <form method="post" action="${pageContext.request.contextPath}/settlement" style="margin: 0;">
                                            <input type="hidden" name="tripId" value="${trip.id}"/>
                                            <input type="hidden" name="paymentId" value="${t.paymentId}"/>
                                            <input type="hidden" name="action" value="confirmReceived"/>
                                            <button type="submit" class="btn btn-sm btn-success" style="font-size: 11px; font-weight: 600; padding: 4px 10px; border-radius: 8px; background-color: #175b43; border-color: #175b43;">
                                                ✓ Confirm Received
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <p style="font-size: 11px; color: #64748b; margin-top: 12px; text-align: center;">
                    💡 Two-way settlement: Debtor clicks <strong>"✓ I Have Paid"</strong> after transferring, and the recipient confirms with <strong>"✓ Confirm Received"</strong>.
                </p>
            </c:otherwise>
        </c:choose>
    </div>

</div>

<%-- Dynamic VietQR Payment Modal --%>
<div id="vietQrModal" class="lt-modal-backdrop" onclick="closeVietQrModal(event)">
    <div class="lt-modal-card" onclick="event.stopPropagation()" style="max-width: 380px; text-align: center;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
            <div style="display: flex; align-items: center; gap: 6px;">
                <span style="font-size: 18px;">📲</span>
                <h3 style="font-size: 15px; font-weight: 800; color: #143b2d; margin: 0;">VietQR Instant Pay</h3>
            </div>
            <button type="button" onclick="document.getElementById('vietQrModal').style.display='none'"
                    style="background: none; border: none; font-size: 18px; color: #64748b; cursor: pointer;">✕</button>
        </div>
        <p style="font-size: 11px; color: #64748b; margin: 0 0 14px;">Scan with Vietcombank, MB, Techcombank or any Banking App</p>

        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 10px; margin-bottom: 12px; font-size: 12px; text-align: left;">
            <div style="margin-bottom: 4px;"><strong>Payer:</strong> <span id="vqrFrom"></span></div>
            <div style="margin-bottom: 4px;"><strong>Recipient:</strong> <span id="vqrTo" style="color: #175b43; font-weight: 700;"></span></div>
            <div style="margin-bottom: 4px;"><strong>Amount:</strong> <span id="vqrAmount" style="color: #e11d48; font-weight: 800;"></span></div>
            <div><strong>Transfer Note:</strong> <span id="vqrNote" style="color: #64748b; font-size: 11px;"></span></div>
        </div>

        <div style="display: flex; justify-content: center; margin-bottom: 14px;">
            <img id="vqrImage" src="" alt="VietQR Payment Code"
                 style="width: 220px; height: 220px; border-radius: 12px; border: 1.5px solid #dce7df; display: block; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
        </div>

        <button type="button" class="lt-btn-action-secondary" style="width: 100%; border-radius: 12px; font-size: 12px; padding: 10px;"
                onclick="document.getElementById('vietQrModal').style.display='none'">
            Close
        </button>
    </div>
</div>

<style>
    .lt-btn-vietqr {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px 10px;
        background: #ecfdf5;
        border: 1px solid #10b981;
        border-radius: 8px;
        color: #047857;
        font-size: 11px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .lt-btn-vietqr:hover {
        background: #175b43;
        color: #ffffff;
    }
    .lt-modal-backdrop {
        display: none;
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(15, 23, 42, 0.6);
        z-index: 9999;
        align-items: center;
        justify-content: center;
        padding: 16px;
    }
    .lt-modal-card {
        background: #ffffff;
        border-radius: 16px;
        padding: 20px;
        width: 100%;
        box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    }
</style>

<script>
    function openVietQrModal(fromName, toName, amount) {
        document.getElementById('vqrFrom').innerText = fromName;
        document.getElementById('vqrTo').innerText = toName;
        document.getElementById('vqrAmount').innerText = new Intl.NumberFormat('vi-VN').format(amount) + ' VND';
        const note = 'LocalTrip Trip ${trip.id} Settle';
        document.getElementById('vqrNote').innerText = note;

        const qrUrl = 'https://img.vietqr.io/image/970436-102870123456-compact2.png?amount=' + amount + '&addInfo=' + encodeURIComponent(note);
        document.getElementById('vqrImage').src = qrUrl;
        document.getElementById('vietQrModal').style.display = 'flex';
    }

    function closeVietQrModal(e) {
        if (e.target.id === 'vietQrModal') {
            e.target.style.display = 'none';
        }
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
