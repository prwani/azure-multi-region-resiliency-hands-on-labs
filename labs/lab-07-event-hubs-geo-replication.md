---
layout: default
title: "Lab 7: Azure Event Hubs – Geo-Replication Failover"
---

[← Back to Index](../index.md)

# Lab 7: Azure Event Hubs – Geo-Replication Failover

## Introduction

Streaming data ingestion is critical infrastructure for modern applications. Whether you
are collecting IoT telemetry, application logs, clickstream analytics, or financial
transactions, **Azure Event Hubs** often sits at the very front of your data pipeline.
A regional outage that takes Event Hubs offline doesn't just affect one service — it
halts the entire downstream processing chain: stream analytics jobs starve, real-time
dashboards go dark, and events are lost or delayed.

**Geo-Disaster Recovery (Geo-DR)** for Event Hubs addresses this by pairing a primary
namespace in one region with a secondary namespace in another. When paired:

- **Namespace-level metadata** (Event Hub entities, consumer groups, partition
  configurations, authorization rules) is continuously replicated from the primary to
  the secondary.
- A **Geo-DR alias** provides a stable FQDN that producers and consumers connect to.
  During normal operation the alias resolves to the primary namespace. After a failover,
  the alias automatically points to the secondary — **no client configuration changes
  required**.
- The failover operation is a **metadata-only DNS switch**. It completes quickly and
  transparently for clients that reconnect.

> **Important:** Geo-DR replicates *metadata only*, not the event data itself. To
> preserve actual event payloads across regions, combine Geo-DR with **Event Hubs
> Capture** (covered in the Discussion section).

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                        Geo-DR Alias                                  │
│              eh-alias-multiregion.servicebus.windows.net              │
│                                                                      │
│    Producers ──────►  Alias Endpoint  ◄────── Consumers              │
│                           │                                          │
│              ┌────────────┴────────────┐                             │
│              │                         │                             │
│              ▼                         ▼                             │
│   ┌─────────────────────┐   ┌─────────────────────┐                 │
│   │   Primary EH NS     │   │  Secondary EH NS    │                 │
│   │  (Sweden Central)   │   │  (Norway East)      │                 │
│   │                     │   │                     │                 │
│   │  events-telemetry   │──►│  events-telemetry   │                 │
│   │   (2 partitions)    │   │   (2 partitions)    │                 │
│   │  analytics-cg       │──►│  analytics-cg       │                 │
│   │                     │   │                     │                 │
│   │  SAS / Auth Rules   │──►│  SAS / Auth Rules   │                 │
│   └─────────────────────┘   └─────────────────────┘                 │
│                                                                      │
│   ──────► = Metadata replication (continuous, async)                 │
│   During failover the alias DNS swings to the secondary namespace   │
└──────────────────────────────────────────────────────────────────────┘
```

During **normal operation**, the alias resolves to the primary namespace in Sweden
Central. Producers send events and consumers read events through the alias endpoint.

During **failover**, the alias DNS record is updated to point to the secondary namespace
in Norway East. The secondary is promoted to primary, and the pairing is dissolved.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.50+ (`az --version`) |
| **Azure subscription** | With permission to create Event Hubs namespaces |
| **Tier** | **Standard** or **Premium** (Geo-DR is supported on both) |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash |

> **Cost note:** Event Hubs Standard tier supports Geo-DR — unlike Service Bus which
> requires Premium. This makes Event Hubs Geo-DR accessible at a lower price point.

---

## Step-by-Step Instructions

### Step 1 — Set Variables

Generate a short random suffix to ensure globally unique namespace names.

```azurecli
# Random 5-character suffix
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)

# Namespace names
EH_PRIMARY="eh-dr-swc-${RANDOM_SUFFIX}"
EH_SECONDARY="eh-dr-noe-${RANDOM_SUFFIX}"

# Geo-DR alias
EH_ALIAS="eh-alias-multiregion"

# Event Hub entity
EH_NAME="events-telemetry"

# Consumer group
CG_NAME="analytics-cg"

# Resource groups
RG_PRIMARY="rg-eh-primary-swedencentral"
RG_SECONDARY="rg-eh-secondary-norwayeast"

