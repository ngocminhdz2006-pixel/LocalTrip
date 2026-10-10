<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List,model.Place,model.Trip"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Combo địa điểm" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="vi_VN" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    Trip comboTrip = (Trip) request.getAttribute("trip");
    String profile = (String) request.getAttribute("profile");
    String visitDate = (String) request.getAttribute("visitDate");
    List<Place> comboPlaces = (List<Place>) request.getAttribute("comboPlaces");
    String profileName = "summer".equals(profile) ? "Mùa hạ" : ("autumn".equals(profile) ? "Mùa thu" : ("winter".equals(profile) ? "Mùa đông" : "Mùa xuân"));
    String profileIcon = "summer".equals(profile) ? "☀️" : ("autumn".equals(profile) ? "🍂" : ("winter".equals(profile) ? "❄️" : "🌸"));
    java.util.Map<String, String> savedDraft = (java.util.Map<String, String>) request.getAttribute("comboDraft");
    String message = request.getParameter("message");
    String error = (String) request.getAttribute("error");
%>
<style>
    .rd-page .rd-tabs a.on {
        background: var(--mint);
        border-radius: 9px 9px 0 0;
    }

    .rd-page .combo-wrap {
        max-width: none;
        margin: 0;
        padding: 0;
        color: var(--ink);
    }

    .combo-intro {
        margin-bottom: 20px;
    }

    .rd-page .season-note {
        font-size: 13px;
        color: var(--ink2);
        line-height: 1.7;
        margin-top: 10px;
    }

    .rd-page .combo-profiles {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 16px;
        margin: 0 0 22px;
    }

    .rd-page .combo-profile {
        display: flex;
        flex-direction: column;
        overflow: hidden;
        padding: 0;
        border: 1px solid var(--line);
        border-radius: 18px;
        color: var(--ink);
        background: #fff;
        box-shadow: none;
        text-decoration: none;
        min-width: 0;
    }

    .rd-page .combo-profile:hover {
        transform: none;
        border-color: var(--green2);
        box-shadow: none;
    }

    .rd-page .combo-profile.active {
        border: 2px solid var(--green);
        background: var(--mint);
        box-shadow: none;
    }

    .rd-page .combo-profile-image {
        display: block;
        width: 100%;
        height: 155px;
        object-fit: cover;
        background: var(--mint);
    }

    .combo-profile-content {
        display: block;
        padding: 16px;
    }

    .rd-page .combo-profile strong {
        display: block;
        margin: 6px 0 8px;
        font-size: 17px;
        color: var(--ink);
    }

    .combo-profile small {
        display: block;
        font-size: 13px;
        line-height: 1.7;
        color: var(--ink2);
    }

    .combo-image-credit {
        display: block;
        margin-top: 10px;
        font-size: 11px;
        color: var(--ink2);
        line-height: 1.6;
    }

    .rd-page .combo-controls {
        display: flex;
        gap: 12px;
        align-items: end;
        flex-wrap: wrap;
        padding: 22px;
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 18px;
        margin-bottom: 26px;
    }

    .combo-controls label {
        display: block;
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 7px;
        color: var(--ink2);
    }

    .rd-page .combo-controls input {
        font: inherit;
        padding: 11px 14px;
        border: 1px solid var(--line);
        border-radius: 11px;
        background: #fff;
        color: var(--ink);
        min-height: 46px;
        max-width: 100%;
    }

    .rd-page .combo-wrap > h2 {
        font-size: 23px;
        margin: 0 0 8px;
    }

    .rd-page .combo-wrap > p {
        font-size: 14px;
        color: var(--ink2);
        line-height: 1.7;
        margin-bottom: 20px;
    }

    .rd-page .combo-list {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 18px;
        margin-top: 20px;
    }

    .rd-page .combo-card {
        min-width: 0;
        border: 1px solid var(--line);
        border-radius: 18px;
        padding: 22px;
        background: #fff;
        box-shadow: none;
    }

    .rd-page .combo-card h3 {
        font-family: inherit;
        font-size: 19px;
        font-weight: 700;
        line-height: 1.5;
        margin: 0 0 18px;
        color: var(--ink);
    }

    .rd-page .combo-card .row {
        row-gap: 0;
    }

    .combo-meta {
        font-size: 13px;
        color: var(--ink2);
        line-height: 1.7;
    }

    .rd-page .combo-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 11px 18px;
        border: 1px solid var(--green);
        border-radius: 11px;
        background: var(--green);
        color: #fff;
        font: 600 14px/1.5 "Be Vietnam Pro", "Segoe UI", sans-serif;
        text-align: center;
        text-decoration: none;
        cursor: pointer;
        min-height: 46px;
    }

    .rd-page .combo-btn:hover {
        background: #174735;
        color: #fff;
    }

    .rd-page .combo-btn.secondary {
        background: #fff;
        color: var(--green);
        border-color: var(--line);
    }

    .rd-page .combo-btn.secondary:hover {
        background: var(--mint);
        color: var(--green);
    }

    .combo-alert {
        padding: 14px 18px;
        border-radius: 12px;
        background: var(--mint);
        border: 1px solid #C9DECF;
        color: var(--green);
        margin: 16px 0;
        line-height: 1.7;
    }

    .combo-warning {
        padding: 14px 18px;
        border-radius: 12px;
        background: var(--sunbg);
        border: 1px solid #ECD79F;
        color: #765300;
        margin: 16px 0;
        line-height: 1.7;
    }

    @media (max-width: 1000px) {
        .rd-page .combo-profiles {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .rd-page .combo-list {
            grid-template-columns: minmax(0, 1fr);
        }
    }

    @media (max-width: 600px) {
        .rd-page .combo-profiles {
            grid-template-columns: minmax(0, 1fr);
        }

        .rd-page .combo-profile-image {
            height: 190px;
        }

        .rd-page .combo-controls {
            padding: 20px;
            align-items: stretch;
            flex-direction: column;
        }

        .combo-controls > div,
        .combo-controls input,
        .combo-controls .combo-btn {
            width: 100%;
        }

        .rd-page .combo-card {
            padding: 20px;
        }

        .combo-wrap > form > .combo-btn {
            width: 100%;
            margin-top: 10px;
        }
    }
</style>
<div class="combo-wrap">
    <%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
    <%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

    <section class="rd-card combo-intro">
        <div class="rd-card-heading">
            <div>
                <h2>Combo địa điểm</h2>
                <p class="rd-sub">
                    Chọn chủ đề và ngày, xem trước rồi chỉnh
                    lịch trình trước khi xác nhận.
                </p>
            </div>

            <span class="rd-count">
                <%= profileIcon%> <%= profileName%>
            </span>
        </div>

        <p class="season-note">
            TP.HCM có hai mùa khí hậu chính.
            Bốn mùa dưới đây là bốn chủ đề trải nghiệm
            để nhóm chọn phong cách khám phá.
        </p>
    </section>
    <% if (message != null && !message.trim().isEmpty()) {%><div class="combo-alert"><%= HtmlUtil.escape(message)%></div><% } %>
    <% if (error != null) {%><div class="combo-warning"><%= HtmlUtil.escape(error)%></div><% }%>
    <div class="combo-profiles">
        <a class="combo-profile <%= "spring".equals(profile) ? "active" : ""%>" href="<%= request.getContextPath()%>/combo?tripId=<%= comboTrip.getTripId()%>&profile=spring&date=<%= visitDate%>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/Tao_Dan_Park,_Ho_Chi_Minh_City.jpg?width=900" alt="Công viên Tao Đàn tại TP.HCM" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Tao_Dan_Park.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">🌸</span><strong>Mùa xuân</strong><small>Du xuân, công viên, đường hoa và trải nghiệm văn hóa.</small><span class="combo-image-credit">Địa điểm tham khảo: Công viên Tao Đàn</span></span>
        </a>
        <a class="combo-profile <%= "summer".equals(profile) ? "active" : ""%>" href="<%= request.getContextPath()%>/combo?tripId=<%= comboTrip.getTripId()%>&profile=summer&date=<%= visitDate%>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/War_Remnants_Museum,_Ho_Chi_Minh_City.jpg?width=900" alt="Bảo tàng Chứng tích Chiến tranh tại TP.HCM" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/War_Remnants_Museum.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">☀️</span><strong>Mùa hạ</strong><small>Ưu tiên điểm trong nhà, bảo tàng, trung tâm thương mại và quán cà phê.</small><span class="combo-image-credit">Địa điểm tham khảo: Bảo tàng Chứng tích Chiến tranh</span></span>
        </a>
        <a class="combo-profile <%= "autumn".equals(profile) ? "active" : ""%>" href="<%= request.getContextPath()%>/combo?tripId=<%= comboTrip.getTripId()%>&profile=autumn&date=<%= visitDate%>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/Ho_Chi_Minh_City,_Central_Post_Office,_2020-01_CN-02.jpg?width=900" alt="Bưu điện Trung tâm Sài Gòn" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Saigon_Central_Post_Office_%2814585530306%29.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">🍂</span><strong>Mùa thu</strong><small>Dạo phố, ngắm kiến trúc, khám phá bảo tàng và cà phê.</small><span class="combo-image-credit">Địa điểm tham khảo: Bưu điện Trung tâm Sài Gòn</span></span>
        </a>
        <a class="combo-profile <%= "winter".equals(profile) ? "active" : ""%>" href="<%= request.getContextPath()%>/combo?tripId=<%= comboTrip.getTripId()%>&profile=winter&date=<%= visitDate%>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/20180413_215356Nguy%E1%BB%85n_Hu%E1%BB%87_Walking_Street.jpg?width=900" alt="Phố đi bộ Nguyễn Huệ về đêm" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Ho_Chi_Minh_City,_Nguyen_Hue_Street,_2020-01_CN-04.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">❄️</span><strong>Mùa đông</strong><small>Ngắm phố đêm, thưởng thức món nóng và khám phá trung tâm.</small><span class="combo-image-credit">Địa điểm tham khảo: Phố đi bộ Nguyễn Huệ</span></span>
        </a>
    </div>
    <form class="combo-controls" method="get" action="<%= request.getContextPath()%>/combo">
        <input type="hidden" name="tripId" value="<%= comboTrip.getTripId()%>">
        <input type="hidden" name="profile" value="<%= profile%>">
        <div><label for="date">Ngày áp dụng combo</label><input id="date" type="date" name="date" value="<%= visitDate%>" min="<%= request.getAttribute("comboMinimumDate")%>" max="<%= comboTrip.getEndDate()%>" required></div>
        <button class="combo-btn" type="submit">Tạo combo cho ngày này</button>
        <a class="combo-btn secondary" href="<%= request.getContextPath()%>/itinerary?tripId=<%= comboTrip.getTripId()%>">Xem lịch trình</a>
    </form>
    <h2>Combo <%= profileName%></h2>
    <p>Khu vực: <strong><%= HtmlUtil.escape(comboTrip.getDestination())%></strong>. Lịch trình có tham quan, bữa ăn, đồ uống và thời gian nghỉ/di chuyển.</p>
    <% if (comboPlaces == null || comboPlaces.isEmpty()) { %>
    <div class="combo-warning">Khu vực này chưa đủ địa điểm cho combo gồm tham quan, bữa ăn và đồ uống. Bạn có thể tự soạn lịch trình.</div>
    <% } else {%>
    <form method="post" action="<%= request.getContextPath()%>/combo">
        <input type="hidden" name="tripId" value="<%= comboTrip.getTripId()%>">
        <input type="hidden" name="profile" value="<%= profile%>">
        <input type="hidden" name="date" value="<%= visitDate%>">
        <input type="hidden" name="comboToken" value="<%= HtmlUtil.escape(String.valueOf(request.getAttribute("comboToken")))%>">
        <div class="combo-list">
            <% int idx = 0;
                for (Place p : comboPlaces) {
                    String[] starts = {"08:00", "11:00", "15:00"};
                    String[] ends = {"10:00", "13:00", "17:00"};
            %>
            <article class="combo-card">
                <h3><%= controller.ComboServlet.slotLabel(idx)%></h3>
                <label for="comboPlace<%= idx%>" class="form-label">Địa điểm</label>
                <select id="comboPlace<%= idx%>" class="form-select" name="placeId<%= idx%>" required>
                    <% for (Place option : (List<Place>) request.getAttribute("comboCandidates")) {
                            if (!controller.ComboServlet.slotMatches(option, idx)) {
                                continue;
                            }
                            String selectedId = savedDraft == null ? String.valueOf(p.getPlaceId()) : savedDraft.get("placeId" + idx);
                    %>
                    <option data-address="<%= HtmlUtil.escape(option.getAddress())%>" data-cost="<%= option.getEstimatedCost() == null ? "0" : option.getEstimatedCost().toPlainString()%>" value="<%= option.getPlaceId()%>" <%= String.valueOf(option.getPlaceId()).equals(selectedId) ? "selected" : ""%>><%= HtmlUtil.escape(option.getPlaceName())%> · <%= HtmlUtil.escape(option.getCategoryName())%> · <%= HtmlUtil.escape(option.getOpenHours())%></option>
                    <% }%>
                </select>
                <div class="row mt-2">
                    <div class="col-6"><label class="form-label" for="comboStart<%= idx%>">Bắt đầu</label><input id="comboStart<%= idx%>" class="form-control" type="time" name="start<%= idx%>" value="<%= HtmlUtil.escape(savedDraft == null ? starts[idx] : savedDraft.get("start" + idx))%>" required></div>
                    <div class="col-6"><label class="form-label" for="comboEnd<%= idx%>">Kết thúc</label><input id="comboEnd<%= idx%>" class="form-control" type="time" name="end<%= idx%>" value="<%= HtmlUtil.escape(savedDraft == null ? ends[idx] : savedDraft.get("end" + idx))%>" required></div>
                </div>
                <p class="combo-meta mt-3 combo-selected-meta">Gợi ý: <%= HtmlUtil.escape(p.getAddress())%><br>Chi phí tham khảo: <%= p.getEstimatedCost() == null ? "0" : p.getEstimatedCost().toPlainString()%> đ</p>
            </article>
            <% idx++;
                } %>
        </div>
        <p class="mt-3">Bạn có thể đổi địa điểm và giờ. Giữ ít nhất 15 phút giữa các hoạt động để nghỉ và di chuyển. Combo chỉ được lưu sau khi xác nhận.</p>
        <% if (Boolean.TRUE.equals(request.getAttribute("comboEditable"))) {%>
        <button class="combo-btn" type="submit">Xác nhận lịch trình ngày <%= visitDate%></button>
        <% } else { %>
        <div class="combo-warning">Chỉ trưởng nhóm được xác nhận combo; ngày áp dụng phải chưa qua và chuyến đi phải còn cho phép chỉnh sửa.</div>
        <% }%>
        <a class="combo-btn secondary" href="<%= request.getContextPath()%>/itinerary?tripId=<%= comboTrip.getTripId()%>">Xem lịch đã lưu</a>
    </form>
    <% }%>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
