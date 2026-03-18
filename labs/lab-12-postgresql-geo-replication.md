---
layout: default
title: "Lab 12: Azure Database for PostgreSQL – Cross-Region Read Replica"
---

[← Back to Index](../index.md)

# Lab 12: Azure Database for PostgreSQL – Cross-Region Read Replica

## Introduction

Azure Database for PostgreSQL Flexible Server is the recommended managed PostgreSQL service on Azure. It supports **cross-region read replicas** using PostgreSQL's native streaming replication (WAL-based), enabling disaster recovery, read scale-out, and data locality across Azure regions.

| Feature | Detail |
|---|---|
| **Read Replicas** | Up to 5 asynchronous replicas per source server |
| **Cross-Region Support** | Replicas can be placed in any supported Azure region |
| **Replication Method** | PostgreSQL WAL (Write-Ahead Log) streaming replication |
| **Promotion** | A replica can be promoted to a standalone read-write server (irreversible) |
| **Read Scale-Out** | Offload reporting, analytics, and BI queries to read replicas |
| **Virtual Endpoints** | Writer and reader virtual endpoints for simplified connection management |

### Why Cross-Region Read Replicas?

* **Disaster Recovery** — If the primary region becomes unavailable, promote the cross-region replica to a standalone server.
* **Read Latency Reduction** — Place a read replica closer to your users to reduce latency for read-heavy workloads.
* **Analytics Isolation** — Run expensive analytical queries against a replica without impacting production write performance.
* **Compliance** — Maintain a copy of data in a specific region for regulatory purposes.

### Key Differences from MySQL

| Aspect | PostgreSQL Flexible Server | MySQL Flexible Server |
|---|---|---|
| Replication mechanism | WAL streaming (physical) | Binlog (logical) |
| Max read replicas | 5 | 10 |
| Virtual endpoints | ✅ Writer + Reader endpoints | ❌ Not available |
| Tier requirement | General Purpose or Memory Optimized | General Purpose or Memory Optimized |
| Promotion | Stop replication → standalone | Stop replication → standalone |

> **Key takeaway:** PostgreSQL Flexible Server's **virtual endpoints** provide a writer endpoint that always points to the current primary — offering some of the connection-string stability that MySQL lacks. However, cross-region failover promotion is still a manual operation.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│   ┌──────────────────────────┐          ┌──────────────────────────┐    │
│   │   Sweden Central         │          │   Norway East            │    │
│   │                          │          │                          │    │
│   │  ┌────────────────────┐  │  Async   │  ┌────────────────────┐  │    │
│   │  │ pgsql-dr-swc-xxxxx │  │   WAL    │  │ pgsql-dr-noe-xxxxx │  │    │
│   │  │ (Source Server)    │──┼──Stream──►│  │ (Read Replica)     │  │    │
│   │  │                    │  │          │  │                    │  │    │
│   │  │ • Read + Write     │  │          │  │ • Read-only        │  │    │
│   │  │ • sampledb         │  │          │  │ • sampledb (copy)  │  │    │
│   │  └────────────────────┘  │          │  └────────────────────┘  │    │
│   │                          │          │                          │    │
│   │  rg-pgsql-dr-swc         │          │  rg-pgsql-dr-noe         │    │
│   └──────────────────────────┘          └──────────────────────────┘    │
│                                                                          │
│   Virtual Endpoints (optional):                                         │
│   • Writer: <account>.writer.postgres.database.azure.com                │
│   • Reader: <account>.reader.postgres.database.azure.com                │
│                                                                          │
│   On failover (manual):                                                 │
│   1. Promote replica → standalone read-write server                     │
│   2. Update application connection strings (or virtual endpoint swings) │
│   3. (Optional) Create new replica from promoted server                 │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.60 or later (`az --version`) |
| **Azure subscription** | With permissions to create PostgreSQL Flexible Servers |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash |
| **psql client** _(optional)_ | For direct database queries. Install via `sudo apt install postgresql-client` |

