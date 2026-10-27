# LocalTrip — End-to-End Smoke Test Script

This document provides a comprehensive, numbered manual test script covering the complete core lifecycle of the **LocalTrip** web application on a clean database setup.

---

## 🛠️ Prerequisites & Setup

1. **Database:** Initialize a fresh database by running `sql/LocalTripDB_RESET.sql`:
   ```powershell
   sqlcmd -S localhost -U sa -P 12345 -i "sql\LocalTripDB_RESET.sql"
   ```
2. **Server:** Start Apache Tomcat 9 with application deployed at:
   ```
   http://localhost:8080/LocalTrip
   ```
3. **Pre-seeded Owner Account (for quick testing if desired):**
   - Email: `thanh@localtrip.vn`
   - Password: `123456`

---

## 📋 Numbered Step-by-Step Test Procedure

### 1. User Registration
* **Target URL:** `http://localhost:8080/LocalTrip/register`
* **Method:** `GET` / `POST`
* **Action:**
  1. Open the registration page.
  2. Fill in the form:
     - **Full Name:** `Alex Turner`
     - **Email:** `alex@localtrip.vn`
     - **Password:** `123456`
     - **Confirm Password:** `123456`
  3. Click **"Create Account"**.
* **Expected Result:**
  - Form validates successfully (Unicode name rules applied).
  - User record created in `dbo.Users` with role `USER`, `is_active = 1`, and PBKDF2 password hash.
  - Redirected to `/login` with flash message: `"Registration successful! Please log in."`.

---

### 2. User Authentication (Login)
* **Target URL:** `http://localhost:8080/LocalTrip/login`
* **Method:** `GET` / `POST`
* **Action:**
  1. Enter email `alex@localtrip.vn` and password `123456`.
  2. (Optional) Check **"Remember me"**.
  3. Click **"Sign In"**.
* **Expected Result:**
  - Login succeeds. Audit entry recorded in `dbo.LoginLogs`.
  - Session established (`sessionScope.user` populated).
  - Redirected to Trips dashboard (`/trips`).
  - Top navigation bar displays user name `Alex Turner` and user avatar pill.

---

### 3. Create a New Trip
* **Target URL:** `http://localhost:8080/LocalTrip/trip/create`
* **Method:** `GET` / `POST`
* **Action:**
  1. Click **"+ New Trip"** button or navigate to `/trip/create`.
  2. Enter trip details:
     - **Trip Name:** `Saigon Weekend Discovery`
     - **Destination:** `Ho Chi Minh City, Vietnam`
     - **Start Date:** *Current Date (Today, e.g. 2026-10-24)*
     - **End Date:** *Current Date + 3 Days (e.g. 2026-10-27)*
     - **Budget:** `2500000`
     - **Description:** `Exploring local street food, cafes, and historical spots.`
  3. Click **"Create Trip"**.
* **Expected Result:**
  - Record created in `dbo.Trips` with `status = 'PLANNING'`.
  - Membership row added in `dbo.TripMembers` with `user_id = Alex` and `member_role = 'OWNER'`.
  - Redirected to Trip Detail view: `/trip/detail?tripId=<newTripId>`.
  - Wizard displays **Step 1: Invite Companions & Sync Vibes**.

---

### 4. Invite Companion via Link & Auto-Join (Private Window Flow)
* **Target URL:** `http://localhost:8080/LocalTrip/trip/invite` & `/trip/join`
* **Method:** `POST` `/trip/invite` (generates token), `GET` `/trip/join?token=<token>`
* **Action:**
  1. On the Trip Detail page as Alex, click **"Copy Invite Link"**.
     *(Link format: `http://localhost:8080/LocalTrip/trip/join?token=<inviteToken>`)*.
  2. Open an **Incognito / InPrivate Browser Window** (unauthenticated).
  3. Paste the invite link into the address bar and press Enter.
  4. Notice the system intercepts the request:
     - Redirected to `/login` with banner: `"Please sign in or create an account to accept the trip invitation."`.
     - Session remembers `redirectAfterLogin`.
  5. Click **"Sign up here"** (`/register`) in the private window.
  6. Register a new companion account:
     - **Full Name:** `Chloe Adams`
     - **Email:** `chloe@localtrip.vn`
     - **Password:** `123456`
     - **Confirm Password:** `123456`
  7. Submit registration -> redirected to `/login`.
  8. Log in with `chloe@localtrip.vn` / `123456`.
