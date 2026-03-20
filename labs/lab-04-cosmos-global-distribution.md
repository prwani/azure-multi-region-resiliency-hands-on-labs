---
layout: default
title: "Lab 4: Azure Cosmos DB – Global Distribution"
---

[← Back to Index](../index.md)

# Lab 4: Azure Cosmos DB – Global Distribution

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

## Introduction

Azure Cosmos DB is Microsoft's globally distributed, multi-model database service
for mission-critical workloads. Unlike traditional databases that require custom
replication pipelines and failover logic, Cosmos DB gives you **built-in global
distribution**, **multi-region replication**, and **transparent failover**.

### Why Cosmos DB Global Distribution Matters

| Capability | Benefit |
|---|---|
| **Turnkey global distribution** | Add or remove Azure regions with no application redesign |
| **Multi-region writes (active-active)** | Accept writes close to users in more than one geography |
| **Five tunable consistency levels** | Choose the trade-off between consistency, latency, and availability |
| **Automatic & manual failover** | Let the platform recover automatically or rehearse your own DR process |
| **99.999% read availability SLA** | Increase availability when you run in multiple regions |
| **Transparent multi-homing** | SDKs can route to the nearest healthy region automatically |

In this lab you will:

1. Create a Cosmos DB for NoSQL account in **Sweden Central**.
2. Add **Norway East** as a secondary region.
3. Enable **multi-region writes** for an active-active topology.
4. Create a database and container.
5. Insert and query sample order documents.
6. Enable **automatic failover** and then perform a **manual failover** drill.
7. Verify the account still works after failover.
8. Fail back to the original primary region and clean up resources.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Cosmos DB Account                                │
│                  (cosmos-multiregion-XXXXX)                             │
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
│  │                  │  │                  │                             │
│  │  ┌────────────┐  │  │  ┌────────────┐  │                             │
│  │  │ Partition  │  │  │  │ Replica    │  │                             │
│  │  │ Set 1      │◄─┼──┼─►│ Set 1      │  │                             │
│  │  └────────────┘  │  │  └────────────┘  │                             │
│  │  ┌────────────┐  │  │  ┌────────────┐  │                             │
│  │  │ Partition  │  │  │  │ Replica    │  │                             │
│  │  │ Set 2      │◄─┼──┼─►│ Set 2      │  │                             │
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

- The **global endpoint** stays the same even when the primary region changes.
- With **multi-region writes** enabled, both regions can accept writes locally.
- **Zone redundancy** protects each region from a zonal outage at no extra cost.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Azure subscription | Contributor or higher on the target subscription or resource group |
| Azure CLI | v2.60 or later, signed in with `az login` (Bash path only) |
| Az PowerShell module | `Az.CosmosDB` and `Az.Resources` (PowerShell path) — install with `Install-Module Az` if needed |
| Bash path | Bash with `curl` and `python3` available (Azure Cloud Shell includes both) |
| PowerShell path | PowerShell 7+ with the `Az` module (`Connect-AzAccount` to sign in) |
| Portal access | Needed for the portal path and Data Explorer |

<div class="lab-note">
<strong>Data-plane note:</strong> Current Azure CLI releases manage the Cosmos DB account, database, and container just fine, but they do not provide GA NoSQL item/query commands. For item creation and querying, this lab uses the supported Cosmos DB REST API in Bash and PowerShell, or <strong>Data Explorer</strong> in the Azure portal. If your account has <strong>Local Authorization</strong> disabled, the validation script falls back to Microsoft Entra ID plus Cosmos native RBAC instead of the key-based examples below.
</div>

---

## How These Tabs Work

This page uses a shared tab preference:

- If you click **Bash**, **PowerShell**, or **Portal** in one step, the rest of the page follows that choice
- The selection is remembered for the page in your browser
- Every code block gets a copy button in the top-right corner

---

## Sign In and Select the Subscription

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Connect-AzAccount
Get-AzSubscription | Select-Object Name, Id | Format-Table -AutoSize
Set-AzContext -SubscriptionId "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the [Azure portal](https://portal.azure.com).
2. If needed, switch to the correct tenant or directory.
3. Open **Subscriptions** and confirm the subscription you want to use.

</div>
</div>

---

## Step 1 — Define Variables

Use one naming pattern for the rest of the lab.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RANDOM_SUFFIX="$(tr -dc '0-9' </dev/urandom | head -c 5)"

export RG="rg-cosmos-global-lab"
export LOCATION_PRIMARY="swedencentral"
export LOCATION_SECONDARY="norwayeast"
export COSMOS_ACCOUNT="cosmos-multiregion-${RANDOM_SUFFIX}"
export DATABASE_NAME="db-sample"
export CONTAINER_NAME="container-orders"
export PARTITION_KEY="/customerId"
export COSMOS_API_VERSION="2018-12-31"
export COSMOS_DOCS_RESOURCE_LINK="dbs/${DATABASE_NAME}/colls/${CONTAINER_NAME}"
export COSMOS_DOCS_PATH="dbs/${DATABASE_NAME}/colls/${CONTAINER_NAME}/docs"

