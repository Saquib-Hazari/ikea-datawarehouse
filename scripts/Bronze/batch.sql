-- Copying the csv files
COPY bronze.customers
FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/customers.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8')

COPY bronze.customer_preferences
FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/customer_preferences.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8')

COPY bronze.order_items
FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/order_items.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8')

COPY bronze.orders
FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/orders.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8')

COPY bronze.products
FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/products.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8')

COPY bronze.sales
FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/sales.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8')

