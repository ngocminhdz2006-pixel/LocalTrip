<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Trip" %>
<%@ page import="utils.HtmlUtil" %>
<%
    model.User currentUser = (model.User) session.getAttribute("user");
    Integer tripCount = (Integer) request.getAttribute("tripCount");
    Integer ownerCount = (Integer) request.getAttribute("ownerCount");
    Integer memberCount = (Integer) request.getAttribute("memberCount");
    List<Trip> trips = (List<Trip>) request.getAttribute("trips");
    String dashboardError = (String) request.getAttribute("dashboardError");
%>
<% request.setAttribute("pageTitle", "Tổng quan"); %>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
    <section class="dashboard-hero">
        <div class="hero-copy">
            <span class="eyebrow">LOCALTRIP / SỔ TAY HÀNH TRÌNH</span>
            <h1>Chuyến đi đẹp hơn<br>khi có nhau.</h1>
            <p class="mt-3 mb-0">Xin chào, <strong><%= HtmlUtil.escape(currentUser.getFullName()) %></strong>.<br>Lên kế hoạch, khám phá địa điểm và chia sẻ chi phí cùng nhóm của bạn.</p>
            <div class="hero-actions">
                <a class="btn btn-brand" href="<%= request.getContextPath() %>/trip/create">+ Lên kế hoạch chuyến đi</a>
                <a class="btn btn-outline-secondary" href="<%= request.getContextPath() %>/places">Khám phá địa điểm ↗</a>
            </div>
        </div>
    </section>

    <% if (dashboardError != null) { %>
        <div class="alert alert-warning"><%= HtmlUtil.escape(dashboardError) %></div>
    <% } %>

    <div class="row g-4 mb-4">
        <div class="col-md-4"><div class="card shadow-sm h-100"><div class="card-body"><div class="text-muted">Tổng số Trip</div><div class="display-6 fw-bold"><%= tripCount == null ? 0 : tripCount %></div></div></div></div>
        <div class="col-md-4"><div class="card shadow-sm h-100"><div class="card-body"><div class="text-muted">Trip bạn làm Owner</div><div class="display-6 fw-bold"><%= ownerCount == null ? 0 : ownerCount %></div></div></div></div>
        <div class="col-md-4"><div class="card shadow-sm h-100"><div class="card-body"><div class="text-muted">Trip bạn là Member</div><div class="display-6 fw-bold"><%= memberCount == null ? 0 : memberCount %></div></div></div></div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0">Trip gần đây</h5>
                <a class="btn btn-primary btn-sm" href="<%= request.getContextPath() %>/trip/create">+ Tạo Trip mới</a>
            </div>
            <% if (trips == null || trips.isEmpty()) { %>
                <div class="text-center py-5 text-muted">
                    <div class="fs-1">🧳</div>
                    <p class="mb-0">Bạn chưa có chuyến đi nào.</p>
                </div>
            <% } else { %>
                <div class="list-group list-group-flush">
                <% for (Trip trip : trips) {
                       boolean owner = trip.getOwnerId() == currentUser.getUserId(); %>
                    <div class="list-group-item px-0 d-flex justify-content-between align-items-center">
                        <div>
                            <a class="fw-semibold text-decoration-none" href="<%= request.getContextPath() %>/trip/detail?tripId=<%= trip.getTripId() %>">
                                <%= HtmlUtil.escape(trip.getTripName()) %>
                            </a>
                            <div class="small text-muted">
                                <%= HtmlUtil.escape(trip.getDestination()) %>
                                &nbsp;|&nbsp; <%= trip.getStartDate() %> → <%= trip.getEndDate() %>
                                &nbsp;|&nbsp; <%= trip.getBudget() %> đ
                            </div>
                        </div>
                        <span class="badge <%= owner ? "text-bg-primary" : "text-bg-secondary" %>"><%= owner ? "OWNER" : "MEMBER" %></span>
                    </div>
                <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <h5 class="fw-bold mb-3">Lối tắt</h5>
            <a href="<%= request.getContextPath() %>/places" class="btn btn-outline-secondary me-2">Khám phá địa điểm</a>
            <a href="<%= request.getContextPath() %>/trips" class="btn btn-outline-secondary">My Trips</a>
        </div>
    </div>
<%
    boolean showSeasonalComboPopup = Boolean.TRUE.equals(session.getAttribute("showSeasonalComboPopup"))
            && currentUser != null && "USER".equalsIgnoreCase(currentUser.getRole());
    if (showSeasonalComboPopup) {
        session.removeAttribute("showSeasonalComboPopup");
    }
%>
<%
    String seasonalComboTarget;
    String seasonalComboButtonText;
    if (trips != null && !trips.isEmpty() && trips.get(0) != null) {
        seasonalComboTarget = request.getContextPath() + "/combo?tripId=" + trips.get(0).getTripId();
        seasonalComboButtonText = "Khám phá địa điểm";
    } else {
        // Combo recommendations require a trip context. If the user has no trip yet,
        // guide them to create one first instead of sending them to a broken /combo URL.
        seasonalComboTarget = request.getContextPath() + "/trip/create";
        seasonalComboButtonText = "Tạo chuyến đi để khám phá combo";
    }
%>
<% if (showSeasonalComboPopup) { %>
<div id="seasonalComboPopup" class="seasonal-popup-backdrop" role="dialog" aria-modal="true" aria-labelledby="seasonalPopupTitle">
    <div class="seasonal-popup-card">
        <button type="button" class="seasonal-popup-close" id="seasonalPopupClose" aria-label="Đóng popup">&times;</button>
        <img class="seasonal-popup-image" src="<%= request.getContextPath() %>/images/saigon-combo-bon-mua-popup.png" alt="Sài Gòn - Khám phá theo combo bốn mùa">
        <div class="seasonal-popup-caption">
            <h2 id="seasonalPopupTitle">Khám phá Sài Gòn theo combo bốn mùa</h2>
            <p>Lên kế hoạch cho hành trình tiếp theo cùng LocalTrip.</p>
            <a class="btn btn-brand" href="<%= seasonalComboTarget %>"><%= seasonalComboButtonText %></a>
        </div>
    </div>
</div>
<style>
.seasonal-popup-backdrop{position:fixed;inset:0;z-index:2000;display:flex;align-items:center;justify-content:center;padding:22px;background:rgba(18,24,20,.68);backdrop-filter:blur(3px);animation:seasonalFadeIn .18s ease-out}
.seasonal-popup-card{position:relative;width:min(900px,96vw);max-height:92vh;overflow:auto;background:#fffaf2;border-radius:18px;box-shadow:0 24px 80px rgba(0,0,0,.3);animation:seasonalPopupIn .22s ease-out}
.seasonal-popup-image{display:block;width:100%;height:auto;max-height:68vh;object-fit:contain;background:#f5e6cf}
.seasonal-popup-close{position:absolute;top:10px;right:10px;z-index:2;width:42px;height:42px;border:0;border-radius:50%;background:rgba(30,25,20,.78);color:#fff;font-size:32px;line-height:1;cursor:pointer;display:flex;align-items:center;justify-content:center}
.seasonal-popup-close:hover{background:#741313}.seasonal-popup-caption{text-align:center;padding:18px 22px 24px}.seasonal-popup-caption h2{font-family:Georgia,'Times New Roman',serif;color:#741313;font-size:clamp(20px,3vw,30px);margin:0 0 8px}.seasonal-popup-caption p{color:#5d6259;margin-bottom:14px}.seasonal-popup-backdrop.is-closing{opacity:0;transition:opacity .15s ease}
@keyframes seasonalFadeIn{from{opacity:0}to{opacity:1}}@keyframes seasonalPopupIn{from{transform:translateY(10px) scale(.985)}to{transform:translateY(0) scale(1)}}
@media(max-width:600px){.seasonal-popup-backdrop{padding:12px}.seasonal-popup-card{width:100%;max-height:94vh;border-radius:13px}.seasonal-popup-image{max-height:58vh}.seasonal-popup-caption{padding:14px 14px 18px}.seasonal-popup-close{width:36px;height:36px;font-size:28px;top:8px;right:8px}}
</style>
<script>
(function(){var popup=document.getElementById('seasonalComboPopup');if(!popup)return;var closeButton=document.getElementById('seasonalPopupClose');function closePopup(){popup.classList.add('is-closing');window.setTimeout(function(){if(popup&&popup.parentNode)popup.parentNode.removeChild(popup);},160);}closeButton.addEventListener('click',closePopup);popup.addEventListener('click',function(event){if(event.target===popup)closePopup();});document.addEventListener('keydown',function(event){if(event.key==='Escape'&&document.getElementById('seasonalComboPopup'))closePopup();});})();
</script>
<% } %>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
