-- Create Database
CREATE DATABASE IF NOT EXISTS walmart_sales;

-- Create Table
CREATE TABLE IF NOT EXISTS sales (
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL , 
    city VARCHAR(30) NOT NULL ,
    customer_type VARCHAR(30) NOT NULL ,
    gender VARCHAR(10) NOT NULL ,
    product_line VARCHAR(100) NOT NULL ,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
    );
    
SELECT * FROM sales;

-------------------------------------- FEATURE ENGINEERING --------------------------------------

-- Add time_of_day column
SELECT time,
	CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening' 
	END AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening' 
	END  );

-- Add day_name column    
SELECT date,DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales 
SET day_name = DAYNAME(date);

-- Add month_name column
SELECT date, MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-------------------------------------- GENERIC --------------------------------------

-- How many unique cities does the data have?
SELECT DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT DISTINCT city, branch
FROM sales;

-------------------------------------- PRODUCT ----------------------------------------------

-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) AS unique_product_lines 
FROM sales;

-- What is the most common payment method?
SELECT payment_method, COUNT(payment_method) AS count
FROM sales
GROUP BY payment_method
ORDER BY count DESC;

-- What is the most selling product line?
SELECT product_line, COUNT(product_line) AS count
FROM sales
GROUP BY product_line
ORDER BY count DESC;

-- What is the total revenue by month?
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT month_name, SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT city, SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT product_line, AVG(vat) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT product_line, SUM(total) AS total_sales, 
CASE WHEN SUM(total) > AVG(total) THEN 'GOOD'
	 WHEN SUM(total) < AVG(total) THEN 'BAD'
     END AS status_of_sales
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS products_sold
FROM sales
GROUP BY branch
HAVING products_sold > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT product_line, gender, COUNT(gender) as cnt
FROM sales
GROUP BY product_line, gender
ORDER BY cnt DESC;

-- What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-------------------------------------- SALES --------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT time_of_day, COUNT(*) AS total_sales FROM sales
WHERE day_name='Sunday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, ROUND(AVG(VAT),2) AS VAT FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type, ROUND(AVG(VAT),2) AS VAT FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-------------------------------------- CUSTOMER --------------------------------------

-- How many unique customer types does the data have?
SELECT DISTINCT(customer_type) FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT(payment_method) FROM sales;

-- What is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS count FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT customer_type, COUNT(*) AS count FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT gender, COUNT(gender) AS count FROM sales
GROUP BY gender
ORDER BY count DESC;

-- What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS gender_count FROM sales
GROUP BY branch, gender
ORDER BY branch ;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS avg_rating FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, AVG(rating) AS avg_rating FROM sales
GROUP BY branch, time_of_day
ORDER BY branch;

-- Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) AS avg_rating FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
WITH cte AS (
SELECT branch, day_name, AVG(rating) AS avg_rating FROM sales
GROUP BY branch, day_name
ORDER BY branch)
SELECT branch, day_name, avg_rating 
FROM cte WHERE (branch, avg_rating) IN ( SELECT branch, MAX(avg_rating) FROM cte GROUP BY branch);


