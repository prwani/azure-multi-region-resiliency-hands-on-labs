---
layout: default
title: "Lab 2-b: Azure SQL Database – Private Geo-Replication &amp; Failover"
---

[Lab 2-a: Azure SQL Database – Geo-Replication & Failover](./lab-02a-sql-geo-replication.md) | **Lab 2-b: Azure SQL Database – Private Geo-Replication & Failover**

# Lab 2-b: Azure SQL Database – Private Geo-Replication & Failover

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

Lab 2-b is the secure companion to Lab 2-a. It assumes you already completed
**Lab 0** and are reusing its fixed hub-and-spoke landing zone in
**Sweden Central** and **Norway East**.

The resiliency story stays the same: a primary Azure SQL Database in Sweden
Central replicates asynchronously to Norway East, and a Failover Group gives you
stable listener names for failover drills. What changes in this variant is the
**network path** — the data plane stays private by using **private endpoints**,
**private DNS**, and **no-public-IP validation VMs** inside the Lab 0 spoke VNets.

| Feature | Detail |
|---|---|
| **Deployment model** | Azure SQL Database on paired logical SQL servers |
| **Replication pattern** | Active Geo-Replication + Failover Group |
| **Primary / DR regions** | Sweden Central → Norway East |
| **Private connectivity model** | Private endpoints in each spoke + `privatelink.database.windows.net` |
| **Client validation path** | No-public-IP Ubuntu VMs in each spoke workload subnet |
| **Failover model** | Planned manual failover via the Failover Group |

### What Changes Compared to Lab 2-a?

| Area | Lab 2-a | Lab 2-b |
|---|---|---|
| **Network exposure** | Public endpoint + firewall rules | Private endpoints only |
| **Lab 0 dependency** | Not required | Required |
| **Private DNS** | Not required for the main flow | Required |
| **Validation client** | Local `sqlcmd`, Query Editor, or Cloud Shell | Regional validation VMs with no public IP |
| **Public network access** | Left enabled | Disabled after private connectivity is verified |

### Why This Secure Variant Matters

- **No public data plane** — neither SQL server needs public inbound connectivity.
- **Regional isolation** — each spoke validates its local private endpoint without flattening the two regional stamps together.
- **Reusable landing zone alignment** — the lab consumes the exact spoke VNets and subnets created in Lab 0.
- **Operational realism** — your application, admin jump host, or automation must resolve private FQDNs and connect from inside the trusted network boundary.

<div class="lab-note">
<strong>Important:</strong> Use the standard Azure SQL names such as <code>&lt;server&gt;.database.windows.net</code> and the Failover Group listener FQDNs. Do <strong>not</strong> connect directly to <code>*.privatelink.database.windows.net</code> or to the private IP addresses.
</div>

---

## Architecture

```text
                           Failover Group listeners
         fg-multiregion-sql-<suffix>.database.windows.net  (read-write)
fg-multiregion-sql-<suffix>.secondary.database.windows.net  (read-only)

                  Shared private DNS zone linked to both spokes
                       privatelink.database.windows.net
                                      │
          ┌───────────────────────────┴───────────────────────────┐
          │                                                       │
          ▼                                                       ▼
┌──────────────────────── Sweden Central ───────────────────────┐  ┌──────────────────────── Norway East ───────────────────────┐
│ rg-hub-swc / vnet-hub-swc                                    │  │ rg-hub-noe / vnet-hub-noe                                  │
│   • afw-hub-swc   • bas-hub-swc   (from Lab 0, unchanged)    │  │   • afw-hub-noe   • bas-hub-noe   (from Lab 0, unchanged)  │
│                                                               │  │                                                             │
│ rg-spoke-swc / vnet-spoke-swc                                │  │ rg-spoke-noe / vnet-spoke-noe                              │
│   ├─ snet-workload                                            │  │   ├─ snet-workload                                          │
│   │   └─ vm-sqltest-swc-xxxxx  (no public IP)                │  │   │   └─ vm-sqltest-noe-xxxxx  (no public IP)              │
│   └─ snet-private-endpoints                                   │  │   └─ snet-private-endpoints                                 │
│       └─ pep-sql-swc-xxxxx                                    │  │       └─ pep-sql-noe-xxxxx                                  │
│                                                               │  │                                                             │
│ rg-sql-private-swc                                            │  │ rg-sql-private-noe                                          │
│   └─ sql-pe-swc-xxxxx                                         │  │   └─ sql-pe-noe-xxxxx                                       │
│      └─ sqldb-sample  (primary before failover)              │  │      └─ sqldb-sample  (secondary before failover)          │
└───────────────────────────────────────────────────────────────┘  └─────────────────────────────────────────────────────────────┘

                         Async geo-replication between regions
```

**Traffic pattern for this lab:**

1. The Sweden validation VM connects privately to the **primary** SQL server.
2. The Norway validation VM connects privately to the **secondary** SQL server.
3. Replication happens asynchronously between the two Azure SQL servers.
4. During the failover drill, the Norway server becomes primary and the Norway
   validation VM becomes the correct client for the read-write listener check.

<div class="lab-note">
<strong>Important:</strong> Lab 0 intentionally does <em>not</em> create cross-region spoke-to-spoke peering. This lab respects that design. Instead of forcing one client VM to reach both regions, validate each regional endpoint from a VM inside the matching regional spoke.
</div>

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Completed Lab 0** | You must already have `rg-spoke-swc`, `rg-spoke-noe`, `vnet-spoke-swc`, `vnet-spoke-noe`, `snet-workload`, and `snet-private-endpoints` in both regions |
| **Azure CLI** | Version 2.50 or later recommended |
| **Azure subscription** | Needs permission to create SQL servers, SQL databases, private DNS zones, private endpoints, and Linux VMs |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash |
| **PowerShell 7+** | Recommended if you want to follow the PowerShell tabs |
| **Budget awareness** | Two SQL servers, one database, two private endpoints, and two small validation VMs incur cost while running |
| **Operational note** | The lab uses `az vm run-command invoke`, so you do not need a local `sqlcmd` installation |

