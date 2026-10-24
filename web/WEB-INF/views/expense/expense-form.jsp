<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:choose>
    <c:when test="${not empty expense}">
        <c:set var="pageTitle" value="Edit expense" scope="request"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Add expense" scope="request"/>
    </c:otherwise>
</c:choose>

<c:set var="currentTrip" value="${trip}" scope="request"/>

<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="app-card p-4" style="border-radius: 16px;">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="mb-0 fw-bold" style="color: #143b2d;">
                    <c:choose>
                        <c:when test="${not empty expense}">
                            Edit Expense
                        </c:when>
                        <c:otherwise>
                            Add New Expense
                        </c:otherwise>
                    </c:choose>
                </h4>
                <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
                   class="btn btn-outline-secondary btn-sm">
                    ← Back to expenses
                </a>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger mb-3">
                    <c:out value="${error}"/>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/expenses">
                <input type="hidden" name="travelCsrf" value="${sessionScope.travelCsrf}"/>
                <input type="hidden" name="tripId" value="${trip.id}">

                <c:if test="${not empty expense}">
                    <input type="hidden" name="expenseId" value="${expense.id}">
                </c:if>

                <div class="mb-3">
                    <label for="description" class="form-label fw-semibold">
                        Description / Title
                    </label>

                    <input type="text"
                           id="description"
                           name="description"
                           maxlength="200"
                           class="form-control"
                           value="<c:out value='${expense.description}'/>"
                           placeholder="e.g. Lunch at Bến Thành Market, Grab transport, Tickets..."
                           required>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="amount" class="form-label fw-semibold">
                            Amount (VND)
                        </label>

                        <input type="number"
                               id="amount"
                               name="amount"
                               class="form-control"
                               min="1"
                               step="1000"
                               value="${expense.amount}"
                               placeholder="e.g. 150000"
                               required>
                    </div>

                    <div class="col-md-6">
                        <label id="payerLabel" for="payerId" class="form-label fw-semibold">
                            Paid by
                        </label>

                        <select id="payerId"
                                name="payerId"
                                class="form-select"
                                required>

                            <c:forEach var="member" items="${members}">
                                <option value="${member.id}"
                                        data-owner="${member.role == 'OWNER'}"
                                        <c:if test="${(not empty expense
                                                      and expense.payerId == member.id)
                                                      or (empty expense
                                                      and member.role == 'OWNER')}">
                                              selected
                                        </c:if>>
                                    <c:out value="${member.fullName}"/>
                                    <c:if test="${member.role == 'OWNER'}"> (Trip Lead)</c:if>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="mb-4 p-3" style="background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 14px;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2">
                        <label class="form-label fw-bold mb-0 text-dark">
                            Split Among Members
                        </label>

                        <div class="d-flex align-items-center gap-2">
                            <span id="perMemberShareBadge" class="badge" style="background: #e8f4ec; color: #175b43; border: 1px solid #86c19a; font-size: 12px; font-weight: 700; padding: 4px 10px; border-radius: 8px;">
                                0 VND / person
                            </span>

                            <div class="form-check form-check-inline mb-0 ms-2">
                                <input type="checkbox"
                                       class="form-check-input"
                                       id="selectAllParticipants">
                                <label class="form-check-label small text-muted" for="selectAllParticipants">
                                    Select all
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="row g-2 mt-1">
                        <c:forEach var="member" items="${members}">
                            <div class="col-12 col-sm-6">
                                <div class="form-check p-2 ps-4" style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 10px;">
                                    <input class="form-check-input participant-checkbox"
                                           type="checkbox"
                                           name="participantIds"
                                           value="${member.id}"
                                           id="p${member.id}"
                                           <c:if test="${empty expense || (not empty participantIds and participantIds.contains(member.id))}">
                                                 checked
                                           </c:if>>

                                    <label class="form-check-label small fw-semibold" for="p${member.id}">
                                        <c:out value="${member.fullName}"/>
                                    </label>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="p-3 mb-4" style="background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 14px;">
                    <div class="form-check mb-0">
                        <input class="form-check-input"
                               type="checkbox"
                               name="fromGroupFund"
                               value="true"
                               id="fromFund"
                               <c:if test="${expense.fromGroupFund}">
                                   checked
                               </c:if>>

                        <label class="form-check-label fw-bold" for="fromFund" style="color: #065f46;">
                            🏦 Paid from Group Fund cash pool
                        </label>
                    </div>

                    <div class="small text-muted ms-4 mt-1">
                        Check this if the expense was paid directly from the shared group fund instead of a personal account.
                    </div>
                </div>

                <div class="d-flex flex-wrap gap-2">
                    <button type="submit" class="btn btn-primary px-4" style="background-color: #175b43; border-color: #175b43;">
                        <c:choose>
                            <c:when test="${not empty expense}">
                                Save changes
                            </c:when>
                            <c:otherwise>
                                Save expense
                            </c:otherwise>
                        </c:choose>
                    </button>

                    <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
                       class="btn btn-outline-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        const amountInput = document.getElementById('amount');
        const checkboxes = document.querySelectorAll('.participant-checkbox');
        const selectAll = document.getElementById('selectAllParticipants');
        const badge = document.getElementById('perMemberShareBadge');

        function updateShare() {
            const amount = parseFloat(amountInput.value) || 0;
            const checkedBoxes = document.querySelectorAll('.participant-checkbox:checked');
            const count = checkedBoxes.length;

            if (count > 0 && amount > 0) {
                const perPerson = Math.round(amount / count);
                const formatted = new Intl.NumberFormat('en-US').format(perPerson);
                badge.textContent = formatted + ' VND / person (' + count + ' selected)';
                badge.style.color = '#175b43';
                badge.style.background = '#e8f4ec';
                badge.style.borderColor = '#86c19a';
            } else if (count === 0) {
                badge.textContent = 'Please select at least 1 person';
                badge.style.color = '#b45309';
                badge.style.background = '#fef3c7';
                badge.style.borderColor = '#fde68a';
            } else {
                badge.textContent = '0 VND / person (' + count + ' selected)';
                badge.style.color = '#64748b';
                badge.style.background = '#f1f5f9';
                badge.style.borderColor = '#cbd5e1';
            }
        }

        if (amountInput) {
            amountInput.addEventListener('input', updateShare);
        }

        checkboxes.forEach(function (cb) {
            cb.addEventListener('change', updateShare);
        });

        if (selectAll) {
            selectAll.addEventListener('change', function () {
                checkboxes.forEach(function (cb) {
                    cb.checked = selectAll.checked;
                });
                updateShare();
            });
        }

        updateShare();
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
