# ClickHouse Connection Examples for Superset

This guide provides different ClickHouse connection string examples for various setups.

## Connection String Format

```
clickhousedb://[username]:[password]@[host]:[port]/[database]?[parameters]
```

---

## Common Scenarios

### 1. Docker to Local ClickHouse (Recommended for this setup)

**Scenario:** Superset running in Docker, ClickHouse running on host machine

```
clickhousedb://default:@host.docker.internal:8123/plateiq
```

**With password:**
```
clickhousedb://default:your_password@host.docker.internal:8123/plateiq
```

**Notes:**
- `host.docker.internal` resolves to host machine from Docker container
- Default HTTP port for ClickHouse is `8123`
- Default user is `default` with empty password

---

### 2. Both on Host Machine (No Docker)

**Scenario:** Both Superset and ClickHouse running directly on host

```
clickhousedb://default:@localhost:8123/plateiq
```

or

```
clickhousedb://default:@127.0.0.1:8123/plateiq
```

---

### 3. Docker Compose Network

**Scenario:** Both services in same docker-compose.yml

Add ClickHouse to your `docker-compose.yml`:

```yaml
services:
  clickhouse:
    image: clickhouse/clickhouse-server:latest
    container_name: qsr-clickhouse
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      - clickhouse_data:/var/lib/clickhouse
    networks:
      - superset-network
    environment:
      - CLICKHOUSE_DB=plateiq
      - CLICKHOUSE_USER=default
      - CLICKHOUSE_PASSWORD=

volumes:
  clickhouse_data:
```

**Connection String:**
```
clickhousedb://default:@clickhouse:8123/plateiq
```

**Note:** Use the service name `clickhouse` as the host when containers are on the same network

---

### 4. Remote ClickHouse Server

**Scenario:** ClickHouse on a different server

```
clickhousedb://username:password@192.168.1.100:8123/plateiq
```

or with domain name:

```
clickhousedb://username:password@clickhouse.example.com:8123/plateiq
```

---

### 5. ClickHouse Cloud

**Scenario:** Using ClickHouse Cloud service

```
clickhousedbs://username:password@hostname.clickhouse.cloud:8443/database_name?secure=true
```

**Note:**
- Use `clickhousedbs://` (with 's') for SSL
- Port is typically `8443` for HTTPS
- Add `?secure=true` parameter

---

### 6. With Additional Parameters

**Enable compression:**
```
clickhousedb://default:@host.docker.internal:8123/plateiq?compression=lz4
```

**Set timeout:**
```
clickhousedb://default:@host.docker.internal:8123/plateiq?connect_timeout=10
```

**Multiple parameters:**
```
clickhousedb://default:@host.docker.internal:8123/plateiq?compression=lz4&connect_timeout=10&send_receive_timeout=300
```

---

## Testing Your Connection

### Method 1: Using curl (from host machine)

```bash
# Test basic connectivity
curl http://localhost:8123

# Should return: Ok.

# Test with query
curl "http://localhost:8123/?query=SELECT 1"

# Test database access
curl "http://localhost:8123/?query=SELECT count(*) FROM plateiq.sales_transactions"
```

### Method 2: Using ClickHouse client

```bash
# Install ClickHouse client
# macOS:
brew install clickhouse

# Connect
clickhouse-client --host localhost --port 9000

# Run test query
SELECT count(*) FROM plateiq.sales_transactions;
```

### Method 3: Using Python

```python
from clickhouse_connect import get_client

client = get_client(
    host='localhost',
    port=8123,
    username='default',
    password=''
)

# Test query
result = client.query('SELECT count(*) FROM plateiq.sales_transactions')
print(result.result_rows)
```

---

## Troubleshooting Connection Issues

### Error: "Connection refused"

**Possible causes:**
1. ClickHouse is not running
2. Wrong port number
3. Firewall blocking connection

**Solutions:**
```bash
# Check if ClickHouse is running
ps aux | grep clickhouse

# Check if port is listening
lsof -i :8123
# or
netstat -an | grep 8123

# Test connection
telnet localhost 8123
```

