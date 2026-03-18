---
layout: default
title: "Lab 4: Azure Cosmos DB – Global Distribution"
---

[← Back to Index](../index.md)

# Lab 4: Azure Cosmos DB – Global Distribution

## Introduction

Azure Cosmos DB is Microsoft's globally distributed, multi-model database service
designed for mission-critical applications. Unlike traditional databases that
require complex replication pipelines and custom conflict-resolution code,
Cosmos DB offers **turnkey global distribution** — you can add or remove regions
with a single click or CLI command, and your data is automatically replicated.

### Why Cosmos DB Global Distribution Matters

| Capability | Benefit |
|---|---|
| **Turnkey global distribution** | Add/remove Azure regions at any time with zero downtime |
| **Multi-region writes (active-active)** | Every region can accept writes, minimising latency for globally distributed users |
| **Five tunable consistency levels** | Choose the exact trade-off between consistency, availability, latency, and throughput |
| **Automatic & manual failover** | The platform detects failures and re-routes traffic; you can also trigger failover on demand |
| **99.999 % read availability SLA** | With multi-region configuration, Cosmos DB offers an industry-leading availability SLA |
| **Transparent multi-homing** | SDKs automatically route requests to the nearest available region |

In this lab you will:

1. Create a Cosmos DB for NoSQL account in **Sweden Central**.
2. Add **Norway East** as a secondary read region.
3. Enable **multi-region writes** for an active-active topology.
4. Create a database, container, and insert sample documents.
5. Verify that data is readable from both regions.
6. Enable **automatic failover** and perform a **manual failover**.
7. Confirm the account remains operational after failover.
8. Fail back to the original primary region.
9. Clean up all resources.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Cosmos DB Account                                │
│                  (cosmos-multiregion-XXXXX)                              │
│                                                                         │
│   Global Endpoint ───────────────────────────────────────────────────   │
│   cosmos-multiregion-XXXXX.documents.azure.com                          │
│       │                                                                 │
│       ├──────────────────────┐                                          │
│       ▼                      ▼                                          │
│  ┌──────────────────┐  ┌──────────────────┐                             │
│  │  Sweden Central  │  │  Norway East     │                             │
│  │  ──────────────  │  │  ──────────────  │                             │
│  │  Priority: 0     │  │  Priority: 1     │                             │
│  │  Role: Write     │  │  Role: Read      │                             │
│  │  Zone Redundant  │  │  Zone Redundant  │                             │
│  │                  │  │                  │                              │
│  │  ┌────────────┐  │  │  ┌────────────┐  │                             │
│  │  │ Partition  │  │  │  │ Replica    │  │                             │
│  │  │  Set 1     │◄─┼──┼─►│  Set 1     │  │                             │
│  │  └────────────┘  │  │  └────────────┘  │                             │
│  │  ┌────────────┐  │  │  ┌────────────┐  │                             │
│  │  │ Partition  │  │  │  │ Replica    │  │                             │
│  │  │  Set 2     │◄─┼──┼─►│  Set 2     │  │                             │
│  │  └────────────┘  │  │  └────────────┘  │                             │
│  └──────────────────┘  └──────────────────┘                             │
│                                                                         │
│  After enabling multi-region writes:                                    │
│  Both regions become Write + Read (active-active)                       │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                             │
│  │  Sweden Central  │  │  Norway East     │                             │
│  │  Role: Write+Read│  │  Role: Write+Read│                             │
│  │  ◄──── sync ────►│  │                  │                             │
│  └──────────────────┘  └──────────────────┘                             │
└─────────────────────────────────────────────────────────────────────────┘
```

**Key points:**

- The **global endpoint** automatically routes reads to the nearest region.
- With multi-region writes enabled, each region accepts writes locally and
  asynchronously replicates to every other region.
- **Zone redundancy** spreads replicas across availability zones within a
  region at no extra cost.

---

## Prerequisites

- **Azure CLI** v2.60 or later installed and authenticated (`az login`).
- An active **Azure subscription** with permissions to create Cosmos DB accounts.
- **Bash shell** (Azure Cloud Shell, WSL, macOS Terminal, or Git Bash on Windows).

Verify your Azure CLI version:

```azurecli
az --version | head -1
```

Expected output (version may be higher):

```
azure-cli    2.60.0
```

---

## Step 1 — Set Variables

Generate a unique suffix and define all the variables you will use throughout
the lab. Using consistent variable names makes it easy to copy-paste commands.

```azurecli
# Generate a random 5-digit suffix
RANDOM_SUFFIX=$(shuf -i 10000-99999 -n 1)

