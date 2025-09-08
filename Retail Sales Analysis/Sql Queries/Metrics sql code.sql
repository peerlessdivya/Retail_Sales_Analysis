----CUSTOMER-LEVEL METRICS (customer_360)

-- 1. Total Customers
SELECT distinct COUNT(custid) AS Total_Customers FROM customer_360;


SELECT COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM order_360;

-- 2. Male vs Female Customers
SELECT Gender, COUNT(*) AS Total FROM customer_360 GROUP BY Gender;

-- 3. Customers by Region
SELECT customer_state, COUNT(*) AS Total_Customers FROM customer_360 GROUP BY customer_state;

select * from order_360

---4 Average sale per customer 
SELECT AVG(CustomerSales) AS Avg_Sales_Per_Customer
FROM (
  SELECT Customer_ID, SUM(Total_Payment_Value) AS CustomerSales
  FROM order_360
  GROUP BY Customer_ID
) AS t;

---5. Average discount per customer 

SELECT AVG(CustomerDiscount) AS Avg_Discount_Per_Customer
FROM (
  SELECT 
    Customer_ID, 
    SUM(CAST(Total_Discount AS FLOAT)) AS CustomerDiscount
  FROM order_360
  GROUP BY Customer_ID
) AS t;


---6.Average profit per customer 
SELECT AVG(CustomerProfit) AS Avg_Profit_Per_Customer
FROM (
  SELECT 
    Customer_ID, 
    SUM(CAST(Profit AS FLOAT)) AS CustomerProfit
  FROM order_360
  GROUP BY Customer_ID
) AS t;

------7.Average Transaction per customer
SELECT AVG(CAST(OrderCount AS FLOAT)) AS Transactions_Per_Customer
FROM (
  SELECT 
    Customer_ID, 
    COUNT(DISTINCT Order_ID) AS OrderCount
  FROM order_360
  GROUP BY Customer_ID
) AS t;



---ORDER-LEVEL METRICS

---Total Order Placed
SELECT COUNT(DISTINCT Order_ID) AS Total_Orders
FROM order_360;

-- 8. Preferred Channel Count
SELECT Channel, COUNT(*) AS Total_Customers FROM order_360 GROUP BY Channel;




-- 10. Total Revenue
SELECT SUM(total_amount) AS Total_Revenue FROM order_360;

-- 11. Total Profit
SELECT SUM(Profit) AS Total_Profit FROM order_360;

-- 12. Average Order Value
SELECT AVG(total_amount) AS Avg_Order_Value FROM order_360;

-- 13. Average Profit per Order
SELECT AVG(Profit) AS Avg_Profit_Per_Order FROM order_360;

-- 14. Average Discount per Order
SELECT 
  CAST(AVG(Total_Discount) AS DECIMAL(10,2)) AS Avg_Discount_Per_Order 
FROM 
  order_360;


-- 15. Average Quantity per Order
SELECT AVG(Total_Quantity) AS Avg_Quantity_Per_Order FROM order_360;



-- 16. Orders by Month
SELECT MONTH(Bill_date_timestamp) AS Month, COUNT(*) AS Orders FROM order_360 
GROUP BY MONTH(Bill_date_timestamp)
order by month(Bill_date_timestamp)

-- 17. Monthly Sales Trend
SELECT MONTH(Bill_date_timestamp) AS Month, SUM(Total_Amount) AS Total_Sales FROM order_360 
GROUP BY MONTH(Bill_date_timestamp)
order by month(Bill_date_timestamp)

--------------------------------------------------------------------------------------------

---PRODUCT-LEVEL METRICS 

-- 18 Total Products
SELECT COUNT(*) AS Total_Products FROM product_360;

-- 19. Products by Category
SELECT Category, COUNT(*) AS Product_Count FROM product_360 GROUP BY Category;

-- 20. Average Price by Category
SELECT Category, AVG(Total_Revenue) AS Avg_Price FROM product_360 GROUP BY Category;

-- 21. Price Range Distribution
SELECT 
  CASE 
    WHEN Total_revenue < 100 THEN 'Low'
    WHEN Total_revenue  BETWEEN 100 AND 500 THEN 'Medium'
    ELSE 'High'
  END AS Price_Range,
  COUNT(*) AS Product_Count
FROM product_360
GROUP BY 
  CASE 
    WHEN Total_revenue < 100 THEN 'Low'
    WHEN Total_revenue BETWEEN 100 AND 500 THEN 'Medium'
    ELSE 'High'
  END;

-- 22. Average Price of All Products
SELECT AVG(Total_Revenue) AS Avg_Product_Price FROM product_360;


-----------------------------------------------------------------------------------------------
-- 23 Total Stores
SELECT COUNT(*) AS Total_Stores FROM store360;

-- 24. Stores by Region
SELECT Region, COUNT(*) AS Total_Stores FROM store360 GROUP BY Region;



-- 27 Average Satisfaction by Store
SELECT AVG(Avg_Satisfaction_score) AS Avg_Satisfaction FROM store360;

-- 28 Store Ratings Distribution
SELECT 
  CASE 
    WHEN Satisfaction BETWEEN 0 AND 2 THEN 'Low'
    WHEN Satisfaction BETWEEN 2.1 AND 4 THEN 'Medium'
    ELSE 'High'
  END AS Satisfaction_Level,
  COUNT(*) AS Store_Count
FROM store360
GROUP BY 
  CASE 
    WHEN Satisfaction BETWEEN 0 AND 2 THEN 'Low'
    WHEN Satisfaction BETWEEN 2.1 AND 4 THEN 'Medium'
    ELSE 'High'
  END;
