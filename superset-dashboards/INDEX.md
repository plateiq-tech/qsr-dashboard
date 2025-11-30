# Superset Dashboard Configuration Index

Complete collection of SQL queries, guides, and resources for creating QSR analytics dashboards in Apache Superset.

## 📁 Files Overview

### 🚀 Quick Start
- **[QUICKSTART.md](QUICKSTART.md)** - Create your first dashboard in 15 minutes
  - Step-by-step beginner guide
  - No prior Superset experience needed
  - Get up and running fast

### 📊 SQL Query Collections

#### 1️⃣ [01-executive-overview-queries.sql](01-executive-overview-queries.sql)
**Executive Sales Overview Dashboard**
- Total Revenue (with trends)
- Transaction counts and averages
- Revenue by restaurant, payment method, order type
- Top menu items
- 10 ready-to-use queries

#### 2️⃣ [02-menu-performance-queries.sql](02-menu-performance-queries.sql)
**Menu Performance Dashboard**
- Top 20 items by revenue
- Category analysis
- Sales trends by category
- Price point analysis
- Week-over-week growth
- 10 queries for menu insights

#### 3️⃣ [03-restaurant-comparison-queries.sql](03-restaurant-comparison-queries.sql)
**Restaurant Comparison Dashboard**
- Multi-location performance
- Top items per restaurant
- Payment & order type distribution
- Day of week patterns
- Growth comparisons
- 11 location-focused queries

#### 4️⃣ [04-hourly-performance-queries.sql](04-hourly-performance-queries.sql)
**Hourly Sales Performance Dashboard**
- Sales heatmap (hour × day of week)
- Peak hour identification
- Popular items by time of day
- Hourly efficiency metrics
- 10 time-based queries

#### 5️⃣ [05-payment-order-type-queries.sql](05-payment-order-type-queries.sql)
**Payment & Order Type Analysis Dashboard**
- Payment method distribution
- Order type trends
- Average transaction values
- Mix analysis by restaurant
- 13 payment & order queries

### 📖 Documentation

#### [README.md](README.md)
**Complete Setup Guide**
- Detailed setup instructions
- Dashboard recommendations
- Chart type selection guide
- Performance optimization tips
- Layout examples
- Troubleshooting section

#### [clickhouse-connection-examples.md](clickhouse-connection-examples.md)
**ClickHouse Connection Guide**
- Connection string examples for all scenarios
- Docker, local, remote, cloud setups
- Testing your connection
- Troubleshooting common issues
- Production recommendations

#### [dashboard-import-guide.md](dashboard-import-guide.md)
**Import/Export & Backup Guide**
- Exporting dashboards
- Importing dashboards
- Backup strategies
- Disaster recovery
- Team collaboration tips
- Version control

---

## 🎯 Recommended Reading Order

### For Beginners:
1. Start with **QUICKSTART.md**
2. Set up ClickHouse connection using **clickhouse-connection-examples.md**
3. Create your first charts using **01-executive-overview-queries.sql**
4. Expand with more dashboards from other SQL files

### For Experienced Users:
1. Browse **README.md** for overview
2. Pick SQL query files based on your needs
3. Reference **dashboard-import-guide.md** for team workflows
4. Use **clickhouse-connection-examples.md** for advanced configs

---

## 📈 Dashboard Priority Guide

### Phase 1: Essential (Week 1)
Start with these for immediate value:
- ✅ Executive Sales Overview (01)
- ✅ Menu Performance (02)

### Phase 2: Operational (Week 2)
Add these for deeper insights:
- ✅ Restaurant Comparison (03)
- ✅ Payment & Order Type Analysis (05)

### Phase 3: Advanced (Week 3)
Complete your analytics suite:
- ✅ Hourly Performance (04)
- ✅ Custom dashboards based on your needs

---

## 🔧 Technical Requirements

### Prerequisites
- Apache Superset (running via Docker)
- ClickHouse database with sales data
- Database: `plateiq`
- Tables: `sales_transactions`, `daily_sales_mv`

### Superset Access
- URL: http://localhost:8088
- Admin credentials from `.env` file

### ClickHouse Connection
```
clickhousedb://default:@host.docker.internal:8123/plateiq
```

---

## 📊 Total Queries Available

| Dashboard Type | # of Queries | Complexity | Estimated Setup Time |
|---------------|--------------|------------|---------------------|
| Executive Overview | 10 | Easy | 30 minutes |
| Menu Performance | 10 | Medium | 45 minutes |
| Restaurant Comparison | 11 | Medium | 45 minutes |
| Hourly Performance | 10 | Medium | 40 minutes |
| Payment & Order Type | 13 | Easy | 35 minutes |
| **TOTAL** | **54** | - | **~3 hours** |

---

## 🎨 Visualization Types Used

The query collections use these chart types:
- 📊 **Bar Charts** - Comparisons, rankings
- 📈 **Line Charts** - Trends over time
- 🥧 **Pie/Donut Charts** - Distributions
- 🔢 **Big Numbers** - KPIs with trends
- 📋 **Tables** - Detailed data
- 🔥 **Heatmaps** - Time patterns
- 🌳 **Treemaps** - Hierarchical data
- 📉 **Area Charts** - Stacked trends
- ⚡ **Scatter Plots** - Correlations

---

## 💡 Key Features

### All Queries Include:
- ✅ Proper date filtering
- ✅ Aggregations optimized for ClickHouse
- ✅ Comments explaining purpose
- ✅ Ready to copy-paste
- ✅ Tested with sample data

### Performance Optimizations:
- Uses materialized view where appropriate
- Leverages ClickHouse's columnar storage
- Includes proper date partitioning
- Optimized GROUP BY clauses

---

## 🚦 Getting Started Checklist

Before you begin, ensure you have:

- [ ] Superset running and accessible
- [ ] ClickHouse connected and tested
- [ ] Sample data in `sales_transactions` table
- [ ] Admin access to Superset
- [ ] Read the QUICKSTART.md guide
- [ ] Chosen which dashboards to build first

---

## 🆘 Need Help?

### Common Issues

**Can't connect to ClickHouse?**
→ See [clickhouse-connection-examples.md](clickhouse-connection-examples.md)

**Query not working?**
→ Check README.md troubleshooting section

**Dashboard not loading?**
→ Verify data exists, check date filters

**Charts showing no data?**
→ Test query in SQL Lab first

### Additional Resources

- Superset Docs: https://superset.apache.org/docs/intro
- ClickHouse Docs: https://clickhouse.com/docs
- Sample Data: Check the ingestor repo

---

## 📝 What's Included

```
superset-dashboards/
├── INDEX.md (you are here)
├── QUICKSTART.md (start here!)
├── README.md (detailed guide)
├── clickhouse-connection-examples.md
├── dashboard-import-guide.md
├── 01-executive-overview-queries.sql
├── 02-menu-performance-queries.sql
├── 03-restaurant-comparison-queries.sql
├── 04-hourly-performance-queries.sql
└── 05-payment-order-type-queries.sql
```

**Total:** 9 files covering everything you need

---

## 🎓 Learning Path

### Beginner → Intermediate → Advanced

**Level 1: Beginner**
1. Follow QUICKSTART.md
2. Create Executive Overview dashboard
3. Learn basic chart types

**Level 2: Intermediate**
4. Create additional dashboards
5. Add custom filters
6. Configure auto-refresh

**Level 3: Advanced**
7. Optimize query performance
8. Set up alerts
9. Create custom metrics
10. Implement row-level security

---

## 🔄 Updates & Maintenance

### Version History
- **v1.0** (2025-11-30): Initial release
  - 54 SQL queries
  - 5 dashboard types
  - Complete documentation

### Future Additions
- More dashboard examples
- Advanced analytics queries
- Custom metric definitions
- Alert configurations

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting sections in each guide
2. Review the README.md FAQ
3. Test queries in ClickHouse directly
4. Check Superset logs: `docker logs qsr-superset`

---

## ⭐ Pro Tips

1. **Start small**: Begin with Executive Overview
2. **Test first**: Try queries in SQL Lab before creating charts
3. **Use filters**: Add date range and restaurant filters to all dashboards
4. **Cache wisely**: Set appropriate cache timeouts
5. **Monitor performance**: Watch query execution times
6. **Document changes**: Keep track of what you modify
7. **Export regularly**: Backup your dashboards weekly

---

**Ready to begin?** → Open [QUICKSTART.md](QUICKSTART.md) and create your first dashboard in 15 minutes!

---

**Last Updated:** 2025-11-30  
**Total Files:** 9  
**Total Queries:** 54  
**Estimated Setup Time:** 3-4 hours for all dashboards