<div class="lab-note">
<strong>Network planning note:</strong> Lab 0 already reserved <code>snet-private-endpoints</code> in each spoke. This lab consumes those subnets exactly as intended and keeps the validation VMs in the reusable <code>snet-workload</code> subnets.
</div>

---

## How These Tabs Work

This page uses a shared tab preference:

- If you click **Bash** in one step, the rest of the page switches to **Bash**
- The selection is remembered for the page in your browser
- Every code block gets a copy button in the top-right corner

---

## Step 1 — Validate the Lab 0 Foundation and Set Variables

This lab reuses the fixed spoke resource groups and VNets from Lab 0. Start by
confirming they exist, then define the SQL-specific names you will use in the
secure variant.

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

RG_PRIMARY="rg-sql-private-swc"
RG_SECONDARY="rg-sql-private-noe"

SPOKE_RG_PRIMARY="rg-spoke-swc"
SPOKE_RG_SECONDARY="rg-spoke-noe"

SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_SECONDARY="vnet-spoke-noe"
WORKLOAD_SUBNET_NAME="snet-workload"
PRIVATE_ENDPOINT_SUBNET_NAME="snet-private-endpoints"

DNS_ZONE_NAME="privatelink.database.windows.net"

PRIMARY_SERVER="sql-pe-swc-${RANDOM_SUFFIX}"
SECONDARY_SERVER="sql-pe-noe-${RANDOM_SUFFIX}"
PRIMARY_ENDPOINT="pep-sql-swc-${RANDOM_SUFFIX}"
SECONDARY_ENDPOINT="pep-sql-noe-${RANDOM_SUFFIX}"

FG_NAME="fg-multiregion-sql-${RANDOM_SUFFIX}"
DB_NAME="sqldb-sample"

VM_PRIMARY="vm-sqltest-swc-${RANDOM_SUFFIX}"
VM_SECONDARY="vm-sqltest-noe-${RANDOM_SUFFIX}"

SQL_ADMIN_USER="sqladmin"
SQL_ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"
VM_ADMIN_USER="azureuser"
VM_ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"

az network vnet show \
  --resource-group "$SPOKE_RG_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query '{VNet:name, Location:location}' \
  --output table

az network vnet show \
  --resource-group "$SPOKE_RG_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query '{VNet:name, Location:location}' \
  --output table

az network vnet subnet show \
  --resource-group "$SPOKE_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$WORKLOAD_SUBNET_NAME" \
  --query '{Subnet:name, Prefix:addressPrefix}' \
  --output table

az network vnet subnet show \
  --resource-group "$SPOKE_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$PRIVATE_ENDPOINT_SUBNET_NAME" \
  --query '{Subnet:name, Prefix:addressPrefix}' \
  --output table

az network vnet subnet show \
  --resource-group "$SPOKE_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$WORKLOAD_SUBNET_NAME" \
  --query '{Subnet:name, Prefix:addressPrefix}' \
  --output table

az network vnet subnet show \
  --resource-group "$SPOKE_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$PRIVATE_ENDPOINT_SUBNET_NAME" \
  --query '{Subnet:name, Prefix:addressPrefix}' \
  --output table

echo "Primary SQL server   : $PRIMARY_SERVER"
echo "Secondary SQL server : $SECONDARY_SERVER"
echo "Failover Group       : $FG_NAME"
echo "Primary validation VM: $VM_PRIMARY"
echo "Secondary validation VM: $VM_SECONDARY"
echo "SQL admin user       : $SQL_ADMIN_USER"
echo "SQL admin password   : $SQL_ADMIN_PASSWORD   (save this!)"
echo "VM admin user        : $VM_ADMIN_USER"
echo "VM admin password    : $VM_ADMIN_PASSWORD    (save this!)"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$RG_PRIMARY = "rg-sql-private-swc"
$RG_SECONDARY = "rg-sql-private-noe"

$SPOKE_RG_PRIMARY = "rg-spoke-swc"
$SPOKE_RG_SECONDARY = "rg-spoke-noe"

$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"
$WORKLOAD_SUBNET_NAME = "snet-workload"
$PRIVATE_ENDPOINT_SUBNET_NAME = "snet-private-endpoints"

$DNS_ZONE_NAME = "privatelink.database.windows.net"

$PRIMARY_SERVER = "sql-pe-swc-$RANDOM_SUFFIX"
$SECONDARY_SERVER = "sql-pe-noe-$RANDOM_SUFFIX"
$PRIMARY_ENDPOINT = "pep-sql-swc-$RANDOM_SUFFIX"
$SECONDARY_ENDPOINT = "pep-sql-noe-$RANDOM_SUFFIX"

$FG_NAME = "fg-multiregion-sql-$RANDOM_SUFFIX"
$DB_NAME = "sqldb-sample"

$VM_PRIMARY = "vm-sqltest-swc-$RANDOM_SUFFIX"
$VM_SECONDARY = "vm-sqltest-noe-$RANDOM_SUFFIX"

$SQL_ADMIN_USER = "sqladmin"
$SQL_ADMIN_PASSWORD = "P@ssw0rd-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
$VM_ADMIN_USER = "azureuser"
$VM_ADMIN_PASSWORD = "P@ssw0rd-$([guid]::NewGuid().ToString('N').Substring(0, 8))"

az network vnet show `
  --resource-group $SPOKE_RG_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query '{VNet:name, Location:location}' `
  --output table

az network vnet show `
  --resource-group $SPOKE_RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query '{VNet:name, Location:location}' `
  --output table

