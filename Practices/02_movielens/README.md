# MovieLens (ml-100k) – Apache Hive Practice

This practice demonstrates an end-to-end Apache Hive workflow using the **MovieLens ml-100k** dataset:

- Download data (wget)
- Copy files into HDFS
- Create Hive tables (ratings + movies)
- Convert epoch timestamps to TIMESTAMP/DATE (enriched tables)
- Monthly analytics with JOINs
- Build performance-oriented ORC tables using Partitioning + Bucketing

All steps are available in `hive_practice_movielens.sql`.

---

## 1) Dataset Files (ml-100k)

This practice uses two core files:

- `u.data`  → user ratings (tab-separated)
- `u.item`  → movie metadata + genre flags (pipe `|` separated)

---

## 2) Download the Data

```bash
wget https://raw.githubusercontent.com/erkansirin78/datasets/refs/heads/master/ml-100k/u.item
wget https://raw.githubusercontent.com/erkansirin78/datasets/refs/heads/master/ml-100k/u.data
```

---

## 3) Copy Data to HDFS

```bash
# Create target folder
hdfs dfs -mkdir -p /user/train/hdfs_odev_2

# Upload local files to HDFS
hdfs dfs -put ~/datasets/u.data /user/train/hdfs_odev_2/
hdfs dfs -put ~/datasets/u.item /user/train/hdfs_odev_2/

# Verify
hdfs dfs -ls /user/train/hdfs_odev_2
```

---

## 4) Hive Workflow (Summary)

1) Create `movielens` database  
2) Create `movielens.ratings` and load `u.data`  
3) Convert epoch timestamps → `ratings_enriched`  
4) Create `movielens.movies` and load `u.item`  
5) Convert `releasedate` string → DATE → `movies_enriched`  
6) Monthly analytics (average rating / vote count) with JOINs  
7) Create ORC partitioned tables and load using dynamic partitions  
8) Create ORC bucketed tables and populate from partitioned tables  
9) Example questions: Top movies in **April 1998** by votes / avg rating

---

## 5) Run the Script

```bash
beeline -u jdbc:hive2://localhost:10000 -f ./hive_practice_movielens.sql
```

---

## 6) Key Learnings

- Handling delimiters (`\t`, `|`)
- Epoch → TIMESTAMP/DATE conversions
- `unix_timestamp`, `from_unixtime`, `CAST`
- Analytics with JOINs
- ORC table design
- Dynamic partitioning
- Bucketing enforcement and bucket tables

This practice clearly shows how to transform raw data into analysis-ready tables in Hive.
