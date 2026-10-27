-- ==============================================================================
-- Upgrade script v5: Scenario Lab Support
-- Adds sim_batch_id nullable columns to Users and Trips for data isolation
-- Expands CK_AdminAuditLogs_Action to allow Scenario Lab actions
-- ==============================================================================

USE LocalTripDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH('dbo.Users', 'sim_batch_id') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD sim_batch_id VARCHAR(50) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Users_sim_batch_id' AND object_id = OBJECT_ID('dbo.Users'))
BEGIN
    CREATE INDEX IX_Users_sim_batch_id ON dbo.Users(sim_batch_id) WHERE sim_batch_id IS NOT NULL;
END
GO

IF COL_LENGTH('dbo.Trips', 'sim_batch_id') IS NULL
BEGIN
    ALTER TABLE dbo.Trips ADD sim_batch_id VARCHAR(50) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Trips_sim_batch_id' AND object_id = OBJECT_ID('dbo.Trips'))
BEGIN
    CREATE INDEX IX_Trips_sim_batch_id ON dbo.Trips(sim_batch_id) WHERE sim_batch_id IS NOT NULL;
END
GO

-- Expand CK_AdminAuditLogs_Action
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_AdminAuditLogs_Action' AND parent_object_id = OBJECT_ID('dbo.AdminAuditLogs'))
BEGIN
    ALTER TABLE dbo.AdminAuditLogs DROP CONSTRAINT CK_AdminAuditLogs_Action;
END
GO

ALTER TABLE dbo.AdminAuditLogs
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
    'DELETE_CATEGORY',
    'SCENARIO_LAB_LOAD',
    'SCENARIO_LAB_TIME',
    'SCENARIO_LAB_CHECKIN',
    'SCENARIO_LAB_EXPENSE',
    'PURGE_SIM_BATCH',
    'PURGE_ALL_SIM'
));
GO