echo "Resource group    : $RG"
echo "Primary region    : $LOCATION_PRIMARY"
echo "Secondary region  : $LOCATION_SECONDARY"
echo "Cosmos account    : $COSMOS_ACCOUNT"
echo "Database          : $DATABASE_NAME"
echo "Container         : $CONTAINER_NAME"
echo "Partition key     : $PARTITION_KEY"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = Get-Random -Minimum 10000 -Maximum 100000

$RG = "rg-cosmos-global-lab"
$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"
$COSMOS_ACCOUNT = "cosmos-multiregion-$RANDOM_SUFFIX"
$DATABASE_NAME = "db-sample"
$CONTAINER_NAME = "container-orders"
$PARTITION_KEY = "/customerId"
$COSMOS_API_VERSION = "2018-12-31"
$COSMOS_DOCS_RESOURCE_LINK = "dbs/$DATABASE_NAME/colls/$CONTAINER_NAME"
$COSMOS_DOCS_PATH = "dbs/$DATABASE_NAME/colls/$CONTAINER_NAME/docs"

Write-Host "Resource group    : $RG"
Write-Host "Primary region    : $LOCATION_PRIMARY"
Write-Host "Secondary region  : $LOCATION_SECONDARY"
Write-Host "Cosmos account    : $COSMOS_ACCOUNT"
Write-Host "Database          : $DATABASE_NAME"
Write-Host "Container         : $CONTAINER_NAME"
Write-Host "Partition key     : $PARTITION_KEY"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Choose or write down these values before you start:

- Resource group: `rg-cosmos-global-lab`
- Primary region: `swedencentral`
- Secondary region: `norwayeast`
- Cosmos account: `cosmos-multiregion-&lt;suffix&gt;`
- Database: `db-sample`
- Container: `container-orders`
- Partition key: `/customerId`

</div>
</div>

<div class="lab-note">
<strong>Tip:</strong> Keep the same shell or PowerShell session open. Steps 8, 9, and 12 reuse the variables and helper functions defined earlier.
</div>

---

## Step 2 — Create the Resource Group

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create \
  --name "$RG" \
  --location "$LOCATION_PRIMARY" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION_PRIMARY
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Create a new resource group named `rg-cosmos-global-lab`.
3. Choose **Sweden Central** as the region.

</div>
</div>

---

## Step 3 — Create the Cosmos DB Account (Single Region)

Create a Cosmos DB for NoSQL account in **Sweden Central** with **Session**
consistency and **zone redundancy** enabled.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb create \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --locations regionName="$LOCATION_PRIMARY" failoverPriority=0 isZoneRedundant=true \
  --default-consistency-level Session \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "{Name:name, Status:provisioningState, Consistency:consistencyPolicy.defaultConsistencyLevel, WriteRegions:writeLocations[].locationName, ReadRegions:readLocations[].locationName}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$primaryLocation = New-AzCosmosDBLocationObject `
  -LocationName $LOCATION_PRIMARY `
  -FailoverPriority 0 `
  -IsZoneRedundant $true

New-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -Location @($primaryLocation) `
  -DefaultConsistencyLevel "Session"

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG
[pscustomobject]@{
  Name         = $account.Name
  Status       = $account.ProvisioningState
  Consistency  = $account.ConsistencyPolicy.DefaultConsistencyLevel
  WriteRegions = $account.WriteLocations.LocationName -join ", "
  ReadRegions  = $account.ReadLocations.LocationName -join ", "
}
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Azure Cosmos DB** and select **Create**.
2. Choose **Azure Cosmos DB for NoSQL**.
3. On **Basics**, use:
   - Resource group: `rg-cosmos-global-lab`
   - Account name: `cosmos-multiregion-&lt;suffix&gt;`
   - Region: **Sweden Central**
4. Keep the default **Session** consistency level.
5. If the wizard shows **Availability zones** or **Zone redundancy**, turn it on.
6. Create the account and wait for deployment to finish.

</div>
</div>

<div class="lab-note">
<strong>Expect a wait:</strong> Cosmos DB account creation can take 5–10 minutes. When the account is ready, you should see <code>swedencentral</code> as the only region.
</div>

---

## Step 4 — Add Norway East as a Secondary Region

Expand the account to a second region.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --locations regionName="$LOCATION_PRIMARY" failoverPriority=0 isZoneRedundant=true \
  --locations regionName="$LOCATION_SECONDARY" failoverPriority=1 isZoneRedundant=true \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "readLocations[].{Region:locationName, Priority:failoverPriority, ZoneRedundant:isZoneRedundant}" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$primaryLocation = New-AzCosmosDBLocationObject `
  -LocationName $LOCATION_PRIMARY `
  -FailoverPriority 0 `
  -IsZoneRedundant $true

