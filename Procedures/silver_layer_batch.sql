/*
==============================================================
💾 SILVER LAYER TRANSFORMATION & DATA CLEANING OVERVIEW
==============================================================

This procedure transforms raw Bronze Layer data into a cleaned, 
standardized, and normalized Silver Layer by applying the following
data cleaning steps:

1. TRUNCATION:
   - Truncates all target Silver Layer tables (`silver.customers`, 
     `silver.customer_preferences`, `silver.order_items`, etc.) 
     before reloading to avoid duplicates or append errors.

2. CUSTOMERS TABLE CLEANING (`silver.customers`):
   - Trimmed and title-cased customer names.
   - Gender values standardized to 'Male', 'Female', or 'n/a'.
   - Normalized multiple inconsistent `dob` date formats using pattern matching.
   - Mapped cities to Indian states using case-insensitive matching.
   - Cleaned category and sub-category using partial keyword-based mapping.

3. CUSTOMER PREFERENCES CLEANING (`silver.customer_preferences`):
   - Null emails filled with 'n/a'.
   - Converted 'NA' loyalty points to `NULL`, others to numeric.
   - Standardized newsletter subscription to 'Yes', 'No', or 'n/a' 
     based on inconsistent representations (Y/N, y/n, null, etc.).

4. ORDER ITEMS CLEANING (`silver.order_items`):
   - Derived `order_item_id` using `ROW_NUMBER()` to ensure uniqueness.
   - Extracted numeric `item_key` from composite ID.
   - Standardized product names with `INITCAP`.
   - Enforced positive quantity and total sales using `ABS()`.

5. ORDERS TABLE CLEANING (`silver.orders`):
   - Standardized order statuses using regex:
     'open/opened' → 'Open', 'closed/shipped' → 'Close', else 'n/a'.
   - Converted order, ship, and due dates to proper date format.

6. PRODUCTS CLEANING (`silver.products`):
   - Standardized and cleaned:
     - Product name using `INITCAP(TRIM())`.
     - Category based on keywords (e.g., 'office', 'kitchen').
     - Sub-categories using regex to correct typos (e.g., 'cjair' → 'Chair').
     - Supplier names cleaned and hyphens replaced with spaces.
     - Defect flags normalized from mixed formats (Y/N/1/0) to 'Yes'/'No'.

7. SALES CLEANING (`silver.sales`):
   - Enforced type conversions and positivity for quantity, total_sales.
   - Rounded net sales to two decimal places.
   - Handled type casting and ensured numeric integrity of monetary values.

8. ERROR HANDLING:
   - Uses `EXCEPTION` blocks to catch and report any errors during truncation or insertion, ensuring the ETL doesn’t fail silently.

9. BATCH TIMING & LOGGING:
   - Tracks and logs `batch_start_time`, `batch_end_time`, and `total_duration` for performance monitoring.

==============================================================
The Silver Layer now contains clean, standardized, and business-usable data.
==============================================================
*/

CREATE OR REPLACE PROCEDURE silver.import_silver_layer()
LANGUAGE plpgsql AS $$
DECLARE 
  batch_start_time TIMESTAMP;
  batch_end_time TIMESTAMP;
  total_duration INTERVAL;
