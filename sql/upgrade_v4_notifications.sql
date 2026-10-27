USE LocalTripDB;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* =====================================================================
       Table: Notifications
       Stores real system and user notifications with unread tracking
       ===================================================================== */
    IF OBJECT_ID(N'dbo.Notifications', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Notifications (
            notification_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            user_id INT NOT NULL,
            actor_user_id INT NULL,
            type VARCHAR(50) NOT NULL,
            trip_id INT NULL,
            ref_id INT NULL,
            message NVARCHAR(300) NOT NULL,
            is_read BIT NOT NULL DEFAULT 0,
            created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

            CONSTRAINT FK_Notifications_User FOREIGN KEY (user_id)
                REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
            CONSTRAINT FK_Notifications_Actor FOREIGN KEY (actor_user_id)
                REFERENCES dbo.Users(user_id),
            CONSTRAINT FK_Notifications_Trip FOREIGN KEY (trip_id)
                REFERENCES dbo.Trips(trip_id) ON DELETE CASCADE
        );

        CREATE INDEX IX_Notifications_UserReadCreated ON dbo.Notifications(user_id, is_read, created_at DESC);
        CREATE INDEX IX_Notifications_TripType ON dbo.Notifications(trip_id, type);
    END;

    COMMIT TRANSACTION;
    PRINT N'LocalTrip Version 4 (Notifications) migration completed successfully!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();

    RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
END CATCH;
GO
