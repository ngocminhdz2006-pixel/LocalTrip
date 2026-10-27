USE LocalTripDB;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
       OR OBJECT_ID(N'dbo.Places', N'U') IS NULL
       OR OBJECT_ID(N'dbo.Categories', N'U') IS NULL
    BEGIN
        THROW 50001,
              N'Thiếu bảng Users, Places hoặc Categories. Kiểm tra database trước.',
              1;
    END;

    /* Thông tin chung của combo mẫu. */
    IF OBJECT_ID(N'dbo.ComboTemplates', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ComboTemplates (
            combo_id INT IDENTITY(1,1) NOT NULL
                CONSTRAINT PK_ComboTemplates PRIMARY KEY,

            combo_name NVARCHAR(150) NOT NULL,
            description NVARCHAR(1000) NULL,
            image_url NVARCHAR(500) NULL,

            city_name NVARCHAR(100) NOT NULL,
            district_name NVARCHAR(100) NOT NULL,

            duration_days INT NOT NULL,

            status VARCHAR(20) NOT NULL
                CONSTRAINT DF_ComboTemplates_Status
                DEFAULT 'DRAFT',

            created_by INT NOT NULL,

            created_at DATETIME2 NOT NULL
                CONSTRAINT DF_ComboTemplates_CreatedAt
                DEFAULT SYSDATETIME(),

            updated_at DATETIME2 NOT NULL
                CONSTRAINT DF_ComboTemplates_UpdatedAt
                DEFAULT SYSDATETIME(),

            CONSTRAINT FK_ComboTemplates_Creator
                FOREIGN KEY (created_by)
                REFERENCES dbo.Users(user_id),

            CONSTRAINT CK_ComboTemplates_Duration
                CHECK (duration_days >= 1),

            CONSTRAINT CK_ComboTemplates_Status
                CHECK (status IN (
                    'DRAFT',
                    'ACTIVE',
                    'INACTIVE'
                ))
        );

        CREATE INDEX IX_ComboTemplates_Search
            ON dbo.ComboTemplates (
                status,
                city_name,
                district_name,
                duration_days
            );
    END;

    /* Nhãn sở thích của combo.
       Một combo có thể phù hợp nhiều sở thích. */
    IF OBJECT_ID(N'dbo.ComboTemplateCategories', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ComboTemplateCategories (
            combo_id INT NOT NULL,
            category_id INT NOT NULL,

            CONSTRAINT PK_ComboTemplateCategories
                PRIMARY KEY (combo_id, category_id),

            CONSTRAINT FK_ComboTemplateCategories_Combo
                FOREIGN KEY (combo_id)
                REFERENCES dbo.ComboTemplates(combo_id),

            CONSTRAINT FK_ComboTemplateCategories_Category
                FOREIGN KEY (category_id)
                REFERENCES dbo.Categories(category_id)
        );
    END;

    /* Hoạt động cụ thể trong combo.
       day_number là ngày tương đối: 1, 2, 3...
       Không lưu ngày lịch cụ thể của chuyến tại đây. */
    IF OBJECT_ID(N'dbo.ComboTemplateItems', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ComboTemplateItems (
            combo_item_id INT IDENTITY(1,1) NOT NULL
                CONSTRAINT PK_ComboTemplateItems PRIMARY KEY,

            combo_id INT NOT NULL,
            day_number INT NOT NULL,
            sort_order INT NOT NULL,

            activity_type VARCHAR(20) NOT NULL,

            place_id INT NULL,
            activity_title NVARCHAR(200) NOT NULL,

            start_time TIME(0) NOT NULL,
            end_time TIME(0) NOT NULL,

            estimated_cost_per_person DECIMAL(18,2) NOT NULL
                CONSTRAINT DF_ComboTemplateItems_Cost
                DEFAULT 0,

            note NVARCHAR(500) NULL,

            CONSTRAINT FK_ComboTemplateItems_Combo
                FOREIGN KEY (combo_id)
                REFERENCES dbo.ComboTemplates(combo_id),

            CONSTRAINT FK_ComboTemplateItems_Place
                FOREIGN KEY (place_id)
                REFERENCES dbo.Places(place_id),

            CONSTRAINT UQ_ComboTemplateItems_Order
                UNIQUE (combo_id, day_number, sort_order),

            CONSTRAINT CK_ComboTemplateItems_Day
                CHECK (day_number >= 1),

            CONSTRAINT CK_ComboTemplateItems_Order
                CHECK (sort_order >= 1),

            CONSTRAINT CK_ComboTemplateItems_Time
                CHECK (end_time > start_time),

            CONSTRAINT CK_ComboTemplateItems_Cost
                CHECK (estimated_cost_per_person >= 0),

            CONSTRAINT CK_ComboTemplateItems_Type
                CHECK (activity_type IN (
                    'VISIT',
                    'MEAL',
                    'CAFE',
                    'REST'
                )),

            /* Nghỉ có thể không gắn địa điểm.
               Các hoạt động còn lại phải chọn địa điểm. */
            CONSTRAINT CK_ComboTemplateItems_Place
                CHECK (
                    activity_type = 'REST'
                    OR place_id IS NOT NULL
                )
        );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

/* Kiểm tra các bảng vừa bổ sung. */
SELECT
    t.name AS table_name
FROM sys.tables t
WHERE t.schema_id = SCHEMA_ID(N'dbo')
  AND t.name IN (
      N'ComboTemplates',
      N'ComboTemplateCategories',
      N'ComboTemplateItems'
  )
ORDER BY t.name;
GO