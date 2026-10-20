<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Travel Feed" scope="request"/>
<c:set var="tripRedesign" value="${true}" scope="request"/>
<fmt:setLocale value="en_US" scope="page"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
    .rd-page .dump-page {
        max-width: 100%;
        padding: 0;
    }

    .rd-page .dump-layout {
        display: grid;
        grid-template-columns: 250px minmax(0, 1fr);
        gap: 24px;
        align-items: start;
    }

    .rd-page .dump-sidebar {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 18px;
        padding: 18px;
        min-width: 0;
    }

    .rd-page .dump-side-link {
        display: flex;
        align-items: center;
        padding: 12px 14px;
        margin-bottom: 6px;
        border-radius: 11px;
        color: var(--ink2);
        text-decoration: none;
        font-weight: 500;
    }

    .rd-page .dump-side-link:hover {
        background: var(--bg);
        color: var(--green);
    }

    .rd-page .dump-side-link.active {
        background: var(--mint);
        color: var(--green);
        font-weight: 600;
    }

    .rd-page .dump-privacy-note {
        margin-top: 20px;
        padding: 16px;
        border-radius: 12px;
        background: var(--bg);
        color: var(--ink2);
        font-size: 13px;
        line-height: 1.6;
    }

    .rd-page .dump-privacy-note strong {
        display: block;
        color: var(--ink);
        margin-bottom: 8px;
    }

    .rd-page .dump-privacy-note p {
        margin: 0;
    }

    .rd-page .dump-main {
        min-width: 0;
    }

    .rd-page .dump-card {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 18px;
        padding: 26px;
        margin-bottom: 24px;
        box-shadow: none;
    }

    .rd-page .dump-card h2 {
        font-size: 22px;
        color: var(--ink);
        margin-bottom: 20px;
    }

    .rd-page .dump-form-bottom {
        display: flex;
        justify-content: space-between;
        align-items: end;
        flex-wrap: wrap;
        gap: 16px;
        margin-top: 20px;
        padding-top: 20px;
        border-top: 1px solid var(--line);
    }

    .rd-page .dump-form-bottom > div {
        flex: 1 1 200px;
    }

    .rd-page .dump-form-hint {
        color: var(--ink2);
        font-size: 13px;
        margin: 14px 0 0;
    }

    .rd-page .dump-post-head {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
        margin-bottom: 20px;
    }

    .rd-page .dump-avatar {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 44px;
        height: 44px;
        flex-shrink: 0;
        border-radius: 50%;
        background: var(--green);
        color: #fff;
        font-weight: 600;
    }

    .rd-page .dump-post-author {
        flex: 1;
        min-width: 0;
        overflow-wrap: anywhere;
    }

    .rd-page .dump-post-author strong,
    .rd-page .dump-post-author small {
        display: block;
    }

    .rd-page .dump-post-author small {
        color: var(--ink2);
        margin-top: 3px;
    }

    .rd-page .dump-post-content {
        white-space: pre-line;
        overflow-wrap: anywhere;
        line-height: 1.75;
        color: var(--ink);
    }

    .rd-page .dump-place-tag {
        color: var(--green);
        font-weight: 500;
    }

    .rd-page .dump-rating {
        color: #996400;
    }

    .rd-page .dump-rating span {
        color: var(--ink2);
        font-size: 13px;
    }

    .rd-page .dump-image-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 8px;
        margin: 16px 0;
    }

    .rd-page .dump-image-grid.count-1 {
        grid-template-columns: minmax(0, 1fr);
    }

    .rd-page .dump-image-grid a {
        min-width: 0;
        overflow: hidden;
        border-radius: 12px;
    }

    .rd-page .dump-image-grid img {
        display: block;
        width: 100%;
        height: 240px;
        object-fit: cover;
    }

    .rd-page .dump-post-stats {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        color: var(--ink2);
        font-size: 13px;
        padding: 14px 0;
    }

    .rd-page .dump-post-actions {
        display: flex;
        align-items: start;
        flex-wrap: wrap;
        gap: 8px;
        padding: 12px 0;
        border-top: 1px solid var(--line);
        border-bottom: 1px solid var(--line);
    }

    .rd-page .dump-action {
        border: 0;
        border-radius: 9px;
        background: transparent;
        color: var(--ink2);
        padding: 9px 12px;
        font-weight: 500;
    }

    .rd-page .dump-action:hover,
    .rd-page .dump-action.is-active {
        background: var(--mint);
        color: var(--green);
    }

    .rd-page .dump-report {
        margin-left: auto;
        max-width: 100%;
    }

    .rd-page .dump-report summary {
        cursor: pointer;
        padding: 8px 12px;
    }

    .rd-page .dump-report form {
        position: static;
        width: 260px;
        max-width: 100%;
        padding: 12px;
        border: 1px solid var(--line);
        border-radius: 12px;
        background: #fff;
    }

    .rd-page .dump-comments {
        margin-top: 18px;
    }

    .rd-page .dump-comments p {
        padding: 10px 14px;
        background: var(--bg);
        border-radius: 11px;
        overflow-wrap: anywhere;
    }

    .rd-page .dump-comment-form {
        display: flex;
        gap: 10px;
        margin-top: 14px;
    }

    .rd-page .dump-comment-form input {
        min-width: 0;
    }

    .rd-page .dump-empty {
        text-align: center;
        padding: 40px 24px;
    }

    .rd-page .dump-empty p {
        color: var(--ink2);
    }

    @media (max-width: 991px) {
        .rd-page .dump-layout {
            grid-template-columns: minmax(0, 1fr);
        }

        .rd-page .dump-sidebar {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .rd-page .dump-side-link {
            margin: 0;
        }

        .rd-page .dump-privacy-note {
            width: 100%;
            margin-top: 8px;
        }
    }

    @media (max-width: 575px) {
        .rd-page .dump-card {
            padding: 20px 16px;
        }

        .rd-page .dump-form-bottom > div,
        .rd-page .dump-form-bottom > button {
            width: 100%;
        }

        .rd-page .dump-comment-form {
            flex-wrap: wrap;
        }

        .rd-page .dump-comment-form input,
        .rd-page .dump-comment-form button {
            width: 100%;
        }

        .rd-page .dump-image-grid img {
            height: 170px;
        }
    }
</style>
<div class="dump-page" id="main-content">
    <section class="rd-hero mb-4">
        <div class="rd-hero-top">
            <div>
                <div class="small text-white-50 mb-2">
                    LOCALTRIP · JOURNEY STORIES
                </div>

                <h1 class="mb-2">Travel Feed</h1>

                <p class="text-white mb-0">
                    Share moments, impressions, and recommendations from your adventures.
                </p>
            </div>

            <div class="d-flex flex-wrap gap-2">
                <a class="rd-back"
                   href="${pageContext.request.contextPath}/dump/friends">
                    Connect friends
                </a>

                <a class="rd-back"
                   href="${pageContext.request.contextPath}/passport">
                    Travel Passport →
                </a>
            </div>
        </div>
    </section>
    <c:if test="${not empty sessionScope.errorMessage}"><div class="alert alert-danger"><c:out value="${sessionScope.errorMessage}"/></div><c:remove var="errorMessage" scope="session"/></c:if>
    <c:if test="${not empty sessionScope.successMessage}"><div class="alert alert-success"><c:out value="${sessionScope.successMessage}"/></div><c:remove var="successMessage" scope="session"/></c:if>
        <div class="dump-layout">
            <aside class="dump-sidebar">
                <a class="dump-side-link ${bookmarksOnly ? '' : 'active'}"
               href="${pageContext.request.contextPath}/dump">
                Activity feed
            </a>

            <a class="dump-side-link ${bookmarksOnly ? 'active' : ''}"
               href="${pageContext.request.contextPath}/dump?filter=BOOKMARKS">
                Saved posts
            </a>
            <a class="dump-side-link" href="${pageContext.request.contextPath}/dump/friends">🤝 Connect friends</a>
            <a class="dump-side-link" href="${pageContext.request.contextPath}/passport">🛂 Travel Passport</a>
            <div class="dump-privacy-note"><strong>🔒 Privacy Control</strong><p>Posts can be public or visible only to confirmed travel friends.</p></div>
        </aside>
        <main class="dump-main">
            <section class="dump-card dump-create-card">
                <h2>Share your journey</h2>
                <form action="${pageContext.request.contextPath}/dump/create" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                    <label class="form-label" for="dumpContent">What did you experience?</label>
                    <textarea class="form-control" id="dumpContent" name="content" maxlength="2000" rows="3" placeholder="Write your impressions, local travel tips, or let photos tell the story..."></textarea>
                    <div class="row g-3 mt-1">
                        <div class="col-md-6"><label class="form-label" for="dumpImages">Photos (up to 5 photos, 5MB each)</label><input class="form-control" id="dumpImages" name="images" type="file" accept="image/jpeg,image/png,image/webp" multiple><small class="text-muted">JPG, PNG, WEBP accepted.</small></div>
                        <div class="col-md-6"><label class="form-label" for="dumpPlace">Destination (optional)</label><select class="form-select" id="dumpPlace" name="placeId"><option value="">No tagged destination</option><c:forEach items="${places}" var="p"><option value="${p.id}"><c:out value="${p.name}"/></option></c:forEach></select>
                            <label class="form-label mt-2" for="dumpTrip">Related trip (optional)</label><select class="form-select" id="dumpTrip" name="tripId"><option value="">No tagged trip</option><c:forEach items="${trips}" var="t"><option value="${t.tripId}"><c:out value="${t.tripName}"/></option></c:forEach></select>
                                <label class="form-label mt-2" for="dumpRating">Rating (optional)</label><select class="form-select" id="dumpRating" name="rating"><option value="">No rating</option><option value="5">★★★★★ - Excellent</option><option value="4">★★★★ - Good</option><option value="3">★★★ - Average</option><option value="2">★★ - Fair</option><option value="1">★ - Poor</option></select></div>
                        </div>
                        <div class="dump-form-bottom"><div><label class="form-label" for="dumpVisibility">Audience</label><select class="form-select" id="dumpVisibility" name="visibility"><option value="PUBLIC">🌎 Public</option><option value="FRIENDS">👥 Friends only</option></select></div><button class="btn btn-brand" type="submit">Post to Feed ↗</button></div>
                    </form>
                </section>
            <c:if test="${bookmarksOnly}"><h2 class="dump-section-title">Saved posts</h2></c:if>
            <c:if test="${empty posts}"><div class="dump-card dump-empty"><span>🧳</span><h3>Every journey begins with a story</h3><p>No posts available yet. Share your first experience or connect with friends.</p></div></c:if>
            <c:forEach items="${posts}" var="post">
                <article class="dump-card dump-post">
                    <div class="dump-post-head"><div class="dump-avatar"><c:out value="${post.fullName.substring(0,1)}"/></div><div class="dump-post-author"><strong><c:out value="${post.fullName}"/></strong><small><fmt:formatDate value="${post.createdAt}" pattern="dd/MM/yyyy HH:mm"/> · <c:choose><c:when test="${post.visibility eq 'FRIENDS'}">👥 Friends</c:when><c:otherwise>🌎 Public</c:otherwise></c:choose></small></div><c:if test="${post.userId eq sessionScope.user.userId}"><form action="${pageContext.request.contextPath}/dump/action" method="post" onsubmit="return confirm('Permanently delete this post?');"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="delete"><button class="btn btn-sm btn-outline-secondary" type="submit">Delete</button></form></c:if></div>
                    <c:if test="${not empty post.content}"><p class="dump-post-content"><c:out value="${post.content}"/></p></c:if>
                    <c:if test="${not empty post.placeName}"><p class="dump-place-tag">📍 <c:out value="${post.placeName}"/></p></c:if>
                    <c:if test="${not empty post.rating}"><p class="dump-rating"><c:forEach begin="1" end="${post.rating}">★</c:forEach><span> Destination rating</span></p></c:if>
                    <c:if test="${not empty post.images}"><div class="dump-image-grid count-${post.images.size()}"><c:forEach items="${post.images}" var="image"><a href="${pageContext.request.contextPath}/dump/image?id=${image.imageId}" target="_blank" rel="noopener"><img src="${pageContext.request.contextPath}/dump/image?id=${image.imageId}" alt="Post image" loading="lazy"></a></c:forEach></div></c:if>
                    <div class="dump-post-stats"><span>♥ ${post.likeCount} likes</span><span>💬 ${post.commentCount} comments</span></div>
                    <div class="dump-post-actions"><form action="${pageContext.request.contextPath}/dump/action" method="post"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="like"><button type="submit" class="dump-action ${post.liked?'is-active':''}">${post.liked?'♥ Liked':'♡ Like'}</button></form><form action="${pageContext.request.contextPath}/dump/action" method="post"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="bookmark"><input type="hidden" name="returnTo" value="${bookmarksOnly?'BOOKMARKS':'ALL'}"><button type="submit" class="dump-action">${post.bookmarked?'🔖 Saved':'♧ Save'}</button></form><details class="dump-report"><summary>⋯</summary><form action="${pageContext.request.contextPath}/dump/action" method="post"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="report"><label class="form-label">Report reason</label><input class="form-control form-control-sm" name="reason" maxlength="500" required><button class="btn btn-sm btn-outline-danger mt-2" type="submit">Submit report</button></form></details></div>
                    <div class="dump-comments"><c:forEach items="${post.comments}" var="comment"><p><strong><c:out value="${comment.fullName}"/></strong> <c:out value="${comment.content}"/></p></c:forEach><form class="dump-comment-form" action="${pageContext.request.contextPath}/dump/action" method="post"><input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}"><input type="hidden" name="postId" value="${post.postId}"><input type="hidden" name="action" value="comment"><input class="form-control" name="content" maxlength="1000" placeholder="Write a comment..." required><button class="btn btn-brand" type="submit">Send</button></form></div>
                    </article>
            </c:forEach>
        </main>
    </div>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
