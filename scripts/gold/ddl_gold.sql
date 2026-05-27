/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.

    The Gold layer represents the final star schema model:
    - Dimension Tables
    - Fact Tables

    These views transform and integrate cleaned Silver layer data into
    business-ready analytical datasets.

Usage:
    Run this script after Silver layer data is successfully loaded.
===============================================================================
*/

USE Datawarehouse;

-- =============================================================================
-- Drop Existing Views
-- =============================================================================
DROP VIEW IF EXISTS gold_fact_sales;
DROP VIEW IF EXISTS gold_dim_products;
DROP VIEW IF EXISTS gold_dim_customers;

-- =============================================================================
-- Create Dimension: gold_dim_customers
-- =============================================================================
CREATE VIEW gold_dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,   -- Surrogate Key

    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,

    la.cntry AS country,

    ci.cst_marital_status AS marital_status,

    CASE
        WHEN ci.cst_gndr <> 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date

FROM silver_crm_cust_info ci
LEFT JOIN silver_erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver_erp_loc_a101 la
    ON ci.cst_key = la.cid;

-- =============================================================================
-- Create Dimension: gold_dim_products
-- =============================================================================
CREATE VIEW gold_dim_products AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY pi.prd_start_dt, pi.prd_key
    ) AS product_key,                      -- Surrogate Key

    pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    pi.prd_nm AS product_name,
    pi.cat_id AS category_id,

    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance AS maintenance,

    pi.prd_cost AS cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS start_date

FROM silver_crm_prd_info pi
LEFT JOIN silver_erp_px_cat_g1v2 pc
    ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL;

-- =============================================================================
-- Create Fact Table: gold_fact_sales
-- =============================================================================
CREATE VIEW gold_fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,

    pr.product_key AS product_key,
    cu.customer_key AS customer_key,

    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,

    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price

FROM silver_crm_sales_details sd
LEFT JOIN gold_dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold_dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
