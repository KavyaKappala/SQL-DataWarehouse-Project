---Analyze sales performance over time
SELECT DATETRUNC(MONTH, order_date) AS order_month,
       SUM(sales_amount) AS total_sales,
       COUNT(DISTINCT customer_key) AS total_customers,
       COUNT(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date) 
ORDER BY DATETRUNC(MONTH, order_date) 
