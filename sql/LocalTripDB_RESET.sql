/* =============================================================
   LocalTripDB_RESET.sql
   Rebuilds a clean LocalTripDB schema based on the uploaded Java project.
   WARNING: this script DROPS and recreates LocalTripDB if it exists.
   Back up any data you need before running it.
   Run in SQL Server Management Studio (SSMS) as a login allowed to create DBs.
   ============================================================= */
IF DB_ID(N'LocalTripDB') IS NOT NULL
BEGIN
    ALTER DATABASE LocalTripDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LocalTripDB;
END;
GO

CREATE DATABASE LocalTripDB;
GO

USE LocalTripDB;
GO

/* =========================
   1. USERS
   ========================= */
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Users_Role
        CHECK (role IN ('ADMIN', 'USER'))
);
GO

/* =========================
   2. TRIPS
   ========================= */
CREATE TABLE Trips (
    trip_id INT IDENTITY(1,1) PRIMARY KEY,
    owner_id INT NOT NULL,
    trip_name NVARCHAR(150) NOT NULL,
    destination NVARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(18,2) NOT NULL DEFAULT 0,
    description NVARCHAR(1000) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PLANNING',
    applied_combo_id INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Trips_Owner
        FOREIGN KEY (owner_id) REFERENCES Users(user_id),

    CONSTRAINT CK_Trips_Date
        CHECK (end_date >= start_date),

    CONSTRAINT CK_Trips_Budget
        CHECK (budget >= 0),

    CONSTRAINT CK_Trips_Status
        CHECK (status IN (
            'PLANNING',
            'ONGOING',
            'COMPLETED',
            'CANCELLED'
        ))
);
GO

/* =========================
   3. TRIP MEMBERS
   ========================= */
CREATE TABLE TripMembers (
    trip_id INT NOT NULL,
    user_id INT NOT NULL,
    member_role VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
    joined_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_TripMembers
        PRIMARY KEY (trip_id, user_id),

    CONSTRAINT FK_TripMembers_Trip
        FOREIGN KEY (trip_id) REFERENCES Trips(trip_id),

    CONSTRAINT FK_TripMembers_User
        FOREIGN KEY (user_id) REFERENCES Users(user_id),

    CONSTRAINT CK_TripMembers_Role
        CHECK (member_role IN ('OWNER', 'MEMBER'))
);
GO

/* =========================
   4. CATEGORIES
   ========================= */
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_code VARCHAR(50) NOT NULL UNIQUE,
    category_name NVARCHAR(100) NOT NULL UNIQUE
);
GO

/* =========================
   5. TRIP MEMBER PREFERENCES
   ========================= */
CREATE TABLE TripMemberPreferences (
    trip_id INT NOT NULL,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_TripMemberPreferences
        PRIMARY KEY (trip_id, user_id, category_id),

    CONSTRAINT FK_Preferences_TripMember
        FOREIGN KEY (trip_id, user_id)
        REFERENCES TripMembers(trip_id, user_id),

    CONSTRAINT FK_Preferences_Category
        FOREIGN KEY (category_id)
        REFERENCES Categories(category_id)
);
GO

/* =========================
   6. PLACES
   ========================= */
CREATE TABLE Places (
    place_id INT IDENTITY(1,1) PRIMARY KEY,
    category_id INT NOT NULL,
    place_name NVARCHAR(200) NOT NULL,
    address NVARCHAR(300) NOT NULL,
    description NVARCHAR(1000) NULL,
    estimated_cost DECIMAL(18,2) NOT NULL DEFAULT 0,
    rating DECIMAL(3,2) NOT NULL DEFAULT 0,
    opening_time TIME NULL,
    closing_time TIME NULL,
    latitude DECIMAL(9,6) NULL,
    longitude DECIMAL(9,6) NULL,
    place_type VARCHAR(20) NOT NULL DEFAULT 'INDOOR',
    is_active BIT NOT NULL DEFAULT 1,
    seasonal_tags NVARCHAR(100) NOT NULL DEFAULT N'ALL',
    city_name NVARCHAR(100) NULL,
    district_name NVARCHAR(100) NULL,

    CONSTRAINT FK_Places_Category
        FOREIGN KEY (category_id)
        REFERENCES Categories(category_id),

    CONSTRAINT CK_Places_Cost
        CHECK (estimated_cost >= 0),

    CONSTRAINT CK_Places_Rating
        CHECK (rating >= 0 AND rating <= 5),

    CONSTRAINT CK_Places_Type
        CHECK (place_type IN ('INDOOR', 'OUTDOOR'))
);
GO

/* =========================
   INDEXES
   ========================= */
CREATE INDEX IX_Trips_Owner
ON Trips(owner_id);
GO

CREATE INDEX IX_TripMembers_User
ON TripMembers(user_id);
GO

CREATE INDEX IX_Places_Category
ON Places(category_id);
GO


/* =========================================================
   CORE TABLES MISSING FROM THE ORIGINAL 01_schema.sql
   Added after checking the current Java DAO queries.
   ========================================================= */
CREATE TABLE dbo.ItineraryItems (
    item_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    trip_id INT NOT NULL,
    place_id INT NULL,
    visit_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    note NVARCHAR(1000) NULL,
    estimated_cost DECIMAL(18,2) NOT NULL CONSTRAINT DF_ItineraryItems_Cost DEFAULT 0,
    activity_type VARCHAR(20) NOT NULL CONSTRAINT DF_ItineraryItems_ActivityType DEFAULT 'VISIT',
    activity_title NVARCHAR(200) NULL,
    activity_status VARCHAR(20) NOT NULL CONSTRAINT DF_ItineraryItems_ActivityStatus DEFAULT 'UPCOMING',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_ItineraryItems_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ItineraryItems_Trip FOREIGN KEY (trip_id) REFERENCES dbo.Trips(trip_id),
    CONSTRAINT FK_ItineraryItems_Place FOREIGN KEY (place_id) REFERENCES dbo.Places(place_id),
    CONSTRAINT CK_ItineraryItems_Time CHECK (end_time > start_time),
    CONSTRAINT CK_ItineraryItems_Cost CHECK (estimated_cost >= 0),
    CONSTRAINT CK_ItineraryItems_ActivityType CHECK (activity_type IN ('VISIT','MEAL','CAFE','REST')),
    CONSTRAINT CK_ItineraryItems_ActivityStatus CHECK (activity_status IN ('UPCOMING','IN_PROGRESS','COMPLETED','CANCELLED')),
    CONSTRAINT CK_ItineraryItems_ActivityPlace CHECK (place_id IS NOT NULL OR (activity_type = 'REST' AND NULLIF(LTRIM(RTRIM(activity_title)), N'') IS NOT NULL))
);
GO
CREATE INDEX IX_ItineraryItems_TripDateTime ON dbo.ItineraryItems(trip_id, visit_date, start_time, end_time);
GO

