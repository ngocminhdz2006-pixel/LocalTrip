<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<<<<<<< HEAD

<c:choose>
    <c:when test="${not empty expense}">
        <c:set var="pageTitle" value="Chỉnh sửa khoản chi" scope="request"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Thêm Expense" scope="request"/>
    </c:otherwise>
</c:choose>

<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

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
=======
<c:set var="pageTitle" value="Thêm Expense" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="app-card">
            <h4 class="mb-4">Thêm khoản chi cho "${trip.name}"</h4>

            <form method="post" action="${pageContext.request.contextPath}/expenses">
                <input type="hidden" name="tripId" value="${trip.id}">

                <div class="mb-3">
                    <label class="form-label">Mô tả</label>
                    <input type="text" name="description" class="form-control"
                           placeholder="VD: Ăn trưa quán A" required>
>>>>>>> 1f8cf38 (Update UI)
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
<<<<<<< HEAD
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
=======
                        <label class="form-label">Số tiền (đ)</label>
                        <input type="number" name="amount" class="form-control" min="0" step="1000" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Người trả (payer)</label>
                        <select name="payerId" class="form-select" required>
                            <c:forEach var="member" items="${members}">
                                <option value="${member.id}">${member.fullName}</option>
>>>>>>> 1f8cf38 (Update UI)
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label d-flex justify-content-between">
<<<<<<< HEAD
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
=======
                        Người tham gia (chia đều)
                        <span class="form-check form-check-inline">
                            <input type="checkbox" class="form-check-input" id="selectAllParticipants">
                            <label class="form-check-label" for="selectAllParticipants">Chọn tất cả</label>
                        </span>
                    </label>
                    <c:forEach var="member" items="${members}">
                        <div class="form-check">
                            <input class="form-check-input participant-checkbox" type="checkbox"
                                   name="participantIds" value="${member.id}" id="p${member.id}">
                            <label class="form-check-label" for="p${member.id}">${member.fullName}</label>
>>>>>>> 1f8cf38 (Update UI)
                        </div>
                    </c:forEach>
                </div>

<<<<<<< HEAD
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
                        Owner được chọn làm người trả mặc định. Bạn vẫn có thể đổi người trả.
                    </div>
                </div>

                <button type="submit" class="btn btn-brand">
                    <c:choose>
                        <c:when test="${not empty expense}">
                            Lưu thay đổi
                        </c:when>
                        <c:otherwise>
                            Lưu Expense
                        </c:otherwise>
                    </c:choose>
                </button>

                <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}"
                   class="btn btn-outline-secondary">
                    Hủy
                </a>
=======
                <div class="form-check mb-4">
                    <input class="form-check-input" type="checkbox" name="fromGroupFund" value="true" id="fromFund">
                    <label class="form-check-label" for="fromFund">
                        Chi từ quỹ nhóm (bỏ chọn nếu payer tự trả tiền cá nhân)
                    </label>
                </div>

                <button type="submit" class="btn btn-brand">Lưu Expense</button>
                <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}" class="btn btn-outline-secondary">Hủy</a>
>>>>>>> 1f8cf38 (Update UI)
            </form>
        </div>
    </div>
</div>

<<<<<<< HEAD
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
=======
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
>>>>>>> 1f8cf38 (Update UI)
