---
layout: default
title: "Lab 4-b: Azure Database for MySQL – Private Cross-Region Read Replica"
---

[← Lab 4-a: Public-access variant](lab-04a-mysql-geo-replication.md)

# Lab 4-b: Azure Database for MySQL – Private Cross-Region Read Replica

> **Variant note:** This secure path assumes you already completed Lab 0 and are reusing its regional spoke VNets, workload subnets, and hub controls.

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

Lab 4-b is the secure companion to Lab 4-a. It assumes you already completed **Lab 0** and are reusing its fixed hub-and-spoke landing zone in **Sweden Central** and **Norway East**.

The resiliency story stays the same: a MySQL Flexible Server source in Sweden Central replicates asynchronously to a cross-region read replica in Norway East, and you promote the replica during a failover drill. What changes in this variant is the **network path** — the data plane stays private by using **virtual network integration**, **dedicated delegated subnets**, and **service-specific private DNS zones**.

| Feature | Detail |
|---|---|
| **Deployment model** | Azure Database for MySQL Flexible Server |
| **Replication pattern** | Cross-region asynchronous read replica |
| **Primary / DR regions** | Sweden Central → Norway East |
| **Private connectivity model** | Private access (virtual network integration) |
| **Client validation path** | No-public-IP Linux VMs in each spoke workload subnet |
| **Failover model** | Manual promotion of the read replica |

> **Design note:** Azure Database for MySQL Flexible Server also supports **Private Link / private endpoints** when the server is created in **public access** mode. For this secure `B` variant, we intentionally choose **private access** instead because it keeps both MySQL servers off the public internet from the start and aligns better with the Lab 0 spoke landing zones.

### What Changes Compared to Lab 4-a?

| Area | Lab 4-a | Lab 4-b |
|---|---|---|
| **Network exposure** | Public endpoint + firewall rules | Private access only |
| **Lab 0 dependency** | Not required | Required |
| **Subnets used** | No VNet integration | Dedicated delegated MySQL subnet in each spoke |
| **Private DNS** | Not required for the main flow | Required |
| **Validation client** | Local MySQL client or Cloud Shell | Regional validation VMs with no public IP |

### Why This Secure Variant Matters

* **No public data plane** — neither the source nor the replica needs public inbound access.
* **Regional isolation** — each spoke can host and validate its local database endpoint without flattening the two regional stamps together.
* **Reusable landing zone alignment** — the lab consumes the exact spoke VNets and workload subnets created in Lab 0.
* **Operational realism** — your application or operational jump host must resolve private FQDNs and connect from inside the trusted network boundary.

---

## Architecture

```text
┌──────────────────────────── Sweden Central (Primary) ─────────────────────────────┐
│ rg-hub-swc / vnet-hub-swc                                                         │
│   • afw-hub-swc   • bas-hub-swc   (inherited from Lab 0, not changed here)       │
│                                                                                    │
│ rg-spoke-swc / vnet-spoke-swc                                                     │
│   ├─ snet-workload               10.10.4.0/24                                     │
│   │   └─ vm-mysql-test-swc-xxxxx (no public IP, validation client)               │
│   ├─ snet-private-endpoints      10.10.5.64/26  (reserved from Lab 0; unused)    │
│   └─ snet-mysql-flex             10.10.6.0/28  delegated to flexibleServers      │
│       └─ mysql-prv-swc-xxxxx     (private access source server)                  │
│                                                                                    │
│   Private DNS zone: mysql-swc.private.mysql.database.azure.com                    │
└────────────────────────────────────────────────────────────────────────────────────┘

                         Async MySQL binlog replication

┌────────────────────────────── Norway East (DR) ───────────────────────────────────┐
│ rg-hub-noe / vnet-hub-noe                                                         │
│   • afw-hub-noe   • bas-hub-noe   (inherited from Lab 0, not changed here)       │
│                                                                                    │
│ rg-spoke-noe / vnet-spoke-noe                                                     │
│   ├─ snet-workload               10.20.4.0/24                                     │
│   │   └─ vm-mysql-test-noe-xxxxx (no public IP, validation client)               │
│   ├─ snet-private-endpoints      10.20.5.64/26  (reserved from Lab 0; unused)    │
│   └─ snet-mysql-flex             10.20.6.0/28  delegated to flexibleServers      │
│       └─ mysql-prv-noe-xxxxx     (private access read replica)                   │
│                                                                                    │
│   Private DNS zone: mysql-noe.private.mysql.database.azure.com                    │
└────────────────────────────────────────────────────────────────────────────────────┘
```

