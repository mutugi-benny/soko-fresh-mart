-- Below are the answers from the project_brief.md file for the Soko Fresh Mart project. The answers are provided in SQL format.

-- =================================================================================================

-- Section A — Data Management: Extraction, Joins & Aggregation

-- ================================================================================================
-- 1. List all stores along with the number of orders each has received, sorted highest to lowest.
SELECT store_name, COUNT(order_id) AS numb_of_orders
FROM stores AS st
INNER JOIN orders AS ord
ON st.store_id = ord.store_id
GROUP BY store_name
ORDER BY numb_of_orders DESC;

-- =============================================================
-- 2. What are the top 10 best-selling products by total quantity sold?
SELECT product_name, SUM(quantity) AS total_quantity
FROM products AS prod
LEFT JOIN order_items AS it
ON prod.product_id = it.product_id
GROUP BY product_name
ORDER BY total_quantity DESC
LIMIT 10;

-- ===========================================================
-- 3. What is the total revenue (`quantity × unit_price_at_sale × (1 - discount_pct/100)`) per store?
SELECT store_name, ROUND(SUM(quantity*unit_price_at_sale*(1- discount_pct/100)),2) AS total_revenue_per_store
FROM stores AS st
INNER JOIN orders AS ord
ON st.store_id = ord.store_id
INNER JOIN order_items AS it
ON it.order_id = ord.order_id
GROUP BY store_name;

-- ==========================================================
-- 4. Which product category generates the most revenue overall?
SELECT category, ROUND(SUM(quantity*unit_price_at_sale*(1- discount_pct/100)),2) AS total_revenue_per_category
FROM products AS prod
INNER JOIN order_items AS it
ON prod.product_id = it.product_id
GROUP BY category
ORDER BY total_revenue_per_category DESC
LIMIT 1;

-- =========================================================
-- 5. For each customer, find their total number of orders and total amount spent — return only customers with more than 5 orders.
SELECT full_name,
	   COUNT(DISTINCT ord.order_id) AS numb_of_orders,
	   ROUND(SUM(quantity*unit_price_at_sale*(1-discount_pct/100)),2) AS total_amount_spent
FROM customers AS cust
INNER JOIN orders AS ord
	ON cust.customer_id = ord.customer_id
INNER JOIN order_items AS it
	ON it.order_id = ord.order_id
GROUP BY cust.customer_id, cust.full_name
HAVING COUNT(DISTINCT ord.order_id)>5
ORDER BY numb_of_orders DESC;

-- =========================================================
-- 6. Using a `LEFT JOIN`, find any orders whose `store_id` does not exist in the `stores` table.
SELECT ord.order_id,
	   ord.store_id
FROM orders AS ord
LEFT JOIN stores AS st
ON ord.store_id = st.store_id
WHERE st.store_id IS NULL

-- ========================================================
-- 7.  Find all customers who have never placed an order (customers with zero matching rows in `orders`).
SELECT cust.customer_id, cust.full_name
FROM customers AS cust
LEFT JOIN orders AS ord
ON cust.customer_id = ord.customer_id
WHERE ord.order_id IS NULL;

-- Alternative query using NOT EXISTS
SELECT cust.customer_id, cust.full_name
FROM customers AS cust
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS ord
    WHERE ord.customer_id = cust.customer_id
);

-- ========================================================
-- 8. Which payment method is most common, and does that vary by region?
SELECT st.region, ord.payment_method, COUNT(ord.order_id) AS total_orders
FROM orders AS ord
INNER JOIN stores AS st
ON st.store_id = ord.store_id
GROUP BY st.region, ord.payment_method
ORDER BY st.region ASC, total_orders DESC;

-- Alternate query using a CTE and window functions
WITH ranked_payments AS (
    SELECT st.region,
           ord.payment_method,
           COUNT(ord.order_id) AS total_orders,
           RANK() OVER (PARTITION BY st.region ORDER BY COUNT(ord.order_id) DESC) AS payment_rank
    FROM orders AS ord
    INNER JOIN stores AS st
        ON st.store_id = ord.store_id
    GROUP BY st.region, ord.payment_method
)
SELECT region, 
       payment_method, 
       total_orders