CREATE TABLE dbo.Expenses (
    expense_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    trip_id INT NOT NULL,
    payer_id INT NOT NULL,
    created_by INT NOT NULL,
    description NVARCHAR(500) NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    from_group_fund BIT NOT NULL CONSTRAINT DF_Expenses_FromGroupFund DEFAULT 0,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_Expenses_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Expenses_Trip FOREIGN KEY (trip_id) REFERENCES dbo.Trips(trip_id),
    CONSTRAINT FK_Expenses_Payer FOREIGN KEY (payer_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Expenses_CreatedBy FOREIGN KEY (created_by) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_Expenses_Amount CHECK (amount > 0)
);
GO
CREATE INDEX IX_Expenses_TripCreatedAt ON dbo.Expenses(trip_id, created_at DESC, expense_id DESC);
GO

CREATE TABLE dbo.ExpenseParticipants (
    expense_id INT NOT NULL,
    user_id INT NOT NULL,
    share_amount DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_ExpenseParticipants PRIMARY KEY (expense_id, user_id),
    CONSTRAINT FK_ExpenseParticipants_Expense FOREIGN KEY (expense_id) REFERENCES dbo.Expenses(expense_id) ON DELETE CASCADE,
    CONSTRAINT FK_ExpenseParticipants_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_ExpenseParticipants_Share CHECK (share_amount >= 0)
);
GO
CREATE INDEX IX_ExpenseParticipants_User ON dbo.ExpenseParticipants(user_id, expense_id);
GO

USE LocalTripDB;
GO

/* =========================
   1. SAMPLE USERS
   Mật khẩu kiểm thử: 123456
   Hash theo định dạng PBKDF2
   ========================= */
IF NOT EXISTS (
    SELECT 1 FROM Users
    WHERE email = N'minh@localtrip.vn'
)
BEGIN
    INSERT INTO Users (
        full_name,
        email,
        password_hash,
        role
    )
    VALUES (
        N'Nguyễn Ngọc Minh',
        N'minh@localtrip.vn',
        N'20000:f4793f1d4b13d5693234a8bb2c2c6c79:c5da67d25cec2716b973e6495def155e9c3b1629767357145264b377361478c1',
        'ADMIN'
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM Users
    WHERE email = N'thanh@localtrip.vn'
)
BEGIN
    INSERT INTO Users (
        full_name,
        email,
        password_hash,
        role
    )
    VALUES (
        N'Thanh',
        N'thanh@localtrip.vn',
        N'20000:c5d9099a7c7a0d0fd193b2a299bf31ab:2b7eafb66e624543723032f1daeec0a7ee982cf20b830b1db9ef8b3ce4771318',
        'USER'
    );
END;
GO
/* Các tài khoản người dùng mẫu của LocalTrip.
   Mật khẩu kiểm thử: 123456 */

IF NOT EXISTS (
    SELECT 1 FROM Users
    WHERE email = N'lananh@localtrip.vn'
)
BEGIN
    INSERT INTO Users (
        full_name,
        email,
        password_hash,
        role,
        is_active
    )
    VALUES (
        N'Nguyễn Lan Anh',
        N'lananh@localtrip.vn',
        N'20000:d5e14c10dc9cb41416fd4c3ef2deec09:b9f93bc1d5bc8ebf976dcb1583b788c16c83a256071c2b48fbb9d9ccd6cd42c6',
        'USER',
        1
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM Users
    WHERE email = N'hoangnam@localtrip.vn'
)
BEGIN
    INSERT INTO Users (
        full_name,
        email,
        password_hash,
        role,
        is_active
    )
    VALUES (
        N'Hoàng Nam',
        N'hoangnam@localtrip.vn',
        N'20000:cab055e465dec7f70aa3b753b9fba44c:0e9bf6f4609fe6a253e63f2df3565f8e0ec0f5765234b2ca552a951402e00688',
        'USER',
        1
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM Users
    WHERE email = N'locked@localtrip.vn'
)
BEGIN
    INSERT INTO Users (
        full_name,
        email,
        password_hash,
        role,
        is_active
    )
    VALUES (
        N'Tài khoản kiểm thử đã khóa',
        N'locked@localtrip.vn',
        N'20000:10f0220a4317e460eec564f449d5f283:e278eb7f1fe11641aa0bb5f8eb14aebfb44d86e82ece798e2d91003d9162e441',
        'USER',
        0
    );
END;
GO



/* =========================
   2. CATEGORIES
   ========================= */
IF NOT EXISTS (SELECT 1 FROM Categories)
BEGIN
    INSERT INTO Categories (
        category_code,
        category_name
    )
    VALUES
        ('FOOD',          N'Ăn uống'),
        ('CAFE',          N'Cà phê'),
        ('SIGHTSEEING',   N'Tham quan'),
        ('ENTERTAINMENT', N'Giải trí'),
        ('SHOPPING',      N'Mua sắm');
END;
GO

/* =========================
   3. SAMPLE PLACES
   Khu vực trung tâm TP.HCM
   ========================= */
IF NOT EXISTS (SELECT 1 FROM Places)
BEGIN
    INSERT INTO Places (
        category_id,
        place_name,
        address,
        description,
        estimated_cost,
        rating,
        opening_time,
        closing_time,
        latitude,
        longitude,
        place_type
    )
    SELECT
        c.category_id,
        p.place_name,
        p.address,
        p.description,
        p.estimated_cost,
        p.rating,
        p.opening_time,
        p.closing_time,
        p.latitude,
        p.longitude,
        p.place_type
    FROM (
        VALUES
        (
            'SIGHTSEEING',
            N'Dinh Độc Lập',
            N'135 Nam Kỳ Khởi Nghĩa, Quận 1, TP.HCM',
            N'Địa điểm lịch sử nổi tiếng tại trung tâm thành phố.',
            CAST(40000 AS DECIMAL(18,2)),
            CAST(4.60 AS DECIMAL(3,2)),
            CAST('08:00' AS TIME),
            CAST('16:30' AS TIME),
            CAST(10.777000 AS DECIMAL(9,6)),
            CAST(106.695300 AS DECIMAL(9,6)),
            'INDOOR'
        ),
        (
            'SIGHTSEEING',
            N'Bưu điện Trung tâm Sài Gòn',
            N'2 Công xã Paris, Quận 1, TP.HCM',
            N'Công trình kiến trúc và điểm chụp ảnh nổi tiếng.',
            0, 4.60, '07:00', '19:00',
            10.779800, 106.699900, 'INDOOR'
        ),
        (
            'SIGHTSEEING',
            N'Nhà thờ Đức Bà Sài Gòn',
            N'1 Công xã Paris, Quận 1, TP.HCM',
            N'Công trình kiến trúc biểu tượng tại trung tâm TP.HCM.',
            0, 4.50, '06:00', '20:00',
            10.779700, 106.699000, 'OUTDOOR'
        ),
        (
            'SIGHTSEEING',
            N'Phố đi bộ Nguyễn Huệ',
            N'Nguyễn Huệ, Quận 1, TP.HCM',
            N'Không gian đi bộ và sinh hoạt cộng đồng.',
            0, 4.50, '00:00', '23:59',
            10.773300, 106.704000, 'OUTDOOR'
        ),
        (
            'CAFE',
            N'The Workshop Coffee',
            N'27 Ngô Đức Kế, Quận 1, TP.HCM',
            N'Quán cà phê phù hợp nghỉ ngơi và trò chuyện.',
            90000, 4.40, '08:00', '21:00',
            10.771900, 106.704600, 'INDOOR'
        ),
        (
            'CAFE',
            N'Bosgaurus Coffee Roasters',
            N'92 Nguyễn Hữu Cảnh, Bình Thạnh, TP.HCM',
            N'Không gian cà phê hiện đại với cà phê rang xay.',
            100000, 4.50, '07:00', '21:00',
            10.789000, 106.716000, 'INDOOR'
        ),
        (
            'CAFE',
            N'43 Factory Coffee Roaster',
            N'178A Pasteur, Quận 1, TP.HCM',
            N'Quán cà phê đặc sản trong khu vực trung tâm.',
            110000, 4.50, '07:00', '22:00',
            10.775700, 106.696300, 'INDOOR'
        ),
        (
            'FOOD',
            N'Bánh mì Huỳnh Hoa',
            N'26 Lê Thị Riêng, Quận 1, TP.HCM',
            N'Địa điểm bánh mì nổi tiếng.',
            65000, 4.30, '06:00', '22:00',
            10.771700, 106.691900, 'INDOOR'
        ),
        (
            'FOOD',
            N'Cơm tấm Nguyễn Văn Cừ',
            N'74 Nguyễn Văn Cừ, Quận 1, TP.HCM',
            N'Quán cơm tấm với khẩu phần lớn.',
            120000, 4.20, '06:30', '21:30',
            10.763900, 106.682700, 'INDOOR'
        ),
        (
            'FOOD',
            N'Phở Hòa Pasteur',
            N'260C Pasteur, Quận 3, TP.HCM',
            N'Quán phở lâu năm tại TP.HCM.',
            100000, 4.20, '06:00', '22:00',
            10.788000, 106.689900, 'INDOOR'
        ),
        (
            'ENTERTAINMENT',
            N'Nguyễn Huệ Walking Street',
            N'Nguyễn Huệ, Quận 1, TP.HCM',
            N'Khu vực giải trí ngoài trời vào buổi tối.',
            0, 4.50, '17:00', '23:59',
            10.773300, 106.704000, 'OUTDOOR'
        ),
        (
            'ENTERTAINMENT',
            N'CGV Vincom Đồng Khởi',
            N'72 Lê Thánh Tôn, Quận 1, TP.HCM',
            N'Rạp chiếu phim tại trung tâm thương mại.',
            120000, 4.30, '09:00', '23:00',
            10.778100, 106.701900, 'INDOOR'
        ),
        (
            'ENTERTAINMENT',
            N'Saigon Skydeck',
            N'2 Hải Triều, Quận 1, TP.HCM',
            N'Đài quan sát thành phố từ tòa nhà Bitexco.',
            240000, 4.40, '09:30', '21:30',
            10.771600, 106.704400, 'INDOOR'
        ),
        (
            'SHOPPING',
            N'Chợ Bến Thành',
            N'Lê Lợi, Quận 1, TP.HCM',
            N'Khu chợ truyền thống phục vụ tham quan và mua sắm.',
            150000, 4.10, '06:00', '19:00',
            10.772500, 106.698000, 'INDOOR'
        ),
        (
            'SHOPPING',
            N'Vincom Center Đồng Khởi',
            N'72 Lê Thánh Tôn, Quận 1, TP.HCM',
            N'Trung tâm mua sắm, ăn uống và giải trí.',
            300000, 4.40, '10:00', '22:00',
            10.778100, 106.701900, 'INDOOR'
        )
    ) AS p (
        category_code,
        place_name,
        address,
        description,
        estimated_cost,
        rating,
        opening_time,
        closing_time,
        latitude,
        longitude,
        place_type
    )
    INNER JOIN Categories c
        ON c.category_code = p.category_code;
END;
GO

USE LocalTripDB;
GO

/*
   Authentication recovery migration.
   - RememberMeTokens: long-lived browser tokens (30 days).
   - PasswordResetTokens: single-use reset tokens (30 minutes).
   Raw tokens are NEVER stored; Java stores SHA-256 hashes.
*/

IF OBJECT_ID('dbo.RememberMeTokens', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RememberMeTokens (
        token_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id INT NOT NULL,
        token_hash VARCHAR(64) NOT NULL UNIQUE,
        expires_at DATETIME2 NOT NULL,
        created_at DATETIME2 NOT NULL CONSTRAINT DF_RememberMeTokens_CreatedAt DEFAULT SYSDATETIME(),
        CONSTRAINT FK_RememberMeTokens_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
    );
END;
GO

IF OBJECT_ID('dbo.PasswordResetTokens', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordResetTokens (
        token_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id INT NOT NULL,
        token_hash VARCHAR(64) NOT NULL UNIQUE,
        expires_at DATETIME2 NOT NULL,
        used_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL CONSTRAINT DF_PasswordResetTokens_CreatedAt DEFAULT SYSDATETIME(),
        CONSTRAINT FK_PasswordResetTokens_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
    );
END;
GO

/* Optional cleanup of expired one-time tokens. */
DELETE FROM dbo.PasswordResetTokens
WHERE expires_at <= SYSDATETIME() OR used_at IS NOT NULL;
GO
DELETE FROM dbo.RememberMeTokens
WHERE expires_at <= SYSDATETIME();
GO

USE LocalTripDB;
GO

/*
    Admin Audit Log
    ----------------
    Ghi lại các thao tác quan trọng của ADMIN:

    User:
      CREATE_USER, UPDATE_USER, RESET_PASSWORD

    Place:
      CREATE_PLACE, UPDATE_PLACE, ACTIVATE_PLACE, DEACTIVATE_PLACE

    Category:
      CREATE_CATEGORY, UPDATE_CATEGORY, DELETE_CATEGORY

    Không lưu password/passwordHash vào audit log.
*/

IF OBJECT_ID('AdminAuditLogs', 'U') IS NULL
BEGIN
    CREATE TABLE AdminAuditLogs (
        audit_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        actor_user_id INT NOT NULL,
        action VARCHAR(40) NOT NULL,
        target_user_id INT NULL,
        detail NVARCHAR(500) NULL,
        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_AdminAuditLogs_CreatedAt DEFAULT SYSDATETIME(),
        CONSTRAINT FK_AdminAuditLogs_Actor
            FOREIGN KEY (actor_user_id) REFERENCES Users(user_id),
        CONSTRAINT FK_AdminAuditLogs_Target
            FOREIGN KEY (target_user_id) REFERENCES Users(user_id)
    );
END;
GO

/* Nếu database cũ đã có CHECK constraint thì xóa để cập nhật danh sách action. */
IF EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_AdminAuditLogs_Action'
      AND parent_object_id = OBJECT_ID('AdminAuditLogs')
)
BEGIN
    ALTER TABLE AdminAuditLogs DROP CONSTRAINT CK_AdminAuditLogs_Action;
END;
GO

IF OBJECT_ID('AdminAuditLogs', 'U') IS NOT NULL
BEGIN
    ALTER TABLE AdminAuditLogs
    ADD CONSTRAINT CK_AdminAuditLogs_Action
    CHECK (action IN (
        'CREATE_USER',
        'UPDATE_USER',
        'RESET_PASSWORD',
        'CREATE_PLACE',
        'UPDATE_PLACE',
        'ACTIVATE_PLACE',
        'DEACTIVATE_PLACE',
        'CREATE_CATEGORY',
        'UPDATE_CATEGORY',
        'DELETE_CATEGORY'
    ));
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_AdminAuditLogs_CreatedAt'
      AND object_id = OBJECT_ID('AdminAuditLogs')
)
BEGIN
    CREATE INDEX IX_AdminAuditLogs_CreatedAt
        ON AdminAuditLogs(created_at DESC, audit_id DESC);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_AdminAuditLogs_Actor'
      AND object_id = OBJECT_ID('AdminAuditLogs')
)
BEGIN
    CREATE INDEX IX_AdminAuditLogs_Actor
        ON AdminAuditLogs(actor_user_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_AdminAuditLogs_Action'
      AND object_id = OBJECT_ID('AdminAuditLogs')
)
BEGIN
    CREATE INDEX IX_AdminAuditLogs_Action
        ON AdminAuditLogs(action, created_at DESC);
