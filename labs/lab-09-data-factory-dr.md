---
layout: default
title: "Lab 9: Azure Data Factory – Active/Passive Data Pipelines"
---

# Lab 9: Azure Data Factory – Active/Passive Data Pipelines

[← Back to Index](../index.md)

---

## Overview

Azure Data Factory (ADF) is the cloud-based ETL/ELT service that orchestrates data
movement and transformation across dozens of connectors. It powers nightly batch
loads, incremental copies, and complex data-engineering workflows — the plumbing
nobody notices until it stops running.

Here's the problem: **an ADF instance is bound to a single Azure region.** Unlike
Cosmos DB or Storage, there is no built-in geo-replication button. If the region
hosting your factory goes down, your pipelines stop, triggers don't fire, and data
stops flowing.

The DR strategy for ADF is a **runbook-style, active/passive** approach:

| Concept | Detail |
|---------|--------|
| **No native geo-DR** | ADF doesn't replicate pipelines, linked services, or triggers to another region. |
| **Duplicate factories** | You maintain a secondary factory in a standby region with identical definitions. |
| **Git integration is key** | Connect ADF to Git so every definition is stored as JSON. Deploying to a second factory becomes a CI/CD step. |
| **Manual switchover** | Failover means enabling triggers in the secondary and disabling them in the primary. |
| **Data source availability** | Your DR factory is only useful if its sources and sinks are also reachable from the secondary region. |

In this lab you will create two ADF instances in **Sweden Central** and **Norway
East**, build a simple pipeline in the primary, re-deploy it to the secondary, and
run it in both factories.

> **⏱ Estimated time:** 45–60 minutes

---

## Architecture

```
              ┌─────────────────────────────────────────────────┐
              │              Git Repository (GitHub /            │
              │              Azure DevOps)                       │
              │  ┌──────────────────────────────────────────┐   │
              │  │  /pipeline/CopyHttpToBlob.json           │   │
              │  │  /linkedService/HttpSource.json           │   │
              │  │  /linkedService/BlobSink.json             │   │
              │  └──────────────┬───────────────┬───────────┘   │
              └─────────────────┼───────────────┼───────────────┘
                    CI/CD deploy│               │CI/CD deploy
                                │               │
                   ┌────────────▼───┐    ┌──────▼──────────────┐
                   │  PRIMARY ADF   │    │  SECONDARY ADF      │
                   │  adf-dr-swc    │    │  adf-dr-noe         │
                   │  Sweden Central│    │  Norway East         │
                   │                │    │                      │
                   │  Triggers: ON  │    │  Triggers: OFF       │
                   │  (active)      │    │  (standby)           │
                   └───────┬────────┘    └──────┬──────────────┘
                           │                    │
                           ▼                    ▼
              ┌─────────────────────────────────────────────────┐
              │          Shared / Replicated Data Sources        │
              │                                                 │
              │  ┌──────────────┐       ┌──────────────────┐   │
              │  │ Storage Acct │◄─ORS─►│ Storage Acct      │   │
              │  │ (Sweden Cntl)│       │ (Norway East)     │   │
              │  └──────────────┘       └──────────────────┘   │
              └─────────────────────────────────────────────────┘
```

**Key points:**

- The **primary ADF** runs all scheduled and event-driven pipelines.
- The **secondary ADF** holds identical definitions but keeps triggers **disabled**.
- Pipeline definitions live in **Git** and deploy to both factories via CI/CD.
- Data sources must be **available in both regions** — via geo-replication or
  globally reachable endpoints.
- **Failover** = enable secondary triggers, disable primary. No DNS alias to flip.

---

## Prerequisites

- [ ] **Azure subscription** with Contributor or Owner access.
- [ ] **Azure CLI** v2.60+ installed and authenticated (`az login`).
- [ ] The **datafactory** CLI extension (`az extension add --name datafactory`).
- [ ] Basic familiarity with ADF concepts (pipelines, linked services, datasets).

> ⚠️ **Important:** ADF itself has no per-run compute cost for orchestration, but
> the storage accounts created in this lab will incur charges. Clean up promptly.

---

## Step 1 — Set Variables

