---
layout: default
title: "Lab 5-b: Azure Database for PostgreSQL – Private Geo-Replication with Private Endpoints"
---

[← Lab 5-a — PostgreSQL Geo-Replication](lab-05a-postgresql-geo-replication.md) | [Lab 5-b — Private PostgreSQL Geo-Replication](lab-05b-postgresql-private-geo-replication.md)

# Lab 5-b: Azure Database for PostgreSQL – Private Geo-Replication with Private Endpoints

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

> **Objective:** Re-create the PostgreSQL geo-replication lab by keeping database traffic private inside the Lab 0 spoke networks, using regional private endpoints, private DNS, and no public firewall rules on either server.

<div class="lab-note">
<strong>Lab 0 dependency:</strong> This variant assumes the Lab 0 landing zone already exists, including <code>rg-hub-swc</code>, <code>rg-hub-noe</code>, <code>rg-spoke-swc</code>, <code>rg-spoke-noe</code>, <code>vnet-spoke-swc</code>, <code>vnet-spoke-noe</code>, <code>snet-workload</code>, <code>snet-private-endpoints</code>, and Azure Bastion in both hubs.
</div>

<div class="lab-note">
<strong>Why this networking model?</strong> Azure Database for PostgreSQL Flexible Server currently supports <strong>Private Link</strong> on servers created in <strong>public access</strong> networking mode. This lab therefore creates both servers in public mode, adds <strong>no public firewall rules</strong>, and exposes each server only through private endpoints in the Lab 0 spoke VNets.
</div>

> **⚠️ Cost note:** This secured variant adds two small Linux VMs and two private endpoints on top of the PostgreSQL servers. Lab 0 hub resources such as Azure Bastion and Azure Firewall continue billing while they exist.

---

## Introduction

Lab 5-b keeps the same core disaster-recovery workflow as Lab 5-a — a writable primary in **Sweden Central**, an asynchronous read replica in **Norway East**, and manual promotion during failover — but changes how clients reach the servers.

Instead of connecting from Azure Cloud Shell or a public workstation IP, each region gets:

- A **private client VM** in Lab 0's `snet-workload`
- A **private endpoint** in Lab 0's `snet-private-endpoints`
- A shared **private DNS zone** for PostgreSQL Private Link resolution
- **No public firewall rules** on the source or replica server

| Layer | Design in Lab 5-b |
|---|---|
| **PostgreSQL service** | Flexible Server, General Purpose tier |
| **Replication** | Cross-region read replica (async WAL streaming) |
| **Private connectivity** | Private Link / private endpoints in each spoke |
| **DNS** | `privatelink.postgres.database.azure.com` linked to both spokes |
| **Validation path** | `az vm run-command invoke` from your terminal, or Azure Bastion from the portal |
| **Lab 0 reuse** | Hub Bastion + spoke workload and private-endpoint subnets |

> **Design note:** This lab deliberately avoids cross-region VNet peering. Replication between the two PostgreSQL servers is service-managed, while application validation happens from a regional client VM in each spoke.

---

## Architecture

