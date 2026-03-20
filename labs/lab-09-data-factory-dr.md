---
layout: default
title: "Lab 9: Azure Data Factory – Active/Passive Data Pipelines"
---

[← Back to Index](../index.md)

# Lab 9: Azure Data Factory – Active/Passive Data Pipelines

<script>
document.documentElement.classList.add("lab-tabs-js");

document.addEventListener("DOMContentLoaded", () => {
  const storageKey = "azure-labs-preferred-tab";
  const validTabs = ["bash", "powershell", "portal"];
  const tabGroups = Array.from(document.querySelectorAll(".lab-tabs"));
  const copyIcon = `
    <svg viewBox="0 0 16 16" aria-hidden="true" focusable="false">
      <path d="M5.75 1A1.75 1.75 0 0 0 4 2.75v6.5C4 10.216 4.784 11 5.75 11h5.5A1.75 1.75 0 0 0 13 9.25v-6.5A1.75 1.75 0 0 0 11.25 1h-5.5Zm-.25 1.75c0-.138.112-.25.25-.25h5.5c.138 0 .25.112.25.25v6.5a.25.25 0 0 1-.25.25h-5.5a.25.25 0 0 1-.25-.25v-6.5Z"></path>
      <path d="M2.75 5A1.75 1.75 0 0 0 1 6.75v6.5C1 14.216 1.784 15 2.75 15h5.5A1.75 1.75 0 0 0 10 13.25V12H8.5v1.25a.25.25 0 0 1-.25.25h-5.5a.25.25 0 0 1-.25-.25v-6.5c0-.138.112-.25.25-.25H4V5H2.75Z"></path>
    </svg>
  `;
  const copiedIcon = `
    <svg viewBox="0 0 16 16" aria-hidden="true" focusable="false">
      <path d="M13.78 4.22a.75.75 0 0 1 0 1.06l-7.25 7.25a.75.75 0 0 1-1.06 0L2.22 9.28a.75.75 0 1 1 1.06-1.06L6 10.94l6.72-6.72a.75.75 0 0 1 1.06 0Z"></path>
    </svg>
  `;

  function setActiveTab(tabName) {
    const selectedTab = validTabs.includes(tabName) ? tabName : "bash";

    tabGroups.forEach((group) => {
      const buttons = group.querySelectorAll(".lab-tabs__button");
      const panels = group.querySelectorAll(".lab-tabs__panel");

      buttons.forEach((button) => {
        const isActive = button.dataset.tab === selectedTab;
        button.classList.toggle("is-active", isActive);
        button.setAttribute("aria-selected", String(isActive));
        button.tabIndex = isActive ? 0 : -1;
      });

      panels.forEach((panel) => {
        const isActive = panel.dataset.tabPanel === selectedTab;
        panel.classList.toggle("is-active", isActive);
        panel.hidden = !isActive;
      });
    });

    try {
      localStorage.setItem(storageKey, selectedTab);
    } catch (error) {
      console.warn("Could not persist tab preference", error);
    }
  }

  tabGroups.forEach((group) => {
    group.querySelectorAll(".lab-tabs__button").forEach((button) => {
      button.type = "button";
      button.setAttribute("role", "tab");
      button.addEventListener("click", () => setActiveTab(button.dataset.tab));
    });

    group.querySelectorAll(".lab-tabs__panel").forEach((panel) => {
      panel.setAttribute("role", "tabpanel");
    });
  });

  let preferredTab = "bash";
  try {
    const storedTab = localStorage.getItem(storageKey);
    if (validTabs.includes(storedTab)) {
      preferredTab = storedTab;
    }
  } catch (error) {
    console.warn("Could not read saved tab preference", error);
  }
  setActiveTab(preferredTab);

  const copyTargets = Array.from(
    document.querySelectorAll("div.highlighter-rouge, pre:not(.highlight)")
  );

  copyTargets.forEach((target) => {
    if (target.dataset.copyReady === "true") {
      return;
    }

    const codeElement = target.querySelector("code");
    if (!codeElement || !codeElement.innerText.trim()) {
      return;
    }

    target.dataset.copyReady = "true";
    target.classList.add("lab-copyable");

    const button = document.createElement("button");
    button.type = "button";
    button.className = "lab-copy-button";
    button.setAttribute("aria-label", "Copy code");
    button.innerHTML = copyIcon;

    button.addEventListener("click", async () => {
      const text = codeElement.innerText.replace(/\s+$/, "");

      try {
        await navigator.clipboard.writeText(text);
        button.classList.add("is-copied");
        button.innerHTML = copiedIcon;
        button.setAttribute("aria-label", "Copied");
        window.setTimeout(() => {
          button.classList.remove("is-copied");
          button.innerHTML = copyIcon;
          button.setAttribute("aria-label", "Copy code");
        }, 1500);
      } catch (error) {
        const range = document.createRange();
        const selection = window.getSelection();
        range.selectNodeContents(codeElement);
        selection.removeAllRanges();
        selection.addRange(range);
      }
    });

    target.appendChild(button);
  });
});
</script>

<style>
.lab-tabs {
  margin: 1rem 0 1.5rem;
  border: 1px solid #d0d7de;
  border-radius: 12px;
  overflow: hidden;
  background: #ffffff;
  box-shadow: 0 1px 2px rgba(16, 24, 40, 0.06);
}

.lab-tabs__list {
  display: flex;
  gap: 0.5rem;
  padding: 0.6rem;
  border-bottom: 1px solid #d0d7de;
  background: #f6f8fa;
  overflow-x: auto;
}

