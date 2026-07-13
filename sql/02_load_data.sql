-- ============================================================================
-- SOKO FRESH MART — Data Loading Script (CORRECTED)
-- Run this AFTER 01_schema.sql, from Git Bash, with your terminal's current
-- directory set to the sql/ folder (so the relative ../data/ paths resolve).
--
-- Usage (from inside the sql/ folder):
--   psql -U postgres -d soko_fresh_mart -f 02_load_data.sql
--
-- IMPORTANT: paths below use forward slashes ONLY. Never use backslashes
-- inside a \copy path — psql's own parser reads \copy as a meta-command and
-- will misinterpret a backslash inside the path as the start of a NEW
-- meta-command, cutting the line in half. That's what caused your
-- "syntax error at or near \" error.
-- ============================================================================

\copy stores(store_id, store_name, town, region, opened_date, store_size_sqm) FROM '../data/stores.csv' WITH (FORMAT csv, HEADER true);

\copy products(product_id, product_name, category, unit_price, supplier) FROM '../data/products.csv' WITH (FORMAT csv, HEADER true);

\copy customers(customer_id, full_name, email, phone, city, signup_date, membership_tier) FROM '../data/customers.csv' WITH (FORMAT csv, HEADER true);

\copy orders(order_id, customer_id, store_id, order_date, payment_method, status) FROM '../data/orders.csv' WITH (FORMAT csv, HEADER true);

\copy order_items(order_item_id, order_id, product_id, quantity, unit_price_at_sale, discount_pct) FROM '../data/order_items.csv' WITH (FORMAT csv, HEADER true);

-- Quick sanity check row counts
SELECT 'stores' AS table_name, COUNT(*) FROM stores
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