$secondaryLocation = New-AzCosmosDBLocationObject `
  -LocationName $LOCATION_SECONDARY `
  -FailoverPriority 1 `
  -IsZoneRedundant $true

Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -Location @($primaryLocation, $secondaryLocation)

Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG |
  Select-Object -ExpandProperty ReadLocations |
  Select-Object LocationName, FailoverPriority, IsZoneRedundant |
  Format-Table -AutoSize
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open your Cosmos DB account.
2. Go to **Global distribution**.
3. Add **Norway East** as a new region.
4. Keep **Sweden Central** at priority `0` and set **Norway East** to priority `1`.
5. Save the change and wait for regional replication to complete.

</div>
</div>

<div class="lab-note">
<strong>Tip:</strong> When you update Cosmos DB regions, include the full intended region list. You are describing the desired topology, not appending to it one region at a time.
</div>

---

## Step 5 — Enable Multi-Region Writes

By default, only the primary region accepts writes. Enable multi-region writes so
both regions can act as write endpoints.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --enable-multiple-write-locations true \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "{MultiRegionWrites:enableMultipleWriteLocations, WriteRegions:writeLocations[].locationName}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -EnableMultipleWriteLocations $true

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG
[pscustomobject]@{
  MultiRegionWrites = $account.EnableMultipleWriteLocations
  WriteRegions      = $account.WriteLocations.LocationName -join ", "
}
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the Cosmos DB account, open **Global distribution**.
2. Turn on **Enable multiple write regions**.
3. Save the change.
4. Confirm both **Sweden Central** and **Norway East** show write capability after the update completes.

</div>
</div>

<div class="lab-note">
<strong>Caution:</strong> Multi-region writes increase write RU consumption because each write must be replicated to every region. Leave this off in production unless you genuinely need low-latency writes in multiple geographies.
</div>

---

## Step 6 — Create the Database

Create a SQL database inside the Cosmos DB account.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb sql database create \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --name "$DATABASE_NAME" \
  --output table

az cosmosdb sql database show \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --name "$DATABASE_NAME" \
  --query "{Database:name}" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzCosmosDBSqlDatabase `
  -AccountName $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -Name $DATABASE_NAME

