<% if (Boolean.TRUE.equals(request.getAttribute("hasAuthLayout"))) { %></div></div><% } %>
<% if (Boolean.TRUE.equals(request.getAttribute("hasTripLayout"))) { %></div></div><% }%>
</main>
<footer class="app-footer">
    <div class="container app-footer-content">
        <div>
            <strong>LocalTrip</strong>
            <span class="app-footer-dot">&middot;</span>
            Plan memorable journeys and track group travel expenses.
            <span class="app-footer-dot">&middot;</span>
            <a href="${pageContext.request.contextPath}/privacy" style="color: inherit; text-decoration: underline;">Privacy</a>
            <span class="app-footer-dot">&middot;</span>
            <a href="${pageContext.request.contextPath}/terms" style="color: inherit; text-decoration: underline;">Terms</a>
        </div>
        <div>PRJ301 Project</div>
    </div>
</footer>

<%
    model.User footerUser = (model.User) session.getAttribute("user");
    boolean footerIsAdmin = footerUser != null && "ADMIN".equalsIgnoreCase(footerUser.getRole());
    if (footerUser != null && !footerIsAdmin) {
%>
<nav class="lt-mobile-nav" aria-label="Bottom mobile navigation">
    <a href="${pageContext.request.contextPath}/trips" class="lt-mobile-nav-item" data-mobile-section="trips">
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"/>
        </svg>
        <span>Trips</span>
    </a>
    <a href="${pageContext.request.contextPath}/dump" class="lt-mobile-nav-item" data-mobile-section="friends">
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
        <span>Friends</span>
    </a>
    <a href="${pageContext.request.contextPath}/account" class="lt-mobile-nav-item" data-mobile-section="account">
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <circle cx="12" cy="12" r="10"/>
            <circle cx="12" cy="10" r="3"/>
            <path d="M6.168 18.849A4 4 0 0 1 10 16h4a4 4 0 0 1 3.834 2.855"/>
        </svg>
        <span>Account</span>
    </a>
</nav>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script src="${pageContext.request.contextPath}/js/image-compressor.js"></script>
<script>
    (function () {
        const navigation = document.querySelector(".lt-mobile-nav");

        if (!navigation) {
            return;
        }

        const contextPath = "${pageContext.request.contextPath}";
        const path = window.location.pathname.slice(contextPath.length);

        const tripRoutes = [
            "/trips", "/trip", "/itinerary", "/combos", "/combo",
            "/expenses", "/settlement", "/preferences", "/recommendations"
        ];

        function matchesRoute(route) {
            return path === route || path.startsWith(route + "/");
        }

        let section = null;

        if (tripRoutes.some(matchesRoute)) {
            section = "trips";
        } else if (matchesRoute("/dump") || matchesRoute("/friends")) {
            section = "friends";
        } else if (matchesRoute("/account")) {
            section = "account";
        }

        if (section) {
            const link = navigation.querySelector(
                    '[data-mobile-section="' + section + '"]'
                    );

            if (link) {
                link.classList.add("is-active");
                link.setAttribute("aria-current", "location");
            }
        }
    })();

    // Auto-inject CSRF protection token into all POST forms
    (function () {
        const csrfToken = "<%= session != null ? (String) session.getAttribute("travelCsrf") : "" %>";
        if (csrfToken && csrfToken.length > 5) {
            document.querySelectorAll("form").forEach(function (form) {
                const method = (form.getAttribute("method") || "").toUpperCase();
                if (method === "POST" && !form.querySelector('input[name="csrfToken"]')) {
                    const input = document.createElement("input");
                    input.type = "hidden";
                    input.name = "csrfToken";
                    input.value = csrfToken;
                    form.appendChild(input);
                }
            });
        }
    })();

    // Register Service Worker for PWA
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', function () {
            navigator.serviceWorker.register('${pageContext.request.contextPath}/sw.js?v=4')
                .then(function (reg) {
                    console.log('[PWA] Service Worker registered successfully with scope:', reg.scope);
                    reg.update();
                })
                .catch(function (err) {
                    console.warn('[PWA] Service Worker registration failed:', err);
                });
        });
    }
</script>
</body>
</html>
