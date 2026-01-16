
/*
====================================================================
 ANALYZING DATA IN BRONZE.CRM_CUST_INFO
====================================================================
*/

---Check For Nulls and Duplicates in Primary key and Clean Data---
---Ecpectation: No Nulls and Duplicates in Primary key columns---

    SELECT cst_id,COUNT(*) FROM bronze.crm_cust_info
    GROUP BY cst_id
    HAVING COUNT(*) > 1 OR cst_id IS NULL;

    ---CHECK FOR UNWANTED SPACES --- 

    SELECT cst_firstname, cst_lastname, cst_marital_status, cst_gndr 
    FROM bronze.crm_cust_info
    WHERE cst_firstname != TRIM(cst_firstname)
    OR cst_lastname != TRIM(cst_lastname)

---DATA STANDARDIZATION & CONSISTENCY---

    SELECT DISTINCT cst_gndr
    FROM bronze.crm_cust_info;

    SELECT DISTINCT cst_marital_status
    FROM bronze.crm_cust_info;

--- VALIDATING CLEANED DATA IN SILVER LAYER ---
    ---Check For Nulls and Duplicates in Primary key and Clean Data---
    ---Ecpectation: No Nulls and Duplicates in Primary key columns---

    SELECT cst_id,COUNT(*) FROM silver.crm_cust_info
    GROUP BY cst_id
    HAVING COUNT(*) > 1 OR cst_id IS NULL;

    ---CHECK FOR UNWANTED SPACES --- 

    SELECT cst_firstname, cst_lastname, cst_marital_status, cst_gndr 
    FROM silver.crm_cust_info
    WHERE cst_firstname != TRIM(cst_firstname)
    OR cst_lastname != TRIM(cst_lastname)

    ---DATA STANDARDIZATION & CONSISTENCY---

    SELECT DISTINCT cst_gndr
    FROM silver.crm_cust_info;

    SELECT DISTINCT cst_marital_status
    FROM silver.crm_cust_info;

/*====================================================================
 ANALYZING DATA IN BRONZE.CRM_PRD_INFO
======================================================================
*/

---Check For Nulls and Duplicates in Primary key and Clean Data---
---Ecpectation: No Nulls and Duplicates in Primary key columns---

    SELECT prd_id,COUNT(*) FROM bronze.crm_prd_info
    GROUP BY prd_id
    HAVING COUNT(*) > 1 OR prd_id IS NULL;

---CHECK FOR UNWANTED SPACES ---

    SELECT prd_nm
    FROM bronze.crm_prd_info
    WHERE prd_nm != TRIM(prd_nm)

---CHECK FOR INVALID PRD_COST VALUES ---
    SELECT prd_cost FROM bronze.crm_prd_info
    WHERE prd_cost <=0 OR prd_cost IS NULL

---ANALYZING RELATION BETWWEN START DATE AND END DATE---

    SELECT * FROM bronze.crm_prd_info 
    WHERE prd_id IN (SELECT prd_id FROM bronze.crm_prd_info GROUP BY prd_id) ORDER BY prd_id;

--- VALIDATING CLEANED DATA IN SILVER LAYER ---
    ---Check For Nulls and Duplicates in Primary key and Clean Data---
    ---Ecpectation: No Nulls and Duplicates in Primary key columns---

    SELECT prd_id,COUNT(*) FROM silver.crm_prd_info
    GROUP BY prd_id
    HAVING COUNT(*) > 1 OR prd_id IS NULL;

    ---CHECK FOR UNWANTED SPACES ---

    SELECT prd_nm
    FROM silver.crm_prd_info
    WHERE prd_nm != TRIM(prd_nm)

    ---CHECK FOR INVALID PRD_COST VALUES ---
    SELECT prd_cost FROM silver.crm_prd_info
    WHERE prd_cost <=0 OR prd_cost IS NULL

    SELECT prd_line FROM silver.crm_prd_info
    GROUP BY prd_line;

    ---ANALYZING RELATION BETWWEN START DATE AND END DATE---

    SELECT * FROM silver.crm_prd_info 
    WHERE prd_id IN (SELECT prd_id FROM silver.crm_prd_info WHERE prd_end_dt < prd_start_dt GROUP BY prd_id) ORDER BY prd_id;

/*====================================================================
 ANALYZING DATA IN BRONZE.CRM_SALES_DETAILS 
======================================================================
*/

