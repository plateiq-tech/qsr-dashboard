# Dashboard Import/Export Guide

This guide explains how to backup, share, and restore Superset dashboards.

## Exporting Dashboards

### Method 1: Using the UI

1. Navigate to **Dashboards**
2. Find your dashboard
3. Click the **⋮** menu
4. Select **Export**
5. Choose format:
   - **Dashboard** - Exports just the dashboard config
   - **Dashboard with datasets** - Includes underlying datasets
   - **Full export** - Includes charts and datasets

6. Save the `.zip` file

### Method 2: Using the API

```bash
# Get dashboard list
curl -X GET "http://localhost:8088/api/v1/dashboard/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Export specific dashboard
curl -X GET "http://localhost:8088/api/v1/dashboard/export/?q=![DASHBOARD_ID]" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -o dashboard_export.zip
```

### Method 3: Bulk Export (All Dashboards)

```bash
# Export all dashboards
superset export-dashboards -f dashboards_backup.zip
```

---

## Importing Dashboards

### Method 1: Using the UI

1. Navigate to **Dashboards**
2. Click **⋮** (top right)
3. Select **Import Dashboard**
4. Upload your `.zip` file
5. Choose import options:
   - **Overwrite** - Replace existing dashboards
   - **Skip** - Keep existing, don't import duplicates

6. Click **Import**

### Method 2: Using the API

```bash
curl -X POST "http://localhost:8088/api/v1/dashboard/import/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "formData=@dashboard_export.zip"
```

---

## Best Practices

### 1. Version Control

Keep dashboard exports in Git:

```bash
# Create exports directory
mkdir -p superset-exports

# Export all dashboards
superset export-dashboards -f superset-exports/dashboards-$(date +%Y%m%d).zip

# Commit to Git
git add superset-exports/
git commit -m "Backup dashboards $(date +%Y-%m-%d)"
```

### 2. Environment-Specific Configs

When moving between environments (dev/staging/prod), update:

**Database connections:**
- Connection strings
- Credentials
- Host names

**Caching settings:**
- Cache timeout values
- Redis/Memcached config

**User permissions:**
- Role assignments
- Row-level security

### 3. Scheduled Backups

Create a cron job for automated backups:

```bash
# Add to crontab (crontab -e)
0 2 * * * /path/to/backup-superset.sh
```

**backup-superset.sh:**
```bash
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR="/backups/superset"

# Export dashboards
superset export-dashboards -f "$BACKUP_DIR/dashboards-$DATE.zip"

# Export database (if using SQLite)
cp /app/superset_home/superset.db "$BACKUP_DIR/superset-$DATE.db"

# Keep only last 30 days
find "$BACKUP_DIR" -name "*.zip" -mtime +30 -delete
```

---

## Dashboard Migration Checklist

When moving dashboards to a new environment:

### Pre-Migration
- [ ] Export dashboards from source environment
- [ ] Document database connections used
- [ ] Note any custom SQL metrics
- [ ] List required datasets
- [ ] Check for environment-specific filters

### Post-Migration
- [ ] Import dashboard files
- [ ] Update database connections
- [ ] Verify dataset availability
- [ ] Test all charts load correctly
- [ ] Check filters work properly
- [ ] Validate date ranges
- [ ] Test user permissions
- [ ] Update cache settings
- [ ] Configure email reports
- [ ] Set up alerts

---

## Sharing Dashboards

### Share with Team

**Read-only access:**
```
http://localhost:8088/superset/dashboard/[id]/?standalone=1
```

**Embedded (iframe):**
```html
<iframe
  src="http://localhost:8088/superset/dashboard/[id]/?standalone=3"
  width="100%"
  height="600">
</iframe>
```

### Email Reports

1. Edit dashboard
2. Click **⋮** > **Set up periodic report**
3. Configure:
   - **Recipients:** email addresses
   - **Schedule:** Daily/Weekly/Monthly
   - **Format:** PNG/PDF
   - **Time:** When to send

### Public Dashboards (Use with caution!)

To make a dashboard public:

1. Go to **Settings** > **Security**
2. Enable **Public Role**
3. Edit dashboard
4. **Properties** > **Owners** > Add "Public"
5. Share the URL

