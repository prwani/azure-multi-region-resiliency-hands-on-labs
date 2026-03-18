---
layout: default
title: "Lab 3: Azure SQL Database – Geo-Replication &amp; Failover"
---

[← Back to Index](../index.md)

# Lab 3: Azure SQL Database – Geo-Replication & Failover

## Introduction

Your application's compute layer may span multiple regions, but if the database
lives in a single region, a regional outage will still bring everything down.
Azure SQL Database offers two complementary features that address this risk:

| Feature | What it does |
|---|---|
| **Active Geo-Replication** | Maintains an asynchronous, readable secondary replica in another region. You control when (and whether) to failover. |
| **Failover Groups** | Wraps geo-replication with **automatic DNS endpoint switching**. Your application connects to a stable listener FQDN that follows the primary role — no connection-string changes required during failover. |

### Why does this matter?

* **Near-zero RPO** — Asynchronous replication lag is typically under 5 seconds
  in normal conditions, so very little data is at risk.
* **Automatic failover** — With a Failover Group in `Automatic` policy mode,
  Azure detects region-level failures and promotes the secondary without human
  intervention.
* **Read scale-out** — The secondary is readable, so you can offload reporting
  and analytics queries to `<fg-name>.secondary.database.windows.net`.
* **Connection transparency** — Applications keep using the same read-write
  and read-only listener endpoints before and after failover.

---

## Architecture

The following diagram shows the target topology you will build in this lab.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Failover Group                                     │
│                   fg-multiregion-sql.database.windows.net  (read-write)     │
│            fg-multiregion-sql.secondary.database.windows.net  (read-only)   │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
┌──────────────────────────┐          ┌──────────────────────────┐
│   Sweden Central (swc)   │          │   Norway East (noe)      │
│                          │          │                          │
│  ┌────────────────────┐  │          │  ┌────────────────────┐  │
│  │  sql-dr-swc        │  │  Async   │  │  sql-dr-noe        │  │
│  │  (Primary Server)  │◄─┼──Geo-Rep─┼─►│  (Secondary Server)│  │
│  │                    │  │          │  │                    │  │
│  │  ┌──────────────┐  │  │          │  │  ┌──────────────┐  │  │
│  │  │ sqldb-sample │  │  │          │  │  │ sqldb-sample │  │  │
│  │  │ (read-write) │  │  │          │  │  │ (read-only)  │  │  │
│  │  └──────────────┘  │  │          │  │  └──────────────┘  │  │
│  └────────────────────┘  │          │  └────────────────────┘  │
│                          │          │                          │
│  rg-dr-swc               │          │  rg-dr-noe               │
└──────────────────────────┘          └──────────────────────────┘
```

**Data flow:**

1. Applications connect to the **read-write listener**
   (`fg-multiregion-sql.database.windows.net`), which resolves to the current
   primary server.
2. Writes are asynchronously replicated to the secondary server in Norway East.
3. Read-only workloads can connect to the **read-only listener**
   (`fg-multiregion-sql.secondary.database.windows.net`).
4. On failover (manual or automatic), the DNS records swap — the read-write
   listener now resolves to Norway East.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.50 or later. Run `az --version` to check. |
| **Azure subscription** | A subscription where you can create SQL servers and databases. |
| **Basic SQL knowledge** | Familiarity with `CREATE TABLE`, `INSERT`, and `SELECT` statements. |
| **`sqlcmd` (optional)** | The [go-sqlcmd](https://learn.microsoft.com/sql/tools/sqlcmd/go-sqlcmd-utility) CLI or SSMS for querying databases directly. If unavailable you can use the Azure Portal query editor. |
| **Your public IP** | Needed for firewall rules. Run `curl -s https://ifconfig.me` to retrieve it. |

> **Tip:** If you completed Lab 1 or Lab 2 you already have the CLI and
> subscription ready.

---

## Step 1 — Define variables

Set shell variables that the remaining commands reference. Adjust the password to
meet the Azure SQL complexity requirements (minimum 8 characters, upper + lower +
digit + special character).

```azurecli
# ── Regions ──
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

# ── Resource groups ──
PRIMARY_RG="rg-dr-swc"
SECONDARY_RG="rg-dr-noe"

# ── SQL Server names (must be globally unique) ──
PRIMARY_SERVER="sql-dr-swc"
SECONDARY_SERVER="sql-dr-noe"

# ── Credentials ──
SQL_ADMIN_USER="sqladmin"
SQL_ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"   # Change or store securely

# ── Database ──
DB_NAME="sqldb-sample"

# ── Failover group ──
FG_NAME="fg-multiregion-sql"

# ── Your public IP (for firewall rules) ──
MY_IP=$(curl -s https://ifconfig.me)

echo "Primary region   : $PRIMARY_REGION"
echo "Secondary region : $SECONDARY_REGION"
echo "Admin user       : $SQL_ADMIN_USER"
echo "Admin password   : $SQL_ADMIN_PASSWORD   (save this!)"
echo "Client IP        : $MY_IP"
```

> **⚠ Caution:** The admin credentials **must be identical** on both the primary
> and secondary servers. Failover Groups require matching logins.

---

## Step 2 — Create resource groups

Create a resource group in each region to keep resources isolated and easy to
clean up.

```azurecli
az group create \
  --name $PRIMARY_RG \
  --location $PRIMARY_REGION \
  --output table

az group create \
  --name $SECONDARY_RG \
  --location $SECONDARY_REGION \
  --output table
```

Expected output — two resource groups in `Succeeded` state.

---

## Step 3 — Create the primary SQL Server

```azurecli
az sql server create \
  --name $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --location $PRIMARY_REGION \
  --admin-user $SQL_ADMIN_USER \
  --admin-password $SQL_ADMIN_PASSWORD \
  --output table
```

This creates a logical SQL Server in Sweden Central. No databases exist yet.

---

## Step 4 — Configure firewall on the primary server

Azure SQL servers deny all external connections by default. Add a rule for your
client IP so you can connect later.

```azurecli
az sql server firewall-rule create \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --name "AllowMyIP" \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP \
  --output table
```

> **Note:** If you also need Azure services (e.g., App Service) to reach the
> server, add the special `0.0.0.0` rule:
>
> ```azurecli
> az sql server firewall-rule create \
>   --server $PRIMARY_SERVER \
>   --resource-group $PRIMARY_RG \
>   --name "AllowAzureServices" \
>   --start-ip-address 0.0.0.0 \
>   --end-ip-address 0.0.0.0
> ```

---

## Step 5 — Create the sample database

Create a small database on the **S0** (Standard, 10 DTUs) tier. This keeps costs
low while still supporting geo-replication.

```azurecli
az sql db create \
  --name $DB_NAME \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --service-objective S0 \
  --output table
```

Verify the database is online:

```azurecli
az sql db show \
  --name $DB_NAME \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --query "{Name:name, Status:status, Location:location, Tier:currentServiceObjectiveName}" \
  --output table
```

---

## Step 6 — Populate with sample data

Use `sqlcmd` (or the Azure Portal **Query editor**) to create a table and insert
a few rows. These rows will replicate to the secondary and confirm the replication
link is working.

```azurecli
# Using go-sqlcmd (sqlcmd v2)
sqlcmd \
  -S "$PRIMARY_SERVER.database.windows.net" \
  -d $DB_NAME \
  -U $SQL_ADMIN_USER \
  -P $SQL_ADMIN_PASSWORD \
  -Q "
    CREATE TABLE dbo.Products (
        ProductId   INT PRIMARY KEY IDENTITY(1,1),
        ProductName NVARCHAR(100) NOT NULL,
        Price       DECIMAL(10,2) NOT NULL,
        CreatedAt   DATETIME2 DEFAULT SYSUTCDATETIME()
    );

    INSERT INTO dbo.Products (ProductName, Price) VALUES
        (N'Widget A',  9.99),
        (N'Widget B', 19.99),
        (N'Widget C', 29.99),
        (N'Widget D', 39.99),
        (N'Widget E', 49.99);

    SELECT * FROM dbo.Products;
  "
```

> **Alternative — Azure Portal:** Navigate to the database in the portal, open
> **Query editor (preview)**, authenticate with the SQL admin credentials, and
> run the SQL above.