END;
GO

SELECT TOP 20
    audit_id,
    actor_user_id,
    action,
    target_user_id,
    detail,
    created_at
FROM AdminAuditLogs
ORDER BY created_at DESC, audit_id DESC;
GO

USE LocalTripDB;
GO

/* Quỹ nhóm: chỉ lưu các khoản đóng góp.
   Số dư thực tế = tổng đóng góp - tổng Expenses có from_group_fund = 1.
   Vì số dư được tính động nên Expense thêm/sửa/xóa sẽ tự cập nhật số dư. */

IF OBJECT_ID('dbo.GroupFundContributions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GroupFundContributions (
        contribution_id INT IDENTITY(1,1) PRIMARY KEY,
        trip_id INT NOT NULL,
        user_id INT NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        note NVARCHAR(255) NULL,
        created_by INT NOT NULL,
        created_at DATETIME2 NOT NULL CONSTRAINT DF_GroupFundContributions_CreatedAt DEFAULT SYSDATETIME(),

        CONSTRAINT FK_GroupFundContributions_Trip
            FOREIGN KEY (trip_id) REFERENCES dbo.Trips(trip_id),
        CONSTRAINT FK_GroupFundContributions_User
            FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_GroupFundContributions_CreatedBy
            FOREIGN KEY (created_by) REFERENCES dbo.Users(user_id),
        CONSTRAINT CK_GroupFundContributions_Amount
            CHECK (amount > 0)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_GroupFundContributions_Trip' AND object_id = OBJECT_ID('dbo.GroupFundContributions'))
BEGIN
    CREATE INDEX IX_GroupFundContributions_Trip
        ON dbo.GroupFundContributions(trip_id, created_at DESC);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_GroupFundContributions_User' AND object_id = OBJECT_ID('dbo.GroupFundContributions'))
BEGIN
    CREATE INDEX IX_GroupFundContributions_User
        ON dbo.GroupFundContributions(user_id);
END;
GO

USE LocalTripDB;
GO

/* ============================================================
   LOGIN HISTORY
   - Records every login attempt from LoginServlet.
   - user_id is NULL when the email does not match a user.
   - Failed attempts keep a reason such as INVALID_CREDENTIALS.
   ============================================================ */

IF OBJECT_ID('dbo.LoginLogs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LoginLogs (
        login_log_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id INT NULL,
        email NVARCHAR(150) NOT NULL,
        success BIT NOT NULL,
        failure_reason VARCHAR(50) NULL,
        ip_address VARCHAR(100) NULL,
        user_agent NVARCHAR(500) NULL,
        attempted_at DATETIME2 NOT NULL
            CONSTRAINT DF_LoginLogs_AttemptedAt DEFAULT SYSDATETIME(),

        CONSTRAINT FK_LoginLogs_User
            FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),

        CONSTRAINT CK_LoginLogs_Result
            CHECK (
                (success = 1 AND failure_reason IS NULL)
                OR
                (success = 0 AND failure_reason IS NOT NULL)
            )
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_LoginLogs_AttemptedAt'
      AND object_id = OBJECT_ID('dbo.LoginLogs')
)
BEGIN
    CREATE INDEX IX_LoginLogs_AttemptedAt
    ON dbo.LoginLogs(attempted_at DESC, login_log_id DESC);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_LoginLogs_Email'
      AND object_id = OBJECT_ID('dbo.LoginLogs')
)
BEGIN
    CREATE INDEX IX_LoginLogs_Email
    ON dbo.LoginLogs(email, attempted_at DESC);
