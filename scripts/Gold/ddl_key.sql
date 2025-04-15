/*
=======================================================================
🔐 GOLD LAYER TABLE CONSTRAINTS, INDEXING & OWNERSHIP MANAGEMENT
=======================================================================

This script enforces referential integrity and improves query performance 
within the Gold Layer of the data warehouse. It includes the following steps:

1. 🆔 PRIMARY KEY CREATION:
   - Ensures entity integrity by defining unique identifiers for each table:
     • `gold.dim_customers(customer_key)`
     • `gold.dim_products(product_key)`
     • `gold.fact_sales(sales_order_key)`

2. 🔗 FOREIGN KEY CONSTRAINTS:
   - Establishes referential relationships between dimension and fact tables:
     • `gold.fact_sales.customer_key` → `gold.dim_customers.customer_key`
     • `gold.fact_sales.product_key` → `gold.dim_products.product_key`
   - Guarantees data consistency across relationships by preventing orphan records.

3. ⚡ INDEX CREATION:
   - Adds indexes to commonly filtered and joined columns to optimize query performance:
     • Dimension keys: `customer_key`, `product_key`
     • Fact foreign keys: `customer_key`, `product_key`
     • Date field: `order_date` — useful for time-based aggregations or filtering

4. 👤 OWNERSHIP ASSIGNMENT:
   - Transfers ownership of all Gold Layer tables to the role/user `saquibhazari`
   - Facilitates permission management and aligns with project-based data governance

=======================================================================
📌 Note:
  - All constraints and indexes align with star schema best practices.
  - Foreign key enforcement ensures high-quality joins between dimensions and fact tables.
  - Indexes are critical for improving dashboard response times and analytical workloads.

✅ This structure supports efficient querying, robust relationships, and clean data modeling.
=======================================================================
*/
ALTER TABLE gold.dim_customers
ADD CONSTRAINT pk_dim_customer PRIMARY KEY (customer_key);
ALTER TABLE gold.dim_products
ADD CONSTRAINT pk_dim_product PRIMARY KEY (product_key);

ALTER TABLE gold.fact_sales
ADD CONSTRAINT pk_fact_sales PRIMARY KEY (sales_order_key);

-- Adding foreign keys
ALTER TABLE gold.fact_sales
ADD CONSTRAINT fk_customer FOREIGN KEY (customer_key)
REFERENCES gold.dim_customers(customer_key);

ALTER TABLE gold.fact_sales
ADD CONSTRAINT fk_product FOREIGN KEY (product_key)
REFERENCES gold.dim_products(product_key);

-- Creating indexes
CREATE INDEX idx_customer_key ON gold.dim_customers(customer_key);
CREATE INDEX idx_product_key ON gold.dim_products(product_key);
CREATE INDEX idx_fact_customer_key ON gold.fact_sales(customer_key);
CREATE INDEX idx_fact_product_key ON gold.fact_sales(product_key);
CREATE INDEX idx_fact_order_date ON gold.fact_sales(order_date);

-- Alter the table ownership to saquibhazari
ALTER TABLE gold.dim_customers OWNER TO saquibhazari;
ALTER TABLE gold.dim_products OWNER TO saquibhazari;
ALTER TABLE gold.fact_sales OWNER TO saquibhazari;