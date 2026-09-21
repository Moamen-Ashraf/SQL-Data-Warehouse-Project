/*
===============================================================================
Purpose:
    Loads the 'silver' schema tables from the 'bronze' schema.
    For each table it will:
        - Truncate the silver table
        - Insert cleaned and transformed data from the bronze table
        - Print the load duration for that table

Tables loaded:
    CRM: crm_cust_info, crm_prod_info, crm_sales_details
    ERP: erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2

Parameters:
    None.

Usage:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROC silver.load_silver AS 
BEGIN
    BEGIN TRY
        DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
		PRINT 'Loading Silver Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT 'Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT 'Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT cst_id,
            cst_key,
            ISNULL(TRIM(cst_firstname), 'N/A') AS 'cst_firstname',
            ISNULL(TRIM(cst_lastname), 'N/A') AS 'cst_lastname',
            CASE
                WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
                WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'
                ELSE 'N/A'
                END AS cst_marital_status,
                CASE
                WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
                WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
                ELSE 'N/A'
                END AS cst_gndr,
                CAST (cst_create_date AS DATE) AS cst_create_date
        FROM (
            SELECT *,
            ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS last_updt
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE last_updt = 1;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(50)) + ' seconds';
        PRINT '-------------';


        SET @start_time = GETDATE();
        PRINT 'Truncating Table: silver.crm_prod_info';
        TRUNCATE TABLE silver.crm_prod_info;

        PRINT 'Inserting Data Into: silver.crm_prod_info';
        INSERT INTO silver.crm_prod_info(
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'M' THEN 'Mountain'
                WHEN 'T' THEN 'Touring'
                Else 'N/A'
                END AS prd_line,
                CAST(prd_start_dt AS DATE) AS prd_start_dt,
                CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt 
        FROM bronze.crm_prod_info;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(50)) + ' seconds';
        PRINT '-------------';


        SET @start_time = GETDATE();
        PRINT 'Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT 'Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN LEN(sls_order_dt) != 8 OR sls_order_dt <= 0 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR(8)) AS DATE) 
            END sls_order_dt,
            CASE 
                WHEN LEN(sls_ship_dt) != 8 OR sls_ship_dt <= 0 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR(8)) AS DATE) 
            END sls_ship_dt,
            CASE 
                WHEN LEN(sls_due_dt) != 8 OR sls_due_dt <= 0 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR(8)) AS DATE) 
            END sls_due_dt,
            CASE
                WHEN sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) OR sls_sales IS NULL THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
                END AS sls_sales,
                sls_quantity,
                CASE
                WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
                END AS sls_price
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(50)) + ' seconds';
        PRINT '-------------';

        PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT 'Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT 'Inserting Data Into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12(
            cid,
            bdate,
            gen
        )
        SELECT CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
                END AS cid,
                CASE 
                    WHEN bdate < '1900-01-01' OR bdate > GETDATE() THEN NULL
                    ELSE bdate
                END AS bdate,
                CASE SUBSTRING(UPPER(TRIM(gen)), 1, 1)
                    WHEN 'M' THEN 'Male'
                    WHEN 'F' THEN 'Female'
                    ELSE 'N/A'
                END AS gen
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(50)) + ' seconds';
        PRINT '-------------';


        SET @start_time = GETDATE();
        PRINT 'Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT 'Inserting Data Into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101(
            cid,
            cntry
        )
        SELECT REPLACE(cid, '-', '') AS cid,
                CASE 
                    WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
                    WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
                    WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'N/A'
                    ELSE TRIM(cntry)
                END AS cntry
        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(50)) + ' seconds';
        PRINT '-------------';


        SET @start_time = GETDATE();
        PRINT 'Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT 'Inserting Data Into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2(
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT id,
            TRIM(cat) AS cat,
            TRIM(subcat) AS subcat,
            CASE 
                    WHEN TRIM(UPPER(maintenance)) LIKE 'Y%' THEN 'YES'
                    WHEN TRIM(UPPER(maintenance)) LIKE 'N%' THEN 'NO'
                    ELSE 'N/A'
                END AS maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(50)) + ' seconds';
        PRINT '-------------';

        SET @batch_end_time= GETDATE();
        PRINT '------------------------------------------------';
        PRINT 'Loading Silver Layer is Completed';
        print 'Total Load Duration:' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(50)) + ' seconds';
        PRINT '------------------------------------------------';
    END TRY
    BEGIN CATCH
        PRINT '---------------------------------------------';
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(50));
        PRINT 'Error Message: ' + ERROR_Message() ;
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(50)) ;
        PRINT '----------------------------------------------';
    END CATCH
END
