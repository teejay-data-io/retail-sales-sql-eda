/* =====================================================================
   Project : Retail Sales: Exploratory Data Analysis (SQL)
   Author  : Tajudeen Gbenga Rabiu
   Tool    : MySQL 8.0 (MySQL Workbench)
   Data    : 1,000,000 retail sales transactions in a star schema
             Fact table : fact_saless_denorm (loaded from fact_saless_denormalized.csv)
             Dimensions : dim_customers, dim_products, dim_stores,
                          dim_salespersons, dim_campaigns
   Note    : The dimension tables were imported into the Retail database
             separately from their CSV files.
             Update the LOAD DATA file path before running.
   ===================================================================== */

-- To create a new database
CREATE DATABASE Retail;

USE Retail;  -- to specify the db to use, which contains our tables

-- to create a new table in our existing database - Retail
CREATE TABLE fact_saless_denorm (
	sales_sk INT,
	sales_id TEXT,
	customer_sk INT,
	product_sk	INT,
	store_sk INT,	
	salesperson_sk	INT,
	campaign_sk	INT,
	sales_date	DATETIME,
	total_amount DOUBLE,
	customer_segment TEXT,
	category TEXT,
	store_type TEXT
);

-- to insert data into the newly created table
SET GLOBAL LOCAL_INFILE=ON;

-- NOTE: replace the path below with the location of fact_saless_denormalized.csv on your machine
LOAD DATA LOCAL INFILE 'path/to/fact_saless_denormalized.csv' INTO TABLE fact_saless_denorm
FIELDS TERMINATED BY ' '
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- to fetch all columns and rows from the stores table for analysis and validation
SELECT *
FROM dim_stores;

-- to fetch all columns and rows from the customers table for analysis and validation
SELECT *
FROM dim_customers;

-- to calculate summary statistics and revenue metrics for sales transactions
SELECT
COUNT(*) AS n,
MIN(total_amount) AS min_amount,
MAX(total_amount) AS max_amount,
ROUND(AVG(total_amount),2) AS mean_amount,
ROUND(STDDEV(total_amount),2) AS stddev_amount,
ROUND(SUM(total_amount), 2) AS total_revenue
FROM fact_saless_denorm;

-- to calculate overall sales KPIs including orders, customers, revenue and average order value
SELECT
COUNT(*) AS total_orders,
COUNT(DISTINCT customer_sk) AS unique_customers,
ROUND(SUM(total_amount), 2) AS total_revenue,
ROUND(AVG(total_amount), 2) AS avg_order_value
FROM fact_saless_denorm;

-- to analyze sales performance by product category
SELECT 
category,
COUNT(*) AS orders,
ROUND(SUM(total_amount), 2) AS revenue,
ROUND(AVG(total_amount), 2) AS avg_order_value
FROM fact_saless_denorm
GROUP BY category
ORDER BY revenue DESC;

-- to count the number of products in each category and rank categories by product count
SELECT category, COUNT(*) AS n_products
FROM dim_products
GROUP BY category
ORDER BY n_products DESC;

-- to analyze customer shopping behavior across hourly time periods
SELECT
HOUR(sales_date) AS hour_of_day,
COUNT(*) AS total_orders,
ROUND(SUM(total_amount), 2) AS total_revenue,
ROUND(AVG(total_amount), 2) AS avg_order_value
FROM fact_saless_denorm
GROUP BY HOUR(sales_date)
ORDER BY hour_of_day;

-- to determine how many customers are one-time versus repeat buyers
SELECT
orders_per_customer,
COUNT(*) AS n_customers
FROM (
SELECT
customer_sk,
COUNT(*) AS orders_per_customer
FROM fact_saless_denorm
GROUP BY customer_sk
) customer_orders
GROUP BY orders_per_customer
ORDER BY orders_per_customer;