END;
GO

USE LocalTripDB;
GO

/* =========================================================
   LOCALTRIP - BỔ SUNG ĐỊA ĐIỂM PHỤC VỤ AUTO ITINERARY
   Mục tiêu: đủ nhiều lựa chọn để mỗi ngày có 3 cột mốc.
   Mỗi cột mốc: FOOD + CAFE + SIGHTSEEING/ENTERTAINMENT/SHOPPING.
   Script an toàn: chạy nhiều lần không tạo bản ghi trùng tên.
   ========================================================= */

INSERT INTO Places (
    category_id, place_name, address, description,
    estimated_cost, rating, opening_time, closing_time,
    latitude, longitude, place_type, is_active
)
SELECT c.category_id, v.place_name, v.address, v.description,
       v.estimated_cost, v.rating, v.opening_time, v.closing_time,
       v.latitude, v.longitude, v.place_type, 1
FROM (
    VALUES
    /* ================= FOOD ================= */
    ('FOOD', N'Bún thịt nướng Chị Tuyền', N'175 Cô Giang, Quận 1, TP.HCM', N'Món bún thịt nướng phù hợp cho bữa sáng hoặc trưa.', 70000, 4.30, '06:30', '21:30', 10.765800, 106.694700, 'INDOOR'),
    ('FOOD', N'Cơm tấm Ba Ghiền', N'84 Đặng Văn Ngữ, Phú Nhuận, TP.HCM', N'Cơm tấm phong cách địa phương.', 90000, 4.40, '07:00', '21:00', 10.793700, 106.674500, 'INDOOR'),
    ('FOOD', N'Hủ Tiếu Thanh Xuân', N'62 Tôn Thất Thiệp, Quận 1, TP.HCM', N'Hủ tiếu truyền thống tại trung tâm thành phố.', 70000, 4.30, '07:00', '21:00', 10.771300, 106.700300, 'INDOOR'),
    ('FOOD', N'Bánh xèo Ngọc Sơn', N'103 Ngô Quyền, Quận 5, TP.HCM', N'Bánh xèo và món ăn miền Nam.', 90000, 4.20, '10:00', '21:30', 10.754500, 106.666700, 'INDOOR'),
    ('FOOD', N'Ốc Oanh', N'534 Vĩnh Khánh, Quận 4, TP.HCM', N'Quán ốc đa dạng món cho nhóm bạn.', 150000, 4.20, '16:00', '23:00', 10.757900, 106.701300, 'INDOOR'),
    ('FOOD', N'Bún bò Huế Đông Ba', N'110A Nguyễn Du, Quận 1, TP.HCM', N'Bún bò Huế đậm vị.', 85000, 4.20, '06:30', '21:30', 10.779300, 106.695800, 'INDOOR'),
    ('FOOD', N'Pizza 4P''s Ben Thanh', N'8 Thủ Khoa Huân, Quận 1, TP.HCM', N'Pizza và món Ý phù hợp nhóm bạn.', 220000, 4.50, '11:00', '23:00', 10.772700, 106.696500, 'INDOOR'),

    /* ================= CAFE ================= */
    ('CAFE', N'Highlands Coffee Nguyễn Huệ', N'26 Nguyễn Huệ, Quận 1, TP.HCM', N'Không gian cà phê trung tâm, thuận tiện nghỉ giữa lịch trình.', 70000, 4.20, '07:00', '22:00', 10.773500, 106.704300, 'INDOOR'),
    ('CAFE', N'Phúc Long Coffee & Tea Nguyễn Huệ', N'42 Nguyễn Huệ, Quận 1, TP.HCM', N'Cà phê và trà tại khu trung tâm.', 70000, 4.20, '07:00', '22:00', 10.773900, 106.704500, 'INDOOR'),
    ('CAFE', N'Cong Caphe Bùi Viện', N'274 Bùi Viện, Quận 1, TP.HCM', N'Không gian cà phê phong cách hoài cổ.', 80000, 4.30, '07:00', '23:00', 10.767500, 106.691000, 'INDOOR'),
    ('CAFE', N'The Running Bean', N'115 Hồ Tùng Mậu, Quận 1, TP.HCM', N'Quán cà phê và brunch tại trung tâm.', 120000, 4.40, '07:30', '21:30', 10.773000, 106.702000, 'INDOOR'),
    ('CAFE', N'Every Half Coffee Roasters', N'8-10 Lê Thánh Tôn, Quận 1, TP.HCM', N'Cà phê rang xay và không gian hiện đại.', 100000, 4.40, '08:00', '21:00', 10.779000, 106.704000, 'INDOOR'),
    ('CAFE', N'Blank Lounge Landmark 81', N'720A Điện Biên Phủ, Bình Thạnh, TP.HCM', N'Không gian cà phê và ngắm cảnh thành phố.', 180000, 4.40, '08:00', '23:00', 10.795300, 106.721800, 'INDOOR'),
    ('CAFE', N'Cafe Cardinal', N'76 Nguyễn Huệ, Quận 1, TP.HCM', N'Không gian cà phê và thư giãn cao cấp.', 180000, 4.30, '07:00', '22:00', 10.774700, 106.704900, 'INDOOR'),

    /* ================= SIGHTSEEING ================= */
    ('SIGHTSEEING', N'Bảo tàng Chứng tích Chiến tranh', N'28 Võ Văn Tần, Quận 3, TP.HCM', N'Bảo tàng lịch sử nổi tiếng của thành phố.', 40000, 4.50, '07:30', '17:30', 10.779400, 106.692000, 'INDOOR'),
    ('SIGHTSEEING', N'Bảo tàng Mỹ thuật TP.HCM', N'97 Phó Đức Chính, Quận 1, TP.HCM', N'Không gian nghệ thuật và kiến trúc cổ.', 30000, 4.40, '08:00', '17:00', 10.768500, 106.698100, 'INDOOR'),

    /* ================= ENTERTAINMENT ================= */
    ('ENTERTAINMENT', N'BHD Star Bitexco', N'2 Hải Triều, Quận 1, TP.HCM', N'Rạp phim tại trung tâm thành phố.', 140000, 4.30, '09:00', '23:00', 10.771700, 106.704000, 'INDOOR'),
    ('ENTERTAINMENT', N'Khu vui chơi Snow Town Sài Gòn', N'125 Đồng Văn Cống, TP Thủ Đức, TP.HCM', N'Khu vui chơi tuyết trong nhà.', 180000, 4.20, '09:00', '21:00', 10.768500, 106.767000, 'INDOOR'),
    ('ENTERTAINMENT', N'Jump Arena Thảo Điền', N'63 Xuân Thủy, TP Thủ Đức, TP.HCM', N'Khu vận động giải trí trong nhà.', 180000, 4.30, '09:00', '21:00', 10.803700, 106.735700, 'INDOOR'),

    /* ================= SHOPPING ================= */
    ('SHOPPING', N'AEON Mall Tân Phú Celadon', N'30 Tân Thắng, Tân Phú, TP.HCM', N'Trung tâm mua sắm, ăn uống và giải trí.', 250000, 4.40, '10:00', '22:00', 10.801800, 106.618300, 'INDOOR'),
    ('SHOPPING', N'GIGAMALL Thủ Đức', N'240-242 Phạm Văn Đồng, TP Thủ Đức, TP.HCM', N'Trung tâm mua sắm và giải trí.', 220000, 4.40, '09:00', '22:00', 10.828500, 106.718900, 'INDOOR'),
    ('SHOPPING', N'Vạn Hạnh Mall', N'11 Sư Vạn Hạnh, Quận 10, TP.HCM', N'Trung tâm mua sắm và vui chơi.', 220000, 4.30, '09:30', '22:00', 10.772200, 106.667300, 'INDOOR'),
    ('SHOPPING', N'Takashimaya Saigon Centre', N'65 Lê Lợi, Quận 1, TP.HCM', N'Trung tâm mua sắm cao cấp tại trung tâm.', 300000, 4.50, '09:30', '21:30', 10.774000, 106.701000, 'INDOOR')
) AS v(category_code, place_name, address, description, estimated_cost, rating, opening_time, closing_time, latitude, longitude, place_type)
INNER JOIN Categories c ON c.category_code = v.category_code
WHERE NOT EXISTS (
    SELECT 1 FROM Places p
    WHERE p.place_name = v.place_name
);
GO

