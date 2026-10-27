<%@ page pageEncoding="UTF-8" language="java" %>
<%@ page import="model.User,utils.HtmlUtil,utils.ScenarioLabConfig,utils.AppClock" %>

<%
    String pageTitleText
            = (String) request.getAttribute("pageTitle");

    User headerUser
            = (User) session.getAttribute("user");

    boolean headerIsAdmin
            = headerUser != null
            && "ADMIN".equalsIgnoreCase(
                    headerUser.getRole()
            );

    boolean headerIsUser
            = headerUser != null
            && "USER".equalsIgnoreCase(
                    headerUser.getRole()
            );

    String headerHomeUrl
            = request.getContextPath() + "/login";

    if (headerIsAdmin) {
        headerHomeUrl
                = request.getContextPath() + "/admin";
    } else if (headerIsUser) {
        headerHomeUrl
                = request.getContextPath() + "/user";
    }

    if (session != null && session.getAttribute("travelCsrf") == null) {
        session.setAttribute("travelCsrf", java.util.UUID.randomUUID().toString());
    }

    String headerError
            = (String) request.getAttribute("errorMessage");

    String headerSuccess
            = (String) request.getAttribute("successMessage");

    String sessionError
            = (String) session.getAttribute("errorMessage");

    String sessionSuccess
            = (String) session.getAttribute("successMessage");

    if (headerError == null) {
        headerError = sessionError;
    }

    if (headerSuccess == null) {
        headerSuccess = sessionSuccess;
    }

    session.removeAttribute("errorMessage");
    session.removeAttribute("successMessage");

    int navUnread = 0;
    java.util.List<model.Notification> headerNotifications = null;
    java.util.List<java.util.Map<String, Object>> headerFriendRequests = null;
    if (headerUser != null) {
        headerFriendRequests = new dao.TravelFeatureDAO().getFriendRequests(headerUser.getUserId());
        headerNotifications = new dao.NotificationDAO().findByUser(headerUser.getUserId(), 8, 0);
        navUnread = new dao.NotificationDAO().countUnread(headerUser.getUserId()) + headerFriendRequests.size();
        session.setAttribute("unreadNotificationCount", navUnread);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta name="view-transition" content="same-origin">
    <meta name="theme-color" content="#175b43">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <link rel="manifest" href="<%= request.getContextPath() %>/manifest.json">

    <title>
        <%= HtmlUtil.escape(
                pageTitleText == null
                ? "LocalTrip"
                : pageTitleText + " - LocalTrip"
        ) %>
    </title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/localtrip.css?v=2">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/travel-features.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mobile-user.css?v=3">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mobile-auth.css?v=2">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css?v=1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css?v=1">
<style>
/* Facebook-Style Notification Bell & Dropdown */
.lt-notif-dropdown-wrapper {
    position: relative;
    display: inline-flex;
    align-items: center;
}
.lt-notif-bell-btn {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: none;
    background: rgba(255, 255, 255, 0.16);
    color: #ffffff;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    position: relative;
    cursor: pointer;
    transition: all 0.2s ease;
    padding: 0;
    text-decoration: none;
}
.lt-notif-bell-btn:hover,
.lt-notif-bell-btn:focus-visible,
.lt-notif-bell-btn[aria-expanded="true"] {
    background: rgba(255, 255, 255, 0.28);
    color: #ffffff;
    outline: none;
}
body.user-page .lt-notif-bell-btn,
.navbar-light .lt-notif-bell-btn {
    background: #f1f5f9;
    color: #174b39;
    border: 1px solid #e2e8f0;
}
body.user-page .lt-notif-bell-btn:hover,
body.user-page .lt-notif-bell-btn[aria-expanded="true"],
.navbar-light .lt-notif-bell-btn:hover,
.navbar-light .lt-notif-bell-btn[aria-expanded="true"] {
    background: #e2e8f0;
    color: #0f172a;
}
.lt-bell-svg {
    width: 20px;
    height: 20px;
    stroke-width: 2.2;
}
.lt-notif-badge {
    position: absolute;
    top: -2px;
    right: -2px;
    background: #e41e3f;
    color: #ffffff;
    font-size: 11px;
    font-weight: 700;
    height: 18px;
    min-width: 18px;
    padding: 0 4px;
    border-radius: 999px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid #ffffff;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.25);
    line-height: 1;
}
.lt-notif-dropdown {
    width: 380px !important;
    max-width: calc(100vw - 24px) !important;
    border-radius: 16px !important;
    border: 1px solid #e2e8f0 !important;
    padding: 0 !important;
    box-shadow: 0 12px 36px rgba(15, 23, 42, 0.16) !important;
    overflow: hidden !important;
    margin-top: 8px !important;
    z-index: 1080 !important;
    animation: ltDropFadeIn 0.15s ease-out;
}
@keyframes ltDropFadeIn {
    from { opacity: 0; transform: translateY(-6px); }
    to { opacity: 1; transform: translateY(0); }
}
.lt-notif-drop-head {
    padding: 14px 16px 12px;
    border-bottom: 1px solid #f1f5f9;
}
.lt-notif-drop-title {
    font-size: 18px;
    font-weight: 800;
    color: #0f172a;
    margin: 0;
}
.lt-notif-mark-all-btn {
    background: none;
    border: none;
    color: #175b43;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    padding: 2px 6px;
    border-radius: 6px;
    transition: background 0.15s;
}
.lt-notif-mark-all-btn:hover {
    background: #ecfdf5;
    text-decoration: underline;
}
.lt-notif-drop-body {
    max-height: 380px;
    overflow-y: auto;
    padding: 6px 0;
}
.lt-notif-section-title {
    font-size: 10.5px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #64748b;
    padding: 8px 16px 4px;
}
.lt-notif-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 10px 16px;
    text-decoration: none;
    color: inherit;
    transition: background 0.15s ease;
    position: relative;
    cursor: pointer;
}
.lt-notif-item:hover {
    background: #f8fafc;
    color: inherit;
}
.lt-notif-item.is-unread {
    background: #f0fdf4;
}
.lt-notif-item.is-unread:hover {
    background: #e6f9ed;
}
.lt-notif-avatar {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: #f1f5f9;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    flex-shrink: 0;
}
.lt-avatar-friend {
    background: #e3f0e8;
    color: #175b43;
    font-weight: 800;
    font-size: 15px;
}
.lt-notif-info {
    flex: 1;
    min-width: 0;
}
.lt-notif-text {
    font-size: 13px;
    line-height: 1.35;
    color: #1e293b;
    word-break: break-word;
}
.lt-notif-time {
    font-size: 11px;
    color: #94a3b8;
    margin-top: 3px;
}
.lt-notif-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #175b43;
    flex-shrink: 0;
    align-self: center;
}
.lt-btn-accept {
    background: #175b43 !important;
    border: none !important;
    color: #ffffff !important;
    font-size: 11.5px !important;
    font-weight: 700 !important;
    padding: 5px 14px !important;
    border-radius: 8px !important;
    transition: all 0.15s ease !important;
}
.lt-btn-accept:hover {
    background: #114231 !important;
}
.lt-btn-decline {
    background: #f1f5f9 !important;
    border: 1px solid #cbd5e1 !important;
    color: #475569 !important;
    font-size: 11.5px !important;
    font-weight: 600 !important;
    padding: 5px 12px !important;
    border-radius: 8px !important;
    margin-left: 6px !important;
}
.lt-btn-decline:hover {
    background: #e2e8f0 !important;
    color: #1e293b !important;
}
.lt-notif-drop-foot {
    border-top: 1px solid #f1f5f9;
    padding: 10px 16px;
    text-align: center;
    background: #fafafa;
}
.lt-notif-view-all {
    font-size: 12.5px;
    font-weight: 700;
    color: #175b43;
    text-decoration: none;
    display: inline-block;
}
.lt-notif-view-all:hover {
    color: #114231;
    text-decoration: underline;
}
.lt-notif-empty {
    padding: 32px 20px;
    text-align: center;
}
.lt-notif-empty-icon {
    font-size: 32px;
    display: block;
    margin-bottom: 8px;
    opacity: 0.6;
}
.lt-notif-empty-text {
    font-size: 14px;
    font-weight: 700;
    color: #334155;
    margin: 0;
}
.lt-notif-empty-sub {
    font-size: 11.5px;
    color: #94a3b8;
    display: block;
    margin-top: 4px;
}
</style>
</head>

