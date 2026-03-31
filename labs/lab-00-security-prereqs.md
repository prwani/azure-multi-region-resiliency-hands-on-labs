---
layout: default
title: "Lab 0: Security Pre-Reqs – Optional Hub-and-Spoke Foundation"
---

[← Back to Index](../index.md)

# Lab 0: Security Pre-Reqs – Optional Hub-and-Spoke Foundation

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

> **Objective:** Build an optional two-region hub-and-spoke network foundation — hub and spoke VNets in Sweden Central and Norway East, plus Azure Firewall and Azure Bastion in both hubs — so later `B` variant labs can reuse consistent network names, subnets, and security assumptions.

<div class="lab-note">
<strong>Optional foundation:</strong> Complete this lab only if you plan to use the secured <code>B</code> variants of later labs. The simpler <code>A</code> variants keep public endpoints and do not depend on Lab 0.
</div>

> **⚠️ Cost note:** Two Azure Firewalls and two Azure Bastions are billed by the hour. If you are not moving directly into a later `B` variant, run the cleanup section as soon as you finish validating the foundation.

---

## Why This Lab Exists

The AKS multi-region reference architecture recommends a **regional hub-and-spoke network** for each workload stamp. That pattern is broader than AKS: once you have a clean hub for shared controls and a clean spoke for workloads, later services can plug into the same security boundary instead of reinventing networking in every lab.

This optional Lab 0 creates that reusable base in the same two regions used throughout the rest of the series:

- **Primary region:** Sweden Central (`swedencentral`, `swc`)
- **DR region:** Norway East (`norwayeast`, `noe`)

Each region gets:

- One **hub VNet** for shared network controls
- One **spoke VNet** for later lab workloads
- One **Azure Firewall** in the hub
- One **Azure Bastion** in the hub
- One consistent set of spoke subnets for workloads, App Service / Functions integration, and private endpoints

This lab deliberately keeps each region as its own **self-contained stamp**. You will create **hub-to-spoke peering inside each region**, but you will **not** create cross-region VNet peering here. Later resiliency layers such as Traffic Manager, Front Door, replication, or service-native failover handle inter-region behavior.

---

## Architecture

