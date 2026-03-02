-- ============================================================
-- APTIV DATA PLATFORM
-- dashboards/06_executive_sales_summary.sql
-- Tableau Dashboard: Executive Sales Summary
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE APTIV_DB;

-- ----------------------------
-- KPI 1: Total Revenue
-- ----------------------------
SELECT ROUND(SUM(total_revenue_usd), 2) AS total_revenue
FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY;

-- ----------------------------
-- KPI 2: Total Profit
-- ----------------------------
SELECT ROUND(SUM(total_profit_usd), 2) AS total_profit
FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY;

-- ----------------------------
-- KPI 3: Total Orders
-- ----------------------------
SELECT SUM(total_orders) AS total_orders
FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY;

-- ----------------------------
-- KPI 4: Overall Profit Margin
-- ----------------------------
SELECT ROUND(SUM(total_profit_usd) / NULLIF(SUM(total_revenue_usd), 0) * 100, 2) AS profit_margin_pct
FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY;

-- ----------------------------
-- CHART 1: Revenue & Profit Trend (Line Chart)
-- Tableau: full_date on columns, revenue + profit on dual axis rows
-- ----------------------------
SELECT
    year,
    month,
    month_name,
    quarter,
    SUM(total_revenue_usd)                          AS total_revenue_usd,
    SUM(total_profit_usd)                           AS total_profit_usd,
    ROUND(SUM(total_profit_usd) / NULLIF(SUM(total_revenue_usd), 0) * 100, 2) AS profit_margin_pct
FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY
GROUP BY year, month, month_name, quarter
ORDER BY year, month;

-- ----------------------------
-- CHART 2: Revenue by Region (Bar Chart)
-- Tableau: region on columns, revenue on rows, sorted descending
-- ----------------------------
SELECT
    region,
    SUM(total_orders)                               AS total_orders,
    SUM(total_units_sold)                           AS total_units_sold,
    ROUND(SUM(total_revenue_usd), 2)                AS total_revenue_usd,
    ROUND(SUM(total_profit_usd), 2)                 AS total_profit_usd,
    ROUND(AVG(profit_margin_pct), 2)                AS avg_profit_margin_pct
FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY
GROUP BY region
ORDER BY total_revenue_usd DESC;

-- ----------------------------
-- CHART 3: Revenue by Customer Segment (Donut)
-- Tableau: segment on color, revenue on angle
-- ----------------------------
SELECT
    customer_segment,
    SUM(total_orders)                               AS total_orders,
    ROUND(SUM(total_revenue_usd), 2)                AS total_revenue_usd,
    ROUND(SUM(total_profit_usd), 2)                 AS total_profit_usd,
    ROUND(SUM(total_revenue_usd) /
        SUM(SUM(total_revenue_usd)) OVER() * 100, 2) AS revenue_share_pct
FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY
GROUP BY customer_segment
ORDER BY total_revenue_usd DESC;

-- ----------------------------
-- CHART 4: Top 10 Categories by Profit (Horizontal Bar)
-- Tableau: category on rows, profit on columns, color by profit status
-- ----------------------------
SELECT
    category,
    department,
    SUM(total_orders)                               AS total_orders,
    ROUND(SUM(total_revenue_usd), 2)                AS total_revenue_usd,
    ROUND(SUM(total_profit_usd), 2)                 AS total_profit_usd,
    ROUND(AVG(profit_margin_pct), 2)                AS avg_profit_margin_pct,
    CASE
        WHEN SUM(total_profit_usd) > 0 THEN 'Positive'
        ELSE 'Negative'
    END                                             AS profit_status
FROM APTIV_DB.GOLD.FACT_SALES_MONTHLY
GROUP BY category, department
ORDER BY total_profit_usd DESC
LIMIT 10;