/* Kiểm tra nhanh số lượng theo nhóm */
SELECT c.category_code, c.category_name, COUNT(p.place_id) AS total_places
FROM Categories c
LEFT JOIN Places p ON p.category_id = c.category_id AND p.is_active = 1
GROUP BY c.category_code, c.category_name
ORDER BY c.category_code;
GO

/* =========================================================
   SEASONAL PLACES & COMBO ATTRACTIONS (from 10_seasonal_combos.sql)
   ========================================================= */
UPDATE dbo.Places SET seasonal_tags = N'SPRING,AUTUMN'
WHERE place_name IN (N'Bưu điện Trung tâm Sài Gòn', N'Dinh Độc Lập', N'Nhà thờ Đức Bà Sài Gòn', N'Bảo tàng Mỹ thuật TP.HCM');
UPDATE dbo.Places SET seasonal_tags = N'SUMMER,WINTER'
WHERE place_name IN (N'Bảo tàng Chứng tích Chiến tranh', N'CGV Vincom Đồng Khởi', N'Saigon Skydeck', N'AEON Mall Tân Phú Celadon', N'GIGAMALL Thủ Đức', N'Vạn Hạnh Mall');
UPDATE dbo.Places SET seasonal_tags = N'SPRING,WINTER'
WHERE place_name IN (N'Phố đi bộ Nguyễn Huệ', N'Nguyễn Huệ Walking Street', N'Chợ Bến Thành');
UPDATE dbo.Places SET seasonal_tags = N'SPRING,SUMMER,AUTUMN,WINTER'
WHERE place_name IN (N'The Workshop Coffee', N'Bosgaurus Coffee Roasters', N'43 Factory Coffee Roaster', N'Highlands Coffee Nguyễn Huệ', N'Phúc Long Coffee & Tea Nguyễn Huệ');
GO

