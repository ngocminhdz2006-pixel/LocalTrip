<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%
    request.setAttribute("pageTitle", "Reset password");
    String token = (String) request.getAttribute("token");
    String resetSuccess = (String) request.getAttribute("successMessage");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-card">
    <div class="mb-4">
        <h2 class="h3 mb-2">Reset password</h2>

        <p class="text-muted mb-0">
            Create a new password to secure and access your LocalTrip account.
        </p>
    </div>

    <% if (resetSuccess != null) { %>

        <a class="btn btn-primary w-100 py-2"
           href="<%= request.getContextPath() %>/login">
            Sign in
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
                    New password
                </label>

                <input type="password"
                       id="newPassword"
                       name="password"
                       class="form-control"
                       minlength="8"
                       maxlength="64"
                       pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,64}"
                       title="Password must be 8–64 characters with uppercase, lowercase, number and special character."
                       autocomplete="new-password"
                       aria-describedby="newPasswordHelp"
                       required>

                <div id="newPasswordHelp" class="form-text">
                    8 to 64 characters, including uppercase, lowercase, numbers, and symbols.
                </div>
            </div>

            <div class="mb-3">
                <label for="confirmNewPassword"
                       class="form-label fw-semibold">
                    Confirm new password
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
                <input class="form-check-input"
                       type="checkbox"
                       id="showResetPasswords">

                <label class="form-check-label"
                       for="showResetPasswords">
                    Show passwords
                </label>
            </div>

            <button type="submit"
                    class="btn btn-primary w-100 py-2">
                Update password
            </button>
        </form>

    <% } else { %>

        <p class="text-muted">
            The reset token is missing, invalid or expired.
        </p>

        <a class="btn btn-secondary w-100 py-2"
           href="<%= request.getContextPath() %>/forgot-password">
            Request new reset link
        </a>

    <% } %>

    <div class="border-top mt-4 pt-4 text-center">
        <p class="mb-0">
            Remembered your credentials?
            <a href="<%= request.getContextPath() %>/login">
                Sign in
            </a>
        </p>
    </div>
</section>

<script>
(function () {
    const form = document.getElementById('resetPasswordForm');
    const password = document.getElementById('newPassword');
    const confirmPassword = document.getElementById('confirmNewPassword');
    const showPasswords = document.getElementById('showResetPasswords');

    if (!form || !password || !confirmPassword) {
        return;
    }

    function validateConfirmation() {
        confirmPassword.setCustomValidity(
            confirmPassword.value
                && confirmPassword.value !== password.value
                ? 'Passwords do not match.'
                : ''
        );
    }

    password.addEventListener('input', validateConfirmation);
    confirmPassword.addEventListener('input', validateConfirmation);

    if (showPasswords) {
        showPasswords.addEventListener('change', function () {
            const type = showPasswords.checked ? 'text' : 'password';
            password.type = type;
            confirmPassword.type = type;
        });
    }

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