Get-AzCosmosDBSqlDatabase `
  -AccountName $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -Name $DATABASE_NAME |
  Select-Object @{n = "Database"; e = { $_.Name }}
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Data Explorer** in the Cosmos DB account.
2. Select **New Database**.
3. Name the database `db-sample`.
4. Leave shared throughput off so the next step can assign dedicated throughput at the container level.

</div>
</div>

---

## Step 7 — Create the Container

Create a container with a partition key and dedicated 400 RU/s throughput.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb sql container create \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --database-name "$DATABASE_NAME" \
  --name "$CONTAINER_NAME" \
  --partition-key-path "$PARTITION_KEY" \
  --throughput 400 \
  --output table

az cosmosdb sql container show \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --database-name "$DATABASE_NAME" \
  --name "$CONTAINER_NAME" \
  --query "{Container:name, PartitionKey:resource.partitionKey.paths[0]}" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzCosmosDBSqlContainer `
  -AccountName $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -DatabaseName $DATABASE_NAME `
  -Name $CONTAINER_NAME `
  -PartitionKeyPath $PARTITION_KEY `
  -Throughput 400

Get-AzCosmosDBSqlContainer `
  -AccountName $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -DatabaseName $DATABASE_NAME `
  -Name $CONTAINER_NAME |
  Select-Object @{n = "Container"; e = { $_.Name }},
    @{n = "PartitionKey"; e = { $_.Resource.PartitionKey.Paths[0] }}
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Data Explorer**, select **New Container** inside `db-sample`.
2. Use:
   - Container id: `container-orders`
   - Partition key: `/customerId`
   - Dedicated throughput: `400 RU/s`
3. Create the container.

</div>
</div>

<div class="lab-note">
<strong>Why <code>/customerId</code>?</strong> Orders for the same customer land in the same logical partition, which keeps customer-scoped queries efficient and makes the partitioning strategy easy to understand in this lab.
</div>

---

## Step 8 — Insert Sample Documents

Retrieve the account endpoint and key, then create three sample order documents.

<div class="lab-note">
<strong>Security note:</strong> The Bash and PowerShell examples use the account primary key for the simplest lab flow. In production, prefer the SDK with Microsoft Entra ID and Cosmos DB RBAC instead of distributing account keys. If your subscription disables <strong>Local Authorization</strong>, switch to an Entra access token for <code>https://cosmos.azure.com/</code> and grant the current user the <strong>Cosmos DB Built-in Data Contributor</strong> role.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
export COSMOS_ENDPOINT="$(az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "documentEndpoint" \
  --output tsv)"

export COSMOS_KEY="$(az cosmosdb keys list \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "primaryMasterKey" \
  --output tsv)"

cosmos_auth_token() {
  local verb="$1"
  local resource_type="$2"
  local resource_link="$3"
  local request_date="$4"

  python3 - "$verb" "$resource_type" "$resource_link" "$request_date" "$COSMOS_KEY" <<'PY'
import base64
import hashlib
import hmac
import sys
import urllib.parse

verb, resource_type, resource_link, request_date, master_key = sys.argv[1:]
payload = f"{verb.lower()}\n{resource_type.lower()}\n{resource_link}\n{request_date.lower()}\n\n"
signature = base64.b64encode(
    hmac.new(
        base64.b64decode(master_key),
        payload.encode("utf-8"),
        hashlib.sha256,
    ).digest()
).decode("utf-8")
print(urllib.parse.quote(f"type=master&ver=1.0&sig={signature}", safe=""))
PY
}

cosmos_request() {
  local method="$1"
  local resource_type="$2"
  local resource_link="$3"
  local resource_path="$4"
  local content_type="$5"
  local body="$6"
  shift 6

  local request_date
  request_date="$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S GMT')"

  local auth_token
  auth_token="$(cosmos_auth_token "$method" "$resource_type" "$resource_link" "$request_date")"

  local curl_args=(
    --silent
    --show-error
    --fail
    --request "$method"
    --url "${COSMOS_ENDPOINT}${resource_path}"
    --header "authorization: $auth_token"
    --header "x-ms-date: $request_date"
    --header "x-ms-version: ${COSMOS_API_VERSION}"
    --header "Content-Type: $content_type"
  )

  while (($#)); do
    curl_args+=(--header "$1")
    shift
  done

  curl_args+=(--data "$body")
  curl "${curl_args[@]}"
}

cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/json" \
  '{"id":"order-001","customerId":"customer-100","product":"Azure Reserved VM Instance","quantity":3,"region":"swedencentral","status":"confirmed","createdAt":"2024-06-15T10:30:00Z"}' \
  'x-ms-documentdb-is-upsert: True' \
  'x-ms-documentdb-partitionkey: ["customer-100"]' >/dev/null

cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/json" \
  '{"id":"order-002","customerId":"customer-200","product":"Azure Cosmos DB Reserved Capacity","quantity":1,"region":"norwayeast","status":"pending","createdAt":"2024-06-15T11:00:00Z"}' \
  'x-ms-documentdb-is-upsert: True' \
  'x-ms-documentdb-partitionkey: ["customer-200"]' >/dev/null

cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/json" \
  '{"id":"order-003","customerId":"customer-100","product":"Azure Front Door Premium","quantity":1,"region":"swedencentral","status":"shipped","createdAt":"2024-06-15T14:45:00Z"}' \
  'x-ms-documentdb-is-upsert: True' \
  'x-ms-documentdb-partitionkey: ["customer-100"]' >/dev/null

echo "Inserted sample documents into $CONTAINER_NAME"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$COSMOS_ENDPOINT = az cosmosdb show `
  --name $COSMOS_ACCOUNT `
  --resource-group $RG `
  --query "documentEndpoint" `
  --output tsv

$COSMOS_KEY = az cosmosdb keys list `
  --name $COSMOS_ACCOUNT `
  --resource-group $RG `
  --query "primaryMasterKey" `
  --output tsv

function New-CosmosMasterKeyAuthorizationToken {
  param(
    [Parameter(Mandatory)][string]$Verb,
    [Parameter(Mandatory)][string]$ResourceType,
    [Parameter(Mandatory)][string]$ResourceLink,
    [Parameter(Mandatory)][string]$Date,
    [Parameter(Mandatory)][string]$MasterKey
  )

  $payload = "{0}`n{1}`n{2}`n{3}`n`n" -f `
    $Verb.ToLowerInvariant(), `
    $ResourceType.ToLowerInvariant(), `
    $ResourceLink, `
    $Date.ToLowerInvariant()

  $hmac = [System.Security.Cryptography.HMACSHA256]::new([Convert]::FromBase64String($MasterKey))
  try {
    $signature = [Convert]::ToBase64String(
      $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payload))
    )
  }
  finally {
    $hmac.Dispose()
  }

  [Uri]::EscapeDataString("type=master&ver=1.0&sig=$signature")
}

function Invoke-CosmosSqlApiRequest {
  param(
    [Parameter(Mandatory)][string]$Method,
    [Parameter(Mandatory)][string]$ResourceType,
    [Parameter(Mandatory)][string]$ResourceLink,
    [Parameter(Mandatory)][string]$ResourcePath,
    [Parameter(Mandatory)][string]$ContentType,
    [Parameter(Mandatory)][string]$Body,
    [hashtable]$AdditionalHeaders = @{}
  )

  $requestDate = [DateTime]::UtcNow.ToString("R")
  $headers = @{
    authorization = New-CosmosMasterKeyAuthorizationToken `
      -Verb $Method `
      -ResourceType $ResourceType `
      -ResourceLink $ResourceLink `
      -Date $requestDate `
      -MasterKey $COSMOS_KEY
    "x-ms-date" = $requestDate
    "x-ms-version" = $COSMOS_API_VERSION
  }

  foreach ($name in $AdditionalHeaders.Keys) {
    $headers[$name] = $AdditionalHeaders[$name]
  }

  Invoke-RestMethod `
    -Method $Method `
    -Uri "$($COSMOS_ENDPOINT)$ResourcePath" `
    -Headers $headers `
    -ContentType $ContentType `
    -Body $Body
}

@(
  [pscustomobject]@{
    id = "order-001"
    customerId = "customer-100"
    product = "Azure Reserved VM Instance"
    quantity = 3
    region = "swedencentral"
    status = "confirmed"
    createdAt = "2024-06-15T10:30:00Z"
  }
  [pscustomobject]@{
    id = "order-002"
    customerId = "customer-200"
    product = "Azure Cosmos DB Reserved Capacity"
    quantity = 1
    region = "norwayeast"
    status = "pending"
    createdAt = "2024-06-15T11:00:00Z"
  }
  [pscustomobject]@{
    id = "order-003"
    customerId = "customer-100"
    product = "Azure Front Door Premium"
    quantity = 1
    region = "swedencentral"
    status = "shipped"
    createdAt = "2024-06-15T14:45:00Z"
  }
) | ForEach-Object {
  $null = Invoke-CosmosSqlApiRequest `
    -Method "POST" `
    -ResourceType "docs" `
    -ResourceLink $COSMOS_DOCS_RESOURCE_LINK `
    -ResourcePath $COSMOS_DOCS_PATH `
    -ContentType "application/json" `
    -Body ($_ | ConvertTo-Json -Depth 10 -Compress) `
    -AdditionalHeaders @{
      "x-ms-documentdb-is-upsert" = "True"
      "x-ms-documentdb-partitionkey" = (@($_.customerId) | ConvertTo-Json -Compress)
    }
}

