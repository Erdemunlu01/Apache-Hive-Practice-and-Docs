# Beeline and Hive CLI Basics

This document is prepared to explain **how to connect to an Apache Hive environment**
via the **command-line interface (CLI)**, which services are required,
and the **basic Hive commands** used after establishing the connection,
step by step.

---

## 1. What Is Apache Hive? (Briefly)

Apache Hive is a data warehouse tool that operates on the Hadoop ecosystem
and allows executing **SQL-like queries (HiveQL)** on large datasets
stored in HDFS.

While executing queries, Hive relies on the following components:
- HDFS
- Hive Metastore
- MapReduce / Tez / Spark

---

## 2. Difference Between Hive CLI and Beeline

### Hive CLI
- An old and deprecated tool
- Not recommended in modern Hive versions
- Not suitable for production environments

### Beeline
- A JDBC-based command-line tool
- Connects to Hive through the HiveServer2 service
- Suitable for real-world Hive usage

For this reason, **Beeline** is used for Hive access in this repository.

---

## 3. What Is HiveServer2?

HiveServer2 is the service that manages client connections
and executes Hive queries.

The connection architecture can be summarized as follows:

Beeline → HiveServer2 → Hive Metastore → HDFS

Beeline does **not** connect directly to Hive;
it connects via HiveServer2.

---

## 4. Checking Hive Services and Connecting to Hive

Before connecting to Hive, it is necessary to verify that
the required services are running. To do this, the active
Java processes are listed, and then Hive is accessed
using the commands below:

```bash
jps
beeline -u jdbc:hive2://localhost:10000
```

If the connection is successful, the following Beeline prompt appears:

```text
0: jdbc:hive2://localhost:10000>
```

---

## 5. Basic Hive Commands After Connection

The following HiveQL commands are used to verify that
the connection is successful and the environment
is working correctly:

```sql
0: jdbc:hive2://localhost:10000> SHOW DATABASES;
0: jdbc:hive2://localhost:10000> USE test1;
0: jdbc:hive2://localhost:10000> SHOW TABLES;
0: jdbc:hive2://localhost:10000> DESCRIBE table_name;
0: jdbc:hive2://localhost:10000> !quit
```