* **Expected Result:**
  - Upon login, `LoginServlet` immediately honors `redirectAfterLogin` and forwards to `/trip/join?token=<inviteToken>`.
  - `TripInviteServlet` auto-joins Chloe into `dbo.TripMembers` (`member_role = 'MEMBER'`).
  - Chloe is redirected to `/trip/detail?tripId=<newTripId>` with success toast:
    `"Welcome aboard! You have joined \"Saigon Weekend Discovery\"."`.
  - Member count in Step 1 updates to **"2 travelers connected"**.

---

### 5. Set Personal Travel Preferences
* **Target URL:** `http://localhost:8080/LocalTrip/account`
* **Method:** `GET` / `POST`
* **Action:**
  1. In Chloe's private session, click on user profile -> **"Account"** (`/account`).
  2. In the **"Travel Taste & Vibes"** section, select checkboxes:
     - `[x] Food & Dining`
     - `[x] Cafe & Drinks`
     - `[x] Sightseeing`
  3. Click **"Save Preferences"** (`action=savePreferences`).
* **Expected Result:**
  - Selected preferences saved in `dbo.UserPreferences`.
  - Flash toast: `"Travel preferences updated successfully! New trips will now auto-match your taste."`.
  - Navigate back to `/trip/detail?tripId=<newTripId>`:
    - Step 1 recalculates group preferences across connected members.
    - Displays synchronized vibe chips with match percentages (e.g., `Food & Dining 100%`, `Cafe & Drinks 100%`).

---

### 6. Build Schedule: Add Places & Apply Curated Combo
* **Target URL:** `http://localhost:8080/LocalTrip/combos` & `/itinerary`
* **Method:** `GET` / `POST`
* **Action (as Trip Owner Alex):**
  1. On `/trip/detail?tripId=<newTripId>`, navigate to **Step 2: Build Your Schedule**.
  2. Click **"Apply Curated Combo"** (`/combos?tripId=<newTripId>`).
  3. Click on the pre-seeded combo: `1-Day Iconic Saigon: Cafe & Heritage`.
  4. Review the timeline of stops, then click **"Apply This Combo"** (`/combos/draft/confirm`).
* **Expected Result:**
  - 6 itinerary activities inserted into `dbo.ItineraryItems` with `activity_status = 'UPCOMING'`, assigned dates and time slots.
  - Trip updated with `applied_combo_id`.
  - Redirected to `/itinerary?tripId=<newTripId>` displaying the structured 3-tier activity cards.

---

### 7. Start Trip (Planning -> Ongoing)
* **Target URL:** `http://localhost:8080/LocalTrip/trip/status`
* **Method:** `POST`
* **Business Rule Requirements:**
  - Caller must be `OWNER`.
  - `start_date <= today <= end_date` (evaluated in `Asia/Ho_Chi_Minh` timezone).
  - Must have at least 1 non-cancelled itinerary item.
  - Valid `statusToken` matching session.
* **Action:**
  1. On the Trip Detail page or Itinerary view, click the green **"Start trip now"** button.
* **Expected Result:**
  - `TripStatusDAO.changeStatus()` updates `dbo.Trips.status` to `'ONGOING'`.
  - UI updates badge to **"🚀 Trip Active"** / **"Live & Tracking"**.
  - Button switches to **"Mark trip as completed"**.
  - Itinerary cards display interactive live action buttons: `Start`, `Directions`, `Lock`.

---

