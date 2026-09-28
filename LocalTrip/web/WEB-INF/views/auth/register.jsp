<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
            </form>

            <p class="text-center mt-3 mb-0">
                Đã có tài khoản?
                <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
            </p>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
