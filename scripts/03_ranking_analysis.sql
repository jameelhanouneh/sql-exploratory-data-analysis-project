/*============================================================================
File: 03_ranking_analysis.sql
Purpose:
    Identifies top and bottom performing products and customers
    based on revenue contribution.

Description:
    Uses ranking window functions to highlight:
    - Top-selling products
    - Revenue contribution by product
    - Highest value customers

Layer Used:
    GOLD layer

Why it matters:
    Ranking analysis helps stakeholders focus on high-value products
    and customers for strategic decision-making.
============================================================================*/

-- ========================== Top 5 Products by Revenue ==========================
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY SUM(f.sales_amount) DESC;


-- ========================== Product Revenue Ranking ==========================
SELECT 
    p.product_name,
    SUM(f.sales_amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS product_rank
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_name;


-- ========================== Customer Revenue Ranking ==========================
SELECT 
    c.customer_number,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS customer_rank
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name;
