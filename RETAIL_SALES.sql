CREATE TABLE sales_transactions (
    transactions_id INT PRIMARY KEY, -- Unique identifier for each transaction
    sale_date DATE NOT NULL,         -- Date of the sale
    sale_time TIME NOT NULL,         -- Time of the sale
    customer_id INT NOT NULL,        -- Unique identifier for the customer
    gender VARCHAR(10),              -- Gender of the customer (e.g., 'Male', 'Female')
    age INT,                         -- Age of the customer
    category VARCHAR(50),            -- Category of the item sold
    quantity INT NOT NULL,           -- Quantity of items sold
    price_per_unit DECIMAL(10, 2),   -- Price per unit of the item
    cogs DECIMAL(10, 2),             -- Cost of goods sold
    total_sale DECIMAL(10, 2)        -- Total sale amount (quantity * price_per_unit)
);

-- DATA CLEANING


SELECT * FROM sales_transactions
LIMIT 10

SELECT 
	COUNT(*)
	FROM sales_transactions;

SELECT *
FROM sales_transactions
WHERE transactions_id = 0 OR customer_id = 0 OR age = 0 OR quantity = 0 OR price_per_unit = 0 OR cogs = 0 OR total_sale = 0
OR gender = '' OR category = '';

DELETE FROM sales_transactions
WHERE transactions_id = 0 OR customer_id = 0 OR age = 0 OR quantity = 0 OR price_per_unit = 0 OR cogs = 0 OR total_sale = 0
OR gender = '' OR category = '';


-- DATA EXPLORATION

--TOTAL SALES AND COUNT?

SELECT SUM(total_sale) AS total_sales
FROM sales_transactions;
SELECT 
	COUNT(*) AS total_sales
		FROM sales_transactions;

-- total unique customers?

SELECT 
	COUNT(DISTINCT customer_id) AS customer_no
		FROM sales_transactions;


-- TOTAL UNIQUE CATEGORY?

SELECT 
	COUNT(DISTINCT category) AS customer_no
		FROM sales_transactions;

SELECT 
	DISTINCT category
		FROM sales_transactions;


-- DATA ANALYSIS 

--Q1. Write a sql query to retrieve all columns for sales made on 22-11-05.
-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)




--Q1. Write a sql query to retrieve all columns for sales made on 22-11-05.

SELECT *
FROM sales_transactions
WHERE sale_date = '2022-11-05';



-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than or equal to 4 in the month of Nov-2022

SELECT category,
	SUM(quantity)
FROM sales_transactions
WHERE category = 'Clothing'
GROUP BY 1

SELECT *
FROM sales_transactions
WHERE category = 'Clothing'
AND quantity >= 4
AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category, SUM(total_sale) AS total_sales
FROM sales_transactions
GROUP BY category;

-- include total count:
SELECT category,
	SUM(total_sale) AS net_sales,
	COUNT(*) AS total_order
FROM sales_transactions
GROUP BY category;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT AVG(age) AS average_age
FROM sales_transactions
WHERE category = 'Beauty';

SELECT ROUND(AVG(age), 2) AS average_age
FROM sales_transactions
WHERE category = 'Beauty';


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *
FROM sales_transactions
WHERE total_sale > 1000;

--TOTAL COUNT OF THE ABOVE SALE:
SELECT COUNT(*) AS high_value_sales
FROM sales_transactions
WHERE total_sale > 1000;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT category, gender, COUNT(transactions_id) AS transaction_count
FROM sales_transactions
GROUP BY category, gender;


-- SOLVING USING CASE STATEMENT:
SELECT category,
       SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_transactions,
       SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_transactions
FROM sales_transactions
GROUP BY category;


-- USING FILTER STATMENT:
SELECT category,
       COUNT(*) FILTER(WHERE gender = 'Male') AS male_transactions,
       COUNT(*) FILTER(WHERE gender = 'Female') AS female_transactions
FROM sales_transactions
GROUP BY category;


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year


--AVERAGE SALES FOR EACH MONTH :
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    AVG(total_sale) AS average_sale
FROM 
    sales_transactions
GROUP BY 
    EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
ORDER BY 
    year, month;



-- BEST SELLING MONTH EACH YEAR:
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_sale) AS total_sales
    FROM 
        sales_transactions
    GROUP BY 
        EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
)
SELECT 
    year, 
    month, 
    total_sales
FROM (
    SELECT 
        year, 
        month, 
        total_sales,
        RANK() OVER (PARTITION BY year ORDER BY total_sales DESC) AS rank
    FROM 
        monthly_sales
) ranked_sales
WHERE rank = 1;

--**ALTERNATE METHOD:
SELECT * FROM
(
	SELECT
		EXTRACT(YEAR FROM sale_date) as year,
		EXTRACT(MONTH FROM sale_date) as month,
		AVG(total_sale) as avg_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale)DESC)  as rank
	FROM sales_transactions
	GROUP BY 1,2
) AS t1
WHERE rank= 1


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT customer_id, SUM(total_sale) AS total_sales
FROM sales_transactions
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT 
    category, 
    COUNT(DISTINCT customer_id) AS unique_customers
FROM 
    sales_transactions
GROUP BY 
    category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 13 AND 16 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(transactions_id) AS number_of_orders
FROM 
    sales_transactions
GROUP BY 
    CASE 
        WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 13 AND 16 THEN 'Afternoon'
        ELSE 'Evening'
    END
ORDER BY 
    shift;


--END OF PROJECT