You should see five rows returned.

---

## Step 7 — Create the secondary SQL Server

Create a second logical SQL Server in **Norway East**. The admin credentials
**must match** the primary server.

```azurecli
az sql server create \
  --name $SECONDARY_SERVER \
  --resource-group $SECONDARY_RG \
  --location $SECONDARY_REGION \
  --admin-user $SQL_ADMIN_USER \
  --admin-password $SQL_ADMIN_PASSWORD \
  --output table
```

---

## Step 8 — Configure firewall on the secondary server

Firewall rules are **per-server** — they are not replicated automatically. Add
the same client-IP rule to the secondary so you can query it after failover.

```azurecli
az sql server firewall-rule create \
  --server $SECONDARY_SERVER \
  --resource-group $SECONDARY_RG \
  --name "AllowMyIP" \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP \
  --output table
```

---

## Step 9 — Set up Active Geo-Replication

Create a geo-replica of the sample database on the secondary server. Azure will
seed the secondary asynchronously from the primary.

```azurecli
az sql db replica create \
  --name $DB_NAME \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --partner-server $SECONDARY_SERVER \
  --partner-resource-group $SECONDARY_RG \
  --output table
```

This command may take a few minutes while the initial seeding completes.

---

## Step 10 — Verify the replication link

Check that the replication link is established and in a `CATCH_UP` or `SEEDING`
state.

```azurecli
az sql db replica list-links \
  --name $DB_NAME \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --output table
```

Expected output includes:

| Column | Value |
|---|---|
| `partnerServer` | `sql-dr-noe` |
| `partnerLocation` | `Norway East` |
| `role` | `Primary` |
| `partnerRole` | `Secondary` |
| `replicationState` | `CATCH_UP` |

> **Tip:** If the state shows `SEEDING`, wait a minute and re-run the command.
> The link will transition to `CATCH_UP` once initial seeding is complete.

---

## Step 11 — Create a Failover Group

A Failover Group wraps one or more geo-replicated databases with automatic DNS
endpoint switching. This is the recommended approach for production because
applications use stable listener endpoints and don't need connection-string
changes during failover.

```azurecli
az sql failover-group create \
  --name $FG_NAME \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --partner-server $SECONDARY_SERVER \
  --partner-resource-group $SECONDARY_RG \
  --add-db $DB_NAME \
  --failover-policy Automatic \
  --grace-period 60 \
  --output table
```

**Parameters explained:**

| Parameter | Purpose |
|---|---|
| `--failover-policy Automatic` | Azure will automatically failover if the primary region is unavailable. Use `Manual` if you want full control. |
| `--grace-period 60` | Wait 60 minutes before triggering auto-failover. This avoids false positives from transient outages. Minimum is 1 hour for automatic policy. |
| `--add-db` | Databases to include in the group. You can add more later with `az sql failover-group update`. |

---

## Step 12 — Show Failover Group endpoints

Retrieve the listener endpoints that your application should use.

```azurecli
az sql failover-group show \
  --name $FG_NAME \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --query "{
    Name: name,
    PrimaryServer: partnerServers[0].id,
    ReadWriteEndpoint: readWriteEndpoint.failoverPolicy,
    GracePeriod: readWriteEndpoint.failoverWithDataLossGracePeriodMinutes,
    ReplicationRole: replicationRole
  }" \
  --output table
```

The two listener FQDNs are:

| Listener | FQDN |
|---|---|
| **Read-Write** | `fg-multiregion-sql.database.windows.net` |
| **Read-Only** | `fg-multiregion-sql.secondary.database.windows.net` |

> **Key insight:** These FQDNs are **role-based**, not server-based. After a
> failover the read-write FQDN will resolve to whichever server is currently
> primary.

---

## Step 13 — Validate: Query the read-write endpoint

Connect through the **Failover Group read-write listener** to confirm that it
routes to the current primary (Sweden Central).

```azurecli
sqlcmd \
  -S "$FG_NAME.database.windows.net" \
  -d $DB_NAME \
  -U $SQL_ADMIN_USER \
  -P $SQL_ADMIN_PASSWORD \
  -Q "
    SELECT @@SERVERNAME AS CurrentServer,
           DB_NAME()     AS DatabaseName,
           COUNT(*)      AS ProductCount
    FROM dbo.Products;
  "
```