```text
┌──────────────────────────── Sweden Central (Primary) ─────────────────────────────┐
│ Lab 0 hub: rg-hub-swc → bas-hub-swc (Bastion)                                     │
│                                                                                    │
│ rg-spoke-swc / vnet-spoke-swc                                                      │
│   ├─ snet-workload          → vm-pg-client-swc-xxxxx (no public IP)               │
│   └─ snet-private-endpoints → pe-pgsql-swc-xxxxx                                  │
│                                   │                                                │
│                                   ▼ Private Link                                   │
│                         rg-pgsql-private-swc                                       │
│                           └─ pgsql-pe-swc-xxxxx (source, read + write)             │
└────────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ Async WAL replication
                                      ▼
┌───────────────────────────── Norway East (DR) ─────────────────────────────────────┐
│ Lab 0 hub: rg-hub-noe → bas-hub-noe (Bastion)                                     │
│                                                                                    │
│ rg-spoke-noe / vnet-spoke-noe                                                      │
│   ├─ snet-workload          → vm-pg-client-noe-xxxxx (no public IP)               │
│   └─ snet-private-endpoints → pe-pgsql-noe-xxxxx                                  │
│                                   │                                                │
│                                   ▼ Private Link                                   │
│                         rg-pgsql-private-noe                                       │
│                           └─ pgsql-pe-noe-xxxxx (read replica)                     │
└────────────────────────────────────────────────────────────────────────────────────┘

Shared private DNS zone:
  privatelink.postgres.database.azure.com

Public firewall rules:
  none
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Lab 0 completed** | The hub-and-spoke resources from Lab 0 must already exist in both regions |
| **Azure CLI** | Version 2.75 or later recommended (`az --version`) |
| **Azure subscription** | Permissions to create PostgreSQL Flexible Servers, private endpoints, VMs, NICs, disks, and private DNS links |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash |
| **PowerShell 7+** | Recommended if you want to follow the PowerShell path |
| **Budget awareness** | Two PostgreSQL servers, two private endpoints, and two client VMs incur cost |

<div class="lab-note">
<strong>Outbound package note:</strong> The client VMs use <code>az vm run-command invoke</code> to install <code>postgresql-client</code>. If your landing zone blocks default outbound package downloads, temporarily allow package egress or use a hardened image with the PostgreSQL client already installed.
</div>

---

## How These Tabs Work

This page uses the same interaction pattern as the rest of the lab series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behavior used in the other labs.

---

## Step 1 — Set Variables

Use the fixed Lab 0 network names, but generate unique server, private endpoint, and VM names so you can rerun the lab safely.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)

PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

LAB0_HUB_RG_PRIMARY="rg-hub-swc"
LAB0_HUB_RG_SECONDARY="rg-hub-noe"
LAB0_SPOKE_RG_PRIMARY="rg-spoke-swc"
LAB0_SPOKE_RG_SECONDARY="rg-spoke-noe"

SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_SECONDARY="vnet-spoke-noe"

WORKLOAD_SUBNET_NAME="snet-workload"
PE_SUBNET_NAME="snet-private-endpoints"

PRIMARY_BASTION="bas-hub-swc"
SECONDARY_BASTION="bas-hub-noe"

RG_PRIMARY="rg-pgsql-private-swc"
RG_SECONDARY="rg-pgsql-private-noe"

PRIMARY_SERVER="pgsql-pe-swc-${RANDOM_SUFFIX}"
REPLICA_SERVER="pgsql-pe-noe-${RANDOM_SUFFIX}"

PRIMARY_PE="pe-pgsql-swc-${RANDOM_SUFFIX}"
REPLICA_PE="pe-pgsql-noe-${RANDOM_SUFFIX}"

CLIENT_VM_PRIMARY="vm-pg-client-swc-${RANDOM_SUFFIX}"
CLIENT_VM_SECONDARY="vm-pg-client-noe-${RANDOM_SUFFIX}"

PRIVATE_DNS_ZONE="privatelink.postgres.database.azure.com"

ADMIN_USER="pgadmin"
ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"
VM_ADMIN="azureuser"
DB_NAME="sampledb"

echo "Primary server     : $PRIMARY_SERVER"
echo "Replica server     : $REPLICA_SERVER"
echo "Primary endpoint   : $PRIMARY_PE"
echo "Replica endpoint   : $REPLICA_PE"
echo "Primary client VM  : $CLIENT_VM_PRIMARY"
echo "Replica client VM  : $CLIENT_VM_SECONDARY"
echo "Private DNS zone   : $PRIVATE_DNS_ZONE"
echo "DB admin password  : $ADMIN_PASSWORD  (save this!)"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$LAB0_HUB_RG_PRIMARY = "rg-hub-swc"
$LAB0_HUB_RG_SECONDARY = "rg-hub-noe"
$LAB0_SPOKE_RG_PRIMARY = "rg-spoke-swc"
$LAB0_SPOKE_RG_SECONDARY = "rg-spoke-noe"

$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"

$WORKLOAD_SUBNET_NAME = "snet-workload"
$PE_SUBNET_NAME = "snet-private-endpoints"

$PRIMARY_BASTION = "bas-hub-swc"
$SECONDARY_BASTION = "bas-hub-noe"

$RG_PRIMARY = "rg-pgsql-private-swc"
$RG_SECONDARY = "rg-pgsql-private-noe"

$PRIMARY_SERVER = "pgsql-pe-swc-$RANDOM_SUFFIX"
$REPLICA_SERVER = "pgsql-pe-noe-$RANDOM_SUFFIX"

$PRIMARY_PE = "pe-pgsql-swc-$RANDOM_SUFFIX"
$REPLICA_PE = "pe-pgsql-noe-$RANDOM_SUFFIX"

$CLIENT_VM_PRIMARY = "vm-pg-client-swc-$RANDOM_SUFFIX"
$CLIENT_VM_SECONDARY = "vm-pg-client-noe-$RANDOM_SUFFIX"

$PRIVATE_DNS_ZONE = "privatelink.postgres.database.azure.com"

$ADMIN_USER = "pgadmin"
$ADMIN_PASSWORD = "P@ssw0rd-$([guid]::NewGuid().ToString('N').Substring(0,8))"
$VM_ADMIN = "azureuser"
$DB_NAME = "sampledb"

Write-Host "Primary server     : $PRIMARY_SERVER"
Write-Host "Replica server     : $REPLICA_SERVER"
Write-Host "Primary endpoint   : $PRIMARY_PE"
Write-Host "Replica endpoint   : $REPLICA_PE"
Write-Host "Primary client VM  : $CLIENT_VM_PRIMARY"
Write-Host "Replica client VM  : $CLIENT_VM_SECONDARY"
Write-Host "Private DNS zone   : $PRIVATE_DNS_ZONE"
Write-Host "DB admin password  : $ADMIN_PASSWORD  (save this!)"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Reuse the fixed Lab 0 network names:
   - Hub resource groups: `rg-hub-swc`, `rg-hub-noe`
   - Spoke resource groups: `rg-spoke-swc`, `rg-spoke-noe`
   - Spoke VNets: `vnet-spoke-swc`, `vnet-spoke-noe`
   - Shared spoke subnets: `snet-workload`, `snet-private-endpoints`
2. Create or note these new lab values before you deploy anything:
   - Resource groups: `rg-pgsql-private-swc`, `rg-pgsql-private-noe`
   - Primary server: `pgsql-pe-swc-<suffix>`
   - Replica server: `pgsql-pe-noe-<suffix>`
   - Primary client VM: `vm-pg-client-swc-<suffix>`
   - Secondary client VM: `vm-pg-client-noe-<suffix>`
   - Primary private endpoint: `pe-pgsql-swc-<suffix>`
   - Replica private endpoint: `pe-pgsql-noe-<suffix>`
   - Private DNS zone: `privatelink.postgres.database.azure.com`
   - Database name: `sampledb`
3. Save the PostgreSQL admin password in a password manager. You will reuse it from the client VMs.

      </div>
    </div>

---

## Step 2 — Validate the Lab 0 Foundation

Lab 5-b assumes the Lab 0 hub-and-spoke resources already exist. Stop here and complete Lab 0 first if any of these checks fail.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet show \
  --resource-group $LAB0_SPOKE_RG_PRIMARY \
  --name $SPOKE_VNET_PRIMARY \
  --query '{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}' \
  --output table

az network vnet subnet show \
  --resource-group $LAB0_SPOKE_RG_PRIMARY \
  --vnet-name $SPOKE_VNET_PRIMARY \
  --name $WORKLOAD_SUBNET_NAME \
  --query '{Name:name, Prefix:addressPrefix}' \
  --output table

az network vnet subnet show \
  --resource-group $LAB0_SPOKE_RG_PRIMARY \
  --vnet-name $SPOKE_VNET_PRIMARY \
  --name $PE_SUBNET_NAME \
  --query '{Name:name, Prefix:addressPrefix}' \
  --output table

az network bastion show \
  --resource-group $LAB0_HUB_RG_PRIMARY \
  --name $PRIMARY_BASTION \
  --query '{Name:name, State:provisioningState}' \
  --output table

az network vnet show \
  --resource-group $LAB0_SPOKE_RG_SECONDARY \
  --name $SPOKE_VNET_SECONDARY \
  --query '{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}' \
  --output table

az network vnet subnet show \
  --resource-group $LAB0_SPOKE_RG_SECONDARY \
  --vnet-name $SPOKE_VNET_SECONDARY \
  --name $WORKLOAD_SUBNET_NAME \
  --query '{Name:name, Prefix:addressPrefix}' \
  --output table

az network vnet subnet show \
  --resource-group $LAB0_SPOKE_RG_SECONDARY \
  --vnet-name $SPOKE_VNET_SECONDARY \
  --name $PE_SUBNET_NAME \
  --query '{Name:name, Prefix:addressPrefix}' \
  --output table

az network bastion show \
  --resource-group $LAB0_HUB_RG_SECONDARY \
  --name $SECONDARY_BASTION \
  --query '{Name:name, State:provisioningState}' \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet show `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query '{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}' `
  --output table

az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query '{Name:name, Prefix:addressPrefix}' `
  --output table

