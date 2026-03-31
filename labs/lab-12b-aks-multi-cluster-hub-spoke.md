---
layout: default
title: "Lab 12-b: AKS Multi-Cluster – Hub-and-Spoke with Fleet, ACR, Application Gateway, and Front Door"
---

[← Lab 12-a: Baseline Public-Edge Variant](lab-12a-aks-multi-cluster.md)

# Lab 12-b: AKS Multi-Cluster – Hub-and-Spoke with Fleet, ACR, Application Gateway, and Front Door

This secure variant assumes the **Lab 0 hub-and-spoke foundation already exists**. It keeps the same Fleet + ACR + Front Door pattern, but moves each AKS cluster into its regional spoke VNet, adds a regional Application Gateway ingress layer, and reuses the hub firewall baseline for staged AKS egress control.

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

> **Deploy two regional AKS clusters into the Lab 0 spoke VNets, place an Application Gateway in front of each cluster, coordinate lifecycle with Azure Kubernetes Fleet Manager, publish a geo-replicated image through ACR, and validate global routing with Azure Front Door.**

<div class="lab-note">
  <strong>Lab 0 dependency:</strong> This lab assumes <code>rg-hub-swc</code>, <code>rg-hub-noe</code>, <code>rg-spoke-swc</code>, <code>rg-spoke-noe</code>, both regional hub/spoke peerings, both Azure Firewalls, both Bastions, and the staged route tables already exist exactly as created in <strong>Lab 0</strong>.
</div>

<div class="lab-note">
  <strong>Closer to the reference architecture:</strong> Unlike Lab 12-a, this variant keeps Azure Front Door at the global edge but inserts a <strong>regional Application Gateway</strong> in front of each AKS cluster and places both clusters directly in the spoke VNets. The hubs continue to hold the shared security controls.
</div>

---

## Why This Variant Exists

Lab 12-a is the fastest way to understand the AKS multi-cluster pattern. This secure variant answers the next question: **what changes when you already have a regional hub-and-spoke landing zone?**

In this version you:

- Keep the same two-region AKS pattern.
- Reuse the fixed regional names from Lab 0.
- Add a dedicated ingress layer in each spoke.
- Use the hub firewall baseline and staged route tables for controlled AKS egress.
- Preserve the “regional stamp” model instead of flattening the network across regions.

---

## Architecture

```text
                         ┌──────────────────────────────┐
                         │ Azure Front Door             │
                         │ Global HTTP(S) entry         │
                         └────────────┬─────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    │                                   │
          ┌─────────▼─────────┐               ┌─────────▼─────────┐
          │ Application       │               │ Application       │
          │ Gateway - SWC     │               │ Gateway - NOE     │
          │ regional ingress  │               │ regional ingress  │
          └─────────┬─────────┘               └─────────┬─────────┘
                    │                                   │
          ┌─────────▼─────────┐               ┌─────────▼─────────┐
          │ AKS - Sweden      │               │ AKS - Norway      │
          │ snet-aks          │               │ snet-aks          │
          │ vnet-spoke-swc    │               │ vnet-spoke-noe    │
          └─────────┬─────────┘               └─────────┬─────────┘
                    │                                   │
          ┌─────────▼─────────┐               ┌─────────▼─────────┐
          │ Hub firewall      │               │ Hub firewall      │
          │ afw-hub-swc       │               │ afw-hub-noe       │
          │ rt-spoke-egress   │               │ rt-spoke-egress   │
          └─────────┬─────────┘               └─────────┬─────────┘
                    │                                   │
                    └───────────────┬───────────────────┘
                                    │
                         ┌──────────▼──────────┐
                         │ Fleet + Premium ACR │
                         │ global coordination │
                         └─────────────────────┘
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Lab 0 completed** | The hub resource groups, spoke resource groups, VNets, firewalls, Bastions, peerings, and staged route tables from Lab 0 must already exist. |
| **Azure CLI 2.75+** | Recommended because this variant uses AKS, Front Door, Fleet, Application Gateway, and firewall policy commands together. |
| **Extensions and tools** | Install the `fleet` and `azure-firewall` Azure CLI extensions and make sure `kubectl` is available. |
| **Permissions** | You need rights to create AKS, ACR, Front Door, Application Gateway, public IPs, and Azure Firewall policy rule collection groups. |
| **Budget awareness** | This variant adds two AKS clusters, two Application Gateways, a Premium ACR, and Azure Front Door on top of the Lab 0 foundation. |

---

## Assumed Lab 0 Baseline

| Asset from Lab 0 | Name used here | Why it matters |
|---|---|---|
| Primary spoke resource group | `rg-spoke-swc` | Hosts the Sweden Central Application Gateway, AKS cluster, and new AKS subnets |
| DR spoke resource group | `rg-spoke-noe` | Hosts the Norway East Application Gateway, AKS cluster, and new AKS subnets |
| Primary spoke VNet | `vnet-spoke-swc` | Regional workload network for the Sweden Central stamp |
| DR spoke VNet | `vnet-spoke-noe` | Regional workload network for the Norway East stamp |
| Primary firewall policy | `afwp-hub-swc` | Extended with AKS and ACR outbound allow rules |
| DR firewall policy | `afwp-hub-noe` | Extended with AKS and ACR outbound allow rules |
| Primary staged route table | `rt-spoke-egress-swc` | Attached to the new AKS subnet after firewall rules are in place |
| DR staged route table | `rt-spoke-egress-noe` | Attached to the new AKS subnet after firewall rules are in place |

---

## How These Tabs Work

This page uses the same interaction pattern as the rest of the lab series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behavior used in the existing labs.

---

## Step 1 — Verify Lab 0 and Define the Shared Variables

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az extension add --name fleet
az extension add --name azure-firewall
az aks install-cli

SUFFIX=$(openssl rand -hex 2)

LOCATION_PRIMARY=swedencentral
LOCATION_SECONDARY=norwayeast

RG_GLOBAL="rg-aks-global-secure-$SUFFIX"

RG_HUB_PRIMARY="rg-hub-swc"
RG_SPOKE_PRIMARY="rg-spoke-swc"
RG_HUB_SECONDARY="rg-hub-noe"
RG_SPOKE_SECONDARY="rg-spoke-noe"

SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_SECONDARY="vnet-spoke-noe"

FW_POLICY_PRIMARY="afwp-hub-swc"
FW_POLICY_SECONDARY="afwp-hub-noe"
FIREWALL_PRIMARY="afw-hub-swc"
FIREWALL_SECONDARY="afw-hub-noe"
FIREWALL_PIP_PRIMARY="pip-afw-swc"
FIREWALL_PIP_SECONDARY="pip-afw-noe"
ROUTE_TABLE_PRIMARY="rt-spoke-egress-swc"
ROUTE_TABLE_SECONDARY="rt-spoke-egress-noe"

AKS_SUBNET_PRIMARY="snet-aks"
AKS_SUBNET_SECONDARY="snet-aks"
AKS_SUBNET_PRIMARY_CIDR="10.10.6.0/23"
AKS_SUBNET_SECONDARY_CIDR="10.20.6.0/23"

APPGW_SUBNET_PRIMARY="snet-appgw"
APPGW_SUBNET_SECONDARY="snet-appgw"
APPGW_SUBNET_PRIMARY_CIDR="10.10.5.128/25"
APPGW_SUBNET_SECONDARY_CIDR="10.20.5.128/25"

ACR_NAME="akshs${SUFFIX}acr"
PRIMARY_CLUSTER="aks-swc-hs-$SUFFIX"
SECONDARY_CLUSTER="aks-noe-hs-$SUFFIX"
APPGW_PRIMARY="agw-swc-aks-$SUFFIX"
APPGW_SECONDARY="agw-noe-aks-$SUFFIX"
APPGW_PIP_PRIMARY="pip-agw-swc-$SUFFIX"
APPGW_PIP_SECONDARY="pip-agw-noe-$SUFFIX"
FLEET_NAME="fleet-aks-hs-$SUFFIX"
AFD_PROFILE="afd-aks-hs-$SUFFIX"
AFD_ENDPOINT="akshs-$SUFFIX"
ORIGIN_GROUP="og-aks-appgw"
NAMESPACE="multiregion-demo"
APP_NAME="regional-app"
RCG_PRIMARY="rcg-aks-swc-$SUFFIX"
RCG_SECONDARY="rcg-aks-noe-$SUFFIX"

az group show --name "$RG_HUB_PRIMARY" --query name --output tsv
az group show --name "$RG_SPOKE_PRIMARY" --query name --output tsv
az group show --name "$RG_HUB_SECONDARY" --query name --output tsv
az group show --name "$RG_SPOKE_SECONDARY" --query name --output tsv

az network vnet show --resource-group "$RG_SPOKE_PRIMARY" --name "$SPOKE_VNET_PRIMARY" --query name --output tsv
az network vnet show --resource-group "$RG_SPOKE_SECONDARY" --name "$SPOKE_VNET_SECONDARY" --query name --output tsv

az network firewall policy show --resource-group "$RG_HUB_PRIMARY" --name "$FW_POLICY_PRIMARY" --query name --output tsv
az network firewall policy show --resource-group "$RG_HUB_SECONDARY" --name "$FW_POLICY_SECONDARY" --query name --output tsv

az network route-table show --resource-group "$RG_SPOKE_PRIMARY" --name "$ROUTE_TABLE_PRIMARY" --query name --output tsv
az network route-table show --resource-group "$RG_SPOKE_SECONDARY" --name "$ROUTE_TABLE_SECONDARY" --query name --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az extension add --name fleet
az extension add --name azure-firewall
az aks install-cli

$Suffix = -join ((48..57 + 97..122 | Get-Random -Count 4 | ForEach-Object { [char]$_ }))

$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"

$RG_GLOBAL = "rg-aks-global-secure-$Suffix"

$RG_HUB_PRIMARY = "rg-hub-swc"
$RG_SPOKE_PRIMARY = "rg-spoke-swc"
$RG_HUB_SECONDARY = "rg-hub-noe"
$RG_SPOKE_SECONDARY = "rg-spoke-noe"

$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"

$FW_POLICY_PRIMARY = "afwp-hub-swc"
$FW_POLICY_SECONDARY = "afwp-hub-noe"
$FIREWALL_PRIMARY = "afw-hub-swc"
$FIREWALL_SECONDARY = "afw-hub-noe"
$FIREWALL_PIP_PRIMARY = "pip-afw-swc"
$FIREWALL_PIP_SECONDARY = "pip-afw-noe"
$ROUTE_TABLE_PRIMARY = "rt-spoke-egress-swc"
$ROUTE_TABLE_SECONDARY = "rt-spoke-egress-noe"

$AKS_SUBNET_PRIMARY = "snet-aks"
$AKS_SUBNET_SECONDARY = "snet-aks"
$AKS_SUBNET_PRIMARY_CIDR = "10.10.6.0/23"
$AKS_SUBNET_SECONDARY_CIDR = "10.20.6.0/23"

$APPGW_SUBNET_PRIMARY = "snet-appgw"
$APPGW_SUBNET_SECONDARY = "snet-appgw"
$APPGW_SUBNET_PRIMARY_CIDR = "10.10.5.128/25"
$APPGW_SUBNET_SECONDARY_CIDR = "10.20.5.128/25"

$ACR_NAME = "akshs${Suffix}acr"
$PRIMARY_CLUSTER = "aks-swc-hs-$Suffix"
$SECONDARY_CLUSTER = "aks-noe-hs-$Suffix"
$APPGW_PRIMARY = "agw-swc-aks-$Suffix"
$APPGW_SECONDARY = "agw-noe-aks-$Suffix"
$APPGW_PIP_PRIMARY = "pip-agw-swc-$Suffix"
$APPGW_PIP_SECONDARY = "pip-agw-noe-$Suffix"
$FLEET_NAME = "fleet-aks-hs-$Suffix"
$AFD_PROFILE = "afd-aks-hs-$Suffix"
$AFD_ENDPOINT = "akshs-$Suffix"
$ORIGIN_GROUP = "og-aks-appgw"
$NAMESPACE = "multiregion-demo"
$APP_NAME = "regional-app"
$RCG_PRIMARY = "rcg-aks-swc-$Suffix"
$RCG_SECONDARY = "rcg-aks-noe-$Suffix"

az group show --name $RG_HUB_PRIMARY --query name --output tsv
az group show --name $RG_SPOKE_PRIMARY --query name --output tsv
az group show --name $RG_HUB_SECONDARY --query name --output tsv
az group show --name $RG_SPOKE_SECONDARY --query name --output tsv

az network vnet show --resource-group $RG_SPOKE_PRIMARY --name $SPOKE_VNET_PRIMARY --query name --output tsv
az network vnet show --resource-group $RG_SPOKE_SECONDARY --name $SPOKE_VNET_SECONDARY --query name --output tsv

az network firewall policy show --resource-group $RG_HUB_PRIMARY --name $FW_POLICY_PRIMARY --query name --output tsv
az network firewall policy show --resource-group $RG_HUB_SECONDARY --name $FW_POLICY_SECONDARY --query name --output tsv

az network route-table show --resource-group $RG_SPOKE_PRIMARY --name $ROUTE_TABLE_PRIMARY --query name --output tsv
az network route-table show --resource-group $RG_SPOKE_SECONDARY --name $ROUTE_TABLE_SECONDARY --query name --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm that **Lab 0** is already complete in both regions.
2. Reuse the fixed hub and spoke resource names from Lab 0 instead of inventing new network names.
3. Pick a short suffix so your ACR, Fleet, Front Door, Application Gateway, and AKS names remain unique.
4. Keep **Sweden Central** as the primary region and **Norway East** as the secondary region to stay consistent with the rest of the lab series.

  </div>
</div>

## Step 2 — Create the Global Resource Group, Premium ACR, and Shared Image

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name "$RG_GLOBAL" --location "$LOCATION_PRIMARY"

az acr create \
  --name "$ACR_NAME" \
  --resource-group "$RG_GLOBAL" \
  --location "$LOCATION_PRIMARY" \
  --sku Premium

az acr replication create \
  --registry "$ACR_NAME" \
  --location "$LOCATION_SECONDARY"

LAB_ROOT="$PWD/aks-hubspoke-app-$SUFFIX"
mkdir -p "$LAB_ROOT"

cat > "$LAB_ROOT/Dockerfile" <<'EOAPP'
FROM python:3.12-alpine
WORKDIR /app
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
EOAPP

cat > "$LAB_ROOT/app.py" <<'EOAPP'
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

APP_REGION = os.getenv("APP_REGION", "unknown")

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"Hello from {APP_REGION}\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body.encode())

HTTPServer(("", 8080), Handler).serve_forever()
EOAPP

az acr build \
  --registry "$ACR_NAME" \
  --image regional-app:v1 \
  "$LAB_ROOT"

rm -rf "$LAB_ROOT"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_GLOBAL --location $LOCATION_PRIMARY | Out-Null

az acr create `
  --name $ACR_NAME `
  --resource-group $RG_GLOBAL `
  --location $LOCATION_PRIMARY `
  --sku Premium | Out-Null

az acr replication create `
  --registry $ACR_NAME `
  --location $LOCATION_SECONDARY | Out-Null

$LabRoot = Join-Path (Get-Location) "aks-hubspoke-app-$Suffix"
New-Item -ItemType Directory -Path $LabRoot -Force | Out-Null

@'
FROM python:3.12-alpine
WORKDIR /app
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
'@ | Set-Content -Path (Join-Path $LabRoot 'Dockerfile') -NoNewline

@'
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

APP_REGION = os.getenv("APP_REGION", "unknown")

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"Hello from {APP_REGION}\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body.encode())

HTTPServer(("", 8080), Handler).serve_forever()
'@ | Set-Content -Path (Join-Path $LabRoot 'app.py') -NoNewline

az acr build `
  --registry $ACR_NAME `
  --image regional-app:v1 `
  $LabRoot | Out-Null