# Core variables
export RG="rg-cosmos-global-lab"
export LOCATION_PRIMARY="swedencentral"
export LOCATION_SECONDARY="norwayeast"
export COSMOS_ACCOUNT="cosmos-multiregion-${RANDOM_SUFFIX}"
export DATABASE_NAME="db-sample"
export CONTAINER_NAME="container-orders"
export PARTITION_KEY="/customerId"

echo "──────────────────────────────────────────"
echo "Resource Group     : $RG"
echo "Cosmos DB Account  : $COSMOS_ACCOUNT"
echo "Primary Region     : $LOCATION_PRIMARY"
echo "Secondary Region   : $LOCATION_SECONDARY"
echo "Database           : $DATABASE_NAME"
echo "Container          : $CONTAINER_NAME"
echo "Partition Key      : $PARTITION_KEY"
echo "──────────────────────────────────────────"
```

---

## Step 2 — Create the Resource Group

```azurecli
az group create \
  --name $RG \
  --location $LOCATION_PRIMARY \
  --output table
```

Expected output:

```
Location       Name
-------------  ----------------------
swedencentral  rg-cosmos-global-lab
```

---

## Step 3 — Create the Cosmos DB Account (Single Region)

Create a Cosmos DB for NoSQL account in **Sweden Central** with **Session**
consistency and **zone redundancy** enabled.

```azurecli
az cosmosdb create \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --locations regionName=$LOCATION_PRIMARY failoverPriority=0 isZoneRedundant=true \
  --default-consistency-level Session \
  --output table
```

> **Note:** Account creation typically takes 5–10 minutes. Session consistency
> is the most popular level — it guarantees monotonic reads, monotonic writes,
> and read-your-own-writes within a single session.

Verify the account was created:

```azurecli
az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query "{Name:name, Status:provisioningState, Consistency:consistencyPolicy.defaultConsistencyLevel, Locations:readLocations[].locationName}" \
  --output table
```

You should see a single location (`swedencentral`) and `Succeeded` status.

---

## Step 4 — Add Norway East as a Secondary Region

Expand the account to a second region. Both existing and new locations must be
specified in a single `--locations` parameter.

```azurecli
az cosmosdb update \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --locations regionName=$LOCATION_PRIMARY  failoverPriority=0 isZoneRedundant=true \
              regionName=$LOCATION_SECONDARY failoverPriority=1 isZoneRedundant=true \
  --output table
```

> **Tip:** Zone redundancy is free but improves availability within a region by
> spreading replicas across three availability zones. Always enable it when the
> region supports it.

Verify both regions are now listed:

```azurecli
az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query "readLocations[].{Region:locationName, Priority:failoverPriority, ZoneRedundant:isZoneRedundant}" \
  --output table
```

Expected output:

```
Region          Priority    ZoneRedundant
--------------  ----------  ---------------
swedencentral   0           True
norwayeast      1           True
```

---

## Step 5 — Enable Multi-Region Writes

By default, only the primary region accepts writes. Enable multi-region writes
so both regions can serve as write endpoints (active-active).

```azurecli
az cosmosdb update \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --enable-multiple-write-locations true \
  --output table
```

Verify:

```azurecli
az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query "{MultiRegionWrites:enableMultipleWriteLocations}" \
  --output json
```

Expected:

```json
{
  "MultiRegionWrites": true
}
```

> ⚠️ **Caution:** Enabling multi-region writes approximately **doubles your
> RU costs** because every write is replicated to all regions. Evaluate whether
> your workload truly requires writes in every region before enabling this.

---

## Step 6 — Create the Database

Create a database within the Cosmos DB account:

```azurecli
az cosmosdb sql database create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --name $DATABASE_NAME \
  --output table
```

Verify:

```azurecli
az cosmosdb sql database show \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --name $DATABASE_NAME \
  --query "{Database:name, Id:id}" \
  --output table