**Warning:** This exposes data to anyone with the link!

---

## Disaster Recovery

### Full Backup

Backup everything important:

```bash
#!/bin/bash
BACKUP_DATE=$(date +%Y%m%d)

# 1. Export dashboards
superset export-dashboards -f dashboards-$BACKUP_DATE.zip

# 2. Export database
docker exec qsr-postgres pg_dump -U superset superset > superset-db-$BACKUP_DATE.sql

# 3. Backup config
cp /app/superset_config.py superset_config-$BACKUP_DATE.py

# 4. Backup custom CSS/assets
tar -czf assets-$BACKUP_DATE.tar.gz /app/superset/static/assets/custom/
```

### Recovery Steps

1. **Restore Database:**
```bash
# PostgreSQL
docker exec -i qsr-postgres psql -U superset < superset-db-backup.sql

# SQLite
cp superset-backup.db /app/superset_home/superset.db
```

2. **Restore Config:**
```bash
cp superset_config-backup.py /app/superset_config.py
```

3. **Import Dashboards:**
```bash
superset import-dashboards -p dashboards-backup.zip
```

4. **Restart Superset:**
```bash
docker-compose restart superset
```

---

## Troubleshooting Import Issues

### Error: "Database does not exist"

**Solution:** Create database connection first, then import

### Error: "Dataset not found"

**Solution:** Import datasets separately or choose "Import with datasets"

### Error: "Permission denied"

**Solution:** Make sure you're logged in as admin

### Error: "Duplicate key"

**Solution:** Use overwrite option or delete existing dashboard first

---

## Sample Export Structure

A dashboard export `.zip` contains:

```
dashboard_export.zip
├── databases/
│   └── QSR_Sales_Database.yaml
├── datasets/
│   ├── sales_transactions.yaml
│   └── daily_sales_mv.yaml
├── charts/
│   ├── Total_Revenue.yaml
│   ├── Revenue_Trend.yaml
│   └── Top_Restaurants.yaml
└── dashboards/
    └── Executive_Overview.yaml
```

Each YAML file contains configuration for that component.

---

## Tips for Team Collaboration

### 1. Dashboard Naming Convention

```
[Team/Department] - [Purpose] - [Version]
Sales - Executive Overview - v2
Operations - Hourly Performance - v1
Finance - Revenue Analysis - v3
```

### 2. Dashboard Tagging

Use tags to organize:
- `executive` - C-level dashboards
- `operations` - Operational metrics
- `sales` - Sales team dashboards
- `daily` - Daily monitoring
- `weekly` - Weekly reports

### 3. Change Management

Document changes:
```markdown
## Executive Overview Dashboard

**Version:** 2.1
**Last Updated:** 2025-11-30
**Owner:** Data Team

### Changelog
- v2.1 (2025-11-30): Added payment method breakdown
- v2.0 (2025-11-15): Redesigned layout, added filters
- v1.0 (2025-11-01): Initial version
```

---

## Automated Dashboard Testing

Create a test script:

```python
import requests

SUPERSET_URL = "http://localhost:8088"
AUTH_TOKEN = "your_token"

def test_dashboard(dashboard_id):
    headers = {"Authorization": f"Bearer {AUTH_TOKEN}"}

    # Test dashboard loads
    response = requests.get(
        f"{SUPERSET_URL}/api/v1/dashboard/{dashboard_id}",
        headers=headers
    )

    assert response.status_code == 200, f"Dashboard {dashboard_id} failed to load"

    # Test charts in dashboard
    data = response.json()
    charts = data['result']['slices']

    for chart in charts:
        chart_response = requests.get(
            f"{SUPERSET_URL}/api/v1/chart/{chart['id']}/data",
            headers=headers
        )
        assert chart_response.status_code == 200, f"Chart {chart['slice_name']} failed"

# Run tests
test_dashboard(1)  # Executive Overview
print("✅ All tests passed")
```

---

## Resources

**Official Docs:**
- Import/Export: https://superset.apache.org/docs/using-superset/import-export-dashboards
- API Reference: https://superset.apache.org/docs/rest-api

**Backup Tools:**
- superset-backup: https://github.com/apache/superset/tree/master/superset/cli