```text
┌──────────────────────────── Sweden Central (Primary) ────────────────────────────┐
│ rg-hub-swc                                                                       │
│  vnet-hub-swc 10.10.0.0/24                                                       │
│   ├─ AzureFirewallSubnet      10.10.0.0/26    → afw-hub-swc + afwp-hub-swc      │
│   ├─ AzureBastionSubnet       10.10.0.64/26   → bas-hub-swc                      │
│   └─ snet-hub-shared          10.10.0.128/26  → reserved for shared services     │
│                  ▲                                                                   │
│                  │ hub-spoke peering                                                 │
│                  ▼                                                                   │
│ rg-spoke-swc                                                                     │
│  vnet-spoke-swc 10.10.4.0/22                                                     │
│   ├─ snet-workload             10.10.4.0/24                                       │
│   ├─ snet-appsvc-integration   10.10.5.0/26                                       │
│   └─ snet-private-endpoints    10.10.5.64/26                                      │
└───────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────── Norway East (DR) ──────────────────────────────────┐
│ rg-hub-noe                                                                       │
│  vnet-hub-noe 10.20.0.0/24                                                       │
│   ├─ AzureFirewallSubnet      10.20.0.0/26    → afw-hub-noe + afwp-hub-noe      │
│   ├─ AzureBastionSubnet       10.20.0.64/26   → bas-hub-noe                      │
│   └─ snet-hub-shared          10.20.0.128/26  → reserved for shared services     │
│                  ▲                                                                   │
│                  │ hub-spoke peering                                                 │
│                  ▼                                                                   │
│ rg-spoke-noe                                                                     │
│  vnet-spoke-noe 10.20.4.0/22                                                     │
│   ├─ snet-workload             10.20.4.0/24                                       │
│   ├─ snet-appsvc-integration   10.20.5.0/26                                       │
│   └─ snet-private-endpoints    10.20.5.64/26                                      │
└───────────────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Contributor or Owner permissions, plus enough quota to create Azure Firewall, Azure Bastion, VNets, route tables, and Standard public IPs |
| **Azure CLI 2.75+** | Recommended because `az network firewall` uses the `azure-firewall` extension; Azure Cloud Shell is a good option |
| **PowerShell 7+** *(optional)* | Needed only if you follow the PowerShell path |
| **Target regions available** | Sweden Central and Norway East must both be available in your subscription |
| **Budget awareness** | Azure Firewall and Azure Bastion are premium services with hourly charges |

> **Important:** This lab intentionally uses **fixed names** such as `vnet-hub-swc` and `vnet-spoke-noe` so later `B` variants can reference them directly. If you rerun the lab, either clean up the old resource groups first or deliberately reuse the same foundation.

> **Scope note:** Private DNS zones, service-specific firewall allow rules, NSGs, and the private endpoints themselves are intentionally left to the later `B` variant labs. Lab 0 creates the network landing zones they plug into.

---

## Canonical Naming & Address Plan

| Component | Primary region | DR region | Why later `B` variants care |
|---|---|---|---|
| **Hub resource group** | `rg-hub-swc` | `rg-hub-noe` | Shared security services live here |
| **Spoke resource group** | `rg-spoke-swc` | `rg-spoke-noe` | Workload VNets and staged route tables live here |
| **Hub VNet** | `vnet-hub-swc` | `vnet-hub-noe` | Hosts Azure Firewall and Bastion |
| **Spoke VNet** | `vnet-spoke-swc` | `vnet-spoke-noe` | Later workloads deploy here, not in the hub |
| **Hub address space** | `10.10.0.0/24` | `10.20.0.0/24` | Compact regional security boundary |
| **Spoke address space** | `10.10.4.0/22` | `10.20.4.0/22` | Leaves room for future subnets beyond Lab 0 |
| **Firewall subnet** | `AzureFirewallSubnet` | `AzureFirewallSubnet` | Mandatory Azure-reserved subnet name |
| **Bastion subnet** | `AzureBastionSubnet` | `AzureBastionSubnet` | Mandatory Azure-reserved subnet name |
| **Shared hub subnet** | `snet-hub-shared` | `snet-hub-shared` | Reserved for future shared services such as DNS or jump hosts |
| **General workload subnet** | `snet-workload` | `snet-workload` | Default target for VMs, AKS, and other spoke compute unless a later lab says otherwise |
| **App Service integration subnet** | `snet-appsvc-integration` | `snet-appsvc-integration` | Reserved for App Service / Functions VNet integration |
| **Private endpoint subnet** | `snet-private-endpoints` | `snet-private-endpoints` | Reserved for Private Link endpoints only |
| **Firewall policy** | `afwp-hub-swc` | `afwp-hub-noe` | Later labs can extend the policy instead of starting over |
| **Firewall** | `afw-hub-swc` | `afw-hub-noe` | Regional egress/security anchor |
| **Bastion** | `bas-hub-swc` | `bas-hub-noe` | Regional admin entry point |
| **Staged route table** | `rt-spoke-egress-swc` | `rt-spoke-egress-noe` | Prepared for forced tunneling later |

<div class="lab-note">
<strong>Subnet sizing reminder:</strong> Keep both <code>AzureFirewallSubnet</code> and <code>AzureBastionSubnet</code> at <strong>/26 or larger</strong>. Those names are mandatory Azure platform requirements.
</div>

---

## How These Tabs Work

This page uses the same interaction pattern as the rest of the lab series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behavior used in the existing labs.

---

## Step 1 — Sign in and Prepare the CLI

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az version --output table
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"

az config set extension.use_dynamic_install=yes_without_prompt
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az version --output table
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"

az config set extension.use_dynamic_install=yes_without_prompt
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the [Azure portal](https://portal.azure.com).
2. Confirm the correct tenant and subscription under **Subscriptions**.
3. If you want an Azure-hosted shell, open **Cloud Shell** from the top toolbar.
4. If you are using a local workstation, make sure Azure CLI is current enough to install the firewall and bastion extensions on first use.

  </div>
</div>

<div class="lab-note">
<strong>Tip:</strong> Setting <code>extension.use_dynamic_install=yes_without_prompt</code> lets the Azure CLI auto-install the <code>azure-firewall</code> and <code>bastion</code> extensions the first time those commands run.
</div>

---

## Step 2 — Set the Fixed Regional Names and Address Spaces

Because later `B` variant labs will refer to these values directly, keep the names deterministic instead of randomizing them.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_REGION="swedencentral"
DR_REGION="norwayeast"

RG_HUB_PRIMARY="rg-hub-swc"
RG_SPOKE_PRIMARY="rg-spoke-swc"
RG_HUB_DR="rg-hub-noe"
RG_SPOKE_DR="rg-spoke-noe"

HUB_VNET_PRIMARY="vnet-hub-swc"
HUB_VNET_DR="vnet-hub-noe"
SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_DR="vnet-spoke-noe"

HUB_PRIMARY_CIDR="10.10.0.0/24"
HUB_DR_CIDR="10.20.0.0/24"
SPOKE_PRIMARY_CIDR="10.10.4.0/22"
SPOKE_DR_CIDR="10.20.4.0/22"

FW_SUBNET_NAME="AzureFirewallSubnet"
FW_SUBNET_PRIMARY_CIDR="10.10.0.0/26"
FW_SUBNET_DR_CIDR="10.20.0.0/26"

BASTION_SUBNET_NAME="AzureBastionSubnet"
BASTION_SUBNET_PRIMARY_CIDR="10.10.0.64/26"
BASTION_SUBNET_DR_CIDR="10.20.0.64/26"

HUB_SHARED_SUBNET_NAME="snet-hub-shared"
HUB_SHARED_PRIMARY_CIDR="10.10.0.128/26"
HUB_SHARED_DR_CIDR="10.20.0.128/26"

WORKLOAD_SUBNET_NAME="snet-workload"
WORKLOAD_PRIMARY_CIDR="10.10.4.0/24"
WORKLOAD_DR_CIDR="10.20.4.0/24"

APPSVC_SUBNET_NAME="snet-appsvc-integration"
APPSVC_PRIMARY_CIDR="10.10.5.0/26"
APPSVC_DR_CIDR="10.20.5.0/26"

PE_SUBNET_NAME="snet-private-endpoints"
PE_PRIMARY_CIDR="10.10.5.64/26"
PE_DR_CIDR="10.20.5.64/26"

FW_POLICY_PRIMARY="afwp-hub-swc"
FW_POLICY_DR="afwp-hub-noe"
FIREWALL_PRIMARY="afw-hub-swc"
FIREWALL_DR="afw-hub-noe"
FIREWALL_PIP_PRIMARY="pip-afw-swc"
FIREWALL_PIP_DR="pip-afw-noe"

BASTION_PRIMARY="bas-hub-swc"
BASTION_DR="bas-hub-noe"
BASTION_PIP_PRIMARY="pip-bas-swc"
BASTION_PIP_DR="pip-bas-noe"

ROUTE_TABLE_PRIMARY="rt-spoke-egress-swc"
ROUTE_TABLE_DR="rt-spoke-egress-noe"

echo "Primary hub VNet : $HUB_VNET_PRIMARY ($HUB_PRIMARY_CIDR)"
echo "Primary spoke VNet: $SPOKE_VNET_PRIMARY ($SPOKE_PRIMARY_CIDR)"
echo "DR hub VNet      : $HUB_VNET_DR ($HUB_DR_CIDR)"
echo "DR spoke VNet    : $SPOKE_VNET_DR ($SPOKE_DR_CIDR)"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_REGION = "swedencentral"
$DR_REGION = "norwayeast"

$RG_HUB_PRIMARY = "rg-hub-swc"
$RG_SPOKE_PRIMARY = "rg-spoke-swc"
$RG_HUB_DR = "rg-hub-noe"
$RG_SPOKE_DR = "rg-spoke-noe"

$HUB_VNET_PRIMARY = "vnet-hub-swc"
$HUB_VNET_DR = "vnet-hub-noe"
$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_DR = "vnet-spoke-noe"

$HUB_PRIMARY_CIDR = "10.10.0.0/24"
$HUB_DR_CIDR = "10.20.0.0/24"
$SPOKE_PRIMARY_CIDR = "10.10.4.0/22"
$SPOKE_DR_CIDR = "10.20.4.0/22"

$FW_SUBNET_NAME = "AzureFirewallSubnet"
$FW_SUBNET_PRIMARY_CIDR = "10.10.0.0/26"
$FW_SUBNET_DR_CIDR = "10.20.0.0/26"

$BASTION_SUBNET_NAME = "AzureBastionSubnet"
$BASTION_SUBNET_PRIMARY_CIDR = "10.10.0.64/26"
$BASTION_SUBNET_DR_CIDR = "10.20.0.64/26"

$HUB_SHARED_SUBNET_NAME = "snet-hub-shared"
$HUB_SHARED_PRIMARY_CIDR = "10.10.0.128/26"
$HUB_SHARED_DR_CIDR = "10.20.0.128/26"

$WORKLOAD_SUBNET_NAME = "snet-workload"
$WORKLOAD_PRIMARY_CIDR = "10.10.4.0/24"
$WORKLOAD_DR_CIDR = "10.20.4.0/24"

$APPSVC_SUBNET_NAME = "snet-appsvc-integration"
$APPSVC_PRIMARY_CIDR = "10.10.5.0/26"
$APPSVC_DR_CIDR = "10.20.5.0/26"

$PE_SUBNET_NAME = "snet-private-endpoints"
$PE_PRIMARY_CIDR = "10.10.5.64/26"
$PE_DR_CIDR = "10.20.5.64/26"

$FW_POLICY_PRIMARY = "afwp-hub-swc"
$FW_POLICY_DR = "afwp-hub-noe"
$FIREWALL_PRIMARY = "afw-hub-swc"
$FIREWALL_DR = "afw-hub-noe"
$FIREWALL_PIP_PRIMARY = "pip-afw-swc"
$FIREWALL_PIP_DR = "pip-afw-noe"

$BASTION_PRIMARY = "bas-hub-swc"
$BASTION_DR = "bas-hub-noe"
$BASTION_PIP_PRIMARY = "pip-bas-swc"
$BASTION_PIP_DR = "pip-bas-noe"

$ROUTE_TABLE_PRIMARY = "rt-spoke-egress-swc"
$ROUTE_TABLE_DR = "rt-spoke-egress-noe"

Write-Host "Primary hub VNet : $HUB_VNET_PRIMARY ($HUB_PRIMARY_CIDR)"
Write-Host "Primary spoke VNet: $SPOKE_VNET_PRIMARY ($SPOKE_PRIMARY_CIDR)"
Write-Host "DR hub VNet      : $HUB_VNET_DR ($HUB_DR_CIDR)"
Write-Host "DR spoke VNet    : $SPOKE_VNET_DR ($SPOKE_DR_CIDR)"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down these exact values before you continue:

- Hub resource groups: `rg-hub-swc`, `rg-hub-noe`
- Spoke resource groups: `rg-spoke-swc`, `rg-spoke-noe`
- Hub VNets: `vnet-hub-swc`, `vnet-hub-noe`
- Spoke VNets: `vnet-spoke-swc`, `vnet-spoke-noe`
- Hub address spaces: `10.10.0.0/24`, `10.20.0.0/24`
- Spoke address spaces: `10.10.4.0/22`, `10.20.4.0/22`
- Mandatory hub subnets: `AzureFirewallSubnet`, `AzureBastionSubnet`
- Reusable spoke subnets: `snet-workload`, `snet-appsvc-integration`, `snet-private-endpoints`
- Firewalls: `afw-hub-swc`, `afw-hub-noe`
- Bastions: `bas-hub-swc`, `bas-hub-noe`

  </div>
</div>

<div class="lab-note">
<strong>Important:</strong> Later <code>B</code> variants should be able to say “use <code>vnet-spoke-swc</code> / <code>snet-private-endpoints</code>” without redefining anything. Avoid renaming these resources if you want to follow those paths verbatim.
</div>

---

## Step 3 — Create the Hub and Spoke Resource Groups

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name "$RG_HUB_PRIMARY"   --location "$PRIMARY_REGION" --tags lab=00 scope=hub   region=swc
az group create --name "$RG_SPOKE_PRIMARY" --location "$PRIMARY_REGION" --tags lab=00 scope=spoke region=swc

az group create --name "$RG_HUB_DR"        --location "$DR_REGION"      --tags lab=00 scope=hub   region=noe
az group create --name "$RG_SPOKE_DR"      --location "$DR_REGION"      --tags lab=00 scope=spoke region=noe
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_HUB_PRIMARY   --location $PRIMARY_REGION --tags lab=00 scope=hub   region=swc
az group create --name $RG_SPOKE_PRIMARY --location $PRIMARY_REGION --tags lab=00 scope=spoke region=swc

az group create --name $RG_HUB_DR        --location $DR_REGION      --tags lab=00 scope=hub   region=noe
az group create --name $RG_SPOKE_DR      --location $DR_REGION      --tags lab=00 scope=spoke region=noe
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Create `rg-hub-swc` and `rg-spoke-swc` in **Sweden Central**.
3. Create `rg-hub-noe` and `rg-spoke-noe` in **Norway East**.
4. Optionally add tags such as `lab=00`, `scope=hub|spoke`, and `region=swc|noe`.

  </div>
</div>

---

## Step 4 — Create the Hub VNets and Required Hub Subnets

Each hub gets the two Azure-reserved subnets plus one spare shared subnet for future DNS, jump box, or shared network services.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet create \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$HUB_VNET_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --address-prefixes "$HUB_PRIMARY_CIDR" \
  --subnet-name "$FW_SUBNET_NAME" \
  --subnet-prefixes "$FW_SUBNET_PRIMARY_CIDR" \
  --tags lab=00 scope=hub region=swc

az network vnet subnet create \
  --resource-group "$RG_HUB_PRIMARY" \
  --vnet-name "$HUB_VNET_PRIMARY" \
  --name "$BASTION_SUBNET_NAME" \
  --address-prefixes "$BASTION_SUBNET_PRIMARY_CIDR"

az network vnet subnet create \
  --resource-group "$RG_HUB_PRIMARY" \
  --vnet-name "$HUB_VNET_PRIMARY" \
  --name "$HUB_SHARED_SUBNET_NAME" \
  --address-prefixes "$HUB_SHARED_PRIMARY_CIDR"

az network vnet create \
  --resource-group "$RG_HUB_DR" \
  --name "$HUB_VNET_DR" \
  --location "$DR_REGION" \
  --address-prefixes "$HUB_DR_CIDR" \
  --subnet-name "$FW_SUBNET_NAME" \
  --subnet-prefixes "$FW_SUBNET_DR_CIDR" \
  --tags lab=00 scope=hub region=noe

az network vnet subnet create \
  --resource-group "$RG_HUB_DR" \
  --vnet-name "$HUB_VNET_DR" \
  --name "$BASTION_SUBNET_NAME" \
  --address-prefixes "$BASTION_SUBNET_DR_CIDR"

az network vnet subnet create \
  --resource-group "$RG_HUB_DR" \
  --vnet-name "$HUB_VNET_DR" \
  --name "$HUB_SHARED_SUBNET_NAME" \
  --address-prefixes "$HUB_SHARED_DR_CIDR"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet create `
  --resource-group $RG_HUB_PRIMARY `
  --name $HUB_VNET_PRIMARY `
  --location $PRIMARY_REGION `
  --address-prefixes $HUB_PRIMARY_CIDR `
  --subnet-name $FW_SUBNET_NAME `
  --subnet-prefixes $FW_SUBNET_PRIMARY_CIDR `
  --tags lab=00 scope=hub region=swc

