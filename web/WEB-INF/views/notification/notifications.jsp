<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Notifications" scope="request" />
<c:set var="tripRedesign" value="${true}" scope="request" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="lt-notify">

    <%-- 1. Header with back button & Mark all read --%>
    <div class="lt-notify-header-bar">
        <a class="lt-btn-circle-back"
           href="${pageContext.request.contextPath}/trips"
           aria-label="Back to trips">
            ‹
        </a>
        <h1 class="lt-notify-title">Notifications</h1>
        <form method="post" action="${pageContext.request.contextPath}/notifications" id="markAllForm" style="margin: 0;">
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.travelCsrf}' />">
            <input type="hidden" name="action" value="markAllRead">
            <button type="button" class="lt-btn-mark-read" onclick="submitMarkAllRead()">
                Mark all read
            </button>
        </form>
    </div>

    <%-- 2. Filter Pills --%>
    <div class="lt-notify-filters">
        <button type="button" class="lt-filter-pill-active" id="unreadBadge">
            ${unreadCount > 0 ? unreadCount : 0} unread
        </button>
        <button type="button" class="lt-filter-pill" onclick="filterNotifs('all')">All</button>
        <button type="button" class="lt-filter-pill" onclick="filterNotifs('trip')">Trips</button>
        <button type="button" class="lt-filter-pill" onclick="filterNotifs('friend')">Friends</button>
        <button type="button" class="lt-filter-pill" onclick="filterNotifs('expense')">Expenses</button>
    </div>

    <%-- 3. Notifications & Friend Requests List --%>
    <c:choose>
        <c:when test="${empty friendRequests and empty notifications}">
            <section class="lt-notify-empty">
                <h2>You're all caught up!</h2>
                <p>New trip invites, friend requests, and expense updates will appear here.</p>
            </section>
        </c:when>

        <c:otherwise>
            <div id="notifListContainer">

                <%-- Pending Friend Requests --%>
                <c:if test="${not empty friendRequests}">
                    <div style="margin: 8px 0 6px;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #175b43; letter-spacing: 0.5px;">Friend Requests</span>
                    </div>
                    <c:forEach items="${friendRequests}" var="fr" varStatus="loop">
                        <article class="lt-notify-card" id="friend-request-${loop.index}" data-type="FRIEND_REQUEST">
                            <div class="lt-notify-row">
                                <div class="lt-person-avatar" aria-hidden="true" style="width: 38px; height: 38px; font-size: 14px; background: #e3f0e8; color: #175b43; display: flex; align-items: center; justify-content: center; border-radius: 50%; font-weight: 700;">
                                    <c:out value="${fn:substring(fr.fullName, 0, 1)}" />
                                </div>
                                <div class="lt-notify-text">
                                    <p style="font-size: 13px; line-height: 1.35; margin: 0;">
                                        <strong style="color: #0f172a;"><c:out value="${fr.fullName}" /></strong> sent you a friend request.
                                    </p>
                                    <small style="font-size: 10px; color: #94a3b8;"><c:out value="${fr.createdAt}" /></small>
                                </div>
                                <span class="lt-notify-dot" aria-label="Unread"></span>
                            </div>
                            <div id="actions-friend-${loop.index}" style="margin-top: 10px;">
                                <form method="post" action="${pageContext.request.contextPath}/dump/friends" class="lt-request-actions"
                                      data-actor-name="<c:out value='${fr.fullName}' />"
                                      onsubmit="return handleFriendFormSubmit(event, 'actions-friend-${loop.index}', this)">
                                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.travelCsrf}' />">
                                    <input type="hidden" name="friendshipId" value="<c:out value='${fr.friendshipId}' />">
                                    <input type="hidden" name="redirect" value="${pageContext.request.contextPath}/notifications">

                                    <button type="submit" class="btn btn-primary" name="action" value="accept"
                                            style="background: #175b43; border: none; font-size: 12px; font-weight: 600; padding: 6px 14px; border-radius: 8px;">
                                        Accept
                                    </button>
                                    <button type="submit" class="btn btn-outline-secondary" name="action" value="decline"
                                            style="font-size: 12px; padding: 6px 14px; border-radius: 8px;">
                                        Decline
                                    </button>
                                </form>
                            </div>
                        </article>
                    </c:forEach>
                </c:if>

                <%-- Real System Notifications --%>
                <c:if test="${not empty notifications}">
                    <c:if test="${not empty friendRequests}">
                        <div style="margin: 14px 0 6px;">
                            <span style="font-size: 10px; font-weight: 700; text-transform: uppercase; color: #94a3b8; letter-spacing: 0.5px;">Activity Updates</span>
                        </div>
                    </c:if>

                    <c:forEach items="${notifications}" var="n" varStatus="loop">
                        <article class="lt-notify-card ${n.read ? 'is-read' : ''}" id="notif-item-${n.notificationId}" data-type="<c:out value='${n.type}'/>">
                            <div class="lt-notify-row">
                                <div class="lt-person-avatar" aria-hidden="true" style="width: 38px; height: 38px; font-size: 18px; display: flex; align-items: center; justify-content: center; background: #e3f0e8; border-radius: 50%; flex-shrink: 0;">
                                    <c:out value="${n.icon}" />
                                </div>

                                <div class="lt-notify-text">
                                    <p style="font-size: 13px; line-height: 1.4; margin: 0; color: #1e293b;">
                                        <c:out value="${n.message}" />
                                    </p>
                                    <div style="display: flex; align-items: center; gap: 8px; margin-top: 4px;">
                                        <small style="font-size: 11px; color: #94a3b8;"><c:out value="${n.timeAgo}" /></small>
                                        <a href="<c:out value='${n.getLink(pageContext.request.contextPath)}'/>"
                                           class="lt-notify-link"
                                           style="font-size: 11px; font-weight: 600; color: #175b43; text-decoration: none;"
                                           onclick="markSingleAsRead(${n.notificationId})">
                                            View →
                                        </a>
                                    </div>
                                </div>

                                <c:if test="${not n.read}">
                                    <span class="lt-notify-dot" id="dot-${n.notificationId}" aria-label="Unread"></span>
                                </c:if>
                            </div>
                        </article>
                    </c:forEach>
                </c:if>

                <%-- Pagination controls if needed --%>
                <c:if test="${currentPage > 1 or fn:length(notifications) >= 20}">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 16px; padding: 8px 0;">
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/notifications?page=${currentPage - 1}" class="btn btn-sm btn-outline-secondary" style="font-size: 12px;">← Previous</a>
                        </c:if>
                        <c:if test="${currentPage <= 1}">
                            <span></span>
                        </c:if>
                        <span style="font-size: 12px; color: #64748b;">Page ${currentPage}</span>
                        <c:if test="${fn:length(notifications) >= 20}">
                            <a href="${pageContext.request.contextPath}/notifications?page=${currentPage + 1}" class="btn btn-sm btn-outline-secondary" style="font-size: 12px;">Next →</a>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
    const csrfToken = "<c:out value='${sessionScope.travelCsrf}'/>";
    const contextPath = "${pageContext.request.contextPath}";

    function submitMarkAllRead() {
        // Optimistic UI update
        document.querySelectorAll('.lt-notify-dot').forEach(function(dot) {
            dot.remove();
        });
        document.querySelectorAll('.lt-notify-card').forEach(function(card) {
            card.classList.add('is-read');
        });
        const badge = document.getElementById('unreadBadge');
        if (badge) {
            badge.innerText = '0 unread';
        }

        const formData = new URLSearchParams();
        formData.append('action', 'markAllRead');
        formData.append('csrfToken', csrfToken);

        fetch(contextPath + '/notifications', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: formData.toString()
        }).then(function(res) {
            return res.json();
        }).then(function(data) {
            if (data && typeof data.unreadCount !== 'undefined' && badge) {
                badge.innerText = data.unreadCount + ' unread';
            }
        }).catch(function() {
            // Fallback: submit standard form
            const form = document.getElementById('markAllForm');
            if (form) form.submit();
        });
    }

    function markSingleAsRead(id) {
        if (!id) return;
        const dot = document.getElementById('dot-' + id);
        if (dot) dot.remove();
        const card = document.getElementById('notif-item-' + id);
        if (card) card.classList.add('is-read');

        const formData = new URLSearchParams();
        formData.append('action', 'markRead');
        formData.append('notificationId', id);
        formData.append('csrfToken', csrfToken);

        fetch(contextPath + '/notifications', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: formData.toString()
        }).then(function(res) {
            return res.json();
        }).then(function(data) {
            if (data && typeof data.unreadCount !== 'undefined') {
                const badge = document.getElementById('unreadBadge');
                if (badge) badge.innerText = data.unreadCount + ' unread';
            }
        }).catch(function(e) {
            // silent ignore on navigation
        });
    }

    function handleFriendFormSubmit(e, containerId, formEl) {
        if (e) e.preventDefault();
        const submitter = e && e.submitter ? e.submitter : null;
        const actionVal = submitter && submitter.value ? submitter.value : 'accept';
        const actorName = formEl.getAttribute('data-actor-name') || 'Friend';
        const friendshipId = formEl.querySelector('input[name="friendshipId"]').value;
        const csrfVal = formEl.querySelector('input[name="csrfToken"]').value;

        const btns = formEl.querySelectorAll('button');
        btns.forEach(function(b) { b.disabled = true; });

        const formData = new URLSearchParams();
        formData.append('csrfToken', csrfVal);
        formData.append('action', actionVal);
        formData.append('friendshipId', friendshipId);

        fetch(formEl.action, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: formData.toString()
        }).then(function(res) {
            return res.json().catch(function() { return { success: res.ok }; });
        }).then(function(data) {
            const container = document.getElementById(containerId);
            if (container) {
                container.innerHTML = '';
                const badge = document.createElement('div');
                if (actionVal === 'accept') {
                    badge.className = 'lt-notify-badge-joined';
                    badge.style.cssText = 'background:#ecfdf5; color:#065f46; border:1px solid #a7f3d0; padding:6px 14px; border-radius:8px; font-size:12px; font-weight:700; display:inline-block;';
                    badge.textContent = '✓ Connected with ' + actorName;
                } else {
                    badge.className = 'lt-notify-badge-declined';
                    badge.style.cssText = 'background:#f1f5f9; color:#64748b; border:1px solid #cbd5e1; padding:6px 14px; border-radius:8px; font-size:12px; font-weight:600; display:inline-block;';
                    badge.textContent = 'Declined';
                }
                container.appendChild(badge);
            }
            // Remove unread dot
            const parentCard = formEl.closest('.lt-notify-card');
            if (parentCard) {
                const dot = parentCard.querySelector('.lt-notify-dot');
                if (dot) dot.remove();
                parentCard.classList.add('is-read');
            }
            // Decrement unreadBadge count
            const unreadBadge = document.getElementById('unreadBadge');
            if (unreadBadge) {
                const curr = parseInt(unreadBadge.innerText, 10);
                if (!isNaN(curr) && curr > 0) {
                    unreadBadge.innerText = (curr - 1) + ' unread';
                }
            }
            if (typeof decrementHeaderBadge === 'function') {
                decrementHeaderBadge();
            }
        }).catch(function(err) {
            console.error('Error responding to friend request:', err);
            formEl.submit();
        });
        return false;
    }

    function filterNotifs(filterType) {
        const cards = document.querySelectorAll('.lt-notify-card');
        cards.forEach(function(card) {
            const type = card.getAttribute('data-type') || '';
            if (filterType === 'all') {
                card.style.display = 'block';
            } else if (filterType === 'trip') {
                card.style.display = (type.indexOf('TRIP') !== -1 || type.indexOf('ITINERARY') !== -1) ? 'block' : 'none';
            } else if (filterType === 'friend') {
                card.style.display = type.indexOf('FRIEND') !== -1 ? 'block' : 'none';
            } else if (filterType === 'expense') {
                card.style.display = (type.indexOf('EXPENSE') !== -1 || type.indexOf('PAYMENT') !== -1) ? 'block' : 'none';
            }
        });
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
