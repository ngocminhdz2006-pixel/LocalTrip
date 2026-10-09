/*
    LocalTrip - Quỹ nhóm / Settlement diagnostics
    CHỈ ĐỌC DỮ LIỆU. Không INSERT/UPDATE/DELETE, không reset database.
    Chọn đúng database LocalTripDB trước khi chạy.
*/
USE LocalTripDB;
GO

-- 1) Trạng thái database và chế độ truy cập.
SELECT name, state_desc, user_access_desc
FROM sys.databases
WHERE name = N'LocalTripDB';
GO

-- 2) Kiểm tra các bảng nền tảng cần cho quỹ và Settlement.
SELECT s.name AS schema_name, t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.name IN (N'Trips', N'TripMembers', N'Users', N'Expenses',
                 N'ExpenseParticipants', N'GroupFundContributions')
ORDER BY t.name;
GO

-- 3) Tổng quỹ theo Trip: tổng đóng góp, tổng chi từ quỹ và số dư.
SELECT t.trip_id, t.name AS trip_name,
       COALESCE(c.total_contributed, 0) AS total_contributed,
       COALESCE(e.total_spent, 0) AS total_spent,
       COALESCE(c.total_contributed, 0) - COALESCE(e.total_spent, 0) AS actual_balance
FROM dbo.Trips t
OUTER APPLY (
    SELECT SUM(gfc.amount) AS total_contributed
    FROM dbo.GroupFundContributions gfc
    WHERE gfc.trip_id = t.trip_id
) c
OUTER APPLY (
    SELECT SUM(ex.amount) AS total_spent
    FROM dbo.Expenses ex
    WHERE ex.trip_id = t.trip_id AND ex.from_group_fund = 1
) e
ORDER BY t.trip_id;
GO

-- 4) Kiểm tra khoản chi từ quỹ: chỉ những Expense from_group_fund = 1
-- mới được trừ vào số dư quỹ.
SELECT e.trip_id, e.expense_id, e.description, e.amount,
       e.from_group_fund, e.payer_id, u.full_name AS payer_name, e.created_at
FROM dbo.Expenses e
LEFT JOIN dbo.Users u ON u.user_id = e.payer_id
WHERE e.from_group_fund = 1
ORDER BY e.trip_id, e.created_at DESC;
GO

-- 5) Kiểm tra chủ Trip có mặt trong TripMembers hay không.
-- SettlementDAO đã được gia cố để vẫn đưa owner vào kết quả nếu thiếu dòng này.
SELECT t.trip_id, t.name AS trip_name, t.owner_id, u.full_name AS owner_name,
       CASE WHEN tm.user_id IS NULL THEN N'MISSING TripMembers row'
            ELSE N'OK' END AS owner_membership_status
FROM dbo.Trips t
JOIN dbo.Users u ON u.user_id = t.owner_id
LEFT JOIN dbo.TripMembers tm
       ON tm.trip_id = t.trip_id AND tm.user_id = t.owner_id
ORDER BY t.trip_id;
GO

-- 6) Kiểm tra phân bổ chi phí: tổng phần chia so với số tiền khoản chi cá nhân.
-- Các dòng sai lệch cần được kiểm tra; chi từ quỹ không nằm trong Settlement cá nhân.
SELECT e.trip_id, e.expense_id, e.description, e.amount,
       COALESCE(SUM(ep.share_amount), 0) AS total_shares,
       COALESCE(SUM(ep.share_amount), 0) - e.amount AS difference
FROM dbo.Expenses e
LEFT JOIN dbo.ExpenseParticipants ep ON ep.expense_id = e.expense_id
WHERE e.from_group_fund = 0
GROUP BY e.trip_id, e.expense_id, e.description, e.amount
HAVING ABS(COALESCE(SUM(ep.share_amount), 0) - e.amount) > 0.01
ORDER BY e.trip_id, e.expense_id;
GO