INSERT INTO dbo.Places (
    category_id, place_name, address, description, estimated_cost, rating,
    opening_time, closing_time, latitude, longitude, place_type, is_active, seasonal_tags
)
SELECT c.category_id, v.place_name, v.address, v.description, v.estimated_cost, v.rating,
       v.opening_time, v.closing_time, v.latitude, v.longitude, v.place_type, 1, v.seasonal_tags
FROM (VALUES
    ('SIGHTSEEING', N'Công viên Tao Đàn', N'55C Nguyễn Thị Minh Khai, Quận 1, TP.HCM', N'Công viên nhiều cây xanh; phù hợp đi dạo và trải nghiệm không khí du xuân.', 0, 4.40, '05:00', '22:00', 10.7755, 106.6920, 'OUTDOOR', N'SPRING,AUTUMN'),
    ('SIGHTSEEING', N'Đường hoa Nguyễn Huệ', N'Phố đi bộ Nguyễn Huệ, Quận 1, TP.HCM', N'Không gian đường hoa thường được tổ chức dịp Tết; cần kiểm tra lịch tổ chức từng năm.', 0, 4.50, '08:00', '22:00', 10.7733, 106.7040, 'OUTDOOR', N'SPRING'),
    ('SIGHTSEEING', N'Bảo tàng Thành phố Hồ Chí Minh', N'65 Lý Tự Trọng, Quận 1, TP.HCM', N'Bảo tàng trong công trình kiến trúc lịch sử; phù hợp tham quan khi nắng nóng hoặc mưa.', 30000, 4.30, '08:00', '17:00', 10.7769, 106.7009, 'INDOOR', N'SUMMER,AUTUMN'),
    ('SIGHTSEEING', N'Bến Bạch Đằng', N'2 Tôn Đức Thắng, Quận 1, TP.HCM', N'Khu vực ven sông để ngắm cảnh và dạo bộ vào sáng sớm hoặc chiều tối.', 0, 4.40, '05:00', '23:00', 10.7720, 106.7060, 'OUTDOOR', N'AUTUMN,WINTER'),
    ('ENTERTAINMENT', N'Suối Tiên', N'120 Xa lộ Hà Nội, TP Thủ Đức, TP.HCM', N'Khu du lịch văn hóa và giải trí; nên kiểm tra lịch hoạt động và thời tiết trước chuyến đi.', 350000, 4.20, '08:00', '17:00', 10.8678, 106.8020, 'OUTDOOR', N'SPRING,WINTER'),
    ('ENTERTAINMENT', N'Đầm Sen', N'3 Hòa Bình, Quận 11, TP.HCM', N'Công viên văn hóa và giải trí với nhiều hoạt động ngoài trời; phù hợp ngày ít mưa.', 250000, 4.20, '08:00', '18:00', 10.7667, 106.6350, 'OUTDOOR', N'SPRING,WINTER'),
    ('ENTERTAINMENT', N'Landmark 81 SkyView', N'720A Điện Biên Phủ, Bình Thạnh, TP.HCM', N'Đài quan sát trong tòa nhà cao tầng để ngắm thành phố; kiểm tra giờ hoạt động trước khi đi.', 300000, 4.30, '09:30', '22:00', 10.7953, 106.7218, 'INDOOR', N'SUMMER,AUTUMN,WINTER'),
    ('SHOPPING', N'Saigon Centre', N'65 Lê Lợi, Quận 1, TP.HCM', N'Trung tâm mua sắm và ăn uống trong nhà, thích hợp tránh nắng hoặc mưa.', 200000, 4.40, '09:30', '21:30', 10.7740, 106.7010, 'INDOOR', N'SUMMER,WINTER'),
    ('CAFE', N'Cafe Apartments Nguyễn Huệ', N'42 Nguyễn Huệ, Quận 1, TP.HCM', N'Tòa nhà có nhiều quán cà phê và cửa hàng nhỏ; phù hợp ngắm phố đi bộ từ trên cao.', 90000, 4.20, '08:00', '22:00', 10.7737, 106.7043, 'INDOOR', N'SPRING,AUTUMN,WINTER')
) AS v(category_code, place_name, address, description, estimated_cost, rating, opening_time, closing_time, latitude, longitude, place_type, seasonal_tags)
INNER JOIN dbo.Categories c ON c.category_code = v.category_code
WHERE NOT EXISTS (SELECT 1 FROM dbo.Places p WHERE p.place_name = v.place_name);
GO



/* =========================================================
   SAMPLE TRIP FOR LOGIN/ITINERARY TESTING
   Test accounts use the hashes already included in 02_seed_data.sql.
   ========================================================= */
