---
layout: default
title: "Lab 7-b: Multi-Region Web App with Traffic Manager, VNet Integration & Private Endpoints"
---

[← Lab 7-a: Baseline Traffic Manager Variant](lab-07a-webapp-traffic-manager.md)

# Lab 7-b: Multi-Region Web App with Traffic Manager, VNet Integration & Private Endpoints

This secure variant assumes the **Lab 0 hub-and-spoke foundation already exists**. It keeps the same active-passive App Service + Traffic Manager pattern, but moves the supported outbound and dependency paths into the regional spoke VNets by using **App Service VNet integration**, **private DNS**, and **private endpoints**.

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

## Why This Secure Variant Exists

The baseline Traffic Manager lab proves **regional failover** for Azure App Service, but it leaves the application and its supporting calls on a mostly public path.

This `B` variant keeps the same multi-region pattern while hardening the parts that **do** support private networking:

- The **web apps** are deployed into the **Lab 0 spoke resource groups**
- Each web app uses **regional VNet integration** through `snet-appsvc-integration`
- Each regional **Key Vault** uses a **private endpoint** in `snet-private-endpoints`
- A shared **private DNS zone** lets the apps resolve Key Vault privately
- **Traffic Manager remains public DNS**, and the selected App Service listener still needs to stay internet reachable in this specific pattern

---

## Architecture

```
                         ┌──────────────────────────────────────┐
                         │      Azure Traffic Manager           │
                         │  tm-webapp-private-<suffix>         │
                         │  .trafficmanager.net                │
                         │  Routing: Priority                  │
                         └──────────────┬──────────────┬───────┘
                                        │              │
                              Priority 1│              │Priority 2
                                        │              │
                  ┌─────────────────────▼──┐      ┌───▼─────────────────────┐
                  │ Sweden Central spoke    │      │ Norway East spoke       │
                  │ rg-spoke-swc            │      │ rg-spoke-noe            │
                  │ vnet-spoke-swc          │      │ vnet-spoke-noe          │
                  │                         │      │                         │
                  │  App Service (public)   │      │  App Service (public)   │
                  │  app-secure-swc-xxxxx   │      │  app-secure-noe-xxxxx   │
                  │         │               │      │         │               │
                  │         │ outbound      │      │         │ outbound      │
                  │         ▼               │      │         ▼               │
                  │ snet-appsvc-integration │      │ snet-appsvc-integration │
                  │         │               │      │         │               │
                  │         ▼               │      │         ▼               │
                  │  Key Vault              │      │  Key Vault              │
                  │  kv7bswcxxxxx           │      │  kv7bnoexxxxx           │
                  │  private endpoint       │      │  private endpoint       │
                  │  snet-private-endpoints │      │  snet-private-endpoints │
                  └─────────────┬───────────┘      └───────────┬─────────────┘
                                │                              │
                                └──── Private DNS links ───────┘
                                   privatelink.vaultcore.azure.net
```

<div class="lab-note">
<strong>Important design boundary:</strong> this lab makes the <strong>app-to-dependency path private</strong>, but it does <strong>not</strong> make the Traffic Manager path private. Traffic Manager only routes to <strong>internet-facing</strong> endpoints, so the App Service listener that clients reach must remain a public-edge endpoint in this design.
</div>

---

## Prerequisites

| Requirement | Details |
|---|---|
| Lab 0 foundation | `rg-spoke-swc`, `rg-spoke-noe`, `vnet-spoke-swc`, `vnet-spoke-noe`, `snet-appsvc-integration`, and `snet-private-endpoints` must already exist |
| Azure subscription | Contributor or higher on the Lab 0 spoke resource groups and VNets |
| Azure CLI | v2.75 or later recommended |
| Shell | Bash, PowerShell 7+, or Azure Cloud Shell |
| Portal access | Needed for the portal-only path |
| Budget awareness | Private Endpoints add hourly cost; Traffic Manager and App Service continue to incur their normal charges |

---

## How These Tabs Work

This page uses the same interaction pattern as the rest of the lab series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behavior used in the existing labs.

---

## Sign In and Validate the Lab 0 Foundation

Before you deploy anything, confirm that the Lab 0 spoke resource groups, VNets, and subnets exist.

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

az group show --name "rg-spoke-swc" --query "{Name:name, Location:location}" -o table
az group show --name "rg-spoke-noe" --query "{Name:name, Location:location}" -o table

az network vnet subnet show \
  --resource-group "rg-spoke-swc" \
  --vnet-name "vnet-spoke-swc" \
  --name "snet-appsvc-integration" \
  --query "{Name:name, Prefix:addressPrefix, Delegations:delegations[].serviceName}" \
  -o jsonc

az network vnet subnet show \
  --resource-group "rg-spoke-swc" \
  --vnet-name "vnet-spoke-swc" \
  --name "snet-private-endpoints" \
  --query "{Name:name, Prefix:addressPrefix, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" \
  -o jsonc

az network vnet subnet show \
  --resource-group "rg-spoke-noe" \
  --vnet-name "vnet-spoke-noe" \
  --name "snet-appsvc-integration" \
  --query "{Name:name, Prefix:addressPrefix, Delegations:delegations[].serviceName}" \
  -o jsonc

az network vnet subnet show \
  --resource-group "rg-spoke-noe" \
  --vnet-name "vnet-spoke-noe" \
  --name "snet-private-endpoints" \
  --query "{Name:name, Prefix:addressPrefix, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" \
  -o jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"

az group show --name "rg-spoke-swc" --query "{Name:name, Location:location}" -o table
az group show --name "rg-spoke-noe" --query "{Name:name, Location:location}" -o table

az network vnet subnet show `
  --resource-group "rg-spoke-swc" `
  --vnet-name "vnet-spoke-swc" `
  --name "snet-appsvc-integration" `
  --query "{Name:name, Prefix:addressPrefix, Delegations:delegations[].serviceName}" `
  -o jsonc

az network vnet subnet show `
  --resource-group "rg-spoke-swc" `
  --vnet-name "vnet-spoke-swc" `
  --name "snet-private-endpoints" `
  --query "{Name:name, Prefix:addressPrefix, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" `
  -o jsonc

