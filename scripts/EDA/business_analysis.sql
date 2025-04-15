-- ===============================================================
-- 📊 Business Intelligence Analysis on Gold Layer Schema
-- ===============================================================
-- Purpose:
-- This SQL script performs customer, product, and time-based analysis
-- using the Gold Layer of the data warehouse. It provides actionable
-- insights for business decision-making across marketing, sales,
-- operations, and customer success functions.

-- Business Use Cases Covered:
-- ----------------------------
-- 👥 Customer Insights:
-- 1. Top 10 Most Valuable Customers - Identify key revenue contributors.
-- 2. CLTV by Age Group - Tailor campaigns by customer demographics.
-- 3. Churn Risk Indicator - Proactively target inactive customers.

-- 📦 Product & Supplier Analysis:
-- 4. Top-Selling Categories - Prioritize high-performing product categories.
-- 5. Defect Rate by Category - Improve product quality through defect tracking.
-- 6. Top Suppliers by Volume - Identify suppliers responsible for major product flows.

-- 📅 Time-Based Trends:
-- 7. Monthly Sales Trend - Analyze seasonal patterns and performance spikes.
-- 8. Avg. Order Size Per Month - Monitor efficiency and customer purchasing behavior.

-- 🚚 Operational Efficiency:
-- 9. Shipping Time Analysis - Assess delivery performance and SLA compliance.
-- 10. Net Sales vs. Discounts - Understand tradeoffs between discounting and revenue.

-- Key Techniques:
-- ---------------
-- ✅ JOINs across dimensions and fact tables to build context-rich aggregations.
-- ✅ Window Functions for ranking, partitioning, and time-based segmentation.
-- ✅ CTEs (Common Table Expressions) for breaking down complex logic.
-- ✅ Filters with conditional logic to isolate subsets like defective products or recent orders.
-- ✅ Calculated Metrics (e.g., discount-to-sales ratio, order size) for business performance monitoring.

-- Business Impact:
-- ----------------
-- These insights are designed to support strategic decisions in:
-- - Customer segmentation and loyalty programs
-- - Inventory prioritization and supply chain optimization
-- - Sales planning and seasonal promotions
-- - Operational improvements in shipping and order processing
-- - Profitability analysis and discount strategies

-- ===============================================================
--1. Top 10 Most Valuable Customers (by Net Sales)
SELECT
  c.customer_id,
  c.customer_name,
  f.net_sales,
  SUM(f.net_sales) AS total_net_sale
FROM gold.dim_customers c 
JOIN gold.fact_sales f ON f.customer_key = c.customer_key
WHERE f.net_sales IS NOT NULL
GROUP BY c.customer_id, c.customer_name, f.net_sales
ORDER BY total_net_sale DESC
LIMIT 10

-- 2. Customer Lifetime Value by Age Group
SELECT
  c.customer_id,
  c.customer_name,
  DATE_PART('year', AGE(c.date_of_birth)) AS age,
  SUM(f.net_sales) AS lifetime_value
FROM gold.dim_customers c 
JOIN gold.fact_sales f ON f.customer_key = c.customer_key
WHERE f.net_sales IS NOT NULL
GROUP BY c.customer_id, c.date_of_birth,c.customer_name
LIMIT 100

-- 3. Churn Risk Indicator (Low Recent Activity)
SELECT 
  c.customer_id,
  c.customer_name,
  MAX(f.order_date) AS last_order_date
FROM gold.dim_customers c 
JOIN gold.fact_sales f ON f.customer_key = c.customer_key
GROUP BY c.customer_id, c.customer_name
HAVING MAX(f.order_date) < CURRENT_DATE - INTERVAL '90 days'

--Products and Sales analysis
-- 4. Top-Selling Product Categories (by Net Sales)
SELECT 
  p.category,
  SUM(f.net_sales) AS total_net_sales
FROM gold.dim_products p 
JOIN gold.fact_sales f ON f.product_key  = p.product_key
GROUP BY p.category
ORDER BY total_net_sales DESC

-- 5. Defect Rate by Product Category
SELECT
  category,
  COUNT(*) FILTER (WHERE LOWER(defect_flag) = 'yes') AS defective_count,
  COUNT(*) AS total_products,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE LOWER(defect_flag) = 'yes') / COUNT(*), 
    2
  ) AS defect_percentage
FROM gold.dim_products
GROUP BY category
ORDER BY defect_percentage DESC;

SELECT *
FROM gold.dim_products
LIMIT 10

-- 6. Top Suppliers by Volume
SELECT p.product_id,
  p.supplier_name,
  SUM(f.order_id) AS total_orders
FROM gold.dim_products p
JOIN gold.fact_sales f ON f.product_key = p.product_key
GROUP BY p.product_id, p.supplier_name
ORDER BY total_orders DESC
LIMIT 10

--📅 Time-Based Sales Insights
-- 7. Monthly Sales Trend
SELECT
  EXTRACT('month' FROM order_date) AS order_months,
  SUM(net_sales) AS total_net_sales
FROM gold.fact_sales
GROUP BY order_months
ORDER BY total_net_sales DESC


-- 8. Average Order Size Per Month
WITH monthly_orders AS (
SELECT
  EXTRACT('month' FROM order_date) AS order_month,
  COUNT(DISTINCT order_id) AS total_orders,
  SUM(net_sales) AS total_net_sales
FROM gold.fact_sales
GROUP BY order_month
)
SELECT
  order_month,
  ROUND(total_orders/total_net_sales * 100000,2) AS avg_order_size
FROM monthly_orders


-- 📈 Sales Efficiency Metrics

-- 9. Shipping Time Analysis
SELECT 
  ROUND(AVG(ship_date - order_date),3) AS avg_ship_days,
  ROUND(AVG(due_date - order_date),3) AS avg_due_days
FROM gold.fact_sales

-- 10. Net Sales vs Discounts by Category
SELECT
  p.category,
  SUM(f.net_sales) AS total_net_sales,
  SUM(f.discount) AS total_discount,
  ROUND(SUM(f.discount) / NULLIF(SUM(f.net_sales), 0), 2) AS discount_to_sales_ratio
FROM gold.dim_products p 
JOIN gold.fact_sales f ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY discount_to_sales_ratio DESC