**Traffic pattern for this lab:**

1. The Sweden Central validation VM connects privately to the **source** server.
2. The Norway East validation VM connects privately to the **replica** server.
3. Replication happens asynchronously between the servers.
4. During the failover drill, you promote the Norway East replica and then write to it from the Norway East validation VM.

<div class="lab-note">
<strong>Important:</strong> Lab 0 intentionally does <em>not</em> create cross-region spoke-to-spoke peering. This lab respects that design. Instead of forcing one client VM to reach both regions, you validate each regional database endpoint from a VM inside the matching regional spoke.
</div>

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Completed Lab 0** | You must already have `rg-spoke-swc`, `rg-spoke-noe`, `vnet-spoke-swc`, `vnet-spoke-noe`, and `snet-workload` in both regions |
| **Azure CLI** | Version 2.75 or later recommended |
| **Azure subscription** | Needs permission to create MySQL Flexible Servers, private DNS zones, subnet delegations, NSGs, and Linux VMs |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash |
| **PowerShell 7+** | Recommended if you want to follow the PowerShell tabs |
| **Budget awareness** | Two MySQL Flexible Servers plus two small validation VMs incur cost while running |
| **Operational note** | The lab uses `az vm run-command invoke`, so you do not need a local `mysql` client |

<div class="lab-note">
<strong>Subnet planning note:</strong> Lab 0 deliberately left room in each spoke for later service-specific subnets. This lab consumes <code>10.10.6.0/28</code> and <code>10.20.6.0/28</code> for a dedicated MySQL delegated subnet called <code>snet-mysql-flex</code>.
</div>

---

## How These Tabs Work

This page uses a shared tab preference:

- If you click **Bash** in one step, the rest of the page switches to **Bash**
- The selection is remembered for the page in your browser
- Every code block gets a copy button in the top-right corner

---

## Step 1 — Validate the Lab 0 Foundation and Set Variables

This lab reuses the fixed spoke resource groups and VNets from Lab 0. Start by confirming they exist, then define the MySQL-specific names you will use in the secure variant.

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

RG_PRIMARY="rg-spoke-swc"
RG_SECONDARY="rg-spoke-noe"

SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_SECONDARY="vnet-spoke-noe"

WORKLOAD_SUBNET_NAME="snet-workload"
MYSQL_SUBNET_NAME="snet-mysql-flex"
MYSQL_PRIMARY_CIDR="10.10.6.0/28"
MYSQL_SECONDARY_CIDR="10.20.6.0/28"

PRIMARY_DNS_ZONE="mysql-swc.private.mysql.database.azure.com"
SECONDARY_DNS_ZONE="mysql-noe.private.mysql.database.azure.com"

PRIMARY_SERVER="mysql-prv-swc-${RANDOM_SUFFIX}"
REPLICA_SERVER="mysql-prv-noe-${RANDOM_SUFFIX}"

VM_PRIMARY="vm-mysql-test-swc-${RANDOM_SUFFIX}"
VM_SECONDARY="vm-mysql-test-noe-${RANDOM_SUFFIX}"
NSG_PRIMARY="nsg-mysql-test-swc-${RANDOM_SUFFIX}"
NSG_SECONDARY="nsg-mysql-test-noe-${RANDOM_SUFFIX}"

ADMIN_USER="mysqladmin"
ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"
DB_NAME="sampledb"

az network vnet show \
  --resource-group "$RG_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query '{VNet:name, Location:location}' \
  --output table

az network vnet show \
  --resource-group "$RG_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query '{VNet:name, Location:location}' \
  --output table

az network vnet subnet show \
  --resource-group "$RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$WORKLOAD_SUBNET_NAME" \
  --query '{Subnet:name, Prefix:addressPrefix}' \
  --output table

az network vnet subnet show \
  --resource-group "$RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$WORKLOAD_SUBNET_NAME" \
  --query '{Subnet:name, Prefix:addressPrefix}' \
  --output table

echo "Primary private server : $PRIMARY_SERVER"
echo "Replica private server : $REPLICA_SERVER"
echo "Primary validator VM  : $VM_PRIMARY"
echo "Replica validator VM  : $VM_SECONDARY"
echo "Admin user            : $ADMIN_USER"
echo "Admin password        : $ADMIN_PASSWORD  (save this)"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$RG_PRIMARY = "rg-spoke-swc"
$RG_SECONDARY = "rg-spoke-noe"

$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"