.lab-tabs__button {
  padding: 0.55rem 0.95rem;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: #57606a;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  white-space: nowrap;
  transition: background-color 0.15s ease, color 0.15s ease;
}

.lab-tabs__button:hover {
  background: rgba(9, 105, 218, 0.08);
  color: #0969da;
}

.lab-tabs__button.is-active {
  background: #ffffff;
  color: #0969da;
  box-shadow: inset 0 0 0 1px rgba(9, 105, 218, 0.16);
}

.lab-tabs__panel {
  padding: 1rem 1rem 0.25rem;
}

.lab-tabs__panel > :first-child {
  margin-top: 0;
}

html.lab-tabs-js .lab-tabs__panel {
  display: none;
}

html.lab-tabs-js .lab-tabs__panel.is-active {
  display: block;
}

.lab-note {
  padding: 0.9rem 1rem;
  margin: 1rem 0;
  border-left: 4px solid #0969da;
  background: #eff6ff;
  border-radius: 8px;
}

.lab-copyable {
  position: relative;
}

.lab-copy-button {
  position: absolute;
  top: 0.7rem;
  right: 0.7rem;
  width: 2rem;
  height: 2rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgba(27, 31, 36, 0.15);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.92);
  color: #57606a;
  cursor: pointer;
  z-index: 2;
}

.lab-copy-button:hover {
  background: #ffffff;
  color: #0969da;
}

.lab-copy-button.is-copied {
  color: #1a7f37;
}

.lab-copy-button svg {
  width: 1rem;
  height: 1rem;
  fill: currentColor;
}

.lab-copyable pre {
  padding-top: 2.6rem;
}

@media (max-width: 767px) {
  .lab-tabs__panel {
    padding: 0.9rem 0.8rem 0.2rem;
  }
}
</style>

## Overview

Azure Data Factory (ADF) is the cloud-based ETL/ELT service that orchestrates data movement and transformation across dozens of connectors. It powers nightly batch loads, incremental copies, and complex data-engineering workflows — the plumbing nobody notices until it stops running.

Here's the problem: **an ADF instance is bound to a single Azure region.** Unlike Cosmos DB or Storage, there is no built-in geo-replication button. If the region hosting your factory goes down, your pipelines stop, triggers don't fire, and data stops flowing.

The DR strategy for ADF is a **runbook-style, active/passive** approach:

| Concept | Detail |
|---------|--------|
| **No native geo-DR** | ADF doesn't replicate pipelines, linked services, or triggers to another region. |
| **Duplicate factories** | You maintain a secondary factory in a standby region with identical definitions. |
| **Git integration is key** | Connect ADF to Git so every definition is stored as JSON. Deploying to a second factory becomes a CI/CD step. |
| **Manual switchover** | Failover means enabling triggers in the secondary and disabling them in the primary. |
| **Data source availability** | Your DR factory is only useful if its sources and sinks are also reachable from the secondary region. |

In this lab you will create two ADF instances in **Sweden Central** and **Norway East**, build a simple pipeline in the primary, re-deploy it to the secondary, and run it in both factories.

> **⏱ Estimated time:** 45–60 minutes

---

## Architecture

```
              ┌─────────────────────────────────────────────────┐
              │              Git Repository (GitHub /            │
              │              Azure DevOps)                       │
              │  ┌──────────────────────────────────────────┐   │
              │  │  /pipeline/CopyHttpToBlob.json           │   │
              │  │  /linkedService/HttpSource.json          │   │
              │  │  /linkedService/BlobSink.json            │   │
              │  └──────────────┬───────────────┬───────────┘   │
              └─────────────────┼───────────────┼───────────────┘
                    CI/CD deploy│               │CI/CD deploy
                                │               │
                   ┌────────────▼───┐    ┌──────▼──────────────┐
                   │  PRIMARY ADF   │    │  SECONDARY ADF      │
                   │  adf-dr-swc    │    │  adf-dr-noe         │
                   │  Sweden Central│    │  Norway East        │
                   │                │    │                     │
                   │  Triggers: ON  │    │  Triggers: OFF      │
                   │  (active)      │    │  (standby)          │
                   └───────┬────────┘    └──────┬──────────────┘
                           │                    │
                           ▼                    ▼
              ┌─────────────────────────────────────────────────┐
              │          Shared / Replicated Data Sources        │
              │                                                 │
              │  ┌──────────────┐       ┌──────────────────┐   │
              │  │ Storage Acct │◄─ORS─►│ Storage Acct     │   │
              │  │ (Sweden Cntl)│       │ (Norway East)    │   │
              │  └──────────────┘       └──────────────────┘   │
              └─────────────────────────────────────────────────┘
```

**Key points:**

- The **primary ADF** runs all scheduled and event-driven pipelines.
- The **secondary ADF** holds identical definitions but keeps triggers **disabled**.
- Pipeline definitions live in **Git** and deploy to both factories via CI/CD.
- Data sources must be **available in both regions** — via geo-replication or globally reachable endpoints.
- **Failover** = enable secondary triggers, disable primary. No DNS alias to flip.

---

## Prerequisites

- [ ] **Azure subscription** with Contributor or Owner access.
- [ ] **Azure CLI** v2.60+ installed and authenticated (`az login`).
- [ ] The **datafactory** CLI extension (`az extension add --name datafactory`).
- [ ] Permission to assign **Storage Blob Data Contributor** on the lab storage accounts (or have that role pre-granted).
- [ ] Basic familiarity with ADF concepts (pipelines, linked services, datasets).

> ⚠️ **Important:** ADF itself has no per-run compute cost for orchestration, but the storage accounts created in this lab will incur charges. Clean up promptly.
>
> 🔒 **Security note:** This lab uses each factory's **system-assigned managed identity** to write to Blob Storage. Many enterprise subscriptions disable shared-key access on storage accounts, which breaks connection-string-based linked services.

---

## How These Tabs Work

This page uses a shared tab preference:

- If you click **Bash** in one step, the rest of the page switches to **Bash**
- The selection is remembered for the page in your browser
- Every code block gets a copy button in the top-right corner

---

## Step 1 — Set Variables

Use a single naming pattern through the rest of the lab.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
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
PRIMARY_BLOB_ENDPOINT="https://$STORAGE_PRIMARY.blob.core.windows.net/"
SECONDARY_BLOB_ENDPOINT="https://$STORAGE_SECONDARY.blob.core.windows.net/"

echo "Primary ADF      : $ADF_PRIMARY   ($PRIMARY_REGION)"
echo "Secondary ADF    : $ADF_SECONDARY ($SECONDARY_REGION)"
echo "Primary Storage  : $STORAGE_PRIMARY"
echo "Secondary Storage: $STORAGE_SECONDARY"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$UNIQUE_SUFFIX = Get-Random -Minimum 1000 -Maximum 9999
$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$RG_PRIMARY = "rg-adf-dr-swc"
$RG_SECONDARY = "rg-adf-dr-noe"

$ADF_PRIMARY = "adf-dr-swc-$UNIQUE_SUFFIX"
$ADF_SECONDARY = "adf-dr-noe-$UNIQUE_SUFFIX"

$STORAGE_PRIMARY = "stgadfdrswc$UNIQUE_SUFFIX"
$STORAGE_SECONDARY = "stgadfdrnoe$UNIQUE_SUFFIX"
$CONTAINER_NAME = "adf-landing"
$PRIMARY_BLOB_ENDPOINT = "https://$STORAGE_PRIMARY.blob.core.windows.net/"
$SECONDARY_BLOB_ENDPOINT = "https://$STORAGE_SECONDARY.blob.core.windows.net/"

Write-Host "Primary ADF      : $ADF_PRIMARY   ($PRIMARY_REGION)"
Write-Host "Secondary ADF    : $ADF_SECONDARY ($SECONDARY_REGION)"
Write-Host "Primary Storage  : $STORAGE_PRIMARY"
Write-Host "Secondary Storage: $STORAGE_SECONDARY"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Pick a numeric suffix so your factory and storage account names stay unique.
2. Record these values before you create resources:
   - Primary region: `swedencentral`
   - Secondary region: `norwayeast`
   - Resource groups: `rg-adf-dr-swc`, `rg-adf-dr-noe`
   - Factories: `adf-dr-swc-<suffix>`, `adf-dr-noe-<suffix>`
   - Storage accounts: `stgadfdrswc<suffix>`, `stgadfdrnoe<suffix>`
   - Container: `adf-landing`
   - Blob endpoints: `https://<storage>.blob.core.windows.net/`
3. Keep the values handy because you reuse the same names in both the portal and CLI flows.

      </div>
    </div>

---

## Step 2 — Install the Data Factory CLI Extension

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az extension add --name datafactory --upgrade --yes 2>/dev/null
az extension show --name datafactory --query version --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az extension add --name datafactory --upgrade --yes
az extension show --name datafactory --query version --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. If you are following the **Portal** path only, you can skip this step because authoring happens directly in the Data Factory studio.
2. If you want CLI parity, open **Azure Cloud Shell** from the portal toolbar.
3. Choose Bash or PowerShell in Cloud Shell and run the matching commands from the other tabs.
4. Confirm the `datafactory` extension version is installed before you rely on the CLI examples later in the lab.

      </div>
    </div>

---

## Step 3 — Create Resource Groups

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name $RG_PRIMARY  --location $PRIMARY_REGION  --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $PRIMARY_REGION --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Search for **Resource groups** in the Azure portal.
2. Create `rg-adf-dr-swc` in **Sweden Central**.
3. Create `rg-adf-dr-noe` in **Norway East**.
4. Verify both groups exist before you create storage or Data Factory resources.

      </div>
    </div>

---

## Step 4 — Create Storage Accounts

The sample pipeline copies data into Blob Storage. Create an account in each region so the secondary factory writes to a region-local sink.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account create   --name $STORAGE_PRIMARY   --resource-group $RG_PRIMARY   --location $PRIMARY_REGION   --sku Standard_LRS --kind StorageV2 --output table

az storage account create   --name $STORAGE_SECONDARY   --resource-group $RG_SECONDARY   --location $SECONDARY_REGION   --sku Standard_LRS --kind StorageV2 --output table

az storage container create --name $CONTAINER_NAME --account-name $STORAGE_PRIMARY  --auth-mode login
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_SECONDARY --auth-mode login
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account create `
  --name $STORAGE_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --sku Standard_LRS --kind StorageV2 --output table

az storage account create `
  --name $STORAGE_SECONDARY `
  --resource-group $RG_SECONDARY `
  --location $SECONDARY_REGION `
  --sku Standard_LRS --kind StorageV2 --output table

az storage container create --name $CONTAINER_NAME --account-name $STORAGE_PRIMARY --auth-mode login
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_SECONDARY --auth-mode login
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the Azure portal, search for **Storage accounts** and create the primary account in `rg-adf-dr-swc` / **Sweden Central**.
2. Create the secondary account in `rg-adf-dr-noe` / **Norway East**.
3. For each account, open **Containers** and create a private container named `adf-landing`.
4. Confirm both accounts and both containers are ready before you build the ADF linked services.

      </div>
    </div>

---

## Step 5 — Create the Primary Data Factory

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory create   --resource-group $RG_PRIMARY   --factory-name $ADF_PRIMARY   --location $PRIMARY_REGION   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --location $PRIMARY_REGION `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Search for **Data factories** and select **Create**.
2. Create the factory in `rg-adf-dr-swc` with region **Sweden Central**.
3. After deployment, open **Launch Studio** so you can author linked services, datasets, and pipelines.

      </div>
    </div>