# Regions
LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

echo "Primary namespace : $EH_PRIMARY"
echo "Secondary namespace: $EH_SECONDARY"
echo "Alias              : $EH_ALIAS"
```

---

### Step 2 — Create Resource Groups

Create a resource group in each target region.

```azurecli
# Primary region resource group
az group create \
  --name $RG_PRIMARY \
  --location $LOCATION_PRIMARY \
  --output table

# Secondary region resource group
az group create \
  --name $RG_SECONDARY \
  --location $LOCATION_SECONDARY \
  --output table
```

---

### Step 3 — Create the Primary Event Hubs Namespace

Create the primary namespace with Standard SKU and 1 throughput unit.

```azurecli
az eventhubs namespace create \
  --name $EH_PRIMARY \
  --resource-group $RG_PRIMARY \
  --location $LOCATION_PRIMARY \
  --sku Standard \
  --capacity 1 \
  --output table
```

This provisions a namespace in Sweden Central with 1 TU (1 MB/s ingress, 2 MB/s egress).

---

### Step 4 — Create the Secondary Event Hubs Namespace

The secondary namespace must be in a **different region** and use the **same SKU and
capacity** as the primary.

```azurecli
az eventhubs namespace create \
  --name $EH_SECONDARY \
  --resource-group $RG_SECONDARY \
  --location $LOCATION_SECONDARY \
  --sku Standard \
  --capacity 1 \
  --output table
```

> **Note:** The secondary namespace must be **empty** — it cannot already contain Event
> Hub entities. All entities will be replicated from the primary during pairing.

---

### Step 5 — Create an Event Hub on the Primary Namespace

Create an Event Hub with 2 partitions and 1-day message retention.

```azurecli
az eventhubs eventhub create \
  --name $EH_NAME \
  --namespace-name $EH_PRIMARY \
  --resource-group $RG_PRIMARY \
  --partition-count 2 \
  --message-retention 1 \
  --output table
```

---

### Step 6 — Create a Consumer Group

Add a dedicated consumer group for analytics workloads.

```azurecli
az eventhubs eventhub consumer-group create \
  --name $CG_NAME \
  --eventhub-name $EH_NAME \
  --namespace-name $EH_PRIMARY \
  --resource-group $RG_PRIMARY \
  --output table
```

Verify the consumer group was created:

```azurecli
az eventhubs eventhub consumer-group list \
  --eventhub-name $EH_NAME \
  --namespace-name $EH_PRIMARY \
  --resource-group $RG_PRIMARY \
  --output table
```

You should see both `$Default` and `analytics-cg`.

---

### Step 7 — Retrieve the Secondary Namespace Resource ID

The Geo-DR pairing command requires the **full Azure Resource ID** of the partner
namespace.

```azurecli
SECONDARY_ID=$(az eventhubs namespace show \
  --name $EH_SECONDARY \
  --resource-group $RG_SECONDARY \
  --query id \
  --output tsv)

echo "Secondary namespace resource ID:"
echo "$SECONDARY_ID"
```

---

### Step 8 — Create the Geo-DR Alias (Pairing)

Pair the primary namespace with the secondary namespace using a Geo-DR alias.

```azurecli
az eventhubs georecovery-alias set \
  --resource-group $RG_PRIMARY \
  --namespace-name $EH_PRIMARY \
  --alias $EH_ALIAS \
  --partner-namespace $SECONDARY_ID
```

This operation:
- Creates a new DNS alias: `eh-alias-multiregion.servicebus.windows.net`
- Begins continuous metadata replication from primary → secondary
- The alias initially resolves to the primary namespace

---

### Step 9 — Check Alias Provisioning Status

The pairing may take 1–2 minutes to complete. Poll the status until it shows
`Succeeded`.

```azurecli
# Check provisioning state
az eventhubs georecovery-alias show \
  --resource-group $RG_PRIMARY \
  --namespace-name $EH_PRIMARY \
  --alias $EH_ALIAS \
  --query '{alias: name, role: role, provisioningState: provisioningState, partnerNamespace: partnerNamespace}' \
  --output table
