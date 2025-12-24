-- =========================================================
-- MOVIELENS (ml-100k) - APACHE HIVE PRACTICE
-- =========================================================
-- Goal:
-- 1) Download files (terminal)
-- 2) Copy to HDFS (terminal)
-- 3) Create Hive tables (ratings + movies)
-- 4) Timestamp / Date transformations (enriched)
-- 5) Monthly analytics with JOINs
-- 6) Build ORC tables with Partitioning + Bucketing
-- =========================================================

-- ---------------------------------------------------------
-- 0) DATABASE
-- ---------------------------------------------------------
CREATE DATABASE IF NOT EXISTS movielens COMMENT 'This is for practice 2';
USE movielens;

SHOW DATABASES;
SHOW TABLES;

-- =========================================================
-- 1) RATINGS TABLE (u.data)
-- =========================================================
-- u.data format: user_id \t item_id \t rating \t timestamp
-- Note: u.data has NO header line, so skip.header.line.count is unnecessary.

DROP TABLE IF EXISTS movielens.ratings;

CREATE TABLE movielens.ratings (
    user_id INT,
    item_id INT,
    rating INT,
    timestamp_val BIGINT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
-- TBLPROPERTIES('skip.header.line.count'='1'); -- (no header)

LOAD DATA INPATH '/user/train/hdfs_odev_2/u.data' INTO TABLE movielens.ratings;

SELECT COUNT(*) AS ratings_cnt FROM movielens.ratings;
SELECT * FROM movielens.ratings LIMIT 10;

-- =========================================================
-- 2) RATINGS ENRICHED (Epoch -> TIMESTAMP/DATE)
-- =========================================================

DROP TABLE IF EXISTS movielens.ratings_enriched;

CREATE TABLE movielens.ratings_enriched AS
SELECT
    user_id,
    item_id,
    rating,
    timestamp_val,
    CAST(from_unixtime(timestamp_val, 'yyyy-MM-dd HH:mm:ss') AS TIMESTAMP) AS readable_timestamp,
    CAST(from_unixtime(timestamp_val, 'yyyy-MM-dd') AS DATE) AS transaction_date
FROM movielens.ratings;

SELECT COUNT(*) AS ratings_enriched_cnt FROM movielens.ratings_enriched;
SELECT * FROM movielens.ratings_enriched LIMIT 10;

-- =========================================================
-- 3) MOVIES TABLE (u.item)
-- =========================================================
-- u.item delimiter: '|'
-- releasedate format: 'dd-MMM-yyyy' (e.g., 01-Jan-1995)
-- Note: u.item has NO header line.

DROP TABLE IF EXISTS movielens.movies;

CREATE TABLE movielens.movies (
    movieid INT,
    movietitle STRING,
    releasedate STRING,
    videoreleasedate STRING,
    imdb_url STRING,
    unknown INT,
    Action INT,
    Adventure INT,
    Animation INT,
    Childrens INT,
    Comedy INT,
    Crime INT,
    Documentary INT,
    Drama INT,
    Fantasy INT,
    Film_Noir INT,
    Horror INT,
    Musical INT,
    Mystery INT,
    Romance INT,
    Sci_Fi INT,
    Thriller INT,
    War INT,
    Western INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
-- TBLPROPERTIES('skip.header.line.count'='1'); -- (no header)

LOAD DATA INPATH '/user/train/hdfs_odev_2/u.item' INTO TABLE movielens.movies;

SELECT COUNT(*) AS movies_cnt FROM movielens.movies;
SELECT * FROM movielens.movies LIMIT 10;

-- =========================================================
-- 4) MOVIES ENRICHED (releasedate STRING -> DATE)
-- =========================================================

DROP TABLE IF EXISTS movielens.movies_enriched;

CREATE TABLE movielens.movies_enriched (
    movieid INT,
    movietitle STRING,
    releasedate_str STRING,
    release_date_dt DATE,
    videoreleasedate STRING,
    imdb_url STRING,
    unknown INT,
    Action INT,
    Adventure INT,
    Animation INT,
    Childrens INT,
    Comedy INT,
    Crime INT,
    Documentary INT,
    Drama INT,
    Fantasy INT,
    Film_Noir INT,
    Horror INT,
    Musical INT,
    Mystery INT,
    Romance INT,
    Sci_Fi INT,
    Thriller INT,
    War INT,
    Western INT
);

INSERT INTO movielens.movies_enriched
SELECT
    movieid,
    movietitle,
    releasedate AS releasedate_str,
    CAST(from_unixtime(unix_timestamp(releasedate, 'dd-MMM-yyyy'), 'yyyy-MM-dd') AS DATE) AS release_date_dt,
    videoreleasedate,
    imdb_url,
    unknown,
    Action,
    Adventure,
    Animation,
    Childrens,
    Comedy,
    Crime,
    Documentary,
    Drama,
    Fantasy,
    Film_Noir,
    Horror,
    Musical,
    Mystery,
    Romance,
    Sci_Fi,
    Thriller,
    War,
    Western
FROM movielens.movies;