Write-Host "Inserted sample documents into $CONTAINER_NAME"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Cosmos DB account and select **Data Explorer**.
2. Expand `db-sample`, select `container-orders`, and choose **New Item**.
3. Paste and save each document below as a separate item.

```json
{
  "id": "order-001",
  "customerId": "customer-100",
  "product": "Azure Reserved VM Instance",
  "quantity": 3,
  "region": "swedencentral",
  "status": "confirmed",
  "createdAt": "2024-06-15T10:30:00Z"
}
```

```json
{
  "id": "order-002",
  "customerId": "customer-200",
  "product": "Azure Cosmos DB Reserved Capacity",
  "quantity": 1,
  "region": "norwayeast",
  "status": "pending",
  "createdAt": "2024-06-15T11:00:00Z"
}
```

```json
{
  "id": "order-003",
  "customerId": "customer-100",
  "product": "Azure Front Door Premium",
  "quantity": 1,
  "region": "swedencentral",
  "status": "shipped",
  "createdAt": "2024-06-15T14:45:00Z"
}
```

</div>
</div>

<div class="lab-note">
<strong>Keep these helpers loaded:</strong> the REST helper functions created in this step are reused in Steps 9 and 12. If you start a new shell, rerun Step 1 and Step 8 before querying.
</div>

---

## Step 9 — Query and Verify Data

Run a cross-partition query and then a single-partition query.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
show_cosmos_orders() {
  local query_body='{"query":"SELECT c.id, c.customerId, c.product, c.status FROM c","parameters":[]}'
  local response

  response="$(cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/query+json" \
    "$query_body" \
    'x-ms-documentdb-isquery: True' \
    'x-ms-documentdb-query-enablecrosspartition: True' \
    'x-ms-max-item-count: -1')"

  python3 - "$response" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])
docs = sorted(data.get("Documents", []), key=lambda doc: doc.get("id", ""))
print(f"{'Id':<12} {'CustomerId':<14} {'Product':<36} Status")
print(f"{'-' * 12} {'-' * 14} {'-' * 36} {'-' * 10}")
for doc in docs:
    print(f"{doc['id']:<12} {doc['customerId']:<14} {doc['product']:<36} {doc['status']}")
print(f"\nCount: {data.get('_count', len(docs))}")
PY
}

show_customer_orders() {
  local customer_id="$1"
  local query_body
  local partition_header
  local response

  query_body="$(printf '{"query":"SELECT c.id, c.product, c.status FROM c WHERE c.customerId = @customerId","parameters":[{"name":"@customerId","value":"%s"}]}' "$customer_id")"
  partition_header="$(printf 'x-ms-documentdb-partitionkey: ["%s"]' "$customer_id")"

  response="$(cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/query+json" \
    "$query_body" \
    'x-ms-documentdb-isquery: True' \
    "$partition_header")"

  python3 - "$response" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])
docs = data.get("Documents", [])
print(f"{'Id':<12} {'Product':<36} Status")
print(f"{'-' * 12} {'-' * 36} {'-' * 10}")
for doc in docs:
    print(f"{doc['id']:<12} {doc['product']:<36} {doc['status']}")
print(f"\nCount: {data.get('_count', len(docs))}")
PY
}

show_cosmos_orders
show_customer_orders "customer-100"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
function Show-CosmosOrders {
  $queryBody = @{
    query = "SELECT c.id, c.customerId, c.product, c.status FROM c"
    parameters = @()
  } | ConvertTo-Json -Depth 5 -Compress

  $response = Invoke-CosmosSqlApiRequest `
    -Method "POST" `
    -ResourceType "docs" `
    -ResourceLink $COSMOS_DOCS_RESOURCE_LINK `
    -ResourcePath $COSMOS_DOCS_PATH `
    -ContentType "application/query+json" `
    -Body $queryBody `
    -AdditionalHeaders @{
      "x-ms-documentdb-isquery" = "True"
      "x-ms-documentdb-query-enablecrosspartition" = "True"
      "x-ms-max-item-count" = "-1"
    }

  $response.Documents | Sort-Object id | Select-Object id, customerId, product, status | Format-Table -AutoSize
  Write-Host "Count: $($response._count)"
}

function Show-CosmosOrdersForCustomer {
  param([Parameter(Mandatory)][string]$CustomerId)

  $queryBody = @{
    query = "SELECT c.id, c.product, c.status FROM c WHERE c.customerId = @customerId"
    parameters = @(
      @{
        name = "@customerId"
        value = $CustomerId
      }
    )
  } | ConvertTo-Json -Depth 5 -Compress

  $response = Invoke-CosmosSqlApiRequest `
    -Method "POST" `
    -ResourceType "docs" `
    -ResourceLink $COSMOS_DOCS_RESOURCE_LINK `
    -ResourcePath $COSMOS_DOCS_PATH `
    -ContentType "application/query+json" `
    -Body $queryBody `
    -AdditionalHeaders @{
      "x-ms-documentdb-isquery" = "True"
      "x-ms-documentdb-partitionkey" = (@($CustomerId) | ConvertTo-Json -Compress)
    }

  $response.Documents | Select-Object id, product, status | Format-Table -AutoSize
  Write-Host "Count: $($response._count)"
}

Show-CosmosOrders
Show-CosmosOrdersForCustomer -CustomerId "customer-100"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Data Explorer**, select `container-orders` and choose **New SQL Query**.
2. Run this cross-partition query:

```sql
SELECT c.id, c.customerId, c.product, c.status FROM c
```

3. Then run this single-partition query:

```sql
SELECT c.id, c.product, c.status FROM c WHERE c.customerId = "customer-100"
```

4. Confirm you see all three orders in the first query and the two `customer-100` orders in the second.

</div>
</div>

<div class="lab-note">
<strong>Validation:</strong> If the three documents are returned successfully, the account, database, container, and data-plane access are all working. The same global endpoint will continue to work after regional failover.
</div>

---

## Step 10 — Enable Automatic Failover

Automatic failover lets Cosmos DB promote the next configured write region if the
current write region becomes unavailable.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --enable-automatic-failover true \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "{AutomaticFailover:enableAutomaticFailover, FailoverOrder:readLocations[].{Region:locationName, Priority:failoverPriority}}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -EnableAutomaticFailover $true

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG
Write-Host "AutomaticFailover: $($account.EnableAutomaticFailover)"
$account.ReadLocations |
  Select-Object LocationName, FailoverPriority |
  Format-Table -AutoSize
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Global distribution** for the Cosmos DB account.
2. Turn on **Enable automatic failover**.
3. Save the change.
4. Confirm the failover priority order is still **Sweden Central = 0** and **Norway East = 1**.

</div>
</div>

---

## Step 11 — Test Manual Failover

Now rehearse a controlled failover by making **Norway East** the primary region.

<div class="lab-note">
<strong>Important:</strong> Manual failover applies to a single-write-region topology, so disable multi-region writes first. The priority change can take several minutes.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --enable-multiple-write-locations false \
  --output table

