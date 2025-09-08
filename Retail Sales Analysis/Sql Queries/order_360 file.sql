
--1. Total Orders Summary

SELECT COUNT(DISTINCT Order_ID) AS total_orders,
       SUM(Total_Amount) AS total_sales
FROM Order_360;

---2.Daily Order Trend

SELECT CAST(Bill_date_Timestamp AS DATE) AS order_date,
       COUNT(*) AS total_orders,
       SUM(Total_Amount) AS revenue
FROM Order_360
GROUP BY CAST(Bill_date_Timestamp AS DATE)
ORDER BY order_date;

---3. Channel wise orders

SELECT Channel,
       COUNT(Order_ID) AS total_orders,
       SUM(Total_Amount) AS total_revenue
FROM Order_360
GROUP BY Channel;

---4.Average order value 

SELECT AVG(Total_Amount) AS average_order_value
FROM Order_360;

---5.Profit Distribution 


SELECT 
    ROUND(MIN(Profit), 4) AS min_profit,
    ROUND(MAX(Profit), 4) AS max_profit,
    ROUND(AVG(Profit), 4) AS avg_profit
FROM Order_360;



---6.Discount Impact Analysis


SELECT 
    CASE 
        WHEN Discount_Percentage = 0 THEN '0%'
        WHEN Discount_Percentage BETWEEN 1 AND 10 THEN '1-10%'
        WHEN Discount_Percentage BETWEEN 11 AND 20 THEN '11-20%'
        WHEN Discount_Percentage BETWEEN 21 AND 30 THEN '21-30%'
        WHEN Discount_Percentage BETWEEN 31 AND 40 THEN '31-40%'
        WHEN Discount_Percentage BETWEEN 41 AND 50 THEN '41-50%'
        ELSE '50%+' 
    END AS Discount_Range,
    COUNT(Order_ID) AS orders,
    SUM(Total_Amount) AS revenue
FROM Order_360
GROUP BY 
    CASE 
        WHEN Discount_Percentage = 0 THEN '0%'
        WHEN Discount_Percentage BETWEEN 1 AND 10 THEN '1-10%'
        WHEN Discount_Percentage BETWEEN 11 AND 20 THEN '11-20%'
        WHEN Discount_Percentage BETWEEN 21 AND 30 THEN '21-30%'
        WHEN Discount_Percentage BETWEEN 31 AND 40 THEN '31-40%'
        WHEN Discount_Percentage BETWEEN 41 AND 50 THEN '41-50%'
        ELSE '50%+' 
    END
ORDER BY Discount_Range;


---7.Payment mode analysis 

SELECT 
    SUM(Credit_Card_Payment) AS credit_card_total,
    SUM(Debit_Card_Payment) AS debit_card_total,
    --SUM(UPI_Cash_Payment) AS upi_cash_total,
    SUM(Voucher_Payment) AS voucher_total
FROM Order_360;

select * from order_360
---8. Quantity-wise Order Grouping

SELECT 
    CASE 
        WHEN Total_Quantity <= 2 THEN '1-2'
        WHEN Total_Quantity <= 5 THEN '3-5'
        ELSE '6+'
    END AS quantity_bucket,
    COUNT(*) AS order_count
FROM Order_360
GROUP BY 
    CASE 
        WHEN Total_Quantity <= 2 THEN '1-2'
        WHEN Total_Quantity <= 5 THEN '3-5'
        ELSE '6+'
    END;

---9.Profit % Bucket Analysis

SELECT 
    CASE 
        WHEN Profitpercent < 5 THEN 'Low Profit (<5%)'
        WHEN Profitpercent < 15 THEN 'Medium Profit (5-15%)'
        ELSE 'High Profit (>15%)'
    END AS profit_range,
    COUNT(*) AS orders
FROM Order_360
GROUP BY 
    CASE 
        WHEN Profitpercent < 5 THEN 'Low Profit (<5%)'
        WHEN Profitpercent < 15 THEN 'Medium Profit (5-15%)'
        ELSE 'High Profit (>15%)'
    END;


---10.Profit by channel

SELECT Channel,
       SUM(Profit) AS total_profit
FROM Order_360
GROUP BY Channel;


---11. Top 10 Most Profitable Orders
SELECT TOP 10 Order_ID, Profit
FROM Order_360
ORDER BY Profit DESC;

---12.Order Count by Store
SELECT Delivered_StoreID,
       COUNT(*) AS order_count,
       SUM(Total_Amount) AS revenue
FROM Order_360
GROUP BY Delivered_StoreID
--ORDER BY revenue DESC;

---13. Customer Satisfaction Distribution

SELECT Customer_Satisfaction_Score,
       COUNT(*) AS order_count,
       AVG(Total_Amount) AS avg_spend
FROM Order_360
GROUP BY Customer_Satisfaction_Score
order by customer_satisfaction_score

---14. Most Discounted Orders (Top 10)
SELECT TOP 10 Order_ID, Total_Discount
FROM Order_360
ORDER BY Total_Discount DESC;


---15.Revenue Vs Cost 
SELECT SUM(Total_Amount) AS total_revenue,
       SUM(Total_Cost_Price) AS total_cost,
       SUM(Total_Amount) - SUM(Total_Cost_Price) AS gross_profit
FROM Order_360;


---16.Top Dates by Revenue
SELECT TOP 5 
    CAST(Bill_date_Timestamp AS DATE) AS order_date,
    SUM(Total_Amount) AS daily_revenue
FROM Order_360
GROUP BY CAST(Bill_date_Timestamp AS DATE)
ORDER BY daily_revenue DESC;


-------------Retention of Customers Month-on-Month----------------

WITH MonthlyOrders AS (
    SELECT 
        Customer_ID,
        FORMAT(Bill_date_Timestamp, 'yyyy-MM') AS Order_Month
    FROM Order_360
    GROUP BY Customer_ID, FORMAT(Bill_date_Timestamp, 'yyyy-MM')
)

SELECT 
    Order_Month,
    COUNT(DISTINCT Customer_ID) AS Active_Customers
FROM MonthlyOrders
GROUP BY Order_Month
ORDER BY Order_Month;

---
------------Sales by month and channel 

SELECT 
    FORMAT(Bill_date_Timestamp, 'yyyy-MM') AS YearMonth,
    DATENAME(MONTH, Bill_date_Timestamp) AS MonthName,
    Channel,
    SUM(Total_Amount) AS Monthly_Sales
FROM Order_360
GROUP BY 
    FORMAT(Bill_date_Timestamp, 'yyyy-MM'),
    DATENAME(MONTH, Bill_date_Timestamp),
    Channel
ORDER BY YearMonth;
-------------------
---Sales by Month with Contribution %
WITH monthly_sales AS (
  SELECT 
    FORMAT(Bill_date_Timestamp, 'yyyy-MMMM') AS Order_Month,
    SUM(Total_Amount) AS Monthly_Sales
  FROM order_360
  GROUP BY FORMAT(Bill_date_Timestamp, 'yyyy-MMMM')
),
total_sales AS (
  SELECT SUM(Monthly_Sales) AS Total_Sales
  FROM monthly_sales
)
SELECT 
  m.Order_Month,
  m.Monthly_Sales,
  ROUND((m.Monthly_Sales * 100.0) / t.Total_Sales, 2) AS Contribution_Percent
FROM monthly_sales m
CROSS JOIN total_sales t
ORDER BY m.Order_Month DESC;
