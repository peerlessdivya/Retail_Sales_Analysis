
---1. Total Number of Stores
SELECT COUNT(DISTINCT StoreID) AS total_stores
FROM store360

---2. Total order per store 

SELECT StoreID, total_orders
FROM store360
ORDER BY total_orders DESC;

---3.Revenue per store

SELECT StoreID, total_MRP AS revenue
FROM store360
ORDER BY revenue DESC;


---4.Total profit per store

SELECT StoreID, total_Profit
FROM store360
ORDER BY total_Profit DESC;

---5. total quantity per store 

SELECT StoreID, total_quantity
FROM store360
ORDER BY total_quantity DESC;




---7.Average Sales per Order and average profit per order 

SELECT StoreID, Avg_Sales_Per_Order, Avg_Profit_Per_Order
FROM store360
ORDER BY Avg_Sales_Per_Order DESC;

---8.Region wise total orders

SELECT Region, SUM(total_orders) AS region_orders
FROM store360
GROUP BY Region;

---9.State wise store count

SELECT seller_state, COUNT(StoreID) AS store_count
FROM store360
GROUP BY seller_state
ORDER BY store_count DESC;

---10.Average Discount per region 

SELECT Region, AVG(Avg_Discount_Per_Order) AS avg_region_discount
FROM store360
GROUP BY Region;


---11.Region wise average satisfaction score 

SELECT Region, 
       AVG(Avg_Satisfaction_Score) AS avg_score
FROM store360
GROUP BY Region;

---12. Efficiency Score (Profit per Order / Discount)(how well a store converts discounting into profit.)

SELECT StoreID,
       (Avg_Profit_Per_Order / NULLIF(Avg_Discount_Per_Order, 0)) AS efficiency_score
FROM store360
ORDER BY efficiency_score DESC;

---13. Avg Discount vs Profit %

SELECT StoreID, 
       Avg_Discount_Per_Order, 
       profit_Percentage
FROM store360;

----14.Revenue vs Cost by Store

SELECT StoreID,
       total_MRP AS total_revenue,
       Total_Cost_Price AS total_cost,
       (total_MRP - Total_Cost_Price) AS gross_margin
FROM store360;

---15.High Satisfaction Score Stores

SELECT StoreID, Avg_Satisfaction_Score
FROM store360
WHERE Avg_Satisfaction_Score >= 4