```azurecli
UNIQUE_SUFFIX=$RANDOM
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

RG_PRIMARY="rg-adf-dr-swc"
RG_SECONDARY="rg-adf-dr-noe"

ADF_PRIMARY="adf-dr-swc-${UNIQUE_SUFFIX}"
ADF_SECONDARY="adf-dr-noe-${UNIQUE_SUFFIX}"

STORAGE_PRIMARY="stgadfdrswc${UNIQUE_SUFFIX}"
STORAGE_SECONDARY="stgadfdrnoe${UNIQUE_SUFFIX}"
CONTAINER_NAME="adf-landing"

echo "Primary ADF     : $ADF_PRIMARY   ($PRIMARY_REGION)"
echo "Secondary ADF   : $ADF_SECONDARY ($SECONDARY_REGION)"
echo "Primary Storage : $STORAGE_PRIMARY"
echo "Secondary Storage: $STORAGE_SECONDARY"
```

---

## Step 2 — Install the Data Factory CLI Extension

```azurecli
az extension add --name datafactory --upgrade --yes 2>/dev/null
az extension show --name datafactory --query version --output tsv
```

---

## Step 3 — Create Resource Groups

```azurecli
az group create --name $RG_PRIMARY  --location $PRIMARY_REGION  --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table
```

---

## Step 4 — Create Storage Accounts

The sample pipeline copies data into Blob Storage. Create an account in each region
so the secondary factory writes to a region-local sink.

```azurecli
az storage account create \
  --name $STORAGE_PRIMARY \
  --resource-group $RG_PRIMARY \
  --location $PRIMARY_REGION \
  --sku Standard_LRS --kind StorageV2 --output table

az storage account create \
  --name $STORAGE_SECONDARY \
  --resource-group $RG_SECONDARY \
  --location $SECONDARY_REGION \
  --sku Standard_LRS --kind StorageV2 --output table
```

Create landing containers in both accounts:

```azurecli
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_PRIMARY  --auth-mode login
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_SECONDARY --auth-mode login
```

---

## Step 5 — Create the Primary Data Factory

```azurecli
az datafactory create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --location $PRIMARY_REGION \
  --output table
```

> 💡 **Tip — Git integration:** In production, connect ADF to a Git repository so
> every pipeline and linked service is version-controlled. This makes deploying to a
> secondary factory a CI/CD step. We use the CLI here for simplicity.

---

## Step 6 — Create Linked Services in the Primary Factory

### 6a — Retrieve the Primary Storage Connection String

```azurecli
STORAGE_CONN_PRIMARY=$(az storage account show-connection-string \
  --name $STORAGE_PRIMARY --resource-group $RG_PRIMARY \
  --query connectionString --output tsv)
```

### 6b — HTTP Source Linked Service

```azurecli
az datafactory linked-service create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --linked-service-name "HttpSource" \
  --properties '{
    "type": "HttpServer",
    "typeProperties": {
      "url": "https://raw.githubusercontent.com/",
      "enableServerCertificateValidation": true,
      "authenticationType": "Anonymous"
    }
  }'
```

### 6c — Blob Storage Sink Linked Service

```azurecli
az datafactory linked-service create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --linked-service-name "BlobSink" \
  --properties "{
    \"type\": \"AzureBlobStorage\",
    \"typeProperties\": {
      \"connectionString\": \"$STORAGE_CONN_PRIMARY\"
    }
  }"
```

---

## Step 7 — Create Datasets

### 7a — HTTP CSV Dataset (Source)

```azurecli
az datafactory dataset create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --dataset-name "HttpCsvDataset" \
  --properties '{
    "type": "DelimitedText",
    "linkedServiceName": { "referenceName": "HttpSource", "type": "LinkedServiceReference" },
    "typeProperties": {
      "location": {
        "type": "HttpServerLocation",
        "relativeUrl": "Azure-Samples/azure-data-factory-runtime-app-service-environment/main/data/sample.csv"
      },
      "columnDelimiter": ",",
      "firstRowAsHeader": true
    },
    "schema": []
  }'
```

### 7b — Blob CSV Dataset (Sink)

```azurecli
az datafactory dataset create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --dataset-name "BlobCsvDataset" \
  --properties "{
    \"type\": \"DelimitedText\",
    \"linkedServiceName\": { \"referenceName\": \"BlobSink\", \"type\": \"LinkedServiceReference\" },
    \"typeProperties\": {
      \"location\": {
        \"type\": \"AzureBlobStorageLocation\",
        \"container\": \"$CONTAINER_NAME\",
        \"fileName\": \"output.csv\"
      },
      \"columnDelimiter\": \",\",
      \"firstRowAsHeader\": true
    },
    \"schema\": []
  }"
```

