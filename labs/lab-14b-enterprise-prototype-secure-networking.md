---
layout: default
title: "Lab 14-b: Integrated Enterprise App – Secure Networking"
---

[← Lab 14-a — Enterprise Prototype](lab-14a-enterprise-prototype.md) | [Lab 14-b — Secure Networking](lab-14b-enterprise-prototype-secure-networking.md)

# Lab 14-b: Integrated Enterprise App – Secure Networking

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

> **Objective:** Deploy the integrated multi-region enterprise prototype into the secure landing zone from Lab 0, place workloads in the spokes, add private endpoints in the reusable private-endpoint subnets, and validate failover without flattening the regional network stamps.

<div class="lab-note">
<strong>Lab 0 required:</strong> This secure <code>B</code> variant assumes <a href="lab-00-security-prereqs.md">Lab 0</a> is already complete and that the fixed regional names from that lab still exist: <code>rg-hub-swc</code>, <code>rg-spoke-swc</code>, <code>rg-hub-noe</code>, <code>rg-spoke-noe</code>, the matching hub and spoke VNets, <code>snet-workload</code>, <code>snet-appsvc-integration</code>, <code>snet-private-endpoints</code>, Azure Firewall in both hubs, and the staged spoke route tables.
</div>

<div class="lab-note">
<strong>Variant note:</strong> This <code>B</code> path keeps the same capstone workflow as <a href="lab-14a-enterprise-prototype.md">Lab 14-a</a>, but adds hub-and-spoke networking, private endpoints, and spoke-based workload placement. The client edge can still stay public while the supported app dependencies move private behind the regional spokes.
</div>

> **⏱ Estimated time:** 2.5–3.5 hours

---

## Why This Secure Variant Exists

Lab 14-a proves the original capstone workflow: one topology manifest, one three-step deployment model, and one coordinated failover exercise across multiple Azure services. Lab 14-b keeps that capstone goal, but runs it inside a reusable **hub-and-spoke landing zone** so you can practice the same orchestration with stronger network boundaries.

This secure variant assumes the regional foundation from Lab 0 and adds the service-specific controls that Lab 0 intentionally deferred:

- **Spoke-based workload placement** so compute stays in `vnet-spoke-swc` and `vnet-spoke-noe`, not in the hubs
- **Private endpoints** in `snet-private-endpoints` for the platform services that support Private Link
- **App Service / Functions integration** through `snet-appsvc-integration` when the sample uses platform-managed compute
- **Private DNS zones and links** so workloads resolve service endpoints to private IPs inside the spokes
- **Shared regional controls** via `afw-hub-swc`, `afw-hub-noe`, `bas-hub-swc`, and `bas-hub-noe`
- **Independent regional stamps** with no cross-region VNet peering; service-native replication still provides the multi-region behavior

The result is a capstone that exercises both **resiliency** and **network design discipline**: each region is self-contained, the global edge handles user routing, and the services behind it rely on private connectivity whenever the platform supports it.

---

## Architecture

The secure variant keeps the same multi-region application flow as Lab 14-a, but the workloads and private endpoints now land inside the pre-created spokes from Lab 0.

```text
┌───────────────────────────────────────────────────────────────────────────────┐
│                Azure Front Door / Global Edge / DNS Layer                     │
│       Public client entry point; prefer private origins when supported        │
└──────────────┬─────────────────────────────────────────────┬──────────────────┘
               │                                             │
┌──────────────▼──────────────┐               ┌──────────────▼──────────────┐
│ Sweden Central secure stamp │               │ Norway East secure stamp    │
│                              │               │                              │
│ rg-hub-swc                   │               │ rg-hub-noe                   │
│  vnet-hub-swc                │               │  vnet-hub-noe                │
│   ├─ afw-hub-swc             │               │   ├─ afw-hub-noe             │
│   └─ bas-hub-swc             │               │   └─ bas-hub-noe             │
│           ▲                  │               │           ▲                  │
│           │ hub-spoke peering│               │           │ hub-spoke peering│
│           ▼                  │               │           ▼                  │
│ rg-spoke-swc                 │               │ rg-spoke-noe                 │
│  vnet-spoke-swc              │               │  vnet-spoke-noe              │
│   ├─ snet-workload           │               │   ├─ snet-workload           │
│   ├─ snet-appsvc-integration │               │   ├─ snet-appsvc-integration │
│   └─ snet-private-endpoints  │               │   └─ snet-private-endpoints  │
│                              │               │                              │
│ workload RGs                 │               │ workload RGs                 │
│  ├─ App / AKS / Functions    │               │  ├─ App / AKS / Functions    │
│  ├─ SQL / Cosmos / Storage   │◄── replication│  ├─ SQL / Cosmos / Storage   │
│  ├─ Service Bus / Event Hubs │◄── and alias ─│  ├─ Service Bus / Event Hubs │
│  └─ Key Vault / ACR          │◄── failover ──│  └─ Key Vault / ACR          │
└──────────────────────────────┘               └──────────────────────────────┘
```

Private endpoints are **regional** interfaces into regional services. The cross-region behavior still comes from each service's native resiliency mechanism — failover groups, geo-DR aliases, geo-replication, or object replication — rather than from east-west VNet connectivity.

### What This Lab Reuses from Lab 0

| Need | Canonical Lab 0 landing zone |
|---|---|
| **General compute or cluster subnet** | `vnet-spoke-swc/snet-workload` and `vnet-spoke-noe/snet-workload` |
| **App Service / Functions VNet integration** | `snet-appsvc-integration` in each spoke |
| **Private endpoints** | `snet-private-endpoints` in each spoke |
| **Shared network controls** | `afw-hub-swc`, `afw-hub-noe`, `bas-hub-swc`, `bas-hub-noe` |
| **Future forced tunneling** | `rt-spoke-egress-swc` and `rt-spoke-egress-noe` |

---

## Prerequisites

### Required Foundation from Lab 0

Before you begin, verify that Lab 0 left you with these reusable assets:

- `rg-hub-swc`, `rg-spoke-swc`, `rg-hub-noe`, and `rg-spoke-noe`
- `vnet-hub-swc`, `vnet-spoke-swc`, `vnet-hub-noe`, and `vnet-spoke-noe`
- Spoke subnets `snet-workload`, `snet-appsvc-integration`, and `snet-private-endpoints`
- Azure Firewalls `afw-hub-swc` and `afw-hub-noe`
- Azure Bastions `bas-hub-swc` and `bas-hub-noe`
- Staged route tables `rt-spoke-egress-swc` and `rt-spoke-egress-noe`

### Tools Required

