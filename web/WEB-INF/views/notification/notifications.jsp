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
        <button type="button" class="lt-btn-mark-read" onclick="markAllNotificationsAsRead()">
            Mark all read
        </button>
    </div>

    <%-- 2. Filter Pills --%>
    <div class="lt-notify-filters">
        <button type="button" class="lt-filter-pill-active" id="unreadBadge">
            ${unreadCount > 0 ? unreadCount : 0} unread
        </button>
        <button type="button" class="lt-filter-pill" onclick="filterNotifs('all')">All</button>
        <button type="button" class="lt-filter-pill" onclick="filterNotifs('trip')">Trips</button>
        <button type="button" class="lt-filter-pill" onclick="filterNotifs('friend')">Friends</button>
    </div>

    <c:if test="${demo}">
        <p class="lt-notify-demo" style="text-align: center; font-size: 11px;">💡 Preview mode with sample notifications.</p>
    </c:if>

    <%-- 3. Notifications List --%>
    <c:choose>
        <c:when test="${empty items}">
            <section class="lt-notify-empty">
                <h2>You're all caught up!</h2>
                <p>New trip invites and friend updates will appear here.</p>
            </section>
        </c:when>

        <c:otherwise>
            <div id="notifListContainer">
                <c:set var="earlierShown" value="${false}" />

                <c:forEach items="${items}" var="n" varStatus="loop">

                    <c:if test="${not n.unread and not earlierShown}">
                        <c:set var="earlierShown" value="${true}" />
                        <div style="margin: 12px 0 6px;">
                            <span style="font-size: 10px; font-weight: 700; text-transform: uppercase; color: #94a3b8; letter-spacing: 0.5px;">Earlier</span>
                        </div>
                    </c:if>

                    <article class="lt-notify-card ${n.unread ? '' : 'is-read'}" id="notif-item-${loop.index}" data-type="${n.type}">
                        <div class="lt-notify-row">
                            <div class="lt-person-avatar" aria-hidden="true" style="width: 38px; height: 38px; font-size: 13px;">
                                <c:out value="${fn:substring(n.actorName, 0, 1)}" />
                            </div>

                            <div class="lt-notify-text">
                                <p style="font-size: 12px; line-height: 1.35; margin: 0;">
                                    <strong style="color: #0f172a;"><c:out value="${n.actorName}" /></strong>
                                    <c:out value="${n.text}" />
                                </p>
                                <small style="font-size: 10px; color: #94a3b8;"><c:out value="${n.timeAgo}" /></small>
                            </div>

                            <c:if test="${n.unread}">
                                <span class="lt-notify-dot" aria-label="Unread"></span>
                            </c:if>
                        </div>

                        <%-- Embedded trip card if available --%>
                        <c:if test="${n.type == 'TRIP_INVITE'}">
                            <div class="lt-notify-trip" style="border-radius: 12px; margin-top: 10px; padding: 10px; background: #f4f7f4; border: 1px solid rgba(23, 91, 67, 0.1);">
                                <strong style="font-size: 12px;"><c:out value="${n.tripName}" /></strong>
                                <span style="font-size: 10px; color: #64748b;">📅 <c:out value="${n.tripDates}" /></span>
                                <a href="${pageContext.request.contextPath}/trips" style="font-size: 11px; font-weight: 700; color: #175b43; margin-top: 3px;">View itinerary →</a>
                            </div>

                            <div id="actions-trip-${loop.index}" class="lt-request-actions" style="margin-top: 10px;">
                                <button type="button" class="btn btn-primary" style="background: #175b43; border: none; font-size: 11px; font-weight: 600; padding: 6px;"
                                        onclick="handleAcceptAction('actions-trip-${loop.index}', '✓ Joined Explore District 1')">
                                    Accept
                                </button>
                                <button type="button" class="btn btn-outline-secondary" style="font-size: 11px; padding: 6px;"
                                        onclick="handleDeclineAction('actions-trip-${loop.index}')">
                                    Decline
                                </button>
                            </div>
                        </c:if>

                        <%-- Friend Request --%>
                        <c:if test="${n.type == 'FRIEND_REQUEST'}">
                            <div id="actions-friend-${loop.index}" style="margin-top: 10px;">
                                <form method="post" action="${pageContext.request.contextPath}/dump/friends" class="lt-request-actions"
                                      data-actor-name="<c:out value='${n.actorName}' />"
                                      onsubmit="return handleFriendFormSubmit(event, 'actions-friend-${loop.index}', this)">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                    <input type="hidden" name="friendshipId" value="${n.friendshipId}">

                                    <button type="submit" class="btn btn-primary" name="action" value="accept"
                                            style="background: #175b43; border: none; font-size: 11px; font-weight: 600; padding: 6px;">
                                        Accept
                                    </button>

                                    <button type="submit" class="btn btn-outline-secondary" name="action" value="decline"
                                            style="font-size: 11px; padding: 6px;">
                                        Decline
                                    </button>
                                </form>
                            </div>
                        </c:if>
                    </article>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
    function markAllNotificationsAsRead() {
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
    }

    // Safe DOM replacement without innerHTML XSS risk
    function handleAcceptAction(containerId, successMessage) {
        const container = document.getElementById(containerId);
        if (container) {
            container.textContent = '';
            const badge = document.createElement('div');
            badge.className = 'lt-notify-badge-joined';
            badge.textContent = successMessage;
            container.appendChild(badge);
        }
    }

    function handleDeclineAction(containerId) {
        const container = document.getElementById(containerId);
        if (container) {
            container.textContent = '';
            const span = document.createElement('span');
            span.style.fontSize = '11px';
            span.style.color = '#94a3b8';
            span.style.fontStyle = 'italic';
            span.textContent = 'Invitation declined';
            container.appendChild(span);
        }
    }

    function handleFriendFormSubmit(e, containerId, formEl) {
        const submitter = e.submitter;
        if (submitter && submitter.value === 'accept') {
            const actorName = formEl.getAttribute('data-actor-name') || 'Friend';
            handleAcceptAction(containerId, '✓ Connected with ' + actorName);
            return true;
        }
        return true;
    }

    function filterNotifs(type) {
        const cards = document.querySelectorAll('.lt-notify-card');
        cards.forEach(function(c) {
            const notifType = c.getAttribute('data-type') || '';
            if (type === 'all') {
                c.style.display = 'block';
            } else if (type === 'trip') {
                c.style.display = notifType.indexOf('TRIP') !== -1 ? 'block' : 'none';
            } else if (type === 'friend') {
                c.style.display = notifType.indexOf('FRIEND') !== -1 ? 'block' : 'none';
            }
        });
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
