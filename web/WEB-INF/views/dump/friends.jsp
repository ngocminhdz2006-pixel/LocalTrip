<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Friends" scope="request" />
<c:set var="tripRedesign" value="${true}" scope="request" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="lt-friends-container">

    <%-- 1. Header Bar: Friends Title + NFC Badge --%>
    <div class="lt-friends-header-bar">
        <h1 class="lt-friends-header-title">Friends</h1>
        <span class="lt-nfc-badge">NFC Ready</span>
    </div>

    <%-- Thông báo phản hồi --%>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger" role="alert" style="border-radius: 12px; font-size: 12px; margin-bottom: 12px;">
            <c:out value="${sessionScope.errorMessage}" />
        </div>
        <c:remove var="errorMessage" scope="session" />
    </c:if>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success" role="status" style="border-radius: 12px; font-size: 12px; margin-bottom: 12px;">
            <c:out value="${sessionScope.successMessage}" />
        </div>
        <c:remove var="successMessage" scope="session" />
    </c:if>

    <%-- 2. Search Bar: Search kiếm bạn bè từ xa --%>
    <div class="lt-friends-search-box">
        <form method="get" action="${pageContext.request.contextPath}/dump/friends" class="lt-search-input-wrap">
            <svg class="lt-search-icon" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
            </svg>
            <input type="search"
                   name="q"
                   minlength="2"
                   value="<c:out value='${keyword}'/>"
                   placeholder="Search by name or email..."
                   class="lt-search-input" />
            <button type="submit" class="lt-search-submit-btn">Search</button>
        </form>
    </div>

    <%-- Search results nếu có keyword --%>
    <c:if test="${not empty keyword or not empty searchResults}">
        <section class="lt-friends-section">
            <div class="lt-friends-section-head">
                <h2 class="lt-friends-section-title">Search results</h2>
                <span class="lt-friends-subtext">${fn:length(searchResults)} results</span>
            </div>
            <c:choose>
                <c:when test="${not empty searchResults}">
                    <c:forEach items="${searchResults}" var="person">
                        <div class="lt-friend-item">
                            <div class="lt-friend-profile">
                                <div class="lt-friend-avatar-wrap">
                                    <c:choose>
                                        <c:when test="${not empty person.fullName}">
                                            <c:out value="${fn:substring(person.fullName, 0, 1)}" />
                                        </c:when>
                                        <c:otherwise>?</c:otherwise>
                                    </c:choose>
                                </div>
                                <div>
                                    <h4 class="lt-friend-name"><c:out value="${person.fullName}" /></h4>
                                    <p class="lt-friend-sub" style="color: #64748b;"><c:out value="${person.email}" /></p>
                                </div>
                            </div>

                            <c:choose>
                                <c:when test="${person.status eq 'ACCEPTED'}">
                                    <span class="lt-btn-invite" style="background: #f1f5f9; color: #475569; border-color: #cbd5e1;">Friends</span>
                                </c:when>
                                <c:when test="${person.status eq 'PENDING' and person.requesterId eq sessionScope.user.userId}">
                                    <form method="post" action="${pageContext.request.contextPath}/dump/friends" style="margin: 0; display: inline-flex; align-items: center; gap: 4px;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="targetUserId" value="${person.userId}">
                                        <button class="lt-btn-invite" type="submit" style="background: #fef2f2; color: #dc2626; border-color: #fecaca; cursor: pointer;" title="Cancel sent friend request">
                                            ✕ Cancel request
                                        </button>
                                    </form>
                                </c:when>
                                <c:when test="${person.status eq 'PENDING'}">
                                    <span class="lt-btn-invite" style="background: #dbeafe; color: #1e40af; border-color: #bfdbfe;">Waiting for you</span>
                                </c:when>
                                <c:otherwise>
                                    <form method="post" action="${pageContext.request.contextPath}/dump/friends" style="margin: 0;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                        <input type="hidden" name="action" value="send">
                                        <input type="hidden" name="targetUserId" value="${person.userId}">
                                        <button class="lt-btn-invite" type="submit">+ Add friend</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p style="font-size: 11px; color: #64748b; padding: 10px; text-align: center; background: #fff; border-radius: 12px; border: 1px dashed #cbd5e1;">
                        No matching users found. Try another search.
                    </p>
                </c:otherwise>
            </c:choose>
        </section>
    </c:if>

    <%-- 3. Connect with NFC Card (Instant Pairing) --%>
    <div class="lt-nfc-pairing-card">
        <div class="lt-nfc-card-top">
            <div class="lt-nfc-card-info">
                <span class="lt-nfc-pill">Instant Pairing</span>
                <h2 class="lt-nfc-card-title">Connect with NFC</h2>
                <p class="lt-nfc-card-desc">Tap an NFC tag or phone to open LocalTrip profile instantly.</p>
            </div>
            <div class="lt-nfc-icon-box">
                <span>((•))</span>
                <span>Tap Tag</span>
            </div>
        </div>

        <%-- Dual Action Buttons: NFC + QR / Share link --%>
        <div class="lt-nfc-actions-dual">
            <button type="button" class="lt-btn-action-primary" onclick="triggerFriendNfcScan()">
                <span>🏷️</span> My NFC tag
            </button>
            <button type="button" class="lt-btn-action-secondary" onclick="openQrModal()">
                <span>🔳</span> QR / Share link
            </button>
        </div>
    </div>

    <%-- 4. Friend Requests (Friend requests nếu có) --%>
    <c:if test="${not empty friendRequests}">
        <section class="lt-friends-section">
            <div class="lt-friends-section-head">
                <h2 class="lt-friends-section-title">Friend requests</h2>
                <span class="lt-friends-subtext">${fn:length(friendRequests)} requests</span>
            </div>
            <c:forEach items="${friendRequests}" var="req">
                <div class="lt-friend-item">
                    <div class="lt-friend-profile">
                        <div class="lt-friend-avatar-wrap">
                            <c:out value="${fn:substring(req.fullName, 0, 1)}" />
                        </div>
                        <div>
                            <h4 class="lt-friend-name"><c:out value="${req.fullName}" /></h4>
                            <p class="lt-friend-sub" style="color: #64748b;"><c:out value="${req.email}" /></p>
                        </div>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/dump/friends" style="display: flex; gap: 6px; margin: 0;">
                        <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                        <input type="hidden" name="friendshipId" value="${req.friendshipId}">
                        <button type="submit" name="action" value="accept" class="lt-btn-invite" style="background: #175b43; color: #fff;">Accept</button>
                        <button type="submit" name="action" value="decline" class="lt-btn-invite" style="background: #f1f5f9; color: #475569; border-color: #e2e8f0;">Decline</button>
                    </form>
                </div>
            </c:forEach>
        </section>
    </c:if>

    <%-- 5. My Friends List --%>
    <section class="lt-friends-section">
        <div class="lt-friends-section-head">
            <h2 class="lt-friends-section-title">My Friends (${fn:length(friends)})</h2>
            <span class="lt-friends-subtext">Online now</span>
        </div>

        <c:choose>
            <c:when test="${empty friends}">
                <div style="background: #ffffff; border: 1px dashed #cbd5e1; border-radius: 16px; padding: 24px; text-align: center;">
                    <p style="font-size: 13px; font-weight: 600; color: #1e293b; margin: 0 0 4px;">No friends connected yet</p>
                    <p style="font-size: 11px; color: #64748b; margin: 0;">Search for friends above or tap NFC to connect instantly!</p>
                </div>
            </c:when>

            <c:otherwise>
                <c:forEach items="${friends}" var="f">
                    <div class="lt-friend-item">
                        <div class="lt-friend-profile">
                            <div class="lt-friend-avatar-wrap">
                                <c:out value="${fn:substring(f.fullName, 0, 1)}" />
                                <span class="lt-online-dot"></span>
                            </div>
                            <div>
                                <h4 class="lt-friend-name"><c:out value="${f.fullName}" /></h4>
                                <p class="lt-friend-sub">Connected via LocalTrip</p>
                            </div>
                        </div>
                        <div class="lt-friend-actions">
                            <button type="button" class="lt-btn-invite lt-btn-invite-trip"
                                    onclick="openTripInviteModal('${f.userId}', '<c:out value="${f.fullName}" escapeXml="true"/>', '<c:out value="${f.email}" escapeXml="true"/>')">
                                + Invite to Trip
                            </button>
                            <form method="post" action="${pageContext.request.contextPath}/dump/friends"
                                  onsubmit="return confirm('Remove <c:out value="${f.fullName}" escapeXml="true"/> from friends?');"
                                  style="margin: 0;">
                                <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                <input type="hidden" name="action" value="unfriend">
                                <input type="hidden" name="friendshipId" value="${f.friendshipId}">
                                <input type="hidden" name="targetUserId" value="${f.userId}">
                                <button type="submit" class="lt-btn-unfriend" title="Unfriend">
                                    Unfriend
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </section>

