USE LocalTripDB;
GO
SET XACT_ABORT ON;

/* Add explicit seasonal tags; existing admin insert/update code keeps working via DEFAULT. */
IF COL_LENGTH(N'dbo.Places', N'seasonal_tags') IS NULL
BEGIN
    ALTER TABLE dbo.Places
    ADD seasonal_tags NVARCHAR(100) NOT NULL
        CONSTRAINT DF_Places_SeasonalTags DEFAULT N'ALL';
END;
GO

/* Mark existing real HCMC places with useful seasons. */
UPDATE dbo.Places SET seasonal_tags = N'SPRING,AUTUMN'
WHERE place_name IN (N'Bưu điện Trung tâm Sài Gòn', N'Dinh Độc Lập', N'Nhà thờ Đức Bà Sài Gòn', N'Bảo tàng Mỹ thuật TP.HCM');
UPDATE dbo.Places SET seasonal_tags = N'SUMMER,WINTER'
WHERE place_name IN (N'Bảo tàng Chứng tích Chiến tranh', N'CGV Vincom Đồng Khởi', N'Saigon Skydeck', N'AEON Mall Tân Phú Celadon', N'GIGAMALL Thủ Đức', N'Vạn Hạnh Mall');
UPDATE dbo.Places SET seasonal_tags = N'SPRING,WINTER'
WHERE place_name IN (N'Phố đi bộ Nguyễn Huệ', N'Nguyễn Huệ Walking Street', N'Chợ Bến Thành');
UPDATE dbo.Places SET seasonal_tags = N'SPRING,SUMMER,AUTUMN,WINTER'
WHERE place_name IN (N'The Workshop Coffee', N'Bosgaurus Coffee Roasters', N'43 Factory Coffee Roaster', N'Highlands Coffee Nguyễn Huệ', N'Phúc Long Coffee & Tea Nguyễn Huệ');
GO

/* Add more real HCMC places; safe to run repeatedly without duplicate place names. */
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
    ('SIGHTSEEING', N'Dinh Độc Lập', N'135 Nam Kỳ Khởi Nghĩa, Quận 1, TP.HCM', N'Di tích lịch sử với không gian trong nhà và khuôn viên; nên kiểm tra giờ mở cửa trước khi đi.', 40000, 4.60, '08:00', '16:30', 10.7770, 106.6953, 'INDOOR', N'SPRING,AUTUMN,WINTER'),
    ('SIGHTSEEING', N'Bến Bạch Đằng', N'2 Tôn Đức Thắng, Quận 1, TP.HCM', N'Khu vực ven sông để ngắm cảnh và dạo bộ vào sáng sớm hoặc chiều tối.', 0, 4.40, '05:00', '23:00', 10.7720, 106.7060, 'OUTDOOR', N'AUTUMN,WINTER'),
    ('SIGHTSEEING', N'Bảo tàng Mỹ thuật TP.HCM', N'97A Phó Đức Chính, Quận 1, TP.HCM', N'Không gian nghệ thuật và kiến trúc cổ, phù hợp cho ngày mưa hoặc lịch trình khám phá văn hóa.', 30000, 4.40, '08:00', '17:00', 10.7685, 106.6981, 'INDOOR', N'SUMMER,AUTUMN,WINTER'),
    ('ENTERTAINMENT', N'Suối Tiên', N'120 Xa lộ Hà Nội, TP Thủ Đức, TP.HCM', N'Khu du lịch văn hóa và giải trí; nên kiểm tra lịch hoạt động và thời tiết trước chuyến đi.', 350000, 4.20, '08:00', '17:00', 10.8678, 106.8020, 'OUTDOOR', N'SPRING,WINTER'),
    ('ENTERTAINMENT', N'Đầm Sen', N'3 Hòa Bình, Quận 11, TP.HCM', N'Công viên văn hóa và giải trí với nhiều hoạt động ngoài trời; phù hợp ngày ít mưa.', 250000, 4.20, '08:00', '18:00', 10.7667, 106.6350, 'OUTDOOR', N'SPRING,WINTER'),
    ('ENTERTAINMENT', N'Landmark 81 SkyView', N'720A Điện Biên Phủ, Bình Thạnh, TP.HCM', N'Đài quan sát trong tòa nhà cao tầng để ngắm thành phố; kiểm tra giờ hoạt động trước khi đi.', 300000, 4.30, '09:30', '22:00', 10.7953, 106.7218, 'INDOOR', N'SUMMER,AUTUMN,WINTER'),
    ('SHOPPING', N'Saigon Centre', N'65 Lê Lợi, Quận 1, TP.HCM', N'Trung tâm mua sắm và ăn uống trong nhà, thích hợp tránh nắng hoặc mưa.', 200000, 4.40, '09:30', '21:30', 10.7740, 106.7010, 'INDOOR', N'SUMMER,WINTER'),
    ('CAFE', N'Cafe Apartments Nguyễn Huệ', N'42 Nguyễn Huệ, Quận 1, TP.HCM', N'Tòa nhà có nhiều quán cà phê và cửa hàng nhỏ; phù hợp ngắm phố đi bộ từ trên cao.', 90000, 4.20, '08:00', '22:00', 10.7737, 106.7043, 'INDOOR', N'SPRING,AUTUMN,WINTER'),
    ('FOOD', N'Phở Hòa Pasteur', N'260C Pasteur, Quận 3, TP.HCM', N'Quán phở lâu năm; gợi ý cho combo mùa đông theo chủ đề thưởng thức món nóng.', 100000, 4.20, '06:00', '22:00', 10.7880, 106.6899, 'INDOOR', N'SUMMER,WINTER')
) AS v(category_code, place_name, address, description, estimated_cost, rating, opening_time, closing_time, latitude, longitude, place_type, seasonal_tags)
INNER JOIN dbo.Categories c ON c.category_code = v.category_code
WHERE NOT EXISTS (SELECT 1 FROM dbo.Places p WHERE p.place_name = v.place_name);
GO

/* Verify tags and place counts for seasonal combos. */
SELECT seasonal_tags, COUNT(*) AS total_places
FROM dbo.Places
WHERE is_active = 1
GROUP BY seasonal_tags
ORDER BY seasonal_tags;
GO
SELECT place_id, place_name, address, seasonal_tags
FROM dbo.Places
WHERE is_active = 1 AND seasonal_tags <> N'ALL'
ORDER BY seasonal_tags, place_name;
GO
