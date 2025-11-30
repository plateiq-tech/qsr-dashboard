-- ============================================
-- Hourly Sales Performance Dashboard
-- SQL Queries for Superset Charts
-- ============================================

-- Chart 1: Sales Heatmap (Hour x Day of Week)
SELECT
    toHour(transaction_date) as hour,
    CASE toDayOfWeek(transaction_date)
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
        WHEN 7 THEN 'Sunday'
    END as day_name,
    sum(total_amount) as revenue,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 4 WEEK
GROUP BY hour, day_name, toDayOfWeek(transaction_date)
ORDER BY toDayOfWeek(transaction_date), hour;

-- Chart 2: Revenue by Hour (Stacked Area - by Order Type)
SELECT
    toHour(transaction_date) as hour,
    order_type,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY hour, order_type
ORDER BY hour, order_type;

-- Chart 3: Transaction Count by Hour (Bar Chart)
SELECT
    toHour(transaction_date) as hour,
    count(*) as transaction_count,
    sum(total_amount) as revenue,
    avg(total_amount) as avg_transaction_value
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY hour
ORDER BY hour;

-- Chart 4: Average Transaction Value by Hour (Line Chart)
SELECT
    toHour(transaction_date) as hour,
    avg(total_amount) as avg_transaction_value,
    quantile(0.5)(total_amount) as median_transaction_value,
    quantile(0.9)(total_amount) as p90_transaction_value
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY hour
ORDER BY hour;

-- Chart 5: Peak Hours Summary (Big Numbers)
-- Highest Revenue Hour
SELECT
    toHour(transaction_date) as peak_hour,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY peak_hour
ORDER BY revenue DESC
LIMIT 1;

-- Busiest Hour (by transaction count)
SELECT
    toHour(transaction_date) as busiest_hour,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY busiest_hour
ORDER BY transaction_count DESC
LIMIT 1;

-- Chart 6: Hourly Performance by Restaurant
SELECT
    restaurant_name,
    toHour(transaction_date) as hour,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY restaurant_name, hour
ORDER BY restaurant_name, hour;

-- Chart 7: Popular Items by Time of Day
WITH time_buckets AS (
    SELECT
        CASE
            WHEN toHour(transaction_date) BETWEEN 6 AND 10 THEN 'Breakfast (6-10 AM)'
            WHEN toHour(transaction_date) BETWEEN 11 AND 14 THEN 'Lunch (11 AM-2 PM)'
            WHEN toHour(transaction_date) BETWEEN 15 AND 17 THEN 'Afternoon (3-5 PM)'
            WHEN toHour(transaction_date) BETWEEN 18 AND 22 THEN 'Dinner (6-10 PM)'
            ELSE 'Late Night/Early Morning'
        END as time_period,
        menu_item_name,
        sum(total_amount) as revenue
    FROM sales_transactions
    WHERE transaction_date >= today() - INTERVAL 30 DAY
    GROUP BY time_period, menu_item_name
),
ranked_items AS (
    SELECT
        time_period,
        menu_item_name,
        revenue,
        ROW_NUMBER() OVER (PARTITION BY time_period ORDER BY revenue DESC) as rank
    FROM time_buckets
)
SELECT
    time_period,
    menu_item_name,
    revenue
FROM ranked_items
WHERE rank <= 5
ORDER BY time_period, rank;

-- Chart 8: Hourly Revenue Trend (Last 7 Days)
SELECT
    toDateTime(toStartOfHour(transaction_date)) as hour_timestamp,
    sum(total_amount) as revenue,
    count(*) as transactions
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY hour_timestamp
ORDER BY hour_timestamp;

-- Chart 9: Payment Method Distribution by Hour
SELECT
    toHour(transaction_date) as hour,
    payment_method,
    count(*) as transaction_count,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY hour, payment_method
ORDER BY hour, revenue DESC;

-- Chart 10: Hourly Efficiency Metrics
SELECT
    toHour(transaction_date) as hour,
    count(*) as total_transactions,
    sum(quantity) as total_items,
    sum(total_amount) as revenue,
    avg(quantity) as avg_items_per_transaction,
    sum(quantity) / count(*) as items_per_transaction
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY hour
ORDER BY hour;