Remove-Item -Path $LabRoot -Recurse -Force
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a dedicated global resource group for Fleet, Front Door, and ACR.
2. Create a **Premium** Azure Container Registry in the primary region.
3. Add a geo-replica in Norway East.
4. Build a tiny region-aware image through **ACR Tasks** so both clusters pull the same artifact from the same registry name.

  </div>
</div>
## Step 3 — Add Dedicated AKS and Application Gateway Subnets to the Spokes

<div class="lab-note">
  <strong>Subnet rule:</strong> Application Gateway must use its own dedicated subnet. Do <em>not</em> reuse the AKS subnet for the gateway.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet subnet create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$APPGW_SUBNET_PRIMARY" \
  --address-prefixes "$APPGW_SUBNET_PRIMARY_CIDR"

az network vnet subnet create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$AKS_SUBNET_PRIMARY" \
  --address-prefixes "$AKS_SUBNET_PRIMARY_CIDR"

az network vnet subnet create \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$APPGW_SUBNET_SECONDARY" \
  --address-prefixes "$APPGW_SUBNET_SECONDARY_CIDR"

az network vnet subnet create \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$AKS_SUBNET_SECONDARY" \
  --address-prefixes "$AKS_SUBNET_SECONDARY_CIDR"

az network vnet subnet show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$AKS_SUBNET_PRIMARY" \
  --query "{Name:name, Prefix:addressPrefix}" \
  --output table

az network vnet subnet show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$AKS_SUBNET_SECONDARY" \
  --query "{Name:name, Prefix:addressPrefix}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet subnet create `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $APPGW_SUBNET_PRIMARY `
  --address-prefixes $APPGW_SUBNET_PRIMARY_CIDR | Out-Null

az network vnet subnet create `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $AKS_SUBNET_PRIMARY `
  --address-prefixes $AKS_SUBNET_PRIMARY_CIDR | Out-Null

az network vnet subnet create `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $APPGW_SUBNET_SECONDARY `
  --address-prefixes $APPGW_SUBNET_SECONDARY_CIDR | Out-Null

az network vnet subnet create `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $AKS_SUBNET_SECONDARY `
  --address-prefixes $AKS_SUBNET_SECONDARY_CIDR | Out-Null

