---
layout: default
title: "Lab 10-b: Azure Event Hubs – Private Networking"
---

[Lab 10-a: Azure Event Hubs – Geo-Replication Failover](lab-10a-event-hubs-geo-replication.md) | **Lab 10-b: Azure Event Hubs – Private Networking**

# Lab 10-b: Azure Event Hubs – Private Networking

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

> **Objective:** Keep the same Event Hubs Geo-DR alias workflow as the public `A` variant, but move namespace and alias access onto private endpoints in the Lab 0 spoke VNets.

<div class="lab-note">
<strong>Lab 0 dependency:</strong> This <code>B</code> variant assumes <code>rg-hub-swc</code>, <code>rg-hub-noe</code>, <code>rg-spoke-swc</code>, <code>rg-spoke-noe</code>, <code>vnet-spoke-swc</code>, <code>vnet-spoke-noe</code>, <code>snet-workload</code>, and <code>snet-private-endpoints</code> already exist from Lab 0.
</div>

## Introduction

The public `A` variant proves the **Geo-Disaster Recovery** control-plane story with public endpoints. This secured `B` variant keeps the same core workflow — primary and secondary namespaces, a stable alias, metadata replication, and manual failover — but shifts the data path into the private network foundation from Lab 0.

That changes the runbook in three important ways:

1. **Each namespace needs its own private endpoint.** Geo-DR does not replicate private endpoint connections, private DNS links, or public-access settings.
2. **Private DNS becomes part of failover.** The namespace records are created automatically by the DNS zone groups, but this lab adds an explicit alias record so the active private endpoint stays predictable during drills.
3. **Validation happens from inside the spokes.** Lab 0 intentionally keeps each region as a separate stamp with no cross-region spoke peering, so you validate the active private alias from the VM in the currently active region.

| This lab adds | Why it matters |
|---|---|
| Two namespace private endpoints in `snet-private-endpoints` | Keeps Event Hubs traffic private in both regions |
| A dedicated private DNS zone `privatelink.servicebus.windows.net` | Makes namespace resolution private without changing the public FQDN pattern used by clients |
| A lab-managed alias `A` record | Gives the Geo-DR alias a private target during failover drills |
| One validation VM per region in `snet-workload` | Lets you prove namespace and alias access from inside each regional spoke |

> **Design consequence:** Geo-DR still replicates Event Hubs metadata only. Treat private endpoints, DNS links, alias-DNS updates, and regional validation as part of your disaster-recovery runbook.

---

## Architecture

```text
                           Shared DNS for this lab
                privatelink.servicebus.windows.net (RG_SHARED)
        +--------------------------------------------------------------+
        | eh-prv-swc-xxxxx     -> 10.10.5.x                            |
        | eh-prv-noe-xxxxx     -> 10.20.5.x                            |
        | eh-alias-prv-xxxxx   -> current primary private endpoint IP  |
        +-----------------------------+--------------------------------+
                                      |
                   normal operation    |   failover updates alias record
                                      |
┌──────────────────── Sweden Central (active first) ────────────────────────────┐
│ rg-hub-swc → bas-hub-swc                                                     │
│ rg-spoke-swc → vnet-spoke-swc                                                │
│   ├─ snet-workload           → vm-ehcli-swc-xxxxx                            │
│   └─ snet-private-endpoints  → pep-eh-swc-xxxxx → eh-prv-swc-xxxxx          │
│                                                                            ▲ │
│                                                                            │ │
│                     Geo-DR alias resolves privately here before failover   │ │
└──────────────────────────────────────────────────────────────────────────────┘ │
                                                                                 │
┌────────────────────── Norway East (active after failover) ─────────────────────┘
│ rg-hub-noe → bas-hub-noe                                                      │
│ rg-spoke-noe → vnet-spoke-noe                                                 │
│   ├─ snet-workload           → vm-ehcli-noe-xxxxx                             │
│   └─ snet-private-endpoints  → pep-eh-noe-xxxxx → eh-prv-noe-xxxxx           │
│                                                                              │
│                     Geo-DR alias resolves privately here after failover      │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Normal operation:** validate direct namespace access from both spokes, and validate alias-based publishing from the Sweden Central VM.

**After failover:** update the alias `A` record to the Norway East private endpoint IP, then validate the same alias from the Norway East VM.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Lab 0 completed** | `vnet-spoke-swc`, `vnet-spoke-noe`, `snet-workload`, `snet-private-endpoints`, and the regional Bastions already exist |
| **Azure subscription** | Permission to create Event Hubs namespaces, private endpoints, private DNS zones, and Linux VMs |
| **Azure CLI ≥ 2.55** | Used for the control-plane steps in the shell tabs |
| **PowerShell 7+** *(optional)* | Needed only if you follow the PowerShell path |
| **Event Hubs Standard or Premium** | Geo-DR and Private Link are both supported on Standard and Premium |
| **Budget awareness** | Two namespaces, two private endpoints, and two small validation VMs are added on top of any Lab 0 costs |

> **Cost warning:** If Lab 0 is still running, Azure Firewall and Azure Bastion are already accruing hourly cost. This lab adds two Event Hubs namespaces plus two small validation VMs.

---

## How These Tabs Work

This page uses the same interaction pattern as the rest of the lab series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behaviour used in the existing labs.

> **Private access note:** After Step 10, portal and Cloud Shell remain useful for control-plane checks, but the Event Hubs data-plane validation must run from the spoke VMs.

---

## Step 1 — Sign In and Validate the Lab 0 Foundation

Confirm that the fixed network resources from Lab 0 are still present before you create any Event Hubs resources.

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

RG_HUB_PRIMARY="rg-hub-swc"
RG_HUB_SECONDARY="rg-hub-noe"
RG_SPOKE_PRIMARY="rg-spoke-swc"
RG_SPOKE_SECONDARY="rg-spoke-noe"

SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_SECONDARY="vnet-spoke-noe"

WORKLOAD_SUBNET_NAME="snet-workload"
PE_SUBNET_NAME="snet-private-endpoints"

az network vnet subnet show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$PE_SUBNET_NAME" \
  --query "{VNet:vnet.name,Subnet:name,Prefix:addressPrefix,PEPolicies:privateEndpointNetworkPolicies}" \
  --output table

az network vnet subnet show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$PE_SUBNET_NAME" \
  --query "{VNet:vnet.name,Subnet:name,Prefix:addressPrefix,PEPolicies:privateEndpointNetworkPolicies}" \
  --output table

az network bastion show \
  --resource-group "$RG_HUB_PRIMARY" \
  --name bas-hub-swc \
  --query "{Name:name,State:provisioningState}" \
  --output table

az network bastion show \
  --resource-group "$RG_HUB_SECONDARY" \
  --name bas-hub-noe \
  --query "{Name:name,State:provisioningState}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"

$RG_HUB_PRIMARY = "rg-hub-swc"
$RG_HUB_SECONDARY = "rg-hub-noe"
$RG_SPOKE_PRIMARY = "rg-spoke-swc"
$RG_SPOKE_SECONDARY = "rg-spoke-noe"

$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"

$WORKLOAD_SUBNET_NAME = "snet-workload"
$PE_SUBNET_NAME = "snet-private-endpoints"

az network vnet subnet show `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PE_SUBNET_NAME `
  --query "{VNet:vnet.name,Subnet:name,Prefix:addressPrefix,PEPolicies:privateEndpointNetworkPolicies}" `
  --output table

