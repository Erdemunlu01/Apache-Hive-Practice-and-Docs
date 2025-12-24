# Apache Hive Partitioning and Bucketing

This document explains the concepts of **Partitioning** and **Bucketing**
in Apache Hive, why they are used, and
their impact on query performance,
with practical examples.

Partitioning and bucketing are fundamental optimization techniques
used in Hive to **reduce the amount of data scanned**
and **improve query performance**.

---

## 1. What Is Partitioning?

Partitioning is the process of dividing a table into
**subdirectories based on the values of a specific column**.

In Hive, a partitioned table is physically stored
as separate directories in HDFS.

Common partition columns include:
- year
- month
- country
- category

These fields are typically used in filter conditions
and are good candidates for partitioning.

---

## 2. Why Use Partitioning?

The main benefits of partitioning are:

- Queries scan only relevant partitions
- Full table scans are reduced
- Query performance improves significantly
- Large tables become easier to manage

Example:
```sql
SELECT *
FROM sales
WHERE year = 2024;
```

If `year` is a partition column,
Hive reads only the corresponding directory.

---

## 3. Creating a Partitioned Table

To create a partitioned table in Hive,
the `PARTITIONED BY` clause is used.

Below is an example of a table partitioned by year:

```sql
CREATE TABLE sales (
  order_id INT,
  product_id INT,
  amount FLOAT
)
PARTITIONED BY (year INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';
```

In this structure:
- The `year` column is not stored in the table data
- It is represented as part of the HDFS directory structure

---

## 4. Inserting Data into Partitions

### Static Partitioning

The partition value is specified manually:

```sql
INSERT INTO TABLE sales PARTITION (year=2024)
SELECT order_id, product_id, amount
FROM sales_raw;
```

---

### Dynamic Partitioning

Partition values are derived automatically from the query.

First, the required settings must be enabled:

```sql
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
```

Then, the dynamic partition insert can be executed:

```sql
INSERT INTO TABLE sales PARTITION (year)
SELECT order_id, product_id, amount, year
FROM sales_raw;
```

---

## 5. What Is Bucketing?

Bucketing is the process of dividing a table into
**a fixed number of files (buckets)** based on the hash value
of a specific column.

Difference from partitioning:
- Partitioning → directory-based separation
- Bucketing → file-based separation

Bucketing is commonly used for:
- Columns used in JOIN operations
- Columns frequently used in GROUP BY clauses

---

## 6. Creating a Bucketed Table

To create a bucketed table,
the `CLUSTERED BY` and `INTO BUCKETS` clauses are used.

```sql
CREATE TABLE users (
  user_id INT,
  name STRING,
  city STRING
)
CLUSTERED BY (user_id)
INTO 8 BUCKETS
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';
```

In this table:
- The `user_id` column is hashed
- Data is distributed into 8 separate bucket files

---

## 7. Loading Data into a Bucketed Table

To ensure that bucketing works correctly,
the following setting must be enabled:

```sql
SET hive.enforce.bucketing = true;
```

Then the data can be inserted:

```sql
INSERT INTO TABLE users
SELECT user_id, name, city
FROM users_raw;
```

---

## 8. Using Partitioning and Bucketing Together

Partitioning and bucketing can be used together in Hive.

Example scenario:
- Partition column → year
- Bucket column → user_id

This approach provides:
- Partition pruning
- Faster JOIN and aggregation operations

---

## 9. When to Use Which?

- Low cardinality, frequently filtered columns → **Partitioning**
- High cardinality, join-heavy columns → **Bucketing**
- Large datasets → **Partitioning + Bucketing**

Poor partition choices may lead to
a large number of small files.

---

## 10. Summary

In this document:

- The concept of partitioning was explained
- Creating partitioned tables and inserting data was demonstrated
- Differences between static and dynamic partitioning were described
- The concept of bucketing and its use cases were explained
- An example of creating a bucketed table was provided
- The combined usage of partitioning and bucketing was discussed

Partitioning and bucketing are among the most important techniques
for building high-performance and scalable tables
in Apache Hive.
