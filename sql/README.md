# Database Setup & Migration Guide — LocalTrip

This directory contains the complete SQL Server scripts for the **LocalTripDB** database ecosystem (compatible with Microsoft SQL Server 2017, 2019, 2022, and Azure SQL).

---

## 🎯 Recommended Database Setup Approaches

### Option 1: Clean Installation / Scratch Setup (Recommended)
Use this option when initializing a new local environment or wiping previous state to start clean with all modern features (Token Invites, 2-Way Settlement Tracking, AI Itinerary Locking, Travel Passport, GPS Check-ins, and 47 curated Ho Chi Minh City destinations).

👉 Run **ONE SINGLE CONSOLIDATED SCRIPT**:
```sql
sql/LocalTripDB_RESET.sql
```
* **How to run:**
  1. Open **SQL Server Management Studio (SSMS)**, VS Code mssql, or command line `sqlcmd`:
     ```powershell
     sqlcmd -S localhost -U sa -P <YOUR_SA_PASSWORD> -i "sql\LocalTripDB_RESET.sql"
     ```
  2. The script drops and recreates `LocalTripDB`, creates all 34 relational tables, sets foreign keys, indexes, triggers, and seeds production-ready sample data.
  3. (Optional / Idempotent validation):
     ```powershell
     sqlcmd -S localhost -U sa -P <YOUR_SA_PASSWORD> -i "sql\upgrade_v3_full.sql"
     sqlcmd -S localhost -U sa -P <YOUR_SA_PASSWORD> -i "sql\clean_legacy_notes.sql"
     ```

---

### Option 2: Sequential Migration Order (From Empty Database)
If applying schema migrations progressively from the historical base schema without using the all-in-one reset script, execute the scripts in the following **exact tested dependency order**:

1. `01_schema.sql` — Initializes `LocalTripDB` and foundational tables (`Users`, `Trips`, `TripMembers`, `Categories`, `TripMemberPreferences`, `Places`).
2. `02_seed_data.sql` — Seeds default admin, test users, sample trip, and initial Saigon places.
3. `03_auth_role_migration.sql` — Creates `RememberMeTokens` and `PasswordResetTokens` tables.
4. `04_auth_recovery.sql` — Adds recovery fields and user status constraints.
5. `05_admin_audit_log.sql` — Creates `AdminAuditLogs` for security audit logging.
6. `LocalTrip_FIX_Missing_Core_Tables.sql` — Creates core itinerary and expense tracking tables (`ItineraryItems`, `Expenses`, `ExpenseParticipants`).
7. `06_group_fund.sql` — Creates `GroupFundContributions` table.
8. `06b_login_history.sql` — Creates `LoginLogs` for security audit tracking.
9. `07_more_places.sql` — Seeds additional verified attractions and destinations.
10. `08_place_regions.sql` — Adds `district_name` column and populates urban regions.
11. `10_seasonal_combos.sql` — Seeds seasonal combo packages and activity mappings.
12. `11_dump_checkin_passport_badges.sql` — Creates social dump and travel passport tables (`Friendships`, `Posts`, `PostImages`, `PostLikes`, `PostComments`, `PostBookmarks`, `PostReports`, `CheckIns`, `CheckInImages`, `TravelPassportSettings`, `TravelBadges`, `UserBadges`).
13. `12_admin_combo_templates.sql` — Creates curated combo template architecture (`ComboTemplates`, `ComboTemplateCategories`, `ComboTemplateItems`).
14. `13_itinerary_activity_lifecycle.sql` — Adds per-activity lifecycle tracking (`activity_status`, `actual_start_time`, `actual_end_time`, `check_in_time`).
15. `upgrade_v2_product.sql` — Adds user preference tags (`UserPreferences`), combo reviews (`ComboReviews`), and trip-combo linkage (`applied_combo_id`).
16. `upgrade_v3_full.sql` — Adds token-based invites (`TripInvites`), in-trip notes (`TripNotes`), two-way settlements (`SettlementPayments`), activity locks (`is_locked`, `source_type`), and normalizes categories/badges to English.
17. `clean_legacy_notes.sql` — Normalizes legacy structured milestone notes in existing itinerary items.
18. `upgrade_v5_scenario_lab.sql` — Adds `sim_batch_id` isolation columns and filtered indexes to `Users` and `Trips` for Scenario Lab data isolation.

*(Note: `09_fund_settlement_diagnostics.sql` is a diagnostic query script used for balance inspection, not a schema migration).

---

### Option 3: Dynamic Demo Dataset (Relative Dates & Full Scenarios)
When you need a rich, fully populated dataset for presentations, feature testing, or QA, use the idempotent demo dataset:

- **`demo_seed.sql`**: Safely cleans existing demo data and seeds 9 demo accounts (`*@demo.localtrip.test`), trips across scenarios A through F (empty planning, startable planning today, live ongoing with "Happening Now", ended ongoing with warning banner, completed with 3-way settlements and group funds, and cancelled), GPS check-ins, social posts, reports, and badges.
  ```powershell
  sqlcmd -S localhost -U sa -P <PASSWORD> -d LocalTripDB -i "sql\demo_seed.sql"
  ```
- **`demo_reset.sql`**: Removes **only** demo accounts and demo trips in strict foreign key order, leaving real user data (`*@localtrip.vn`) 100% untouched.
  ```powershell
  sqlcmd -S localhost -U sa -P <PASSWORD> -d LocalTripDB -i "sql\demo_reset.sql"
  ```

📖 See [docs/DEMO_DATA.md](../docs/DEMO_DATA.md) for full scenario matrix, test accounts, and development credentials.*

---

## 🔑 Pre-seeded Test Accounts

All pre-seeded test accounts share the default password: **`123456`**

| Role | Name | Email | Password | Details |
| :--- | :--- | :--- | :--- | :--- |
| **ADMIN** | Nguyễn Ngọc Minh | `minh@localtrip.vn` | `123456` | Full admin privileges, system logs, place/combo curation |
| **USER** | Thanh | `thanh@localtrip.vn` | `123456` | Owner of the sample trip (`LocalTrip Demo - TP.HCM`) |
| **USER** | Nguyễn Lan Anh | `lananh@localtrip.vn` | `123456` | Member with Food & Cafe preferences, friend of Minh |
| **USER** | Hoàng Nam | `hoangnam@localtrip.vn` | `123456` | Member with Entertainment & Sightseeing preferences |

---

## ⚙️ Connection Configuration (`DBContext.java`)

Default local connection configuration:
- **Server:** `localhost:1433`
- **Database:** `LocalTripDB`
- **User:** Configured in `web/META-INF/context.xml` or via `DB_USER`
- **Password:** Configured in `web/META-INF/context.xml` or via `DB_PASSWORD`

### Environment Variables & System Properties
The application supports configuration via environment variables or JVM system properties without code modifications:
- `DB_SERVER` or `DB_HOST`: Hostname or IP address (Default: `localhost`)
- `DB_PORT`: Database port (Default: `1433`)
- `DB_NAME`: Database catalog name (Default: `LocalTripDB`)
- `DB_USER`: Database login user
- `DB_PASSWORD`: Database login password (Must be explicitly set; no insecure default)
- `DB_ENCRYPT`: Connection encryption flag (`true` or `false`)
- `DB_TRUST_CERT`: Trust server certificate (`true` or `false`)
- `APP_ENV`: Environment flag (`development` or `production`). In `production`, default passwords and `sa` user are strictly rejected at startup.
