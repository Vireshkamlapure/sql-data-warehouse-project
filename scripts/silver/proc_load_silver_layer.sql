USE datawarehouse;

DELIMITER $$

DROP PROCEDURE IF EXISTS load_silver_layer $$

CREATE PROCEDURE load_silver_layer()
BEGIN
	DECLARE batch_start DATETIME;
    DECLARE batch_end	DATETIME;
    DECLARE step_start  DATETIME;
    DECLARE step_end	DATETIME;
    
    /*
		Error Handler
    */
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
			@error_msg = MESSAGE_TEXT;
            
		SELECT 'ERROR DURING SILVER LOAD' AS Status,
			@error_msg = Error_message;
	END;
    
    SET batch_start = NOW();
    
    SELECT "Starting Silver layer load" AS Message;
    
    /*
    ============================================================
    CRM TABLES
    ============================================================
    */

    /*
    ------------------------------------------------------------
    1. CRM CUSTOMER INFO
    ------------------------------------------------------------
    */
    
    SET step_start = NOW();
    TRUNCATE TABLE silver_crm_cust_info;
    INSERT INTO silver_crm_cust_info
			(cst_id,
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		) 
            SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END cst_marital_status,
            CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END cst_gndr,
            cst_create_date
            FROM(
            SELECT *,
            ROW_NUMBER() OVER (
				PARTITION BY cst_id 
				ORDER BY cst_create_date DESC
            ) AS flag_last
			FROM bronze_crm_cust_info
			WHERE cst_id <> 0
            ) AS t
			WHERE flag_last =1;
		
		SET step_end = NOW();
        SELECT 'silver_crm_cust_info Loaded' AS Table_Name,
           TIMESTAMPDIFF(SECOND, step_start, step_end) AS Duration_Seconds;

	/*
    ------------------------------------------------------------
    2. CRM PRODUCT INFO
    ------------------------------------------------------------
    */
    SET step_start = NOW();
    TRUNCATE TABLE silver_crm_prd_info;
    INSERT INTO silver_crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract Category ID
    SUBSTRING(prd_key, 7) AS prd_key,					   -- Extract Product ID 
    prd_nm,
    IFNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    DATE(prd_start_dt) AS prd_start_dt,
    DATE_SUB(
        LEAD(DATE(prd_start_dt)) OVER (
            PARTITION BY SUBSTRING(prd_key, 7)
            ORDER BY prd_start_dt
        ),
        INTERVAL 1 DAY
    ) AS prd_end_dt
	FROM bronze_crm_prd_info;
	SET step_end = NOW();

    SELECT 'silver_crm_prd_info Loaded' AS Table_Name,
           TIMESTAMPDIFF(SECOND, step_start, step_end) AS Duration_Seconds;


    /*
    ------------------------------------------------------------
    3. CRM SALES DETAILS
    ------------------------------------------------------------
    */
    SET step_start = NOW();
    TRUNCATE TABLE silver_crm_sales_details;
    INSERT INTO silver_crm_sales_details(
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
        SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) !=8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) !=8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) !=8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
		END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales , 
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_sales / sls_quantity
			ELSE sls_price
		END AS sls_price 
	FROM bronze_crm_sales_details;
    
    SET step_end = NOW();

    SELECT 'silver_crm_sales_details Loaded' AS Table_Name,
           TIMESTAMPDIFF(SECOND, step_start, step_end) AS Duration_Seconds;


    /*
    ============================================================
    ERP TABLES
    ============================================================
    */

    /*
    ------------------------------------------------------------
    4. ERP CUSTOMER
    ------------------------------------------------------------
    */
    SET step_start = NOW();
    TRUNCATE TABLE silver_erp_cust_az12;
    INSERT INTO silver_erp_cust_az12(
	cid,
    bdate,
    gen
    )
    SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
        ELSE cid
    END AS cid,
    CASE 
        WHEN bdate > CURRENT_TIMESTAMP THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(REPLACE(TRIM(gen), '\r', '')) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(REPLACE(TRIM(gen), '\r', '')) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
	FROM bronze_erp_cust_az12;
     SET step_end = NOW();

    SELECT 'silver_erp_cust_az12 Loaded' AS Table_Name,
           TIMESTAMPDIFF(SECOND, step_start, step_end) AS Duration_Seconds;


    /*
    ------------------------------------------------------------
    5. ERP LOCATION
    ------------------------------------------------------------
    */
    SET step_start = NOW();
    TRUNCATE TABLE silver_erp_loc_a101;
    INSERT INTO silver_erp_loc_a101(cid,cntry)
    SELECT 
		REPLACE(cid,'-' , '') AS cid,
		CASE WHEN  TRIM(REPLACE(cntry, '\r', '')) = 'DE' THEN 'Germany'
			WHEN  TRIM(REPLACE(cntry, '\r', '')) IN ('US' , 'USA') THEN 'United States'
			WHEN  TRIM(REPLACE(cntry, '\r', '')) = ''  OR cntry IS NULL THEN 'n/a'
			ELSE  TRIM(REPLACE(cntry, '\r', ''))
		END AS cntry
	FROM bronze_erp_loc_a101;
    SET step_end = NOW();

    SELECT 'silver_erp_loc_a101 Loaded' AS Table_Name,
           TIMESTAMPDIFF(SECOND, step_start, step_end) AS Duration_Seconds;


    /*
    ------------------------------------------------------------
    6. ERP PRODUCT CATEGORY
    ------------------------------------------------------------
    */
    SET step_start = NOW();
    TRUNCATE TABLE silver_erp_px_cat_g1v2;
    INSERT INTO silver_erp_px_cat_g1v2(id,cat,subcat,maintenance)
	SELECT
		id,
		cat,
		subcat,
		TRIM(REPLACE(maintenance, '\r', '')) AS maintenance
	FROM bronze_erp_px_cat_g1v2;

	SET step_end = NOW();
    SELECT 'silver_erp_px_cat_g1v2 loaded',
           TIMESTAMPDIFF(SECOND, step_start, step_end);

    SET batch_end = NOW();

    SELECT '=========================================' AS msg;
    SELECT 'Silver Layer Load Completed' AS msg;
    SELECT TIMESTAMPDIFF(SECOND, batch_start, batch_end) AS total_duration_seconds;
    SELECT '=========================================' AS msg;


END $$

DELIMITER ;

CALL load_silver_layer();
