<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%
    request.setAttribute("pageTitle", "Đăng nhập");
    String emailValue = request.getParameter("email");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-card">
    <div class="mb-4">
        <h2 class="h3 mb-2">Chào mừng bạn trở lại</h2>

        <p class="text-muted mb-0">
            Đăng nhập để tiếp tục hành trình cùng LocalTrip.
        </p>
    </div>

    <form method="post"
          action="<%= request.getContextPath() %>/login">

        <div class="mb-3">
            <label for="loginEmail"
                   class="form-label fw-semibold">
                Email
            </label>

            <input type="email"
                   id="loginEmail"
                   name="email"
                   class="form-control"
                   value="<%= utils.HtmlUtil.escape(emailValue) %>"
                   placeholder="ban@example.com"
                   autocomplete="email"
                   required>
        </div>

        <div class="mb-3">
            <label for="loginPassword"
                   class="form-label fw-semibold">
                Mật khẩu
            </label>

            <input type="password"
                   id="loginPassword"
                   name="password"
                   class="form-control"
                   autocomplete="current-password"
                   required>
        </div>

        <div class="form-check mb-3">
            <input class="form-check-input"
                   type="checkbox"
                   id="showLoginPassword">

            <label class="form-check-label"
                   for="showLoginPassword">
                Hiển thị mật khẩu
            </label>
        </div>

        <div class="form-check mb-4">
            <input class="form-check-input"
                   type="checkbox"
                   name="rememberMe"
                   id="rememberMe">

            <label class="form-check-label"
                   for="rememberMe">
                Ghi nhớ đăng nhập trên thiết bị này (30 ngày)
            </label>
        </div>

        <button type="submit"
                class="btn btn-primary w-100 py-2">
            Đăng nhập
        </button>
    </form>

    <div class="text-center mt-3">
        <a href="<%= request.getContextPath() %>/forgot-password">
            Quên mật khẩu?
        </a>
    </div>

    <div class="border-top mt-4 pt-4 text-center">
        <p class="mb-0">
            Chưa có tài khoản?
            <a href="<%= request.getContextPath() %>/register">
                Đăng ký ngay
            </a>
        </p>
    </div>
</section>

<script>
(function () {
    const password = document.getElementById('loginPassword');
    const showPassword = document.getElementById('showLoginPassword');

    showPassword.addEventListener('change', function () {
        password.type = showPassword.checked ? 'text' : 'password';
    });
})();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>