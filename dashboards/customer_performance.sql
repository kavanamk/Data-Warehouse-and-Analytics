-- ============================================================
-- APTIV DATA PLATFORM
-- dashboards/07_customer_performance.sql
-- Snowsight Dashboard: Customer Performance
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE APTIV_DB;

-- ----------------------------
-- TILE 1 (Scorecard): Total Customers
-- ----------------------------
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM APTIV_DB.GOLD.FACT_CUSTOMER_PERFORMANCE;

-- ----------------------------
-- TILE 2 (Scorecard): Total Revenue
-- ----------------------------
SELECT ROUND(SUM(total_revenue_usd), 2) AS total_revenue_usd
FROM APTIV_DB.GOLD.FACT_CUSTOMER_PERFORMANCE;

-- ----------------------------
-- TILE 3 (Scorecard): Avg Order Value
-- ----------------------------
SELECT ROUND(AVG(avg_order_value), 2) AS avg_order_value_usd
FROM APTIV_DB.GOLD.FACT_CUSTOMER_PERFORMANCE;

-- ----------------------------
-- TILE 4 (Bar Chart): Top 10 Customers by Revenue
-- Snowsight: x = customer_name, y = total_revenue_usd, color = segment
-- ----------------------------
SELECT
    customer_name,
    segment,
    country,
    total_orders,
    total_revenue_usd,
    total_profit_usd,
    profit_margin_pct,
    avg_order_value
FROM APTIV_DB.GOLD.FACT_CUSTOMER_PERFORMANCE
ORDER BY total_revenue_usd DESC
LIMIT 10;

-- ----------------------------
-- TILE 5 (Bar Chart): Revenue by Customer Segment
-- Snowsight: x = segment, y = total_revenue, color = segment
-- ----------------------------
SELECT
    segment,
    COUNT(DISTINCT customer_id)                     AS total_customers,
    ROUND(SUM(total_revenue_usd), 2)                AS total_revenue_usd,
    ROUND(AVG(profit_margin_pct), 2)                AS avg_profit_margin_pct,
    ROUND(AVG(avg_order_value), 2)                  AS avg_order_value_usd,
    ROUND(SUM(total_revenue_usd) /
        SUM(SUM(total_revenue_usd)) OVER() * 100, 2) AS revenue_share_pct
FROM APTIV_DB.GOLD.FACT_CUSTOMER_PERFORMANCE
GROUP BY segment
ORDER BY total_revenue_usd DESC;

-- ----------------------------
-- TILE 6 (Table): Customer Leaderboard
-- Snowsight: set chart type to Table
-- ----------------------------
SELECT
    customer_name                                   AS "Customer",
    segment                                         AS "Segment",
    country                                         AS "Country",
    total_orders                                    AS "Orders",
    total_units                                     AS "Units",
    total_revenue_usd                               AS "Revenue ($)",
    total_profit_usd                                AS "Profit ($)",
    profit_margin_pct                               AS "Margin (%)",
    avg_order_value                                 AS "Avg Order ($)",
    late_deliveries                                 AS "Late Deliveries",
    customer_lifespan_days                          AS "Lifespan (days)"
FROM APTIV_DB.GOLD.FACT_CUSTOMER_PERFORMANCE
ORDER BY total_revenue_usd DESC
LIMIT 50;
