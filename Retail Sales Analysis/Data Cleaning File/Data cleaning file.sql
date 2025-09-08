
------1.  check which orders are outside the valid date range

SELECT *
FROM Orders
WHERE TRY_CAST(Bill_date_timestamp AS DATETIME) < '2021-09-01'
   OR TRY_CAST(Bill_date_timestamp AS DATETIME) > '2023-10-31';

-----------Now deleting it---------------
DELETE FROM Orders
WHERE TRY_CAST(Bill_date_timestamp AS DATETIME) < '2021-09-01'
   OR TRY_CAST(Bill_date_timestamp AS DATETIME) > '2023-10-31';

-------2.For rows with the same order_id and product_id, want to keep only the row with the highest
---Quantity and remove all other duplicate combinations (lower quantity rows)

SELECT *
FROM (
    SELECT *,
           Row_number() OVER (PARTITION BY order_id, product_id ORDER BY Quantity DESC) AS rnk
    FROM Orders
) AS ranked_orders
-----------Get only the entries where the Row Number = 1

SELECT *
FROM (
    SELECT *,
           Row_number() OVER (
               PARTITION BY order_id, product_id
               ORDER BY Quantity DESC
           ) AS rnk
    FROM Orders
) AS ranked_orders
WHERE rnk = 1;
----------Just previewing which rows would be deleted  
WITH ranked_orders AS (
    SELECT *,
           Row_number() OVER (
               PARTITION BY order_id, product_id
               ORDER BY Quantity DESC
           ) AS rnk
    FROM Orders
)
SELECT *
FROM ranked_orders
WHERE rnk > 1;

-------keep only those entries which had highest number of quantity in orderid+productid

WITH ranked_orders AS (
    SELECT *,
           Row_number() OVER (
               PARTITION BY order_id, product_id
               ORDER BY Quantity DESC
           ) AS rnk
    FROM Orders
)
DELETE FROM ranked_orders
WHERE rnk > 1;

-----Just had a check whether Quantity and remove all other duplicate combinations (lower quantity rows)

SELECT
	order_id,
	product_id,
	COUNT(*) AS Entries_Count
FROM
	Orders
GROUP BY
	order_id,
	product_id
HAVING
	COUNT(*) > 1;

----3.For OrderIDs with multiple CustomerIDs replace the CustomerID of 
---lower TotalAmount with the one of higher TotalAmount

-----------Assigning the Row Number based on TotalAmount-----
SELECT order_id,customer_id,total_amount,
           Row_Number() OVER (
               PARTITION BY order_id
               ORDER BY [Total_Amount] DESC
           ) AS rnk
          FROM Orders

-------------Get entries (Only OrderID and CustomerID) where Row Number = 1

SELECT 
    order_id,
    customer_id,rnk
FROM (
    SELECT 
        order_id,
        customer_id,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY Total_Amount DESC
        ) AS rnk
    FROM Orders
) AS ranked_orders
WHERE rnk = 1;
------------Using cte------------------------------

-- Step 1: Get top customer_id per order_id based on highest total_amount
WITH ranked_orders AS (
    SELECT 
        order_id,
        customer_id,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY total_amount DESC
        ) AS rnk
    FROM Orders
),

-- Step 2: Get the correct mapping (only where rnk = 1)
correct_mapping AS (
    SELECT 
        order_id,
        customer_id AS correct_customer_id
    FROM ranked_orders
    WHERE rnk = 1
)
---select * from correct_mapping
-- Step 3: Join original Orders table to get the correct customer_id mapped
SELECT 
    o.order_id,
    o.customer_id AS original_customer_id,
    cm.correct_customer_id,
    o.total_amount
FROM Orders as o
JOIN correct_mapping as cm
  ON o.order_id = cm.order_id;



---------------------------------------------------------------------------
---Replace customer_id in orders tables  using the correct mapping of customer id 
WITH ranked_orders AS (
    SELECT 
        order_id,
        customer_id,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY total_amount DESC
        ) AS rnk
    FROM Orders
),
correct_mapping AS (
    SELECT 
        order_id,
        customer_id AS correct_customer_id
    FROM ranked_orders
    WHERE rnk = 1
)

-- Now update the cleaned table with the correct customer_id
UPDATE o
SET o.customer_id = cm.correct_customer_id
FROM Orders o
JOIN correct_mapping cm ON o.order_id = cm.order_id;

