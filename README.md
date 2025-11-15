# AdventureWorks Business performance Analytics

## Project Overview

This SQL script performs a comprehensive analytics workflow across sales, product performance, and customer behavior using the AdventureWorks sample data warehouse. It integrates data from both Internet and Reseller sales, calculates key business metrics, and produces monthly sales trends with running totals and moving averages. The script segments products based on net sales and profit margins and implements a full RFM (Recency, Frequency, Monetary) model to classify customers into purchasing behavior segments such as Champions, Loyal Customers, and At-Risk. The final output provides actionable insights to support data-driven decisions in revenue management, product profitability, and customer lifecycle optimization.

*Key Objectives:*

- Track sales performance trends over time across multiple channels
- Identify high-performing products and optimization opportunities
- Segment customers for targeted marketing and retention strategies
- Enable data-driven decision-making through clear, quantifiable metrics

-----

## SQL Scripts & Analysis Coverage

### 1. Sales Analysis 


*Key Metrics:*

- Total Orders per month
- Total Quantity sold
- Net Sales and Profit
- Profit Margin percentage
- Running totals for cumulative performance
- 3-month moving averages for trend smoothing

```sql
--Combined internet and Reseller Sales Fact tables CTE
WITH CombinedSales AS (
    SELECT 
        FORMAT(OrderDate,'yyyy-MM') AS OrderDate,
        OrderQuantity,
        SalesOrderNumber,
        SalesAmount - TaxAmt AS NetSales,
        SalesAmount - ProductStandardCost AS Profit
    FROM FactInternetSales
    WHERE OrderDate IS NOT NULL
    UNION ALL
    SELECT 
        FORMAT(OrderDate,'yyyy-MM') AS OrderDate,
        OrderQuantity,
        SalesOrderNumber,
        SalesAmount - TaxAmt AS NetSales,
        SalesAmount - ProductStandardCost AS Profit
    FROM FactResellerSales
    WHERE OrderDate IS NOT NULL
),
--Sales calculation CTE
SalesCalc AS (
    SELECT
        OrderDate,
        COUNT(DISTINCT SalesOrderNumber) AS TotalOrders,
        SUM(OrderQuantity) AS TotalQuantity,
        ROUND(SUM(NetSales), 2) AS NetSales,
        ROUND(SUM(Profit), 2) AS Profit,
        ROUND(SUM(Profit) / NULLIF(SUM(NetSales), 0) * 100, 2) AS ProfitMargin_pct
    FROM CombinedSales
    GROUP BY OrderDate
)
--  Final output with running totals and moving averages
SELECT
    OrderDate,
    TotalOrders,
    TotalQuantity,
    NetSales,
    Profit,
    ProfitMargin_pct,
    -- Running totals and moving averages for Net Sales and Profit
    SUM(NetSales) OVER (ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal_NetSales,
    SUM(Profit) OVER (ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal_Profit,
    ROUND(AVG(NetSales) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS MovingAvg_NetSales,
    ROUND(AVG(Profit) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS MovingAvg_Profit
FROM SalesCalc
ORDER BY OrderDate;
```

-----

### 2. Product Performance Report


*Key Metrics:*

- Total Orders and Quantity per product
- Net Sales, Total Cost, and Profit
- Profit Margin percentages
- Product segmentation into four quadrants according to average sales and profit margins

```sql
--Combined internet and Reseller Sales Fact tables CTE
WITH CombinedSales AS (
    SELECT
        ProductKey,
        SalesOrderNumber,
        OrderQuantity,
        SalesAmount,
        TaxAmt,
        ProductStandardCost
    FROM FactInternetSales
    UNION ALL
    SELECT
        ProductKey,
        SalesOrderNumber,
        OrderQuantity,
        SalesAmount,
        TaxAmt,
        ProductStandardCost
    FROM FactResellerSales
),
-- Product calculations CTE
Product_Calc AS (
    SELECT
        ProductKey,
        COUNT(DISTINCT SalesOrderNumber) AS TotalOrders,
        SUM(OrderQuantity) AS Total_Quantity,
        ROUND(SUM(SalesAmount - TaxAmt),2) AS NetSales,
        ROUND(SUM(ProductStandardCost),2) AS TotalCost,
        ROUND(SUM(SalesAmount - TaxAmt) - SUM(ProductStandardCost),2) AS Profit,
        (SUM(SalesAmount - TaxAmt) - SUM(ProductStandardCost)) 
            / NULLIF(SUM(SalesAmount - TaxAmt), 0) * 100 AS ProfitMargin_pct
    FROM CombinedSales
    GROUP BY ProductKey
),
-- Averages CTE for segmentation thresholds
Averages AS (
    SELECT 
        AVG(NetSales) AS AvgSales,
        AVG(ProfitMargin_pct) AS AvgProfitMargin
    FROM Product_Calc
)
-- Final output with product details and segmentation
SELECT 
    p.ProductKey,
    d.EnglishProductName AS ProductName,
    COALESCE(s.EnglishProductSubcategoryName, 'Others') AS Subcategory,
    COALESCE(c.EnglishProductCategoryName, 'Others') AS Category,
    p.TotalOrders,
    p.Total_Quantity,
    p.NetSales,
    p.TotalCost,
    p.Profit, 
    p.ProfitMargin_pct,
    CASE
        WHEN p.NetSales >= a.AvgSales AND p.ProfitMargin_pct >= a.AvgProfitMargin THEN 'High Sales - High Margin'
        WHEN p.NetSales >= a.AvgSales AND p.ProfitMargin_pct < a.AvgProfitMargin THEN 'High Sales - Low Margin'
        WHEN p.NetSales < a.AvgSales AND p.ProfitMargin_pct >= a.AvgProfitMargin THEN 'Low Sales - High Margin'
        ELSE 'Low Sales - Low Margin'
    END AS ProductSegment   
FROM Product_Calc p
CROSS JOIN Averages a  
LEFT JOIN DimProduct d ON p.ProductKey = d.ProductKey
LEFT JOIN DimProductSubcategory s ON d.ProductSubcategoryKey = s.ProductSubcategoryKey
LEFT JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
ORDER BY p.NetSales DESC;
```

