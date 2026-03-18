---
layout: default
title: "Lab 6: Azure Service Bus – Geo-Disaster Recovery"
---

[← Back to Index](../index.md)

# Lab 6: Azure Service Bus – Geo-Disaster Recovery

## Introduction

Azure Service Bus is a fully managed enterprise message broker that supports
queues, topics, and subscriptions. A Service Bus **namespace** lives in a single
Azure region. Unlike some other Azure services, Service Bus does **not**
automatically replicate messages across regions. If the region hosting your
namespace suffers an outage, your messaging infrastructure — and any in-flight
messages — become unavailable.

**Geo-Disaster Recovery (Geo-DR)** addresses the *namespace continuity* problem.
It continuously replicates **metadata** (queues, topics, subscriptions, filters,
authorization rules) from a **primary** namespace to a **secondary** namespace in
a different region. A DNS alias abstracts the two namespaces behind a single
fully-qualified domain name (FQDN). When you initiate a failover, the alias
swings to the secondary namespace and your producers and consumers reconnect
transparently — no connection-string changes required.

### What Geo-DR Is — and What It Is Not

| Replicated (metadata)                | **Not** replicated                      |
|--------------------------------------|-----------------------------------------|
| Queue definitions                    | Messages in queues / topics             |
| Topic definitions                    | Dead-letter queue contents              |
| Subscription definitions             | Message state (deferred, scheduled)     |
| Subscription filters / actions       | Sequence numbers                        |
| SAS policies and keys                | Active sessions                         |
| RBAC role assignments (ARM level)    | Per-message locks                       |

> **Key takeaway:** Geo-DR is about *namespace continuity and connection-string
> stability*, **not** about message replication. If you need zero-message-loss
> across regions, you must implement application-level forwarding (see the
> Discussion section at the end of this lab).

---

## Architecture

```
                        ┌──────────────────────────────┐
                        │       Geo-DR Alias           │
                        │  sb-alias-multiregion        │
                        │  .servicebus.windows.net     │
                        └──────────┬───────────────────┘
                                   │
                          DNS resolves to
                          active namespace
                                   │
              ┌────────────────────┼────────────────────┐
              │                                         │
              ▼                                         ▼
┌───────────────────────────┐          ┌───────────────────────────┐
│    Primary Namespace      │          │   Secondary Namespace     │
│    sb-dr-swc-xxxxx        │  ──────► │   sb-dr-noe-xxxxx        │
│    Sweden Central         │ metadata │   Norway East             │
│                           │   sync   │                           │
│  ┌─────────────────────┐  │          │  ┌─────────────────────┐  │
│  │  orders-queue       │  │          │  │  orders-queue       │  │
│  │  events-topic       │  │          │  │  events-topic       │  │
│  │   └─ all-events-sub │  │          │  │   └─ all-events-sub │  │
│  └─────────────────────┘  │          │  └─────────────────────┘  │
└───────────────────────────┘          └───────────────────────────┘
              ▲                                         ▲
              │                                         │
     ┌────────┴────────┐                       (after failover,
     │   Producers &   │                        alias swings here)
     │   Consumers     │
     │  (connect via   │
     │   alias FQDN)   │
     └─────────────────┘
```

**Normal operation:** The alias FQDN resolves to the primary namespace. All
messages flow through Sweden Central. Metadata is continuously synchronised to
the secondary in Norway East.

**During failover:** You invoke `fail-over` on the secondary. The alias DNS
record swings to Norway East. Producers and consumers reconnect (most SDKs
retry automatically) and resume operations against the secondary. Any messages
that were in-flight in the primary are **lost**.

---

## Prerequisites

| Requirement             | Details                                                    |
|-------------------------|------------------------------------------------------------|
| **Azure subscription**  | With permissions to create Service Bus Premium namespaces   |
| **Azure CLI ≥ 2.55**    | `az --version` — install or update via `az upgrade`        |
| **Service Bus Premium** | ⚠️ **Both namespaces must be Premium tier** (see cost note) |
| **Bash shell**          | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash        |

> ⚠️ **Cost warning:** Service Bus Premium is billed per Messaging Unit per hour.
> Two Premium namespaces with 1 MU each will incur significant cost. **Delete
> resources promptly** after completing the lab to minimise charges.

---

## Step 1 — Set Variables

Generate a short random suffix to ensure globally unique namespace names.

