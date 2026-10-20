<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"
           uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"
           uri="http://java.sun.com/jsp/jstl/functions" %>

<fmt:setLocale value="en_US" scope="page"/>
<c:set var="pageTitle" value="My trips" scope="request"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="lt-home">
    <c:set var="nameParts" value="${fn:split(sessionScope.user.fullName, ' ')}"/>
    <c:set var="firstName" value="${nameParts[fn:length(nameParts) - 1]}"/>

    <%-- 1. Greeting & Quick NFC Header --%>
    <section class="lt-home-greeting">
        <div class="lt-home-greeting-left">
            <span class="lt-home-avatar" aria-hidden="true">
                <c:out value="${fn:substring(firstName, 0, 1)}"/>
            </span>
            <div>
                <span class="lt-home-greeting-sub">Good morning,</span>
                <h1>Hi, <c:out value="${firstName}"/> 👋</h1>
            </div>
        </div>

        <button type="button" class="lt-home-nfc-tap-btn" onclick="triggerNfcScan()" title="Tap NFC to connect">
            <span>((•))</span>
            <span>Tap</span>
        </button>
    </section>

    <%-- 2. Section Header: Title + Inline Compact "+ Create trip" Button --%>
    <div class="lt-home-section-header">
        <h2 class="lt-home-title">
            My trips <span class="lt-home-count">(${fn:length(trips)})</span>
        </h2>
        <a href="${pageContext.request.contextPath}/trip/create" class="lt-btn-create-compact">
            <span>+</span> Create trip
        </a>
    </div>

    <%-- 3. Trips List / Empty State --%>
    <c:choose>
        <c:when test="${empty trips}">
            <section class="lt-home-empty">
                <h3>No trips yet</h3>
                <p>
                    Create a trip and invite friends to plan it together.
                </p>
                <a href="${pageContext.request.contextPath}/trip/create" class="lt-btn-create-compact" style="margin-top: 12px; display: inline-flex;">
                    <span>+</span> Create first trip
                </a>
            </section>
        </c:when>

        <c:otherwise>
            <div class="lt-home-trip-grid">
                <c:forEach var="trip" items="${trips}">
                    <article class="lt-home-trip-card">
                        <%-- Card Cover with Gradient and Badges --%>
                        <div class="lt-home-card-cover">
                            <img class="lt-home-cover-img"
                                 src="${pageContext.request.contextPath}/images/trip-cover.jpg"
                                 alt="${trip.name}"
                                 onerror="this.src='https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=600&auto=format&fit=crop&q=80'">
                            <div class="lt-home-cover-overlay"></div>

                            <%-- Status Tag --%>
                            <div class="lt-home-status-tag">
                                <span class="lt-status-dot"></span>
                                <span>
                                    <c:choose>
                                        <c:when test="${trip.status == 'PLANNING'}">Planning</c:when>
                                        <c:when test="${trip.status == 'ONGOING'}">Ongoing</c:when>
                                        <c:when test="${trip.status == 'COMPLETED'}">Completed</c:when>
                                        <c:when test="${trip.status == 'CANCELLED'}">Cancelled</c:when>
                                        <c:otherwise>${trip.status}</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <%-- Dropdown Action Menu --%>
                            <div class="lt-card-menu">
                                <button type="button" class="lt-card-menu-btn" title="Actions" onclick="event.stopPropagation(); window.location.href='${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}';">•••</button>
                            </div>

                            <%-- Title & Dates on Cover --%>
                            <div class="lt-home-cover-info">
                                <h3 class="lt-home-card-title"><c:out value="${trip.name}"/></h3>
                                <p class="lt-home-card-dates">
                                    📅 <fmt:formatDate value="${trip.startDate}" pattern="MMM d"/> – <fmt:formatDate value="${trip.endDate}" pattern="MMM d, yyyy"/>
                                </p>
                            </div>
                        </div>

                        <%-- Card Footer: Members & Readiness Status --%>
                        <div class="lt-home-card-footer">
                            <div class="lt-home-card-members">
                                <span class="lt-home-member-text">
                                    👥 ${memberCounts[trip.id]} ${memberCounts[trip.id] == 1 ? 'member' : 'members'}
                                </span>
                            </div>
                            <span class="lt-home-ready-badge">
                                <c:choose>
                                    <c:when test="${trip.status == 'PLANNING'}">2/3 ready</c:when>
                                    <c:otherwise>Confirmed</c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <%-- Continue / Open Button --%>
                        <a href="${pageContext.request.contextPath}/trip/detail?tripId=${trip.id}"
                           class="lt-home-card-btn">
                            <c:choose>
                                <c:when test="${trip.status == 'PLANNING'}">
                                    Continue planning →
                                </c:when>
                                <c:when test="${trip.status == 'ONGOING'}">
                                    Open itinerary →
                                </c:when>
                                <c:otherwise>
                                    View trip details →
                                </c:otherwise>
                            </c:choose>
                        </a>
                    </article>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

    <%-- 4. Rich Combos Section --%>
    <section class="lt-home-combos-section">
        <div class="lt-combos-header">
            <div>
                <h3 class="lt-combos-title">Combos for your group</h3>
                <p class="lt-combos-sub">Curated for your travel group</p>
            </div>
            <a href="${pageContext.request.contextPath}/places" class="lt-combos-see-all">See all</a>
        </div>

        <div class="lt-combos-grid">
            <%-- Combo 1 --%>
            <article class="lt-combo-card">
                <div class="lt-combo-thumb-wrap">
                    <img src="https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=300&auto=format&fit=crop&q=80"
                         alt="Saigon Specialty Coffee" class="lt-combo-img">
                    <span class="lt-combo-rating">⭐ 4.9</span>
                </div>
                <h4 class="lt-combo-name">Saigon Specialty Coffee</h4>
                <div class="lt-combo-meta">
                    <span class="lt-combo-price">145k / pax</span>
                    <button type="button" class="lt-combo-add-btn" onclick="alert('Saigon Specialty Coffee added to suggestions!')">+ Add</button>
                </div>
            </article>

            <%-- Combo 2 --%>
            <article class="lt-combo-card">
                <div class="lt-combo-thumb-wrap">
                    <img src="https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=300&auto=format&fit=crop&q=80"
                         alt="Banh Mi & Local Bites" class="lt-combo-img">
                    <span class="lt-combo-rating">⭐ 4.8</span>
                </div>
                <h4 class="lt-combo-name">Banh Mi & Local Bites</h4>
                <div class="lt-combo-meta">
                    <span class="lt-combo-price">190k / pax</span>
                    <button type="button" class="lt-combo-add-btn" onclick="alert('Street food combo added to suggestions!')">+ Add</button>
                </div>
            </article>
        </div>
    </section>
</div>

<script>
    function triggerNfcScan() {
        if ('NDEFReader' in window) {
            try {
                const ndef = new NDEFReader();
                ndef.scan().then(function() {
                    alert('Scanning NFC tag... Please tap an NFC tag or a friend\'s phone against the back of your device.');
                }).catch(function(err) {
                    alert('Cannot start NFC scan: ' + err.message);
                });
            } catch (e) {
                alert('NFC permission was not granted by your browser.');
            }
        } else {
            // Fallback for iOS or non-Chrome browsers
            alert('💡 PWA Tip: This device supports direct NFC taps from lockscreen/home screen to open shared trip links!');
        }
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>