FROM ranked_payments
WHERE payment_rank = 1
ORDER BY total_orders DESC;


-- ========================================================
-- 9. Write a query using a `CASE WHEN` to bucket customers into spend tiers (e.g., "Low," "Medium," "High" total spend).
WITH customer_expenditure AS (
SELECT full_name,
	   COUNT(DISTINCT ord.order_id) AS numb_of_orders,
	   ROUND(SUM(quantity*unit_price_at_sale*(1-discount_pct/100)),2) AS total_amount_spent
FROM customers AS cust
INNER JOIN orders AS ord
	ON cust.customer_id = ord.customer_id
INNER JOIN order_items AS it
	ON it.order_id = ord.order_id
GROUP BY cust.customer_id, cust.full_name
)
SELECT full_name, numb_of_orders, total_amount_spent,
	CASE WHEN total_amount_spent < 5000.00 THEN 'Low'
	WHEN total_amount_spent <= 20000.00 THEN 'Medium'
	ELSE 'High' END AS spend_tier
FROM customer_expenditure;

-- ========================================================
-- 10. Find the average order value (AOV) per store, per month, for 2025.
SELECT ord.store_id,
	  EXTRACT(MONTH from ord.order_date) AS order_month,
	  ROUND(
	  SUM(it.quantity*it.unit_price_at_sale*(1-discount_pct/100)):: NUMERIC
	  / COUNT(DISTINCT ord.order_id),2) AS average_order_value
FROM orders AS ord
INNER JOIN order_items AS it
ON it.order_id = ord.order_id
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY ord.store_id, EXTRACT(MONTH from ord.order_date)
ORDER BY ord.store_id, order_month ASC;

-- ========================================================================================

-- Section B — Data Management: Window Functions

-- ========================================================================================
-- 11. Rank customers within each membership tier by total amount spent, using `RANK()`
WITH customer_expenditure AS (
SELECT full_name,
	   COUNT(DISTINCT ord.order_id) AS numb_of_orders,
	   ROUND(SUM(quantity*unit_price_at_sale*(1-discount_pct/100.0)),2) AS total_amount_spent
FROM customers AS cust
INNER JOIN orders AS ord
	ON cust.customer_id = ord.customer_id
INNER JOIN order_items AS it
	ON it.order_id = ord.order_id
GROUP BY cust.customer_id, cust.full_name
),
cust_spending AS (SELECT full_name, numb_of_orders, total_amount_spent,
	CASE 
		WHEN total_amount_spent < 5000.00 THEN 'Low'
		WHEN total_amount_spent <= 20000.00 THEN 'Medium'
		ELSE 'High' 
	END AS spend_tier
FROM customer_expenditure)
SELECT full_name, 
	   numb_of_orders, 
	   total_amount_spent, 
	   spend_tier,
	   RANK() OVER ( PARTITION BY spend_tier ORDER BY total_amount_spent DESC) AS spend_tier_rank
FROM cust_spending
ORDER BY spend_tier ASC, spend_tier_rank ASC;


-- =========================================================
-- 12. For each store, use `ROW_NUMBER()` to find each store's single best-selling product.
WITH store_product_sales AS (
SELECT st.store_id,
	   store_name,
	   product_name,
	  ROUND(SUM(it.quantity*it.unit_price_at_sale*(1-discount_pct/100.0)),2):: NUMERIC AS product_sales
FROM stores AS st
INNER JOIN orders AS ord
ON st.store_id = ord.store_id
INNER JOIN order_items AS it
ON it.order_id = ord.order_id
INNER JOIN products AS prod
ON prod.product_id = it.product_id
GROUP BY st.store_id,
		 st.store_name,
		 prod.product_id,
		 product_name
),
ranked_sales AS (
SELECT store_id,
	   store_name,
	   product_name,
	   product_sales,
	   ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY product_sales DESC) AS sales_rank
FROM store_product_sales
)
SELECT store_id,
	   store_name,
	   product_name,
	   product_sales
FROM ranked_sales
WHERE sales_rank = 1;

