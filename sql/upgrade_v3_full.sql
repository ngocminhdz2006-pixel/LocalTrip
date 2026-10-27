USE LocalTripDB;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* =====================================================================
       1. Table: TripInvites
       Supports token-based trip invites via link / QR / NFC
       ===================================================================== */
    IF OBJECT_ID(N'dbo.TripInvites', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.TripInvites (
            invite_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            trip_id INT NOT NULL,
            invite_token VARCHAR(64) NOT NULL UNIQUE,
            created_by INT NOT NULL,
            expires_at DATETIME2 NOT NULL,
            is_active BIT NOT NULL DEFAULT 1,
            created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

            CONSTRAINT FK_TripInvites_Trip FOREIGN KEY (trip_id)
                REFERENCES dbo.Trips(trip_id) ON DELETE CASCADE,
            CONSTRAINT FK_TripInvites_User FOREIGN KEY (created_by)
                REFERENCES dbo.Users(user_id)
        );

        CREATE INDEX IX_TripInvites_Token ON dbo.TripInvites(invite_token);
        CREATE INDEX IX_TripInvites_Trip ON dbo.TripInvites(trip_id);
    END;

    /* =====================================================================
       2. Table: TripNotes
       Supports group discussion and quick activity notes directly inside trips
       ===================================================================== */
    IF OBJECT_ID(N'dbo.TripNotes', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.TripNotes (
            note_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            trip_id INT NOT NULL,
            user_id INT NOT NULL,
            note_text NVARCHAR(1000) NOT NULL,
            created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

            CONSTRAINT FK_TripNotes_Trip FOREIGN KEY (trip_id)
                REFERENCES dbo.Trips(trip_id) ON DELETE CASCADE,
            CONSTRAINT FK_TripNotes_User FOREIGN KEY (user_id)
                REFERENCES dbo.Users(user_id)
        );

        CREATE INDEX IX_TripNotes_Trip ON dbo.TripNotes(trip_id);
    END;

    /* =====================================================================
       3. Table: SettlementPayments
       Tracks two-way payment status: PENDING -> SENT (I Have Paid) -> CONFIRMED
       ===================================================================== */
    IF OBJECT_ID(N'dbo.SettlementPayments', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.SettlementPayments (
            payment_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            trip_id INT NOT NULL,
            from_user_id INT NOT NULL,
            to_user_id INT NOT NULL,
            amount DECIMAL(18,2) NOT NULL,
            status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, SENT, CONFIRMED
            updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
            created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

            CONSTRAINT FK_SettlementPayments_Trip FOREIGN KEY (trip_id)
                REFERENCES dbo.Trips(trip_id) ON DELETE CASCADE,
            CONSTRAINT FK_SettlementPayments_FromUser FOREIGN KEY (from_user_id)
                REFERENCES dbo.Users(user_id),
            CONSTRAINT FK_SettlementPayments_ToUser FOREIGN KEY (to_user_id)
                REFERENCES dbo.Users(user_id)
        );

        CREATE INDEX IX_SettlementPayments_Trip ON dbo.SettlementPayments(trip_id);
        CREATE INDEX IX_SettlementPayments_Users ON dbo.SettlementPayments(from_user_id, to_user_id);
    END;

    /* =====================================================================
       4. Columns in ItineraryItems: is_locked and source_type
       Protects pinned items during AI auto-scheduling and tags origin
       ===================================================================== */
    IF COL_LENGTH(N'dbo.ItineraryItems', N'is_locked') IS NULL
    BEGIN
        ALTER TABLE dbo.ItineraryItems
        ADD is_locked BIT NOT NULL DEFAULT 0;
    END;

    IF COL_LENGTH(N'dbo.ItineraryItems', N'source_type') IS NULL
    BEGIN
        ALTER TABLE dbo.ItineraryItems
        ADD source_type VARCHAR(20) NOT NULL DEFAULT 'MANUAL'; -- MANUAL, COMBO, AI
    END;

    /* =====================================================================
       5. English Normalization for Categories & TravelBadges Seeds
       ===================================================================== */
    IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL
    BEGIN
        UPDATE dbo.Categories SET category_name = 'Cafe & Coffee' WHERE category_name LIKE N'%Cà phê%' OR category_name LIKE N'%Cafe%';
        UPDATE dbo.Categories SET category_name = 'Local Food & Dining' WHERE category_name LIKE N'%Ẩm thực%' OR category_name LIKE N'%Ăn uống%';
        UPDATE dbo.Categories SET category_name = 'Culture & Heritage' WHERE category_name LIKE N'%Văn hóa%' OR category_name LIKE N'%Di tích%';
        UPDATE dbo.Categories SET category_name = 'Nature & Parks' WHERE category_name LIKE N'%Thiên nhiên%' OR category_name LIKE N'%Công viên%';
        UPDATE dbo.Categories SET category_name = 'Shopping & Markets' WHERE category_name LIKE N'%Mua sắm%' OR category_name LIKE N'%Chợ%';
        UPDATE dbo.Categories SET category_name = 'Entertainment & Nightlife' WHERE category_name LIKE N'%Giải trí%' OR category_name LIKE N'%Vui chơi%';
    END;

    IF OBJECT_ID(N'dbo.TravelBadges', N'U') IS NOT NULL
    BEGIN
        UPDATE dbo.TravelBadges SET badge_name = 'Saigon Explorer', description = 'Check in at 3 different locations across Saigon' WHERE badge_name LIKE N'%Khám phá%';
        UPDATE dbo.TravelBadges SET badge_name = 'Coffee Aficionado', description = 'Check in at 3 specialty cafes in Ho Chi Minh City' WHERE badge_name LIKE N'%Cà phê%';
        UPDATE dbo.TravelBadges SET badge_name = 'Heritage Seeker', description = 'Visit 3 cultural or historical landmarks' WHERE badge_name LIKE N'%Di tích%';
        UPDATE dbo.TravelBadges SET badge_name = 'Street Food Gourmet', description = 'Check in at 3 popular local food dining spots' WHERE badge_name LIKE N'%Ẩm thực%';
    END;

    COMMIT TRANSACTION;
    PRINT N'LocalTrip Version 3 Migration completed successfully!';
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
