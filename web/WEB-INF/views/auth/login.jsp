<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%
    request.setAttribute("pageTitle", "Sign in");
    request.setAttribute("isLoginPage", Boolean.TRUE);
    String emailValue = request.getParameter("email");
    String nfcOwner = request.getParameter("nfc");
    String nfcTrip = request.getParameter("trip");
    boolean hasNfcContext = (nfcOwner != null && !nfcOwner.trim().isEmpty())
                         || (nfcTrip != null && !nfcTrip.trim().isEmpty());
    if (nfcOwner == null || nfcOwner.trim().isEmpty()) {
        nfcOwner = "Trip Partner";
    }
    if (nfcTrip == null || nfcTrip.trim().isEmpty()) {
        nfcTrip = "LocalTrip Journey";
    }
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-card lt-signin">

    <%-- 1. Mobile-only Brand Header & Hero NFC Sync Banner --%>
    <div class="lt-signin-brand">
        <div class="lt-signin-logo" style="position:relative;display:inline-block;font-size:36px;font-weight:700;color:#164b36;letter-spacing:-1px;">
            Local<span>Trip</span>
            <svg class="lt-signin-pin" width="22" height="22" viewBox="0 0 24 24" aria-hidden="true" style="position:absolute;top:-10px;right:-12px;width:22px;height:22px;">
                <path d="M12 2a6 6 0 0 0-6 6c0 4.5 6 12 6 12s6-7.5 6-12a6 6 0 0 0-6-6z" fill="#f2b544"/>
                <circle cx="12" cy="8" r="2.2" fill="#fff"/>
            </svg>
        </div>

        <% if (hasNfcContext) { %>
        <div style="background: linear-gradient(180deg, #e5f0e8 0%, #f3f6f2 100%); border-radius: 16px; padding: 12px; margin-top: 14px; border: 1px solid rgba(23, 91, 67, 0.12); text-align: center;">
            <div style="display: flex; align-items: center; justify-content: center; gap: 12px;">
                <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80"
                     style="width: 38px; height: 38px; border-radius: 50%; object-fit: cover; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border: 2px solid #fff;" alt="Traveler 1">
                <div style="display: flex; flex-direction: column; align-items: center;">
                    <span style="font-size: 9px; font-weight: 700; background: #d1fae5; color: #175b43; padding: 1px 7px; border-radius: 20px; border: 1px solid #a7f3d0;">NFC Tap))</span>
                    <span style="width: 36px; border-top: 2px dashed rgba(23, 91, 67, 0.4); margin: 3px 0;"></span>
                </div>
                <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80"
                     style="width: 38px; height: 38px; border-radius: 50%; object-fit: cover; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border: 2px solid #fff;" alt="Traveler 2">
            </div>
            <p style="font-size: 11px; color: #2e533e; font-weight: 600; margin: 6px 0 0;">Instant trip syncing with friends</p>
        </div>
        <% } %>
    </div>

    <h2 class="lt-signin-title">Welcome back</h2>
    <p class="lt-signin-sub">Plan your next trip with friends.</p>

    <%-- 2. Fast Social Login Button for PWA --%>
    <button type="button" class="lt-social-login-btn" onclick="alert('Google Social Sign-in ready for Firebase/OAuth integration!')">
        <svg width="18" height="18" viewBox="0 0 24 24" style="width:18px;height:18px;flex-shrink:0;">
            <path fill="#EA4335" d="M12 5c1.6 0 3 .6 4.1 1.7l3.1-3.1C17.3 1.8 14.8 1 12 1 7.4 1 3.5 3.6 1.6 7.4l3.7 2.8C6.2 7.2 8.9 5 12 5z"/>
            <path fill="#4285F4" d="M23.5 12.3c0-.8-.1-1.6-.2-2.3H12v4.5h6.5c-.3 1.5-1.1 2.8-2.4 3.6l3.7 2.9c2.2-2 3.7-5 3.7-8.7z"/>
            <path fill="#FBBC05" d="M5.3 14.8c-.2-.8-.4-1.6-.4-2.5s.2-1.7.4-2.5L1.6 7C.6 9 0 11.2 0 13.5s.6 4.5 1.6 6.5l3.7-2.9z"/>
            <path fill="#34A853" d="M12 24c3.2 0 6-1.1 8-3l-3.7-2.9c-1.1.7-2.5 1.2-4.3 1.2-3.1 0-5.8-2.1-6.7-5L1.6 17c1.9 3.9 5.8 7 10.4 7z"/>
        </svg>
        <span>Sign in with Google</span>
    </button>

    <div class="lt-divider-or">
        <div class="lt-divider-line"></div>
        <span class="lt-divider-text">or email</span>
        <div class="lt-divider-line"></div>
    </div>

    <%-- 3. Email & Password Form --%>
    <form method="post" action="<%= request.getContextPath()%>/login">

        <div class="lt-field-group">
            <label for="loginEmail" class="form-label" style="font-size:13px;font-weight:600;color:#334155;">Email</label>
            <div class="lt-field" style="position:relative;">
                <svg class="lt-field-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#7a8a82" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="position:absolute;left:14px;top:50%;transform:translateY(-50%);width:20px;height:20px;pointer-events:none;">
                    <rect x="3" y="5" width="18" height="14" rx="2" fill="none"/>
                    <path d="M3 7l9 6 9-6"/>
                </svg>
                <input type="email" id="loginEmail" name="email"
                       class="form-control"
                       value="<%= utils.HtmlUtil.escape(emailValue)%>"
                       placeholder="Enter your email"
                       autocomplete="email" required>
            </div>
        </div>

        <div class="lt-field-group">
            <label for="loginPassword" class="form-label" style="font-size:13px;font-weight:600;color:#334155;">Password</label>
            <div class="lt-field" style="position:relative;">
                <svg class="lt-field-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#7a8a82" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="position:absolute;left:14px;top:50%;transform:translateY(-50%);width:20px;height:20px;pointer-events:none;">
                    <rect x="5" y="11" width="14" height="10" rx="2" fill="none"/>
                    <path d="M8 11V8a4 4 0 0 1 8 0v3"/>
                </svg>
                <input type="password" id="loginPassword" name="password"
                       class="form-control"
                       placeholder="Enter your password"
                       autocomplete="current-password" required>
                <button type="button" id="togglePassword"
                        class="lt-field-toggle"
                        aria-label="Show password" aria-pressed="false"
                        style="position:absolute;right:6px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;width:36px;height:36px;color:#64748b;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="width:20px;height:20px;">
                        <path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/>
                        <circle cx="12" cy="12" r="3"/>
                    </svg>
                </button>
            </div>
        </div>

        <div class="lt-signin-forgot">
            <a href="<%= request.getContextPath()%>/forgot-password">Forgot password?</a>
        </div>

        <div class="form-check mb-4">
            <input class="form-check-input" type="checkbox"
                   name="rememberMe" id="rememberMe">
            <label class="form-check-label" for="rememberMe" style="font-size:13px;color:#475569;">
                Remember me on this device (30 days)
            </label>
        </div>

        <button type="submit" class="btn btn-primary w-100 lt-signin-submit">
            Sign in
        </button>
    </form>

    <p class="lt-signin-switch">
        New here?
        <a href="<%= request.getContextPath()%>/register">Create account</a>
    </p>

    <% if (hasNfcContext) { %>
    <%-- 4. Contextual NFC Deep Link Banner --%>
    <div class="lt-nfc-context-card">
        <div class="lt-nfc-context-icon" aria-hidden="true">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M5 8.5a7 7 0 0 1 14 0"/>
                <path d="M8 11.5a4 4 0 0 1 8 0"/>
                <circle cx="12" cy="15.5" r="1.5" fill="currentColor"/>
            </svg>
        </div>
        <div>
            <h4 class="lt-nfc-context-title">NFC Tag detected: <%= utils.HtmlUtil.escape(nfcOwner) %></h4>
            <p class="lt-nfc-context-desc">Sign in to connect and join "<%= utils.HtmlUtil.escape(nfcTrip) %>"</p>
        </div>
    </div>
    <% } %>
</section>

<script>
    (function () {
        var password = document.getElementById('loginPassword');
        var toggle = document.getElementById('togglePassword');

        if (toggle && password) {
            toggle.addEventListener('click', function () {
                var show = password.type === 'password';
                password.type = show ? 'text' : 'password';
                toggle.setAttribute('aria-pressed', show);
                toggle.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
            });
        }
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
