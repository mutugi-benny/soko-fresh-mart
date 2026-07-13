/* ============================================================================
   Title: Monthly Executive Data Quality & Integrity Report
   
   Description: 
   A consolidated data quality report designed for monthly leadership review. 
   This query evaluates the overall health of the database by calculating 
   five critical data integrity metrics in a single executive summary row:
     1. Percentage (%) of missing customer emails
     2. Percentage (%) of missing customer phone numbers
     3. Count of likely duplicate customer records (based on name/email)
     4. Count of orphaned orders (assigned to non-existent store_ids)
     5. Count of invalid order items (quantities <= 0 or NULL)
============================================================================ */

WITH customer_completeness AS (
    -- 1. Calculate the percentage of missing emails and phone numbers
    SELECT 
        ROUND(COUNT(customer_id) FILTER (WHERE email IS NULL) * 100.0 / NULLIF(COUNT(customer_id), 0), 2) AS pct_missing_emails,
        ROUND(COUNT(customer_id) FILTER (WHERE phone IS NULL) * 100.0 / NULLIF(COUNT(customer_id), 0), 2) AS pct_missing_phones
    FROM customers
),
customer_duplicates AS (
    -- 2. Count the total number of customer records entangled in duplication
    -- (Using the exact data-cleaning logic we built previously)
    SELECT 
        COALESCE(SUM(duplicate_count), 0) AS count_duplicate_customers
    FROM (
        SELECT COUNT(customer_id) AS duplicate_count
        FROM customers
        GROUP BY INITCAP(TRIM(full_name)), LOWER(TRIM(email))
        HAVING COUNT(customer_id) > 1
    ) AS duplicates_grouped
),
orphan_orders AS (
    -- 3. Count orders assigned to a non-existent store_id (Using the Anti-Join method)
    SELECT 
        COUNT(order_id) AS count_orphaned_store_ids
    FROM orders AS ord
    WHERE NOT EXISTS (
        SELECT 1 
        FROM stores AS st 
        WHERE st.store_id = ord.store_id
    )
),
invalid_line_items AS (
    -- 4. Count order_items with invalid quantities (e.g., 0, negative, or NULL)
    SELECT 
        COUNT(*) AS count_invalid_quantities
    FROM order_items
    WHERE quantity <= 0 OR quantity IS NULL
)
-- 5. Bring it all together into a single executive summary row!
SELECT 
    cc.pct_missing_emails,
    cc.pct_missing_phones,
    cd.count_duplicate_customers,
    oo.count_orphaned_store_ids,
    ili.count_invalid_quantities
FROM customer_completeness AS cc
CROSS JOIN customer_duplicates AS cd
CROSS JOIN orphan_orders AS oo
CROSS JOIN invalid_line_items AS ili;