-- ========================================================================================	
-- 13. Calculate a running (cumulative) total of daily revenue for the whole chain across 2025.
WITH date_and_revenue AS (
SELECT ord.order_date:: DATE AS order_day,
	   ROUND(SUM(it.quantity*it.unit_price_at_sale*(1-discount_pct/100.0)),2)::NUMERIC AS daily_revenue
FROM orders AS ord
INNER JOIN order_items AS it
ON ord.order_id = it.order_id
WHERE ord.order_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY ord.order_date::DATE
)
SELECT order_day,
	   daily_revenue,
	   SUM(daily_revenue)
	   OVER(ORDER BY order_day ASC) AS running_total
FROM date_and_revenue
ORDER BY order_day ASC;

-- ============================================================================================
--14. Using `LAG()`, calculate the change in a store's monthly revenue compared to the previous month.
WITH store_revenue AS (
SELECT st.store_id,
	   store_name,
	   TO_CHAR(ord.order_date, 'YYYY-MM') AS order_month,
	   ROUND(SUM(it.quantity*it.unit_price_at_sale*(1-discount_pct/100.0))::NUMERIC,2) AS monthly_revenue
FROM orders AS ord
INNER JOIN order_items AS it
	ON ord.order_id = it.order_id
INNER JOIN stores AS st
	ON st.store_id = ord.store_id
GROUP BY st.store_id,
	     st.store_name,
	     TO_CHAR(ord.order_date, 'YYYY-MM')
)
SELECT store_id,
	   store_name,
	   order_month,
	   monthly_revenue,
	   LAG(monthly_revenue,1)
	   OVER(PARTITION BY store_id ORDER BY order_month ASC) AS last_month_revenue,
	   monthly_revenue - LAG(monthly_revenue,1) OVER(PARTITION BY store_id ORDER BY order_month ASC) AS month_over_month_change
FROM store_revenue
ORDER BY 
		 store_id ASC, 
	     order_month ASC;

-- ============ Alternative query that enforces a strict "month" gap check

WITH store_revenue AS (
    SELECT 
        st.store_id,
        st.store_name,
        -- INSTEAD OF TO_CHAR: We use DATE_TRUNC to keep it as a real, mathematical date
        -- e.g., '2025-01-15' becomes '2025-01-01'
        DATE_TRUNC('month', ord.order_date)::DATE AS order_month, 
        ROUND(SUM(it.quantity * it.unit_price_at_sale * (1 - it.discount_pct / 100.0))::numeric, 2) AS monthly_revenue
    FROM orders AS ord
    INNER JOIN order_items AS it
        ON ord.order_id = it.order_id
    INNER JOIN stores AS st
        ON st.store_id = ord.store_id
    GROUP BY 
        st.store_id,
        st.store_name,
        DATE_TRUNC('month', ord.order_date)::DATE
),
lagged_data AS (
    SELECT 
        store_id,
        store_name,
        order_month,
        monthly_revenue,
        -- We grab both the previous month's REVENUE and the previous month's DATE
        LAG(order_month, 1) OVER(PARTITION BY store_id ORDER BY order_month ASC) AS previous_row_date,
        LAG(monthly_revenue, 1) OVER(PARTITION BY store_id ORDER BY order_month ASC) AS previous_row_revenue
    FROM store_revenue
)
SELECT 
    store_id,
    store_name,
    TO_CHAR(order_month, 'YYYY-MM') AS order_month, -- Convert back to nice text for the final report
    monthly_revenue,
    
    -- THE GAP CHECK: Is the current month exactly 1 month after the previous row?
    CASE 
        WHEN order_month - INTERVAL '1 month' = previous_row_date THEN previous_row_revenue
        ELSE NULL 
    END AS strict_last_month_revenue,
    
    CASE 
        WHEN order_month - INTERVAL '1 month' = previous_row_date THEN monthly_revenue - previous_row_revenue
        ELSE NULL 
    END AS month_over_month_change

FROM lagged_data
ORDER BY 
    store_id ASC, 
    order_month ASC;

