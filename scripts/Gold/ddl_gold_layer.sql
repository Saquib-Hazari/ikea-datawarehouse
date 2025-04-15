-- ===============================================
-- 🏗️ GOLD LAYER CREATION (STAR SCHEMA DESIGN)
-- ===============================================
-- This script creates the Gold Layer with:
-- • dim_customers: Enriched customer info with surrogate key.
-- • dim_products: Product master data with surrogate key.
-- • fact_sales: Sales transactions joined with customer & product dimensions.
-- • Surrogate keys generated using ROW_NUMBER().
-- • Enables efficient joins and analytics in BI tools.
-- ===============================================
CREATE SCHEMA IF NOT EXISTS gold;
DROP TABLE IF EXISTS gold.dim_customers;
CREATE TABLE gold.dim_customers AS
SELECT 
  ROW_NUMBER() OVER(ORDER BY c.customer_id) AS customer_key, -- Surrogate key
  c.customer_id,
  c.customer_name,
  c.gender,
  c.date_of_birth,
  c.state,
  c.city,
  c.country,
  c.category,
  c.sub_category,
  cp.email_id,
  cp.feedback_score,
  cp.loyalty_points,
  cp.newsletter_subscribed,
  COALESCE(cp.preferred_store, 'Unknown') AS preferred_store
FROM silver.customers c 
LEFT JOIN silver.customer_preferences cp 
  ON cp.customer_id = c.customer_id;

-- FACT: fact_sales_orders
DROP TABLE IF EXISTS gold.fact_sales;
CREATE TABLE gold.fact_sales AS
SELECT 
  ROW_NUMBER() OVER(ORDER BY o.order_id) AS sales_order_key, -- Fact table surrogate key
  dc.customer_key,
  dp.product_key,
  o.order_id,
  o.order_date,
  o.ship_date,
  o.due_date,
  o.order_status,
  oi.quantity,
  oi.price,
  oi.total_sales,
  s.discount,
  s.net_sales
FROM silver.orders o
JOIN silver.order_items oi ON o.order_id = oi.order_id
JOIN silver.sales s ON s.order_id = o.order_id AND s.product_id = oi.product_id
JOIN gold.dim_customers dc ON dc.customer_id = o.customer_id
JOIN gold.dim_products dp ON dp.product_id = oi.product_id;


-- DIMENSION: dim_products
DROP TABLE IF EXISTS gold.dim_products;
CREATE TABLE gold.dim_products AS
SELECT 
  ROW_NUMBER() OVER(ORDER BY p.product_id) AS product_key, -- Surrogate key
  p.product_id,
  p.product_name,
  p.category,
  p.sub_category,
  p.supplier_name,
  p.defect_flag
FROM silver.products p;

