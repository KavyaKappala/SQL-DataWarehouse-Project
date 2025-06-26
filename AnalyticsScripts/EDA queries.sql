use DataWarehouse
----Find Youngest and oldest Customers
SELECT MIN(birthdate) AS oldest_customer,
       DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
       DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age,
       MAX(birthdate) AS youngest_customer
FROM gold.dim_customers

----Find Total Sales
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales 

----Find how many items are sold
SELECT SUM(quantity) AS items_sold
FROM gold.fact_sales

---Find average selling price
SELECT AVG(price) AS average_price
FROM gold.fact_sales

---Find total number of orders
SELECT COUNT(order_number) AS total_orders
FROM gold.fact_sales

SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales

---Find total number of products
SELECT COUNT(product_key) AS total_products
FROM gold.dim_products

---Find total number of customers
SELECT COUNT(customer_key) AS total_customers
FROM gold.dim_customers

---Find total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales

---Generate a report that shows all key metrics of business
SELECT 'Total_Sales' AS measure_name, SUM(sales_amount) AS mesure_value 
FROM gold.fact_sales
UNION ALL
SELECT 'Total_Quantity' AS measure_name, SUM(quantity) AS mesure_value 
FROM gold.fact_sales
UNION ALL
SELECT 'Avg_price' AS measure_name, AVG(price) AS mesure_value 
FROM gold.fact_sales
UNION ALL
SELECT 'No. of Orders' AS measure_name, COUNT(DISTINCT order_number) AS mesure_value 
FROM gold.fact_sales
UNION ALL
SELECT 'No. of Products' AS measure_name, COUNT(product_key) AS mesure_value 
FROM gold.dim_products
UNION ALL
SELECT 'No. of Customers' AS measure_name, COUNT(customer_key) AS mesure_value 
FROM gold.dim_customers