az network vnet subnet show `
  --resource-group $SPOKE_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query '{Subnet:name, Prefix:addressPrefix}' `
  --output table

az network vnet subnet show `
  --resource-group $SPOKE_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PRIVATE_ENDPOINT_SUBNET_NAME `
  --query '{Subnet:name, Prefix:addressPrefix}' `
  --output table

az network vnet subnet show `
  --resource-group $SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query '{Subnet:name, Prefix:addressPrefix}' `
  --output table

az network vnet subnet show `
  --resource-group $SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PRIVATE_ENDPOINT_SUBNET_NAME `
  --query '{Subnet:name, Prefix:addressPrefix}' `
  --output table

Write-Host "Primary SQL server     : $PRIMARY_SERVER"
Write-Host "Secondary SQL server   : $SECONDARY_SERVER"
Write-Host "Failover Group         : $FG_NAME"
Write-Host "Primary validation VM  : $VM_PRIMARY"
Write-Host "Secondary validation VM: $VM_SECONDARY"
Write-Host "SQL admin user         : $SQL_ADMIN_USER"
Write-Host "SQL admin password     : $SQL_ADMIN_PASSWORD   (save this!)"
Write-Host "VM admin user          : $VM_ADMIN_USER"
Write-Host "VM admin password      : $VM_ADMIN_PASSWORD    (save this!)"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm the Lab 0 spoke resource groups still exist:
   - `rg-spoke-swc`
   - `rg-spoke-noe`
2. In each spoke VNet, confirm these subnets exist:
   - `snet-workload`
   - `snet-private-endpoints`
3. Choose or write down these names for this lab run:
   - Primary SQL server: `sql-pe-swc-<suffix>`
   - Secondary SQL server: `sql-pe-noe-<suffix>`
   - Private endpoints: `pep-sql-swc-<suffix>`, `pep-sql-noe-<suffix>`
   - Failover Group: `fg-multiregion-sql-<suffix>`
   - Validation VMs: `vm-sqltest-swc-<suffix>`, `vm-sqltest-noe-<suffix>`
4. Choose and save a strong SQL admin password and VM admin password.

  </div>
</div>

---

## Step 2 — Create Resource Groups and the Private DNS Zone

Keep the SQL servers, private endpoints, and validation VMs inside two dedicated
lab resource groups so cleanup stays simple and does not remove the Lab 0 network
foundation.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name "$RG_PRIMARY" --location "$PRIMARY_REGION" --output table
az group create --name "$RG_SECONDARY" --location "$SECONDARY_REGION" --output table

az network private-dns zone create \
  --resource-group "$RG_PRIMARY" \
  --name "$DNS_ZONE_NAME" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $PRIMARY_REGION --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table

az network private-dns zone create `
  --resource-group $RG_PRIMARY `
  --name $DNS_ZONE_NAME `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create `rg-sql-private-swc` in **Sweden Central**.
2. Create `rg-sql-private-noe` in **Norway East**.
3. Open **Private DNS zones** and create `privatelink.database.windows.net` in `rg-sql-private-swc`.

  </div>
</div>

---

## Step 3 — Link the DNS Zone to Both Spoke VNets and Capture Subnet IDs

Link the shared zone to both Lab 0 spokes, then capture the subnet IDs you will
reuse for the validation VMs and SQL private endpoints.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_VNET_ID=$(az network vnet show \
  --resource-group "$SPOKE_RG_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query id --output tsv)

SECONDARY_VNET_ID=$(az network vnet show \
  --resource-group "$SPOKE_RG_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query id --output tsv)

az network private-dns link vnet create \
  --resource-group "$RG_PRIMARY" \
  --zone-name "$DNS_ZONE_NAME" \
  --name "link-vnet-spoke-swc-sql" \
  --virtual-network "$PRIMARY_VNET_ID" \
  --registration-enabled false \
  --output table

az network private-dns link vnet create \
  --resource-group "$RG_PRIMARY" \
  --zone-name "$DNS_ZONE_NAME" \
  --name "link-vnet-spoke-noe-sql" \
  --virtual-network "$SECONDARY_VNET_ID" \
  --registration-enabled false \
  --output table

WORKLOAD_SUBNET_PRIMARY_ID=$(az network vnet subnet show \
  --resource-group "$SPOKE_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$WORKLOAD_SUBNET_NAME" \
  --query id --output tsv)

WORKLOAD_SUBNET_SECONDARY_ID=$(az network vnet subnet show \
  --resource-group "$SPOKE_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$WORKLOAD_SUBNET_NAME" \
  --query id --output tsv)

PE_SUBNET_PRIMARY_ID=$(az network vnet subnet show \
  --resource-group "$SPOKE_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$PRIVATE_ENDPOINT_SUBNET_NAME" \
  --query id --output tsv)

PE_SUBNET_SECONDARY_ID=$(az network vnet subnet show \
  --resource-group "$SPOKE_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$PRIVATE_ENDPOINT_SUBNET_NAME" \
  --query id --output tsv)

echo "Primary workload subnet : $WORKLOAD_SUBNET_PRIMARY_ID"
echo "Secondary workload subnet: $WORKLOAD_SUBNET_SECONDARY_ID"
echo "Primary PE subnet       : $PE_SUBNET_PRIMARY_ID"
echo "Secondary PE subnet     : $PE_SUBNET_SECONDARY_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_VNET_ID = az network vnet show `
  --resource-group $SPOKE_RG_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query id --output tsv