$WORKLOAD_SUBNET_NAME = "snet-workload"
$MYSQL_SUBNET_NAME = "snet-mysql-flex"
$MYSQL_PRIMARY_CIDR = "10.10.6.0/28"
$MYSQL_SECONDARY_CIDR = "10.20.6.0/28"

$PRIMARY_DNS_ZONE = "mysql-swc.private.mysql.database.azure.com"
$SECONDARY_DNS_ZONE = "mysql-noe.private.mysql.database.azure.com"

$PRIMARY_SERVER = "mysql-prv-swc-$RANDOM_SUFFIX"
$REPLICA_SERVER = "mysql-prv-noe-$RANDOM_SUFFIX"

$VM_PRIMARY = "vm-mysql-test-swc-$RANDOM_SUFFIX"
$VM_SECONDARY = "vm-mysql-test-noe-$RANDOM_SUFFIX"
$NSG_PRIMARY = "nsg-mysql-test-swc-$RANDOM_SUFFIX"
$NSG_SECONDARY = "nsg-mysql-test-noe-$RANDOM_SUFFIX"

$ADMIN_USER = "mysqladmin"
$ADMIN_PASSWORD = "P@ssw0rd-$([guid]::NewGuid().ToString('N').Substring(0,8))"
$DB_NAME = "sampledb"

az network vnet show `
  --resource-group $RG_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query '{VNet:name, Location:location}' `
  --output table

az network vnet show `
  --resource-group $RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query '{VNet:name, Location:location}' `
  --output table

az network vnet subnet show `
  --resource-group $RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query '{Subnet:name, Prefix:addressPrefix}' `
  --output table

az network vnet subnet show `
  --resource-group $RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query '{Subnet:name, Prefix:addressPrefix}' `
  --output table

Write-Host "Primary private server : $PRIMARY_SERVER"
Write-Host "Replica private server : $REPLICA_SERVER"
Write-Host "Primary validator VM  : $VM_PRIMARY"
Write-Host "Replica validator VM  : $VM_SECONDARY"
Write-Host "Admin user            : $ADMIN_USER"
Write-Host "Admin password        : $ADMIN_PASSWORD  (save this)"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm you already completed Lab 0 and can see these resources:
   - `rg-spoke-swc` with `vnet-spoke-swc`
   - `rg-spoke-noe` with `vnet-spoke-noe`
   - `snet-workload` in both spoke VNets
2. Choose a short unique suffix that you will reuse for the private MySQL servers and validation VMs.
3. Write down these values before you create anything:
   - Primary server: `mysql-prv-swc-<suffix>`
   - Replica server: `mysql-prv-noe-<suffix>`
   - Validation VMs: `vm-mysql-test-swc-<suffix>`, `vm-mysql-test-noe-<suffix>`
   - Dedicated MySQL subnet name: `snet-mysql-flex`
   - Private DNS zones: `mysql-swc.private.mysql.database.azure.com`, `mysql-noe.private.mysql.database.azure.com`
4. Store or generate an admin password that you can reuse later from the validation VMs.

      </div>
    </div>

<div class="lab-note">
<strong>Safety reminder:</strong> Lab 4-b reuses the Lab 0 spoke resource groups. Do <em>not</em> plan to delete `rg-spoke-swc` or `rg-spoke-noe` during cleanup — those groups contain your shared landing zone resources.
</div>

---

## Step 2 — Create Dedicated Delegated MySQL Subnets in Both Spokes

MySQL Flexible Server private access needs its own delegated subnet. Do not delegate `snet-workload`, and do not reuse `snet-private-endpoints` for this deployment model.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet subnet create \
  --resource-group "$RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$MYSQL_SUBNET_NAME" \
  --address-prefixes "$MYSQL_PRIMARY_CIDR" \
  --delegations Microsoft.DBforMySQL/flexibleServers \
  --output table

az network vnet subnet create \
  --resource-group "$RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$MYSQL_SUBNET_NAME" \
  --address-prefixes "$MYSQL_SECONDARY_CIDR" \
  --delegations Microsoft.DBforMySQL/flexibleServers \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet subnet create `
  --resource-group $RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $MYSQL_SUBNET_NAME `
  --address-prefixes $MYSQL_PRIMARY_CIDR `
  --delegations Microsoft.DBforMySQL/flexibleServers `
  --output table

az network vnet subnet create `
  --resource-group $RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $MYSQL_SUBNET_NAME `
  --address-prefixes $MYSQL_SECONDARY_CIDR `
  --delegations Microsoft.DBforMySQL/flexibleServers `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `vnet-spoke-swc`.
