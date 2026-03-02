-- ============================================================
-- APTIV DATA PLATFORM
-- gold/04_dimensions.sql: business-ready dimension tables
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE SCHEMA APTIV_DB.GOLD;

CREATE OR REPLACE TABLE APTIV_DB.GOLD.DIM_DATE AS
SELECT DISTINCT
    TO_CHAR(order_date, 'YYYYMMDD')::NUMBER         AS date_id,
    order_date                                       AS full_date,
    YEAR(order_date)                                 AS year,
    QUARTER(order_date)                              AS quarter_number,
    'Q' || QUARTER(order_date)                       AS quarter,
    MONTH(order_date)                                AS month_number,
    MONTHNAME(order_date)                            AS month_name,
    WEEKOFYEAR(order_date)                           AS week_number,
    DAYOFWEEK(order_date)                            AS day_of_week,
    DAYNAME(order_date)                              AS day_name,
    CASE WHEN DAYOFWEEK(order_date) IN (0,6)
         THEN TRUE ELSE FALSE END                    AS is_weekend
FROM APTIV_DB.SILVER.STG_ORDERS
WHERE order_date IS NOT NULL
ORDER BY full_date;

CREATE OR REPLACE TABLE APTIV_DB.GOLD.DIM_CUSTOMER AS
SELECT
    customer_id,
    customer_name,
    segment,
    city,
    state,
    country,
    zipcode,
    CASE segment
        WHEN 'Consumer'    THEN 'Consumer'
        WHEN 'Corporate'   THEN 'Corporate'
        WHEN 'Home Office' THEN 'Home Office'
        ELSE segment
    END                                              AS segment_label
FROM APTIV_DB.SILVER.STG_CUSTOMERS;

CREATE OR REPLACE TABLE APTIV_DB.GOLD.DIM_PRODUCT AS
SELECT
    product_id,
    product_name,
    category,
    department,
    unit_price,
    product_status,
    CASE
        WHEN unit_price < 50   THEN 'Budget'
        WHEN unit_price < 200  THEN 'Mid-Range'
        WHEN unit_price < 500  THEN 'Premium'
        ELSE 'Enterprise'
    END                                              AS price_tier
FROM APTIV_DB.SILVER.STG_PRODUCTS;

-- verify
SELECT 'DIM_DATE'     AS table_name, COUNT(*) AS row_count FROM APTIV_DB.GOLD.DIM_DATE
UNION ALL
SELECT 'DIM_CUSTOMER', COUNT(*) FROM APTIV_DB.GOLD.DIM_CUSTOMER
UNION ALL
SELECT 'DIM_PRODUCT',  COUNT(*) FROM APTIV_DB.GOLD.DIM_PRODUCT;
