<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="model.User,utils.HtmlUtil" %>

<%
    User item = (User) request.getAttribute("item");
    boolean editMode = item != null;

    String fullNameValue = request.getParameter("fullName");
    String emailValue = request.getParameter("email");
    String roleValue = request.getParameter("role");

    if (fullNameValue == null) {
        fullNameValue = editMode ? item.getFullName() : "";
    }

    if (emailValue == null) {
        emailValue = editMode ? item.getEmail() : "";
    }

    if (roleValue == null || roleValue.trim().isEmpty()) {
        roleValue = editMode ? item.getRole() : "USER";
    }

    boolean activeValue;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        activeValue = request.getParameter("active") != null;
    } else {
        activeValue = editMode ? item.isActive() : true;
    }

    String formTitle = editMode
        ? "Sửa người dùng" : "Thêm người dùng";

    String formAction = editMode
        ? "/admin/users/edit" : "/admin/users/create";

    request.setAttribute("pageTitle", formTitle);
    request.setAttribute("tripRedesign", Boolean.TRUE);
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · QUẢN TRỊ TÀI KHOẢN
            </div>

            <h1 class="mb-2"><%= formTitle %></h1>

            <p class="text-white mb-0">
                <%= editMode
                    ? "Cập nhật thông tin, vai trò và trạng thái tài khoản."
                    : "Tạo tài khoản mới trong hệ thống LocalTrip." %>
            </p>
        </div>

        <a class="rd-back"
           href="<%= request.getContextPath() %>/admin/users">
            ← Danh sách người dùng
        </a>
    </div>
</section>

<div class="row justify-content-center">
    <div class="col-12 col-lg-8">
        <section class="rd-card">
            <h2 class="h4 mb-4">Thông tin tài khoản</h2>

            <form id="adminUserForm"
                  method="post"
                  action="<%= request.getContextPath() + formAction %>">`r`n                <input type="hidden" name="csrfToken" value="<%= session.getAttribute("travelCsrf") %>">

                <% if (editMode) { %>
                    <input type="hidden"
                           name="userId"
                           value="<%= item.getUserId() %>">
                <% } %>

                <div class="mb-3">
                    <label for="userFullName"
                           class="form-label fw-semibold">
                        Họ tên
                    </label>

                    <input type="text"
                           id="userFullName"
                           name="fullName"
                           class="form-control"
                           maxlength="100"
                           value="<%= HtmlUtil.escape(fullNameValue) %>"
                           required>
                </div>

                <div class="mb-4">
                    <label for="userEmail"
                           class="form-label fw-semibold">
                        Email
                    </label>

                    <input type="email"
                           id="userEmail"
                           name="email"
                           class="form-control"
                           maxlength="150"
                           value="<%= HtmlUtil.escape(emailValue) %>"
                           required>
                </div>

                <% if (!editMode) { %>
                    <div class="row g-3 mb-3">
                        <div class="col-12 col-md-6">
                            <label for="userPassword"
                                   class="form-label fw-semibold">
                                Mật khẩu
                            </label>

                            <input type="password"
                                   id="userPassword"
                                   name="password"
                                   class="form-control"
                                   minlength="8"
                                   maxlength="64"
                                   pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,64}"
                                   title="Mật khẩu phải có 8–64 ký tự, gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt."
                                   autocomplete="new-password"
                                   aria-describedby="userPasswordHelp"
                                   required>
                        </div>

                        <div class="col-12 col-md-6">
                            <label for="userConfirmPassword"
                                   class="form-label fw-semibold">
                                Nhập lại mật khẩu
                            </label>

                            <input type="password"
                                   id="userConfirmPassword"
                                   name="confirmPassword"
                                   class="form-control"
                                   minlength="8"
                                   maxlength="64"
                                   autocomplete="new-password"
                                   required>
                        </div>
                    </div>

                    <p id="userPasswordHelp" class="small text-muted">
                        Từ 8 đến 64 ký tự, gồm chữ hoa,
                        chữ thường, chữ số và ký tự đặc biệt.
                    </p>

                    <div class="form-check mb-4">
                        <input type="checkbox"
                               id="showUserPasswords"
                               class="form-check-input">

                        <label for="showUserPasswords"
                               class="form-check-label">
                            Hiển thị mật khẩu
                        </label>
                    </div>
                <% } %>

                <div class="border-top pt-4">
                    <div class="mb-3">
                        <label for="userRole"
                               class="form-label fw-semibold">
                            Vai trò
                        </label>

                        <select id="userRole"
                                name="role"
                                class="form-select"
                                required>
                            <option value="USER"
                                    <%= "USER".equals(roleValue) ? "selected" : "" %>>
                                Người dùng
                            </option>

                            <option value="ADMIN"
                                    <%= "ADMIN".equals(roleValue) ? "selected" : "" %>>
                                Quản trị viên
                            </option>
                        </select>
                    </div>

                    <div class="form-check mb-4">
                        <input type="checkbox"
                               name="active"
                               id="active"
                               class="form-check-input"
                               <%= activeValue ? "checked" : "" %>>

                        <label for="active" class="form-check-label">
                            Tài khoản đang hoạt động
                        </label>
                    </div>
                </div>

                <div class="border-top pt-4 d-flex flex-wrap gap-2">
                    <button type="submit"
                            class="btn btn-primary px-4">
                        <%= editMode ? "Lưu thay đổi" : "Tạo người dùng" %>
                    </button>

                    <a class="btn btn-outline-secondary px-4"
                       href="<%= request.getContextPath() %>/admin/users">
                        Hủy
                    </a>
                </div>
            </form>
        </section>
    </div>
</div>

<script>
(function () {
    const form = document.getElementById('adminUserForm');
    const password = document.getElementById('userPassword');
    const confirmation = document.getElementById('userConfirmPassword');
    const toggle = document.getElementById('showUserPasswords');

    if (!password || !confirmation || !toggle) {
        return;
    }

    function validateConfirmation() {
        confirmation.setCustomValidity(
            confirmation.value && confirmation.value !== password.value
                ? 'Mật khẩu nhập lại chưa khớp.'
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