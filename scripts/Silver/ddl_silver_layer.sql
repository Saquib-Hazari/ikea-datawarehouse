INSERT INTO silver.customers(
  customer_id,
  customer_name,
  gender,
  date_of_birth,
  city, 
  state,
  country,
  category,
  sub_category
)
SELECT customer_id::INTEGER,
  INITCAP(TRIM(name)) AS customer_name,
  CASE 
    WHEN UPPER(TRIM(gender)) = 'M' OR LOWER(TRIM(gender)) = 'm' THEN 'Male'  
    WHEN UPPER(TRIM(gender)) = 'F' OR LOWER(TRIM(gender)) = 'f' THEN 'Female'
    ELSE 'n/a' 
  END AS gender,
    CASE
    WHEN dob ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN TO_DATE(dob, 'Month DD, YYYY')  -- March 12, 2004
    WHEN dob ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(dob, 'YYYY/MM/DD')         -- 1989/12/15
    WHEN dob ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN TO_DATE(dob, 'DD-MM-YYYY')         -- 12-10-1996
    WHEN dob ~ '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(dob, 'DD/MM/YY')           -- 20/05/99
    WHEN dob ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN TO_DATE(dob, 'DD/MM/YYYY')         -- fallback
    ELSE NULL
  END::DATE AS date_of_birth,
  city,
    CASE 
        WHEN LOWER(city) = 'new delhi' THEN 'Delhi'
        WHEN LOWER(city) = 'hyderabad' THEN 'Telangana'
        WHEN LOWER(city) = 'chennai' THEN 'Tamil Nadu'
        WHEN LOWER(city) = 'mumbai' THEN 'Maharashtra'
        WHEN LOWER(city) = 'bengaluru' THEN 'Karnataka'
        ELSE 'Unknown'
    END AS state,
  TRIM(country) AS country,
  CASE 
    WHEN UPPER(TRIM(category)) LIKE 'OUTDOOR%' THEN 'Outdoor'
    WHEN UPPER(TRIM(category)) LIKE 'OFFICE%' THEN 'Office'
    WHEN UPPER(TRIM(category)) LIKE 'KITCHEN%' THEN 'Kitchen'
    WHEN UPPER(TRIM(category)) LIKE 'HOME%' THEN 'Home'
    ELSE 'Unknown'
  END AS category,
  CASE 
    WHEN LOWER(subcategory) LIKE '%bed%' THEN 'Bed'
    WHEN LOWER(subcategory) LIKE '%desk%' THEN 'Desk'
    WHEN LOWER(subcategory) LIKE '%chair%' THEN 'Chair'
    WHEN LOWER(subcategory) LIKE '%lamp%' THEN 'Lamp'
    WHEN LOWER(subcategory) LIKE '%sofa%' THEN 'Sofa'
    WHEN LOWER(subcategory) LIKE '%table%' THEN 'Table'
    ELSE 'Unknown'
  END AS sub_category
FROM bronze.customers

-- Cleaning the customer_preference table
INSERT INTO silver.customer_preferences(
  customer_id,
  email_id,
  loyalty_points,
  feedback_score,
  preferred_store,
  newsletter_subscribed
)
SELECT 
  customer_id::INTEGER,
  CASE 
    WHEN email IS NULL THEN 'n/a'
    ELSE email
  END AS email,
  CASE 
    WHEN loyalty_points = 'NA' THEN NULL 
    ELSE  loyalty_points::NUMERIC(10,2)
  END AS loyalty_points,
  feedback_score::INTEGER,
  preferred_store,
  CASE WHEN newletter_subscribed IS NULL THEN 'n/a'
  WHEN UPPER(TRIM(newletter_subscribed)) = 'Y' THEN 'Yes'
  WHEN UPPER(TRIM(newletter_subscribed)) = 'Y' THEN 'Yes'
  WHEN UPPER(TRIM(newletter_subscribed)) = 'N' THEN 'No'
  WHEN LOWER(TRIM(newletter_subscribed)) = 'n' THEN 'No'
  ELSE newletter_subscribed
  END AS
  newsletter_subscribed
FROM customer_preferences


INSERT INTO silver.order_items (
  order_item_id,
  item_key,
  order_id,
  product_id,
  product_name,
  quantity,
  price,
  total_sales
)
SELECT 
  ROW_NUMBER() OVER()::INTEGER AS order_item_id,
  split_part(order_item_id, '-', 2)::INTEGER AS item_key,
  order_id::INTEGER,
  product_id::INTEGER,
  INITCAP(TRIM(item_name)) AS product_name,
  ABS(quantity::NUMERIC) AS quantity,
  price::NUMERIC,
  ABS(item_total::NUMERIC) AS told
FROM order_items

INSERT INTO silver.orders(
  order_id,
  customer_id,
  order_date,
  ship_date,
  due_date,
  order_status
)
SELECT 
  order_id::INTEGER,
  customer_id::INTEGER,
  order_date::DATE,
  ship_date::DATE,
  due_date::DATE,
  CASE 
    WHEN LOWER(order_status) ~ '^(open|opened)$' THEN 'Open'  
    WHEN LOWER(order_status) ~ '^(close|closed)$' THEN 'Close'  
    WHEN LOWER(order_status) ~ '^(shipped)$' THEN 'Close'  
    ELSE 'n/a'
  END AS order_status
  FROM orders;




INSERT INTO silver.products(
  product_id,
  product_name,
  category,
  sub_category,
  supplier_name,
  defect_flag
)

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

INSERT INTO silver.sales(
  order_id,
  product_id,
  quantity,
  price,
  total_sales,
  discount,
  net_sales
)

SELECT 
  order_id::INTEGER,
  product_id::INTEGER,
  ABS(quantity::NUMERIC) AS quantity,
  price::NUMERIC,
  item_total::NUMERIC AS total_sales,
  discount::NUMERIC,
  ROUND(ABS((net_sales::NUMERIC)),2) AS net_sales
FROM sales