az network vnet subnet show `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PE_SUBNET_NAME `
  --query "{VNet:vnet.name,Subnet:name,Prefix:addressPrefix,PEPolicies:privateEndpointNetworkPolicies}" `
  --output table

az network bastion show `
  --resource-group $RG_HUB_PRIMARY `
  --name bas-hub-swc `
  --query "{Name:name,State:provisioningState}" `
  --output table

az network bastion show `
  --resource-group $RG_HUB_SECONDARY `
  --name bas-hub-noe `
  --query "{Name:name,State:provisioningState}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the [Azure portal](https://portal.azure.com) and confirm the correct subscription.
2. Open `rg-spoke-swc` and `rg-spoke-noe` and verify `vnet-spoke-swc` / `vnet-spoke-noe` still contain:
   - `snet-workload`
   - `snet-private-endpoints`
3. Confirm **Private endpoint network policies** are disabled on both `snet-private-endpoints` subnets.
4. Open `rg-hub-swc` and `rg-hub-noe` and verify `bas-hub-swc` and `bas-hub-noe` are still healthy.

  </div>
</div>

<div class="lab-note">
<strong>Stop here if Lab 0 is missing:</strong> This lab assumes the shared network landing zone already exists. If you prefer the public-endpoint-only workflow, return to the `A` variant instead.
</div>

---

## Step 2 — Set the Lab Variables and Capture the Existing Network IDs

Keep the Lab 0 network names fixed, but randomise the Event Hubs, private endpoint, DNS-link, and validation-VM names for this run.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RANDOM_SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | head -c 5)

LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

RG_PRIMARY="rg-eh-private-swc-$RANDOM_SUFFIX"
RG_SECONDARY="rg-eh-private-noe-$RANDOM_SUFFIX"
RG_SHARED="rg-eh-private-shared-$RANDOM_SUFFIX"

EH_PRIMARY="eh-prv-swc-$RANDOM_SUFFIX"
EH_SECONDARY="eh-prv-noe-$RANDOM_SUFFIX"
EH_ALIAS="eh-alias-prv-$RANDOM_SUFFIX"

EH_NAME="events-telemetry"
CG_NAME="analytics-cg"

VM_PRIMARY="vm-ehcli-swc-$RANDOM_SUFFIX"
VM_SECONDARY="vm-ehcli-noe-$RANDOM_SUFFIX"
VM_ADMIN="azureuser"

PE_PRIMARY="pep-eh-swc-$RANDOM_SUFFIX"
PE_SECONDARY="pep-eh-noe-$RANDOM_SUFFIX"
PE_CONNECTION_PRIMARY="psc-eh-swc-$RANDOM_SUFFIX"
PE_CONNECTION_SECONDARY="psc-eh-noe-$RANDOM_SUFFIX"

DNS_LINK_PRIMARY="link-eh-swc-$RANDOM_SUFFIX"
DNS_LINK_SECONDARY="link-eh-noe-$RANDOM_SUFFIX"
PRIVATE_DNS_ZONE="privatelink.servicebus.windows.net"

