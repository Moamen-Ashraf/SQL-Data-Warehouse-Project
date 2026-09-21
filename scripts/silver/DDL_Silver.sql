/*
----------------------------------------------------------------------------------------
DDL Script: Create silver Tables
----------------------------------------------------------------------------------------
Create tables of silver layers:
crm_cust_info
crm_prod_info
crm_sales_details

erp_cust_az12
erp_loc_a101
erp_px_cat_g1v2

Note: if table is existed already it will drop it
*/

-- Table: silver.crm_cust_info - Silver Layer
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: silver.crm_cust_info';
    DROP TABLE silver.crm_cust_info;
END
GO

PRINT 'Creating table: silver.crm_cust_info';
GO

CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(30),
    cst_lastname VARCHAR(30),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATE,
    dwh_create_date DATETIME DEFAULT GETDATE()
);
GO

-- Table: silver.crm_prod_info - Silver Layer
IF OBJECT_ID('silver.crm_prod_info', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: silver.crm_prod_info';
    DROP TABLE silver.crm_prod_info;
END
GO

PRINT 'Creating table: silver.crm_prod_info';
GO

CREATE TABLE silver.crm_prod_info (
    prd_id INT,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost DECIMAL,
    prd_line VARCHAR(30),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT GETDATE()
);
GO

-- Table: silver.crm_sales_details - Silver Layer
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: silver.crm_sales_details';
    DROP TABLE silver.crm_sales_details;
END
GO

PRINT 'Creating table: silver.crm_sales_details';
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME DEFAULT GETDATE()
);
GO

-- Table: silver.erp_cust_az12 - Silver Layer
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: silver.erp_cust_az12';
    DROP TABLE silver.erp_cust_az12;
END
GO

PRINT 'Creating table: silver.erp_cust_az12';
GO

CREATE TABLE silver.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(10),
    dwh_create_date DATETIME DEFAULT GETDATE()
);
GO

-- Table: silver.erp_loc_a101 - Silver Layer
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: silver.erp_loc_a101';
    DROP TABLE silver.erp_loc_a101;
END
GO

PRINT 'Creating table: silver.erp_loc_a101';
GO

CREATE TABLE silver.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date DATETIME DEFAULT GETDATE()
);
GO

-- Table: silver.erp_px_cat_g1v2 - Silver Layer
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping existing table: silver.erp_px_cat_g1v2';
    DROP TABLE silver.erp_px_cat_g1v2;
END
GO

PRINT 'Creating table: silver.erp_px_cat_g1v2';
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(10),
    dwh_create_date DATETIME DEFAULT GETDATE()
);
GO