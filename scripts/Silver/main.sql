SELECT 
  order_id,
  customer_id,
  order_date,
  ship_date,
  due_date,
  CASE 
    WHEN LOWER(order_status) ~ '^(open|opened)$' THEN 'Open'  
    WHEN LOWER(order_status) ~ '^(close|closed)$' THEN 'Close'  
    WHEN LOWER(order_status) ~ '^(shipped)$' THEN 'Close'  
    ELSE 'n/a'
  END AS cleaned_order_status
FROM orders


SELECT
  CASE 
    WHEN LOWER(order_status) ~ '^(open|opened)$' THEN 'Open'  
    WHEN LOWER(order_status) ~ '^(close|closed)$' THEN 'Close'  
    WHEN LOWER(order_status) ~ '^(shipped)$' THEN 'Close'  
    ELSE 'n/a'
  END AS cleaned_order_status
FROM orders
LIMIT 100