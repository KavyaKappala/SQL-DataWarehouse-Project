---Calculate total sales for each month and running total of sales over time per year

SELECT order_month, total_sales,
       SUM(total_sales) OVER (PARTITION BY YEAR(order_month) ORDER BY order_month) AS running_sales
FROM(
    SELECT DATETRUNC(MONTH, order_date) AS order_month,
           SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date) 
)t

---Calculate total sales for each month and running total of sales over time

SELECT order_month, total_sales,
       SUM(total_sales) OVER (ORDER BY order_month) AS running_sales
FROM(
    SELECT DATETRUNC(MONTH, order_date) AS order_month,
           SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date) 
)t