---

## Step 1 — Set Variables

```bash
# Unique suffix
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)

# Regions
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

# Resource groups
RG_PRIMARY="rg-pgsql-dr-swc"
RG_SECONDARY="rg-pgsql-dr-noe"

# Server names (globally unique)
PRIMARY_SERVER="pgsql-dr-swc-${RANDOM_SUFFIX}"
REPLICA_SERVER="pgsql-dr-noe-${RANDOM_SUFFIX}"

# Credentials
ADMIN_USER="pgadmin"
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

## Step 3 — Create the Source PostgreSQL Flexible Server

Create a General Purpose tier server in Sweden Central.

```bash
az postgres flexible-server create \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --location $PRIMARY_REGION \
  --admin-user $ADMIN_USER \
  --admin-password $ADMIN_PASSWORD \
  --sku-name Standard_B2ms \
  --tier GeneralPurpose \
  --storage-size 32 \
  --version 16 \
  --public-access 0.0.0.0 \
  --output table
```

Verify the server is ready:

```bash
az postgres flexible-server show \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query "{Name:name, State:state, Location:location, SKU:sku.name, Version:version}" \
  --output table
```

---

## Step 4 — Create a Sample Database and Table

```bash
az postgres flexible-server db create \
  --server-name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --database-name $DB_NAME \
  --output table
```

If you have the `psql` client installed, connect and create sample data:

```bash
export PGPASSWORD="$ADMIN_PASSWORD"
psql -h "${PRIMARY_SERVER}.postgres.database.azure.com" \
  -U $ADMIN_USER -d $DB_NAME <<'SQL'
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    region VARCHAR(50) DEFAULT 'swedencentral',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO orders (customer_name, product, amount) VALUES
    ('Alice',   'Azure VM',           149.99),
    ('Bob',     'Azure Storage',       29.99),
    ('Charlie', 'Azure Functions',     49.99),
    ('Diana',   'Azure Cosmos DB',    199.99),
    ('Eve',     'Azure Key Vault',     19.99);

SELECT * FROM orders;
SQL
```

---

## Step 5 — Create a Cross-Region Read Replica

Create an asynchronous read replica in Norway East using PostgreSQL WAL streaming:

```bash
az postgres flexible-server replica create \
  --replica-name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --source-server $PRIMARY_SERVER \
  --location $SECONDARY_REGION \
  --output table
```

> **Note:** This command may take 15-20 minutes. PostgreSQL performs a base backup of the source server, transfers it to the replica region, and then begins WAL streaming replication.

---

## Step 6 — Verify the Replica

```bash
az postgres flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query "{Name:name, State:state, Location:location, ReplicationRole:replicationRole, SourceServer:sourceServerResourceId}" \
  --output table
```

Expected output:

| Name | State | Location | ReplicationRole | SourceServer |
|---|---|---|---|---|
| pgsql-dr-noe-xxxxx | Ready | Norway East | AsyncReplica | /subscriptions/.../pgsql-dr-swc-xxxxx |

---

## Step 7 — List All Replicas

```bash
az postgres flexible-server replica list \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query "[].{Name:name, Location:location, State:state, Role:replicationRole}" \
  --output table
```

---

## Step 8 — Verify Data Replication

Connect to the **replica** and verify data has been replicated:

```bash
export PGPASSWORD="$ADMIN_PASSWORD"
psql -h "${REPLICA_SERVER}.postgres.database.azure.com" \
  -U $ADMIN_USER -d $DB_NAME \
  -c "SELECT * FROM orders;"
```

You should see all 5 rows. The replica is **read-only** — any write attempt will fail.

---

## Step 9 — Monitor Replication Lag

```bash
az postgres flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query "{Name:name, ReplicationRole:replicationRole, State:state}" \
  --output table
