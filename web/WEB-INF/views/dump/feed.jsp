<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Nhật ký - Cộng đồng du lịch" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<div class="dump-page" id="main-content">
    <div class="dump-hero">
        <div><p class="eyebrow">CỘNG ĐỒNG LOCALTRIP</p><h1>Nhật ký <span>✦</span></h1><p>Chia sẻ những khoảnh khắc, cảm nhận và kinh nghiệm du lịch chân thật.</p></div>
        <div class="dump-hero-actions"><a class="btn btn-light" href="${pageContext.request.contextPath}/dump/friends">👥 Bạn bè</a><a class="btn btn-light" href="${pageContext.request.contextPath}/passport">🧭 Hộ chiếu du lịch</a></div>
    </div>
    <c:if test="${not empty sessionScope.errorMessage}"><div class="alert alert-danger"><c:out value="${sessionScope.errorMessage}"/></div><c:remove var="errorMessage" scope="session"/></c:if>
    <c:if test="${not empty sessionScope.successMessage}"><div class="alert alert-success"><c:out value="${sessionScope.successMessage}"/></div><c:remove var="successMessage" scope="session"/></c:if>
    <div class="dump-layout">
        <aside class="dump-sidebar">
            <a class="dump-side-link active" href="${pageContext.request.contextPath}/dump">🌎 Bảng tin</a>
            <a class="dump-side-link" href="${pageContext.request.contextPath}/dump?filter=BOOKMARKS">🔖 Bài đã lưu</a>
            <a class="dump-side-link" href="${pageContext.request.contextPath}/dump/friends">🤝 Kết nối bạn bè</a>
            <a class="dump-side-link" href="${pageContext.request.contextPath}/passport">🛂 Hộ chiếu du lịch</a>
            <div class="dump-privacy-note"><strong>🔒 Bạn kiểm soát quyền riêng tư</strong><p>Bài viết có thể công khai hoặc chỉ hiển thị với bạn bè đã chấp nhận lời mời.</p></div>
        </aside>
        <main class="dump-main">
            <section class="dump-card dump-create-card">
                <h2>Chia sẻ hành trình của bạn</h2>
                <form action="${pageContext.request.contextPath}/dump/create" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                    <label class="form-label" for="dumpContent">Bạn đã trải nghiệm điều gì?</label>
                    <textarea class="form-control" id="dumpContent" name="content" maxlength="2000" rows="3" placeholder="Viết cảm nhận, mẹo du lịch hoặc để ảnh kể câu chuyện của bạn..."></textarea>
                    <div class="row g-3 mt-1">
                        <div class="col-md-6"><label class="form-label" for="dumpImages">Ảnh (tối đa 5 ảnh, mỗi ảnh 5 MB)</label><input class="form-control" id="dumpImages" name="images" type="file" accept="image/jpeg,image/png,image/webp" multiple><small class="text-muted">Chỉ nhận JPG, PNG, WEBP. Ảnh được lưu ngoài thư mục web công khai.</small></div>
                        <div class="col-md-6"><label class="form-label" for="dumpPlace">Địa điểm (không bắt buộc)</label><select class="form-select" id="dumpPlace" name="placeId"><option value="">Không gắn địa điểm</option><c:forEach items="${places}" var="p"><option value="${p.id}"><c:out value="${p.name}"/></option></c:forEach></select>
                            <label class="form-label mt-2" for="dumpTrip">Chuyến đi liên quan (không bắt buộc)</label><select class="form-select" id="dumpTrip" name="tripId"><option value="">Không gắn chuyến đi</option><c:forEach items="${trips}" var="t"><option value="${t.tripId}"><c:out value="${t.tripName}"/></option></c:forEach></select>
                            <label class="form-label mt-2" for="dumpRating">Đánh giá (không bắt buộc)</label><select class="form-select" id="dumpRating" name="rating"><option value="">Không đánh giá</option><option value="5">★★★★★ - Rất tuyệt</option><option value="4">★★★★ - Tốt</option><option value="3">★★★ - Bình thường</option><option value="2">★★ - Chưa tốt</option><option value="1">★ - Không hài lòng</option></select></div>
                    </div>
                    <div class="dump-form-bottom"><div><label class="form-label" for="dumpVisibility">Ai có thể xem?</label><select class="form-select" id="dumpVisibility" name="visibility"><option value="PUBLIC">🌎 Công khai</option><option value="FRIENDS">👥 Chỉ bạn bè</option></select></div><button class="btn btn-brand" type="submit">Đăng lên Nhật ký ↗</button></div>
                    <p class="dump-form-hint">Bài viết chỉ có nội dung hoặc ảnh đều được chấp nhận. Không cần đánh giá địa điểm.</p>
                </form>
            </section>
            <c:if test="${bookmarksOnly}"><h2 class="dump-section-title">Bài viết đã lưu</h2></c:if>
            <c:if test="${empty posts}"><div class="dump-card dump-empty"><span>🧳</span><h3>Chuyến đi nào cũng bắt đầu từ một câu chuyện</h3><p>Chưa có bài viết phù hợp. Hãy chia sẻ trải nghiệm đầu tiên hoặc kết nối thêm bạn bè.</p></div></c:if>
            <c:forEach items="${posts}" var="post">
                <article class="dump-card dump-post">
                    <div class="dump-post-head"><div class="dump-avatar"><c:out value="${post.fullName.substring(0,1)}"/></div><div class="dump-post-author"><strong><c:out value="${post.fullName}"/></strong><small><fmt:formatDate value="${post.createdAt}" pattern="dd/MM/yyyy HH:mm"/> · <c:choose><c:when test="${post.visibility eq 'FRIENDS'}">👥 Bạn bè</c:when><c:otherwise>🌎 Công khai</c:otherwise></c:choose></small></div><c:if test="${post.userId eq sessionScope.user.userId}"><form action="${pageContext.request.contextPath}/dump/action" method="post" onsubmit="return confirm('Bạn chắc chắn muốn xóa bài viết này?');"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="delete"><button class="btn btn-sm btn-outline-secondary" type="submit">Xóa</button></form></c:if></div>
                    <c:if test="${not empty post.content}"><p class="dump-post-content"><c:out value="${post.content}"/></p></c:if>
                    <c:if test="${not empty post.placeName}"><p class="dump-place-tag">📍 <c:out value="${post.placeName}"/></p></c:if>
                    <c:if test="${not empty post.rating}"><p class="dump-rating"><c:forEach begin="1" end="${post.rating}">★</c:forEach><span> Đánh giá địa điểm</span></p></c:if>
                    <c:if test="${not empty post.images}"><div class="dump-image-grid count-${post.images.size()}"><c:forEach items="${post.images}" var="image"><a href="${pageContext.request.contextPath}/dump/image?id=${image.imageId}" target="_blank" rel="noopener"><img src="${pageContext.request.contextPath}/dump/image?id=${image.imageId}" alt="Ảnh trong bài nhật ký" loading="lazy"></a></c:forEach></div></c:if>
                    <div class="dump-post-stats"><span>♥ ${post.likeCount} lượt thích</span><span>💬 ${post.commentCount} bình luận</span></div>
                    <div class="dump-post-actions"><form action="${pageContext.request.contextPath}/dump/action" method="post"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="like"><button type="submit" class="dump-action ${post.liked?'is-active':''}">${post.liked?'♥ Đã thích':'♡ Thích'}</button></form><form action="${pageContext.request.contextPath}/dump/action" method="post"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="bookmark"><input type="hidden" name="returnTo" value="${bookmarksOnly?'BOOKMARKS':'ALL'}"><button type="submit" class="dump-action">${post.bookmarked?'🔖 Đã lưu':'♧ Lưu bài'}</button></form><details class="dump-report"><summary>⋯</summary><form action="${pageContext.request.contextPath}/dump/action" method="post"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="report"><label class="form-label">Lý do báo cáo</label><input class="form-control form-control-sm" name="reason" maxlength="500" required><button class="btn btn-sm btn-outline-danger mt-2" type="submit">Gửi báo cáo</button></form></details></div>
                    <div class="dump-comments"><c:forEach items="${post.comments}" var="comment"><p><strong><c:out value="${comment.fullName}"/></strong> <c:out value="${comment.content}"/></p></c:forEach><form class="dump-comment-form" action="${pageContext.request.contextPath}/dump/action" method="post"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="comment"><input class="form-control" name="content" maxlength="1000" placeholder="Viết bình luận..." required><button class="btn btn-brand" type="submit">Gửi</button></form></div>
                </article>
            </c:forEach>
        </main>
    </div>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
