<%@ page pageEncoding="UTF-8" language="java" %>
<%@ page import="model.User,utils.HtmlUtil" %>

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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mobile-user.css?v=2">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mobile-auth.css?v=2">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css?v=1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css?v=1">
</head>

<body class="rd-page <%= headerUser == null ? "auth-page" : (headerIsAdmin ? "admin-page" : "user-page") %> <%= Boolean.TRUE.equals(request.getAttribute("isLoginPage")) ? "login-page" : "" %>">
<a class="skip-link" href="#main-content">Skip to content</a>

<nav class="navbar navbar-expand-lg app-navbar sticky-top">
    <div class="container">

        <a class="navbar-brand app-brand"
           href="<%= headerHomeUrl %>">

            <span class="app-brand-icon">L</span>

            <span>
                Local<span>Trip</span>
            </span>
        </a>

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


<% boolean redesignAuth = headerUser == null && java.util.Arrays.asList("Sign in", "Register", "Forgot password", "Reset password", "Đăng ký", "Quên mật khẩu", "Đặt lại mật khẩu").contains(pageTitleText);
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

