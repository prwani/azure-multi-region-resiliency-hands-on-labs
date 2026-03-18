---
layout: default
title: "Lab 2: Azure Blob Storage – Object Replication across Regions"
---

[← Back to Index](../index.md)

# Lab 2: Azure Blob Storage – Object Replication across Regions

> **Replicate block blobs between two non-paired Azure regions using Object Replication, so your data is available close to users — and safe from a regional outage — without being forced into Azure's default paired region.**

---

## Why Object Replication for Non-Paired Regions?

When you enable **Geo-Redundant Storage (GRS)** on an Azure Storage account, your data is automatically replicated to the [paired region](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure) — you don't get to choose which region receives the copy. For many organisations, that is fine. But if you need data in a *specific* secondary region — for latency, compliance, or sovereignty reasons — GRS won't help.

**Object Replication** solves this by asynchronously copying block blobs from a *source* container to a *destination* container in **any** other storage account, in **any** region. You control:

| You decide | GRS decides for you |
|---|---|
| Which region(s) receive the copy | Fixed to the paired region |
| Which containers and prefix filters replicate | Everything or nothing |
| When replication starts (new blobs only, or include existing blobs) | Always all data |
| Whether the destination is read-only or a full account | Read-only secondary endpoint |

In this lab you will configure Object Replication between **Sweden Central** (source) and **Norway East** (destination) — a validated non-paired combination.

