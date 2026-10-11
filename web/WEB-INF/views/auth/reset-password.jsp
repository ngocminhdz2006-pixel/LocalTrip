<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%
    request.setAttribute("pageTitle", "Đặt lại mật khẩu");
    String token = (String) request.getAttribute("token");
    String resetSuccess = (String) request.getAttribute("successMessage");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-card">
    <div class="mb-4">
        <h2 class="h3 mb-2">Đặt lại mật khẩu</h2>

        <p class="text-muted mb-0">
            Tạo mật khẩu mới để tiếp tục sử dụng LocalTrip.
        </p>
    </div>

    <% if (resetSuccess != null) { %>

        <a class="btn btn-primary w-100 py-2"
           href="<%= request.getContextPath() %>/login">
            Đăng nhập
        </a>

    <% } else if (token != null && !token.isEmpty()) { %>

        <form id="resetPasswordForm"
              method="post"
              action="<%= request.getContextPath() %>/reset-password">

            <input type="hidden"
                   name="token"
                   value="<%= utils.HtmlUtil.escape(token) %>">

            <div class="mb-3">
                <label for="newPassword"
                       class="form-label fw-semibold">
                    Mật khẩu mới
                </label>

                <input type="password"
                       id="newPassword"
                       name="password"
                       class="form-control"
                       minlength="8"
                       maxlength="64"
                       pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,64}"
                       title="Mật khẩu phải có 8–64 ký tự, gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt."
                       autocomplete="new-password"
                       aria-describedby="newPasswordHelp"
                       required>

                <div id="newPasswordHelp" class="form-text">
                    Từ 8 đến 64 ký tự, gồm chữ hoa, chữ thường,
                    chữ số và ký tự đặc biệt.
                </div>
            </div>

            <div class="mb-3">
                <label for="confirmNewPassword"
                       class="form-label fw-semibold">
                    Nhập lại mật khẩu mới
                </label>

                <input type="password"
                       id="confirmNewPassword"
                       name="confirmPassword"
                       class="form-control"
                       minlength="8"
                       maxlength="64"
                       autocomplete="new-password"
                       required>
            </div>

            <div class="form-check mb-4">
                <input type="checkbox"
                       class="form-check-input"
                       id="showResetPasswords">

                <label class="form-check-label"
                       for="showResetPasswords">
                    Hiển thị mật khẩu
                </label>
            </div>

            <button type="submit"
                    class="btn btn-primary w-100 py-2">
                Lưu mật khẩu mới
            </button>
        </form>

    <% } else { %>

        <p class="text-muted mb-4">
            Hãy yêu cầu liên kết mới để đặt lại mật khẩu.
        </p>

        <a class="btn btn-primary w-100 py-2"
           href="<%= request.getContextPath() %>/forgot-password">
            Yêu cầu liên kết mới
        </a>

    <% } %>

    <% if (resetSuccess == null) { %>
        <div class="border-top mt-4 pt-4 text-center">
            <a href="<%= request.getContextPath() %>/login">
                ← Quay lại đăng nhập
            </a>
        </div>
    <% } %>
</section>

<script>
(function () {
    const form = document.getElementById('resetPasswordForm');

    if (!form) {
        return;
    }

    const password = document.getElementById('newPassword');
    const confirmation = document.getElementById('confirmNewPassword');
    const showPasswords = document.getElementById('showResetPasswords');

    function validateConfirmation() {
        confirmation.setCustomValidity(
            confirmation.value && confirmation.value !== password.value
                ? 'Mật khẩu nhập lại chưa khớp.'
                : ''
        );
    }

    password.addEventListener('input', validateConfirmation);
    confirmation.addEventListener('input', validateConfirmation);

    showPasswords.addEventListener('change', function () {
        const type = showPasswords.checked ? 'text' : 'password';
        password.type = type;
        confirmation.type = type;
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