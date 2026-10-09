/* LocalTrip - read-only diagnostics for database connection and authentication.
   Safe to run in SSMS: this script does NOT create, drop, alter, or delete anything. */

SELECT name, state_desc, user_access_desc, compatibility_level
FROM sys.databases
WHERE name = N'LocalTripDB';
GO

USE LocalTripDB;
GO

-- Verify the Users columns used by UserDAO.
SELECT c.column_id, c.name AS column_name, TYPE_NAME(c.user_type_id) AS data_type,
       c.max_length, c.is_nullable
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID(N'dbo.Users')
ORDER BY c.column_id;
GO

-- Check valid role values and whether accounts are active (no password hashes shown).
SELECT role, is_active, COUNT(*) AS account_count
FROM dbo.Users
GROUP BY role, is_active
ORDER BY role, is_active;
GO

-- Confirm LoginLogs exists and inspect recent attempts, if the table exists.
IF OBJECT_ID(N'dbo.LoginLogs', N'U') IS NOT NULL
BEGIN
    SELECT TOP (20) login_log_id, email, success, failure_reason, attempted_at
    FROM dbo.LoginLogs
    ORDER BY attempted_at DESC, login_log_id DESC;
END
ELSE
BEGIN
    PRINT 'dbo.LoginLogs does not exist. Login history/rate-limit logging may not be installed.';
END;
GO