```azurecli
# Random 5-character suffix
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)

# Namespace names
SB_PRIMARY="sb-dr-swc-${RANDOM_SUFFIX}"
SB_SECONDARY="sb-dr-noe-${RANDOM_SUFFIX}"

# Geo-DR alias
SB_ALIAS="sb-alias-multiregion"

# Resource groups
RG_PRIMARY="rg-servicebus-dr-primary"
RG_SECONDARY="rg-servicebus-dr-secondary"

# Regions
LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

echo "Primary namespace : $SB_PRIMARY"
echo "Secondary namespace: $SB_SECONDARY"
echo "Alias              : $SB_ALIAS"
```

---

## Step 2 — Create Resource Groups

```azurecli
az group create \
  --name $RG_PRIMARY \
  --location $LOCATION_PRIMARY \
  --output table

az group create \
  --name $RG_SECONDARY \
  --location $LOCATION_SECONDARY \
  --output table
```

---

## Step 3 — Create the Primary Service Bus Namespace (Premium)

Geo-DR requires the **Premium** SKU. We provision 1 Messaging Unit (the
minimum).

```azurecli
az servicebus namespace create \
  --name $SB_PRIMARY \
  --resource-group $RG_PRIMARY \
  --location $LOCATION_PRIMARY \
  --sku Premium \
  --capacity 1 \
  --output table
```

This operation takes 2–4 minutes. Premium namespaces run on dedicated
infrastructure.

---

## Step 4 — Create the Secondary Service Bus Namespace (Premium)

```azurecli
az servicebus namespace create \
  --name $SB_SECONDARY \
  --resource-group $RG_SECONDARY \
  --location $LOCATION_SECONDARY \
  --sku Premium \
  --capacity 1 \
  --output table
```

> ⚠️ **Both namespaces must be Premium.** Standard or Basic namespaces cannot
> participate in Geo-DR pairings.

---

## Step 5 — Create a Test Queue in the Primary Namespace

```azurecli
az servicebus queue create \
  --namespace-name $SB_PRIMARY \
  --resource-group $RG_PRIMARY \
  --name orders-queue \
  --max-size 1024 \
  --output table
```

Confirm the queue exists:

```azurecli
az servicebus queue list \
  --namespace-name $SB_PRIMARY \
  --resource-group $RG_PRIMARY \
  --query "[].name" \
  --output tsv
```

Expected output:

```
orders-queue
```

---

## Step 6 — Create a Test Topic and Subscription

```azurecli
# Create the topic
az servicebus topic create \
  --namespace-name $SB_PRIMARY \
  --resource-group $RG_PRIMARY \
  --name events-topic \
  --max-size 1024 \
  --output table

# Create a subscription on the topic
az servicebus topic subscription create \
  --namespace-name $SB_PRIMARY \
  --resource-group $RG_PRIMARY \
  --topic-name events-topic \
  --name all-events-sub \
  --output table
```

Verify:

```azurecli
az servicebus topic list \
  --namespace-name $SB_PRIMARY \
  --resource-group $RG_PRIMARY \
  --query "[].name" \
  --output tsv
```

Expected output:

```
events-topic
```

---

## Step 7 — Retrieve the Secondary Namespace Resource ID

The Geo-DR pairing command requires the **full ARM resource ID** of the
secondary namespace.

```azurecli
SECONDARY_ID=$(az servicebus namespace show \
  --name $SB_SECONDARY \
  --resource-group $RG_SECONDARY \
  --query id \
  --output tsv)

echo "Secondary resource ID: $SECONDARY_ID"
```

---

## Step 8 — Create the Geo-DR Alias (Pairing)

This is the core step. It links the two namespaces under a single alias and
begins continuous metadata synchronisation.

```azurecli
az servicebus georecovery-alias create \
  --resource-group $RG_PRIMARY \
  --namespace-name $SB_PRIMARY \
  --alias $SB_ALIAS \
  --partner-namespace $SECONDARY_ID \
  --output table
```

---

## Step 9 — Wait for Provisioning to Complete

The pairing takes 1–3 minutes to fully provision. Poll until `provisioningState`
is `Succeeded` and `role` is `Primary`.

```azurecli
while true; do
  STATE=$(az servicebus georecovery-alias show \
    --resource-group $RG_PRIMARY \
    --namespace-name $SB_PRIMARY \
    --alias $SB_ALIAS \
    --query "provisioningState" \
    --output tsv)

  ROLE=$(az servicebus georecovery-alias show \
    --resource-group $RG_PRIMARY \
    --namespace-name $SB_PRIMARY \
    --alias $SB_ALIAS \
    --query "role" \
    --output tsv)

  echo "State: $STATE | Role: $ROLE"

  if [ "$STATE" == "Succeeded" ]; then
    echo "Geo-DR pairing is ready."
    break
  fi

  sleep 10
done
```

Once `Succeeded`, inspect the full alias configuration:

```azurecli
az servicebus georecovery-alias show \
  --resource-group $RG_PRIMARY \
  --namespace-name $SB_PRIMARY \
  --alias $SB_ALIAS \
  --output json
```

Note the key fields in the output:

| Field                  | Expected Value                                        |
|------------------------|-------------------------------------------------------|
| `provisioningState`    | `Succeeded`                                           |
| `role`                 | `Primary`                                             |
| `partnerNamespace`     | Full resource ID of the secondary namespace           |
| `pendingReplicationOperationsCount` | `0` (once sync is complete)              |

---

## Step 10 — Confirm the Alias FQDN

After pairing, producers and consumers should connect using the **alias** FQDN
instead of the primary or secondary namespace FQDNs:

```
Alias FQDN:     sb-alias-multiregion.servicebus.windows.net
Primary FQDN:   sb-dr-swc-xxxxx.servicebus.windows.net   (do NOT use directly)
Secondary FQDN: sb-dr-noe-xxxxx.servicebus.windows.net   (do NOT use directly)
```

Print the alias FQDN:

```azurecli
echo "Alias FQDN: ${SB_ALIAS}.servicebus.windows.net"
```

Retrieve the alias connection string (uses the primary's SAS keys):

```azurecli
az servicebus georecovery-alias authorization-rule keys list \
  --resource-group $RG_PRIMARY \
  --namespace-name $SB_PRIMARY \
  --alias $SB_ALIAS \
  --name RootManageSharedAccessKey \
  --query "primaryConnectionString" \
  --output tsv
```

> The connection string's `Endpoint=` value uses the alias FQDN, so your
> applications don't need to change connection strings after a failover.

---

## Step 11 — Verify Metadata Was Replicated to the Secondary

Check that the queue and topic created on the primary also appear on the
secondary namespace. This confirms metadata sync is working.

```azurecli
echo "=== Queues on secondary ==="
az servicebus queue list \
  --namespace-name $SB_SECONDARY \
  --resource-group $RG_SECONDARY \
  --query "[].name" \
  --output tsv

echo ""
echo "=== Topics on secondary ==="
az servicebus topic list \
  --namespace-name $SB_SECONDARY \
  --resource-group $RG_SECONDARY \
  --query "[].name" \
  --output tsv
```

Expected output:

```
=== Queues on secondary ===
orders-queue

=== Topics on secondary ===
events-topic
```

> If the entities don't appear yet, wait a minute and retry. Metadata sync may
> still be in progress even after `provisioningState` shows `Succeeded`.

---

## Step 12 — Send Test Messages via the Alias

Now let's send messages **through the alias** to verify end-to-end connectivity.

### Option A: Azure CLI

```azurecli
# Send a message to the queue via the alias namespace
az servicebus queue send \
  --namespace-name $SB_ALIAS \
  --resource-group $RG_PRIMARY \
  --queue-name orders-queue \
  --body '{"orderId": "ORD-001", "item": "Widget", "qty": 5}' \
  --output table

az servicebus queue send \
  --namespace-name $SB_ALIAS \
  --resource-group $RG_PRIMARY \
  --queue-name orders-queue \
  --body '{"orderId": "ORD-002", "item": "Gadget", "qty": 3}' \
  --output table

echo "Sent 2 messages to orders-queue via alias."
```

### Option B: Service Bus Explorer / Azure Portal

You can also use the **Azure Portal** → Service Bus namespace → Queues →
orders-queue → Service Bus Explorer → **Send Messages** tab. Make sure you
navigate to the alias or primary namespace to send.

---

## Step 13 — Receive Messages from the Alias

```azurecli
# Peek at messages (non-destructive)
az servicebus queue peek \
  --namespace-name $SB_ALIAS \
  --resource-group $RG_PRIMARY \
  --queue-name orders-queue \
  --max-count 5 \
  --output table

# Receive and delete a message (destructive)
az servicebus queue receive \
  --namespace-name $SB_ALIAS \
  --resource-group $RG_PRIMARY \
  --queue-name orders-queue \
  --output json
```

This confirms that messages sent to the alias flow through the **primary**
namespace in Sweden Central as expected.

---

## Step 14 — Send Additional Messages Before Failover

Send a few more messages to demonstrate that in-flight messages are lost during
failover.

```azurecli
for i in $(seq 100 105); do
  az servicebus queue send \
    --namespace-name $SB_ALIAS \
    --resource-group $RG_PRIMARY \
    --queue-name orders-queue \
    --body "{\"orderId\": \"ORD-${i}\", \"item\": \"Pre-failover-item\", \"qty\": ${i}}" \
    --output none
done

echo "Sent 6 pre-failover messages."

# Check the message count on the primary
az servicebus queue show \
  --namespace-name $SB_PRIMARY \
  --resource-group $RG_PRIMARY \
  --name orders-queue \
  --query "countDetails.activeMessageCount" \
  --output tsv
```

> ⚠️ **Remember:** These messages live **only** in the primary namespace. They
> will **not** survive the failover.

---

## Step 15 — Initiate Failover

This is the critical disaster-recovery step. The failover command is executed
against the **secondary** namespace.

```azurecli
az servicebus georecovery-alias fail-over \
  --resource-group $RG_SECONDARY \
  --namespace-name $SB_SECONDARY \
  --alias $SB_ALIAS
```

> ⚠️ **Important notes about failover:**
>
> - Failover is a **one-way, irreversible** operation on the pairing.
> - It **breaks the pairing** — the former primary is disconnected.
> - The alias DNS record swings to the secondary namespace.
> - Any **messages in the primary namespace are not transferred** and are lost.
> - The operation can take **1–5 minutes** to complete.

---

## Step 16 — Wait for Failover to Complete

```azurecli
while true; do
  STATE=$(az servicebus georecovery-alias show \
    --resource-group $RG_SECONDARY \
    --namespace-name $SB_SECONDARY \
    --alias $SB_ALIAS \
    --query "provisioningState" \
    --output tsv 2>/dev/null)

  echo "Failover state: $STATE"

  if [ "$STATE" == "Succeeded" ] || [ -z "$STATE" ]; then
    echo "Failover complete."
    break
  fi

  sleep 15
done
```

Verify the alias now shows the secondary as the active namespace:

```azurecli
az servicebus georecovery-alias show \
  --resource-group $RG_SECONDARY \
  --namespace-name $SB_SECONDARY \
  --alias $SB_ALIAS \
  --output json
```

Expected: `role` should now be `Primary` for the **secondary** namespace (Norway
East), and `partnerNamespace` should be empty (pairing is broken).

---

## Step 17 — Verify the Alias Now Points to the Secondary

```azurecli
echo "Alias FQDN: ${SB_ALIAS}.servicebus.windows.net"
echo ""
echo "Queues on secondary (now primary):"
az servicebus queue list \
  --namespace-name $SB_SECONDARY \
  --resource-group $RG_SECONDARY \
  --query "[].name" \
  --output tsv

echo ""
echo "Message count on secondary:"
az servicebus queue show \
  --namespace-name $SB_SECONDARY \
  --resource-group $RG_SECONDARY \
  --name orders-queue \
  --query "countDetails.activeMessageCount" \
  --output tsv
```

> The active message count on the secondary should be **0** — confirming that
> the pre-failover messages were **not** replicated. This is the expected
> behaviour. Geo-DR replicates metadata, not messages.

---

## Step 18 — Send and Receive via Alias Post-Failover

Confirm that the alias is fully functional against the secondary namespace.

```azurecli
# Send a new message through the alias (now hitting Norway East)
az servicebus queue send \
  --namespace-name $SB_ALIAS \
  --resource-group $RG_SECONDARY \
  --queue-name orders-queue \
  --body '{"orderId": "ORD-POST-001", "item": "Post-failover-item", "qty": 1}' \
  --output table

echo "Sent post-failover message."

# Receive the message
az servicebus queue receive \
  --namespace-name $SB_ALIAS \
  --resource-group $RG_SECONDARY \
  --queue-name orders-queue \
  --output json
```

✅ If you received the `ORD-POST-001` message, the failover was successful. The
alias is now serving traffic from Norway East, and your applications did not
need any connection-string changes.

---

## Step 19 — Inspect the Former Primary

After failover, the former primary namespace still exists but is no longer part
of a Geo-DR pairing.

```azurecli
# The old primary still has the pre-failover messages (if the region is available)
az servicebus queue show \
  --namespace-name $SB_PRIMARY \
  --resource-group $RG_PRIMARY \
  --name orders-queue \
  --query "countDetails.activeMessageCount" \
  --output tsv
```

> If the former primary's region is still accessible, you could drain these
> messages manually. In a real disaster scenario, the primary region may be
> completely unavailable.

---

## Cleanup

> ⚠️ **Service Bus Premium is expensive.** Delete these resources as soon as you
> are finished.

### Delete the Geo-DR alias (if still present)

```azurecli
# Delete the alias from the current primary (secondary after failover)
az servicebus georecovery-alias delete \
  --resource-group $RG_SECONDARY \
  --namespace-name $SB_SECONDARY \
  --alias $SB_ALIAS \
  --output none 2>/dev/null

echo "Alias deleted (or already removed by failover)."
```

### Delete both resource groups

```azurecli
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

echo "Resource group deletion initiated (runs in background)."
```

### Verify cleanup

```azurecli
# Wait a few minutes, then confirm
az group list \
  --query "[?starts_with(name, 'rg-servicebus-dr')].name" \
  --output tsv
```

Expected: no output (both groups deleted).

---

## Discussion

### What Geo-DR Gives You

1. **Namespace continuity** — the alias FQDN survives a regional failure.
2. **Metadata replication** — you don't need to recreate queues, topics,
   subscriptions, filters, or SAS policies after failover.
3. **Transparent failover** — connection strings using the alias don't change,
   so applications reconnect automatically.

### What Geo-DR Does NOT Give You

1. **Message replication** — messages sitting in queues or topic subscriptions
   are **not** copied to the secondary. They exist only in the primary region.
2. **Dead-letter queue contents** — dead-lettered messages are not replicated.
3. **Scheduled / deferred messages** — these are per-namespace state and are
   lost on failover.
4. **Active sessions** — session state is not replicated.
5. **Sequence number continuity** — sequence numbers restart on the secondary.

### After Failover: Re-establishing DR

Once failover completes, the pairing is **broken**. To protect against a
*second* regional failure:

1. Create a **new** Premium namespace in a third region (or re-use the original
   primary region if it's recovered).
2. Create a **new** Geo-DR pairing with the current active namespace as primary
   and the new namespace as secondary.

### Active-Active Alternatives (Application-Level)

If your application cannot tolerate any message loss, consider an
**application-level active-active** pattern:

```
┌────────────┐         ┌────────────┐
│ Namespace A│ ◄─────► │ Namespace B│
│ (Region 1) │  app    │ (Region 2) │
│             │ forward │             │
└────────────┘         └────────────┘
      ▲                       ▲
      │                       │
   Producers               Producers
   (Region 1)              (Region 2)
```

- Each producer sends to its **local** namespace.
- A **forwarder service** (or Azure Function) reads from Namespace A and sends
  to Namespace B, and vice versa.
- Consumers read from their local namespace and apply **idempotency** logic
  (since messages may be duplicated).
- This approach provides **zero message loss** at the cost of increased
  complexity and potential duplicate processing.

### When to Use Which Pattern

| Scenario                                    | Recommended Pattern     |
|---------------------------------------------|-------------------------|
| Namespace continuity; messages are ephemeral | Geo-DR (this lab)       |
| Zero message loss required                  | Active-active forwarder |
| Multi-region writes with local latency      | Active-active forwarder |
| Compliance: metadata must exist in 2 regions| Geo-DR (this lab)       |

---

## Summary

In this lab you:

| Step | Action                                                    |
|------|-----------------------------------------------------------|
| 1–2  | Created resource groups in Sweden Central and Norway East |
| 3–4  | Provisioned two Premium Service Bus namespaces            |
| 5–6  | Created a test queue and topic with subscription          |
| 7–9  | Established a Geo-DR pairing with a DNS alias             |
| 10–11| Verified metadata replication to the secondary            |
| 12–13| Sent and received messages through the alias              |
| 14   | Sent additional messages to demonstrate message loss      |
| 15–16| Initiated and monitored failover                          |
| 17–18| Confirmed alias now serves traffic from the secondary     |
| 19   | Inspected the former primary's orphaned messages          |

**Key takeaways:**

- Geo-DR protects your **namespace metadata and connection strings**, not your
  messages.
- Failover is a **manual, one-way** operation that breaks the pairing.
- Applications using the **alias FQDN** require **zero reconfiguration** after
  failover.
- For **message-level** resilience, implement application-level forwarding
  between namespaces.

---

[Next: Lab 7 — Azure Event Hubs Geo-Replication →](lab-07-event-hubs-geo-replication.md)
