# Superset Dashboard Setup Guide

This directory contains SQL queries and configuration guides for creating QSR analytics dashboards in Apache Superset.

## Dashboard Collection

### 1. Executive Sales Overview Dashboard
**File:** `01-executive-overview-queries.sql`

**Purpose:** High-level KPIs for C-suite and management

**Key Metrics:**
- Total Revenue (with comparisons)
- Transaction Count
- Average Transaction Value
- Top Products & Restaurants
- Revenue trends and patterns

**Recommended Refresh:** Every 5 minutes

---

### 2. Menu Performance Dashboard
**File:** `02-menu-performance-queries.sql`

**Purpose:** Deep dive into menu item and category performance

**Key Insights:**
- Best and worst performing items
- Category revenue distribution
- Price point analysis
- Week-over-week growth
- Day-of-week patterns

**Recommended Refresh:** Every 15 minutes

---

### 3. Restaurant Comparison Dashboard
**File:** `03-restaurant-comparison-queries.sql`

**Purpose:** Compare performance across restaurant locations

**Key Insights:**
- Multi-location performance rankings
- Revenue trends by location
- Top items per restaurant
- Payment method preferences by location
- Growth comparison

**Recommended Refresh:** Every 15 minutes

---

### 4. Hourly Sales Performance Dashboard
**File:** `04-hourly-performance-queries.sql`

**Purpose:** Understand peak hours and optimize staffing

**Key Insights:**
- Sales heatmap (hour x day of week)
- Peak hour identification
- Hourly revenue patterns
- Popular items by time of day
- Payment method preferences by hour

**Recommended Refresh:** Every 5 minutes

---

### 5. Payment & Order Type Analysis Dashboard
**File:** `05-payment-order-type-queries.sql`

**Purpose:** Analyze customer payment preferences and order types

**Key Insights:**
- Payment method distribution
- Order type trends (dine-in, takeout, delivery)
- Average transaction value by payment/order type
- Hourly and daily patterns
- Restaurant-level breakdowns

**Recommended Refresh:** Every 15 minutes

---

## Setup Instructions

### Step 1: Connect ClickHouse to Superset

1. Access your Superset instance at http://localhost:8088
2. Login with credentials from your `.env` file
3. Navigate to **Data > Databases**
4. Click **+ Database**
5. Select **ClickHouse** from the list
6. Enter connection details:
   ```
   SQLAlchemy URI: clickhousedb://default:@host.docker.internal:8123/plateiq
   ```

   **Note:** Use `host.docker.internal` to connect from Docker container to host machine's ClickHouse instance.

7. Click **Test Connection** to verify
8. Click **Connect**

### Step 2: Create Datasets

For each dashboard, you'll need to create SQL-based datasets:

1. Navigate to **Data > SQL Lab**
2. Select your ClickHouse database
3. Paste a query from the SQL files
4. Click **Run** to test
5. Click **Save** > **Save Dataset**
6. Name the dataset appropriately (e.g., "Daily Revenue Trend")
7. Repeat for each query you want to use

**Alternative:** Use the base tables as datasets:
- `sales_transactions` - for detailed queries
- `daily_sales_mv` - for aggregated queries (faster)

### Step 3: Create Charts

1. Navigate to **Charts**
2. Click **+ Chart**
3. Select your dataset
4. Choose appropriate visualization type:
   - **Big Number:** For KPIs
   - **Line Chart:** For trends over time
   - **Bar Chart:** For comparisons
   - **Pie/Donut Chart:** For distribution
   - **Table:** For detailed data
   - **Heatmap:** For hour x day patterns
   - **Treemap:** For hierarchical data

5. Configure the chart using the query columns
6. Apply filters and formatting
7. Save the chart

### Step 4: Create Dashboards

1. Navigate to **Dashboards**
2. Click **+ Dashboard**
3. Name your dashboard (e.g., "Executive Sales Overview")
4. Drag and drop charts onto the canvas
5. Resize and arrange charts
6. Add filters:
   - Date Range filter
   - Restaurant filter
   - Category filter (if applicable)
7. Configure filter scopes
8. Save the dashboard

### Step 5: Configure Auto-Refresh

For real-time dashboards:

1. Edit the dashboard
2. Click the **...** menu > **Edit Properties**
3. Set **Auto Refresh Interval** (e.g., 300 seconds for 5 minutes)
4. Save

---

## Query Customization Guide

### Using Date Filters

Replace hardcoded date ranges with Superset's time filters:

