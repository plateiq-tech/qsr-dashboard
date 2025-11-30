-- ============================================
-- Menu Performance Dashboard
-- SQL Queries for Superset Charts
-- ============================================

-- Chart 1: Top 20 Menu Items by Revenue (Table)
SELECT
    menu_item_name,
    category,
    sum(total_amount) as revenue,
    sum(quantity) as units_sold,
    avg(unit_price) as avg_price,
    count(DISTINCT transaction_id) as transaction_count,
    (revenue / (SELECT sum(total_amount) FROM sales_transactions WHERE transaction_date >= today() - INTERVAL 30 DAY)) * 100 as pct_of_total
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY menu_item_name, category
ORDER BY revenue DESC
LIMIT 20;

-- Chart 2: Revenue by Category (Treemap)
SELECT
    category,
    menu_item_name,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY category, menu_item_name
ORDER BY category, revenue DESC;

-- Chart 3: Category Performance (Grouped Bar Chart)
SELECT
    category,
    sum(total_amount) as revenue,
    sum(quantity) as units_sold,
    count(DISTINCT transaction_id) as transactions
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY category
ORDER BY revenue DESC;

-- Chart 4: Sales Trend by Category (Multi-line Chart)
SELECT
    toDate(transaction_date) as date,
    category,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 90 DAY
GROUP BY date, category
ORDER BY date, category;

-- Chart 5: Item Performance Heatmap (Day of Week)
SELECT
    menu_item_name,
    toDayOfWeek(transaction_date) as day_of_week,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
AND menu_item_name IN (
    SELECT menu_item_name
    FROM sales_transactions
    WHERE transaction_date >= today() - INTERVAL 30 DAY
    GROUP BY menu_item_name
    ORDER BY sum(total_amount) DESC
    LIMIT 15
)
GROUP BY menu_item_name, day_of_week
ORDER BY revenue DESC;

-- Chart 6: Price Point Analysis (Scatter Plot)
SELECT
    menu_item_name,
    avg(unit_price) as avg_price,
    sum(quantity) as total_units_sold,
    sum(total_amount) as total_revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY menu_item_name
HAVING total_units_sold > 10;

-- Chart 7: Menu Mix Analysis (Stacked Bar by Restaurant)
SELECT
    restaurant_name,
    category,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY restaurant_name, category
ORDER BY restaurant_name, revenue DESC;

-- Chart 8: Growth Analysis (Week over Week)
WITH weekly_sales AS (
    SELECT
        menu_item_name,
        toStartOfWeek(transaction_date) as week,
        sum(total_amount) as revenue
    FROM sales_transactions
    WHERE transaction_date >= today() - INTERVAL 8 WEEK
    GROUP BY menu_item_name, week
)
SELECT
    curr.menu_item_name,
    curr.revenue as current_week_revenue,
    prev.revenue as previous_week_revenue,
    ((curr.revenue - prev.revenue) / prev.revenue) * 100 as growth_pct
FROM weekly_sales curr
LEFT JOIN weekly_sales prev
    ON curr.menu_item_name = prev.menu_item_name
    AND curr.week = prev.week + INTERVAL 1 WEEK
WHERE curr.week = toStartOfWeek(today())
AND prev.revenue > 0
ORDER BY growth_pct DESC
LIMIT 20;

-- Chart 9: Category Revenue Distribution (Sunburst)
SELECT
    'All Items' as level1,
    category as level2,
    menu_item_name as level3,
    sum(total_amount) as value
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY category, menu_item_name;

-- Chart 10: Average Transaction Value by Item
SELECT
    menu_item_name,
    category,
    avg(total_amount) as avg_transaction_value,
    count(*) as frequency
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 30 DAY
GROUP BY menu_item_name, category
HAVING frequency >= 10
ORDER BY avg_transaction_value DESC
LIMIT 20;