```

Wait until `provisioningState` is `Succeeded` before proceeding.

```azurecli
# Poll until ready (simple loop)
while true; do
  STATE=$(az eventhubs georecovery-alias show \
    --resource-group $RG_PRIMARY \
    --namespace-name $EH_PRIMARY \
    --alias $EH_ALIAS \
    --query provisioningState \
    --output tsv)

  echo "Current state: $STATE"

  if [ "$STATE" == "Succeeded" ]; then
    echo "Geo-DR alias is ready!"
    break
  fi

  sleep 10
done
```

---

### Step 10 — Verify Entities Replicated to Secondary

After the pairing succeeds, all entities (Event Hubs, consumer groups, authorization
rules) are replicated to the secondary namespace.

```azurecli
# List Event Hubs on secondary namespace
az eventhubs eventhub list \
  --namespace-name $EH_SECONDARY \
  --resource-group $RG_SECONDARY \
  --output table
```

You should see `events-telemetry` with the same partition count and retention settings.

```azurecli
# List consumer groups on secondary
az eventhubs eventhub consumer-group list \
  --eventhub-name $EH_NAME \
  --namespace-name $EH_SECONDARY \
  --resource-group $RG_SECONDARY \
  --output table
```

You should see both `$Default` and `analytics-cg` — confirming full metadata
replication.

> **What is replicated:**
> - Event Hub entities (name, partition count, retention)
> - Consumer groups
> - Shared Access Policies and keys
> - Partition configurations
>
> **What is NOT replicated:**
> - Event data (messages/events)
> - Consumer offsets / checkpoints
> - Capture settings (must be configured independently)

---

### Step 11 — Send Test Events to the Alias Endpoint

Producers should always connect to the **alias endpoint** rather than the primary
namespace directly. This ensures seamless failover.

The alias FQDN is:
```
eh-alias-multiregion.servicebus.windows.net
```

Below is a small Python snippet using the `azure-eventhub` SDK to send events:

```python
# send_events.py
# pip install azure-eventhub azure-identity

import os
from azure.eventhub import EventHubProducerClient, EventData

# Use the alias connection string, not the primary namespace directly
ALIAS_CONN_STR = os.environ["EVENTHUB_ALIAS_CONNECTION_STRING"]
EVENT_HUB_NAME = "events-telemetry"

producer = EventHubProducerClient.from_connection_string(
    conn_str=ALIAS_CONN_STR,
    eventhub_name=EVENT_HUB_NAME
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"Pre-failover event {i}"))
    producer.send_batch(batch)
    print(f"Sent {len(batch)} events to alias endpoint (pre-failover)")
```

To get the alias connection string:

```azurecli
# Get the primary connection string for the alias
az eventhubs georecovery-alias authorization-rule keys list \
  --resource-group $RG_PRIMARY \
  --namespace-name $EH_PRIMARY \
  --alias $EH_ALIAS \
  --name RootManageSharedAccessKey \
  --query '{primaryConnectionString: primaryConnectionString}' \
  --output table
```

> **Tip:** Store the alias connection string in your application configuration. Because
> the alias DNS updates during failover, the same connection string works before and
> after failover — no reconfiguration needed.

---

### Step 12 — Initiate Failover

Simulate a disaster by initiating a manual failover. This promotes the secondary
namespace to primary and **breaks the pairing**.

```azurecli
az eventhubs georecovery-alias fail-over \
  --resource-group $RG_SECONDARY \
  --namespace-name $EH_SECONDARY \
  --alias $EH_ALIAS
```

> **⚠️ Failover is a one-way operation.** It:
> 1. Updates the alias DNS to point to the secondary (now promoted to primary).
> 2. Breaks the Geo-DR pairing.
> 3. The old primary becomes a standalone namespace.
>
> To re-establish Geo-DR after failover, you must create a **new** secondary namespace
> and pair again.

---

### Step 13 — Verify Alias Points to the Secondary

After failover, confirm the alias now resolves to the former secondary namespace.

```azurecli
az eventhubs georecovery-alias show \
  --resource-group $RG_SECONDARY \
  --namespace-name $EH_SECONDARY \
  --alias $EH_ALIAS \
  --query '{alias: name, role: role, provisioningState: provisioningState}' \
  --output table