```

---

## Step 7 — Create the Container

Create a container with a partition key and 400 RU/s throughput:

```azurecli
az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --name $CONTAINER_NAME \
  --partition-key-path $PARTITION_KEY \
  --throughput 400 \
  --output table
```

Verify the container:

```azurecli
az cosmosdb sql container show \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --name $CONTAINER_NAME \
  --query "{Container:name, PartitionKey:resource.partitionKey.paths[0], Throughput:'400 RU/s'}" \
  --output table
```

---

## Step 8 — Insert Sample Documents

Retrieve the primary connection key and insert sample order documents.

```azurecli
# Get the primary key
COSMOS_KEY=$(az cosmosdb keys list \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query "primaryMasterKey" \
  --output tsv)

echo "Primary key retrieved (length: ${#COSMOS_KEY} chars)"
```

Now get the endpoint:

```azurecli
COSMOS_ENDPOINT=$(az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query "documentEndpoint" \
  --output tsv)

echo "Endpoint: $COSMOS_ENDPOINT"
```

Insert three sample order documents using the data-plane CLI commands:

```azurecli
# Document 1
az cosmosdb sql container create-item \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --container-name $CONTAINER_NAME \
  --body '{
    "id": "order-001",
    "customerId": "customer-100",
    "product": "Azure Reserved VM Instance",
    "quantity": 3,
    "region": "swedencentral",
    "status": "confirmed",
    "createdAt": "2024-06-15T10:30:00Z"
  }' \
  --output json

echo "✅ Inserted order-001"
```

```azurecli
# Document 2
az cosmosdb sql container create-item \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --container-name $CONTAINER_NAME \
  --body '{
    "id": "order-002",
    "customerId": "customer-200",
    "product": "Azure Cosmos DB Reserved Capacity",
    "quantity": 1,
    "region": "norwayeast",
    "status": "pending",
    "createdAt": "2024-06-15T11:00:00Z"
  }' \
  --output json

echo "✅ Inserted order-002"
```

```azurecli
# Document 3
az cosmosdb sql container create-item \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --container-name $CONTAINER_NAME \
  --body '{
    "id": "order-003",
    "customerId": "customer-100",
    "product": "Azure Front Door Premium",
    "quantity": 1,
    "region": "swedencentral",
    "status": "shipped",
    "createdAt": "2024-06-15T14:45:00Z"
  }' \
  --output json

echo "✅ Inserted order-003"
```

---

## Step 9 — Query and Verify Data

Run a cross-partition query to verify the documents are stored and readable:

```azurecli
az cosmosdb sql query \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --container-name $CONTAINER_NAME \
  --query-text "SELECT c.id, c.customerId, c.product, c.status FROM c ORDER BY c.createdAt" \
  --output table
```

Expected output:

```
Id         CustomerId     Product                            Status
---------  -------------  ---------------------------------  ---------
order-001  customer-100   Azure Reserved VM Instance          confirmed
order-002  customer-200   Azure Cosmos DB Reserved Capacity   pending
order-003  customer-100   Azure Front Door Premium            shipped
```

You can also filter by partition key:

```azurecli
az cosmosdb sql query \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --container-name $CONTAINER_NAME \
  --partition-key-value "customer-100" \
  --query-text "SELECT c.id, c.product, c.status FROM c WHERE c.customerId = 'customer-100'" \
  --output table
```

> **Validation:** If you see all three documents, Cosmos DB has replicated the
> data to both Sweden Central and Norway East. The global endpoint routes your
> reads to the nearest region automatically.

---

## Step 10 — Enable Automatic Failover

Automatic failover lets Cosmos DB detect regional outages and promote the
secondary region without manual intervention.

```azurecli
az cosmosdb update \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --enable-automatic-failover true \
  --output table
```

Verify:

```azurecli
az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query "{AutomaticFailover:enableAutomaticFailover}" \
  --output json
