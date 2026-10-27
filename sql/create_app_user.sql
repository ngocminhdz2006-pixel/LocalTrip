/* ==============================================================================
   LocalTrip — Dedicated Application User Provisioning Script
   ==============================================================================
   This script creates a least-privileged SQL Server login and database user
   specifically for the LocalTrip application.

   Security Principles Enforced:
   - Principle of Least Privilege: grants db_datareader, db_datawriter, and EXECUTE.
   - NO sysadmin role.
   - NO db_owner role.
   - Replaces generic/dangerous 'sa' superuser usage in production.

   INSTRUCTIONS:
   1. Replace the placeholder password N'<REPLACE_WITH_STRONG_PASSWORD>' with a
      cryptographically strong, unique secret.
   2. Execute this script in SQL Server Management Studio (SSMS) or via sqlcmd
      as an administrator (e.g., 'sa' or Windows Administrator).
   ============================================================================== */

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'localtrip_app')
BEGIN
    -- NOTE: Change this password before executing in production!
    CREATE LOGIN [localtrip_app]
        WITH PASSWORD = N'<REPLACE_WITH_STRONG_PASSWORD>',
        CHECK_POLICY = ON,
        CHECK_EXPIRATION = OFF;

    PRINT N'Created SQL Server login [localtrip_app].';
END
ELSE
BEGIN
    PRINT N'SQL Server login [localtrip_app] already exists. Skipping login creation.';
END;
GO

USE LocalTripDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'localtrip_app')
BEGIN
    CREATE USER [localtrip_app] FOR LOGIN [localtrip_app];
    PRINT N'Created database user [localtrip_app] in LocalTripDB.';
END
ELSE
BEGIN
    PRINT N'Database user [localtrip_app] already exists in LocalTripDB.';
END;
GO

-- Grant minimum required permissions for application operation
ALTER ROLE [db_datareader] ADD MEMBER [localtrip_app];
ALTER ROLE [db_datawriter] ADD MEMBER [localtrip_app];
GRANT EXECUTE TO [localtrip_app];
GO

PRINT N'Successfully granted db_datareader, db_datawriter, and EXECUTE permissions to [localtrip_app].';
PRINT N'Verified: [localtrip_app] is NOT a member of db_owner or sysadmin.';
GO
