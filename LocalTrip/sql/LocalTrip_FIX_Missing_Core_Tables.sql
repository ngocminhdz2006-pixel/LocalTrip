	-- Add missing core tables. Existing tables and rows are preserved.
USE [LocalTripDB];
GO
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
       OR OBJECT_ID(N'dbo.Trips', N'U') IS NULL
       OR OBJECT_ID(N'dbo.Places', N'U') IS NULL
        THROW 50001, 'Required base tables Users, Trips or Places are missing. Check the database.', 1;

    IF OBJECT_ID(N'dbo.ItineraryItems', N'U') IS NULL
    BEGIN
CREATE TABLE dbo.ItineraryItems (
    item_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    trip_id INT NOT NULL,
    place_id INT NOT NULL,
    visit_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    note NVARCHAR(1000) NULL,
    estimated_cost DECIMAL(18,2) NOT NULL CONSTRAINT DF_ItineraryItems_Cost DEFAULT 0,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_ItineraryItems_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ItineraryItems_Trip FOREIGN KEY (trip_id) REFERENCES dbo.Trips(trip_id),
    CONSTRAINT FK_ItineraryItems_Place FOREIGN KEY (place_id) REFERENCES dbo.Places(place_id),
    CONSTRAINT CK_ItineraryItems_Time CHECK (end_time > start_time),
    CONSTRAINT CK_ItineraryItems_Cost CHECK (estimated_cost >= 0)
);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ItineraryItems') AND name = N'IX_ItineraryItems_TripDateTime')
    BEGIN
CREATE INDEX IX_ItineraryItems_TripDateTime ON dbo.ItineraryItems(trip_id, visit_date, start_time, end_time);
    END;

    IF OBJECT_ID(N'dbo.Expenses', N'U') IS NULL
    BEGIN
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
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Expenses') AND name = N'IX_Expenses_TripCreatedAt')
    BEGIN
CREATE INDEX IX_Expenses_TripCreatedAt ON dbo.Expenses(trip_id, created_at DESC, expense_id DESC);
    END;

    IF OBJECT_ID(N'dbo.ExpenseParticipants', N'U') IS NULL
    BEGIN
CREATE TABLE dbo.ExpenseParticipants (
    expense_id INT NOT NULL,
    user_id INT NOT NULL,
    share_amount DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_ExpenseParticipants PRIMARY KEY (expense_id, user_id),
    CONSTRAINT FK_ExpenseParticipants_Expense FOREIGN KEY (expense_id) REFERENCES dbo.Expenses(expense_id) ON DELETE CASCADE,
    CONSTRAINT FK_ExpenseParticipants_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_ExpenseParticipants_Share CHECK (share_amount >= 0)
);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ExpenseParticipants') AND name = N'IX_ExpenseParticipants_User')
    BEGIN
CREATE INDEX IX_ExpenseParticipants_User ON dbo.ExpenseParticipants(user_id, expense_id);
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME IN ('ItineraryItems', 'Expenses', 'ExpenseParticipants', 'GroupFundContributions', 'LoginLogs')
ORDER BY TABLE_NAME;
GO
