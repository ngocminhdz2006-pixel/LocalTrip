<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:if test="${not empty pageTitle}">${pageTitle} - </c:if>Trip Planner</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<nav class="navbar navbar-expand-lg app-navbar navbar-dark mb-4">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/trips">🧳 Trip Planner</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="mainNav">
            <c:if test="${not empty sessionScope.user}">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/trips">My Trips</a>
                    </li>
                    <c:if test="${not empty currentTrip}">
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/trip/detail?tripId=${currentTrip.id}">Trip Detail</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/preferences?tripId=${currentTrip.id}">Preferences</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/recommendations?tripId=${currentTrip.id}">Recommendation</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/itinerary?tripId=${currentTrip.id}">Itinerary</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/expenses?tripId=${currentTrip.id}">Expenses</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/settlement?tripId=${currentTrip.id}">Settlement</a>
                        </li>
                    </c:if>
                </ul>
                <span class="navbar-text text-white me-3">
                    Xin chào, <strong>${sessionScope.user.fullName}</strong>
                </span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Đăng xuất</a>
            </c:if>
            <c:if test="${empty sessionScope.user}">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/register">Đăng ký</a>
                    </li>
                </ul>
            </c:if>
        </div>
    </div>
</nav>

<div class="container pb-5">
    <c:if test="${not empty errorMessage}">
        <div class="msg-error">${errorMessage}</div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="msg-success">${successMessage}</div>
    </c:if>
    <%-- Flash message tu session: dung khi servlet phai redirect (vd loi 403
         khi da dang nhap, quay ve /trips) nen khong the dùng request attribute.
         Hien xong la xoa ngay de khong lap lai o lan xem trang sau. --%>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="msg-error">${sessionScope.errorMessage}</div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="msg-success">${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
