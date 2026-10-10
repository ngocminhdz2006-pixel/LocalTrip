<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:choose>
    <c:when test="${not empty expense}">
        <c:set var="pageTitle" value="Chỉnh sửa khoản chi" scope="request"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Thêm khoản chi" scope="request"/>
    </c:otherwise>
</c:choose>

<c:set var="currentTrip" value="${trip}" scope="request"/>

<fmt:setLocale value="vi_VN" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<style>
    .rd-expense-form {
        max-width: 860px;
        margin: 0 auto;
    }

    .rd-expense-form-heading {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
    }

    .rd-expense-form-heading h2 {
        margin: 0 0 8px;
        color: var(--ink);
        font-size: 24px;
        font-weight: 700;
    }

    .rd-expense-form .form-label {
        color: var(--ink);
        font-weight: 600;
    }

    .rd-expense-form .form-control,
    .rd-expense-form .form-select {
        min-height: 46px;
        border-radius: 10px;
    }

    .rd-expense-participants {
        padding: 20px;
        margin-bottom: 24px;
        background: #F6F9F7;
        border: 1px solid var(--line);
        border-radius: 14px;
    }

    .rd-expense-participant-heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
        margin-bottom: 16px;
    }

    .rd-expense-participant-heading h3 {
        margin: 0;
        color: var(--ink);
        font-size: 16px;
        font-weight: 600;
    }

    .rd-expense-participant-list {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px;
    }

    .rd-expense-participant-list .form-check {
        margin: 0;
        padding: 12px 14px 12px 38px;
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 10px;
        overflow-wrap: anywhere;
    }

    .rd-expense-form .group-fund-option {
        padding: 18px 20px;
        background: var(--mint);
        border: 1px solid var(--line);
        border-radius: 14px;
    }

    .rd-expense-form-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        padding-top: 20px;
        border-top: 1px solid var(--line);
    }

    @media (max-width: 600px) {
        .rd-expense-form-heading h2 {
            font-size: 21px;
        }

        .rd-expense-participant-list {
            grid-template-columns: 1fr;
        }

        .rd-expense-form-actions .btn {
            width: 100%;
        }
    }
</style>

<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="app-card">

            <h4 class="mb-4">
                <c:choose>
                    <c:when test="${not empty expense}">
                        Chỉnh sửa khoản chi
                    </c:when>
                    <c:otherwise>
                        Thêm khoản chi
                    </c:otherwise>
                </c:choose>
                cho "<c:out value="${trip.name}"/>"
            </h4>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <c:out value="${error}"/>
                </div>
            </c:if>

            <form method="post"
                  action="${pageContext.request.contextPath}/expenses">

                <input type="hidden"
                       name="tripId"
                       value="${trip.id}">

                <c:if test="${not empty expense}">
                    <input type="hidden"
                           name="expenseId"
                           value="${expense.id}">
                </c:if>

                <div class="mb-3">
                    <label for="description" class="form-label">
                        Mô tả
                    </label>

                    <input type="text"
                           id="description"
                           name="description"
                           maxlength="200"
                           class="form-control"
                           value="<c:out value='${expense.description}'/>"
                           placeholder="VD: Ăn trưa quán A"
                           required>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="amount" class="form-label">
                            Số tiền (đ)
                        </label>

                        <input type="number"
                               id="amount"
                               name="amount"
                               class="form-control"
                               min="1"
                               step="1"
                               value="${expense.amount}"
                               required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label id="payerLabel" for="payerId" class="form-label">
                            Người trả
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
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label d-flex justify-content-between">
                        Người tham gia chia đều

                        <span class="form-check form-check-inline">
                            <input type="checkbox"
                                   class="form-check-input"
                                   id="selectAllParticipants">

                            <label class="form-check-label"
                                   for="selectAllParticipants">
                                Chọn tất cả
                            </label>
                        </span>
                    </label>

                    <c:forEach var="member" items="${members}">
                        <div class="form-check">
                            <input class="form-check-input participant-checkbox"
                                   type="checkbox"
                                   name="participantIds"
                                   value="${member.id}"
                                   id="p${member.id}"
                                   <c:if test="${not empty participantIds
                                                 and participantIds.contains(member.id)}">
                                         checked
                                   </c:if>>

                            <label class="form-check-label"
                                   for="p${member.id}">
                                <c:out value="${member.fullName}"/>
                            </label>
                        </div>
                    </c:forEach>
                </div>

                <div class="group-fund-option mb-4">
                    <div class="form-check">
                        <input class="form-check-input"
                               type="checkbox"
                               name="fromGroupFund"
                               value="true"
                               id="fromFund"
                               <c:if test="${expense.fromGroupFund}">
                                   checked
                               </c:if>>

                        <label class="form-check-label fw-bold" for="fromFund">
                            Chi từ quỹ nhóm
                        </label>
                    </div>

                    <div class="small text-muted ms-4 mt-1">
                        Trưởng nhóm được chọn làm người trả mặc định. Bạn vẫn có thể đổi người trả.
                    </div>
                </div>

                <button type="submit" class="btn btn-brand">
                    <c:choose>
                        <c:when test="${not empty expense}">
                            Lưu thay đổi
                        </c:when>
                        <c:otherwise>
                            Lưu khoản chi
                        </c:otherwise>
                    </c:choose>
                </button>

                <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
                   class="btn btn-outline-secondary">
                    Hủy
                </a>
            </form>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>