az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PE_SUBNET_NAME `
  --query '{Name:name, Prefix:addressPrefix}' `
  --output table

az network bastion show `
  --resource-group $LAB0_HUB_RG_PRIMARY `
  --name $PRIMARY_BASTION `
  --query '{Name:name, State:provisioningState}' `
  --output table

az network vnet show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query '{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}' `
  --output table

az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query '{Name:name, Prefix:addressPrefix}' `
  --output table

az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PE_SUBNET_NAME `
  --query '{Name:name, Prefix:addressPrefix}' `
  --output table

az network bastion show `
  --resource-group $LAB0_HUB_RG_SECONDARY `
  --name $SECONDARY_BASTION `
  --query '{Name:name, State:provisioningState}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the Azure portal, verify these Lab 0 resources exist before you continue:
   - `rg-hub-swc` with Bastion `bas-hub-swc`
   - `rg-hub-noe` with Bastion `bas-hub-noe`
   - `rg-spoke-swc` with `vnet-spoke-swc`
   - `rg-spoke-noe` with `vnet-spoke-noe`
2. In each spoke VNet, confirm these subnets exist:
   - `snet-workload`
   - `snet-private-endpoints`
3. If any of those resources are missing, stop and complete Lab 0 first.

      </div>
    </div>

---

## Step 3 — Create Resource Groups and the Private DNS Zone

Create the two workload resource groups for the database resources, then create the shared PostgreSQL Private Link DNS zone in the primary-region resource group.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name $RG_PRIMARY   --location $PRIMARY_REGION   --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table

az network private-dns zone create \
  --resource-group $RG_PRIMARY \
  --name $PRIVATE_DNS_ZONE \
  --output table

PRIVATE_DNS_ZONE_ID=$(az network private-dns zone show \
  --resource-group $RG_PRIMARY \
  --name $PRIVATE_DNS_ZONE \
  --query id -o tsv)
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $PRIMARY_REGION --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table

az network private-dns zone create `
  --resource-group $RG_PRIMARY `
  --name $PRIVATE_DNS_ZONE `
  --output table

