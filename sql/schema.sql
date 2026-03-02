-- ============================================================
-- APTIV DATA PLATFORM
-- 01_setup.sql: environment, database, schema setup
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

CREATE DATABASE IF NOT EXISTS APTIV_DB;

-- medallion architecture: 3 layers
CREATE SCHEMA IF NOT EXISTS APTIV_DB.BRONZE;
CREATE SCHEMA IF NOT EXISTS APTIV_DB.SILVER;
CREATE SCHEMA IF NOT EXISTS APTIV_DB.GOLD;

SHOW SCHEMAS IN DATABASE APTIV_DB;