</div>

<%-- Modal QR / Share Link Fallback --%>
<div id="qrShareModal" class="lt-modal-backdrop" onclick="closeQrModal(event)">
    <div class="lt-modal-card" onclick="event.stopPropagation()">
        <h3 style="font-size: 15px; font-weight: 700; color: #143b2d; margin: 0 0 6px;">QR Code & Profile Link</h3>
        <p style="font-size: 11px; color: #64748b; margin: 0 0 12px;">Scan this code with iPhone Camera or Android to view profile</p>
        
        <div class="lt-modal-qr-wrap">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/dump/friends?q=${sessionScope.user.email}"
                 alt="Friend invite QR code" style="width: 160px; height: 160px; display: block; border-radius: 8px;">
        </div>

        <p style="font-size: 11px; font-weight: 600; color: #0f172a; margin: 8px 0 14px; word-break: break-all;">
            ${sessionScope.user.fullName} (${sessionScope.user.email})
        </p>

        <div style="display: flex; gap: 8px;">
            <button type="button" class="lt-btn-action-primary" style="flex: 1;" onclick="copyProfileLink()">
                📋 Copy Link
            </button>
            <button type="button" class="lt-btn-action-secondary" style="flex: 1;" onclick="document.getElementById('qrShareModal').style.display='none'">
                Close
            </button>
        </div>
    </div>
</div>

<%-- Modal Invite Friend to Planning Trip --%>
<div id="tripInviteModal" class="lt-modal-backdrop" onclick="closeTripInviteModal(event)">
    <div class="lt-modal-card" onclick="event.stopPropagation()" style="max-width: 420px; width: 92%;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
            <div>
                <h3 style="font-size: 16px; font-weight: 700; color: #143b2d; margin: 0 0 4px;">Invite to Trip</h3>
                <p style="font-size: 11.5px; color: #64748b; margin: 0;">
                    Inviting <strong id="modalFriendName" style="color: #175b43;"></strong> (<span id="modalFriendEmail"></span>)
                </p>
            </div>
            <button type="button" onclick="document.getElementById('tripInviteModal').style.display='none'"
                    style="background: none; border: none; font-size: 18px; color: #94a3b8; cursor: pointer; padding: 0 4px;">✕</button>
        </div>

        <c:choose>
            <c:when test="${not empty planningTrips}">
                <form method="post" action="${pageContext.request.contextPath}/trip/member/add" style="margin: 0;">
                    <input type="hidden" id="modalInviteEmail" name="email" value="">

                    <label style="display: block; font-size: 11px; font-weight: 700; color: #475569; margin-bottom: 6px;">
                        SELECT A PLANNING TRIP (YOU ARE OWNER):
                    </label>

                    <div style="display: flex; flex-direction: column; gap: 8px; max-height: 220px; overflow-y: auto; margin-bottom: 16px; padding: 2px;">
                        <c:forEach items="${planningTrips}" var="pTrip" varStatus="pStatus">
                            <label class="lt-trip-select-label">
                                <input type="radio" name="tripId" value="${pTrip.tripId}" ${pStatus.first ? 'checked' : ''} style="accent-color: #175b43;">
                                <div style="flex: 1; min-width: 0;">
                                    <div style="font-size: 12.5px; font-weight: 700; color: #143b2d;">
                                        <c:out value="${pTrip.tripName}" />
                                    </div>
                                    <div style="font-size: 10.5px; color: #64748b;">
                                        📍 <c:out value="${pTrip.destination}" /> · <fmt:formatDate value="${pTrip.startDate}" pattern="dd/MM/yyyy"/> - <fmt:formatDate value="${pTrip.endDate}" pattern="dd/MM/yyyy"/>
                                    </div>
                                </div>
                            </label>
                        </c:forEach>
                    </div>

                    <div style="display: flex; gap: 8px;">
                        <button type="submit" class="lt-btn-action-primary" style="flex: 1; border-radius: 12px; font-size: 12.5px;">
                            ✉️ Send Trip Invitation
                        </button>
                        <button type="button" class="lt-btn-action-secondary" style="flex: 1; border-radius: 12px; font-size: 12.5px;"
                                onclick="document.getElementById('tripInviteModal').style.display='none'">
                            Cancel
                        </button>
                    </div>
                </form>
            </c:when>
            <c:otherwise>
                <div style="background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 12px; padding: 18px; text-align: center; margin-bottom: 14px;">
                    <p style="font-size: 12.5px; font-weight: 600; color: #1e293b; margin: 0 0 4px;">No Planning Trips Available</p>
                    <p style="font-size: 11px; color: #64748b; margin: 0 0 12px;">You need to own an upcoming trip in Planning status to invite friends.</p>
                    <a href="${pageContext.request.contextPath}/trip/create" class="lt-btn-action-primary" style="display: inline-block; padding: 8px 16px; border-radius: 10px; font-size: 11.5px; text-decoration: none;">
                        + Create a New Trip
                    </a>
                </div>
                <button type="button" class="lt-btn-action-secondary" style="width: 100%; border-radius: 12px; font-size: 12px;"
                        onclick="document.getElementById('tripInviteModal').style.display='none'">
                    Close
                </button>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
    .lt-friend-actions {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .lt-btn-invite-trip {
        background: #175b43 !important;
        color: #ffffff !important;
        border: none !important;
        cursor: pointer;
        transition: background 0.15s ease;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
    }
    .lt-btn-invite-trip:hover {
        background: #143b2d !important;
    }
    .lt-btn-unfriend {
        background: #f8fafc;
        color: #94a3b8;
        border: 1px solid #e2e8f0;
        font-size: 11px;
        font-weight: 600;
        padding: 6px 10px;
        border-radius: 999px;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .lt-btn-unfriend:hover {
        background: #fef2f2;
        color: #dc2626;
        border-color: #fecaca;
    }
    .lt-trip-select-label {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        background: #f8fafc;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .lt-trip-select-label:hover {
        background: #ffffff;
        border-color: #175b43;
    }
</style>
<script>
    async function triggerFriendNfcScan() {
        if ('NDEFReader' in window) {
            try {
                const ndef = new NDEFReader();
                await ndef.scan();
                alert('NFC scanner activated! Tap your friend\'s NFC tag or phone against your device.');

                ndef.onreading = (event) => {
                    let scannedData = '';
                    const decoder = new TextDecoder();
                    for (const record of event.message.records) {
                        if (record.recordType === 'text') {
                            scannedData = decoder.decode(record.data);
                        } else if (record.recordType === 'url') {
                            scannedData = decoder.decode(record.data);
                        }
                    }

                    if (scannedData) {
                        let queryValue = scannedData.trim();
                        try {
                            if (queryValue.includes('http://') || queryValue.includes('https://')) {
                                const parsedUrl = new URL(queryValue);
                                const qParam = parsedUrl.searchParams.get('q');
                                if (qParam) {
                                    queryValue = qParam;
                                }
                            }
                        } catch (ignored) {}

                        window.location.href = '${pageContext.request.contextPath}/dump/friends?q=' + encodeURIComponent(queryValue);
                    }
                };

                ndef.onreadingerror = () => {
                    alert('Cannot read data from NFC tag. Please try tapping again.');
                };
            } catch (e) {
                alert('Cannot start NFC scan: ' + (e.message || e));
            }
        } else {
            // iOS / Desktop Fallback
            openQrModal();
        }
    }

    function openTripInviteModal(friendId, friendName, friendEmail) {
        document.getElementById('modalFriendName').innerText = friendName;
        document.getElementById('modalFriendEmail').innerText = friendEmail;
        const emailInput = document.getElementById('modalInviteEmail');
        if (emailInput) {
            emailInput.value = friendEmail;
        }
        document.getElementById('tripInviteModal').style.display = 'flex';
    }

    function closeTripInviteModal(e) {
        if (e.target.id === 'tripInviteModal') {
            e.target.style.display = 'none';
        }
    }

    function openQrModal() {
        document.getElementById('qrShareModal').style.display = 'flex';
    }

    function closeQrModal(e) {
        if (e.target.id === 'qrShareModal') {
            e.target.style.display = 'none';
        }
    }

    function copyProfileLink() {
        const link = window.location.origin + '${pageContext.request.contextPath}/dump/friends?q=${sessionScope.user.email}';
        if (navigator.clipboard) {
            navigator.clipboard.writeText(link).then(function() {
                alert('Friend invite link copied to clipboard: ' + link);
            });
        } else {
            prompt('Copy this link to share with friends:', link);
        }
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>