### 8. Live Activity Lifecycle (Start / Skip / Complete Activities)
* **Target URL:** `http://localhost:8080/LocalTrip/itinerary/activity/status`
* **Method:** `POST`
* **Action & Verification Sequence:**
  1. **Start First Activity:**
     - On Activity #1 (`The Workshop Coffee`), click **"Start"** (`action=start&itemId=<id1>`).
     - *Expected:* Status changes `UPCOMING -> IN_PROGRESS`. `actual_start_time` recorded. Card renders pulsing orange **"In Progress"** badge and **"Complete"** button.
  2. **Rule Enforcement (Single Running Activity):**
     - Attempt to click **"Start"** on Activity #2 (`43 Factory Coffee`).
     - *Expected:* Blocked with error message: only one activity may be in progress at a time.
  3. **Complete Activity:**
     - Click **"Complete"** on Activity #1 (`action=complete&itemId=<id1>`).
     - *Expected:* Status changes `IN_PROGRESS -> COMPLETED`. `actual_end_time` recorded. Card renders dark green **"Completed"** badge.
  4. **Skip / Cancel Activity:**
     - On Activity #3, click the action dropdown / menu -> click **"Skip Activity"** (`action=skip&itemId=<id3>`).
     - *Expected:* Status changes to `CANCELLED`. Card renders grey **"Skipped"** badge.

---

### 9. Add Trip Expenses
* **Target URL:** `http://localhost:8080/LocalTrip/expenses/create?tripId=<newTripId>`
* **Method:** `GET` / `POST`
* **Action:**
  1. Click **"Expenses"** tab on trip or navigate to `/expenses?tripId=<newTripId>`.
  2. Click **"+ Add Expense"**.
  3. Fill out the expense form:
     - **Payer:** `Alex Turner`
     - **Amount:** `300,000` VND
     - **Description:** `Dinner & Drinks at Ben Thanh Market`
     - **Split Method:** `EQUAL` (Split evenly)
     - **Participants:** Check both `[x] Alex Turner` and `[x] Chloe Adams`.
  4. Click **"Save Expense"**.
* **Expected Result:**
  - Expense row inserted into `dbo.Expenses`.
  - 2 split rows inserted into `dbo.ExpenseParticipants` (150,000 VND each).
  - Redirected to `/expenses?tripId=<newTripId>` showing total spent `300,000 VND`.

---

### 10. Two-Way Debt Settlement Flow (PENDING -> SENT -> CONFIRMED)
* **Target URL:** `http://localhost:8080/LocalTrip/settlement?tripId=<newTripId>`
* **Method:** `GET` / `POST`
* **Action & Verification Sequence:**
  1. **View Balances (as Chloe Adams):**
     - Navigate to `/settlement?tripId=<newTripId>` in Chloe's private window.
     - Chloe owes Alex `150,000 VND`.
     - System displays debt card with initial status **`PENDING`** and Alex's bank/VietQR transfer details.
  2. **Payer Marks as Sent:**
     - Chloe clicks **"I Have Paid"** (`POST /settlement` with `action=markSent&paymentId=<id>&tripId=<newTripId>`).
     - *Expected:* Status transitions `PENDING -> SENT`.
     - Flash toast: `"Payment marked as SENT. Waiting for recipient confirmation."`.
  3. **Recipient Confirms Payment:**
     - Switch back to Alex Turner's window and refresh `/settlement?tripId=<newTripId>`.
     - Alex sees the transfer request labeled **`SENT`** with an incoming confirmation prompt.
     - Alex clicks **"Confirm Received"** (`POST /settlement` with `action=confirmReceived&paymentId=<id>&tripId=<newTripId>`).
     - *Expected:* Status transitions `SENT -> CONFIRMED`.
     - Flash toast: `"Payment confirmed successfully!"`. Transfer is finalized.

---

### 11. Finalize & Complete Trip
* **Target URL:** `http://localhost:8080/LocalTrip/trip/status`
* **Method:** `POST`
* **Action:**
  1. As Trip Owner Alex, return to `/trip/detail?tripId=<newTripId>`.
  2. Click **"Mark trip as completed"** (`status=COMPLETED`).
* **Expected Result:**
  - `dbo.Trips.status` transitions `ONGOING -> COMPLETED`.
  - Status badge updates to **"✓ Completed"**.
  - Combo review prompt appears linking to `/combo/review?tripId=<newTripId>` allowing members to rate the applied itinerary.

---

### 12. Location Check-In & Travel Passport
* **Target URL:** `http://localhost:8080/LocalTrip/checkin`
* **Method:** `GET` / `POST`
* **Action:**
  1. Browse to verified place #1 (`The Workshop Coffee`, `placeId=2`).
  2. Click **"Check-in Here"** (`/checkin?placeId=2&tripId=<newTripId>`).
  3. Submit check-in with GPS coordinates within 200m of venue (e.g., Latitude `10.771900`, Longitude `106.704600`).
