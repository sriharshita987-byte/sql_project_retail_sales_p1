# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `p1_retail_db`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `p1_retail_db`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
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
);

Imported the date from excel into a new table called 'Retail sales staging' and then inserted the date from dummy table to original table named 'retail sales'
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
```

### 2. Data Exploration & Cleaning
```sql
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
```
### 3. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.


---------------DATA EXPLORATION------------
--Q1 how many sales we have done = 1997?
```sql
select 
count(*) as total_sales 
from retail_sales
```

--Q2 how many unique customers we have = 155?
```sql
select 
count(distinct(customer_id))
from retail_sales
```

--Q3 how many unique categories we have = 3?
```sql
select
count(distinct(category))
from retail_sales
```
--Q4 find the null values delete them and update the null values in age column as age '35'
```sql
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
```

### 4. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
 select *
 from retail_sales
 where sale_date = '2022-11-05'
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
select
transactions_id,
DATENAME(Month, sale_date) as month_of_sale,
DATENAME(Year, sale_date) as year_of_sale
from retail_sales
where category = 'Clothing' and
DATENAME(Month, sale_date) = 'November'
and DATENAME(Year, sale_date) = 2022 and quantity >= 4

OR

select *
from retail_sales
where category = 'Clothing' and
      quantity >=4 and
      month(sale_date) = 11 and
      year(sale_date) = 2022
--format(sale_date , 'YYYY-MM') = '2022-11'
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
select 
category,
sum(total_sale) as net_sale,
count(total_sale) as total_order
from retail_sales
group by category
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
select 
avg(age) as average_age
from retail_sales
where category = 'beauty'
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
select *
from retail_sales
where total_sale > 1000
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
select
gender,
category,
count(total_sale) as net_sale
from retail_sales
group by gender,
category
order by gender asc
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
with best_selling
as 
(
select
datename(month,sale_date) as month_of_sale,
datename(year,sale_date) as year_of_sale,
round(avg(total_sale),0) as average_sale_for_each_month

from retail_sales
group by datename(month,sale_date),
datename(year,sale_date)
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
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
select top 5
customer_id,
sum(total_sale) as net_sale
from retail_sales
group by customer_id 
order by net_sale desc
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
select
count(distinct(customer_id)),
category
from retail_sales
group by category
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.


- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/harshita-srivastava-660949332/)
- **E-Mail ID**: [(sriharshita987@gmail.com)]


