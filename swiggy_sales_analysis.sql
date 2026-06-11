CREATE DATABASE swiggy;
USE swiggy;
CREATE TABLE swiggy_sales (
    state VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    order_date DATE NOT NULL,
    restaurant_name VARCHAR(200),
    location VARCHAR(100),
    category VARCHAR(100),
    dish_name VARCHAR(255),
    price DOUBLE NOT NULL,
    rating DOUBLE,
    rating_count INT
);

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/EXCEL/Swiggy_Dataa.csv'
INTO TABLE swiggy_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(state, city, order_date, restaurant_name, location, category,
dish_name, price, rating, rating_count);


SELECT*FROM swiggy_sales;
SELECT COUNT(*) FROM swiggy_sales;

-- Data Validation & Cleaning
-- Null check 
SELECT 
    SUM(CASE
        WHEN state IS NULL THEN 1
        ELSE 0
    END) AS null_state,
    SUM(CASE
        WHEN city IS NULL THEN 1
        ELSE 0
    END) AS null_city,
    SUM(CASE
        WHEN order_date IS NULL THEN 1
        ELSE 0
    END) AS null_order_date,
    SUM(CASE
        WHEN restaurant_name IS NULL THEN 1
        ELSE 0
    END) AS null_restaurant_name,
    SUM(CASE
        WHEN location IS NULL THEN 1
        ELSE 0
    END) AS null_location,
    SUM(CASE
        WHEN category IS NULL THEN 1
        ELSE 0
    END) AS null_category,
    SUM(CASE
        WHEN dish_name IS NULL THEN 1
        ELSE 0
    END) AS null_dish_name,
    SUM(CASE
        WHEN price IS NULL THEN 1
        ELSE 0
    END) AS null_price,
    SUM(CASE
        WHEN rating IS NULL THEN 1
        ELSE 0
    END) AS null_rating,
    SUM(CASE
        WHEN rating_count IS NULL THEN 1
        ELSE 0
    END) AS null_rating_count
FROM
    swiggy_sales;


-- Blank or Empty Strings in the data

SELECT 
    *
FROM
    swiggy_sales
WHERE
    state = '' OR city = ''
        OR restaurant_name = ''
        OR location = ''
        OR category = ''
        OR dish_name = '';
        
        
-- Duplicate Detection
SELECT *,
       COUNT(*) AS duplicate_count
FROM swiggy_sales
GROUP BY state, city, order_date, restaurant_name, location,
         category, dish_name, price, rating, rating_count
HAVING COUNT(*) > 1;

-- Delete Duplication

CREATE TABLE swiggy_sales_clean AS
SELECT DISTINCT *
FROM swiggy_sales;

SELECT COUNT(*) AS original_rows
FROM swiggy_sales;

SELECT COUNT(*) AS cleaned_rows
FROM swiggy_sales_clean;

DROP TABLE swiggy_sales;

RENAME TABLE swiggy_sales_clean TO swiggy_sales;

-- Creating Schema
-- Dimensions Table
-- Date Table
CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE NOT NULL,
    year_num INT,
    month_num INT,
    month_name VARCHAR(50),
    quarter_num INT,
    day_num INT,
    week_num INT
);

SELECT* FROM dim_date;

-- dim location
CREATE TABLE dim_location(
location_id INT AUTO_INCREMENT PRIMARY KEY,
state VARCHAR (100),
city VARCHAR(100),
location VARCHAR (200)
);

-- dim restaurant
CREATE TABLE dim_restaurant(
restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
restaurant_name VARCHAR(100)
);

-- dim category
CREATE TABLE dim_category(
category_id INT AUTO_INCREMENT PRIMARY KEY,
category VARCHAR (200)
);

-- dim dish
CREATE TABLE dim_dish(
dish_id INT AUTO_INCREMENT PRIMARY KEY,
dish_name VARCHAR (200)
);