-- to identify each customer's favorite product category based on highest spending
SELECT
customer_sk,
category,
ROUND(category_spend, 2) AS favorite_category_spend
FROM (
SELECT
customer_sk,
category,
SUM(total_amount) AS category_spend
FROM fact_saless_denorm
GROUP BY customer_sk, category
) t
WHERE (customer_sk, category_spend) IN (
SELECT
customer_sk,
MAX(category_spend)
FROM (
SELECT
customer_sk,
category,
SUM(total_amount) AS category_spend
FROM fact_saless_denorm
GROUP BY customer_sk, category
) x
GROUP BY customer_sk
)
ORDER BY customer_sk;

-- to analyze revenue and average order value by customer segment
SELECT
customer_segment,
COUNT(*) AS n_transactions,
ROUND(SUM(total_amount), 2) AS revenue,
ROUND(AVG(total_amount), 2) AS avg_order_value
FROM fact_saless_denorm
GROUP BY customer_segment
ORDER BY revenue DESC;

-- to analyze transaction count and revenue by sales amount range
SELECT
CASE
WHEN total_amount < 100 THEN '01: <100'
WHEN total_amount < 500 THEN '02: 100-499'
WHEN total_amount < 1000 THEN '03: 500-999'
WHEN total_amount < 2000 THEN '04: 1000-1999'
WHEN total_amount < 3000 THEN '05: 2000-2999'
ELSE '06: 3000+'
END AS amount_bucket,
COUNT(*) AS n_transactions,
ROUND(SUM(total_amount),2) AS bucket_revenue
FROM fact_saless_denorm
GROUP BY amount_bucket
ORDER BY amount_bucket;

-- to count unique categories, brands, customer segments, and locations across dimensions
SELECT
(SELECT COUNT(DISTINCT category) FROM dim_products) AS n_categories,
(SELECT COUNT(DISTINCT brand) FROM dim_products) AS n_brands,
(SELECT COUNT(DISTINCT customer_segment) FROM dim_customers) AS n_segments,
(SELECT COUNT(DISTINCT store_type) FROM dim_stores) AS n_store_types,
(SELECT COUNT(DISTINCT store_location) FROM dim_stores) AS n_store_locations,
(SELECT COUNT(DISTINCT residential_location) FROM dim_customers) AS n_customer_locations;

-- to count products by category and rank categories by product count
SELECT category, COUNT(*) AS n_products
FROM dim_products
GROUP BY category
ORDER BY n_products DESC;

-- to count customers by segment and calculate each segment's share of total customers
SELECT
s.customer_segment,
s.n_customers,
ROUND(100.0 * s.n_customers / t.total_customers, 2) AS pct_of_customers
FROM (
SELECT
customer_segment,
COUNT(*) AS n_customers
FROM dim_customers
GROUP BY customer_segment
) s
CROSS JOIN (
SELECT COUNT(*) AS total_customers
FROM dim_customers
) t
ORDER BY s.n_customers DESC;

-- to count stores by type and rank store types by store count
SELECT
 store_type, COUNT(*) AS n_stores
 FROM dim_stores 
 GROUP BY store_type
 ORDER BY n_stores DESC;

-- to show the top 15 store locations ranked by number of stores
SELECT 
store_location, COUNT(*) AS n_stores 
FROM dim_stores 
GROUP BY store_location 
ORDER BY n_stores DESC LIMIT 15;

-- to count salespeople by role
SELECT 
	salesperson_role, COUNT(*) AS n_people 
FROM dim_salespersons 
GROUP BY salesperson_role;

-- to analyze monthly transaction volume, revenue, and average ticket size
SELECT
DATE_FORMAT(sales_date, '%Y-%m') AS sales_month,
COUNT(*) AS n_transactions,
ROUND(SUM(total_amount),2) AS monthly_revenue,
ROUND(AVG(total_amount),2) AS avg_ticket_size
FROM fact_saless_denorm
GROUP BY sales_month
ORDER BY sales_month;

