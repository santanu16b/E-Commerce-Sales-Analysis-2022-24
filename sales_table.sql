-- Create the database Project1 and then sales_table table for analysis

create database Project1;

use Project1;

CREATE TABLE sales_table (
    Order_Number    VARCHAR(100) primary key,
    Order_Date      DATE,
    Product_Name    VARCHAR(100),
    Category        VARCHAR(100),
    Region          VARCHAR(100),
    Quantity        INT,
    Sales           DECIMAL(10,2),
    Profit          DECIMAL(10,2),
    Profit_Margin DECIMAL(10,2));
    
  
-- import the csv file from the device usingthe data import wizard
-- cross check that the data is all there or not, for that, use the select function

select* from sales_table;

-- now a little bit of data exploration and insights generation

select count(*) as total_orders,
sum(sales) as total_sales,
sum(profit) as total_profit,
avg(profit_margin) as avg_profit_margin
from sales_table;

-- total_sales = 10667881.00, total_profit = 1844665.21, avg_profit_margin = 17.369951

select * from sales_table;

-- now we will find the top categories 

select Category, sum(quantity) as total_quantity from sales_table
group by Category
order by total_quantity desc limit 3;

-- Ranking - 1. Electronics- 8610, 2. Accessories- 6917, 3- Office- 1734 i.e. Eelectronics is the top category sold

select * from sales_table;

-- we will try to see the sales amount of each category for each year along with the profit

select year(Order_Date) as Year, sum(Sales) as total_sales, sum(Profit) as total_profit
from sales_table 
group by Year
order by total_sales desc, total_profit desc;

-- profit -> ranking - 1. 2023 - 666866.42, 2. 2024 - 604941.81,3.  2022 - 572856.98
-- sales -> highest - 1. 2023 - 3786592.00, 2. 2024- 3625319.00, 2022- 3255970.00

-- now we will look at the profit margins of all of these years collectively

select year(Order_Date) as Year, sum(Profit) as total_profit,
sum(Sales) as total_sales, round(sum(Profit)/sum(Sales)*100,2) as profit_margin from sales_table
group by Year 
order by Year;

-- Profit Margin -> It reveals exactly how much money a business keeps as profit for every dollar it earns in revenue.
-- Ranking in profit_margin - 1. 2022 -17.59%, 2. 2023 - 17.61%, 2024 - 16.69%
-- Even though the profit and sales of 2023 and 2024 were higher than 2022, the profit margin says otherwise
-- This means we were much efficient in managing costs in 2022 followed by 2023 and then 2024

-- now we will exactly which category of products are we having good or bad profit margins in

select sum(Profit) as total_profit, sum(Sales) as total_sales, Category, Year(Order_Date) as Year,
round(sum(Profit)/sum(Sales)*100,2) as profit_margin from sales_table
group by Category,Year order by Category asc;

-- Profit Margins -> 2022 - Accessories - 17.91%, Electronics -> 17.71%, Office - 15.62%
-- Profit Margins -> 2023 - Accessories - 17.49%, Electronics -> 17.61%, Office - 18.06%
-- Profit Margins -> 2024 - Accessories - 16.61%, Electronics -> 16.72%, Office - 16.81%
-- -- A downward trend, it shows something is increasing our costs down the years, so we can check Product Name

select sum(Profit) as total_profit, sum(Sales) as total_sales, Product_Name,Category,
Year(Order_Date) as Year, round(sum(Profit)/sum(Sales)*100,2) as Profit_Margin
from sales_table
 group by Product_name, Category, Year order by Profit_Margin desc limit 5;
 
 -- In this we can clearly see that in 2022 -> Laptop with 18.71% Profit Margin was the main driver for Electronics
 -- In the top 5, Accessories is in the bottom of top 5 with Headphones and Keyboard
 -- And yet, they have the highest profit margin, this means they are selling a huge quantity of products, which now we will check
 
 select sum(Quantity) as total_quantity, year(Order_Date) as Year,
 Category, Product_Name, round(sum(Profit)/sum(Sales)*100,2) as profit_margin 
 from sales_table
 group by Category, Product_Name, Year order by total_quantity asc limit 5;
 
 select sum(Quantity) as total_quantity, year(Order_Date) as Year,
 Category, Product_Name, round(sum(Profit)/sum(Sales)*100,2) as profit_margin 
 from sales_table
 group by Category, Product_Name, Year order by total_quantity desc limit 5;
 
 -- This now shows that Office category in 2022 was the highest quantity sold and yet they were lowest in profit and sales generation
 -- Also, Office category are also not in the bottom 5 meanwhile both Electronics and Accessories are
 -- It means that Office category with the product Printer is generating high sales volume but costs are higher than other categories

