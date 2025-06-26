/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
	DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH customer_aggregation AS(
SELECT 
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	MAX(f.order_date) AS last_order,
	CASE
		WHEN SUM(f.sales_amount) > 50000 THEN 'High-Performer'
		WHEN  SUM(f.sales_amount)>= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	COUNT(f.order_number) AS total_orders,
	SUM(f.sales_amount) AS total_sales,
	SUM(f.quantity) AS total_quantity,
	COUNT(DISTINCT f.customer_key) AS total_unique_customers,
	DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY 
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
)

SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	product_segment,
	total_orders,
	total_sales,
	total_quantity,
	total_unique_customers,
	lifespan,
	DATEDIFF(MONTH, last_order, GETDATE()) AS recency,
	CASE WHEN total_orders = 0 THEN 0
	     ELSE total_sales / total_orders 
    END AS avg_order,
	CASE WHEN lifespan = 0 THEN total_sales
	     ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation
