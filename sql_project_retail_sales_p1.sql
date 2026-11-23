--SQL RETAL SALES ANALYSIS PROJECT

CREATE database sql_project_p1		
use sql_project_p1
--CREATE TABLE
drop table reatil_sales;
create table retail_sales
(
      transactions_id INT primary key,	
      sale_date	DATE,
      sale_time	TIME,
      customer_id	INT,
      gender	VARCHAR(10),
      age	INT,
      category	VARCHAR(15),
      quantity INT,	
      price_per_unit FLOAT,	
      cogs	FLOAT,
      total_sale FLOAT
)

select * from retail_sales_staging;
INSERT INTO dbo.retail_sales
(
    transactions_id,
    sale_date,
    sale_time,
    customer_id,
    gender,
    age,
    category,
    quantity,
    price_per_unit,
    cogs,
    total_sale
)
SELECT
    transactions_id,
    sale_date,
    sale_time,
    customer_id,
    gender,
    age,
    category,
    quantiy,
    price_per_unit,
    cogs,
    total_sale
FROM dbo.retail_sales_staging;

select * from retail_sales

DROP TABLE dbo.retail_sales_staging;

-------------DATA CLEANING-----------
---CHECK NULL VALUES IN OUR DATA
select * 
from retail_sales
where  transactions_id is null 
or
    sale_date is null or
    sale_time is null or
    customer_id is null or
    gender is null or
    age is null or
    category is null or
    quantity is null or
    price_per_unit is null or
    cogs is null or
    total_sale is null 
    update retail_sales
    set age  = 35
    where age is null
    delete from retail_sales
    where  transactions_id  in (679,746,1225)

---------------DATA EXPLORATION------------
--Q1 how many sales we have done = 1997?
select 
count(*) as total_sales 
from retail_sales

--Q2 how many unique customers we have = 155?
select 
count(distinct(customer_id))
from retail_sales

--Q3 how many unique categories we have = 3?
select
count(distinct(category))
from retail_sales

-------DATA ANALYSIS and BSUINESS KEY PROBLEMS-------
--Q1- write a query to retrieve all the columns for the sales made on '2022-11-05'
 select *
 from retail_sales
 where sale_date = '2022-11-05'

--Q2- write a query to retrieve all transactions where the category is 'Clothing'and the quantity sold is moore than or equal to 4 in month of nov-2022.
select transactions_id,
DATENAME(Month, sale_date) as month_of_sale,
DATENAME(Year, sale_date) as year_of_sale
from retail_sales
where category = 'Clothing' and
DATENAME(Month, sale_date) = 'November'
and DATENAME(Year, sale_date) = 2022 and quantity >= 4

--OR--
select *
from retail_sales
where category = 'Clothing' and
      quantity >=4 and
      month(sale_date) = 11 and
      year(sale_date) = 2022
--format(sale_date , 'YYYY-MM') = '2022-11'

--Q3-write a query to calculate the total sales for each category
 select 
 category,
 sum(total_sale) as net_sale,
 count(total_sale) as total_order
 from retail_sales
 group by category

--Q4-write a query to find average age of customers who purchased items from 'beauty' category
select 
avg(age) as average_age
from retail_sales
where category = 'beauty'

--Q5- write a query to find all transactions where the toal sale is greater than 1000.
select 
*
from retail_sales
where total_sale > 1000

--Q6- write a query to find the total number of transactions made by each gender in each category
select
gender,category,
count(total_sale) as net_sale
from retail_sales
group by gender, category
order by gender asc

--Q7- write a query to calculate the average sale for each month. Find out best selling in each year.
with best_selling as 
(
select
datename(month,sale_date) as month_of_sale,
datename(year,sale_date) as year_of_sale,
round(avg(total_sale),0) as average_sale_for_each_month

from retail_sales
group by datename(month,sale_date),datename(year,sale_date)
),

ranked_sales as
(
select *,
dense_rank() over
(
partition by year_of_sale order by average_sale_for_each_month desc
) as sales_rank
from best_selling)
    select *
    from ranked_sales
    where sales_rank = 1

--Q8- write a query to find the top 5 customers based on the highest total sales
select top 5 customer_id,
sum(total_sale) as net_sale
--transactions_id
from retail_sales
group by customer_id 
order by net_sale desc

--Q9-write a query to find the number of unique customers who purchased from each category
select 
count(distinct(customer_id)),
category
from retail_sales
group by category

--Q10-write a query to create each shift and no. of orders (example morning <= 12, afternoon between 12 and 17, evening > 17)   
with shiftwise_sale 
AS
(
select *,
case 
when datepart(hour,sale_time) < 12 then 'Morning'
--when datepart(hour,sale_time) > 12 and datepart(hour,sale_time) <= 17 then 'Afternoon' 
when datepart(hour,sale_time) between 12 and 17 then 'Afternoon'
else 'Evening'
end as shift_name 

from retail_sales
)
select shift_name,
count (transactions_id) as total_orders
from shiftwise_sale
group by shift_name 

---END OF PROJECT---
