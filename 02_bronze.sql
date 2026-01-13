/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);
GO

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);
GO


/* BULK INSERT COMMANDS CAN BE ADDED BELOW TO LOAD DATA INTO THE BRONZE TABLES */

-- =====================================================================
-- BULK INSERT: Load CRM Customer Information into Bronze Layer
-- =====================================================================
-- DESCRIPTION:
--   Loads customer information from a CSV file into the bronze.crm_cust_info
--   table. This operation reads from the source CRM dataset and populates
--   the bronze layer with raw customer data for further transformation.
--
-- SOURCE:
--   File: datasets/source_crm/cust_info.csv
--   Format: CSV (Comma-Separated Values)
--
-- TARGET:
--   Schema: bronze
--   Table: crm_cust_info
--
-- PARAMETERS:
--   FIRSTROW = 2        - Skips the header row (row 1) and starts loading from row 2
--   FIELDTERMINATOR = ',' - Specifies comma as the field delimiter
--   TABLOCK             - Uses table-level lock for improved performance during bulk insert
--
-- NOTES:
--   - Assumes the CSV file has a header row in the first line
--   - Requires appropriate file system permissions and valid file path
--   - TABLOCK minimizes transaction log space and improves insert performance
--   - Part of the data warehouse ETL pipeline (bronze layer ingestion)
-- =====================================================================
BULK INSERT bronze.crm_cust_info
FROM 'datasets/source_crm/cust_info.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
)
GO

-- =====================================================================
-- BULK INSERT: Load CRM Product Information into Bronze Layer
-- =====================================================================
-- DESCRIPTION:
--   Loads product information from a CSV file into the bronze.crm_prd_info
--   table. This operation reads from the source CRM dataset and populates
--   the bronze layer with raw product data for further transformation.
--
-- SOURCE:
--   File: datasets/source_crm/prd_info.csv
--   Format: CSV (Comma-Separated Values)
--
-- TARGET:
--   Schema: bronze
--   Table: crm_prd_info
--
-- PARAMETERS:
--   FIRSTROW = 2        - Skips the header row (row 1) and starts loading from row 2
--   FIELDTERMINATOR = ',' - Specifies comma as the field delimiter
--   TABLOCK             - Uses table-level lock for improved performance during bulk insert
--
-- NOTES:
--   - Assumes the CSV file has a header row in the first line
--   - Requires appropriate file system permissions and valid file path
--   - TABLOCK minimizes transaction log space and improves insert performance
--   - Part of the data warehouse ETL pipeline (bronze layer ingestion)
-- =====================================================================
BULK INSERT bronze.crm_prd_info
FROM 'datasets/source_crm/prd_info.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
)
GO

-- =====================================================================
-- BULK INSERT: Load CRM Sales Details into Bronze Layer
-- =====================================================================
BULK INSERT bronze.crm_sales_details
FROM 'datasets/source_crm/sales_details.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
)
GO

-- =====================================================================
-- BULK INSERT: Load ERP Location Data into Bronze Layer
-- =====================================================================
BULK INSERT bronze.erp_loc_a101
FROM 'datasets/source_erp/loc_a101.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
)
GO

-- =====================================================================
-- BULK INSERT: Load ERP Customer Data into Bronze Layer
-- =====================================================================
BULK INSERT bronze.erp_cust_az12
FROM 'datasets/source_erp/cust_az12.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
)
GO

-- =====================================================================
-- BULK INSERT: Load ERP Product Category Data into Bronze Layer
-- =====================================================================
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'datasets/source_erp/px_cat_g1v2.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
)


SELECT * FROM bronze.crm_cust_info;
GO
SELECT * FROM bronze.crm_prd_info;
GO
SELECT * FROM bronze.crm_sales_details; 
GO
SELECT * FROM bronze.erp_loc_a101;
GO    
SELECT * FROM bronze.erp_cust_az12;
GO
SELECT * FROM bronze.erp_px_cat_g1v2;
GO