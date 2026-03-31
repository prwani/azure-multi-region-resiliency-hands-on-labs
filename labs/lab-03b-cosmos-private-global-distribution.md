---
layout: default
title: "Lab 3-b: Azure Cosmos DB – Private Global Distribution"
---

[Lab 3-a: Azure Cosmos DB – Global Distribution](./lab-03a-cosmos-global-distribution.md) | **Lab 3-b: Azure Cosmos DB – Private Global Distribution**

# Lab 3-b: Azure Cosmos DB – Private Global Distribution

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

Lab 3-b keeps the same Azure Cosmos DB global distribution story as Lab 3-a,
but it assumes you already completed **Lab 0**. Instead of validating Cosmos DB
from a public workstation, this secured variant reuses the **existing spoke
VNets**, places private endpoints into the reserved
`vnet-spoke-*/snet-private-endpoints` subnets, and then validates the private
path from lightweight Linux VMs in `snet-workload`.

In this lab you will:

1. Reuse the Lab 0 Sweden Central and Norway East spoke landing zones.
2. Create a Cosmos DB for NoSQL account and expand it to two regions.
3. Create the database, container, and sample order data.
4. Create one **regional private endpoint per spoke**.
5. Create one **regional private DNS zone instance per spoke** so each spoke
   resolves the same global Cosmos DB endpoint to its **local** private
   endpoint.
6. Disable public network access after private connectivity is ready.
7. Validate the private access path from both spokes before and after a manual
   failover drill.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    Azure Cosmos DB account (global endpoint)                   │
│                    cosmos-private-XXXXX.documents.azure.com                    │
│                                                                                 │
│    Regions: Sweden Central (priority 0)  <────replication────>  Norway East    │
└─────────────────────────────────────────────────────────────────────────────────┘
                ▲                                                      ▲
                │                                                      │
                │ private endpoint                                      │ private endpoint
                │                                                      │
┌──────────────────────────────────────┐     ┌──────────────────────────────────────┐
│ Sweden Central spoke (Lab 0)         │     │ Norway East spoke (Lab 0)            │
│ rg-spoke-swc / vnet-spoke-swc        │     │ rg-spoke-noe / vnet-spoke-noe        │
│                                      │     │                                      │
│ snet-workload                        │     │ snet-workload                        │
│   └─ vm-cosmos-swc-XXXXX             │     │   └─ vm-cosmos-noe-XXXXX             │
│                                      │     │                                      │
│ snet-private-endpoints               │     │ snet-private-endpoints               │
│   └─ pe-cosmos-swc-XXXXX             │     │   └─ pe-cosmos-noe-XXXXX             │
│                                      │     │                                      │
│ rg-cosmos-private-swc                │     │ rg-cosmos-private-noe                │
│   └─ privatelink.documents.azure.com │     │   └─ privatelink.documents.azure.com │
│      (linked only to vnet-spoke-swc) │     │      (linked only to vnet-spoke-noe) │
└──────────────────────────────────────┘     └──────────────────────────────────────┘
```

**Key points:**

- Lab 0 already reserved `snet-workload` and `snet-private-endpoints` in both
  spokes, so this lab plugs directly into those names.
- Each spoke gets its **own** `privatelink.documents.azure.com` zone instance,
  linked only to the local spoke VNet. That keeps the DNS records local to the
  matching private endpoint.
- Applications still use the same global Cosmos DB endpoint
  `<account>.documents.azure.com`; only the **private resolution path** changes.
- A **service-only Cosmos DB failover** does not require DNS changes inside this
  lab's spoke-only design. Whole-region DNS failover planning is discussed later.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Lab 0 | Complete `labs/lab-00-security-prereqs.md` first |
| Azure permissions | Contributor or equivalent on `rg-spoke-swc`, `rg-spoke-noe`, `rg-cosmos-private-swc`, and `rg-cosmos-private-noe` |
| Existing VNets | `vnet-spoke-swc` and `vnet-spoke-noe` must still contain `snet-workload` and `snet-private-endpoints` |
| Azure CLI | v2.60 or later for the Bash path and the networking commands used from PowerShell |
| Az PowerShell module | `Az.CosmosDB`, `Az.Resources`, and `Az.Network` for the original management-plane cmdlets reused here |
| Validation compute | This lab creates two small Linux VMs and uses **Run command** for the private-access checks |
| Portal access | Needed for the Portal path, private endpoint creation, and VM Run command |

<div class="lab-note">
<strong>Private DNS design:</strong> This lab intentionally creates two separate
<code>privatelink.documents.azure.com</code> zone instances—one in each regional
lab resource group—and links each zone only to the matching spoke VNet. That
keeps the A-records local to each regional private endpoint and avoids record
collisions when both spokes need private access to the same Cosmos account.
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

az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the [Azure portal](https://portal.azure.com).
2. If needed, switch to the correct tenant or directory.
3. Open **Subscriptions** and confirm the subscription you want to use.

</div>
</div>

<div class="lab-note">
<strong>PowerShell note:</strong> This lab mixes Az PowerShell cmdlets with Azure
CLI networking commands. If you stay on the PowerShell path, sign in to both
toolchains before continuing.
</div>

---

## Step 1 — Define Variables

Keep the Lab 0 network names fixed and randomize only the Cosmos DB account and
regional private endpoint / VM names.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RANDOM_SUFFIX="$(tr -dc '0-9' </dev/urandom | head -c 5)"

export RG_PRIMARY="rg-cosmos-private-swc"
export RG_SECONDARY="rg-cosmos-private-noe"
export NETWORK_RG_PRIMARY="rg-spoke-swc"
export NETWORK_RG_SECONDARY="rg-spoke-noe"
export LOCATION_PRIMARY="swedencentral"
export LOCATION_SECONDARY="norwayeast"
export SPOKE_VNET_PRIMARY="vnet-spoke-swc"
export SPOKE_VNET_SECONDARY="vnet-spoke-noe"
export SUBNET_WORKLOAD="snet-workload"
export SUBNET_PRIVATE_ENDPOINTS="snet-private-endpoints"
export COSMOS_ACCOUNT="cosmos-private-${RANDOM_SUFFIX}"
export DATABASE_NAME="db-sample"
export CONTAINER_NAME="container-orders"
export PARTITION_KEY="/customerId"
export PRIVATE_DNS_ZONE="privatelink.documents.azure.com"
export PE_PRIMARY="pe-cosmos-swc-${RANDOM_SUFFIX}"
export PE_SECONDARY="pe-cosmos-noe-${RANDOM_SUFFIX}"
export DNS_LINK_PRIMARY="link-cosmos-swc-${RANDOM_SUFFIX}"
export DNS_LINK_SECONDARY="link-cosmos-noe-${RANDOM_SUFFIX}"
export DNS_ZONE_GROUP_PRIMARY="dzg-cosmos-swc"
export DNS_ZONE_GROUP_SECONDARY="dzg-cosmos-noe"
export VALIDATION_VM_PRIMARY="vm-cosmos-swc-${RANDOM_SUFFIX}"
export VALIDATION_VM_SECONDARY="vm-cosmos-noe-${RANDOM_SUFFIX}"
export VM_ADMIN="azureuser"
export COSMOS_API_VERSION="2018-12-31"
export COSMOS_DOCS_RESOURCE_LINK="dbs/${DATABASE_NAME}/colls/${CONTAINER_NAME}"
export COSMOS_DOCS_PATH="dbs/${DATABASE_NAME}/colls/${CONTAINER_NAME}/docs"

echo "Primary lab RG         : $RG_PRIMARY"
echo "Secondary lab RG       : $RG_SECONDARY"
echo "Primary spoke RG       : $NETWORK_RG_PRIMARY"
echo "Secondary spoke RG     : $NETWORK_RG_SECONDARY"
echo "Cosmos account         : $COSMOS_ACCOUNT"
echo "Primary private EP     : $PE_PRIMARY"
echo "Secondary private EP   : $PE_SECONDARY"
echo "Primary validation VM  : $VALIDATION_VM_PRIMARY"
echo "Secondary validation VM: $VALIDATION_VM_SECONDARY"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = Get-Random -Minimum 10000 -Maximum 100000

$RG_PRIMARY = "rg-cosmos-private-swc"
$RG_SECONDARY = "rg-cosmos-private-noe"
$NETWORK_RG_PRIMARY = "rg-spoke-swc"
$NETWORK_RG_SECONDARY = "rg-spoke-noe"
$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"
$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"
$SUBNET_WORKLOAD = "snet-workload"
$SUBNET_PRIVATE_ENDPOINTS = "snet-private-endpoints"
$COSMOS_ACCOUNT = "cosmos-private-$RANDOM_SUFFIX"
$DATABASE_NAME = "db-sample"
$CONTAINER_NAME = "container-orders"
$PARTITION_KEY = "/customerId"
$PRIVATE_DNS_ZONE = "privatelink.documents.azure.com"
$PE_PRIMARY = "pe-cosmos-swc-$RANDOM_SUFFIX"
$PE_SECONDARY = "pe-cosmos-noe-$RANDOM_SUFFIX"
$DNS_LINK_PRIMARY = "link-cosmos-swc-$RANDOM_SUFFIX"
$DNS_LINK_SECONDARY = "link-cosmos-noe-$RANDOM_SUFFIX"
$DNS_ZONE_GROUP_PRIMARY = "dzg-cosmos-swc"
$DNS_ZONE_GROUP_SECONDARY = "dzg-cosmos-noe"
$VALIDATION_VM_PRIMARY = "vm-cosmos-swc-$RANDOM_SUFFIX"
$VALIDATION_VM_SECONDARY = "vm-cosmos-noe-$RANDOM_SUFFIX"
$VM_ADMIN = "azureuser"
$COSMOS_API_VERSION = "2018-12-31"
$COSMOS_DOCS_RESOURCE_LINK = "dbs/$DATABASE_NAME/colls/$CONTAINER_NAME"
$COSMOS_DOCS_PATH = "dbs/$DATABASE_NAME/colls/$CONTAINER_NAME/docs"

Write-Host "Primary lab RG         : $RG_PRIMARY"
Write-Host "Secondary lab RG       : $RG_SECONDARY"
Write-Host "Primary spoke RG       : $NETWORK_RG_PRIMARY"
Write-Host "Secondary spoke RG     : $NETWORK_RG_SECONDARY"
Write-Host "Cosmos account         : $COSMOS_ACCOUNT"
Write-Host "Primary private EP     : $PE_PRIMARY"
Write-Host "Secondary private EP   : $PE_SECONDARY"
Write-Host "Primary validation VM  : $VALIDATION_VM_PRIMARY"
Write-Host "Secondary validation VM: $VALIDATION_VM_SECONDARY"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down these values before you start:

- Primary lab resource group: `rg-cosmos-private-swc`
- Secondary lab resource group: `rg-cosmos-private-noe`
- Primary spoke resource group: `rg-spoke-swc`
- Secondary spoke resource group: `rg-spoke-noe`
- Primary spoke VNet / workload subnet: `vnet-spoke-swc` / `snet-workload`
- Secondary spoke VNet / workload subnet: `vnet-spoke-noe` / `snet-workload`
- Private endpoint subnet in both regions: `snet-private-endpoints`
- Cosmos account: `cosmos-private-<suffix>`
- Database / container: `db-sample` / `container-orders`
- Private DNS zone name: `privatelink.documents.azure.com`

</div>
</div>

<div class="lab-note">
<strong>Tip:</strong> Keep the same shell or PowerShell session open. Later steps
reuse these variables for the Cosmos account, private DNS, private endpoints,
validation VMs, and failover commands.
</div>

---

## Step 2 — Validate the Lab 0 Spoke Foundation

Before you create any Cosmos resources, confirm the two spoke VNets still expose
exactly the subnets that Lab 0 promised to later `B` variants.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet subnet show \
  --resource-group "$NETWORK_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$SUBNET_WORKLOAD" \
  --query "{Subnet:name, Prefix:addressPrefix}" \
  --output table

az network vnet subnet show \
  --resource-group "$NETWORK_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$SUBNET_PRIVATE_ENDPOINTS" \
  --query "{Subnet:name, Prefix:addressPrefix, PEPolicies:privateEndpointNetworkPolicies}" \
  --output table

az network vnet subnet show \
  --resource-group "$NETWORK_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$SUBNET_WORKLOAD" \
  --query "{Subnet:name, Prefix:addressPrefix}" \
  --output table

az network vnet subnet show \
  --resource-group "$NETWORK_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$SUBNET_PRIVATE_ENDPOINTS" \
  --query "{Subnet:name, Prefix:addressPrefix, PEPolicies:privateEndpointNetworkPolicies}" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet subnet show `
  --resource-group $NETWORK_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $SUBNET_WORKLOAD `
  --query "{Subnet:name, Prefix:addressPrefix}" `
  --output table

az network vnet subnet show `
  --resource-group $NETWORK_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $SUBNET_PRIVATE_ENDPOINTS `
  --query "{Subnet:name, Prefix:addressPrefix, PEPolicies:privateEndpointNetworkPolicies}" `
  --output table

az network vnet subnet show `
  --resource-group $NETWORK_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $SUBNET_WORKLOAD `
  --query "{Subnet:name, Prefix:addressPrefix}" `
  --output table

az network vnet subnet show `
  --resource-group $NETWORK_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $SUBNET_PRIVATE_ENDPOINTS `
  --query "{Subnet:name, Prefix:addressPrefix, PEPolicies:privateEndpointNetworkPolicies}" `
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `vnet-spoke-swc` in `rg-spoke-swc` and confirm:
   - `snet-workload` exists with `10.10.4.0/24`
   - `snet-private-endpoints` exists with `10.10.5.64/26`
   - private endpoint network policies are disabled on `snet-private-endpoints`
2. Open `vnet-spoke-noe` in `rg-spoke-noe` and confirm:
   - `snet-workload` exists with `10.20.4.0/24`
   - `snet-private-endpoints` exists with `10.20.5.64/26`
   - private endpoint network policies are disabled on `snet-private-endpoints`
3. If those names or prefixes drifted, fix Lab 0 first so the rest of this lab can use the canonical values directly.

</div>
</div>

<div class="lab-note">
<strong>Why this matters:</strong> Lab 0 intentionally reserved
<code>snet-workload</code> for compute and <code>snet-private-endpoints</code>
for Private Link. This lab relies on that exact split.
</div>

---

## Step 3 — Create the Regional Lab Resource Groups

Create one resource group per region for the Cosmos account support resources,
private DNS zones, validation VMs, and regional private endpoints.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create \
  --name "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --output table

az group create \
  --name "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create `
  --name $RG_PRIMARY `
  --location $LOCATION_PRIMARY `
  --output table

az group create `
  --name $RG_SECONDARY `
  --location $LOCATION_SECONDARY `
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Create `rg-cosmos-private-swc` in **Sweden Central**.
3. Create `rg-cosmos-private-noe` in **Norway East**.
4. Do **not** recreate the Lab 0 spoke resource groups; this lab reuses them.

</div>
</div>

---

## Step 4 — Create the Cosmos DB Account (Single Region)

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
  --resource-group "$RG_PRIMARY" \
  --locations regionName="$LOCATION_PRIMARY" failoverPriority=0 isZoneRedundant=true \
  --default-consistency-level Session \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
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
  -ResourceGroupName $RG_PRIMARY `
  -Location @($primaryLocation) `
  -DefaultConsistencyLevel "Session"

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG_PRIMARY
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
   - Resource group: `rg-cosmos-private-swc`
   - Account name: `cosmos-private-&lt;suffix&gt;`
   - Region: **Sweden Central**
4. Keep the default **Session** consistency level.
5. If the wizard shows **Availability zones** or **Zone redundancy**, turn it on.
6. Create the account and wait for deployment to finish.

</div>
</div>

<div class="lab-note">
<strong>Expect a wait:</strong> Cosmos DB account creation can take 5–10 minutes. When the account is ready, you should see <code>swedencentral</code> as the only region.
</div>

<div class="lab-note">
<strong>Private variant sequencing:</strong> Leave public network access enabled for
now. Step 13 turns it off only after the regional private endpoints and private
DNS zones are in place.
</div>

---

## Step 5 — Add Norway East as a Secondary Region

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
  --resource-group "$RG_PRIMARY" \
  --locations regionName="$LOCATION_PRIMARY" failoverPriority=0 isZoneRedundant=true \
  --locations regionName="$LOCATION_SECONDARY" failoverPriority=1 isZoneRedundant=true \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
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
  -ResourceGroupName $RG_PRIMARY `
  -Location @($primaryLocation, $secondaryLocation)

Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG_PRIMARY |
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

## Step 6 — Enable Multi-Region Writes

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
  --resource-group "$RG_PRIMARY" \
  --enable-multiple-write-locations true \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --query "{MultiRegionWrites:enableMultipleWriteLocations, WriteRegions:writeLocations[].locationName}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG_PRIMARY `
  -EnableMultipleWriteLocations $true

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG_PRIMARY
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

## Step 7 — Create the Database

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
  --resource-group "$RG_PRIMARY" \
  --name "$DATABASE_NAME" \
  --output table

az cosmosdb sql database show \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --name "$DATABASE_NAME" \
  --query "{Database:name}" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzCosmosDBSqlDatabase `
  -AccountName $COSMOS_ACCOUNT `
  -ResourceGroupName $RG_PRIMARY `
  -Name $DATABASE_NAME

Get-AzCosmosDBSqlDatabase `
  -AccountName $COSMOS_ACCOUNT `
  -ResourceGroupName $RG_PRIMARY `
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

## Step 8 — Create the Container

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
  --resource-group "$RG_PRIMARY" \
  --database-name "$DATABASE_NAME" \
  --name "$CONTAINER_NAME" \
  --partition-key-path "$PARTITION_KEY" \
  --throughput 400 \
  --output table

az cosmosdb sql container show \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
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
  -ResourceGroupName $RG_PRIMARY `
  -DatabaseName $DATABASE_NAME `
  -Name $CONTAINER_NAME `
  -PartitionKeyPath $PARTITION_KEY `
  -Throughput 400

Get-AzCosmosDBSqlContainer `
  -AccountName $COSMOS_ACCOUNT `
  -ResourceGroupName $RG_PRIMARY `
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

## Step 9 — Seed Sample Documents Before the Lockdown

Seed three sample order documents before you disable public network access. This
keeps the private variant focused on private networking and failover validation
later in the lab.

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
  --resource-group "$RG_PRIMARY" \
  --query "documentEndpoint" \
  --output tsv)"

export COSMOS_KEY="$(az cosmosdb keys list \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
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
  --resource-group $RG_PRIMARY `
  --query "documentEndpoint" `
  --output tsv

$COSMOS_KEY = az cosmosdb keys list `
  --name $COSMOS_ACCOUNT `
  --resource-group $RG_PRIMARY `
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
<strong>Keep these helpers loaded:</strong> if you want one more workstation-based
data-plane check before the lockdown, reuse them in Step 10. After Step 13,
move the validation flow into the spoke VNets in Steps 15 and 18.
</div>

---

## Step 10 — Query and Verify Data Before the Lockdown

Run one final workstation-friendly data-plane validation before you disable
public network access. After Step 13, the validation path moves inside the spoke
VNets.

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
<strong>Validation:</strong> If the three documents are returned successfully, the
account, database, container, and pre-lockdown data-plane path are all working.
The same global endpoint will be revalidated privately from the spoke VNets
after failover.
</div>

---

## Step 11 — Create the Regional Private DNS Zones and VNet Links

Create one `privatelink.documents.azure.com` zone instance per regional lab
resource group and link each zone only to its matching spoke VNet.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
export SPOKE_VNET_PRIMARY_ID="$(az network vnet show \
  --resource-group "$NETWORK_RG_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query id \
  --output tsv)"

export SPOKE_VNET_SECONDARY_ID="$(az network vnet show \
  --resource-group "$NETWORK_RG_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query id \
  --output tsv)"

az network private-dns zone create \
  --resource-group "$RG_PRIMARY" \
  --name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-dns zone create \
  --resource-group "$RG_SECONDARY" \
  --name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-dns link vnet create \
  --resource-group "$RG_PRIMARY" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "$DNS_LINK_PRIMARY" \
  --virtual-network "$SPOKE_VNET_PRIMARY_ID" \
  --registration-enabled false \
  --output table

az network private-dns link vnet create \
  --resource-group "$RG_SECONDARY" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "$DNS_LINK_SECONDARY" \
  --virtual-network "$SPOKE_VNET_SECONDARY_ID" \
  --registration-enabled false \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SPOKE_VNET_PRIMARY_ID = az network vnet show `
  --resource-group $NETWORK_RG_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query id `
  --output tsv

$SPOKE_VNET_SECONDARY_ID = az network vnet show `
  --resource-group $NETWORK_RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query id `
  --output tsv

az network private-dns zone create `
  --resource-group $RG_PRIMARY `
  --name $PRIVATE_DNS_ZONE `
  --output table

az network private-dns zone create `
  --resource-group $RG_SECONDARY `
  --name $PRIVATE_DNS_ZONE `
  --output table

az network private-dns link vnet create `
  --resource-group $RG_PRIMARY `
  --zone-name $PRIVATE_DNS_ZONE `
  --name $DNS_LINK_PRIMARY `
  --virtual-network $SPOKE_VNET_PRIMARY_ID `
  --registration-enabled false `
  --output table

az network private-dns link vnet create `
  --resource-group $RG_SECONDARY `
  --zone-name $PRIVATE_DNS_ZONE `
  --name $DNS_LINK_SECONDARY `
  --virtual-network $SPOKE_VNET_SECONDARY_ID `
  --registration-enabled false `
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-cosmos-private-swc`, create a private DNS zone named `privatelink.documents.azure.com`.
2. Link that zone only to `vnet-spoke-swc`.
3. In `rg-cosmos-private-noe`, create **another** private DNS zone with the same name: `privatelink.documents.azure.com`.
4. Link that second zone only to `vnet-spoke-noe`.
5. Do not attach both spokes to the same zone instance for this lab.

</div>
</div>

<div class="lab-note">
<strong>Important:</strong> Azure Cosmos DB can use multiple private endpoints per
account, but two regional private endpoints for the same account should not
share the same private DNS zone instance. This lab keeps each zone local to the
matching spoke.
</div>

---

## Step 12 — Create Private Endpoints in Both Spokes

Deploy one private endpoint per spoke into the Lab 0 `snet-private-endpoints`
subnet, then attach each private endpoint to its local private DNS zone.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
export COSMOS_ID="$(az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --query id \
  --output tsv)"

export PE_SUBNET_PRIMARY_ID="$(az network vnet subnet show \
  --resource-group "$NETWORK_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$SUBNET_PRIVATE_ENDPOINTS" \
  --query id \
  --output tsv)"

export PE_SUBNET_SECONDARY_ID="$(az network vnet subnet show \
  --resource-group "$NETWORK_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$SUBNET_PRIVATE_ENDPOINTS" \
  --query id \
  --output tsv)"

az network private-endpoint create \
  --resource-group "$RG_PRIMARY" \
  --name "$PE_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --subnet "$PE_SUBNET_PRIMARY_ID" \
  --private-connection-resource-id "$COSMOS_ID" \
  --group-id Sql \
  --connection-name "${PE_PRIMARY}-conn" \
  --output table

az network private-endpoint create \
  --resource-group "$RG_SECONDARY" \
  --name "$PE_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --subnet "$PE_SUBNET_SECONDARY_ID" \
  --private-connection-resource-id "$COSMOS_ID" \
  --group-id Sql \
  --connection-name "${PE_SECONDARY}-conn" \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group "$RG_PRIMARY" \
  --endpoint-name "$PE_PRIMARY" \
  --name "$DNS_ZONE_GROUP_PRIMARY" \
  --private-dns-zone "$PRIVATE_DNS_ZONE" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group "$RG_SECONDARY" \
  --endpoint-name "$PE_SECONDARY" \
  --name "$DNS_ZONE_GROUP_SECONDARY" \
  --private-dns-zone "$PRIVATE_DNS_ZONE" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$COSMOS_ID = az cosmosdb show `
  --name $COSMOS_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --query id `
  --output tsv

$PE_SUBNET_PRIMARY_ID = az network vnet subnet show `
  --resource-group $NETWORK_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $SUBNET_PRIVATE_ENDPOINTS `
  --query id `
  --output tsv

$PE_SUBNET_SECONDARY_ID = az network vnet subnet show `
  --resource-group $NETWORK_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $SUBNET_PRIVATE_ENDPOINTS `
  --query id `
  --output tsv

az network private-endpoint create `
  --resource-group $RG_PRIMARY `
  --name $PE_PRIMARY `
  --location $LOCATION_PRIMARY `
  --subnet $PE_SUBNET_PRIMARY_ID `
  --private-connection-resource-id $COSMOS_ID `
  --group-id Sql `
  --connection-name "$PE_PRIMARY-conn" `
  --output table

az network private-endpoint create `
  --resource-group $RG_SECONDARY `
  --name $PE_SECONDARY `
  --location $LOCATION_SECONDARY `
  --subnet $PE_SUBNET_SECONDARY_ID `
  --private-connection-resource-id $COSMOS_ID `
  --group-id Sql `
  --connection-name "$PE_SECONDARY-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $RG_PRIMARY `
  --endpoint-name $PE_PRIMARY `
  --name $DNS_ZONE_GROUP_PRIMARY `
  --private-dns-zone $PRIVATE_DNS_ZONE `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $RG_SECONDARY `
  --endpoint-name $PE_SECONDARY `
  --name $DNS_ZONE_GROUP_SECONDARY `
  --private-dns-zone $PRIVATE_DNS_ZONE `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-cosmos-private-swc`, create a private endpoint named `pe-cosmos-swc-<suffix>`.
2. Target the existing Cosmos DB account, choose subresource **Sql**, and place the private endpoint in `vnet-spoke-swc / snet-private-endpoints`.
3. On the DNS step, associate the private endpoint with the Sweden Central `privatelink.documents.azure.com` zone in `rg-cosmos-private-swc`.
4. Repeat in `rg-cosmos-private-noe` with `pe-cosmos-noe-<suffix>` placed in `vnet-spoke-noe / snet-private-endpoints`.
5. Associate the Norway East private endpoint with the Norway East zone instance in `rg-cosmos-private-noe`.

</div>
</div>

<div class="lab-note">
<strong>Expected result:</strong> Each private endpoint should show multiple
private IP mappings—one for the global Cosmos DB endpoint and one per regional
endpoint. The private IPs should land inside the Lab 0 private endpoint subnets.
</div>

---

## Step 13 — Disable Public Network Access

Now that both regional private endpoints exist, lock the Cosmos DB account down
to private access only.

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
  --resource-group "$RG_PRIMARY" \
  --public-network-access DISABLED \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --query "{Account:name, PublicNetworkAccess:publicNetworkAccess}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az cosmosdb update `
  --name $COSMOS_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --public-network-access DISABLED `
  --output table

az cosmosdb show `
  --name $COSMOS_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --query "{Account:name, PublicNetworkAccess:publicNetworkAccess}" `
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Cosmos DB account.
2. Go to **Networking**.
3. Under public access, set **Public network access** to **Disabled**.
4. Save the change.
5. Keep using the Azure control plane for management tasks, but treat data-plane validation from your browser as no longer authoritative for this lab.

</div>
</div>

<div class="lab-note">
<strong>After this step:</strong> the private path from the spoke VNets becomes the
main validation path. Use the VMs in Steps 14, 15, and 18 instead of relying on
your local browser.
</div>

---

## Step 14 — Create Validation VMs in Both Spokes

Create one small Linux VM in each spoke workload subnet. These VMs stay inside
the Lab 0 spokes and act as your private-access validation points.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
export WORKLOAD_SUBNET_PRIMARY_ID="$(az network vnet subnet show \
  --resource-group "$NETWORK_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$SUBNET_WORKLOAD" \
  --query id \
  --output tsv)"

export WORKLOAD_SUBNET_SECONDARY_ID="$(az network vnet subnet show \
  --resource-group "$NETWORK_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$SUBNET_WORKLOAD" \
  --query id \
  --output tsv)"

az vm create \
  --resource-group "$RG_PRIMARY" \
  --name "$VALIDATION_VM_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username "$VM_ADMIN" \
  --generate-ssh-keys \
  --subnet "$WORKLOAD_SUBNET_PRIMARY_ID" \
  --public-ip-address "" \
  --output table

az vm create \
  --resource-group "$RG_SECONDARY" \
  --name "$VALIDATION_VM_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username "$VM_ADMIN" \
  --generate-ssh-keys \
  --subnet "$WORKLOAD_SUBNET_SECONDARY_ID" \
  --public-ip-address "" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$WORKLOAD_SUBNET_PRIMARY_ID = az network vnet subnet show `
  --resource-group $NETWORK_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $SUBNET_WORKLOAD `
  --query id `
  --output tsv