az cosmosdb failover-priority-change \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --failover-policies "$LOCATION_SECONDARY"=0 "$LOCATION_PRIMARY"=1 \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "{WriteRegions:writeLocations[].locationName, ReadRegions:readLocations[].locationName, MultiRegionWrites:enableMultipleWriteLocations}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Disable multi-region writes (required before manual priority change)
Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -EnableMultipleWriteLocations $false

# Swap failover priorities: Norway East becomes primary (0), Sweden Central becomes secondary (1)
$newPrimary = New-AzCosmosDBLocationObject `
  -LocationName $LOCATION_SECONDARY `
  -FailoverPriority 0 `
  -IsZoneRedundant $true

$newSecondary = New-AzCosmosDBLocationObject `
  -LocationName $LOCATION_PRIMARY `
  -FailoverPriority 1 `
  -IsZoneRedundant $true

Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -Location @($newPrimary, $newSecondary)

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG
[pscustomobject]@{
  WriteRegions      = $account.WriteLocations.LocationName -join ", "
  ReadRegions       = $account.ReadLocations.LocationName -join ", "
  MultiRegionWrites = $account.EnableMultipleWriteLocations
}
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Global distribution**.
2. If **Enable multiple write regions** is on, turn it off and save.
3. Change the failover priority so **Norway East** becomes priority `0` and **Sweden Central** becomes priority `1`.
4. Save the change and wait for the failover to complete.
5. Confirm **Norway East** now shows as the write region.

</div>
</div>

---

## Step 12 — Verify the Account Still Works After Failover

Query the data again through the same global endpoint.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
show_cosmos_orders
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Show-CosmosOrders
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Return to **Data Explorer**.
2. Run the Step 9 cross-partition query again:

```sql
SELECT c.id, c.customerId, c.product, c.status FROM c ORDER BY c.createdAt
```

3. Confirm the same three documents are returned after failover.

</div>
</div>

<div class="lab-note">
<strong>Expected result:</strong> You should see the same three orders with no data loss. The global endpoint is unchanged even though the write region moved to <code>norwayeast</code>.
</div>

---

## Step 13 — Fail Back to Sweden Central

Restore the original priority order. If you still want active-active writes after
the drill, re-enable multi-region writes at the end.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb failover-priority-change \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --failover-policies "$LOCATION_PRIMARY"=0 "$LOCATION_SECONDARY"=1 \
  --output table

az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --enable-multiple-write-locations true \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "{Account:name, WriteRegions:writeLocations[].locationName, ReadRegions:readLocations[].locationName, MultiRegionWrites:enableMultipleWriteLocations, AutomaticFailover:enableAutomaticFailover, Consistency:consistencyPolicy.defaultConsistencyLevel}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Restore Sweden Central as primary (0) and Norway East as secondary (1)
$originalPrimary = New-AzCosmosDBLocationObject `
  -LocationName $LOCATION_PRIMARY `
  -FailoverPriority 0 `
  -IsZoneRedundant $true

$originalSecondary = New-AzCosmosDBLocationObject `
  -LocationName $LOCATION_SECONDARY `
  -FailoverPriority 1 `
  -IsZoneRedundant $true

Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -Location @($originalPrimary, $originalSecondary)

# Re-enable multi-region writes for active-active topology
Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG `
  -EnableMultipleWriteLocations $true

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG
[pscustomobject]@{
  Account           = $account.Name
  WriteRegions      = $account.WriteLocations.LocationName -join ", "
  ReadRegions       = $account.ReadLocations.LocationName -join ", "
  MultiRegionWrites = $account.EnableMultipleWriteLocations
  AutomaticFailover = $account.EnableAutomaticFailover
  Consistency       = $account.ConsistencyPolicy.DefaultConsistencyLevel
}
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Global distribution** again.
2. Change the priorities back so **Sweden Central** is `0` and **Norway East** is `1`.
3. Save the failback.
4. If you want to return to active-active mode, turn **Enable multiple write regions** back on and save once more.
5. Review the final topology and failover settings on the same page.

</div>
</div>

<div class="lab-note">
<strong>Cost tip:</strong> If your real workload does not need active-active writes, leave multi-region writes disabled after the failback to reduce write RU cost.
</div>

---

## Step 14 — SDK Preferred Regions Configuration

In production, configure your SDK with a preferred region list so it uses the
nearest healthy region automatically.

### .NET SDK

```csharp
CosmosClientOptions options = new CosmosClientOptions
{
    ApplicationPreferredRegions = new List<string>
    {
        Regions.NorwayEast,
        Regions.SwedenCentral
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

<div class="lab-note">
<strong>Why it matters:</strong> Preferred regions reduce read latency and help the SDK react gracefully after a failover. Without them, clients often default to the current write region even when a nearer read region is available.
</div>

---

## Cleanup

Delete the lab resource group.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete \
  --name "$RG" \
  --yes \
  --no-wait

unset RG LOCATION_PRIMARY LOCATION_SECONDARY COSMOS_ACCOUNT \
  DATABASE_NAME CONTAINER_NAME PARTITION_KEY COSMOS_API_VERSION \
  COSMOS_DOCS_RESOURCE_LINK COSMOS_DOCS_PATH COSMOS_ENDPOINT COSMOS_KEY
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Remove-AzResourceGroup -Name $RG -Force -AsJob

Remove-Variable RG, LOCATION_PRIMARY, LOCATION_SECONDARY, COSMOS_ACCOUNT, `
  DATABASE_NAME, CONTAINER_NAME, PARTITION_KEY, COSMOS_API_VERSION, `
  COSMOS_DOCS_RESOURCE_LINK, COSMOS_DOCS_PATH, COSMOS_ENDPOINT, COSMOS_KEY `
  -ErrorAction SilentlyContinue
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Select `rg-cosmos-global-lab`.
3. Choose **Delete resource group**, type the name, and confirm deletion.

</div>
</div>

---

## Discussion

### Consistency Levels Deep-Dive

Cosmos DB offers five consistency levels, ordered from strongest to weakest:

| Level | Guarantee | Trade-off |
|---|---|---|
| **Strong** | Linearizable reads; always returns the latest committed write | Highest latency; **not available** with multi-region writes |
| **Bounded Staleness** | Reads lag behind writes by at most *K* versions or *T* time interval | Good balance for single-write-region accounts with geo-distributed reads |
| **Session** | Read-your-writes, monotonic reads, and monotonic writes within a session | Default for new accounts and usually the best starting point |
| **Consistent Prefix** | Reads never see out-of-order writes | Lower latency than Session, weaker recency guarantee |
| **Eventual** | No ordering guarantee | Lowest latency and highest read availability |

> ⚠️ **Strong consistency is not available when multi-region writes are enabled.**

### Multi-Region Write Costs

When you enable multi-region writes:

- **Write RU consumption increases** because each write must be replicated to every region.
- Reads are still served from the local region when the SDK is configured well.
- Storage cost scales with the number of regions because each region keeps a full copy of the data.

**Recommendation:** Use multi-region writes only when users in multiple geographies
need low-latency writes close to them. For read-heavy workloads, a single write
region plus multiple read regions is often the better trade-off.

### Conflict Resolution Policies

With multi-region writes, concurrent updates to the same item can create
conflicts. Cosmos DB supports:

1. **Last Writer Wins (LWW)** — the default conflict strategy.
2. **Custom resolution via stored procedure** — useful when business rules must merge or arbitrate competing writes.

If you want to define a custom LWW path at container creation time, use a
conflict resolution policy like this:

```bash
az cosmosdb sql container create \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --database-name "$DATABASE_NAME" \
  --name "container-orders-lww" \
  --partition-key-path "$PARTITION_KEY" \
  --throughput 400 \
  --conflict-resolution-policy '{"mode":"lastWriterWins","conflictResolutionPath":"/lastModified"}'
```

### When NOT to Use Multi-Region Writes

Multi-region writes add both cost and operational considerations. Avoid them
when:

| Scenario | Better fit |
|---|---|
| Read-heavy workload (>90% reads) | Single write region + multiple read regions |
| Application requires **Strong** consistency | Single write region only |
| Writes come from a single geography | Single write region in that geography |
| Budget-constrained workload | Single write region to reduce write RU cost |
| Data sovereignty requires writes in one region | Single write region with geo-distributed reads |

### Zone Redundancy vs. Multi-Region

These resilience features protect different failure scopes:

- **Zone redundancy** protects from an availability zone outage inside one region.
- **Multi-region replication** protects from a full regional outage.

For maximum resilience, use **both** when the workload and budget justify it.

---

## Summary

In this lab you:

- ✅ Created a Cosmos DB for NoSQL account in Sweden Central
- ✅ Added Norway East as a secondary region
- ✅ Enabled multi-region writes for an active-active topology
- ✅ Created a database and container
- ✅ Inserted and queried sample documents with current, supported tooling
- ✅ Enabled automatic failover
- ✅ Performed a manual failover drill and verified the account still worked
- ✅ Failed back to the original primary region

---

## Key Takeaways

1. **Cosmos DB global distribution is operationally simple** compared to managing your own replication layer.
2. **The global endpoint remains stable** even when the primary write region changes.
3. **Multi-region writes improve write locality** but increase write RU cost.
4. **Zone redundancy and multi-region replication solve different failure modes** and complement each other.
5. **Preferred regions in the SDK matter** for latency and graceful failover behavior.
6. **Current Azure CLI workflows split cleanly**: CLI for management-plane tasks, REST or Data Explorer for item-level NoSQL work.

---

[← Back to Index](../index.md) | [Next: Lab 5 — Azure Database for MySQL Read Replica →](lab-11-mysql-geo-replication.md)
