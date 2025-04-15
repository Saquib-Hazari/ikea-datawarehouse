-- ================================================
-- 📊 EXPLORATORY DATA ANALYSIS ON GOLD LAYER
-- ================================================
-- 1. Inspect gold schema tables and their structures.
-- 2. Record counts for dim_customers, dim_products, fact_sales.
-- 3. Perform EDA on:
--    • dim_customers → gender, age, preferred_store
--    • dim_products → category, defect_flag, top suppliers
--    • fact_sales → monthly orders, shipping times, sales by status
-- 4. Run schema health checks:
--    • Foreign key constraint mapping
--    • Index definitions across all gold tables
-- ================================================
-- EDA on GOLD schemas

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'gold'
  AND table_type = 'BASE TABLE';

SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'gold'
  AND table_name = 'your_table_name';

SELECT 'dim_customers' AS table_name, COUNT(*) FROM gold.dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM gold.fact_sales;

-- EDA on dim_customers
SELECT gender, COUNT(*) FROM gold.dim_customers GROUP BY gender;

SELECT DATE_PART('year', AGE(date_of_birth)) AS age, COUNT(*)
FROM gold.dim_customers
GROUP BY age ORDER BY age;

SELECT preferred_store, COUNT(*)
FROM gold.dim_customers
GROUP BY preferred_store
ORDER BY COUNT(*) DESC;

-- EDA on dim_products
SELECT category, COUNT(*)
FROM gold.dim_products
GROUP BY category ORDER BY COUNT(*) DESC;

SELECT defect_flag, COUNT(*)
FROM gold.dim_products
GROUP BY defect_flag;

SELECT supplier_name, COUNT(*)
FROM gold.dim_products
GROUP BY supplier_name
ORDER BY COUNT(*) DESC
LIMIT 10;

-- EDA of fact_sales
SELECT DATE_TRUNC('month', order_date) AS order_month, COUNT(*)
FROM gold.fact_sales
GROUP BY order_month
ORDER BY order_month;

SELECT
  AVG(ship_date - order_date) AS avg_shipping_days,
  MAX(ship_date - order_date) AS max_shipping_days
FROM gold.fact_sales;

SELECT order_status, SUM(net_sales) AS total_sales
FROM gold.fact_sales
GROUP BY order_status;

-- Schema health checks
SELECT
    conname AS constraint_name,
    conrelid::regclass AS table_from,
    a.attname AS column_from,
    confrelid::regclass AS table_to,
    af.attname AS column_to
FROM   pg_constraint
JOIN   pg_class ON conrelid = pg_class.oid
JOIN   pg_attribute a ON a.attrelid = conrelid AND a.attnum = ANY(conkey)
JOIN   pg_attribute af ON af.attrelid = confrelid AND af.attnum = ANY(confkey)
WHERE  contype = 'f'
AND    pg_class.relnamespace::regnamespace::text = 'gold';

-- List all index
SELECT
    tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'gold';