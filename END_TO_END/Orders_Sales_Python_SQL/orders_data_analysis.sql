-- Using the order_data database
USE order_data;

-- find top 10 highest revenue generating products 
select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10;

-- Find top 5 highest selling products in each region
with cte as (
    select region, product_id, sum(sale_price) as sales
    from df_orders
    group by region, product_id
)
select * 
from (
    select *, row_number() over (partition by region order by sales desc) as rn
    from cte
) A
where rn <= 5;

-- Find month-over-month growth comparison for 2022 and 2023 sales (e.g., Jan 2022 vs Jan 2023)
with cte as (
    select year(order_date) as order_year, month(order_date) as order_month,
           sum(sale_price) as sales
    from df_orders
    group by year(order_date), month(order_date)
)
select order_month,
       sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
       sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;


-- For each category, find which month had the highest sales
with cte as (
    select category, date_format(order_date, '%Y%m') as order_year_month,
           sum(sale_price) as sales
    from df_orders
    group by category, date_format(order_date, '%Y%m')
)
select * from (
    select *,
           row_number() over (partition by category order by sales desc) as rn
    from cte
) a
where rn = 1;

-- Which sub-category had highest growth by profit in 2023 compared to 2022
with cte as (
    select sub_category, year(order_date) as order_year,
           sum(sale_price) as sales
    from df_orders
    group by sub_category, year(order_date)
)
, cte2 as (
    select sub_category,
           sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
           sum(case when order_year = 2023 then sales else 0 end) as sales_2023
    from cte 
    group by sub_category
)
select *,
       (sales_2023 - sales_2022) as sales_growth
from cte2
order by sales_growth desc
limit 1;