$SECONDARY_VNET_ID = az network vnet show `
  --resource-group $SPOKE_RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query id --output tsv

az network private-dns link vnet create `
  --resource-group $RG_PRIMARY `
  --zone-name $DNS_ZONE_NAME `
  --name "link-vnet-spoke-swc-sql" `
  --virtual-network $PRIMARY_VNET_ID `
  --registration-enabled false `
  --output table

az network private-dns link vnet create `
  --resource-group $RG_PRIMARY `
  --zone-name $DNS_ZONE_NAME `
  --name "link-vnet-spoke-noe-sql" `
  --virtual-network $SECONDARY_VNET_ID `
  --registration-enabled false `
  --output table

$WORKLOAD_SUBNET_PRIMARY_ID = az network vnet subnet show `
  --resource-group $SPOKE_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query id --output tsv

$WORKLOAD_SUBNET_SECONDARY_ID = az network vnet subnet show `
  --resource-group $SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query id --output tsv

$PE_SUBNET_PRIMARY_ID = az network vnet subnet show `
  --resource-group $SPOKE_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PRIVATE_ENDPOINT_SUBNET_NAME `
  --query id --output tsv

$PE_SUBNET_SECONDARY_ID = az network vnet subnet show `
  --resource-group $SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PRIVATE_ENDPOINT_SUBNET_NAME `
  --query id --output tsv

Write-Host "Primary workload subnet : $WORKLOAD_SUBNET_PRIMARY_ID"
Write-Host "Secondary workload subnet: $WORKLOAD_SUBNET_SECONDARY_ID"
Write-Host "Primary PE subnet       : $PE_SUBNET_PRIMARY_ID"
Write-Host "Secondary PE subnet     : $PE_SUBNET_SECONDARY_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the `privatelink.database.windows.net` DNS zone.
2. Add a VNet link for `vnet-spoke-swc` from `rg-spoke-swc` with auto registration disabled.
3. Add a second VNet link for `vnet-spoke-noe` from `rg-spoke-noe` with auto registration disabled.
4. Save both links.
5. Keep the workload and private endpoint subnet names handy for the next steps.

  </div>
</div>

---

## Step 4 — Create No-Public-IP Validation VMs in Both Spokes

Because the SQL servers are private, create one small Ubuntu VM in each spoke
workload subnet. You will use **Run Command** (or Bastion if you prefer) to
install `sqlcmd` and validate connectivity.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az vm create \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --image Ubuntu2204 \
  --admin-username "$VM_ADMIN_USER" \
  --admin-password "$VM_ADMIN_PASSWORD" \
  --authentication-type password \
  --subnet "$WORKLOAD_SUBNET_PRIMARY_ID" \
  --public-ip-address "" \
  --nic-delete-option Delete \
  --os-disk-delete-option Delete \
  --output table

az vm create \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --location "$SECONDARY_REGION" \
  --image Ubuntu2204 \
  --admin-username "$VM_ADMIN_USER" \
  --admin-password "$VM_ADMIN_PASSWORD" \
  --authentication-type password \
  --subnet "$WORKLOAD_SUBNET_SECONDARY_ID" \
  --public-ip-address "" \
  --nic-delete-option Delete \
  --os-disk-delete-option Delete \
  --output table

BOOTSTRAP_SCRIPT=$(cat <<'EOS'
set -e
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y ca-certificates curl gpg dnsutils
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list >/dev/null
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools18 unixodbc-dev
sudo ln -sf /opt/mssql-tools18/bin/sqlcmd /usr/local/bin/sqlcmd
command -v sqlcmd
EOS
)

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "$BOOTSTRAP_SCRIPT" \
  --query "value[0].message" \
  --output tsv

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$BOOTSTRAP_SCRIPT" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az vm create `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --location $PRIMARY_REGION `
  --image Ubuntu2204 `
  --admin-username $VM_ADMIN_USER `
  --admin-password $VM_ADMIN_PASSWORD `
  --authentication-type password `
  --subnet $WORKLOAD_SUBNET_PRIMARY_ID `
  --public-ip-address "" `
  --nic-delete-option Delete `
  --os-disk-delete-option Delete `
  --output table

az vm create `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --location $SECONDARY_REGION `
  --image Ubuntu2204 `
  --admin-username $VM_ADMIN_USER `
  --admin-password $VM_ADMIN_PASSWORD `
  --authentication-type password `
  --subnet $WORKLOAD_SUBNET_SECONDARY_ID `
  --public-ip-address "" `
  --nic-delete-option Delete `
  --os-disk-delete-option Delete `
  --output table

$BootstrapScript = @"
set -e
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y ca-certificates curl gpg dnsutils
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list >/dev/null
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools18 unixodbc-dev
sudo ln -sf /opt/mssql-tools18/bin/sqlcmd /usr/local/bin/sqlcmd
command -v sqlcmd
"@

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $BootstrapScript `
  --query "value[0].message" `
  --output tsv

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $BootstrapScript `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create an Ubuntu VM in `rg-sql-private-swc` named `vm-sqltest-swc-<suffix>`.
2. Place it in the existing Sweden spoke workload subnet and do **not** assign a public IP.
3. Repeat the same pattern in `rg-sql-private-noe` with `vm-sqltest-noe-<suffix>`.
4. After both VMs are deployed, open each VM and use **Run command** → **RunShellScript** to install `sqlcmd`, or reach them through Bastion if you prefer an interactive shell.

  </div>
</div>

<div class="lab-note">
<strong>Operational note:</strong> If the first <code>Run Command</code> attempt says the VM agent is not ready yet, wait a minute and rerun it. New VMs sometimes need a short warm-up before command execution is available.
</div>

---

## Step 5 — Create the Primary SQL Server

Create the Sweden Central logical SQL server first. Keep public network access
enabled temporarily so you can finish the private-endpoint setup before locking
the server down.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql server create \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --admin-user "$SQL_ADMIN_USER" \
  --admin-password "$SQL_ADMIN_PASSWORD" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql server create `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --admin-user $SQL_ADMIN_USER `
  --admin-password $SQL_ADMIN_PASSWORD `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **SQL servers** and select **Create**.
2. Use:
   - Server name: `sql-pe-swc-<suffix>`
   - Resource group: `rg-sql-private-swc`
   - Location: **Sweden Central**
   - Authentication method: **Use SQL authentication**
   - Server admin login: `sqladmin`
   - Password: the value you saved in Step 1
3. Leave public network access enabled for now.
4. Review and create the server.

  </div>
</div>

---

## Step 6 — Create the Primary Private Endpoint

Create the Sweden private endpoint inside the Lab 0
`vnet-spoke-swc/snet-private-endpoints` subnet and attach it to the shared
private DNS zone.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_SERVER_ID=$(az sql server show \
  --resource-group "$RG_PRIMARY" \
  --name "$PRIMARY_SERVER" \
  --query id --output tsv)

DNS_ZONE_ID=$(az network private-dns zone show \
  --resource-group "$RG_PRIMARY" \
  --name "$DNS_ZONE_NAME" \
  --query id --output tsv)

az network private-endpoint create \
  --resource-group "$RG_PRIMARY" \
  --name "$PRIMARY_ENDPOINT" \
  --location "$PRIMARY_REGION" \
  --subnet "$PE_SUBNET_PRIMARY_ID" \
  --private-connection-resource-id "$PRIMARY_SERVER_ID" \
  --group-id sqlServer \
  --connection-name "${PRIMARY_ENDPOINT}-conn" \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group "$RG_PRIMARY" \
  --endpoint-name "$PRIMARY_ENDPOINT" \
  --name default \
  --private-dns-zone "$DNS_ZONE_ID" \
  --zone-name "$DNS_ZONE_NAME" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_SERVER_ID = az sql server show `
  --resource-group $RG_PRIMARY `
  --name $PRIMARY_SERVER `
  --query id --output tsv

$DNS_ZONE_ID = az network private-dns zone show `
  --resource-group $RG_PRIMARY `
  --name $DNS_ZONE_NAME `
  --query id --output tsv

az network private-endpoint create `
  --resource-group $RG_PRIMARY `
  --name $PRIMARY_ENDPOINT `
  --location $PRIMARY_REGION `
  --subnet $PE_SUBNET_PRIMARY_ID `
  --private-connection-resource-id $PRIMARY_SERVER_ID `
  --group-id sqlServer `
  --connection-name "$PRIMARY_ENDPOINT-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $RG_PRIMARY `
  --endpoint-name $PRIMARY_ENDPOINT `
  --name default `
  --private-dns-zone $DNS_ZONE_ID `
  --zone-name $DNS_ZONE_NAME `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary SQL server.
2. Go to **Networking** → **Private access** → **Create a private endpoint**.
3. Use:
   - Name: `pep-sql-swc-<suffix>`
   - Virtual network: `vnet-spoke-swc`
   - Subnet: `snet-private-endpoints`
   - Private DNS integration: use the existing `privatelink.database.windows.net` zone
4. Create the endpoint and wait for the connection state to become **Approved**.

  </div>
</div>

---

## Step 7 — Create the Secondary SQL Server and Private Endpoint

Create the Norway East SQL server with the same SQL admin credentials, then
create its matching private endpoint in the Norway spoke.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql server create \
  --name "$SECONDARY_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --location "$SECONDARY_REGION" \
  --admin-user "$SQL_ADMIN_USER" \
  --admin-password "$SQL_ADMIN_PASSWORD" \
  --output table

SECONDARY_SERVER_ID=$(az sql server show \
  --resource-group "$RG_SECONDARY" \
  --name "$SECONDARY_SERVER" \
  --query id --output tsv)

az network private-endpoint create \
  --resource-group "$RG_SECONDARY" \
  --name "$SECONDARY_ENDPOINT" \
  --location "$SECONDARY_REGION" \
  --subnet "$PE_SUBNET_SECONDARY_ID" \
  --private-connection-resource-id "$SECONDARY_SERVER_ID" \
  --group-id sqlServer \
  --connection-name "${SECONDARY_ENDPOINT}-conn" \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group "$RG_SECONDARY" \
  --endpoint-name "$SECONDARY_ENDPOINT" \
  --name default \
  --private-dns-zone "$DNS_ZONE_ID" \
  --zone-name "$DNS_ZONE_NAME" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql server create `
  --name $SECONDARY_SERVER `
  --resource-group $RG_SECONDARY `
  --location $SECONDARY_REGION `
  --admin-user $SQL_ADMIN_USER `
  --admin-password $SQL_ADMIN_PASSWORD `
  --output table

$SECONDARY_SERVER_ID = az sql server show `
  --resource-group $RG_SECONDARY `
  --name $SECONDARY_SERVER `
  --query id --output tsv

az network private-endpoint create `
  --resource-group $RG_SECONDARY `
  --name $SECONDARY_ENDPOINT `
  --location $SECONDARY_REGION `
  --subnet $PE_SUBNET_SECONDARY_ID `
  --private-connection-resource-id $SECONDARY_SERVER_ID `
  --group-id sqlServer `
  --connection-name "$SECONDARY_ENDPOINT-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $RG_SECONDARY `
  --endpoint-name $SECONDARY_ENDPOINT `
  --name default `
  --private-dns-zone $DNS_ZONE_ID `
  --zone-name $DNS_ZONE_NAME `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create the secondary SQL server in `rg-sql-private-noe` using the same `sqladmin` login and password.
2. On that secondary server, go to **Networking** → **Private access** → **Create a private endpoint**.
3. Use:
   - Name: `pep-sql-noe-<suffix>`
   - Virtual network: `vnet-spoke-noe`
   - Subnet: `snet-private-endpoints`
   - Private DNS integration: the existing `privatelink.database.windows.net` zone
4. Wait for the private endpoint connection to show **Approved**.

  </div>
</div>

---

## Step 8 — Verify Server-Level Private Connectivity and Disable Public Access

First prove that the Sweden VM can reach the Sweden SQL server and the Norway VM
can reach the Norway SQL server through the private DNS path. Then disable public
network access on both servers.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_CONNECTIVITY_SCRIPT=$(cat <<EOF
set -e
nslookup ${PRIMARY_SERVER}.database.windows.net
sqlcmd -S tcp:${PRIMARY_SERVER}.database.windows.net,1433 \
  -d master \
  -U ${SQL_ADMIN_USER} \
  -P '${SQL_ADMIN_PASSWORD}' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, client_net_address AS ClientNetAddress FROM sys.dm_exec_connections WHERE session_id = @@SPID;"
EOF
)

SECONDARY_CONNECTIVITY_SCRIPT=$(cat <<EOF
set -e
nslookup ${SECONDARY_SERVER}.database.windows.net
sqlcmd -S tcp:${SECONDARY_SERVER}.database.windows.net,1433 \
  -d master \
  -U ${SQL_ADMIN_USER} \
  -P '${SQL_ADMIN_PASSWORD}' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, client_net_address AS ClientNetAddress FROM sys.dm_exec_connections WHERE session_id = @@SPID;"
EOF
)

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "$PRIMARY_CONNECTIVITY_SCRIPT" \
  --query "value[0].message" \
  --output tsv

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$SECONDARY_CONNECTIVITY_SCRIPT" \
  --query "value[0].message" \
  --output tsv

az sql server update \
  --resource-group "$RG_PRIMARY" \
  --name "$PRIMARY_SERVER" \
  --enable-public-network false \
  --output table

az sql server update \
  --resource-group "$RG_SECONDARY" \
  --name "$SECONDARY_SERVER" \
  --enable-public-network false \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PrimaryConnectivityScript = @"
set -e
nslookup $PRIMARY_SERVER.database.windows.net
sqlcmd -S tcp:$PRIMARY_SERVER.database.windows.net,1433 \
  -d master \
  -U $SQL_ADMIN_USER \
  -P '$SQL_ADMIN_PASSWORD' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, client_net_address AS ClientNetAddress FROM sys.dm_exec_connections WHERE session_id = @@SPID;"
"@

$SecondaryConnectivityScript = @"
set -e
nslookup $SECONDARY_SERVER.database.windows.net
sqlcmd -S tcp:$SECONDARY_SERVER.database.windows.net,1433 \
  -d master \
  -U $SQL_ADMIN_USER \
  -P '$SQL_ADMIN_PASSWORD' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, client_net_address AS ClientNetAddress FROM sys.dm_exec_connections WHERE session_id = @@SPID;"
"@

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $PrimaryConnectivityScript `
  --query "value[0].message" `
  --output tsv

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $SecondaryConnectivityScript `
  --query "value[0].message" `
  --output tsv

az sql server update `
  --resource-group $RG_PRIMARY `
  --name $PRIMARY_SERVER `
  --enable-public-network false `
  --output table

az sql server update `
  --resource-group $RG_SECONDARY `
  --name $SECONDARY_SERVER `
  --enable-public-network false `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. On the **Sweden** validation VM, use **Run command** → **RunShellScript**.
2. Run:
   - `nslookup <primary-server>.database.windows.net`
   - `sqlcmd -S tcp:<primary-server>.database.windows.net,1433 -d master -U sqladmin -P '<password>' -Q "SELECT @@SERVERNAME AS CurrentServer, client_net_address AS ClientNetAddress FROM sys.dm_exec_connections WHERE session_id = @@SPID;"`
3. Repeat the same test on the **Norway** validation VM against the secondary server.
4. After both tests succeed, open each SQL server and disable **Public network access**.

  </div>
</div>

<div class="lab-note">
<strong>After this step:</strong> Cloud Shell and Query Editor are no longer valid data-plane tests for this lab because the SQL servers no longer accept public connections.
</div>

---

## Step 9 — Create a Sample Database and Table from the Primary Validation VM

Keep the management-plane database creation step, but run the SQL from the Sweden
validation VM so you exercise the private network path.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql db create \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --service-objective S0 \
  --output table