| Tool | Version | Required? | Notes |
|------|---------|-----------|-------|
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | 2.60+ | ✅ Yes | Needed for network, PaaS, and deployment orchestration |
| [Azure Developer CLI (`azd`)](https://learn.microsoft.com/azure/developer/azure-developer-cli/) | Latest | ✅ Yes | Used by parts of the prototype workflow |
| [PowerShell 7+](https://learn.microsoft.com/powershell/) | 7.0+ | ⬜ Optional | Required only if you follow the PowerShell path |
| [jq](https://jqlang.github.io/jq/) | 1.6+ | ✅ Yes | Helpful for topology inspection and API output |
| [Git](https://git-scm.com/) | 2.x | ✅ Yes | Required to clone the prototype repository |

> **PowerShell note:** Several orchestration entry points in the prototype repository are Bash scripts. The PowerShell tabs keep you in PowerShell but call those same Bash entry points through `bash`.

### Azure Requirements

- Contributor or Owner rights in the subscription(s) used by the prototype
- Permission to create **private endpoints**, **private DNS zones**, VNet links, and any service-specific private-link approvals required by your environment
- Capacity in **Sweden Central** and **Norway East** (or the region pair you deliberately choose)
- Budget for the multi-region app itself **plus** the Lab 0 secure foundation if you keep the hubs running
- A clear plan for outbound traffic if you decide to associate the staged route tables and force spoke egress through the hub firewalls

---

## How These Tabs Work

This page uses the same interaction pattern as the rest of the lab series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behavior used in the existing labs.

<div class="lab-note">
<strong>Secure-variant note:</strong> The deployment flow is still the same three-step prototype model. The difference is that you pre-stage network dependencies — private DNS, subnet mappings, and optional forced-tunneling decisions — before you enable the secondary region.
</div>

---

## Step-by-Step Instructions

### 1. Validate the Lab 0 Foundation

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

RG_HUB_PRIMARY="rg-hub-swc"
RG_SPOKE_PRIMARY="rg-spoke-swc"
RG_HUB_SECONDARY="rg-hub-noe"
RG_SPOKE_SECONDARY="rg-spoke-noe"

SPOKE_VNET_PRIMARY="vnet-spoke-swc"
WORKLOAD_SUBNET="snet-workload"
APPSVC_SUBNET="snet-appsvc-integration"
PE_SUBNET="snet-private-endpoints"

FIREWALL_PRIMARY="afw-hub-swc"
BASTION_PRIMARY="bas-hub-swc"
ROUTE_TABLE_PRIMARY="rt-spoke-egress-swc"

for rg in "$RG_HUB_PRIMARY" "$RG_SPOKE_PRIMARY" "$RG_HUB_SECONDARY" "$RG_SPOKE_SECONDARY"; do
  az group show --name "$rg" --query "{name:name,location:location}" -o table
done

for subnet in "$WORKLOAD_SUBNET" "$APPSVC_SUBNET" "$PE_SUBNET"; do
  az network vnet subnet show \
    --resource-group "$RG_SPOKE_PRIMARY" \
    --vnet-name "$SPOKE_VNET_PRIMARY" \
    --name "$subnet" \
    --query "{name:name,prefix:addressPrefix,privateEndpointNetworkPolicies:privateEndpointNetworkPolicies}" \
    -o table
done

az network firewall show -g "$RG_HUB_PRIMARY" -n "$FIREWALL_PRIMARY" --query "{name:name,state:provisioningState,privateIp:ipConfigurations[0].privateIPAddress}" -o json
az network bastion show -g "$RG_HUB_PRIMARY" -n "$BASTION_PRIMARY" --query "{name:name,state:provisioningState}" -o table
az network route-table show -g "$RG_SPOKE_PRIMARY" -n "$ROUTE_TABLE_PRIMARY" --query "{name:name,routes:routes[].{name:name,prefix:addressPrefix,nextHop:nextHopIpAddress}}" -o json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RG_HUB_PRIMARY = "rg-hub-swc"
$RG_SPOKE_PRIMARY = "rg-spoke-swc"
$RG_HUB_SECONDARY = "rg-hub-noe"
$RG_SPOKE_SECONDARY = "rg-spoke-noe"

$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$WORKLOAD_SUBNET = "snet-workload"
$APPSVC_SUBNET = "snet-appsvc-integration"
$PE_SUBNET = "snet-private-endpoints"

$FIREWALL_PRIMARY = "afw-hub-swc"
$BASTION_PRIMARY = "bas-hub-swc"
$ROUTE_TABLE_PRIMARY = "rt-spoke-egress-swc"

foreach ($rg in @($RG_HUB_PRIMARY, $RG_SPOKE_PRIMARY, $RG_HUB_SECONDARY, $RG_SPOKE_SECONDARY)) {
  az group show --name $rg --query "{name:name,location:location}" -o table
}

foreach ($subnet in @($WORKLOAD_SUBNET, $APPSVC_SUBNET, $PE_SUBNET)) {
  az network vnet subnet show `
    --resource-group $RG_SPOKE_PRIMARY `
    --vnet-name $SPOKE_VNET_PRIMARY `
    --name $subnet `
    --query "{name:name,prefix:addressPrefix,privateEndpointNetworkPolicies:privateEndpointNetworkPolicies}" `
    -o table
}

az network firewall show -g $RG_HUB_PRIMARY -n $FIREWALL_PRIMARY --query "{name:name,state:provisioningState,privateIp:ipConfigurations[0].privateIPAddress}" -o json
az network bastion show -g $RG_HUB_PRIMARY -n $BASTION_PRIMARY --query "{name:name,state:provisioningState}" -o table
az network route-table show -g $RG_SPOKE_PRIMARY -n $ROUTE_TABLE_PRIMARY --query "{name:name,routes:routes[].{name:name,prefix:addressPrefix,nextHop:nextHopIpAddress}}" -o json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups** and confirm the four Lab 0 groups still exist in the correct regions.
2. Open **vnet-spoke-swc** and **vnet-spoke-noe** and verify the reusable subnets are present.
3. Open **afw-hub-swc** / **afw-hub-noe** and **bas-hub-swc** / **bas-hub-noe** to confirm the shared controls are healthy.
4. Check that the staged route tables still exist, even if you have not associated them with the spoke subnets yet.

  </div>
</div>

Do not continue until the Lab 0 foundation is intact. This lab is designed to **reuse** the fixed names and subnets from Lab 0, not recreate them.

---

### 2. Clone the Prototype Repository

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
git clone https://github.com/prwani/multi-region-nonpaired-enterprise-prototype.git
cd multi-region-nonpaired-enterprise-prototype
ls -la
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
git clone https://github.com/prwani/multi-region-nonpaired-enterprise-prototype.git
Set-Location .\multi-region-nonpaired-enterprise-prototype
Get-ChildItem -Force
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the prototype repository in GitHub so you can inspect the README and docs while you work.
2. Use Azure Cloud Shell or your workstation to clone the repository.
3. Keep the repository open in an editor because you will modify `config/topology.json` and validate generated outputs throughout the lab.

  </div>
</div>

---

### 3. Configure the Topology Manifest for the Secure Variant

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cp config/topology.example.json config/topology.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Copy-Item ./config/topology.example.json ./config/topology.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `config/topology.example.json` in your editor.
2. Save a working copy as `config/topology.json`.
3. Keep the same two-region intent as Lab 14-a, but switch the secure-networking flags and network-placement inputs before you deploy.

  </div>
</div>

Use the secure variant to turn on private connectivity while keeping the same primary and secondary region pair:

```jsonc
{
  "$schema": "./topology.schema.json",
  "version": "1.0.0",
  "subscriptions": {
    "main": {
      "id": "<your-primary-subscription-id>",
      "name": "main-subscription"
    },
    "fabric": {
      "id": "<your-fabric-subscription-id-or-same-as-primary>",
      "name": "fabric-subscription"
    }
  },
  "primaryRegion": "swedencentral",
  "secondaryRegion": "norwayeast",
  "regionProfile": "./region-profiles/swedencentral-norwayeast.json",
  "featureFlags": {
    "enableCrossSubscription": false,
    "enablePrivateEndpoints": true,
    "enableCMK": false,
    "enableFabric": false,
    "enableActiveActive": false
  },
  "domains": {
    "app-workloads": {
      "subscription": "main",
      "description": "Application workload samples.",
      "samples": ["A-aks-store"]
    }
  },
  "sampleManifest": "./samples-manifest.json"
}
```

For the secure `B` variant, also set whichever **network placement** inputs your branch exposes so that:

- Primary compute uses `vnet-spoke-swc/snet-workload`
- Secondary compute uses `vnet-spoke-noe/snet-workload`
- App Service / Functions integration uses `snet-appsvc-integration`
- Private endpoints land in `snet-private-endpoints`
- Shared controls remain in the existing hubs (`rg-hub-swc`, `rg-hub-noe`)

<div class="lab-note">
<strong>Schema flexibility:</strong> The exact property names for existing-VNet reuse can differ across prototype branches. If your branch does not yet expose explicit subnet mapping fields, treat the bullets above as the target operating model and capture the network placement in the Bicep parameter files, environment variables, or deployment overrides your branch uses.
</div>

> **💡 Keep the responsibility split clean:** Lab 0 owns the shared network resources. The prototype still creates workload-specific application, data, and messaging resources as needed, but those resources should connect into the Lab 0 spokes rather than creating a parallel network of their own.

---

### 4. Create the Private DNS Zones and VNet Links

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
DNS_RG="rg-hub-swc"
SUB_ID=$(az account show --query id -o tsv)
PRIMARY_SPOKE_ID="/subscriptions/$SUB_ID/resourceGroups/rg-spoke-swc/providers/Microsoft.Network/virtualNetworks/vnet-spoke-swc"
SECONDARY_SPOKE_ID="/subscriptions/$SUB_ID/resourceGroups/rg-spoke-noe/providers/Microsoft.Network/virtualNetworks/vnet-spoke-noe"

for zone in \
  privatelink.database.windows.net \
  privatelink.documents.azure.com \
  privatelink.blob.core.windows.net \
  privatelink.vaultcore.azure.net \
  privatelink.servicebus.windows.net \
  privatelink.azurecr.io \
  privatelink.azurewebsites.net

do
  LINK_PREFIX=$(echo "$zone" | tr '.' '-')
  az network private-dns zone create -g "$DNS_RG" -n "$zone"
  az network private-dns link vnet create -g "$DNS_RG" -z "$zone" -n "${LINK_PREFIX}-swc" -v "$PRIMARY_SPOKE_ID" -e false
  az network private-dns link vnet create -g "$DNS_RG" -z "$zone" -n "${LINK_PREFIX}-noe" -v "$SECONDARY_SPOKE_ID" -e false
done

az network private-dns zone list -g "$DNS_RG" -o table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$DNS_RG = "rg-hub-swc"
$SUB_ID = az account show --query id -o tsv
$PRIMARY_SPOKE_ID = "/subscriptions/$SUB_ID/resourceGroups/rg-spoke-swc/providers/Microsoft.Network/virtualNetworks/vnet-spoke-swc"
$SECONDARY_SPOKE_ID = "/subscriptions/$SUB_ID/resourceGroups/rg-spoke-noe/providers/Microsoft.Network/virtualNetworks/vnet-spoke-noe"

$Zones = @(
  "privatelink.database.windows.net",
  "privatelink.documents.azure.com",
  "privatelink.blob.core.windows.net",
  "privatelink.vaultcore.azure.net",
  "privatelink.servicebus.windows.net",
  "privatelink.azurecr.io",
  "privatelink.azurewebsites.net"
)

foreach ($zone in $Zones) {
  $LinkPrefix = $zone -replace '\\.', '-'
  az network private-dns zone create -g $DNS_RG -n $zone
  az network private-dns link vnet create -g $DNS_RG -z $zone -n "$LinkPrefix-swc" -v $PRIMARY_SPOKE_ID -e false
  az network private-dns link vnet create -g $DNS_RG -z $zone -n "$LinkPrefix-noe" -v $SECONDARY_SPOKE_ID -e false
}

az network private-dns zone list -g $DNS_RG -o table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the private DNS zones service in the Azure portal.
2. Create the Private Link zones required by the services your topology enables.
3. Link each zone to both `vnet-spoke-swc` and `vnet-spoke-noe`.
4. If your branch automates zone creation, verify the resulting zones and links instead of recreating them manually.

  </div>
</div>

Start with these common zones and extend the list if your sample uses more storage subservices or additional private-link-enabled services:

| Service family | Common Private DNS zone |
|---|---|
| Azure SQL Database | `privatelink.database.windows.net` |
| Cosmos DB | `privatelink.documents.azure.com` |
| Blob Storage | `privatelink.blob.core.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| Service Bus / Event Hubs | `privatelink.servicebus.windows.net` |
| Azure Container Registry | `privatelink.azurecr.io` |
| App Service / Functions private endpoints | `privatelink.azurewebsites.net` |

> **💡 Zone scope:** A Private DNS zone is global. Storing it in `rg-hub-swc` is simply a convenient shared-home convention for this lab; the important part is that both spoke VNets are linked to it.

---

### 5. Review Egress and Route-Table Strategy

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network route-table show -g rg-spoke-swc -n rt-spoke-egress-swc --query "{name:name,routes:routes[].{name:name,prefix:addressPrefix,nextHop:nextHopIpAddress}}" -o json
az network route-table show -g rg-spoke-noe -n rt-spoke-egress-noe --query "{name:name,routes:routes[].{name:name,prefix:addressPrefix,nextHop:nextHopIpAddress}}" -o json
az network firewall show -g rg-hub-swc -n afw-hub-swc --query "{name:name,privateIp:ipConfigurations[0].privateIPAddress,state:provisioningState}" -o json
az network firewall show -g rg-hub-noe -n afw-hub-noe --query "{name:name,privateIp:ipConfigurations[0].privateIPAddress,state:provisioningState}" -o json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network route-table show -g rg-spoke-swc -n rt-spoke-egress-swc --query "{name:name,routes:routes[].{name:name,prefix:addressPrefix,nextHop:nextHopIpAddress}}" -o json
az network route-table show -g rg-spoke-noe -n rt-spoke-egress-noe --query "{name:name,routes:routes[].{name:name,prefix:addressPrefix,nextHop:nextHopIpAddress}}" -o json
az network firewall show -g rg-hub-swc -n afw-hub-swc --query "{name:name,privateIp:ipConfigurations[0].privateIPAddress,state:provisioningState}" -o json
az network firewall show -g rg-hub-noe -n afw-hub-noe --query "{name:name,privateIp:ipConfigurations[0].privateIPAddress,state:provisioningState}" -o json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the staged route tables from Lab 0 and confirm they still point to the regional firewall private IPs.
2. Decide whether you will leave those route tables unassociated during the first deployment, or whether your environment is ready for forced tunneling from the start.
3. Confirm the two regional firewalls are healthy before you tighten any egress controls.

  </div>
</div>

Lab 0 created the route tables but deliberately did **not** attach them to the spoke subnets. That is still a good default while you validate the secure deployment. If you do decide to force-tunnel outbound traffic through the hub firewalls, make sure the required control-plane and package-fetch paths are allowed first.

| Traffic category | Why it matters | Secure-variant guidance |
|---|---|---|
| Azure control plane | ARM/Bicep deployments, platform agents, diagnostics | Allow the Azure management paths required by your deployment tooling |
| Package and image pulls | App startup, container image pulls, runtime bootstrapping | Allow the package feeds and registries your sample actually uses |
| Private Link data-plane traffic | SQL, Storage, Cosmos DB, Key Vault, Service Bus, ACR | Prefer Private Link and keep it in-spoke |
| Global edge health probes | Front Door / Traffic Manager needs to validate origins | Allow the minimal inbound/outbound paths required by the chosen global edge |

> **Recommended sequence:** deploy first, verify private endpoints and DNS, then associate `rt-spoke-egress-swc` / `rt-spoke-egress-noe` and harden firewall policy in a second pass.

---

### 6. Bootstrap Upstream Samples

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
bash ./scripts/fetch-samples.sh
ls samples/
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/fetch-samples.sh
Get-ChildItem .\samples
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the bootstrap script from Cloud Shell or your workstation.
2. Use the portal primarily for verification here: inspect the resulting `samples/` folder in your editor once the script completes.
3. Resolve local prerequisite issues before you move on to the secure deployment.

  </div>
</div>
---

### 7. Step 1 — Deploy the Primary Baseline into the Primary Spoke

Step 1 provisions the primary-region resources: the App Service or AKS cluster, Azure Functions, SQL Database, Cosmos DB account, Storage accounts, Key Vault, Service Bus namespace, and the supporting network integrations that bind the workload to the Lab 0 spoke landing zone.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd step1-primary-baseline
bash ./scripts/deploy.sh --topology ../config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location (Join-Path $RepoRoot "step1-primary-baseline")

bash ./scripts/deploy.sh --topology ../config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Start the Step 1 deployment from Cloud Shell or your workstation.
2. In the Azure portal, monitor **Resource groups** and **Deployments** as resources appear in the primary region.
3. Do not proceed until the baseline deployment finishes successfully and outputs the actual resource names you will reuse later.

      </div>
    </div>

> **⏱ This step takes 15–25 minutes** depending on the services enabled in your topology.

> **🔐 Secure-variant note:** If your branch exposes explicit existing-VNet, subnet, or Private DNS parameters, pass them here so compute lands in the spoke and private endpoints land in `snet-private-endpoints`.

> **💡 Readiness-check note:** The prototype's current readiness checker evaluates some optional services even when your topology disables them. If you intentionally turned off capabilities such as Databricks, Front Door/CDN, or Redis and the pre-check still flags those providers, rerun the command with `--skip-checks`.

The deploy script:

1. Reads the topology manifest to determine subscriptions, primary region, and enabled features
2. Creates resource groups with consistent naming (`rg-<purpose>-<region>`)
3. Deploys infrastructure using Bicep/ARM templates
4. Deploys application code to compute resources
5. Configures networking (VNet, NSGs, Private Endpoints where applicable)
6. Outputs a summary of deployed resources

#### Verify Primary Deployment

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group list --query "[?location=='swedencentral'].name" -o tsv

PRIMARY_APP_URL=$(az webapp show -g rg-app-swedencentral -n <your-app-name> --query defaultHostName -o tsv)
curl -s -o /dev/null -w "%{http_code}" "https://$PRIMARY_APP_URL/health"

az sql server list -g rg-data-swedencentral -o table
az cosmosdb show -g rg-data-swedencentral -n <your-cosmos-account> --query "readLocations[].locationName" -o tsv
az servicebus namespace show -g rg-messaging-swedencentral -n <your-sb-namespace> --query status -o tsv
az keyvault show -g rg-security-swedencentral -n <your-keyvault> --query "properties.provisioningState" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group list --query "[?location=='swedencentral'].name" -o tsv

$PRIMARY_APP_URL = az webapp show -g rg-app-swedencentral -n <your-app-name> --query defaultHostName -o tsv
(Invoke-WebRequest -UseBasicParsing -Uri "https://$PRIMARY_APP_URL/health").StatusCode

az sql server list -g rg-data-swedencentral -o table
az cosmosdb show -g rg-data-swedencentral -n <your-cosmos-account> --query "readLocations[].locationName" -o tsv
az servicebus namespace show -g rg-messaging-swedencentral -n <your-sb-namespace> --query status -o tsv
az keyvault show -g rg-security-swedencentral -n <your-keyvault> --query "properties.provisioningState" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open each primary-region resource group and verify the expected services exist.
2. Browse to the primary web app or API health endpoint from the **Overview** page.
3. Confirm the SQL server, Cosmos DB account, Service Bus namespace, and Key Vault each show healthy provisioning state in their overview blades.
4. Replace the placeholder names in the CLI tabs with the actual names the deployment produced.

      </div>
    </div>

> **📝 Note:** The deploy script outputs the actual resource names. Replace the `<your-*>` placeholders above with those values.

At this point you have a fully working single-region application. This mirrors what many teams have in production — and it is exactly what needs multi-region protection.

**Cross-reference — this step combines concepts from:**
- [Lab 7-b — Web App deployment](lab-07b-webapp-traffic-manager-private-networking.md) (App Service provisioning)
- [Lab 2-b — SQL Database creation](lab-02b-sql-private-geo-replication.md) (SQL Server + database)
- [Lab 3-b — Cosmos DB setup](lab-03b-cosmos-private-global-distribution.md) (single-region Cosmos account)
- [Lab 8-b — Key Vault creation](lab-08b-key-vault-private-networking.md) (primary Key Vault)
- [Lab 9-b — Service Bus namespace](lab-09b-service-bus-private-networking.md) (Premium namespace)

---

### 8. Step 2 — Discover & Recommend the Secondary Region

Step 2 scans the Azure Resource Manager API, evaluates candidate secondary regions, and produces a recommendation report.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd ../step2-discover-recommend
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
pwsh scripts/run-discovery.ps1 -SubscriptionId $SUBSCRIPTION_ID -TopologyFile ../config/topology.json

jq '{primaryRegion, recommendedSecondaryRegion, totalRecommendations: (.recommendations | length)}' outputs/recommendations.json
jq '.candidates | sort_by(-.compositeScore) | .[:5] | map({region, compositeScore})' outputs/region-scorecard.json
jq '.recommendations[] | {resourceType, targetRegion, action: (.step3Action.script // .step3Action.blockReason // "manual")}' outputs/recommendations.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Set-Location ..\step2-discover-recommend
$SubscriptionId = az account show --query id -o tsv
pwsh ./scripts/run-discovery.ps1 -SubscriptionId $SubscriptionId -TopologyFile ../config/topology.json

(Get-Content .\outputs\recommendations.json -Raw | ConvertFrom-Json) |
  Select-Object primaryRegion, recommendedSecondaryRegion, @{Name='totalRecommendations';Expression={$_.recommendations.Count}}

(Get-Content .\outputs\region-scorecard.json -Raw | ConvertFrom-Json).candidates |
  Sort-Object -Property compositeScore -Descending |
  Select-Object -First 5 region, compositeScore

(Get-Content .\outputs\recommendations.json -Raw | ConvertFrom-Json).recommendations |
  Select-Object resourceType, targetRegion, @{Name='action';Expression={$_.step3Action.script ?? $_.step3Action.blockReason ?? 'manual'}}
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the discovery step from your terminal or Cloud Shell.
2. Use the Azure portal to spot-check that the discovered primary resources match what was actually deployed.
3. Open the generated JSON files in your editor and confirm the recommended region aligns with your compliance, service coverage, and cost expectations.
4. If you need a different secondary region, update `config/topology.json` before you proceed to Step 3.

      </div>
    </div>

**Expected output for the default Sweden Central → Norway East configuration:**

```json
{
  "topScoringRegion": "norwayeast",
  "compositeScore": 0.915,
  "breakdown": {
    "serviceCoverage": 0.915,
    "availabilityZones": 3,
    "costIndex": 1.02,
    "latencyMs": 8.3,
    "complianceMatch": true
  }
}
```

> **💡 Why Norway East?** It scores highest for EU workloads: 91.5% service coverage of your deployed resource types, full 3-AZ support, comparable pricing, sub-10 ms network latency from Sweden Central, and both regions fall within EU/EEA data residency boundaries. See [`docs/REGION-SELECTION.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/REGION-SELECTION.md) for the full methodology.

---

### 9. Step 3 — Enable the Secondary Region Inside the Secondary Spoke

Step 3 deploys the secondary-region resources and configures cross-region replication for every service layer while reusing the Norway East spoke resources from Lab 0. **Always run a dry run first.**

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd ../step3-enable-secondary
bash ./scripts/orchestrate-secondary.sh --topology ../config/topology.json --dry-run

# After reviewing the plan, run the real deployment:
bash ./scripts/orchestrate-secondary.sh --topology ../config/topology.json --yes
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location (Join-Path $RepoRoot "step3-enable-secondary")

bash ./scripts/orchestrate-secondary.sh --topology ../config/topology.json --dry-run

# After reviewing the plan, run the real deployment:
bash ./scripts/orchestrate-secondary.sh --topology ../config/topology.json --yes
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the dry run first and review the output carefully.
2. In the Azure portal, watch secondary-region resource groups and deployment operations appear only after you launch the real enablement step.
3. Verify the target region shown in the dry run matches your topology manifest.
4. Do not continue until the orchestration completes and the secondary resources finish provisioning.

      </div>
    </div>

> **⏱ This step takes 20–35 minutes.** It deploys in dependency order — infrastructure first, then data-tier replication, then compute, then networking/DNS.

The dry run should confirm that:

- ✅ All expected services are listed
- ✅ The target region matches your topology
- ✅ Replication strategies are appropriate (for example, async for Storage and failover groups for SQL)
- ✅ No service gaps exist because of regional availability limitations

---

### 10. Verify Cross-Region Secure Configuration

After Step 3 completes, verify both the **private-networking** posture and the **cross-region resiliency** relationships.

#### Private Endpoints and Private DNS

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-endpoint list --query "[].{name:name,resourceGroup:resourceGroup,subnet:subnet.id}" -o table
az network private-dns link vnet list -g rg-hub-swc -z privatelink.database.windows.net -o table
az network private-dns link vnet list -g rg-hub-swc -z privatelink.vaultcore.azure.net -o table
az network private-dns link vnet list -g rg-hub-swc -z privatelink.servicebus.windows.net -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-endpoint list --query "[].{name:name,resourceGroup:resourceGroup,subnet:subnet.id}" -o table
az network private-dns link vnet list -g rg-hub-swc -z privatelink.database.windows.net -o table
az network private-dns link vnet list -g rg-hub-swc -z privatelink.vaultcore.azure.net -o table
az network private-dns link vnet list -g rg-hub-swc -z privatelink.servicebus.windows.net -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Private endpoints** and confirm you have endpoints in both regional stamps where the secure topology expects them.
2. Open the Private DNS zones created earlier and verify both spokes are linked.
3. Check the endpoint DNS zone groups so record creation succeeded for the services that support it.

      </div>
    </div>

#### SQL Database — Failover Group ([Lab 2-b](lab-02b-sql-private-geo-replication.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group list -g rg-data-swedencentral -s <primary-sql-server> -o table
az sql failover-group show -g rg-data-swedencentral -s <primary-sql-server> -n <fg-name> --query "replicationState" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql failover-group list -g rg-data-swedencentral -s <primary-sql-server> -o table
az sql failover-group show -g rg-data-swedencentral -s <primary-sql-server> -n <fg-name> --query "replicationState" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary SQL server.
2. Go to **Failover groups**.
3. Confirm the failover group exists and the secondary server is attached.
4. Verify the replication state is healthy (`CATCH_UP` or `SYNCHRONIZED`).

      </div>
    </div>

#### Cosmos DB — Multi-Region ([Lab 3-b](lab-03b-cosmos-private-global-distribution.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb show -g rg-data-swedencentral -n <cosmos-account> --query "readLocations[].{region: locationName, priority: failoverPriority}" -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az cosmosdb show -g rg-data-swedencentral -n <cosmos-account> --query "readLocations[].{region: locationName, priority: failoverPriority}" -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Cosmos DB account.
2. Go to **Replicate data globally**.
3. Confirm both **Sweden Central** and **Norway East** appear in the regional map and the priorities match your design.

      </div>
    </div>

#### Storage — Object Replication ([Lab 1-b](lab-01b-blob-storage-private-endpoints.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account or-policy list --account-name <primary-storage> -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account or-policy list --account-name <primary-storage> -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary storage account.
2. Go to **Data management** → **Object replication**.
3. Confirm the replication policy targets the secondary account and reports a healthy state.

      </div>
    </div>

#### Service Bus — Geo-DR Alias ([Lab 9-b](lab-09b-service-bus-private-networking.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-sb-namespace> --alias <alias-name> --query "role" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-sb-namespace> --alias <alias-name> --query "role" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary Service Bus namespace.
2. Go to **Geo-recovery**.
3. Confirm the alias exists and the namespace reports the **Primary** role.

      </div>
    </div>

#### Key Vault — Secret Sync ([Lab 8-b](lab-08b-key-vault-private-networking.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault secret list --vault-name <secondary-keyvault> --query "[].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault secret list --vault-name <secondary-keyvault> --query "[].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the secondary Key Vault.
2. Go to **Secrets**.
3. Confirm the expected application secrets exist in the secondary vault.

      </div>
    </div>

#### Event Hubs — Geo-Replication ([Lab 10-b](lab-10b-event-hubs-private-networking.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-eh-namespace> --alias <eh-alias-name> --query "role" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-eh-namespace> --alias <eh-alias-name> --query "role" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary Event Hubs namespace.
2. Go to **Geo-recovery**.
3. Confirm the alias exists and the namespace role is healthy.

      </div>
    </div>

#### Container Registry — Geo-Replica ([Lab 11-b](lab-11b-acr-private-networking.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr replication list -r <acr-name> -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr replication list -r <acr-name> -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Azure Container Registry.
2. Go to **Replications**.
3. Confirm a Norway East replication exists and is healthy.

      </div>
    </div>

#### Front Door / Traffic Manager — Global Endpoint ([Lab 7-b](lab-07b-webapp-traffic-manager-private-networking.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network front-door show -g rg-global -n <frontdoor-name> --query "backendPools[0].backends[].address" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network front-door show -g rg-global -n <frontdoor-name> --query "backendPools[0].backends[].address" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open Azure Front Door or Traffic Manager.
2. Confirm both primary and secondary backends/origins are configured.
3. Verify health probes show the expected backend as healthy before you test failover.

      </div>
    </div>

---

### 11. Test the Running Application

With both regions fully deployed and all replication configured, test the client entry path you chose for the secure variant. If you keep a public global edge, access the application through that endpoint. If your branch is fully private, run the same checks from a host or pod inside the spoke.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
GLOBAL_URL=$(az network front-door show -g rg-global -n <frontdoor-name> --query "frontendEndpoints[0].hostName" -o tsv)

echo "Application URL: https://$GLOBAL_URL"
curl -s "https://$GLOBAL_URL/health"
curl -s "https://$GLOBAL_URL/api/status" | jq .
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$GLOBAL_URL = az network front-door show -g rg-global -n <frontdoor-name> --query "frontendEndpoints[0].hostName" -o tsv

Write-Host "Application URL: https://$GLOBAL_URL"
Invoke-RestMethod "https://$GLOBAL_URL/health" | ConvertTo-Json -Depth 10
Invoke-RestMethod "https://$GLOBAL_URL/api/status" | ConvertTo-Json -Depth 10
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open Azure Front Door / Traffic Manager and copy the public frontend hostname.
2. Browse to the application URL.
3. Confirm the health or status endpoint reports the primary region (`swedencentral`).
4. Verify the application is healthy before you simulate a failure.

      </div>
    </div>

You should see a healthy response served from Sweden Central (the primary). Front Door / Traffic Manager directs all traffic to the primary while it is healthy.

---

### 12. Simulate a Disaster

Now test that coordinated failover actually works. There are two approaches.

#### Trigger the Failure

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
# Option A: stop primary compute
az webapp stop -g rg-app-swedencentral -n <primary-app-name>
az functionapp stop -g rg-app-swedencentral -n <primary-functions-name>

# Option B: start a Chaos Studio experiment instead
az rest --method POST --url "https://management.azure.com/subscriptions/<sub-id>/resourceGroups/rg-chaos/providers/Microsoft.Chaos/experiments/<experiment-name>/start?api-version=2024-01-01"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Option A: stop primary compute
az webapp stop -g rg-app-swedencentral -n <primary-app-name>
az functionapp stop -g rg-app-swedencentral -n <primary-functions-name>

# Option B: start a Chaos Studio experiment instead
az rest --method POST --url "https://management.azure.com/subscriptions/<sub-id>/resourceGroups/rg-chaos/providers/Microsoft.Chaos/experiments/<experiment-name>/start?api-version=2024-01-01"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. For a simple test, open the primary **Web App** and **Function App** and use **Stop**.
2. For a more realistic drill, open **Chaos Studio** and start the experiment that targets the primary compute tier.
3. Record the time you initiated the fault so you can compare it with the observed failover time.

      </div>
    </div>

#### Monitor the Failover

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
for i in $(seq 1 20); do
  RESPONSE=$(curl -s "https://$GLOBAL_URL/health" 2>/dev/null)
  REGION=$(echo "$RESPONSE" | jq -r '.region // "unreachable"')
  echo "$(date +%H:%M:%S) — Region: $REGION"
  sleep 15
done

curl -s "https://$GLOBAL_URL/health"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
for ($i = 1; $i -le 20; $i++) {
  try {
    $Response = Invoke-RestMethod "https://$GLOBAL_URL/health"
    $Region = $Response.region
  } catch {
    $Region = 'unreachable'
  }
  Write-Host "$(Get-Date -Format HH:mm:ss) — Region: $Region"
  Start-Sleep -Seconds 15
}

Invoke-RestMethod "https://$GLOBAL_URL/health" | ConvertTo-Json -Depth 10
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Watch the global endpoint from a browser or the Front Door / Traffic Manager monitoring views.
2. Confirm the primary backend starts failing health probes.
3. Within the expected health probe and DNS interval, verify requests begin landing in **Norway East**.
4. Keep notes on the observed failover time so you can compare it with your target RTO.

      </div>
    </div>

After 30–90 seconds (depending on health probe interval and DNS TTL), the health response should come from `norwayeast`.

The key observation: **the global endpoint URL did not change.** Front Door / Traffic Manager detected the primary failure through health probes and automatically routed traffic to the secondary in Norway East.

---

### 13. Validate Failover with Secure Networking Still Intact

Failover is not just about compute. Verify that every service layer is operating correctly from the secondary region.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
curl -s "https://$GLOBAL_URL/api/status" | jq '.region'
az sql failover-group show -g rg-data-swedencentral -s <primary-sql-server> -n <fg-name> --query "{primary: replicationRole, state: replicationState}" -o json
curl -s "https://$GLOBAL_URL/api/data/test" | jq '.source'
az servicebus georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-sb-namespace> --alias <alias-name> --query "pendingReplicationOperationsCount" -o tsv
az keyvault secret show --vault-name <secondary-keyvault> -n app-connection-string --query "id" -o tsv
az storage blob list --account-name <secondary-storage> -c app-data --query "[].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
(Invoke-RestMethod "https://$GLOBAL_URL/api/status").region
az sql failover-group show -g rg-data-swedencentral -s <primary-sql-server> -n <fg-name> --query "{primary: replicationRole, state: replicationState}" -o json
(Invoke-RestMethod "https://$GLOBAL_URL/api/data/test").source
az servicebus georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-sb-namespace> --alias <alias-name> --query "pendingReplicationOperationsCount" -o tsv
az keyvault secret show --vault-name <secondary-keyvault> -n app-connection-string --query "id" -o tsv
az storage blob list --account-name <secondary-storage> -c app-data --query "[].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm the application now reports **Norway East** in its status endpoint or UI.
2. Check the SQL failover group, Cosmos DB regional map, Service Bus alias, and storage replication state in the portal.
3. Verify the secondary Key Vault contains the expected application secrets without exposing secret values unnecessarily.
4. Confirm the storage account in the secondary region contains the expected application data.

      </div>
    </div>

> **🔑 Key insight:** In the secure variant, failover validates two things at once: **service resilience** and **network correctness**. If Private DNS, subnet placement, or firewall assumptions are wrong, the secondary region may be healthy at the service layer but still unreachable from the workload.

---

### 14. Discuss Failback

Failover gets the headlines, but **failback** is often more complex and less tested. Review the prototype's failover runbook:

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
cat docs/failover-runbook.md
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Set-Location (git rev-parse --show-toplevel)
Get-Content ./docs/failover-runbook.md
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `docs/failover-runbook.md` in your editor or in the repository browser.
2. Review the documented failback sequencing before you restore primary traffic.
3. Make sure the on-call and operations assumptions in the runbook match your environment.

      </div>
    </div>

Key failback considerations:

1. **Data synchronization direction reversal** — after failover, the secondary becomes the new primary for writes. Before failing back, you need to ensure data written to the (former) secondary is replicated back to the original primary.
2. **SQL Failover Group failback** — reverse the failover group so the original primary becomes primary again. This requires the original primary to be healthy and caught up.
3. **Service Bus re-pairing** — after a geo-DR failover, the pairing is **broken**. You must delete the old pairing and re-create it in the original direction. This is not instantaneous.
4. **Cosmos DB region priority** — update the failover priority list to restore the original primary as the preferred write region.
5. **DNS TTL propagation** — Front Door / Traffic Manager DNS changes take time to propagate. Monitor TTL expiration to confirm all clients are routing correctly.
6. **Application state** — clear caches, reset circuit breakers, and verify connection pools have reconnected to the restored primary.

> **⚠️ Warning:** Never fail back without verifying that the original primary region is fully healthy and all data replication has caught up. A premature failback can cause data loss or split-brain scenarios.

For detailed step-by-step failback procedures, see: [`docs/failover-runbook.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/failover-runbook.md)

---

### 15. Restore Primary Services

If you used Option A (manual stoppage), restart the primary services.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az webapp start -g rg-app-swedencentral -n <primary-app-name>
az functionapp start -g rg-app-swedencentral -n <primary-functions-name>

PRIMARY_APP_URL=$(az webapp show -g rg-app-swedencentral -n <primary-app-name> --query defaultHostName -o tsv)
curl -s "https://$PRIMARY_APP_URL/health"

for i in $(seq 1 10); do
  REGION=$(curl -s "https://$GLOBAL_URL/health" | jq -r '.region // "unknown"')
  echo "$(date +%H:%M:%S) — Serving from: $REGION"
  sleep 15
done
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az webapp start -g rg-app-swedencentral -n <primary-app-name>
az functionapp start -g rg-app-swedencentral -n <primary-functions-name>

$PRIMARY_APP_URL = az webapp show -g rg-app-swedencentral -n <primary-app-name> --query defaultHostName -o tsv
Invoke-RestMethod "https://$PRIMARY_APP_URL/health" | ConvertTo-Json -Depth 10

for ($i = 1; $i -le 10; $i++) {
  $Region = (Invoke-RestMethod "https://$GLOBAL_URL/health").region
  Write-Host "$(Get-Date -Format HH:mm:ss) — Serving from: $Region"
  Start-Sleep -Seconds 15
}
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Start the primary web app and function app from their **Overview** blades.
2. Watch Front Door / Traffic Manager health probes turn green again for the primary backend.
3. Confirm the application eventually serves from **Sweden Central** again if your design supports automatic failback.
4. Record the recovery time and any operational surprises.

      </div>
    </div>

Within a few minutes, Front Door / Traffic Manager should detect the primary is healthy again and route traffic back if your configuration supports it.

---

### 16. Cost Management

Multi-region deployments double (or more) your resource costs. The prototype includes scripts to manage costs effectively.

#### Pause All Resources

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
bash ./scripts/pause-all.sh --topology ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/pause-all.sh --topology ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the pause script from Cloud Shell or your workstation.
2. In the portal, verify compute resources show **Stopped** or scaled down afterward.
3. Confirm databases or clusters that should remain allocated are still reachable according to the script's behavior.

      </div>
    </div>

This script:

- Stops App Service plans (or scales to zero)
- Deallocates VMs / AKS node pools
- Pauses SQL databases (if using serverless tier)
- Does **not** delete data or break replication — resources remain deployed but idle

#### Resume All Resources

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
bash ./scripts/resume-all.sh --topology ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/resume-all.sh --topology ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the resume script from Cloud Shell or your workstation.
2. In the portal, confirm the paused resources return to a healthy running state.
3. Recheck the application health endpoint after resume completes.

      </div>
    </div>

Restarts all paused resources and verifies health across both regions.

#### Decouple Secondary

If you want to keep the primary running but remove the secondary to save costs:

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
bash ./scripts/decouple-secondary.sh --topology ./config/topology.json --yes
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/decouple-secondary.sh --topology ./config/topology.json --yes
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Use this option only when you intentionally want to break secondary-region protection.
2. Run the script from Cloud Shell or your workstation.
3. In the portal, verify the replication relationships are removed cleanly before any secondary resources are deleted.

      </div>
    </div>

This cleanly breaks all cross-region replication relationships before removing secondary resources. It is preferable to directly deleting secondary resource groups, which could leave orphaned replication configurations on the primary side.

---

### 17. Cleanup

When you are done with the lab, remove all deployed resources.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
bash ./scripts/cleanup-all.sh --topology ./config/topology.json --yes

az group list --query "[?starts_with(name, 'rg-contoso-') || starts_with(name, 'MC_rg-contoso-')].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/cleanup-all.sh --topology ./config/topology.json --yes

az group list --query "[?starts_with(name, 'rg-contoso-') || starts_with(name, 'MC_rg-contoso-')].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the cleanup script from Cloud Shell or your workstation.
2. In the Azure portal, refresh **Resource groups** and confirm the lab groups disappear as the cleanup progresses.
3. If you use soft-delete features such as Key Vault recovery, verify any optional purge steps before you walk away.

      </div>
    </div>

The cleanup script:

1. Breaks all replication relationships (geo-DR pairings, failover groups, object replication policies)
2. Removes Front Door / Traffic Manager global endpoint
3. Deletes secondary region resource groups
4. Deletes primary region resource groups
5. Removes the global resource group
6. Purges soft-deleted Key Vaults (optional — prompts for confirmation)

> **⚠️ This is destructive and irreversible.** Verify you want to remove everything before confirming.

---


## End-to-End Validation Checklist

Before considering this lab complete, verify each item:

| # | Check | Status |
|---|-------|--------|
| 1 | Lab 0 hub-and-spoke foundation exists in both regions | ☐ |
| 2 | `config/topology.json` enables `enablePrivateEndpoints` | ☐ |
| 3 | The topology or deployment overrides map workloads to the existing spokes | ☐ |
| 4 | Required Private DNS zones exist and both spokes are linked | ☐ |
| 5 | Step 1 deploys the primary baseline without creating a parallel VNet | ☐ |
| 6 | Primary compute uses the expected spoke subnet or VNet integration path | ☐ |
| 7 | Private endpoints land in `snet-private-endpoints` | ☐ |
| 8 | Public network access is disabled or tightly restricted for the supported PaaS services | ☐ |
| 9 | Step 2 confirms the secure secondary region choice | ☐ |
| 10 | Step 3 enables the Norway East deployment inside the secondary spoke | ☐ |
| 11 | SQL, Cosmos DB, Storage, Service Bus, Key Vault, and ACR relationships are healthy | ☐ |
| 12 | The global edge is healthy before the drill | ☐ |
| 13 | Disaster simulation shifts traffic to Norway East | ☐ |
| 14 | The application remains reachable with private connectivity intact | ☐ |
| 15 | Primary restored and traffic resumed | ☐ |
| 16 | Failback discussion reviewed (`docs/failover-runbook.md`) | ☐ |
| 17 | Cleanup completed, or the Lab 0 secure foundation was intentionally retained | ☐ |

---


## Discussion Questions

Use these questions to deepen your understanding of secure multi-region application design.

### Why Keep the Regions as Separate Stamps?

Because the labs favor **global failover** over a flat cross-region mesh. Independent regional stamps reduce blast radius, keep address management simpler, and make it obvious which region is active. The application fails over at the **service** and **global-routing** layers instead of depending on a large east-west network.

### Why Reserve a Dedicated Private-Endpoint Subnet?

Private endpoints are easiest to manage when they are isolated from compute. Putting them in `snet-private-endpoints` keeps routing, diagnostics, and service ownership cleaner. It also avoids accidental delegation or NSG choices that were meant for application compute rather than for Private Link interfaces.

### What Breaks First When DNS Is Wrong?

Usually the workload fails long before the platform reports a regional outage. The database, vault, or messaging namespace may be perfectly healthy, but if the workload resolves the service name to a public endpoint or to a missing private record, the application behaves as if the service is down. In secure multi-region architectures, **DNS correctness is part of application availability**.

### When Should You Keep Lab 0 Deployed?

Keep it when you plan to run more secure `B` variants or when you want to iterate on firewall policy, Private Link coverage, or spoke placement over multiple sessions. Clean it up when cost matters more than reuse, especially because Azure Firewall and Bastion are hourly-billed shared services.

---


## Key Reference Documents

| Document | Why it matters |
|----------|----------------|
| [Lab 0 — Security Pre-Reqs](lab-00-security-prereqs.md) | Defines the canonical hub-and-spoke names, subnets, and shared controls this lab reuses |
| [`docs/architecture.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/architecture.md) | Full prototype architecture documentation |
| [`docs/OPERATIONS.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/OPERATIONS.md) | Day-2 operational procedures, monitoring, and maintenance |
| [`docs/REGION-SELECTION.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/REGION-SELECTION.md) | Region scoring methodology and selection criteria |
| [`docs/failover-runbook.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/failover-runbook.md) | Step-by-step failover and failback procedures |
| [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/networking/architecture/hub-spoke) | Background on the regional landing-zone model |
| [Azure Private Link and private endpoints](https://learn.microsoft.com/azure/private-link/private-endpoint-overview) | Private connectivity for platform services |
| [Azure Private DNS for Private Link](https://learn.microsoft.com/azure/private-link/private-endpoint-dns) | DNS behavior for private endpoints |

---

## Discussion & Next Steps

Choose [Lab 14-a](lab-14a-enterprise-prototype.md) if you want the same capstone orchestration with fewer prerequisites, if your environment is not yet ready for Private Link and hub firewalls, or if you want to teach the failover workflow before you introduce secure landing-zone design.

[← Lab 14-a — Enterprise Prototype](lab-14a-enterprise-prototype.md) | [Lab 14-b — Secure Networking](lab-14b-enterprise-prototype-secure-networking.md)
