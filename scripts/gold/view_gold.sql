
/*
==================================================
Creating Gold Dimension gold.dim_customer 
==================================================
*/
IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
    DROP VIEW gold.dim_customer;
GO

CREATE VIEW gold.dim_customer AS
SELECT  
    ROW_NUMBER() OVER(order by cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS marital_status,
    CASE
        WHEN ci.cst_gndr !='Unknown' THEN ci.cst_gndr
        ELSE COALESCE(ci.cst_gndr, 'Unknown')
    END AS gender,
    el.cntry AS country,
    ea.bdate AS birth_date,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ea
ON ci.cst_key = ea.cid
LEFT JOIN silver.erp_loc_a101 el 
ON ci.cst_key = el.cid;
GO

/*
==================================================
Creating Gold Dimension gold.dim_product 
==================================================
*/

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO

CREATE VIEW gold.dim_product AS
SELECT  
    ROW_NUMBER() OVER(order by pi.prd_start_dt) AS product_key,
    pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    pi.prd_nm AS product_name,
    pi.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance AS maintenance,
    pi.prd_cost AS product_cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS product_start_date
    FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pc 
ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL; --- Filter out Historical Products ---
GO

/*
==================================================
Creating Gold Dimension gold.fact_sales
==================================================
*/

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num AS sales_order_number,
    dp.product_key AS product_key,
    dc.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS ship_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product dp
ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customer dc
ON sd.sls_cust_id = dc.customer_id
GO


SELECT * FROM gold.fact_sales;
SELECT * FROM gold.dim_customer;
SELECT * FROM gold.dim_product;

-- VALIDATION QUERIES --
SELECT * FROM gold.fact_sales 
LEFT JOIN gold.dim_customer
ON fact_sales.customer_key = dim_customer.customer_key
LEFT JOIN gold.dim_product
ON fact_sales.product_key = dim_product.product_key
WHERE dim_customer.customer_key IS NULL 
AND dim_product.product_key IS NULL;