> 💡 **Tip — Git integration:** In production, connect ADF to a Git repository so every pipeline and linked service is version-controlled. This makes deploying to a secondary factory a CI/CD step. We use the CLI here for simplicity.

---

## Step 6 — Create Linked Services in the Primary Factory

### 6a — Enable Managed Identity and Storage Access

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

az rest --method patch \
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_PRIMARY/providers/Microsoft.DataFactory/factories/$ADF_PRIMARY?api-version=2018-06-01" \
  --body "{\"name\":\"$ADF_PRIMARY\",\"location\":\"$PRIMARY_REGION\",\"identity\":{\"type\":\"SystemAssigned\"},\"properties\":{}}"

ADF_PRIMARY_PRINCIPAL_ID=$(az datafactory show \
  --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY \
  --query identity.principalId --output tsv)

PRIMARY_STORAGE_ID=$(az storage account show \
  --name $STORAGE_PRIMARY --resource-group $RG_PRIMARY \
  --query id --output tsv)

az role assignment create \
  --assignee-object-id $ADF_PRIMARY_PRINCIPAL_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope $PRIMARY_STORAGE_ID

echo "Waiting 60 seconds for RBAC to propagate..."
sleep 60
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SUBSCRIPTION_ID = az account show --query id --output tsv

$PrimaryFactoryPatch = @{
  name = $ADF_PRIMARY
  location = $PRIMARY_REGION
  identity = @{ type = "SystemAssigned" }
  properties = @{}
} | ConvertTo-Json -Depth 5 -Compress

az rest --method patch `
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_PRIMARY/providers/Microsoft.DataFactory/factories/$ADF_PRIMARY?api-version=2018-06-01" `
  --body $PrimaryFactoryPatch

$ADF_PRIMARY_PRINCIPAL_ID = az datafactory show `
  --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY `
  --query identity.principalId --output tsv

$PRIMARY_STORAGE_ID = az storage account show `
  --name $STORAGE_PRIMARY --resource-group $RG_PRIMARY `
  --query id --output tsv

az role assignment create `
  --assignee-object-id $ADF_PRIMARY_PRINCIPAL_ID `
  --assignee-principal-type ServicePrincipal `
  --role "Storage Blob Data Contributor" `
  --scope $PRIMARY_STORAGE_ID

Write-Host "Waiting 60 seconds for RBAC to propagate..."
Start-Sleep -Seconds 60
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary Data Factory and go to **Properties**.
2. Confirm the factory has a **Managed identity object ID**. If you created the factory in the portal, this is generated automatically.
3. Open the primary storage account, go to **Access control (IAM)**, and assign **Storage Blob Data Contributor** to that Data Factory managed identity.
4. Wait about a minute for the role assignment to propagate before you test the pipeline.

      </div>
    </div>

### 6b — HTTP Source Linked Service

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory linked-service create   --resource-group $RG_PRIMARY   --factory-name $ADF_PRIMARY   --linked-service-name "HttpSource"   --properties '{
    "type": "HttpServer",
    "typeProperties": {
      "url": "https://raw.githubusercontent.com/",
      "enableServerCertificateValidation": true,
      "authenticationType": "Anonymous"
    }
  }'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory linked-service create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --linked-service-name "HttpSource" `
  --properties '{"type":"HttpServer","typeProperties":{"url":"https://raw.githubusercontent.com/","enableServerCertificateValidation":true,"authenticationType":"Anonymous"}}'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Launch Studio** for the primary factory.
2. In **Manage** → **Linked services**, select **New**.
3. Choose **HTTP**.
4. Set the base URL to `https://raw.githubusercontent.com/` and use **Anonymous** authentication.
5. Test the connection, then create the linked service as `HttpSource`.

      </div>
    </div>

### 6c — Blob Storage Sink Linked Service

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory linked-service create --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY --linked-service-name "BlobSink" --properties '{"type":"AzureBlobStorage","typeProperties":{"serviceEndpoint":"'"$PRIMARY_BLOB_ENDPOINT"'","accountKind":"StorageV2"}}'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PrimaryBlobSink = '{"type":"AzureBlobStorage","typeProperties":{"serviceEndpoint":"' + $PRIMARY_BLOB_ENDPOINT + '","accountKind":"StorageV2"}}'
az datafactory linked-service create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --linked-service-name "BlobSink" `
  --properties $PrimaryBlobSink
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the primary factory studio, stay in **Manage** → **Linked services**.
2. Create another linked service and choose **Azure Blob Storage**.
3. Choose **Managed identity** authentication, point it at the primary storage account, then save it as `BlobSink`.
4. Test the connection so you know the factory can write to the landing container without shared keys.

      </div>
    </div>

---

## Step 7 — Create Datasets

### 7a — HTTP CSV Dataset (Source)

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory dataset create   --resource-group $RG_PRIMARY   --factory-name $ADF_PRIMARY   --dataset-name "HttpCsvDataset"   --properties '{
    "type": "DelimitedText",
    "linkedServiceName": { "referenceName": "HttpSource", "type": "LinkedServiceReference" },
    "typeProperties": {
      "location": {
        "type": "HttpServerLocation",
        "relativeUrl": "mwaskom/seaborn-data/master/iris.csv"
      },
      "columnDelimiter": ",",
      "firstRowAsHeader": true
    },
    "schema": []
  }'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory dataset create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --dataset-name "HttpCsvDataset" `
  --properties '{"type":"DelimitedText","linkedServiceName":{"referenceName":"HttpSource","type":"LinkedServiceReference"},"typeProperties":{"location":{"type":"HttpServerLocation","relativeUrl":"mwaskom/seaborn-data/master/iris.csv"},"columnDelimiter":",","firstRowAsHeader":true},"schema":[]}'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Author**, create a new dataset.
2. Choose **DelimitedText** as the format and **HTTP** as the connector.
3. Bind it to `HttpSource`.
4. Set the relative URL to `mwaskom/seaborn-data/master/iris.csv`.
5. Mark the first row as a header and save the dataset as `HttpCsvDataset`.

      </div>
    </div>

### 7b — Blob CSV Dataset (Sink)

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory dataset create --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY --dataset-name "BlobCsvDataset" --properties '{"type":"DelimitedText","linkedServiceName":{"referenceName":"BlobSink","type":"LinkedServiceReference"},"typeProperties":{"location":{"type":"AzureBlobStorageLocation","container":"'"$CONTAINER_NAME"'","fileName":"output.csv"},"columnDelimiter":",","firstRowAsHeader":true},"schema":[]}'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PrimaryBlobDataset = '{"type":"DelimitedText","linkedServiceName":{"referenceName":"BlobSink","type":"LinkedServiceReference"},"typeProperties":{"location":{"type":"AzureBlobStorageLocation","container":"' + $CONTAINER_NAME + '","fileName":"output.csv"},"columnDelimiter":",","firstRowAsHeader":true},"schema":[]}'
az datafactory dataset create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --dataset-name "BlobCsvDataset" `
  --properties $PrimaryBlobDataset
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Author**, create another **DelimitedText** dataset.
2. Choose **Azure Blob Storage** as the connector and bind it to `BlobSink`.
3. Point it at the `adf-landing` container and set the target file name to `output.csv`.
4. Save the dataset as `BlobCsvDataset`.

      </div>
    </div>

---

## Step 8 — Create a Pipeline in the Primary Factory

Create a **Copy Activity** pipeline that fetches a CSV from an HTTP endpoint and writes it to Blob Storage.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory pipeline create   --resource-group $RG_PRIMARY   --factory-name $ADF_PRIMARY   --pipeline-name "CopyHttpToBlob"   --pipeline '{
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

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory pipeline create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --pipeline-name "CopyHttpToBlob" `
  --pipeline '{"activities":[{"name":"CopyFromHttpToBlob","type":"Copy","typeProperties":{"source":{"type":"DelimitedTextSource","storeSettings":{"type":"HttpReadSettings","requestMethod":"GET"},"formatSettings":{"type":"DelimitedTextReadSettings"}},"sink":{"type":"DelimitedTextSink","storeSettings":{"type":"AzureBlobStorageWriteSettings"},"formatSettings":{"type":"DelimitedTextWriteSettings","quoteAllText":true,"fileExtension":".csv"}}},"inputs":[{"referenceName":"HttpCsvDataset","type":"DatasetReference"}],"outputs":[{"referenceName":"BlobCsvDataset","type":"DatasetReference"}]}]}'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Author**, create a new pipeline named `CopyHttpToBlob`.
2. Add a **Copy data** activity.
3. Set the source dataset to `HttpCsvDataset` and the sink dataset to `BlobCsvDataset`.
4. Validate the pipeline and publish the changes.

      </div>
    </div>

---

## Step 9 — Run the Pipeline in the Primary Factory

Start the primary pipeline, wait for it to complete, and verify the run result before you build the standby factory.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RUN_ID=$(az datafactory pipeline create-run   --resource-group $RG_PRIMARY   --factory-name $ADF_PRIMARY   --pipeline-name "CopyHttpToBlob"   --query runId --output tsv)

echo "Pipeline run started: $RUN_ID"
echo "Waiting for pipeline run to complete..."
while true; do
  STATUS=$(az datafactory pipeline-run show     --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY     --run-id $RUN_ID --query status --output tsv)
  echo "  Status: $STATUS"
  if [ "$STATUS" = "Succeeded" ] || [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ]; then
    break
  fi
  sleep 10
done

az datafactory pipeline-run show   --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY   --run-id $RUN_ID --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RUN_ID = az datafactory pipeline create-run `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --pipeline-name "CopyHttpToBlob" `
  --query runId --output tsv

Write-Host "Pipeline run started: $RUN_ID"
Write-Host "Waiting for pipeline run to complete..."
while ($true) {
  $STATUS = az datafactory pipeline-run show `
    --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY `
    --run-id $RUN_ID --query status --output tsv
  Write-Host "  Status: $STATUS"
  if ($STATUS -in @('Succeeded', 'Failed', 'Cancelled')) {
    break
  }
  Start-Sleep -Seconds 10
}

az datafactory pipeline-run show `
  --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY `
  --run-id $RUN_ID --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the primary factory studio, open the pipeline and select **Add trigger** → **Trigger now**.
2. Go to **Monitor**.
3. Watch the pipeline run until it completes.
4. Confirm the run finishes with **Succeeded** before you copy the design to the secondary factory.

      </div>
    </div>

**Expected output (key columns):**

```
RunId                                 PipelineName     Status
------------------------------------  ---------------  ---------
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  CopyHttpToBlob   Succeeded
```

> ✅ **Success!** The primary factory ran the pipeline and copied data to blob storage. Now let's set up the DR factory.

---

## Step 10 — Export the Primary Factory Definition

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory show   --resource-group $RG_PRIMARY   --factory-name $ADF_PRIMARY   --output json > adf-primary-factory.json

echo "Saved factory metadata to adf-primary-factory.json"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory show `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --output json | Set-Content -Path ./adf-primary-factory.json

Write-Host "Saved factory metadata to adf-primary-factory.json"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary factory studio.
2. Go to **Manage** → **ARM template**.
3. Use **Export ARM template** if you want the full deployable representation of pipelines, linked services, datasets, and triggers.
4. Keep the export for comparison as you recreate the standby factory.

      </div>
    </div>

<div class="lab-note">
<strong>Important:</strong> <code>az datafactory show</code> captures the factory resource metadata. For a full deployable export of pipelines, datasets, linked services, and triggers, use Git integration or the portal's <strong>Manage → ARM template</strong> experience.
</div>

---

## Step 11 — Create the Secondary Data Factory

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory create   --resource-group $RG_SECONDARY   --factory-name $ADF_SECONDARY   --location $SECONDARY_REGION   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory create `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --location $SECONDARY_REGION `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a second Data Factory in `rg-adf-dr-noe` with region **Norway East**.
2. Open **Launch Studio** for the standby factory.
3. Leave triggers disabled in the standby region; the goal is to keep definitions ready but inactive until failover.

      </div>
    </div>

---

## Step 12 — Deploy Definitions to the Secondary Factory

Re-create linked services, datasets, and the pipeline in the secondary factory, pointing to the **secondary** storage account.

### 12a — Enable Managed Identity and Storage Access

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

az rest --method patch \
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_SECONDARY/providers/Microsoft.DataFactory/factories/$ADF_SECONDARY?api-version=2018-06-01" \
  --body "{\"name\":\"$ADF_SECONDARY\",\"location\":\"$SECONDARY_REGION\",\"identity\":{\"type\":\"SystemAssigned\"},\"properties\":{}}"

ADF_SECONDARY_PRINCIPAL_ID=$(az datafactory show \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --query identity.principalId --output tsv)

SECONDARY_STORAGE_ID=$(az storage account show \
  --name $STORAGE_SECONDARY --resource-group $RG_SECONDARY \
  --query id --output tsv)

az role assignment create \
  --assignee-object-id $ADF_SECONDARY_PRINCIPAL_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope $SECONDARY_STORAGE_ID

echo "Waiting 60 seconds for RBAC to propagate..."
sleep 60
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SUBSCRIPTION_ID = az account show --query id --output tsv

$SecondaryFactoryPatch = @{
  name = $ADF_SECONDARY
  location = $SECONDARY_REGION
  identity = @{ type = "SystemAssigned" }
  properties = @{}
} | ConvertTo-Json -Depth 5 -Compress

az rest --method patch `
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_SECONDARY/providers/Microsoft.DataFactory/factories/$ADF_SECONDARY?api-version=2018-06-01" `
  --body $SecondaryFactoryPatch

$ADF_SECONDARY_PRINCIPAL_ID = az datafactory show `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --query identity.principalId --output tsv

$SECONDARY_STORAGE_ID = az storage account show `
  --name $STORAGE_SECONDARY --resource-group $RG_SECONDARY `
  --query id --output tsv

az role assignment create `
  --assignee-object-id $ADF_SECONDARY_PRINCIPAL_ID `
  --assignee-principal-type ServicePrincipal `
  --role "Storage Blob Data Contributor" `
  --scope $SECONDARY_STORAGE_ID

Write-Host "Waiting 60 seconds for RBAC to propagate..."
Start-Sleep -Seconds 60
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the secondary Data Factory and confirm it has a **Managed identity object ID**.
2. Open the secondary storage account, go to **Access control (IAM)**, and assign **Storage Blob Data Contributor** to that Data Factory managed identity.
3. Wait about a minute for the role assignment to propagate.
4. Use managed identity authentication in the standby Blob linked service.

      </div>
    </div>

### 12b — Linked Services

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
# HTTP Source — identical (globally reachable, no region dependency)
az datafactory linked-service create   --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY   --linked-service-name "HttpSource"   --properties '{
    "type": "HttpServer",
    "typeProperties": {
      "url": "https://raw.githubusercontent.com/",
      "enableServerCertificateValidation": true,
      "authenticationType": "Anonymous"
    }
  }'

# Blob Sink — points to the SECONDARY storage account
az datafactory linked-service create --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY --linked-service-name "BlobSink" --properties '{"type":"AzureBlobStorage","typeProperties":{"serviceEndpoint":"'"$SECONDARY_BLOB_ENDPOINT"'","accountKind":"StorageV2"}}'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory linked-service create `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --linked-service-name "HttpSource" `
  --properties '{"type":"HttpServer","typeProperties":{"url":"https://raw.githubusercontent.com/","enableServerCertificateValidation":true,"authenticationType":"Anonymous"}}'

$SecondaryBlobSink = '{"type":"AzureBlobStorage","typeProperties":{"serviceEndpoint":"' + $SECONDARY_BLOB_ENDPOINT + '","accountKind":"StorageV2"}}'
az datafactory linked-service create `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --linked-service-name "BlobSink" `
  --properties $SecondaryBlobSink
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the secondary factory studio, create the same `HttpSource` linked service you used in the primary region.
2. Create `BlobSink` again with **Managed identity** authentication, but bind it to the **Norway East** storage account this time.
3. Test both connections.
4. This is the key DR check: the HTTP source stays the same, while the sink becomes region-local.

      </div>
    </div>

> ⚠️ **Important:** The HTTP linked service is identical in both factories, but the Blob linked service points to the **secondary** storage account. In production, parameterize storage endpoints and keep the matching managed-identity RBAC assignments in place for each region.

### 12c — Datasets

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory dataset create   --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY   --dataset-name "HttpCsvDataset"   --properties '{
    "type": "DelimitedText",
    "linkedServiceName": { "referenceName": "HttpSource", "type": "LinkedServiceReference" },
    "typeProperties": {
      "location": {
        "type": "HttpServerLocation",
        "relativeUrl": "mwaskom/seaborn-data/master/iris.csv"
      },
      "columnDelimiter": ",", "firstRowAsHeader": true
    },
    "schema": []
  }'

az datafactory dataset create --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY --dataset-name "BlobCsvDataset" --properties '{"type":"DelimitedText","linkedServiceName":{"referenceName":"BlobSink","type":"LinkedServiceReference"},"typeProperties":{"location":{"type":"AzureBlobStorageLocation","container":"'"$CONTAINER_NAME"'","fileName":"output.csv"},"columnDelimiter":",","firstRowAsHeader":true},"schema":[]}'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory dataset create `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --dataset-name "HttpCsvDataset" `
  --properties '{"type":"DelimitedText","linkedServiceName":{"referenceName":"HttpSource","type":"LinkedServiceReference"},"typeProperties":{"location":{"type":"HttpServerLocation","relativeUrl":"mwaskom/seaborn-data/master/iris.csv"},"columnDelimiter":",","firstRowAsHeader":true},"schema":[]}'

$SecondaryBlobDataset = '{"type":"DelimitedText","linkedServiceName":{"referenceName":"BlobSink","type":"LinkedServiceReference"},"typeProperties":{"location":{"type":"AzureBlobStorageLocation","container":"' + $CONTAINER_NAME + '","fileName":"output.csv"},"columnDelimiter":",","firstRowAsHeader":true},"schema":[]}'
az datafactory dataset create `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --dataset-name "BlobCsvDataset" `
  --properties $SecondaryBlobDataset
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Recreate `HttpCsvDataset` and `BlobCsvDataset` in the standby factory.
2. Keep the same dataset names so your pipeline JSON and CI/CD process stay consistent across regions.
3. For the blob dataset, verify the destination container is `adf-landing` in the Norway East storage account.

      </div>
    </div>

### 12d — Pipeline

Use the same pipeline definition as Step 8:

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory pipeline create   --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY   --pipeline-name "CopyHttpToBlob"   --pipeline '{
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

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory pipeline create `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --pipeline-name "CopyHttpToBlob" `
  --pipeline '{"activities":[{"name":"CopyFromHttpToBlob","type":"Copy","typeProperties":{"source":{"type":"DelimitedTextSource","storeSettings":{"type":"HttpReadSettings","requestMethod":"GET"},"formatSettings":{"type":"DelimitedTextReadSettings"}},"sink":{"type":"DelimitedTextSink","storeSettings":{"type":"AzureBlobStorageWriteSettings"},"formatSettings":{"type":"DelimitedTextWriteSettings","quoteAllText":true,"fileExtension":".csv"}}},"inputs":[{"referenceName":"HttpCsvDataset","type":"DatasetReference"}],"outputs":[{"referenceName":"BlobCsvDataset","type":"DatasetReference"}]}]}'
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Recreate `CopyHttpToBlob` in the standby factory, or import it from your ARM/Git source of truth.
2. Confirm the source dataset is still `HttpCsvDataset` and the sink dataset is `BlobCsvDataset`.
3. Publish the changes to the standby factory.

      </div>
    </div>

---

## Step 13 — Run the Pipeline in the Secondary Factory

Validate that the standby factory is fully functional.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RUN_ID_SECONDARY=$(az datafactory pipeline create-run   --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY   --pipeline-name "CopyHttpToBlob"   --query runId --output tsv)

echo "Secondary pipeline run started: $RUN_ID_SECONDARY"
echo "Waiting for secondary pipeline run to complete..."
while true; do
  STATUS=$(az datafactory pipeline-run show     --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY     --run-id $RUN_ID_SECONDARY --query status --output tsv)
  echo "  Status: $STATUS"
  if [ "$STATUS" = "Succeeded" ] || [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ]; then
    break
  fi
  sleep 10
done

az datafactory pipeline-run show   --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY   --run-id $RUN_ID_SECONDARY --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RUN_ID_SECONDARY = az datafactory pipeline create-run `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --pipeline-name "CopyHttpToBlob" `
  --query runId --output tsv

Write-Host "Secondary pipeline run started: $RUN_ID_SECONDARY"
Write-Host "Waiting for secondary pipeline run to complete..."
while ($true) {
  $STATUS = az datafactory pipeline-run show `
    --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
    --run-id $RUN_ID_SECONDARY --query status --output tsv
  Write-Host "  Status: $STATUS"
  if ($STATUS -in @('Succeeded', 'Failed', 'Cancelled')) {
    break
  }
  Start-Sleep -Seconds 10
}

