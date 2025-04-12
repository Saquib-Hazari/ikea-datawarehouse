-- Creating the tables for the silver layer
CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE if EXISTS silver.customers;
CREATE TABLE silver.customers(
  customer_id INTEGER,
  customer_name VARCHAR(50),
  gender VARCHAR(10),
  date_of_birth DATE,
  state TEXT,
  city TEXT, 
  country TEXT,
  category TEXT,
  sub_category TEXT,
  dwh_created_date TIMESTAMP DEFAULT NOW(),
  dwh_updated_date TIMESTAMP DEFAULT NOW()
)