* **Expected Result:**
  - Geofence validator confirms distance <= 200m.
  - Entry inserted into `dbo.CheckIns`.
  - Award badge rules evaluate (e.g. `Saigon Explorer` in `dbo.UserBadges`).
  - Check-in appears on user's Travel Passport (`/passport`).

---

### 14. Real Notifications & Activity Sync
* **Target URL:** `http://localhost:8080/LocalTrip/notifications`
* **Method:** `GET` / `POST`
* **Action:**
  1. Click notification bell in header navigation bar.
  2. Verify `/notifications` displays genuine activity notifications (`TRIP_ADDED`, `TRIP_JOINED`, `TRIP_STATUS`, `EXPENSE_ADDED`, `PAYMENT_SENT`, `PAYMENT_CONFIRMED`, `ITINERARY_CHANGE`).
  3. Verify adding `?demo=1` displays identical real data with zero mock records and zero demo banners.
  4. Click **"Mark all read"** -> POST issued with `csrfToken` -> unread counter badge in header resets to 0.
* **Expected Result:**
  - Real notifications loaded from `dbo.Notifications`.
  - Filter pills allow filtering by All, Trips, Friends, and Expenses.
  - No fake data injected via query parameters.

---

### 13. Account Deletion & Anonymization
* **Target URL:** `http://localhost:8080/LocalTrip/account`
* **Method:** `POST`
* **Action:**
  1. In Chloe's session, navigate to `/account`.
  2. Scroll to the bottom danger zone. Click **"Delete Account"**.
  3. Confirm the modal action (`action=deleteAccount`).
* **Expected Result:**
  - `UserDAO.deactivateAndAnonymize(user_id)` executes:
    - Sets `is_active = 0`.
    - Clears personal data and invalidates stored password hash.
    - Revokes Remember-Me tokens.
  - Session invalidated.
  - Redirected to `/login` with notification:
    `"Your account has been deleted and deactivated successfully."`.
  - Attempting to log back in with `chloe@localtrip.vn` is rejected with:
    `"Account has been deactivated. Please contact support."`.

---

## 🎯 Verification Summary Matrix

| Step | Feature / URL | Expected DB Effect | Primary Success Criterion |
| :--- | :--- | :--- | :--- |
| **1** | Register (`/register`) | Row in `Users` (`USER`) | Redirect to `/login` with success banner |
| **2** | Login (`/login`) | Row in `LoginLogs` | Session initialized, redirected to `/trips` |
| **3** | Create Trip (`/trip/create`) | Row in `Trips` & `TripMembers` (`OWNER`) | Redirect to `/trip/detail?tripId=X` |
| **4** | Invite / Join (`/trip/join`) | Row in `TripInvites` & `TripMembers` (`MEMBER`) | Auto-join after auth in private session |
| **5** | Preferences (`/account`) | Rows in `UserPreferences` | Vibe match chips recalculate dynamically |
| **6** | Combos (`/combos`) | Rows in `ItineraryItems` (`UPCOMING`) | Curated stops populated into timeline |
| **7** | Start Trip (`/trip/status`) | `Trips.status = 'ONGOING'` | Status badge becomes "Live & Tracking" |
| **8** | Activity Status (`/itinerary/activity/status`) | `activity_status` updates | Only 1 `IN_PROGRESS` allowed at a time |
| **9** | Expenses (`/expenses/create`) | Rows in `Expenses` & `ExpenseParticipants` | Total and individual splits computed |
| **10** | Settlement (`/settlement`) | `SettlementPayments.status` transitions | PENDING -> SENT -> CONFIRMED |
| **11** | Complete Trip (`/trip/status`) | `Trips.status = 'COMPLETED'` | Finalized state, combo review unlocked |
| **12** | Check-in (`/checkin`) | Row in `CheckIns`, badge in `UserBadges` | GPS verified, added to Travel Passport |
| **13** | Notifications (`/notifications`) | Rows in `Notifications` (`is_read` flag) | Real updates only, unread count in header |
| **14** | Delete Account (`/account`) | `Users.is_active = 0`, hash cleared | Immediate logout, future logins blocked |
