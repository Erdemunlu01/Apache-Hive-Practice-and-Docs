# Apache Hive Troubleshooting Guide

This document is prepared to explain the **most common issues encountered
while working with Apache Hive**, their **possible causes**, and
**practical solutions**.

The goal is to help analyze Hive-related problems more quickly
and provide a reference guide for recurring issues.

---

## 1. Beeline Connection Error

### Issue
The connection cannot be established or times out
when trying to connect to Hive using Beeline.

### Possible Causes
- HiveServer2 service is not running
- Incorrect host or port is used
- Hive services have not fully started yet

### Solution
First, check whether Hive services are running:

```bash
jps
```

Make sure that `HiveServer2` and `Metastore`
appear in the output.

Then try connecting again:

```bash
beeline -u jdbc:hive2://localhost:10000
```

---

## 2. INSERT INTO Partition Error (Dynamic Partition)

### Issue
Insert operations fail when inserting data
into a partitioned table.

### Possible Causes
- Dynamic partitioning is disabled
- Hive runs in strict mode by default

### Solution
Enable dynamic partitioning:

```sql
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
```

Then retry the insert operation.

---

## 3. Table Not Found Error

### Issue
A table that is expected to exist cannot be accessed,
and a `Table not found` error is returned.

### Possible Causes
- The wrong database is selected
- The table exists in a different database

### Solution
Check the currently selected database:

```sql
SELECT current_database();
```

Switch to the correct database:

```sql
USE test1;
```

Then list available tables:

```sql
SHOW TABLES;
```

---

## 4. LOAD DATA Works but No Data Appears

### Issue
The `LOAD DATA` command executes successfully,
but no data appears in the table.

### Possible Causes
- Incorrect HDFS path
- Wrong file format or delimiter
- Header row is not skipped

### Solution
Verify that the file exists in HDFS:

```bash
hdfs dfs -ls /user/train
```

Check the table definition for delimiter
and header-related properties:

```sql
DESCRIBE FORMATTED table_name;
```

---

## 5. Thinking Data Is Deleted After Dropping an External Table

### Issue
It is assumed that data is deleted
after dropping an external table.

### Explanation
When an external table is dropped:
- Only Hive metadata is removed
- The data remains in HDFS

### Verification
Check whether the data still exists:

```bash
hdfs dfs -ls /user/train/hotel_reviews
```

---

## 6. Too Many Small Files Problem

### Issue
Hive queries run slowly,
and a large number of small files exist in HDFS.

### Possible Causes
- Poor partition column selection
- Over-partitioning
- Small batch insert operations

### Recommended Solutions
- Choose partition columns carefully
- Reduce unnecessary partition counts
- Use CTAS to generate larger files

---

## 7. Bucketing Not Enforced

### Issue
Although a bucketed table is created,
data is not distributed into buckets as expected.

### Possible Causes
- Bucketing enforcement is disabled

### Solution
Enable bucketing enforcement:

```sql
SET hive.enforce.bucketing = true;
```

Then reload or reinsert the data.

---

## 8. Lower Than Expected Query Performance

### Issue
Queries run slower than expected
despite using partitioning and bucketing.

### Possible Causes
- Partition columns are not used in query filters
- Incorrect join keys are selected
- Unnecessary columns are scanned

### Recommended Solutions
- Always use partition columns in WHERE clauses
- Select only required columns
- Analyze query plans using EXPLAIN

```sql
EXPLAIN SELECT *
FROM sales
WHERE year = 2024;
```

---

## 9. Summary

In this document:

- Common Hive issues were discussed
- Possible causes of errors were explained
- Practical solutions were provided
- Recommendations for performance-related problems were shared

This document can be used as a **quick reference guide**
for troubleshooting Apache Hive-related issues.
