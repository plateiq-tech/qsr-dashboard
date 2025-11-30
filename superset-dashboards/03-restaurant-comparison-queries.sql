-- ============================================
-- Restaurant Comparison Dashboard
-- SQL Queries for Superset Charts
-- ============================================

-- Chart 1: Restaurant Performance Summary (Table)
SELECT
    restaurant_name,
    count(DISTINCT toDate(transaction_date)) as days_active,
    sum(total_amount) as total_revenue,
    count(*) as total_transactions,
    sum(quantity) as total_items_sold,
    avg(total_amount) as avg_transaction_value,
    max(total_amount) as highest_transaction,
    count(DISTINCT menu_item_id) as unique_items_sold
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name
ORDER BY total_revenue DESC;

-- Chart 2: Revenue Trend by Restaurant (Multi-line Chart)
SELECT
    toDate(transaction_date) as date,
    restaurant_name,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 90 DAY
GROUP BY date, restaurant_name
ORDER BY date, restaurant_name;

-- Chart 3: Monthly Revenue Comparison (Pivot Table)
SELECT
    restaurant_name,
    toStartOfMonth(transaction_date) as month,
    sum(total_amount) as revenue,
    count(*) as transactions
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 12 MONTH
GROUP BY restaurant_name, month
ORDER BY month DESC, revenue DESC;

-- Chart 4: Top Items by Restaurant (Grouped Bar)
WITH ranked_items AS (
    SELECT
        restaurant_name,
        menu_item_name,
        sum(total_amount) as revenue,
        ROW_NUMBER() OVER (PARTITION BY restaurant_name ORDER BY sum(total_amount) DESC) as rank
    FROM sales_transactions
    WHERE transaction_date >= today() - INTERVAL 30 DAY
    GROUP BY restaurant_name, menu_item_name
)
SELECT
    restaurant_name,
    menu_item_name,
    revenue
FROM ranked_items
WHERE rank <= 5
ORDER BY restaurant_name, rank;

-- Chart 5: Restaurant Performance Scatter (Transactions vs Avg Value)
SELECT
    restaurant_name,
    count(*) as transaction_count,
    avg(total_amount) as avg_transaction_value,
    sum(total_amount) as total_revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name;

-- Chart 6: Payment Method Distribution by Restaurant (Stacked Bar)
SELECT
    restaurant_name,
    payment_method,
    sum(total_amount) as revenue,
    count(*) as transaction_count
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name, payment_method
ORDER BY restaurant_name, revenue DESC;

-- Chart 7: Order Type Mix by Restaurant (100% Stacked Bar)
SELECT
    restaurant_name,
    order_type,
    sum(total_amount) as revenue,
    (revenue / sum(revenue) OVER (PARTITION BY restaurant_name)) * 100 as pct_of_restaurant_revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name, order_type
ORDER BY restaurant_name, revenue DESC;

-- Chart 8: Category Performance by Restaurant (Heatmap)
SELECT
    restaurant_name,
    category,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name, category
ORDER BY restaurant_name, revenue DESC;

-- Chart 9: Day of Week Performance by Restaurant
SELECT
    restaurant_name,
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
    count(*) as transactions
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 8 WEEK
GROUP BY restaurant_name, day_name, toDayOfWeek(transaction_date)
ORDER BY restaurant_name, toDayOfWeek(transaction_date);

-- Chart 10: Growth Comparison (MoM Growth Rate)
WITH monthly_revenue AS (
    SELECT
        restaurant_name,
        toStartOfMonth(transaction_date) as month,
        sum(total_amount) as revenue
    FROM sales_transactions
    WHERE transaction_date >= today() - INTERVAL 6 MONTH
    GROUP BY restaurant_name, month
)
SELECT
    curr.restaurant_name,
    curr.month,
    curr.revenue as current_month,
    prev.revenue as previous_month,
    ((curr.revenue - prev.revenue) / prev.revenue) * 100 as growth_pct
FROM monthly_revenue curr
LEFT JOIN monthly_revenue prev
    ON curr.restaurant_name = prev.restaurant_name
    AND curr.month = prev.month + INTERVAL 1 MONTH
WHERE prev.revenue > 0
ORDER BY curr.month DESC, growth_pct DESC;

-- Chart 11: Restaurant Rankings with Sparkline Data
SELECT
    restaurant_name,
    toDate(transaction_date) as date,
    sum(total_amount) as daily_revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name, date
ORDER BY restaurant_name, date;
