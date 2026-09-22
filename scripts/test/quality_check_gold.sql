------------------------------------------------------------
-- Quality Checks: Gold Layer
------------------------------------------------------------

------------------------------------------------------------
-- 1. Dimension: gold.dim_customer
------------------------------------------------------------

-- Preview all customer records
SELECT * FROM gold.dim_customer;

-- Check for duplicates in surrogate primary key (customer_key)
SELECT customer_key, COUNT(*)
FROM gold.dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1;


------------------------------------------------------------
-- 2. Dimension: gold.dim_product
------------------------------------------------------------

-- Preview all product records
SELECT * FROM gold.dim_product;

-- Check for duplicates in surrogate primary key (product_key)
SELECT product_key, COUNT(*)
FROM gold.dim_product
GROUP BY product_key
HAVING COUNT(*) > 1;


------------------------------------------------------------
-- 3. Fact Table: gold.fact_sales
------------------------------------------------------------

-- Preview all sales records
SELECT * FROM gold.fact_sales;

-- Check referential integrity: ensure every FK in fact_sales
-- exists in its parent dimension (no orphan records)
SELECT *
    FROM gold.fact_sales sls
        LEFT JOIN gold.dim_customer cst 
        ON sls.customer_key = cst.customer_key
        LEFT JOIN gold.dim_product prd
        ON sls.product_key = prd.product_key
WHERE prd.product_key IS NULL OR cst.customer_key IS NULL