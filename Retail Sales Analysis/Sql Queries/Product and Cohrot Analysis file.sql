
---1.Categorywise Highest number of total orders------
SELECT 
    p.Category,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders
FROM product_360 p
JOIN Orders o ON p.Product_ID = o.Product_ID
GROUP BY  p.Category
ORDER BY Total_Orders DESC;

---2.Products with Most Unique Customers
SELECT 
    p.Product_ID,
    COUNT(DISTINCT o.Customer_ID) AS Unique_Customers
FROM product_360 p
JOIN Orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Product_ID
ORDER BY Unique_Customers DESC;

---3.Category with Highest Total Quantity Sold

SELECT 
    p.Category,
    SUM(o.Quantity) AS Total_Quantity_Sold
FROM product_360 p
JOIN orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Category
ORDER BY Total_Quantity_Sold DESC;

select * from orders

---4.Product generating with highest revenue 

SELECT 
    p.Product_ID,
    SUM(o.Quantity * (p.MRP_Per_Unit - p.Discount_Per_Unit)) AS Total_Revenue
FROM product_360 p
JOIN orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Product_ID
ORDER BY Total_Revenue DESC;

---5.Product Generating Highest Profit

SELECT 
    p.Product_ID,
    SUM(o.Quantity * (p.MRP_Per_Unit - p.Discount_Per_Unit - p.Cost_Price_Per_Unit)) AS Total_Profit
FROM product_360 p
JOIN orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Product_ID
ORDER BY Total_Profit DESC;
---6.Products with High Revenue but Low Profit
SELECT 
    p.Product_ID,
    SUM(o.Quantity * (p.MRP_Per_Unit - p.Discount_Per_Unit)) AS Total_Revenue,
    SUM(o.Quantity * (p.MRP_Per_Unit - p.Discount_Per_Unit - p.Cost_Price_Per_Unit)) AS Total_Profit
FROM product_360 p
JOIN orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Product_ID
HAVING SUM(o.Quantity * (p.MRP_Per_Unit - p.Discount_Per_Unit)) > 10000
   AND SUM(o.Quantity * (p.MRP_Per_Unit - p.Discount_Per_Unit - p.Cost_Price_Per_Unit)) < 1000
ORDER BY Total_Revenue DESC;
-------------------------------------------------------------------------------------------------

----1.Cohrot Analysis--------------
---- It  tracks how many unique customers make purchases each month after their first purchase.


-- Step 1: Identify the first purchase date for each customer
WITH FirstOrders AS (
    SELECT 
        Customer_ID,
        MIN(CAST(Bill_date_Timestamp AS DATE)) AS First_Order_Date
    FROM Order_360
    GROUP BY Customer_ID
),

-- Step 2: Map each order to cohort and order month
CohortMapping AS (
    SELECT 
        o.Customer_ID,
        o.Order_ID,
        CAST(o.Bill_date_Timestamp AS DATE) AS Order_Date,
        FORMAT(f.First_Order_Date, 'yyyy-MM') AS Cohort_Month,
        FORMAT(CAST(o.Bill_date_Timestamp AS DATE), 'yyyy-MM') AS Order_Month,
        o.Total_Amount
    FROM Order_360 o
    JOIN FirstOrders f ON o.Customer_ID = f.Customer_ID
),

-- Step 3: Get customer counts per cohort
CohortStats AS (
    SELECT 
        Cohort_Month,
        COUNT(DISTINCT Customer_ID) AS Cohort_Customers
    FROM CohortMapping
    WHERE Order_Month = Cohort_Month
    GROUP BY Cohort_Month
),
---select * from cohortStats order by cohort_month

-- Step 4: Identify customers who placed repeat orders in later months
RepeatCustomers AS (
    SELECT 
        Cohort_Month,
        Customer_ID,
        DATEDIFF(
            MONTH,
            MIN(Order_Date),
            MIN(CASE WHEN Order_Month <> Cohort_Month THEN Order_Date END)
        ) AS Months_To_Repeat
    FROM CohortMapping
    GROUP BY Cohort_Month, Customer_ID
    HAVING COUNT(DISTINCT Order_Month) > 1
),