```

The `role` should now show `Primary` for the secondary namespace.

You can also verify with a DNS lookup:

```azurecli
nslookup eh-alias-multiregion.servicebus.windows.net
```

The resolved CNAME should now point to the Norway East namespace.

---

### Step 14 — Send Events After Failover

Using the **same alias connection string**, send additional events. They should arrive
at the former secondary namespace (now primary) without any client changes.

```python
# send_events_post_failover.py
# Uses the SAME connection string as before

import os
from azure.eventhub import EventHubProducerClient, EventData

ALIAS_CONN_STR = os.environ["EVENTHUB_ALIAS_CONNECTION_STRING"]
EVENT_HUB_NAME = "events-telemetry"

producer = EventHubProducerClient.from_connection_string(
    conn_str=ALIAS_CONN_STR,
    eventhub_name=EVENT_HUB_NAME
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"Post-failover event {i}"))
    producer.send_batch(batch)
    print(f"Sent {len(batch)} events to alias endpoint (post-failover)")
    print("Events are now arriving at the Norway East namespace!")
```

---

### Step 15 — Verify Events on the New Primary

List Event Hubs on the (now-promoted) secondary to confirm the entity is active and
accepting events:

```azurecli
az eventhubs eventhub show \
  --name $EH_NAME \
  --namespace-name $EH_SECONDARY \
  --resource-group $RG_SECONDARY \
  --output table
```

Check consumer groups are intact:

```azurecli
az eventhubs eventhub consumer-group list \
  --eventhub-name $EH_NAME \
  --namespace-name $EH_SECONDARY \
  --resource-group $RG_SECONDARY \
  --output table
```

---

## Validation Checklist

| # | Check | Expected Result |
|---|---|---|
| 1 | Alias created and provisioned | `provisioningState: Succeeded` |
| 2 | Event Hub replicated to secondary | `events-telemetry` visible on secondary namespace |
| 3 | Consumer groups replicated | `$Default` and `analytics-cg` on secondary |
| 4 | Pre-failover events sent via alias | Events arrive at primary (Sweden Central) |
| 5 | Failover completed | Alias role shows `Primary` on secondary namespace |
| 6 | Post-failover events sent via alias | Events arrive at secondary (Norway East) |
| 7 | DNS resolves to new primary | `nslookup` shows Norway East namespace |

---

## Cleanup

Remove all resources created during this lab.

```azurecli
# Delete the alias (if failover hasn't already dissolved it)
az eventhubs georecovery-alias delete \
  --resource-group $RG_SECONDARY \
  --namespace-name $EH_SECONDARY \
  --alias $EH_ALIAS \
  2>/dev/null || echo "Alias already removed by failover"

# Delete both resource groups (and all resources within them)
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

echo "Cleanup initiated. Resources will be deleted in the background."
```

---

## Discussion

### Geo-DR vs. Full Geo-Replication

Azure Event Hubs Geo-DR is a **metadata-only replication** mechanism:

| Aspect | Geo-DR (Current) | Full Geo-Replication (Preview) |
|---|---|---|
| **What replicates** | Metadata (entities, configs, auth rules) | Metadata + event data |
| **Data availability** | Events only on active primary | Events replicated across regions |
| **Failover type** | Manual, one-way DNS switch | Automatic, transparent |
| **Consumer offsets** | Not replicated | Replicated (in full geo-replication) |
| **Tier requirement** | Standard or Premium | Premium only |

Full geo-replication (in preview) is the next evolution and addresses the data gap, but
Geo-DR remains the generally available option for production workloads today.

### Differences from Service Bus Geo-DR

Event Hubs and Service Bus share a common architecture, and their Geo-DR features are
similar — but there are important differences:

| Feature | Event Hubs | Service Bus |
|---|---|---|
| **Minimum tier** | Standard | **Premium** |
| **Cost** | Lower entry point | Higher (Premium required) |
| **Metadata replicated** | EH entities, consumer groups, partitions, SAS | Queues, topics, subscriptions, rules, SAS |
| **Data replicated** | No | No |
| **Failover** | Manual, one-way | Manual, one-way |
| **Data preservation** | Event Hubs Capture → Storage/ADLS | No built-in equivalent |

> **Key takeaway:** Event Hubs Geo-DR is more accessible because it works on the
> Standard tier, which significantly reduces cost for organizations that need cross-region
> resilience.

### Event Hubs Capture — Independent Data Preservation

While Geo-DR does not replicate event data, **Event Hubs Capture** provides an
independent data preservation mechanism:

- Capture automatically writes incoming events to **Azure Blob Storage** or **Azure Data
  Lake Storage** in Avro format.
- Capture operates at the partition level and runs continuously.
- Even if the primary region goes down, captured data is safe in the Storage account
  (which can itself be geo-redundant via GRS/GZRS).
- After a failover, you can replay captured data or use it for analytics independently.

```azurecli
# Example: Enable Capture on the Event Hub (before pairing)
az eventhubs eventhub update \
  --name $EH_NAME \
  --namespace-name $EH_PRIMARY \
  --resource-group $RG_PRIMARY \
  --enable-capture true \
  --capture-interval 300 \
  --capture-size-limit 314572800 \
  --destination-name EventHubArchive.AzureBlockBlob \
  --storage-account <storage-account-resource-id> \
  --blob-container eventhub-capture \
  --archive-name-format "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
