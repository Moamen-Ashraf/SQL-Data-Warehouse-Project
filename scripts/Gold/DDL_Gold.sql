/*
----------------------------------------------------------------------------------------
DDL Script: Create Gold Layer Views
----------------------------------------------------------------------------------------
Purpose:
    Create aggregated views for the Gold layer representing
    dimensions and fact tables for analytical consumption.

Note: If a view already exists, it will be dropped and recreated.
----------------------------------------------------------------------------------------
*/

------------------------------------------------------------
-- 1. Dimension: gold.dim_customer
------------------------------------------------------------

IF OBJECT_ID('gold.dim_customer','v') IS NOT NULL
    DROP VIEW gold.dim_customer;
GO

CREATE VIEW gold.dim_customer AS
    SELECT 
        ROW_NUMBER() OVER(ORDER BY ci.cst_create_date, ci.cst_id) AS customer_key, -- Surrogate Key
        ci.cst_id AS customer_id, 
        ci.cst_key AS customer_number,
        ci.cst_firstname AS first_name,
        ci.cst_lastname AS last_name, 
        cl.cntry AS country,
        ci.cst_marital_status AS marital_status,
        CASE
                WHEN ci.cst_gndr LIKE 'N/A' THEN NULLIF(ca.gen, 'N/A')
                ELSE ci.cst_gndr
            END AS gender,
        ca.bdate AS birth_date,
        ci.cst_create_date AS create_date
    FROM silver.crm_cust_info ci
        LEFT JOIN silver.erp_cust_az12 ca
                ON ci.cst_key = ca.cid
        LEFT JOIN silver.erp_loc_a101 cl 
                ON ci.cst_key = cl.cid;
GO


------------------------------------------------------------
-- 2. Dimension: gold.dim_product
------------------------------------------------------------

IF OBJECT_ID('gold.dim_product','v') IS NOT NULL
    DROP VIEW gold.dim_product;
GO

CREATE VIEW gold.dim_product AS
    SELECT 
        ROW_NUMBER() OVER(ORDER BY prd.prd_start_dt, prd.prd_key) AS Product_key,  -- Surrogate Key
        prd.prd_id AS product_id,
        prd.prd_key AS product_number,
        prd.prd_nm AS product_name,
        prd.cat_id AS Category_id,
        cat.cat AS category,
        cat.subcat AS sub_category,
        cat.maintenance,
        prd.prd_cost AS product_cost,
        prd.prd_line AS product_line,
        prd.prd_start_dt AS start_date
    FROM silver.crm_prod_info prd
        LEFT JOIN silver.erp_px_cat_g1v2 cat
        ON prd.cat_id = cat.id
    WHERE prd.prd_end_dt IS NULL
GO


------------------------------------------------------------
-- 3. Fact Table: gold.fact_sales
------------------------------------------------------------

IF OBJECT_ID('gold.fact_sales','v') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
    SELECT 
        sls.sls_ord_num AS order_number,
        prd.product_key,
        cst.customer_key,
        sls.sls_order_dt AS order_date,
        sls.sls_ship_dt AS shipping_date,
        sls.sls_due_dt AS due_date,
        sls.sls_sales AS sales_amount,
        sls.sls_quantity AS quantity,
        sls.sls_price AS price
    FROM silver.crm_sales_details sls
        LEFT JOIN gold.dim_customer cst 
        ON sls.sls_cust_id = cst.customer_id
        LEFT JOIN gold.dim_product prd
        ON sls.sls_prd_key = prd.product_number
GO 