-- ===================================================================================================	
-- 15. Identify each customer's **first** and **most recent** order date using window functions, and calculate the number of days between them (customer "lifespan")
WITH customer_dates AS (
SELECT DISTINCT cust.customer_id,
	   cust.full_name,
       -- Find the absolute first (earliest) date for each specific customer
	   MIN(ord.order_date::DATE) OVER(PARTITION BY cust.customer_id) AS first_order_date,
	   -- Find the absolute last (most recent) date for each specific customer
	   MAX(ord.order_date::DATE) OVER(PARTITION BY cust.customer_id) AS most_recent_order_date
FROM customers AS cust
INNER JOIN orders AS ord
ON cust.customer_id = ord.customer_id
)
SELECT customer_id,
	   full_name,
	   first_order_date,
	   most_recent_order_date,
	   (most_recent_order_date - first_order_date) AS customer_lifespan
FROM customer_dates
ORDER BY customer_lifespan DESC;

-- ======================================================================================================	

-- Section C — Data Management: Cleaning & Validation

-- =======================================================================================================
-- 16. Standardize the `city` column: trim whitespace and normalize casing so `"Nairobi"`, `"nairobi"`, 
-- `"NAIROBI"`, and `"Nairobi "` are all treated as one value. (Write the SELECT that shows this — a view or CTE, not a permanent overwrite.)
CREATE OR REPLACE VIEW standard_customer_city AS
	     SELECT customer_id,
		 	    full_name,
				INITCAP(TRIM(city)) AS city_name
FROM customers;

SELECT *
FROM standard_customer_city;

-- =======================================================================================================
-- 17. Identify likely duplicate customers using name and email matching logic (case-insensitive, trimmed).
SELECT 
	   INITCAP(TRIM(full_name)) AS clean_name,
	   LOWER(TRIM(email)) AS clean_email,
	   -- Count number of times the name/ email combination appears
	    COUNT(customer_id) AS duplicate_count,
		STRING_AGG(customer_id::TEXT, ',') AS duplicate_customer_ids
FROM customers
GROUP BY 
		INITCAP(TRIM(full_name)),
		LOWER(TRIM(email))
-- Only returns groups that have more than 1 customer ID in them
HAVING COUNT(customer_id) > 1;

-- Alternative query to list the actual duplicate customer rows
WITH flagged_customers AS (
    SELECT 
        customer_id,
        full_name,
        email,
        -- Apply the this cleaning logic to ensure accurate matching
        INITCAP(TRIM(full_name)) AS clean_name,
        LOWER(TRIM(email)) AS clean_email,
        
        -- This counts occurrences of the name/email combo and attaches that total to every individual row
        COUNT(*) OVER (
            PARTITION BY INITCAP(TRIM(full_name)), LOWER(TRIM(email))
        ) AS duplicate_count
    FROM customers
)
SELECT 
    customer_id,
    full_name,
    email,
    clean_name,
    clean_email
FROM flagged_customers
-- Only pull the rows that belong to a duplicate group
WHERE duplicate_count > 1
-- Order them so the duplicates sit right next to each other in the results
ORDER BY 
    clean_name ASC, 
    clean_email ASC, 
    customer_id ASC;

-- =======================================================================================================
-- 18. Find every order with a `store_id` that does not exist in `stores` — quantify how much revenue this affects.
SELECT 
	  ord.order_id,
	  ord.store_id AS invalid_store_id,
	  ord.order_date,
	  ROUND(SUM(it.quantity*it.unit_price_at_sale*(1-discount_pct/100.0))::NUMERIC, 2) AS affected_revenue
FROM orders AS ord
INNER JOIN order_items AS it
	ON ord.order_id = it.order_id
WHERE NOT EXISTS (
	SELECT 1
	FROM stores AS st
	WHERE ord.store_id = st.store_id
)
GROUP BY 
	    ord.order_id,
		ord.store_id,
		order_date
ORDER BY 
	    affected_revenue DESC;

-- =======================================================================================================
-- 19. Find any orders whose `order_date` is earlier than their store's `opened_date`.
SELECT 
    ord.order_id,
    ord.store_id,
    st.store_name,
    ord.order_date,
    st.opened_date,
    -- Bonus: Show exactly how many days early the order was placed
    (st.opened_date - ord.order_date::DATE) AS days_before_opening
FROM orders AS ord
INNER JOIN stores AS st 
    ON ord.store_id = st.store_id
-- THE FILTER: Only keep orders placed before the store's official open date
WHERE ord.order_date < st.opened_date
ORDER BY days_before_opening DESC;

-- =======================================================================================================
-- 20. Find all `order_items` rows with zero or negative `quantity` — decide and justify whether these should be excluded from revenue calculations.
SELECT 
	  it.order_item_id,
	  it.order_id,
	  prod.product_name,
	  it.quantity,
	  ROUND((quantity * unit_price_at_sale * (1 - discount_pct / 100.0))::numeric, 2) AS revenue_impact,
	  CASE WHEN it.quantity = 0 THEN 'Incude'
	  	   WHEN it.quantity < 0 THEN 'Exclude'
		   	END AS revenue_calc_viability
FROM order_items AS it
INNER JOIN products AS prod
ON it.product_id = prod.product_id
WHERE it.quantity <= 0;

-- =======================================================================================================
-- 21. Detect exact duplicate rows in `order_items` (same `order_id`, `product_id`, `quantity`, `unit_price_at_sale`) using `ROW_NUMBER() OVER (PARTITION BY ...)`
WITH tagged_items AS (
    SELECT 
		order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price_at_sale,
        discount_pct,
        -- Assign a sequential number to rows that have the exact same data combination
        ROW_NUMBER() OVER (
            PARTITION BY order_id, product_id, quantity, unit_price_at_sale 
            ORDER BY order_id
        ) AS row_num,
        -- Calculate the total number of duplicates for this specific combination
        COUNT(*) OVER (
            PARTITION BY order_id, product_id, quantity, unit_price_at_sale
        ) AS duplicate_count
    FROM order_items
)
SELECT 
	order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price_at_sale,
    discount_pct,
    row_num,
    duplicate_count
FROM tagged_items
-- Filter to show ALL rows (originals and copies) that belong to a duplicate set
WHERE duplicate_count > 1
ORDER BY 
    order_id ASC, 
    product_id ASC,
    row_num ASC;

-- ===========================================================================================	
-- 22. Use `COALESCE` to produce a customer contact list where missing emails fall back to phone number, and missing phone falls back to `'Not on file'`
SELECT 
    customer_id,
    full_name,
    email,
    phone,
    -- COALESCE checks email first. If email is NULL, it checks phone. 
    -- If both are NULL, it defaults to 'Not on file'.
    COALESCE(email, phone, 'Not on file') AS primary_contact
FROM customers
ORDER BY customer_id ASC;

-- ===========================================================================================
-- 23. Find products whose `unit_price` looks like an outlier relative to others in the same category (IQR method).
WITH category_percentiles AS (
    -- STEP 1: Calculate the 25th (Q1) and 75th (Q3) percentiles for each category
    SELECT 
        category,
        -- PERCENTILE_CONT interpolates the exact mathematical percentile value
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY unit_price) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY unit_price) AS q3
    FROM products
    GROUP BY category
),
iqr_bounds AS (
    -- STEP 2: Calculate the IQR and define the upper and lower limits
    SELECT 
        category,
        q1,
        q3,
        (q3 - q1) AS iqr,
        (q1 - 1.5 * (q3 - q1)) AS lower_bound,
        (q3 + 1.5 * (q3 - q1)) AS upper_bound
    FROM category_percentiles
)
-- STEP 3: Join back to the products table and filter for the outliers
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    b.lower_bound,
    b.upper_bound
FROM products AS p
INNER JOIN iqr_bounds AS b 
    ON p.category = b.category
-- THE FILTER: Keep only products that fall outside the normal bounds
WHERE p.unit_price < b.lower_bound 
   OR p.unit_price > b.upper_bound
ORDER BY 
    p.category ASC, 
    p.unit_price DESC;

-- ===========================================================================================

-- =================  Exploratory Data Analysis (EDA)   ======================================

