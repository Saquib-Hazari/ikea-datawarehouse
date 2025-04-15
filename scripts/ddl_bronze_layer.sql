/* Dropping and Creating tables to import all the data to the database.
==============================================================
DROPPING AND CREATING TABLES (DDL) bronze layer
==============================================================
1- Creating the schema in the database named bronze.
2- Dropping the tables if exists and creating the tables.
3- Inserting the raw columns to the table with data type TEXT.
4- Copying the file form the csv with Decimeter ',';
ex:   COPY bronze.products
        FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/products.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        RAISE NOTICE '✅ Loaded bronze.products';
5- Batch processing.

*/

-- Extracting raw data to the database
CREATE SCHEMA IF NOT EXISTS bronze;
DROP TABLE IF EXISTS bronze.customer;
CREATE TABLE bronze.customers(
  -- customer_id,name,gender,dob,state,city,country,category,sub_category
  customer_id TEXT,
  name TEXT,
  gender TEXT,
  dob TEXT,
  city TEXT,
  state TEXT,
  country TEXT, 
  category TEXT,
  subcategory TEXT
)

DROP TABLE IF EXISTS bronze.customer_preferences;
CREATE TABLE bronze.customer_preferences(
  -- customer_id,email,loyalty_points,feedback_score,preferred_store,newsletter_subscribed
  customer_id TEXT,
  email TEXT,
  loyalty_points TEXT,
  feedback_score TEXT,
  preferred_store TEXT,
  newletter_subscribed TEXT
)

DROP TABLE IF EXISTS bronze.order_items;
CREATE TABLE bronze.order_items(
  -- order_item_id,order_id,product_id,item_name,quantity,price,item_total
  order_item_id TEXT,
  order_id TEXT,
  product_id TEXT,
  item_name TEXT,
  quantity TEXT,
  price TEXT,
  item_total TEXT
);

DROP TABLE IF EXISTS bronze.orders;
CREATE TABLE bronze.orders(
  -- order_id,customer_id,order_date,ship_date,due_date,order_status
  order_id TEXT,
  customer_id TEXT,
  order_date TEXT,
  ship_date TEXT,
  due_date TEXT,
  order_status TEXT
);

DROP TABLE IF EXISTS bronze.products;
CREATE TABLE bronze.products(
  -- product_id,product_name,category,sub_category,supplier_name,defect_flag
  product_id TEXT,
  product_name TEXT,
  category TEXT,
  sub_category TEXT,
  supplier_name TEXT,
  defect_flag TEXT
);

DROP TABLE IF EXISTS bronze.sales;
CREATE TABLE bronze.sales(
  -- order_id,product_id,quantity,price,item_total,discount,net_sales
  order_id TEXT,
  product_id TEXT,
  quantity TEXT,
  price TEXT,
  item_total TEXT,
  discount TEXT,
  net_sales TEXT
);