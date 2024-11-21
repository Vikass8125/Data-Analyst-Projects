# Pizza Sales Analysis

## Description:
This project analyzes pizza sales data, including orders, revenue, and customer preferences. Using SQL, we explore the data to answer key business questions and derive actionable insights.

## Tool:
- SQL

## Project Type:
Data Analysis, Data Modeling

## Data Set Link:
![]()
[]()

## Project File Link:
![]()
[Pizza_sales_solution.sql](./Pizza_sales_solution.sql)

---

## Summary

### Goal:
To provide insights into pizza sales, customer behavior, and revenue patterns for better decision-making.

### Process:
1. **Database Setup**:
   - Created and initialized the `pizzahut` database.
   - Defined the `orders` and `order_details` tables to store the dataset.
2. **Analysis**:
   - Wrote SQL queries to solve business questions, including revenue analysis, most popular pizzas, and time-based order trends.

### Insights:
1. **Total Orders**:
   - Query: `SELECT COUNT(order_id) AS total_orders FROM orders;`
   - Insight: Retrieves the total number of orders placed.
   
2. **Total Revenue**:
   - Query: 
     ```sql
     SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales
     FROM order_details 
     JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;
     ```
   - Insight: Calculates the total revenue generated from pizza sales.

3. **Highest-Priced Pizza**:
   - Query:
     ```sql
     SELECT pizza_types.name, pizzas.price
     FROM pizza_types
     JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
     ORDER BY pizzas.price DESC LIMIT 1;
     ```
   - Insight: Identifies the most expensive pizza in the menu.

4. **Most Common Pizza Size**:
   - Query:
     ```sql
     SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
     FROM pizzas
     JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
     GROUP BY pizzas.size
     ORDER BY order_count DESC;
     ```
   - Insight: Shows the most frequently ordered pizza size.

5. **Top 5 Most Ordered Pizza Types**:
   - Query:
     ```sql
     SELECT pizza_types.name, SUM(order_details.quantity) AS quantity
     FROM pizza_types
     JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
     JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
     GROUP BY pizza_types.name
     ORDER BY quantity DESC LIMIT 5;
     ```
   - Insight: Lists the top 5 pizzas by quantity ordered.


