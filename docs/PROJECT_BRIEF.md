# Soko Fresh Mart — Data Management & EDA Capstone Project

**Tooling:** PostgreSQL only (psql / pgAdmin)
**Dataset size:** ~25,200 rows across 5 tables

---

## 1. Business Context

**Soko Fresh Mart** is a 12-branch supermarket chain operating across Nairobi, Mombasa, Kisumu, Nakuru, Eldoret, Thika, and Machakos. The leadership team has flagged three concerns going into the next strategic planning cycle:

1. **Inconsistent branch performance** — some stores appear to be underperforming, but nobody has quantified it.
2. **Uncertain customer retention** — the loyalty program (Bronze/Silver/Gold/Platinum) was launched years ago, but it's unclear whether it's actually driving repeat purchases.
3. **Data trust issues** — the analytics team suspects the customer and transaction data has quality problems (duplicates, missing fields, invalid entries) that are quietly distorting every report built on top of it.

**Your mandate as the data engineer:** Before anyone can trust a dashboard or a KPI from this data, it needs to be cleaned, validated, and understood. You will use PostgreSQL to diagnose data quality, build trustworthy metrics, and surface the insights leadership needs to act on retention and branch performance.

The following skills are required: **Data Management (cleaning/validation/extraction in SQL)** and **Exploratory Analysis (reading and creating visual/statistical summaries)**.

---

## 2. Data Dictionary & Schema

Five normalized tables (3NF), intentionally seeded with realistic data quality problems.

| Table | Row Count (approx.) | Description |
|---|---|---|
| `stores` | 12 | Branch metadata: location, region, size, open date |
| `products` | 44 | Product catalog across 10 categories |
| `customers` | 2,240 | Customer records — **contains dirty data** |
| `orders` | 5,015 | Order headers — **contains integrity issues** |
| `order_items` | 17,877 | Line items per order — **contains entry errors** |

**Relationships:** `orders.customer_id → customers.customer_id` · `order_items.order_id → orders.order_id` · `order_items.product_id → products.product_id` · `orders.store_id → stores.store_id` (**not enforced as a real FK — see below**)



## 3. Setup Instructions (Local PostgreSQL)

```bash
# 1. Create the database
createdb soko_fresh_mart

# 2. Build the schema
psql -d soko_fresh_mart -f sql/01_schema.sql

# 3. Load the data (run FROM inside the sql/ folder so relative paths resolve)
cd sql
psql -d soko_fresh_mart -f 02_load_data.sql
```

If `\copy` gives a path error, either `cd` into the `sql/` folder first (as shown above), or edit the paths in `02_load_data.sql` to absolute paths on your machine.

---

## 4. Questions To Answer

Organized to mirror the exam's three sections. Work through them roughly in order — later questions build on earlier cleaning work.

### Section A — Data Management: Extraction, Joins & Aggregation (Exam-style: 50%)

1. List all stores along with the number of orders each has received, sorted highest to lowest.
2. What are the top 10 best-selling products by total quantity sold?
3. What is the total revenue (`quantity × unit_price_at_sale × (1 - discount_pct/100)`) per store?
4. Which product category generates the most revenue overall?
5. For each customer, find their total number of orders and total amount spent — return only customers with more than 5 orders.
6. Using a `LEFT JOIN`, find any orders whose `store_id` does not exist in the `stores` table.
7. Find all customers who have never placed an order (customers with zero matching rows in `orders`).
8. Which payment method is most common, and does that vary by region?
9. Write a query using a `CASE WHEN` to bucket customers into spend tiers (e.g., "Low," "Medium," "High" total spend).
10. Find the average order value (AOV) per store, per month, for 2025.

### Section B — Data Management: Window Functions (Exam-style)

11. Rank customers within each membership tier by total amount spent, using `RANK()`.
12. For each store, use `ROW_NUMBER()` to find each store's single best-selling product.
13. Calculate a running (cumulative) total of daily revenue for the whole chain across 2025.
14. Using `LAG()`, calculate the change in a store's monthly revenue compared to the previous month.
15. Identify each customer's **first** and **most recent** order date using window functions, and calculate the number of days between them (customer "lifespan").

### Section C — Data Management: Cleaning & Validation (Exam-style)

16. Standardize the `city` column: trim whitespace and normalize casing so `"Nairobi"`, `"nairobi"`, `"NAIROBI"`, and `"Nairobi "` are all treated as one value. (Write the SELECT that shows this — a view or CTE, not a permanent overwrite.)
17. Identify likely duplicate customers using name and email matching logic (case-insensitive, trimmed).
18. Find every order with a `store_id` that does not exist in `stores` — quantify how much revenue this affects.
19. Find any orders whose `order_date` is earlier than their store's `opened_date`.
20. Find all `order_items` rows with zero or negative `quantity` — decide and justify whether these should be excluded from revenue calculations.
21. Detect exact duplicate rows in `order_items` (same `order_id`, `product_id`, `quantity`, `unit_price_at_sale`) using `ROW_NUMBER() OVER (PARTITION BY ...)`.
22. Use `COALESCE` to produce a customer contact list where missing emails fall back to phone number, and missing phone falls back to `'Not on file'`.
23. Find products whose `unit_price` looks like an outlier relative to others in the same category (IQR method).
24. Write one consolidated **data quality report query** (or a small set of queries) that leadership could run monthly to see: % missing emails, % missing phones, count of orphaned store_ids, count of invalid quantities, count of likely duplicate customers.

### Section D — Exploratory Data Analysis (Exam-style: 33%)

25. Produce the query that would feed a **histogram** of order values (bucket total order value into ranges, e.g., 0-500, 500-1000, 1000-2000, 2000+, and count orders in each bucket).
26. Produce the query that would feed a **bar chart** comparing total revenue by store.
27. Produce the query that would feed a **line chart** of monthly revenue trend for the whole chain, Jan 2023–June 2026.
28. Calculate mean, median (using `PERCENTILE_CONT`), and standard deviation of order value. Is the distribution likely skewed? Justify from the numbers alone.
29. Produce a query that would feed a **box plot** of order value by membership tier (min, Q1, median, Q3, max per tier).
30. Investigate the correlation between a store's `store_size_sqm` and its average monthly revenue — is there a relationship? (Compute revenue per store, then reason about the pattern; bonus if you compute Pearson's r manually via `CORR()`.)
31. Segment customers by recency of last order (e.g., ordered in last 30/90/180+ days) — this is the foundation of a churn-risk view for leadership.
32. Based on everything above, write a **half-page summary** (in your own words, as if presenting to Soko Fresh Mart's leadership) covering: which stores need attention, whether the loyalty tiers actually correlate with spend, and what data quality issues must be fixed before these numbers can be trusted company-wide.

---

## 5. Metrics To Judge Your Own Work

Use this rubric to self-assess once you've attempted all 32 questions. Be honest — this is diagnostic, not decorative.

| Category | What "Excellent" Looks Like | Self-Score (1–5) |
|---|---|---|
| **Correctness** | Query results are accurate; joins don't fan-out row counts incorrectly; aggregations match manual spot-checks | |
| **Query efficiency** | Uses appropriate joins (not unnecessary subqueries); filters early (WHERE before aggregating); uses indexes-friendly predicates | |
| **NULL handling** | Correctly distinguishes `NULL` from `0`/empty string; uses `COALESCE`/`IS NULL` appropriately rather than `= NULL` | |
| **Data quality reasoning** | Doesn't just find dirty data — explains *why* it's a problem and what the business impact is (e.g., "$X revenue is tied to a store that doesn't exist") | |
| **Window function fluency** | Can write `PARTITION BY` + `ORDER BY` combinations from memory, understands ranking vs. running-total logic | |
| **EDA translation** | Can go from a raw query result to "what chart would show this and why" without hesitation | |
| **Communication (Q32)** | The leadership summary is written in plain business language, not SQL jargon — a non-technical exec could act on it | |

**Scoring guide:**
- **28–32 (5s across the board):** You're translating business questions into SQL fluently.
- **20–27:** Solid foundation — revisit whichever category scored lowest.
- **Below 20:** Go back to the books and come back stronger.

---

Push your final `.sql` answer file to your github alongside your other portfolio projects once done — this one demonstrates data cleaning judgment, which most portfolio projects skip entirely.
