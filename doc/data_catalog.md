# 📚 Data Catalog – Gold Layer

The **Gold Layer** follows a star schema design optimized for efficient querying and analytics. It contains:

- Two dimension tables: `dim_customers`, `dim_products`
- One fact table: `fact_sales`
- Surrogate keys are generated using `ROW_NUMBER()` for better join performance.

---

## 🧑‍💼 gold.dim_customers

**Description**: Enriched customer dimension combining core customer data and preferences.

| Column Name             | Data Type | Description                                          |
| ----------------------- | --------- | ---------------------------------------------------- |
| `customer_key`          | INTEGER   | Surrogate key generated via `ROW_NUMBER()`           |
| `customer_id`           | INTEGER   | Source system natural key                            |
| `customer_name`         | TEXT      | Customer full name                                   |
| `gender`                | TEXT      | Gender of the customer                               |
| `date_of_birth`         | DATE      | Date of birth                                        |
| `state`                 | TEXT      | State of residence                                   |
| `city`                  | TEXT      | City of residence                                    |
| `country`               | TEXT      | Country of residence                                 |
| `category`              | TEXT      | Customer segment category                            |
| `sub_category`          | TEXT      | Sub-segment within customer segment                  |
| `email_id`              | TEXT      | Email address                                        |
| `feedback_score`        | NUMERIC   | Average customer feedback score                      |
| `loyalty_points`        | INTEGER   | Accumulated loyalty points                           |
| `newsletter_subscribed` | BOOLEAN   | Indicates if subscribed to marketing newsletters     |
| `preferred_store`       | TEXT      | Most frequented store or `'Unknown'` if not provided |

---

## 📦 gold.dim_products

**Description**: Product dimension containing product master data and quality status.

| Column Name     | Data Type | Description                                 |
| --------------- | --------- | ------------------------------------------- |
| `product_key`   | INTEGER   | Surrogate key generated via `ROW_NUMBER()`  |
| `product_id`    | INTEGER   | Source system product identifier            |
| `product_name`  | TEXT      | Name of the product                         |
| `category`      | TEXT      | Product category (e.g., Furniture, Storage) |
| `sub_category`  | TEXT      | More specific product classification        |
| `supplier_name` | TEXT      | Name of the supplier/manufacturer           |
| `defect_flag`   | BOOLEAN   | Indicates if the product has known defects  |

---

## 📈 gold.fact_sales

**Description**: Central fact table recording sales transactions enriched with dimensional references.

| Column Name       | Data Type | Description                                     |
| ----------------- | --------- | ----------------------------------------------- |
| `sales_order_key` | INTEGER   | Surrogate key generated via `ROW_NUMBER()`      |
| `customer_key`    | INTEGER   | Foreign key from `dim_customers`                |
| `product_key`     | INTEGER   | Foreign key from `dim_products`                 |
| `order_id`        | INTEGER   | Unique order identifier                         |
| `order_date`      | DATE      | Date the order was placed                       |
| `ship_date`       | DATE      | Date the order was shipped                      |
| `due_date`        | DATE      | Expected delivery date                          |
| `order_status`    | TEXT      | Status of the order (e.g., Delivered, Canceled) |
| `quantity`        | INTEGER   | Number of items ordered                         |
| `price`           | NUMERIC   | Price per item                                  |
| `total_sales`     | NUMERIC   | Total value before discounts                    |
| `discount`        | NUMERIC   | Discount applied                                |
| `net_sales`       | NUMERIC   | Final sale amount after discount                |

---

📁 **Source:** Data is transformed from the **Silver Layer**, combining multiple cleaned tables from CRM and ERP sources.
