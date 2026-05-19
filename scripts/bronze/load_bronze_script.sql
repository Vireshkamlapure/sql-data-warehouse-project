USE DataWarehouse;

SET @batch_start = NOW();

SELECT '==========================================' AS Status;
SELECT CONCAT('Bronze Layer Load Started At: ', @batch_start) AS Status;
SELECT '==========================================' AS Status;

-- CRM CUSTOMER
SET @start_time = NOW();

SELECT CONCAT('Started loading bronze_crm_cust_info at: ', @start_time) AS Status;

TRUNCATE TABLE bronze_crm_cust_info;

LOAD DATA LOCAL INFILE '/Users/vireshkamlapure/Desktop/SELF STUDY PLACEMENT /Projects/MySQL/Data_Warehouse_With_ETL/datasets/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'Completed bronze_crm_cust_info | Rows: ',
    COUNT(*),
    ' | Started: ', @start_time,
    ' | Ended: ', @end_time,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec'
) AS Status
FROM bronze_crm_cust_info;


-- CRM PRODUCT
SET @start_time = NOW();

SELECT CONCAT('Started loading bronze_crm_prd_info at: ', @start_time) AS Status;

TRUNCATE TABLE bronze_crm_prd_info;

LOAD DATA LOCAL INFILE '/Users/vireshkamlapure/Desktop/SELF STUDY PLACEMENT /Projects/MySQL/Data_Warehouse_With_ETL/datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'Completed bronze_crm_prd_info | Rows: ',
    COUNT(*),
    ' | Started: ', @start_time,
    ' | Ended: ', @end_time,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec'
) AS Status
FROM bronze_crm_prd_info;


-- CRM SALES
SET @start_time = NOW();

SELECT CONCAT('Started loading bronze_crm_sales_details at: ', @start_time) AS Status;

TRUNCATE TABLE bronze_crm_sales_details;

LOAD DATA LOCAL INFILE '/Users/vireshkamlapure/Desktop/SELF STUDY PLACEMENT /Projects/MySQL/Data_Warehouse_With_ETL/datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'Completed bronze_crm_sales_details | Rows: ',
    COUNT(*),
    ' | Started: ', @start_time,
    ' | Ended: ', @end_time,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec'
) AS Status
FROM bronze_crm_sales_details;


-- ERP CUSTOMER
SET @start_time = NOW();

SELECT CONCAT('Started loading bronze_erp_cust_az12 at: ', @start_time) AS Status;

TRUNCATE TABLE bronze_erp_cust_az12;

LOAD DATA LOCAL INFILE '/Users/vireshkamlapure/Desktop/SELF STUDY PLACEMENT /Projects/MySQL/Data_Warehouse_With_ETL/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'Completed bronze_erp_cust_az12 | Rows: ',
    COUNT(*),
    ' | Started: ', @start_time,
    ' | Ended: ', @end_time,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec'
) AS Status
FROM bronze_erp_cust_az12;


-- ERP LOCATION
SET @start_time = NOW();

SELECT CONCAT('Started loading bronze_erp_loc_a101 at: ', @start_time) AS Status;

TRUNCATE TABLE bronze_erp_loc_a101;

LOAD DATA LOCAL INFILE '/Users/vireshkamlapure/Desktop/SELF STUDY PLACEMENT /Projects/MySQL/Data_Warehouse_With_ETL/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'Completed bronze_erp_loc_a101 | Rows: ',
    COUNT(*),
    ' | Started: ', @start_time,
    ' | Ended: ', @end_time,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec'
) AS Status
FROM bronze_erp_loc_a101;


-- ERP CATEGORY
SET @start_time = NOW();

SELECT CONCAT('Started loading bronze_erp_px_cat_g1v2 at: ', @start_time) AS Status;

TRUNCATE TABLE bronze_erp_px_cat_g1v2;

LOAD DATA LOCAL INFILE '/Users/vireshkamlapure/Desktop/SELF STUDY PLACEMENT /Projects/MySQL/Data_Warehouse_With_ETL/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'Completed bronze_erp_px_cat_g1v2 | Rows: ',
    COUNT(*),
    ' | Started: ', @start_time,
    ' | Ended: ', @end_time,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec'
) AS Status
FROM bronze_erp_px_cat_g1v2;


-- TOTAL BATCH TIME
SET @batch_end = NOW();

SELECT '==========================================' AS Status;
SELECT CONCAT('Bronze Layer Load Ended At: ', @batch_end) AS Status;
SELECT CONCAT(
    'Total Duration: ',
    TIMESTAMPDIFF(SECOND, @batch_start, @batch_end),
    ' sec'
) AS Status;
SELECT '==========================================' AS Status;
