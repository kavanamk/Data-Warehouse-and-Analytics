-- ============================================================
-- DATA PLATFORM
-- silver/03_staging.sql: cleaned and typed staging tables
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE SCHEMA APTIV_DB.SILVER;

-- ----------------------------
-- SUPPLY CHAIN STAGING
-- ----------------------------

CREATE OR REPLACE TABLE APTIV_DB.SILVER.STG_ORDERS AS
SELECT
    order_id,
    order_customer_id                               AS customer_id,
    TRY_TO_DATE(order_date, 'MM/DD/YYYY HH24:MI')  AS order_date,
    order_status,
    order_region                                    AS region,
    order_country                                   AS country,
    order_city                                      AS city,
    market,
    shipping_mode,
    delivery_status,
    late_delivery_risk,
    days_for_shipping_real                          AS actual_shipping_days,
    days_for_shipment_scheduled                     AS scheduled_shipping_days,
    (days_for_shipping_real - days_for_shipment_scheduled) AS shipping_delay_days,
    product_name,
    category_name                                   AS category,
    department_name                                 AS department,
    order_item_quantity                             AS quantity,
    product_price                                   AS unit_price,
    sales                                           AS sales_usd,
    order_item_discount                             AS discount_usd,
    order_item_discount_rate                        AS discount_rate,
    order_profit_per_order                          AS profit_usd,
    benefit_per_order                               AS benefit_usd,
    order_item_profit_ratio                         AS profit_ratio,
    customer_segment,
    customer_country,
    customer_city,
    TRY_TO_DATE(shipping_date, 'MM/DD/YYYY HH24:MI') AS shipping_date
FROM APTIV_DB.BRONZE.RAW_SUPPLY_CHAIN
WHERE order_id IS NOT NULL;

CREATE OR REPLACE TABLE APTIV_DB.SILVER.STG_CUSTOMERS AS
SELECT DISTINCT
    customer_id,
    customer_fname || ' ' || customer_lname         AS customer_name,
    customer_segment                                AS segment,
    customer_city                                   AS city,
    customer_state                                  AS state,
    customer_country                                AS country,
    customer_zipcode                                AS zipcode
FROM APTIV_DB.BRONZE.RAW_SUPPLY_CHAIN
WHERE customer_id IS NOT NULL;

CREATE OR REPLACE TABLE APTIV_DB.SILVER.STG_PRODUCTS AS
SELECT DISTINCT
    product_card_id                                 AS product_id,
    product_name,
    category_name                                   AS category,
    department_name                                 AS department,
    product_price                                   AS unit_price,
    CASE
        WHEN product_status = 0 THEN 'Active'
        ELSE 'Inactive'
    END                                             AS product_status
FROM APTIV_DB.BRONZE.RAW_SUPPLY_CHAIN
WHERE product_card_id IS NOT NULL;

-- ----------------------------
-- MAINTENANCE STAGING
-- kelvin to celsius conversion + derived columns
-- ----------------------------

CREATE OR REPLACE TABLE APTIV_DB.SILVER.STG_MACHINE_EVENTS AS
SELECT
    udi                                             AS machine_id,
    product_id,
    type                                            AS machine_type,
    air_temperature_k                               AS air_temp_kelvin,
    ROUND(air_temperature_k - 273.15, 2)            AS air_temp_celsius,
    process_temperature_k                           AS process_temp_kelvin,
    ROUND(process_temperature_k - 273.15, 2)        AS process_temp_celsius,
    rotational_speed_rpm,
    torque_nm,
    tool_wear_min                                   AS tool_wear_minutes,
    machine_failure                                 AS machine_failure_flag,
    twf                                             AS tool_wear_failure,
    hdf                                             AS heat_dissipation_failure,
    pwf                                             AS power_failure,
    osf                                             AS overstrain_failure,
    rnf                                             AS random_failure,
    CASE
        WHEN machine_failure = 1 THEN 'Failed'
        ELSE 'Normal'
    END                                             AS machine_status,
    CASE
        WHEN tool_wear_min < 100  THEN 'Low'
        WHEN tool_wear_min <= 200 THEN 'Medium'
        ELSE 'High'
    END                                             AS tool_wear_category
FROM APTIV_DB.BRONZE.RAW_MAINTENANCE
WHERE udi IS NOT NULL;

-- verify
SELECT 'STG_ORDERS'          AS table_name, COUNT(*) AS row_count FROM APTIV_DB.SILVER.STG_ORDERS
UNION ALL
SELECT 'STG_CUSTOMERS',      COUNT(*) FROM APTIV_DB.SILVER.STG_CUSTOMERS
UNION ALL
SELECT 'STG_PRODUCTS',       COUNT(*) FROM APTIV_DB.SILVER.STG_PRODUCTS
UNION ALL
SELECT 'STG_MACHINE_EVENTS', COUNT(*) FROM APTIV_DB.SILVER.STG_MACHINE_EVENTS;
