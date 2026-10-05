<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<<<<<<< HEAD

<%
    request.setAttribute("pageTitle", "Đăng ký");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-5">

        <div class="app-card">
            <h3 class="mb-4 text-center">
                Tạo tài khoản
            </h3>

            <form method="post"
                  action="<%= request.getContextPath() %>/register">

                <div class="mb-3">
                    <label for="fullName" class="form-label">
                        Họ tên
                    </label>

                    <input type="text"
                           id="fullName"
                           name="fullName"
                           class="form-control"
                           maxlength="100"
                           autocomplete="name"
                           required
                           autofocus>
                </div>

                <div class="mb-3">
                    <label for="email" class="form-label">
                        Email
                    </label>

                    <input type="email"
                           id="email"
                           name="email"
                           class="form-control"
                           maxlength="150"
                           autocomplete="email"
                           required>
                </div>

                <div class="mb-3">
                    <label for="password" class="form-label">
                        Mật khẩu
                    </label>

                    <input type="password"
                           id="password"
                           name="password"
                           class="form-control"
                           minlength="8"
                           maxlength="64"
                           pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,64}"
                           title="Mật khẩu phải có 8–64 ký tự, gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt."
                           autocomplete="new-password"
                           required>

                    <div class="form-text">
                        Từ 8 đến 64 ký tự, gồm chữ hoa, chữ thường,
                        chữ số và ký tự đặc biệt.
                    </div>
                </div>

                <div class="mb-3">
                    <label for="confirmPassword" class="form-label">
                        Nhập lại mật khẩu
                    </label>

                    <input type="password"
                           id="confirmPassword"
                           name="confirmPassword"
                           class="form-control"
                           minlength="8"
                           maxlength="64"
                           autocomplete="new-password"
                           required>
                </div>

                <p class="text-muted small">
                    Tài khoản đăng ký mới sẽ được cấp role USER mặc định.
                </p>

                <button type="submit"
                        class="btn btn-brand w-100">
                    Đăng ký
                </button>
=======
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Đăng ký" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-5">
        <div class="app-card">
            <h3 class="mb-4 text-center">Tạo tài khoản</h3>

            <form method="post" action="${pageContext.request.contextPath}/register">
                <div class="mb-3">
                    <label class="form-label">Họ tên</label>
                    <input type="text" name="fullName" class="form-control"
                           value="${param.fullName}" required autofocus>
                </div>
                <div class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control"
                           value="${param.email}" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Mật khẩu</label>
                    <input type="password" name="password" class="form-control" required minlength="6">
                </div>
                <div class="mb-3">
                    <label class="form-label">Nhập lại mật khẩu</label>
                    <input type="password" name="confirmPassword" class="form-control" required minlength="6">
                </div>
                <button type="submit" class="btn btn-brand w-100">Đăng ký</button>
>>>>>>> 1f8cf38 (Update UI)
            </form>

            <p class="text-center mt-3 mb-0">
                Đã có tài khoản?
<<<<<<< HEAD
                <a href="<%= request.getContextPath() %>/login">
                    Đăng nhập
                </a>
=======
                <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
>>>>>>> 1f8cf38 (Update UI)
            </p>
        </div>
    </div>
</div>

<<<<<<< HEAD
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
=======
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
>>>>>>> 1f8cf38 (Update UI)
