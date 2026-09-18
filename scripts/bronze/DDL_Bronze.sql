/*
----------------------------------------------------------------------------------------
DDL Script: Create Bronze Tables
----------------------------------------------------------------------------------------
Create tables of bronze layers:
crm_cust_info
crm_prd_info
crm_sales_details

erp_cust_az12
erp_loc_a101
erp_px_cat_g1v2

Note: if table is existed already it will drop it
*/

IF OBJECT_ID('bronze.crm_cut_info', 'U') IS NOT NULL 
    DROP TABLE bronze.crm_cut_info;
GO

CREATE TABLE bronze.crm_cut_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(30),
    cst_lastname VARCHAR(30),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATETIME
);
GO

IF OBJECT_ID('bronze.crm_prod_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prod_info;
GO

CREATE TABLE bronze.crm_prod_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost DECIMAL,
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);
GO

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
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

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid INT,
    bdate DATE,
    gen VARCHAR(10)
);
GO

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);
GO

IF OBJECT_ID('bronze.px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.px_cat_g1v2;
GO

CREATE TABLE bronze.px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(10)
);
GO