az network vnet subnet show `
  --resource-group "rg-spoke-noe" `
  --vnet-name "vnet-spoke-noe" `
  --name "snet-appsvc-integration" `
  --query "{Name:name, Prefix:addressPrefix, Delegations:delegations[].serviceName}" `
  -o jsonc

az network vnet subnet show `
  --resource-group "rg-spoke-noe" `
  --vnet-name "vnet-spoke-noe" `
  --name "snet-private-endpoints" `
  --query "{Name:name, Prefix:addressPrefix, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" `
  -o jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the [Azure portal](https://portal.azure.com).
2. Confirm the correct subscription under **Subscriptions**.
3. Open **Resource groups** and verify both `rg-spoke-swc` and `rg-spoke-noe` exist.
4. Open **Virtual networks** and confirm both `vnet-spoke-swc` and `vnet-spoke-noe` exist.
5. In each spoke VNet, confirm these subnets exist:
   - `snet-appsvc-integration`
   - `snet-private-endpoints`
6. On `snet-private-endpoints`, confirm **Private endpoint network policies** are disabled.

</div>
</div>

<div class="lab-note">
<strong>If these resources are missing:</strong> stop here and complete the Lab 0 foundation first. This lab intentionally reuses those fixed spoke names instead of creating a second network layout.
</div>

---

## Step 1 — Define Variables

Use the Lab 0 spoke names directly, and add a random suffix for workload resources that must be unique.

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

PRIMARY_RG="rg-spoke-swc"
SECONDARY_RG="rg-spoke-noe"

PRIMARY_VNET="vnet-spoke-swc"
SECONDARY_VNET="vnet-spoke-noe"
INTEGRATION_SUBNET="snet-appsvc-integration"
PE_SUBNET="snet-private-endpoints"

RANDOM_SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | head -c 5)

PRIMARY_PLAN="plan-secure-swc-${RANDOM_SUFFIX}"
SECONDARY_PLAN="plan-secure-noe-${RANDOM_SUFFIX}"

PRIMARY_APP="app-secure-swc-${RANDOM_SUFFIX}"
SECONDARY_APP="app-secure-noe-${RANDOM_SUFFIX}"

PRIMARY_KV="kv7bswc${RANDOM_SUFFIX}"
SECONDARY_KV="kv7bnoe${RANDOM_SUFFIX}"
PRIMARY_KV_PE="pe-kv-swc-${RANDOM_SUFFIX}"
SECONDARY_KV_PE="pe-kv-noe-${RANDOM_SUFFIX}"

TM_PROFILE="tm-webapp-private-${RANDOM_SUFFIX}"
TM_DNS_NAME="tm-webapp-private-${RANDOM_SUFFIX}"
KV_DNS_ZONE="privatelink.vaultcore.azure.net"

printf 'Primary app:       %s\n' "$PRIMARY_APP"
printf 'Secondary app:     %s\n' "$SECONDARY_APP"
printf 'Primary Key Vault: %s\n' "$PRIMARY_KV"
printf 'Secondary Key Vault: %s\n' "$SECONDARY_KV"
printf 'Traffic Manager:   %s\n' "$TM_DNS_NAME"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$PRIMARY_RG = "rg-spoke-swc"
$SECONDARY_RG = "rg-spoke-noe"

$PRIMARY_VNET = "vnet-spoke-swc"
$SECONDARY_VNET = "vnet-spoke-noe"
$INTEGRATION_SUBNET = "snet-appsvc-integration"
$PE_SUBNET = "snet-private-endpoints"

$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$PRIMARY_PLAN = "plan-secure-swc-$RANDOM_SUFFIX"
$SECONDARY_PLAN = "plan-secure-noe-$RANDOM_SUFFIX"

$PRIMARY_APP = "app-secure-swc-$RANDOM_SUFFIX"
$SECONDARY_APP = "app-secure-noe-$RANDOM_SUFFIX"

$PRIMARY_KV = "kv7bswc$RANDOM_SUFFIX"
$SECONDARY_KV = "kv7bnoe$RANDOM_SUFFIX"
$PRIMARY_KV_PE = "pe-kv-swc-$RANDOM_SUFFIX"
$SECONDARY_KV_PE = "pe-kv-noe-$RANDOM_SUFFIX"

$TM_PROFILE = "tm-webapp-private-$RANDOM_SUFFIX"
$TM_DNS_NAME = "tm-webapp-private-$RANDOM_SUFFIX"
$KV_DNS_ZONE = "privatelink.vaultcore.azure.net"

Write-Host "Primary app:         $PRIMARY_APP"
Write-Host "Secondary app:       $SECONDARY_APP"
Write-Host "Primary Key Vault:   $PRIMARY_KV"
Write-Host "Secondary Key Vault: $SECONDARY_KV"
Write-Host "Traffic Manager:     $TM_DNS_NAME"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down these values before you start:

- Primary region: `swedencentral`
- Secondary region: `norwayeast`
- Spoke resource groups: `rg-spoke-swc`, `rg-spoke-noe`
- Spoke VNets: `vnet-spoke-swc`, `vnet-spoke-noe`
- Integration subnet: `snet-appsvc-integration`
- Private endpoint subnet: `snet-private-endpoints`
- App Service plans: `plan-secure-swc-<suffix>`, `plan-secure-noe-<suffix>`
- Web apps: `app-secure-swc-<suffix>`, `app-secure-noe-<suffix>`
- Key Vaults: `kv7bswc<suffix>`, `kv7bnoe<suffix>`
- Traffic Manager profile / DNS label: `tm-webapp-private-<suffix>`

</div>
</div>

---

## Step 2 — Delegate the App Service Integration Subnets

Lab 0 intentionally leaves `snet-appsvc-integration` reusable and undecorated. This lab now delegates it to `Microsoft.Web/serverFarms` so App Service can integrate with it.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet subnet update \
  --resource-group "$PRIMARY_RG" \
  --vnet-name "$PRIMARY_VNET" \
  --name "$INTEGRATION_SUBNET" \
  --delegations Microsoft.Web/serverFarms

az network vnet subnet update \
  --resource-group "$SECONDARY_RG" \
  --vnet-name "$SECONDARY_VNET" \
  --name "$INTEGRATION_SUBNET" \
  --delegations Microsoft.Web/serverFarms
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet subnet update `
  --resource-group $PRIMARY_RG `
  --vnet-name $PRIMARY_VNET `
  --name $INTEGRATION_SUBNET `
  --delegations Microsoft.Web/serverFarms