SELECT * FROM movielens.movies_enriched LIMIT 10;

-- =========================================================
-- 5) ANALYTICS (Monthly Avg Rating / Vote Count)
-- =========================================================

-- Monthly average rating per movie
SELECT
    DATE_FORMAT(mre.transaction_date, 'yyyy-MM') AS rating_month_string,
    mme.movietitle,
    AVG(mre.rating) AS avg_rating
FROM movielens.movies_enriched mme
JOIN movielens.ratings_enriched mre
  ON mme.movieid = mre.item_id
GROUP BY DATE_FORMAT(mre.transaction_date, 'yyyy-MM'), mme.movietitle
ORDER BY rating_month_string ASC;

-- Monthly vote count per movie
SELECT
    DATE_FORMAT(mre.transaction_date, 'yyyy-MM') AS rating_month_string,
    mme.movietitle,
    COUNT(mre.user_id) AS vote_count
FROM movielens.movies_enriched mme
JOIN movielens.ratings_enriched mre
  ON mme.movieid = mre.item_id
GROUP BY DATE_FORMAT(mre.transaction_date, 'yyyy-MM'), mme.movietitle
ORDER BY rating_month_string ASC;

-- =========================================================
-- 6) PARTITIONING (ORC) - Dynamic Partition
-- =========================================================

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

DROP TABLE IF EXISTS movielens.movie_avg_rating;

CREATE TABLE movielens.movie_avg_rating (
    movietitle STRING,
    avg_rating FLOAT
)
PARTITIONED BY (review_year INT, review_month INT)
STORED AS ORC;

INSERT OVERWRITE TABLE movielens.movie_avg_rating
PARTITION (review_year, review_month)
SELECT
    mme.movietitle,
    AVG(mre.rating) AS avg_rating,
    YEAR(mre.transaction_date) AS review_year,
    MONTH(mre.transaction_date) AS review_month
FROM movielens.movies_enriched mme
JOIN movielens.ratings_enriched mre
  ON mme.movieid = mre.item_id
GROUP BY
    mme.movietitle,
    YEAR(mre.transaction_date),
    MONTH(mre.transaction_date);

SELECT * FROM movielens.movie_avg_rating LIMIT 5;
SHOW PARTITIONS movielens.movie_avg_rating;

DROP TABLE IF EXISTS movielens.movie_count_users;

CREATE TABLE movielens.movie_count_users (
    movietitle STRING,
    count_users INT
)
PARTITIONED BY (review_year INT, review_month INT)
STORED AS ORC;

INSERT OVERWRITE TABLE movielens.movie_count_users
PARTITION (review_year, review_month)
SELECT
    mme.movietitle,
    COUNT(mre.user_id) AS count_users,
    YEAR(mre.transaction_date) AS review_year,
    MONTH(mre.transaction_date) AS review_month
FROM movielens.movies_enriched mme
JOIN movielens.ratings_enriched mre
  ON mme.movieid = mre.item_id
GROUP BY
    mme.movietitle,
    YEAR(mre.transaction_date),
    MONTH(mre.transaction_date);

SELECT * FROM movielens.movie_count_users LIMIT 5;
SHOW PARTITIONS movielens.movie_count_users;

-- =========================================================
-- 7) BUCKETING (ORC)
-- =========================================================

SET hive.enforce.bucketing = true;

DROP TABLE IF EXISTS movielens.movie_avg_rating_bucket;

CREATE TABLE movielens.movie_avg_rating_bucket (
    movietitle STRING,
    avg_rating FLOAT,
    review_year INT,
    review_month INT
)
CLUSTERED BY (movietitle) INTO 32 BUCKETS
STORED AS ORC;

INSERT OVERWRITE TABLE movielens.movie_avg_rating_bucket
SELECT
    movietitle,
    avg_rating,
    review_year,
    review_month
FROM movielens.movie_avg_rating;

SELECT * FROM movielens.movie_avg_rating_bucket LIMIT 5;

DROP TABLE IF EXISTS movielens.movie_count_users_bucket;

CREATE TABLE movielens.movie_count_users_bucket (
    movietitle STRING,
    count_users INT,
    review_year INT,
    review_month INT
)
CLUSTERED BY (movietitle) INTO 32 BUCKETS
STORED AS ORC;

INSERT OVERWRITE TABLE movielens.movie_count_users_bucket
SELECT
    movietitle,
    count_users,
    review_year,
    review_month
FROM movielens.movie_count_users;

SELECT * FROM movielens.movie_count_users_bucket LIMIT 5;

-- =========================================================
-- 8) SAMPLE QUESTIONS
-- =========================================================

-- Top 20 most rated movies in April 1998
SELECT *
FROM movielens.movie_count_users_bucket
WHERE review_year = 1998 AND review_month = 4
ORDER BY count_users DESC
LIMIT 20;

-- Top 20 highest average rated movies in April 1998
SELECT *
FROM movielens.movie_avg_rating_bucket
WHERE review_year = 1998 AND review_month = 4
ORDER BY avg_rating DESC
LIMIT 20;

-- =========================================================
-- END
-- =========================================================
