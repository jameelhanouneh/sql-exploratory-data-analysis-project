/*
======================================================================
Customer Report
======================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors
Highlights:
	1. Gather essential fields such as names, ages , and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups
	3. Aggregates customer-level metrics:
		- total orders
		- totals sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
======================================================================
*/
--Base Query: Retrieves core columns from tables
IF OBJECT_ID('gold.report_customers', 'v') IS NOT NULL
DROP VIEW gold.report_customers;
GO
CREATE VIEW gold.report_customers AS 
WITH base_query AS(
SELECT 
	c.customer_number,
	CONCAT(c.first_name,' ', c.last_name) customer_name, 
	DATEDIFF(YEAR,c.birthdate, GETDATE()) age,
	f.order_number,
	p.product_name,
	f.order_date,
	f.sales_amount,
	f.quantity
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
)

--=============================Aggregations Query=============================
,customer_aggregation AS(
SELECT
	customer_number,
	customer_name, 
	age,
	COUNT(order_number) total_orders,
	SUM(sales_amount) total_sales,
	SUM(quantity)total_quantity,
	COUNT(DISTINCT product_name)total_product,
	MAX(order_date) last_order_date,
	DATEDIFF(MONTH,MIN(order_date), MAX(order_date)) lifespan
FROM base_query
GROUP BY customer_number, customer_name, age
)
--===========================Final Results=======================
SELECT
	customer_number,
	customer_name, 
	age,
	CASE WHEN age <20 THEN 'Under 20'
		 WHEN age between 20 AND 29 THEN '20-29'
		 WHEN age between 30 AND 39 THEN '30-39'
		 WHEN age between 40 AND 49 THEN '40-49'
		 ELSE '50 and above'
	END age_group,
	CASE WHEN total_sales> 5000 AND lifespan>=12 THEN 'VIP' 
		 WHEN total_sales <= 5000 AND lifespan>=12 THEN 'Regular'
		 ELSE 'New'
	END customer_segment,
	DATEDIFF(MONTH, last_order_date, GETDATE()) recency,
	total_orders,
	total_sales,
	total_quantity,
	total_product,
	--Compute average order value (AVO)
	CASE WHEN total_orders = 0 THEN 0
	ELSE total_sales/ total_orders
	END AS Average_order_value,
	--Compute average monthly spend
	CASE WHEN lifespan = 0 THEN 0
		 ELSE total_sales/lifespan
	END average_monthly_spend,
	lifespan
FROM customer_aggregation