az network vnet subnet update `
  --resource-group $SECONDARY_RG `
  --vnet-name $SECONDARY_VNET `
  --name $INTEGRATION_SUBNET `
  --delegations Microsoft.Web/serverFarms
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `vnet-spoke-swc` and go to **Subnets**.
2. Select `snet-appsvc-integration`.
3. Set the subnet delegation to **Microsoft.Web/serverFarms** and save.
4. Repeat the same change for `vnet-spoke-noe/snet-appsvc-integration`.

</div>
</div>

<div class="lab-note">
<strong>Idempotent step:</strong> if the subnet is already delegated from an earlier run, leaving it as-is is fine.
</div>

---

## Step 3 — Create the App Service Plans and Web Apps

The apps live in the Lab 0 spoke resource groups so the workload and private dependencies stay aligned with the spoke network layout.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az appservice plan create \
  --name "$PRIMARY_PLAN" \
  --resource-group "$PRIMARY_RG" \
  --location "$PRIMARY_REGION" \
  --sku B1 \
  --is-linux

az appservice plan create \
  --name "$SECONDARY_PLAN" \
  --resource-group "$SECONDARY_RG" \
  --location "$SECONDARY_REGION" \
  --sku B1 \
  --is-linux

az webapp create \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --plan "$PRIMARY_PLAN" \
  --runtime "NODE:20-lts"

az webapp create \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --plan "$SECONDARY_PLAN" \
  --runtime "NODE:20-lts"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az appservice plan create `
  --name $PRIMARY_PLAN `
  --resource-group $PRIMARY_RG `
  --location $PRIMARY_REGION `
  --sku B1 `
  --is-linux

az appservice plan create `
  --name $SECONDARY_PLAN `
  --resource-group $SECONDARY_RG `
  --location $SECONDARY_REGION `
  --sku B1 `
  --is-linux

az webapp create `
  --name $PRIMARY_APP `
  --resource-group $PRIMARY_RG `
  --plan $PRIMARY_PLAN `
  --runtime "NODE:20-lts"

az webapp create `
  --name $SECONDARY_APP `
  --resource-group $SECONDARY_RG `
  --plan $SECONDARY_PLAN `
  --runtime "NODE:20-lts"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **App Service plans** and create a Linux **B1** plan in `rg-spoke-swc` named `plan-secure-swc-<suffix>`.
2. Create a matching Linux **B1** plan in `rg-spoke-noe` named `plan-secure-noe-<suffix>`.
3. Open **App Services** and create a Node 20 LTS Linux app in `rg-spoke-swc` named `app-secure-swc-<suffix>`.
4. Repeat in `rg-spoke-noe` with `app-secure-noe-<suffix>`.

</div>
</div>

---

## Step 4 — Enable Managed Identity, VNet Integration, and Route All

Each app gets a system-assigned identity for Key Vault access, then integrates with the regional spoke subnet for outbound private access.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az webapp identity assign --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG"
az webapp identity assign --name "$SECONDARY_APP" --resource-group "$SECONDARY_RG"

az webapp vnet-integration add \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --vnet "$PRIMARY_VNET" \
  --subnet "$INTEGRATION_SUBNET"

az webapp vnet-integration add \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --vnet "$SECONDARY_VNET" \
  --subnet "$INTEGRATION_SUBNET"

az webapp config set \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --vnet-route-all-enabled true

az webapp config set \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --vnet-route-all-enabled true

