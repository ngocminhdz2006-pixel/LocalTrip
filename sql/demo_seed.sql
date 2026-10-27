-- ==============================================================================
-- LocalTrip — Production-Grade Demo Seed Script (Idempotent & Relative Dates)
-- File: sql/demo_seed.sql
--
-- PURPOSE:
-- Seed a complete, cohesive demo dataset so every feature can be exercised without
-- manual data entry.
--
-- SAFETY GUARDS:
-- 1. All demo users use the marker domain '@demo.localtrip.test'.
-- 2. Demo password: 'Demo123456!' (PBKDF2-HMAC-SHA256, 600,000 iterations).
--    *** NOTICE: THIS PASSWORD IS FOR LOCAL DEVELOPMENT / DEMO / TESTING ONLY! ***
--    *** NEVER DEPLOY OR USE DEMO ACCOUNTS IN PRODUCTION! ***
-- 3. Production check aborts immediately if extended property 'Environment' = 'Production'.
-- 4. Idempotent: completely resets existing demo data before re-seeding.
-- 5. All dates are RELATIVE to runtime date (DATEADD from CAST(SYSDATETIME() AS DATE)).
-- ==============================================================================

USE LocalTripDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;

-- Abort if database is explicitly tagged as Production
IF EXISTS (
    SELECT 1 FROM sys.extended_properties 
    WHERE name = 'Environment' AND CAST(value AS NVARCHAR(100)) = 'Production'
)
BEGIN
    RAISERROR(N'SAFETY CHECK ABORT: Cannot run demo scripts on a database marked as Production!', 16, 1);
    SET NOEXEC ON;
END
GO

PRINT N'Starting Demo Data Seed (Relative Dates)...';

BEGIN TRANSACTION;

