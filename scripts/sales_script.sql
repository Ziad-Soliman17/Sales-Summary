--Sales Analysis--

USE AdventureWorksDW2019
GO


-- Change over time for FactinternetSales and FactResellerSales--
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
SELECT
    OrderDate,
    TotalOrders,
    TotalQuantity,
    NetSales,
    Profit,
    ProfitMargin_pct,

    -- Running Totals
    SUM(NetSales) OVER (ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal_NetSales,
    SUM(Profit) OVER (ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal_Profit,

    -- 3-Month Moving Averages
    ROUND(AVG(NetSales) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS MovingAvg_NetSales,
    ROUND(AVG(Profit) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS MovingAvg_Profit

FROM SalesCalc
ORDER BY OrderDate;