**Before:**
```sql
WHERE transaction_date >= today() - INTERVAL 30 DAY
```

**After (using Superset time filter):**
```sql
WHERE transaction_date >= {{ from_dttm }}
  AND transaction_date < {{ to_dttm }}
```

### Adding Dashboard Filters

Use Jinja templating for dynamic filters:

```sql
WHERE 1=1
  {% if filter_values('restaurant_name') %}
  AND restaurant_name IN {{ filter_values('restaurant_name')|where_in }}
  {% endif %}
  {% if filter_values('category') %}
  AND category IN {{ filter_values('category')|where_in }}
  {% endif %}
```

### Performance Optimization Tips

1. **Use the Materialized View** for aggregated queries:
   - Query `daily_sales_mv` instead of `sales_transactions` when possible
   - Example:
     ```sql
     SELECT
       date,
       sumMerge(total_revenue) as revenue
     FROM daily_sales_mv
     GROUP BY date
     ```

2. **Add Date Range Filters** to limit data scanned

3. **Use LIMIT** for large result sets

4. **Cache Results** in Superset:
   - Enable caching in Superset settings
   - Set appropriate cache timeout

5. **Optimize ClickHouse Queries:**
   - Use `PREWHERE` instead of `WHERE` when possible
   - Leverage the `ORDER BY` columns in your queries

---

## Chart Type Recommendations

| Data Type | Best Chart Type | Example Use Case |
|-----------|----------------|------------------|
| Single KPI | Big Number | Total Revenue Today |
| Trend over time | Line Chart | Daily Revenue Trend |
| Comparison | Bar Chart | Revenue by Restaurant |
| Distribution | Pie/Donut | Payment Method Split |
| Ranking | Table | Top 20 Menu Items |
| Two dimensions | Heatmap | Sales by Hour x Day |
| Hierarchy | Treemap/Sunburst | Category > Item Revenue |
| Correlation | Scatter Plot | Price vs Volume |
| Parts of whole | Stacked Bar | Order Type by Restaurant |

---

## Dashboard Layout Tips

### Executive Dashboard Layout
```
┌─────────────────┬─────────────────┬─────────────────┐
│   Total Revenue │  Transactions   │   Avg Value     │
│   (Big Number)  │  (Big Number)   │  (Big Number)   │
├─────────────────┴─────────────────┴─────────────────┤
│              Revenue Trend (Line Chart)              │
├─────────────────────────┬────────────────────────────┤
│  Revenue by Restaurant  │  Revenue by Payment Method │
│      (Bar Chart)        │       (Pie Chart)          │
├─────────────────────────┼────────────────────────────┤
│  Top 5 Items (Bar)      │  Revenue by Order Type     │
└─────────────────────────┴────────────────────────────┘
```

### Analysis Dashboard Layout
```
┌──────────────────────────────────────────────────────┐
│           Filters: Date Range | Restaurant           │
├───────────────────────────┬──────────────────────────┤
│                           │                          │
│   Primary Chart           │   Secondary Metrics      │
│   (Large Area)            │   (Smaller Cards)        │
│                           │                          │
├───────────────────────────┴──────────────────────────┤
│              Detailed Table / Breakdown              │
└──────────────────────────────────────────────────────┘
```

---

## Troubleshooting

### Common Issues

**1. "Database connection failed"**
- Check that ClickHouse is running
- Verify connection string
- Use `host.docker.internal` for Docker setup
- Check ClickHouse port (default: 8123)

**2. "Query timeout"**
- Add date range filters
- Use the materialized view
- Increase timeout in Superset settings
- Optimize your query

**3. "No data returned"**
- Check that data exists in ClickHouse
- Verify table/column names
- Check date filters aren't too restrictive

**4. "Chart not updating"**
- Clear Superset cache
- Check auto-refresh settings
- Verify data is being ingested

---

## Next Steps

1. **Set up Alerts:**
   - Configure email alerts for revenue drops
   - Set up anomaly detection

2. **Mobile Optimization:**
   - Create mobile-friendly dashboard layouts
   - Test on different screen sizes

3. **User Access Control:**
   - Set up roles and permissions
   - Restrict access to sensitive data

4. **Advanced Features:**
   - Create custom metrics
   - Use SQL Lab for ad-hoc analysis
   - Export dashboard as PDF/Email

---

## Support

For issues or questions:
- Superset Documentation: https://superset.apache.org/docs/intro
- ClickHouse Documentation: https://clickhouse.com/docs
- Project Repository: [Your repo URL]

---

**Last Updated:** 2025-11-30