```

Expected:

```json
{
  "AutomaticFailover": true
}
```

---

## Step 11 — Test Manual Failover

Simulate a regional outage by swapping the failover priorities. This makes
**Norway East** the new primary (write) region.

> ⚠️ **Caution:** Failover priority changes can take **several minutes** to
> complete. Do not cancel the command while it is running.

> **Note:** Before performing a manual failover, you must disable multi-region
> writes. Manual failover is only applicable to single-write-region accounts.

```azurecli
# Disable multi-region writes for manual failover test
az cosmosdb update \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --enable-multiple-write-locations false \
  --output table

echo "Multi-region writes disabled. Proceeding with failover..."
```

```azurecli
# Trigger manual failover: promote Norway East to primary
az cosmosdb failover-priority-change \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --failover-policies norwayeast=0 swedencentral=1 \
  --output table

echo "✅ Manual failover complete"
```

Verify Norway East is now the primary write region:

```azurecli
az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query "writeLocations[].{Region:locationName, Priority:failoverPriority}" \
  --output table
```

Expected output:

```
Region         Priority
-------------  ----------
norwayeast     0
```

---

## Step 12 — Verify Account Still Works After Failover

Query the data again to confirm the account is fully operational with the new
primary region:

```azurecli
az cosmosdb sql query \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --container-name $CONTAINER_NAME \
  --query-text "SELECT c.id, c.product, c.status FROM c ORDER BY c.createdAt" \
  --output table
```

You should see the same three documents, confirming zero data loss during
failover.

---

## Step 13 — Fail Back to Sweden Central

Restore the original topology by setting Sweden Central back to priority 0:

```azurecli
az cosmosdb failover-priority-change \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --failover-policies swedencentral=0 norwayeast=1 \
  --output table

echo "✅ Fail-back complete — Sweden Central is primary again"
```

Re-enable multi-region writes if your workload requires active-active:

```azurecli
az cosmosdb update \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --enable-multiple-write-locations true \
  --output table

echo "Multi-region writes re-enabled"
```

Verify final state:

```azurecli
az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query "{Account:name, WriteLocations:writeLocations[].locationName, ReadLocations:readLocations[].locationName, MultiRegionWrites:enableMultipleWriteLocations, AutoFailover:enableAutomaticFailover, Consistency:consistencyPolicy.defaultConsistencyLevel}" \
  --output json
```

---

## Step 14 — SDK Preferred Regions Configuration

In production, your application SDK should be configured with a **preferred
regions** list so that it routes requests to the nearest region. Here is how
the configuration looks for common SDKs:

### .NET SDK

```csharp
CosmosClientOptions options = new CosmosClientOptions
{
    ApplicationPreferredRegions = new List<string>
    {
        Regions.NorwayEast,      // closest region
        Regions.SwedenCentral    // fallback
    }
};

CosmosClient client = new CosmosClient(endpoint, key, options);
```

### Python SDK

```python
from azure.cosmos import CosmosClient

client = CosmosClient(
    url=endpoint,
    credential=key,
    preferred_locations=["Norway East", "Sweden Central"]
)
```

### Java SDK

```java
CosmosClientBuilder builder = new CosmosClientBuilder()
    .endpoint(endpoint)
    .key(key)
    .preferredRegions(Arrays.asList("Norway East", "Sweden Central"));

CosmosAsyncClient client = builder.buildAsyncClient();
```

> **Tip:** Always specify preferred regions in your SDK configuration. Without
> it, the SDK defaults to the write region for all operations, which may
> increase latency for geographically distant clients.

---

## Cleanup

Remove all resources created in this lab:

```azurecli
az group delete \
  --name $RG \
  --yes \
  --no-wait

echo "🗑️  Resource group '$RG' deletion initiated (runs in background)"
```

Unset shell variables:

```azurecli
unset RG LOCATION_PRIMARY LOCATION_SECONDARY COSMOS_ACCOUNT \
      DATABASE_NAME CONTAINER_NAME PARTITION_KEY COSMOS_KEY COSMOS_ENDPOINT
```

---

## Discussion

### Consistency Levels Deep-Dive

Cosmos DB offers five consistency levels, ordered from strongest to weakest:

| Level | Guarantee | Trade-off |
|---|---|---|
| **Strong** | Linearisable reads; always returns the most recent committed write | Highest latency; **not available** with multi-region writes |
| **Bounded Staleness** | Reads lag behind writes by at most *K* versions or *T* time interval | Good balance for single-region writes with multi-region reads |
| **Session** | Within a session: read-your-writes, monotonic reads/writes | Most popular; default for new accounts |
| **Consistent Prefix** | Reads never see out-of-order writes | Lower latency than Session |
| **Eventual** | No ordering guarantee; lowest latency | Best throughput, acceptable for non-critical reads |

> ⚠️ **Strong consistency is NOT available when multi-region writes are
> enabled.** If your application requires strong consistency, you must use a
> single-write-region topology.

### Multi-Region Write Costs

When you enable multi-region writes:

- **RU consumption approximately doubles** because every write must be
  replicated to all regions synchronously (within the region's quorum) and
  asynchronously to other regions.
- Reads are **not affected** — they are served locally in each region.
- The total storage cost increases proportionally to the number of regions
  (each region stores a full copy of the data).

**Recommendation:** Only enable multi-region writes if you have users in
multiple geographies who need **low-latency writes** from their local region.
For read-heavy workloads, a single-write-region with multiple read regions is
more cost-effective.

### Conflict Resolution Policies

When multi-region writes are enabled, concurrent writes to the same item in
different regions can create conflicts. Cosmos DB provides two resolution
strategies:

1. **Last Writer Wins (LWW)** — Default. The write with the highest value in
   a designated conflict-resolution path (default: `_ts` timestamp) wins. This
   is fully automatic and requires no application code.

2. **Custom (Stored Procedure)** — You register a stored procedure that Cosmos
   DB invokes when a conflict is detected. The procedure receives both versions
   and decides the outcome. Use this when business logic must determine the
   winner (e.g., merging shopping cart items).

```azurecli
# Example: set LWW with a custom path
az cosmosdb sql container update \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $DATABASE_NAME \
  --name $CONTAINER_NAME \
  --conflict-resolution-policy '{"mode":"LastWriterWins","conflictResolutionPath":"/lastModified"}' \
  --output json
```

### When NOT to Use Multi-Region Writes

Multi-region writes add complexity and cost. Avoid them when:

| Scenario | Recommendation |
|---|---|
| Read-heavy workload (>90 % reads) | Single-write region + multiple read regions |
| Application requires **Strong** consistency | Single-write region only |
| Writes originate from a single geography | Single-write region in that geography |
| Budget-constrained workloads | Single-write region to halve write RU costs |
| Data sovereignty requires writes in one region | Single-write region with geo-replication for reads |

### Zone Redundancy vs. Multi-Region

These two resilience features operate at different scopes:

- **Zone redundancy** protects against failures within a single region by
  spreading replicas across three availability zones. It is **free** and should
  always be enabled.
- **Multi-region replication** protects against an entire region going offline.
  It costs additional RU/s (for writes) and storage (full data copy per region).

For maximum resilience, enable **both**: zone-redundant replicas in each region
of a multi-region account.

---

## Summary

In this lab you:

- ✅ Created a Cosmos DB for NoSQL account with zone redundancy in Sweden Central
- ✅ Added Norway East as a secondary read region
- ✅ Enabled multi-region writes for active-active topology
- ✅ Created a database, container, and inserted sample documents
- ✅ Queried and verified data replication across regions
- ✅ Enabled automatic failover
- ✅ Performed a manual failover and verified zero data loss
- ✅ Failed back to the original primary region
- ✅ Discussed consistency levels, costs, and conflict resolution

---

## Key Takeaways

1. **Turnkey global distribution** makes Cosmos DB one of the easiest databases
   to deploy across multiple regions.
2. **Multi-region writes double your RU costs** — use them only when you need
   low-latency writes from multiple geographies.
3. **Zone redundancy is free** — always enable it for higher availability
   within each region.
4. **Strong consistency is not supported** with multi-region writes.
5. **SDK preferred regions** should always be configured so that the client
   routes requests to the nearest available region.
6. **Conflict resolution** defaults to Last Writer Wins but can be customised
   with stored procedures when business logic requires it.
7. **Failover priority changes can take several minutes** — plan for this in
   your disaster recovery runbooks.

---

[← Back to Index](../index.md) | [Next: Lab 5 — Azure Key Vault Multi-Region →](lab-05-key-vault-multi-region.md)