-- ===========================================================================================
-- 24. Produce the query that would feed a **histogram** of order values (bucket total order value into ranges, e.g., 0-500, 500-1000, 1000-2000, 2000+, and count orders in each bucket).
WITH order_totals AS (
    -- STEP 1: Calculate the exact total checkout value for every single order
    SELECT 
        order_id,
        ROUND(SUM(quantity * unit_price_at_sale * (1 - discount_pct / 100.0))::numeric, 2) AS total_order_value
    FROM order_items
    GROUP BY order_id
),
bucketed_orders AS (
    -- STEP 2: Use a CASE statement to assign each order into a price bucket
    SELECT 
        order_id,
        total_order_value,
        CASE 
            WHEN total_order_value >= 0 AND total_order_value < 500 THEN '1. $0 - $500'
            WHEN total_order_value >= 500 AND total_order_value < 1000 THEN '2. $500 - $1,000'
            WHEN total_order_value >= 1000 AND total_order_value < 2000 THEN '3. $1,000 - $2,000'
            WHEN total_order_value >= 2000 THEN '4. $2,000+'
            ELSE 'Unknown'
        END AS price_bucket
    FROM order_totals
)
-- STEP 3: Count how many orders fell into each bucket
SELECT 
    price_bucket,
    COUNT(order_id) AS total_orders
FROM bucketed_orders
GROUP BY price_bucket
ORDER BY price_bucket ASC;

-- ================================================================================================
-- 25. Produce the query that would feed a bar chart comparing total revenue by store. (Exclude/strip out any invalid data (negative quantities, impossible order dates, broken prices/discounts and store_ids that don't exist in the `stores` table) to ensure accuracy.)
SELECT 
    st.store_name,
    ROUND(SUM(it.quantity * it.unit_price_at_sale * (1 - it.discount_pct / 100.0))::numeric, 2) AS total_revenue
FROM stores AS st
INNER JOIN orders AS ord 
    ON st.store_id = ord.store_id
INNER JOIN order_items AS it 
    ON ord.order_id = it.order_id
-- Add data quality filters to ensure revenue accuracy
WHERE it.quantity > 0 
  AND it.unit_price_at_sale >= 0
  AND it.discount_pct BETWEEN 0 AND 100
  AND ord.order_date >= st.opened_date
  AND st.store_id IN (
      SELECT store_id 
      FROM stores
  )
GROUP BY 
    st.store_id, 
    st.store_name
-- Sort descending so your bar chart displays the highest-performing stores first
ORDER BY 
    total_revenue DESC;

-- ===============================================================================================
-- 26. Produce the query that would feed a line chart of monthly revenue trend for the whole chain, Jan 2023–June 2026.
-- Calculate monthly revenue trend for the whole chain (Jan 2023 - Jun 2026)
SELECT 
    -- Use DATE_TRUNC so charting tools recognize this as a true continuous date (e.g., '2023-01-01')
    DATE_TRUNC('month', ord.order_date)::DATE AS revenue_month,
    ROUND(SUM(it.quantity * it.unit_price_at_sale * (1 - it.discount_pct / 100.0))::numeric, 2) AS total_revenue
FROM orders AS ord
INNER JOIN order_items AS it 
    ON ord.order_id = it.order_id
INNER JOIN stores AS st
    ON ord.store_id = st.store_id
WHERE 
    -- Filter for the requested timeframe (Jan 1, 2023 up to, but not including, July 1, 2026)
    ord.order_date >= '2023-01-01' 
    AND ord.order_date < '2026-07-01'
    -- Data quality filters for accuracy
    AND it.quantity > 0 
    AND it.unit_price_at_sale >= 0
    AND it.discount_pct BETWEEN 0 AND 100
    AND ord.order_date >= st.opened_date
GROUP BY 
    DATE_TRUNC('month', ord.order_date)::DATE
-- Sort chronologically so the line chart draws from left to right correctly
ORDER BY 
    revenue_month ASC;

-- ===============================================================================================
-- 27. Calculate mean, median (using `PERCENTILE_CONT`), and standard deviation of order value. Is the distribution likely skewed? Justify from the numbers alone.
WITH order_totals AS (
    -- Step 1: Calculate the exact total value of each individual order, 
    -- applying strict data quality checks to ensure accuracy.
    SELECT 
        it.order_id,
        ROUND(SUM(it.quantity * it.unit_price_at_sale * (1 - it.discount_pct / 100.0))::numeric, 2) AS order_value
    FROM order_items AS it
    INNER JOIN orders AS ord
        ON it.order_id = ord.order_id
    INNER JOIN stores AS st
        ON ord.store_id = st.store_id
    WHERE it.quantity > 0 
      AND it.unit_price_at_sale >= 0
      AND it.discount_pct BETWEEN 0 AND 100
      AND ord.order_date >= st.opened_date
    GROUP BY it.order_id
)
-- Step 2: Calculate the statistical distribution metrics across all orders
SELECT 
    ROUND(AVG(order_value), 2) AS mean_order_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_value) AS median_order_value,
    ROUND(STDDEV(order_value), 2) AS stddev_order_value
FROM order_totals;

-- The distribution is right-skewwed (The mean is greater than the median)

-- ===============================================================================================
-- 28. Produce a query that would feed a **box plot** of order value by membership tier (min, Q1, median, Q3, max per tier).
WITH order_totals AS (
    -- Step 1: Calculate the exact total value of each order and attach the customer's membership tier.
    -- Strict data quality checks are applied to ensure accuracy.
    SELECT 
        it.order_id,
        -- DATA QUALITY: Standardize text to prevent 'gold' and ' Gold ' from splitting into different boxes
        UPPER(TRIM(cust.membership_tier)) AS membership_tier,
        ROUND(SUM(it.quantity * it.unit_price_at_sale * (1 - it.discount_pct / 100.0))::numeric, 2) AS order_value
    FROM order_items AS it
    INNER JOIN orders AS ord
        ON it.order_id = ord.order_id
    INNER JOIN stores AS st
        ON ord.store_id = st.store_id
    INNER JOIN customers AS cust
        ON ord.customer_id = cust.customer_id
    WHERE it.quantity > 0 
      AND it.unit_price_at_sale >= 0
      AND it.discount_pct BETWEEN 0 AND 100
      AND ord.order_date >= st.opened_date
      -- EXTRA DATA QUALITY: Prevent any impossible future dates from skewing the data
      AND ord.order_date <= CURRENT_DATE
    GROUP BY 
        it.order_id,
        UPPER(TRIM(cust.membership_tier))
)
-- Step 2: Calculate the 5-number summary needed for a box plot, grouped by tier
SELECT 
    -- Use COALESCE just in case there are customers with a NULL membership tier
    COALESCE(membership_tier, 'NO TIER') AS membership_tier,
    
    MIN(order_value) AS min_value,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY order_value) AS q1_value,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY order_value) AS median_value,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY order_value) AS q3_value,
    MAX(order_value) AS max_value,
    
    -- Bonus: Count the number of orders in each tier to provide sample size context
    COUNT(order_id) AS total_orders