az datafactory pipeline-run show `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --run-id $RUN_ID_SECONDARY --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the standby factory studio, open `CopyHttpToBlob`.
2. Select **Add trigger** → **Trigger now**.
3. Use **Monitor** to watch the run.
4. Confirm the standby factory can complete the run successfully while writing to the Norway East storage account.

      </div>
    </div>

> ✅ **Success!** Both factories can run the same pipeline. The secondary is ready to take over if the primary region becomes unavailable.

---

## Step 14 — Verify Data in Both Storage Accounts

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "=== Primary Storage ==="
az storage blob list --container-name $CONTAINER_NAME   --account-name $STORAGE_PRIMARY --auth-mode login   --query "[].name" --output table

echo ""
echo "=== Secondary Storage ==="
az storage blob list --container-name $CONTAINER_NAME   --account-name $STORAGE_SECONDARY --auth-mode login   --query "[].name" --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "=== Primary Storage ==="
az storage blob list --container-name $CONTAINER_NAME `
  --account-name $STORAGE_PRIMARY --auth-mode login `
  --query "[].name" --output table

Write-Host ""
Write-Host "=== Secondary Storage ==="
az storage blob list --container-name $CONTAINER_NAME `
  --account-name $STORAGE_SECONDARY --auth-mode login `
  --query "[].name" --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary storage account and browse to **Containers** → `adf-landing`.
2. Confirm `output.csv` exists.
3. Repeat the same check in the secondary storage account.
4. Seeing `output.csv` in both locations proves both factories can execute the same design against region-local storage.

      </div>
    </div>

You should see `output.csv` in both storage accounts.

---

## Cleanup

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name $RG_PRIMARY   --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
rm -f adf-primary-factory.json

echo "Cleanup initiated. Both resource groups are being deleted."
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
Remove-Item -Path ./adf-primary-factory.json -ErrorAction SilentlyContinue

Write-Host "Cleanup initiated. Both resource groups are being deleted."
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Delete `rg-adf-dr-swc` and `rg-adf-dr-noe` when you are done with the lab.
3. If you exported metadata or ARM files locally, remove them from your workstation or Cloud Shell storage when you no longer need them.

      </div>
    </div>

After a few minutes, verify:

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group show --name $RG_PRIMARY 2>&1 | head -1
az group show --name $RG_SECONDARY 2>&1 | head -1
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group show --name $RG_PRIMARY --output none 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Primary resource group deleted" }

az group show --name $RG_SECONDARY --output none 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Secondary resource group deleted" }
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Refresh the **Resource groups** list in the portal.
2. Confirm both lab resource groups disappear or show as deleting.
3. Wait until deletion finishes before you assume costs have stopped.

      </div>
    </div>

Both should return `Resource group 'rg-adf-dr-*' could not be found.`

---

## Discussion — Making ADF DR Production-Ready

### CI/CD-Driven Deployment

In production, **never** copy pipeline definitions by hand. Instead:

1. **Connect ADF to Git** (Azure DevOps or GitHub). Every pipeline, linked service, and trigger is stored as JSON.
2. **Use a release pipeline** that deploys ARM/Bicep templates to **both** factories on every merge to `main`.
3. **Parameterize** region-specific values (storage endpoints, server names, Key Vault URIs) so one template works in any region.

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

> 💡 **Tip:** The [ADF CI/CD docs](https://learn.microsoft.com/azure/data-factory/continuous-integration-delivery) include pre/post-deployment scripts that handle trigger start/stop automatically.

### ARM Template Export/Import

If you skip Git integration, export from the portal and deploy manually:

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az deployment group create   --resource-group $RG_SECONDARY   --template-file ARMTemplateForFactory.json   --parameters factoryName=$ADF_SECONDARY   --parameters BlobSink_serviceEndpoint="$SECONDARY_BLOB_ENDPOINT"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az deployment group create `
  --resource-group $RG_SECONDARY `
  --template-file ARMTemplateForFactory.json `
  --parameters factoryName=$ADF_SECONDARY `
  --parameters BlobSink_serviceEndpoint="$SECONDARY_BLOB_ENDPOINT"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Export the full ARM template from the primary factory's **Manage** → **ARM template** experience.
2. In the Azure portal, search for **Deploy a custom template**.
3. Select the secondary resource group, upload the exported template, and override region-specific parameters such as the factory name and Blob service endpoint.
4. Review the deployment before you submit it.

      </div>
    </div>

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

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
TRIGGERS=$(az datafactory trigger list   --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY   --query "[].name" --output tsv)

for TRIGGER in $TRIGGERS; do
  az datafactory trigger start     --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY     --trigger-name $TRIGGER
  echo "Started trigger: $TRIGGER"
done
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$TRIGGERS = az datafactory trigger list `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --query "[].name" --output tsv

foreach ($TRIGGER in ($TRIGGERS -split "`n" | Where-Object { $_ })) {
  az datafactory trigger start `
    --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
    --trigger-name $TRIGGER
  Write-Host "Started trigger: $TRIGGER"
}
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the standby factory studio, open **Manage** → **Triggers**.
2. Start the required triggers on the secondary factory.
3. In the primary factory, stop the equivalent triggers so you do not process the same workload twice.
4. Validate trigger state in **Monitor** after the switchover runbook completes.

      </div>
    </div>

### Key Takeaways

1. **ADF has no native geo-DR** — maintain duplicate factories.
2. **Git + CI/CD** is the right way to keep both factories in sync.
3. **Parameterize everything** so one template deploys to any region.
4. **SHIR nodes** need separate instances in each region.
5. **Data source DR** is just as critical — if the source isn't available, the pipeline can't run.
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
