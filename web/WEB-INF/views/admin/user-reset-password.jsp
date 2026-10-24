<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="model.User,utils.HtmlUtil" %>

<%
    User item = (User) request.getAttribute("item");

    request.setAttribute("pageTitle", "Reset Password");
    request.setAttribute("tripRedesign", Boolean.TRUE);
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · USER ADMINISTRATION
            </div>

            <h1 class="mb-2">Reset Password</h1>

            <p class="text-white mb-0">
                Generate a new password for this user account.
            </p>
        </div>

        <a class="rd-back"
           href="<%= request.getContextPath() %>/admin/users">
            ← User List
        </a>
    </div>
</section>

<div class="row justify-content-center">
    <div class="col-12 col-lg-7">
        <section class="rd-card">
            <% if (item == null) { %>

                <h2 class="h4 mb-3">User Not Found</h2>

                <p class="text-muted mb-4">
                    Return to the user list to select an account.
                </p>

                <a class="btn btn-outline-secondary"
                   href="<%= request.getContextPath() %>/admin/users">
                    User List
                </a>

            <% } else { %>

                <div class="border-bottom pb-4 mb-4">
                    <div class="small text-muted mb-2">
                        Target User Account
                    </div>

                    <h2 class="h4 mb-1"
                        style="overflow-wrap:anywhere;">
                        <%= HtmlUtil.escape(item.getFullName()) %>
                    </h2>

                    <p class="text-muted mb-0"
                       style="overflow-wrap:anywhere;">
                        <%= HtmlUtil.escape(item.getEmail()) %>
                    </p>
                </div>

                <form id="adminResetForm"
                      method="post"
                      action="<%= request.getContextPath() %>/admin/users/reset-password">`r`n                    <input type="hidden" name="csrfToken" value="<%= session.getAttribute("travelCsrf") %>">

                    <input type="hidden"
                           name="userId"
                           value="<%= item.getUserId() %>">

                    <div class="mb-3">
                        <label for="adminNewPassword"
                               class="form-label fw-semibold">
                            New Password
                        </label>

                        <input type="password"
                               id="adminNewPassword"
                               name="password"
                               class="form-control"
                               minlength="8"
                               maxlength="64"
                               pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,64}"
                               title="Password must be 8–64 characters with uppercase, lowercase, number, and special character."
                               autocomplete="new-password"
                               aria-describedby="adminPasswordHelp"
                               required>

                        <div id="adminPasswordHelp" class="form-text">
                            8 to 64 characters, including uppercase, lowercase, number, and symbol.
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="adminConfirmPassword"
                               class="form-label fw-semibold">
                            Confirm New Password
                        </label>

                        <input type="password"
                               id="adminConfirmPassword"
                               name="confirmPassword"
                               class="form-control"
                               minlength="8"
                               maxlength="64"
                               autocomplete="new-password"
                               required>
                    </div>

                    <div class="form-check mb-4">
                        <input type="checkbox"
                               id="showAdminPasswords"
                               class="form-check-input">

                        <label for="showAdminPasswords"
                               class="form-check-label">
                            Show password
                        </label>
                    </div>

                    <div class="border-top pt-4 d-flex flex-wrap gap-2">
                        <button type="submit"
                                class="btn btn-primary px-4">
                            Save New Password
                        </button>

                        <a class="btn btn-outline-secondary px-4"
                           href="<%= request.getContextPath() %>/admin/users">
                            Cancel
                        </a>
                    </div>
                </form>

            <% } %>
        </section>
    </div>
</div>

<script>
(function () {
    const form = document.getElementById('adminResetForm');

    if (!form) {
        return;
    }

    const password = document.getElementById('adminNewPassword');
    const confirmation = document.getElementById('adminConfirmPassword');
    const toggle = document.getElementById('showAdminPasswords');

    function validateConfirmation() {
        confirmation.setCustomValidity(
            confirmation.value && confirmation.value !== password.value
                ? 'Password confirmation does not match.'
                : ''
        );
    }

    password.addEventListener('input', validateConfirmation);
    confirmation.addEventListener('input', validateConfirmation);

    toggle.addEventListener('change', function () {
        const type = toggle.checked ? 'text' : 'password';
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