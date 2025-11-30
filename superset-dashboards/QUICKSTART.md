# Superset Dashboard Quick Start Guide

This guide will help you create your first dashboard in 15 minutes.

## Prerequisites

- Superset running on http://localhost:8088
- ClickHouse with sales data
- Login credentials from `.env` file

---

## Step-by-Step: Create Your First Dashboard in 15 Minutes

### Part 1: Connect ClickHouse (2 minutes)

1. Open Superset at http://localhost:8088
2. Login with your credentials
3. Click **Settings** (⚙️) > **Database Connections**
4. Click **+ Database**
5. Choose **ClickHouse** or **Other**
6. Fill in the connection details:

   **Display Name:** QSR Sales Database

   **SQLAlchemy URI:**
   ```
   clickhousedb://default:@host.docker.internal:8123/plateiq
   ```

   If you're using a password, the format is:
   ```
   clickhousedb://username:password@host:port/database
   ```

7. In **Advanced** > **SQL Lab**, check:
   - ✅ Expose database in SQL Lab
   - ✅ Allow CREATE TABLE AS
   - ✅ Allow DML

8. Click **Test Connection**
9. If successful, click **Connect**

---

### Part 2: Create Your First Chart - Total Revenue (3 minutes)

1. Navigate to **SQL Lab** > **SQL Editor**
2. Select your ClickHouse database
3. Paste this query:

```sql
SELECT
    sum(total_amount) as revenue
FROM sales_transactions
WHERE toDate(transaction_date) = today();
```

4. Click **Run**
5. Verify you see a number
6. Click **Save** > **Save dataset**
   - **Dataset Name:** Today Revenue
   - Click **Save & Explore**

7. You'll be redirected to chart creation
8. Configure the chart:
   - **Chart Type:** Big Number
   - **Metric:** revenue (should be auto-selected)
   - **Timestamp:** None needed

9. In the **Customize** tab:
   - **Number format:** $,.2f (for currency)
   - **Subheader:** Today's Revenue

10. Click **Update Chart**
11. Click **Save** > Name it "Today's Revenue"
12. Click **Save & go to dashboard** > **+ Create new dashboard**
13. Name it **"Executive Overview"**

✅ **Checkpoint:** You now have your first chart on a dashboard!

---

### Part 3: Add More Charts (10 minutes)

#### Chart 2: Revenue Trend (3 minutes)

1. Go to **Charts** > **+ Chart**
2. Select dataset: **Create new dataset**
3. Select your ClickHouse database
4. Choose **sales_transactions** table
5. Click **Create Dataset and Create Chart**

6. Configure:
   - **Chart Type:** Line Chart
   - **Time Column:** transaction_date
   - **Metrics:** SUM(total_amount)
   - **Time Grain:** Day
   - **Time Range:** Last 30 days

7. Click **Update Chart**
8. **Save** as "30 Day Revenue Trend"
9. **Add to Dashboard** > Select "Executive Overview"

#### Chart 3: Top Restaurants (3 minutes)

1. **Charts** > **+ Chart**
2. Use the **sales_transactions** dataset
3. Configure:
   - **Chart Type:** Bar Chart
   - **Dimensions:** restaurant_name
   - **Metrics:** SUM(total_amount)
   - **Time Range:** Last 30 days
   - **Row limit:** 10
   - **Sort by:** SUM(total_amount) DESC

4. **Customize** tab:
   - **Show Values:** ✅ Yes
   - **Orientation:** Horizontal

5. **Save** as "Top 10 Restaurants"
6. **Add to Dashboard** > "Executive Overview"

#### Chart 4: Payment Methods (2 minutes)

1. **Charts** > **+ Chart**
2. Use **sales_transactions** dataset
3. Configure:
   - **Chart Type:** Pie Chart
   - **Dimensions:** payment_method
   - **Metrics:** SUM(total_amount)
   - **Time Range:** Last 30 days

4. **Customize** tab:
   - **Show Labels:** ✅ Yes
   - **Show Percentage:** ✅ Yes

5. **Save** as "Revenue by Payment Method"
6. **Add to Dashboard** > "Executive Overview"

#### Chart 5: Order Type Distribution (2 minutes)

1. **Charts** > **+ Chart**
2. Use **sales_transactions** dataset
3. Configure:
   - **Chart Type:** Pie Chart (or Donut)
   - **Dimensions:** order_type
   - **Metrics:** SUM(total_amount)
   - **Time Range:** Last 30 days

