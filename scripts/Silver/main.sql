-- creating order_items cleansing analysis
SELECT 
  order_item_id,
  order_id,
  product_id,
  INITCAP(TRIM(item_name)) AS product_name,
  ABS(quantity::NUMERIC) AS quantity,
  price,
  ABS(item_total::NUMERIC) AS told
FROM order_items
LIMIT 100

SELECT 
  CASE 
    WHEN quantity::NUMERIC < 0 THEN ABS(quantity::NUMERIC)
    ELSE  quantity::NUMERIC(10,1)
  END AS quantity
FROM order_items;

SELECT ABS(item_total::NUMERIC) AS told
FROM order_items

SELECT product_id::INTEGER,
  INITCAP(TRIM(product_name)) AS product_names,
  CASE 
        WHEN LOWER(category) ~ 'outdoor' THEN 'Outdoor'
        WHEN LOWER(category) ~ 'kitchen' THEN 'Kitchen'
        WHEN LOWER(category) ~ 'office' THEN 'Office'
        WHEN LOWER(category) ~ 'home' THEN 'Home'
        ELSE 'Unknown'
    END AS category,
  CASE 
    WHEN LOWER(sub_category) ~ 'chair|cjair' THEN 'Chair'
    WHEN LOWER(sub_category) ~ 'lamp|iamp' THEN 'Lamp'
    WHEN LOWER(sub_category) ~ 'desk|djsk' THEN 'Desk'
    WHEN LOWER(sub_category) ~ 'sofa|swfa|sbfa' THEN 'Sofa'
    WHEN LOWER(sub_category) ~ 'table' THEN 'Table'
    WHEN LOWER(sub_category) ~ 'bed' THEN 'Bed'
    ELSE 'Unknown' 
END AS sub_category,
  INITCAP(TRIM(REPLACE (supplier_name, '-', ' '))) AS supplier_name,
  CASE 
    WHEN defect_flag = 'N' THEN 'No'  
    WHEN defect_flag = 'Y' THEN 'Yes'  
    WHEN defect_flag = '1' THEN 'Yes'
    WHEN defect_flag = '0' THEN 'No'
    ELSE  'Unknown'
  END AS defect_flag
FROM products

SELECT  sub_category,
  ROW_NUMBER() OVER() AS row_number
FROM (
SELECT 
   CASE 
    WHEN LOWER(sub_category) ~ 'chair|cjair' THEN 'Chair'
    WHEN LOWER(sub_category) ~ 'lamp|iamp' THEN 'Lamp'
    WHEN LOWER(sub_category) ~ 'desk|djsk' THEN 'Desk'
    WHEN LOWER(sub_category) ~ 'sofa|swfa|sbfa' THEN 'Sofa'
    WHEN LOWER(sub_category) ~ 'table' THEN 'Table'
    WHEN LOWER(sub_category) ~ 'bed' THEN 'Bed'
    ELSE 'Unknown' 
END AS sub_category
FROM products
)t

SELECT CASE 
  WHEN defect_flag = 'N' THEN 'No'  
  WHEN defect_flag = 'Y' THEN 'Yes'  
  WHEN defect_flag = '1' THEN 'Yes'
  WHEN defect_flag = '0' THEN 'No'
  ELSE  'Unknown'
END AS defect_flag
FROM products

SELECT INITCAP(TRIM(REPLACE (supplier_name, '-', ' '))) AS supplier_name
FROM products
