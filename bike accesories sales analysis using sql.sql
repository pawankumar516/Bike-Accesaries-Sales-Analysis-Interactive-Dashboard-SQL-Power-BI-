use bikes;

select * from sales_data;

#BASIC QUERIES (1-5)

#Q1:write a query for Total Sales Overview
select count(*) as count,
       sum(profit) as total_profit,
       sum(cost) as total_cost,
       sum(revenue) as total_revenue,
       round(sum(profit/revenue)*100,2) as profit_margin
       from sales_data;
       
#Q2:write query for Sales by Product Category
select Product_Category,
       sum(profit) as total_profit,
       sum(cost) as total_cost,
       sum(revenue) as total_revenue,
       round(sum(profit/revenue)*100,2) as profit_margin
       from sales_data
       group by Product_Category
       order by total_profit desc;
       
#Q3:write a query for Customer Segmentation by Age Group
select age_group,
       count(distinct customer_age) as uinique_customer,
       sum(profit) as total_profit,
       sum(revenue) as total_revenue
       from sales_data
       group by Age_Group;
       
#Q4:write a query for Geographic Performance (Country Level)
 

select country,
       count(*) as count,
       sum(profit) as profit,
       sum(revenue) as revenue,
       round((SUM(Revenue) / (SELECT SUM(Revenue) FROM sales_data))*100,2)
       as MarketSharePercent from sales_data
       group by country;

#Q5:write a query for Time-Based Sales Trend (Annual)
SELECT 
    Year,
    COUNT(*) as OrderCount,
    SUM(Revenue) as TotalRevenue,
    SUM(Profit) as TotalProfit,
    ROUND((SUM(Profit) / SUM(Revenue)) * 100, 2) as ProfitMarginPercent,
    LAG(SUM(Revenue)) OVER (ORDER BY Year) as PreviousYearRevenue,
    ROUND(((SUM(Revenue) - LAG(SUM(Revenue)) OVER (ORDER BY Year)) /
    NULLIF(LAG(SUM(Revenue)) OVER (ORDER BY Year), 0)) * 100, 2) as
    YoYGrowthPercent
FROM sales_data
GROUP BY Year
ORDER BY Year;


#INTERMEDIATE QUERIES (6-10)

#Q6:write a query for Product Performance Analysis (Top 10)
select product,
       Product_Category,
       Sub_Category,
       count(*) as count,
       sum(profit) as total_profit,
       sum(revenue) as total_revenue,
       round(sum(profit/revenue)*100,2) as profit_margin,
       sum(Order_Quantity) as quantity
       from sales_data
       group by product,Product_Category,Sub_Category
       order by total_revenue desc;
       
#Q7:write a query for Gender-Based Purchase Behavior
select customer_gender,
	   count(*) as count,
       sum(profit) as total_profit,
       sum(revenue) as total_revenue,
       round(sum(profit/revenue)*100,2) as profit_margin,
       avg(revenue) as avg_revenue,
       sum(Order_Quantity) as quantity
       from sales_data
       group by Customer_Gender;
       
#Q8:write a query for Regional State-Level Analysis
select state,
       count(*) as count,
       sum(profit) as profit,
       sum(revenue) as revenue,
       round((SUM(Revenue) / (SELECT SUM(Revenue) FROM sales_data))*100,2)
       as MarketSharePercent from sales_data
       group by state;
       
#Q9:write a query for Category × SubCategory Cross-Analysis
select product_category,
       Sub_Category,
       count(*) as count,
       sum(profit) as profit,
       sum(revenue) as revenue,
       round((SUM(Revenue) / (SELECT SUM(Revenue) FROM sales_data))*100,2)
       as MarketSharePercent from sales_data
       group by Product_Category,Sub_Category;
       
#Q10:write a query for Customer Lifetime & Purchase Frequency
WITH CustomerFrequency AS (
    SELECT 
        CONCAT(Customer_Age, Customer_Gender, Country, State) as CustomerId,
        COUNT(*) as PurchaseFrequency,
        SUM(Revenue) as TotalMonetary,
        SUM(Profit) as TotalProfit
    FROM sales_data
    GROUP BY CONCAT(Customer_Age, Customer_Gender, Country, State)
)
SELECT 
    CASE 
        WHEN PurchaseFrequency = 1 THEN '1 Purchase'
        WHEN PurchaseFrequency BETWEEN 2 AND 3 THEN '2-3 Purchases'
        WHEN PurchaseFrequency BETWEEN 4 AND 5 THEN '4-5 Purchases'
        ELSE '6+ Purchases'
    END as FrequencySegment,
    COUNT(*) as CustomerCount,
    ROUND(AVG(PurchaseFrequency), 2) as AvgFrequency,
    ROUND(AVG(TotalMonetary), 2) as AvgMonetaryValue,
    SUM(TotalMonetary) as TotalSegmentRevenue
FROM CustomerFrequency
GROUP BY 
    CASE 
        WHEN PurchaseFrequency = 1 THEN '1 Purchase'
        WHEN PurchaseFrequency BETWEEN 2 AND 3 THEN '2-3 Purchases'
        WHEN PurchaseFrequency BETWEEN 4 AND 5 THEN '4-5 Purchases'
        ELSE '6+ Purchases'
    END
ORDER BY CustomerCount DESC;

#ADVANCED QUERIES (11-15)

#Q11:write a query for Profitability Margin Analysis by Segment
select age_group,
       product_category,
       count(*) as transaction_count,
       sum(profit) as total_profit,
       sum(revenue) as total_revenue,
       round((sum(profit)/sum(revenue))*100,2) as profit_margin_percentage from sales_data
       group by age_group,product_category
       order by total_profit desc,total_revenue;
       
#Q12:write a query for Seasonal and Temporal Trend Analysis
select year,
       case
       when month between 1 and 3 then 'Q1'
       when month between 4 and 6 then 'Q2'
       when month between 7 and 9 then 'Q3'
       else 'Q4' end as quarter,
       count(*) as count,
       sum(profit) as profit,
       sum(revenue) as revenue,
       round((sum(profit)/sum(revenue))*100,2) as profit_margin
       from sales_data
       group by year,case
       when month between 1 and 3 then 'Q1'
       when month between 4 and 6 then 'Q2'
       when month between 7 and 9 then 'Q3'
       else 'Q4' end
       order by year, quarter;
       
#Q13:write a query for Market Share and Competitive Position
WITH ProductYearMetrics AS (
    SELECT 
        Product,
        product_Category,
        Year,
        SUM(Revenue) as YearRevenue,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY SUM(Revenue) DESC) as YearRank
    FROM sales_data
    GROUP BY Product, product_Category, Year
)
SELECT 
    Product,
    product_Category,
    SUM(CASE WHEN Year = 2016 THEN YearRevenue END) as Revenue2016,
    SUM(CASE WHEN Year = 2015 THEN YearRevenue END) as Revenue2015,
    ROUND(((SUM(CASE WHEN Year = 2016 THEN YearRevenue END) - SUM(CASE WHEN Year = 2015 THEN YearRevenue END)) / NULLIF(SUM(CASE WHEN Year = 2015 THEN YearRevenue END), 0)) * 100, 2) as GrowthRatePercent,
    MAX(YearRank) as BestYearRank
FROM ProductYearMetrics
WHERE Year IN (2015, 2016)
GROUP BY Product, product_Category
ORDER BY Revenue2016 DESC;

 