az network vnet subnet create `
  --resource-group $RG_HUB_PRIMARY `
  --vnet-name $HUB_VNET_PRIMARY `
  --name $BASTION_SUBNET_NAME `
  --address-prefixes $BASTION_SUBNET_PRIMARY_CIDR

az network vnet subnet create `
  --resource-group $RG_HUB_PRIMARY `
  --vnet-name $HUB_VNET_PRIMARY `
  --name $HUB_SHARED_SUBNET_NAME `
  --address-prefixes $HUB_SHARED_PRIMARY_CIDR

az network vnet create `
  --resource-group $RG_HUB_DR `
  --name $HUB_VNET_DR `
  --location $DR_REGION `
  --address-prefixes $HUB_DR_CIDR `
  --subnet-name $FW_SUBNET_NAME `
  --subnet-prefixes $FW_SUBNET_DR_CIDR `
  --tags lab=00 scope=hub region=noe

az network vnet subnet create `
  --resource-group $RG_HUB_DR `
  --vnet-name $HUB_VNET_DR `
  --name $BASTION_SUBNET_NAME `
  --address-prefixes $BASTION_SUBNET_DR_CIDR

az network vnet subnet create `
  --resource-group $RG_HUB_DR `
  --vnet-name $HUB_VNET_DR `
  --name $HUB_SHARED_SUBNET_NAME `
  --address-prefixes $HUB_SHARED_DR_CIDR
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-hub-swc`, create a VNet named `vnet-hub-swc` in **Sweden Central** with address space `10.10.0.0/24`.
2. Add these subnets:
   - `AzureFirewallSubnet` → `10.10.0.0/26`
   - `AzureBastionSubnet` → `10.10.0.64/26`
   - `snet-hub-shared` → `10.10.0.128/26`
