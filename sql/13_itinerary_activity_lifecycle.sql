USE LocalTripDB;
GO
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID(N'dbo.ItineraryItems', N'U') IS NULL
        THROW 50001, N'Thiếu bảng ItineraryItems.', 1;
    IF COL_LENGTH(N'dbo.ItineraryItems', N'activity_type') IS NULL
        EXEC(N'ALTER TABLE dbo.ItineraryItems ADD activity_type VARCHAR(20) NOT NULL CONSTRAINT DF_ItineraryItems_ActivityType DEFAULT ''VISIT'' WITH VALUES');
    IF COL_LENGTH(N'dbo.ItineraryItems', N'activity_title') IS NULL
        EXEC(N'ALTER TABLE dbo.ItineraryItems ADD activity_title NVARCHAR(200) NULL');
    IF COL_LENGTH(N'dbo.ItineraryItems', N'activity_status') IS NULL
        EXEC(N'ALTER TABLE dbo.ItineraryItems ADD activity_status VARCHAR(20) NOT NULL CONSTRAINT DF_ItineraryItems_ActivityStatus DEFAULT ''UPCOMING'' WITH VALUES');
    IF EXISTS(SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID(N'dbo.ItineraryItems') AND name=N'place_id' AND is_nullable=0)
        EXEC(N'ALTER TABLE dbo.ItineraryItems ALTER COLUMN place_id INT NULL');
    IF OBJECT_ID(N'dbo.CK_ItineraryItems_ActivityType', N'C') IS NULL
        EXEC(N'ALTER TABLE dbo.ItineraryItems WITH CHECK ADD CONSTRAINT CK_ItineraryItems_ActivityType CHECK(activity_type IN (''VISIT'',''MEAL'',''CAFE'',''REST''))');
    IF OBJECT_ID(N'dbo.CK_ItineraryItems_ActivityStatus', N'C') IS NULL
        EXEC(N'ALTER TABLE dbo.ItineraryItems WITH CHECK ADD CONSTRAINT CK_ItineraryItems_ActivityStatus CHECK(activity_status IN (''UPCOMING'',''IN_PROGRESS'',''COMPLETED'',''CANCELLED''))');
    IF OBJECT_ID(N'dbo.CK_ItineraryItems_ActivityPlace', N'C') IS NULL
        EXEC(N'ALTER TABLE dbo.ItineraryItems WITH CHECK ADD CONSTRAINT CK_ItineraryItems_ActivityPlace CHECK(place_id IS NOT NULL OR (activity_type=''REST'' AND NULLIF(LTRIM(RTRIM(activity_title)),N'''') IS NOT NULL))');
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK;
    THROW;
END CATCH;
GO