-- to analyze monthly revenue trends and MoM growth rates
SELECT
a.sales_month,
ROUND(a.revenue, 2) AS revenue,
ROUND(b.revenue, 2) AS prev_month_revenue,
ROUND(
((a.revenue - b.revenue) / b.revenue) * 100,
2
) AS mom_growth_pct
FROM
(
SELECT
DATE_FORMAT(sales_date, '%Y-%m') AS sales_month,
SUM(total_amount) AS revenue
FROM fact_saless_denorm
GROUP BY DATE_FORMAT(sales_date, '%Y-%m')
) a
LEFT JOIN
(
SELECT
DATE_FORMAT(sales_date, '%Y-%m') AS sales_month,
SUM(total_amount) AS revenue
FROM fact_saless_denorm
GROUP BY DATE_FORMAT(sales_date, '%Y-%m')
) b
ON PERIOD_DIFF(
REPLACE(a.sales_month, '-', ''),
REPLACE(b.sales_month, '-', '')
) = 1
ORDER BY a.sales_month;

-- to analyze transaction volume and revenue by quarter
SELECT
CASE
WHEN MONTH(sales_date) BETWEEN 1 AND 3 THEN 'Q1'
WHEN MONTH(sales_date) BETWEEN 4 AND 6 THEN 'Q2'
WHEN MONTH(sales_date) BETWEEN 7 AND 9 THEN 'Q3'
ELSE 'Q4'
END AS quarter,
COUNT(*) AS n_transactions,
ROUND(SUM(total_amount), 2) AS revenue
FROM fact_saless_denorm
GROUP BY quarter
ORDER BY quarter;

-- to analyze transaction volume, revenue, and average ticket size by product category
SELECT 
category, COUNT(*) AS n_transactions, ROUND(SUM(total_amount),2) AS revenue,
ROUND(AVG(total_amount),2) AS avg_ticket
FROM fact_saless_denorm
GROUP BY category
ORDER BY revenue DESC;

-- to analyze sales performance by store type
SELECT store_type, COUNT(*) AS n_transactions, ROUND(SUM(total_amount),2) AS revenue
FROM fact_saless_denorm
GROUP BY store_type
ORDER BY revenue DESC;

-- to analyze category revenue by customer segment
SELECT
category,
ROUND(SUM(CASE WHEN customer_segment = 'High Value' THEN total_amount END),2) AS high_value_rev,
ROUND(SUM(CASE WHEN customer_segment = 'Loyal Customer' THEN total_amount END),2) AS loyal_rev,
ROUND(SUM(CASE WHEN customer_segment = 'Occasional Shopper' THEN total_amount END),2) AS occasional_rev,
ROUND(SUM(CASE WHEN customer_segment = 'Churn Risk' THEN total_amount END),2) AS churn_risk_rev
FROM fact_saless_denorm
GROUP BY category;

-- to analyze sales performance with and without marketing campaigns
SELECT
CASE WHEN campaign_sk IS NULL THEN 'No Campaign' ELSE 'With Campaign' END AS campaign_flag,
COUNT(*) AS n_transactions, ROUND(SUM(total_amount),2) AS revenue, ROUND(AVG(total_amount),2) AS avg_ticket
FROM fact_saless_denorm
GROUP BY campaign_flag;

-- to analyze sales performance by brand
SELECT p.brand, COUNT(*) AS n_transactions, ROUND(SUM(f.total_amount),2) AS revenue
FROM fact_saless_denorm f JOIN dim_products p ON f.product_sk = p.product_sk
GROUP BY p.brand
ORDER BY revenue DESC
LIMIT 15;

-- to identify the highest-revenue products across categories
SELECT p.product_name, p.category, COUNT(*) AS n_sold, ROUND(SUM(f.total_amount),2) AS revenue
FROM fact_saless_denorm f JOIN dim_products p ON f.product_sk = p.product_sk
GROUP BY p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-- to evaluate campaign revenue and marketing spend efficiency
SELECT cp.campaign_name, cp.campaign_budget,
COUNT(f.sales_sk) AS n_sales, ROUND(SUM(f.total_amount),2) AS revenue,
ROUND(SUM(f.total_amount) / NULLIF(cp.campaign_budget,0), 2) AS revenue_per_budget_dollar
FROM dim_campaigns cp
LEFT JOIN fact_saless_denorm f ON f.campaign_sk = cp.campaign_sk
GROUP BY cp.campaign_name, cp.campaign_budget
ORDER BY revenue DESC;