3. In `rg-hub-noe`, create `vnet-hub-noe` in **Norway East** with address space `10.20.0.0/24`.
4. Add the same subnet names with the DR prefixes:
   - `AzureFirewallSubnet` → `10.20.0.0/26`
   - `AzureBastionSubnet` → `10.20.0.64/26`
   - `snet-hub-shared` → `10.20.0.128/26`

  </div>
</div>

<div class="lab-note">
<strong>Mandatory names:</strong> Azure Firewall and Azure Bastion will not deploy correctly unless the subnets are named exactly <code>AzureFirewallSubnet</code> and <code>AzureBastionSubnet</code>.
</div>

---

## Step 5 — Create the Spoke VNets and Reusable Spoke Subnets

The spoke is where the secure `B` variants deploy their workload resources. Keep private endpoints isolated in their own dedicated subnet.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --address-prefixes "$SPOKE_PRIMARY_CIDR" \
  --subnet-name "$WORKLOAD_SUBNET_NAME" \
  --subnet-prefixes "$WORKLOAD_PRIMARY_CIDR" \
  --tags lab=00 scope=spoke region=swc

az network vnet subnet create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$APPSVC_SUBNET_NAME" \
  --address-prefixes "$APPSVC_PRIMARY_CIDR"

az network vnet subnet create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$PE_SUBNET_NAME" \
  --address-prefixes "$PE_PRIMARY_CIDR" \
  --private-endpoint-network-policies Disabled

az network vnet create \
  --resource-group "$RG_SPOKE_DR" \
  --name "$SPOKE_VNET_DR" \
  --location "$DR_REGION" \
  --address-prefixes "$SPOKE_DR_CIDR" \
  --subnet-name "$WORKLOAD_SUBNET_NAME" \
  --subnet-prefixes "$WORKLOAD_DR_CIDR" \
  --tags lab=00 scope=spoke region=noe

az network vnet subnet create \
  --resource-group "$RG_SPOKE_DR" \
  --vnet-name "$SPOKE_VNET_DR" \
  --name "$APPSVC_SUBNET_NAME" \
  --address-prefixes "$APPSVC_DR_CIDR"

az network vnet subnet create \
  --resource-group "$RG_SPOKE_DR" \
  --vnet-name "$SPOKE_VNET_DR" \
  --name "$PE_SUBNET_NAME" \
  --address-prefixes "$PE_DR_CIDR" \
  --private-endpoint-network-policies Disabled
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet create `
  --resource-group $RG_SPOKE_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --location $PRIMARY_REGION `
  --address-prefixes $SPOKE_PRIMARY_CIDR `
  --subnet-name $WORKLOAD_SUBNET_NAME `
  --subnet-prefixes $WORKLOAD_PRIMARY_CIDR `
  --tags lab=00 scope=spoke region=swc

az network vnet subnet create `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $APPSVC_SUBNET_NAME `
  --address-prefixes $APPSVC_PRIMARY_CIDR

az network vnet subnet create `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PE_SUBNET_NAME `
  --address-prefixes $PE_PRIMARY_CIDR `
  --private-endpoint-network-policies Disabled

