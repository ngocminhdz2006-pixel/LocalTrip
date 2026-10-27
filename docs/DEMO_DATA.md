# Demo Dataset & Test Scenarios — LocalTrip

This document details the re-runnable demo dataset designed to exercise every major feature of the LocalTrip platform without requiring manual trip creation.

---

## 🔒 Safety Guards & Environment Isolation

1. **Email Domain Marker:** All demo accounts are isolated under `@demo.localtrip.test`.
2. **Strict Foreign Key Isolation:** Demo trips are strictly owned by demo users. Deletions and resets never affect real user accounts (`*@localtrip.vn`, etc.) or production data.
3. **Production Abort Guard:** Both `sql/demo_seed.sql` and `sql/demo_reset.sql` verify that the database is not flagged as Production via SQL Server extended properties:
   ```sql
   IF EXISTS (
       SELECT 1 FROM sys.extended_properties 
       WHERE name = 'Environment' AND CAST(value AS NVARCHAR(100)) = 'Production'
   )
   BEGIN
       RAISERROR(N'SAFETY CHECK ABORT: Cannot run demo scripts on a database marked as Production!', 16, 1);
       SET NOEXEC ON;
   END
   ```
4. **Dynamic Relative Dates:** All dates use `DATEADD(day, N, CAST(SYSDATETIME() AS DATE))` relative to runtime today. The dataset will remain fresh and accurate regardless of when it is executed.

---

## 🚀 How to Load and Reset

### 1. Load Demo Data (Idempotent)
Runs `demo_seed.sql`, which safely resets existing demo data and seeds users, trips A through F, itinerary items, expenses, group funds, settlements, social dumps, check-ins, and badges:

```powershell
sqlcmd -S localhost -U sa -P 12345 -d LocalTripDB -i "sql\demo_seed.sql"
```

> **Note on Terminal Encodings:**
> If running on Windows terminal with non-standard codepages, pass `-f 65001` (UTF-8):
> ```powershell
> sqlcmd -S localhost -U sa -P 12345 -d LocalTripDB -f 65001 -i "sql\demo_seed.sql"
> ```
> *The script is idempotent and safe to run repeatedly without accumulating duplicates.*

### 2. Reset Demo Data
To completely remove all demo data while leaving real accounts and trips 100% untouched:

```powershell
sqlcmd -S localhost -U sa -P 12345 -d LocalTripDB -i "sql\demo_reset.sql"
```

---

## 👥 Demo User Accounts

> [!IMPORTANT]
> **Password Notice:** All demo accounts share a known development password hashed via PBKDF2-HMAC-SHA256 (600,000 iterations). 
> See the comment in the header of `sql/demo_seed.sql` for the development credentials (`Demo123456!`). 
> **These accounts are strictly for local testing and demonstration purposes.**

| Email | Full Name | Role | Primary Scenario / Usage |
|---|---|---|---|
| `admin@demo.localtrip.test` | Admin LocalTrip | `ADMIN` | Admin portal, audit logs, category & place management |
| `alice@demo.localtrip.test` | Alice Nguyen | `USER` | **Primary Trip Owner** for Scenarios A through F |
| `bob@demo.localtrip.test` | Bob Tran | `USER` | Co-traveler (Trips B, C, D, E, F), Expense payer, Social commenter |
| `charlie@demo.localtrip.test` | Charlie Le | `USER` | Co-traveler (Trips B, C, E), Settlement debtor, Post author |
| `david@demo.localtrip.test` | David Pham | `USER` | Co-traveler (Trips B, E), Settlement debtor, Reporter of spam |
| `emma@demo.localtrip.test` | Emma Vu | `USER` | Co-traveler (Trip E), Settlement debtor, Friend requester |
| `frank@demo.localtrip.test` | Frank Hoang | `USER` | Community traveler for social discovery & invitations |
| `grace@demo.localtrip.test` | Grace Do | `USER` | Community traveler for social discovery & invitations |
| `henry@demo.localtrip.test` | Henry Dang | `USER` | Community traveler for social discovery & invitations |

---

## 🗺️ Scenario Matrix (Trips A through F)