$WORKLOAD_SUBNET_SECONDARY_ID = az network vnet subnet show `
  --resource-group $NETWORK_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $SUBNET_WORKLOAD `
  --query id `
  --output tsv

az vm create `
  --resource-group $RG_PRIMARY `
  --name $VALIDATION_VM_PRIMARY `
  --location $LOCATION_PRIMARY `
  --image Ubuntu2204 `
  --size Standard_B1s `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --subnet $WORKLOAD_SUBNET_PRIMARY_ID `
  --public-ip-address '""' `
  --output table

az vm create `
  --resource-group $RG_SECONDARY `
  --name $VALIDATION_VM_SECONDARY `
  --location $LOCATION_SECONDARY `
  --image Ubuntu2204 `
  --size Standard_B1s `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --subnet $WORKLOAD_SUBNET_SECONDARY_ID `
  --public-ip-address '""' `
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-cosmos-private-swc`, create a Linux VM named `vm-cosmos-swc-<suffix>`.
2. Place it in `vnet-spoke-swc / snet-workload` with **no public IP** and no inbound ports.
3. In `rg-cosmos-private-noe`, create a second Linux VM named `vm-cosmos-noe-<suffix>`.
4. Place it in `vnet-spoke-noe / snet-workload`, again with **no public IP**.
5. You will use **Run command** on these VMs in the next step, so you do not need to open SSH from the internet.

</div>
</div>

---

## Step 15 — Validate Private Access From Each Spoke

Use **Run command** so the validation executes inside the spoke VNets. The goal
is to prove that the same global Cosmos DB endpoint resolves to a **private IP**
and returns an immediate HTTPS response from each spoke.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_PRIVATE_TEST="$(az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VALIDATION_VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null) && echo '=== DNS ===' && getent hosts ${COSMOS_ACCOUNT}.documents.azure.com && echo '=== HTTPS ===' && curl -sS -o /dev/null -D - https://${COSMOS_ACCOUNT}.documents.azure.com/ | head -n 5" \
  --query "value[0].message" \
  --output tsv)"

printf '%s\n' "$PRIMARY_PRIVATE_TEST"

SECONDARY_PRIVATE_TEST="$(az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VALIDATION_VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null) && echo '=== DNS ===' && getent hosts ${COSMOS_ACCOUNT}.documents.azure.com && echo '=== HTTPS ===' && curl -sS -o /dev/null -D - https://${COSMOS_ACCOUNT}.documents.azure.com/ | head -n 5" \
  --query "value[0].message" \
  --output tsv)"

printf '%s\n' "$SECONDARY_PRIVATE_TEST"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_PRIVATE_TEST = az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VALIDATION_VM_PRIMARY `
  --command-id RunShellScript `
  --scripts "command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null) && echo '=== DNS ===' && getent hosts $($COSMOS_ACCOUNT).documents.azure.com && echo '=== HTTPS ===' && curl -sS -o /dev/null -D - https://$($COSMOS_ACCOUNT).documents.azure.com/ | head -n 5" `
  --query "value[0].message" `
  --output tsv

$PRIMARY_PRIVATE_TEST

$SECONDARY_PRIVATE_TEST = az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VALIDATION_VM_SECONDARY `
  --command-id RunShellScript `
  --scripts "command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null) && echo '=== DNS ===' && getent hosts $($COSMOS_ACCOUNT).documents.azure.com && echo '=== HTTPS ===' && curl -sS -o /dev/null -D - https://$($COSMOS_ACCOUNT).documents.azure.com/ | head -n 5" `
  --query "value[0].message" `
  --output tsv

$SECONDARY_PRIVATE_TEST
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `vm-cosmos-swc-<suffix>` and select **Run command** > **RunShellScript**.
2. Run this script:

```bash
command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null)
echo "=== DNS ==="
getent hosts cosmos-private-<suffix>.documents.azure.com
echo "=== HTTPS ==="
curl -sS -o /dev/null -D - https://cosmos-private-<suffix>.documents.azure.com/ | head -n 5
```

3. Repeat on `vm-cosmos-noe-<suffix>`.
4. Confirm the Sweden Central VM resolves the account to a private IP in `10.10.5.64/26`, and the Norway East VM resolves it to a private IP in `10.20.5.64/26`.
5. An immediate HTTP response such as `401`, `403`, or `400` is acceptable—the important part is that the request reaches Cosmos DB over the private path instead of timing out or resolving publicly.

</div>
</div>

<div class="lab-note">
<strong>Expected result:</strong> The VMs should resolve the same global endpoint to
private IPs in their local Lab 0 private endpoint subnet ranges. The exact HTTP
status code can vary, but the connection should succeed quickly with no public
path required.
</div>

---