-- Step 5: Final aggregation
FinalCohortAnalysis AS (
    SELECT 
        cs.Cohort_Month,
        cs.Cohort_Customers,

        COALESCE(COUNT(DISTINCT rc.Customer_ID), 0) AS Repeat_Customers,

        ROUND(
            CASE WHEN cs.Cohort_Customers > 0 
                THEN 100.0 * COUNT(DISTINCT rc.Customer_ID) / cs.Cohort_Customers 
                ELSE 0 END, 2
        ) AS Retention_Rate,

        -- Replace NULL with 0.0 for months to repeat
        ISNULL(ROUND(AVG(rc.Months_To_Repeat * 1.0), 1), 0.0) AS Avg_Months_To_Repeat,

        ISNULL(COUNT(CASE WHEN cm.Order_Month = cm.Cohort_Month THEN cm.Order_ID END), 0) AS Total_Orders_Cohort_Customers,
        ISNULL(SUM(CASE WHEN cm.Order_Month = cm.Cohort_Month THEN cm.Total_Amount ELSE 0 END), 0) AS Total_Revenue_Cohort_Customers,

        ISNULL(COUNT(CASE WHEN cm.Order_Month <> cm.Cohort_Month THEN cm.Order_ID END), 0) AS Total_Orders_Repeat_Customers,
        ISNULL(SUM(CASE WHEN cm.Order_Month <> cm.Cohort_Month THEN cm.Total_Amount ELSE 0 END), 0) AS Total_Revenue_Repeat_Customers

    FROM CohortStats cs
    LEFT JOIN RepeatCustomers rc ON cs.Cohort_Month = rc.Cohort_Month
    LEFT JOIN CohortMapping cm ON cs.Cohort_Month = cm.Cohort_Month
        AND cm.Customer_ID IN (
            SELECT Customer_ID FROM CohortMapping WHERE Order_Month = Cohort_Month
        )
    GROUP BY cs.Cohort_Month, cs.Cohort_Customers
)


-- Step 6: Final Output
SELECT *
FROM FinalCohortAnalysis
ORDER BY Cohort_Month;
----------------------------------------------------------------------------------------------------
----How does customer retention evolve over time for each acquisition cohort?

WITH FirstOrders AS (
    SELECT 
        Customer_ID,
        MIN(CAST(Bill_date_Timestamp AS DATE)) AS First_Order_Date
    FROM Order_360
    GROUP BY Customer_ID
),

CohortData AS (
    SELECT 
        o.Customer_ID,
        FORMAT(f.First_Order_Date, 'yyyy-MM') AS Cohort_Month,
        DATEDIFF(MONTH, f.First_Order_Date, CAST(o.Bill_date_Timestamp AS DATE)) AS Month_Index
    FROM Order_360 o
    JOIN FirstOrders f ON o.Customer_ID = f.Customer_ID
)

SELECT
    Cohort_Month,
    COUNT(DISTINCT CASE WHEN Month_Index = 0 THEN Customer_ID END) AS Month_0,
    COUNT(DISTINCT CASE WHEN Month_Index = 1 THEN Customer_ID END) AS Month_1,
    COUNT(DISTINCT CASE WHEN Month_Index = 2 THEN Customer_ID END) AS Month_2,
    COUNT(DISTINCT CASE WHEN Month_Index = 3 THEN Customer_ID END) AS Month_3,
    COUNT(DISTINCT CASE WHEN Month_Index = 4 THEN Customer_ID END) AS Month_4,
    COUNT(DISTINCT CASE WHEN Month_Index = 5 THEN Customer_ID END) AS Month_5,
    COUNT(DISTINCT CASE WHEN Month_Index = 6 THEN Customer_ID END) AS Month_6,
    COUNT(DISTINCT CASE WHEN Month_Index = 7 THEN Customer_ID END) AS Month_7,
    COUNT(DISTINCT CASE WHEN Month_Index = 8 THEN Customer_ID END) AS Month_8,
    COUNT(DISTINCT CASE WHEN Month_Index = 9 THEN Customer_ID END) AS Month_9,
    COUNT(DISTINCT CASE WHEN Month_Index = 10 THEN Customer_ID END) AS Month_10,
    COUNT(DISTINCT CASE WHEN Month_Index = 11 THEN Customer_ID END) AS Month_11,
    COUNT(DISTINCT CASE WHEN Month_Index = 12 THEN Customer_ID END) AS Month_12
FROM CohortData
WHERE Month_Index BETWEEN 0 AND 12
GROUP BY Cohort_Month
ORDER BY Cohort_Month;