---

## Step 8 — Create a Pipeline in the Primary Factory

Create a **Copy Activity** pipeline that fetches a CSV from an HTTP endpoint and
writes it to Blob Storage.

```azurecli
az datafactory pipeline create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --pipeline-name "CopyHttpToBlob" \
  --pipeline '{
    "activities": [
      {
        "name": "CopyFromHttpToBlob",
        "type": "Copy",
        "typeProperties": {
          "source": {
            "type": "DelimitedTextSource",
            "storeSettings": { "type": "HttpReadSettings", "requestMethod": "GET" },
            "formatSettings": { "type": "DelimitedTextReadSettings" }
          },
          "sink": {
            "type": "DelimitedTextSink",
            "storeSettings": { "type": "AzureBlobStorageWriteSettings" },
            "formatSettings": {
              "type": "DelimitedTextWriteSettings",
              "quoteAllText": true,
              "fileExtension": ".csv"
            }
          }
        },
        "inputs":  [{ "referenceName": "HttpCsvDataset", "type": "DatasetReference" }],
        "outputs": [{ "referenceName": "BlobCsvDataset", "type": "DatasetReference" }]
      }
    ]
  }'
```

---

## Step 9 — Run the Pipeline in the Primary Factory

```azurecli
RUN_ID=$(az datafactory pipeline create-run \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --pipeline-name "CopyHttpToBlob" \
  --query runId --output tsv)

echo "Pipeline run started: $RUN_ID"
```

### 9a — Monitor the Run

```azurecli
echo "Waiting for pipeline run to complete..."
while true; do
  STATUS=$(az datafactory pipeline-run show \
    --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY \
    --run-id $RUN_ID --query status --output tsv)
  echo "  Status: $STATUS"
  if [ "$STATUS" = "Succeeded" ] || [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ]; then
    break
  fi
  sleep 10
done
```

### 9b — Verify Success

```azurecli
az datafactory pipeline-run show \
  --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY \
  --run-id $RUN_ID --output table
```

**Expected output (key columns):**

```
RunId                                 PipelineName     Status
------------------------------------  ---------------  ---------
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  CopyHttpToBlob   Succeeded
```

> ✅ **Success!** The primary factory ran the pipeline and copied data to blob
> storage. Now let's set up the DR factory.

---

## Step 10 — Export the Primary Factory Definition

```azurecli
az datafactory show \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --output json > adf-primary-template.json

echo "Exported factory definition to adf-primary-template.json"
```

> 💡 **Tip — ARM export:** In the Azure portal, navigate to your factory →
> **Manage** → **ARM template** → **Export ARM template** for a full deployable
> template that includes all pipelines, linked services, datasets, and triggers.

---

## Step 11 — Create the Secondary Data Factory

```azurecli
az datafactory create \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --location $SECONDARY_REGION \
  --output table
```

---

## Step 12 — Deploy Definitions to the Secondary Factory

Re-create linked services, datasets, and the pipeline in the secondary factory,
pointing to the **secondary** storage account.

### 12a — Secondary Storage Connection String

```azurecli
STORAGE_CONN_SECONDARY=$(az storage account show-connection-string \
  --name $STORAGE_SECONDARY --resource-group $RG_SECONDARY \
  --query connectionString --output tsv)
```

### 12b — Linked Services

```azurecli
# HTTP Source — identical (globally reachable, no region dependency)
az datafactory linked-service create \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --linked-service-name "HttpSource" \
  --properties '{
    "type": "HttpServer",
    "typeProperties": {
      "url": "https://raw.githubusercontent.com/",
      "enableServerCertificateValidation": true,
      "authenticationType": "Anonymous"
    }
  }'

# Blob Sink — points to the SECONDARY storage account
az datafactory linked-service create \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --linked-service-name "BlobSink" \
  --properties "{
    \"type\": \"AzureBlobStorage\",
    \"typeProperties\": {
      \"connectionString\": \"$STORAGE_CONN_SECONDARY\"
    }
  }"
```

> ⚠️ **Important:** The HTTP linked service is identical in both factories, but the
> Blob linked service points to the **secondary** storage account. In production,
> parameterize connection strings or use Key Vault references with region-specific
> vaults.