```

> **Tip:** In the Azure Portal, navigate to the replica → Monitoring → Metrics → "Max Physical Replication Lag" and "Read Replica Lag" for real-time monitoring.

---

## Step 10 — Promote the Replica (Simulate Failover)

Promoting a replica disconnects it from the source and converts it to a standalone read-write server. **This action is irreversible.**

```bash
az postgres flexible-server replica stop-replication \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --yes \
  --output table
```

Verify the replica is now standalone:

```bash
az postgres flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query "{Name:name, State:state, ReplicationRole:replicationRole}" \
  --output table
```

Expected: `ReplicationRole` should now be `None`.

---

## Step 11 — Validate Write Access on Promoted Server

```bash
export PGPASSWORD="$ADMIN_PASSWORD"
psql -h "${REPLICA_SERVER}.postgres.database.azure.com" \
  -U $ADMIN_USER -d $DB_NAME \
  -c "INSERT INTO orders (customer_name, product, amount, region) VALUES ('Frank', 'Failover Test', 99.99, 'norwayeast'); SELECT * FROM orders;"
```

---

## Step 12 — (Optional) Virtual Endpoints

PostgreSQL Flexible Server supports **virtual endpoints** that provide stable connection points:

| Endpoint Type | Purpose | Behavior |
|---|---|---|
| **Writer** | Always routes to current primary | Follows promotions |
| **Reader** | Routes to read replicas | Load-balances across replicas |

```bash
# Create a writer virtual endpoint
az postgres flexible-server virtual-endpoint create \
  --name writer-endpoint \
  --server-name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --endpoint-type ReadWrite \
  --members $REPLICA_SERVER \
  --output table
```

> **Note:** Virtual endpoints are a newer feature and may have limited availability. Check the Azure documentation for current region support.

---

## Step 13 — Cleanup

> ⚠️ **Skip this step if you want to keep resources for portal verification.**

```bash
az group delete --name $RG_PRIMARY   --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

---

## Discussion & Next Steps

### Failover Strategy

PostgreSQL Flexible Server's cross-region failover is similar to MySQL's approach:

1. **Monitor** — Set up Azure Monitor alerts on server availability and replication lag.
2. **Promote** — Stop replication on the cross-region replica to make it writable.
3. **Redirect** — Update application connection strings (or rely on virtual endpoints if configured).
4. **Re-protect** — Create a new read replica from the promoted server for continued DR coverage.

### Cost Considerations

| Component | Approximate Monthly Cost |
|---|---|
| Source: General Purpose B2ms (2 vCores) | ~$55/mo |
| Replica: General Purpose B2ms (2 vCores) | ~$55/mo |
| Storage: 32 GiB × 2 servers | ~$8/mo |
| **Total** | **~$118/mo** |

### Comparison: PostgreSQL vs MySQL vs Azure SQL

| Feature | Azure SQL | MySQL Flexible | PostgreSQL Flexible |
|---|---|---|---|
| Automatic failover | ✅ Failover Groups | ❌ Manual | ❌ Manual |
| DNS alias switching | ✅ Listener endpoints | ❌ | ⚠️ Virtual endpoints |
| Replication | Synchronous + async | Async (binlog) | Async (WAL streaming) |
| Max replicas | 4 geo-replicas | 10 | 5 |
| RPO | Near-zero | Replication lag | Replication lag |
| Promotion | Automatic or manual | Manual (irreversible) | Manual (irreversible) |

---

## Useful Links

* 📖 [Read replicas in Azure Database for PostgreSQL – Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-read-replicas)
* 📖 [Geo-replication concepts](https://learn.microsoft.com/azure/postgresql/read-replica/concepts-read-replicas-geo)
* 📖 [Manage read replicas – Azure CLI](https://learn.microsoft.com/cli/azure/postgres/flexible-server/replica)
* 📖 [Virtual endpoints](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-read-replicas-virtual-endpoints)
* 📖 [High availability overview](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-high-availability)

---
