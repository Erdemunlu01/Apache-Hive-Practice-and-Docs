-- =========================================================
-- WINE DATASET - APACHE HIVE PRACTICE (Based on your notes)
-- =========================================================
-- This script covers:
-- 1) Creating training DB (test1)
-- 2) Creating wine DB + wine.wine table (CSV)
-- 3) Loading data from HDFS (LOAD DATA)
-- 4) Creating a filtered table (LIKE + INSERT) where Alcohol > 13
-- 5) Cleanup: DROP DATABASE wine CASCADE (optional)
-- =========================================================

-- ---------------------------------------------------------
-- 1) DATABASES
-- ---------------------------------------------------------
CREATE DATABASE IF NOT EXISTS test1 COMMENT "This is for training";

CREATE DATABASE IF NOT EXISTS wine COMMENT "Wine dataset database";
SHOW DATABASES;

-- ---------------------------------------------------------
-- 2) MAIN TABLE: wine.wine
-- ---------------------------------------------------------
-- CSV: fields separated by ',' and lines separated by '\n'
-- If the CSV has a header row, skip it with skip.header.line.count = 1

DROP TABLE IF EXISTS wine.wine;

CREATE TABLE IF NOT EXISTS wine.wine (
  Alcohol FLOAT,
  Malic_Acid FLOAT,
  Ash FLOAT,
  Ash_Alcanity FLOAT,
  Magnesium INT,
  Total_Phenols FLOAT,
  Flavanoids FLOAT,
  Nonflavanoid_Phenols FLOAT,
  Proanthocyanins FLOAT,
  Color_Intensity FLOAT,
  Hue FLOAT,
  OD280 FLOAT,
  Proline INT,
  Customer_Segment INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
TBLPROPERTIES('skip.header.line.count'='1');

-- If you want to validate table metadata/type/location:
-- DESCRIBE FORMATTED wine.wine;

-- ---------------------------------------------------------
-- 3) LOAD DATA (HDFS -> HIVE)
-- ---------------------------------------------------------
-- Data location in HDFS: /user/train/hdfs_odev/Wine.csv

LOAD DATA INPATH '/user/train/hdfs_odev/Wine.csv'
INTO TABLE wine.wine;

-- Validation
SELECT COUNT(*) AS total_rows FROM wine.wine;
SELECT * FROM wine.wine LIMIT 5;

-- ---------------------------------------------------------
-- 4) CREATE FILTER TABLE + INSERT (Alcohol > 13)
-- ---------------------------------------------------------
DROP TABLE IF EXISTS wine.wine_alc_gt_13;

-- Clone schema
CREATE TABLE wine.wine_alc_gt_13 LIKE wine.wine;

SHOW TABLES IN wine;

-- Insert filtered rows
INSERT INTO wine.wine_alc_gt_13
SELECT
  Alcohol,
  Malic_Acid,
  Ash,
  Ash_Alcanity,
  Magnesium,
  Total_Phenols,
  Flavanoids,
  Nonflavanoid_Phenols,
  Proanthocyanins,
  Color_Intensity,
  Hue,
  OD280,
  Proline,
  Customer_Segment
FROM wine.wine
WHERE Alcohol > 13;

-- Validation
SELECT COUNT(*) AS alc_gt_13_rows FROM wine.wine_alc_gt_13;
SELECT * FROM wine.wine_alc_gt_13 LIMIT 5;

-- ---------------------------------------------------------
-- 5) CLEANUP (Optional)
-- ---------------------------------------------------------
-- To remove the entire wine database and all its tables:
-- DROP DATABASE wine CASCADE;
--
-- Note: CASCADE drops all tables inside the database.
-- ---------------------------------------------------------
