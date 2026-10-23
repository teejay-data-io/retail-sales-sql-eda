# 🛒 Retail Sales: Exploratory Data Analysis (SQL)

**Exploring 1,000,000 retail sales transactions with SQL to answer core business questions on revenue, products, customers, stores, seasonality and marketing.**

I loaded a star-schema retail dataset into MySQL, then wrote queries to profile the data, calculate KPIs and answer business questions. This is the SQL side of my retail sales analysis; the same data is visualised in my Power BI dashboard.

📂 Part of my portfolio: [github.com/teejay-data-io](https://github.com/teejay-data-io)

📈 **Companion Power BI dashboard:** [retail-sales-powerbi-dashboard](https://github.com/teejay-data-io/retail-sales-powerbi-dashboard) · 📄 **Full script:** [`retail_sales_analysis.sql`](retail_sales_analysis.sql)

![Overall sales KPIs](images/04_overall_kpis.png)

---

## 🧰 Tools used

- **MySQL 8.0** and **MySQL Workbench**
- `LOAD DATA LOCAL INFILE` for the bulk load
- Aggregations (`COUNT`, `SUM`, `AVG`, `STDDEV`), `GROUP BY` and `ORDER BY`
- `CASE` expressions, subqueries, derived tables and `CROSS JOIN` for percentage shares
- Self-join with `PERIOD_DIFF` for month-over-month growth
- `JOIN`s between the fact and dimension tables; date functions (`DATE_FORMAT`, `HOUR`, `MONTH`)

---

## 💡 Key findings

1. **Scale:** 1,000,000 orders from 99,996 customers produced 2,750,874,594.76 in revenue, an average order value of 2,750.87.
2. **Big tickets drive revenue:** orders of 3,000 and above are 444,562 transactions but about 65% of revenue.
3. **Strong second half:** monthly revenue rises from 42.07M in January to 422.89M in October, and Q3 is the best quarter at 940.06M.
4. **Sports & Outdoors leads, narrowly:** it is the top category (461.7M) and holds the top four products, led by Yoga Mat (52.36M).
5. **Supermarkets sell the most:** 952.0M in revenue, in line with having the most stores (173).
6. **Campaign return depends on budget, not sales:** the top 10 campaigns all brought in about 55M each, so the cheapest ones show the best return (288.95 per budget dollar for New Arrival Showcase vs 58.14 for Countdown to Savings).

![Monthly revenue](images/19_monthly_revenue.png)

📄 **Full write-up** with every query result (22 screenshots), notes on the data and how to run the script: [PROJECT_WRITEUP.md](PROJECT_WRITEUP.md)

---

## 📁 Files

| File | What it is |
|---|---|
| `retail_sales_analysis.sql` | The full MySQL script |
| `images/` | Query result screenshots |
| `PROJECT_WRITEUP.md` | Full project write-up |

**Data:** [Retail Store Star Schema Dataset](https://www.kaggle.com/datasets/shrinivasv/retail-store-star-schema-dataset) on Kaggle. The dimension CSV files are stored in the [Power BI repository](https://github.com/teejay-data-io/retail-sales-powerbi-dashboard); the 1,000,000-row sales fact table is not included because of its size.

---

## 👤 Author

**Tajudeen Olugbenga Rabiu** | Data Analyst · Power BI · SQL · Python · Excel

- 💼 LinkedIn: [linkedin.com/in/tajudeen-rabiu-data](https://www.linkedin.com/in/tajudeen-rabiu-data)
- 📧 Email: [tjrabiu.data@gmail.com](mailto:tjrabiu.data@gmail.com)
- 🌐 Portfolio site: [teejay-data-io.github.io](https://teejay-data-io.github.io/)

📂 Part of my portfolio: [github.com/teejay-data-io](https://github.com/teejay-data-io)