4. **Save** as "Revenue by Order Type"
5. **Add to Dashboard** > "Executive Overview"

---

### Part 4: Arrange Your Dashboard (2 minutes)

1. Go to **Dashboards** > **Executive Overview**
2. Click **Edit Dashboard**
3. Drag and resize charts to create a layout like this:

```
┌──────────────────────────────────────────────────────┐
│                   Today's Revenue                    │
│                   (Big Number)                       │
├──────────────────────────────────────────────────────┤
│              30 Day Revenue Trend                    │
│                 (Line Chart)                         │
├───────────────────────────┬──────────────────────────┤
│   Top 10 Restaurants      │  Payment Methods         │
│      (Bar Chart)          │     (Pie Chart)          │
│                           ├──────────────────────────┤
│                           │  Order Types             │
│                           │     (Pie Chart)          │
└───────────────────────────┴──────────────────────────┘
```

4. Click **Save**

---

## Adding Filters

Make your dashboard interactive:

1. **Edit Dashboard**
2. Click **Add/Edit Filters**
3. Add a **Time Range** filter:
   - **Filter Type:** Time range
   - **Default Value:** Last 30 days
   - **Scoped to:** All charts (except Today's Revenue)

4. Add a **Restaurant** filter:
   - **Filter Type:** Select filter
   - **Column:** restaurant_name
   - **Dataset:** sales_transactions
   - **Scoped to:** All charts

5. Click **Save**

---

## Testing Your Dashboard

1. Try changing the date range filter
2. Select different restaurants
3. Charts should update automatically

---

## Next Steps

### Enable Auto-Refresh

For real-time monitoring:

1. **Dashboard** > **⋮** menu > **Edit Properties**
2. Set **Auto Refresh** to 300 seconds (5 minutes)
3. **Save**

### Create More Advanced Charts

Try these queries in SQL Lab:

**Top 10 Menu Items:**
```sql
SELECT
    menu_item_name,
    sum(total_amount) as revenue,
    sum(quantity) as units_sold
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY menu_item_name
ORDER BY revenue DESC
LIMIT 10
```

**Hourly Revenue Pattern:**
```sql
SELECT
    toHour(transaction_date) as hour,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE toDate(transaction_date) = today()
GROUP BY hour
ORDER BY hour
```

**Revenue Heatmap (Hour x Day):**
```sql
SELECT
    toHour(transaction_date) as hour,
    toDayOfWeek(transaction_date) as day_of_week,
    sum(total_amount) as revenue
FROM sales_transactions
WHERE transaction_date >= today() - INTERVAL 7 DAY
GROUP BY hour, day_of_week
ORDER BY day_of_week, hour
```

Use **Heatmap** chart type for the last query!

---

## Troubleshooting

**Can't connect to ClickHouse?**
- Make sure ClickHouse is running
- Try `127.0.0.1` instead of `localhost`
- Check if ClickHouse is on port 8123: `curl http://localhost:8123`

**No data showing?**
- Verify data exists: Run query in ClickHouse directly
- Check date filters aren't excluding all data
- Make sure you're using the right database name

**Charts not updating?**
- Click **Force Refresh** button (⟳)
- Clear browser cache
- Check Superset cache settings

**Permission errors?**
- Make sure you're logged in as admin
- Check database connection permissions

---

## Pro Tips

1. **Use SQL Lab** for testing queries before creating charts
2. **Save queries** for reuse
3. **Use templates** for similar charts
4. **Group dashboards** into folders for organization
5. **Set up email reports** for daily summaries
6. **Export dashboards** as JSON for backup

---

## Common Metrics You'll Want

### Revenue Metrics
- Total Revenue
- Average Transaction Value
- Revenue per Restaurant
- Revenue Growth (MoM, WoW)

### Volume Metrics
- Transaction Count
- Items Sold
- Transactions per Restaurant
- Average Items per Transaction

### Product Metrics
- Top Selling Items
- Category Performance
- Item Mix
- New Item Performance

### Time-based Metrics
- Peak Hours
- Day of Week Patterns
- Seasonal Trends
- Year over Year Growth

---

**Need help?** Check the full README.md for detailed instructions and more advanced queries!

---

**Estimated Total Time:** 15-20 minutes

✅ **You're Done!** You now have a functional sales dashboard.
