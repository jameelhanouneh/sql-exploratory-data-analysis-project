--================Products Report======================
/*
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
*/


/*-----------------------------------------------------------------------------------------------
1) Base query: Which contains all needed columns
-----------------------------------------------------------------------------------------------*/
IF OBJECT_ID('gold.report_products', 'v') IS NOT NULL
DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS
(
SELECT 
	p.product_name,
	p.category,
	p.subcategory,
	c.first_name,
	c.last_name,
	p.cost,
	s.order_number,
	s.sales_amount,
	s.quantity,
	s.order_date
FROM gold.dim_products p
LEFT JOIN gold.fact_sales s
	ON p.product_key = s.product_key
LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
WHERE s.order_number IS NOT NULL
),

/*-----------------------------------------------------------------------------------------------
2) Products Aggregations: Summarizes key metrics at the product level
-----------------------------------------------------------------------------------------------*/
products_aggregated AS
(
SELECT
	product_name,
	category,
	subcategory,
	COUNT(DISTINCT CONCAT(first_name, ' ', last_name)) AS total_customers,
	SUM(cost) AS total_cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY product_name, category, subcategory
)

/*-----------------------------------------------------------------------------------------------
3) Final Query: Combines all product results into one output and Calculating valuable KPIs
-----------------------------------------------------------------------------------------------*/
SELECT
	product_name,
	category,
	subcategory,
	total_customers,
	total_cost,
	total_orders,
	total_sales,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS average_order_revenue,
	total_quantity,
	CASE 
		WHEN total_sales <= 50000 THEN 'Low-Performers'
		WHEN total_sales < 100000 THEN 'Mid-Range'
		ELSE 'High-Performers'
	END AS products_segment,
	lifespan,
	CASE WHEN lifespan = 0 THEN 0
		 ELSE total_sales / lifespan 
	END AS average_monthly_revenue,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency
FROM products_aggregated;