### 12c — Datasets

```azurecli
az datafactory dataset create \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --dataset-name "HttpCsvDataset" \
  --properties '{
    "type": "DelimitedText",
    "linkedServiceName": { "referenceName": "HttpSource", "type": "LinkedServiceReference" },
    "typeProperties": {
      "location": {
        "type": "HttpServerLocation",
        "relativeUrl": "Azure-Samples/azure-data-factory-runtime-app-service-environment/main/data/sample.csv"
      },
      "columnDelimiter": ",", "firstRowAsHeader": true
    },
    "schema": []
  }'

az datafactory dataset create \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --dataset-name "BlobCsvDataset" \
  --properties "{
    \"type\": \"DelimitedText\",
    \"linkedServiceName\": { \"referenceName\": \"BlobSink\", \"type\": \"LinkedServiceReference\" },
    \"typeProperties\": {
      \"location\": {
        \"type\": \"AzureBlobStorageLocation\",
        \"container\": \"$CONTAINER_NAME\",
        \"fileName\": \"output.csv\"
      },
      \"columnDelimiter\": \",\", \"firstRowAsHeader\": true
    },
    \"schema\": []
  }"
```

### 12d — Pipeline

Use the same pipeline definition as Step 8:

```azurecli
az datafactory pipeline create \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --pipeline-name "CopyHttpToBlob" \
  --pipeline '{
    "activities": [
      {
        "name": "CopyFromHttpToBlob",
        "type": "Copy",
        "typeProperties": {
          "source": {
            "type": "DelimitedTextSource",
            "storeSettings": { "type": "HttpReadSettings", "requestMethod": "GET" },
            "formatSettings": { "type": "DelimitedTextReadSettings" }
          },
          "sink": {
            "type": "DelimitedTextSink",
            "storeSettings": { "type": "AzureBlobStorageWriteSettings" },
            "formatSettings": {
              "type": "DelimitedTextWriteSettings",
              "quoteAllText": true, "fileExtension": ".csv"
            }
          }
        },
        "inputs":  [{ "referenceName": "HttpCsvDataset", "type": "DatasetReference" }],
        "outputs": [{ "referenceName": "BlobCsvDataset", "type": "DatasetReference" }]
      }
    ]
  }'
```

---

## Step 13 — Run the Pipeline in the Secondary Factory

Validate that the standby factory is fully functional.

```azurecli
RUN_ID_SECONDARY=$(az datafactory pipeline create-run \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --pipeline-name "CopyHttpToBlob" \
  --query runId --output tsv)

echo "Secondary pipeline run started: $RUN_ID_SECONDARY"
```

```azurecli
echo "Waiting for secondary pipeline run to complete..."
while true; do
  STATUS=$(az datafactory pipeline-run show \
    --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
    --run-id $RUN_ID_SECONDARY --query status --output tsv)
  echo "  Status: $STATUS"
  if [ "$STATUS" = "Succeeded" ] || [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ]; then
    break
  fi
  sleep 10
done
```

> ✅ **Success!** Both factories can run the same pipeline. The secondary is ready
> to take over if the primary region becomes unavailable.

---

## Step 14 — Verify Data in Both Storage Accounts

```azurecli
echo "=== Primary Storage ==="
az storage blob list --container-name $CONTAINER_NAME \
  --account-name $STORAGE_PRIMARY --auth-mode login \
  --query "[].name" --output table

echo ""
echo "=== Secondary Storage ==="
az storage blob list --container-name $CONTAINER_NAME \
  --account-name $STORAGE_SECONDARY --auth-mode login \
  --query "[].name" --output table
```

You should see `output.csv` in both storage accounts.

---

## Cleanup

```azurecli
az group delete --name $RG_PRIMARY   --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
rm -f adf-primary-template.json

echo "Cleanup initiated. Both resource groups are being deleted."
```

After a few minutes, verify:

```azurecli
az group show --name $RG_PRIMARY 2>&1 | head -1
az group show --name $RG_SECONDARY 2>&1 | head -1
```

Both should return `Resource group 'rg-adf-dr-*' could not be found.`

---

## Discussion — Making ADF DR Production-Ready

### CI/CD-Driven Deployment

In production, **never** copy pipeline definitions by hand. Instead:

