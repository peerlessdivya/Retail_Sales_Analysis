# 🛒 Retail Sales Analysis

## 📌 Project Overview
This project is a **Retail Case Study** for a leading retail chain in India.  
The goal was to analyze **Point-of-Sale (POS) data** to uncover customer behavior, product performance, store trends, and sales patterns.  

Using **SQL (SSMS)**, **Power BI**, and **PowerPoint**, the project delivers:
- Data cleaning and preparation
- Exploratory Data Analysis (EDA)
- Interactive dashboards
- Strategic business recommendations

---

## 🛠️ Technology Stack
- **SQL Server Management Studio (SSMS)** → Data cleaning, transformation, and querying  
- **Power BI** → Dashboard creation and KPI visualization  
- **Excel / CSV** → Initial data storage and preprocessing  
- **PowerPoint** → Final presentation of insights & recommendations  

---

## 🔍 Problem Statement
The client had large volumes of POS data but lacked **data-driven visibility** into:
- Customer behavior and retention
- Product/category performance
- Store- and region-level sales
- Channel optimization (online, phone, in-store)
- Seasonal demand patterns  

The objective was to build a **data-driven strategy** that improves sales, customer loyalty, and overall profitability.

---

## 🔧 Data Cleaning & Preparation (SQL)
Key steps included:
- Removing invalid billing dates, duplicates, and inconsistent store IDs  
- Standardizing multiple customer IDs per order  
- Resolving missing product categories (#N/A → "Missing")  
- Cleaning payment tables (pivoting multiple payment methods into single row per order)  
- Creating a unified dataset for analysis  

---

## 📊 Exploratory Data Analysis (EDA)
**Key Metrics Identified:**
- Total Customers: **92,935**
- Orders: **93,022**
- Total Revenue: **₹14.7M**
- Total Profit: **₹2.1M**
- Average Order Value (AOV): **₹158**
- Average Profit per Order: **₹22.1**
- Avg. Customer Satisfaction Score: **3.92 / 5**
- Stores Analyzed: **37 across 4 regions**

---

## 📈 Business Insights
### Customer Analysis
- Majority of customers are **female (70%)**  
- ~40% of customers used **discounts** → effective for retention  
- Most customers are **one-time buyers (<10% repeat rate)**  
- Certain cities (e.g., *Maghar, Jawar*) show higher **average orders per customer**

### Order & Channel Insights
- **Online channel dominates (~88%)**, followed by in-store and phone  
- Most orders are **small baskets (1–2 items)**  
- Discounts above 10% **don’t increase revenue significantly**  

### Product & Store Insights
- **Top categories:** Home Appliances, Baby Products, Toys & Gifts  
- **Underperforming categories:** Construction Tools, Computers  
- Regional disparity → **West region generates ~68% of orders**  

### Customer Retention (Cohort Analysis)
- Retention rate is **<10%** across cohorts  
- Majority of customers are **one-time buyers**  
- Best performing cohorts: **Mar–Jun 2022** (~9% retention)  
- Delayed repeat behavior (3–6 months gap before re-purchase)  

---

## 📷 Dashboard Preview
(Add screenshots in `/images/` and update links below)

![Dashboard Overview](https://app.powerbi.com/groups/me/reports/b4499f89-c417-4f67-bb20-7819fc517590/bd697bc135a107d7e84b?experience=power-bi)  
  

---

## 🚀 Recommendations
1. **Improve Retention Rate**  
   - Launch loyalty programs, personalized offers, and re-engagement campaigns.  
2. **Optimize Discounts**  
   - Keep discounts in the **0–10% range** for maximum profitability.  
3. **Enhance Customer Experience**  
   - Raise satisfaction scores (currently 3.9/5) via service quality improvements.  
4. **Boost Underperforming Regions**  
   - Focus on East & North India with regional campaigns.  
5. **Leverage High-Profit Categories**  
   - Upsell/cross-sell in Home Appliances, Baby, and Toys & Gifts.  
6. **Automate Retention Campaigns**  
   - Follow-up with new customers within 1–3 months to reduce churn.  

---

## 📁 Project Structure
Retail_Sales_Analysis/
│-- data/ # Sample CSV dataset
│-- sql_queries/ # SQL scripts (data cleaning, EDA ,Order360 ,customer360 ,storeinfo360)
│-- dashboard/ # Power BI .pbix file
│-- presentation/ # Final insights deck (PDF)
│-- images/ # Dashboard screenshots
│-- README.md # Project documentation

---

## 👩‍💻 Author
**Divya Gupta**  
📌 Data Analyst | SQL | Power BI | Data Visualization  
🔗 [LinkedIn](https://www.linkedin.com/in/divya-gupta-20bb16299/) |
