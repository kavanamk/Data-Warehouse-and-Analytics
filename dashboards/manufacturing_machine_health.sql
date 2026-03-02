-- ============================================================
-- DATA PLATFORM
-- dashboards/08_manufacturing_machine_health.sql
-- Snowsight Dashboard: Manufacturing & Machine Health
-- Story: "Our machines are running — but some are silently failing"
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE APTIV_DB;

-- ============================================================
-- ACT 1: THE BIG PICTURE
-- ============================================================

-- TILE 1 (Scorecard): Fleet Health Score
SELECT ROUND(100 - AVG(failure_rate_pct), 1) AS fleet_health_score
FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY;

-- TILE 2 (Scorecard): Critical Machines (high wear + failed)
SELECT COUNT(DISTINCT machine_id) AS critical_machines
FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
WHERE tool_wear_category = 'High'
AND machine_status = 'Failed';

-- TILE 3 (Scorecard): Normal Machines
SELECT COUNT(DISTINCT machine_id) AS normal_machines
FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
WHERE machine_status = 'Normal';

-- TILE 4 (Scorecard): Failed Machines
SELECT COUNT(DISTINCT machine_id) AS failed_machines
FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
WHERE machine_status = 'Failed';

-- ============================================================
-- ACT 2: WHERE IS IT HAPPENING?
-- ============================================================

-- TILE 5 (Heatmap): Failure Rate by Machine Type x Tool Wear Level
-- Snowsight: x = tool_wear_category, y = machine_type, color = avg_failure_rate_pct
-- darker red = higher failure risk
SELECT
    machine_type                                    AS "Machine Type",
    tool_wear_category                              AS "Tool Wear Level",
    ROUND(AVG(failure_rate_pct), 2)                 AS "Avg Failure Rate (%)",
    COUNT(DISTINCT machine_id)                      AS "Machine Count",
    SUM(total_failures)                             AS "Total Failures"
FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
GROUP BY machine_type, tool_wear_category
ORDER BY
    machine_type,
    CASE tool_wear_category
        WHEN 'Low'    THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High'   THEN 3
    END;

-- TILE 6 (Bar Chart): Failure Count by Machine Type (ranked)
-- Snowsight: x = total_failures, y = machine_type, color = failure_rate_pct (gradient red)
SELECT
    machine_type                                    AS "Machine Type",
    SUM(total_failures)                             AS "Total Failures",
    SUM(total_readings)                             AS "Total Readings",
    ROUND(AVG(failure_rate_pct), 2)                 AS "Failure Rate (%)",
    ROUND(AVG(avg_torque_nm), 2)                    AS "Avg Torque (Nm)"
FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
GROUP BY machine_type
ORDER BY SUM(total_failures) DESC;

-- ============================================================
-- ACT 3: WHAT IS CAUSING IT?
-- ============================================================

-- TILE 7 (Line Chart): Tool Wear vs Failure Rate Trend
-- Snowsight: x = wear_bucket, y = avg_failure_rate_pct
-- story: as wear increases, failure rate climbs
SELECT
    FLOOR(avg_tool_wear_min / 50) * 50              AS wear_bucket,
    COUNT(DISTINCT machine_id)                      AS machine_count,
    ROUND(AVG(failure_rate_pct), 2)                 AS avg_failure_rate_pct,
    ROUND(AVG(avg_torque_nm), 2)                    AS avg_torque_nm,
    ROUND(AVG(avg_rpm), 0)                          AS avg_rpm
FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
GROUP BY wear_bucket
ORDER BY wear_bucket;

-- TILE 8 (Bar Chart): Failure Type Breakdown
-- Snowsight: x = failure_type, y = count, each bar different color
SELECT 'Tool Wear'        AS "Failure Type", SUM(tool_wear_failures)    AS "Count", 1 AS sort_order FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
UNION ALL
SELECT 'Heat Dissipation',                   SUM(heat_failures),        2 FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
UNION ALL
SELECT 'Power Failure',                      SUM(power_failures),       3 FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
UNION ALL
SELECT 'Overstrain',                         SUM(overstrain_failures),  4 FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
UNION ALL
SELECT 'Random',                             SUM(random_failures),      5 FROM APTIV_DB.GOLD.FACT_PRODUCTION_QUALITY
ORDER BY sort_order;