FROM order_totals
GROUP BY membership_tier
ORDER BY membership_tier ASC;

-- ===============================================================================================
-- 29. Investigate the correlation between a store's `store_size_sqm` and its average monthly revenue — is there a relationship? (Compute revenue per store, then reason about the pattern; bonus if you compute Pearson's r manually via `CORR()`.)
WITH monthly_revenue AS (
    -- Step 1: Calculate the total revenue for every store, for every month they were active
    SELECT 
        st.store_id,
        st.store_size_sqm,
        DATE_TRUNC('month', ord.order_date) AS order_month,
        SUM(it.quantity * it.unit_price_at_sale * (1 - it.discount_pct / 100.0)) AS monthly_total
    FROM stores AS st
    INNER JOIN orders AS ord 
        ON st.store_id = ord.store_id
    INNER JOIN order_items AS it 
        ON ord.order_id = it.order_id
    -- Strict data quality checks to ensure our stats aren't skewed by bad data
    WHERE it.quantity > 0 
      AND it.unit_price_at_sale >= 0
      AND it.discount_pct BETWEEN 0 AND 100
      AND ord.order_date >= st.opened_date
      AND ord.order_date <= CURRENT_DATE
    GROUP BY 
        st.store_id,
        st.store_size_sqm,
        DATE_TRUNC('month', ord.order_date)
),
store_averages AS (
    -- Step 2: Roll up those months into a single "average monthly revenue" per store
    SELECT 
        store_id,
        store_size_sqm,
        AVG(monthly_total) AS avg_monthly_revenue
    FROM monthly_revenue
    GROUP BY 
        store_id, 
        store_size_sqm
)
-- Step 3: Output the raw data and compute Pearson's r as a Window Function
SELECT 
    store_id,
    store_size_sqm,
    ROUND(avg_monthly_revenue::numeric, 2) AS avg_monthly_revenue,
    
    -- Calculate Pearson correlation (r) across the entire dataset
    -- CORR(Y-axis, X-axis)
    ROUND(CORR(avg_monthly_revenue, store_size_sqm) OVER ()::numeric, 4) AS pearson_r