WORKLOAD_SUBNET_PRIMARY_ID=$(az network vnet subnet show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$WORKLOAD_SUBNET_NAME" \
  --query id --output tsv)

WORKLOAD_SUBNET_SECONDARY_ID=$(az network vnet subnet show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$WORKLOAD_SUBNET_NAME" \
  --query id --output tsv)

PE_SUBNET_PRIMARY_ID=$(az network vnet subnet show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$PE_SUBNET_NAME" \
  --query id --output tsv)

PE_SUBNET_SECONDARY_ID=$(az network vnet subnet show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$PE_SUBNET_NAME" \
  --query id --output tsv)

SPOKE_VNET_PRIMARY_ID=$(az network vnet show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query id --output tsv)

SPOKE_VNET_SECONDARY_ID=$(az network vnet show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query id --output tsv)

echo "Primary namespace : $EH_PRIMARY"
echo "Secondary namespace: $EH_SECONDARY"
echo "Geo-DR alias      : $EH_ALIAS"
echo "Primary VM        : $VM_PRIMARY"
echo "Secondary VM      : $VM_SECONDARY"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"

$RG_PRIMARY = "rg-eh-private-swc-$RANDOM_SUFFIX"
$RG_SECONDARY = "rg-eh-private-noe-$RANDOM_SUFFIX"
$RG_SHARED = "rg-eh-private-shared-$RANDOM_SUFFIX"

$EH_PRIMARY = "eh-prv-swc-$RANDOM_SUFFIX"
$EH_SECONDARY = "eh-prv-noe-$RANDOM_SUFFIX"
$EH_ALIAS = "eh-alias-prv-$RANDOM_SUFFIX"

$EH_NAME = "events-telemetry"
$CG_NAME = "analytics-cg"

$VM_PRIMARY = "vm-ehcli-swc-$RANDOM_SUFFIX"
$VM_SECONDARY = "vm-ehcli-noe-$RANDOM_SUFFIX"
$VM_ADMIN = "azureuser"

$PE_PRIMARY = "pep-eh-swc-$RANDOM_SUFFIX"
$PE_SECONDARY = "pep-eh-noe-$RANDOM_SUFFIX"
$PE_CONNECTION_PRIMARY = "psc-eh-swc-$RANDOM_SUFFIX"
$PE_CONNECTION_SECONDARY = "psc-eh-noe-$RANDOM_SUFFIX"

$DNS_LINK_PRIMARY = "link-eh-swc-$RANDOM_SUFFIX"
$DNS_LINK_SECONDARY = "link-eh-noe-$RANDOM_SUFFIX"
$PRIVATE_DNS_ZONE = "privatelink.servicebus.windows.net"

$WORKLOAD_SUBNET_PRIMARY_ID = az network vnet subnet show `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query id --output tsv

$WORKLOAD_SUBNET_SECONDARY_ID = az network vnet subnet show `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query id --output tsv

$PE_SUBNET_PRIMARY_ID = az network vnet subnet show `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PE_SUBNET_NAME `
  --query id --output tsv

$PE_SUBNET_SECONDARY_ID = az network vnet subnet show `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PE_SUBNET_NAME `
  --query id --output tsv

$SPOKE_VNET_PRIMARY_ID = az network vnet show `
  --resource-group $RG_SPOKE_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query id --output tsv

$SPOKE_VNET_SECONDARY_ID = az network vnet show `
  --resource-group $RG_SPOKE_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query id --output tsv

Write-Host "Primary namespace : $EH_PRIMARY"
Write-Host "Secondary namespace: $EH_SECONDARY"
Write-Host "Geo-DR alias      : $EH_ALIAS"
Write-Host "Primary VM        : $VM_PRIMARY"
Write-Host "Secondary VM      : $VM_SECONDARY"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down or pre-plan these values:

1. Three new resource groups:
   - `rg-eh-private-swc-<suffix>`
   - `rg-eh-private-noe-<suffix>`
   - `rg-eh-private-shared-<suffix>`
2. Two Event Hubs namespaces:
   - `eh-prv-swc-<suffix>`
   - `eh-prv-noe-<suffix>`
3. One Geo-DR alias: `eh-alias-prv-<suffix>`
4. One Event Hub: `events-telemetry`
5. One consumer group: `analytics-cg`
6. Two validation VMs:
   - `vm-ehcli-swc-<suffix>`
   - `vm-ehcli-noe-<suffix>`
7. Existing Lab 0 targets you will select repeatedly:
   - `vnet-spoke-swc` / `snet-workload`
   - `vnet-spoke-noe` / `snet-workload`
   - `vnet-spoke-swc` / `snet-private-endpoints`
   - `vnet-spoke-noe` / `snet-private-endpoints`

  </div>
</div>

---

## Step 3 — Create the Resource Groups and Event Hubs Namespaces

Keep the Event Hubs namespaces separate from the Lab 0 network resource groups so cleanup stays simple.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name "$RG_PRIMARY" --location "$LOCATION_PRIMARY" --output table
az group create --name "$RG_SECONDARY" --location "$LOCATION_SECONDARY" --output table
az group create --name "$RG_SHARED" --location "$LOCATION_PRIMARY" --output table

az eventhubs namespace create \
  --name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku Standard \
  --capacity 1 \
  --output table

az eventhubs namespace create \
  --name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --sku Standard \
  --capacity 1 \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $LOCATION_PRIMARY --output table
az group create --name $RG_SECONDARY --location $LOCATION_SECONDARY --output table
az group create --name $RG_SHARED --location $LOCATION_PRIMARY --output table

az eventhubs namespace create `
  --name $EH_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $LOCATION_PRIMARY `
  --sku Standard `
  --capacity 1 `
  --output table

az eventhubs namespace create `
  --name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --location $LOCATION_SECONDARY `
  --sku Standard `
  --capacity 1 `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create the two Event Hubs resource groups in **Sweden Central** and **Norway East**.
2. Create one extra shared resource group for the private DNS zone.
3. Create a **Standard** Event Hubs namespace in each region.
4. Keep both namespaces empty for the moment except for the lab entities you add next.

  </div>
</div>

<div class="lab-note">
<strong>Provisioning note:</strong> Standard tier is enough for this lab. That keeps the Geo-DR pattern lower-cost while still preserving the same primary / secondary / alias failover flow.
</div>

---

## Step 4 — Create the Event Hub, Consumer Group, and Geo-DR Alias

The `B` variant keeps the same Event Hubs storyline as the public version: define the metadata on the primary namespace, then pair the secondary through a stable alias.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs eventhub create \
  --name "$EH_NAME" \
  --namespace-name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --partition-count 2 \
  --cleanup-policy Delete \
  --retention-time-in-hours 24 \
  --output table

az eventhubs eventhub consumer-group create \
  --name "$CG_NAME" \
  --eventhub-name "$EH_NAME" \
  --namespace-name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --output table

SECONDARY_ID=$(az eventhubs namespace show \
  --name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query id \
  --output tsv)

az eventhubs georecovery-alias set \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$EH_PRIMARY" \
  --alias "$EH_ALIAS" \
  --partner-namespace "$SECONDARY_ID" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs eventhub create `
  --name $EH_NAME `
  --namespace-name $EH_PRIMARY `
  --resource-group $RG_PRIMARY `
  --partition-count 2 `
  --cleanup-policy Delete `
  --retention-time-in-hours 24 `
  --output table

az eventhubs eventhub consumer-group create `
  --name $CG_NAME `
  --eventhub-name $EH_NAME `
  --namespace-name $EH_PRIMARY `
  --resource-group $RG_PRIMARY `
  --output table

$SECONDARY_ID = az eventhubs namespace show `
  --name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --query id `
  --output tsv

az eventhubs georecovery-alias set `
  --resource-group $RG_PRIMARY `
  --namespace-name $EH_PRIMARY `
  --alias $EH_ALIAS `
  --partner-namespace $SECONDARY_ID `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the **primary** namespace, create Event Hub `events-telemetry` with **2 partitions** and **1 day** retention.
2. Add consumer group `analytics-cg`.
3. Open **Geo recovery** on the primary namespace.
4. Pair the Norway East namespace by using alias `eh-alias-prv-<suffix>`.

  </div>
</div>

---

## Step 5 — Wait for Pairing, Verify Metadata Replication, and Capture the Alias Connection String

Do not move on to networking until the Geo-DR alias reports a healthy state.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
while true; do
  STATE=$(az eventhubs georecovery-alias show \
    --resource-group "$RG_PRIMARY" \
    --namespace-name "$EH_PRIMARY" \
    --alias "$EH_ALIAS" \
    --query provisioningState \
    --output tsv)

  ROLE=$(az eventhubs georecovery-alias show \
    --resource-group "$RG_PRIMARY" \
    --namespace-name "$EH_PRIMARY" \
    --alias "$EH_ALIAS" \
    --query role \
    --output tsv)

  echo "State: $STATE | Role: $ROLE"
  [ "$STATE" = "Succeeded" ] && break
  sleep 10
done

az eventhubs eventhub list \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --output table

az eventhubs eventhub consumer-group list \
  --eventhub-name "$EH_NAME" \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --output table

EVENTHUB_ALIAS_CONNECTION_STRING=$(az eventhubs georecovery-alias authorization-rule keys list \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$EH_PRIMARY" \
  --alias "$EH_ALIAS" \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString \
  --output tsv)

echo "Alias FQDN: $EH_ALIAS.servicebus.windows.net"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
do {
    $STATE = az eventhubs georecovery-alias show `
      --resource-group $RG_PRIMARY `
      --namespace-name $EH_PRIMARY `
      --alias $EH_ALIAS `
      --query provisioningState `
      --output tsv

    $ROLE = az eventhubs georecovery-alias show `
      --resource-group $RG_PRIMARY `
      --namespace-name $EH_PRIMARY `
      --alias $EH_ALIAS `
      --query role `
      --output tsv

    Write-Host "State: $STATE | Role: $ROLE"
    if ($STATE -ne "Succeeded") { Start-Sleep -Seconds 10 }
} while ($STATE -ne "Succeeded")

az eventhubs eventhub list `
  --namespace-name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --output table

az eventhubs eventhub consumer-group list `
  --eventhub-name $EH_NAME `
  --namespace-name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --output table

$EVENTHUB_ALIAS_CONNECTION_STRING = az eventhubs georecovery-alias authorization-rule keys list `
  --resource-group $RG_PRIMARY `
  --namespace-name $EH_PRIMARY `
  --alias $EH_ALIAS `
  --name RootManageSharedAccessKey `
  --query primaryConnectionString `
  --output tsv

Write-Host "Alias FQDN: $EH_ALIAS.servicebus.windows.net"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. On the **Geo recovery** blade, refresh until the alias shows **Succeeded** and the Sweden Central namespace is **Primary**.
2. Open the Norway East namespace and confirm `events-telemetry` and `analytics-cg` are visible there.
3. Treat the application endpoint as `eh-alias-prv-<suffix>.servicebus.windows.net`.
4. If you need the exact alias connection string, use **Cloud Shell** or the shell tabs.

  </div>
</div>

<div class="lab-note">
<strong>Application guidance:</strong> Use the alias connection string rather than a regional namespace connection string. The alias is what lets your client survive a namespace failover without changing configuration.
</div>

<div class="lab-note">
<strong>If local auth is disabled:</strong> Some subscriptions enforce <code>disableLocalAuth=true</code> on Event Hubs namespaces. In that case the SAS examples in the VM-based producer steps fail with authentication errors. Assign yourself an Event Hubs data role on both namespaces and use <code>AzureCliCredential</code> or <code>DefaultAzureCredential</code> against the alias FQDN instead.
</div>

<div class="lab-note">
<strong>Replication scope:</strong> The Event Hub definition and consumer group metadata replicate to the secondary namespace, but the event payloads themselves do <em>not</em>. This lab is about namespace continuity, not event-history preservation.
</div>

---

## Step 6 — Create the Private DNS Zone and Link Both Spokes

Use a dedicated shared resource group for the DNS zone so cleanup does not remove any Lab 0 network resources.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-dns zone create \
  --resource-group "$RG_SHARED" \
  --name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-dns link vnet create \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "$DNS_LINK_PRIMARY" \
  --virtual-network "$SPOKE_VNET_PRIMARY_ID" \
  --registration-enabled false \
  --output table

az network private-dns link vnet create \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "$DNS_LINK_SECONDARY" \
  --virtual-network "$SPOKE_VNET_SECONDARY_ID" \
  --registration-enabled false \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-dns zone create `
  --resource-group $RG_SHARED `
  --name $PRIVATE_DNS_ZONE `
  --output table

az network private-dns link vnet create `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --name $DNS_LINK_PRIMARY `
  --virtual-network $SPOKE_VNET_PRIMARY_ID `
  --registration-enabled false `
  --output table

az network private-dns link vnet create `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --name $DNS_LINK_SECONDARY `
  --virtual-network $SPOKE_VNET_SECONDARY_ID `
  --registration-enabled false `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a private DNS zone named `privatelink.servicebus.windows.net` in the shared lab resource group.
2. Link that zone to `vnet-spoke-swc`.
3. Link the same zone to `vnet-spoke-noe`.
4. Keep auto-registration disabled — this zone is for explicit Private Link records, not general VM hostname registration.

  </div>
</div>

---

## Step 7 — Create Private Endpoints for Both Namespaces

Namespace private endpoints are regional resources. Geo-DR does not create or copy them for you.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIVATE_DNS_ZONE_ID=$(az network private-dns zone show \
  --resource-group "$RG_SHARED" \
  --name "$PRIVATE_DNS_ZONE" \
  --query id \
  --output tsv)

EH_PRIMARY_ID=$(az eventhubs namespace show \
  --resource-group "$RG_PRIMARY" \
  --name "$EH_PRIMARY" \
  --query id \
  --output tsv)

EH_SECONDARY_ID=$(az eventhubs namespace show \
  --resource-group "$RG_SECONDARY" \
  --name "$EH_SECONDARY" \
  --query id \
  --output tsv)

# Create the secondary private endpoint first because the Geo-DR pairing already exists.
az network private-endpoint create \
  --name "$PE_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --subnet "$PE_SUBNET_SECONDARY_ID" \
  --private-connection-resource-id "$EH_SECONDARY_ID" \
  --group-id namespace \
  --connection-name "$PE_CONNECTION_SECONDARY" \
  --nic-name "nic-$PE_SECONDARY" \
  --output table

az network private-endpoint dns-zone-group create \
  --endpoint-name "$PE_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --name default \
  --private-dns-zone "$PRIVATE_DNS_ZONE_ID" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-endpoint create \
  --name "$PE_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --subnet "$PE_SUBNET_PRIMARY_ID" \
  --private-connection-resource-id "$EH_PRIMARY_ID" \
  --group-id namespace \
  --connection-name "$PE_CONNECTION_PRIMARY" \
  --nic-name "nic-$PE_PRIMARY" \
  --output table

az network private-endpoint dns-zone-group create \
  --endpoint-name "$PE_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --name default \
  --private-dns-zone "$PRIVATE_DNS_ZONE_ID" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-dns record-set a list \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --query "[].{Name:name,IP:arecords[0].ipv4Address}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIVATE_DNS_ZONE_ID = az network private-dns zone show `
  --resource-group $RG_SHARED `
  --name $PRIVATE_DNS_ZONE `
  --query id `
  --output tsv

$EH_PRIMARY_ID = az eventhubs namespace show `
  --resource-group $RG_PRIMARY `
  --name $EH_PRIMARY `
  --query id `
  --output tsv

$EH_SECONDARY_ID = az eventhubs namespace show `
  --resource-group $RG_SECONDARY `
  --name $EH_SECONDARY `
  --query id `
  --output tsv

# Create the secondary private endpoint first because the Geo-DR pairing already exists.
az network private-endpoint create `
  --name $PE_SECONDARY `
  --resource-group $RG_SECONDARY `
  --location $LOCATION_SECONDARY `
  --subnet $PE_SUBNET_SECONDARY_ID `
  --private-connection-resource-id $EH_SECONDARY_ID `
  --group-id namespace `
  --connection-name $PE_CONNECTION_SECONDARY `
  --nic-name "nic-$PE_SECONDARY" `
  --output table

az network private-endpoint dns-zone-group create `
  --endpoint-name $PE_SECONDARY `
  --resource-group $RG_SECONDARY `
  --name default `
  --private-dns-zone $PRIVATE_DNS_ZONE_ID `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table

az network private-endpoint create `
  --name $PE_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $LOCATION_PRIMARY `
  --subnet $PE_SUBNET_PRIMARY_ID `
  --private-connection-resource-id $EH_PRIMARY_ID `
  --group-id namespace `
  --connection-name $PE_CONNECTION_PRIMARY `
  --nic-name "nic-$PE_PRIMARY" `
  --output table

az network private-endpoint dns-zone-group create `
  --endpoint-name $PE_PRIMARY `
  --resource-group $RG_PRIMARY `
  --name default `
  --private-dns-zone $PRIVATE_DNS_ZONE_ID `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table

az network private-dns record-set a list `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --query "[].{Name:name,IP:arecords[0].ipv4Address}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a private endpoint for the Norway East namespace first in `vnet-spoke-noe` → `snet-private-endpoints`.
2. Attach it to the shared private DNS zone.
3. Repeat the same pattern for the Sweden Central namespace in `vnet-spoke-swc` → `snet-private-endpoints`.
4. Confirm the zone now contains at least two namespace records — one for each namespace name.

  </div>
</div>

<div class="lab-note">
<strong>Why both endpoints matter:</strong> Event Hubs Geo-DR does not replicate virtual-network configuration, private endpoint connections, or public-network-access settings. If you want a private failover story, build the private plumbing in <strong>both</strong> regions up front.
</div>

---

## Step 8 — Create Two Regional Validation VMs

These small VMs live in the existing workload subnets from Lab 0. They let you validate private namespace and alias access from inside each regional stamp.

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
  --location "$LOCATION_PRIMARY" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username "$VM_ADMIN" \
  --generate-ssh-keys \
  --subnet "$WORKLOAD_SUBNET_PRIMARY_ID" \
  --public-ip-address "" \
  --nsg-rule NONE \
  --output table

az vm create \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username "$VM_ADMIN" \
  --generate-ssh-keys \
  --subnet "$WORKLOAD_SUBNET_SECONDARY_ID" \
  --public-ip-address "" \
  --nsg-rule NONE \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az vm create `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --location $LOCATION_PRIMARY `
  --image Ubuntu2204 `
  --size Standard_B1s `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --subnet $WORKLOAD_SUBNET_PRIMARY_ID `
  --public-ip-address "" `
  --nsg-rule NONE `
  --output table

az vm create `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --location $LOCATION_SECONDARY `
  --image Ubuntu2204 `
  --size Standard_B1s `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --subnet $WORKLOAD_SUBNET_SECONDARY_ID `
  --public-ip-address "" `
  --nsg-rule NONE `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create one small Ubuntu VM in `snet-workload` inside `vnet-spoke-swc`.
2. Create a second small Ubuntu VM in `snet-workload` inside `vnet-spoke-noe`.
3. Do **not** assign public IP addresses.
4. If you prefer an interactive portal validation path later, Bastion from Lab 0 can still connect to these VMs.

  </div>
</div>

---

## Step 9 — Bootstrap the VMs and Validate Direct Namespace Access

Install the minimal tooling inside each VM, then verify the direct namespace FQDN in each region resolves to a private IP and answers on AMQP-over-TLS port `5671`.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
VM_NAMESPACE_TEST_SCRIPT='
set -e
TARGET_HOST="$1"

apt-get update
apt-get install -y dnsutils python3-venv

if [ ! -d /opt/ehvenv ]; then
  python3 -m venv /opt/ehvenv
fi
/opt/ehvenv/bin/pip install --quiet azure-eventhub

nslookup "$TARGET_HOST"

TARGET_HOST="$TARGET_HOST" python3 - <<PY
import os, socket
host = os.environ["TARGET_HOST"]
socket.create_connection((host, 5671), timeout=5).close()
print(f"{host} TCP 5671 reachable over private endpoint.")
PY
'

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "$VM_NAMESPACE_TEST_SCRIPT" \
  --parameters "$EH_PRIMARY.servicebus.windows.net" \
  --query "value[0].message" \
  --output tsv

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$VM_NAMESPACE_TEST_SCRIPT" \
  --parameters "$EH_SECONDARY.servicebus.windows.net" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$VmNamespaceTestScript = @'
set -e
TARGET_HOST="$1"

apt-get update
apt-get install -y dnsutils python3-venv

if [ ! -d /opt/ehvenv ]; then
  python3 -m venv /opt/ehvenv
fi
/opt/ehvenv/bin/pip install --quiet azure-eventhub

nslookup "$TARGET_HOST"

TARGET_HOST="$TARGET_HOST" python3 - <<PY
import os, socket
host = os.environ["TARGET_HOST"]
socket.create_connection((host, 5671), timeout=5).close()
print(f"{host} TCP 5671 reachable over private endpoint.")
PY
'@

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $VmNamespaceTestScript `
  --parameters "$EH_PRIMARY.servicebus.windows.net" `
  --query "value[0].message" `
  --output tsv

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $VmNamespaceTestScript `
  --parameters "$EH_SECONDARY.servicebus.windows.net" `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. On each VM, use **Run command** → **RunShellScript** to install:
   - `dnsutils`
   - `python3-venv`
   - `azure-eventhub` inside a small virtual environment
2. From the Sweden Central VM, run `nslookup <primary-namespace>.servicebus.windows.net` and confirm the answer is private.
3. From the Norway East VM, run `nslookup <secondary-namespace>.servicebus.windows.net` and confirm the answer is private.
4. Optionally use Bastion for an interactive shell, but the shell tabs keep everything reproducible through **Run command**.

  </div>
</div>

<div class="lab-note">
<strong>Namespace versus alias:</strong> These direct namespace checks prove the private endpoints and DNS are healthy in both regions. Your actual producers should still use the alias connection string for messaging.
</div>

---

## Step 10 — Map the Alias to the Active Private Endpoint and Disable Public Access

The namespace records were created automatically by the DNS zone groups. Now add an explicit alias record for the current active region, then turn off public ingress on both namespaces.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PE_PRIMARY_NIC_ID=$(az network private-endpoint show \
  --resource-group "$RG_PRIMARY" \
  --name "$PE_PRIMARY" \
  --query "networkInterfaces[0].id" \
  --output tsv)

PE_SECONDARY_NIC_ID=$(az network private-endpoint show \
  --resource-group "$RG_SECONDARY" \
  --name "$PE_SECONDARY" \
  --query "networkInterfaces[0].id" \
  --output tsv)

PE_PRIMARY_IP=$(az network nic show \
  --ids "$PE_PRIMARY_NIC_ID" \
  --query "ipConfigurations[0].privateIPAddress" \
  --output tsv)

PE_SECONDARY_IP=$(az network nic show \
  --ids "$PE_SECONDARY_NIC_ID" \
  --query "ipConfigurations[0].privateIPAddress" \
  --output tsv)

az network private-dns record-set a delete \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "$EH_ALIAS" \
  --yes 2>/dev/null || true

az network private-dns record-set a add-record \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --record-set-name "$EH_ALIAS" \
  --ipv4-address "$PE_PRIMARY_IP"

az network private-dns record-set a show \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "$EH_ALIAS" \
  --query "{Name:name,IP:arecords[0].ipv4Address}" \
  --output table

az eventhubs namespace network-rule-set update \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$EH_PRIMARY" \
  --default-action Deny \
  --public-network-access Disabled \
  --output table

az eventhubs namespace network-rule-set update \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$EH_SECONDARY" \
  --default-action Deny \
  --public-network-access Disabled \
  --output table

if [ -z "$VM_NAMESPACE_TEST_SCRIPT" ]; then
  VM_NAMESPACE_TEST_SCRIPT='
set -e
TARGET_HOST="$1"

apt-get update
apt-get install -y dnsutils python3-venv

if [ ! -d /opt/ehvenv ]; then
  python3 -m venv /opt/ehvenv
fi
/opt/ehvenv/bin/pip install --quiet azure-eventhub

nslookup "$TARGET_HOST"

TARGET_HOST="$TARGET_HOST" python3 - <<PY
import os, socket
host = os.environ["TARGET_HOST"]
socket.create_connection((host, 5671), timeout=5).close()
print(f"{host} TCP 5671 reachable over private endpoint.")
PY
'
fi

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "$VM_NAMESPACE_TEST_SCRIPT" \
  --parameters "$EH_ALIAS.servicebus.windows.net" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PE_PRIMARY_NIC_ID = az network private-endpoint show `
  --resource-group $RG_PRIMARY `
  --name $PE_PRIMARY `
  --query "networkInterfaces[0].id" `
  --output tsv

$PE_SECONDARY_NIC_ID = az network private-endpoint show `
  --resource-group $RG_SECONDARY `
  --name $PE_SECONDARY `
  --query "networkInterfaces[0].id" `
  --output tsv

$PE_PRIMARY_IP = az network nic show `
  --ids $PE_PRIMARY_NIC_ID `
  --query "ipConfigurations[0].privateIPAddress" `
  --output tsv

$PE_SECONDARY_IP = az network nic show `
  --ids $PE_SECONDARY_NIC_ID `
  --query "ipConfigurations[0].privateIPAddress" `
  --output tsv

az network private-dns record-set a delete `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --name $EH_ALIAS `
  --yes 2>$null

az network private-dns record-set a add-record `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --record-set-name $EH_ALIAS `
  --ipv4-address $PE_PRIMARY_IP

az network private-dns record-set a show `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --name $EH_ALIAS `
  --query "{Name:name,IP:arecords[0].ipv4Address}" `
  --output table

az eventhubs namespace network-rule-set update `
  --resource-group $RG_PRIMARY `
  --namespace-name $EH_PRIMARY `
  --default-action Deny `
  --public-network-access Disabled `
  --output table

az eventhubs namespace network-rule-set update `
  --resource-group $RG_SECONDARY `
  --namespace-name $EH_SECONDARY `
  --default-action Deny `
  --public-network-access Disabled `
  --output table

if (-not $VmNamespaceTestScript) {
    $VmNamespaceTestScript = @'
set -e
TARGET_HOST="$1"

apt-get update
apt-get install -y dnsutils python3-venv

if [ ! -d /opt/ehvenv ]; then
  python3 -m venv /opt/ehvenv
fi
/opt/ehvenv/bin/pip install --quiet azure-eventhub

nslookup "$TARGET_HOST"

TARGET_HOST="$TARGET_HOST" python3 - <<PY
import os, socket
host = os.environ["TARGET_HOST"]
socket.create_connection((host, 5671), timeout=5).close()
print(f"{host} TCP 5671 reachable over private endpoint.")
PY
'@
}

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $VmNamespaceTestScript `
  --parameters "$EH_ALIAS.servicebus.windows.net" `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Find the private IP of the Sweden Central namespace private endpoint.
2. In `privatelink.servicebus.windows.net`, create an `A` record named after the alias and point it to that private IP.
3. Disable **Public network access** on both Event Hubs namespaces.
4. Use **Run command** on the Sweden Central VM to confirm `eh-alias-prv-<suffix>.servicebus.windows.net` now resolves privately.

  </div>
</div>

<div class="lab-note">
<strong>Regional-stamp note:</strong> Lab 0 intentionally does <strong>not</strong> create cross-region VNet peering. Before failover, validate the private alias from the Sweden Central VM because the alias record points to the Sweden Central private endpoint. After failover, you will validate from the Norway East VM instead.
</div>

---

## Step 11 — Send Through the Alias from Sweden Central

Use the same alias endpoint as the public version, but execute the client code inside the Sweden Central spoke VM so the connection stays private end to end.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
if [ -z "$EVENTHUB_ALIAS_CONNECTION_STRING" ]; then
  EVENTHUB_ALIAS_CONNECTION_STRING=$(az eventhubs georecovery-alias authorization-rule keys list \
    --resource-group "$RG_PRIMARY" \
    --namespace-name "$EH_PRIMARY" \
    --alias "$EH_ALIAS" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString \
    --output tsv)
fi

EVENTHUB_ALIAS_CONNECTION_STRING_B64=$(printf '%s' "$EVENTHUB_ALIAS_CONNECTION_STRING" | base64 | tr -d '\n')

VM_ALIAS_PRODUCER_SCRIPT='
set -e
CONN_B64="$1"
MESSAGE_PREFIX="$2"
CONN=$(printf "%s" "$CONN_B64" | base64 -d)
export EH_CONN="$CONN"
export MESSAGE_PREFIX="$MESSAGE_PREFIX"

/opt/ehvenv/bin/python - <<PY
import os
from azure.eventhub import EventHubProducerClient, EventData

connection_string = os.environ["EH_CONN"]
message_prefix = os.environ["MESSAGE_PREFIX"]

producer = EventHubProducerClient.from_connection_string(
    conn_str=connection_string,
    eventhub_name="events-telemetry",
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"{message_prefix} {i}"))
    producer.send_batch(batch)
    print(f"Sent 10 events with prefix: {message_prefix}")
PY
'

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_PRIMARY" \
  --command-id RunShellScript \
  --scripts "$VM_ALIAS_PRODUCER_SCRIPT" \
  --parameters "$EVENTHUB_ALIAS_CONNECTION_STRING_B64" "Pre-failover private event" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
if (-not $EVENTHUB_ALIAS_CONNECTION_STRING) {
    $EVENTHUB_ALIAS_CONNECTION_STRING = az eventhubs georecovery-alias authorization-rule keys list `
      --resource-group $RG_PRIMARY `
      --namespace-name $EH_PRIMARY `
      --alias $EH_ALIAS `
      --name RootManageSharedAccessKey `
      --query primaryConnectionString `
      --output tsv
}

$EVENTHUB_ALIAS_CONNECTION_STRING_B64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($EVENTHUB_ALIAS_CONNECTION_STRING))

$VmAliasProducerScript = @'
set -e
CONN_B64="$1"
MESSAGE_PREFIX="$2"
CONN=$(printf "%s" "$CONN_B64" | base64 -d)
export EH_CONN="$CONN"
export MESSAGE_PREFIX="$MESSAGE_PREFIX"

/opt/ehvenv/bin/python - <<PY
import os
from azure.eventhub import EventHubProducerClient, EventData

connection_string = os.environ["EH_CONN"]
message_prefix = os.environ["MESSAGE_PREFIX"]

producer = EventHubProducerClient.from_connection_string(
    conn_str=connection_string,
    eventhub_name="events-telemetry",
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"{message_prefix} {i}"))
    producer.send_batch(batch)
    print(f"Sent 10 events with prefix: {message_prefix}")
PY
'@

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_PRIMARY `
  --command-id RunShellScript `
  --scripts $VmAliasProducerScript `
  --parameters $EVENTHUB_ALIAS_CONNECTION_STRING_B64 "Pre-failover private event" `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Retrieve the alias connection string if you have not already kept it from Step 5.
2. On the Sweden Central VM, use **Run command** or an interactive Bastion shell to run a tiny producer script against the alias.
3. Send a short batch of events through `events-telemetry`.
4. This proves the alias works privately from the active regional spoke.

  </div>
</div>

---

## Step 12 — Fail Over the Alias to Norway East

Keep the Event Hubs failover story identical to the public variant: fail over from the current secondary namespace and wait until it becomes the new primary.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs georecovery-alias fail-over \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$EH_SECONDARY" \
  --alias "$EH_ALIAS"

while true; do
  STATE=$(az eventhubs georecovery-alias show \
    --resource-group "$RG_SECONDARY" \
    --namespace-name "$EH_SECONDARY" \
    --alias "$EH_ALIAS" \
    --query provisioningState \
    --output tsv 2>/dev/null)

  ROLE=$(az eventhubs georecovery-alias show \
    --resource-group "$RG_SECONDARY" \
    --namespace-name "$EH_SECONDARY" \
    --alias "$EH_ALIAS" \
    --query role \
    --output tsv 2>/dev/null)

  echo "State: ${STATE:-pending} | Role: ${ROLE:-unknown}"
  if [ "$STATE" = "Succeeded" ] && [[ "$ROLE" == Primary* ]]; then
    break
  fi
  sleep 15
done
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs georecovery-alias fail-over `
  --resource-group $RG_SECONDARY `
  --namespace-name $EH_SECONDARY `
  --alias $EH_ALIAS

do {
    $STATE = az eventhubs georecovery-alias show `
      --resource-group $RG_SECONDARY `
      --namespace-name $EH_SECONDARY `
      --alias $EH_ALIAS `
      --query provisioningState `
      --output tsv 2>$null

    $ROLE = az eventhubs georecovery-alias show `
      --resource-group $RG_SECONDARY `
      --namespace-name $EH_SECONDARY `
      --alias $EH_ALIAS `
      --query role `
      --output tsv 2>$null

    Write-Host "State: $STATE | Role: $ROLE"
    if (-not ($STATE -eq "Succeeded" -and $ROLE -like "Primary*")) {
        Start-Sleep -Seconds 15
    }
} while (-not ($STATE -eq "Succeeded" -and $ROLE -like "Primary*"))
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Norway East namespace.
2. On **Geo recovery**, choose the alias and select **Fail over**.
3. Confirm the operation.
4. Wait until the Norway East namespace reports itself as the new primary.

  </div>
</div>

<div class="lab-note">
<strong>Failover is still one-way:</strong> Geo-DR promotes Norway East and breaks the old pairing. The networking layer changes too — your private alias record now needs to follow the promoted private endpoint.
</div>

---

## Step 13 — Update the Alias DNS Record and Validate from Norway East

After failover, repoint the alias record to the Norway East private endpoint IP, then validate the alias from the Norway East workload VM.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-dns record-set a delete \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "$EH_ALIAS" \
  --yes

az network private-dns record-set a add-record \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --record-set-name "$EH_ALIAS" \
  --ipv4-address "$PE_SECONDARY_IP"

az network private-dns record-set a show \
  --resource-group "$RG_SHARED" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "$EH_ALIAS" \
  --query "{Name:name,IP:arecords[0].ipv4Address}" \
  --output table

if [ -z "$VM_NAMESPACE_TEST_SCRIPT" ]; then
  VM_NAMESPACE_TEST_SCRIPT='
set -e
TARGET_HOST="$1"

apt-get update
apt-get install -y dnsutils python3-venv

if [ ! -d /opt/ehvenv ]; then
  python3 -m venv /opt/ehvenv
fi
/opt/ehvenv/bin/pip install --quiet azure-eventhub

nslookup "$TARGET_HOST"

TARGET_HOST="$TARGET_HOST" python3 - <<PY
import os, socket
host = os.environ["TARGET_HOST"]
socket.create_connection((host, 5671), timeout=5).close()
print(f"{host} TCP 5671 reachable over private endpoint.")
PY
'
fi

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$VM_NAMESPACE_TEST_SCRIPT" \
  --parameters "$EH_ALIAS.servicebus.windows.net" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-dns record-set a delete `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --name $EH_ALIAS `
  --yes

az network private-dns record-set a add-record `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --record-set-name $EH_ALIAS `
  --ipv4-address $PE_SECONDARY_IP

az network private-dns record-set a show `
  --resource-group $RG_SHARED `
  --zone-name $PRIVATE_DNS_ZONE `
  --name $EH_ALIAS `
  --query "{Name:name,IP:arecords[0].ipv4Address}" `
  --output table

if (-not $VmNamespaceTestScript) {
    $VmNamespaceTestScript = @'
set -e
TARGET_HOST="$1"

apt-get update
apt-get install -y dnsutils python3-venv

if [ ! -d /opt/ehvenv ]; then
  python3 -m venv /opt/ehvenv
fi
/opt/ehvenv/bin/pip install --quiet azure-eventhub

nslookup "$TARGET_HOST"

TARGET_HOST="$TARGET_HOST" python3 - <<PY
import os, socket
host = os.environ["TARGET_HOST"]
socket.create_connection((host, 5671), timeout=5).close()
print(f"{host} TCP 5671 reachable over private endpoint.")
PY
'@
}

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $VmNamespaceTestScript `
  --parameters "$EH_ALIAS.servicebus.windows.net" `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the private DNS zone, update the alias `A` record so it points to the Norway East private endpoint IP.
2. Use **Run command** on the Norway East VM to run `nslookup <alias>.servicebus.windows.net`.
3. Confirm the alias now resolves privately in Norway East.
4. Do not expect the original Sweden Central VM to reach the Norway East private IP without adding cross-region network connectivity — Lab 0 intentionally does not create that path.

  </div>
</div>

---

## Step 14 — Send Through the Same Alias After Failover

The client configuration stays the same. Only the private alias record and the active region changed.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
if [ -z "$EVENTHUB_ALIAS_CONNECTION_STRING" ]; then
  EVENTHUB_ALIAS_CONNECTION_STRING=$(az eventhubs georecovery-alias authorization-rule keys list \
    --resource-group "$RG_SECONDARY" \
    --namespace-name "$EH_SECONDARY" \
    --alias "$EH_ALIAS" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString \
    --output tsv)
fi

EVENTHUB_ALIAS_CONNECTION_STRING_B64=$(printf '%s' "$EVENTHUB_ALIAS_CONNECTION_STRING" | base64 | tr -d '\n')

if [ -z "$VM_ALIAS_PRODUCER_SCRIPT" ]; then
  VM_ALIAS_PRODUCER_SCRIPT='
set -e
CONN_B64="$1"
MESSAGE_PREFIX="$2"
CONN=$(printf "%s" "$CONN_B64" | base64 -d)
export EH_CONN="$CONN"
export MESSAGE_PREFIX="$MESSAGE_PREFIX"

/opt/ehvenv/bin/python - <<PY
import os
from azure.eventhub import EventHubProducerClient, EventData

connection_string = os.environ["EH_CONN"]
message_prefix = os.environ["MESSAGE_PREFIX"]

producer = EventHubProducerClient.from_connection_string(
    conn_str=connection_string,
    eventhub_name="events-telemetry",
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"{message_prefix} {i}"))
    producer.send_batch(batch)
    print(f"Sent 10 events with prefix: {message_prefix}")
PY
'
fi

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$VM_SECONDARY" \
  --command-id RunShellScript \
  --scripts "$VM_ALIAS_PRODUCER_SCRIPT" \
  --parameters "$EVENTHUB_ALIAS_CONNECTION_STRING_B64" "Post-failover private event" \
  --query "value[0].message" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
if (-not $EVENTHUB_ALIAS_CONNECTION_STRING) {
    $EVENTHUB_ALIAS_CONNECTION_STRING = az eventhubs georecovery-alias authorization-rule keys list `
      --resource-group $RG_SECONDARY `
      --namespace-name $EH_SECONDARY `
      --alias $EH_ALIAS `
      --name RootManageSharedAccessKey `
      --query primaryConnectionString `
      --output tsv
}

$EVENTHUB_ALIAS_CONNECTION_STRING_B64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($EVENTHUB_ALIAS_CONNECTION_STRING))

if (-not $VmAliasProducerScript) {
    $VmAliasProducerScript = @'
set -e
CONN_B64="$1"
MESSAGE_PREFIX="$2"
CONN=$(printf "%s" "$CONN_B64" | base64 -d)
export EH_CONN="$CONN"
export MESSAGE_PREFIX="$MESSAGE_PREFIX"

/opt/ehvenv/bin/python - <<PY
import os
from azure.eventhub import EventHubProducerClient, EventData

connection_string = os.environ["EH_CONN"]
message_prefix = os.environ["MESSAGE_PREFIX"]

producer = EventHubProducerClient.from_connection_string(
    conn_str=connection_string,
    eventhub_name="events-telemetry",
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"{message_prefix} {i}"))
    producer.send_batch(batch)
    print(f"Sent 10 events with prefix: {message_prefix}")
PY
'@
}

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $VM_SECONDARY `
  --command-id RunShellScript `
  --scripts $VmAliasProducerScript `
  --parameters $EVENTHUB_ALIAS_CONNECTION_STRING_B64 "Post-failover private event" `
  --query "value[0].message" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Reuse the same alias connection string you captured earlier. If you lost it, retrieve it again from the promoted Norway East namespace.
2. On the Norway East VM, send a batch of events through the alias.
3. Keep the alias and Event Hub name exactly the same as before failover.
4. This proves the alias-based client flow still works after failover without changing application configuration.

  </div>
</div>

---

## Validation Checklist

| # | Check | Expected Result |
|---|---|---|
| 1 | Lab 0 spoke foundation present | `vnet-spoke-swc`, `vnet-spoke-noe`, `snet-workload`, and `snet-private-endpoints` all exist |
| 2 | Namespace private endpoints created | One private endpoint exists per namespace, each in the correct spoke subnet |
| 3 | Private DNS zone linked to both spokes | `privatelink.servicebus.windows.net` is linked to both VNets |
| 4 | Event Hub metadata replicated | `events-telemetry` and `analytics-cg` appear on the secondary namespace |
| 5 | Direct namespace access validated | Each VM resolves its regional namespace FQDN to a private IP and reaches TCP 5671 |
| 6 | Public network access disabled | Both namespaces deny public ingress after the alias private path is ready |
| 7 | Alias works privately before failover | Sweden Central VM sends through `eh-alias-prv-<suffix>.servicebus.windows.net` |
| 8 | Alias follows failover privately | After the alias `A` record is updated, the Norway East VM reaches the same alias privately |
| 9 | Same alias still publishes after failover | Norway East VM sends through the same alias without changing producer configuration |

---

## Cleanup

Delete only the lab-specific resource groups. Keep the Lab 0 shared network resource groups if you plan to use other secured `B` variants later.

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
az group delete --name "$RG_SHARED" --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
az group delete --name $RG_SHARED --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete the Sweden Central lab resource group.
2. Delete the Norway East lab resource group.
3. Delete the shared private-DNS resource group for this lab.
4. Leave `rg-hub-swc`, `rg-hub-noe`, `rg-spoke-swc`, and `rg-spoke-noe` in place if you want to reuse the Lab 0 foundation.

  </div>
</div>

---

## Discussion

### Why Private DNS Becomes Part of the DR Runbook

Geo-DR keeps the **Event Hubs namespace contract** alive, but it does not move your private endpoints, private DNS links, or alias-private-IP mapping for you. In a private-only design, DNS changes are no longer optional operational details — they are part of the actual failover sequence.

### What Still Does Not Replicate

Even in the private variant, Geo-DR still replicates **metadata only**:

- Event Hubs, consumer groups, and namespace configuration
- SAS rules and alias metadata

It still does **not** replicate:

- Event payloads already published to the old primary
- Consumer checkpoints
- Private endpoint resources
- Private DNS zone links and custom alias records

### Why Validation Stays Regional

Lab 0 intentionally keeps the Sweden Central and Norway East spokes as separate regional stamps. That is why this lab validates the alias from the **active region’s** spoke VM before failover and then from the newly active region’s spoke VM after failover, instead of assuming cross-region east-west reachability.

---

## Summary

In this lab you reused the Lab 0 spoke VNets, created one private endpoint per Event Hubs namespace, linked a shared private DNS zone to both spokes, validated direct namespace reachability from regional workload VMs, published through the Geo-DR alias from Sweden Central, failed over to Norway East, updated the private alias mapping, and then published through the **same alias** again from the Norway East spoke.

---

## Key Takeaways

- **Private Link is separate from Geo-DR** — you must build the network path in both regions.
- **The alias remains the right client target** even when the data path is private-only.
- **Private DNS is part of failover** when you want the alias to stay private during regional promotion.
- **Regional spoke validation is intentional** because Lab 0 does not create cross-region spoke peering.
- **Cleanup stays scoped to this lab** by deleting only the three application resource groups.

---

[Lab 10-a: Azure Event Hubs – Geo-Replication Failover](lab-10a-event-hubs-geo-replication.md) | **Lab 10-b: Azure Event Hubs – Private Networking**
