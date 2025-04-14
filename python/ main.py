import pandas as pd
import numpy as np
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
  dbname = os.getenv("DB_NAME"),
  user = os.getenv("DB_USER"),
  password = os.getenv("DB_PASSWORD"),
  host = os.getenv("DB_HOST"),
  port = os.getenv("DB_PORT")
)

queries = {
  "dim_customers" : "SELECT * FROM gold.dim_customers",
  "dim_products" : "SELECT * FROM gold.dim_products",
  "fact_sales": "SELECT * FROM gold.fact_sales"
}

for name, query in queries.items():
  df = pd.read_sql(query, conn)
  df.to_csv(f"{name}.csv", index=False)
  print(f"Extracted the {name}.csv Successfully!");
conn.close()