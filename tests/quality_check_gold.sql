/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    This script performs quality checks on Gold layer views.

    Checks include:
    - Null or duplicate surrogate keys
    - Missing foreign key mappings
    - Data consistency
    - Business rule validation

Usage:
    Run after ddl_gold.sql
===============================================================================
*/

USE Datawarehouse;

-- =============================================================================
-- Check gold_dim_customers
-- =============================================================================

-- Check duplicate customer keys
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Check null customer keys
SELECT *
FROM gold_dim_customers
WHERE customer_key IS NULL;

-- Check invalid gender values
SELECT DISTINCT gender
FROM gold_dim_customers;

-- Check missing customer IDs
SELECT *
FROM gold_dim_customers
WHERE customer_id IS NULL;

-- Check future birthdates
SELECT *
FROM gold_dim_customers
WHERE birthdate > CURDATE();


-- =============================================================================
-- Check gold_dim_products
-- =============================================================================

-- Check duplicate product keys
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Check null product keys
SELECT *
FROM gold_dim_products
WHERE product_key IS NULL;

-- Check products without category
SELECT *
FROM gold_dim_products
WHERE category IS NULL;

-- Check negative product cost
SELECT *
FROM gold_dim_products
WHERE cost < 0;


-- =============================================================================
-- Check gold_fact_sales
-- =============================================================================

-- Check rows with missing product mapping
SELECT *
FROM gold_fact_sales
WHERE product_key IS NULL;

-- Check rows with missing customer mapping
SELECT *
FROM gold_fact_sales
WHERE customer_key IS NULL;

-- Check negative sales amount
SELECT *
FROM gold_fact_sales
WHERE sales_amount < 0;

-- Check negative quantity
SELECT *
FROM gold_fact_sales
WHERE quantity < 0;

-- Check negative price
SELECT *
FROM gold_fact_sales
WHERE price < 0;

-- Check invalid date logic
SELECT *
FROM gold_fact_sales
WHERE shipping_date < order_date
   OR due_date < order_date;

-- Check fact rows with missing product join
SELECT f.*
FROM gold_fact_sales f
LEFT JOIN gold_dim_products p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

-- Check fact rows with missing customer join
SELECT f.*
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;
