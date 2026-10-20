<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%
    request.setAttribute("pageTitle", "Register");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-card">
    <div class="mb-4">
        <h2 class="h3 mb-2">Create your LocalTrip account</h2>

        <p class="text-muted mb-0">
            Start planning journeys and exploring the world with friends.
        </p>
    </div>

    <form id="registerForm"
          method="post"
          action="<%= request.getContextPath() %>/register">

        <div class="mb-3">
            <label for="fullName" class="form-label fw-semibold">
                Full name
            </label>

            <input type="text"
                   id="fullName"
                   name="fullName"
                   class="form-control"
                   placeholder="Enter your full name"
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
                   placeholder="you@example.com"
                   maxlength="150"
                   autocomplete="email"
                   required>
        </div>

        <div class="mb-3">
            <label for="password" class="form-label fw-semibold">
                Password
            </label>

            <input type="password"
                   id="password"
                   name="password"
                   class="form-control"
                   minlength="8"
                   maxlength="64"
                   pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,64}"
                   title="Password must be 8–64 characters with uppercase, lowercase, number and special character."
                   aria-describedby="passwordHelp"
                   autocomplete="new-password"
                   required>

            <div id="passwordHelp" class="form-text">
                8 to 64 characters, including uppercase, lowercase, numbers, and symbols.
            </div>
        </div>

        <div class="mb-3">
            <label for="confirmPassword"
                   class="form-label fw-semibold">
                Confirm password
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
                Show passwords
            </label>
        </div>

        <button type="submit"
                class="btn btn-primary w-100 py-2">
            Create account
        </button>
    </form>

    <div class="border-top mt-4 pt-4 text-center">
        <p class="mb-0">
            Already have an account?
            <a href="<%= request.getContextPath() %>/login">
                Sign in
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
                ? 'Passwords do not match.'
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
