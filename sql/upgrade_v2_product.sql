USE LocalTripDB;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* 1. UserPreferences (User's profile travel preferences) */
    IF OBJECT_ID(N'dbo.UserPreferences', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.UserPreferences (
            user_id INT NOT NULL,
            category_id INT NOT NULL,
            created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
            CONSTRAINT PK_UserPreferences PRIMARY KEY (user_id, category_id),
            CONSTRAINT FK_UserPreferences_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
            CONSTRAINT FK_UserPreferences_Category FOREIGN KEY (category_id) REFERENCES dbo.Categories(category_id) ON DELETE CASCADE
        );

        CREATE INDEX IX_UserPreferences_User ON dbo.UserPreferences(user_id);
    END;

    /* 2. Add applied_combo_id to Trips */
    IF COL_LENGTH(N'dbo.Trips', N'applied_combo_id') IS NULL
    BEGIN
        ALTER TABLE dbo.Trips
        ADD applied_combo_id INT NULL;

        IF OBJECT_ID(N'dbo.ComboTemplates', N'U') IS NOT NULL
        BEGIN
            ALTER TABLE dbo.Trips
            ADD CONSTRAINT FK_Trips_AppliedCombo
            FOREIGN KEY (applied_combo_id) REFERENCES dbo.ComboTemplates(combo_id);
        END;
    END;

    /* 3. ComboReviews (Post-trip reviews for admin combo templates) */
    IF OBJECT_ID(N'dbo.ComboReviews', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ComboReviews (
            review_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            combo_id INT NOT NULL,
            trip_id INT NOT NULL,
            user_id INT NOT NULL,
            rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
            pace_feedback NVARCHAR(30) NULL,
            budget_match BIT DEFAULT 1,
            vibe_tags NVARCHAR(200) NULL,
            comment NVARCHAR(1000) NULL,
            created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

            CONSTRAINT UQ_ComboReviews_TripUser UNIQUE (trip_id, user_id),

            CONSTRAINT FK_ComboReviews_Combo
                FOREIGN KEY (combo_id) REFERENCES dbo.ComboTemplates(combo_id),

            CONSTRAINT FK_ComboReviews_Trip
                FOREIGN KEY (trip_id) REFERENCES dbo.Trips(trip_id),

            CONSTRAINT FK_ComboReviews_User
                FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
        );

        CREATE INDEX IX_ComboReviews_Combo ON dbo.ComboReviews(combo_id);
        CREATE INDEX IX_ComboReviews_Trip ON dbo.ComboReviews(trip_id);
    END;

    COMMIT TRANSACTION;
    PRINT N'Migration upgrade_v2_product.sql completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@errMsg, 16, 1);
END CATCH;
GO