-----

### 3. RFM Customer Segmentation Report


*Key Metrics:*

- *Recency:* Days since last purchase
- *Frequency:* Number of orders placed
- *Monetary:* Total spending amount
- RFM Scores (1-5 scale for each dimension)
- Total products purchased and quantities
- Order lifespan (months between first and last purchase)
- Average Order Value and Monthly Spending

```sql
-- RFM calculations CTE
WITH RFM_Calc AS ( 
	SELECT 
		CustomerKey,
		COUNT(DISTINCT ProductKey) AS TotalProductsPurchased,
		SUM(OrderQuantity) AS TotalQuantity,
		CAST(MAX(OrderDate) AS DATE) AS RecentPurchaseDate,
		DATEDIFF(DAY, CAST(MAX(OrderDate) AS DATE), GETDATE()) AS Recency_Days,
		COUNT(DISTINCT SalesOrderNumber) AS Frequency,
		SUM(SalesAmount) AS Monetary
	FROM FactInternetSales
	WHERE OrderDate IS NOT NULL 
	GROUP BY CustomerKey 
),
-- RFM Scoring CTE
RFM_Scores AS (
    SELECT
        CustomerKey,
		TotalProductsPurchased,
		TotalQuantity,
		RecentPurchaseDate,
        Recency_Days,
        Frequency,
        Monetary,
        NTILE(5) OVER (ORDER BY Recency_Days ASC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM RFM_Calc
),
-- combine customer location  details with RFM scores
Customer_Details AS ( 
	SELECT 
		r.CustomerKey,
		CONCAT(d.FirstName, ' ', d.LastName) AS CustomerName,
		d.BirthDate,
		DATEDIFF(YEAR, d.BirthDate, GETDATE()) AS Age,
		g.City,
		g.StateProvinceName AS Province,
		g.EnglishCountryRegionName AS Country,
		r.TotalProductsPurchased,
		r.TotalQuantity,
		d.DateFirstPurchase AS FirstPurchaseDate,
		r.RecentPurchaseDate,
		DATEDIFF(MONTH, d.DateFirstPurchase, r.RecentPurchaseDate) AS OrderLifespan_Month,
		r.Monetary / r.Frequency AS AverageOrderValue,
		r.Recency_Days,
		r.Frequency,
		r.Monetary,
		r.R_Score,
        r.F_Score, 
        r.M_Score,
		r.R_Score + r.F_Score + r.M_Score AS RFM_Score
	FROM RFM_Scores r
	LEFT JOIN DimCustomer d ON r.CustomerKey = d.CustomerKey
	LEFT JOIN DimGeography g ON d.GeographyKey = g.GeographyKey
)
-- Final output with age group and RFM segmentation
SELECT 
	CustomerKey,
	CustomerName,
	BirthDate,
	Age,		
	CASE 
		WHEN Age <= 20 THEN '1-20'
		WHEN Age BETWEEN 21 AND 40 THEN '21-40'
		WHEN Age BETWEEN 41 AND 60 THEN '41-60'
		WHEN Age BETWEEN 61 AND 80 THEN '60-80'
		ELSE 'Above 80'
	END AS Age_Group,
	City,
	Province,
	Country,
	TotalProductsPurchased,
	TotalQuantity,
	FirstPurchaseDate,
	RecentPurchaseDate,
	OrderLifespan_Month,
	AverageOrderValue,
	CASE 
		WHEN OrderLifespan_Month = 0 THEN Monetary
		ELSE Monetary / OrderLifespan_Month
	END AS AverageMonthlySpending,
	Recency_Days,
	Frequency,
	Monetary,
	CASE
		WHEN RFM_Score >= 13 THEN 'Champion'
		WHEN RFM_Score BETWEEN 10 AND 12 THEN 'Loyal Customer'
		WHEN RFM_Score BETWEEN 7 AND 9 THEN 'Potential Loyalist'
		WHEN RFM_Score BETWEEN 4 AND 6 THEN 'At Risk'
		ELSE 'Lost'
	END AS CustomerSegment
FROM Customer_Details;
```
-----

## Contact Information

- **Email**: ziad.mohamed17.1@gmail.com
- **LinkedIn**: [Ziad Soliman](https://linkedin.com/in/ziadsoliman)


## Resources
- [AdventureWorksDW2019 Database](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms)