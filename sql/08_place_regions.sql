USE LocalTripDB;
GO

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.Places', N'U') IS NULL
        THROW 50001, 'Khong tim thay bang dbo.Places.', 1;

    IF COL_LENGTH(N'dbo.Places', N'city_name') IS NULL
    BEGIN
        ALTER TABLE dbo.Places
        ADD city_name NVARCHAR(100) NULL;
    END;

    IF COL_LENGTH(N'dbo.Places', N'district_name') IS NULL
    BEGIN
        ALTER TABLE dbo.Places
        ADD district_name NVARCHAR(100) NULL;
    END;

    -- SQL động để sử dụng được các cột vừa thêm trong cùng lần chạy.
    EXEC sys.sp_executesql N'
        UPDATE dbo.Places
        SET city_name = N''TP.HCM''
        WHERE NULLIF(LTRIM(RTRIM(city_name)), N'''') IS NULL
          AND (
              address LIKE N''%TP.HCM%''
              OR address LIKE N''%TP. HCM%''
              OR address LIKE N''%Hồ Chí Minh%''
          );

        UPDATE dbo.Places
        SET district_name =
            CASE
                WHEN address LIKE N''%, Quận 1,%''
                    THEN N''Quận 1''
                WHEN address LIKE N''%, Quận 3,%''
                    THEN N''Quận 3''
                WHEN address LIKE N''%, Bình Thạnh,%''
                    THEN N''Bình Thạnh''
                WHEN address LIKE N''%, TP Thủ Đức,%''
                    THEN N''Thủ Đức''
                WHEN address LIKE N''%, TP. Thủ Đức,%''
                    THEN N''Thủ Đức''
                WHEN address LIKE N''%, Tân Phú,%''
                    THEN N''Tân Phú''
                ELSE district_name
            END
        WHERE city_name = N''TP.HCM''
          AND NULLIF(LTRIM(RTRIM(district_name)), N'''') IS NULL;
    ';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

-- Kiểm tra số lượng địa điểm theo khu vực.
SELECT
    city_name AS ThanhPho,
    district_name AS KhuVuc,
    COUNT(*) AS SoDiaDiem
FROM dbo.Places
GROUP BY city_name, district_name
ORDER BY city_name, district_name;
GO

-- Các địa điểm chưa nhận diện được cần kiểm tra thủ công.
SELECT
    place_id,
    place_name,
    address,
    city_name,
    district_name
FROM dbo.Places
WHERE NULLIF(LTRIM(RTRIM(city_name)), N'') IS NULL
   OR NULLIF(LTRIM(RTRIM(district_name)), N'') IS NULL;
GO
