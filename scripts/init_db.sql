/*
----------------------------------------------------------------------------------------
DDL Script: Initialize Data Warehouse Database
----------------------------------------------------------------------------------------
Create the DataWarehouse database and its schemas:
bronze
silver
gold

Note: if the database already exists, it will be dropped and recreated
      (all connections are terminated and any open transactions are rolled back)
*/

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