$PRIVATE_DNS_ZONE_ID = az network private-dns zone show `
  --resource-group $RG_PRIMARY `
  --name $PRIVATE_DNS_ZONE `
  --query id -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create `rg-pgsql-private-swc` in **Sweden Central**.
2. Create `rg-pgsql-private-noe` in **Norway East**.
3. Search for **Private DNS zones** and create a zone named `privatelink.postgres.database.azure.com` in `rg-pgsql-private-swc`.
4. Leave the zone empty for now; you will link it to the spoke VNets in the next step.

      </div>
    </div>

---

## Step 4 — Link the DNS Zone to Both Spoke VNets

Link the Private DNS zone to both Lab 0 spoke VNets so regional workloads can resolve PostgreSQL private endpoint records.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_VNET_ID=$(az network vnet show \
  --resource-group $LAB0_SPOKE_RG_PRIMARY \
  --name $SPOKE_VNET_PRIMARY \
  --query id -o tsv)

SECONDARY_VNET_ID=$(az network vnet show \
  --resource-group $LAB0_SPOKE_RG_SECONDARY \
  --name $SPOKE_VNET_SECONDARY \
  --query id -o tsv)

az network private-dns link vnet create \
  --resource-group $RG_PRIMARY \
  --zone-name $PRIVATE_DNS_ZONE \
  --name link-vnet-spoke-swc \
  --virtual-network $PRIMARY_VNET_ID \
  --registration-enabled false \
  --output table

az network private-dns link vnet create \
  --resource-group $RG_PRIMARY \
  --zone-name $PRIVATE_DNS_ZONE \
  --name link-vnet-spoke-noe \
  --virtual-network $SECONDARY_VNET_ID \
  --registration-enabled false \
  --output table

az network private-dns link vnet list \
  --resource-group $RG_PRIMARY \
  --zone-name $PRIVATE_DNS_ZONE \
  --query '[].{Link:name, Registration:registrationEnabled, VirtualNetwork:virtualNetwork.id}' \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_VNET_ID = az network vnet show `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query id -o tsv

$SECONDARY_VNET_ID = az network vnet show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query id -o tsv

az network private-dns link vnet create `
  --resource-group $RG_PRIMARY `
  --zone-name $PRIVATE_DNS_ZONE `
  --name link-vnet-spoke-swc `
  --virtual-network $PRIMARY_VNET_ID `
  --registration-enabled false `
  --output table

az network private-dns link vnet create `
  --resource-group $RG_PRIMARY `
  --zone-name $PRIVATE_DNS_ZONE `
  --name link-vnet-spoke-noe `
  --virtual-network $SECONDARY_VNET_ID `
  --registration-enabled false `
  --output table

az network private-dns link vnet list `
  --resource-group $RG_PRIMARY `
  --zone-name $PRIVATE_DNS_ZONE `
  --query '[].{Link:name, Registration:registrationEnabled, VirtualNetwork:virtualNetwork.id}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the `privatelink.postgres.database.azure.com` Private DNS zone.
2. Go to **Virtual network links** and create a link for `vnet-spoke-swc`.
3. Create a second link for `vnet-spoke-noe`.
4. Leave **auto registration** disabled for both links.
5. Confirm both spoke VNets now appear in the zone's link list.

      </div>
    </div>

---

## Step 5 — Create Regional Client VMs

Create one small Linux VM in each Lab 0 workload subnet. These VMs have no public IPs; you will reach them through Azure Bastion from the portal or through Azure VM Run Command from the CLI.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_WORKLOAD_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $LAB0_SPOKE_RG_PRIMARY \
  --vnet-name $SPOKE_VNET_PRIMARY \
  --name $WORKLOAD_SUBNET_NAME \
  --query id -o tsv)

SECONDARY_WORKLOAD_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $LAB0_SPOKE_RG_SECONDARY \
  --vnet-name $SPOKE_VNET_SECONDARY \
  --name $WORKLOAD_SUBNET_NAME \
  --query id -o tsv)

az vm create \
  --name $CLIENT_VM_PRIMARY \
  --resource-group $RG_PRIMARY \
  --location $PRIMARY_REGION \
  --image Ubuntu2204 \
  --size Standard_B1ms \
  --admin-username $VM_ADMIN \
  --generate-ssh-keys \
  --subnet $PRIMARY_WORKLOAD_SUBNET_ID \
  --public-ip-address "" \
  --output table

az vm create \
  --name $CLIENT_VM_SECONDARY \
  --resource-group $RG_SECONDARY \
  --location $SECONDARY_REGION \
  --image Ubuntu2204 \
  --size Standard_B1ms \
  --admin-username $VM_ADMIN \
  --generate-ssh-keys \
  --subnet $SECONDARY_WORKLOAD_SUBNET_ID \
  --public-ip-address "" \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_WORKLOAD_SUBNET_ID = az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query id -o tsv

$SECONDARY_WORKLOAD_SUBNET_ID = az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query id -o tsv

az vm create `
  --name $CLIENT_VM_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --image Ubuntu2204 `
  --size Standard_B1ms `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --subnet $PRIMARY_WORKLOAD_SUBNET_ID `
  --public-ip-address "" `
  --output table

az vm create `
  --name $CLIENT_VM_SECONDARY `
  --resource-group $RG_SECONDARY `
  --location $SECONDARY_REGION `
  --image Ubuntu2204 `
  --size Standard_B1ms `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --subnet $SECONDARY_WORKLOAD_SUBNET_ID `
  --public-ip-address "" `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a Linux VM named `vm-pg-client-swc-<suffix>` in `rg-pgsql-private-swc`.
   - Region: **Sweden Central**
   - Image: **Ubuntu 22.04 LTS**
   - Size: **Standard_B1ms** (or similar small lab size)
   - Virtual network: `vnet-spoke-swc`
   - Subnet: `snet-workload`
   - Public inbound ports: **None**
   - Public IP: **None**
2. Create a second Linux VM named `vm-pg-client-noe-<suffix>` in `rg-pgsql-private-noe` with the same settings, but in **Norway East** on `vnet-spoke-noe/snet-workload`.
3. Keep both VMs private. Later portal steps use the existing Lab 0 Bastion hosts for access.

      </div>
    </div>

