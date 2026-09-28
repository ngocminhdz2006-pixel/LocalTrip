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
        password_hash
    )
    VALUES (
        N'Nguyễn Ngọc Minh',
        N'minh@localtrip.vn',
        N'20000:f4793f1d4b13d5693234a8bb2c2c6c79:c5da67d25cec2716b973e6495def155e9c3b1629767357145264b377361478c1'
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
        password_hash
    )
    VALUES (
        N'Thanh',
        N'thanh@localtrip.vn',
        N'20000:c5d9099a7c7a0d0fd193b2a299bf31ab:2b7eafb66e624543723032f1daeec0a7ee982cf20b830b1db9ef8b3ce4771318'
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
