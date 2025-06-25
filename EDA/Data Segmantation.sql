---Segment products into cost ranges and count how many products fall into each segment
use DataWarehouse;
WITH product_segmants AS(
SELECT product_key,
       product_name,
       cost,
       CASE WHEN cost > 1000 THEN 'High Price'
            WHEN cost < 1000 THEN 'Less Price'
       END AS price_range
FROM gold.dim_products
)

SELECT price_range,
       COUNT(product_key) AS total_products
FROM product_segmants
GROUP BY price_range;

/*Group customers into three segments based on their spending behavior:
  -VIP: Customers with at least 12 months of history and spending more than $5,000.
  -Regular: Customers with atleast 12 months of history but spending $5000 or less.
  -New: Customers with life span less than 12 months.
And find total number of customers by each group.*/

WITH customer_sales_segments AS(
SELECT c.customer_id,
       MAX(order_date) AS last_order,
       MIN(f.order_date) AS first_order,
       DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan,
       SUM(f.sales_amount) AS customer_sales,
       CASE WHEN DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) >= 12 AND SUM(f.sales_amount) > 5000 THEN 'VIP'
            WHEN DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) >= 12 AND SUM(f.sales_amount) <= 5000 THEN 'Regular'
            ELSE 'New'
       END AS customer_segments
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_id
)

SELECT customer_segments,
       COUNT(customer_id) AS total_customers
FROM customer_sales_segments
GROUP BY customer_segments
ORDER BY total_customers DESC
