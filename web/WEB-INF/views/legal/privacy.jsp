<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Privacy Policy" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="container py-4" style="max-width: 600px;">
    <div class="card shadow-sm border-0 rounded-4 p-4" style="background: #ffffff;">
        <div class="d-flex align-items-center gap-2 mb-3">
            <span style="font-size: 24px;">🛡️</span>
            <h2 class="h4 mb-0 fw-bold" style="color: #175b43;">Privacy Policy</h2>
        </div>
        <p class="text-muted small">Effective Date: October 2026</p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">1. Information We Collect</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            LocalTrip collects information you provide directly, such as your name, email, travel preferences, and group trip data. To enable verified check-ins and travel passport milestones, we request access to your device's GPS location strictly when you tap "Check-in Here".
        </p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">2. How We Use Location & Travel Data</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            GPS coordinates are used solely to calculate your proximity to local places for badge unlocks. We do not track your real-time location in the background or sell your location data to third parties.
        </p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">3. Photos & Memory Dumps</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            Uploaded memory photos are stored securely and displayed only to your trip companions or community based on the visibility setting you choose (Public vs. Friends).
        </p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">4. Expense & VietQR Records</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            Group expenses and bank payment identifiers are visible only to members of that specific trip. LocalTrip does not process bank transactions directly; payment settlements are executed via standard VietQR deep links to your banking application.
        </p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">5. Account Deletion Rights</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            You have the right to delete your account at any time via your Account Settings. Deletion anonymizes your personal information and deactivates your login credentials permanently.
        </p>

        <div class="mt-4 pt-3 border-top text-center">
            <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm px-4 rounded-pill">Back</a>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
