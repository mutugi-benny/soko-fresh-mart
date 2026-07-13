-- ============================================================================
-- SOKO FRESH MART — Database Schema
-- PostgreSQL-only project
-- Run this FIRST, before loading any data.
-- ============================================================================

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS stores CASCADE;

-- ── STORES ────────────────────────────────────────────────────────────────
CREATE TABLE stores (
    store_id        INTEGER PRIMARY KEY,
    store_name      VARCHAR(100) NOT NULL,
    town            VARCHAR(60)  NOT NULL,
    region          VARCHAR(60)  NOT NULL,
    opened_date     DATE NOT NULL,
    store_size_sqm  INTEGER CHECK (store_size_sqm > 0)
);

-- ── PRODUCTS ──────────────────────────────────────────────────────────────
CREATE TABLE products (
    product_id      INTEGER PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(60)  NOT NULL,
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    supplier        VARCHAR(100)
);

-- ── CUSTOMERS ─────────────────────────────────────────────────────────────
-- NOTE: intentionally NOT enforcing UNIQUE on email/full_name here —
-- part of the project is to DETECT duplicate/dirty records yourself.
CREATE TABLE customers (
    customer_id     INTEGER PRIMARY KEY,
    full_name       VARCHAR(150) NOT NULL,
    email           VARCHAR(150),
    phone           VARCHAR(20),
    city            VARCHAR(60),
    signup_date     DATE NOT NULL,
    membership_tier VARCHAR(20)
);

-- ── ORDERS ────────────────────────────────────────────────────────────────
-- NOTE: store_id intentionally has NO foreign key constraint —
-- the raw data contains a few orphaned store_id values (e.g. 999) on purpose,
-- so you can practice detecting referential-integrity problems yourself.
CREATE TABLE orders (
    order_id        INTEGER PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES customers(customer_id),
    store_id        INTEGER NOT NULL,        -- NOT a real FK on purpose, see above
    order_date      DATE NOT NULL,
    payment_method  VARCHAR(20),
    status          VARCHAR(20)
);

-- ── ORDER_ITEMS ───────────────────────────────────────────────────────────
CREATE TABLE order_items (
    order_item_id       INTEGER PRIMARY KEY,
    order_id            INTEGER NOT NULL REFERENCES orders(order_id),
    product_id          INTEGER NOT NULL REFERENCES products(product_id),
    quantity            INTEGER NOT NULL,     -- NOTE: not CHECK(quantity>0) on purpose — dirty data included
    unit_price_at_sale  NUMERIC(10,2) NOT NULL,
    discount_pct        NUMERIC(5,2) DEFAULT 0
);

-- Helpful indexes for join/aggregation performance
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_store      ON orders(store_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_items_order       ON order_items(order_id);
CREATE INDEX idx_items_product     ON order_items(product_id);
