-- ============================================================
-- DATA PLATFORM
-- bronze/02_raw_tables.sql: raw tables, stage, file format, load
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE SCHEMA APTIV_DB.BRONZE;

-- ----------------------------
-- RAW TABLES
-- ----------------------------

-- DataCo Smart Supply Chain (~180k rows)
CREATE OR REPLACE TABLE RAW_SUPPLY_CHAIN (
    type                            VARCHAR,
    days_for_shipping_real          NUMBER,
    days_for_shipment_scheduled     NUMBER,
    benefit_per_order               FLOAT,
    sales_per_customer              FLOAT,
    delivery_status                 VARCHAR,
    late_delivery_risk              NUMBER,
    category_id                     NUMBER,
    category_name                   VARCHAR,
    customer_city                   VARCHAR,
    customer_country                VARCHAR,
    customer_email                  VARCHAR,
    customer_fname                  VARCHAR,
    customer_id                     NUMBER,
    customer_lname                  VARCHAR,
    customer_password               VARCHAR,
    customer_segment                VARCHAR,
    customer_state                  VARCHAR,
    customer_street                 VARCHAR,
    customer_zipcode                VARCHAR,
    department_id                   NUMBER,
    department_name                 VARCHAR,
    latitude                        FLOAT,
    longitude                       FLOAT,
    market                          VARCHAR,
    order_city                      VARCHAR,
    order_country                   VARCHAR,
    order_customer_id               NUMBER,
    order_date                      VARCHAR,
    order_id                        NUMBER,
    order_item_cardprod_id          NUMBER,
    order_item_discount             FLOAT,
    order_item_discount_rate        FLOAT,
    order_item_id                   NUMBER,
    order_item_product_price        FLOAT,
    order_item_profit_ratio         FLOAT,
    order_item_quantity             NUMBER,
    sales                           FLOAT,
    order_item_total                FLOAT,
    order_profit_per_order          FLOAT,
    order_region                    VARCHAR,
    order_state                     VARCHAR,
    order_status                    VARCHAR,
    order_zipcode                   VARCHAR,
    product_card_id                 NUMBER,
    product_category_id             NUMBER,
    product_description             VARCHAR,
    product_image                   VARCHAR,
    product_name                    VARCHAR,
    product_price                   FLOAT,
    product_status                  NUMBER,
    shipping_date                   VARCHAR,
    shipping_mode                   VARCHAR
);

-- AI4I 2020 Predictive Maintenance (10k rows)
CREATE OR REPLACE TABLE RAW_MAINTENANCE (
    udi                             NUMBER,
    product_id                      VARCHAR,
    type                            VARCHAR,
    air_temperature_k               FLOAT,
    process_temperature_k           FLOAT,
    rotational_speed_rpm            NUMBER,
    torque_nm                       FLOAT,
    tool_wear_min                   NUMBER,
    machine_failure                 NUMBER,
    twf                             NUMBER,
    hdf                             NUMBER,
    pwf                             NUMBER,
    osf                             NUMBER,
    rnf                             NUMBER
);

-- ----------------------------
-- FILE FORMAT & STAGE
-- ----------------------------

CREATE OR REPLACE FILE FORMAT APTIV_DB.BRONZE.CSV_FORMAT
    TYPE                            = 'CSV'
    FIELD_DELIMITER                 = ','
    RECORD_DELIMITER                = '\n'
    SKIP_HEADER                     = 1
    FIELD_OPTIONALLY_ENCLOSED_BY    = '"'
    NULL_IF                         = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL             = TRUE;

CREATE OR REPLACE STAGE APTIV_DB.BRONZE.APTIV_STAGE
    FILE_FORMAT = APTIV_DB.BRONZE.CSV_FORMAT;

-- ----------------------------
-- LOAD DATA
-- run PUT commands via SnowSQL CLI before running COPY INTO:
--   PUT file:///path/to/DataCoSupplyChainDataset.csv @APTIV_DB.BRONZE.APTIV_STAGE AUTO_COMPRESS=TRUE;
--   PUT file:///path/to/ai4i2020.csv @APTIV_DB.BRONZE.APTIV_STAGE AUTO_COMPRESS=TRUE;
-- ----------------------------

COPY INTO APTIV_DB.BRONZE.RAW_SUPPLY_CHAIN
    FROM @APTIV_DB.BRONZE.APTIV_STAGE/DataCoSupplyChainDataset.csv.gz
    FILE_FORMAT = APTIV_DB.BRONZE.CSV_FORMAT
    ON_ERROR = 'CONTINUE';

COPY INTO APTIV_DB.BRONZE.RAW_MAINTENANCE
    FROM @APTIV_DB.BRONZE.APTIV_STAGE/ai4i2020.csv.gz
    FILE_FORMAT = APTIV_DB.BRONZE.CSV_FORMAT
    ON_ERROR = 'CONTINUE';

-- verify
SELECT 'RAW_SUPPLY_CHAIN' AS table_name, COUNT(*) AS row_count FROM APTIV_DB.BRONZE.RAW_SUPPLY_CHAIN
UNION ALL
SELECT 'RAW_MAINTENANCE',               COUNT(*) FROM APTIV_DB.BRONZE.RAW_MAINTENANCE;
