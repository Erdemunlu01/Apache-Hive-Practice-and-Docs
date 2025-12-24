-- =========================================================
-- FLO CUSTOMER TRANSACTIONS - APACHE HIVE CASE STUDY
-- =========================================================
-- Goal:
-- 1) Ingest raw FLO CSV data into Hive
-- 2) Transform date fields into proper types
-- 3) Create an ORC-based analytical table
-- 4) Answer business-oriented analytical questions
-- =========================================================

-- ---------------------------------------------------------
-- 1) DATABASE
-- ---------------------------------------------------------
CREATE DATABASE IF NOT EXISTS flo
COMMENT 'FLO Data Analysis with Apache Hive';

SHOW DATABASES;
USE flo;

-- ---------------------------------------------------------
-- 2) RAW TABLE: flo_transactions
-- ---------------------------------------------------------
DROP TABLE IF EXISTS flo.flo_transactions;

CREATE TABLE IF NOT EXISTS flo.flo_transactions (
    master_id STRING,
    order_channel STRING,
    platform_type STRING,
    last_order_channel STRING,
    first_order_date STRING,
    last_order_date STRING,
    last_order_date_online STRING,
    last_order_date_offline STRING,
    order_num_total_ever_online FLOAT,
    order_num_total_ever_offline FLOAT,
    customer_value_total_ever_offline FLOAT,
    customer_value_total_ever_online FLOAT,
    interested_in_categories_12 STRING,
    online_product_group_amount_top_name_12 STRING,
    offline_product_group_name_12 STRING,
    last_order_date_new STRING,
    store_type STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
TBLPROPERTIES (
    'skip.header.line.count' = '1',
    'serialization.null.format' = ''
);

SHOW TABLES;

-- ---------------------------------------------------------
-- 3) LOAD DATA (HDFS -> HIVE)
-- ---------------------------------------------------------
LOAD DATA INPATH '/user/train/flo_data/flo100k.csv'
INTO TABLE flo.flo_transactions;

SELECT * FROM flo.flo_transactions LIMIT 10;

-- ---------------------------------------------------------
-- 4) DATE ENRICHED TABLE (ORC)
-- ---------------------------------------------------------
DROP TABLE IF EXISTS flo.flo_transactions_date;

CREATE TABLE flo.flo_transactions_date
STORED AS ORC
AS
SELECT
    master_id,
    order_channel,
    platform_type,
    last_order_channel,
    CAST(regexp_replace(first_order_date, 'T', ' ') AS TIMESTAMP) AS first_order_date_ts,
    CAST(regexp_replace(last_order_date, 'T', ' ') AS TIMESTAMP) AS last_order_date_ts,
    CAST(regexp_replace(last_order_date_online, 'T', ' ') AS TIMESTAMP) AS last_order_date_online_ts,
    CAST(regexp_replace(last_order_date_offline, 'T', ' ') AS TIMESTAMP) AS last_order_date_offline_ts,
    order_num_total_ever_online,
    order_num_total_ever_offline,
    customer_value_total_ever_offline,
    customer_value_total_ever_online,
    interested_in_categories_12,
    online_product_group_amount_top_name_12,
    offline_product_group_name_12,
    CAST(last_order_date_new AS DATE) AS last_order_date_dt,
    store_type
FROM flo.flo_transactions;

SELECT * FROM flo.flo_transactions_date LIMIT 10;

-- ---------------------------------------------------------
-- 5) BUSINESS ANALYTICS
-- ---------------------------------------------------------

-- 5.1 Transaction count by store type
SELECT
    store_type,
    COUNT(*) AS transaction_count
FROM flo.flo_transactions_date
GROUP BY store_type
ORDER BY transaction_count DESC;

-- 5.2 Transaction count by order channel
SELECT
    order_channel,
    COUNT(*) AS transaction_count
FROM flo.flo_transactions_date
GROUP BY order_channel
ORDER BY transaction_count DESC;

-- 5.3 Transaction counts by first order year
SELECT
    DATE_FORMAT(first_order_date_ts, 'yyyy') AS first_order_year,
    COUNT(*) AS transaction_count
FROM flo.flo_transactions_date
GROUP BY DATE_FORMAT(first_order_date_ts, 'yyyy')
ORDER BY transaction_count DESC;

-- 5.4 Top 15 highest value OmniChannel customers
SELECT
    master_id,
    customer_value_total_ever_offline + customer_value_total_ever_online AS total_customer_value
FROM flo.flo_transactions_date
WHERE platform_type = 'OmniChannel'
ORDER BY total_customer_value DESC
LIMIT 15;

-- =========================================================
-- END OF CASE STUDY
-- =========================================================