<div class="lab-note">
<strong>VM note:</strong> These VMs are only private test clients for the lab. They deliberately have no public IPs. In a real workload, these could be your application nodes, AKS pods, or App Service instances integrated into the same spoke networks.
</div>

---

## Step 6 — Create the Primary PostgreSQL Flexible Server

Create the Sweden Central source server in public-access networking mode, but do not add any public firewall rules. Private Link needs the public-access deployment model, but the client path remains private.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server create \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --location $PRIMARY_REGION \
  --admin-user $ADMIN_USER \
  --admin-password $ADMIN_PASSWORD \
  --sku-name Standard_D2ads_v5 \
  --tier GeneralPurpose \
  --storage-size 32 \
  --version 16 \
  --public-access None \
  --output table

az postgres flexible-server show \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query '{Name:name, State:state, Location:location, SKU:sku.name, Version:version}' \
  --output table

az postgres flexible-server firewall-rule list \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server create `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --admin-user $ADMIN_USER `
  --admin-password $ADMIN_PASSWORD `
  --sku-name Standard_D2ads_v5 `
  --tier GeneralPurpose `
  --storage-size 32 `
  --version 16 `
  --public-access None `
  --output table

az postgres flexible-server show `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '{Name:name, State:state, Location:location, SKU:sku.name, Version:version}' `
  --output table

az postgres flexible-server firewall-rule list `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create an **Azure Database for PostgreSQL flexible server** in `rg-pgsql-private-swc`.
2. On **Basics**, choose:
   - Region: **Sweden Central**
   - Server name: your `pgsql-pe-swc-<suffix>` value
   - Compute tier: **General Purpose**
   - Admin username/password: the values you saved in Step 1
3. On **Networking**, choose the **Public access** deployment model, but do **not** add client IP rules.
4. Create the server.
5. After deployment, open **Networking** or **Firewall rules** and confirm there are no public allow-list entries.

      </div>
    </div>

<div class="lab-note">
<strong>Security reminder:</strong> In this lab, <code>public access</code> is only the service deployment mode required for Private Link. With no firewall rules and no public client IPs allowed, the practical data path stays private.
</div>

---

## Step 7 — Create the Primary Private Endpoint

Create a private endpoint for the source server in the Lab 0 primary spoke private-endpoint subnet, then attach it to the shared Private DNS zone.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_PE_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $LAB0_SPOKE_RG_PRIMARY \
  --vnet-name $SPOKE_VNET_PRIMARY \
  --name $PE_SUBNET_NAME \
  --query id -o tsv)

PRIMARY_SERVER_ID=$(az postgres flexible-server show \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query id -o tsv)

PRIMARY_GROUP_ID=$(az postgres flexible-server private-link-resource list \
  --server-name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query '[0].groupId' -o tsv)

az network private-endpoint create \
  --name $PRIMARY_PE \
  --resource-group $RG_PRIMARY \
  --location $PRIMARY_REGION \
  --subnet $PRIMARY_PE_SUBNET_ID \
  --private-connection-resource-id $PRIMARY_SERVER_ID \
  --group-id $PRIMARY_GROUP_ID \
  --connection-name ${PRIMARY_PE}-conn \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group $RG_PRIMARY \
  --endpoint-name $PRIMARY_PE \
  --name default \
  --private-dns-zone $PRIVATE_DNS_ZONE_ID \
  --zone-name $PRIVATE_DNS_ZONE \
  --output table

az postgres flexible-server private-endpoint-connection list \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query '[].{Connection:name, State:privateLinkServiceConnectionState.status}' \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_PE_SUBNET_ID = az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PE_SUBNET_NAME `
  --query id -o tsv

$PRIMARY_SERVER_ID = az postgres flexible-server show `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query id -o tsv

$PRIMARY_GROUP_ID = az postgres flexible-server private-link-resource list `
  --server-name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '[0].groupId' -o tsv

az network private-endpoint create `
  --name $PRIMARY_PE `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --subnet $PRIMARY_PE_SUBNET_ID `
  --private-connection-resource-id $PRIMARY_SERVER_ID `
  --group-id $PRIMARY_GROUP_ID `
  --connection-name "$PRIMARY_PE-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $RG_PRIMARY `
  --endpoint-name $PRIMARY_PE `
  --name default `
  --private-dns-zone $PRIVATE_DNS_ZONE_ID `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table

az postgres flexible-server private-endpoint-connection list `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '[].{Connection:name, State:privateLinkServiceConnectionState.status}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary PostgreSQL flexible server.
2. Go to **Networking** → **Private access** or **Private endpoint connections**.
3. Create a new private endpoint with these choices:
   - Target subnet: `vnet-spoke-swc / snet-private-endpoints`
   - Resource group: `rg-pgsql-private-swc`
   - Private DNS integration: use the existing `privatelink.postgres.database.azure.com` zone
4. Wait for the connection state to show **Approved**.
5. If DNS record creation is delayed for a minute or two, wait before you test connectivity.

      </div>
    </div>

---

## Step 8 — Create a Sample Database and Table from the Primary VM