1. **Connect ADF to Git** (Azure DevOps or GitHub). Every pipeline, linked service,
   and trigger is stored as JSON.
2. **Use a release pipeline** that deploys ARM/Bicep templates to **both** factories
   on every merge to `main`.
3. **Parameterize** region-specific values (connection strings, server names, Key
   Vault URIs) so one template works in any region.

```
  ┌──────────────┐     merge to main      ┌───────────────────┐
  │  Developers  │ ──────────────────────► │  Git Repository   │
  │  (ADF UI)    │                         │  (source of truth)│
  └──────────────┘                         └────────┬──────────┘
                                                    │
                                          CI/CD pipeline
                                    ┌───────────────┴───────────────┐
                                    │                               │
                              ┌─────▼─────────┐          ┌─────────▼──────┐
                              │  Primary ADF  │          │  Secondary ADF │
                              │  (triggers ON)│          │  (triggers OFF)│
                              └───────────────┘          └────────────────┘
```

> 💡 **Tip:** The
> [ADF CI/CD docs](https://learn.microsoft.com/azure/data-factory/continuous-integration-delivery)
> include pre/post-deployment scripts that handle trigger start/stop automatically.

### ARM Template Export/Import

If you skip Git integration, export from the portal and deploy manually:

```azurecli
az deployment group create \
  --resource-group $RG_SECONDARY \
  --template-file ARMTemplateForFactory.json \
  --parameters factoryName=$ADF_SECONDARY \
  --parameters BlobSink_connectionString="$STORAGE_CONN_SECONDARY"
```

This works but is error-prone. **Git + CI/CD is strongly preferred.**

### Self-Hosted Integration Runtime (SHIR)

If your pipelines use a SHIR to reach on-premises or private-network sources:

- Each factory needs its own SHIR registration (or use the *shared SHIR* feature).
- Deploy SHIR nodes in **both regions** for true DR.
- Pre-install and register secondary SHIR nodes so they're ready during failover.
- Ensure network connectivity (ExpressRoute / VPN) from both regions to the source.

### Data Source Availability

Your DR factory is only as useful as the data it can reach:

| Question | Action |
|----------|--------|
| Public API or SaaS source? | No region dependency — likely fine as-is. |
| Azure SQL source? | Set up [Geo-Replication](lab-03-sql-geo-replication.md); point secondary linked service to secondary server. |
| Blob Storage source? | Set up [Object Replication](lab-02-blob-storage-replication.md); point to replica account. |
| On-premises source? | Ensure SHIR in secondary region can reach it. |

### Automated Switchover

ADF has no built-in failover button, but you can automate it:

1. **Azure Monitor** detects the primary region is unhealthy.
2. An **Azure Function** or **Logic App** fires.
3. The function calls the ADF REST API to stop primary triggers and start secondary:

```azurecli
TRIGGERS=$(az datafactory trigger list \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --query "[].name" --output tsv)

for TRIGGER in $TRIGGERS; do
  az datafactory trigger start \
    --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
    --trigger-name $TRIGGER
  echo "Started trigger: $TRIGGER"
done
```

### Key Takeaways

1. **ADF has no native geo-DR** — maintain duplicate factories.
2. **Git + CI/CD** is the right way to keep both factories in sync.
3. **Parameterize everything** so one template deploys to any region.
4. **SHIR nodes** need separate instances in each region.
5. **Data source DR** is just as critical — if the source isn't available, the
   pipeline can't run.
6. **Test regularly** — run pipelines in the secondary to catch drift.
7. **Automate switchover** with scripted trigger start/stop.

---

## Further Reading

- [Azure Data Factory — BCDR](https://learn.microsoft.com/azure/data-factory/data-factory-bcdr)
- [CI/CD in Azure Data Factory](https://learn.microsoft.com/azure/data-factory/continuous-integration-delivery)
- [Self-Hosted IR — HA and scalability](https://learn.microsoft.com/azure/data-factory/create-self-hosted-integration-runtime#high-availability-and-scalability)
- [Azure Data Factory pricing](https://azure.microsoft.com/pricing/details/data-factory/v2/)

---

| [← Lab 8: ACR Geo-Replication](lab-08-acr-geo-replication.md) | [Back to Index](../index.md) | [Lab 10: Enterprise Prototype →](lab-10-enterprise-prototype.md) |
|:---|:---:|---:|
