/*
----------------------------------------------------------------------------------------
DDL Script: Create Bronze Tables
----------------------------------------------------------------------------------------
Create tables of bronze layers:
    CRM: crm_cust_info, crm_prod_info, crm_sales_details
    ERP: erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2

Note: if table is existed already it will drop it
*/

-- Table: bronze.crm_cust_info - Bronze Layer
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: bronze.crm_cust_info';
    DROP TABLE bronze.crm_cust_info;
END
GO

PRINT 'Creating table: bronze.crm_cust_info';
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(30),
    cst_lastname VARCHAR(30),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATETIME
);
GO

-- Table: bronze.crm_prod_info - Bronze Layer
IF OBJECT_ID('bronze.crm_prod_info', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: bronze.crm_prod_info';
    DROP TABLE bronze.crm_prod_info;
END
GO

PRINT 'Creating table: bronze.crm_prod_info';
GO

CREATE TABLE bronze.crm_prod_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost DECIMAL,
    prd_line VARCHAR(10),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);
GO

-- Table: bronze.crm_sales_details - Bronze Layer
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: bronze.crm_sales_details';
    DROP TABLE bronze.crm_sales_details;
END
GO

PRINT 'Creating table: bronze.crm_sales_details';
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price DECIMAL
);
GO

-- Table: bronze.erp_cust_az12 - Bronze Layer
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: bronze.erp_cust_az12';
    DROP TABLE bronze.erp_cust_az12;
END
GO

PRINT 'Creating table: bronze.erp_cust_az12';
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(10)
);
GO

-- Table: bronze.erp_loc_a101 - Bronze Layer
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: bronze.erp_loc_a101';
    DROP TABLE bronze.erp_loc_a101;
END
GO

PRINT 'Creating table: bronze.erp_loc_a101';
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);
GO

-- Table: bronze.erp_px_cat_g1v2 - Bronze Layer
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: bronze.erp_px_cat_g1v2';
    DROP TABLE bronze.erp_px_cat_g1v2;
END
GO

PRINT 'Creating table: bronze.erp_px_cat_g1v2';
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(10)
);
GO