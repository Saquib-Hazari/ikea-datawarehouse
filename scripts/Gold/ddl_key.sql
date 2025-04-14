-- Creating primary keys and foreign keys
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