Use the private client VM in Sweden Central to install the PostgreSQL client, verify private DNS resolution, create the sample database, and insert a few rows.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_SETUP_SCRIPT=$(cat <<SCRIPT
set -e
sudo apt-get update
sudo apt-get install -y postgresql-client
export PGPASSWORD='$ADMIN_PASSWORD'
getent hosts $PRIMARY_SERVER.postgres.database.azure.com
psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=postgres user=$ADMIN_USER sslmode=require" -c "CREATE DATABASE $DB_NAME;"
psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "CREATE TABLE orders (id SERIAL PRIMARY KEY, customer_name VARCHAR(100) NOT NULL, product VARCHAR(100) NOT NULL, amount DECIMAL(10,2) NOT NULL, region VARCHAR(50) DEFAULT 'swedencentral', created_at TIMESTAMPTZ DEFAULT NOW());"
psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "INSERT INTO orders (customer_name, product, amount) VALUES ('Alice','Azure VM',149.99), ('Bob','Azure Storage',29.99), ('Charlie','Azure Functions',49.99), ('Diana','Azure Cosmos DB',199.99), ('Eve','Azure Key Vault',19.99);"
psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "SELECT * FROM orders;"
SCRIPT
)

az vm run-command invoke \
  --resource-group $RG_PRIMARY \
  --name $CLIENT_VM_PRIMARY \
  --command-id RunShellScript \
  --scripts "$PRIMARY_SETUP_SCRIPT" \
  --query 'value[0].message' \
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PrimarySetupScript = @"
set -e
sudo apt-get update
sudo apt-get install -y postgresql-client
export PGPASSWORD='$ADMIN_PASSWORD'
getent hosts $PRIMARY_SERVER.postgres.database.azure.com
psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=postgres user=$ADMIN_USER sslmode=require" -c "CREATE DATABASE $DB_NAME;"
psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "CREATE TABLE orders (id SERIAL PRIMARY KEY, customer_name VARCHAR(100) NOT NULL, product VARCHAR(100) NOT NULL, amount DECIMAL(10,2) NOT NULL, region VARCHAR(50) DEFAULT 'swedencentral', created_at TIMESTAMPTZ DEFAULT NOW());"
psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "INSERT INTO orders (customer_name, product, amount) VALUES ('Alice','Azure VM',149.99), ('Bob','Azure Storage',29.99), ('Charlie','Azure Functions',49.99), ('Diana','Azure Cosmos DB',199.99), ('Eve','Azure Key Vault',19.99);"
psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "SELECT * FROM orders;"
"@

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $CLIENT_VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $PrimarySetupScript `
  --query 'value[0].message' `
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open Bastion `bas-hub-swc` from Lab 0 and connect to `vm-pg-client-swc-<suffix>`.
2. On the VM, install the PostgreSQL client if needed:
   - `sudo apt-get update`
   - `sudo apt-get install -y postgresql-client`
3. Run `getent hosts <primary-server>.postgres.database.azure.com` and confirm it resolves to a private IP.
4. Use `psql` to connect to the primary server and create `sampledb`.
5. Run the table creation and insert statements from the Bash or PowerShell tab.
6. Confirm the five sample rows are returned from `sampledb.orders`.

      </div>
    </div>

<div class="lab-note">
<strong>Run Command note:</strong> Azure VM Run Command reaches the VM through Azure control plane channels, but the PostgreSQL session itself runs <em>from the VM</em> and resolves the server through the private endpoint and private DNS zone.
</div>

---

## Step 9 — Create a Cross-Region Read Replica

Create the Norway East replica from the Sweden Central source server. The replica remains unreachable from public clients until you also add its private endpoint.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SOURCE_ID=$(az postgres flexible-server show \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query id -o tsv)

az postgres flexible-server replica create \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --source-server $SOURCE_ID \
  --location $SECONDARY_REGION \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SOURCE_ID = az postgres flexible-server show `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query id -o tsv

az postgres flexible-server replica create `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --source-server $SOURCE_ID `
  --location $SECONDARY_REGION `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary PostgreSQL flexible server.
2. Go to **Replication** or **Read replicas**.
3. Choose **Add replica**.
4. Set the target resource group to `rg-pgsql-private-noe` and the region to **Norway East**.
5. Create the replica and wait for the initial seeding process to finish.

      </div>
    </div>

> **Note:** Replica creation can take 15–20 minutes because Azure seeds the replica with a full base backup before WAL streaming settles into steady state.

---

## Step 10 — Create the Replica Private Endpoint

Create a Norway East private endpoint for the replica so the secondary-region client VM can reach it privately.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SECONDARY_PE_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $LAB0_SPOKE_RG_SECONDARY \
  --vnet-name $SPOKE_VNET_SECONDARY \
  --name $PE_SUBNET_NAME \
  --query id -o tsv)

REPLICA_SERVER_ID=$(az postgres flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query id -o tsv)

REPLICA_GROUP_ID=$(az postgres flexible-server private-link-resource list \
  --server-name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query '[0].groupId' -o tsv)

az network private-endpoint create \
  --name $REPLICA_PE \
  --resource-group $RG_SECONDARY \
  --location $SECONDARY_REGION \
  --subnet $SECONDARY_PE_SUBNET_ID \
  --private-connection-resource-id $REPLICA_SERVER_ID \
  --group-id $REPLICA_GROUP_ID \
  --connection-name ${REPLICA_PE}-conn \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group $RG_SECONDARY \
  --endpoint-name $REPLICA_PE \
  --name default \
  --private-dns-zone $PRIVATE_DNS_ZONE_ID \
  --zone-name $PRIVATE_DNS_ZONE \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SECONDARY_PE_SUBNET_ID = az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PE_SUBNET_NAME `
  --query id -o tsv

$REPLICA_SERVER_ID = az postgres flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query id -o tsv

$REPLICA_GROUP_ID = az postgres flexible-server private-link-resource list `
  --server-name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '[0].groupId' -o tsv

az network private-endpoint create `
  --name $REPLICA_PE `
  --resource-group $RG_SECONDARY `
  --location $SECONDARY_REGION `
  --subnet $SECONDARY_PE_SUBNET_ID `
  --private-connection-resource-id $REPLICA_SERVER_ID `
  --group-id $REPLICA_GROUP_ID `
  --connection-name "$REPLICA_PE-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $RG_SECONDARY `
  --endpoint-name $REPLICA_PE `
  --name default `
  --private-dns-zone $PRIVATE_DNS_ZONE_ID `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Norway East replica server.
2. Create a private endpoint in `vnet-spoke-noe / snet-private-endpoints`.
3. Attach it to the same `privatelink.postgres.database.azure.com` Private DNS zone.
4. Wait for the private endpoint connection to show **Approved**.

      </div>
    </div>

---

## Step 11 — Verify the Replica and Private Endpoint Connections

Confirm the server is a read replica, then check that both private endpoint connections are approved and that the replica DNS name resolves privately from the secondary-region client VM.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query '{Name:name, State:state, Location:location, ReplicationRole:replicationRole, SourceServer:sourceServerResourceId}' \
  --output table

az postgres flexible-server private-endpoint-connection list \
  --name $PRIMARY_SERVER \
  --resource-group $RG_PRIMARY \
  --query '[].{Server:name, Connection:privateEndpoint.id, State:privateLinkServiceConnectionState.status}' \
  --output table

az postgres flexible-server private-endpoint-connection list \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query '[].{Server:name, Connection:privateEndpoint.id, State:privateLinkServiceConnectionState.status}' \
  --output table

az vm run-command invoke \
  --resource-group $RG_SECONDARY \
  --name $CLIENT_VM_SECONDARY \
  --command-id RunShellScript \
  --scripts 'set -e' 'getent hosts '$REPLICA_SERVER'.postgres.database.azure.com' \
  --query 'value[0].message' \
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, State:state, Location:location, ReplicationRole:replicationRole, SourceServer:sourceServerResourceId}' `
  --output table

az postgres flexible-server private-endpoint-connection list `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '[].{Server:name, Connection:privateEndpoint.id, State:privateLinkServiceConnectionState.status}' `
  --output table

az postgres flexible-server private-endpoint-connection list `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '[].{Server:name, Connection:privateEndpoint.id, State:privateLinkServiceConnectionState.status}' `
  --output table

$ReplicaDnsScript = @"
set -e
getent hosts $REPLICA_SERVER.postgres.database.azure.com
"@

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $CLIENT_VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $ReplicaDnsScript `
  --query 'value[0].message' `
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Norway East replica server and confirm it is provisioned in **Norway East**.
2. Go to **Replication** and verify it still shows the Sweden Central source server.
3. Open **Private endpoint connections** on both the source and replica servers and confirm the connection state is **Approved**.
4. Use Bastion `bas-hub-noe` to connect to the secondary client VM.
5. Run `getent hosts <replica-server>.postgres.database.azure.com` and confirm the name resolves to a private IP.

      </div>
    </div>

Expected output: the replica should report `ReplicationRole` as `AsyncReplica`, and the private endpoint connection state should be `Approved`.

---

## Step 12 — Verify Data Replication from the Secondary VM

Query the replica over its private endpoint from the Norway East client VM. This proves both the data path and the DNS path are private and working.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
REPLICA_QUERY_SCRIPT=$(cat <<SCRIPT
set -e
sudo apt-get update
sudo apt-get install -y postgresql-client
export PGPASSWORD='$ADMIN_PASSWORD'
psql "host=$REPLICA_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "SELECT * FROM orders;"
SCRIPT
)

az vm run-command invoke \
  --resource-group $RG_SECONDARY \
  --name $CLIENT_VM_SECONDARY \
  --command-id RunShellScript \
  --scripts "$REPLICA_QUERY_SCRIPT" \
  --query 'value[0].message' \
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$ReplicaQueryScript = @"
set -e
sudo apt-get update
sudo apt-get install -y postgresql-client
export PGPASSWORD='$ADMIN_PASSWORD'
psql "host=$REPLICA_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "SELECT * FROM orders;"
"@

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $CLIENT_VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $ReplicaQueryScript `
  --query 'value[0].message' `
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Use Bastion `bas-hub-noe` to connect to the secondary client VM.
2. Install the PostgreSQL client if you have not already done so:
   - `sudo apt-get update`
   - `sudo apt-get install -y postgresql-client`
3. Connect to `sampledb` on the replica server using `psql`.
4. Run `SELECT * FROM orders;`.
5. Confirm the five rows inserted on the primary server are present.

      </div>
    </div>

You should see the same five rows you created in Sweden Central. The replica remains **read-only** until you promote it.

---

## Step 13 — Monitor Replication Lag

Use the control plane to confirm the replica is healthy, then inspect lag metrics in Azure Monitor.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query '{Name:name, ReplicationRole:replicationRole, State:state}' \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, ReplicationRole:replicationRole, State:state}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the replica server.
2. Go to **Monitoring** → **Metrics**.
3. Chart **Max Physical Replication Lag** and **Read Replica Lag** over the last 30 minutes.
4. Confirm lag trends back toward zero after the initial seeding phase completes.

      </div>
    </div>