## Step 16 — Enable Automatic Failover

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
  --resource-group "$RG_PRIMARY" \
  --enable-automatic-failover true \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --query "{AutomaticFailover:enableAutomaticFailover, FailoverOrder:readLocations[].{Region:locationName, Priority:failoverPriority}}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG_PRIMARY `
  -EnableAutomaticFailover $true

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG_PRIMARY
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

## Step 17 — Test Manual Failover

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
  --resource-group "$RG_PRIMARY" \
  --enable-multiple-write-locations false \
  --output table

az cosmosdb failover-priority-change \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --failover-policies "$LOCATION_SECONDARY"=0 "$LOCATION_PRIMARY"=1 \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --query "{WriteRegions:writeLocations[].locationName, ReadRegions:readLocations[].locationName, MultiRegionWrites:enableMultipleWriteLocations}" \
  --output jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Disable multi-region writes (required before manual priority change)
Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG_PRIMARY `
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
  -ResourceGroupName $RG_PRIMARY `
  -Location @($newPrimary, $newSecondary)

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG_PRIMARY
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

<div class="lab-note">
<strong>Private failover note:</strong> For a service-only Azure Cosmos DB failover,
this lab's spoke-local private endpoints keep working without DNS changes. If you
later extend the pattern to hub DNS forwarders or on-premises resolvers, document
that whole-region DNS failover procedure separately.
</div>

---

## Step 18 — Re-Run the Private Validation After Failover

The write region has moved to Norway East, but the application-facing endpoint is
still the same. Prove that both spoke VMs can still resolve and reach the
account privately.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --query "{WriteRegions:writeLocations[].locationName, ReadRegions:readLocations[].locationName, PublicNetworkAccess:publicNetworkAccess}" \
  --output jsonc

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VALIDATION_VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null) && echo '=== DNS ===' && getent hosts ${COSMOS_ACCOUNT}.documents.azure.com && echo '=== HTTPS ===' && curl -sS -o /dev/null -D - https://${COSMOS_ACCOUNT}.documents.azure.com/ | head -n 5" \
  --query "value[0].message" \
  --output tsv

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VALIDATION_VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null) && echo '=== DNS ===' && getent hosts ${COSMOS_ACCOUNT}.documents.azure.com && echo '=== HTTPS ===' && curl -sS -o /dev/null -D - https://${COSMOS_ACCOUNT}.documents.azure.com/ | head -n 5" \
  --query "value[0].message" \
  --output tsv
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az cosmosdb show `
  --name $COSMOS_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --query "{WriteRegions:writeLocations[].locationName, ReadRegions:readLocations[].locationName, PublicNetworkAccess:publicNetworkAccess}" `
  --output jsonc

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VALIDATION_VM_PRIMARY `
  --command-id RunShellScript `
  --scripts "command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null) && echo '=== DNS ===' && getent hosts $($COSMOS_ACCOUNT).documents.azure.com && echo '=== HTTPS ===' && curl -sS -o /dev/null -D - https://$($COSMOS_ACCOUNT).documents.azure.com/ | head -n 5" `
  --query "value[0].message" `
  --output tsv

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VALIDATION_VM_SECONDARY `
  --command-id RunShellScript `
  --scripts "command -v curl >/dev/null || (sudo apt-get update >/dev/null && sudo apt-get install -y curl >/dev/null) && echo '=== DNS ===' && getent hosts $($COSMOS_ACCOUNT).documents.azure.com && echo '=== HTTPS ===' && curl -sS -o /dev/null -D - https://$($COSMOS_ACCOUNT).documents.azure.com/ | head -n 5" `
  --query "value[0].message" `
  --output tsv
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Global distribution** and confirm **Norway East** now holds write priority `0`.
2. Re-run the Step 15 **Run command** script on `vm-cosmos-swc-<suffix>`.
3. Re-run the same script on `vm-cosmos-noe-<suffix>`.
4. Confirm both VMs still resolve and reach the same global endpoint privately.
5. No DNS edits should be necessary for this service-only failover drill.

</div>
</div>

<div class="lab-note">
<strong>Expected result:</strong> The same global endpoint remains reachable over the
private path from both spokes even though the write region moved to
<code>norwayeast</code>.
</div>

---

## Step 19 — Fail Back to Sweden Central

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
  --resource-group "$RG_PRIMARY" \
  --failover-policies "$LOCATION_PRIMARY"=0 "$LOCATION_SECONDARY"=1 \
  --output table

az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --enable-multiple-write-locations true \
  --output table

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
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
  -ResourceGroupName $RG_PRIMARY `
  -Location @($originalPrimary, $originalSecondary)

# Re-enable multi-region writes for active-active topology
Update-AzCosmosDBAccount `
  -Name $COSMOS_ACCOUNT `
  -ResourceGroupName $RG_PRIMARY `
  -EnableMultipleWriteLocations $true

$account = Get-AzCosmosDBAccount -Name $COSMOS_ACCOUNT -ResourceGroupName $RG_PRIMARY
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

## Step 20 — SDK Preferred Regions Configuration

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

## Validation Checklist

- [ ] Lab 0 still exposes `vnet-spoke-swc` and `vnet-spoke-noe` with `snet-workload` and `snet-private-endpoints`
- [ ] `snet-private-endpoints` keeps private endpoint network policies disabled in both regions
- [ ] The Cosmos DB account runs in Sweden Central and Norway East with multi-region writes enabled before the failover drill
- [ ] `db-sample` and `container-orders` exist and contain the three sample order documents
- [ ] `privatelink.documents.azure.com` exists in both `rg-cosmos-private-swc` and `rg-cosmos-private-noe`
- [ ] Each private DNS zone links only to its matching spoke VNet
- [ ] `pe-cosmos-swc-<suffix>` and `pe-cosmos-noe-<suffix>` exist inside the Lab 0 private endpoint subnets
- [ ] Public network access is disabled on the Cosmos DB account
- [ ] `vm-cosmos-swc-<suffix>` resolves the Cosmos endpoint to a private IP in `10.10.5.64/26`
- [ ] `vm-cosmos-noe-<suffix>` resolves the Cosmos endpoint to a private IP in `10.20.5.64/26`
- [ ] Both spoke VMs receive an immediate HTTPS response from the same global endpoint before and after failover
- [ ] Failback restores Sweden Central as priority `0`