2. Add a new subnet named `snet-mysql-flex` with address prefix `10.10.6.0/28`.
3. Set **Subnet delegation** to **Microsoft.DBforMySQL/flexibleServers**.
4. Repeat the same pattern in `vnet-spoke-noe` using `10.20.6.0/28`.
5. Leave `snet-workload` and `snet-private-endpoints` untouched.

      </div>
    </div>

<div class="lab-note">
<strong>Why not use <code>snet-private-endpoints</code>?</strong> That subnet from Lab 0 is reserved for services that use Private Link. This MySQL variant uses <strong>private access (VNet integration)</strong>, which requires a <strong>delegated subnet</strong> instead.
</div>

---

## Step 3 — Create the MySQL Private DNS Zones

Lab 0 intentionally deferred service-specific private DNS. Create one MySQL private DNS zone per region so each regional server gets a clear, predictable private namespace.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-dns zone create \
  --resource-group "$RG_PRIMARY" \
  --name "$PRIMARY_DNS_ZONE" \
  --output table

az network private-dns zone create \
  --resource-group "$RG_SECONDARY" \
  --name "$SECONDARY_DNS_ZONE" \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-dns zone create `
  --resource-group $RG_PRIMARY `
  --name $PRIMARY_DNS_ZONE `
  --output table

az network private-dns zone create `
  --resource-group $RG_SECONDARY `
  --name $SECONDARY_DNS_ZONE `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-spoke-swc`, create a **Private DNS zone** named `mysql-swc.private.mysql.database.azure.com`.
2. In `rg-spoke-noe`, create a **Private DNS zone** named `mysql-noe.private.mysql.database.azure.com`.
3. You do not need to create record sets manually for the lab flow. The server creation workflow will populate the required records.

      </div>
    </div>

<div class="lab-note">
<strong>DNS note:</strong> When you create the MySQL server and pass the private DNS zone name, Azure links the zone to the matching VNet if needed and then manages the necessary record set for the server's private FQDN.
</div>

---
## Step 4 — Create the Source MySQL Flexible Server with Private Access

Deploy the Sweden Central source server into the delegated subnet you created in the primary spoke.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az mysql flexible-server create \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --admin-user "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  --sku-name Standard_D2ads_v5 \
  --tier GeneralPurpose \
  --storage-size 32 \
  --version 8.0.21 \
  --vnet "$SPOKE_VNET_PRIMARY" \
  --subnet "$MYSQL_SUBNET_NAME" \
  --private-dns-zone "$PRIMARY_DNS_ZONE" \
  --output table

PRIMARY_FQDN=$(az mysql flexible-server show \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --query fullyQualifiedDomainName \
  --output tsv)

az mysql flexible-server show \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --query '{Name:name, State:state, Location:location, FQDN:fullyQualifiedDomainName}' \
  --output table

echo "Primary private FQDN: $PRIMARY_FQDN"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server create `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --admin-user $ADMIN_USER `
  --admin-password $ADMIN_PASSWORD `
  --sku-name Standard_D2ads_v5 `
  --tier GeneralPurpose `
  --storage-size 32 `
  --version 8.0.21 `
  --vnet $SPOKE_VNET_PRIMARY `
  --subnet $MYSQL_SUBNET_NAME `
  --private-dns-zone $PRIMARY_DNS_ZONE `
  --output table

$PRIMARY_FQDN = az mysql flexible-server show `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query fullyQualifiedDomainName `
  --output tsv

az mysql flexible-server show `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '{Name:name, State:state, Location:location, FQDN:fullyQualifiedDomainName}' `
  --output table

Write-Host "Primary private FQDN: $PRIMARY_FQDN"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a new **Azure Database for MySQL flexible server** in `rg-spoke-swc`.
2. Choose **Sweden Central** as the region.
3. On **Networking**, select **Private access**.
4. Choose existing VNet `vnet-spoke-swc`, subnet `snet-mysql-flex`, and private DNS zone `mysql-swc.private.mysql.database.azure.com`.
5. Use the same compute profile as Lab 4-a if you want to preserve behavior (`General Purpose`, `Standard_D2ads_v5`, 32 GiB storage).
6. After deployment, open **Overview** and copy the server's private FQDN.

      </div>
    </div>

---

## Step 5 — Create No-Public-IP Validation VMs in Both Spokes

Because the database servers are private, create one small Linux VM in each spoke workload subnet. You will use **Run Command** (or Bastion if you prefer) to install the MySQL client and validate connectivity.

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
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --subnet "$WORKLOAD_SUBNET_NAME" \
  --nsg "$NSG_PRIMARY" \
  --public-ip-address "" \
  --nic-delete-option Delete \
  --os-disk-delete-option Delete \
  --output table

az vm create \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --location "$SECONDARY_REGION" \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --subnet "$WORKLOAD_SUBNET_NAME" \
  --nsg "$NSG_SECONDARY" \
  --public-ip-address "" \
  --nic-delete-option Delete \
  --os-disk-delete-option Delete \
  --output table

BOOTSTRAP_SCRIPT=$(cat <<'EOS'
set -e
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y default-mysql-client
mysql --version
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
  --admin-username azureuser `
  --generate-ssh-keys `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --subnet $WORKLOAD_SUBNET_NAME `
  --nsg $NSG_PRIMARY `
  --public-ip-address "" `
  --nic-delete-option Delete `
  --os-disk-delete-option Delete `
  --output table

