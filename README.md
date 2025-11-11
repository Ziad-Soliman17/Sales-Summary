# AdventureWorks Intelligence Suite

## Project Overview

The AdventureWorks Intelligence Suite is a comprehensive SQL-based analytics solution designed to extract actionable business insights from the AdventureWorksDW2019 database. This project combines three critical analysis dimensions—sales trends, product performance, and customer behavior—to provide a complete view of business operations and opportunities.

*Key Objectives:*

- Track sales performance trends over time across multiple channels
- Identify high-performing products and optimization opportunities
- Segment customers for targeted marketing and retention strategies
- Enable data-driven decision-making through clear, quantifiable metrics

*Technology Stack:*

- Database: SQL Server (AdventureWorksDW2019)
- Query Language: T-SQL
- Analysis Methods: Time-series analysis, RFM segmentation, product categorization

-----

## SQL Scripts & Analysis Coverage

### 1. Sales Analysis - Temporal Trends

*File:* sales_analysis.sql

*What It Covers:*

- Combines Internet and Reseller sales channels into unified metrics
- Monthly aggregation of orders, quantities, and financial performance
- Net sales calculation (excluding tax) and profit computation
- Profit margin percentages tracked over time

*Key Metrics:*

- Total Orders per month
- Total Quantity sold
- Net Sales and Profit
- Profit Margin percentage
- Running totals for cumulative performance
- 3-month moving averages for trend smoothing

*Insights Delivered:*

- Seasonal sales patterns and cyclical trends
- Revenue growth trajectory and momentum
- Profitability trends independent of volume
- Early warning signals through moving averages
- Overall business health indicators

-----

### 2. Product Performance Report

*File:* product_performance.sql

*What It Covers:*

- Unified view of product sales across all channels
- Product categorization with category and subcategory hierarchy
- Cost, revenue, and profitability calculations per product
- Performance-based product segmentation using average benchmarks

*Key Metrics:*

- Total Orders and Quantity per product
- Net Sales, Total Cost, and Profit
- Profit Margin percentages
- Product segmentation into four quadrants

*Product Segments:*

- *High Sales - High Margin:* Star products driving revenue and profit
- *High Sales - Low Margin:* Volume leaders needing pricing/cost optimization
- *Low Sales - High Margin:* Niche opportunities for promotion
- *Low Sales - Low Margin:* Candidates for discontinuation or repositioning

*Insights Delivered:*

- Which products to prioritize in marketing campaigns
- Inventory optimization opportunities
- Pricing strategy guidance
- Product portfolio rationalization recommendations
- Cross-selling and upselling opportunities

-----

### 3. RFM Customer Segmentation Report

*File:* customer_segmentation.sql

*What It Covers:*

- Customer purchase behavior analysis using RFM methodology
- Demographic profiling (age, location)
- Customer lifetime value indicators
- Behavioral segmentation for targeted engagement

*Key Metrics:*

- *Recency:* Days since last purchase
- *Frequency:* Number of orders placed
- *Monetary:* Total spending amount
- RFM Scores (1-5 scale for each dimension)
- Total products purchased and quantities
- Order lifespan (months between first and last purchase)
- Average Order Value and Monthly Spending

*Customer Segments:*

- *Champion (RFM 13-15):* Best customers—high value, recent, frequent
- *Loyal Customer (RFM 10-12):* Reliable revenue generators
- *Potential Loyalist (RFM 7-9):* Growing customers worth nurturing
- *At Risk (RFM 4-6):* Declining engagement—retention needed
- *Lost (RFM 3 or below):* Inactive customers—reactivation campaigns

*Additional Dimensions:*

- Age group segmentation (1-20, 21-40, 41-60, 61-80, 80+)
- Geographic analysis (City, Province, Country)
- Purchase pattern analysis

*Insights Delivered:*

- Which customers to prioritize for retention
- Optimal timing for re-engagement campaigns
- Customer lifetime value predictions
- Geographic expansion opportunities
- Age-based product recommendation strategies
- Churn risk identification and prevention

-----

## Business Impact

This analytics suite enables stakeholders to:

1. *Optimize Marketing Spend:* Target the right customers with the right products at the right time
1. *Improve Inventory Management:* Stock decisions based on profitability, not just sales volume
1. *Enhance Customer Retention:* Identify at-risk customers before they churn
1. *Drive Strategic Planning:* Data-backed decisions on product development and market expansion
1. *Increase Profitability:* Focus resources on high-margin products and high-value customers

-----

## Getting Started

1. Ensure access to AdventureWorksDW2019 database
1. Execute scripts in SQL Server Management Studio or Azure Data Studio
1. Scripts can be run independently in any order
1. Results can be exported to Excel, Power BI, or Tableau for visualization

-----

## Contact Information

*Project Author:* [Your Name]  
*Email:* [your.email@example.com]  
*LinkedIn:* [linkedin.com/in/yourprofile]  
*GitHub:* [github.com/yourusername]

For questions, suggestions, or collaboration opportunities, please reach out via email or LinkedIn.

## Resources
- [AdventureWorksDW2019 Database](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms)