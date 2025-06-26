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

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
	DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH customer_aggregation AS(
SELECT 
	c.customer_key,
	c.customer_number,
	CONCAT(first_name, ' ', last_name) AS cust_name,
	DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age,
	MAX(f.order_date) AS last_order,
	CASE WHEN DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) >= 12 AND SUM(f.sales_amount) > 5000 THEN 'VIP'
         WHEN DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) >= 12 AND SUM(f.sales_amount) <= 5000 THEN 'Regular'
         ELSE 'New'
	END customer_segment,
	CASE WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) < 20 THEN 'Below 20'
	     WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 20 AND 39 THEN '20-39'
		 WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 40 AND 59 THEN '40-59'
		 ELSE '60 and above'
	END AS age_segment,
	COUNT(f.order_number) AS total_orders,
	SUM(f.sales_amount) AS total_sales,
	SUM(f.quantity) AS total_quantity,
	COUNT(f.product_key) AS total_products,
	DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
	c.customer_key,
	c.customer_number,
	CONCAT(first_name, ' ', last_name),
	DATEDIFF(YEAR, c.birthdate, GETDATE())
)

SELECT 
	customer_key,
	customer_number,
	cust_name,
	age,
	customer_segment,
	age_segment,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	DATEDIFF(MONTH, last_order, GETDATE()) AS recency,
	CASE WHEN total_orders = 0 THEN 0
	     ELSE total_sales / total_orders 
    END AS avg_order,
	CASE WHEN lifespan = 0 THEN total_sales
	     ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation

