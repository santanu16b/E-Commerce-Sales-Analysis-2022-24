# E-Commerce-Sales-Analysis-2022-24
Tools Used: Excel · MySQL · Tableau Dataset: Custom sales dataset — 3,500 rows across 3 categories, 4 regions, 10 products (2022–2024) Dashboard: https://public.tableau.com/app/profile/santanu.banerjee/viz/E-CommerceSalesDashboard_17809883086000/SalesDashboard?showOnboarding=true

Business Question
Revenue is growing year over year — but is the business actually becoming more profitable?
Which products, categories, and regions are driving or eroding profit margins?




**Dataset Overview**
Rows ~3,500 orders
Period -> January 2022 – December 2024
Categories -> Electronics, Accessories, OfficeRegionsEast, North, South, WestProductsLaptop, Camera, Smartphone, Smartwatch, Tablet, Headphones, Monitor, Mouse, Keyboard, Printer
Columns -> Order_Number, Order_Date, Product_Name, Category, Region, Quantity, Sales, Profit, Profit_Margin

What I Did:

Step 1 — Data Cleaning (Excel)

Imported the raw CSV and checked for nulls, duplicates, and formatting issues
Verified date formats, ensured numerical columns had no text values
Confirmed all 3,500 rows loaded correctly with no missing values in key columns
Kept a data notes log of every change made

Step 2 — Database Setup (MySQL)

Created the Project1 database and sales_table with appropriate data types
Imported the cleaned CSV using MySQL Workbench's Table Data Import Wizard
Ran exploratory queries to verify data integrity and overall summary metrics
Structured all queries with inline comments explaining the business logic

Step 3 — Analysis (MySQL)
Ran structured SQL queries across 7 analytical layers — overall summary, category performance, year-wise trends, product-level margin analysis, cost breakdown, regional deep dive, and monthly trends — progressively building toward the root cause of margin compression.
Step 4 — Visualisation (Tableau)

Connected the cleaned CSV to Tableau Public
Built 5 sheets: KPIs, Monthly Trend, Category Margin, Region, Products
Assembled into a single dashboard with a Year filter for interactivity
Added a reference line at the lowest margin point (December 2024)
Published to Tableau Public


Analysis & Insights
1. Overall Business Summary
SELECT count(*) as total_orders, sum(sales) as total_sales,
       sum(profit) as total_profit, avg(profit_margin) as avg_profit_margin
FROM sales_table;
<img width="384" height="50" alt="Screenshot 2026-06-09 at 4 27 41 PM" src="https://github.com/user-attachments/assets/c0ae54bc-b711-4d60-b603-ac7daf5930ee" />

Insight: The business is generating healthy overall revenue and profit. However, the average margin of 17.37% becomes the benchmark — anything below this at the category, product, or regional level signals a problem area requiring investigation.

2. Category Performance by Volume
SELECT Category, sum(quantity) as total_quantity FROM sales_table
GROUP BY Category ORDER BY total_quantity DESC;
<img width="159" height="78" alt="Screenshot 2026-06-09 at 4 29 20 PM" src="https://github.com/user-attachments/assets/bb2edb7e-dbe2-4716-a011-46dd8b395147" />

Insight: Electronics is the dominant category by volume — selling nearly 5× more than Office. However, volume alone does not tell the profitability story. The subsequent analysis reveals that high sales volume does not always translate to high margins.

3. Year-Wise Profit Margin Trend
SELECT year(Order_Date) as Year, sum(Profit) as total_profit,
       sum(Sales) as total_sales,
       round(sum(Profit)/sum(Sales)*100,2) as profit_margin
FROM sales_table GROUP BY Year ORDER BY Year;
<img width="418" height="83" alt="Screenshot 2026-06-09 at 4 30 17 PM" src="https://github.com/user-attachments/assets/fd1826ba-b66b-471e-8244-acbc6f9641b6" />

Insight: Revenue and profit in absolute terms are highest in 2023. However, profit margin tells a different story. Despite growing revenue from 2022 to 2023, the margin remained nearly flat (17.59% to 17.61%). In 2024, both revenue and margin declined — with margin dropping sharply to 16.69%. This means the business was most cost-efficient in 2022, and cost growth has been outpacing revenue growth since then — a structural efficiency problem, not a sales problem.

4. Category × Year Margin Analysis
SELECT sum(Profit) as total_profit, sum(Sales) as total_sales,
       Category, Year(Order_Date) as Year,
       round(sum(Profit)/sum(Sales)*100,2) as profit_margin
FROM sales_table GROUP BY Category, Year ORDER BY Category ASC;
<img width="485" height="167" alt="Screenshot 2026-06-09 at 4 31 00 PM" src="https://github.com/user-attachments/assets/fca62584-3886-4ec4-8db8-f156553de48d" />

Insight: Every category shows a downward trend by 2024 — no category has been immune to the margin compression. Office shows the most volatility, jumping from 15.62% in 2022 to 18.06% in 2023 before falling to 16.81% in 2024. Accessories started highest (17.91%) but has experienced the sharpest overall decline. This consistent cross-category decline points to a structural cost issue — likely rising input or operational costs that are not being offset by pricing.

5. Product-Level Cost Analysis (Office Category)
   SELECT Product_Name, Category, Year(Order_Date) as Year,
       sum(Quantity) as total_quantity, sum(Sales) as total_sales,
       sum(Profit) as total_profit,
       round(sum(Sales)-sum(Profit), 2) as total_cost,
       round(sum(Profit)/sum(Sales)*100, 2) as profit_margin
FROM sales_table WHERE Category = 'Office'
GROUP BY Product_Name, Category, Year ORDER BY total_cost DESC;
<img width="659" height="77" alt="Screenshot 2026-06-09 at 4 31 50 PM" src="https://github.com/user-attachments/assets/9c1cc217-ed61-4077-b186-3863cdcbd7b5" />

Insight: Printer is the sole product in the Office category and is the single biggest cost contributor in that category. Despite generating reasonable sales, the cost structure of Printer is significantly higher than comparable products in other categories. This explains why Office consistently sits at or below the overall average margin. The Printer is not generating enough margin to justify its cost base at the current pricing level.

6. Regional Performance Analysis
   SELECT Region, Category, sum(Quantity) as total_quantity,
       sum(Sales) as total_sales, sum(Profit) as total_profit,
       round(sum(Sales)-sum(Profit), 2) as total_cost,
       round(sum(Profit)/sum(Sales)*100, 2) as profit_margin
FROM sales_table GROUP BY Region, Category ORDER BY profit_margin DESC;
<img width="542" height="208" alt="Screenshot 2026-06-09 at 4 33 18 PM" src="https://github.com/user-attachments/assets/1bb88cb4-9d72-4aba-9ebb-6ee49493826c" />

Key regional findings:
West is the strongest performing region overall with the highest margin at 18.36%
North/Office is the single weakest segment at 14.58% — well below the overall average
South/Electronics/Tablet has the highest absolute cost at $93,096 with the lowest margin (11.33% at the product level) — the most concerning combination in the entire dataset
South also has the lowest-cost segment: Electronics/Smartphone at $38,440

Insight: The South region's Tablet problem is the most critical finding. The combination of high cost and low margin in one product-region segment represents the highest-priority intervention point in the business.

7. Monthly Trend Analysis
   SELECT date_format(Order_Date, '%Y-%m') as Month,
       sum(Profit) as monthly_profit, sum(Sales) as monthly_sales,
       round(sum(Profit)/sum(Sales)*100,2) as monthly_profit_margin
FROM sales_table GROUP BY Month ORDER BY Month;
<img width="348" height="424" alt="Screenshot 2026-06-09 at 4 34 12 PM" src="https://github.com/user-attachments/assets/2927cd5d-48df-4817-842a-6442385ded17" />

2022: Opens at 18.69% → declines and recovers through the year → ends at 17.27%. Peak: November at 19.49%.
2023: Opens at 18.56% → volatile movement throughout → ends at 20.13% (the highest single month across all 3 years). The year-end spike is an anomaly worth investigating — possibly a cost reduction or product mix shift in December.
2024: Opens at 17.59% (lower than both prior years' openings) → declines consistently → ends at 16.49% with no recovery month. This is the most alarming year — it deteriorates from the very start.
Insight: The opening margin of each year has declined consistently (18.69% → 18.56% → 17.59%), indicating a structural cost problem that is not being corrected between years. 2024 is the only year where both the starting and ending margins are lower than corresponding months in prior years — with no single recovery month. This suggests the cost problem accelerated in 2024.

8. Product Ranking by Margin (Window Function)
   SELECT Category, Product_Name,
       round(sum(Sales), 2) as total_sales,
       round(sum(Profit)/sum(Sales)*100, 2) as margin_pct,
       rank() over (partition by Category order by sum(Profit)/sum(Sales) desc)
       as rank_in_category
FROM sales_table GROUP BY Category, Product_Name;
<img width="405" height="186" alt="Screenshot 2026-06-09 at 4 35 24 PM" src="https://github.com/user-attachments/assets/021ca630-e215-4fb1-b0c3-14c812814e6b" />

Insight: Laptop is the standout performer across all categories at 18.47% — the highest margin product in the entire dataset. Tablet is the weakest at 16.36% — the lowest across all categories. Accessories is the most consistent category with a tight 17.16%–17.45% range, meaning no single product is significantly dragging it down. Office has no high-margin product to compensate for Printer's weakness — making it structurally vulnerable. Priority intervention: Tablet (Electronics) and Printer (Office).

Key Findings Summary
1. Revenue grew from $3.26M (2022) to $3.79M (2023) but margin compressed from 17.59% to 16.69% by 2024
2. Electronics leads in sales volume (8,610 units) but Tablet drags its margin to the lowest in the category
3. Laptop is the highest-margin product at 18.47% — its cost structure should be studied and replicated
4. Tablet (16.36%) and Printer (16.94%) are the two lowest-margin products and the primary cost intervention points
5. South region + Electronics + Tablet has the highest absolute cost ($93,097) and the lowest product-level margin (11.33%)
6. North region + Office is the weakest region-category combination at 14.58% margin
7. West region is the strongest overall at 18.36% — should be studied as a performance benchmark
8. 2024 is the only year with no single recovery month — margin declines from January to December without pause
9. December 2023 at 20.13% is the highest single-month margin across all 3 years — worth investigating as a best-practice case
10. The opening margin of each year has declined consistently (18.69% → 18.56% → 17.59%) — a structural, not seasonal, problem

Conclusion & Recommendations
1. The core finding of this analysis is that the business has a revenue growth problem masking a profitability problem. Sales figures suggest a healthy, growing business. But margin analysis reveals that cost growth is consistently outpacing revenue growth — and the gap is widening each year.
This is not a sales problem. It is a cost efficiency problem concentrated in specific products and regions.
Recommendation 1 — Address Tablet pricing or cost structure in the South region

2. The South/Electronics/Tablet combination has the highest cost and lowest margin in the dataset. Either renegotiate supplier costs for Tablets sold in the South, or implement a pricing adjustment of 3–5% to bring the margin in line with the category average.
Recommendation 2 — Review Printer cost structure in the Office category

3. Printer is the only Office product and consistently sits below the overall average margin. A cost audit of the Printer supply chain or a pricing revision is needed to bring Office margin above 17%.
Recommendation 3 — Study the Laptop cost model and apply learnings

4. Laptop at 18.47% is the highest-margin product. Understanding what makes Laptop's cost structure efficient — supplier terms, logistics, pricing strategy — and applying those learnings to Tablet and Smartwatch could recover 1–2% margin across Electronics.
Recommendation 4 — Investigate December 2023 as a best-practice case

5. The 20.13% margin in December 2023 is the highest single month in 3 years. What changed in that month — product mix, lower promotions, cost reduction? Replicating those conditions could help recover 2024's declining margins.
Recommendation 5 — Set a margin floor of 17% as a business KPI
Any product-region combination falling below 17% should trigger an automatic review. This prevents margin erosion from becoming normalized across the business.

Excel Dashboard -> <img width="1406" height="654" alt="Excel Dashboard" src="https://github.com/user-attachments/assets/82723011-426b-414b-b191-fc0dc81315b0" />

Tableau Dashboard -> <img width="1191" height="795" alt="Tableau Dashboard" src="https://github.com/user-attachments/assets/e91bba0d-958c-40c8-893f-a6ea54997de5" />

Tableau Dashboard Link -> https://public.tableau.com/app/profile/santanu.banerjee/viz/E-CommerceSalesDashboard_17809883086000/SalesDashboard
