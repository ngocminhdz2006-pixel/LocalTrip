# Clock Audit & Classification — LocalTrip (AppClock)

This document classifies every clock read across `src/java/` into either **BUSINESS DATE** (governed by the centralized, simulatable `AppClock`) or **SECURITY/AUDIT** (strictly bound to the immutable real-world hardware clock).

---

## 🕒 Architecture & Separation Principles

1. **BUSINESS DATE:**
   - Covers domain calendar logic: trip start window eligibility, trip "Today" schedule, "Trip end date has passed!" banner, live milestone activity transitions, auto-itinerary date generation, seasonal combo availability, and GPS check-in timestamps.
   - **Action:** Routed through `utils.AppClock` (`today()`, `todaySql()`, `now()`, `nowTimestamp()`, `zone()`).
   - Supports time simulation in development via the Scenario Lab when explicitly enabled.

2. **SECURITY / AUDIT:**
   - Covers tokens with temporal lifespans (password reset tokens, remember-me persistent tokens, invite links), brute-force login lockouts, login logs, administrative audit logs, session cache TTLs, and HTTP request telemetry.
   - **Action:** Strictly preserved on the real system clock (`System.currentTimeMillis()`, SQL Server `SYSDATETIME()`) with explicit inline justifying comments.
   - **Security Invariant:** Tampering with simulated business dates must NEVER bypass token expirations, delay lockouts, or forge audit trails.

---

## 📊 Comprehensive Inventory Table

| # | File & Location | Clock Mechanism | Classification | Implementation Status |
|:---:|:---|:---|:---:|:---|
| 1 | `controller/ComboDraftServlet.java:222` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 2 | `controller/ComboPreviewServlet.java:98` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 3 | `controller/ComboServlet.java:170` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 4 | `controller/ComboSuggestionServlet.java:97` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 5 | `controller/auth/ForgotPasswordServlet.java:44` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// SECURITY` comment |
| 6 | `controller/auth/RememberMeUtil.java:40` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// SECURITY` comment |
| 7 | `controller/itinerary/AutoItineraryServlet.java:319` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.todaySql()` |
| 8 | `controller/itinerary/AutoItineraryServlet.java:360` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 9 | `controller/itinerary/ItineraryEditServlet.java:50` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.todaySql()` |
| 10 | `controller/itinerary/ItineraryServlet.java:413` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 11 | `controller/itinerary/ItineraryServlet.java:553` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 12 | `controller/itinerary/ItineraryServlet.java:1133` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 13 | `controller/trip/TripServlet.java:277` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 14 | `controller/trip/TripServlet.java:447` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.today()` |
| 15 | `controller/trip/TripStatusServlet.java:91` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.todaySql()` |
| 16 | `dao/ActivityLifecycleDAO.java:15` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.todaySql()` |
| 17 | `dao/ComboTemplateStatusDAO.java:46` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 18 | `dao/ComboTemplateWriteDAO.java:131` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 19 | `dao/ItineraryDAO.java:64` | `LocalDate.now(...)` | **BUSINESS DATE** | Converted to `AppClock.todaySql()` |
| 20 | `dao/LoginLogDAO.java:119` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* SECURITY */` comment |
| 21 | `dao/NotificationDAO.java:16` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 22 | `dao/NotificationDAO.java:49` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* SECURITY */` comment |
| 23 | `dao/NotificationDAO.java:52` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 24 | `dao/PasswordResetDAO.java:34` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* SECURITY */` comment |
| 25 | `dao/PasswordResetDAO.java:57` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* SECURITY */` comment |
| 26 | `dao/PasswordResetDAO.java:59` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* SECURITY */` comment |
| 27 | `dao/RememberMeDAO.java:31` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* SECURITY */` comment |
| 28 | `dao/SettlementDAO.java:205` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `// AUDIT` comment |
| 29 | `dao/SettlementDAO.java:278` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 30 | `dao/TravelFeatureDAO.java:144` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 31 | `dao/TravelFeatureDAO.java:172` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 32 | `dao/TravelFeatureDAO.java:190` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 33 | `dao/TravelFeatureDAO.java:383` | Default SQL `SYSDATETIME()` | **BUSINESS DATE** | Explicit `checkin_time` parameter via `AppClock.nowTimestamp()` |
| 34 | `dao/TravelFeatureDAO.java:427` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* AUDIT */` comment |
| 35 | `dao/TripInviteDAO.java:20` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* SECURITY */` comment |
| 36 | `dao/TripInviteDAO.java:44` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// SECURITY` comment |
| 37 | `dao/TripInviteDAO.java:81` | SQL `SYSDATETIME()` | **SECURITY/AUDIT** | Retained with `/* SECURITY */` comment |
| 38 | `dao/UserDAO.java:445` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// AUDIT/SECURITY` comment |
| 39 | `filter/AuthFilter.java:96` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// TELEMETRY` comment |
| 40 | `model/ItineraryDraft.java:24` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// CACHE/SESSION` comment |
| 41 | `model/ItineraryDraft.java:36` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// CACHE/SESSION` comment |
| 42 | `model/Notification.java:114` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// UI DISPLAY` comment |
| 43 | `model/TripInvite.java:74` | `System.currentTimeMillis()` | **SECURITY/AUDIT** | Retained with `// SECURITY` comment |

---

## 🛡️ Summary Totals
- **Total Clock Reads Evaluated:** 43
- **BUSINESS DATE (converted to `AppClock`):** 14 (100% complete)
- **SECURITY / AUDIT (retained on real system clock with comments):** 29 (100% complete)
