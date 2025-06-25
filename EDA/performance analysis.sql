/*Analyze yearly performance of products by comparing their sales to both 
average sales performance of product and previous year sales performance */

WITH yearly_sales_performance AS(
SELECT YEAR(f.order_date) AS order_year,
	   p.product_name,
	   SUM(sales_amount) AS current_sales
	  
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE f.order_date IS NOT NULL
GROUP BY p.product_name,YEAR(f.order_date)
)

SELECT order_year,
	   product_name,
	   current_sales,
	   AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	   current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	   CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above avg'
	        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEn 'Below avg'
			ELSE 'avg'
		END AS avg_change,
---Year-over-year analysis
		LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	   current_sales - (LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)) AS diff_py,
	   CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increased'
	        WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEn 'Decreased'
			ELSE 'No change'
		END AS py_change
FROM yearly_sales_performance
