---1.Total Customers

SELECT COUNT(*) AS Total_Customers FROM Customer_360

---2. Customer count by gender 

SELECT Gender, COUNT(*) AS Customer_Count FROM Customer_360 GROUP BY Gender

--3.Customer by state

SELECT customer_state, COUNT(*) AS Customers FROM Customer_360
GROUP BY customer_state ORDER BY Customers DESC;

---4.Top 10 customer by total orders

SELECT top 10  Custid, No_of_Total_Orders FROM Customer_360
ORDER BY No_of_Total_Orders DESC 

select * from customer_360
------

-------New Customer acquired every month 
SELECT
    FORMAT(first_purchase_date, 'MMM yyyy') AS Acquisition_Month,
    COUNT(DISTINCT Custid) AS New_Customers
FROM Customer_360
GROUP BY FORMAT(first_purchase_date, 'MMM yyyy')
ORDER BY MIN(first_purchase_date);



---5.Order Channel Preference Segmentation

SELECT 
    Custid,
    No_of_Online_Orders,
    No_of_Instore_Orders,
    No_of_Phone_Delivery_Orders,
    CASE 
        WHEN No_of_Online_Orders >= GREATEST(No_of_Instore_Orders, No_of_Phone_Delivery_Orders) 
		THEN 'Online'
        WHEN No_of_Instore_Orders >= GREATEST(No_of_Online_Orders, No_of_Phone_Delivery_Orders) 
		THEN 'In-Store'
        ELSE 'Phone Delivery'
    END AS Preferred_Channel
FROM Customer_360
order by No_of_Instore_Orders desc

---6. Average Orders by City
SELECT customer_city, AVG(No_of_Total_Orders) AS Avg_Orders 
FROM Customer_360 
GROUP BY customer_city
order by Avg_Orders  desc

select count(distinct customer_city) from Customer_360

--7.Top 10 Customers by Revenue

SELECT top 10
    Custid,
    No_of_Total_Orders * Avg_Revenue_Per_Order AS Estimated_Revenue
FROM Customer_360
order by Estimated_Revenue desc
----------------------
SELECT --top 10
    c.Custid,
    SUM(o.Total_Amount) AS Total_Revenue
FROM Customer_360 c
JOIN Order_360 o 
    ON c.Custid = o.Customer_ID
GROUP BY c.Custid
ORDER BY Total_Revenue DESC


--8.Top Customers by Profit
SELECT top 10 Custid, Profit FROM Customer_360
ORDER BY Profit DESC 

--9.Avg Revenue Per Order by State
SELECT top 10
customer_state, AVG(Avg_Revenue_Per_Order) AS Avg_Order_Value
FROM Customer_360 GROUP BY customer_state
order by Avg_Order_Value desc

--10."How many customers have used discounts, and what is the average discount value used by them?"


SELECT 
    CASE 
        WHEN Total_Discount > 0 THEN 'Yes'
        ELSE 'No'
    END AS Discount_benefit, 
    COUNT(*) AS No_of_Customers,
    AVG(Total_Discount) AS Avg_Discount_Used
FROM Customer_360
GROUP BY 
    CASE 
        WHEN Total_Discount > 0 THEN 'Yes'
        ELSE 'No'
    END;

---11.Recency, Frequency, Monetary
SELECT
    Custid,
    DATEDIFF(DAY, Last_Purchase_Date, GETDATE()) AS Recency,
    No_of_Total_Orders AS Frequency,
     No_of_Total_Orders * Avg_Revenue_Per_Order  AS Monetary
FROM Customer_360;

---12.Inactive Customers with High Revenue

SELECT Custid, No_of_Total_Orders * Avg_Revenue_Per_Order as Total_Revenue, Last_Purchase_Date
FROM Customer_360
WHERE Status = 'Inactive' AND  No_of_Total_Orders * Avg_Revenue_Per_Order > 500
ORDER BY Total_Revenue DESC;

---13.Days Since Last Purchase

SELECT Custid, DATEDIFF(DAY, Last_Purchase_Date, GETDATE()) AS Days_Since_Last_Purchase
FROM Customer_360


---14.Average Satisfaction by State

SELECT customer_state, AVG(Customer_Satisfaction_Score) AS Avg_Score
FROM Customer_360
GROUP BY customer_state
ORDER BY Avg_Score DESC;

---15.Count of Low Satisfaction Customers (Score <= 2)
SELECT COUNT(*) AS Unhappy_Customers
FROM Customer_360
WHERE Customer_Satisfaction_Score <= 2;

---16.Credit/Debit/Voucher Users


SELECT 
  Credit_Users,
  Debit_Users,
  Voucher_Users

FROM
(
  SELECT 
    COUNT(CASE WHEN Credit_Card_User = 'Yes' THEN 1 END) AS Credit_Users,
    COUNT(CASE WHEN Debit_Card_User = 'Yes' THEN 1 END) AS Debit_Users,
    COUNT(CASE WHEN Voucher_User = 'Yes' THEN 1 END) AS Voucher_Users
	FROM Customer_360
) AS x


select * from customer_360
---17. Payment Type Distribution by Gender

SELECT 
    Gender,
    SUM(CASE WHEN Credit_Card_User = 'yes' THEN 1 ELSE 0 END) AS Credit_Card_Users,
    SUM(CASE WHEN Debit_Card_User = 'yes' THEN 1 ELSE 0 END) AS Debit_Card_Users,
    SUM(CASE WHEN Voucher_User = 'yes' THEN 1 ELSE 0 END) AS Voucher_Users
FROM Customer_360
GROUP BY Gender;

---18. Customer Tiering Based on Revenue
SELECT Custid,
    CASE 
        WHEN No_of_Total_Orders * Avg_Revenue_Per_Order >= 1000 THEN 'Platinum'
        WHEN No_of_Total_Orders * Avg_Revenue_Per_Order >= 500 THEN 'Gold'
        WHEN No_of_Total_Orders * Avg_Revenue_Per_Order >= 100 THEN 'Silver'
        ELSE 'Bronze'
    END AS Revenue_Tier
FROM Customer_360

---19.Customers by First Purchase Month

SELECT 
    FORMAT(CAST(First_Purchase_Date AS DATE), 'yyyy-MM') AS Acquisition_Month,
    COUNT(*) AS Customer_Count
FROM Customer_360
GROUP BY FORMAT(CAST(First_Purchase_Date AS DATE), 'yyyy-MM')
ORDER BY Acquisition_Month;

---20. High Order, High Satisfaction Customers

SELECT Custid, No_of_Total_Orders, Customer_Satisfaction_Score
FROM Customer_360
WHERE No_of_Total_Orders >= 5 AND Customer_Satisfaction_Score >= 4;


-------------Revenue from New vs Existing Customers------------------------

WITH FirstPurchase AS (
    SELECT 
        Customer_ID,
        MIN(Bill_date_Timestamp) AS First_Purchase_Date
    FROM Order_360
    GROUP BY Customer_ID
),
OrderData AS (
    SELECT 
        o.Customer_ID,
        FORMAT(o.Bill_date_Timestamp, 'yyyy-MM') AS Month,
        o.Total_Amount,
        CASE 
            WHEN o.Bill_date_Timestamp = fp.First_Purchase_Date THEN 'New'
            ELSE 'Existing'
        END AS Customer_Type
    FROM Order_360 o
    JOIN FirstPurchase fp ON o.Customer_ID = fp.Customer_ID
)

SELECT 
    Month,
    Customer_Type,
    SUM(Total_Amount) AS Revenue
FROM OrderData
GROUP BY Month, Customer_Type
ORDER BY Month;