Expected result: `CurrentServer` is `sql-dr-swc`.

---

## Step 14 — Validate: Query the read-only endpoint

Connect through the **read-only listener** to confirm the secondary is readable
and data has replicated.

```azurecli
sqlcmd \
  -S "$FG_NAME.secondary.database.windows.net" \
  -d $DB_NAME \
  -U $SQL_ADMIN_USER \
  -P $SQL_ADMIN_PASSWORD \
  -Q "
    SELECT @@SERVERNAME AS CurrentServer,
           DB_NAME()     AS DatabaseName,
           COUNT(*)      AS ProductCount
    FROM dbo.Products;
  "
```

Expected result: `CurrentServer` is `sql-dr-noe` and `ProductCount` is `5`.

> **Congratulations!** Both endpoints are working and data is replicated across
> two regions.

---

## Step 15 — Initiate manual failover

Simulate a region failover by promoting the secondary server (Norway East) to
primary.

```azurecli
az sql failover-group set-primary \
  --name $FG_NAME \
  --server $SECONDARY_SERVER \
  --resource-group $SECONDARY_RG \
  --output table
```

This performs a **planned failover** — it waits for all pending transactions to
replicate before switching roles, so there is **zero data loss**.

> **Note:** A planned failover typically completes in under 30 seconds. An
> unplanned (forced) failover can be triggered with the `--allow-data-loss`
> flag — use this only when the primary is unreachable and you accept potential
> data loss.

---

## Step 16 — Verify roles have swapped

After failover, confirm that Norway East is now the primary.

```azurecli
# Check failover group status
az sql failover-group show \
  --name $FG_NAME \
  --server $SECONDARY_SERVER \
  --resource-group $SECONDARY_RG \
  --query "{
    Name: name,
    ReplicationRole: replicationRole,
    PartnerRole: partnerServers[0].replicationRole
  }" \
  --output table
```

You should see:

| Field | Value |
|---|---|
| `ReplicationRole` | `Primary` |
| `PartnerRole` | `Secondary` |

Now query the read-write endpoint again:

```azurecli
sqlcmd \
  -S "$FG_NAME.database.windows.net" \
  -d $DB_NAME \
  -U $SQL_ADMIN_USER \
  -P $SQL_ADMIN_PASSWORD \
  -Q "SELECT @@SERVERNAME AS CurrentServer;"
```

The `CurrentServer` should now return `sql-dr-noe` — the DNS has switched
transparently.

---

## Step 17 — (Optional) Fail back to Sweden Central

If you want to restore the original topology, fail back by targeting the
original primary server.

```azurecli
az sql failover-group set-primary \
  --name $FG_NAME \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --output table
```

Verify:

```azurecli
az sql failover-group show \
  --name $FG_NAME \
  --server $PRIMARY_SERVER \
  --resource-group $PRIMARY_RG \
  --query "{ReplicationRole: replicationRole}" \
  --output table
```

`ReplicationRole` should be `Primary` again.

---

## Cleanup

Delete the resource groups to remove all resources created in this lab. Deleting
the resource groups also removes the servers, databases, firewall rules, and the
failover group.

```azurecli
# Delete both resource groups (no confirmation prompt)
az group delete --name $PRIMARY_RG  --yes --no-wait
az group delete --name $SECONDARY_RG --yes --no-wait

echo "Cleanup initiated. Resources will be deleted in the background."
```

> **Tip:** The `--no-wait` flag returns immediately. Actual deletion may take a
> few minutes. You can monitor progress with:
>
> ```azurecli
> az group show --name $PRIMARY_RG --query "properties.provisioningState" 2>/dev/null || echo "Deleted"
> ```

---

## Discussion

### Active Geo-Replication vs. Failover Groups

| Aspect | Active Geo-Replication | Failover Groups |
|---|---|---|
| **DNS management** | Manual — you update connection strings | Automatic — listener FQDNs follow the primary role |
| **Failover trigger** | Manual only (`az sql db replica set-primary`) | Manual or Automatic (policy-based) |
| **Multiple databases** | Managed individually | Grouped — all databases fail over together |
| **Read-only endpoint** | Yes (connect directly to secondary) | Yes (via `.secondary` listener) |
| **Recommended for** | Fine-grained control, non-critical workloads | Production workloads needing automatic failover |

