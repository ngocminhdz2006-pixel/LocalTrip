<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chi tiết chuyến đi" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="app-card">
    <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
        <div>
            <h3 class="mb-2">
                <c:out value="${trip.name}"/>
            </h3>

            <p class="text-muted mb-2">
                <strong>Khu vực:</strong>
                <c:out value="${trip.area}"/>
            </p>

            <p class="text-muted mb-2">
                <strong>Thời gian:</strong>
                <fmt:formatDate value="${trip.startDate}"
                                pattern="dd/MM/yyyy"/>
                –
                <fmt:formatDate value="${trip.endDate}"
                                pattern="dd/MM/yyyy"/>
            </p>

            <p class="text-muted mb-3">
                <strong>Ngân sách:</strong>
                <fmt:formatNumber value="${trip.budget}"
                                  type="number"
                                  maxFractionDigits="2"/>
                đ
            </p>

            <c:choose>
                <c:when test="${trip.status == 'PLANNING'}">
                    <span class="badge text-bg-secondary">
                        Đang lên kế hoạch
                    </span>
                </c:when>
                <c:when test="${trip.status == 'ONGOING'}">
                    <span class="badge text-bg-primary">
                        Đang diễn ra
                    </span>
                </c:when>
                <c:when test="${trip.status == 'COMPLETED'}">
                    <span class="badge text-bg-success">
                        Đã hoàn thành
                    </span>
                </c:when>
                <c:when test="${trip.status == 'CANCELLED'}">
                    <span class="badge text-bg-danger">
                        Đã hủy
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="badge text-bg-secondary">
                        Chưa xác định
                    </span>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="d-flex align-items-center flex-wrap gap-2">
            <c:choose>
                <c:when test="${trip.role == 'OWNER'}">
                    <span class="badge badge-owner">
                        Trưởng nhóm
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="badge badge-member">
                        Thành viên
                    </span>
                </c:otherwise>
            </c:choose>

            <a href="${pageContext.request.contextPath}/trips"
               class="btn btn-outline-secondary btn-sm">
                Danh sách chuyến đi
            </a>

        </div>
    </div>
</div>

