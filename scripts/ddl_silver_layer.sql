/* Dropping and Creating tables to import all the data to the database.
==============================================================
DROPPING AND CREATING TABLES (DDL) Silver layer
==============================================================
1- Creating the schema in the database named silver.
2- Dropping the tables if exists and creating the tables.
3- Inserting the raw columns to the silver layer table with correct data type from bronze layer.
4- Data Cleaning and inserting into the tables with correct Data type.
5- Batch processing.

*/
-- Creating the tables for the silver layer
CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE if EXISTS silver.customers;
CREATE TABLE silver.customers(
  customer_id INTEGER,
  customer_name VARCHAR(50),
  gender VARCHAR(10),
  date_of_birth DATE,
  city TEXT, 
  state TEXT,
  country TEXT,
  category TEXT,
  sub_category TEXT,
  dwh_created_date TIMESTAMP DEFAULT NOW(),
  dwh_updated_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.customer_preferences;
CREATE TABLE silver.customer_preferences(
  customer_id INTEGER,
  email_id TEXT,
  loyalty_points NUMERIC(10,2),
  feedback_score INTEGER,
  preferred_store VARCHAR(30),
  newsletter_subscribed VARCHAR(10),
  dwh_created_date TIMESTAMP DEFAULT NOW(),
  dwh_updated_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.order_items;

CREATE TABLE silver.order_items (
  order_item_id INTEGER,
  item_key INTEGER,
  order_id INTEGER,
  product_id INTEGER,
  product_name TEXT,
  quantity NUMERIC,
  price NUMERIC,
  total_sales NUMERIC,
  dwh_created_date TIMESTAMP DEFAULT NOW(),
  dwh_updated_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.orders;
CREATE TABLE silver.orders(
  order_id INTEGER,
  customer_id INTEGER,
  order_date DATE,
  ship_date DATE,
  due_date DATE,
  order_status TEXT,
  dwh_created_date TIMESTAMP DEFAULT NOW(),
  dwh_updated_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.products;
CREATE TABLE silver.products(
  product_id INTEGER,
  product_name VARCHAR(50),
  category TEXT,
  sub_category TEXT,
  supplier_name TEXT,
  defect_flag TEXT,
  dwh_created_date TIMESTAMP DEFAULT NOW(),
  dwh_updated_date TIMESTAMP DEFAULT NOW()
);


DROP TABLE IF EXISTS silver.sales;
CREATE TABLE silver.sales(
  order_id INTEGER,
  product_id INTEGER,
  quantity NUMERIC,
  price NUMERIC,
  total_sales NUMERIC,
  discount NUMERIC,
  net_sales NUMERIC,
  dwh_created_date TIMESTAMP DEFAULT NOW(),
  dwh_updated_date TIMESTAMP DEFAULT NOW()
);