---

## Step 14 — Promote the Replica (Simulate Failover)

Promote the Norway East replica to a standalone writable server. This is the same one-way failover step as the public-access variant.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server replica promote \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --yes \
  --output table

az postgres flexible-server show \
  --name $REPLICA_SERVER \
  --resource-group $RG_SECONDARY \
  --query '{Name:name, State:state, ReplicationRole:replicationRole}' \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server replica promote `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --yes `
  --output table

az postgres flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, State:state, ReplicationRole:replicationRole}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Norway East replica server.
2. Go to **Replication**.
3. Choose **Promote**.
4. Confirm the warning that promotion is irreversible.
5. Wait for the operation to finish, then verify the server is now standalone and writable.

      </div>
    </div>

Expected: `ReplicationRole` should now be `None`.

---

## Step 15 — Validate Write Access on the Promoted Server

Use the Norway East client VM again. After promotion, inserts should succeed over the same private endpoint path.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PROMOTED_WRITE_SCRIPT=$(cat <<SCRIPT
set -e
sudo apt-get install -y postgresql-client
export PGPASSWORD='$ADMIN_PASSWORD'
psql "host=$REPLICA_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "INSERT INTO orders (customer_name, product, amount, region) VALUES ('Frank','Private Failover Test',99.99,'norwayeast'); SELECT * FROM orders;"
SCRIPT
)

az vm run-command invoke \
  --resource-group $RG_SECONDARY \
  --name $CLIENT_VM_SECONDARY \
  --command-id RunShellScript \
  --scripts "$PROMOTED_WRITE_SCRIPT" \
  --query 'value[0].message' \
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PromotedWriteScript = @"
set -e
sudo apt-get install -y postgresql-client
export PGPASSWORD='$ADMIN_PASSWORD'
psql "host=$REPLICA_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" -c "INSERT INTO orders (customer_name, product, amount, region) VALUES ('Frank','Private Failover Test',99.99,'norwayeast'); SELECT * FROM orders;"
"@

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $CLIENT_VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $PromotedWriteScript `
  --query 'value[0].message' `
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Reconnect to the secondary client VM through Bastion.
2. Use `psql` to connect to the promoted server.
3. Run an `INSERT` against `sampledb.orders`, then query the table again.
4. Confirm the new row appears. That proves the promoted server is now writable even though clients still use the private endpoint path.

      </div>
    </div>

---

## Step 16 — Cleanup

Delete only the private PostgreSQL lab resource groups. Keep the Lab 0 hub-and-spoke foundation if you plan to reuse it for other secured `B` variants.

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
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups** in the Azure portal.
2. Delete `rg-pgsql-private-swc`.
3. Delete `rg-pgsql-private-noe`.
4. Do <strong>not</strong> delete `rg-hub-swc`, `rg-hub-noe`, `rg-spoke-swc`, or `rg-spoke-noe` unless you are also done with the Lab 0 foundation.

      </div>
    </div>

---

## Discussion & Next Steps

### Why This Lab Uses Private Link Instead of VNet Injection

- **Private endpoints fit the Lab 0 landing zone directly** because Lab 0 already reserves `snet-private-endpoints` in both spokes.
- **PostgreSQL Flexible Server supports read replicas with Private Link**, so the geo-replication workflow still works.
- **Private Link currently applies to servers created in public-access networking mode.** That is why this lab keeps the deployment model public, but adds no public firewall rules.
- If you prefer **private access (VNet integration)** instead, that is a different PostgreSQL deployment model and does not use private endpoints on those servers.

### Failover Strategy

1. **Monitor** the replica health and lag.
2. **Promote** the Norway East replica during an outage or drill.
3. **Fail over the application tier** to the secondary region as well, so clients stay close to the secondary private endpoint.
4. **Re-protect** by creating a new read replica after failover testing is complete.

### Design Extension Ideas

- Add **App Service** or **Functions** from later labs into the same spokes and route them to the PostgreSQL private endpoints.
- Evaluate **virtual endpoints** after the private endpoint topology is stable if you want a more abstract writer/reader naming model.
- If a single regional application must reach both database servers privately, create additional private endpoints in that application's VNet.

### Cost Considerations

| Component | Approximate Monthly Cost |
|---|---|
| Primary PostgreSQL Flexible Server | Check Azure pricing calculator |
| Replica PostgreSQL Flexible Server | Check Azure pricing calculator |
| Private endpoints (2) | Additional |
| Small Linux VMs (2) | Additional |
| Lab 0 Bastion / Firewall | Already running from Lab 0 |
| **Total** | **Depends on region, runtime, and cleanup timing** |

---

## Useful Links

* 📖 [Read replicas in Azure Database for PostgreSQL – Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-read-replicas)
* 📖 [Geo-replication concepts](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-read-replicas-geo)
* 📖 [Azure Database for PostgreSQL networking with Private Link](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-networking-private-link)
* 📖 [Private endpoint DNS integration](https://learn.microsoft.com/azure/private-link/private-endpoint-dns)
* 📖 [Azure CLI reference for PostgreSQL Flexible Server](https://learn.microsoft.com/cli/azure/postgres/flexible-server)

---

[← Lab 5-a — PostgreSQL Geo-Replication](lab-05a-postgresql-geo-replication.md) | [Lab 5-b — Private PostgreSQL Geo-Replication](lab-05b-postgresql-private-geo-replication.md)
