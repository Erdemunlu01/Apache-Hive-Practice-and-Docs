# FLO Customer Transactions – Apache Hive Case Study

This case study demonstrates a **real-world analytical workflow**
built on Apache Hive using customer transaction data from FLO.

Within this study:
- raw CSV data is ingested into Hive,
- date fields are transformed into proper TIMESTAMP and DATE types,
- an ORC-based analytical table is created for performance,
- business-oriented analytical queries are executed.

The main goal of this case study is to show that Hive is not only a
technical tool, but also a powerful platform for **solving business problems**.

---

## 1) Dataset Description

The dataset contains customer-level transaction information.

Main columns include:

- `master_id` – unique customer identifier
- `order_channel` – order channel
- `platform_type` – Online / Offline / OmniChannel
- `store_type` – store type
- `first_order_date` – first order date (STRING)
- `last_order_date` – last order date (STRING)
- `last_order_date_online` – last online order date (STRING)
- `last_order_date_offline` – last offline order date (STRING)
- `last_order_date_new` – normalized date field (DATE-like STRING)
- `order_num_total_ever_online`
- `order_num_total_ever_offline`
- `customer_value_total_ever_online`
- `customer_value_total_ever_offline`
- `interested_in_categories_12`
- `online_product_group_amount_top_name_12`
- `offline_product_group_name_12`

The dataset is in CSV format and uses the `|` character as delimiter.

HDFS path used in this study:

/user/train/flo_data/flo100k.csv

---

## 2) Objective

This case study aims to:

- Work with **real-world CSV data** in Hive
- Convert string-based date fields to `TIMESTAMP` and `DATE`
- Create a performant analytical table using **ORC**
- Answer business-driven analytical questions using HiveQL

---

## 3) Workflow Overview

1) Create the `flo` database  
2) Create the raw table `flo_transactions`  
3) Load CSV data from HDFS into Hive  
4) Transform date fields and generate `flo_transactions_date` table  
5) Perform store, channel, and year-based analytics  
6) Analyze high-value OmniChannel customers  

---

## 4) Business Questions Answered

- What is the number of transactions by store type?
- What is the transaction distribution by order channel?
- How do transaction counts change by first order year?
- Who are the top 15 highest-value OmniChannel customers?

---

## 5) How to Run

```bash
beeline -u jdbc:hive2://localhost:10000 -f ./flo_hive_case.sql