-- fact table
CREATE TABLE swiggy_orders(
order_id INT AUTO_INCREMENT PRIMARY KEY,
date_id INT,
price DECIMAL (10,2),
rating DECIMAL (4,2),
rating_count INT,

location_id INT,
restaurant_id INT,
category_id INT,
dish_id INT,

FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

SELECT* FROM swiggy_orders;

-- INSERT DATA INTO TABLES
-- dim_date
INSERT INTO dim_date (
    full_date,
    year_num,
    month_num,
    month_name,
    quarter_num,
    day_num,
    week_num
)
SELECT DISTINCT
    order_date,
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    QUARTER(order_date),
    DAY(order_date),
    WEEK(order_date)
FROM swiggy_sales
WHERE order_date IS NOT NULL;

SELECT* FROM dim_date;

-- dim_location
INSERT INTO dim_location(
state,
city, 
location
)
SELECT DISTINCT state, city, location
FROM swiggy_sales;

SELECT* FROM dim_location;

-- dim restaurant
INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT 
restaurant_name
FROM swiggy_sales;
SELECT* FROM dim_restaurant;

-- dim category
INSERT INTO dim_category (category)
SELECT DISTINCT
category 
FROM swiggy_sales;
SELECT* FROM dim_category;

-- dim dish
INSERT INTO dim_dish (dish_name)
SELECT DISTINCT
dish_name
FROM swiggy_sales;
SELECT* FROM dim_dish;

-- swiggy_orders fact table

INSERT INTO swiggy_orders (
date_id,
price,
rating,
rating_count,
location_id,
restaurant_id,
category_id,
dish_id
)
SELECT DISTINCT 
dd.date_id,
s.price,
s.rating,
s.rating_count,

dl.location_id,
dr.restaurant_id,
dc.category_id,
dsh.dish_id

FROM swiggy_sales s
JOIN
dim_date dd
ON dd.full_date = s.order_date

JOIN
dim_location dl
ON dl.state = s.state
AND dl.city = s.city
AND dl.location = s.location

JOIN
dim_restaurant dr
ON dr.restaurant_name = s.restaurant_name

JOIN 
dim_category dc
ON dc.category = s.category

JOIN
dim_dish dsh
ON dsh.dish_name = s.dish_name;

SELECT*FROM swiggy_orders;

SELECT * FROM swiggy_orders so
JOIN dim_date d ON so.date_id = d.date_id
JOIN dim_location dl ON so.location_id = dl.location_id
JOIN dim_restaurant dr ON so.restaurant_id = dr.restaurant_id
JOIN dim_category dc ON so.category_id = dc.category_id
JOIN dim_dish di ON so.dish_id = di.dish_id;

-- KPIs
-- Total Orders
SELECT COUNT(*) AS Total_Orders
FROM swiggy_orders;

-- Total Rvenue
SELECT 
CONCAT(
    FORMAT(SUM(price) / 1000000, 2),
    ' INR Million'
) AS Total_Revenue
FROM swiggy_orders;

-- Avg Dish Price

SELECT 
    CONCAT(
        FORMAT(AVG(price), 2),
        ' INR'
    ) AS Average_Dish_Price
FROM swiggy_orders;

-- Average Rating
SELECT 
AVG(rating) AS Avg_rating
FROM swiggy_orders;

-- Deep Dive Business Analysis

-- Monthly Order Trends
SELECT
d.year_num,
d.month_num,
d.month_name,
COUNT(*) AS Total_Orders 
FROM swiggy_orders so
JOIN dim_date d
ON so.date_id = d.date_id
GROUP BY 
d.year_num,
d.month_num,
d.month_name
ORDER BY COUNT(*) DESC;


-- Total Revenue

SELECT
d.year_num,
d.month_num,
d.month_name,
SUM(price) AS Total_Revenue 
FROM swiggy_orders so
JOIN dim_date d
ON so.date_id = d.date_id
GROUP BY 
d.year_num,
d.month_num,
d.month_name
ORDER BY SUM(price) DESC;

-- Quarterly Trend

SELECT
d.year_num,
d.quarter_num,
COUNT(*) AS Total_Orders 
FROM swiggy_orders so
JOIN dim_date d
ON so.date_id = d.date_id
GROUP BY 
d.year_num,
d.quarter_num
ORDER BY COUNT(*) DESC;

-- Yearly Trend
SELECT
d.year_num,
COUNT(*) AS Total_Orders 
FROM swiggy_orders so
JOIN dim_date d
ON so.date_id = d.date_id
GROUP BY 
d.year_num
ORDER BY COUNT(*) DESC;

-- Order by day of the week (Mon - Sun)
SELECT
    DAYNAME(d.full_date) AS day_name,
    COUNT(*) AS total_orders
FROM swiggy_orders so
JOIN dim_date d
    ON so.date_id = d.date_id
GROUP BY
    DAYNAME(d.full_date),
    DAYOFWEEK(d.full_date)
ORDER BY
    DAYOFWEEK(d.full_date);
    
-- Top 10 cities by order volume

SELECT dl.city,
COUNT(*) AS Total_orders FROM swiggy_orders so
JOIN dim_location dl
ON dl.location_id = so.location_id
GROUP BY dl.city
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Top 10 cities by revenue

SELECT dl.city,
SUM(so.price) AS Total_Revenue FROM swiggy_orders so
JOIN dim_location dl
ON dl.location_id = so.location_id
GROUP BY dl.city
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Revenue contribution by States

SELECT dl.state,
SUM(so.price) AS Total_Revenue FROM swiggy_orders so
JOIN dim_location dl
ON dl.location_id = so.location_id
GROUP BY dl.state
ORDER BY Total_Revenue DESC
;


-- Top 10 restaurants by order
SELECT dr.restaurant_name,
SUM(so.price) AS Total_Revenue FROM swiggy_orders so
JOIN dim_restaurant dr
ON dr.restaurant_id = so.restaurant_id
GROUP BY dr.restaurant_name
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Top categories by order volume
SELECT
dc.category, COUNT(*) AS total_orders
FROM swiggy_orders so
JOIN dim_category dc
ON dc.category_id = so.category_id
GROUP BY dc.category
ORDER BY total_orders DESC;

-- Most ordered dish

SELECT
ds.dish_name, COUNT(*) AS most_ordered_dish
FROM swiggy_orders so
JOIN dim_dish ds
ON ds.dish_id = so.dish_id
GROUP BY ds.dish_name
ORDER BY most_ordered_dish DESC
LIMIT 10;


-- Cuisine Performance
SELECT
    dc.category,
    COUNT(*) AS total_orders,
    ROUND(AVG(so.rating), 2) AS avg_rating
FROM swiggy_orders so
JOIN dim_category dc
    ON dc.category_id = so.category_id
GROUP BY dc.category
ORDER BY total_orders DESC
;

-- Total Orders by price range

SELECT
    CASE
        WHEN CAST(price AS DECIMAL(10,2)) < 100 THEN 'Under 100'
        WHEN CAST(price AS DECIMAL(10,2)) BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN CAST(price AS DECIMAL(10,2)) BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN CAST(price AS DECIMAL(10,2)) BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END AS price_range,
    COUNT(*) AS total_orders
FROM swiggy_orders
GROUP BY
    CASE
        WHEN CAST(price AS DECIMAL(10,2)) < 100 THEN 'Under 100'
        WHEN CAST(price AS DECIMAL(10,2)) BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN CAST(price AS DECIMAL(10,2)) BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN CAST(price AS DECIMAL(10,2)) BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END
ORDER BY total_orders DESC;

-- Rating count distribution
SELECT rating, COUNT(*) AS rating_count
FROM swiggy_orders
GROUP BY rating
ORDER BY rating_count DESC;

SELECT COUNT(*) FROM swiggy_sales;