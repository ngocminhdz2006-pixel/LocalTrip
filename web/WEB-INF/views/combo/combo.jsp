<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List,model.Place,model.Trip"%>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<%
    Trip comboTrip = (Trip) request.getAttribute("trip");
    String profile = (String) request.getAttribute("profile");
    String visitDate = (String) request.getAttribute("visitDate");
    List<Place> comboPlaces = (List<Place>) request.getAttribute("comboPlaces");
    String profileName = "summer".equals(profile) ? "Mùa hạ" : ("autumn".equals(profile) ? "Mùa thu" : ("winter".equals(profile) ? "Mùa đông" : "Mùa xuân"));
    String profileIcon = "summer".equals(profile) ? "☀️" : ("autumn".equals(profile) ? "🍂" : ("winter".equals(profile) ? "❄️" : "🌸"));
    String message = request.getParameter("message");
    String error = (String) request.getAttribute("error");
%>
<style>
.combo-wrap{max-width:1120px;margin:24px auto;padding:0 16px;color:var(--brand-text,#223b31)}.combo-hero{padding:30px;border:1px solid var(--brand-border,#dedfd5);border-radius:18px;background:#e9eddf;margin-bottom:20px}.combo-hero h1{margin:0 0 8px;font-family:Georgia,"Times New Roman",serif;font-weight:500;font-size:clamp(25px,3vw,36px);color:var(--brand-text,#223b31)}.combo-hero p{color:#506654}.combo-profiles{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px;margin:18px 0}.combo-profile{display:flex;flex-direction:column;overflow:hidden;padding:0;border:1px solid var(--brand-border,#dedfd5);border-radius:14px;text-decoration:none;color:var(--brand-text,#223b31);background:var(--brand-surface,#fffefa);transition:transform .18s ease,box-shadow .18s ease,border-color .18s ease}.combo-profile:hover{transform:translateY(-3px);box-shadow:0 10px 26px rgba(34,59,49,.10);color:var(--brand-text,#223b31);border-color:#aab9a0}.combo-profile.active{border:2px solid var(--brand-primary,#245b48);background:#edf1e7;box-shadow:0 8px 22px rgba(36,91,72,.12)}.combo-profile-image{display:block;width:100%;height:155px;object-fit:cover;background:#e9ece6}.combo-profile-content{display:block;padding:13px 14px 15px}.combo-profile strong{display:block;margin:5px 0 7px;font-size:17px;color:var(--brand-text,#223b31)}.combo-profile small{display:block;line-height:1.5;color:var(--brand-muted,#637268)}.combo-image-credit{display:block;margin-top:8px;font-size:10px;color:var(--brand-muted,#637268)}.combo-controls{display:flex;gap:12px;align-items:end;flex-wrap:wrap;padding:16px;background:var(--brand-surface,#fffefa);border:1px solid var(--brand-border,#dedfd5);border-radius:14px;margin-bottom:18px}.combo-controls label{display:block;font-size:13px;margin-bottom:6px;color:var(--brand-text,#223b31)}.combo-controls input{padding:10px;border:1px solid #cfd6c9;border-radius:8px;background:#fffefa;color:var(--brand-text,#223b31)}.combo-list{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px}.combo-card{border:1px solid var(--brand-border,#dedfd5);border-top:3px solid #b4c3a9;border-radius:14px;padding:18px;background:var(--brand-surface,#fffefa);box-shadow:0 3px 10px rgba(34,59,49,.025)}.combo-number{display:inline-flex;border-radius:5px;background:#e5eedf;color:var(--brand-primary,#245b48);padding:5px 9px;font-size:12px}.combo-card h3{font-family:Georgia,"Times New Roman",serif;font-size:20px;margin:12px 0;color:var(--brand-text,#223b31)}.combo-meta{font-size:13px;color:var(--brand-muted,#637268);line-height:1.7}.combo-actions{margin-top:18px;display:flex;gap:10px;flex-wrap:wrap}.combo-btn{display:inline-block;padding:11px 16px;border:1px solid var(--brand-primary,#245b48);border-radius:8px;background:var(--brand-primary,#245b48);color:white;font-weight:600;text-decoration:none;cursor:pointer}.combo-btn:hover{background:var(--brand-primary-dark,#173e32);color:white}.combo-btn.secondary{background:transparent;color:var(--brand-primary,#245b48);border-color:#bfcbbb}.combo-btn.secondary:hover{background:#e9eee5;color:var(--brand-primary-dark,#173e32)}.combo-alert{padding:12px 15px;border-radius:10px;background:#e7efdf;border:1px solid #cbdbbe;color:#245b48;margin:12px 0}.combo-warning{padding:12px 15px;border-radius:10px;background:#f5e8d8;border:1px solid #e7d0b7;color:#754626;margin:12px 0}.season-note{font-size:13px;color:#506654;margin-top:8px}@media(max-width:900px){.combo-profiles{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:600px){.combo-profiles,.combo-list{grid-template-columns:1fr}.combo-profile-image{height:210px}.combo-hero h1{font-size:23px}}
</style>
<div class="combo-wrap">
    <section class="combo-hero">
        <h1><%= profileIcon %> Combo địa điểm theo mùa</h1>
        <p>Chọn một chủ đề theo mùa để nhận 3 địa điểm gợi ý tại TP.HCM và thêm nhanh vào lịch trình.</p>
        <div class="season-note">Lưu ý: TP.HCM có hai mùa khí hậu chính. Bốn mùa trong Combo là bốn chủ đề trải nghiệm để bạn dễ chọn phong cách khám phá thành phố.</div>
        <strong>Chuyến đi: <%= HtmlUtil.escape(comboTrip == null ? "" : comboTrip.getTripName()) %></strong>
    </section>
    <% if (message != null && !message.trim().isEmpty()) { %><div class="combo-alert"><%= HtmlUtil.escape(message) %></div><% } %>
    <% if (error != null) { %><div class="combo-warning"><%= HtmlUtil.escape(error) %></div><% } %>
    <div class="combo-profiles">
        <a class="combo-profile <%= "spring".equals(profile) ? "active" : "" %>" href="<%= request.getContextPath() %>/combo?tripId=<%= comboTrip.getTripId() %>&profile=spring&date=<%= visitDate %>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/Tao_Dan_Park,_Ho_Chi_Minh_City.jpg?width=900" alt="Công viên Tao Đàn tại TP.HCM" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Tao_Dan_Park.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">🌸</span><strong>Mùa xuân</strong><small>Du xuân, công viên, đường hoa và trải nghiệm văn hóa.</small><span class="combo-image-credit">Địa điểm tham khảo: Công viên Tao Đàn</span></span>
        </a>
        <a class="combo-profile <%= "summer".equals(profile) ? "active" : "" %>" href="<%= request.getContextPath() %>/combo?tripId=<%= comboTrip.getTripId() %>&profile=summer&date=<%= visitDate %>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/War_Remnants_Museum,_Ho_Chi_Minh_City.jpg?width=900" alt="Bảo tàng Chứng tích Chiến tranh tại TP.HCM" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/War_Remnants_Museum.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">☀️</span><strong>Mùa hạ</strong><small>Ưu tiên điểm trong nhà, bảo tàng, trung tâm thương mại và quán cà phê.</small><span class="combo-image-credit">Địa điểm tham khảo: Bảo tàng Chứng tích Chiến tranh</span></span>
        </a>
        <a class="combo-profile <%= "autumn".equals(profile) ? "active" : "" %>" href="<%= request.getContextPath() %>/combo?tripId=<%= comboTrip.getTripId() %>&profile=autumn&date=<%= visitDate %>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/Ho_Chi_Minh_City,_Central_Post_Office,_2020-01_CN-02.jpg?width=900" alt="Bưu điện Trung tâm Sài Gòn" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Saigon_Central_Post_Office_%2814585530306%29.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">🍂</span><strong>Mùa thu</strong><small>Dạo phố, ngắm kiến trúc, khám phá bảo tàng và cà phê.</small><span class="combo-image-credit">Địa điểm tham khảo: Bưu điện Trung tâm Sài Gòn</span></span>
        </a>
        <a class="combo-profile <%= "winter".equals(profile) ? "active" : "" %>" href="<%= request.getContextPath() %>/combo?tripId=<%= comboTrip.getTripId() %>&profile=winter&date=<%= visitDate %>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/20180413_215356Nguy%E1%BB%85n_Hu%E1%BB%87_Walking_Street.jpg?width=900" alt="Phố đi bộ Nguyễn Huệ về đêm" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Ho_Chi_Minh_City,_Nguyen_Hue_Street,_2020-01_CN-04.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">❄️</span><strong>Mùa đông</strong><small>Ngắm phố đêm, thưởng thức món nóng và khám phá trung tâm.</small><span class="combo-image-credit">Địa điểm tham khảo: Phố đi bộ Nguyễn Huệ</span></span>
        </a>
    </div>
    <form class="combo-controls" method="get" action="<%= request.getContextPath() %>/combo">
        <input type="hidden" name="tripId" value="<%= comboTrip.getTripId() %>">
        <input type="hidden" name="profile" value="<%= profile %>">
        <div><label for="date">Ngày áp dụng combo</label><input id="date" type="date" name="date" value="<%= visitDate %>" min="<%= comboTrip.getStartDate() %>" max="<%= comboTrip.getEndDate() %>" required></div>
        <button class="combo-btn" type="submit">Tạo combo cho ngày này</button>
        <a class="combo-btn secondary" href="<%= request.getContextPath() %>/itinerary?tripId=<%= comboTrip.getTripId() %>">Xem lịch trình</a>
    </form>
    <h2>Combo <%= profileName %></h2>
    <% if (comboPlaces == null || comboPlaces.isEmpty()) { %>
        <div class="combo-warning">Chưa có địa điểm đang hoạt động. Hãy chạy script sql/10_seasonal_combos.sql rồi thử lại.</div>
    <% } else { %>
        <div class="combo-list">
        <% int idx = 0; for (Place p : comboPlaces) { idx++; %>
            <article class="combo-card">
                <span class="combo-number">Điểm dừng <%= idx %> · <%= idx == 1 ? "08:00–10:00" : (idx == 2 ? "11:00–13:00" : "15:00–17:00") %></span>
                <h3><%= HtmlUtil.escape(p.getPlaceName() == null ? "Địa điểm" : p.getPlaceName()) %></h3>
                <div class="combo-meta"><strong>Danh mục:</strong> <%= HtmlUtil.escape(p.getCategoryName() == null ? "Chưa phân loại" : p.getCategoryName()) %><br>
                <strong>Địa chỉ:</strong> <%= HtmlUtil.escape(p.getAddress() == null ? "Chưa cập nhật" : p.getAddress()) %><br>
                <strong>Chi phí dự kiến:</strong> <%= p.getEstimatedCost() == null ? "0" : p.getEstimatedCost().toPlainString() %> đ<br>
                <strong>Đánh giá:</strong> <%= p.getRating() == null ? "Chưa có" : p.getRating().toPlainString() + "/5" %></div>
                <% if (p.getDescription() != null && !p.getDescription().trim().isEmpty()) { %><p><%= HtmlUtil.escape(p.getDescription()) %></p><% } %>
            </article>
        <% } %>
        </div>
        <% if (comboPlaces.size() < 3) { %><div class="combo-warning">Dữ liệu hiện chỉ có <%= comboPlaces.size() %> địa điểm phù hợp/đang hoạt động; hãy bổ sung thêm địa điểm.</div><% } %>
        <form class="combo-actions" method="post" action="<%= request.getContextPath() %>/combo">
            <input type="hidden" name="tripId" value="<%= comboTrip.getTripId() %>">
            <input type="hidden" name="profile" value="<%= profile %>">
            <input type="hidden" name="date" value="<%= visitDate %>">
            <button class="combo-btn" type="submit">Thêm combo vào lịch trình</button>
            <a class="combo-btn secondary" href="<%= request.getContextPath() %>/itinerary?tripId=<%= comboTrip.getTripId() %>">Mở lịch trình</a>
        </form>
    <% } %>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
