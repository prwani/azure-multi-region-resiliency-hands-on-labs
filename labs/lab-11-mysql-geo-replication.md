---
layout: default
title: "Lab 11: Azure Database for MySQL – Cross-Region Read Replica"
---

[← Back to Index](../index.md)

# Lab 11: Azure Database for MySQL – Cross-Region Read Replica

## Introduction

Azure Database for MySQL Flexible Server is the recommended deployment option for MySQL workloads on Azure. Unlike Azure SQL Database, MySQL Flexible Server does not offer built-in Failover Groups with automatic DNS switching. Instead, it provides **cross-region read replicas** using MySQL's native asynchronous binary log (binlog) replication.

| Feature | Detail |
|---|---|
| **Read Replicas** | Up to 10 asynchronous replicas per source server |
| **Cross-Region Support** | Replicas can be placed in any supported Azure region |
| **Replication Method** | MySQL binlog-based asynchronous replication |
| **Promotion** | A replica can be promoted to a standalone read-write server (irreversible) |
| **Read Scale-Out** | Offload reporting, analytics, and BI queries to read replicas |

### Why Cross-Region Read Replicas?

* **Disaster Recovery** — If the primary region becomes unavailable, promote the cross-region replica to a standalone server and redirect application traffic.
* **Read Latency Reduction** — Place a read replica near your users in another geography to reduce query latency for read-heavy workloads.
* **Compliance** — Keep a copy of data in a specific geographic region for regulatory requirements.

### What Read Replicas Are — and What They Are Not

| Replicated | **Not** replicated |
|---|---|
| All databases on the source server | Server parameters (must be set independently) |
| All tables, rows, and schema changes | Firewall rules |
| User accounts and privileges | Scheduled events |
| Binary log position | Server-level configuration changes |

> **Key takeaway:** Read replicas provide _data continuity_ across regions, but promotion to primary is a **manual, one-way operation**. There is no automatic failover or DNS alias switching — your application must handle the endpoint change.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│   ┌──────────────────────────┐          ┌──────────────────────────┐    │
│   │   Sweden Central         │          │   Norway East            │    │
│   │                          │          │                          │    │
│   │  ┌────────────────────┐  │  Async   │  ┌────────────────────┐  │    │
│   │  │ mysql-dr-swc-xxxxx │  │  Binlog  │  │ mysql-dr-noe-xxxxx │  │    │
│   │  │ (Source Server)    │──┼──Repl───►│  │ (Read Replica)     │  │    │
│   │  │                    │  │          │  │                    │  │    │
│   │  │ • Read + Write     │  │          │  │ • Read-only        │  │    │
│   │  │ • sampledb         │  │          │  │ • sampledb (copy)  │  │    │
│   │  └────────────────────┘  │          │  └────────────────────┘  │    │
│   │                          │          │                          │    │
│   │  rg-mysql-dr-swc         │          │  rg-mysql-dr-noe         │    │
│   └──────────────────────────┘          └──────────────────────────┘    │
│                                                                          │
│   On failover (manual):                                                 │
│   1. Promote replica → standalone read-write server                     │
│   2. Update application connection strings                              │
│   3. (Optional) Create new replica from promoted server                 │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

**Data flow:**

1. Applications connect to the **source server** in Sweden Central for read-write operations.
2. All writes are asynchronously replicated via MySQL binlog to the read replica in Norway East.
3. Read-only workloads can connect directly to the replica endpoint.
4. During a disaster, you **promote** the replica (one-way operation) and update your application's connection string.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.60 or later (`az --version`) |
| **Azure subscription** | With permissions to create MySQL Flexible Servers |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash |
| **mysql client** _(optional)_ | For direct database queries. Install via `sudo apt install mysql-client` |

> **Tip:** If you completed Lab 3 (Azure SQL), the workflow is similar — but MySQL uses read replicas instead of Failover Groups.

---

## Step 1 — Set Variables

```bash
# Unique suffix
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)

# Regions
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

# Resource groups
RG_PRIMARY="rg-mysql-dr-swc"
RG_SECONDARY="rg-mysql-dr-noe"

# Server names (globally unique)
PRIMARY_SERVER="mysql-dr-swc-${RANDOM_SUFFIX}"
REPLICA_SERVER="mysql-dr-noe-${RANDOM_SUFFIX}"

# Credentials
ADMIN_USER="mysqladmin"
ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"

# Database
DB_NAME="sampledb"

echo "Primary server : $PRIMARY_SERVER"
echo "Replica server : $REPLICA_SERVER"
echo "Admin user     : $ADMIN_USER"
echo "Admin password : $ADMIN_PASSWORD  (save this!)"
```

---

## Step 2 — Create Resource Groups

```bash
az group create --name $RG_PRIMARY   --location $PRIMARY_REGION   --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table
```

---

## Step 3 — Create the Source MySQL Flexible Server

Create a General Purpose tier server in Sweden Central. Read replicas require General Purpose or Memory Optimized tiers.

```bash
az mysql flexible-server create \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --location $PRIMARY_REGION \
  --admin-user $ADMIN_USER \
  --admin-password $ADMIN_PASSWORD \
  --sku-name Standard_B2ms \
  --tier GeneralPurpose \
  --storage-size 32 \
  --version 8.0.21 \
  --public-access 0.0.0.0 \
  --output table
```

> **Note:** `--public-access 0.0.0.0` enables access from all Azure services. In production, use private endpoints or restrict to specific IP ranges.

Verify the server is ready:

```bash
az mysql flexible-server show \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query "{Name:name, State:state, Location:location, SKU:sku.name, Version:version}" \
  --output table
```