az network vnet subnet show `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $AKS_SUBNET_PRIMARY `
  --query "{Name:name, Prefix:addressPrefix}" `
  --output table

az network vnet subnet show `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $AKS_SUBNET_SECONDARY `
  --query "{Name:name, Prefix:addressPrefix}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `vnet-spoke-swc`, create a dedicated `snet-appgw` subnet and a dedicated `snet-aks` subnet.
2. Repeat the same pattern in `vnet-spoke-noe`.
3. Keep Application Gateway isolated from the AKS nodes by using separate subnets.
4. The address ranges in the Bash and PowerShell tabs intentionally fit within the Lab 0 spoke CIDR plan.

  </div>
</div>

## Step 4 — Extend the Hub Firewall Baseline and Attach the Staged Route Tables

<div class="lab-note">
  <strong>Firewall scope note:</strong> The Microsoft-maintained <code>AzureKubernetesService</code> and <code>AzureContainerRegistry</code> tags cover the core lab path. If you add extra node images, Helm charts, or third-party registries, extend the policy <em>before</em> you attach the route tables.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
FIREWALL_PUBLIC_IP_PRIMARY=$(az network public-ip show \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$FIREWALL_PIP_PRIMARY" \
  --query ipAddress \
  --output tsv)

FIREWALL_PUBLIC_IP_SECONDARY=$(az network public-ip show \
  --resource-group "$RG_HUB_SECONDARY" \
  --name "$FIREWALL_PIP_SECONDARY" \
  --query ipAddress \
  --output tsv)

az network route-table route create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --route-table-name "$ROUTE_TABLE_PRIMARY" \
  --name "firewall-public-ip" \
  --address-prefix "$FIREWALL_PUBLIC_IP_PRIMARY/32" \
  --next-hop-type Internet

az network route-table route create \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --route-table-name "$ROUTE_TABLE_SECONDARY" \
  --name "firewall-public-ip" \
  --address-prefix "$FIREWALL_PUBLIC_IP_SECONDARY/32" \
  --next-hop-type Internet

configure_policy() {
  local hub_rg=$1
  local policy=$2
  local rcg=$3
  local subnet_cidr=$4
  local location=$5

  az network firewall policy rule-collection-group create \
    --resource-group "$hub_rg" \
    --policy-name "$policy" \
    --name "$rcg" \
    --priority 200

  az network firewall policy rule-collection-group collection add-filter-collection \
    --resource-group "$hub_rg" \
    --policy-name "$policy" \
    --rule-collection-group-name "$rcg" \
    --name "aks-network" \
    --action Allow \
    --collection-priority 200 \
    --rule-name "aks-tcp-9000" \
    --rule-type NetworkRule \
    --source-addresses "$subnet_cidr" \
    --destination-addresses "AzureCloud.$location" \
    --destination-ports 9000 \
    --ip-protocols TCP

  az network firewall policy rule-collection-group collection rule add \
    --resource-group "$hub_rg" \
    --policy-name "$policy" \
    --rule-collection-group-name "$rcg" \
    --collection-name "aks-network" \
    --name "aks-udp-1194" \
    --rule-type NetworkRule \
    --source-addresses "$subnet_cidr" \
    --destination-addresses "AzureCloud.$location" \
    --destination-ports 1194 \
    --ip-protocols UDP

  az network firewall policy rule-collection-group collection add-filter-collection \
    --resource-group "$hub_rg" \
    --policy-name "$policy" \
    --rule-collection-group-name "$rcg" \
    --name "aks-application" \
    --action Allow \
    --collection-priority 210 \
    --rule-name "aks-core" \
    --rule-type ApplicationRule \
    --source-addresses "$subnet_cidr" \
    --protocols Http=80 Https=443 \
    --fqdn-tags AzureKubernetesService AzureContainerRegistry

  az network firewall policy rule-collection-group collection rule add \
    --resource-group "$hub_rg" \
    --policy-name "$policy" \
    --rule-collection-group-name "$rcg" \
    --collection-name "aks-application" \
    --name "acr-storage" \
    --rule-type ApplicationRule \
    --source-addresses "$subnet_cidr" \
    --protocols Https=443 \
    --target-fqdns '*.blob.core.windows.net' '*.blob.storage.azure.net'
}

configure_policy "$RG_HUB_PRIMARY" "$FW_POLICY_PRIMARY" "$RCG_PRIMARY" "$AKS_SUBNET_PRIMARY_CIDR" "$LOCATION_PRIMARY"
configure_policy "$RG_HUB_SECONDARY" "$FW_POLICY_SECONDARY" "$RCG_SECONDARY" "$AKS_SUBNET_SECONDARY_CIDR" "$LOCATION_SECONDARY"

az network vnet subnet update \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$AKS_SUBNET_PRIMARY" \
  --route-table "$ROUTE_TABLE_PRIMARY"

az network vnet subnet update \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$AKS_SUBNET_SECONDARY" \
  --route-table "$ROUTE_TABLE_SECONDARY"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$FIREWALL_PUBLIC_IP_PRIMARY = az network public-ip show `
  --resource-group $RG_HUB_PRIMARY `
  --name $FIREWALL_PIP_PRIMARY `
  --query ipAddress `
  --output tsv

$FIREWALL_PUBLIC_IP_SECONDARY = az network public-ip show `
  --resource-group $RG_HUB_SECONDARY `
  --name $FIREWALL_PIP_SECONDARY `
  --query ipAddress `
  --output tsv

az network route-table route create `
  --resource-group $RG_SPOKE_PRIMARY `
  --route-table-name $ROUTE_TABLE_PRIMARY `
  --name firewall-public-ip `
  --address-prefix "$FIREWALL_PUBLIC_IP_PRIMARY/32" `
  --next-hop-type Internet | Out-Null