az vm create `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --location $SECONDARY_REGION `
  --image Ubuntu2204 `
  --admin-username azureuser `
  --generate-ssh-keys `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --subnet $WORKLOAD_SUBNET_NAME `
  --nsg $NSG_SECONDARY `
  --public-ip-address "" `
  --nic-delete-option Delete `
  --os-disk-delete-option Delete `
  --output table

$BootstrapScript = @"
set -e
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y default-mysql-client
mysql --version
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

1. Create an Ubuntu VM in `rg-spoke-swc` named `vm-mysql-test-swc-<suffix>`.
2. Place it in `vnet-spoke-swc` and subnet `snet-workload`.
3. Do **not** assign a public IP.
4. Repeat the same pattern in `rg-spoke-noe` with `vm-mysql-test-noe-<suffix>`.
5. After both VMs are deployed, open each VM and use **Run command** → **RunShellScript** to install `default-mysql-client`, or reach them via Bastion if you prefer an interactive shell.

      </div>
    </div>

<div class="lab-note">
<strong>Operational note:</strong> If the first <code>Run Command</code> attempt says the VM agent is not ready yet, wait a minute and rerun it. New VMs sometimes need a short warm-up before command execution is available.
</div>

---

## Step 6 — Create a Sample Database and Table from the Primary Validation VM

Keep the management-plane database creation step, but run the SQL from the Sweden Central validation VM so you exercise the private network path.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az mysql flexible-server db create \
  --server-name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --database-name "$DB_NAME" \
  --output table