---

### Error: "Authentication failed"

**Possible causes:**
1. Wrong username/password
2. User doesn't have access to database

**Solutions:**
1. Check ClickHouse user configuration:
   - File: `/etc/clickhouse-server/users.xml`
   - Or use default user with empty password

2. Grant permissions:
```sql
GRANT SELECT ON plateiq.* TO default;
```

---

### Error: "Database not found"

**Solution:**
```sql
-- Check existing databases
SHOW DATABASES;

-- Create database if missing
CREATE DATABASE IF NOT EXISTS plateiq;

-- Verify tables exist
USE plateiq;
SHOW TABLES;
```

---

### Error: "Network is unreachable" (Docker)

**For Docker Desktop users:**

On **macOS/Windows**, use:
```
host.docker.internal
```

On **Linux**, you may need to:
1. Use `172.17.0.1` (Docker bridge IP)
2. Or add to docker-compose.yml:
```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

Then connection becomes:
```
clickhousedb://default:@host.docker.internal:8123/plateiq
```

---

## Advanced Configuration

### Using Native Protocol (Port 9000)

For better performance, use the native protocol:

```
clickhousenative://default:@host.docker.internal:9000/plateiq
```

**Note:** Requires `clickhouse-driver` Python package in Superset

---

### SSL/TLS Configuration

For secure connections:

```
clickhousedbs://default:password@hostname:8443/plateiq?secure=true&verify=true
```

Parameters:
- `secure=true` - Enable SSL
- `verify=true` - Verify SSL certificate
- `verify=false` - Skip certificate verification (development only)

---

### Read-only User

Create a read-only user for Superset:

```sql
-- In ClickHouse
CREATE USER superset_readonly IDENTIFIED BY 'your_secure_password';
GRANT SELECT ON plateiq.* TO superset_readonly;
```

Connection string:
```
clickhousedb://superset_readonly:your_secure_password@host.docker.internal:8123/plateiq
```

---

## Recommended Setup for Production

### 1. Create dedicated Superset user

```sql
CREATE USER superset IDENTIFIED BY 'strong_random_password';
GRANT SELECT ON plateiq.* TO superset;
```

### 2. Use connection with parameters

```
clickhousedb://superset:strong_random_password@clickhouse.internal:8123/plateiq?compression=lz4&connect_timeout=10&send_receive_timeout=300
```

### 3. Enable connection pooling in Superset

In Superset's database connection, go to **Advanced** > **Other**:

```json
{
  "engine_params": {
    "pool_size": 10,
    "pool_recycle": 3600,
    "pool_pre_ping": true
  }
}
```

---

## Quick Reference Table

| Setup Type | Host | Port | Example |
|------------|------|------|---------|
| Docker → Host | `host.docker.internal` | 8123 | `clickhousedb://default:@host.docker.internal:8123/plateiq` |
| Local | `localhost` | 8123 | `clickhousedb://default:@localhost:8123/plateiq` |
| Docker Network | `clickhouse` | 8123 | `clickhousedb://default:@clickhouse:8123/plateiq` |
| Remote | IP or domain | 8123 | `clickhousedb://user:pass@192.168.1.100:8123/db` |
| Cloud (SSL) | Cloud hostname | 8443 | `clickhousedbs://user:pass@host:8443/db?secure=true` |

---

## Verification Checklist

Before configuring Superset, verify:

- [ ] ClickHouse is running
- [ ] Port 8123 is accessible
- [ ] Database `plateiq` exists
- [ ] Tables `sales_transactions` and `daily_sales_mv` exist
- [ ] User has SELECT permissions
- [ ] Can run queries successfully from command line
- [ ] Network connectivity works (ping/telnet)

---

**Need help?** Check the logs:

**ClickHouse logs:**
```bash
# Docker
docker logs [clickhouse-container-name]

# Local installation
tail -f /var/log/clickhouse-server/clickhouse-server.log
```

**Superset logs:**
```bash
docker logs qsr-superset
```
