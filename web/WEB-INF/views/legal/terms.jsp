<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Terms of Service" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="container py-4" style="max-width: 600px;">
    <div class="card shadow-sm border-0 rounded-4 p-4" style="background: #ffffff;">
        <div class="d-flex align-items-center gap-2 mb-3">
            <span style="font-size: 24px;">📜</span>
            <h2 class="h4 mb-0 fw-bold" style="color: #175b43;">Terms of Service</h2>
        </div>
        <p class="text-muted small">Effective Date: October 2026</p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">1. Acceptance of Terms</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            By creating an account or using LocalTrip, you agree to these Terms of Service. If you disagree with any part of these terms, please refrain from using the service.
        </p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">2. User Conduct & Community Guidelines</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            Users are responsible for all content posted in trip discussions and community memory dumps. Abusive, fraudulent, defamatory, or copyright-infringing content is strictly prohibited and subject to immediate account termination.
        </p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">3. Group Expenses & Settlements</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            LocalTrip acts as an itinerary planning and expense ledger calculation tool. It does not act as an escrow agent or financial institution. Users are solely responsible for verifying amounts before completing bank transfers.
        </p>

        <h5 class="fw-bold mt-3" style="color: #0f172a; font-size: 15px;">4. Service Availability</h5>
        <p class="text-secondary small" style="line-height: 1.6;">
            We strive to provide reliable offline-first PWA features, but cannot guarantee uninterrupted availability due to external network or server conditions.
        </p>

        <div class="mt-4 pt-3 border-top text-center">
            <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm px-4 rounded-pill">Back</a>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