---Check For Nulls and Duplicates in Primary key and Clean Data in crm_prd_info ---
    SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt, 
    sls_sales,
    sls_quantity,
    sls_price
    FROM bronze.crm_sales_details
    WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

---Check For Nulls and Duplicates in Primary key and Clean Data in crm_cust_info ---
    SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt, 
    sls_sales,
    sls_quantity,
    sls_price
    FROM bronze.crm_sales_details
    WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

---CHECK FOR INVALID DATE VALUES ---

    SELECT NULLIF(sls_order_dt, 0) FROM bronze.crm_sales_details 
    WHERE sls_order_dt <=0 OR LEN(sls_order_dt) !=8;

    SELECT sls_ship_dt FROM bronze.crm_sales_details 
    WHERE sls_ship_dt <=0 OR LEN(sls_ship_dt) !=8 AND sls_ship_dt < sls_order_dt;

    SELECT sls_due_dt FROM bronze.crm_sales_details 
    WHERE sls_due_dt <=0 OR LEN(sls_due_dt) !=8 AND sls_due_dt < sls_order_dt;

---CHECK FOR INVALID SALES, QUANTITY AND PRICE VALUES ---

    SELECT sls_sales,sls_quantity,sls_price FROM bronze.crm_sales_details 
    WHERE sls_sales <0 OR sls_quantity <0 OR sls_price <0
    OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
    OR sls_sales!= sls_quantity * sls_price;

---RULES TO FOLLOW TO CORRECT DATA---
---1. sls_sales is NULL, negative or 0 then calculate using sls_quantity and        sls_price---
---2. sls_price is NULL or 0 then calculate using sls_sales and sls_quantity
---3. sls_price is negative then take absolute value---

--- VALIDATING CLEANED DATA IN SILVER LAYER ---
    ---Check For Nulls and Duplicates in Primary key and Clean Data in crm_prd_info ---
    SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt, 
    sls_sales,
    sls_quantity,
    sls_price
    FROM silver.crm_sales_details
    WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

    ---Check For Nulls and Duplicates in Primary key and Clean Data in crm_cust_info ---
    SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt, 
    sls_sales,
    sls_quantity,
    sls_price
    FROM silver.crm_sales_details
    WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

/*====================================================================
 ANALYZING DATA IN BRONZE.ERP_CUST_AZ12 
======================================================================
*/

SELECT * FROM bronze.erp_cust_az12
 --- CHECK LENGTH OF CST_KEY AND CID FIELDS ---
SELECT DISTINCT LEN(CST_KEY) FROM SILVER.crm_cust_info
SELECT * FROM SILVER.crm_cust_info WHERE LEN(CST_KEY) = 5
SELECT DISTINCT LEN(CID) FROM BRONZE.erp_cust_az12
SELECT * FROM BRONZE.erp_cust_az12 WHERE LEN(CID) = 13

---CHECKING BIRTH DATE FIELD FOR INVALID DATES---

SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

--- STANDADIZING GENDER FIELD VALUES ---

SELECT DISTINCT gen FROM bronze.erp_cust_az12;

---VALIDATING CLEANED DATA IN SILVER LAYER ---
SELECT * FROM silver.erp_cust_az12

/*====================================================================
 ANALYZING DATA IN BRONZE.ERP_LOC_A101 
======================================================================
*/

SELECT DISTINCT LEN(cid) FROM bronze.erp_loc_a101

SELECT DISTINCT cntry FROM bronze.erp_loc_a101

SELECT cst_key FROM silver.crm_cust_info

--- VALIDATING CLEANED DATA IN SILVER LAYER ---
SELECT * FROM silver.erp_loc_a101


/*====================================================================
 ANALYZING DATA IN BRONZE.ERP_PX_CAT_G1V2
======================================================================
*/

SELECT * FROM bronze.erp_px_cat_g1v2

---CHECK FOR UNWANTED SPACES ---
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat!= TRIM(cat)
OR subcat != TRIM(subcat)

SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2
SELECT DISTINCT TRIM(maintenance)maintenance FROM bronze.erp_px_cat_g1v2

SELECT prd_key FROM silver.crm_prd_info

--- VALIDATING CLEANED DATA IN SILVER LAYER ---
SELECT * FROM silver.erp_px_cat_g1v2
