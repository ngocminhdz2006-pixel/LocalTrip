<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%
    request.setAttribute("pageTitle", "Đăng ký");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-card">
    <div class="mb-4">
        <h2 class="h3 mb-2">Tạo tài khoản LocalTrip</h2>

        <p class="text-muted mb-0">
            Bắt đầu lên kế hoạch và khám phá cùng bạn bè.
        </p>
    </div>

    <form id="registerForm"
          method="post"
          action="<%= request.getContextPath() %>/register">

        <div class="mb-3">
            <label for="fullName" class="form-label fw-semibold">
                Họ tên
            </label>

            <input type="text"
                   id="fullName"
                   name="fullName"
                   class="form-control"
                   placeholder="Nhập họ tên của bạn"
                   maxlength="100"
                   autocomplete="name"
                   required>
        </div>

        <div class="mb-3">
            <label for="email" class="form-label fw-semibold">
                Email
            </label>

            <input type="email"
                   id="email"
                   name="email"
                   class="form-control"
                   placeholder="ban@example.com"
                   maxlength="150"
                   autocomplete="email"
                   required>
        </div>

        <div class="mb-3">
            <label for="password" class="form-label fw-semibold">
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
                   aria-describedby="passwordHelp"
                   autocomplete="new-password"
                   required>

            <div id="passwordHelp" class="form-text">
                Từ 8 đến 64 ký tự, gồm chữ hoa, chữ thường,
                chữ số và ký tự đặc biệt.
            </div>
        </div>

        <div class="mb-3">
            <label for="confirmPassword"
                   class="form-label fw-semibold">
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

        <div class="form-check mb-4">
            <input class="form-check-input"
                   type="checkbox"
                   id="showRegisterPasswords">

            <label class="form-check-label"
                   for="showRegisterPasswords">
                Hiển thị mật khẩu
            </label>
        </div>

        <button type="submit"
                class="btn btn-primary w-100 py-2">
            Tạo tài khoản
        </button>
    </form>

    <div class="border-top mt-4 pt-4 text-center">
        <p class="mb-0">
            Đã có tài khoản?
            <a href="<%= request.getContextPath() %>/login">
                Đăng nhập
            </a>
        </p>
    </div>
</section>

<script>
(function () {
    const form = document.getElementById('registerForm');
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirmPassword');
    const showPasswords = document.getElementById('showRegisterPasswords');

    function validateConfirmation() {
        confirmPassword.setCustomValidity(
            confirmPassword.value
                && confirmPassword.value !== password.value
                ? 'Mật khẩu nhập lại chưa khớp.'
                : ''
        );
    }

    password.addEventListener('input', validateConfirmation);
    confirmPassword.addEventListener('input', validateConfirmation);

    showPasswords.addEventListener('change', function () {
        const type = showPasswords.checked ? 'text' : 'password';
        password.type = type;
        confirmPassword.type = type;
    });

    form.addEventListener('submit', function (event) {
        validateConfirmation();

        if (!form.checkValidity()) {
            event.preventDefault();
            form.reportValidity();
        }
    });
})();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>