az network route-table route create `
  --resource-group $RG_SPOKE_SECONDARY `
  --route-table-name $ROUTE_TABLE_SECONDARY `
  --name firewall-public-ip `
  --address-prefix "$FIREWALL_PUBLIC_IP_SECONDARY/32" `
  --next-hop-type Internet | Out-Null

function Configure-AksFirewallPolicy {
  param (
    [string]$HubResourceGroup,
    [string]$PolicyName,
    [string]$RuleCollectionGroupName,
    [string]$SubnetCidr,
    [string]$Location
  )

  az network firewall policy rule-collection-group create `
    --resource-group $HubResourceGroup `
    --policy-name $PolicyName `
    --name $RuleCollectionGroupName `
    --priority 200 | Out-Null

  az network firewall policy rule-collection-group collection add-filter-collection `
    --resource-group $HubResourceGroup `
    --policy-name $PolicyName `
    --rule-collection-group-name $RuleCollectionGroupName `
    --name aks-network `
    --action Allow `
    --collection-priority 200 `
    --rule-name aks-tcp-9000 `
    --rule-type NetworkRule `
    --source-addresses $SubnetCidr `
    --destination-addresses "AzureCloud.$Location" `
    --destination-ports 9000 `
    --ip-protocols TCP | Out-Null

  az network firewall policy rule-collection-group collection rule add `
    --resource-group $HubResourceGroup `
    --policy-name $PolicyName `
    --rule-collection-group-name $RuleCollectionGroupName `
    --collection-name aks-network `
    --name aks-udp-1194 `
    --rule-type NetworkRule `
    --source-addresses $SubnetCidr `
    --destination-addresses "AzureCloud.$Location" `
    --destination-ports 1194 `
    --ip-protocols UDP | Out-Null

  az network firewall policy rule-collection-group collection add-filter-collection `
    --resource-group $HubResourceGroup `
    --policy-name $PolicyName `
    --rule-collection-group-name $RuleCollectionGroupName `
    --name aks-application `
    --action Allow `
    --collection-priority 210 `
    --rule-name aks-core `
    --rule-type ApplicationRule `
    --source-addresses $SubnetCidr `
    --protocols Http=80 Https=443 `
    --fqdn-tags AzureKubernetesService AzureContainerRegistry | Out-Null

  az network firewall policy rule-collection-group collection rule add `
    --resource-group $HubResourceGroup `
    --policy-name $PolicyName `
    --rule-collection-group-name $RuleCollectionGroupName `
    --collection-name aks-application `
    --name acr-storage `
    --rule-type ApplicationRule `
    --source-addresses $SubnetCidr `
    --protocols Https=443 `
    --target-fqdns '*.blob.core.windows.net' '*.blob.storage.azure.net' | Out-Null
}

Configure-AksFirewallPolicy -HubResourceGroup $RG_HUB_PRIMARY -PolicyName $FW_POLICY_PRIMARY -RuleCollectionGroupName $RCG_PRIMARY -SubnetCidr $AKS_SUBNET_PRIMARY_CIDR -Location $LOCATION_PRIMARY
Configure-AksFirewallPolicy -HubResourceGroup $RG_HUB_SECONDARY -PolicyName $FW_POLICY_SECONDARY -RuleCollectionGroupName $RCG_SECONDARY -SubnetCidr $AKS_SUBNET_SECONDARY_CIDR -Location $LOCATION_SECONDARY

az network vnet subnet update `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $AKS_SUBNET_PRIMARY `
  --route-table $ROUTE_TABLE_PRIMARY | Out-Null

az network vnet subnet update `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $AKS_SUBNET_SECONDARY `
  --route-table $ROUTE_TABLE_SECONDARY | Out-Null
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Extend `afwp-hub-swc` and `afwp-hub-noe` with AKS- and ACR-related outbound allow rules.
2. Add an Internet exception route for each firewall public IP into the staged route tables.
3. Attach `rt-spoke-egress-swc` to the new Sweden Central AKS subnet and `rt-spoke-egress-noe` to the new Norway East AKS subnet.
4. Leave the Application Gateway subnet on the default system routes; only the AKS subnet gets the staged route table in this lab.

  </div>
</div>

## Step 5 — Create Regional Application Gateways and AKS Clusters in the Spokes

<div class="lab-note">
  <strong>Lab simplification:</strong> To keep the hands-on path reachable from your current workstation, the clusters in this lab use public API servers. In a production implementation, pair this pattern with <strong>API server authorized IP ranges</strong> or <strong>private clusters</strong>.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
ACR_ID=$(az acr show --resource-group "$RG_GLOBAL" --name "$ACR_NAME" --query id --output tsv)

create_region_stack() {
  local spoke_rg=$1
  local spoke_vnet=$2
  local location=$3
  local appgw_name=$4
  local appgw_pip=$5
  local appgw_subnet=$6
  local aks_subnet=$7
  local cluster_name=$8

  az network public-ip create \
    --resource-group "$spoke_rg" \
    --name "$appgw_pip" \
    --location "$location" \
    --sku Standard \
    --allocation-method Static

  az network application-gateway create \
    --resource-group "$spoke_rg" \
    --name "$appgw_name" \
    --location "$location" \
    --sku Standard_v2 \
    --public-ip-address "$appgw_pip" \
    --vnet-name "$spoke_vnet" \
    --subnet "$appgw_subnet" \
    --priority 100

  local aks_subnet_id
  aks_subnet_id=$(az network vnet subnet show \
    --resource-group "$spoke_rg" \
    --vnet-name "$spoke_vnet" \
    --name "$aks_subnet" \
    --query id \
    --output tsv)

  local appgw_id
  appgw_id=$(az network application-gateway show \
    --resource-group "$spoke_rg" \
    --name "$appgw_name" \
    --query id \
    --output tsv)

  az aks create \
    --resource-group "$spoke_rg" \
    --name "$cluster_name" \
    --location "$location" \
    --node-count 1 \
    --node-vm-size Standard_B2s \
    --network-plugin azure \
    --outbound-type userDefinedRouting \
    --vnet-subnet-id "$aks_subnet_id" \
    --enable-managed-identity \
    --attach-acr "$ACR_ID" \
    --enable-addons ingress-appgw \
    --appgw-id "$appgw_id" \
    --generate-ssh-keys
}

create_region_stack "$RG_SPOKE_PRIMARY" "$SPOKE_VNET_PRIMARY" "$LOCATION_PRIMARY" "$APPGW_PRIMARY" "$APPGW_PIP_PRIMARY" "$APPGW_SUBNET_PRIMARY" "$AKS_SUBNET_PRIMARY" "$PRIMARY_CLUSTER"
create_region_stack "$RG_SPOKE_SECONDARY" "$SPOKE_VNET_SECONDARY" "$LOCATION_SECONDARY" "$APPGW_SECONDARY" "$APPGW_PIP_SECONDARY" "$APPGW_SUBNET_SECONDARY" "$AKS_SUBNET_SECONDARY" "$SECONDARY_CLUSTER"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$ACR_ID = az acr show --resource-group $RG_GLOBAL --name $ACR_NAME --query id --output tsv

function New-RegionalAksStack {
  param (
    [string]$SpokeResourceGroup,
    [string]$SpokeVnet,
    [string]$Location,
    [string]$ApplicationGatewayName,
    [string]$ApplicationGatewayPublicIp,
    [string]$ApplicationGatewaySubnet,
    [string]$AksSubnet,
    [string]$ClusterName
  )

  az network public-ip create `
    --resource-group $SpokeResourceGroup `
    --name $ApplicationGatewayPublicIp `
    --location $Location `
    --sku Standard `
    --allocation-method Static | Out-Null

  az network application-gateway create `
    --resource-group $SpokeResourceGroup `
    --name $ApplicationGatewayName `
    --location $Location `
    --sku Standard_v2 `
    --public-ip-address $ApplicationGatewayPublicIp `
    --vnet-name $SpokeVnet `
    --subnet $ApplicationGatewaySubnet `
    --priority 100 | Out-Null

  $AksSubnetId = az network vnet subnet show `
    --resource-group $SpokeResourceGroup `
    --vnet-name $SpokeVnet `
    --name $AksSubnet `
    --query id `
    --output tsv

  $ApplicationGatewayId = az network application-gateway show `
    --resource-group $SpokeResourceGroup `
    --name $ApplicationGatewayName `
    --query id `
    --output tsv

  az aks create `
    --resource-group $SpokeResourceGroup `
    --name $ClusterName `
    --location $Location `
    --node-count 1 `
    --node-vm-size Standard_B2s `
    --network-plugin azure `
    --outbound-type userDefinedRouting `
    --vnet-subnet-id $AksSubnetId `
    --enable-managed-identity `
    --attach-acr $ACR_ID `
    --enable-addons ingress-appgw `
    --appgw-id $ApplicationGatewayId `
    --generate-ssh-keys | Out-Null
}

New-RegionalAksStack -SpokeResourceGroup $RG_SPOKE_PRIMARY -SpokeVnet $SPOKE_VNET_PRIMARY -Location $LOCATION_PRIMARY -ApplicationGatewayName $APPGW_PRIMARY -ApplicationGatewayPublicIp $APPGW_PIP_PRIMARY -ApplicationGatewaySubnet $APPGW_SUBNET_PRIMARY -AksSubnet $AKS_SUBNET_PRIMARY -ClusterName $PRIMARY_CLUSTER
New-RegionalAksStack -SpokeResourceGroup $RG_SPOKE_SECONDARY -SpokeVnet $SPOKE_VNET_SECONDARY -Location $LOCATION_SECONDARY -ApplicationGatewayName $APPGW_SECONDARY -ApplicationGatewayPublicIp $APPGW_PIP_SECONDARY -ApplicationGatewaySubnet $APPGW_SUBNET_SECONDARY -AksSubnet $AKS_SUBNET_SECONDARY -ClusterName $SECONDARY_CLUSTER
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create one regional Application Gateway in each spoke VNet, each with its own dedicated subnet and public IP.
2. Create one AKS cluster in each spoke resource group and place each cluster in the dedicated `snet-aks` subnet.
3. Attach the shared Premium ACR to both clusters.
4. Enable the **Application Gateway Ingress Controller add-on** so each gateway becomes the regional ingress layer for its cluster.

  </div>
</div>

## Step 6 — Create a Fleet and Join Both Regional Clusters

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_CLUSTER_ID=$(az aks show --resource-group "$RG_SPOKE_PRIMARY" --name "$PRIMARY_CLUSTER" --query id --output tsv)
SECONDARY_CLUSTER_ID=$(az aks show --resource-group "$RG_SPOKE_SECONDARY" --name "$SECONDARY_CLUSTER" --query id --output tsv)

