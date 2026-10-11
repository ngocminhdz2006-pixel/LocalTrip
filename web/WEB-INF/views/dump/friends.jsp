<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Bạn bè" scope="request" />
<c:set var="tripRedesign" value="${true}" scope="request" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · KẾT NỐI BẠN ĐỒNG HÀNH
            </div>

            <h1 class="mb-2">Kết nối bạn bè</h1>

            <p class="text-white mb-0">
                Tìm bạn đồng hành và chia sẻ những trải nghiệm.
                Người đã chấp nhận kết bạn mới xem được
                nhật ký ở chế độ Bạn bè.
            </p>
        </div>

        <a class="rd-back"
           href="${pageContext.request.contextPath}/dump">
            ← Quay lại nhật ký
        </a>
    </div>
</section>

<c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger" role="alert">
        <c:out value="${sessionScope.errorMessage}" />
    </div>
    <c:remove var="errorMessage" scope="session" />
</c:if>

<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success" role="status">
        <c:out value="${sessionScope.successMessage}" />
    </div>
    <c:remove var="successMessage" scope="session" />
</c:if>

<div class="row g-4">
    <div class="col-12 col-lg-7">
        <section class="rd-card">
            <h2 class="h4 mb-2">Tìm bạn đồng hành</h2>

            <p class="text-muted mb-4">
                Nhập tên hoặc email tài khoản LocalTrip.
            </p>

            <form method="get"
                  action="${pageContext.request.contextPath}/dump/friends"
                  class="row g-2">

                <div class="col-12 col-sm">
                    <label for="friendKeyword" class="visually-hidden">
                        Tên hoặc email
                    </label>

                    <input type="search"
                           class="form-control"
                           id="friendKeyword"
                           name="q"
                           minlength="2"
                           value="<c:out value='${keyword}'/>"
                           placeholder="Tên hoặc email, ít nhất 2 ký tự">
                </div>

                <div class="col-12 col-sm-auto">
                    <button class="btn btn-primary w-100"
                            type="submit">
                        Tìm kiếm
                    </button>
                </div>
            </form>

            <c:choose>
                <c:when test="${not empty searchResults}">
                    <div class="border-top mt-4 pt-3">
                        <h3 class="h6 mb-3">Kết quả tìm kiếm</h3>

                        <c:forEach items="${searchResults}" var="person">
                            <div class="d-flex flex-wrap align-items-center
                                        gap-3 border-bottom py-3">

                                <div class="rounded-circle d-flex
                                            align-items-center justify-content-center
                                            flex-shrink-0 text-white"
                                     style="width:44px;height:44px;background:var(--green);">
                                    <c:choose>
                                        <c:when test="${not empty person.fullName}">
                                            <c:out value="${fn:substring(person.fullName, 0, 1)}" />
                                        </c:when>
                                        <c:otherwise>?</c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="flex-grow-1"
                                     style="min-width:0;overflow-wrap:anywhere;">
                                    <strong class="d-block">
                                        <c:out value="${person.fullName}" />
                                    </strong>

                                    <span class="small text-muted">
                                        <c:out value="${person.email}" />
                                    </span>
                                </div>

                                <c:choose>
                                    <c:when test="${person.status eq 'ACCEPTED'}">
                                        <span class="rd-count">Bạn bè</span>
                                    </c:when>

                                    <c:when test="${person.status eq 'PENDING'
                                                  and person.requesterId eq sessionScope.user.userId}">
                                        <span class="rd-role">
                                            Đã gửi lời mời
                                        </span>
                                    </c:when>

                                    <c:when test="${person.status eq 'PENDING'}">
                                        <span class="rd-role rd-role-lead">
                                            Đang chờ bạn xử lý
                                        </span>
                                    </c:when>

                                    <c:otherwise>
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/dump/friends">
                                            <input type="hidden"
                                                   name="csrfToken"
                                                   value="${sessionScope.travelCsrf}">

                                            <input type="hidden"
                                                   name="action"
                                                   value="send">

                                            <input type="hidden"
                                                   name="targetUserId"
                                                   value="${person.userId}">

                                            <button class="btn btn-sm btn-outline-primary"
                                                    type="submit">
                                                + Kết bạn
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>

                <c:when test="${not empty keyword}">
                    <div class="border-top mt-4 pt-4">
                        <p class="text-muted mb-0">
                            Chưa tìm thấy người dùng phù hợp.
                            Hãy thử tên hoặc email khác.
                        </p>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="border-top mt-4 pt-4">
                        <p class="text-muted mb-0">
                            Tìm người dùng để gửi lời mời kết bạn.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <div class="col-12 col-lg-5">
        <section class="rd-card">
            <div class="d-flex justify-content-between
                        align-items-center gap-2 mb-2">
                <h2 class="h4 mb-0">Lời mời kết bạn</h2>

                <span class="rd-count">
                    ${fn:length(friendRequests)}
                </span>
            </div>

            <p class="text-muted mb-4">
                Những người đang muốn kết nối với bạn.
            </p>

            <c:choose>
                <c:when test="${empty friendRequests}">
                    <div class="border-top pt-4">
                        <p class="text-muted mb-0">
                            Bạn chưa có lời mời kết bạn mới.
                        </p>
                    </div>
                </c:when>

                <c:otherwise>
                    <c:forEach items="${friendRequests}" var="friend">
                        <div class="border-top py-3">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="rounded-circle d-flex
                                            align-items-center justify-content-center
                                            flex-shrink-0 text-white"
                                     style="width:44px;height:44px;background:var(--green);">
                                    <c:choose>
                                        <c:when test="${not empty friend.fullName}">
                                            <c:out value="${fn:substring(friend.fullName, 0, 1)}" />
                                        </c:when>
                                        <c:otherwise>?</c:otherwise>
                                    </c:choose>
                                </div>

                                <div style="min-width:0;overflow-wrap:anywhere;">
                                    <strong class="d-block">
                                        <c:out value="${friend.fullName}" />
                                    </strong>

                                    <span class="small text-muted">
                                        <c:out value="${friend.email}" />
                                    </span>
                                </div>
                            </div>

                            <form method="post"
                                  action="${pageContext.request.contextPath}/dump/friends"
                                  class="d-flex flex-wrap gap-2">
                                <input type="hidden"
                                       name="csrfToken"
                                       value="${sessionScope.travelCsrf}">

                                <input type="hidden"
                                       name="friendshipId"
                                       value="${friend.friendshipId}">

                                <button type="submit"
                                        class="btn btn-sm btn-primary"
                                        name="action"
                                        value="accept">
                                    Chấp nhận
                                </button>

                                <button type="submit"
                                        class="btn btn-sm btn-outline-secondary"
                                        name="action"
                                        value="decline">
                                    Từ chối
                                </button>
                            </form>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>