<body class="rd-page <%= headerUser == null ? "auth-page" : (headerIsAdmin ? "admin-page" : "user-page") %> <%= Boolean.TRUE.equals(request.getAttribute("isLoginPage")) ? "login-page" : "" %>">
<a class="skip-link" href="#main-content">Skip to content</a>

<%
    java.time.Duration simOffsetBanner = AppClock.getOffset();
    if (simOffsetBanner != null && !simOffsetBanner.isZero()) {
%>
    <div class="alert alert-warning text-center py-2 mb-0 rounded-0 border-0 fw-bold shadow-sm" style="background: #fff3cd; color: #856404; font-size: 0.95rem; z-index: 1060;">
        ⚠️ SIMULATED TIME: <%= AppClock.today() %> (<%= AppClock.now().toLocalTime().toString().substring(0, 5) %>)
        <% if (headerIsAdmin && ScenarioLabConfig.isScenarioLabEnabled()) { %>
            · <a href="<%= request.getContextPath() %>/admin/lab" class="alert-link text-decoration-underline">Scenario Lab</a>
        <% } %>
    </div>
<% } %>

<nav class="navbar navbar-expand-lg app-navbar sticky-top">
    <div class="container">

        <a class="navbar-brand app-brand"
           href="<%= headerHomeUrl %>">

            <span class="app-brand-icon">L</span>

            <span>
                Local<span>Trip</span>
            </span>
        </a>

        <% if (headerUser != null) { %>
            <div class="dropdown lt-notif-dropdown-wrapper ms-auto me-2 me-lg-3">
                <button class="lt-notif-bell-btn" type="button" id="headerNotifBellBtn" 
                        data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false" 
                        title="Notifications (<%= navUnread %> unread)" aria-label="Notifications (<%= navUnread %> unread)">
                    <svg class="lt-bell-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                        <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                    </svg>
                    <span class="lt-notif-badge <%= navUnread > 0 ? "" : "d-none" %>" id="headerNotifBadge">
                        <%= navUnread > 99 ? "99+" : navUnread %>
                    </span>
                </button>

                <div class="dropdown-menu dropdown-menu-end shadow-lg lt-notif-dropdown" aria-labelledby="headerNotifBellBtn">
                    <%-- 1. Dropdown Header --%>
                    <div class="lt-notif-drop-head">
                        <div class="d-flex align-items-center justify-content-between w-100">
                            <span class="lt-notif-drop-title">Notifications</span>
                            <button type="button" class="lt-notif-mark-all-btn" onclick="headerMarkAllRead(event)">
                                Mark all as read
                            </button>
                        </div>
                    </div>

                    <%-- 2. Dropdown List --%>
                    <div class="lt-notif-drop-body" id="headerNotifList">
                        <%-- Pending Friend Requests --%>
                        <% if (headerFriendRequests != null && !headerFriendRequests.isEmpty()) { %>
                            <div class="lt-notif-section-title">Friend Requests</div>
                            <% for (java.util.Map<String, Object> fr : headerFriendRequests) {
                                   int fsId = (Integer) fr.get("friendshipId");
                                   String frName = (String) fr.get("fullName");
                                   String frInitial = frName != null && !frName.isEmpty() ? frName.substring(0, 1) : "F";
                            %>
                            <div class="lt-notif-item is-unread" id="header-fr-<%= fsId %>">
                                <div class="lt-notif-avatar lt-avatar-friend"><%= frInitial %></div>
                                <div class="lt-notif-info">
                                    <div class="lt-notif-text">
                                        <strong><%= HtmlUtil.escape(frName) %></strong> sent you a friend request.
                                    </div>
                                    <div class="lt-notif-actions mt-2" id="header-fr-actions-<%= fsId %>">
                                        <button type="button" class="btn btn-sm lt-btn-accept" 
                                                onclick="respondFriendHeader(<%= fsId %>, 'accept', '<%= HtmlUtil.escape(frName) %>')">
                                            Accept
                                        </button>
                                        <button type="button" class="btn btn-sm lt-btn-decline" 
                                                onclick="respondFriendHeader(<%= fsId %>, 'decline', '<%= HtmlUtil.escape(frName) %>')">
                                            Decline
                                        </button>
                                    </div>
                                </div>
                                <span class="lt-notif-dot" id="header-fr-dot-<%= fsId %>"></span>
                            </div>
                            <% } %>
                        <% } %>

                        <%-- Activity & System Notifications --%>
                        <% if (headerNotifications != null && !headerNotifications.isEmpty()) { %>
                            <% if (headerFriendRequests != null && !headerFriendRequests.isEmpty()) { %>
                                <div class="lt-notif-section-title">Earlier</div>
                            <% } %>
                            <% for (model.Notification n : headerNotifications) { %>
                            <a href="<%= n.getLink(request.getContextPath()) %>" 
                               class="lt-notif-item <%= n.isRead() ? "is-read" : "is-unread" %>" 
                               id="header-notif-<%= n.getNotificationId() %>"
                               onclick="headerMarkSingleRead(event, <%= n.getNotificationId() %>, '<%= n.getLink(request.getContextPath()) %>')">
                                <div class="lt-notif-avatar"><%= n.getIcon() %></div>
                                <div class="lt-notif-info">
                                    <div class="lt-notif-text"><%= HtmlUtil.escape(n.getMessage()) %></div>
                                    <div class="lt-notif-time"><%= n.getTimeAgo() %></div>
                                </div>
                                <% if (!n.isRead()) { %>
                                    <span class="lt-notif-dot" id="header-notif-dot-<%= n.getNotificationId() %>"></span>
                                <% } %>
                            </a>
                            <% } %>
                        <% } %>

                        <%-- Empty State --%>
                        <% if ((headerFriendRequests == null || headerFriendRequests.isEmpty()) && (headerNotifications == null || headerNotifications.isEmpty())) { %>
                            <div class="lt-notif-empty" id="headerNotifEmptyState">
                                <span class="lt-notif-empty-icon">🔔</span>
                                <p class="lt-notif-empty-text">No notifications right now</p>
                                <span class="lt-notif-empty-sub">We'll alert you about trips, invites, and friend updates here.</span>
                            </div>
                        <% } %>
                    </div>

                    <%-- 3. Dropdown Footer --%>
                    <div class="lt-notif-drop-foot">
                        <a href="<%= request.getContextPath() %>/notifications" class="lt-notif-view-all">
                            View all in Notifications &rarr;
                        </a>
                    </div>
                </div>
            </div>

            <script>
                const headerContextPath = "<%= request.getContextPath() %>";
                const headerCsrfToken = "<%= session != null ? (String) session.getAttribute("travelCsrf") : "" %>";

                function decrementHeaderBadge() {
                    const badge = document.getElementById('headerNotifBadge');
                    if (!badge) return;
                    let count = parseInt(badge.textContent.trim(), 10);
                    if (isNaN(count)) return;
                    count = Math.max(0, count - 1);
                    if (count === 0) {
                        badge.classList.add('d-none');
                        badge.textContent = '0';
                    } else {
                        badge.textContent = count > 99 ? '99+' : count;
                        badge.classList.remove('d-none');
                    }
                }

                function respondFriendHeader(fsId, action, actorName) {
                    if (!fsId) return;
                    const actionsDiv = document.getElementById('header-fr-actions-' + fsId);
                    if (actionsDiv) {
                        actionsDiv.innerHTML = '<span class="text-muted" style="font-size: 11px;">Processing...</span>';
                    }

                    const formData = new URLSearchParams();
                    formData.append('csrfToken', headerCsrfToken);
                    formData.append('action', action);
                    formData.append('friendshipId', fsId);

                    fetch(headerContextPath + '/dump/friends', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: formData.toString()
                    }).then(function(res) {
                        return res.json().catch(function() { return { success: res.ok }; });
                    }).then(function(data) {
                        if (actionsDiv) {
                            if (action === 'accept') {
                                actionsDiv.innerHTML = '<span class="badge" style="background:#ecfdf5; color:#065f46; border:1px solid #a7f3d0; font-size:11px; padding:4px 8px;">✓ Connected</span>';
                            } else {
                                actionsDiv.innerHTML = '<span class="badge" style="background:#f1f5f9; color:#64748b; border:1px solid #cbd5e1; font-size:11px; padding:4px 8px;">Declined</span>';
                            }
                        }
                        const dot = document.getElementById('header-fr-dot-' + fsId);
                        if (dot) dot.remove();
                        decrementHeaderBadge();
                    }).catch(function(err) {
                        console.error('Error in respondFriendHeader:', err);
                        if (actionsDiv) {
                            actionsDiv.innerHTML = '<span class="text-danger" style="font-size: 11px;">Failed. Please refresh.</span>';
                        }
                    });
                }

                function headerMarkSingleRead(e, notifId, link) {
                    if (!notifId) return;
                    const dot = document.getElementById('header-notif-dot-' + notifId);
                    if (dot) dot.remove();
                    const item = document.getElementById('header-notif-' + notifId);
                    if (item) {
                        item.classList.remove('is-unread');
                        item.classList.add('is-read');
                    }
                    decrementHeaderBadge();

                    const formData = new URLSearchParams();
                    formData.append('csrfToken', headerCsrfToken);
                    formData.append('action', 'markRead');
                    formData.append('notificationId', notifId);

                    fetch(headerContextPath + '/notifications', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: formData.toString()
                    }).catch(function() {});
                }

                function headerMarkAllRead(e) {
                    if (e) e.preventDefault();
                    document.querySelectorAll('#headerNotifList .lt-notif-dot').forEach(function(dot) {
                        dot.remove();
                    });
                    document.querySelectorAll('#headerNotifList .lt-notif-item').forEach(function(item) {
                        item.classList.remove('is-unread');
                        item.classList.add('is-read');
                    });
                    const badge = document.getElementById('headerNotifBadge');
                    if (badge) {
                        badge.classList.add('d-none');
                        badge.textContent = '0';
                    }

                    const formData = new URLSearchParams();
                    formData.append('csrfToken', headerCsrfToken);
                    formData.append('action', 'markAllRead');

                    fetch(headerContextPath + '/notifications', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: formData.toString()
                    }).catch(function() {});
                }
            </script>
        <% } %>

        <button class="navbar-toggler"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#mainNavigation"
                aria-controls="mainNavigation"
                aria-expanded="false"
                aria-label="Open navigation">

            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse"
             id="mainNavigation">

            <% if (headerIsUser) { %>

                <ul class="navbar-nav me-auto app-nav-links">

                    <li class="nav-item">
                        <a class="nav-link"
                           href="<%= request.getContextPath() %>/user">
                            Overview
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link"
                           href="<%= request.getContextPath() %>/trips">
                            Trips
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link"
                           href="<%= request.getContextPath() %>/places">
                            Places
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/dump">Dump</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/passport">Passport</a>
                    </li>
                </ul>

            <% } else if (headerIsAdmin) { %>

                <ul class="navbar-nav me-auto app-nav-links">

                    <li class="nav-item">
                        <a class="nav-link"
                           href="<%= request.getContextPath() %>/admin">
                            Overview
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link"
                           href="<%= request.getContextPath() %>/admin/users">
                            Users
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link"
                           href="<%= request.getContextPath() %>/admin/places">
                            Places
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link"
                           href="<%= request.getContextPath() %>/admin/audit-logs">
                            Dump
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/admin/dump-reports">Dump Reports</a>
                    </li>
                    <% if (ScenarioLabConfig.isScenarioLabEnabled()) { %>
                    <li class="nav-item">
                        <a class="nav-link text-warning fw-bold" href="<%= request.getContextPath() %>/admin/lab">🧪 Lab</a>
                    </li>
                    <% } %>
                </ul>

            <% } %>

            <% if (headerUser != null) { %>

                <div class="app-user-menu ms-lg-auto">

                    <div class="app-avatar">
                        <%= HtmlUtil.escape(
                                headerUser.getFullName()
                                        .substring(0, 1)
                                        .toUpperCase()
                        ) %>
                    </div>

                    <div class="app-user-info">
                        <span class="app-user-name">
                            <%= HtmlUtil.escape(
                                    headerUser.getFullName()
                            ) %>
                        </span>

                        <span class="app-user-role">
                            <%= HtmlUtil.escape(
                                    headerIsAdmin ? "Administrator" : "Member"
                            ) %>
                        </span>
                    </div>

                    <a href="<%= request.getContextPath() %>/logout"
                       class="btn app-logout-btn">
                        Sign out
                    </a>
                </div>

            <% } else { %>

                <div class="ms-lg-auto d-flex gap-2">

                    <a href="<%= request.getContextPath() %>/login"
                       class="btn btn-outline-light">
                        Sign in
                    </a>

                    <a href="<%= request.getContextPath() %>/register"
                       class="btn btn-light">
                        Register
                    </a>
                </div>

            <% } %>
        </div>
    </div>