az network vnet create `
  --resource-group $RG_SPOKE_DR `
  --name $SPOKE_VNET_DR `
  --location $DR_REGION `
  --address-prefixes $SPOKE_DR_CIDR `
  --subnet-name $WORKLOAD_SUBNET_NAME `
  --subnet-prefixes $WORKLOAD_DR_CIDR `
  --tags lab=00 scope=spoke region=noe

az network vnet subnet create `
  --resource-group $RG_SPOKE_DR `
  --vnet-name $SPOKE_VNET_DR `
  --name $APPSVC_SUBNET_NAME `
  --address-prefixes $APPSVC_DR_CIDR

az network vnet subnet create `
  --resource-group $RG_SPOKE_DR `
  --vnet-name $SPOKE_VNET_DR `
  --name $PE_SUBNET_NAME `
  --address-prefixes $PE_DR_CIDR `
  --private-endpoint-network-policies Disabled
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-spoke-swc`, create `vnet-spoke-swc` in **Sweden Central** with address space `10.10.4.0/22`.
2. Add:
   - `snet-workload` → `10.10.4.0/24`
   - `snet-appsvc-integration` → `10.10.5.0/26`
   - `snet-private-endpoints` → `10.10.5.64/26`
3. On `snet-private-endpoints`, disable **Private endpoint network policies**.
4. Repeat the same pattern in `rg-spoke-noe` using `vnet-spoke-noe` and these prefixes:
   - `snet-workload` → `10.20.4.0/24`
   - `snet-appsvc-integration` → `10.20.5.0/26`
   - `snet-private-endpoints` → `10.20.5.64/26`

  </div>
</div>

<div class="lab-note">
<strong>Keep the spoke clean:</strong> Do not place compute in <code>snet-private-endpoints</code>. Save it for Private Link endpoints only. Also avoid delegating <code>snet-appsvc-integration</code> in Lab 0; a later lab can do that when it actually needs App Service or Functions integration.
</div>

---

## Step 6 — Peer Each Hub to Its Regional Spoke

Hub-and-spoke peering gives the spoke access to the shared controls in the hub without flattening both VNets into one address space.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
HUB_VNET_PRIMARY_ID=$(az network vnet show --resource-group "$RG_HUB_PRIMARY" --name "$HUB_VNET_PRIMARY" --query id --output tsv)
SPOKE_VNET_PRIMARY_ID=$(az network vnet show --resource-group "$RG_SPOKE_PRIMARY" --name "$SPOKE_VNET_PRIMARY" --query id --output tsv)

HUB_VNET_DR_ID=$(az network vnet show --resource-group "$RG_HUB_DR" --name "$HUB_VNET_DR" --query id --output tsv)
SPOKE_VNET_DR_ID=$(az network vnet show --resource-group "$RG_SPOKE_DR" --name "$SPOKE_VNET_DR" --query id --output tsv)

az network vnet peering create \
  --resource-group "$RG_HUB_PRIMARY" \
  --vnet-name "$HUB_VNET_PRIMARY" \
  --name "peer-hub-to-spoke" \
  --remote-vnet "$SPOKE_VNET_PRIMARY_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic

az network vnet peering create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "peer-spoke-to-hub" \
  --remote-vnet "$HUB_VNET_PRIMARY_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic

az network vnet peering create \
  --resource-group "$RG_HUB_DR" \
  --vnet-name "$HUB_VNET_DR" \
  --name "peer-hub-to-spoke" \
  --remote-vnet "$SPOKE_VNET_DR_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic

az network vnet peering create \
  --resource-group "$RG_SPOKE_DR" \
  --vnet-name "$SPOKE_VNET_DR" \
  --name "peer-spoke-to-hub" \
  --remote-vnet "$HUB_VNET_DR_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$HUB_VNET_PRIMARY_ID = az network vnet show --resource-group $RG_HUB_PRIMARY --name $HUB_VNET_PRIMARY --query id --output tsv
$SPOKE_VNET_PRIMARY_ID = az network vnet show --resource-group $RG_SPOKE_PRIMARY --name $SPOKE_VNET_PRIMARY --query id --output tsv

$HUB_VNET_DR_ID = az network vnet show --resource-group $RG_HUB_DR --name $HUB_VNET_DR --query id --output tsv
$SPOKE_VNET_DR_ID = az network vnet show --resource-group $RG_SPOKE_DR --name $SPOKE_VNET_DR --query id --output tsv

az network vnet peering create `
  --resource-group $RG_HUB_PRIMARY `
  --vnet-name $HUB_VNET_PRIMARY `
  --name "peer-hub-to-spoke" `
  --remote-vnet $SPOKE_VNET_PRIMARY_ID `
  --allow-vnet-access `
  --allow-forwarded-traffic

az network vnet peering create `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name "peer-spoke-to-hub" `
  --remote-vnet $HUB_VNET_PRIMARY_ID `
  --allow-vnet-access `
  --allow-forwarded-traffic

az network vnet peering create `
  --resource-group $RG_HUB_DR `
  --vnet-name $HUB_VNET_DR `
  --name "peer-hub-to-spoke" `
  --remote-vnet $SPOKE_VNET_DR_ID `
  --allow-vnet-access `
  --allow-forwarded-traffic

az network vnet peering create `
  --resource-group $RG_SPOKE_DR `
  --vnet-name $SPOKE_VNET_DR `
  --name "peer-spoke-to-hub" `
  --remote-vnet $HUB_VNET_DR_ID `
  --allow-vnet-access `
  --allow-forwarded-traffic
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `vnet-hub-swc` and add a peering named `peer-hub-to-spoke` to `vnet-spoke-swc`.
2. Open `vnet-spoke-swc` and add a return peering named `peer-spoke-to-hub` to `vnet-hub-swc`.
3. In both peerings, allow **virtual network access** and **forwarded traffic**.
4. Repeat the same two-way peering in Norway East between `vnet-hub-noe` and `vnet-spoke-noe`.

  </div>
</div>

<div class="lab-note">
<strong>Design choice:</strong> This lab does <em>not</em> enable gateway transit or create cross-region peering. Each region stays independent, which matches the “regional stamp” approach from the AKS multi-region guidance.
</div>

---

## Step 7 — Create Azure Firewall Policies, Public IPs, and Firewalls in Both Hubs

This step establishes the regional security appliances. The policies are intentionally minimal so later `B` variants can add only the allow rules they actually need.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network firewall policy create \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$FW_POLICY_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --sku Standard \
  --threat-intel-mode Alert

az network public-ip create \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$FIREWALL_PIP_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --sku Standard \
  --allocation-method Static \
  --tags lab=00 role=firewall-pip region=swc

az network firewall create \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$FIREWALL_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --sku AZFW_VNet \
  --tier Standard \
  --vnet-name "$HUB_VNET_PRIMARY" \
  --public-ip "$FIREWALL_PIP_PRIMARY" \
  --firewall-policy "$FW_POLICY_PRIMARY" \
  --conf-name "fw-ipconfig" \
  --tags lab=00 role=hub-firewall region=swc

az network firewall policy create \
  --resource-group "$RG_HUB_DR" \
  --name "$FW_POLICY_DR" \
  --location "$DR_REGION" \
  --sku Standard \
  --threat-intel-mode Alert

az network public-ip create \
  --resource-group "$RG_HUB_DR" \
  --name "$FIREWALL_PIP_DR" \
  --location "$DR_REGION" \
  --sku Standard \
  --allocation-method Static \
  --tags lab=00 role=firewall-pip region=noe

az network firewall create \
  --resource-group "$RG_HUB_DR" \
  --name "$FIREWALL_DR" \
  --location "$DR_REGION" \
  --sku AZFW_VNet \
  --tier Standard \
  --vnet-name "$HUB_VNET_DR" \
  --public-ip "$FIREWALL_PIP_DR" \
  --firewall-policy "$FW_POLICY_DR" \
  --conf-name "fw-ipconfig" \
  --tags lab=00 role=hub-firewall region=noe
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network firewall policy create `
  --resource-group $RG_HUB_PRIMARY `
  --name $FW_POLICY_PRIMARY `
  --location $PRIMARY_REGION `
  --sku Standard `
  --threat-intel-mode Alert

az network public-ip create `
  --resource-group $RG_HUB_PRIMARY `
  --name $FIREWALL_PIP_PRIMARY `
  --location $PRIMARY_REGION `
  --sku Standard `
  --allocation-method Static `
  --tags lab=00 role=firewall-pip region=swc

az network firewall create `
  --resource-group $RG_HUB_PRIMARY `
  --name $FIREWALL_PRIMARY `
  --location $PRIMARY_REGION `
  --sku AZFW_VNet `
  --tier Standard `
  --vnet-name $HUB_VNET_PRIMARY `
  --public-ip $FIREWALL_PIP_PRIMARY `
  --firewall-policy $FW_POLICY_PRIMARY `
  --conf-name "fw-ipconfig" `
  --tags lab=00 role=hub-firewall region=swc

az network firewall policy create `
  --resource-group $RG_HUB_DR `
  --name $FW_POLICY_DR `
  --location $DR_REGION `
  --sku Standard `
  --threat-intel-mode Alert

az network public-ip create `
  --resource-group $RG_HUB_DR `
  --name $FIREWALL_PIP_DR `
  --location $DR_REGION `
  --sku Standard `
  --allocation-method Static `
  --tags lab=00 role=firewall-pip region=noe

az network firewall create `
  --resource-group $RG_HUB_DR `
  --name $FIREWALL_DR `
  --location $DR_REGION `
  --sku AZFW_VNet `
  --tier Standard `
  --vnet-name $HUB_VNET_DR `
  --public-ip $FIREWALL_PIP_DR `
  --firewall-policy $FW_POLICY_DR `
  --conf-name "fw-ipconfig" `
  --tags lab=00 role=hub-firewall region=noe
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-hub-swc`, create an Azure Firewall Policy named `afwp-hub-swc` with **Standard** SKU and **Threat intelligence mode = Alert**.
2. Create a **Standard / Static** public IP named `pip-afw-swc`.
3. Create an Azure Firewall named `afw-hub-swc`:
   - Region: **Sweden Central**
   - Virtual network: `vnet-hub-swc`
   - Subnet: `AzureFirewallSubnet`
   - Public IP: `pip-afw-swc`
   - Firewall policy: `afwp-hub-swc`
4. Repeat the same pattern in `rg-hub-noe` using `afwp-hub-noe`, `pip-afw-noe`, and `afw-hub-noe`.

  </div>
</div>

<div class="lab-note">
<strong>Provisioning time:</strong> Azure Firewall can take several minutes per region. That delay is normal and is one reason this lab is positioned as an optional prerequisite rather than something every later lab repeats.
</div>

---

## Step 8 — Create Azure Bastion in Both Hubs

Bastion gives later private-only labs a standard admin path without exposing management ports directly to the internet.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network public-ip create \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$BASTION_PIP_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --sku Standard \
  --allocation-method Static \
  --tags lab=00 role=bastion-pip region=swc

az network bastion create \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$BASTION_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --vnet-name "$HUB_VNET_PRIMARY" \
  --public-ip-address "$BASTION_PIP_PRIMARY" \
  --sku Standard \
  --tags lab=00 role=bastion region=swc

az network public-ip create \
  --resource-group "$RG_HUB_DR" \
  --name "$BASTION_PIP_DR" \
  --location "$DR_REGION" \
  --sku Standard \
  --allocation-method Static \
  --tags lab=00 role=bastion-pip region=noe

az network bastion create \
  --resource-group "$RG_HUB_DR" \
  --name "$BASTION_DR" \
  --location "$DR_REGION" \
  --vnet-name "$HUB_VNET_DR" \
  --public-ip-address "$BASTION_PIP_DR" \
  --sku Standard \
  --tags lab=00 role=bastion region=noe
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network public-ip create `
  --resource-group $RG_HUB_PRIMARY `
  --name $BASTION_PIP_PRIMARY `
  --location $PRIMARY_REGION `
  --sku Standard `
  --allocation-method Static `
  --tags lab=00 role=bastion-pip region=swc