**Recommendation:** Use **Failover Groups** for most production scenarios. Use
standalone Active Geo-Replication only when you need per-database failover
control or when Failover Groups are not supported (e.g., certain Hyperscale
configurations).

### RPO & RTO expectations

| Metric | Typical value | Notes |
|---|---|---|
| **RPO (Recovery Point Objective)** | ~5 seconds | Async replication; under heavy write load the lag can increase |
| **RTO (Recovery Time Objective)** | < 30 seconds (planned) | Automatic failover may take up to the grace period (default 60 min) before initiating |
| **Automatic failover grace period** | 1–360 minutes | Controls how long Azure waits to confirm the outage is sustained before promoting the secondary |

> **⚠ Caution:** The grace period for automatic failover is measured in
> **minutes**, not seconds. A 60-minute grace period means Azure waits up to
> one hour before triggering automatic failover. Set this value based on your
> application's tolerance for downtime versus the risk of false positives.

### Azure SQL Managed Instance differences

Failover Groups are also available for **Azure SQL Managed Instance**, but with
some differences:

* The secondary instance must be in a different region and a different virtual
  network.
* A VNet peering or VPN/ExpressRoute connection is required between the two
  virtual networks.
* The failover group manages **all** user databases on the instance (you cannot
  select individual databases).
* The listener endpoint pattern is different:
  `<fg-name>.database.windows.net` (same) but the port and connection approach
  may vary with private endpoints.

### Auto-failover policy considerations

| Policy | Behavior | Use when |
|---|---|---|
| `Automatic` | Azure promotes the secondary after the grace period expires | You want hands-off DR for sustained regional outages |
| `Manual` | No automatic failover; you must run `az sql failover-group set-primary` | You need human-in-the-loop decision making, or the application has complex failover orchestration |

**Best practice for production:**

1. Set `--failover-policy Automatic` with a grace period between 60 and 120
   minutes.
2. Ensure firewall rules, logins, and users are synchronized on both servers.
3. Test failover regularly (quarterly at minimum) during maintenance windows.
4. Monitor replication lag with `sys.dm_geo_replication_link_status` or Azure
   Monitor alerts.

### Monitoring replication health

You can query the replication status directly from the primary database:

```sql
SELECT
    partner_server,
    partner_database,
    replication_state_desc,
    last_replication,
    replication_lag_sec
FROM sys.dm_geo_replication_link_status;
```

Set up Azure Monitor alerts on the `replication_lag_sec` metric to get notified
when lag exceeds your RPO threshold.

---

## Key takeaways

1. **Active Geo-Replication** provides a readable secondary with near-zero RPO.
2. **Failover Groups** add automatic DNS management and policy-based failover on
   top of geo-replication.
3. Admin credentials **must match** on both servers for Failover Groups to work.
4. Firewall rules are **per-server** — remember to configure both servers.
5. The **grace period** for automatic failover is your trade-off between
   minimizing downtime and avoiding false positives.
6. Always **test failover** before you need it in a real outage.

---

## Additional resources

* [Active Geo-Replication overview](https://learn.microsoft.com/azure/azure-sql/database/active-geo-replication-overview)
* [Failover Groups overview](https://learn.microsoft.com/azure/azure-sql/database/failover-group-sql-db)
* [Configure Failover Group — Tutorial](https://learn.microsoft.com/azure/azure-sql/database/failover-group-configure-sql-db)
* [Business continuity overview](https://learn.microsoft.com/azure/azure-sql/database/business-continuity-high-availability-disaster-recover-hadr-overview)
* [sys.dm_geo_replication_link_status](https://learn.microsoft.com/sql/relational-databases/system-dynamic-management-views/sys-dm-geo-replication-link-status-azure-sql-database)

---

[← Back to Index](../index.md) · [Next: Lab 4 — Azure Cosmos DB Global Distribution →](lab-04-cosmos-global-distribution.md)
