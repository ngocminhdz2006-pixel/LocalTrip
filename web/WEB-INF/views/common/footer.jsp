<% if (Boolean.TRUE.equals(request.getAttribute("hasAuthLayout"))) { %></div></div><% } %>
<% if (Boolean.TRUE.equals(request.getAttribute("hasTripLayout"))) { %></div></div><% } %>
</main>
<footer class="app-footer">
    <div class="container app-footer-content">
        <div>
            <strong>LocalTrip</strong>
            <span class="app-footer-dot">&middot;</span>
            L&#7853;p k&#7871; ho&#7841;ch v&#224; qu&#7843;n l&#253;
            chi ph&#237; chuy&#7871;n &#273;i.
        </div>
        <div>D&#7921; &#225;n PRJ301</div>
    </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