```

> **💡 Tip:** Enable Event Hubs Capture to preserve event data independently of Geo-DR.
> Even if a region goes down completely, captured data is safe in your Storage account.
> Combine Capture with a geo-redundant storage account (GRS/GZRS) for maximum
> resilience.

### Consumer Group Behavior After Failover

A critical detail for consumers:

1. **Consumer groups ARE replicated** — after failover, your consumer groups exist on the
   new primary with the same names.

2. **Consumer offsets/checkpoints are NOT replicated** — checkpoints are stored per-
   namespace (often in Azure Blob Storage via the `EventProcessorClient`). After failover,
   consumers connecting to the new primary will **not** have their previous checkpoint
   positions.

3. **What happens in practice:**
   - If consumers use `EventPosition.LATEST`, they start reading only new events after
     reconnecting — no duplicates, but events published to the old primary before
     failover are missed.
   - If consumers use `EventPosition.EARLIEST`, they start reading from the beginning of
     the new primary's log — but since Geo-DR doesn't replicate data, there may be no
     historical events.

4. **Recommendation:** Use a checkpoint store (e.g., Azure Blob Storage) that is
   accessible from both regions, and handle the "checkpoint not found" scenario
   gracefully in your consumer code.

### Partition Count and Entity Configuration

All entity-level configurations are replicated:

- **Partition count** — The secondary Event Hub will have the same number of partitions.
- **Message retention** — Same retention period on both sides.
- **Authorization rules** — SAS keys and policies are replicated, so the same connection
  string works via the alias.
- **Consumer groups** — All custom consumer groups are replicated.

> **Note:** Changes made to entities on the primary are continuously replicated to the
> secondary. You cannot independently modify entities on the secondary while the pairing
> is active — it is read-only.

---

## Summary

In this lab you:

1. ✅ Created paired Event Hubs namespaces in **Sweden Central** and **Norway East**
2. ✅ Set up an Event Hub with partitions and consumer groups
3. ✅ Established a **Geo-DR alias** for transparent DNS-based failover
4. ✅ Verified **metadata replication** (entities, consumer groups)
5. ✅ Sent events through the alias endpoint
6. ✅ Performed a **manual failover** and confirmed the alias switched
7. ✅ Validated that producers can send events post-failover with **zero config changes**
8. ✅ Discussed Capture, consumer offsets, and differences from Service Bus

---

## Key Takeaways

- **Geo-DR is metadata-only** — use Event Hubs Capture for data preservation.
- **Standard tier is sufficient** — unlike Service Bus, you don't need Premium.
- **Always use the alias endpoint** — this enables transparent failover for producers
  and consumers.
- **Consumer checkpoints don't transfer** — plan your consumer restart strategy.
- **Failover is one-way** — you must re-pair with a new namespace afterward.

---

[← Back to Index](../index.md) · [Next: Lab 8 — Azure Container Registry Geo-Replication →](lab-08-acr-geo-replication.md)