SELECT Product_Name, Category,
Year(Order_Date) as Year,
sum(Quantity) as total_quantity,
sum(Sales) as total_sales,
sum(Profit) as total_profit, round(sum(Sales)-sum(Profit), 2) as total_cost, 
round(sum(Profit)/sum(Sales)*100, 2) as profit_margin
from sales_table
where Category = 'Office'
group by  Product_Name, Category, Year
order by total_cost desc;

-- It shows us exactly that Printer is the biggest contributor in the increased costs in the Office Category
-- Now we have to check that which region is exactly having the highest and lowest profit margins

select Region, Category, Product_Name, Year(Order_Date) as Year, 
round(sum(profit)/sum(sales)*100,2) as profit_margin from sales_table
group by Product_Name ,Category, Region, Year order by profit_margin desc
limit 5;

select Region, Category, Product_Name, Year(Order_Date) as Year, 
round(sum(profit)/sum(sales)*100,2) as profit_margin from sales_table
group by Product_Name ,Category, Region, Year order by profit_margin asc
limit 5;

-- This shows us that the West Region is performing best in the Office category with Printers with a profit margin of 21.38%
-- This also shows us that in the South Region is performing worst in the Electronics category with Tablets with a profit margin of 11.33%
-- Now we will see which region is selling the most quantity along with the cost associated with it 

select Region, Category, Product_Name, Year(Order_Date) as Year, 
round(sum(profit)/sum(sales)*100,2) as profit_margin,
round(sum(sales)-sum(profit),2) as total_cost from sales_table
group by Product_Name ,Category, Region, Year order by  total_cost desc
limit 10;

select Region, Category, Product_Name, Year(Order_Date) as Year, 
round(sum(profit)/sum(sales)*100,2) as profit_margin,
round(sum(sales)-sum(profit),2) as total_cost from sales_table
group by Product_Name ,Category, Region, Year order by total_cost asc
limit 10;

-- We can now exactly see that in the South region we are incurring the highest costs with $93096.70 in the Electronics category with Tablets with the lowest margin
-- In the same South region, we are also incurring the lowest costs with $38439.98 in the Electronics category with smartphones

select Region, Category, sum(Quantity) as total_quantity,
sum(Sales) as total_sales, sum(Profit) as total_profit,
round(sum(Sales)-sum(Profit), 2) as total_cost,
round(sum(Profit)/sum(Sales)*100, 2) as profit_margin
from sales_table
group by Region, Category
order by profit_margin desc;

-- West has the highest with profit margin of 18.36% with 479 quantity of products sold
-- North being the lowest with profit margin of 14.58% with 376 quantity of products sold
-- Now we will see the monthly trend

select date_format(Order_Date, '%Y-%m') as Month, sum(Profit) as monthly_profit, sum(Sales) as monthly_sales,
round(sum(Profit)/sum(Sales)*100,2) as monthly_profit_margin from sales_table
group by Month order by Month;

-- Overall trend: revenue is growing but margins are contracting 
-- year over year (2022 avg ~17.59%, 2023 ~17.61%, 2024 ~16.69%).
-- Cost growth is outpacing revenue growth — a structural efficiency 
-- problem. 2024 shows no recovery month — the most concerning year.
-- Recommendation: investigate cost drivers in Electronics (South) 
-- and Printer category, where costs are highest relative to margin.

select Category,Product_Name, round(sum(Sales), 2) as total_sales,
round(sum(Profit)/sum(Sales)*100, 2) as margin_pct,
rank() over (partition by Category order by sum(Profit)/sum(Sales) desc) as rank_in_category
from sales_table
group by Category, Product_Name;

-- Laptop (Electronics) leads all products at 18.47% — highest margin overall.
-- Tablet (Electronics) is the weakest at 16.36% — lowest across all categories.
-- Accessories are the most consistent category with a tight 17.16%–17.45% range.
-- Printer (Office) at 16.94% sits below every Accessories product despite being
-- the only Office product — no high-margin item to compensate.
-- Priority: address cost structure of Tablet and Printer first.