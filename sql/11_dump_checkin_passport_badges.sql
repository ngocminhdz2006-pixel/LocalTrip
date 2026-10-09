/* LocalTrip social Dump, GPS Check-in, Travel Passport and Badges.
   Run once in SQL Server Management Studio while connected to LocalTripDB. */
USE LocalTripDB;
GO

IF OBJECT_ID('dbo.Friendships','U') IS NULL
BEGIN
    CREATE TABLE dbo.Friendships (
        friendship_id INT IDENTITY(1,1) PRIMARY KEY,
        requester_id INT NOT NULL,
        addressee_id INT NOT NULL,
        status VARCHAR(12) NOT NULL CONSTRAINT DF_Friendships_Status DEFAULT 'PENDING',
        created_at DATETIME2 NOT NULL CONSTRAINT DF_Friendships_Created DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL CONSTRAINT DF_Friendships_Updated DEFAULT SYSDATETIME(),
        CONSTRAINT FK_Friendships_Requester FOREIGN KEY (requester_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_Friendships_Addressee FOREIGN KEY (addressee_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT CK_Friendships_NoSelf CHECK (requester_id <> addressee_id),
        CONSTRAINT CK_Friendships_Status CHECK (status IN ('PENDING','ACCEPTED','DECLINED'))
    );
    CREATE INDEX IX_Friendships_AddresseeStatus ON dbo.Friendships(addressee_id, status);
    CREATE INDEX IX_Friendships_RequesterStatus ON dbo.Friendships(requester_id, status);
END;
GO

IF OBJECT_ID('dbo.Posts','U') IS NULL
BEGIN
    CREATE TABLE dbo.Posts (
        post_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        place_id INT NULL,
        trip_id INT NULL,
        content NVARCHAR(2000) NULL,
        rating TINYINT NULL,
        visibility VARCHAR(10) NOT NULL CONSTRAINT DF_Posts_Visibility DEFAULT 'PUBLIC',
        created_at DATETIME2 NOT NULL CONSTRAINT DF_Posts_Created DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL CONSTRAINT DF_Posts_Updated DEFAULT SYSDATETIME(),
        is_deleted BIT NOT NULL CONSTRAINT DF_Posts_Deleted DEFAULT 0,
        CONSTRAINT FK_Posts_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_Posts_Place FOREIGN KEY (place_id) REFERENCES dbo.Places(place_id),
        CONSTRAINT FK_Posts_Trip FOREIGN KEY (trip_id) REFERENCES dbo.Trips(trip_id),
        CONSTRAINT CK_Posts_Rating CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
        CONSTRAINT CK_Posts_Visibility CHECK (visibility IN ('PUBLIC','FRIENDS'))
    );
    CREATE INDEX IX_Posts_Created ON dbo.Posts(is_deleted, created_at DESC);
    CREATE INDEX IX_Posts_User ON dbo.Posts(user_id, created_at DESC);
END;
GO

IF OBJECT_ID('dbo.PostImages','U') IS NULL
BEGIN
    CREATE TABLE dbo.PostImages (
        image_id INT IDENTITY(1,1) PRIMARY KEY,
        post_id INT NOT NULL,
        stored_name NVARCHAR(180) NOT NULL,
        original_name NVARCHAR(255) NULL,
        content_type VARCHAR(50) NOT NULL,
        display_order INT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_PostImages_Post FOREIGN KEY (post_id) REFERENCES dbo.Posts(post_id) ON DELETE CASCADE
    );
    CREATE INDEX IX_PostImages_Post ON dbo.PostImages(post_id, display_order);
END;
GO

IF OBJECT_ID('dbo.PostLikes','U') IS NULL
BEGIN
    CREATE TABLE dbo.PostLikes (
        post_id INT NOT NULL,
        user_id INT NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT PK_PostLikes PRIMARY KEY (post_id,user_id),
        CONSTRAINT FK_PostLikes_Post FOREIGN KEY (post_id) REFERENCES dbo.Posts(post_id) ON DELETE CASCADE,
        CONSTRAINT FK_PostLikes_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
    );
END;
GO

IF OBJECT_ID('dbo.PostComments','U') IS NULL
BEGIN
    CREATE TABLE dbo.PostComments (
        comment_id INT IDENTITY(1,1) PRIMARY KEY,
        post_id INT NOT NULL,
        user_id INT NOT NULL,
        content NVARCHAR(1000) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        is_deleted BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_PostComments_Post FOREIGN KEY (post_id) REFERENCES dbo.Posts(post_id) ON DELETE CASCADE,
        CONSTRAINT FK_PostComments_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT CK_PostComments_Content CHECK (LEN(LTRIM(RTRIM(content))) > 0)
    );
END;
GO

IF OBJECT_ID('dbo.PostBookmarks','U') IS NULL
BEGIN
    CREATE TABLE dbo.PostBookmarks (
        post_id INT NOT NULL,
        user_id INT NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT PK_PostBookmarks PRIMARY KEY (post_id,user_id),
        CONSTRAINT FK_PostBookmarks_Post FOREIGN KEY (post_id) REFERENCES dbo.Posts(post_id) ON DELETE CASCADE,
        CONSTRAINT FK_PostBookmarks_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
    );
END;
GO

IF OBJECT_ID('dbo.PostReports','U') IS NULL
BEGIN
    CREATE TABLE dbo.PostReports (
        report_id INT IDENTITY(1,1) PRIMARY KEY,
        post_id INT NOT NULL,
        reporter_id INT NOT NULL,
        reason NVARCHAR(500) NOT NULL,
        status VARCHAR(12) NOT NULL DEFAULT 'OPEN',
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_PostReports_Post FOREIGN KEY (post_id) REFERENCES dbo.Posts(post_id),
        CONSTRAINT FK_PostReports_User FOREIGN KEY (reporter_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT UQ_PostReports_PostReporter UNIQUE (post_id,reporter_id),
        CONSTRAINT CK_PostReports_Status CHECK (status IN ('OPEN','REVIEWED','DISMISSED'))
    );
END;
GO

IF OBJECT_ID('dbo.CheckIns','U') IS NULL
BEGIN
    CREATE TABLE dbo.CheckIns (
        checkin_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        place_id INT NOT NULL,
        trip_id INT NULL,
        checkin_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        latitude DECIMAL(9,6) NOT NULL,
        longitude DECIMAL(9,6) NOT NULL,
        distance_meters DECIMAL(9,2) NOT NULL,
        verification_method VARCHAR(12) NOT NULL DEFAULT 'GPS',
        status VARCHAR(12) NOT NULL DEFAULT 'VERIFIED',
        has_photo BIT NOT NULL DEFAULT 0,
        note NVARCHAR(500) NULL,
        CONSTRAINT FK_CheckIns_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_CheckIns_Place FOREIGN KEY (place_id) REFERENCES dbo.Places(place_id),
        CONSTRAINT FK_CheckIns_Trip FOREIGN KEY (trip_id) REFERENCES dbo.Trips(trip_id),
        CONSTRAINT UQ_CheckIns_UserPlace UNIQUE (user_id,place_id),
        CONSTRAINT CK_CheckIns_Distance CHECK (distance_meters >= 0),
        CONSTRAINT CK_CheckIns_Method CHECK (verification_method IN ('GPS')),
        CONSTRAINT CK_CheckIns_Status CHECK (status IN ('VERIFIED','REJECTED'))
    );
    CREATE INDEX IX_CheckIns_UserTime ON dbo.CheckIns(user_id, checkin_time DESC);
END;
GO

IF OBJECT_ID('dbo.CheckInImages','U') IS NULL
BEGIN
    CREATE TABLE dbo.CheckInImages (
        checkin_image_id INT IDENTITY(1,1) PRIMARY KEY,
        checkin_id INT NOT NULL,
        stored_name NVARCHAR(180) NOT NULL,
        original_name NVARCHAR(255) NULL,
        content_type VARCHAR(50) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_CheckInImages_CheckIn FOREIGN KEY (checkin_id) REFERENCES dbo.CheckIns(checkin_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID('dbo.TravelPassportSettings','U') IS NULL
BEGIN
    CREATE TABLE dbo.TravelPassportSettings (
        user_id INT NOT NULL PRIMARY KEY,
        visibility VARCHAR(10) NOT NULL DEFAULT 'PRIVATE',
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_TravelPassportSettings_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
        CONSTRAINT CK_TravelPassportSettings_Visibility CHECK (visibility IN ('PRIVATE','PUBLIC'))
    );
END;
GO

IF OBJECT_ID('dbo.TravelBadges','U') IS NULL
BEGIN
    CREATE TABLE dbo.TravelBadges (
        badge_id INT IDENTITY(1,1) PRIMARY KEY,
        badge_code VARCHAR(60) NOT NULL UNIQUE,
        badge_name NVARCHAR(120) NOT NULL,
        description NVARCHAR(500) NOT NULL,
        icon NVARCHAR(20) NOT NULL DEFAULT N'🏅',
        criteria_type VARCHAR(30) NOT NULL,
        threshold INT NOT NULL,
        is_active BIT NOT NULL DEFAULT 1,
        display_order INT NOT NULL DEFAULT 0,
        CONSTRAINT CK_TravelBadges_Threshold CHECK (threshold > 0),
        CONSTRAINT CK_TravelBadges_Criteria CHECK (criteria_type IN ('UNIQUE_PLACES','PHOTO_CHECKINS','CATEGORY_PLACES'))
    );
END;
GO

IF OBJECT_ID('dbo.UserBadges','U') IS NULL
BEGIN
    CREATE TABLE dbo.UserBadges (
        user_id INT NOT NULL,
        badge_id INT NOT NULL,
        earned_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT PK_UserBadges PRIMARY KEY (user_id,badge_id),
        CONSTRAINT FK_UserBadges_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_UserBadges_Badge FOREIGN KEY (badge_id) REFERENCES dbo.TravelBadges(badge_id)
    );
END;
GO

/* Safe seed: do not overwrite administrator-edited badge definitions. */
IF NOT EXISTS (SELECT 1 FROM dbo.TravelBadges WHERE badge_code='FIRST_5')
    INSERT dbo.TravelBadges(badge_code,badge_name,description,icon,criteria_type,threshold,display_order)
    VALUES ('FIRST_5',N'Tân binh khám phá',N'Check-in hợp lệ tại 5 địa điểm khác nhau',N'🧭','UNIQUE_PLACES',5,1);
IF NOT EXISTS (SELECT 1 FROM dbo.TravelBadges WHERE badge_code='PHOTO_5')
    INSERT dbo.TravelBadges(badge_code,badge_name,description,icon,criteria_type,threshold,display_order)
    VALUES ('PHOTO_5',N'Người lưu giữ kỷ niệm',N'Check-in có ảnh tại 5 địa điểm khác nhau',N'📸','PHOTO_CHECKINS',5,2);
IF NOT EXISTS (SELECT 1 FROM dbo.TravelBadges WHERE badge_code='EXPLORE_10')
    INSERT dbo.TravelBadges(badge_code,badge_name,description,icon,criteria_type,threshold,display_order)
    VALUES ('EXPLORE_10',N'Nhà thám hiểm',N'Check-in hợp lệ tại 10 địa điểm khác nhau',N'🌍','UNIQUE_PLACES',10,3);
GO
