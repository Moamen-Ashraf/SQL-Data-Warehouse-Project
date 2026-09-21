/*
===============================================================================
Data Quality Checks: Bronze Layer
===============================================================================
Purpose:
    Profile the raw data in the 'bronze' schema to find problems that must be
    fixed in the Silver layer transformations (silver.load_silver).

Checks performed:
    - Duplicates or NULLs in primary keys
    - Unwanted leading/trailing spaces in text columns
    - Data standardization and consistency (distinct values)
    - Invalid values, outliers, and invalid date ranges
    - Data integrity of keys between related tables

Tables checked:
    CRM: crm_cust_info, crm_prod_info, crm_sales_details
    ERP: erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2

Usage notes:
    - Run after loading the bronze layer (EXEC bronze.load_bronze;).
    - Most queries should return NO rows. Any rows returned show an issue to
      handle in the Silver layer. Queries with DISTINCT are for review.
===============================================================================
*/

USE DataWarehouse

------------------------------------------------
--    Check Data Quality of table (bronze.crm_cust_info)
------------------------------------------------

-- Check For Nulls or Duplicates in Primary Key
SELECT * FROM bronze.crm_cust_info
WHERE cst_id IN 
                (SELECT cst_id
                FROM bronze.crm_cust_info
                GROUP BY cst_id
                HAVING Count(cst_id) > 1 OR cst_id IS NULL)
        OR cst_id IS NULL


-- Check For Unwanted Spaces or Nulls in cst_key
SELECT cst_key
From bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key) OR cst_key IS NULL


-- Check For Unwanted Spaces in cst_lastname
SELECT cst_lastname, *
From bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- Check For Data Standardization and Consistency (marital status)
select DISTINCT cst_marital_status from bronze.crm_cust_info


------------------------------------------------
--    Check Data Quality of table (bronze.crm_prod_info)
------------------------------------------------

-- Check For Nulls or Duplicates in Primary Key
SELECT * FROM bronze.crm_prod_info
WHERE prd_id IN 
                (SELECT prd_id
                FROM bronze.crm_prod_info
                GROUP BY prd_id
                HAVING Count(prd_id) > 1)
      OR prd_id IS NULL

-- Check For Invalid Values (NULL or non-positive cost)
SELECT prd_cost 
FROM bronze.crm_prod_info
WHERE prd_cost IS NULL OR prd_cost <= 0

-- Check For Unwanted Spaces in prd_line
SELECT prd_line, *
From bronze.crm_prod_info
WHERE prd_line != TRIM(prd_line)

-- Check For Data Standardization and Consistency (product line)
SELECT DISTINCT prd_line FROM bronze.crm_prod_info

-- Check For Outliers (start date out of range)
SELECT prd_start_dt 
FROM bronze.crm_prod_info
WHERE prd_start_dt < '1900-01-01' OR prd_start_dt > GETDATE()

-- Check For Invalid Date Ranges (start date after end date)
SELECT prd_id, prd_key, prd_cost, prd_start_dt, prd_end_dt 
FROM bronze.crm_prod_info
WHERE prd_start_dt > prd_end_dt


------------------------------------------------
--    Check Data Quality of table (bronze.crm_sales_details)
------------------------------------------------

-- Check For Nulls or Duplicates in Order Number
SELECT * FROM bronze.crm_sales_details
WHERE sls_ord_num IN 
                (SELECT sls_ord_num
                FROM bronze.crm_sales_details
                GROUP BY sls_ord_num
                HAVING Count(sls_ord_num) > 1)
      OR sls_ord_num IS NULL
      
-- Check For Unwanted Spaces in sls_prd_key
SELECT sls_prd_key, *
From bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)

-- Check For Outliers (order date out of range)
SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt < '19000101' OR  sls_order_dt > '20300101'

-- Check For Invalid Dates (must be 8 digits, YYYYMMDD, and positive)
SELECT sls_order_dt, sls_ship_dt, sls_due_dt
FROM bronze.crm_sales_details
WHERE 
    (LEN(sls_order_dt) != 8 OR sls_order_dt <= 0)
    OR (LEN(sls_ship_dt) != 8 OR sls_ship_dt <= 0)
    OR (LEN(sls_due_dt) != 8 OR sls_due_dt <= 0);

-- Check For Invalid Date Order (order date after ship or due date)
SELECT sls_order_dt, sls_ship_dt, sls_due_dt
FROM bronze.crm_sales_details
WHERE 
    sls_order_dt > sls_ship_dt OR
    sls_order_dt > sls_due_dt

-- Check For Data Consistency (NULL or non-positive price, sales, quantity)
SELECT * FROM bronze.crm_sales_details
WHERE sls_price <= 0 OR sls_price IS NULL OR
      sls_sales <= 0 OR sls_sales IS NULL OR 
      sls_quantity <= 0 OR sls_quantity IS NULL

------------------------------------------------
--    Check Data Quality of table (bronze.erp_cust_az12)
------------------------------------------------

-- Check Data Integrity of Key (cid after removing 'NAS' prefix vs crm cst_key)
SELECT cid
FROM (SELECT CASE 
           WHEN SUBSTRING(cid, 1, 3) = 'NAS' THEN SUBSTRING(cid, 4, LEN(cid))
           ELSE cid
      END AS cid
FROM bronze.erp_cust_az12) t 
WHERE cid NOT IN (
      SELECT cst_key FROM bronze.crm_cust_info
)

-- Check For Outliers (birth date out of range or NULL)
SELECT bdate 
FROM bronze.erp_cust_az12
WHERE bdate < '1900-01-01' OR bdate > GETDATE() OR bdate IS NULL

-- Check For Unwanted Spaces in gen
SELECT gen
From bronze.erp_cust_az12
WHERE gen != TRIM(gen)

-- Check For Data Standardization and Consistency (gender)
SELECT DISTINCT gen 
From bronze.erp_cust_az12

------------------------------------------------
--    Check Data Quality of table (bronze.erp_loc_a101)
------------------------------------------------

-- Check Data Integrity of Key (cid after removing '-' vs crm cst_key)
SELECT cid
FROM 
    (SELECT REPLACE(cid, '-', '') AS cid
     FROM bronze.erp_loc_a101) t
WHERE cid NOT IN (SELECT cst_key FROM bronze.crm_cust_info)

-- Check For Unwanted Spaces in cntry
SELECT cntry
From bronze.erp_loc_a101
WHERE cntry != TRIM(cntry)

-- Check For Data Standardization and Consistency (country)
SELECT DISTINCT cntry 
From bronze.erp_loc_a101

------------------------------------------------
--    Check Data Quality of table (bronze.erp_px_cat_g1v2)
------------------------------------------------

-- Check Data Integrity of Foriegn Key
SELECT id
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (
    SELECT REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')
    FROM bronze.crm_prod_info
)

-- Check For Unwanted Spaces in cat
SELECT cat
From bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)

-- Check For Data Standardization and Consistency (maintenance)
SELECT DISTINCT maintenance 
From bronze.erp_px_cat_g1v2