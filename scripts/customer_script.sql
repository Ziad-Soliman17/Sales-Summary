-- RFM CUSTOMER SEGMENTATION REPORT
/*
to classify customers into behavioral segments.
Purpose: Consolidate key customer metrics and segment customers according to democraphics and behavior.
Highlights:
	1. Calculate core purchase metrics for each customer.
	2. Derive demographic and geographic details.
	3. Segment customers based on aged group and RFM scores.
*/

USE  AdventureWorksDW2019
GO

-- Calculate Recency, Frequency, and Monetary values per customer
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

-- Assign R, F, and M scores using NTILE (1–5 scale)
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

-- Add customer demographics and compute extra metrics
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

-- Final report with segmentations
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