---select * from orders 
---Checking in updated orders table whether there is a duplicate customer id or not

SELECT
	order_id,
	COUNT(DISTINCT Customer_id) as Distinct_CustIDs_Count
FROM
	orders
GROUP BY
	order_id
HAVING
	COUNT(DISTINCT Customer_id) > 1

----------------------------------------------------------------------------------------------------------------
----4.Dealing wih multiple reviews for same OrderID
---Checking Which OrderIDs Have Multiple Reviews
SELECT
	order_id AS Order_ID,
	AVG(Customer_Satisfaction_Score) AS Customer_Satisfaction_Score
FROM
	OrderReviewRating
GROUP BY
	order_id
-----------Checking the Order Review Rating Table
	SELECT
	order_id,
	COUNT(Customer_Satisfaction_Score)
FROM
	OrderReviewRating
GROUP BY
	order_id
HAVING
	COUNT(Customer_Satisfaction_Score) > 1

-----------Create a Cleaned Table with One Row per order_id
SELECT
	order_id,
	AVG(Customer_Satisfaction_Score) AS Customer_Satisfaction_Score
INTO OrderReviewRating_cleaned
FROM OrderReviewRating
GROUP BY order_id;

--select count( order_id) from OrderReviewRating_cleaned
---select count( order_id) from OrderReviewRating

------------------------------------------------------------------------------------------------
----5.Single OrderID has multiple StoreID so Replacing the oldest StoreID with the latest StoreID (Based on Bill Time Stamp) 
-----creating a window function row number based an bill timestamp.

            SELECT order_id,
			Delivered_StoreID,Bill_date_timestamp,
			ROW_NUMBER() OVER (
				PARTITION BY
					order_id
				ORDER BY
					Bill_date_timestamp DESC
			) AS rn
		FROM
			Orders

--------Get only the latest Delivered_StoreID per order_id
----whose rn = 1
	select order_id,Delivered_StoreID,rn
		FROM
             (
		SELECT order_id,Delivered_StoreID,
			ROW_NUMBER() OVER (
				PARTITION BY
					order_id
				ORDER BY
					Bill_date_timestamp DESC
			) AS rn
		FROM
			Orders) as x
WHERE rn = 1

--  CTE to get latest Delivered_StoreID per order_id
WITH LatestStore AS (
    SELECT 
        order_id,
        Delivered_StoreID AS Latest_StoreID
    FROM (
        SELECT 
            order_id,
            Delivered_StoreID,
            ROW_NUMBER() OVER (
                PARTITION BY order_id
                ORDER BY Bill_date_timestamp DESC
            ) AS rn
        FROM Orders
    ) AS ranked
    WHERE rn = 1
)

--  Update Orders to set Delivered_StoreID to the latest one
UPDATE o
SET o.Delivered_StoreID = ls.Latest_StoreID
FROM Orders as o
JOIN LatestStore ls ON o.order_id = ls.order_id;


--Checking in the Orders Table the duplicate of the store count
SELECT
	order_id,
	COUNT(distinct Delivered_StoreID) as Store_Count
FROM
	Orders
GROUP BY
	order_id
HAVING
	COUNT(distinct Delivered_StoreID) > 1

----6.Deleting the duplicate StoreID


--Checking duplicate storeId
SELECT
	StoreID,
	COUNT(StoreID) AS Store_Count
FROM
	StoreInfo
GROUP BY
	StoreID
HAVING
	COUNT(StoreID) > 1
-----------Identifying Duplicates Using ROW_NUMBER()
	With RankedStore as
	( 
	select *,ROW_NUMBER() over (Partition by storeID order by storeID) as rn
	from storeInfo
	)
	--Delete rows where rn > 1
	Delete RankedStore
	where rn > 1
-----------------------------------------------------------------------------------------
---7.One Order has multiple Bill Timestamps
------just checking order id which had multiple bill timestamp 
SELECT
	Order_ID,
	COUNT(DISTINCT Bill_date_timestamp) as Bill_Count
FROM 
	Orders
GROUP BY
	Order_ID
HAVING
	COUNT(DISTINCT Bill_date_timestamp) > 1

---just updating the Bill_date_timestamp field in all rows to the earliest one	

update o
set o.Bill_date_timestamp = x.earliest_bill from 
Orders as o join (
		select order_id,min(Bill_date_timestamp) as Earliest_bill
		from Orders
		group by order_id) as x
		on o.order_id = x.order_id
-----8.Updating the table info where category was #NA

UPDATE ProductInfo
SET Category = 'Missing'
WHERE Category = '#N/A';



select product_id, Category from ProductInfo
where Category = 'missing'
group by product_id,Category

-----9.cleaning the order payment table 

-----------------------------------------------------------------
----Cleaned Order Payment
----Creating new table of cleaned order payment and then inserting it
CREATE TABLE Cleaned_OrderPayment (
    Order_ID VARCHAR(255),
    Credit_Card_Payment FLOAT,
    Debit_Card_Payment FLOAT,
    UPI_Cash_Payment FLOAT,
    Voucher_Payment FLOAT,
    Total_Payment_Value FLOAT
);

-----Inserting the values
INSERT INTO Cleaned_OrderPayment (
    Order_ID,
    Credit_Card_Payment,
    Debit_Card_Payment,
    UPI_Cash_Payment,
    Voucher_Payment,
    Total_Payment_Value
)
SELECT 
    order_id,
    SUM(CASE WHEN payment_type = 'credit_card' THEN payment_value ELSE 0 END),
    SUM(CASE WHEN payment_type = 'debit_card' THEN payment_value ELSE 0 END),
    SUM(CASE WHEN payment_type = 'upi_cash' THEN payment_value ELSE 0 END),
    SUM(CASE WHEN payment_type = 'voucher' THEN payment_value ELSE 0 END),
    SUM(payment_value)
FROM
    orderPayment
GROUP BY
    order_id;

select * from Cleaned_OrderPayment
-------------------------------------------------------------------------
---Containing number of products per order and the total quantity  
------table created at Orders level 
WITH OrderSummary AS (
	SELECT
		Customer_ID,
		Order_ID,
		COUNT(DISTINCT Product_ID) AS No_of_Products,
		SUM(Quantity) as Total_Quantity,
		Channel,
		Delivered_StoreID,
		Bill_date_timestamp
	FROM Orders
	GROUP BY Order_ID, Customer_ID, Channel, Delivered_StoreID, Bill_date_timestamp
),
----
OrderAmount AS (
	SELECT
		Order_ID,
		SUM(Quantity * Cost_Per_Unit) as Total_Cost_Price,
		SUM(Quantity * MRP) AS Total_MRP,
		SUM(Quantity * Discount) AS Total_Discount,
		---SUM(Quantity * (MRP - Discount_Per_Unit)) AS Total_Amount
		SUM(Total_Amount) AS Total_Amount, 
		CAST((SUM(Quantity * Discount) / SUM(Quantity * MRP)) * 100 AS decimal(5,2)) AS Discount_Percentage
	FROM Orders
	GROUP BY Order_ID
),
---Joining the table order summary and order amount
AmountSummary AS(
	SELECT
		os.*,
		oa.Total_Cost_Price,
		oa.Total_MRP,
		oa.Total_Discount,
		oa.Discount_Percentage,
		oa.Total_Amount
	FROM OrderSummary AS os
	INNER JOIN OrderAmount AS oa ON os.Order_ID = oa.Order_ID
),
----Joining table with amountSummary with orderPayment 
Order_payment as(
	SELECT
		ass.*,
		cop.Credit_Card_Payment,
		cop.Debit_Card_Payment,
		cop.Upi_Cash_Payment,
		cop.Voucher_Payment,
		cop.Total_Payment_Value,
		(cop.Total_Payment_Value - ass.Total_Cost_Price) AS Profit,
		CAST(((cop.Total_Payment_Value - ass.Total_Cost_Price) / cop.Total_Payment_Value) * 100 AS decimal(5,2)) AS Profitpercent
	FROM AmountSummary as ass
	INNER JOIN Cleaned_orderPayment as cop ON ass.Order_ID = cop.Order_ID
	
	)
	SELECT
		opy.Customer_ID,
		opy.Order_ID,
		opy.Delivered_StoreID,
		opy.Channel,
		opy.Bill_date_Timestamp,
		opy.No_of_Products,
		opy.Total_Quantity,
		opy.Total_MRP,
		opy.Total_Discount,
		opy.Discount_Percentage,
		opy.Credit_Card_Payment,
		opy.Debit_Card_Payment,
		opy.UPI_Cash_Payment,
		opy.Voucher_Payment,
		opy.Total_Payment_Value,
		opy.Total_Cost_Price,
		opy.Total_Amount,
		opy.Profit,
		opy.Profitpercent,
		orr.Customer_Satisfaction_Score
	INTO
		Order_360
	FROM
		Order_Payment as opy
	INNER JOIN
		OrderReviewRating_Cleaned as orr
	ON
		opy.Order_ID = orr.Order_ID
	WHERE
		Total_Amount = Total_Payment_Value

select * from Order_360
select * from orders
-----------------------------------------------------------------------------------------

--table created at customer level 

--unique combinations of orders and customers with purchase channel and timestamp.
WITH distinctorders as
		(
		select distinct order_id,customer_id,Channel,Bill_date_timestamp
		from Orders
		),
--- total sales and quantity per order.
OrderRevenue as
		(
			select Customer_id, order_id, sum(total_amount) as TotalSales,
			sum(quantity) as totalQuantity
			from Orders
			group by Customer_id,order_id
		),
----Finds each customer's first and last purchase date.
OrderDates AS (
    SELECT 
        Customer_ID,
        MIN(Bill_date_Timestamp) AS First_Purchase_Date,
        MAX(Bill_date_Timestamp) AS Last_Purchase_Date
    FROM DistinctOrders
    GROUP BY Customer_ID
),
-----Latest Date order 
MaxOrderDate AS (
    SELECT MAX(Bill_date_Timestamp) AS Max_Bill_Date
    FROM Orders
),

---select * from Order_360

OrderPayments_CTE AS (
    SELECT 
        Customer_ID,
        SUM(Total_Cost_Price) AS Total_Cost_Price,
        SUM(Total_MRP) AS Total_MRP,
        SUM(Total_Discount) AS Total_Discount,
        SUM(Total_Amount) AS Total_Amount,
        SUM(Credit_Card_Payment) AS Credit_Card_Payment,
        SUM(Debit_Card_Payment) AS Debit_Card_Payment,
        SUM(Upi_Cash_Payment) AS Upi_Cash_Payment,
        SUM(Voucher_Payment) AS Voucher_Payment,
        SUM(Total_Payment_Value) AS Total_Payment_Value,
        AVG(Customer_Satisfaction_Score) AS Customer_Satisfaction_Score
    FROM Order_360
    GROUP BY Customer_ID
),
CustomerMetrics AS (
	SELECT 
		d.Customer_ID,
		COUNT(CASE WHEN d.Channel = 'Online' THEN 1 END) AS No_of_Online_Orders,
		COUNT(CASE WHEN d.Channel = 'Instore' THEN 1 END) AS No_of_Instore_Orders,
		COUNT(CASE WHEN d.Channel = 'Phone Delivery' THEN 1 END) AS No_of_Phone_Delivery_Orders,
		COUNT(*) AS No_of_Total_Orders,
		CAST(SUM(o.TotalSales) AS decimal(18,2)) AS Total_Revenue,
		CAST(AVG(o.TotalSales) AS decimal(18,2)) AS Avg_Revenue_Per_Order,
		SUM(o.totalQuantity) AS Total_Quantity,
		CAST(SUM(o.totalQuantity) * 1.0 / COUNT(*) AS DECIMAL(10,2)) AS Avg_Quantity_Per_Order,
		od.First_Purchase_Date,
		od.Last_Purchase_Date,

		-- Active/Inactive tag (Inactive if last purchase > 90 days ago)
		CASE 
			WHEN
				DATEDIFF(DAY, od.Last_Purchase_Date, m.Max_Bill_Date) > 90
			THEN
				'Inactive'
			ELSE
				'Active'
		END AS [Status],
		CASE 
            WHEN
				p.Total_Discount > 0
			THEN 'yes'
            ELSE 'no'
        END AS Discount_Benefit,
		CASE 
            WHEN
				p.Voucher_Payment > 0
			THEN 'yes'
            ELSE 'no'
        END AS Voucher_User,
		CASE 
            WHEN
				p.Credit_Card_Payment > 0
			THEN 'yes'
            ELSE 'no'
        END AS Credit_Card_User,
		CASE 
            WHEN
				p.Debit_Card_Payment > 0
			THEN 'yes'
            ELSE 'no'
        END AS Debit_Card_User,
		case 
			when 
				p.upi_cash_payment > 0
			then 'yes'
			else 'no'
			end as Upi_Cash_User,
        p.Total_Cost_Price,
        p.Total_MRP,
		p.Total_Discount,
		CAST((p.Total_Discount * 100.0) / p.Total_MRP AS DECIMAL(5,2)) AS Discount_Percentage,
		p.Total_Amount,
		p.Credit_Card_Payment,
        p.Debit_Card_Payment,
        p.Upi_Cash_Payment,
        p.Voucher_Payment,
        p.Total_Payment_Value,
        p.Customer_Satisfaction_Score
	FROM
		DistinctOrders AS d
	JOIN
		OrderRevenue AS o ON d.Order_ID = o.Order_ID
	JOIN
		OrderDates od ON d.Customer_ID = od.Customer_ID
	JOIN
		OrderPayments_CTE AS p ON d.Customer_ID = p.Customer_ID
	CROSS JOIN
		MaxOrderDate AS m

	GROUP BY 
		d.Customer_ID,
		od.First_Purchase_Date,
		od.Last_Purchase_Date,
		m.Max_Bill_Date,
		p.Total_Cost_Price,
        p.Total_MRP,
		p.Total_Discount,
		p.Total_Amount,
		p.Credit_Card_Payment,
        p.Debit_Card_Payment,
        p.Upi_Cash_Payment,
        p.Voucher_Payment,
        p.Total_Payment_Value,
        p.Customer_Satisfaction_Score
)
	SELECT
		c.*,
		cm.No_of_Online_Orders,
		cm.No_of_Instore_Orders,
		cm.No_of_Phone_Delivery_Orders,
		cm.No_of_Total_Orders,
		cm.Avg_Revenue_Per_Order,
		cm.Total_Quantity,
		cm.Avg_Quantity_Per_Order,
		cm.Total_Cost_Price,
		cm.Total_MRP,
		cm.Total_Discount,
		cm.Discount_Percentage,
		cm.Credit_Card_Payment,
		cm.Debit_Card_Payment,
		cm.Upi_Cash_Payment,
		cm.Voucher_Payment,
		cm.Total_Payment_Value,
		(cm.Total_Payment_Value - cm.Total_Cost_Price) AS Profit,
		CAST(((cm.Total_Payment_Value - cm.Total_Cost_Price) / cm.Total_Payment_Value) * 100 AS decimal(5,2)) AS Profit_Percentage,
		cm.Customer_Satisfaction_Score,
		cm.First_Purchase_Date,
		cm.Last_Purchase_Date,
		cm.discount_benefit,
		cm.Credit_Card_User,
		cm.Debit_Card_User,
		cm.Voucher_User,
		cm.Upi_Cash_User,
		cm.[Status]
	INTO
		Customer_360
	FROM
		Customers AS c
	INNER JOIN
		CustomerMetrics AS cm ON c.Custid = cm.Customer_ID
	WHERE
		cm.Total_Amount = cm.Total_Payment_Value

		