BEGIN
  batch_start_time := clock_timestamp();
  RAISE NOTICE '===========================';
  RAISE NOTICE 'Loading Silver Layer';
  RAISE NOTICE '===========================';
  RAISE NOTICE 'Batch start: %', batch_start_time;

  BEGIN
    RAISE NOTICE 'Truncating the silver layer tables...';
    TRUNCATE TABLE 
      silver.customers,
      silver.customer_preferences,
      silver.order_items,
      silver.orders,
      silver.products,
      silver.sales;
    RAISE NOTICE '✅ Truncation completed!';
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE WARNING '❌ Error truncating tables: %', SQLERRM;
  END;

  BEGIN
    RAISE NOTICE 'Inserting data into silver layer tables...';

    -- silver.customers
    INSERT INTO silver.customers (
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
    SELECT 
      customer_id::INTEGER,
      INITCAP(TRIM(name)),
      CASE 
        WHEN UPPER(TRIM(gender)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(gender)) = 'F' THEN 'Female'
        ELSE 'n/a'
      END,
      CASE
        WHEN dob ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN TO_DATE(dob, 'Month DD, YYYY')
        WHEN dob ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(dob, 'YYYY/MM/DD')
        WHEN dob ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN TO_DATE(dob, 'DD-MM-YYYY')
        WHEN dob ~ '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(dob, 'DD/MM/YY')
        WHEN dob ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN TO_DATE(dob, 'DD/MM/YYYY')
        ELSE NULL
      END,
      city,
      CASE 
        WHEN LOWER(city) = 'new delhi' THEN 'Delhi'
        WHEN LOWER(city) = 'hyderabad' THEN 'Telangana'
        WHEN LOWER(city) = 'chennai' THEN 'Tamil Nadu'
        WHEN LOWER(city) = 'mumbai' THEN 'Maharashtra'
        WHEN LOWER(city) = 'bengaluru' THEN 'Karnataka'
        ELSE 'Unknown'
      END,
      TRIM(country),
      CASE 
        WHEN UPPER(category) LIKE 'OUTDOOR%' THEN 'Outdoor'
        WHEN UPPER(category) LIKE 'OFFICE%' THEN 'Office'
        WHEN UPPER(category) LIKE 'KITCHEN%' THEN 'Kitchen'
        WHEN UPPER(category) LIKE 'HOME%' THEN 'Home'
        ELSE 'Unknown'
      END,
      CASE 
        WHEN LOWER(subcategory) LIKE '%bed%' THEN 'Bed'
        WHEN LOWER(subcategory) LIKE '%desk%' THEN 'Desk'
        WHEN LOWER(subcategory) LIKE '%chair%' THEN 'Chair'
        WHEN LOWER(subcategory) LIKE '%lamp%' THEN 'Lamp'
        WHEN LOWER(subcategory) LIKE '%sofa%' THEN 'Sofa'
        WHEN LOWER(subcategory) LIKE '%table%' THEN 'Table'
        ELSE 'Unknown'
      END
    FROM bronze.customers;
    RAISE NOTICE '✅ silver.customers inserted';

    -- silver.customer_preferences
    INSERT INTO silver.customer_preferences (
      customer_id,
      email_id,
      loyalty_points,
      feedback_score,
      preferred_store,
      newsletter_subscribed
    )
    SELECT 
      customer_id::INTEGER,
      COALESCE(email, 'n/a') AS email,
      CASE WHEN loyalty_points = 'NA' THEN NULL ELSE loyalty_points::NUMERIC(10,2) END,
      feedback_score::INTEGER,
      preferred_store,
      CASE 
        WHEN newletter_subscribed IS NULL THEN 'n/a'
        WHEN TRIM(LOWER(newletter_subscribed)) IN ('y', 'yes') THEN 'Yes'
        WHEN TRIM(LOWER(newletter_subscribed)) IN ('n', 'no') THEN 'No'
        ELSE 'Unknown'
      END AS newsletter_subscribed
    FROM bronze.customer_preferences;
    RAISE NOTICE '✅ silver.customer_preferences inserted';

    -- silver.order_items
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
      ROW_NUMBER() OVER()::INTEGER,
      split_part(order_item_id, '-', 2)::INTEGER,
      order_id::INTEGER,
      product_id::INTEGER,
      INITCAP(TRIM(item_name)),
      ABS(quantity::NUMERIC),
      price::NUMERIC,
      ABS(item_total::NUMERIC)
    FROM bronze.order_items;
    RAISE NOTICE '✅ silver.order_items inserted';

    -- silver.orders
    INSERT INTO silver.orders (
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
        WHEN LOWER(order_status) ~ '^(close|closed|shipped)$' THEN 'Close'
        ELSE 'n/a'
      END
    FROM bronze.orders;
    RAISE NOTICE '✅ silver.orders inserted';

    -- silver.products
    INSERT INTO silver.products (
      product_id,
      product_name,
      category,
      sub_category,
      supplier_name,
      defect_flag
    )
    SELECT 
      product_id::INTEGER,
      INITCAP(TRIM(product_name)),
      CASE 
        WHEN LOWER(category) ~ 'outdoor' THEN 'Outdoor'
        WHEN LOWER(category) ~ 'kitchen' THEN 'Kitchen'
        WHEN LOWER(category) ~ 'office' THEN 'Office'
        WHEN LOWER(category) ~ 'home' THEN 'Home'
        ELSE 'Unknown'
      END,
      CASE 
        WHEN LOWER(sub_category) ~ 'chair|cjair' THEN 'Chair'
        WHEN LOWER(sub_category) ~ 'lamp|iamp' THEN 'Lamp'
        WHEN LOWER(sub_category) ~ 'desk|djsk' THEN 'Desk'
        WHEN LOWER(sub_category) ~ 'sofa|swfa|sbfa' THEN 'Sofa'
        WHEN LOWER(sub_category) ~ 'table' THEN 'Table'
        WHEN LOWER(sub_category) ~ 'bed' THEN 'Bed'
        ELSE 'Unknown'
      END,
      INITCAP(TRIM(REPLACE(supplier_name, '-', ' '))),
      CASE 
        WHEN defect_flag IN ('Y', '1') THEN 'Yes'
        WHEN defect_flag IN ('N', '0') THEN 'No'
        ELSE 'Unknown'
      END
    FROM bronze.products;
    RAISE NOTICE '✅ silver.products inserted';

    -- silver.sales
    INSERT INTO silver.sales (
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
      ABS(quantity::NUMERIC),
      price::NUMERIC,
      item_total::NUMERIC,
      discount::NUMERIC,
      ROUND(ABS(net_sales::NUMERIC), 2)
    FROM bronze.sales;
    RAISE NOTICE '✅ silver.sales inserted';

  EXCEPTION
    WHEN OTHERS THEN 
      RAISE WARNING '❌ Error inserting tables: %', SQLERRM;
  END;

  -- Completion log
  batch_end_time := clock_timestamp();
  total_duration := batch_end_time - batch_start_time;
  RAISE NOTICE 'Batch completed at: %', batch_end_time;
  RAISE NOTICE '⏱️ Duration: % seconds', EXTRACT(EPOCH FROM total_duration);

END;
$$;


CALL silver.import_silver_layer();