PRIMARY_DATA_SCRIPT=$(cat <<EOF
set -e
cat >/home/${VM_ADMIN_USER}/lab2b-setup.sql <<'SQL'
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO
CREATE TABLE dbo.Products (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
INSERT INTO dbo.Products (ProductName, Price) VALUES
    (N'Widget A',  9.99),
    (N'Widget B', 19.99),
    (N'Widget C', 29.99),
    (N'Widget D', 39.99),
    (N'Widget E', 49.99);
GO
SELECT * FROM dbo.Products;
SQL

sqlcmd -S tcp:${PRIMARY_SERVER}.database.windows.net,1433 \
  -d ${DB_NAME} \
  -U ${SQL_ADMIN_USER} \
  -P '${SQL_ADMIN_PASSWORD}' \
  -i /home/${VM_ADMIN_USER}/lab2b-setup.sql
EOF
)

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "$PRIMARY_DATA_SCRIPT" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql db create `
  --name $DB_NAME `
  --server $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --service-objective S0 `
  --output table

$PrimaryDataScript = @"
set -e
cat >/home/$VM_ADMIN_USER/lab2b-setup.sql <<'SQL'
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO
CREATE TABLE dbo.Products (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
INSERT INTO dbo.Products (ProductName, Price) VALUES
    (N'Widget A',  9.99),
    (N'Widget B', 19.99),
    (N'Widget C', 29.99),
    (N'Widget D', 39.99),
    (N'Widget E', 49.99);
GO
SELECT * FROM dbo.Products;
SQL

sqlcmd -S tcp:$PRIMARY_SERVER.database.windows.net,1433 \
  -d $DB_NAME \
  -U $SQL_ADMIN_USER \
  -P '$SQL_ADMIN_PASSWORD' \
  -i /home/$VM_ADMIN_USER/lab2b-setup.sql
"@

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $PrimaryDataScript `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a database named `sqldb-sample` on the primary SQL server.
2. Open the **Sweden** validation VM.
3. Use **Run command** → **RunShellScript**.
4. Create the sample `Products` table and insert the five rows from the shared SQL shown in the Bash tab.

  </div>
</div>

---

## Step 10 — Set Up Active Geo-Replication

Create a readable geo-replica of the sample database on the Norway East server.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql db replica create \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --partner-server "$SECONDARY_SERVER" \
  --partner-resource-group "$RG_SECONDARY" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql db replica create `
  --name $DB_NAME `
  --server $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --partner-server $SECONDARY_SERVER `
  --partner-resource-group $RG_SECONDARY `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary database.
2. Go to **Geo-Replication**.
3. Select the Norway East server as the target.
4. Create the replica and wait for seeding to begin.

  </div>
</div>

---

## Step 11 — Verify the Replication Link

Confirm the replica link is established and progressing to `CATCH_UP`.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql db replica list-links \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --query "[].{Partner:partnerServer, Location:partnerLocation, Role:role, PartnerRole:partnerRole, State:replicationState}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql db replica list-links `
  --name $DB_NAME `
  --server $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query "[].{Partner:partnerServer, Location:partnerLocation, Role:role, PartnerRole:partnerRole, State:replicationState}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary database.
2. Go to **Geo-Replication**.
3. Confirm the Norway East replica is present and moving toward **CATCH_UP**.

  </div>
</div>

---

## Step 12 — Create the Failover Group and Show Listener Endpoints

Create the Failover Group, then note the read-write and read-only listener FQDNs.
These are the same names your application would keep during and after failover.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group create \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --partner-server "$SECONDARY_SERVER" \
  --partner-resource-group "$RG_SECONDARY" \
  --add-db "$DB_NAME" \
  --failover-policy Automatic \
  --grace-period 60 \
  --output table

az sql failover-group show \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --query "{Name:name, Role:replicationRole, FailoverPolicy:readWriteEndpoint.failoverPolicy}" \
  --output table

echo "Read-write listener: ${FG_NAME}.database.windows.net"
echo "Read-only listener : ${FG_NAME}.secondary.database.windows.net"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql failover-group create `
  --name $FG_NAME `
  --server $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --partner-server $SECONDARY_SERVER `
  --partner-resource-group $RG_SECONDARY `
  --add-db $DB_NAME `
  --failover-policy Automatic `
  --grace-period 60 `
  --output table

az sql failover-group show `
  --name $FG_NAME `
  --server $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query "{Name:name, Role:replicationRole, FailoverPolicy:readWriteEndpoint.failoverPolicy}" `
  --output table

Write-Host "Read-write listener: $FG_NAME.database.windows.net"
Write-Host "Read-only listener : $FG_NAME.secondary.database.windows.net"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary SQL server.
2. Go to **Failover groups** and select **Add group**.
3. Use your Failover Group name from Step 1.
4. Choose the Norway East server and add `sqldb-sample`.
5. Create the Failover Group.
6. Note the **Read-write listener** and **Read-only listener** values on the overview page.

  </div>
</div>

<div class="lab-note">
<strong>Validation matrix:</strong> before failover, use the Sweden VM for the <code>read-write</code> listener and the Norway VM for the <code>.secondary</code> listener. After failover, use the Norway VM for the read-write listener because Norway becomes primary.
</div>

---

## Step 13 — Validate the Read-Write Listener from the Sweden VM

Before failover, the **read-write** listener should resolve to the Sweden primary.
Validate it from the Sweden spoke VM.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_RW_SCRIPT=$(cat <<EOF
set -e
nslookup ${FG_NAME}.database.windows.net
sqlcmd -S tcp:${FG_NAME}.database.windows.net,1433 \
  -d ${DB_NAME} \
  -U ${SQL_ADMIN_USER} \
  -P '${SQL_ADMIN_PASSWORD}' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount, (SELECT client_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) AS ClientNetAddress;"
EOF
)

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "$PRIMARY_RW_SCRIPT" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PrimaryRwScript = @"
set -e
nslookup $FG_NAME.database.windows.net
sqlcmd -S tcp:$FG_NAME.database.windows.net,1433 \
  -d $DB_NAME \
  -U $SQL_ADMIN_USER \
  -P '$SQL_ADMIN_PASSWORD' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount, (SELECT client_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) AS ClientNetAddress;"
"@

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $PrimaryRwScript `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **Sweden** validation VM.
2. Use **Run command** → **RunShellScript**.
3. Run `nslookup <fg-name>.database.windows.net`.
4. Run the `sqlcmd` query from this step against the read-write listener.
5. Confirm the current server is the Sweden SQL server and `ProductCount` is `5`.

  </div>
</div>

---

## Step 14 — Validate the Read-Only Listener from the Norway VM

The **read-only** listener should resolve to the Norway secondary. Validate it
from the Norway spoke VM.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SECONDARY_RO_SCRIPT=$(cat <<EOF
set -e
nslookup ${FG_NAME}.secondary.database.windows.net
sqlcmd -S tcp:${FG_NAME}.secondary.database.windows.net,1433 \
  -d ${DB_NAME} \
  -U ${SQL_ADMIN_USER} \
  -P '${SQL_ADMIN_PASSWORD}' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount, (SELECT client_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) AS ClientNetAddress;"
EOF
)

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$SECONDARY_RO_SCRIPT" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SecondaryRoScript = @"
set -e
nslookup $FG_NAME.secondary.database.windows.net
sqlcmd -S tcp:$FG_NAME.secondary.database.windows.net,1433 \
  -d $DB_NAME \
  -U $SQL_ADMIN_USER \
  -P '$SQL_ADMIN_PASSWORD' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount, (SELECT client_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) AS ClientNetAddress;"
"@

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $SecondaryRoScript `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **Norway** validation VM.
2. Use **Run command** → **RunShellScript**.
3. Run `nslookup <fg-name>.secondary.database.windows.net`.
4. Run the `sqlcmd` query from this step against the read-only listener.
5. Confirm the current server is the Norway SQL server and `ProductCount` is `5`.

  </div>
</div>

<div class="lab-note">
<strong>Congratulations:</strong> both listener endpoints are now working privately from the correct regional spokes, and the sample data is replicated across both regions.
</div>

---

## Step 15 — Initiate Manual Failover

Simulate a regional failover by promoting the Norway East server to primary.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group set-primary \
  --name "$FG_NAME" \
  --server "$SECONDARY_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql failover-group set-primary `
  --name $FG_NAME `
  --server $SECONDARY_SERVER `
  --resource-group $RG_SECONDARY `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Failover Group.
2. Choose the action to switch the primary to the Norway East server.
3. Use planned failover and wait for the role change to complete.

  </div>
</div>

---

## Step 16 — Validate the Read-Write Listener from the Norway VM

After failover, the **read-write** listener should resolve to the Norway primary.
Validate it from the Norway spoke VM.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group show \
  --name "$FG_NAME" \
  --server "$SECONDARY_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --query "{Name:name, ReplicationRole:replicationRole, PartnerRole:partnerServers[0].replicationRole}" \
  --output table

POST_FAILOVER_RW_SCRIPT=$(cat <<EOF
set -e
nslookup ${FG_NAME}.database.windows.net
sqlcmd -S tcp:${FG_NAME}.database.windows.net,1433 \
  -d ${DB_NAME} \
  -U ${SQL_ADMIN_USER} \
  -P '${SQL_ADMIN_PASSWORD}' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount, (SELECT client_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) AS ClientNetAddress;"
EOF
)

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$POST_FAILOVER_RW_SCRIPT" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql failover-group show `
  --name $FG_NAME `
  --server $SECONDARY_SERVER `
  --resource-group $RG_SECONDARY `
  --query "{Name:name, ReplicationRole:replicationRole, PartnerRole:partnerServers[0].replicationRole}" `
  --output table

$PostFailoverRwScript = @"
set -e
nslookup $FG_NAME.database.windows.net
sqlcmd -S tcp:$FG_NAME.database.windows.net,1433 \
  -d $DB_NAME \
  -U $SQL_ADMIN_USER \
  -P '$SQL_ADMIN_PASSWORD' \
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount, (SELECT client_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) AS ClientNetAddress;"
"@

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $PostFailoverRwScript `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm the Failover Group now shows the Norway East server as **Primary**.
2. Open the **Norway** validation VM.
3. Use **Run command** → **RunShellScript**.
4. Run the `nslookup` and `sqlcmd` checks from this step against the read-write listener.
5. Confirm the current server is now the Norway SQL server.

  </div>
</div>

---

## Step 17 — Cleanup

Delete only the lab-specific resource groups. That removes the SQL servers,
database, failover group, private endpoints, private DNS zone, and validation
VMs created in this lab while leaving the Lab 0 foundation intact.

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

echo "Cleanup initiated for lab resource groups only. Keep the Lab 0 rg-hub-* and rg-spoke-* groups if you want to reuse them."
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

Write-Host "Cleanup initiated for lab resource groups only. Keep the Lab 0 rg-hub-* and rg-spoke-* groups if you want to reuse them."
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete `rg-sql-private-swc`.
2. Delete `rg-sql-private-noe`.
3. Leave the Lab 0 resource groups (`rg-hub-*` and `rg-spoke-*`) in place unless you are done with the secured variants.

  </div>
</div>

---

## Discussion & Next Steps

### Secure Failover Strategy

This lab keeps the same database failover story as Lab 2-a, but it proves that
your clients can follow the Failover Group listener **without reopening the SQL
data plane to the public internet**.

### Why Regional Validation Matters

Because Lab 0 intentionally avoids cross-region spoke peering, this private SQL
pattern is validated from **two regional clients** instead of one. That is often
closer to a real multi-region application design, where each region hosts its
own application or jump host.

### Design Extension Ideas

- Add an application tier in each spoke and point both regions at the same Failover Group listener.
- Extend Lab 0 with DNS forwarders or custom resolvers if you need hybrid name resolution.
- Add Azure Monitor alerts for replica health, failover events, and private endpoint state changes.

### Cost Considerations

- The two temporary VMs are convenient for realistic private validation, but you should delete them as soon as the drill is complete.
- Private endpoints and the private DNS zone have modest ongoing cost, but the SQL servers and database are the primary billable components in this lab.

---

## Useful Links

- [Azure SQL private endpoint overview](https://learn.microsoft.com/azure/azure-sql/database/private-endpoint-overview)
- [Active Geo-Replication overview](https://learn.microsoft.com/azure/azure-sql/database/active-geo-replication-overview)
- [Failover Groups overview](https://learn.microsoft.com/azure/azure-sql/database/failover-group-sql-db)
- [Configure a Failover Group for Azure SQL Database](https://learn.microsoft.com/azure/azure-sql/database/failover-group-configure-sql-db)
- [Azure Private Endpoint DNS integration guidance](https://learn.microsoft.com/azure/private-link/private-endpoint-dns-integration)

---

[Lab 2-a: Azure SQL Database – Geo-Replication & Failover](./lab-02a-sql-geo-replication.md) | **Lab 2-b: Azure SQL Database – Private Geo-Replication & Failover**