az network bastion create `
  --resource-group $RG_HUB_PRIMARY `
  --name $BASTION_PRIMARY `
  --location $PRIMARY_REGION `
  --vnet-name $HUB_VNET_PRIMARY `
  --public-ip-address $BASTION_PIP_PRIMARY `
  --sku Standard `
  --tags lab=00 role=bastion region=swc

az network public-ip create `
  --resource-group $RG_HUB_DR `
  --name $BASTION_PIP_DR `
  --location $DR_REGION `
  --sku Standard `
  --allocation-method Static `
  --tags lab=00 role=bastion-pip region=noe

az network bastion create `
  --resource-group $RG_HUB_DR `
  --name $BASTION_DR `
  --location $DR_REGION `
  --vnet-name $HUB_VNET_DR `
  --public-ip-address $BASTION_PIP_DR `
  --sku Standard `
  --tags lab=00 role=bastion region=noe
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-hub-swc`, create a **Standard / Static** public IP named `pip-bas-swc`.
2. Create an Azure Bastion host named `bas-hub-swc`:
   - Region: **Sweden Central**
   - Virtual network: `vnet-hub-swc`
   - Subnet: `AzureBastionSubnet`
   - Public IP: `pip-bas-swc`
3. Repeat the same pattern in Norway East with `pip-bas-noe` and `bas-hub-noe`.

  </div>
</div>

---

## Step 9 — Create Staged Route Tables That Point to Each Regional Firewall

These route tables are created now so later `B` variants have consistent names to attach when they are ready to force-tunnel traffic through the hub firewall.

<div class="lab-note">
<strong>Why staged instead of attached?</strong> A brand-new Azure Firewall denies traffic until you add explicit allow rules. Lab 0 creates the route tables and default routes now, but leaves them <strong>unattached</strong> so later labs can add service-specific firewall rules and private DNS before enforcing the route.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
FIREWALL_PRIVATE_IP_PRIMARY=$(az network firewall show \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$FIREWALL_PRIMARY" \
  --query "ipConfigurations[0].privateIPAddress" \
  --output tsv)

FIREWALL_PRIVATE_IP_DR=$(az network firewall show \
  --resource-group "$RG_HUB_DR" \
  --name "$FIREWALL_DR" \
  --query "ipConfigurations[0].privateIPAddress" \
  --output tsv)

az network route-table create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --name "$ROUTE_TABLE_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --tags lab=00 role=staged-egress region=swc

az network route-table route create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --route-table-name "$ROUTE_TABLE_PRIMARY" \
  --name "default-to-regional-firewall" \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address "$FIREWALL_PRIVATE_IP_PRIMARY"

az network route-table create \
  --resource-group "$RG_SPOKE_DR" \
  --name "$ROUTE_TABLE_DR" \
  --location "$DR_REGION" \
  --tags lab=00 role=staged-egress region=noe

az network route-table route create \
  --resource-group "$RG_SPOKE_DR" \
  --route-table-name "$ROUTE_TABLE_DR" \
  --name "default-to-regional-firewall" \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address "$FIREWALL_PRIVATE_IP_DR"

echo "Primary firewall private IP: $FIREWALL_PRIVATE_IP_PRIMARY"
echo "DR firewall private IP     : $FIREWALL_PRIVATE_IP_DR"
echo "Route tables created but intentionally not attached to subnets yet."
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$FIREWALL_PRIVATE_IP_PRIMARY = az network firewall show `
  --resource-group $RG_HUB_PRIMARY `
  --name $FIREWALL_PRIMARY `
  --query "ipConfigurations[0].privateIPAddress" `
  --output tsv

$FIREWALL_PRIVATE_IP_DR = az network firewall show `
  --resource-group $RG_HUB_DR `
  --name $FIREWALL_DR `
  --query "ipConfigurations[0].privateIPAddress" `
  --output tsv

az network route-table create `
  --resource-group $RG_SPOKE_PRIMARY `
  --name $ROUTE_TABLE_PRIMARY `
  --location $PRIMARY_REGION `
  --tags lab=00 role=staged-egress region=swc

az network route-table route create `
  --resource-group $RG_SPOKE_PRIMARY `
  --route-table-name $ROUTE_TABLE_PRIMARY `
  --name "default-to-regional-firewall" `
  --address-prefix "0.0.0.0/0" `
  --next-hop-type VirtualAppliance `
  --next-hop-ip-address $FIREWALL_PRIVATE_IP_PRIMARY

az network route-table create `
  --resource-group $RG_SPOKE_DR `
  --name $ROUTE_TABLE_DR `
  --location $DR_REGION `
  --tags lab=00 role=staged-egress region=noe

az network route-table route create `
  --resource-group $RG_SPOKE_DR `
  --route-table-name $ROUTE_TABLE_DR `
  --name "default-to-regional-firewall" `
  --address-prefix "0.0.0.0/0" `
  --next-hop-type VirtualAppliance `
  --next-hop-ip-address $FIREWALL_PRIVATE_IP_DR

Write-Host "Primary firewall private IP: $FIREWALL_PRIVATE_IP_PRIMARY"
Write-Host "DR firewall private IP     : $FIREWALL_PRIVATE_IP_DR"
Write-Host "Route tables created but intentionally not attached to subnets yet."
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `afw-hub-swc` and note its **private IP address** from the overview blade.
2. In `rg-spoke-swc`, create a route table named `rt-spoke-egress-swc`.
3. Add a route named `default-to-regional-firewall` with:
   - Address prefix: `0.0.0.0/0`
   - Next hop type: `Virtual appliance`
   - Next hop address: the private IP from `afw-hub-swc`
4. Repeat the same process in Norway East with `afw-hub-noe` and `rt-spoke-egress-noe`.
5. Do **not** associate either route table to a subnet yet.

  </div>
</div>

---

## Step 10 — Validate the Foundation

Before you hand this network off to a later `B` variant, confirm the subnets, peerings, firewalls, Bastions, and staged route tables all exist in both regions.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "=== Hub subnets ==="
az network vnet subnet list \
  --resource-group "$RG_HUB_PRIMARY" \
  --vnet-name "$HUB_VNET_PRIMARY" \
  --query "[].{Name:name, Prefix:addressPrefix}" \
  --output table

az network vnet subnet list \
  --resource-group "$RG_HUB_DR" \
  --vnet-name "$HUB_VNET_DR" \
  --query "[].{Name:name, Prefix:addressPrefix}" \
  --output table

echo "=== Spoke subnets ==="
az network vnet subnet list \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --query "[].{Name:name, Prefix:addressPrefix, PEPolicies:privateEndpointNetworkPolicies}" \
  --output table

az network vnet subnet list \
  --resource-group "$RG_SPOKE_DR" \
  --vnet-name "$SPOKE_VNET_DR" \
  --query "[].{Name:name, Prefix:addressPrefix, PEPolicies:privateEndpointNetworkPolicies}" \
  --output table

echo "=== Peerings ==="
az network vnet peering list \
  --resource-group "$RG_HUB_PRIMARY" \
  --vnet-name "$HUB_VNET_PRIMARY" \
  --query "[].{Name:name, State:peeringState}" \
  --output table

az network vnet peering list \
  --resource-group "$RG_HUB_DR" \
  --vnet-name "$HUB_VNET_DR" \
  --query "[].{Name:name, State:peeringState}" \
  --output table

echo "=== Firewalls ==="
az network firewall show \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$FIREWALL_PRIMARY" \
  --query "{Name:name, PrivateIP:ipConfigurations[0].privateIPAddress, State:provisioningState}" \
  --output table

az network firewall show \
  --resource-group "$RG_HUB_DR" \
  --name "$FIREWALL_DR" \
  --query "{Name:name, PrivateIP:ipConfigurations[0].privateIPAddress, State:provisioningState}" \
  --output table

echo "=== Bastions ==="
az network bastion show \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$BASTION_PRIMARY" \
  --query "{Name:name, SKU:sku.name, State:provisioningState}" \
  --output table

az network bastion show \
  --resource-group "$RG_HUB_DR" \
  --name "$BASTION_DR" \
  --query "{Name:name, SKU:sku.name, State:provisioningState}" \
  --output table

echo "=== Staged routes ==="
az network route-table route list \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --route-table-name "$ROUTE_TABLE_PRIMARY" \
  --query "[].{Name:name, Prefix:addressPrefix, NextHop:nextHopIpAddress}" \
  --output table

az network route-table route list \
  --resource-group "$RG_SPOKE_DR" \
  --route-table-name "$ROUTE_TABLE_DR" \
  --query "[].{Name:name, Prefix:addressPrefix, NextHop:nextHopIpAddress}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "=== Hub subnets ==="
az network vnet subnet list `
  --resource-group $RG_HUB_PRIMARY `
  --vnet-name $HUB_VNET_PRIMARY `
  --query "[].{Name:name, Prefix:addressPrefix}" `
  --output table

az network vnet subnet list `
  --resource-group $RG_HUB_DR `
  --vnet-name $HUB_VNET_DR `
  --query "[].{Name:name, Prefix:addressPrefix}" `
  --output table

Write-Host "=== Spoke subnets ==="
az network vnet subnet list `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --query "[].{Name:name, Prefix:addressPrefix, PEPolicies:privateEndpointNetworkPolicies}" `
  --output table

az network vnet subnet list `
  --resource-group $RG_SPOKE_DR `
  --vnet-name $SPOKE_VNET_DR `
  --query "[].{Name:name, Prefix:addressPrefix, PEPolicies:privateEndpointNetworkPolicies}" `
  --output table

Write-Host "=== Peerings ==="
az network vnet peering list `
  --resource-group $RG_HUB_PRIMARY `
  --vnet-name $HUB_VNET_PRIMARY `
  --query "[].{Name:name, State:peeringState}" `
  --output table

az network vnet peering list `
  --resource-group $RG_HUB_DR `
  --vnet-name $HUB_VNET_DR `
  --query "[].{Name:name, State:peeringState}" `
  --output table

Write-Host "=== Firewalls ==="
az network firewall show `
  --resource-group $RG_HUB_PRIMARY `
  --name $FIREWALL_PRIMARY `
  --query "{Name:name, PrivateIP:ipConfigurations[0].privateIPAddress, State:provisioningState}" `
  --output table

az network firewall show `
  --resource-group $RG_HUB_DR `
  --name $FIREWALL_DR `
  --query "{Name:name, PrivateIP:ipConfigurations[0].privateIPAddress, State:provisioningState}" `
  --output table

Write-Host "=== Bastions ==="
az network bastion show `
  --resource-group $RG_HUB_PRIMARY `
  --name $BASTION_PRIMARY `
  --query "{Name:name, SKU:sku.name, State:provisioningState}" `
  --output table

az network bastion show `
  --resource-group $RG_HUB_DR `
  --name $BASTION_DR `
  --query "{Name:name, SKU:sku.name, State:provisioningState}" `
  --output table

Write-Host "=== Staged routes ==="
az network route-table route list `
  --resource-group $RG_SPOKE_PRIMARY `
  --route-table-name $ROUTE_TABLE_PRIMARY `
  --query "[].{Name:name, Prefix:addressPrefix, NextHop:nextHopIpAddress}" `
  --output table

az network route-table route list `
  --resource-group $RG_SPOKE_DR `
  --route-table-name $ROUTE_TABLE_DR `
  --query "[].{Name:name, Prefix:addressPrefix, NextHop:nextHopIpAddress}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm all four resource groups exist.
