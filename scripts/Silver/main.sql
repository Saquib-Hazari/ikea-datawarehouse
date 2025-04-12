-- Creating data cleansing and data preparation
SELECT customer_id,
  INITCAP(TRIM(name)) AS full_name,
  CASE 
    WHEN UPPER(TRIM(gender)) = 'M' OR LOWER(TRIM(gender)) = 'm' THEN 'Male'  
    WHEN UPPER(TRIM(gender)) = 'F' OR LOWER(TRIM(gender)) = 'f' THEN 'Female'
    ELSE 'n/a' 
  END AS gender,
    CASE
    WHEN dob ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN TO_DATE(dob, 'Month DD, YYYY')  -- March 12, 2004
    WHEN dob ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(dob, 'YYYY/MM/DD')         -- 1989/12/15
    WHEN dob ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN TO_DATE(dob, 'DD-MM-YYYY')         -- 12-10-1996
    WHEN dob ~ '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(dob, 'DD/MM/YY')           -- 20/05/99
    WHEN dob ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN TO_DATE(dob, 'DD/MM/YYYY')         -- fallback
    ELSE NULL
  END AS date_of_birth,
  TRIM(state) AS state,
  TRIM(city) AS city,
  TRIM(country) AS country,
  CASE 
    WHEN UPPER(TRIM(category)) LIKE 'OUTDOOR%' THEN 'Outdoor'
    WHEN UPPER(TRIM(category)) LIKE 'OFFICE%' THEN 'Office'
    WHEN UPPER(TRIM(category)) LIKE 'KITCHEN%' THEN 'Kitchen'
    WHEN UPPER(TRIM(category)) LIKE 'HOME%' THEN 'Home'
    ELSE 'Unknown'
  END AS clean_category,
  CASE 
    WHEN LOWER(subcategory) LIKE '%bed%' THEN 'Bed'
    WHEN LOWER(subcategory) LIKE '%desk%' THEN 'Desk'
    WHEN LOWER(subcategory) LIKE '%chair%' THEN 'Chair'
    WHEN LOWER(subcategory) LIKE '%lamp%' THEN 'Lamp'
    WHEN LOWER(subcategory) LIKE '%sofa%' THEN 'Sofa'
    WHEN LOWER(subcategory) LIKE '%table%' THEN 'Table'
    ELSE 'Unknown'
  END AS sub_category
FROM bronze.customers

SELECT full_name
FROM(
SELECT
  INITCAP(TRIM(name)) AS full_name
FROM bronze.customers
)t 
WHERE full_name IS NULL

SELECT 
  CASE 
    WHEN UPPER(TRIM(gender)) = 'M' OR LOWER(TRIM(gender)) = 'm' THEN 'Male'  
    WHEN UPPER(TRIM(gender)) = 'F' OR LOWER(TRIM(gender)) = 'f' THEN 'Female'
    ELSE 'n/a' 
  END AS gender
FROM bronze.customers
WHERE gender IS NOT NULL

SELECT 
  CASE
    WHEN dob ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN TO_DATE(dob, 'Month DD, YYYY')  -- March 12, 2004
    WHEN dob ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(dob, 'YYYY/MM/DD')         -- 1989/12/15
    WHEN dob ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN TO_DATE(dob, 'DD-MM-YYYY')         -- 12-10-1996
    WHEN dob ~ '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN TO_DATE(dob, 'DD/MM/YY')           -- 20/05/99
    WHEN dob ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN TO_DATE(dob, 'DD/MM/YYYY')         -- fallback
    ELSE NULL
  END AS date_of_birth
FROM bronze.customers


SELECT 
  CASE 
    WHEN UPPER(TRIM(category)) LIKE 'OUTDOOR%' THEN 'Outdoor'
    WHEN UPPER(TRIM(category)) LIKE 'OFFICE%' THEN 'Office'
    WHEN UPPER(TRIM(category)) LIKE 'KITCHEN%' THEN 'Kitchen'
    WHEN UPPER(TRIM(category)) LIKE 'HOME%' THEN 'Home'
    ELSE 'Unknown'
  END AS clean_category
FROM bronze.customers;

UPDATE bronze.customers
SET country = 
  CASE 
    WHEN LOWER(TRIM(country)) = 'india' OR UPPER(TRIM(country))= 'INDIA' OR country = 'indai' OR country = 'INDAI' THEN 'India'
    ELSE 'India'
  END;


SELECT CASE 
    WHEN LOWER(subcategory) LIKE '%bed%' THEN 'Bed'
    WHEN LOWER(subcategory) LIKE '%desk%' THEN 'Desk'
    WHEN LOWER(subcategory) LIKE '%chair%' THEN 'Chair'
    WHEN LOWER(subcategory) LIKE '%lamp%' THEN 'Lamp'
    WHEN LOWER(subcategory) LIKE '%sofa%' THEN 'Sofa'
    WHEN LOWER(subcategory) LIKE '%table%' THEN 'Table'
    ELSE 'Unknown'
  END AS cleaned_product
FROM bronze.customers
