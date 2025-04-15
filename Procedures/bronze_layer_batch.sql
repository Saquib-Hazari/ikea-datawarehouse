/*
=======================================================================
📥 BRONZE LAYER INGESTION & RAW DATA STAGING OVERVIEW
=======================================================================

This procedure imports raw data from CSV files into the Bronze Layer 
(tables in the `bronze` schema). This is the initial landing zone for 
all unprocessed data from external systems. It includes the following 
stages:

1. BATCH TIMING & LOGGING:
   - Captures the start and end timestamp of the batch load using `clock_timestamp()`.
   - Logs batch start, completion, and total duration for traceability and performance monitoring.

2. TRUNCATION OF EXISTING DATA:
   - Truncates all Bronze Layer tables (`bronze.customers`, `bronze.customer_preferences`, etc.)
     to ensure a clean slate before reloading new data.
   - Wrapped in a `BEGIN...EXCEPTION` block to catch and log any truncation failures without halting the pipeline.

3. DATA INGESTION FROM CSV FILES:
   - Loads raw data from CSV files into the respective Bronze tables using the `COPY` command.
   - Assumes files are comma-delimited with headers, encoded in UTF-8.
   - Each load is logged with success notices or warnings if any file fails to load.

4. ERROR HANDLING:
   - Each major step (truncation and load) is wrapped in a `BEGIN...EXCEPTION` block to ensure
     error reporting without terminating the overall execution.
   - Errors are reported using `RAISE WARNING` with detailed SQL error messages (`SQLERRM`).

5. OUTPUT:
   - If successful, all six Bronze tables are refreshed with the latest raw data from CSVs.
   - Provides complete visibility into the load status of each table and total batch duration.

=======================================================================
The Bronze Layer serves as the foundation for all downstream Silver 
and Gold transformations, enabling traceable, repeatable ETL execution.
=======================================================================
*/
CREATE OR REPLACE PROCEDURE bronze.import_bronze_layer()
LANGUAGE plpgsql AS $$
DECLARE
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
    total_duration INTERVAL;
BEGIN
    -- Start logging
    batch_start_time := clock_timestamp();
    RAISE NOTICE '============================';
    RAISE NOTICE '🔄 LOADING BRONZE LAYER';
    RAISE NOTICE '============================';
    RAISE NOTICE 'Batch start time: %', batch_start_time;

    -- Truncate bronze tables
    BEGIN
        RAISE NOTICE '🚧 Truncating Bronze Tables...';
        TRUNCATE TABLE
            bronze.customers,
            bronze.customer_preferences,
            bronze.order_items,
            bronze.orders,
            bronze.products,
            bronze.sales;
        RAISE NOTICE '✅ Truncation completed!';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING '❌ Failed to truncate tables: %', SQLERRM;
    END;

    -- Load data from CSV files into Bronze tables
    BEGIN
        RAISE NOTICE '📥 Loading data into Bronze layer...';

        COPY bronze.customers
        FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/customers.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        RAISE NOTICE '✅ Loaded bronze.customers';

        COPY bronze.customer_preferences
        FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/customer_preferences.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        RAISE NOTICE '✅ Loaded bronze.customer_preferences';

        COPY bronze.order_items
        FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/order_items.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        RAISE NOTICE '✅ Loaded bronze.order_items';

        COPY bronze.orders
        FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/orders.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        RAISE NOTICE '✅ Loaded bronze.orders';

        COPY bronze.products
        FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/products.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        RAISE NOTICE '✅ Loaded bronze.products';

        COPY bronze.sales
        FROM '/Users/saquibhazari/DEVELOPERS/ikea_sales_database/CSV/Ikea_sale/sales.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        RAISE NOTICE '✅ Loaded bronze.sales';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING '❌ Error occurred during data load: %', SQLERRM;
    END;

    -- End batch and log duration
    batch_end_time := clock_timestamp();
    total_duration := batch_end_time - batch_start_time;

    RAISE NOTICE '✅ Bronze layer load completed at: %', batch_end_time;
    RAISE NOTICE '🕒 Total Batch Duration: % seconds.',
        EXTRACT(EPOCH FROM total_duration);

END;
$$;

CALL bronze.import_bronze_layer();