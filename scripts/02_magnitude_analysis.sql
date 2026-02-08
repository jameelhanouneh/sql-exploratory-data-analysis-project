/*============================================================================
File: 02_magnitude_analysis.sql
Purpose:
    Analyzes the magnitude (volume and totals) of customers, products,
    and revenue across different business dimensions.

Description:
    This script explores how data is distributed across:
    - Countries
    - Genders
    - Product categories
    - Customers
    - Sales volume

Layer Used:
    GOLD layer (business-ready star schema)

Why it matters:
    Magnitude analysis helps identify major markets, key customer groups,
    and top-performing product categories.
============================================================================*/

-- ========================== Customers by Country ==========================
SELECT 
    country,
    COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;


-- ========================== Customers by Gender ==========================
SELECT 
    gender,
    COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY gender;


-- ========================== Products by Category ==========================
SELECT 
    category,
    COUNT(product_id) AS total_products
FROM gold.dim_products
GROUP BY category;


-- ========================== Average Cost by Category ==========================
SELECT 
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category;


-- ========================== Revenue by Category ==========================
SELECT 
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;


-- ========================== Revenue by Customer ==========================
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_revenue DESC;


-- ========================== Sold Items by Country ==========================
SELECT 
    c.country,
    SUM(f.quantity) AS total_items_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_items_sold DESC;
