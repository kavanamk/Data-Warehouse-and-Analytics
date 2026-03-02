-- ============================================================
-- APTIV DATA PLATFORM
-- gold/05_facts.sql: aggregated business-ready fact tables
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE SCHEMA APTIV_DB.GOLD;

-- monthly sales by region, segment, category
CREATE OR REPLACE TABLE APTIV_DB.GOLD.FACT_SALES_MONTHLY AS
SELECT
    YEAR(order_date)                                 AS year,
    MONTH(order_date)                                AS month,
    MONTHNAME(order_date)                            AS month_name,
    'Q' || QUARTER(order_date)                       AS quarter,
    region,
    market,
    customer_segment,
    category,
    department,
    COUNT(DISTINCT order_id)                         AS total_orders,
    SUM(quantity)                                    AS total_units_sold,
    ROUND(SUM(sales_usd), 2)                         AS total_revenue_usd,
    ROUND(SUM(profit_usd), 2)                        AS total_profit_usd,
    ROUND(SUM(discount_usd), 2)                      AS total_discount_usd,
    ROUND(AVG(discount_rate), 4)                     AS avg_discount_rate,
    ROUND(SUM(profit_usd) / NULLIF(SUM(sales_usd), 0) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(sales_usd), 2)                         AS avg_order_value_usd
FROM APTIV_DB.SILVER.STG_ORDERS
WHERE order_date IS NOT NULL
GROUP BY 1,2,3,4,5,6,7,8,9;

-- shipping performance and late delivery tracking
CREATE OR REPLACE TABLE APTIV_DB.GOLD.FACT_SUPPLY_CHAIN AS
SELECT
    YEAR(order_date)                                 AS year,
    MONTH(order_date)                                AS month,
    MONTHNAME(order_date)                            AS month_name,
    'Q' || QUARTER(order_date)                       AS quarter,
    region,
    market,
    shipping_mode,
    delivery_status,
    COUNT(DISTINCT order_id)                         AS total_shipments,
    SUM(late_delivery_risk)                          AS late_delivery_count,
    ROUND(SUM(late_delivery_risk) / NULLIF(COUNT(*), 0) * 100, 2) AS late_delivery_rate_pct,
    ROUND(AVG(actual_shipping_days), 2)              AS avg_actual_shipping_days,
    ROUND(AVG(scheduled_shipping_days), 2)           AS avg_scheduled_shipping_days,
    ROUND(AVG(shipping_delay_days), 2)               AS avg_delay_days,
    COUNT(CASE WHEN shipping_delay_days > 0  THEN 1 END) AS delayed_orders,
    COUNT(CASE WHEN shipping_delay_days <= 0 THEN 1 END) AS on_time_orders,
    ROUND(COUNT(CASE WHEN shipping_delay_days <= 0 THEN 1 END) /
          NULLIF(COUNT(*), 0) * 100, 2)              AS on_time_delivery_pct
FROM APTIV_DB.SILVER.STG_ORDERS
WHERE order_date IS NOT NULL
GROUP BY 1,2,3,4,5,6,7,8;

-- machine health, failure rates, sensor averages
CREATE OR REPLACE TABLE APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY AS
SELECT
    machine_id,
    machine_type,
    machine_status,
    tool_wear_category,
    COUNT(*)                                         AS total_readings,
    SUM(machine_failure_flag)                        AS total_failures,
    ROUND(SUM(machine_failure_flag) / NULLIF(COUNT(*), 0) * 100, 2) AS failure_rate_pct,
    ROUND(AVG(air_temp_celsius), 2)                  AS avg_air_temp_c,
    ROUND(AVG(process_temp_celsius), 2)              AS avg_process_temp_c,
    ROUND(AVG(rotational_speed_rpm), 2)              AS avg_rpm,
    ROUND(AVG(torque_nm), 2)                         AS avg_torque_nm,
    ROUND(AVG(tool_wear_minutes), 2)                 AS avg_tool_wear_min,
    MAX(tool_wear_minutes)                           AS max_tool_wear_min,
    SUM(tool_wear_failure)                           AS tool_wear_failures,
    SUM(heat_dissipation_failure)                    AS heat_failures,
    SUM(power_failure)                               AS power_failures,
    SUM(overstrain_failure)                          AS overstrain_failures,
    SUM(random_failure)                              AS random_failures
FROM APTIV_DB.SILVER.STG_MACHINE_EVENTS
GROUP BY 1,2,3,4;

-- customer lifetime value and order behavior
CREATE OR REPLACE TABLE APTIV_DB.GOLD.FACT_CUSTOMER_PERFORMANCE AS
SELECT
    o.customer_id,
    c.customer_name,
    c.segment,
    c.country,
    COUNT(DISTINCT o.order_id)                       AS total_orders,
    SUM(o.quantity)                                  AS total_units,
    ROUND(SUM(o.sales_usd), 2)                       AS total_revenue_usd,
    ROUND(SUM(o.profit_usd), 2)                      AS total_profit_usd,
    ROUND(AVG(o.sales_usd), 2)                       AS avg_order_value,
    ROUND(SUM(o.profit_usd) / NULLIF(SUM(o.sales_usd), 0) * 100, 2) AS profit_margin_pct,
    SUM(o.late_delivery_risk)                        AS late_deliveries,
    MIN(o.order_date)                                AS first_order_date,
    MAX(o.order_date)                                AS last_order_date,
    DATEDIFF('day', MIN(o.order_date), MAX(o.order_date)) AS customer_lifespan_days
FROM APTIV_DB.SILVER.STG_ORDERS o
LEFT JOIN APTIV_DB.SILVER.STG_CUSTOMERS c ON o.customer_id = c.customer_id
GROUP BY 1,2,3,4;

-- verify all fact tables
SELECT 'FACT_SALES_MONTHLY'        AS table_name, COUNT(*) AS row_count FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY
UNION ALL
SELECT 'FACT_SUPPLY_CHAIN',        COUNT(*) FROM APTIV_DB.GOLD.FACT_SUPPLY_CHAIN
UNION ALL
SELECT 'FACT_PRODUCTION_QUALITY',  COUNT(*) FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
UNION ALL
SELECT 'FACT_CUSTOMER_PERFORMANCE',COUNT(*) FROM APTIV_DB.GOLD.FACT_CUSTOMER_PERFORMANCE;