---

## Cleanup

Delete only the resources created by this lab. Leave the Lab 0 hub-and-spoke
foundation in place if you plan to continue with other secured `B` variants.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name "$RG_PRIMARY" --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait

unset RG_PRIMARY RG_SECONDARY NETWORK_RG_PRIMARY NETWORK_RG_SECONDARY \
  LOCATION_PRIMARY LOCATION_SECONDARY SPOKE_VNET_PRIMARY SPOKE_VNET_SECONDARY \
  SUBNET_WORKLOAD SUBNET_PRIVATE_ENDPOINTS COSMOS_ACCOUNT DATABASE_NAME \
  CONTAINER_NAME PARTITION_KEY PRIVATE_DNS_ZONE PE_PRIMARY PE_SECONDARY \
  DNS_LINK_PRIMARY DNS_LINK_SECONDARY DNS_ZONE_GROUP_PRIMARY DNS_ZONE_GROUP_SECONDARY \
  VALIDATION_VM_PRIMARY VALIDATION_VM_SECONDARY VM_ADMIN COSMOS_API_VERSION \
  COSMOS_DOCS_RESOURCE_LINK COSMOS_DOCS_PATH
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

Remove-Variable RG_PRIMARY, RG_SECONDARY, NETWORK_RG_PRIMARY, NETWORK_RG_SECONDARY, `
  LOCATION_PRIMARY, LOCATION_SECONDARY, SPOKE_VNET_PRIMARY, SPOKE_VNET_SECONDARY, `
  SUBNET_WORKLOAD, SUBNET_PRIVATE_ENDPOINTS, COSMOS_ACCOUNT, DATABASE_NAME, `
  CONTAINER_NAME, PARTITION_KEY, PRIVATE_DNS_ZONE, PE_PRIMARY, PE_SECONDARY, `
  DNS_LINK_PRIMARY, DNS_LINK_SECONDARY, DNS_ZONE_GROUP_PRIMARY, DNS_ZONE_GROUP_SECONDARY, `
  VALIDATION_VM_PRIMARY, VALIDATION_VM_SECONDARY, VM_ADMIN, COSMOS_API_VERSION, `
  COSMOS_DOCS_RESOURCE_LINK, COSMOS_DOCS_PATH -ErrorAction SilentlyContinue
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Delete `rg-cosmos-private-swc` and `rg-cosmos-private-noe`.
3. Leave `rg-hub-swc`, `rg-hub-noe`, `rg-spoke-swc`, and `rg-spoke-noe` in place unless you also want to tear down Lab 0.
4. If you are completely done with the secured variants, use the Lab 0 cleanup guidance separately.

</div>
</div>

---

## Discussion

### Why this lab uses one private DNS zone instance per region

Azure Cosmos DB supports multiple private endpoints per account, but two regional
private endpoints for the same account should not share the same private DNS zone
instance. This lab keeps the DNS zones regional so each spoke resolves the
Cosmos endpoint to its **local** private endpoint without overwriting the other
region's records.

### What a Cosmos DB service failover does not change

The **global endpoint stays the same** even when the write region changes. In
this lab, each spoke still reaches the account through its local private
endpoint, so a service-only failover does not require any spoke-side DNS edits.

### Whole-region DR still needs a broader DNS plan

This lab intentionally keeps each spoke self-contained. If you later introduce
hub-based DNS forwarders, Azure Private Resolver, or on-premises DNS, you should
document how those resolvers fail over during a **whole-region outage**. That is
a bigger DNS design problem than the service-only failover drill you completed
here.

### Management plane versus private data plane

The Azure control plane remains public Azure Resource Manager traffic, so you can
still create databases, containers, private endpoints, and failover settings from
your workstation. The **private data-plane proof** in this lab comes from the
spoke VMs in Steps 15 and 18. In production, prefer Microsoft Entra ID and Cosmos
DB RBAC over long-lived account keys.

### Multi-region writes still have the same trade-offs

Private endpoints improve **network isolation**, not write economics. Enabling
multi-region writes still increases write RU consumption because every write must
replicate to every write region.

---

## Summary

In this lab you:

- ✅ Reused the Lab 0 Sweden Central and Norway East spokes
- ✅ Created a two-region Cosmos DB for NoSQL account
- ✅ Created the database, container, and sample order documents
- ✅ Added one regional private endpoint per spoke
- ✅ Added one regional `privatelink.documents.azure.com` zone instance per spoke
- ✅ Disabled public network access after private connectivity was ready
- ✅ Validated the same global endpoint privately from both spokes
- ✅ Repeated the private validation after a manual failover drill

---

## Key Takeaways

1. **Lab 0 intentionally set this up**: the spoke VNets and reserved private endpoint subnets let later `B` variants plug in without redefining the network.
2. **One private endpoint per spoke** keeps the private path local to the region where the application runs.
3. **One private DNS zone instance per region** avoids A-record collisions when both spokes need private access to the same Cosmos account.
4. **The global Cosmos DB endpoint stays stable** across failover, even when the write region changes.
5. **Private networking and multi-region writes solve different problems**: one improves isolation, the other improves write locality.

---

[Lab 3-a: Azure Cosmos DB – Global Distribution](./lab-03a-cosmos-global-distribution.md) | **Lab 3-b: Azure Cosmos DB – Private Global Distribution**
