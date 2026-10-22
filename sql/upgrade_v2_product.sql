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

    /* 4. Ensure city_name and district_name in Places are fully populated */
    IF COL_LENGTH(N'dbo.Places', N'city_name') IS NOT NULL
    BEGIN
        UPDATE dbo.Places
        SET city_name = N'TP.HCM'
        WHERE city_name IS NULL
          AND (address LIKE N'%TP.HCM%' OR address LIKE N'%TP. HCM%' OR address LIKE N'%Hồ Chí Minh%');

        UPDATE dbo.Places
        SET district_name =
            CASE
                WHEN address LIKE N'%Quận 1%' THEN N'Quận 1'
                WHEN address LIKE N'%Quận 3%' THEN N'Quận 3'
                WHEN address LIKE N'%Quận 4%' THEN N'Quận 4'
                WHEN address LIKE N'%Quận 5%' THEN N'Quận 5'
                WHEN address LIKE N'%Quận 10%' THEN N'Quận 10'
                WHEN address LIKE N'%Quận 11%' THEN N'Quận 11'
                WHEN address LIKE N'%Phú Nhuận%' THEN N'Phú Nhuận'
                WHEN address LIKE N'%Bình Thạnh%' THEN N'Bình Thạnh'
                WHEN address LIKE N'%Thủ Đức%' THEN N'Thủ Đức'
                WHEN address LIKE N'%Tân Phú%' THEN N'Tân Phú'
                ELSE district_name
            END
        WHERE district_name IS NULL;
    END;

    /* 5. Seed sample UserPreferences if empty */
    IF NOT EXISTS (SELECT 1 FROM dbo.UserPreferences)
    BEGIN
        INSERT INTO dbo.UserPreferences (user_id, category_id)
        SELECT u.user_id, c.category_id
        FROM dbo.Users u
        CROSS JOIN dbo.Categories c
        WHERE (
            (u.email = 'minh@localtrip.vn' AND c.category_code IN ('FOOD', 'CAFE', 'SIGHTSEEING'))
            OR (u.email = 'thanh@localtrip.vn' AND c.category_code IN ('CAFE', 'SIGHTSEEING', 'FOOD'))
            OR (u.email = 'lananh@localtrip.vn' AND c.category_code IN ('FOOD', 'CAFE', 'SHOPPING'))
            OR (u.email = 'hoangnam@localtrip.vn' AND c.category_code IN ('FOOD', 'ENTERTAINMENT', 'SIGHTSEEING'))
        );
    END;

    /* 6. Seed sample Friendships if empty (for Vibe Match % testing) */
    IF OBJECT_ID(N'dbo.Friendships', N'U') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Friendships)
    BEGIN
        DECLARE @uMinh INT = (SELECT user_id FROM dbo.Users WHERE email = 'minh@localtrip.vn');
        DECLARE @uThanh INT = (SELECT user_id FROM dbo.Users WHERE email = 'thanh@localtrip.vn');
        DECLARE @uLanAnh INT = (SELECT user_id FROM dbo.Users WHERE email = 'lananh@localtrip.vn');
        DECLARE @uNam INT = (SELECT user_id FROM dbo.Users WHERE email = 'hoangnam@localtrip.vn');

        IF @uMinh IS NOT NULL AND @uLanAnh IS NOT NULL
            INSERT INTO dbo.Friendships (requester_id, addressee_id, status)
            VALUES (@uLanAnh, @uMinh, 'ACCEPTED');

        IF @uThanh IS NOT NULL AND @uLanAnh IS NOT NULL
            INSERT INTO dbo.Friendships (requester_id, addressee_id, status)
            VALUES (@uLanAnh, @uThanh, 'ACCEPTED');

        IF @uNam IS NOT NULL AND @uLanAnh IS NOT NULL
            INSERT INTO dbo.Friendships (requester_id, addressee_id, status)
            VALUES (@uNam, @uLanAnh, 'PENDING');
    END;

    /* 7. Seed sample Admin Combo Template with Items if empty */
    IF OBJECT_ID(N'dbo.ComboTemplates', N'U') IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.ComboTemplates WHERE combo_name = N'1-Day Iconic Saigon: Cafe & Heritage')
    BEGIN
        DECLARE @adminId INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE role = 'ADMIN');
        IF @adminId IS NULL SET @adminId = (SELECT TOP 1 user_id FROM dbo.Users);

        INSERT INTO dbo.ComboTemplates (
            combo_name, description, image_url, city_name, district_name,
            duration_days, status, created_by
        )
        VALUES (
            N'1-Day Iconic Saigon: Cafe & Heritage',
            N'A curated 1-day exploration around District 1 highlights: morning specialty coffee, historic landmarks, art museum, and signature Vietnamese street food.',
            N'https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=800&q=80',
            N'TP.HCM',
            N'Quận 1',
            1,
            'ACTIVE',
            @adminId
        );

        DECLARE @newComboId INT = SCOPE_IDENTITY();

        INSERT INTO dbo.ComboTemplateCategories (combo_id, category_id)
        SELECT @newComboId, category_id FROM dbo.Categories WHERE category_code IN ('FOOD', 'CAFE', 'SIGHTSEEING');

        DECLARE @pCafe INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Highlands Coffee Nguyễn Huệ%');
        DECLARE @pMuseum INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Bảo tàng Chứng tích Chiến tranh%');
        DECLARE @pLunch INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Hủ Tiếu Thanh Xuân%');
        DECLARE @pArt INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Bảo tàng Mỹ thuật%');
        DECLARE @pDinner INT = (SELECT TOP 1 place_id FROM dbo.Places WHERE place_name LIKE N'%Bún thịt nướng Chị Tuyền%');

        IF @pCafe IS NULL SET @pCafe = (SELECT TOP 1 place_id FROM dbo.Places WHERE category_id = 2);
        IF @pMuseum IS NULL SET @pMuseum = (SELECT TOP 1 place_id FROM dbo.Places WHERE category_id = 3);
        IF @pLunch IS NULL SET @pLunch = (SELECT TOP 1 place_id FROM dbo.Places WHERE category_id = 1);
        IF @pArt IS NULL SET @pArt = (SELECT TOP 1 place_id FROM dbo.Places WHERE category_id = 3);
        IF @pDinner IS NULL SET @pDinner = (SELECT TOP 1 place_id FROM dbo.Places WHERE category_id = 1);

        INSERT INTO dbo.ComboTemplateItems (
            combo_id, day_number, sort_order, activity_type, place_id,
            activity_title, start_time, end_time, estimated_cost_per_person, note
        )
        VALUES
        (@newComboId, 1, 1, 'CAFE', @pCafe, N'Morning Coffee at Nguyen Hue', '08:00', '09:30', 70000, N'Enjoy morning breeze and vibrant street atmosphere.'),
        (@newComboId, 1, 2, 'VISIT', @pMuseum, N'War Remnants History Discovery', '10:00', '11:45', 40000, N'Tour historical exhibits and artifacts.'),
        (@newComboId, 1, 3, 'MEAL', @pLunch, N'Authentic Saigon Lunch', '12:00', '13:30', 70000, N'Traditional savory noodles in downtown alley.'),
        (@newComboId, 1, 4, 'REST', NULL, N'Midday Break & Hotel Chill', '13:45', '15:15', 0, N'Relax and recharge energy out of the noon sun.'),
        (@newComboId, 1, 5, 'VISIT', @pArt, N'Fine Arts Museum Architecture Tour', '15:30', '17:30', 30000, N'Colonial French-era architectural wonder and galleries.'),
        (@newComboId, 1, 6, 'MEAL', @pDinner, N'Local Crispy Spring Rolls & BBQ Pork', '18:00', '20:00', 85000, N'Hearty local dinner with signature Saigon sauces.');

        DECLARE @sampleTrip INT = (SELECT TOP 1 trip_id FROM dbo.Trips);
        DECLARE @sampleReviewer INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE email = 'thanh@localtrip.vn');
        IF @sampleTrip IS NOT NULL AND @sampleReviewer IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ComboReviews WHERE combo_id = @newComboId)
        BEGIN
            INSERT INTO dbo.ComboReviews (combo_id, trip_id, user_id, rating, pace_feedback, budget_match, vibe_tags, comment)
            VALUES (@newComboId, @sampleTrip, @sampleReviewer, 5, 'BALANCED', 1, N'Cafe,Local Bites,Culture,Great Value', N'Incredible route! The pace between museum visits and cafe stops was just right for our group.');
        END;
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