az fleet create \
  --resource-group "$RG_GLOBAL" \
  --location "$LOCATION_PRIMARY" \
  --name "$FLEET_NAME" \
  --enable-managed-identity

az fleet member create \
  --resource-group "$RG_GLOBAL" \
  --fleet-name "$FLEET_NAME" \
  --name "$PRIMARY_CLUSTER" \
  --member-cluster-id "$PRIMARY_CLUSTER_ID" \
  --labels region=swc topology=spoke role=primary \
  --update-group blue

az fleet member create \
  --resource-group "$RG_GLOBAL" \
  --fleet-name "$FLEET_NAME" \
  --name "$SECONDARY_CLUSTER" \
  --member-cluster-id "$SECONDARY_CLUSTER_ID" \
  --labels region=noe topology=spoke role=secondary \
  --update-group green

az fleet member list \
  --resource-group "$RG_GLOBAL" \
  --fleet-name "$FLEET_NAME" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_CLUSTER_ID = az aks show --resource-group $RG_SPOKE_PRIMARY --name $PRIMARY_CLUSTER --query id --output tsv
$SECONDARY_CLUSTER_ID = az aks show --resource-group $RG_SPOKE_SECONDARY --name $SECONDARY_CLUSTER --query id --output tsv

az fleet create `
  --resource-group $RG_GLOBAL `
  --location $LOCATION_PRIMARY `
  --name $FLEET_NAME `
  --enable-managed-identity | Out-Null

az fleet member create `
  --resource-group $RG_GLOBAL `
  --fleet-name $FLEET_NAME `
  --name $PRIMARY_CLUSTER `
  --member-cluster-id $PRIMARY_CLUSTER_ID `
  --labels region=swc topology=spoke role=primary `
  --update-group blue | Out-Null

az fleet member create `
  --resource-group $RG_GLOBAL `
  --fleet-name $FLEET_NAME `
  --name $SECONDARY_CLUSTER `
  --member-cluster-id $SECONDARY_CLUSTER_ID `
  --labels region=noe topology=spoke role=secondary `
  --update-group green | Out-Null

az fleet member list `
  --resource-group $RG_GLOBAL `
  --fleet-name $FLEET_NAME `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a Fleet resource in the global resource group.
2. Add both spoke-based AKS clusters as fleet members.
3. Label the members so you can reason about region and topology later.
4. Confirm the fleet sees both members before you deploy the workload.

  </div>
</div>

## Step 7 — Deploy the Regional Workload Behind Application Gateway

<div class="lab-note">
  <strong>Patience note:</strong> The Application Gateway Ingress Controller can take a few minutes to reconcile the ingress objects and program the gateway listeners and backend pools.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
REGISTRY_FQDN=$(az acr show --resource-group "$RG_GLOBAL" --name "$ACR_NAME" --query loginServer --output tsv)
PRIMARY_CONTEXT="$PRIMARY_CLUSTER-ctx"
SECONDARY_CONTEXT="$SECONDARY_CLUSTER-ctx"

az aks get-credentials --resource-group "$RG_SPOKE_PRIMARY" --name "$PRIMARY_CLUSTER" --context "$PRIMARY_CONTEXT" --overwrite-existing
az aks get-credentials --resource-group "$RG_SPOKE_SECONDARY" --name "$SECONDARY_CLUSTER" --context "$SECONDARY_CONTEXT" --overwrite-existing

deploy_region() {
  local context=$1
  local region_label=$2

  cat <<EOF | kubectl --context "$context" apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: web
        image: $REGISTRY_FQDN/regional-app:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        env:
        - name: APP_REGION
          value: $region_label
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  type: ClusterIP
  selector:
    app: $APP_NAME
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/health-probe-path: /
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $APP_NAME
            port:
              number: 80
EOF
}

deploy_region "$PRIMARY_CONTEXT" "Sweden Central"
deploy_region "$SECONDARY_CONTEXT" "Norway East"

PRIMARY_APPGW_IP=$(az network public-ip show --resource-group "$RG_SPOKE_PRIMARY" --name "$APPGW_PIP_PRIMARY" --query ipAddress --output tsv)
SECONDARY_APPGW_IP=$(az network public-ip show --resource-group "$RG_SPOKE_SECONDARY" --name "$APPGW_PIP_SECONDARY" --query ipAddress --output tsv)

wait_for_region() {
  local label=$1
  local ip=$2
  for attempt in {1..20}; do
    echo "$label Application Gateway attempt $attempt"
    if curl -fsS "http://$ip"; then
      break
    fi
    sleep 15
  done
}

kubectl --context "$PRIMARY_CONTEXT" --namespace "$NAMESPACE" get ingress
kubectl --context "$SECONDARY_CONTEXT" --namespace "$NAMESPACE" get ingress

wait_for_region "Primary" "$PRIMARY_APPGW_IP"
wait_for_region "Secondary" "$SECONDARY_APPGW_IP"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$REGISTRY_FQDN = az acr show --resource-group $RG_GLOBAL --name $ACR_NAME --query loginServer --output tsv
$PRIMARY_CONTEXT = "$PRIMARY_CLUSTER-ctx"
$SECONDARY_CONTEXT = "$SECONDARY_CLUSTER-ctx"

az aks get-credentials --resource-group $RG_SPOKE_PRIMARY --name $PRIMARY_CLUSTER --context $PRIMARY_CONTEXT --overwrite-existing | Out-Null
az aks get-credentials --resource-group $RG_SPOKE_SECONDARY --name $SECONDARY_CLUSTER --context $SECONDARY_CONTEXT --overwrite-existing | Out-Null

function Deploy-RegionalIngressWorkload {
  param (
    [string]$Context,
    [string]$RegionLabel
  )

  $Manifest = @"
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: web
        image: $REGISTRY_FQDN/regional-app:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        env:
        - name: APP_REGION
          value: $RegionLabel
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  type: ClusterIP
  selector:
    app: $APP_NAME
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/health-probe-path: /
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $APP_NAME
            port:
              number: 80
"@

  $Manifest | kubectl --context $Context apply -f -
}

Deploy-RegionalIngressWorkload -Context $PRIMARY_CONTEXT -RegionLabel 'Sweden Central'
Deploy-RegionalIngressWorkload -Context $SECONDARY_CONTEXT -RegionLabel 'Norway East'

$PRIMARY_APPGW_IP = az network public-ip show --resource-group $RG_SPOKE_PRIMARY --name $APPGW_PIP_PRIMARY --query ipAddress --output tsv
$SECONDARY_APPGW_IP = az network public-ip show --resource-group $RG_SPOKE_SECONDARY --name $APPGW_PIP_SECONDARY --query ipAddress --output tsv

kubectl --context $PRIMARY_CONTEXT --namespace $NAMESPACE get ingress
kubectl --context $SECONDARY_CONTEXT --namespace $NAMESPACE get ingress

1..20 | ForEach-Object {
  Write-Host "Primary Application Gateway attempt $_"
  try {
    (Invoke-WebRequest -Uri "http://$PRIMARY_APPGW_IP" -UseBasicParsing).Content
    break
  } catch {
    Start-Sleep -Seconds 15
  }
}

1..20 | ForEach-Object {
  Write-Host "Secondary Application Gateway attempt $_"
  try {
    (Invoke-WebRequest -Uri "http://$SECONDARY_APPGW_IP" -UseBasicParsing).Content
    break
  } catch {
    Start-Sleep -Seconds 15
  }
}
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Get `kubectl` access to both AKS clusters.
2. Deploy the same application to both clusters, but set the `APP_REGION` environment variable differently in each region.
3. Expose the app through a **ClusterIP** service and an **Ingress** object instead of a public `LoadBalancer` service.
4. Wait until each regional Application Gateway begins returning its regional greeting before you add Azure Front Door.

  </div>
</div>

## Step 8 — Put Azure Front Door in Front of Both Regional Application Gateways

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az afd profile create \
  --resource-group "$RG_GLOBAL" \
  --profile-name "$AFD_PROFILE" \
  --sku Standard_AzureFrontDoor

az afd endpoint create \
  --resource-group "$RG_GLOBAL" \
  --profile-name "$AFD_PROFILE" \
  --endpoint-name "$AFD_ENDPOINT" \
  --enabled-state Enabled

az afd origin-group create \
  --resource-group "$RG_GLOBAL" \
  --profile-name "$AFD_PROFILE" \
  --origin-group-name "$ORIGIN_GROUP" \
  --enable-health-probe true \
  --probe-path / \
  --probe-request-type GET \
  --probe-protocol Http \
  --probe-interval-in-seconds 30 \
  --sample-size 4 \
  --successful-samples-required 3

az afd origin create \
  --resource-group "$RG_GLOBAL" \
  --profile-name "$AFD_PROFILE" \
  --origin-group-name "$ORIGIN_GROUP" \
  --origin-name origin-swc \
  --host-name "$PRIMARY_APPGW_IP" \
  --origin-host-header "$PRIMARY_APPGW_IP" \
  --http-port 80 \
  --priority 1 \
  --weight 500 \
  --enabled-state Enabled

az afd origin create \
  --resource-group "$RG_GLOBAL" \
  --profile-name "$AFD_PROFILE" \
  --origin-group-name "$ORIGIN_GROUP" \
  --origin-name origin-noe \
  --host-name "$SECONDARY_APPGW_IP" \
  --origin-host-header "$SECONDARY_APPGW_IP" \
  --http-port 80 \
  --priority 1 \
  --weight 500 \
  --enabled-state Enabled

az afd route create \
  --resource-group "$RG_GLOBAL" \
  --profile-name "$AFD_PROFILE" \
  --endpoint-name "$AFD_ENDPOINT" \
  --route-name route-default \
  --origin-group "$ORIGIN_GROUP" \
  --patterns-to-match '/*' \
  --supported-protocols Http Https \
  --forwarding-protocol HttpOnly \
  --https-redirect Disabled \
  --link-to-default-domain Enabled

AFD_HOST=$(az afd endpoint show \
  --resource-group "$RG_GLOBAL" \
  --profile-name "$AFD_PROFILE" \
  --endpoint-name "$AFD_ENDPOINT" \
  --query hostName \
  --output tsv)

curl -s "http://$AFD_HOST"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az afd profile create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --sku Standard_AzureFrontDoor | Out-Null

az afd endpoint create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --endpoint-name $AFD_ENDPOINT `
  --enabled-state Enabled | Out-Null

