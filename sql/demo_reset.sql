-- ==============================================================================
-- LocalTrip — Demo Data Reset Script
-- File: sql/demo_reset.sql
-- Purpose: Remove ONLY demo data without touching real user accounts or trips.
-- Marker: Demo users end with '@demo.localtrip.test'
--
-- SAFETY GUARD:
-- 1. This script is intended for DEVELOPMENT / TESTING environments only.
-- 2. It will NEVER delete any user without '@demo.localtrip.test' in their email.
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

PRINT N'Starting Demo Data Reset...';

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Notifications involving demo users or demo trips
    DELETE FROM dbo.Notifications
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR actor_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR trip_id IN (
           SELECT trip_id FROM dbo.Trips 
           WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       );

    -- 2. Admin Audit Logs involving demo users
    DELETE FROM dbo.AdminAuditLogs
    WHERE actor_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR target_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 3. Social Data: Post Reports
    DELETE FROM dbo.PostReports
    WHERE reporter_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR post_id IN (
           SELECT post_id FROM dbo.Posts 
           WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
              OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
       );

    -- 4. Social Data: Post Likes
    DELETE FROM dbo.PostLikes
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR post_id IN (
           SELECT post_id FROM dbo.Posts 
           WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
              OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
       );

    -- 5. Social Data: Post Comments
    DELETE FROM dbo.PostComments
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR post_id IN (
           SELECT post_id FROM dbo.Posts 
           WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
              OR trip_id IN (SELECT trip_id FROM dbo.Trips WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test'))
       );

    -- 6. Social Data: Post Bookmarks & Images
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

    -- 7. Posts
    DELETE FROM dbo.Posts
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR trip_id IN (
           SELECT trip_id FROM dbo.Trips 
           WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       );

    -- 8. Check-in Images & Check-ins
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

    -- 9. Combo Reviews
    DELETE FROM dbo.ComboReviews
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR trip_id IN (
           SELECT trip_id FROM dbo.Trips 
           WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       );

    -- 10. Badges & Passport Settings
    DELETE FROM dbo.UserBadges
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.TravelPassportSettings
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 11. Expense Participants
    DELETE FROM dbo.ExpenseParticipants
    WHERE expense_id IN (
        SELECT expense_id FROM dbo.Expenses 
        WHERE trip_id IN (
            SELECT trip_id FROM dbo.Trips 
            WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
        )
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 12. Expenses
    DELETE FROM dbo.Expenses
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR payer_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
      OR created_by IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 13. Settlement Payments
    DELETE FROM dbo.SettlementPayments
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR from_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
      OR to_user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 14. Group Fund Contributions
    DELETE FROM dbo.GroupFundContributions
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
      OR created_by IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 15. Itinerary Items
    DELETE FROM dbo.ItineraryItems
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    );

    -- 16. Trip Notes
    DELETE FROM dbo.TripNotes
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 17. Trip Invites
    DELETE FROM dbo.TripInvites
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR created_by IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 18. Trip Member Preferences
    DELETE FROM dbo.TripMemberPreferences
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 19. Trip Members
    DELETE FROM dbo.TripMembers
    WHERE trip_id IN (
        SELECT trip_id FROM dbo.Trips 
        WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
    ) OR user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 20. Trips owned by demo users
    DELETE FROM dbo.Trips
    WHERE owner_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 21. Friendships
    DELETE FROM dbo.Friendships
    WHERE requester_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test')
       OR addressee_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 22. User Preferences
    DELETE FROM dbo.UserPreferences
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 23. Auth Tokens & Logs
    DELETE FROM dbo.RememberMeTokens
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.PasswordResetTokens
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    DELETE FROM dbo.LoginLogs
    WHERE user_id IN (SELECT user_id FROM dbo.Users WHERE email LIKE '%@demo.localtrip.test');

    -- 24. Demo Users
    DELETE FROM dbo.Users
    WHERE email LIKE '%@demo.localtrip.test';

    COMMIT TRANSACTION;
    PRINT N'Demo Data Reset Completed Successfully. All demo data removed.';
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