FROM store_averages
ORDER BY 
    store_size_sqm DESC;

-- ===============================================================================================
--30. Segment customers by recency of last order (e.g., ordered in last 30/90/180+ days) — this is the foundation of a churn-risk view for leadership.
WITH customer_recent_order AS (
    -- Step 1: Find the absolute most recent, valid order date for each customer
    SELECT 
        cust.customer_id,
        cust.full_name,
        MAX(ord.order_date::DATE) AS last_order_date
    FROM customers AS cust
    INNER JOIN orders AS ord 
        ON cust.customer_id = ord.customer_id
    -- Data Quality: Exclude any corrupted "future" orders from messing up our calculation
    WHERE ord.order_date <= CURRENT_DATE
    GROUP BY 
        cust.customer_id,
        cust.full_name
),
recency_calculation AS (
    -- Step 2: Calculate exactly how many days it has been since that last order
    SELECT 
        customer_id,
        full_name,
        last_order_date,
        (CURRENT_DATE - last_order_date) AS days_since_last_order
    FROM customer_recent_order
)
-- Step 3: Segment the customers into actionable Churn Risk buckets
SELECT 
    customer_id,
    full_name,
    last_order_date,
    days_since_last_order,
    CASE 
        WHEN days_since_last_order <= 30 THEN '1. Active (0-30 days)'
        WHEN days_since_last_order <= 90 THEN '2. At Risk (31-90 days)'
        WHEN days_since_last_order <= 180 THEN '3. Churning (91-180 days)'
        ELSE '4. Lost (181+ days)'
    END AS churn_risk_segment
FROM recency_calculation
ORDER BY 
    churn_risk_segment ASC,
    days_since_last_order ASC;

-- ================================= High level summary of Churn Risk Segmentation =========================================
WITH customer_recent_order AS (
    -- Step 1: Find the absolute most recent, valid order date for each customer
    SELECT 
        cust.customer_id,
        cust.full_name,
        MAX(ord.order_date::DATE) AS last_order_date
    FROM customers AS cust
    INNER JOIN orders AS ord 
        ON cust.customer_id = ord.customer_id
    -- Data Quality: Exclude any corrupted "future" orders from messing up our calculation
    WHERE ord.order_date <= CURRENT_DATE
    GROUP BY 
        cust.customer_id,
        cust.full_name
),
recency_calculation AS (
    -- Step 2: Calculate exactly how many days it has been since that last order
    SELECT 
        customer_id,
        full_name,
        last_order_date,
        (CURRENT_DATE - last_order_date) AS days_since_last_order
    FROM customer_recent_order
),
segmented_customers AS (
    -- Step 3: Segment the customers into actionable Churn Risk buckets
    SELECT 
        customer_id,
        CASE 
            WHEN days_since_last_order <= 30 THEN '1. Active (0-30 days)'
            WHEN days_since_last_order <= 90 THEN '2. At Risk (31-90 days)'
            WHEN days_since_last_order <= 180 THEN '3. Churning (91-180 days)'
            ELSE '4. Lost (181+ days)'
        END AS churn_risk_segment
    FROM recency_calculation
)
-- Step 4: High-level summary counting customers in each segment
SELECT 
    churn_risk_segment,
    COUNT(customer_id) AS total_customers
FROM segmented_customers
GROUP BY 
    churn_risk_segment
ORDER BY 
    churn_risk_segment ASC;

-- =======================================================================================