az afd origin-group create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --origin-group-name $ORIGIN_GROUP `
  --enable-health-probe true `
  --probe-path / `
  --probe-request-type GET `
  --probe-protocol Http `
  --probe-interval-in-seconds 30 `
  --sample-size 4 `
  --successful-samples-required 3 | Out-Null

az afd origin create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --origin-group-name $ORIGIN_GROUP `
  --origin-name origin-swc `
  --host-name $PRIMARY_APPGW_IP `
  --origin-host-header $PRIMARY_APPGW_IP `
  --http-port 80 `
  --priority 1 `
  --weight 500 `
  --enabled-state Enabled | Out-Null

az afd origin create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --origin-group-name $ORIGIN_GROUP `
  --origin-name origin-noe `
  --host-name $SECONDARY_APPGW_IP `
  --origin-host-header $SECONDARY_APPGW_IP `
  --http-port 80 `
  --priority 1 `
  --weight 500 `
  --enabled-state Enabled | Out-Null

az afd route create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --endpoint-name $AFD_ENDPOINT `
  --route-name route-default `
  --origin-group $ORIGIN_GROUP `
  --patterns-to-match '/*' `
  --supported-protocols Http Https `
  --forwarding-protocol HttpOnly `
  --https-redirect Disabled `
  --link-to-default-domain Enabled | Out-Null

