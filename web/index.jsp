<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (session.getAttribute("user") != null) {
        response.sendRedirect(request.getContextPath() + "/trips");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>LocalTrip — Smart Group Travel & Itinerary Planner</title>
    <meta name="description" content="Effortless group trips with zero-click vibe matching, smart itineraries, fair expense splitting, and NFC travel passport.">
    <meta name="theme-color" content="#175b43">
    <link rel="manifest" href="<%= request.getContextPath() %>/manifest.json">
    <link rel="icon" type="image/x-icon" href="<%= request.getContextPath() %>/favicon.ico">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mobile-user.css?v=3">
    <style>
        .lt-landing {
            max-width: 480px;
            margin: 0 auto;
            min-height: 100vh;
            background: #f8fafc;
            display: flex;
            flex-direction: column;
            padding-bottom: 30px;
        }
        .lt-landing-hero {
            background: linear-gradient(145deg, #175b43 0%, #143b2d 100%);
            color: #ffffff;
            padding: 42px 24px 36px;
            border-radius: 0 0 28px 28px;
            box-shadow: 0 8px 24px rgba(20, 59, 45, 0.2);
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .lt-landing-hero::after {
            content: "";
            position: absolute;
            top: -50px;
            right: -50px;
            width: 160px;
            height: 160px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 50%;
            pointer-events: none;
        }
        .lt-brand-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(8px);
            padding: 5px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.3px;
            margin-bottom: 18px;
        }
        .lt-landing-title {
            font-size: 28px;
            font-weight: 800;
            line-height: 1.25;
            margin-bottom: 12px;
            letter-spacing: -0.5px;
        }
        .lt-landing-title span {
            color: #f2b544;
        }
        .lt-landing-desc {
            font-size: 14px;
            color: #d1fae5;
            line-height: 1.5;
            margin-bottom: 24px;
            font-weight: 400;
        }
        .lt-landing-cta-wrap {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .lt-btn-cta-primary {
            background: #f2b544;
            color: #143b2d;
            font-weight: 700;
            font-size: 15px;
            padding: 14px 20px;
            border-radius: 14px;
            text-decoration: none;
            box-shadow: 0 4px 12px rgba(242, 181, 68, 0.35);
            transition: transform 0.15s ease;
            display: block;
        }
        .lt-btn-cta-primary:hover {
            background: #f5c464;
            color: #143b2d;
            transform: translateY(-1px);
        }
        .lt-btn-cta-secondary {
            background: rgba(255, 255, 255, 0.12);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.25);
            font-weight: 600;
            font-size: 14px;
            padding: 12px 20px;
            border-radius: 14px;
            text-decoration: none;
            display: block;
            backdrop-filter: blur(6px);
        }
        .lt-btn-cta-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
            color: #ffffff;
        }
        .lt-features-grid {
            padding: 24px 16px;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .lt-feature-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 18px 16px;
            display: flex;
            gap: 14px;
            align-items: flex-start;
            border: 1px solid #e2e8f0;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        }
        .lt-feature-icon-box {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-size: 20px;
        }
        .lt-feature-title {
            font-size: 15px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 4px;
        }
        .lt-feature-desc {
            font-size: 13px;
            color: #475569;
            line-height: 1.45;
            margin: 0;
        }
        .lt-landing-footer {
            margin-top: auto;
            text-align: center;
            padding: 16px 20px 0;
            font-size: 12px;
            color: #64748b;
        }
        .lt-landing-footer a {
            color: #175b43;
            text-decoration: none;
            font-weight: 600;
            margin: 0 6px;
        }
        .lt-landing-footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <main class="lt-landing">
        <section class="lt-landing-hero">
            <div class="lt-brand-pill">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="#f2b544"><path d="M12 2a6 6 0 0 0-6 6c0 4.5 6 12 6 12s6-7.5 6-12a6 6 0 0 0-6-6z"/></svg>
                <span>Mobile PWA & Companion</span>
            </div>

            <h1 class="lt-landing-title">
                Explore Local.<br>
                <span>Travel Together.</span>
            </h1>

            <p class="lt-landing-desc">
                The smart group itinerary planner for friends. Zero vibe mismatches, stress-free schedule building, and fair VietQR bill splitting.
            </p>

            <div class="lt-landing-cta-wrap">
                <a href="<%= request.getContextPath() %>/register" class="lt-btn-cta-primary">
                    Get Started — Free
                </a>
                <a href="<%= request.getContextPath() %>/login" class="lt-btn-cta-secondary">
                    Sign In to Existing Account
                </a>
            </div>
        </section>

        <section class="lt-features-grid">
            <%-- Feature 1 --%>
            <div class="lt-feature-card">
                <div class="lt-feature-icon-box" style="background: #eef2ff; color: #4f46e5;">
                    ✨
                </div>
                <div>
                    <h3 class="lt-feature-title">Zero-Click Vibe Match</h3>
                    <p class="lt-feature-desc">
                        Pick your favorite travel vibes once in your profile. When joining a trip, group chemistry scores and shared tastes are calculated automatically.
                    </p>
                </div>
            </div>

            <%-- Feature 2 --%>
            <div class="lt-feature-card">
                <div class="lt-feature-icon-box" style="background: #ecfdf5; color: #059669;">
                    🍱
                </div>
                <div>
                    <h3 class="lt-feature-title">Curated & AI Auto-Itinerary</h3>
                    <p class="lt-feature-desc">
                        Generate balanced daily schedules matching your pace and budget in seconds, or apply handpicked expert local combos.
                    </p>
                </div>
            </div>

            <%-- Feature 3 --%>
            <div class="lt-feature-card">
                <div class="lt-feature-icon-box" style="background: #fffbeb; color: #d97706;">
                    📲
                </div>
                <div>
                    <h3 class="lt-feature-title">Group Expense & VietQR Split</h3>
                    <p class="lt-feature-desc">
                        Track spending transparently, split bills per-person with checkboxes, and settle debts with one-tap VietQR bank transfers.
                    </p>
                </div>
            </div>

            <%-- Feature 4 --%>
            <div class="lt-feature-card">
                <div class="lt-feature-icon-box" style="background: #fdf2f8; color: #db2777;">
                    🛂
                </div>
                <div>
                    <h3 class="lt-feature-title">Travel Passport & NFC Connect</h3>
                    <p class="lt-feature-desc">
                        Instant tap-to-sync with companions via NFC, earn achievement badges at verified GPS spots, and preserve collective memory dumps.
                    </p>
                </div>
            </div>
        </section>

        <footer class="lt-landing-footer">
            <p style="margin-bottom: 6px;">&copy; 2026 LocalTrip. All rights reserved.</p>
            <p>
                <a href="<%= request.getContextPath() %>/privacy">Privacy Policy</a> &bull;
                <a href="<%= request.getContextPath() %>/terms">Terms of Service</a>
            </p>
        </footer>
    </main>
</body>
</html>
