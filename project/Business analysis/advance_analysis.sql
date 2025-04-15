-- ==============================================
-- SQL Analysis for Gold Layer Data Warehouse
-- ==============================================
-- This file contains advanced exploratory data analysis (EDA)
-- and business-focused insights based on the Gold schema of our data warehouse.
-- The analysis aims to address key business questions and help in strategic decision-making.
-- The following types of analysis are covered:
-- 
-- 1. **Customer Lifetime Value (CLTV) Tiering**
--    - Identifies high-value customers for loyalty and retention efforts using quartiles based on total revenue.
--    - Helps segment customers for targeted marketing and personalized offers.
-- 
-- 2. **Top Product Contributors by Revenue**
--    - Analyzes revenue generation by product and ranks products within categories.
--    - Helps prioritize products for promotion and inventory management.
-- 
-- 3. **Shipping Delay Analysis (vs. SLA)**
--    - Identifies customers with the highest shipping delays, supporting logistics improvement.
--    - Focuses on reducing delays to enhance customer satisfaction.
-- 
-- 4. **Repeat Customer Rate Over Time**
--    - Tracks customer loyalty by measuring the number of repeat purchases over time.
--    - Provides insights into customer retention trends and loyalty strategies.
-- 
-- 5. **Cohort Analysis: Customer Acquisition by Month**
--    - Provides insights into customer lifecycle by tracking cohort behavior over time.
--    - Helps evaluate the effectiveness of acquisition strategies and customer retention.
-- 
-- 6. **Category-Level Defect Rate Trend**
--    - Analyzes defect rates for each product category based on defect flags.
--    - Aims to help quality assurance and procurement teams focus on high-defect areas.
-- 
-- Techniques Used:
-- - **Window Functions**: Used for ranking, partitioning, and calculating averages across partitions of data (e.g., NTILE(), RANK()).
-- - **Common Table Expressions (CTEs)**: Used for modularizing complex queries and improving readability (e.g., cohort_base, customer_sales).
-- - **Aggregations**: Summarizing data at different levels (e.g., customer-level, product-category level).
-- - **Filters**: Applied within aggregations to compute specific metrics such as defect rate and sales.
-- ==============================================
-- 🔍 1. Customer Lifetime Value (CLTV) Tiering
-- Business Impact: Helps in identifying VIP customers for loyalty programs and personalized marketing.

WITH customer_sales AS (
SELECT customer_key,
  SUM(net_sales) AS total_revenue
FROM gold.fact_sales
GROUP BY customer_key
),
ranked_customers AS (
  SELECT *,
    NTILE(4) OVER(ORDER BY total_revenue DESC) AS cltv_quartile
  FROM customer_sales
)

SELECT cltv_quartile,
  COUNT(*) AS customer_count,
  ROUND(AVG(total_revenue),2) AS avg_revenue
FROM ranked_customers
GROUP BY cltv_quartile
ORDER BY cltv_quartile

-- 📦 2. Top Product Contributors by Revenue
-- Business Impact: Prioritize products generating high revenue for inventory and marketing strategy.
SELECT 
  p.product_name,
  p.category,
  SUM(f.net_sales) AS total_net_sales,
  RANK() OVER(PARTITION BY p.category ORDER BY SUM(f.net_sales))AS rank_in_category
FROM gold.dim_products p 
JOIN gold.fact_sales f ON f.product_key = p.product_key
GROUP BY p.product_name, p.category
HAVING SUM(f.net_sales) > 1
ORDER BY p.category, rank_in_category

-- 🧭 3. Shipping Delay Analysis (vs. SLA)

-- Business Impact: Helps logistics teams reduce shipping delays and improve customer satisfaction.
SELECT customer_key,
  ROUND(AVG(ship_date - order_date),2) AS avg_ship_days,
  RANK() OVER(ORDER BY AVG(ship_date - order_date) DESC) AS worst_ship_rank
FROM gold.fact_sales
GROUP BY customer_key
ORDER BY worst_ship_rank
LIMIT 10

-- 🕰 4. Repeat Customer Rate Over Time

-- Business Impact: Track retention and customer loyalty over months.

WITH first_orders AS (
  SELECT customer_key, MIN(order_date) AS first_order
  FROM gold.fact_sales
  GROUP BY customer_key
),
repeat_customers AS (
  SELECT fs.customer_key, EXTRACT('month' FROM fs.order_date) AS order_month
  FROM gold.fact_sales fs
  JOIN first_orders fo ON fs.customer_key = fo.customer_key
  WHERE fs.order_date > fo.first_order
)
SELECT 
  order_month,
  COUNT(DISTINCT customer_key) AS repeat_customers
FROM repeat_customers
GROUP BY order_month
ORDER BY order_month;

-- 📊 5. Cohort Analysis: Customer Acquisition by Month

-- Business Impact: Understand when your customers were acquired and how they behave over time.
WITH cohort_base AS(
  SELECT customer_key,
    MIN(DATE_TRUNC('month', order_date)) AS cohort_month
  FROM gold.fact_sales
  GROUP BY customer_key
),
sales_with_cohort AS(
  SELECT fs.customer_key,
    DATE_TRUNC('month', order_date) AS order_month,
    cb.cohort_month
  FROM gold.fact_sales fs
  JOIN cohort_base cb ON cb.customer_key = fs.customer_key
)

SELECT 
  cohort_month,
  order_month,
  COUNT(DISTINCT(customer_key)) AS active_customers
FROM sales_with_cohort
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month

-- 🚩 6. Category-Level Defect Rate Trend

-- Business Impact: Helps quality assurance and procurement teams mitigate high-defect areas.

SELECT 
  category,
  ROUND(100.0 * COUNT(*) FILTER (WHERE LOWER(defect_flag) = 'yes') / COUNT(*), 2) AS defect_rate,
  RANK() OVER (ORDER BY ROUND(100.0 * COUNT(*) FILTER (WHERE LOWER(defect_flag) = 'yes') / COUNT(*), 2) DESC) AS rank
FROM gold.dim_products
GROUP BY category;