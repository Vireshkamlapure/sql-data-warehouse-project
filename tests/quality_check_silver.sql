/*
===============================================================================
Quality Checks - MySQL Version
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer.

Checks Included:
    - NULL or duplicate primary keys
    - Unwanted spaces in string fields
    - Data standardization & consistency
    - Invalid date ranges
    - Invalid date order checks
    - Sales consistency validation

Run after loading data into Silver Layer.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver_crm_cust_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM silver_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cst_key
FROM silver_crm_cust_info
WHERE cst_key <> TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status
FROM silver_crm_cust_info;

SELECT DISTINCT 
    cst_gndr
FROM silver_crm_cust_info;


-- ====================================================================
-- Checking 'silver_crm_prd_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) AS record_count
FROM silver_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    prd_nm
FROM silver_crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost
FROM silver_crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line
FROM silver_crm_prd_info;

-- Check for Invalid Date Orders
-- Expectation: No Results
SELECT *
FROM silver_crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- Checking 'silver_crm_sales_details'
-- ====================================================================

-- Check for Invalid Raw Date Values
-- Expectation: No Invalid Dates
SELECT 
    sls_due_dt
FROM bronze_crm_sales_details
WHERE sls_due_dt <= 0
   OR CHAR_LENGTH(sls_due_dt) <> 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- Check for Invalid Date Orders
-- Expectation: No Results
SELECT *
FROM silver_crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check Sales Consistency
-- Expectation: No Results
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver_crm_sales_details
WHERE sls_sales <> (sls_quantity * sls_price)
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ====================================================================
-- Checking 'silver_erp_cust_az12'
-- ====================================================================

-- Birthdate Validation
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT
    bdate
FROM silver_erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > CURDATE();

-- Gender Standardization
SELECT DISTINCT
    gen
FROM silver_erp_cust_az12;


-- ====================================================================
-- Checking 'silver_erp_loc_a101'
-- ====================================================================

-- Country Standardization
SELECT DISTINCT
    cntry
FROM silver_erp_loc_a101
ORDER BY cntry;


-- ====================================================================
-- Checking 'silver_erp_px_cat_g1v2'
-- ====================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT *
FROM silver_erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);

-- Maintenance Standardization
SELECT DISTINCT
    maintenance
FROM silver_erp_px_cat_g1v2;