$AFD_HOST = az afd endpoint show `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --endpoint-name $AFD_ENDPOINT `
  --query hostName `
  --output tsv

(Invoke-WebRequest -Uri "http://$AFD_HOST" -UseBasicParsing).Content
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create an **Azure Front Door Standard** profile and endpoint.
2. Add one origin group with health probes against `/`.
3. Register the two regional Application Gateways as origins.
4. Create a default route that links the Front Door hostname to the origin group.
5. Validate that the Front Door hostname returns one of the regional responses.

  </div>
</div>

## Step 9 — Simulate a Regional Failure and Watch the Secure Path Fail Over

<div class="lab-note">
  <strong>Expected behavior:</strong> This drill usually takes a little longer than Lab 12-a because both Application Gateway and Front Door need to observe the unhealthy primary path.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
kubectl --context "$PRIMARY_CONTEXT" --namespace "$NAMESPACE" scale deployment "$APP_NAME" --replicas=0

for attempt in {1..15}; do
  echo "Attempt $attempt"
  curl -s "http://$AFD_HOST"
  sleep 20
done

kubectl --context "$PRIMARY_CONTEXT" --namespace "$NAMESPACE" scale deployment "$APP_NAME" --replicas=2
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
kubectl --context $PRIMARY_CONTEXT --namespace $NAMESPACE scale deployment $APP_NAME --replicas=0

1..15 | ForEach-Object {
  Write-Host "Attempt $_"
  (Invoke-WebRequest -Uri "http://$AFD_HOST" -UseBasicParsing).Content
  Start-Sleep -Seconds 20
}

kubectl --context $PRIMARY_CONTEXT --namespace $NAMESPACE scale deployment $APP_NAME --replicas=2
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Scale the Sweden Central deployment down to zero replicas.
2. Refresh the Front Door hostname until the response shifts to **Norway East**.
3. Restore the Sweden Central deployment after the drill so both regions become healthy again.
4. Notice that this version fails over through the regional ingress layer, not directly to a cluster public service IP.

  </div>
</div>

## Step 10 — Cleanup

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az aks delete --resource-group "$RG_SPOKE_PRIMARY" --name "$PRIMARY_CLUSTER" --yes --no-wait
az aks delete --resource-group "$RG_SPOKE_SECONDARY" --name "$SECONDARY_CLUSTER" --yes --no-wait

az aks wait --resource-group "$RG_SPOKE_PRIMARY" --name "$PRIMARY_CLUSTER" --deleted
az aks wait --resource-group "$RG_SPOKE_SECONDARY" --name "$SECONDARY_CLUSTER" --deleted

az network application-gateway delete --resource-group "$RG_SPOKE_PRIMARY" --name "$APPGW_PRIMARY"
az network application-gateway delete --resource-group "$RG_SPOKE_SECONDARY" --name "$APPGW_SECONDARY"

az network public-ip delete --resource-group "$RG_SPOKE_PRIMARY" --name "$APPGW_PIP_PRIMARY"
az network public-ip delete --resource-group "$RG_SPOKE_SECONDARY" --name "$APPGW_PIP_SECONDARY"

az network vnet subnet update \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$AKS_SUBNET_PRIMARY" \
  --remove routeTable

az network vnet subnet update \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$AKS_SUBNET_SECONDARY" \
  --remove routeTable

az network vnet subnet delete --resource-group "$RG_SPOKE_PRIMARY" --vnet-name "$SPOKE_VNET_PRIMARY" --name "$APPGW_SUBNET_PRIMARY"
az network vnet subnet delete --resource-group "$RG_SPOKE_PRIMARY" --vnet-name "$SPOKE_VNET_PRIMARY" --name "$AKS_SUBNET_PRIMARY"
az network vnet subnet delete --resource-group "$RG_SPOKE_SECONDARY" --vnet-name "$SPOKE_VNET_SECONDARY" --name "$APPGW_SUBNET_SECONDARY"
az network vnet subnet delete --resource-group "$RG_SPOKE_SECONDARY" --vnet-name "$SPOKE_VNET_SECONDARY" --name "$AKS_SUBNET_SECONDARY"

az network route-table route delete --resource-group "$RG_SPOKE_PRIMARY" --route-table-name "$ROUTE_TABLE_PRIMARY" --name "firewall-public-ip"
az network route-table route delete --resource-group "$RG_SPOKE_SECONDARY" --route-table-name "$ROUTE_TABLE_SECONDARY" --name "firewall-public-ip"

az network firewall policy rule-collection-group delete --resource-group "$RG_HUB_PRIMARY" --policy-name "$FW_POLICY_PRIMARY" --name "$RCG_PRIMARY"
az network firewall policy rule-collection-group delete --resource-group "$RG_HUB_SECONDARY" --policy-name "$FW_POLICY_SECONDARY" --name "$RCG_SECONDARY"

az group delete --name "$RG_GLOBAL" --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az aks delete --resource-group $RG_SPOKE_PRIMARY --name $PRIMARY_CLUSTER --yes --no-wait
az aks delete --resource-group $RG_SPOKE_SECONDARY --name $SECONDARY_CLUSTER --yes --no-wait

az aks wait --resource-group $RG_SPOKE_PRIMARY --name $PRIMARY_CLUSTER --deleted
az aks wait --resource-group $RG_SPOKE_SECONDARY --name $SECONDARY_CLUSTER --deleted

az network application-gateway delete --resource-group $RG_SPOKE_PRIMARY --name $APPGW_PRIMARY
az network application-gateway delete --resource-group $RG_SPOKE_SECONDARY --name $APPGW_SECONDARY

az network public-ip delete --resource-group $RG_SPOKE_PRIMARY --name $APPGW_PIP_PRIMARY
az network public-ip delete --resource-group $RG_SPOKE_SECONDARY --name $APPGW_PIP_SECONDARY

az network vnet subnet update `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $AKS_SUBNET_PRIMARY `
  --remove routeTable | Out-Null

az network vnet subnet update `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $AKS_SUBNET_SECONDARY `
  --remove routeTable | Out-Null

az network vnet subnet delete --resource-group $RG_SPOKE_PRIMARY --vnet-name $SPOKE_VNET_PRIMARY --name $APPGW_SUBNET_PRIMARY
az network vnet subnet delete --resource-group $RG_SPOKE_PRIMARY --vnet-name $SPOKE_VNET_PRIMARY --name $AKS_SUBNET_PRIMARY
az network vnet subnet delete --resource-group $RG_SPOKE_SECONDARY --vnet-name $SPOKE_VNET_SECONDARY --name $APPGW_SUBNET_SECONDARY
az network vnet subnet delete --resource-group $RG_SPOKE_SECONDARY --vnet-name $SPOKE_VNET_SECONDARY --name $AKS_SUBNET_SECONDARY

az network route-table route delete --resource-group $RG_SPOKE_PRIMARY --route-table-name $ROUTE_TABLE_PRIMARY --name firewall-public-ip
az network route-table route delete --resource-group $RG_SPOKE_SECONDARY --route-table-name $ROUTE_TABLE_SECONDARY --name firewall-public-ip

az network firewall policy rule-collection-group delete --resource-group $RG_HUB_PRIMARY --policy-name $FW_POLICY_PRIMARY --name $RCG_PRIMARY
az network firewall policy rule-collection-group delete --resource-group $RG_HUB_SECONDARY --policy-name $FW_POLICY_SECONDARY --name $RCG_SECONDARY

az group delete --name $RG_GLOBAL --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete both AKS clusters and wait for the managed `MC_*` resource groups to disappear.
2. Delete both regional Application Gateways and their public IPs.
3. Detach the staged route tables from the AKS subnets, then remove the new AKS and Application Gateway subnets.
4. Delete the firewall rule collection groups that this lab added to `afwp-hub-swc` and `afwp-hub-noe`.
5. Delete the global resource group that contains Front Door, Fleet, and ACR.

  </div>
</div>

---

## Key Takeaways

1. **Lab 0 becomes the landing zone for the secure AKS stamp.** You no longer invent ad hoc VNets for each cluster.
2. **Front Door plus regional Application Gateway is closer to the reference architecture** than routing directly to a public AKS service IP.
3. **Fleet still gives you coordination, not shared fate.** Each region remains independently deployable and independently recoverable.
4. **The staged route tables from Lab 0 matter now.** They let you graduate from the baseline public-edge lab to controlled AKS egress without rebuilding the topology.

---

## Further Reading

- [AKS multi-cluster multi-region reference architecture](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks-multi-region/aks-multi-cluster)
- [Azure Firewall + AKS egress control](https://learn.microsoft.com/azure/aks/limit-egress-traffic)
- [Application Gateway Ingress Controller add-on for AKS](https://learn.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-existing)
- [Azure Kubernetes Fleet Manager CLI reference](https://learn.microsoft.com/cli/azure/fleet)
- [Azure Front Door CLI reference](https://learn.microsoft.com/cli/azure/afd)
