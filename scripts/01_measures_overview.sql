/*============================================================================
File: 01_measures_overview.sql
Purpose:
    Provides high-level business KPIs from the data warehouse to understand
    overall performance across sales, customers, and products.

Description:
    This script calculates core performance measures such as total sales,
    total quantity sold, average product price, number of orders,
    number of products, and number of customers.

Layer Used:
    GOLD layer (fact and dimension tables)

Why it matters:
    These metrics give a quick snapshot of business scale and performance
    before diving into deeper analysis.
============================================================================*/

-- =============================== Measures Exploration ===============================

SELECT 'total_sales'      AS measure_name, SUM(sales_amount)              AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total_quantity',  SUM(quantity)                                   FROM gold.fact_sales
UNION ALL
SELECT 'avg_price',       AVG(price)                                       FROM gold.fact_sales
UNION ALL
SELECT 'total_orders',    COUNT(DISTINCT order_number)                     FROM gold.fact_sales
UNION ALL
SELECT 'total_products',  COUNT(product_key)                               FROM gold.dim_products
UNION ALL
SELECT 'total_customers', COUNT(customer_id)                               FROM gold.dim_customers;