---

## Step 4 — Create a Sample Database and Table

```bash
az mysql flexible-server db create \
  --server-name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --database-name $DB_NAME \
  --output table
```

If you have the `mysql` client installed, connect and create sample data:

```bash
mysql -h "${PRIMARY_SERVER}.mysql.database.azure.com" \
  -u $ADMIN_USER -p"$ADMIN_PASSWORD" $DB_NAME <<'SQL'
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name, price) VALUES
    ('Widget A', 9.99),
    ('Widget B', 19.99),
    ('Widget C', 29.99),
    ('Widget D', 39.99),
    ('Widget E', 49.99);

SELECT * FROM products;
SQL
```

---

## Step 5 — Create a Cross-Region Read Replica

Create an asynchronous read replica in Norway East:

```bash
az mysql flexible-server replica create \
  --replica-name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --source-server $PRIMARY_SERVER \
  --location $SECONDARY_REGION \
  --output table
```

> **Note:** This command may take 10-15 minutes. The replica is seeded with a full snapshot of the source server, then binlog replication begins.

---

## Step 6 — Verify the Replica

```bash
az mysql flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query "{Name:name, State:state, Location:location, ReplicationRole:replicationRole, SourceServer:sourceServerResourceId}" \
  --output table
```

Expected output:

| Name | State | Location | ReplicationRole | SourceServer |
|---|---|---|---|---|
| mysql-dr-noe-xxxxx | Ready | Norway East | Replica | /subscriptions/.../mysql-dr-swc-xxxxx |

---

## Step 7 — List All Replicas

```bash
az mysql flexible-server replica list \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query "[].{Name:name, Location:location, State:state, Role:replicationRole}" \
  --output table
```

---

## Step 8 — Verify Data Replication

If you have the `mysql` client, connect to the **replica** and verify data has been replicated:

```bash
mysql -h "${REPLICA_SERVER}.mysql.database.azure.com" \
  -u $ADMIN_USER -p"$ADMIN_PASSWORD" $DB_NAME \
  -e "SELECT * FROM products;"
```

You should see all 5 rows from the source server. The replica is **read-only** — any write attempt will fail with an error.

---

## Step 9 — Monitor Replication Lag

Check replication lag using Azure CLI:

```bash
az mysql flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query "{Name:name, ReplicationRole:replicationRole, State:state}" \
  --output table
```

> **Tip:** In the Azure Portal, navigate to the replica server → Monitoring → Metrics → select "Replication Lag In Seconds" to see a time-series graph of replication delay.

---

## Step 10 — Promote the Replica (Simulate Failover)

Promoting a replica disconnects it from the source and converts it to a standalone read-write server. **This action is irreversible.**

```bash
az mysql flexible-server replica stop-replication \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --yes \
  --output table
```

Verify the replica is now a standalone server:

```bash
az mysql flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query "{Name:name, State:state, ReplicationRole:replicationRole}" \
  --output table
```

Expected: `ReplicationRole` should now be `None` — the server is an independent, writable MySQL instance.

---

## Step 11 — Validate Write Access on Promoted Server

After promotion, the former replica accepts writes:

```bash
mysql -h "${REPLICA_SERVER}.mysql.database.azure.com" \
  -u $ADMIN_USER -p"$ADMIN_PASSWORD" $DB_NAME \
  -e "INSERT INTO products (name, price) VALUES ('Failover Widget', 59.99); SELECT * FROM products;"
```

---

## Step 12 — Cleanup

> ⚠️ **Skip this step if you want to keep resources for portal verification.**

```bash
az group delete --name $RG_PRIMARY   --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

---

## Discussion & Next Steps

### Failover Strategy

Unlike Azure SQL Failover Groups, MySQL Flexible Server does not provide automatic DNS switching. Your application-level failover strategy should include:

1. **Health monitoring** — Use Azure Monitor alerts on the source server's availability metric.
2. **Promote replica** — When a regional outage is detected, promote the cross-region replica.
3. **DNS / connection string update** — Update your application's connection string to point to the promoted server. Consider using Azure Traffic Manager or Azure DNS with low TTLs.
4. **Re-establish replication** — Create a new read replica from the promoted server for continued DR coverage.

### Cost Considerations

| Component | Approximate Monthly Cost |
|---|---|
| Source: General Purpose B2ms (2 vCores) | ~$50/mo |
| Replica: General Purpose B2ms (2 vCores) | ~$50/mo |
| Storage: 32 GiB × 2 servers | ~$8/mo |
| **Total** | **~$108/mo** |

### Comparison with Azure SQL

| Feature | Azure SQL | MySQL Flexible Server |
|---|---|---|
| Automatic failover | ✅ Failover Groups | ❌ Manual promotion |
| DNS alias switching | ✅ Listener endpoints | ❌ Must update connection strings |
| Read replicas | ✅ (via geo-replication) | ✅ (binlog replication) |
| Max replicas | 4 geo-replicas | 10 read replicas |
| RPO | Near-zero | Depends on replication lag |

---

## Useful Links

* 📖 [Read replicas in Azure Database for MySQL – Flexible Server](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-read-replicas)
* 📖 [Manage read replicas – Azure CLI](https://learn.microsoft.com/cli/azure/mysql/flexible-server/replica)
* 📖 [Geo-replication for MySQL Flexible Server](https://techcommunity.microsoft.com/blog/adformysql/read-replica-in-geo-paired-regions---general-availability/3834224)
* 📖 [High availability concepts](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-high-availability)

---
