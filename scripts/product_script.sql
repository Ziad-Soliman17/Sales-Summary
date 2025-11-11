
-- PRODUCT PERFORMANCE REPORT
/* 
Purpose: Consolidate key product metrics from both Internet and Reseller sales.
Highlights:
    1. Gather essential product details (name, category, subcategory, cost).
    2. Segment products by revenue and margin to classify performance:
        - High Sales / High Margin
        - High Sales / Low Margin
        - Low Sales / High Margin
        - Low Sales / Low Margin
    3. Aggregate product-level metrics:
        - Total Orders
        - Total Quantity Sold
        - Net Sales
        - Profit and Profit Margin
*/

USE AdventureWorksDW2019
GO

-- Combine Internet and Reseller sales into a unified dataset
WITH CombinedSales AS (
    SELECT
        ProductKey,
        SalesOrderNumber,
        OrderQuantity,
        ProductStandardCost,
        SalesAmount - TaxAmt AS NetSales,
        SalesAmount - ProductStandardCost AS Profit
    FROM FactInternetSales
    UNION ALL
    SELECT
        ProductKey,
        SalesOrderNumber,
        OrderQuantity,
        ProductStandardCost,
        SalesAmount - TaxAmt AS NetSales,
        SalesAmount - ProductStandardCost AS Profit
    FROM FactResellerSales
),

-- Calculate core product-level metrics
Product_Calc AS (
    SELECT
        ProductKey,
        COUNT(DISTINCT SalesOrderNumber) AS TotalOrders,
        SUM(OrderQuantity) AS Total_Quantity,
        ROUND(SUM(ProductStandardCost),2) AS TotalCost,
        ROUND(SUM(NetSales),2) AS NetSales,
        ROUND(SUM(Profit),2) AS Profit,
        SUM(Profit) / NULLIF(SUM(NetSales), 0) * 100 AS ProfitMargin_pct
    FROM CombinedSales
    GROUP BY ProductKey
),

-- calculate averages for performance segmentation
Averages AS (
    SELECT 
        AVG(NetSales) AS AvgSales,
        AVG(ProfitMargin_pct) AS AvgProfitMargin
    FROM Product_Calc
)

-- Final report with product attributes and performance segmentation
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