PRIMARY_DATA_SCRIPT=$(cat <<EOS
set -e
mysql -h "$PRIMARY_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
TRUNCATE TABLE products;
INSERT INTO products (name, price) VALUES
    ('Widget A', 9.99),
    ('Widget B', 19.99),
    ('Widget C', 29.99),
    ('Widget D', 39.99),
    ('Widget E', 49.99);
SELECT * FROM products;
"
EOS
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
az mysql flexible-server db create `
  --server-name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --database-name $DB_NAME `
  --output table

$PrimaryDataScript = @"
set -e
mysql -h "$PRIMARY_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
TRUNCATE TABLE products;
INSERT INTO products (name, price) VALUES
    ('Widget A', 9.99),
    ('Widget B', 19.99),
    ('Widget C', 29.99),
    ('Widget D', 39.99),
    ('Widget E', 49.99);
SELECT * FROM products;
"
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

1. Open the primary MySQL server and create `sampledb` if it is not already present.
2. Open the primary validation VM (`vm-mysql-test-swc-<suffix>`) and use **Run command** → **RunShellScript**.
3. Paste the SQL workflow from the Bash or PowerShell tab so the commands run from inside the primary spoke.
4. Confirm that the `products` table exists and returns five rows.

      </div>
    </div>

<div class="lab-note">
<strong>Rerun tip:</strong> The script uses <code>TRUNCATE TABLE products;</code> so you can repeat the step without accumulating duplicate sample rows.
</div>

---

## Step 7 — Create a Cross-Region Private Read Replica

Create the Norway East replica in the DR spoke, using the delegated subnet and the DR private DNS zone.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SOURCE_ID=$(az mysql flexible-server show \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --query id \
  --output tsv)

az mysql flexible-server replica create \
  --replica-name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --source-server "$SOURCE_ID" \
  --location "$SECONDARY_REGION" \
  --vnet "$SPOKE_VNET_SECONDARY" \
  --subnet "$MYSQL_SUBNET_NAME" \
  --private-dns-zone "$SECONDARY_DNS_ZONE" \
  --sku-name Standard_D2ads_v5 \
  --tier GeneralPurpose \
  --storage-size 32 \
  --output table

REPLICA_FQDN=$(az mysql flexible-server show \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --query fullyQualifiedDomainName \
  --output tsv)

echo "Replica private FQDN: $REPLICA_FQDN"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SOURCE_ID = az mysql flexible-server show `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query id `
  --output tsv

az mysql flexible-server replica create `
  --replica-name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --source-server $SOURCE_ID `
  --location $SECONDARY_REGION `
  --vnet $SPOKE_VNET_SECONDARY `
  --subnet $MYSQL_SUBNET_NAME `
  --private-dns-zone $SECONDARY_DNS_ZONE `
  --sku-name Standard_D2ads_v5 `
  --tier GeneralPurpose `
  --storage-size 32 `
  --output table

$REPLICA_FQDN = az mysql flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query fullyQualifiedDomainName `
  --output tsv

Write-Host "Replica private FQDN: $REPLICA_FQDN"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary MySQL server in Sweden Central.
2. Go to **Replication** / **Read replicas** and choose **Add replica**.
3. Set the replica name to `mysql-prv-noe-<suffix>` and the region to **Norway East**.
4. On the networking choices, use `vnet-spoke-noe`, `snet-mysql-flex`, and the private DNS zone `mysql-noe.private.mysql.database.azure.com`.
5. Submit the create operation and wait for the seeding process to finish.

      </div>
    </div>

> **Note:** This is still a cross-region seed + asynchronous replication workflow. Expect the initial replica creation to take several minutes.

---
## Step 8 — Verify the Replica, Private FQDN, and Read-Only State

Confirm that the replica exists in Norway East, resolves privately, and rejects writes before promotion.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az mysql flexible-server show \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --query '{Name:name, State:state, Location:location, ReplicationRole:replicationRole, FQDN:fullyQualifiedDomainName}' \
  --output table

az mysql flexible-server replica list \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --query '[].{Name:name, Location:location, State:state, Role:replicationRole}' \
  --output table

REPLICA_CHECK_SCRIPT=$(cat <<EOS
set -e
getent hosts "$REPLICA_FQDN"
mysql -h "$REPLICA_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "SELECT COUNT(*) AS seed_rows FROM products;"
if mysql -h "$REPLICA_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "INSERT INTO products (name, price) VALUES ('Should Fail', 0.01);"; then
  echo "Unexpected: replica accepted writes."
  exit 1
else
  echo "Replica rejected write operations as expected."
fi
EOS
)

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$REPLICA_CHECK_SCRIPT" \
  --query "value[0].message" \
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, State:state, Location:location, ReplicationRole:replicationRole, FQDN:fullyQualifiedDomainName}' `
  --output table

az mysql flexible-server replica list `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '[].{Name:name, Location:location, State:state, Role:replicationRole}' `
  --output table

$ReplicaCheckScript = @"
set -e
getent hosts "$REPLICA_FQDN"
mysql -h "$REPLICA_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "SELECT COUNT(*) AS seed_rows FROM products;"
if mysql -h "$REPLICA_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "INSERT INTO products (name, price) VALUES ('Should Fail', 0.01);"; then
  echo "Unexpected: replica accepted writes."
  exit 1
else
  echo "Replica rejected write operations as expected."
fi
"@

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $ReplicaCheckScript `
  --query "value[0].message" `
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the replica server in **Norway East** and confirm it is healthy.
2. On **Overview**, copy the private FQDN.
3. On the Norway East validation VM, use **Run command** → **RunShellScript** (or Bastion) to:
   - resolve the replica FQDN
   - run `SELECT COUNT(*) FROM products;`
   - attempt a test write that should fail while replication is still active
4. Confirm the row count is `5` and the write attempt is rejected.

      </div>
    </div>

Expected behavior: the replica resolves to a **private IP**, returns the seeded rows, and remains **read-only** until you promote it.

---

## Step 9 — Verify Ongoing Replication and Monitor Lag

Insert a new row on the primary after the replica exists, then confirm the new row shows up in Norway East.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
POST_REPLICA_INSERT_SCRIPT=$(cat <<EOS
set -e
mysql -h "$PRIMARY_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "
INSERT INTO products (name, price) VALUES ('Post-Replica Widget', 59.99);
SELECT COUNT(*) AS source_count FROM products;
"
EOS
)

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "$POST_REPLICA_INSERT_SCRIPT" \
  --query "value[0].message" \
  --output tsv

sleep 30

REPLICA_QUERY_SCRIPT=$(cat <<EOS
set -e
mysql -h "$REPLICA_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "
SELECT COUNT(*) AS replica_count FROM products;
SELECT id, name, price FROM products ORDER BY id DESC LIMIT 2;
"
EOS
)

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$REPLICA_QUERY_SCRIPT" \
  --query "value[0].message" \
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PostReplicaInsertScript = @"
set -e
mysql -h "$PRIMARY_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "
INSERT INTO products (name, price) VALUES ('Post-Replica Widget', 59.99);
SELECT COUNT(*) AS source_count FROM products;
"
"@

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $PostReplicaInsertScript `
  --query "value[0].message" `
  --output tsv

Start-Sleep -Seconds 30

$ReplicaQueryScript = @"
set -e
mysql -h "$REPLICA_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "
SELECT COUNT(*) AS replica_count FROM products;
SELECT id, name, price FROM products ORDER BY id DESC LIMIT 2;
"
"@

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $ReplicaQueryScript `
  --query "value[0].message" `
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. From the Sweden Central validation VM, insert a new row into `sampledb.products`.
2. Wait about 30 seconds.
3. From the Norway East validation VM, query the table again and confirm the new row appears.
4. In the portal, open the replica server and chart **Monitoring** → **Metrics** → **Replication Lag In Seconds**.

      </div>
    </div>

<div class="lab-note">
<strong>Asynchronous replication note:</strong> If the new row has not arrived yet, wait another 15–30 seconds and rerun the replica query. Cross-region replication is not synchronous.
</div>

---

## Step 10 — Promote the Replica (Simulate Failover)

Promoting the Norway East replica breaks the replication relationship and converts the server into a standalone read-write database. This is **irreversible**.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az mysql flexible-server replica stop-replication \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --yes \
  --output table

az mysql flexible-server show \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --query '{Name:name, State:state, ReplicationRole:replicationRole, FQDN:fullyQualifiedDomainName}' \
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server replica stop-replication `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --yes `
  --output table

az mysql flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, State:state, ReplicationRole:replicationRole, FQDN:fullyQualifiedDomainName}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Norway East replica.
2. Go to **Replication**.
3. Choose **Stop replication** / **Promote**.
4. Confirm the warning dialog.
5. After the operation completes, verify the server is now standalone and writable.

      </div>
    </div>

Expected: `ReplicationRole` becomes `None` and the Norway East server is now an independent primary candidate.

---

## Step 11 — Validate Write Access on the Promoted Server

After promotion, the former replica should accept writes. This is also the point where an application would cut over to the Norway East FQDN.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PROMOTED_WRITE_SCRIPT=$(cat <<EOS
set -e
mysql -h "$REPLICA_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "
INSERT INTO products (name, price) VALUES ('Failover Widget', 69.99);
SELECT id, name, price FROM products ORDER BY id DESC LIMIT 3;
"
EOS
)

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$PROMOTED_WRITE_SCRIPT" \
  --query "value[0].message" \
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PromotedWriteScript = @"
set -e
mysql -h "$REPLICA_FQDN" -u "$ADMIN_USER" --password="$ADMIN_PASSWORD" --ssl-mode=REQUIRED "$DB_NAME" -e "
INSERT INTO products (name, price) VALUES ('Failover Widget', 69.99);
SELECT id, name, price FROM products ORDER BY id DESC LIMIT 3;
"
"@

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $PromotedWriteScript `
  --query "value[0].message" `
  --output tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Stay on the promoted Norway East server.
2. From the Norway East validation VM, run an `INSERT` against `sampledb.products`.
3. Query the table again and confirm the new row appears.
4. Treat the Norway East private FQDN as the new application target after failover.

      </div>
    </div>

---

## Step 12 — Cleanup

> ⚠️ **Do not delete the spoke resource groups.** They belong to the shared Lab 0 landing zone.

Delete only the service-specific resources that this lab created.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az mysql flexible-server delete --name "$REPLICA_SERVER" --resource-group "$RG_SECONDARY" --yes
az mysql flexible-server delete --name "$PRIMARY_SERVER" --resource-group "$RG_PRIMARY" --yes

az vm delete --name "$VM_PRIMARY" --resource-group "$RG_PRIMARY" --yes
az vm delete --name "$VM_SECONDARY" --resource-group "$RG_SECONDARY" --yes