PRIMARY_PRINCIPAL_ID=$(az webapp identity show --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG" --query principalId -o tsv)
SECONDARY_PRINCIPAL_ID=$(az webapp identity show --name "$SECONDARY_APP" --resource-group "$SECONDARY_RG" --query principalId -o tsv)

echo "Primary principal ID:   $PRIMARY_PRINCIPAL_ID"
echo "Secondary principal ID: $SECONDARY_PRINCIPAL_ID"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az webapp identity assign --name $PRIMARY_APP --resource-group $PRIMARY_RG
az webapp identity assign --name $SECONDARY_APP --resource-group $SECONDARY_RG

az webapp vnet-integration add `
  --name $PRIMARY_APP `
  --resource-group $PRIMARY_RG `
  --vnet $PRIMARY_VNET `
  --subnet $INTEGRATION_SUBNET

az webapp vnet-integration add `
  --name $SECONDARY_APP `
  --resource-group $SECONDARY_RG `
  --vnet $SECONDARY_VNET `
  --subnet $INTEGRATION_SUBNET

az webapp config set `
  --name $PRIMARY_APP `
  --resource-group $PRIMARY_RG `
  --vnet-route-all-enabled true

az webapp config set `
  --name $SECONDARY_APP `
  --resource-group $SECONDARY_RG `
  --vnet-route-all-enabled true

$PRIMARY_PRINCIPAL_ID = az webapp identity show --name $PRIMARY_APP --resource-group $PRIMARY_RG --query principalId -o tsv
$SECONDARY_PRINCIPAL_ID = az webapp identity show --name $SECONDARY_APP --resource-group $SECONDARY_RG --query principalId -o tsv

Write-Host "Primary principal ID:   $PRIMARY_PRINCIPAL_ID"
Write-Host "Secondary principal ID: $SECONDARY_PRINCIPAL_ID"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

For each app:

1. Open **Identity** and turn on the **System assigned** identity.
2. Open **Networking > VNet integration** and add integration to the regional spoke VNet.
   - Sweden Central app → `vnet-spoke-swc` / `snet-appsvc-integration`
   - Norway East app → `vnet-spoke-noe` / `snet-appsvc-integration`
3. In the same networking area, enable the option that routes **all outbound traffic through the VNet**.
4. Record each app's principal ID from the **Identity** blade.

</div>
</div>

<div class="lab-note">
<strong>Why route all?</strong> Microsoft recommends enabling <code>vnetRouteAllEnabled</code> when Linux App Service needs to reach private endpoints such as a network-restricted Key Vault.
</div>

---

## Step 5 — Create Regional Key Vaults and Grant App Access

This lab uses a small regional secret as the application's dependency so you can verify that the app keeps working after each vault is restricted to private access.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault create \
  --name "$PRIMARY_KV" \
  --resource-group "$PRIMARY_RG" \
  --location "$PRIMARY_REGION" \
  --sku standard \
  --enable-rbac-authorization false \
  --public-network-access Enabled

az keyvault create \
  --name "$SECONDARY_KV" \
  --resource-group "$SECONDARY_RG" \
  --location "$SECONDARY_REGION" \
  --sku standard \
  --enable-rbac-authorization false \
  --public-network-access Enabled

az keyvault secret set \
  --vault-name "$PRIMARY_KV" \
  --name "banner-message" \
  --value "Hello from Sweden Central over Private Link"

az keyvault secret set \
  --vault-name "$SECONDARY_KV" \
  --name "banner-message" \
  --value "Hello from Norway East over Private Link"

az keyvault set-policy \
  --name "$PRIMARY_KV" \
  --resource-group "$PRIMARY_RG" \
  --object-id "$PRIMARY_PRINCIPAL_ID" \
  --secret-permissions get list

az keyvault set-policy \
  --name "$SECONDARY_KV" \
  --resource-group "$SECONDARY_RG" \
  --object-id "$SECONDARY_PRINCIPAL_ID" \
  --secret-permissions get list
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault create `
  --name $PRIMARY_KV `
  --resource-group $PRIMARY_RG `
  --location $PRIMARY_REGION `
  --sku standard `
  --enable-rbac-authorization false `
  --public-network-access Enabled

az keyvault create `
  --name $SECONDARY_KV `
  --resource-group $SECONDARY_RG `
  --location $SECONDARY_REGION `
  --sku standard `
  --enable-rbac-authorization false `
  --public-network-access Enabled

az keyvault secret set `
  --vault-name $PRIMARY_KV `
  --name "banner-message" `
  --value "Hello from Sweden Central over Private Link"

az keyvault secret set `
  --vault-name $SECONDARY_KV `
  --name "banner-message" `
  --value "Hello from Norway East over Private Link"

az keyvault set-policy `
  --name $PRIMARY_KV `
  --resource-group $PRIMARY_RG `
  --object-id $PRIMARY_PRINCIPAL_ID `
  --secret-permissions get list

az keyvault set-policy `
  --name $SECONDARY_KV `
  --resource-group $SECONDARY_RG `
  --object-id $SECONDARY_PRINCIPAL_ID `
  --secret-permissions get list
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Key vaults** and create one vault in each spoke resource group.
2. Use the **Vault access policy** permission model for this lab so you can grant the web app identity direct secret permissions.
3. Create a secret named `banner-message` in each vault.
   - Sweden Central value: `Hello from Sweden Central over Private Link`
   - Norway East value: `Hello from Norway East over Private Link`
4. In each vault, open **Access policies** and grant the corresponding web app's managed identity **Get** and **List** on secrets.
5. Leave **Public network access** enabled for the moment; you will disable it after the private endpoint is ready.

</div>
</div>

---

## Step 6 — Create Private DNS and Key Vault Private Endpoints

Now move the Key Vault data path off the public internet. The apps will keep using the vault's normal hostname, but private DNS will resolve it to the regional private endpoint.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_VNET_ID=$(az network vnet show --resource-group "$PRIMARY_RG" --name "$PRIMARY_VNET" --query id -o tsv)
SECONDARY_VNET_ID=$(az network vnet show --resource-group "$SECONDARY_RG" --name "$SECONDARY_VNET" --query id -o tsv)

PRIMARY_KV_ID=$(az keyvault show --name "$PRIMARY_KV" --resource-group "$PRIMARY_RG" --query id -o tsv)
SECONDARY_KV_ID=$(az keyvault show --name "$SECONDARY_KV" --resource-group "$SECONDARY_RG" --query id -o tsv)

az network private-dns zone create \
  --resource-group "$PRIMARY_RG" \
  --name "$KV_DNS_ZONE"

az network private-dns link vnet create \
  --resource-group "$PRIMARY_RG" \
  --zone-name "$KV_DNS_ZONE" \
  --name "link-${PRIMARY_VNET}" \
  --virtual-network "$PRIMARY_VNET_ID" \
  --registration-enabled false

az network private-dns link vnet create \
  --resource-group "$PRIMARY_RG" \
  --zone-name "$KV_DNS_ZONE" \
  --name "link-${SECONDARY_VNET}" \
  --virtual-network "$SECONDARY_VNET_ID" \
  --registration-enabled false

az network private-endpoint create \
  --name "$PRIMARY_KV_PE" \
  --resource-group "$PRIMARY_RG" \
  --location "$PRIMARY_REGION" \
  --vnet-name "$PRIMARY_VNET" \
  --subnet "$PE_SUBNET" \
  --private-connection-resource-id "$PRIMARY_KV_ID" \
  --group-id vault \
  --connection-name "${PRIMARY_KV_PE}-conn"

az network private-endpoint dns-zone-group create \
  --resource-group "$PRIMARY_RG" \
  --endpoint-name "$PRIMARY_KV_PE" \
  --name "default" \
  --private-dns-zone "$KV_DNS_ZONE" \
  --zone-name "$KV_DNS_ZONE"

az network private-endpoint create \
  --name "$SECONDARY_KV_PE" \
  --resource-group "$SECONDARY_RG" \
  --location "$SECONDARY_REGION" \
  --vnet-name "$SECONDARY_VNET" \
  --subnet "$PE_SUBNET" \
  --private-connection-resource-id "$SECONDARY_KV_ID" \
  --group-id vault \
  --connection-name "${SECONDARY_KV_PE}-conn"

az network private-endpoint dns-zone-group create \
  --resource-group "$SECONDARY_RG" \
  --endpoint-name "$SECONDARY_KV_PE" \
  --name "default" \
  --private-dns-zone "$KV_DNS_ZONE" \
  --zone-name "$KV_DNS_ZONE"

az keyvault update \
  --name "$PRIMARY_KV" \
  --resource-group "$PRIMARY_RG" \
  --public-network-access Disabled

az keyvault update \
  --name "$SECONDARY_KV" \
  --resource-group "$SECONDARY_RG" \
  --public-network-access Disabled
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_VNET_ID = az network vnet show --resource-group $PRIMARY_RG --name $PRIMARY_VNET --query id -o tsv
$SECONDARY_VNET_ID = az network vnet show --resource-group $SECONDARY_RG --name $SECONDARY_VNET --query id -o tsv

$PRIMARY_KV_ID = az keyvault show --name $PRIMARY_KV --resource-group $PRIMARY_RG --query id -o tsv
$SECONDARY_KV_ID = az keyvault show --name $SECONDARY_KV --resource-group $SECONDARY_RG --query id -o tsv

az network private-dns zone create `
  --resource-group $PRIMARY_RG `
  --name $KV_DNS_ZONE

az network private-dns link vnet create `
  --resource-group $PRIMARY_RG `
  --zone-name $KV_DNS_ZONE `
  --name "link-$PRIMARY_VNET" `
  --virtual-network $PRIMARY_VNET_ID `
  --registration-enabled false

az network private-dns link vnet create `
  --resource-group $PRIMARY_RG `
  --zone-name $KV_DNS_ZONE `
  --name "link-$SECONDARY_VNET" `
  --virtual-network $SECONDARY_VNET_ID `
  --registration-enabled false

az network private-endpoint create `
  --name $PRIMARY_KV_PE `
  --resource-group $PRIMARY_RG `
  --location $PRIMARY_REGION `
  --vnet-name $PRIMARY_VNET `
  --subnet $PE_SUBNET `
  --private-connection-resource-id $PRIMARY_KV_ID `
  --group-id vault `
  --connection-name "$PRIMARY_KV_PE-conn"

az network private-endpoint dns-zone-group create `
  --resource-group $PRIMARY_RG `
  --endpoint-name $PRIMARY_KV_PE `
  --name "default" `
  --private-dns-zone $KV_DNS_ZONE `
  --zone-name $KV_DNS_ZONE

az network private-endpoint create `
  --name $SECONDARY_KV_PE `
  --resource-group $SECONDARY_RG `
  --location $SECONDARY_REGION `
  --vnet-name $SECONDARY_VNET `
  --subnet $PE_SUBNET `
  --private-connection-resource-id $SECONDARY_KV_ID `
  --group-id vault `
  --connection-name "$SECONDARY_KV_PE-conn"

az network private-endpoint dns-zone-group create `
  --resource-group $SECONDARY_RG `
  --endpoint-name $SECONDARY_KV_PE `
  --name "default" `
  --private-dns-zone $KV_DNS_ZONE `
  --zone-name $KV_DNS_ZONE

az keyvault update `
  --name $PRIMARY_KV `
  --resource-group $PRIMARY_RG `
  --public-network-access Disabled

az keyvault update `
  --name $SECONDARY_KV `
  --resource-group $SECONDARY_RG `
  --public-network-access Disabled
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a **Private DNS zone** named `privatelink.vaultcore.azure.net`.
   - Put it in `rg-spoke-swc` so it stays near the spoke networking artifacts.
2. Link the zone to both spoke VNets with auto-registration disabled.
3. For each Key Vault, open **Networking > Private endpoint connections** and create a private endpoint.
   - Sweden Central vault → `vnet-spoke-swc` / `snet-private-endpoints`
   - Norway East vault → `vnet-spoke-noe` / `snet-private-endpoints`
4. During private endpoint creation, integrate each endpoint with the existing private DNS zone.
5. After both private endpoints show as approved, go back to each Key Vault and set **Public network access** to **Disabled**.

</div>
</div>

<div class="lab-note">
<strong>What is private now?</strong> the Key Vault data-plane path. The application still uses the normal vault hostname, but private DNS resolves that hostname to the private endpoint inside the spoke VNet.
</div>

---

## Step 7 — Deploy a Tiny Region-Aware App that Reads a Secret

The sample app prints the hostname, region, timestamp, and a banner value resolved from each region's Key Vault. The app code stays simple because App Service resolves the Key Vault reference into an app setting for you.

### Shared app files

`index.js`

```javascript
const http = require("http");
const os = require("os");

const server = http.createServer((req, res) => {
  const region = process.env.REGION || "unknown";
  const banner = process.env.BANNER_MESSAGE || "Key Vault reference not resolved";

  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Secure Multi-Region Resiliency Lab</title>
    <style>
      body { font-family: "Segoe UI", system-ui, sans-serif; margin: 40px; background: #f6f8fa; color: #24292f; }
      .card { max-width: 760px; padding: 28px; border-radius: 16px; background: #ffffff; box-shadow: 0 12px 28px rgba(31, 35, 40, 0.08); }
      h1 { margin-top: 0; }
      .label { color: #57606a; font-size: 0.9rem; margin-top: 1rem; }
      .value { font-size: 1.15rem; font-weight: 700; }
    </style>
  </head>
  <body>
    <div class="card">
      <h1>Secure Multi-Region Resiliency Lab</h1>
      <div class="label">Hostname</div>
      <div class="value">${os.hostname()}</div>
      <div class="label">Region</div>
      <div class="value">${region}</div>
      <div class="label">Banner</div>
      <div class="value">${banner}</div>
      <div class="label">Timestamp</div>
      <div class="value">${new Date().toISOString()}</div>
    </div>
  </body>
</html>`);
});