<div class="row g-4">
    <div class="col-lg-8">
        <div class="app-card">
            <h5 class="mb-2">Thành viên chuyến đi</h5>

            <p class="text-muted small mb-3">
                Các thành viên cùng tham gia lên kế hoạch và chia sẻ chi phí.
            </p>

            <c:choose>
                <c:when test="${empty members}">
                    <p class="text-muted mb-0">
                        Chưa có thông tin thành viên.
                    </p>
                </c:when>

                <c:otherwise>
                    <ul class="list-group list-group-flush">
                        <c:forEach var="member" items="${members}">
                            <li class="list-group-item px-0 py-3">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                                    <div style="min-width: 0;">
                                        <div class="fw-semibold">
                                            <c:out value="${member.fullName}"/>
                                        </div>

                                        <div class="text-muted small"
                                             style="overflow-wrap: anywhere;">
                                            <c:out value="${member.email}"/>
                                        </div>
                                    </div>

                                    <div class="d-flex align-items-center gap-2">
                                        <c:choose>
                                            <c:when test="${member.role == 'OWNER'}">
                                                <span class="badge badge-owner">
                                                    Trưởng nhóm
                                                </span>
                                            </c:when>

                                            <c:otherwise>
                                                <span class="badge badge-member">
                                                    Thành viên
                                                </span>

                                                <c:if test="${trip.role == 'OWNER'}">
                                                    <form method="post"
                                                          action="${pageContext.request.contextPath}/trip/member/remove"
                                                          onsubmit="return confirm('Xóa thành viên này khỏi chuyến đi?');">
                                                        <input type="hidden"
                                                               name="tripId"
                                                               value="${trip.id}">

                                                        <input type="hidden"
                                                               name="userId"
                                                               value="${member.userId}">

                                                        <button type="submit"
                                                                class="btn btn-outline-danger btn-sm">
                                                            Xóa
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </li>
                        </c:forEach>
                    </ul>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="col-lg-4">
        <c:choose>
            <c:when test="${trip.role == 'OWNER'}">
                <div class="app-card">
                    <h5 class="mb-2">Quản lý chuyến đi</h5>

                    <p class="text-muted small mb-3">
                        Cập nhật tên, thời gian, khu vực và ngân sách.
                    </p>

                    <c:choose>
                        <c:when test="${trip.status == 'PLANNING'
                                        or trip.status == 'ONGOING'}">
                                <a href="${pageContext.request.contextPath}/trip/edit?tripId=${trip.id}"
                                   class="btn btn-outline-primary w-100">
                                    Sửa thông tin chuyến đi
                                </a>
                        </c:when>

                        <c:otherwise>
                            <div class="alert alert-info mb-0">
                                Chuyến đi đã hoàn thành hoặc đã hủy.
                                Thông tin chuyến đi được giữ lại để xem.
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <%
                        if (session.getAttribute("tripStatusToken") == null) {
                            session.setAttribute(
                                    "tripStatusToken",
                                    java.util.UUID.randomUUID().toString()
                            );
                        }
                    %>

                    <div class="d-grid gap-2 mt-3">
                        <c:if test="${trip.status == 'PLANNING'}">
                            <form method="post"
                                  action="${pageContext.request.contextPath}/trip/status"
                                  onsubmit="return confirm('Xác nhận lịch trình hiện tại và bắt đầu chuyến đi?');">

                                <input type="hidden"
                                       name="tripId"
                                       value="${trip.id}">

                                <input type="hidden"
                                       name="status"
                                       value="ONGOING">

                                <input type="hidden"
                                       name="statusToken"
                                       value="${sessionScope.tripStatusToken}">

                                <button type="submit" class="btn btn-brand w-100">
                                    Bắt đầu chuyến đi
                                </button>
                            </form>
                        </c:if>

                        <c:if test="${trip.status == 'ONGOING'}">
                            <form method="post"
                                  action="${pageContext.request.contextPath}/trip/status"
                                  onsubmit="return confirm('Đánh dấu chuyến đi đã hoàn thành?');">

                                <input type="hidden"
                                       name="tripId"
                                       value="${trip.id}">

                                <input type="hidden"
                                       name="status"
                                       value="COMPLETED">

                                <input type="hidden"
                                       name="statusToken"
                                       value="${sessionScope.tripStatusToken}">

                                <button type="submit" class="btn btn-success w-100">
                                    Hoàn thành chuyến đi
                                </button>
                            </form>
                        </c:if>

                        <c:if test="${trip.status == 'PLANNING'
                                      or trip.status == 'ONGOING'}">
                              <form method="post"
                                    action="${pageContext.request.contextPath}/trip/status"
                                    onsubmit="return confirm('Hủy chuyến đi này? Dữ liệu hiện có vẫn được giữ lại.');">

                                  <input type="hidden"
                                         name="tripId"
                                         value="${trip.id}">

                                  <input type="hidden"
                                         name="status"
                                         value="CANCELLED">

                                  <input type="hidden"
                                         name="statusToken"
                                         value="${sessionScope.tripStatusToken}">

                                  <button type="submit"
                                          class="btn btn-outline-danger w-100">
                                      Hủy chuyến đi
                                  </button>
                              </form>
                        </c:if>
                        <%
                            if (session.getAttribute("tripDeleteToken") == null) {
                                session.setAttribute(
                                        "tripDeleteToken",
                                        java.util.UUID.randomUUID().toString()
                                );
                            }
                        %>

                        <c:if test="${trip.role == 'OWNER'
                                      and trip.status == 'PLANNING'}">
                              <div class="border-top pt-3 mt-3">
                                  <p class="text-muted small">
                                      Chỉ xóa được chuyến đang lên kế hoạch,
                                      chưa có chi phí hoặc tiền đóng quỹ.
                                      Lịch trình và sở thích của chuyến đi cũng sẽ bị xóa.
                                  </p>

                                  <form method="post"
                                        action="${pageContext.request.contextPath}/trip/delete"
                                        onsubmit="return confirm('Xóa vĩnh viễn chuyến đi, lịch trình và sở thích của các thành viên?');">

                                      <input type="hidden"
                                             name="tripId"
                                             value="${trip.id}">

                                      <input type="hidden"
                                             name="deleteToken"
                                             value="${sessionScope.tripDeleteToken}">

                                      <button type="submit"
                                              class="btn btn-outline-danger w-100">
                                          Xóa chuyến đi
                                      </button>
                                  </form>
                              </div>
                        </c:if>
                    </div>
                </div>

                <div class="app-card">
                    <h5 class="mb-2">Thêm thành viên</h5>

                    <p class="text-muted small mb-3">
                        Nhập email của người đã có tài khoản LocalTrip.
                    </p>

                    <form method="post"
                          action="${pageContext.request.contextPath}/trip/member/add">
                        <input type="hidden"
                               name="tripId"
                               value="${trip.id}">

                        <div class="mb-3">
                            <label for="memberEmail" class="form-label">
                                Email thành viên
                            </label>

                            <input id="memberEmail"
                                   type="email"
                                   name="email"
                                   class="form-control"
                                   maxlength="150"
                                   placeholder="ban@example.com"
                                   autocomplete="email"
                                   required>
                        </div>

                        <button type="submit" class="btn btn-brand w-100">
                            Thêm thành viên
                        </button>
                    </form>
                </div>
            </c:when>

            <c:otherwise>
                <div class="app-card">
                    <h5 class="mb-2">Vai trò của bạn</h5>

                    <p class="text-muted mb-0">
                        Bạn tham gia với vai trò thành viên.
                        Bạn có thể khai báo sở thích và xem kế hoạch
                        của chuyến đi. Trưởng nhóm quản lý thông tin,
                        thành viên và lịch trình.
                    </p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>