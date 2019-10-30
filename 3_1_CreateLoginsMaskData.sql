--------------------------------------------------------------------------------- 
-- DEMO 1 --
-- Creating Development Login and mask sensitive data
---------------------------------------------------------------------------------

SET NOCOUNT ON

-- Creating login for development team
USE master
GO

-- Creating login
CREATE LOGIN dev_team WITH PASSWORD=N'_D3v3L0pM3nt_',
DEFAULT_DATABASE=HumanResources, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

EXEC sp_addsrvrolemember 'dev_team', 'processadmin'
GO

-- Granting additional permissions
GRANT VIEW SERVER STATE TO dev_team
GO

-- Creating user login with execute permission in DBA database
USE DBA
GO

CREATE USER dev_team FOR LOGIN dev_team
GO
GRANT EXECUTE ON dbo.sp_WhoIsActive TO dev_team
GO

-- Creating user for login with read-only access in Human Resources database
USE HumanResources
GO

CREATE USER dev_team FOR LOGIN dev_team
GO
ALTER ROLE db_datareader ADD MEMBER dev_team
GO
ALTER ROLE db_datawriter ADD MEMBER dev_team
GO
ALTER ROLE db_ddladmin ADD MEMBER dev_team
GO
ALTER ROLE db_backupoperator ADD MEMBER dev_team
GO

-- Start flag
SELECT 'Logins succesfully created'
GO

-- ***** Masking data using Dynamic data masking ***** 
-- ***** Employees data *****
-- First name
ALTER TABLE HumanResources.dbo.Employees  
ALTER COLUMN first_name ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",2)');  

-- Last name
ALTER TABLE HumanResources.dbo.Employees  
ALTER COLUMN last_name ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",2)');  

-- Salary
ALTER TABLE HumanResources.dbo.Employees  
ALTER COLUMN salary ADD MASKED WITH (FUNCTION = 'random(1, 12)');  

-- Email
ALTER TABLE HumanResources.dbo.Employees  
ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');

-- Phone number
ALTER TABLE HumanResources.dbo.Employees  
ALTER COLUMN phone_number ADD MASKED WITH (FUNCTION = 'partial(1,"XXX",1)');

-- ***** Dependents data *****
-- First name
ALTER TABLE HumanResources.dbo.Dependents  
ALTER COLUMN first_name ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",2)');  

-- Last name
ALTER TABLE HumanResources.dbo.Dependents  
ALTER COLUMN last_name ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",2)');
GO

-- End flag
SELECT 'Data has been masked';
GO