DECLARE @OwnerId INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE email = N'thanh@localtrip.vn');
DECLARE @Member1 INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE email = N'lananh@localtrip.vn');
DECLARE @Member2 INT = (SELECT TOP 1 user_id FROM dbo.Users WHERE email = N'hoangnam@localtrip.vn');
DECLARE @TripId INT;

IF @OwnerId IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM dbo.Trips WHERE owner_id = @OwnerId AND trip_name = N'LocalTrip Demo - TP.HCM'
)
BEGIN
    INSERT INTO dbo.Trips (owner_id, trip_name, destination, start_date, end_date, budget, description, status)
    VALUES (@OwnerId, N'LocalTrip Demo - TP.HCM', N'TP. Hồ Chí Minh',
            DATEADD(DAY, 7, CAST(GETDATE() AS DATE)),
            DATEADD(DAY, 9, CAST(GETDATE() AS DATE)),
            5000000, N'Chuyến đi mẫu để kiểm tra Trip, thành viên, lịch trình và quỹ nhóm.', 'PLANNING');
END;
SELECT TOP 1 @TripId = trip_id FROM dbo.Trips
WHERE owner_id = @OwnerId AND trip_name = N'LocalTrip Demo - TP.HCM'
ORDER BY trip_id DESC;

IF @TripId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TripMembers WHERE trip_id = @TripId AND user_id = @OwnerId)
    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role) VALUES (@TripId, @OwnerId, 'OWNER');
IF @TripId IS NOT NULL AND @Member1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TripMembers WHERE trip_id = @TripId AND user_id = @Member1)
    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role) VALUES (@TripId, @Member1, 'MEMBER');
IF @TripId IS NOT NULL AND @Member2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TripMembers WHERE trip_id = @TripId AND user_id = @Member2)
    INSERT INTO dbo.TripMembers (trip_id, user_id, member_role) VALUES (@TripId, @Member2, 'MEMBER');

/* Set sample preferences for all demo participants so recommendation scoring has data. */
IF @TripId IS NOT NULL
BEGIN
    INSERT INTO dbo.TripMemberPreferences (trip_id, user_id, category_id)
    SELECT @TripId, tm.user_id, c.category_id
    FROM dbo.TripMembers tm
    CROSS JOIN dbo.Categories c
    WHERE tm.trip_id = @TripId
      AND NOT EXISTS (
          SELECT 1 FROM dbo.TripMemberPreferences p
          WHERE p.trip_id = @TripId AND p.user_id = tm.user_id AND p.category_id = c.category_id
      );
END;
GO


/* =========================================================
   7. SOCIAL DUMP, FRIENDSHIPS, CHECK-INS, PASSPORT & BADGES
   ========================================================= */
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

/* =========================================================
   8. ADMIN COMBO TEMPLATES
   ========================================================= */
