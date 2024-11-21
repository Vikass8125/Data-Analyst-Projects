# Retail Order Data Analysis

## Description
This project provides insights into retail order data by analyzing key metrics such as revenue, profit, discount rates, and regional performance. It uses Python for preprocessing and SQL for advanced querying, alongside data visualizations to support business decisions.

## Tool
- Python (Data Cleaning and Preprocessing)
- MySQL (Data Querying)

## Project Type
Data Analysis, Data Cleaning, Data Modeling, Data Transformation

## Data Set Link
![orders_Data_Set](./orders_Data_Set.png)

[Download orders.csv](./orders.csv)

## Project File Link
![orders_sql_op](./orders_sql_op.png)

[Order Data Analysis](./Order_Data_Analysis.ipynb)

---

## Summary

### Goal
- Analyze sales and revenue trends to uncover high-performing products and regions.
- Identify growth patterns across categories and subcategories over time.
- Provide actionable insights for improving sales and inventory strategies.

### Process
1. **Data Cleaning**: 
   - Handled missing values and standardized column names for consistency.
   - Derived new columns such as `discount`, `sale_price`, and `profit`.
2. **Data Transformation**:
   - Converted `order_date` to datetime for time-series analysis.
   - Dropped unnecessary columns like `list_price`, `cost_price`, and `discount_percent`.
3. **Database Integration**:
   - Loaded the cleaned data into a MySQL database.
   - Created SQL queries for specific business insights.
4. **Analysis Highlights**:
   - Revenue trends by month and year.
   - Top 10 products generating the highest revenue.
   - Regional performance comparison for product categories.

### Insights
- **Top Products**: Certain product IDs consistently rank as the highest revenue generators.
- **Regional Performance**:
  - The Western region outperformed others in terms of sales volume.
  - High revenue concentration in categories like Furniture and Technology.
- **Seasonal Trends**:
  - Sales peak during Q3 and Q4 of each year.
  - Discount strategies significantly impact profitability in the summer months.
- **Growth Analysis**:
  - Subcategories like "Phones" and "Tables" showed the highest growth in 2023 compared to 2022.
  - Office Supplies experienced a steady year-over-year increase in profit margins.

## Python Pseudocode

```python
# Import necessary libraries
import pandas as pd
import sqlalchemy as sal

# Step 1: Load Data
df = pd.read_csv('orders.csv', na_values=['Not Available', 'unknown'])

# Step 2: Clean and Transform Data
df.rename(columns={'Order Id': 'order_id', 'City': 'city'}, inplace=True)
df.columns = df.columns.str.lower().str.replace(' ', '_')
df['order_date'] = pd.to_datetime(df['order_date'], format='%Y-%m-%d')
df['discount'] = df['list_price'] * df['discount_percent'] * 0.01
df['sale_price'] = df['list_price'] - df['discount']
df['profit'] = df['sale_price'] - df['cost_price']
df.drop(columns=['list_price', 'cost_price', 'discount_percent'], inplace=True)

# Step 3: Load Data into SQL Database
engine = sal.create_engine("mysql+mysqldb://user:password@localhost:3306/order_data")
df.to_sql('df_orders', con=engine, index=False, if_exists='append')

# Step 4: Analyze Data Using SQL Queries
# Example queries:
# 1. Top 10 revenue-generating products
# SELECT product_id, SUM(sale_price) AS sales FROM df_orders
# GROUP BY product_id ORDER BY sales DESC LIMIT 10;

# 2. Monthly revenue comparison for 2022 vs 2023
# SELECT MONTH(order_date) AS month,
# SUM(CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END) AS sales_2022,
# SUM(CASE WHEN YEAR(order_date) = 2023 THEN sale_price ELSE 0 END) AS sales_2023
# FROM df_orders GROUP BY month;


