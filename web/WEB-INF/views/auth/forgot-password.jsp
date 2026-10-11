<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%
    request.setAttribute("pageTitle", "Quên mật khẩu");
    String emailValue = request.getParameter("email");
    String devResetUrl = (String) request.getAttribute("devResetUrl");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-card">
    <div class="mb-4">
        <h2 class="h3 mb-2">Quên mật khẩu?</h2>

        <p class="text-muted mb-0">
            Nhập email đã đăng ký để yêu cầu
            liên kết đặt lại mật khẩu.
        </p>
    </div>

    <form method="post"
          action="<%= request.getContextPath() %>/forgot-password">

        <div class="mb-4">
            <label for="recoveryEmail"
                   class="form-label fw-semibold">
                Email tài khoản
            </label>

            <input type="email"
                   id="recoveryEmail"
                   name="email"
                   class="form-control"
                   value="<%= utils.HtmlUtil.escape(emailValue) %>"
                   placeholder="ban@example.com"
                   autocomplete="email"
                   required
                   aria-describedby="recoveryHelp">

            <div id="recoveryHelp" class="form-text">
                Nếu tài khoản tồn tại, hệ thống sẽ tạo
                liên kết có hiệu lực trong 30 phút.
            </div>
        </div>

        <button type="submit"
                class="btn btn-primary w-100 py-2">
            Yêu cầu đặt lại mật khẩu
        </button>
    </form>

    <% if (devResetUrl != null) { %>
        <div class="alert alert-warning mt-4 mb-0">
            <strong class="d-block mb-2">
                Liên kết thử nghiệm
            </strong>

            <p class="small mb-3">
                Phiên bản hiện tại chưa gửi email.
                Dùng liên kết dưới đây để thử đặt lại mật khẩu.
            </p>

            <a href="<%= utils.HtmlUtil.escape(devResetUrl) %>"
               class="fw-semibold">
                Đặt lại mật khẩu →
            </a>
        </div>
    <% } %>

    <div class="border-top mt-4 pt-4 text-center">
        <a href="<%= request.getContextPath() %>/login">
            ← Quay lại đăng nhập
        </a>
    </div>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>