2. Open each hub VNet and verify `AzureFirewallSubnet`, `AzureBastionSubnet`, and `snet-hub-shared`.
3. Open each spoke VNet and verify `snet-workload`, `snet-appsvc-integration`, and `snet-private-endpoints`.
4. Check the peering status between hub and spoke in both regions.
5. Open each Azure Firewall and confirm it has a private IP and a healthy provisioning state.
6. Open each Bastion host and confirm it is provisioned successfully.
7. Open `rt-spoke-egress-swc` and `rt-spoke-egress-noe` and confirm each contains a default route to its regional firewall private IP, with no subnet associations yet.

  </div>
</div>

---

## Validation Checklist

- [ ] `rg-hub-swc`, `rg-spoke-swc`, `rg-hub-noe`, and `rg-spoke-noe` exist
- [ ] `vnet-hub-swc` and `vnet-hub-noe` each contain `AzureFirewallSubnet`, `AzureBastionSubnet`, and `snet-hub-shared`
- [ ] `vnet-spoke-swc` and `vnet-spoke-noe` each contain `snet-workload`, `snet-appsvc-integration`, and `snet-private-endpoints`
- [ ] `snet-private-endpoints` has private endpoint network policies disabled in both regions
- [ ] Hub-to-spoke peering exists in both directions in Sweden Central and Norway East
- [ ] `afw-hub-swc` and `afw-hub-noe` are provisioned successfully
- [ ] `bas-hub-swc` and `bas-hub-noe` are provisioned successfully
- [ ] `rt-spoke-egress-swc` and `rt-spoke-egress-noe` point to the correct regional firewall private IPs
- [ ] The route tables are still **unattached**, ready for later `B` variants to use deliberately

---

## Cleanup

Delete the foundation when you are done, especially if you are not continuing immediately into a secure `B` variant. Firewall and Bastion charges continue until the resource groups are fully deleted.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name "$RG_HUB_PRIMARY"   --yes --no-wait
az group delete --name "$RG_SPOKE_PRIMARY" --yes --no-wait
az group delete --name "$RG_HUB_DR"        --yes --no-wait
az group delete --name "$RG_SPOKE_DR"      --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_HUB_PRIMARY   --yes --no-wait
az group delete --name $RG_SPOKE_PRIMARY --yes --no-wait
az group delete --name $RG_HUB_DR        --yes --no-wait
az group delete --name $RG_SPOKE_DR      --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Delete `rg-hub-swc`, `rg-spoke-swc`, `rg-hub-noe`, and `rg-spoke-noe`.
3. Wait for deletion to finish before assuming Firewall and Bastion billing has stopped.

  </div>
</div>

---

## Discussion & Next Steps

### What Later `B` Variants Should Assume

| Need | Recommended Lab 0 landing zone |
|---|---|
| **General compute or cluster subnet** | `vnet-spoke-swc/snet-workload` and `vnet-spoke-noe/snet-workload` |
| **App Service / Functions VNet integration** | `snet-appsvc-integration` in each spoke |
| **Private endpoints** | `snet-private-endpoints` in each spoke |
| **Shared network controls** | `afw-hub-swc`, `afw-hub-noe`, `bas-hub-swc`, `bas-hub-noe` |
| **Future forced tunneling** | `rt-spoke-egress-swc` and `rt-spoke-egress-noe` after the later lab adds firewall rules |

### Intentionally Deferred to Later Labs

Lab 0 does **not** create these on purpose:

1. **Private DNS zones and links** — each service family brings its own zone names.
2. **Service-specific firewall allow rules** — Storage, SQL, Key Vault, ACR, Event Hubs, and other services all have different needs.
3. **Subnet delegations beyond the reusable baseline** — later labs can delegate or add subnets only when the target service requires it.
4. **Cross-region VNet peering** — the labs favor independent regional stamps with global failover, not a flat east-west network mesh.

### Why Bastion and Firewall Live in the Hub

The hub is the right place for **shared** controls that multiple workloads can reuse:

- **Azure Firewall** gives you one regional egress and inspection point instead of scattered per-workload controls.
- **Azure Bastion** gives you browser-based or tunneled management access without exposing RDP/SSH directly.
- The **spoke** stays focused on workloads, private endpoints, and service-specific subnet choices.

---

## Useful Links

- [AKS multi-region architecture reference](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-multi-region/aks-multi-cluster)
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/hub-spoke)
- [Azure Firewall overview](https://learn.microsoft.com/en-us/azure/firewall/overview)
- [Azure Bastion overview](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
- [Virtual network peering overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
- [Private Endpoint subnet policy guidance](https://learn.microsoft.com/en-us/azure/private-link/disable-private-endpoint-network-policy)

---

[← Back to Index](../index.md)