az network nsg delete --name "$NSG_PRIMARY" --resource-group "$RG_PRIMARY"
az network nsg delete --name "$NSG_SECONDARY" --resource-group "$RG_SECONDARY"

az network private-dns zone delete --name "$PRIMARY_DNS_ZONE" --resource-group "$RG_PRIMARY" --yes
az network private-dns zone delete --name "$SECONDARY_DNS_ZONE" --resource-group "$RG_SECONDARY" --yes

az network vnet subnet delete --name "$MYSQL_SUBNET_NAME" --resource-group "$RG_PRIMARY" --vnet-name "$SPOKE_VNET_PRIMARY"
az network vnet subnet delete --name "$MYSQL_SUBNET_NAME" --resource-group "$RG_SECONDARY" --vnet-name "$SPOKE_VNET_SECONDARY"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server delete --name $REPLICA_SERVER --resource-group $RG_SECONDARY --yes
az mysql flexible-server delete --name $PRIMARY_SERVER --resource-group $RG_PRIMARY --yes

az vm delete --name $VM_PRIMARY --resource-group $RG_PRIMARY --yes
az vm delete --name $VM_SECONDARY --resource-group $RG_SECONDARY --yes

az network nsg delete --name $NSG_PRIMARY --resource-group $RG_PRIMARY
az network nsg delete --name $NSG_SECONDARY --resource-group $RG_SECONDARY

az network private-dns zone delete --name $PRIMARY_DNS_ZONE --resource-group $RG_PRIMARY --yes
az network private-dns zone delete --name $SECONDARY_DNS_ZONE --resource-group $RG_SECONDARY --yes

az network vnet subnet delete --name $MYSQL_SUBNET_NAME --resource-group $RG_PRIMARY --vnet-name $SPOKE_VNET_PRIMARY
az network vnet subnet delete --name $MYSQL_SUBNET_NAME --resource-group $RG_SECONDARY --vnet-name $SPOKE_VNET_SECONDARY
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete only the two MySQL flexible servers that this lab created.
2. Delete only the two validation VMs and their lab-specific NSGs.
3. Delete the two MySQL private DNS zones if you no longer need them.
4. Delete the `snet-mysql-flex` subnet from each spoke VNet only after the MySQL servers are gone.
5. Keep `rg-spoke-swc`, `rg-spoke-noe`, `vnet-spoke-swc`, `vnet-spoke-noe`, and the rest of the Lab 0 landing zone intact.

      </div>
    </div>

<div class="lab-note">
<strong>Cleanup timing note:</strong> If subnet deletion fails because Azure is still tearing down NICs or delegated resources, wait a minute and rerun just the subnet delete commands.
</div>

---

## Discussion & Next Steps

### Secure Failover Strategy

A private MySQL failover drill still needs an application cutover plan:

1. **Detect the regional issue** — use Azure Monitor health and replication metrics.
2. **Promote the replica** — stop replication and make the DR server writable.
3. **Update private connection settings** — point the application at the promoted Norway East FQDN.
4. **Rebuild DR protection** — create a new cross-region replica from the promoted server after the incident.

### Why This Lab Chose Private Access Instead of Private Endpoints

This `B` variant uses **private access (VNet integration)** because it is the cleanest way to keep the entire data plane private while reusing the Lab 0 spoke landing zones. If you specifically need **Private Link / private endpoints** for MySQL Flexible Server, that is a different connectivity model that starts from a **public access** server and then adds private endpoints.

### Lab 4-a vs Lab 4-b Summary

| Variant | Best fit |
|---|---|
| **Lab 4-a** | Fastest way to learn MySQL cross-region read replicas and promotion using public connectivity |
| **Lab 4-b** | Secure hub-and-spoke environments where workloads and operators connect privately from inside the landing zone |

---

## Useful Links

* 📖 [Read replicas in Azure Database for MySQL – Flexible Server](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-read-replicas)
* 📖 [Private access using virtual network integration](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-networking-vnet)
* 📖 [Create and manage virtual networks for MySQL Flexible Server with Azure CLI](https://learn.microsoft.com/azure/mysql/flexible-server/how-to-manage-virtual-network-cli)
* 📖 [Private Link for Azure Database for MySQL – Flexible Server](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-networking-private-link)
* 📖 [Azure Private DNS overview](https://learn.microsoft.com/azure/dns/private-dns-overview)

---

[← Lab 4-a: Public-access variant](lab-04a-mysql-geo-replication.md) | [Lab 4-b](lab-04b-mysql-private-geo-replication.md)
