# Wine Dataset – Apache Hive Practice (Wine DB)

This practice demonstrates an end-to-end Apache Hive workflow using a Wine dataset:
- creating databases,
- designing a CSV-compatible Hive table,
- loading data from HDFS (`LOAD DATA`),
- creating a filtered table using `LIKE` + `INSERT INTO`,
- cleaning up with `DROP DATABASE ... CASCADE`.

All steps are aligned with `hive_practice_wine.sql` in this folder.

---

## 1) Dataset

The Wine dataset used in this practice is in CSV format (comma-separated).
The Hive table schema (columns) is exactly the following:

- `Alcohol` (FLOAT)
- `Malic_Acid` (FLOAT)
- `Ash` (FLOAT)
- `Ash_Alcanity` (FLOAT)
- `Magnesium` (INT)
- `Total_Phenols` (FLOAT)
- `Flavanoids` (FLOAT)
- `Nonflavanoid_Phenols` (FLOAT)
- `Proanthocyanins` (FLOAT)
- `Color_Intensity` (FLOAT)
- `Hue` (FLOAT)
- `OD280` (FLOAT)
- `Proline` (INT)
- `Customer_Segment` (INT)

The data is assumed to be available in HDFS at:

- `/user/train/hdfs_odev/Wine.csv`

> Note: If the CSV contains a header row, the table uses `skip.header.line.count=1`.

---

## 2) Objective

This practice covers:
- Creating a **managed table** in Hive
- Handling CSV delimiter and line delimiter settings
- Loading data from HDFS into Hive
- Building a filtered table (`Alcohol > 13`)
- Understanding `DROP DATABASE ... CASCADE` behavior

---

## 3) Workflow Summary

1) Create `test1` database (general training DB)  
2) Create and use `wine` database  
3) Create `wine.wine` table (CSV layout)  
4) Load `Wine.csv` from HDFS into Hive  
5) Insert `Alcohol > 13` rows into `wine.wine_alc_gt_13`  
6) Validate results using `COUNT(*)` and `LIMIT`  
7) (Optional) Clean up using `DROP DATABASE wine CASCADE`

---

## 4) Run

```bash
beeline -u jdbc:hive2://localhost:10000 -f ./hive_practice_wine.sql