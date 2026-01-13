/* 
======================================================================
Create Database and Schemas
======================================================================
Script Purpose: 
    This script creates a new database named 'DataWarehosue' after checking if it already exisits.
    if the database exists, it is dropped and recreated. Aditionally,the script sets up three schema within the database: 'bronze', 'silver' , 'gold'
WARNING: 
    Running this sript will drop the entire 'DataWarehouse' database if it exists
    All data in the database will be deleted permanently. Proceed with caution.
    and ensure you have proper backups before running th scripts.
*/

USE master;
GO

-- DROP AND RECREATE THE DATABASE 'DATAWAREHOUSE' IF IT EXISTS (force disconnect)
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END
GO
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- CREATE SCHEMAS FOR DIFFERENT LAYERS OF THE DATA WAREHOUSE (idempotent)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'BRONZE')
    EXEC('CREATE SCHEMA BRONZE');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'SILVER')
    EXEC('CREATE SCHEMA SILVER');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'GOLD')
    EXEC('CREATE SCHEMA GOLD');
GO
 

