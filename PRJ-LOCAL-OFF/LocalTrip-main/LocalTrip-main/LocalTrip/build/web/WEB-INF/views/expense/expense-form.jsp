<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Số tiền (đ)</label>
                        <input type="number" name="amount" class="form-control" min="0" step="1000" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Người trả (payer)</label>
                        <select name="payerId" class="form-select" required>
                            <c:forEach var="member" items="${members}">
                                <option value="${member.id}">${member.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label d-flex justify-content-between">
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
                        </div>
                    </c:forEach>
                </div>

                <div class="form-check mb-4">
                    <input class="form-check-input" type="checkbox" name="fromGroupFund" value="true" id="fromFund">
                    <label class="form-check-label" for="fromFund">
                        Chi từ quỹ nhóm (bỏ chọn nếu payer tự trả tiền cá nhân)
                    </label>
                </div>

                <button type="submit" class="btn btn-brand">Lưu Expense</button>
                <a href="${pageContext.request.contextPath}/expenses?tripId=${trip.id}" class="btn btn-outline-secondary">Hủy</a>
            </form>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