</nav>

<main class="container app-main" id="main-content" tabindex="-1">
<%
    Object workspaceTripObject = request.getAttribute("currentTrip");
    if (workspaceTripObject == null) workspaceTripObject = request.getAttribute("trip");
    if (headerIsUser && !Boolean.TRUE.equals(request.getAttribute("tripRedesign")) && workspaceTripObject instanceof model.Trip) {
        model.Trip workspaceTrip = (model.Trip) workspaceTripObject;
        if (workspaceTrip.getTripId() > 0) {
%>
<div class="trip-layout"><aside class="trip-workspace">
    <div class="trip-workspace-label">Trip workspace · <%= HtmlUtil.escape(workspaceTrip.getTripName()) %></div>
    <nav aria-label="Trip features">
        <a href="<%= request.getContextPath() %>/trip/detail?tripId=<%= workspaceTrip.getTripId() %>">Overview</a>
        <a href="<%= request.getContextPath() %>/preferences?tripId=<%= workspaceTrip.getTripId() %>">My Preferences</a>
        <a href="<%= request.getContextPath() %>/preferences/group?tripId=<%= workspaceTrip.getTripId() %>">Group Preferences</a>
        <a href="<%= request.getContextPath() %>/recommendations?tripId=<%= workspaceTrip.getTripId() %>">Place Suggestions</a>
        <a href="<%= request.getContextPath() %>/combo?tripId=<%= workspaceTrip.getTripId() %>">Combos</a>
        <a href="<%= request.getContextPath() %>/itinerary?tripId=<%= workspaceTrip.getTripId() %>">Itinerary</a>
        <a href="<%= request.getContextPath() %>/expenses?tripId=<%= workspaceTrip.getTripId() %>">Expenses</a>
        <a href="<%= request.getContextPath() %>/settlement?tripId=<%= workspaceTrip.getTripId() %>">Settlement</a>
        <a href="<%= request.getContextPath() %>/group-fund?tripId=<%= workspaceTrip.getTripId() %>">Group Fund</a>
    </nav>
</aside><div class="trip-content">
<% request.setAttribute("hasTripLayout", Boolean.TRUE); } } %>

    <% if (headerError != null
            && !headerError.isEmpty()) { %>

        <div class="app-alert app-alert-error">
            <span class="app-alert-icon">!</span>

            <span>
                <%= HtmlUtil.escape(headerError) %>
            </span>
        </div>

    <% } %>

    <% if (headerSuccess != null
            && !headerSuccess.isEmpty()) { %>

        <div class="app-alert app-alert-success">
            <span class="app-alert-icon">✓</span>

            <span>
                <%= HtmlUtil.escape(headerSuccess) %>
            </span>
        </div>

    <% } %>


<% boolean redesignAuth = headerUser == null && java.util.Arrays.asList("Sign in", "Register", "Forgot password", "Reset password").contains(pageTitleText);
   if (redesignAuth) { request.setAttribute("hasAuthLayout", Boolean.TRUE); %>
<div class="rd-auth-layout">
    <section class="rd-auth-welcome" aria-label="About LocalTrip">
        <span class="eyebrow">LOCALTRIP · EXPLORE TOGETHER</span>
        <h1>Trips are better<br>together.</h1>
        <p>Plan memorable journeys, discover exciting places, and share adventures with friends.</p>
        <div class="rd-auth-features"><span>Discover places</span><span>Group planning</span><span>Split expenses</span></div>
    </section>
    <div class="rd-auth-form">
<% } %>