select * from Customer_360


--- select * from cleaned_orderPayment order by total_payment_value asc

--------------------------------------------------------------------------------------------
-----store level table 

-----store level table  
SELECT
	si.StoreID,
	si.seller_city,
	si.seller_state,
	si.Region,
	COUNT(DISTINCT o.Customer_id) AS Total_customers,
	COUNT(DISTINCT o.order_id) AS total_orders,
	SUM(o.No_of_Products) AS total_products,
	SUM(o.total_quantity) AS total_quantity,
	SUM(o.total_mrp) AS total_MRP,
	SUM(o.total_discount) AS total_discount,
	CAST(SUM(o.total_discount)*100.0/SUM(o.total_MRP) AS DECIMAL(5,2)) AS discount_percentage,
	SUM(o.credit_card_payment) AS Total_credit_card_payment,
	SUM(o.Debit_Card_Payment) AS Total_debit_card_payment,
	SUM(o.upi_cash_payment) AS Total_UPI_cash_payment,
	SUM(o.Voucher_payment) AS total_Voucher_payment,
	SUM(o.Total_Payment_Value) AS TotalSales,
	SUM(o.Total_Cost_Price) AS Total_Cost_Price,
	SUM(o.profit) AS total_Profit,
	CAST(SUM(o.profit)*100.0/SUM(o.total_Payment_value) AS DECIMAL(5,2)) AS profit_Percentage,
	CAST(AVG(o.Profitpercent) AS DECIMAL(5,2)) AS avg_ProfitPercent_Per_order,
	CAST(SUM(o.total_mrp) * 1.0 / COUNT(DISTINCT o.Order_ID) AS DECIMAL(10,2)) AS Avg_MRP_Per_Order,
	CAST(SUM(o.Total_discount) * 1.0 / COUNT(DISTINCT o.Order_ID) AS DECIMAL(10,2)) AS Avg_Discount_Per_Order,
	CAST(SUM(o.Total_Payment_Value) * 1.0 / COUNT(DISTINCT o.Order_ID) AS DECIMAL(10,2)) AS Avg_Sales_Per_Order,
	CAST(SUM(o.Total_Cost_Price) * 1.0 / COUNT(DISTINCT o.Order_ID) AS DECIMAL(10,2)) AS Avg_Cost_Price_Per_Order,
	CAST(SUM(o.Profit) * 1.0 / COUNT(DISTINCT o.Order_ID) AS DECIMAL(10,2)) AS Avg_Profit_Per_Order,
	CAST(AVG(o.Customer_Satisfaction_Score) AS DECIMAL(5,2)) AS Avg_Satisfaction_Score