All demo trips are owned by **Alice Nguyen** (`alice@demo.localtrip.test`). Logging in as Alice surfaces each scenario:

| Scenario Code & Name | Trip Status | Scheduled Window | Key Features Tested |
|---|---|---|---|
| **[DEMO] A - Planning, empty** | `PLANNING` | Today +7d &rarr; Today +9d | Empty itinerary state, companion invitation flow, preference alignment ("Sync Vibes"), and manual item addition. |
| **[DEMO] B - Planning, ready** | `PLANNING` | **Today** &rarr; Today +2d | 4-member group (`Alice`, `Bob`, `Charlie`, `David`), full 2-day itinerary with locked milestones, active invite token (`expires_at > now`), expired invite token. **Eligible to click "Start Trip" today!** |
| **[DEMO] C - Ongoing, live milestones** | `ONGOING` | Today -1d &rarr; Today +1d | Spans **today** with activities across all 4 statuses: past `COMPLETED` activities, exactly one `IN_PROGRESS` activity (triggers **🔴 Happening Now**), multiple `UPCOMING` activities (triggers **⏳ Next Up**), and one `CANCELLED` (skipped) activity. |
| **[DEMO] D - Ongoing, ended** | `ONGOING` | Today -3d &rarr; Today -1d | End date concluded yesterday while status remains `ONGOING`. Triggers the **"Trip end date has passed!"** warning banner with the action button to complete the trip. |
| **[DEMO] E - Completed, settlements** | `COMPLETED` | Today -6d &rarr; Today -2d | 5-member group (`Alice`, `Bob`, `Charlie`, `David`, `Emma`). Equal splits, unequal splits, group fund contributions (1.5M VND), group fund spending (300k VND), and settlement transfers across **`PENDING`**, **`SENT`**, and **`CONFIRMED`** states. |
| **[DEMO] F - Cancelled** | `CANCELLED` | Today +3d &rarr; Today +5d | Pre-departure cancellation lifecycle and display of cancelled itinerary items. |

---

## 📸 Social, Travel Passport & Badges

- **Friendships:**
  - `ACCEPTED`: Alice &harr; Bob, Alice &harr; Charlie, Bob &harr; Charlie.
  - `PENDING`: David &rarr; Alice, Emma &rarr; Alice.
- **GPS Check-Ins:**
  - Verified GPS check-ins at *Dinh Độc Lập* (14.2m), *Bưu điện Trung tâm Sài Gòn* (8.0m), *The Workshop Coffee* (3.1m), and *Phố đi bộ Nguyễn Huệ* (15.5m), all complying with `distance_meters <= 200` and the unique `(user_id, place_id)` constraint.
- **Community Posts & Moderation:**
  - Public posts by Alice, Bob, and Charlie with photo landmarks and star ratings.
  - Social interactions: Comments and Likes across travelers.
  - Moderation Report: One open report in `dbo.PostReports` (`status = 'OPEN'`) submitted by David against a spam link, testable from the Admin portal.
- **Badges:**
  - `FIRST_5` badge awarded to Alice and Bob in `dbo.UserBadges`.
  - Public Travel Passport enabled for Alice, Bob, and Charlie in `dbo.TravelPassportSettings`.

---

## ⚠️ Schema Constraints & Design Notes

1. **Expense Amounts:**
   - Database constraint `CK_Expenses_Amount` enforces `amount > 0`. Therefore, refund/negative expense rows are rejected by the schema; negative balances are modeled mathematically through unequal splits and debtor/creditor settlement netting.
2. **Activity Types & Milestones:**
   - Table `dbo.ItineraryItems` check constraint `CK_ItineraryItems_ActivityType` permits `VISIT`, `MEAL`, `CAFE`, and `REST`.
   - `CK_ItineraryItems_ActivityPlace` requires `place_id IS NOT NULL` for all activities unless `activity_type = 'REST'` with an activity title.
3. **Live Milestone Uniqueness:**
   - Business logic allows at most one `IN_PROGRESS` item per trip at any given time. Trip C seeds exactly one item with `activity_status = 'IN_PROGRESS'` today.
