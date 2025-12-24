# External Tables in Apache Hive

This document explains the concept of **External Tables** in Apache Hive,
why they are used, and how they differ from managed (internal) tables.
Practical examples are provided to demonstrate their usage.

---

## 1. What Is an External Table?

An external table in Hive is a table definition that points to data
stored outside of Hive’s managed warehouse directory.

In external tables:
- Hive does **not own the data**
- Dropping the table does **not delete the data**
- The data lifecycle is managed externally

External tables are commonly used when data is shared
between multiple systems or tools.

---

## 2. External Tables vs Managed Tables

### Managed (Internal) Tables
- Hive manages both metadata and data
- Data is stored under Hive warehouse directory
- Dropping the table deletes the data

### External Tables
- Hive manages only metadata
- Data is stored at a user-defined HDFS location
- Dropping the table does **not** delete the data

Because of this behavior, external tables are safer
when working with critical or shared datasets.

---

## 3. When to Use External Tables

External tables are preferred in scenarios such as:
- Reading raw data stored in HDFS
- Sharing datasets with Spark, Presto, or other tools
- Preventing accidental data deletion
- Separating data storage from Hive metadata

---

## 4. Creating an External Table

To create an external table, the `EXTERNAL` keyword
and a `LOCATION` must be specified.

Below is an example of creating an external table
that reads CSV data from HDFS:

```sql
CREATE EXTERNAL TABLE hotel_reviews (
  review_id INT,
  review_text STRING,
  review_score FLOAT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/train/hotel_reviews'
TBLPROPERTIES ('skip.header.line.count'='1');
```

In this example:
- Hive reads data from the specified HDFS directory
- The data remains intact even if the table is dropped

---

## 5. Verifying External Table Behavior

After creating the table, it can be queried
like a managed table:

```sql
SELECT *
FROM hotel_reviews
LIMIT 10;
```

If the table is dropped:

```sql
DROP TABLE hotel_reviews;
```

The data located at `/user/train/hotel_reviews`
will still exist in HDFS.

---

## 6. Checking Table Type

To verify whether a table is external or managed,
the following command can be used:

```sql
DESCRIBE FORMATTED hotel_reviews;
```

In the output:
- `Table Type: EXTERNAL_TABLE` indicates an external table
- `Location` shows the HDFS path of the data

---

## 7. External Tables and Data Management

External tables are especially useful for:
- Staging raw data
- Performing exploratory analysis
- Building data pipelines where multiple tools access the same data

They allow Hive to act as a **query engine**
without taking full ownership of the data.

---

## 8. Summary

In this document:

- The concept of external tables was explained
- Differences between managed and external tables were described
- Use cases for external tables were discussed
- An example of creating an external table was provided
- The behavior of external tables when dropped was demonstrated
- Table type verification using DESCRIBE FORMATTED was shown

External tables play a key role in building
safe and flexible data architectures in Apache Hive.
