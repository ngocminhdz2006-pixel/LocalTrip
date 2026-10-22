<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"
           uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Account" scope="request"/>
<c:set var="tripRedesign" value="${true}" scope="request" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="lt-account-container">

    <%-- 1. Header Bar --%>
    <div class="lt-account-head-bar">
        <h1 class="lt-account-head-title">Account Profile</h1>
        <span class="lt-nfc-badge">PWA Ready</span>
    </div>

    <%-- 2. Hero Profile Card --%>
    <section class="lt-acc-hero-card">
        <div class="lt-acc-avatar-large" aria-hidden="true">
            <c:out value="${fn:substring(sessionScope.user.fullName, 0, 1)}"/>
        </div>

        <h2 class="lt-acc-name">
            <c:out value="${sessionScope.user.fullName}"/>
        </h2>

        <p class="lt-acc-email">
            <c:out value="${sessionScope.user.email}"/>
        </p>

        <span class="lt-acc-role-pill">
            <span>✨</span> LocalTrip Member
        </span>
    </section>

    <%-- 2.5. Travel Vibes (Zero-Click Matching) --%>
    <section class="lt-acc-card-group" style="padding: 16px; margin-bottom: 16px;">
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 6px;">
            <h3 class="lt-acc-group-title" style="margin: 0;">
                <span>✨</span> My Travel Vibes (Zero-Click Matching)
            </h3>
            <span style="font-size: 11px; font-weight: 700; color: #175b43; background: #ecfdf5; border: 1px solid #a7f3d0; padding: 2px 8px; border-radius: 12px;">
                ${fn:length(userCategoryIds)} Selected
            </span>
        </div>
        <p style="font-size: 11.5px; color: #64748b; margin: 0 0 14px; line-height: 1.45;">
            Choose your favorite travel vibes. When you join or create a trip, your tastes automatically sync with friends without repeating choices!
        </p>

        <form method="post" action="${pageContext.request.contextPath}/account">
            <input type="hidden" name="action" value="savePreferences">
            <div class="lt-acc-vibe-grid">
                <c:forEach var="cat" items="${categories}">
                    <c:set var="isSelected" value="${userCategoryIds.contains(cat.categoryId)}"/>
                    <label class="lt-acc-vibe-chip ${isSelected ? 'is-active' : ''}">
                        <input type="checkbox" name="categoryIds" value="${cat.categoryId}"
                               ${isSelected ? 'checked' : ''} onchange="this.parentElement.classList.toggle('is-active', this.checked)">
                        <span><c:out value="${cat.categoryName}"/></span>
                    </label>
                </c:forEach>
            </div>
            <button type="submit" class="lt-acc-vibe-submit">
                💾 Save Travel Preferences
            </button>
        </form>
    </section>

    <style>
        .lt-acc-vibe-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 14px;
        }
        .lt-acc-vibe-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: 20px;
            border: 1.5px solid #dce7df;
            background: #f8fafc;
            font-size: 12px;
            font-weight: 600;
            color: #334155;
            cursor: pointer;
            transition: all 0.15s ease;
            user-select: none;
        }
        .lt-acc-vibe-chip input[type="checkbox"] {
            accent-color: #175b43;
            margin: 0;
            cursor: pointer;
        }
        .lt-acc-vibe-chip.is-active {
            background: #ecfdf5;
            border-color: #175b43;
            color: #143b2d;
            box-shadow: 0 1px 3px rgba(23, 91, 67, 0.1);
        }
        .lt-acc-vibe-submit {
            display: block;
            width: 100%;
            padding: 11px;
            background: #175b43;
            color: #ffffff;
            font-size: 13px;
            font-weight: 700;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            transition: background 0.15s ease;
        }
        .lt-acc-vibe-submit:hover {
            background: #143b2d;
        }
    </style>

    <%-- 3. PWA Install to Home Screen Banner --%>
    <section class="lt-pwa-install-card" id="pwaInstallCard">
        <div class="lt-pwa-icon-box">
            📲
        </div>
        <div class="lt-pwa-install-info">
            <h3 class="lt-pwa-install-title">Install LocalTrip to Home Screen</h3>
            <p class="lt-pwa-install-sub" id="pwaInstallDesc">Experience standalone app speed with zero browser UI.</p>
        </div>
        <button type="button" class="lt-pwa-install-btn" id="btnInstallPwa" onclick="handlePwaInstall()">
            Install
        </button>
    </section>

    <%-- 4. NFC Tag & Quick Connect Hub --%>
    <section class="lt-acc-card-group">
        <h3 class="lt-acc-group-title">
            <span>🏷️</span> NFC Tag & Quick Connect
        </h3>
        
        <div class="lt-acc-row-item">
            <div>
                <span class="lt-acc-row-label">Personal NFC Deep Link</span>
                <span class="lt-acc-row-val" style="font-size: 11px; color: #175b43;">
                    ${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/dump/friends?q=${sessionScope.user.email}
                </span>
            </div>
        </div>

        <div class="lt-acc-row-item">
            <div>
                <span class="lt-acc-row-label">Write to physical NFC tag</span>
                <span class="lt-acc-row-val" style="font-size: 11px; color: #64748b;">Tap a blank NFC tag to write</span>
            </div>
            <button type="button" class="lt-acc-btn-copy" onclick="writeToNfcTag()">
                Write Tag
            </button>
        </div>

        <div class="lt-acc-row-item">
            <div>
                <span class="lt-acc-row-label">Share personal profile link</span>
                <span class="lt-acc-row-val" style="font-size: 11px; color: #64748b;">Send via messaging apps or SMS</span>
            </div>
            <button type="button" class="lt-acc-btn-copy" onclick="copyMyProfileLink()">
                📋 Copy
            </button>
        </div>
    </section>

    <%-- 5. Account Details --%>
    <section class="lt-acc-card-group">
        <h3 class="lt-acc-group-title">
            <span>👤</span> Account Details
        </h3>

        <div class="lt-acc-row-item">
            <span class="lt-acc-row-label">Full name</span>
            <span class="lt-acc-row-val"><c:out value="${sessionScope.user.fullName}"/></span>
        </div>

        <div class="lt-acc-row-item">
            <span class="lt-acc-row-label">Email address</span>
            <span class="lt-acc-row-val"><c:out value="${sessionScope.user.email}"/></span>
        </div>

        <div class="lt-acc-row-item">
            <span class="lt-acc-row-label">System role</span>
            <span class="lt-acc-row-val" style="color: #175b43; font-weight: 700;">Member</span>
        </div>
    </section>

    <%-- 6. Logout Button --%>
    <a href="${pageContext.request.contextPath}/logout" class="lt-acc-signout-btn">
        <span>🚪</span> Sign out
    </a>

</div>

<script>
    // PWA Install Prompt Handler
    let deferredPrompt = null;
    const installBtn = document.getElementById('btnInstallPwa');
    const installDesc = document.getElementById('pwaInstallDesc');

    window.addEventListener('beforeinstallprompt', (e) => {
        e.preventDefault();
        deferredPrompt = e;
        if (installBtn) {
            installBtn.style.display = 'block';
            installDesc.innerText = 'Tap Install to add LocalTrip to your home screen now!';
        }
    });

    window.addEventListener('appinstalled', () => {
        deferredPrompt = null;
        if (installBtn) {
            installBtn.innerText = '✓ Installed';
            installBtn.disabled = true;
            installBtn.style.background = '#10b981';
            installBtn.style.color = '#fff';
        }
    });

    function handlePwaInstall() {
        if (deferredPrompt) {
            deferredPrompt.prompt();
            deferredPrompt.userChoice.then((choiceResult) => {
                if (choiceResult.outcome === 'accepted') {
                    console.log('User accepted PWA installation');
                }
                deferredPrompt = null;
            });
        } else {
            const isIos = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
            if (isIos) {
                alert('📱 To install on iPhone / iPad:\n1. Tap the Share button (square icon with upward arrow ⬆️ in Safari)\n2. Select "Add to Home Screen"');
            } else {
                alert('💡 Tip: The app is ready! You can also tap the browser menu (⋮) and select "Install app" or "Add to Home Screen".');
            }
        }
    }

    function copyMyProfileLink() {
        const link = window.location.origin + '${pageContext.request.contextPath}/dump/friends?q=${sessionScope.user.email}';
        if (navigator.clipboard) {
            navigator.clipboard.writeText(link).then(function() {
                alert('Personal profile link copied to clipboard: ' + link);
            });
        } else {
            prompt('Copy this link:', link);
        }
    }

    function writeToNfcTag() {
        const link = window.location.origin + '${pageContext.request.contextPath}/dump/friends?q=${sessionScope.user.email}';
        if ('NDEFReader' in window) {
            try {
                const ndef = new NDEFReader();
                alert('Please hold a blank NFC tag against the back of your phone to write your profile link...');
                ndef.write({
                    records: [{ recordType: "url", data: link }]
                }).then(() => {
                    alert('✓ Profile link written successfully to NFC tag!');
                }).catch(error => {
                    alert('Unable to write to NFC tag: ' + error.message);
                });
            } catch (e) {
                alert('Browser does not have NFC permission: ' + e.message);
            }
        } else {
            alert('💡 Web NFC writing is supported on Chrome for Android. On other devices, you can copy the link and use the NFC Tools app to write the tag.');
        }
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