INTO 
	store360
FROM 
	storeInfo AS si 
JOIN 
	Order_360 AS o ON o.Delivered_StoreID = si.StoreID
GROUP BY
	si.StoreID,
	si.Seller_City,
	si.Seller_State,
	si.Region

select * from store360

--------------------------------------------------------------------------------------



SELECT
    p.Product_ID,
    p.Category,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COUNT(DISTINCT o.Customer_ID) AS Unique_Customers,
    SUM(o.Quantity) AS Total_Quantity_Sold,
    CAST(AVG(o.Cost_Per_Unit) AS decimal(18,2)) AS Cost_Price_Per_Unit,
    CAST(AVG(o.MRP) AS decimal(18,2)) AS MRP_Per_Unit,
    CAST(AVG(o.Discount) AS decimal(18,2)) AS Discount_Per_Unit,
	CAST((SUM(o.Total_Amount) / SUM(o.Quantity)) AS decimal(18,2)) AS Selling_Price_Per_Unit,
	CAST((SUM(o.Total_Amount) - SUM(o.Cost_Per_Unit * o.Quantity)) / SUM(o.Quantity) AS decimal(18,2)) AS Profit_Per_Unit,
    SUM(o.Cost_Per_Unit * o.Quantity) AS Total_Cost_Price,
	CAST(SUM(o.MRP * o.Quantity) AS decimal(18,2)) AS Total_MRP,
	CAST(SUM(o.Discount * o.Quantity) AS decimal(18,2)) AS Total_Discount,
    SUM(o.Total_Amount) AS Total_Revenue,
    SUM(o.Total_Amount) - SUM(o.Cost_Per_Unit * o.Quantity) AS Total_Profit,
    CAST(((SUM(o.Total_Amount) - SUM(o.Cost_Per_Unit * o.Quantity)) / SUM(o.Total_Amount) * 100) AS decimal(18,2)) AS Profit_Percentage,
    CAST(AVG(r.Customer_Satisfaction_Score) AS decimal(3,2)) AS Customer_Satisfaction_Score

INTO
	Product_360
FROM
    ProductInfo AS p
LEFT JOIN
    Orders AS o
ON
	p.Product_ID = o.Product_ID
LEFT JOIN
    OrderReviewRating_Cleaned AS r
ON
	o.Order_ID = r.Order_ID
GROUP BY
    p.Product_ID,
    p.Category;


	select * from Orders
	select * from ProductInfo
	select * from Product_360


select * from orders 
select * from Cleaned_OrderPayment


SELECT *
FROM Order_360 o
JOIN Cleaned_OrderPayment p
    ON o.Order_ID = p.Order_ID
WHERE o.Total_Amount = 0
  AND p.Total_Payment_Value = 0;
-----------------------------------------------------------------------------------


  
---------------------------------------------------------------------

SELECT o.*
INTO Orders_Cleaned
FROM Orders as o
INNER JOIN Order_360 od ON o.Order_ID = od.Order_ID;



SELECT c.*
INTO customers_Cleaned
FROM customers as c
INNER JOIN customer_360 as CI ON c.custId = ci.custId;


select * from product_360
select * from productinfo