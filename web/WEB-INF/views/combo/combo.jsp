<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List,model.Place,model.Trip,utils.HtmlUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Curated Combos" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="en_US" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    Trip comboTrip = (Trip) request.getAttribute("trip");
    String profile = (String) request.getAttribute("profile");
    String visitDate = (String) request.getAttribute("visitDate");
    List<Place> comboPlaces = (List<Place>) request.getAttribute("comboPlaces");
    String profileName = "summer".equals(profile) ? "Summer Cool" : ("autumn".equals(profile) ? "Autumn Walk" : ("winter".equals(profile) ? "Winter Evening" : "Spring Fresh"));
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
        line-height: 1.6;
    }

    .combo-profiles {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }

    .combo-profile {
        display: flex;
        flex-direction: column;
        border: 1px solid var(--line);
        border-radius: 12px;
        overflow: hidden;
        background: #fff;
        text-decoration: none;
        color: inherit;
        transition: transform 0.15s ease, box-shadow 0.15s ease;
    }

    .combo-profile:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.06);
    }

    .combo-profile.active {
        border-color: var(--green);
        box-shadow: 0 0 0 2px var(--green);
    }

    .combo-profile-image {
        width: 100%;
        height: 120px;
        object-fit: cover;
    }

    .combo-profile-content {
        padding: 12px;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .combo-profile-content strong {
        font-size: 14px;
        color: var(--ink);
    }

    .combo-profile-content small {
        font-size: 11px;
        color: var(--ink2);
        line-height: 1.4;
    }

    .combo-image-credit {
        font-size: 10px;
        color: #94a3b8;
        margin-top: 4px;
    }

    .combo-controls {
        display: flex;
        align-items: flex-end;
        gap: 12px;
        margin-bottom: 24px;
        flex-wrap: wrap;
        background: #fff;
        padding: 16px;
        border-radius: 12px;
        border: 1px solid var(--line);
    }

    .combo-controls label {
        font-size: 12px;
        font-weight: 600;
        margin-bottom: 4px;
        display: block;
    }

    .combo-controls input[type="date"] {
        padding: 8px 12px;
        border: 1px solid var(--line);
        border-radius: 8px;
        font-size: 14px;
    }

    .combo-btn {
        padding: 8px 16px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        background: var(--green);
        color: #fff;
        border: none;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .combo-btn:hover {
        background: var(--green-hover, #114633);
        color: #fff;
    }

    .combo-btn.secondary {
        background: transparent;
        border: 1px solid var(--line);
        color: var(--ink);
    }

    .combo-list {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        margin-bottom: 20px;
    }

    .combo-card {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 12px;
        padding: 16px;
    }

    .combo-card h3 {
        font-size: 15px;
        font-weight: 700;
        color: var(--green);
        margin: 0 0 10px;
    }

    .combo-warning {
        background: #fffbeb;
        border: 1px solid #fde68a;
        color: #92400e;
        padding: 12px 16px;
        border-radius: 10px;
        font-size: 13px;
        margin-bottom: 16px;
    }

    .combo-alert {
        background: #ecfdf5;
        border: 1px solid #a7f3d0;
        color: #065f46;
        padding: 12px 16px;
        border-radius: 10px;
        font-size: 13px;
        margin-bottom: 16px;
    }

    @media (max-width: 768px) {
        .combo-profiles {
            grid-template-columns: repeat(2, 1fr);
        }
        .combo-list {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="combo-wrap">
    <%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
    <%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

    <section class="rd-card combo-intro">
        <div class="rd-card-heading">
            <div>
                <h2>Curated Combos</h2>
                <p class="rd-sub">
                    Select a theme and date, preview curated options, and adjust schedule before confirming.
                </p>
            </div>

            <span class="rd-count">
                <%= profileIcon%> <%= profileName%>
            </span>
        </div>

        <p class="season-note">
            Each combo theme offers a balanced combination of sightseeing, dining, coffee breaks, and rest.
        </p>
    </section>

    <% if (message != null && !message.trim().isEmpty()) {%><div class="combo-alert"><%= HtmlUtil.escape(message)%></div><% } %>
    <% if (error != null) {%><div class="combo-warning"><%= HtmlUtil.escape(error)%></div><% }%>

    <div class="combo-profiles">
        <a class="combo-profile <%= "spring".equals(profile) ? "active" : ""%>" href="<%= request.getContextPath()%>/combo?tripId=<%= comboTrip.getTripId()%>&profile=spring&date=<%= visitDate%>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/Tao_Dan_Park,_Ho_Chi_Minh_City.jpg?width=900" alt="Tao Dan Park" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Tao_Dan_Park.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">🌸</span><strong>Spring Fresh</strong><small>Parks, flower walks, and cultural discovery.</small><span class="combo-image-credit">Reference spot: Tao Dan Park</span></span>
        </a>
        <a class="combo-profile <%= "summer".equals(profile) ? "active" : ""%>" href="<%= request.getContextPath()%>/combo?tripId=<%= comboTrip.getTripId()%>&profile=summer&date=<%= visitDate%>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/War_Remnants_Museum,_Ho_Chi_Minh_City.jpg?width=900" alt="War Remnants Museum" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/War_Remnants_Museum.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">☀️</span><strong>Summer Cool</strong><small>Indoor exhibitions, museums, and air-conditioned cafes.</small><span class="combo-image-credit">Reference spot: War Remnants Museum</span></span>
        </a>
        <a class="combo-profile <%= "autumn".equals(profile) ? "active" : ""%>" href="<%= request.getContextPath()%>/combo?tripId=<%= comboTrip.getTripId()%>&profile=autumn&date=<%= visitDate%>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/Ho_Chi_Minh_City,_Central_Post_Office,_2020-01_CN-02.jpg?width=900" alt="Central Post Office" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Saigon_Central_Post_Office_%2814585530306%29.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">🍂</span><strong>Autumn Walk</strong><small>City strolls, architecture, museums, and artisanal coffee.</small><span class="combo-image-credit">Reference spot: Central Post Office</span></span>
        </a>
        <a class="combo-profile <%= "winter".equals(profile) ? "active" : ""%>" href="<%= request.getContextPath()%>/combo?tripId=<%= comboTrip.getTripId()%>&profile=winter&date=<%= visitDate%>">
            <img class="combo-profile-image" loading="lazy" src="https://commons.wikimedia.org/wiki/Special:FilePath/20180413_215356Nguy%E1%BB%85n_Hu%E1%BB%87_Walking_Street.jpg?width=900" alt="Nguyen Hue Walking Street" onerror="this.onerror=null;this.src='https://commons.wikimedia.org/wiki/Special:FilePath/Ho_Chi_Minh_City,_Nguyen_Hue_Street,_2020-01_CN-04.jpg?width=900';">
            <span class="combo-profile-content"><span aria-hidden="true">❄️</span><strong>Winter Evening</strong><small>Night walks, warm culinary treats, and illuminated center.</small><span class="combo-image-credit">Reference spot: Nguyen Hue Walking Street</span></span>
        </a>
    </div>

    <form class="combo-controls" method="get" action="<%= request.getContextPath()%>/combo">
        <input type="hidden" name="tripId" value="<%= comboTrip.getTripId()%>">
        <input type="hidden" name="profile" value="<%= profile%>">
        <div>
            <label for="date">Apply combo for date</label>
            <input id="date" type="date" name="date" value="<%= visitDate%>" min="<%= request.getAttribute("comboMinimumDate")%>" max="<%= comboTrip.getEndDate()%>" required>
        </div>
        <button class="combo-btn" type="submit">Generate combo for this date</button>
        <a class="combo-btn secondary" href="<%= request.getContextPath()%>/itinerary?tripId=<%= comboTrip.getTripId()%>">View itinerary</a>
    </form>

    <h2>Combo: <%= profileName%></h2>
    <p>Destination area: <strong><%= HtmlUtil.escape(comboTrip.getDestination())%></strong>. Itinerary covers sightseeing, meal, drinks, and rest.</p>

    <% if (comboPlaces == null || comboPlaces.isEmpty()) { %>
    <div class="combo-warning">This area does not have enough places for a full combo. You can customize the itinerary manually.</div>
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
                <label for="comboPlace<%= idx%>" class="form-label">Destination</label>
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
                    <div class="col-6"><label class="form-label" for="comboStart<%= idx%>">Start</label><input id="comboStart<%= idx%>" class="form-control" type="time" name="start<%= idx%>" value="<%= HtmlUtil.escape(savedDraft == null ? starts[idx] : savedDraft.get("start" + idx))%>" required></div>
                    <div class="col-6"><label class="form-label" for="comboEnd<%= idx%>">End</label><input id="comboEnd<%= idx%>" class="form-control" type="time" name="end<%= idx%>" value="<%= HtmlUtil.escape(savedDraft == null ? ends[idx] : savedDraft.get("end" + idx))%>" required></div>
                </div>
                <p class="combo-meta mt-3 combo-selected-meta">Address: <%= HtmlUtil.escape(p.getAddress())%><br>Estimated reference cost: <%= p.getEstimatedCost() == null ? "0" : p.getEstimatedCost().toPlainString()%> VND</p>
            </article>
            <% idx++;
                } %>
        </div>
        <p class="mt-3">You can adjust places and times. Keep at least 15 minutes between activities for travel. Combo is saved upon confirmation.</p>
        <% if (Boolean.TRUE.equals(request.getAttribute("comboEditable"))) {%>
        <button class="combo-btn" type="submit">Confirm itinerary for <%= visitDate%></button>
        <% } else { %>
        <div class="combo-warning">Only the Trip Lead can confirm combos for upcoming days on editable trips.</div>
        <% }%>
        <a class="combo-btn secondary" href="<%= request.getContextPath()%>/itinerary?tripId=<%= comboTrip.getTripId()%>">View saved itinerary</a>
    </form>
    <% }%>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