BEGIN TRY
    -- ==========================================================================
    -- STEP 0: CLEAN EXISTING DEMO DATA (IDEMPOTENCY)
    -- ==========================================================================
    PRINT N'Step 0: Clearing existing demo data...';

    DELETE FROM dbo.Notifications
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR actor_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR trip_id IN (
           SELECT trip_id FROM dbo.Trips 
           WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       );

    DELETE FROM dbo.AdminAuditLogs
    WHERE actor_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR target_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.PostReports
    WHERE reporter_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR post_id IN (
           SELECT post_id FROM dbo.Posts 
           WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
              OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
       );

    DELETE FROM dbo.PostLikes
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR post_id IN (
           SELECT post_id FROM dbo.Posts 
           WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
              OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
       );

    DELETE FROM dbo.PostComments
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR post_id IN (
           SELECT post_id FROM dbo.Posts 
           WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
              OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
       );

    DELETE FROM dbo.PostBookmarks
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR post_id IN (
           SELECT post_id FROM dbo.Posts 
           WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
              OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
       );

    DELETE FROM dbo.PostImages
    WHERE post_id IN (
        SELECT post_id FROM dbo.Posts 
        WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
           OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
    );

    DELETE FROM dbo.Posts
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR trip_id IN (
           SELECT trip_id FROM dbo.Trips 
           WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       );

    DELETE FROM dbo.CheckInImages
    WHERE checkin_id IN (
        SELECT checkin_id FROM dbo.CheckIns 
        WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
           OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
    );

    DELETE FROM dbo.CheckIns
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR trip_id IN (
           SELECT trip_id FROM dbo.Trips 
           WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       );

    DELETE FROM dbo.ComboReviews
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR trip_id IN (
           SELECT trip_id FROM dbo.Trips 
           WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       );

    DELETE FROM dbo.UserBadges
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.TravelPassportSettings
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.ExpenseParticipants
    WHERE expense_id IN (
        SELECT expense_id FROM dbo.Expenses 
        WHERE trip_id IN (
            SELECT trip_id FROM dbo.Trips 
            WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
        )
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.Expenses
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR payer_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
      OR created_by IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.SettlementPayments
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR from_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
      OR to_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.GroupFundContributions
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
      OR created_by IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.ItineraryItems
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    );

    DELETE FROM dbo.TripNotes
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.TripInvites
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR created_by IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.TripMemberPreferences
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.TripMembers
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.Trips
    WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.Friendships
    WHERE requester_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR addressee_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.UserPreferences
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.RememberMeTokens
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.PasswordResetTokens
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.LoginLogs
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.Users
    WHERE email LIKE '%@demo.localtrip.test';

    -- ==========================================================================
    -- STEP 1: DEMO USERS (1 Admin, 8 Normal Users)
    -- Demo password: 'Demo123456!' (600,000 iterations PBKDF2)
    -- ==========================================================================
    PRINT N'Step 1: Creating demo users...';
    DECLARE @DemoPasswordHash NVARCHAR(255) = N'600000:935186f53befced7860aaca8ee3771da:824dc8670dd32a4f9ba2aa42fa02ad4e9fb62b2b8fa926a01ebfd676cbd06c1f';

    INSERT INTO dbo.Users (full_name, email, password_hash, role, is_active, created_at)
    VALUES
        (N'Admin LocalTrip', N'admin@demo.localtrip.test', @DemoPasswordHash, 'ADMIN', 1, SYSDATETIME()),
        (N'Alice Nguyen',   N'alice@demo.localtrip.test', @DemoPasswordHash, 'USER',  1, SYSDATETIME()),
        (N'Bob Tran',       N'bob@demo.localtrip.test',   @DemoPasswordHash, 'USER',  1, SYSDATETIME()),
        (N'Charlie Le',     N'charlie@demo.localtrip.test', @DemoPasswordHash, 'USER', 1, SYSDATETIME()),
        (N'David Pham',     N'david@demo.localtrip.test', @DemoPasswordHash, 'USER',  1, SYSDATETIME()),
        (N'Emma Vu',        N'emma@demo.localtrip.test',  @DemoPasswordHash, 'USER',  1, SYSDATETIME()),
        (N'Frank Hoang',    N'frank@demo.localtrip.test', @DemoPasswordHash, 'USER',  1, SYSDATETIME()),
        (N'Grace Do',       N'grace@demo.localtrip.test', @DemoPasswordHash, 'USER',  1, SYSDATETIME()),
        (N'Henry Dang',     N'henry@demo.localtrip.test', @DemoPasswordHash, 'USER',  1, SYSDATETIME());

    -- Fetch user IDs
    DECLARE @u_admin INT = (SELECT user_id FROM dbo.Users WHERE email = N'admin@demo.localtrip.test');
    DECLARE @u_alice INT = (SELECT user_id FROM dbo.Users WHERE email = N'alice@demo.localtrip.test');
    DECLARE @u_bob INT = (SELECT user_id FROM dbo.Users WHERE email = N'bob@demo.localtrip.test');
    DECLARE @u_charlie INT = (SELECT user_id FROM dbo.Users WHERE email = N'charlie@demo.localtrip.test');
    DECLARE @u_david INT = (SELECT user_id FROM dbo.Users WHERE email = N'david@demo.localtrip.test');
    DECLARE @u_emma INT = (SELECT user_id FROM dbo.Users WHERE email = N'emma@demo.localtrip.test');
    DECLARE @u_frank INT = (SELECT user_id FROM dbo.Users WHERE email = N'frank@demo.localtrip.test');
    DECLARE @u_grace INT = (SELECT user_id FROM dbo.Users WHERE email = N'grace@demo.localtrip.test');
    DECLARE @u_henry INT = (SELECT user_id FROM dbo.Users WHERE email = N'henry@demo.localtrip.test');

    -- Setup User Preferences (Categories: 1=FOOD, 2=CAFE, 3=SIGHTSEEING, 4=ENTERTAINMENT, 5=SHOPPING)
    INSERT INTO dbo.UserPreferences (user_id, category_id, created_at)
    VALUES
        (@u_alice, 1, SYSDATETIME()), (@u_alice, 2, SYSDATETIME()), (@u_alice, 3, SYSDATETIME()),
        (@u_bob, 1, SYSDATETIME()), (@u_bob, 2, SYSDATETIME()), (@u_bob, 4, SYSDATETIME()),
        (@u_charlie, 1, SYSDATETIME()), (@u_charlie, 3, SYSDATETIME()), (@u_charlie, 5, SYSDATETIME()),
        (@u_david, 1, SYSDATETIME()), (@u_david, 3, SYSDATETIME()),
        (@u_emma, 2, SYSDATETIME()), (@u_emma, 5, SYSDATETIME());

    -- Setup Passport Settings
    INSERT INTO dbo.TravelPassportSettings (user_id, visibility, updated_at)
    VALUES
        (@u_alice, 'PUBLIC', SYSDATETIME()),
        (@u_bob, 'PUBLIC', SYSDATETIME()),
        (@u_charlie, 'PUBLIC', SYSDATETIME());

    -- Award Badges (1: FIRST_5)
    INSERT INTO dbo.UserBadges (user_id, badge_id, earned_at)
    VALUES
        (@u_alice, 1, DATEADD(day, -5, SYSDATETIME())),
        (@u_bob, 1, DATEADD(day, -4, SYSDATETIME()));

    -- ==========================================================================
    -- STEP 2: LOOK UP EXISTING PLACES
    -- Patterns support both UTF-8 (-f 65001) and default ANSI terminal environments
    -- ==========================================================================
    PRINT N'Step 2: Looking up existing places...';
    DECLARE @p_DinhDocLap INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Dinh Độc Lập%' OR place_name LIKE '%Dinh %');
    DECLARE @p_BuuDien    INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Bưu điện Trung tâm%' OR place_name LIKE '%B_u %i_n%');
    DECLARE @p_DucBa      INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Nhà thờ Đức Bà%' OR place_name LIKE '%Nh_ th_ %');
    DECLARE @p_NguyenHue  INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Nguyễn Huệ%' OR place_name LIKE '%Nguy_n Hu_%');
    DECLARE @p_Workshop   INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%The Workshop Coffee%' OR place_name LIKE '%Workshop%');
    DECLARE @p_PhoHoa     INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Phở Hòa Pasteur%' OR place_name LIKE '%Pasteur%');
    DECLARE @p_BenThanh   INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Chợ Bến Thành%' OR place_name LIKE '%B_n Th_nh%');
    DECLARE @p_BaGhien    INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Ba Ghiền%' OR place_name LIKE '%Ba Ghi_n%');
    DECLARE @p_BaoTang    INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Chứng tích Chiến tranh%' OR place_name LIKE '%Ch_ng t_ch%');

    IF @p_DinhDocLap IS NULL OR @p_BuuDien IS NULL OR @p_DucBa IS NULL OR @p_Workshop IS NULL OR @p_PhoHoa IS NULL
    BEGIN
        RAISERROR(N'Missing foundational places in dbo.Places. Ensure 02_seed_data.sql or LocalTripDB_RESET.sql was executed.', 16, 1);
    END

    -- Anchor relative date to today
    DECLARE @today DATE = CAST(SYSDATETIME() AS DATE);

    -- ==========================================================================
    -- STEP 3: DEMO TRIPS A - F (All owned by Alice Nguyen)
    -- ==========================================================================
    PRINT N'Step 3: Creating demo trips A through F...';

    -- --------------------------------------------------------------------------
    -- SCENARIO A: PLANNING, no itinerary
    -- --------------------------------------------------------------------------
    INSERT INTO dbo.Trips (owner_id, trip_name, destination, start_date, end_date, budget, description, status, created_at)
    VALUES (@u_alice, N'[DEMO] A - Planning, empty', N'TP. Hồ Chí Minh', DATEADD(day, 7, @today), DATEADD(day, 9, @today), 2500000,
            N'Idea phase with 0 activities; ready to add places and companions.', 'PLANNING', SYSDATETIME());
    DECLARE @trip_A INT = SCOPE_IDENTITY();

    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role, joined_at)
    VALUES (@trip_A, @u_alice, 'OWNER', SYSDATETIME());

    -- --------------------------------------------------------------------------
    -- SCENARIO B: PLANNING with full itinerary, start_date = today (Ready to Start)
    -- Group of 4: Alice (OWNER), Bob, Charlie, David
    -- --------------------------------------------------------------------------
    INSERT INTO dbo.Trips (owner_id, trip_name, destination, start_date, end_date, budget, description, status, created_at)
    VALUES (@u_alice, N'[DEMO] B - Planning, ready', N'TP. Hồ Chí Minh', @today, DATEADD(day, 2, @today), 5000000,
            N'Ready to depart today! Click Start Trip to transition to ONGOING.', 'PLANNING', SYSDATETIME());
    DECLARE @trip_B INT = SCOPE_IDENTITY();

    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role, joined_at)
    VALUES
        (@trip_B, @u_alice, 'OWNER', SYSDATETIME()),
        (@trip_B, @u_bob, 'MEMBER', SYSDATETIME()),
        (@trip_B, @u_charlie, 'MEMBER', SYSDATETIME()),
        (@trip_B, @u_david, 'MEMBER', SYSDATETIME());

    -- Trip B Member Preferences
    INSERT INTO dbo.TripMemberPreferences (trip_id, user_id, category_id, created_at)
    VALUES
        (@trip_B, @u_alice, 1, SYSDATETIME()), (@trip_B, @u_alice, 2, SYSDATETIME()), (@trip_B, @u_alice, 3, SYSDATETIME()),
        (@trip_B, @u_bob, 1, SYSDATETIME()), (@trip_B, @u_bob, 2, SYSDATETIME()),
        (@trip_B, @u_charlie, 1, SYSDATETIME()), (@trip_B, @u_charlie, 3, SYSDATETIME()),
        (@trip_B, @u_david, 1, SYSDATETIME()), (@trip_B, @u_david, 3, SYSDATETIME());

    -- Trip B Notes
    INSERT INTO dbo.TripNotes (trip_id, user_id, note_text, created_at)
    VALUES
        (@trip_B, @u_alice, N'Don''t forget to bring walking shoes and power banks!', SYSDATETIME()),
        (@trip_B, @u_bob, N'Grab rides booked for the morning schedule at 8:15 AM.', SYSDATETIME());

    -- Trip B Invites (1 Active, 1 Expired)
    INSERT INTO dbo.TripInvites (trip_id, invite_token, created_by, expires_at, is_active, created_at)
    VALUES
        (@trip_B, 'demo_token_trip_b_active_0123456789abcdef0123456789abcdef012345', @u_alice, DATEADD(day, 7, SYSDATETIME()), 1, SYSDATETIME()),
        (@trip_B, 'demo_token_trip_b_expired_0123456789abcdef0123456789abcdef0123', @u_alice, DATEADD(day, -3, SYSDATETIME()), 0, DATEADD(day, -10, SYSDATETIME()));

    -- Trip B Full Itinerary (Day 1: Today, Day 2: Tomorrow) - All UPCOMING
    INSERT INTO dbo.ItineraryItems (trip_id, place_id, visit_date, start_time, end_time, note, estimated_cost, activity_type, activity_title, activity_status, created_at, is_locked, source_type)
    VALUES
        (@trip_B, @p_DinhDocLap, @today, '08:30', '10:30', N'Historical landmark tour', 40000, 'VISIT', N'Dinh Độc Lập Tour', 'UPCOMING', SYSDATETIME(), 1, 'MANUAL'),
        (@trip_B, @p_PhoHoa,     @today, '11:30', '13:00', N'Traditional beef noodle soup', 90000, 'MEAL', N'Lunch at Phở Hòa Pasteur', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_B, @p_Workshop,   @today, '14:00', '16:00', N'Coffee break & plan afternoon', 90000, 'CAFE', N'Coffee Break', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_B, @p_BuuDien,    @today, '16:30', '18:00', N'Sightseeing & group photos', 0, 'VISIT', N'Central Post Office Visit', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_B, @p_DucBa,      DATEADD(day, 1, @today), '09:00', '11:00', N'Architectural photo stop', 0, 'VISIT', N'Notre Dame Cathedral', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_B, @p_BaGhien,    DATEADD(day, 1, @today), '11:30', '13:00', N'Famous broken rice lunch', 110000, 'MEAL', N'Lunch at Cơm Tấm Ba Ghiền', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_B, @p_BaoTang,    DATEADD(day, 1, @today), '14:00', '16:30', N'Historical exhibition', 40000, 'VISIT', N'War Remnants Museum Tour', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL');

    -- --------------------------------------------------------------------------
    -- SCENARIO C: ONGOING, spanning today, with activities in every status:
    -- completed, one IN_PROGRESS, several UPCOMING, one CANCELLED (skipped)
    -- Group: Alice (OWNER), Bob, Charlie
    -- --------------------------------------------------------------------------
    INSERT INTO dbo.Trips (owner_id, trip_name, destination, start_date, end_date, budget, description, status, created_at)
    VALUES (@u_alice, N'[DEMO] C - Ongoing, live milestones', N'TP. Hồ Chí Minh', DATEADD(day, -1, @today), DATEADD(day, 1, @today), 6000000,
            N'Happening right now! Spans today with live milestone tracking.', 'ONGOING', SYSDATETIME());
    DECLARE @trip_C INT = SCOPE_IDENTITY();

    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role, joined_at)
    VALUES
        (@trip_C, @u_alice, 'OWNER', SYSDATETIME()),
        (@trip_C, @u_bob, 'MEMBER', SYSDATETIME()),
        (@trip_C, @u_charlie, 'MEMBER', SYSDATETIME());

    INSERT INTO dbo.TripNotes (trip_id, user_id, note_text, created_at)
    VALUES (@trip_C, @u_bob, N'Exhibition tickets purchased in advance.', SYSDATETIME());

    -- Itinerary Items for Trip C across all 4 statuses
    INSERT INTO dbo.ItineraryItems (trip_id, place_id, visit_date, start_time, end_time, note, estimated_cost, activity_type, activity_title, activity_status, created_at, is_locked, source_type)
    VALUES
        -- Yesterday (Day 1): Completed and Cancelled
        (@trip_C, @p_DinhDocLap, DATEADD(day, -1, @today), '09:00', '11:00', N'Completed morning tour', 40000, 'VISIT', N'Dinh Độc Lập', 'COMPLETED', SYSDATETIME(), 1, 'MANUAL'),
        (@trip_C, @p_PhoHoa,     DATEADD(day, -1, @today), '12:00', '13:30', N'Completed lunch', 90000, 'MEAL', N'Phở Hòa Pasteur', 'COMPLETED', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_C, @p_DucBa,      DATEADD(day, -1, @today), '15:00', '16:30', N'Skipped due to sudden thunderstorm', 0, 'VISIT', N'Notre Dame Cathedral', 'CANCELLED', SYSDATETIME(), 0, 'MANUAL'),
        -- Today (Day 2): One Completed, EXACTLY ONE IN_PROGRESS (Happening Now), and Upcoming
        (@trip_C, @p_BuuDien,    @today, '09:00', '10:30', N'Completed morning photo walk', 0, 'VISIT', N'Saigon Central Post Office', 'COMPLETED', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_C, @p_Workshop,   @today, '11:00', '13:00', N'Happening right now – artisan coffee and work break', 90000, 'CAFE', N'The Workshop Coffee Break', 'IN_PROGRESS', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_C, @p_BaoTang,    @today, '14:30', '16:30', N'Next up this afternoon', 40000, 'VISIT', N'War Remnants Museum', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_C, @p_NguyenHue,  @today, '18:00', '20:30', N'Evening walking street breeze', 0, 'VISIT', N'Nguyễn Huệ Walking Street', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL'),
        -- Tomorrow (Day 3): Upcoming
        (@trip_C, @p_BenThanh,   DATEADD(day, 1, @today), '09:00', '11:30', N'Local souvenir shopping', 0, 'VISIT', N'Bến Thành Market Exploration', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_C, @p_BaGhien,    DATEADD(day, 1, @today), '12:00', '13:30', N'Farewell group lunch', 110000, 'MEAL', N'Cơm Tấm Ba Ghiền', 'UPCOMING', SYSDATETIME(), 0, 'MANUAL');

    -- --------------------------------------------------------------------------
    -- SCENARIO D: ONGOING but end_date = yesterday (Triggers "trip has ended" warning banner)
    -- --------------------------------------------------------------------------
    INSERT INTO dbo.Trips (owner_id, trip_name, destination, start_date, end_date, budget, description, status, created_at)
    VALUES (@u_alice, N'[DEMO] D - Ongoing, ended', N'TP. Hồ Chí Minh', DATEADD(day, -3, @today), DATEADD(day, -1, @today), 3500000,
            N'Scheduled dates have ended while status is still ONGOING. Shows trip-ended banner.', 'ONGOING', SYSDATETIME());
    DECLARE @trip_D INT = SCOPE_IDENTITY();

    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role, joined_at)
    VALUES
        (@trip_D, @u_alice, 'OWNER', SYSDATETIME()),
        (@trip_D, @u_bob, 'MEMBER', SYSDATETIME());

    INSERT INTO dbo.ItineraryItems (trip_id, place_id, visit_date, start_time, end_time, note, estimated_cost, activity_type, activity_title, activity_status, created_at, is_locked, source_type)
    VALUES
        (@trip_D, @p_DinhDocLap, DATEADD(day, -3, @today), '09:00', '11:00', N'Historical visit', 40000, 'VISIT', N'Dinh Độc Lập', 'COMPLETED', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_D, @p_PhoHoa,     DATEADD(day, -2, @today), '12:00', '13:30', N'Lunch', 90000, 'MEAL', N'Phở Hòa Pasteur', 'COMPLETED', SYSDATETIME(), 0, 'MANUAL');

    -- --------------------------------------------------------------------------
    -- SCENARIO E: COMPLETED, with expenses (equal & unequal splits, group fund)
    -- and settlements in PENDING, SENT, and CONFIRMED states
    -- 5-member group: Alice (OWNER), Bob, Charlie, David, Emma
    -- --------------------------------------------------------------------------
    INSERT INTO dbo.Trips (owner_id, trip_name, destination, start_date, end_date, budget, description, status, created_at)
    VALUES (@u_alice, N'[DEMO] E - Completed, settlements', N'TP. Hồ Chí Minh', DATEADD(day, -6, @today), DATEADD(day, -2, @today), 10000000,
            N'Completed journey with full expense splits, group fund, and all settlement payment states.', 'COMPLETED', SYSDATETIME());
    DECLARE @trip_E INT = SCOPE_IDENTITY();

    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role, joined_at)
    VALUES
        (@trip_E, @u_alice, 'OWNER', SYSDATETIME()),
        (@trip_E, @u_bob, 'MEMBER', SYSDATETIME()),
        (@trip_E, @u_charlie, 'MEMBER', SYSDATETIME()),
        (@trip_E, @u_david, 'MEMBER', SYSDATETIME()),
        (@trip_E, @u_emma, 'MEMBER', SYSDATETIME());

    -- Itinerary Items
    INSERT INTO dbo.ItineraryItems (trip_id, place_id, visit_date, start_time, end_time, note, estimated_cost, activity_type, activity_title, activity_status, created_at, is_locked, source_type)
    VALUES
        (@trip_E, @p_DinhDocLap, DATEADD(day, -5, @today), '09:00', '11:30', N'Completed tour', 40000, 'VISIT', N'Dinh Độc Lập', 'COMPLETED', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_E, @p_PhoHoa,     DATEADD(day, -5, @today), '12:00', '13:30', N'Lunch', 90000, 'MEAL', N'Phở Hòa Pasteur', 'COMPLETED', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_E, @p_Workshop,   DATEADD(day, -4, @today), '14:00', '16:00', N'Coffee afternoon', 90000, 'CAFE', N'The Workshop Coffee', 'COMPLETED', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_E, @p_NguyenHue,  DATEADD(day, -3, @today), '19:00', '21:00', N'Evening walk', 0, 'VISIT', N'Phố đi bộ Nguyễn Huệ', 'COMPLETED', SYSDATETIME(), 0, 'MANUAL');

    -- Group Fund Contributions (Total Contributed: 1,500,000 VND)
    INSERT INTO dbo.GroupFundContributions (trip_id, user_id, amount, note, created_by, created_at)
    VALUES
        (@trip_E, @u_alice,   500000, N'Quỹ chung ban đầu (Initial fund)', @u_alice, DATEADD(day, -6, SYSDATETIME())),
        (@trip_E, @u_bob,     500000, N'Góp quỹ chung (Group fund contribution)', @u_bob, DATEADD(day, -6, SYSDATETIME())),
        (@trip_E, @u_charlie, 500000, N'Góp quỹ chung (Group fund contribution)', @u_charlie, DATEADD(day, -6, SYSDATETIME()));

    -- Expense 1: Paid by Alice (500,000 VND), Equal split (100k each among Alice, Bob, Charlie, David, Emma)
    -- Net effect: Alice paid 500k, owes 100k (+400k); Bob owes 100k; Charlie owes 100k; David owes 100k; Emma owes 100k
    INSERT INTO dbo.Expenses (trip_id, payer_id, created_by, description, amount, from_group_fund, created_at)
    VALUES (@trip_E, @u_alice, @u_alice, N'Vé tham quan & Hướng dẫn viên (Tour guide & Tickets)', 500000, 0, DATEADD(day, -5, SYSDATETIME()));
    DECLARE @exp_1 INT = SCOPE_IDENTITY();

    INSERT INTO dbo.ExpenseParticipants (expense_id, user_id, share_amount)
    VALUES
        (@exp_1, @u_alice,   100000),
        (@exp_1, @u_bob,     100000),
        (@exp_1, @u_charlie, 100000),
        (@exp_1, @u_david,   100000),
        (@exp_1, @u_emma,    100000);

    -- Expense 2: Paid by Bob (1,000,000 VND), Unequal split
    -- Alice owes 200k, Bob owes 200k, Charlie owes 300k, David owes 300k, Emma owes 0.
    -- Net effect: Bob paid 1,000k, owes 200k (+800k). Total Net: Alice +200k, Bob +700k; Charlie -400k, David -400k, Emma -100k.
    INSERT INTO dbo.Expenses (trip_id, payer_id, created_by, description, amount, from_group_fund, created_at)
    VALUES (@trip_E, @u_bob, @u_bob, N'Bữa tối hải sản nướng (Seafood Dinner)', 1000000, 0, DATEADD(day, -4, SYSDATETIME()));
    DECLARE @exp_2 INT = SCOPE_IDENTITY();

    INSERT INTO dbo.ExpenseParticipants (expense_id, user_id, share_amount)
    VALUES
        (@exp_2, @u_alice,   200000),
        (@exp_2, @u_bob,     200000),
        (@exp_2, @u_charlie, 300000),
        (@exp_2, @u_david,   300000),
        (@exp_2, @u_emma,         0);

    -- Expense 3: Group Fund Spending (300,000 VND)
    -- CK_Expenses_Amount enforces amount > 0, so negative expenses/refunds are rejected by schema.
    INSERT INTO dbo.Expenses (trip_id, payer_id, created_by, description, amount, from_group_fund, created_at)
    VALUES (@trip_E, @u_alice, @u_alice, N'Nước uống & Bánh ngọt quỹ chung (Group Snacks & Drinks)', 300000, 1, DATEADD(day, -4, SYSDATETIME()));
    DECLARE @exp_3 INT = SCOPE_IDENTITY();

    INSERT INTO dbo.ExpenseParticipants (expense_id, user_id, share_amount)
    VALUES
        (@exp_3, @u_alice,   60000),
        (@exp_3, @u_bob,     60000),
        (@exp_3, @u_charlie, 60000),
        (@exp_3, @u_david,   60000),
        (@exp_3, @u_emma,    60000);

    -- Settlement Payments matching the calculated transfers in PENDING, SENT, and CONFIRMED states:
    -- Transfer 1: Charlie -> Bob (400,000) -> CONFIRMED
    -- Transfer 2: David -> Bob (300,000)   -> SENT
    -- Transfer 3: David -> Alice (100,000) -> PENDING
    -- Transfer 4: Emma -> Alice (100,000)  -> CONFIRMED
    INSERT INTO dbo.SettlementPayments (trip_id, from_user_id, to_user_id, amount, status, updated_at, created_at)
    VALUES
        (@trip_E, @u_charlie, @u_bob,   400000, 'CONFIRMED', DATEADD(day, -2, SYSDATETIME()), DATEADD(day, -3, SYSDATETIME())),
        (@trip_E, @u_david,   @u_bob,   300000, 'SENT',      DATEADD(day, -1, SYSDATETIME()), DATEADD(day, -3, SYSDATETIME())),
        (@trip_E, @u_david,   @u_alice, 100000, 'PENDING',   DATEADD(day, -3, SYSDATETIME()), DATEADD(day, -3, SYSDATETIME())),
        (@trip_E, @u_emma,    @u_alice, 100000, 'CONFIRMED', DATEADD(day, -2, SYSDATETIME()), DATEADD(day, -3, SYSDATETIME())),
        (@trip_E, @u_charlie, @u_alice, 400000, 'CONFIRMED', DATEADD(day, -2, SYSDATETIME()), DATEADD(day, -3, SYSDATETIME()));

    -- --------------------------------------------------------------------------
    -- SCENARIO F: CANCELLED
    -- --------------------------------------------------------------------------
    INSERT INTO dbo.Trips (owner_id, trip_name, destination, start_date, end_date, budget, description, status, created_at)
    VALUES (@u_alice, N'[DEMO] F - Cancelled', N'TP. Hồ Chí Minh', DATEADD(day, 3, @today), DATEADD(day, 5, @today), 2000000,
            N'Cancelled trip prior to departure due to companion scheduling conflicts.', 'CANCELLED', SYSDATETIME());
    DECLARE @trip_F INT = SCOPE_IDENTITY();

    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role, joined_at)
    VALUES
        (@trip_F, @u_alice, 'OWNER', SYSDATETIME()),
        (@trip_F, @u_bob, 'MEMBER', SYSDATETIME());

    INSERT INTO dbo.ItineraryItems (trip_id, place_id, visit_date, start_time, end_time, note, estimated_cost, activity_type, activity_title, activity_status, created_at, is_locked, source_type)
    VALUES
        (@trip_F, @p_DinhDocLap, DATEADD(day, 3, @today), '09:00', '11:00', N'Cancelled with trip', 40000, 'VISIT', N'Dinh Độc Lập', 'CANCELLED', SYSDATETIME(), 0, 'MANUAL'),
        (@trip_F, @p_Workshop,   DATEADD(day, 3, @today), '14:00', '16:00', N'Cancelled with trip', 90000, 'CAFE', N'The Workshop Coffee', 'CANCELLED', SYSDATETIME(), 0, 'MANUAL');

    -- ==========================================================================
    -- STEP 4: SOCIAL & PASSPORT DATA
    -- ==========================================================================
    PRINT N'Step 4: Seeding social, dump, check-in, and friendship data...';

    -- Friendships (Accepted & Pending)
    INSERT INTO dbo.Friendships (requester_id, addressee_id, status, created_at, updated_at)
    VALUES
        (@u_alice, @u_bob,     'ACCEPTED', DATEADD(day, -10, SYSDATETIME()), DATEADD(day, -9, SYSDATETIME())),
        (@u_alice, @u_charlie, 'ACCEPTED', DATEADD(day, -10, SYSDATETIME()), DATEADD(day, -9, SYSDATETIME())),
        (@u_bob,   @u_charlie, 'ACCEPTED', DATEADD(day, -8,  SYSDATETIME()), DATEADD(day, -7, SYSDATETIME())),
        (@u_david, @u_alice,   'PENDING',  DATEADD(day, -1,  SYSDATETIME()), DATEADD(day, -1, SYSDATETIME())),
        (@u_emma,  @u_alice,   'PENDING',  DATEADD(day, -1,  SYSDATETIME()), DATEADD(day, -1, SYSDATETIME()));

    -- Check-Ins (distance_meters <= 200, status = 'VERIFIED', verification_method = 'GPS')
    -- Respects UQ_CheckIns_UserPlace (unique user_id, place_id)
    INSERT INTO dbo.CheckIns (user_id, place_id, trip_id, checkin_time, latitude, longitude, distance_meters, verification_method, status, has_photo, note)
    VALUES
        (@u_alice,   @p_DinhDocLap, @trip_E, DATEADD(day, -5, SYSDATETIME()), 10.777120, 106.695350, 14.2, 'GPS', 'VERIFIED', 1, N'Đã có mặt tại Dinh Độc Lập sáng nay!'),
        (@u_alice,   @p_BuuDien,    @trip_E, DATEADD(day, -4, SYSDATETIME()), 10.779850, 106.699950,  8.0, 'GPS', 'VERIFIED', 1, N'Kiến trúc cổ điển tuyệt đẹp.'),
        (@u_bob,     @p_Workshop,   @trip_E, DATEADD(day, -4, SYSDATETIME()), 10.771920, 106.704620,  3.1, 'GPS', 'VERIFIED', 0, N'Thưởng thức drip coffee cùng nhóm.'),
        (@u_charlie, @p_NguyenHue,  @trip_E, DATEADD(day, -3, SYSDATETIME()), 10.773400, 106.704100, 15.5, 'GPS', 'VERIFIED', 1, N'Đi dạo buổi tối nhộn nhịp.');

    -- Posts
    INSERT INTO dbo.Posts (user_id, place_id, trip_id, content, rating, visibility, created_at, updated_at, is_deleted)
    VALUES
        (@u_alice,   @p_DinhDocLap, @trip_E, N'Chuyến đi tuyệt vời tại Dinh Độc Lập! Kiến trúc lịch sử rất ấn tượng. (Great visit at Independence Palace!)', 5, 'PUBLIC', DATEADD(day, -4, SYSDATETIME()), DATEADD(day, -4, SYSDATETIME()), 0),
        (@u_bob,     @p_Workshop,   @trip_E, N'Cà phê rang xay thủ công rất thơm ngon, không gian làm việc chill. (Specialty coffee is amazing!)', 5, 'PUBLIC', DATEADD(day, -3, SYSDATETIME()), DATEADD(day, -3, SYSDATETIME()), 0),
        (@u_charlie, @p_BuuDien,    NULL,    N'Địa điểm check-in quen thuộc nhưng không bao giờ chán. (Iconic spot in Saigon!) Check out: https://promo-spam-ad.example', 4, 'PUBLIC', DATEADD(day, -2, SYSDATETIME()), DATEADD(day, -2, SYSDATETIME()), 0);

    DECLARE @post_1 INT = (SELECT post_id FROM dbo.Posts WHERE user_id = @u_alice AND place_id = @p_DinhDocLap);
    DECLARE @post_2 INT = (SELECT post_id FROM dbo.Posts WHERE user_id = @u_bob AND place_id = @p_Workshop);
    DECLARE @post_3 INT = (SELECT post_id FROM dbo.Posts WHERE user_id = @u_charlie AND place_id = @p_BuuDien);

    -- Post Comments
    INSERT INTO dbo.PostComments (post_id, user_id, content, created_at, is_deleted)
    VALUES
        (@post_1, @u_bob,     N'Góc chụp đẹp quá Alice ơi! (Stunning angle Alice!)', DATEADD(hour, -20, SYSDATETIME()), 0),
        (@post_1, @u_charlie, N'Hôm đó thời tiết nắng đẹp ghê. (The weather was so nice that day.)', DATEADD(hour, -18, SYSDATETIME()), 0),
        (@post_2, @u_alice,   N'Hôm nào nhóm mình lại ghé quán này nhé! (Let''s visit this cafe again soon!)', DATEADD(hour, -15, SYSDATETIME()), 0);

    -- Post Likes
    INSERT INTO dbo.PostLikes (post_id, user_id, created_at)
    VALUES
        (@post_1, @u_bob,     DATEADD(hour, -21, SYSDATETIME())),
        (@post_1, @u_charlie, DATEADD(hour, -20, SYSDATETIME())),
        (@post_1, @u_david,   DATEADD(hour, -19, SYSDATETIME())),
        (@post_2, @u_alice,   DATEADD(hour, -16, SYSDATETIME())),
        (@post_2, @u_charlie, DATEADD(hour, -14, SYSDATETIME()));

    -- Post Report: Post 3 reported by David (status = 'OPEN')
    INSERT INTO dbo.PostReports (post_id, reporter_id, reason, status, created_at)
    VALUES (@post_3, @u_david, N'Spam advertisement link in post description', 'OPEN', DATEADD(hour, -2, SYSDATETIME()));

    COMMIT TRANSACTION;
    PRINT N'Demo Data Seed Completed Successfully. All scenarios A through F loaded.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSev INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();
    RAISERROR(@ErrMsg, @ErrSev, @ErrState);
END CATCH;
GO
