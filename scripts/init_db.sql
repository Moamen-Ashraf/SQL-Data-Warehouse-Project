USE master;

GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DataWarehouse')
   Drop DATABASE DataWarehouse;

GO

CREATE DATABASE DataWarehouse;

GO

USE DataWarehouse;

GO

CREATE SCHEMA bronze;

GO

CREATE SCHEMA silver;

GO

CREATE SCHEMA gold;
GO