server.listen(process.env.PORT || 8080);
```

`package.json`

```json
{
  "name": "secure-dr-webapp",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js"
  }
}
```

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
LAB_ROOT="$HOME/lab07b-webapp"
ZIP_PATH="$HOME/lab07b-webapp.zip"

mkdir -p "$LAB_ROOT"

cat > "$LAB_ROOT/index.js" <<'EOF'
const http = require("http");
const os = require("os");

const server = http.createServer((req, res) => {
  const region = process.env.REGION || "unknown";
  const banner = process.env.BANNER_MESSAGE || "Key Vault reference not resolved";

  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Secure Multi-Region Resiliency Lab</title>
  </head>
  <body>
    <h1>Secure Multi-Region Resiliency Lab</h1>
    <p><strong>Hostname:</strong> ${os.hostname()}</p>
    <p><strong>Region:</strong> ${region}</p>
    <p><strong>Banner:</strong> ${banner}</p>
    <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
  </body>
</html>`);
});

server.listen(process.env.PORT || 8080);
EOF

cat > "$LAB_ROOT/package.json" <<'EOF'
{
  "name": "secure-dr-webapp",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js"
  }
}
EOF

(cd "$LAB_ROOT" && zip -qr "$ZIP_PATH" .)

az webapp config appsettings set \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --settings \
    REGION="$PRIMARY_REGION" \
    BANNER_MESSAGE="@Microsoft.KeyVault(VaultName=${PRIMARY_KV};SecretName=banner-message)"