> **📝 Companion repository:** This lab is based on the CLI-first demo track in [**prwani/multi-region-nonpaired-azurestorage**](https://github.com/prwani/multi-region-nonpaired-azurestorage), which provides Bash and PowerShell scripts, benchmark tooling, and an AVM/Bicep companion track for production use.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Azure Subscription                              │
│                                                                        │
│   Sweden Central                           Norway East                 │
│  ┌──────────────────────┐                ┌──────────────────────┐      │
│  │  stobjreplsrc<uid>   │  Object        │  stobjrepldst<uid>   │      │
│  │  (Source Account)    │  Replication   │  (Destination Acct)  │      │
│  │                      │ ─────────────► │                      │      │
│  │  ┌────────────────┐  │  async copy    │  ┌────────────────┐  │      │
│  │  │  source-01     │  │  (block blobs) │  │  dest-01       │  │      │
│  │  │  ┌──────────┐  │  │                │  │  ┌──────────┐  │  │      │
│  │  │  │ myblob   │──┼──┼───────────────►│──┼─►│ myblob   │  │  │      │
│  │  │  └──────────┘  │  │                │  │  └──────────┘  │  │      │
│  │  └────────────────┘  │                │  └────────────────┘  │      │
│  │                      │                │       (read-only     │      │
│  │  • Versioning   ✓    │                │        once policy   │      │
│  │  • Change Feed  ✓    │                │        is active)    │      │
│  └──────────────────────┘                │  • Versioning   ✓    │      │
│                                          └──────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
```

**Data flow:** When a blob is created or updated in `source-01`, the change feed records the event. Azure's Object Replication fabric picks up the change and asynchronously copies the blob (and its version) to `dest-01`.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Contributor or Owner role |
| **Azure CLI** | v2.60 or later (`az --version`) |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash on Windows |
| **Logged in** | `az login` with the correct subscription selected |
| **Data-plane RBAC** | **Storage Blob Data Contributor** on both the source and destination storage accounts |
| **Lab 1 completed** | Recommended but not required |

> **💡 Tip:** If you want to run this lab without installing anything locally, open [Azure Cloud Shell](https://shell.azure.com) — the CLI and Bash are pre-installed.

> **🔒 Security note:** This lab uses `az login` (Azure AD) for all data-plane access. No shared keys are needed. The scripts use `--auth-mode login` throughout, so ensure your identity has the **Storage Blob Data Contributor** role on both storage accounts (or their containers).

---

## Object Replication — Limits to Know

Before you start, be aware of the service limits. These rarely block a hands-on lab, but they matter for production designs.

| Limit | Value |
|---|---|
| Max destination accounts per source account | **2** |
| Max replication policies per storage account | **2** (one as source, one as destination) |
| Max rules per replication policy | **1,000** (use a [JSON policy definition file](https://learn.microsoft.com/azure/storage/blobs/object-replication-configure?tabs=azure-cli#configure-object-replication-using-a-json-file) for more than 10 rules via CLI) |
| Priority replication policies per source account | **1** |
| Supported blob types | **Block blobs only** (page blobs, append blobs, and Data Lake Storage Gen2 with hierarchical namespace are not supported) |
| Destination container access | **Read-only** once a replication policy is active |
| Minimum TLS version required | 1.2 |
| Supported account kinds | General-purpose v2, Premium block blob |

> **⚠️ Caution:** Once a replication policy targets a destination container, that container becomes **read-only**. You cannot upload blobs directly to it. Complete any seeding, review, or approval steps before enabling the policy.

---

## Step-by-Step Instructions

### Step 1 — Set Variables

Open a Bash terminal and define the variables you will use throughout the lab. Replace `<unique>` with a short random suffix (storage account names must be globally unique and lowercase).

```azurecli
# ── Configuration ─────────────────────────────────────────────
UNIQUE_SUFFIX=$(openssl rand -hex 3)          # e.g. "a1b2c3"
RESOURCE_GROUP="rg-objrepl-lab02"
LOCATION_SRC="swedencentral"                  # Primary region
LOCATION_DST="norwayeast"                     # Secondary (non-paired) region
SRC_ACCOUNT="stobjreplsrc${UNIQUE_SUFFIX}"
DST_ACCOUNT="stobjrepldst${UNIQUE_SUFFIX}"
SRC_CONTAINER="source-01"
DST_CONTAINER="dest-01"

echo "Source account:      $SRC_ACCOUNT  ($LOCATION_SRC)"
echo "Destination account: $DST_ACCOUNT  ($LOCATION_DST)"
```

> **💡 Tip:** Write these values down or export them in your shell profile — you will need them in every step.

---

### Step 2 — Create the Resource Group

```azurecli
az group create \
  --name     "$RESOURCE_GROUP" \
  --location "$LOCATION_SRC" \
  --tags     lab=02 purpose=object-replication
```

---

### Step 3 — Create the Source Storage Account (Sweden Central)

```azurecli
az storage account create \
  --name              "$SRC_ACCOUNT" \
  --resource-group    "$RESOURCE_GROUP" \
  --location          "$LOCATION_SRC" \
  --sku               Standard_LRS \
  --kind              StorageV2 \
  --min-tls-version   TLS1_2 \
  --allow-blob-public-access false \
  --tags              role=source lab=02
```

We use **Standard_LRS** (locally redundant) because Object Replication provides the cross-region copy — there is no need to pay for GRS on top.

---

### Step 4 — Create the Destination Storage Account (Norway East)

```azurecli
az storage account create \
  --name              "$DST_ACCOUNT" \
  --resource-group    "$RESOURCE_GROUP" \
  --location          "$LOCATION_DST" \
  --sku               Standard_LRS \
  --kind              StorageV2 \
  --min-tls-version   TLS1_2 \
  --allow-blob-public-access false \
  --tags              role=destination lab=02
```

---

### Step 5 — Enable Blob Versioning on Both Accounts

Object Replication **requires** blob versioning on both the source and destination accounts. Without it, the replication policy creation will fail.

```azurecli
# Source account
az storage account blob-service-properties update \
  --account-name   "$SRC_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true

# Destination account
az storage account blob-service-properties update \
  --account-name   "$DST_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true
```

---

### Step 6 — Enable Change Feed on the Source Account

The change feed records all blob create, update, and delete events. Object Replication reads this feed to discover which blobs need to be copied.

```azurecli
az storage account blob-service-properties update \
  --account-name   "$SRC_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-change-feed true
```

> **📝 Note:** Change feed is only required on the **source** account. Enabling it on the destination is optional and has no effect on replication.

---

### Step 7 — Create the Containers

```azurecli
# Source container
az storage container create \
  --name           "$SRC_CONTAINER" \
  --account-name   "$SRC_ACCOUNT" \
  --auth-mode      login

# Destination container
az storage container create \
  --name           "$DST_CONTAINER" \
  --account-name   "$DST_ACCOUNT" \
  --auth-mode      login
```

---

### Step 8 — Create the Object Replication Policy

Object Replication policies are created in a two-step process:

1. **Create the policy on the destination account first** — this generates a policy ID.
2. **Apply the same policy (with the generated ID) on the source account** — this activates replication.

#### 8a — Define the Policy on the Destination

```azurecli
DST_POLICY=$(az storage account or-policy create \
  --account-name        "$DST_ACCOUNT" \
  --resource-group      "$RESOURCE_GROUP" \
  --source-account      "$SRC_ACCOUNT" \
  --destination-account "$DST_ACCOUNT" \
  --source-container    "$SRC_CONTAINER" \
  --destination-container "$DST_CONTAINER" \
  --min-creation-time   "1601-01-01T00:00:00Z" \
  --query "policyId" -o tsv)

echo "Destination-side policy ID: $DST_POLICY"
```

> **📝 Note:** The `--min-creation-time '1601-01-01T00:00:00Z'` parameter tells Object Replication to replicate **all existing blobs** in addition to future ones. This is the approach used by the companion repo scripts. Omit this flag if you only want new blobs to be replicated.

#### 8b — Retrieve the Rule ID

```azurecli
RULE_ID=$(az storage account or-policy rule list \
  --account-name      "$DST_ACCOUNT" \
  --resource-group    "$RESOURCE_GROUP" \
  --policy-id         "$DST_POLICY" \
  --query "[0].ruleId" -o tsv)

echo "Rule ID: $RULE_ID"
```

#### 8c — Apply the Policy on the Source

```azurecli
az storage account or-policy create \
  --account-name        "$SRC_ACCOUNT" \
  --resource-group      "$RESOURCE_GROUP" \
  --source-account      "$SRC_ACCOUNT" \
  --destination-account "$DST_ACCOUNT" \
  --policy-id           "$DST_POLICY" \
  --source-container    "$SRC_CONTAINER" \
  --destination-container "$DST_CONTAINER" \
  --rule-id             "$RULE_ID" \
  --min-creation-time   "1601-01-01T00:00:00Z"
```

At this point, Object Replication is **active**. Any block blob written to `source-01` will be asynchronously copied to `dest-01`.

> **⚠️ Caution:** The destination container `dest-01` is now **read-only**. Attempting to upload directly to it will return a `409 Conflict` error.

---

### Step 9 — Upload a Test Blob

Create a small test file and upload it to the source container.

```azurecli
echo "Hello from Sweden Central — $(date -u)" > /tmp/hello.txt

az storage blob upload \
  --account-name   "$SRC_ACCOUNT" \
  --container-name "$SRC_CONTAINER" \
  --name           "hello.txt" \
  --file           /tmp/hello.txt \
  --auth-mode      login \
  --overwrite
```

---

### Step 10 — Monitor Replication Status

Object Replication is **asynchronous** — the blob won't appear in the destination instantly. You can poll the replication status on the **source** blob.

```azurecli
az storage blob show \
  --account-name   "$SRC_ACCOUNT" \
  --container-name "$SRC_CONTAINER" \
  --name           "hello.txt" \
  --auth-mode      login \
  --query          "objectReplicationSourceProperties" \
  -o jsonc
```

**Possible status values:**

| Status | Meaning |
|---|---|
| `complete` | Blob has been successfully replicated to the destination |
| `pending` | Replication is in progress or queued |
| `failed` | Replication failed — check blob size and type |

> **💡 Tip:** For a freshly created policy, initial replication of existing blobs can take several minutes. New blobs typically replicate within seconds to a few minutes depending on size.

You can also loop until the status is `complete`:

```azurecli
echo "Waiting for replication to complete..."
while true; do
  STATUS=$(az storage blob show \
    --account-name   "$SRC_ACCOUNT" \
    --container-name "$SRC_CONTAINER" \
    --name           "hello.txt" \
    --auth-mode      login \
    --query          "objectReplicationSourceProperties[0].rules[0].status" \
    -o tsv 2>/dev/null)
  echo "  Status: ${STATUS:-not yet available}"
  [ "$STATUS" = "complete" ] && break
  sleep 10
done
echo "✅ Replication complete!"
```

---

### Step 11 — Verify the Blob in the Destination

```azurecli
# List blobs in the destination container
az storage blob list \
  --account-name   "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --auth-mode      login \
  --query          "[].{name:name, size:properties.contentLength, lastModified:properties.lastModified}" \
  -o table
```

Download the replicated blob and verify its content matches:

```azurecli
az storage blob download \
  --account-name   "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --name           "hello.txt" \
  --file           /tmp/hello-destination.txt \
  --auth-mode      login

echo "── Source blob content ──"
cat /tmp/hello.txt
echo "── Destination blob content ──"
cat /tmp/hello-destination.txt
```

You should see identical content. 🎉

---

## Alternative: Using the Companion Repository Scripts

If you prefer a **one-command** path — or want a production-ready starting point — the companion repository [**prwani/multi-region-nonpaired-azurestorage**](https://github.com/prwani/multi-region-nonpaired-azurestorage) automates everything you just did manually. It provides both **Bash** and **PowerShell** scripts with full parity.

### Quick Start

```bash
git clone https://github.com/prwani/multi-region-nonpaired-azurestorage.git
cd multi-region-nonpaired-azurestorage
```

**Core setup only (no benchmarking):**

```bash
# Bash
./scripts/setup-all.sh --skip-benchmark

# PowerShell
./scripts/setup-all.ps1 -SkipBenchmark
```

**Full setup with benchmarking:**

```bash
# Bash
./scripts/setup-all.sh

# PowerShell
./scripts/setup-all.ps1
```

This single command runs the underlying scripts in order:

| Step | Bash | PowerShell | What it does |
|---|---|---|---|
| 1 | `01-create-storage.sh` | `01-create-storage.ps1` | Creates the resource group, source account, and destination account |
| 2 | `02-enable-prereqs.sh` | `02-enable-prereqs.ps1` | Enables change feed, versioning, and creates source containers |
| 3 *(optional)* | `bench-01-ingest-data.sh` | `bench-01-ingest-data.ps1` | Seeds data before replication for historical catchup measurement |
| 4 | `03-setup-replication.sh` | `03-setup-replication.ps1` | Creates destination containers and activates object replication |
| 5 *(optional)* | `bench-02-continue-ingestion.sh` | `bench-02-continue-ingestion.ps1` | Adds new data after replication starts for ongoing latency measurement |
| 6 *(optional)* | `bench-03-monitor-replication.sh` | `bench-03-monitor-replication.ps1` | Reads blob status and Azure Monitor metrics |

### Configuration — `config.env`

All settings are centralised in **`config.env`** at the repository root. Key defaults:

```bash
# config.env (excerpt)
SOURCE_REGION="swedencentral"        # Source storage account region
DEST_REGION="norwayeast"             # Destination region (non-paired)
RESOURCE_GROUP="rg-objrepl-demo"     # Resource group name
SOURCE_STORAGE="objreplsrc736208"    # Source account name (auto-generated if blank)
DEST_STORAGE="objrepldst736208"      # Destination account name (auto-generated if blank)
CONTAINER_COUNT="5"                  # Number of blob containers (default: 5 pairs)
SOURCE_CONTAINER_PREFIX="source"     # Container names: source-01 … source-05
DEST_CONTAINER_PREFIX="dest"         # Container names: dest-01 … dest-05
REPLICATION_MODE="default"           # "default" (async) or "priority" (SLA-backed)
```

> **📝 Note:** If `SOURCE_STORAGE` and `DEST_STORAGE` are blank, the scripts derive stable names from the resource group hash — e.g. `objreplsrc736208` and `objrepldst736208`. Precedence: CLI flags > environment variables > config.env > built-in defaults.

### AVM / Bicep Companion Track

For **production deployments**, the repository includes an Infrastructure-as-Code track under **`infra/avm/`** that uses [Azure Verified Modules (AVM)](https://aka.ms/avm) with Bicep. This gives you:

- Repeatable, auditable deployments with `main.bicep` and parameter files
- Secure defaults: `allowSharedKeyAccess=false`, blob public access disabled, HTTPS-only, TLS 1.2
- Optional monitoring, CMK (customer-managed keys), and private endpoints
- Replication activated as a separate CLI step via `infra/avm/create-object-replication.sh`

```bash
# AVM companion deployment
az group create --name rg-objrepl-companion --location swedencentral

az deployment group create \
  --resource-group  rg-objrepl-companion \
  --name            avm-companion \
  --template-file   infra/avm/main.bicep \
  --parameters      infra/avm/main.bicepparam

# Activate replication after deployment completes
./infra/avm/create-object-replication.sh \
  --resource-group    rg-objrepl-companion \
  --deployment-name   avm-companion
```

> **💡 Tip:** Use the CLI scripts for learning and experimentation; use the AVM/Bicep templates when deploying to shared or production environments. See [`Blog2.md`](https://github.com/prwani/multi-region-nonpaired-azurestorage/blob/main/Blog2.md) for the full AVM companion narrative and design trade-offs.

---

## Monitoring Replication

Azure exposes Object Replication metrics through Azure Monitor. You can query them with the CLI or view them in the portal under **Storage account → Monitoring → Metrics**.

### Key Metrics

| Signal | Why it matters |
|---|---|
| `ObjectReplicationSourceBytesReplicated` | Confirms bytes are actually flowing from source to destination |
| `ObjectReplicationSourceOperationsReplicated` | Shows replicated write activity and helps validate throughput |
| `Operations pending for replication` *(priority mode)* | Shows backlog by time bucket and helps detect SLA risk |
| `Bytes pending for replication` *(priority mode)* | Data backlog by age bucket in priority replication mode |
| Blob `replicationStatus` samples | Useful spot-check for `complete`, `pending`, or `failed` blobs |
| Storage account metrics and blob service logs | Helpful for troubleshooting access, network, or policy issues |

### Query Example

```azurecli
# Query replicated bytes (last 1 hour)
az monitor metrics list \
  --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$SRC_ACCOUNT" \
  --metric "ObjectReplicationSourceBytesReplicated" \
  --interval PT1H \
  --query "value[0].timeseries[0].data[-1].total" \
  -o tsv
```

### Setting Up Alerts

For production workloads, create an alert rule that fires when pending blobs exceed a threshold:

```azurecli
az monitor metrics alert create \
  --name               "high-replication-lag" \
  --resource-group     "$RESOURCE_GROUP" \
  --scopes             "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$SRC_ACCOUNT" \
  --condition          "total ObjectReplicationSourceBlobsPending > 1000" \
  --window-size        5m \
  --evaluation-frequency 1m \
  --description        "Object Replication backlog exceeds 1000 pending blobs"
```

---

## Validation Checklist

Before moving on, confirm each item:

- [ ] Source storage account exists in **Sweden Central** with versioning and change feed enabled
- [ ] Destination storage account exists in **Norway East** with versioning enabled
- [ ] Object Replication policy is active on both accounts (same policy ID)
- [ ] Test blob uploaded to `source-01` appears in `dest-01`
- [ ] Replication status shows `complete` on the source blob
- [ ] Content of the replicated blob matches the original
- [ ] Destination container is read-only (optional: test by attempting an upload)

### Quick Validation Script

```azurecli
echo "── Validation ──────────────────────────────────────────"

# Check versioning on source
SRC_VER=$(az storage account blob-service-properties show \
  --account-name "$SRC_ACCOUNT" -g "$RESOURCE_GROUP" \
  --query "isVersioningEnabled" -o tsv)
echo "Source versioning:    $SRC_VER"

# Check versioning on destination
DST_VER=$(az storage account blob-service-properties show \
  --account-name "$DST_ACCOUNT" -g "$RESOURCE_GROUP" \
  --query "isVersioningEnabled" -o tsv)
echo "Dest versioning:     $DST_VER"

# Check change feed on source
CF=$(az storage account blob-service-properties show \
  --account-name "$SRC_ACCOUNT" -g "$RESOURCE_GROUP" \
  --query "changeFeed.enabled" -o tsv)
echo "Source change feed:  $CF"

# Check replication policy
POLICY_COUNT=$(az storage account or-policy list \
  --account-name "$SRC_ACCOUNT" -g "$RESOURCE_GROUP" \
  --query "length(@)" -o tsv)
echo "Replication policies: $POLICY_COUNT"

# Check blob exists in destination
BLOB_COUNT=$(az storage blob list \
  --account-name "$DST_ACCOUNT" --container-name "$DST_CONTAINER" \
  --auth-mode login --query "length(@)" -o tsv)
echo "Blobs in dest:       $BLOB_COUNT"

# Verify read-only behaviour on destination
echo ""
echo "Testing read-only on destination container..."
echo "test" > /tmp/readonly-test.txt
az storage blob upload \
  --account-name "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --name "readonly-test.txt" \
  --file /tmp/readonly-test.txt \
  --auth-mode login 2>&1 | grep -q "Conflict" \
  && echo "✅ Destination is read-only (409 Conflict)" \
  || echo "⚠️  Destination accepted the upload — check policy status"

echo "─────────────────────────────────────────────────────────"
```

---

## Cleanup

When you are finished with the lab, delete all resources to avoid ongoing charges.

### Manual Cleanup

```azurecli
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
echo "Resource group '$RESOURCE_GROUP' deletion initiated."
```

> **📝 Note:** The `--no-wait` flag returns immediately. The resource group and all its resources will be deleted in the background within a few minutes.

### Companion Repository Cleanup

If you used the companion repository, clean up with:

```bash
cd multi-region-nonpaired-azurestorage

# Bash
./scripts/cleanup.sh

# PowerShell
./scripts/cleanup.ps1
```

---

## Discussion: GRS vs Object Replication

### When to Use Each

| Factor | GRS / RA-GRS | Object Replication |
|---|---|---|
| **Region choice** | Paired region only (no choice) | Any region you choose |
| **Granularity** | Entire storage account | Per-container, with optional prefix filters |
| **Replication target** | Read-only secondary endpoint | Separate storage account (full or read-only) |
| **RPO** | ~15 minutes (best effort) | Varies — typically seconds to minutes |
| **Failover** | Account failover (DNS swap) | Application-level failover (change connection string) |
| **Blob types** | All (block, append, page) | Block blobs only |
| **Cost** | Higher storage SKU (GRS/RA-GRS) | LRS + bandwidth + transactions |
| **Data residency** | May conflict if paired region is outside your jurisdiction | Full control over data residency |
| **Benchmark visibility** | Limited | Better operational visibility via metrics and blob status |

### Priority Replication

For time-sensitive workloads, you can enable **priority replication** on the Object Replication policy. Priority replication provides a **99% SLA to replicate within 15 minutes** for same-continent region pairs. Key considerations:

- Only **one** priority replication policy per source account is allowed.
- Priority replication adds a **per-GB ingress surcharge**.
- **Billing continues for 30 days after disabling priority replication** — plan accordingly.
- Use the `REPLICATION_MODE="priority"` setting in `config.env` when using the companion repo.

### Cost Components

Object Replication charges include:

| Component | Applies to |
|---|---|
| **Change feed** | Source account (must be enabled for replication) |
| **Blob versioning storage** | Both source and destination accounts |
| **Source reads and destination writes** | Replicated blob traffic |
| **Cross-region data transfer** | Standard Azure egress between regions |
| **Priority replication surcharge** | Per-GB charge; billing continues for **30 days after disabling** |
| **Destination storage** | Standard LRS rates in the destination region |
| **ACR + ACI** *(optional)* | Only when using the AzDataMaker benchmark path |

> **💡 Tip:** For large-scale replication, egress bandwidth is typically the dominant cost. Use the [Azure Storage pricing calculator](https://azure.microsoft.com/pricing/details/storage/) to estimate costs based on your data volume and regions.

### Multi-Destination Replication

You can replicate from one source to **up to two** destination accounts. Each destination can be in a different region, giving you a "one-to-many" topology:

```
                ┌─► Destination A  (Norway East)
Source ─────────┤
(Sweden Central)└─► Destination B  (UK South)
```

Each destination requires its own replication policy and rule set. The per-account limit of 2 policies means you can have at most 2 destinations per source.

### Failover and Cutover Caveats

Object Replication supports regional resilience, but it does **not** deliver a turnkey application failover workflow on its own. It does not automatically:

- Switch application endpoints or DNS
- Move your application secrets or identities
- Make the destination writeable while the policy remains active
- Provide a full failback workflow after a cutover

Treat object replication as one building block inside a broader DR or cutover plan, not the entire runbook.

---

## Troubleshooting

If replication does not behave as expected, check these first:

| Symptom | What to check |
|---|---|
| Historical data not replicating | Confirm the policy was created with `--min-creation-time '1601-01-01T00:00:00Z'` |
| Uploads or blob inspection failing | Check Azure AD login state, data-plane RBAC, and storage firewall settings |
| Replication policy creation errors | Verify change feed is enabled on the source and versioning is enabled on both accounts |
| `409 Conflict` writing to destination | Expected — destination containers are read-only while the policy is active |
| Post-hardening regressions | After CMK, private endpoint, DNS, or firewall changes, re-test replication |

---

## Key Takeaways

1. **Object Replication gives you region choice** — essential for non-paired region architectures.
2. **Versioning + change feed are mandatory prerequisites** — enable them before creating a policy.
3. **Destination containers become read-only** — plan your application architecture accordingly.
4. **Replication is asynchronous** — monitor the `objectReplicationSourceProperties` for status.
5. **Use `--min-creation-time '1601-01-01T00:00:00Z'`** to replicate existing blobs, not just new ones.
6. **Use the companion repo** for automated setup, benchmarking, and production-grade AVM/Bicep templates.

---

## Further Reading

- 📖 [Object Replication overview](https://learn.microsoft.com/azure/storage/blobs/object-replication-overview)
- 📖 [Configure Object Replication](https://learn.microsoft.com/azure/storage/blobs/object-replication-configure)
- 📖 [Priority replication](https://learn.microsoft.com/azure/storage/blobs/object-replication-priority-replication)
- 📖 [Blob versioning](https://learn.microsoft.com/azure/storage/blobs/versioning-overview)
- 📖 [Change feed support](https://learn.microsoft.com/azure/storage/blobs/storage-blob-change-feed)
- 📖 [Azure Storage redundancy](https://learn.microsoft.com/azure/storage/common/storage-redundancy)
- 📖 [Azure Storage pricing](https://azure.microsoft.com/pricing/details/storage/)
- 🔧 [Companion repo: prwani/multi-region-nonpaired-azurestorage](https://github.com/prwani/multi-region-nonpaired-azurestorage)

---

## Navigation

| Previous | Home | Next |
|---|---|---|
| [Lab 1: Multi-Region Web App](lab-01-webapp-traffic-manager.md) | [All Labs](../index.md) | [Lab 3: Azure SQL Geo-Replication](lab-03-sql-geo-replication.md) |

[Next: Lab 3 — Azure SQL Database Geo-Replication →](lab-03-sql-geo-replication.md)
