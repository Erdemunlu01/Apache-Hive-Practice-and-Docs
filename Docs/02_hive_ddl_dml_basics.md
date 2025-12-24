# Hive DDL and DML Basics

This document is prepared to explain **basic DDL (Data Definition Language)**
and **DML (Data Manipulation Language)** operations in Apache Hive.

The goal is to demonstrate database creation, table definition,
data loading, and basic data operations in Hive
step by step with practical examples.

---

## 1. What Are DDL and DML in Hive?

### DDL (Data Definition Language)
DDL commands are used to define Hive objects.

Examples of DDL operations include:
- Creating / dropping databases
- Creating / dropping tables
- Modifying table structures

### DML (Data Manipulation Language)
DML commands are used to work with data stored in tables.

Examples of DML operations include:
- Loading data
- Insert operations
- Select queries

---

## 2. Database Operations

To create a new database in Hive, the following command is used:

```sql
CREATE DATABASE IF NOT EXISTS test1;
```

To use the created database:

```sql
USE test1;
```

To list existing databases:

```sql
SHOW DATABASES;
```

---

## 3. Creating Tables in Hive (DDL)

When creating a table in Hive, columns, data types,
file format, and delimiter are defined.

Below is an example of creating a table in CSV format:

```sql
CREATE TABLE wine (
  fixed_acidity FLOAT,
  volatile_acidity FLOAT,
  citric_acid FLOAT,
  alcohol FLOAT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
TBLPROPERTIES ('skip.header.line.count'='1');
```

This table:
- Reads data in CSV format
- Uses comma (`,`) as the field delimiter
- Skips the first line as a header

---

## 4. Inspecting Table Structure

To view the structure of the created table:

```sql
DESCRIBE wine;
```

To get more detailed information about the table:

```sql
DESCRIBE FORMATTED wine;
```

---

## 5. Loading Data into Hive Tables (DML)

To load data into Hive tables,
the data must exist on HDFS.

To load data from HDFS into a table:

```sql
LOAD DATA INPATH '/user/train/wine.csv'
INTO TABLE wine;
```

This command:
- Reads data from HDFS
- Copies it into the table
- Appends data to the existing table content

---

## 6. Writing Filtered Data into a New Table

In Hive, the result of a SELECT query can be written into a new table.

For example, to write records with an alcohol level greater than 13
into a new table:

```sql
CREATE TABLE wine_high_alcohol AS
SELECT *
FROM wine
WHERE alcohol > 13;
```

This operation:
- Creates a new table
- Writes filtered data into the new table
- Uses the CTAS (Create Table As Select) approach

---

## 7. Using INSERT INTO

To insert data into an existing table, `INSERT INTO` is used:

```sql
INSERT INTO TABLE wine_high_alcohol
SELECT *
FROM wine
WHERE alcohol > 14;
```

This command inserts the selected data
into the target table.

---

## 8. Truncating and Dropping Tables

To remove all data from a table:

```sql
TRUNCATE TABLE wine_high_alcohol;
```

To completely remove a table:

```sql
DROP TABLE wine_high_alcohol;
```

---

## 9. Summary

In this document:

- DDL and DML concepts in Hive were explained
- Database creation and usage were demonstrated
- The logic of creating Hive tables was described
- An example of loading data from HDFS was provided
- CTAS and INSERT INTO usage were shown
- Table truncation and drop operations were covered

These steps cover the **most commonly used basic DDL and DML operations**
when working with Apache Hive.
