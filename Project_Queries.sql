-- create database
create database gold;

-- using database
use gold;

-- checking all the records
select * from dim_customers;
select * from dim_products;
select count(*) as number_rows from fact_sales;

-- Analysing total sales according by specific YEAR and total customer purchase in that specific year
SELECT * FROM fact_sales;
SELECT YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers	
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Analyzing over MONTH
SELECT MONTH(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity	
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- Analyzing with year and month
SELECT 
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity	,
COUNT(DISTINCT customer_key) AS total_customers	
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date);

-- retrive all first row of each month 
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_year_month,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_key) AS total_customers
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    DATE_FORMAT(order_date, '%Y-%m')
ORDER BY 
    DATE_FORMAT(order_date, '%Y-%m');
    
    -- to see month in string but it is not giving a proper order still
SELECT 
    DATE_FORMAT(order_date, '%Y-%b') AS order_year_month,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_key) AS total_customers
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    DATE_FORMAT(order_date, '%Y-%b')
ORDER BY 
    DATE_FORMAT(order_date, '%Y-%b');

-- calculate the total sales 
-- and the running total of sales over time 
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    avg(avg_price) over (ORDER BY order_date) as moving_avg_price
    FROM (
    SELECT 
        DATE_FORMAT(order_date, '%Y') AS order_date,
        SUM(sales_amount) AS total_sales,
        avg(price) as avg_price
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y')
) AS t;
SELECT 
    display_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY display_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY display_date) AS moving_avg_price
FROM (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m-01') AS display_date,  -- first day of month
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')  -- same as SELECT
) AS t
ORDER BY display_date;

-- Performance Analysis (Year-over-Year, Month-over-Month)--

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

select * from fact_sales;

WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales 
FROM fact_sales f
LEFT JOIN dim_products p 
ON f.product_key=p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY 
YEAR(f.order_date),
p.product_name
)
select order_year,
	product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name ) AS avg_sale,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name )  AS diff_avg,
    CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name ) > 0 THEN  'Above avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name ) < 0 THEN  'below avg'
        ELSE 'Avg'
        END AS avg_change,
	-- year - over - year Analysis -- 
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase' 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease' 
        ELSE 'NO change'
        END AS py_change
        FROM yearly_product_sales
        ORDER BY product_name,order_year;
        
-- PART - OF - WHOLE ANALYSE --
/* Which category contribute the mpst of overall the most to overall sales */

SELECT * FROM dim_productS ;

WITH category_sales AS (
    SELECT 
        p.category,
        SUM(f.sales_amount) AS total_sales 
    FROM fact_sales f 
    LEFT JOIN dim_products p
        ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
WHERE category IS NOT NULL   -- removes the blank last row
  AND category <> 'Components'  -- removes Components (first row)
ORDER BY total_sales DESC;
  
  
/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/
/*Segment products into cost ranges and 
count how many products fall into each segment*/

WITH product_segments AS (
SELECT 
	product_key,
    product_name,
    cost,
    CASE 
    WHEN cost < 100 THEN 'Below 100' 
    WHEN cost BETWEEN  100 AND 500 THEN '100 - 500 '
    WHEN cost BETWEEN  500 AND 1000 THEN '500 - 1000 '
    ELSE 'Above 1000'
    END AS cost_range
    FROM dim_products
)
SELECT 
	cost_range,
    COUNT(product_key) AS total_products 
    FROM product_segments
    GROUP BY cost_range
    ORDER BY total_products DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending AS
(SELECT 
	c.customer_key,
    SUM(f.sales_amount) AS total_Spending,
    MIN(order_date) AS First_Date,
    MAX(order_date) AS Last_Date,
	TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM fact_sales f 
    LEFT JOIN dim_customers c
    ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
    )
    SELECT 
		customer_segment ,
		COUNT(customer_key ) AS total_customers
        FROM (
				SELECT 
					customer_key,
                    CASE 
                    WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
                    WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'REGULAR'
                    ELSE 'NEW' 
                    END AS customer_segment
                    FROM customer_spending
			) AS segmented_customers
            GROUP BY customer_segment
            ORDER BY total_customers DESC; 
        
/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

CREATE VIEW report_customer AS
 WITH base_query AS
 /*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/   
  (SELECT 
  f.order_number,
  f.product_key,
  f.order_date,
  f.sales_amount,
  f.quantity,
  c.customer_key,
  c.customer_number,
  CONCAT(c.first_name,' ',c.last_name) AS customer_name,
  TIMESTAMPDIFF(year, c.birthdate,CURDATE()) AS age
  FROM fact_sales f
  LEFT JOIN dim_customers c 
  ON f.customer_key=c.customer_key
  WHERE f.order_date IS NOT NULL
  ), customer_aggregation AS
 /*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
 (SELECT 
	customer_key,
	 customer_number,
	customer_name,
	age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY customer_key,customer_number,customer_name,age
    )
    SELECT
    customer_key,
	 customer_number,
	customer_name,
	age,
    CASE 
		WHEN age < 20 THEN 'Under 20'
        WHEN age Between 20 AND 29 THEN '20-29'
		WHEN age Between 30 AND 39 THEN '30-39'
        WHEN age Between 40 AND 49 THEN '40-49'
        ELSE 'Above 50' 
        END AS age_group,
     CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'REGULAR'
		ELSE 'NEW' 
	  END AS customer_segment,
    last_order_date,
    timestampdiff(month,last_order_date,CURDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- compute average order value (AVO) --
    CASE 
    WHEN total_sales = 0 THEN 0
    ELSE
    total_sales / total_orders END AS avg_order_value,
   
-- Compute average montly spend
CASE 
WHEN
lifespan = 0 THEN total_sales 
ELSE total_sales / lifespan 
END AS avg_monthly_spend
FROM customer_aggregation;

SELECT * FROM report_customer;