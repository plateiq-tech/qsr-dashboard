-- ============================================
-- Executive Sales Overview Dashboard
-- SQL Queries for Superset Charts
-- ============================================

-- Chart 1: Total Revenue (Big Number with Trend)
-- Metric: Total Revenue Today
SELECT
    sum(total_amount) as revenue
FROM sales_transactions
WHERE toDate(transaction_date) = today();

-- Comparison: Yesterday
SELECT
    sum(total_amount) as revenue
FROM sales_transactions
WHERE toDate(transaction_date) = today() - INTERVAL 1 DAY;

-- Chart 2: Total Transactions (Big Number)
SELECT
    count(*) as transaction_count
FROM sales_transactions
WHERE toDate(transaction_date) = today();

-- Chart 3: Average Transaction Value (Big Number)
SELECT
    avg(total_amount) as avg_transaction_value
FROM sales_transactions
WHERE toDate(transaction_date) = today();

-- Chart 4: Daily Revenue Trend (Line Chart - Last 30 Days)
SELECT
    toDate(transaction_date) as date,
    sum(total_amount) as revenue,
    count(*) as transactions
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY date
ORDER BY date;

-- Chart 5: Revenue by Restaurant (Horizontal Bar Chart)
SELECT
    restaurant_name,
    sum(total_amount) as revenue,
    count(*) as transactions
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name
ORDER BY revenue DESC
LIMIT 10;

-- Chart 6: Revenue by Payment Method (Pie Chart)
SELECT
    payment_method,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY payment_method
ORDER BY revenue DESC;

-- Chart 7: Revenue by Order Type (Donut Chart)
SELECT
    order_type,
    sum(total_amount) as revenue,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY order_type
ORDER BY revenue DESC;

-- Chart 8: Top 5 Menu Items (Bar Chart)
SELECT
    menu_item_name,
    sum(total_amount) as revenue,
    sum(quantity) as units_sold
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY menu_item_name
ORDER BY revenue DESC
LIMIT 5;

-- Chart 9: Month-to-Date vs Last Month (Comparison)
-- MTD
SELECT
    sum(total_amount) as mtd_revenue
FROM sales_transactions
WHERE toStartOfMonth(transaction_date) = toStartOfMonth(today())
AND transaction_date <= today();

-- Last Month Same Period
SELECT
    sum(total_amount) as last_month_revenue
FROM sales_transactions
WHERE toStartOfMonth(transaction_date) = toStartOfMonth(today() - INTERVAL 1 MONTH)
AND toDayOfMonth(transaction_date) <= toDayOfMonth(today());

-- Chart 10: Hourly Sales Pattern (Area Chart - Today)
SELECT
    toHour(transaction_date) as hour,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE toDate(transaction_date) = today()
GROUP BY hour
ORDER BY hour;