az webapp config appsettings set \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --settings \
    REGION="$SECONDARY_REGION" \
    BANNER_MESSAGE="@Microsoft.KeyVault(VaultName=${SECONDARY_KV};SecretName=banner-message)"

az webapp deploy \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --src-path "$ZIP_PATH" \
  --type zip

az webapp deploy \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --src-path "$ZIP_PATH" \
  --type zip
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$LabRoot = Join-Path $HOME "lab07b-webapp"
$ZipPath = Join-Path $HOME "lab07b-webapp.zip"

New-Item -ItemType Directory -Path $LabRoot -Force | Out-Null

@'
const http = require("http");
const os = require("os");

const server = http.createServer((req, res) => {
  const region = process.env.REGION || "unknown";
  const banner = process.env.BANNER_MESSAGE || "Key Vault reference not resolved";

  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Secure Multi-Region Resiliency Lab</title>
  </head>
  <body>
    <h1>Secure Multi-Region Resiliency Lab</h1>
    <p><strong>Hostname:</strong> ${os.hostname()}</p>
    <p><strong>Region:</strong> ${region}</p>
    <p><strong>Banner:</strong> ${banner}</p>
    <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
  </body>
</html>`);
});

server.listen(process.env.PORT || 8080);
'@ | Set-Content -Path (Join-Path $LabRoot "index.js")

@'
{
  "name": "secure-dr-webapp",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js"
  }
}
'@ | Set-Content -Path (Join-Path $LabRoot "package.json")

if (Test-Path $ZipPath) {
  Remove-Item $ZipPath -Force
}

Compress-Archive -Path (Join-Path $LabRoot "*") -DestinationPath $ZipPath

az webapp config appsettings set `
  --name $PRIMARY_APP `
  --resource-group $PRIMARY_RG `
  --settings `
    REGION=$PRIMARY_REGION `
    BANNER_MESSAGE="@Microsoft.KeyVault(VaultName=$PRIMARY_KV;SecretName=banner-message)"

az webapp config appsettings set `
  --name $SECONDARY_APP `
  --resource-group $SECONDARY_RG `
  --settings `
    REGION=$SECONDARY_REGION `
    BANNER_MESSAGE="@Microsoft.KeyVault(VaultName=$SECONDARY_KV;SecretName=banner-message)"

az webapp deploy --name $PRIMARY_APP --resource-group $PRIMARY_RG --src-path $ZipPath --type zip
az webapp deploy --name $SECONDARY_APP --resource-group $SECONDARY_RG --src-path $ZipPath --type zip
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In each App Service, open **Configuration** and add these app settings:
   - `REGION`
   - `BANNER_MESSAGE`
2. Set the `BANNER_MESSAGE` values as Key Vault references:
   - Primary: `@Microsoft.KeyVault(VaultName=<primary-vault>;SecretName=banner-message)`
   - Secondary: `@Microsoft.KeyVault(VaultName=<secondary-vault>;SecretName=banner-message)`
3. Open **Development Tools > Advanced Tools** and launch Kudu for each app.
4. In Kudu, browse to `site/wwwroot` and upload `index.js` and `package.json` using the shared file contents above.
5. Restart each app from **Overview**.

</div>
</div>

---

## Step 8 — Verify Each App and Its Private Dependency Path

At this point, each app should still answer on its public `azurewebsites.net` address, but the Key Vault lookup should now succeed through the private endpoint because the vault itself no longer allows public data-plane traffic.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "Primary:   https://${PRIMARY_APP}.azurewebsites.net"
echo "Secondary: https://${SECONDARY_APP}.azurewebsites.net"

curl -s "https://${PRIMARY_APP}.azurewebsites.net" | head -25
curl -s "https://${SECONDARY_APP}.azurewebsites.net" | head -25

az keyvault show \
  --name "$PRIMARY_KV" \
  --resource-group "$PRIMARY_RG" \
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" \
  -o table

az keyvault show \
  --name "$SECONDARY_KV" \
  --resource-group "$SECONDARY_RG" \
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" \
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "Primary:   https://$PRIMARY_APP.azurewebsites.net"
Write-Host "Secondary: https://$SECONDARY_APP.azurewebsites.net"

(Invoke-WebRequest "https://$PRIMARY_APP.azurewebsites.net").Content
(Invoke-WebRequest "https://$SECONDARY_APP.azurewebsites.net").Content

az keyvault show `
  --name $PRIMARY_KV `
  --resource-group $PRIMARY_RG `
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" `
  -o table

az keyvault show `
  --name $SECONDARY_KV `
  --resource-group $SECONDARY_RG `
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" `
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open each App Service and select **Browse**.
2. Confirm each app shows its own hostname, region, and banner text from the regional Key Vault.
3. Open each Key Vault and confirm **Public network access** is disabled.
4. Open each Key Vault's **Private endpoint connections** blade and confirm the connection is approved.

</div>
</div>

<div class="lab-note">
<strong>Expected outcome:</strong> the app stays publicly reachable, but its secret dependency is no longer publicly reachable. The rendered banner proves the app can still reach the vault after public access was disabled on the vault.
</div>

---

## Step 9 — Create the Traffic Manager Profile

Traffic Manager stays the global DNS failover layer exactly as it does in the baseline lab.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network traffic-manager profile create \
  --name "$TM_PROFILE" \
  --resource-group "$PRIMARY_RG" \
  --routing-method Priority \
  --unique-dns-name "$TM_DNS_NAME" \
  --protocol HTTPS \
  --port 443 \
  --path "/" \
  --ttl 30
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network traffic-manager profile create `
  --name $TM_PROFILE `
  --resource-group $PRIMARY_RG `
  --routing-method Priority `
  --unique-dns-name $TM_DNS_NAME `
  --protocol HTTPS `
  --port 443 `
  --path "/" `
  --ttl 30
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Traffic Manager profiles** and create a new profile.
2. Use:
   - Name: `tm-webapp-private-<suffix>`
   - Resource group: `rg-spoke-swc`
   - Routing method: **Priority**
   - Relative DNS name: `tm-webapp-private-<suffix>`
3. In **Configuration**, set:
   - Protocol: **HTTPS**
   - Port: `443`
   - Path: `/`
   - TTL: `30`

</div>
</div>

---

## Step 10 — Add Both Web Apps as Endpoints

Primary gets priority **1** and secondary gets priority **2**, just like the baseline lab.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_APP_ID=$(az webapp show \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --query "id" -o tsv)

SECONDARY_APP_ID=$(az webapp show \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --query "id" -o tsv)

az network traffic-manager endpoint create \
  --name "primary-swedencentral" \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --type azureEndpoints \
  --target-resource-id "$PRIMARY_APP_ID" \
  --priority 1 \
  --endpoint-status Enabled

az network traffic-manager endpoint create \
  --name "secondary-norwayeast" \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --type azureEndpoints \
  --target-resource-id "$SECONDARY_APP_ID" \
  --priority 2 \
  --endpoint-status Enabled
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_APP_ID = az webapp show --name $PRIMARY_APP --resource-group $PRIMARY_RG --query "id" -o tsv
$SECONDARY_APP_ID = az webapp show --name $SECONDARY_APP --resource-group $SECONDARY_RG --query "id" -o tsv

az network traffic-manager endpoint create `
  --name "primary-swedencentral" `
  --resource-group $PRIMARY_RG `
  --profile-name $TM_PROFILE `
  --type azureEndpoints `
  --target-resource-id $PRIMARY_APP_ID `
  --priority 1 `
  --endpoint-status Enabled

az network traffic-manager endpoint create `
  --name "secondary-norwayeast" `
  --resource-group $PRIMARY_RG `
  --profile-name $TM_PROFILE `
  --type azureEndpoints `
  --target-resource-id $SECONDARY_APP_ID `
  --priority 2 `
  --endpoint-status Enabled
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Traffic Manager profile.
2. Go to **Endpoints > Add**.
3. Add the Sweden Central web app as an **Azure endpoint** with priority `1`.
4. Add the Norway East web app as an **Azure endpoint** with priority `2`.

</div>
</div>

---

## Step 11 — Validate Normal Routing and the Remaining Public Edge

<div class="lab-note">
<strong>Important:</strong> the dependency path to Key Vault is now private, but the <strong>Traffic Manager path is still public</strong>. Traffic Manager is DNS only, and it returns the hostname of a public App Service endpoint. Do <strong>not</strong> disable App Service public network access in this pattern unless you change to a different global entry design.
</div>

<div class="lab-note">
<strong>Host header note:</strong> as in the baseline lab, the <code>*.trafficmanager.net</code> name itself is not automatically a valid browser hostname for App Service. Use <strong>DNS resolution</strong> to validate failover unless you also bind a shared custom domain on both apps.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
TM_FQDN="${TM_DNS_NAME}.trafficmanager.net"

echo "Traffic Manager DNS name: $TM_FQDN"
nslookup "$TM_FQDN"

az network traffic-manager endpoint list \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --query "[].{Name:name, Priority:priority, Status:endpointStatus, MonitorStatus:endpointMonitorStatus}" \
  -o table

echo "Primary app public URL:   https://${PRIMARY_APP}.azurewebsites.net"
echo "Secondary app public URL: https://${SECONDARY_APP}.azurewebsites.net"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$TM_FQDN = "$TM_DNS_NAME.trafficmanager.net"

Write-Host "Traffic Manager DNS name: $TM_FQDN"
nslookup $TM_FQDN

az network traffic-manager endpoint list `
  --resource-group $PRIMARY_RG `
  --profile-name $TM_PROFILE `
  --query "[].{Name:name, Priority:priority, Status:endpointStatus, MonitorStatus:endpointMonitorStatus}" `
  -o table

Write-Host "Primary app public URL:   https://$PRIMARY_APP.azurewebsites.net"
Write-Host "Secondary app public URL: https://$SECONDARY_APP.azurewebsites.net"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Traffic Manager profile and confirm both endpoints are enabled.
2. Copy the Traffic Manager DNS name from **Overview**.
3. Use `nslookup` from a shell to confirm it resolves to the Sweden Central app during normal operation.
4. Record the direct public hostnames for both web apps so you can recognize which endpoint Traffic Manager is returning.

</div>
</div>

---

## Step 12 — Simulate Failover

This variant keeps the failover demo simple: stop the primary app and watch Traffic Manager switch to the secondary app.

<div class="lab-note">
<strong>Why manual stop here?</strong> Lab 7-a already covers the Chaos Studio path. In this secure networking variant, the focus is on the spoke/VNet/private-endpoint design while still validating the failover behavior.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az webapp stop --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG"
sleep 60

nslookup "${TM_DNS_NAME}.trafficmanager.net"

az network traffic-manager endpoint list \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" \
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az webapp stop --name $PRIMARY_APP --resource-group $PRIMARY_RG
Start-Sleep -Seconds 60

nslookup "$TM_DNS_NAME.trafficmanager.net"

az network traffic-manager endpoint list `
  --resource-group $PRIMARY_RG `
  --profile-name $TM_PROFILE `
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" `
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Sweden Central App Service.
2. Select **Stop** from **Overview**.
3. Wait about a minute, then use `nslookup` from a shell to confirm the Traffic Manager DNS name resolves to the Norway East app.
4. Check **Endpoints** in the Traffic Manager profile to watch the health state change.

</div>
</div>

<div class="lab-note">
<strong>DNS is the source of truth:</strong> the endpoint monitor view can lag slightly behind the actual DNS answer.
</div>

---

## Step 13 — Verify Recovery

Bring the primary app back online and confirm Traffic Manager returns to its normal priority order.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az webapp start --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG"
sleep 45

nslookup "${TM_DNS_NAME}.trafficmanager.net"

az network traffic-manager endpoint list \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" \
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az webapp start --name $PRIMARY_APP --resource-group $PRIMARY_RG
Start-Sleep -Seconds 45

nslookup "$TM_DNS_NAME.trafficmanager.net"

az network traffic-manager endpoint list `
  --resource-group $PRIMARY_RG `
  --profile-name $TM_PROFILE `
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" `
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Start the Sweden Central App Service again.
2. Wait for the app to become healthy.
3. Confirm the Traffic Manager DNS name resolves back to the Sweden Central app.
4. Verify both endpoints return to a healthy state in the Traffic Manager profile.

</div>
</div>

---

## Troubleshooting Notes

- **The app shows `Key Vault reference not resolved`**
  Verify four things together: the web app identity exists, the vault access policy includes **Get** and **List**, the app is VNet-integrated with `vnetRouteAllEnabled=true`, and the private DNS zone is linked to the spoke VNet.

- **The vault is private, but the app still cannot read the secret**
  Restart the app after changing VNet integration, app settings, or Key Vault networking. App Service refreshes Key Vault references on restart or other config changes.

- **Key Vault audit logs show one failed request and then one successful request**
  That can be expected. Microsoft documents that a network-restricted vault may log an initial 403 from the app's public path before the successful retry through the private path.

- **Traffic Manager does not fail over to a private-only app**
  That is by design. Traffic Manager requires internet-facing endpoints. If you disable App Service public ingress entirely, you need a different global entry pattern.

- **The Traffic Manager hostname shows a 404 page in the browser**
  That is the normal App Service host-header behavior unless you bind a custom domain on both apps.

- **`snet-appsvc-integration` is rejected during integration**
  Make sure the subnet is delegated to `Microsoft.Web/serverFarms` and isn't being used for unrelated resources.

---

## Validation Checklist

- [ ] The Lab 0 spoke resource groups and VNets are reused, not recreated
- [ ] Both web apps are deployed in the spoke resource groups
- [ ] Each web app is integrated with `snet-appsvc-integration`
- [ ] Each Key Vault has a private endpoint in `snet-private-endpoints`
- [ ] Public network access is disabled on both Key Vaults
- [ ] Each web app renders the region-specific banner value from its regional Key Vault
- [ ] Traffic Manager resolves to the primary app during normal operation
- [ ] During failover, Traffic Manager resolves to the secondary app
- [ ] After recovery, Traffic Manager resolves back to the primary app
- [ ] The remaining public-edge dependency is understood: Traffic Manager and the client-facing App Service listener stay public in this design

---

## Cleanup

<div class="lab-note">
<strong>Keep Lab 0 intact:</strong> delete only the workload resources created in this lab. Do <strong>not</strong> delete `rg-spoke-swc`, `rg-spoke-noe`, the spoke VNets, or the shared subnets if you plan to reuse the landing zone.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network traffic-manager profile delete \
  --name "$TM_PROFILE" \
  --resource-group "$PRIMARY_RG" \
  --yes

az webapp delete --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG"
az webapp delete --name "$SECONDARY_APP" --resource-group "$SECONDARY_RG"

az appservice plan delete --name "$PRIMARY_PLAN" --resource-group "$PRIMARY_RG" --yes
az appservice plan delete --name "$SECONDARY_PLAN" --resource-group "$SECONDARY_RG" --yes

az network private-endpoint delete --name "$PRIMARY_KV_PE" --resource-group "$PRIMARY_RG"
az network private-endpoint delete --name "$SECONDARY_KV_PE" --resource-group "$SECONDARY_RG"

az keyvault delete --name "$PRIMARY_KV" --resource-group "$PRIMARY_RG"
az keyvault delete --name "$SECONDARY_KV" --resource-group "$SECONDARY_RG"

az network private-dns zone delete \
  --name "$KV_DNS_ZONE" \
  --resource-group "$PRIMARY_RG" \
  --yes

rm -rf "$HOME/lab07b-webapp" "$HOME/lab07b-webapp.zip"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network traffic-manager profile delete `
  --name $TM_PROFILE `
  --resource-group $PRIMARY_RG `
  --yes

az webapp delete --name $PRIMARY_APP --resource-group $PRIMARY_RG
az webapp delete --name $SECONDARY_APP --resource-group $SECONDARY_RG

az appservice plan delete --name $PRIMARY_PLAN --resource-group $PRIMARY_RG --yes
az appservice plan delete --name $SECONDARY_PLAN --resource-group $SECONDARY_RG --yes

az network private-endpoint delete --name $PRIMARY_KV_PE --resource-group $PRIMARY_RG
az network private-endpoint delete --name $SECONDARY_KV_PE --resource-group $SECONDARY_RG

az keyvault delete --name $PRIMARY_KV --resource-group $PRIMARY_RG
az keyvault delete --name $SECONDARY_KV --resource-group $SECONDARY_RG

az network private-dns zone delete `
  --name $KV_DNS_ZONE `
  --resource-group $PRIMARY_RG `
  --yes

Remove-Item (Join-Path $HOME "lab07b-webapp") -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $HOME "lab07b-webapp.zip") -Force -ErrorAction SilentlyContinue
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete the Traffic Manager profile created for this lab.
2. Delete the two App Services and both App Service plans.
3. Delete the two Key Vault private endpoints.
4. Delete the two Key Vaults.
5. Delete the `privatelink.vaultcore.azure.net` private DNS zone **only if no other lab is reusing it**.
6. Leave the Lab 0 spoke resource groups, VNets, and subnets in place.

</div>
</div>

<div class="lab-note">
<strong>Shared DNS note:</strong> if another lab or workload is already reusing <code>privatelink.vaultcore.azure.net</code>, leave the zone in place and remove only the records/endpoints you created for this lab.
</div>

---

## Design Notes

### What became private in Lab 7-b?

- The **app-to-Key Vault** data path
- The **Key Vault listener**, via a regional private endpoint
- The **name resolution** for the vault hostname, via a private DNS zone linked to both spokes

### What is still public-edge?

- **Azure Traffic Manager** itself, because it is a public DNS service
- The **client-facing App Service hostname** that Traffic Manager returns
- Any browser or public client traffic that follows the Traffic Manager DNS answer

### Why not add an App Service private endpoint here?

App Service private endpoints are valid for private ingress, but **Traffic Manager cannot route to private-only endpoints**. In this specific lab pattern, the correct compromise is:

1. Keep **App Service ingress public** so Traffic Manager can steer clients.
2. Move the **supported dependency path** private with VNet integration and Private Link.
3. Use a different global entry design if your requirement is **private-only** app ingress.

[← Lab 7-a: Baseline Traffic Manager Variant](lab-07a-webapp-traffic-manager.md)
