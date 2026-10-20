<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" language="java" %>
<%
    request.setAttribute("pageTitle", "Forgot password");
    String emailValue = request.getParameter("email");
    if (emailValue == null) {
        emailValue = "";
    }
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-card lt-signin" style="max-width: 440px; margin: 0 auto;">

    <div class="lt-signin-brand">
        <div class="lt-signin-logo">
            Local<span>Trip</span>
        </div>
    </div>

    <h2 class="lt-signin-title">Reset password</h2>
    <p class="lt-signin-sub">
        Enter your registered email address and we will help you regain access to your account.
    </p>

    <form method="post" action="<%= request.getContextPath() %>/forgot-password">

        <div class="lt-field-group mb-3">
            <label for="recoveryEmail" class="form-label">Email address</label>
            <div class="lt-field">
                <svg class="lt-field-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#7a8a82" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="position:absolute;left:14px;top:50%;transform:translateY(-50%);width:20px;height:20px;pointer-events:none;">
                    <rect x="3" y="5" width="18" height="14" rx="2" fill="none"/>
                    <path d="M3 7l9 6 9-6"/>
                </svg>
                <input type="email"
                       id="recoveryEmail"
                       name="email"
                       class="form-control"
                       value="<%= utils.HtmlUtil.escape(emailValue) %>"
                       placeholder="your.email@example.com"
                       autocomplete="email"
                       required>
            </div>
            <div class="form-text" style="font-size: 11px; color: #64748b; margin-top: 4px;">
                Reset tokens remain valid for 30 minutes for security purposes.
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100 lt-signin-submit">
            Send reset instructions
        </button>
    </form>

    <p class="lt-signin-switch" style="margin-top: 20px;">
        Remember your password?
        <a href="<%= request.getContextPath() %>/login">Sign in</a>
    </p>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
