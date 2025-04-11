# SQL_dashboard
## PROJECT OVERVIEW

**Project Title**: Sales Transaction Analysis

This repository contains SQL queries to analyze sales transactions data. The queries are designed to answer specific business questions related to sales, customers, and categories.

### OBJECTIVES

1. **Set up a retail sales database: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA): Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis: Use SQL to answer specific business questions and derive insights from the sales data


### Project Structure
### 1.Database Setup
- **Database Creation: The project starts by creating a database named p1_retail_db.
- **Table Creation: A table named retail_sales is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.


```sql
CREATE DATABASE sql_project_01;

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
```
### Data Exploration & Cleaning
- **Record Count: Determine the total number of records in the dataset.
- **Customer Count: Find out how many unique customers are in the dataset.
- **Category Count: Identify all unique product categories in the dataset.
- **Null Value Check: Check for any null values in the dataset and delete records with missing data.

'''sql
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

'''
### Data Analysis & Findings
The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**

'''sql
SELECT *
FROM sales_transactions
WHERE sale_date = '2022-11-05';
'''

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than or equal to 4 in the month of Nov-2022**
'''sql
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
'''

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**
'''sql
SELECT category, SUM(total_sale) AS total_sales
FROM sales_transactions
GROUP BY category;

-- include total count:
SELECT category,
	SUM(total_sale) AS net_sales,
	COUNT(*) AS total_order
FROM sales_transactions
GROUP BY category;
'''

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**
'''sql
SELECT AVG(age) AS average_age
FROM sales_transactions
WHERE category = 'Beauty';

SELECT ROUND(AVG(age), 2) AS average_age
FROM sales_transactions
WHERE category = 'Beauty';
'''

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**
'''sql
SELECT *
FROM sales_transactions
WHERE total_sale > 1000;

--TOTAL COUNT OF THE ABOVE SALE:
SELECT COUNT(*) AS high_value_sales
FROM sales_transactions
WHERE total_sale > 1000;
'''

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**
'''sql
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
'''

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.**
'''sql
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
'''

8. **Write a SQL query to find the top 5 customers based on the highest total sales.**
'''sql
SELECT customer_id, SUM(total_sale) AS total_sales
FROM sales_transactions
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
'''

9. **Write a SQL query to find the number of unique customers who purchased items from each category.
'''sql
SELECT 
    category, 
    COUNT(DISTINCT customer_id) AS unique_customers
FROM 
    sales_transactions
GROUP BY 
    category;
'''

10. **Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17).**
'''sql
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
'''


### Findings
- **Customer Demographics: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.**
- **High-Value Transactions: Several transactions had a total sale amount greater than 1000, indicating premium purchases.**
- **Sales Trends: Monthly analysis shows variations in sales, helping identify peak seasons.**
- **Customer Insights: The analysis identifies the top-spending customers and the most popular product categories.**

### Conclusion
This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.






























