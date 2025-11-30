-- ============================================
-- Payment & Order Type Analysis Dashboard
-- SQL Queries for Superset Charts
-- ============================================

-- Chart 1: Revenue by Payment Method (Pie Chart)
SELECT
    payment_method,
    sum(total_amount) as revenue,
    count(*) as transaction_count,
    (revenue / (SELECT sum(total_amount) FROM sales_transactions WHERE transaction_date >= today() - INTERVAL 30 DAY)) * 100 as pct_of_total
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY payment_method
ORDER BY revenue DESC;

-- Chart 2: Revenue by Order Type (Donut Chart)
SELECT
    order_type,
    sum(total_amount) as revenue,
    count(*) as transaction_count,
    (revenue / (SELECT sum(total_amount) FROM sales_transactions WHERE transaction_date >= today() - INTERVAL 30 DAY)) * 100 as pct_of_total
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY order_type
ORDER BY revenue DESC;

-- Chart 3: Payment Method Trend (Stacked Area Chart)
SELECT
    toDate(transaction_date) as date,
    payment_method,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 90 DAY
GROUP BY date, payment_method
ORDER BY date, payment_method;

-- Chart 4: Order Type Trend (Line Chart)
SELECT
    toDate(transaction_date) as date,
    order_type,
    sum(total_amount) as revenue,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 90 DAY
GROUP BY date, order_type
ORDER BY date, order_type;

-- Chart 5: Average Transaction Value by Payment Method (Bar Chart)
SELECT
    payment_method,
    avg(total_amount) as avg_transaction_value,
    quantile(0.5)(total_amount) as median_transaction_value,
    max(total_amount) as max_transaction_value,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY payment_method
ORDER BY avg_transaction_value DESC;

-- Chart 6: Average Transaction Value by Order Type (Bar Chart)
SELECT
    order_type,
    avg(total_amount) as avg_transaction_value,
    avg(quantity) as avg_items_per_order,
    sum(total_amount) as total_revenue,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY order_type
ORDER BY avg_transaction_value DESC;

-- Chart 7: Payment Method by Restaurant (Table)
SELECT
    restaurant_name,
    payment_method,
    sum(total_amount) as revenue,
    count(*) as transaction_count,
    avg(total_amount) as avg_transaction_value
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name, payment_method
ORDER BY restaurant_name, revenue DESC;

-- Chart 8: Order Type by Restaurant (Grouped Bar)
SELECT
    restaurant_name,
    order_type,
    sum(total_amount) as revenue,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name, order_type
ORDER BY restaurant_name, revenue DESC;

-- Chart 9: Payment Method Mix by Hour (Stacked Bar)
SELECT
    toHour(transaction_date) as hour,
    payment_method,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY hour, payment_method
ORDER BY hour, transaction_count DESC;

-- Chart 10: Order Type Mix by Day of Week
SELECT
    CASE toDayOfWeek(transaction_date)
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
        WHEN 7 THEN 'Sunday'
    END as day_name,
    order_type,
    sum(total_amount) as revenue,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 8 WEEK
GROUP BY day_name, order_type, toDayOfWeek(transaction_date)
ORDER BY toDayOfWeek(transaction_date), revenue DESC;

-- Chart 11: Payment + Order Type Matrix (Heatmap)
SELECT
    payment_method,
    order_type,
    sum(total_amount) as revenue,
    count(*) as transaction_count,
    avg(total_amount) as avg_transaction_value
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY payment_method, order_type
ORDER BY revenue DESC;

-- Chart 12: Payment Method Adoption Trend
SELECT
    toStartOfWeek(transaction_date) as week,
    payment_method,
    count(*) as transaction_count,
    (transaction_count / sum(count(*)) OVER (PARTITION BY week)) * 100 as pct_of_week_transactions
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 12 WEEK
GROUP BY week, payment_method
ORDER BY week, transaction_count DESC;

-- Chart 13: Order Type Performance by Category
SELECT
    order_type,
    category,
    sum(total_amount) as revenue,
    sum(quantity) as items_sold
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY order_type, category
ORDER BY order_type, revenue DESC;