IF OBJECT_ID(N'dbo.ComboTemplates', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ComboTemplates (
        combo_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ComboTemplates PRIMARY KEY,
        combo_name NVARCHAR(150) NOT NULL,
        description NVARCHAR(1000) NULL,
        image_url NVARCHAR(500) NULL,
        city_name NVARCHAR(100) NOT NULL,
        district_name NVARCHAR(100) NOT NULL,
        duration_days INT NOT NULL,
        status VARCHAR(20) NOT NULL CONSTRAINT DF_ComboTemplates_Status DEFAULT 'DRAFT',
        created_by INT NOT NULL,
        created_at DATETIME2 NOT NULL CONSTRAINT DF_ComboTemplates_CreatedAt DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL CONSTRAINT DF_ComboTemplates_UpdatedAt DEFAULT SYSDATETIME(),
        CONSTRAINT FK_ComboTemplates_Creator FOREIGN KEY (created_by) REFERENCES dbo.Users(user_id),
        CONSTRAINT CK_ComboTemplates_Duration CHECK (duration_days >= 1),
        CONSTRAINT CK_ComboTemplates_Status CHECK (status IN ('DRAFT','ACTIVE','INACTIVE'))
    );
    CREATE INDEX IX_ComboTemplates_Search ON dbo.ComboTemplates (status, city_name, district_name, duration_days);
END;
GO

IF OBJECT_ID(N'dbo.ComboTemplateCategories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ComboTemplateCategories (
        combo_id INT NOT NULL,
        category_id INT NOT NULL,
        CONSTRAINT PK_ComboTemplateCategories PRIMARY KEY (combo_id, category_id),
        CONSTRAINT FK_ComboTemplateCategories_Combo FOREIGN KEY (combo_id) REFERENCES dbo.ComboTemplates(combo_id) ON DELETE CASCADE,
        CONSTRAINT FK_ComboTemplateCategories_Category FOREIGN KEY (category_id) REFERENCES dbo.Categories(category_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID(N'dbo.ComboTemplateItems', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ComboTemplateItems (
        combo_item_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ComboTemplateItems PRIMARY KEY,
        combo_id INT NOT NULL,
        day_number INT NOT NULL,
        sort_order INT NOT NULL,
        activity_type VARCHAR(20) NOT NULL,
        place_id INT NULL,
        activity_title NVARCHAR(200) NOT NULL,
        start_time TIME(0) NOT NULL,
        end_time TIME(0) NOT NULL,
        estimated_cost_per_person DECIMAL(18,2) NOT NULL CONSTRAINT DF_ComboTemplateItems_Cost DEFAULT 0,
        note NVARCHAR(500) NULL,
        CONSTRAINT FK_ComboTemplateItems_Combo FOREIGN KEY (combo_id) REFERENCES dbo.ComboTemplates(combo_id) ON DELETE CASCADE,
        CONSTRAINT FK_ComboTemplateItems_Place FOREIGN KEY (place_id) REFERENCES dbo.Places(place_id),
        CONSTRAINT UQ_ComboTemplateItems_Order UNIQUE (combo_id, day_number, sort_order),
        CONSTRAINT CK_ComboTemplateItems_Day CHECK (day_number >= 1),
        CONSTRAINT CK_ComboTemplateItems_Order CHECK (sort_order >= 1),
        CONSTRAINT CK_ComboTemplateItems_Time CHECK (end_time > start_time),
        CONSTRAINT CK_ComboTemplateItems_Cost CHECK (estimated_cost_per_person >= 0),
        CONSTRAINT CK_ComboTemplateItems_Type CHECK (activity_type IN ('VISIT','MEAL','CAFE','REST')),
        CONSTRAINT CK_ComboTemplateItems_Place CHECK (activity_type = 'REST' OR place_id IS NOT NULL)
    );
END;
GO

IF OBJECT_ID(N'dbo.FK_Trips_AppliedCombo', N'F') IS NULL
   AND OBJECT_ID(N'dbo.Trips', N'U') IS NOT NULL
   AND OBJECT_ID(N'dbo.ComboTemplates', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Trips
    ADD CONSTRAINT FK_Trips_AppliedCombo
    FOREIGN KEY (applied_combo_id) REFERENCES dbo.ComboTemplates(combo_id);
END;
GO

/* =========================================================
   9. PRODUCT V2: USER PREFERENCES & COMBO REVIEWS
   ========================================================= */
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
GO

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
        CONSTRAINT FK_ComboReviews_Combo FOREIGN KEY (combo_id) REFERENCES dbo.ComboTemplates(combo_id),
        CONSTRAINT FK_ComboReviews_Trip FOREIGN KEY (trip_id) REFERENCES dbo.Trips(trip_id),
        CONSTRAINT FK_ComboReviews_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
    );
    CREATE INDEX IX_ComboReviews_Combo ON dbo.ComboReviews(combo_id);
    CREATE INDEX IX_ComboReviews_Trip ON dbo.ComboReviews(trip_id);
END;
GO

/* =========================================================
   10. NORMALIZE PLACES (City & District Recognition)
   ========================================================= */
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
GO

/* =========================================================
   11. SEED DATA FOR BADGES, PREFERENCES, SOCIAL & COMBOS
   ========================================================= */
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
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Friendships)
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
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ComboTemplates WHERE combo_name = N'1-Day Iconic Saigon: Cafe & Heritage')
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
GO

/* =========================================================
   FINAL VERIFICATION SUMMARY (31 System Tables)
   ========================================================= */
SELECT 'Users' AS table_name, COUNT(*) AS row_count FROM dbo.Users
UNION ALL SELECT 'Trips', COUNT(*) FROM dbo.Trips
UNION ALL SELECT 'TripMembers', COUNT(*) FROM dbo.TripMembers
UNION ALL SELECT 'Categories', COUNT(*) FROM dbo.Categories
UNION ALL SELECT 'Places', COUNT(*) FROM dbo.Places
UNION ALL SELECT 'ItineraryItems', COUNT(*) FROM dbo.ItineraryItems
UNION ALL SELECT 'Expenses', COUNT(*) FROM dbo.Expenses
UNION ALL SELECT 'ExpenseParticipants', COUNT(*) FROM dbo.ExpenseParticipants
UNION ALL SELECT 'GroupFundContributions', COUNT(*) FROM dbo.GroupFundContributions
UNION ALL SELECT 'LoginLogs', COUNT(*) FROM dbo.LoginLogs
UNION ALL SELECT 'AdminAuditLogs', COUNT(*) FROM dbo.AdminAuditLogs
UNION ALL SELECT 'RememberMeTokens', COUNT(*) FROM dbo.RememberMeTokens
UNION ALL SELECT 'PasswordResetTokens', COUNT(*) FROM dbo.PasswordResetTokens
UNION ALL SELECT 'Friendships', COUNT(*) FROM dbo.Friendships
UNION ALL SELECT 'Posts', COUNT(*) FROM dbo.Posts
UNION ALL SELECT 'PostImages', COUNT(*) FROM dbo.PostImages
UNION ALL SELECT 'PostLikes', COUNT(*) FROM dbo.PostLikes
UNION ALL SELECT 'PostComments', COUNT(*) FROM dbo.PostComments
UNION ALL SELECT 'PostBookmarks', COUNT(*) FROM dbo.PostBookmarks
UNION ALL SELECT 'PostReports', COUNT(*) FROM dbo.PostReports
UNION ALL SELECT 'CheckIns', COUNT(*) FROM dbo.CheckIns
UNION ALL SELECT 'CheckInImages', COUNT(*) FROM dbo.CheckInImages
UNION ALL SELECT 'TravelPassportSettings', COUNT(*) FROM dbo.TravelPassportSettings
UNION ALL SELECT 'TravelBadges', COUNT(*) FROM dbo.TravelBadges
UNION ALL SELECT 'UserBadges', COUNT(*) FROM dbo.UserBadges
UNION ALL SELECT 'ComboTemplates', COUNT(*) FROM dbo.ComboTemplates
UNION ALL SELECT 'ComboTemplateCategories', COUNT(*) FROM dbo.ComboTemplateCategories
UNION ALL SELECT 'ComboTemplateItems', COUNT(*) FROM dbo.ComboTemplateItems
UNION ALL SELECT 'UserPreferences', COUNT(*) FROM dbo.UserPreferences
UNION ALL SELECT 'ComboReviews', COUNT(*) FROM dbo.ComboReviews;
GO


/* =========================================================
   VERSION 3 FULL PRODUCTION UPGRADES
   ========================================================= */
IF OBJECT_ID(N'dbo.TripInvites', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TripInvites (
        invite_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        trip_id INT NOT NULL CONSTRAINT FK_TripInvites_Trip REFERENCES dbo.Trips(trip_id) ON DELETE CASCADE,
        invite_token VARCHAR(64) NOT NULL UNIQUE,
        created_by INT NOT NULL CONSTRAINT FK_TripInvites_User REFERENCES dbo.Users(user_id),
        expires_at DATETIME2 NOT NULL,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
    CREATE INDEX IX_TripInvites_Token ON dbo.TripInvites(invite_token);
    CREATE INDEX IX_TripInvites_Trip ON dbo.TripInvites(trip_id);
END;
GO

IF OBJECT_ID(N'dbo.TripNotes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TripNotes (
        note_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        trip_id INT NOT NULL CONSTRAINT FK_TripNotes_Trip REFERENCES dbo.Trips(trip_id) ON DELETE CASCADE,
        user_id INT NOT NULL CONSTRAINT FK_TripNotes_User REFERENCES dbo.Users(user_id),
        note_text NVARCHAR(1000) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
    CREATE INDEX IX_TripNotes_Trip ON dbo.TripNotes(trip_id);
END;
GO

IF OBJECT_ID(N'dbo.SettlementPayments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SettlementPayments (
        payment_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        trip_id INT NOT NULL CONSTRAINT FK_SettlementPayments_Trip REFERENCES dbo.Trips(trip_id) ON DELETE CASCADE,
        from_user_id INT NOT NULL CONSTRAINT FK_SettlementPayments_FromUser REFERENCES dbo.Users(user_id),
        to_user_id INT NOT NULL CONSTRAINT FK_SettlementPayments_ToUser REFERENCES dbo.Users(user_id),
        amount DECIMAL(18,2) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
    CREATE INDEX IX_SettlementPayments_Trip ON dbo.SettlementPayments(trip_id);
END;
GO

IF COL_LENGTH(N'dbo.ItineraryItems', N'is_locked') IS NULL
BEGIN
    ALTER TABLE dbo.ItineraryItems ADD is_locked BIT NOT NULL DEFAULT 0;
END;
GO

IF COL_LENGTH(N'dbo.ItineraryItems', N'source_type') IS NULL
BEGIN
    ALTER TABLE dbo.ItineraryItems ADD source_type VARCHAR(20) NOT NULL DEFAULT 'MANUAL';
END;
GO
