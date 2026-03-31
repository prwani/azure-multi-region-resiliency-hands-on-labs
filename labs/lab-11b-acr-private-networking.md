---
layout: default
title: "Lab 11-b: Azure Container Registry – Private Networking"
---

[← Lab 11-a: ACR Geo-Replication](lab-11a-acr-geo-replication.md)

# Lab 11-b: Azure Container Registry – Private Networking

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

.lab-copy-button svg {
  width: 1rem;
  height: 1rem;
  fill: currentColor;
}

.lab-copy-button.is-copied {
  color: #1a7f37;
}
</style>

## Introduction

Geo-replication solves **where** your images live, but not **how** consumers reach them securely. This lab assumes you already have the geo-replicated Premium registry from Lab 11-a and the fixed two-region hub-and-spoke network landing zone from Lab 0. You will now make image pulls private, identity-based, and region-aware.

| Challenge | Secure Pattern |
|---|---|
| **Public registry exposure** | Private endpoints plus public network access disabled |
| **Shared credentials** | System-assigned managed identities plus `AcrPull` |
| **Independent regional stamps** | One `privatelink.azurecr.io` zone per regional spoke |
| **Private-only consumers** | No-public-IP VMs in `snet-workload`, managed through Bastion or Run Command |

> **Objective:** Create regional private endpoints and DNS for ACR, disable public access, then validate private image pulls from consumers in both Sweden Central and Norway East.

---

## Architecture

```text
+--------------------------------------------------------------------------------------------------+
|             Geo-replicated Premium ACR: <registry>.azurecr.io (public access disabled)          |
|                                              |                                                   |
|                         +--------------------+--------------------+                             |
|                         |                                         |                             |
|            +------------v------------+              +-------------v------------+                |
|            | Sweden Central stamp    |              | Norway East stamp        |                |
|            | rg-spoke-swc            |              | rg-spoke-noe             |                |
|            | vnet-spoke-swc          |              | vnet-spoke-noe           |                |
|            | pe-acr-swc              |              | pe-acr-noe               |                |
|            | privatelink.azurecr.io  |              | privatelink.azurecr.io   |                |
|            | vm-acr-pull-swc         |              | vm-acr-pull-noe          |                |
|            | system MI + AcrPull     |              | system MI + AcrPull      |                |
|            +------------+------------+              +-------------+------------+                |
|                         ^                                         ^                             |
|                         |                                         |                             |
|                 bas-hub-swc / Run Command                 bas-hub-noe / Run Command             |
+--------------------------------------------------------------------------------------------------+
```

<div class="lab-note">
<strong>Why two DNS zones with the same name?</strong> Lab 0 intentionally keeps the Sweden Central and Norway East spokes as independent regional stamps without cross-region peering. A separate <code>privatelink.azurecr.io</code> zone in each spoke lets local consumers resolve the registry to their own regional private endpoint IPs without creating cross-region DNS collisions.
</div>

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Lab 0 completed** | You already have `rg-spoke-swc`, `rg-spoke-noe`, `vnet-spoke-swc`, `vnet-spoke-noe`, `snet-workload`, and `snet-private-endpoints` in both regions |
| **Lab 11-a completed** | You already created a Premium ACR with a Norway East geo-replica and pushed `hello-multiregion:v1` |
| **Azure CLI** | Version 2.50 or later |
| **Permissions** | Enough rights to create private endpoints, private DNS zones, VMs, and role assignments |
| **Budget awareness** | Private Link, VMs, and Premium ACR all incur charges |
| **Outbound package access** | The validation VMs need outbound access to install Docker and Azure CLI unless you use a pre-baked image |

<div class="lab-note">
<strong>Important:</strong> Do all <code>az acr build</code> and general push work before you disable public access. Once public access is off, external build agents without private connectivity will stop working unless you move to dedicated agent pools or self-hosted build infrastructure with network line of sight.
</div>

---

## How These Tabs Work

- Pick <strong>Bash</strong>, <strong>PowerShell</strong>, or <strong>Portal</strong> once.
- Only one instruction path stays visible at a time.
- Your preference is remembered in the browser.
- Code blocks keep the same copy-button behaviour used throughout the labs.

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
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the [Azure portal](https://portal.azure.com).
2. Confirm you are in the same subscription used for Lab 0 and Lab 11-a.
3. Keep both the Azure portal and Cloud Shell available for the rest of the lab.

  </div>
</div>

---

## Step 1 — Set Variables from Lab 0 and Lab 11-a

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
ACR_NAME="<YOUR_EXISTING_ACR_NAME_FROM_LAB_11A>"
ACR_RG="rg-acr-georeplication-lab"
IMAGE_NAME="hello-multiregion"
IMAGE_TAG="v1"

HOME_REGION="swedencentral"
REPLICA_REGION="norwayeast"

PRIMARY_SPOKE_RG="rg-spoke-swc"
SECONDARY_SPOKE_RG="rg-spoke-noe"
PRIMARY_VNET="vnet-spoke-swc"
SECONDARY_VNET="vnet-spoke-noe"
WORKLOAD_SUBNET="snet-workload"
PE_SUBNET="snet-private-endpoints"
PRIVATE_DNS_ZONE="privatelink.azurecr.io"

PRIMARY_PE_NAME="pe-acr-swc"
SECONDARY_PE_NAME="pe-acr-noe"
PRIMARY_VM_NAME="vm-acr-pull-swc"
SECONDARY_VM_NAME="vm-acr-pull-noe"
VM_ADMIN="azureuser"

ACR_ID=$(az acr show --name "$ACR_NAME" --resource-group "$ACR_RG" --query id -o tsv)
PRIMARY_VNET_ID=$(az network vnet show --resource-group "$PRIMARY_SPOKE_RG" --name "$PRIMARY_VNET" --query id -o tsv)
SECONDARY_VNET_ID=$(az network vnet show --resource-group "$SECONDARY_SPOKE_RG" --name "$SECONDARY_VNET" --query id -o tsv)

echo "ACR_ID=$ACR_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$ACR_NAME = "<YOUR_EXISTING_ACR_NAME_FROM_LAB_11A>"
$ACR_RG = "rg-acr-georeplication-lab"
$IMAGE_NAME = "hello-multiregion"
$IMAGE_TAG = "v1"

$HOME_REGION = "swedencentral"
$REPLICA_REGION = "norwayeast"

$PRIMARY_SPOKE_RG = "rg-spoke-swc"
$SECONDARY_SPOKE_RG = "rg-spoke-noe"
$PRIMARY_VNET = "vnet-spoke-swc"
$SECONDARY_VNET = "vnet-spoke-noe"
$WORKLOAD_SUBNET = "snet-workload"
$PE_SUBNET = "snet-private-endpoints"
$PRIVATE_DNS_ZONE = "privatelink.azurecr.io"

$PRIMARY_PE_NAME = "pe-acr-swc"
$SECONDARY_PE_NAME = "pe-acr-noe"
$PRIMARY_VM_NAME = "vm-acr-pull-swc"
$SECONDARY_VM_NAME = "vm-acr-pull-noe"
$VM_ADMIN = "azureuser"

$ACR_ID = az acr show --name $ACR_NAME --resource-group $ACR_RG --query id -o tsv
$PRIMARY_VNET_ID = az network vnet show --resource-group $PRIMARY_SPOKE_RG --name $PRIMARY_VNET --query id -o tsv
$SECONDARY_VNET_ID = az network vnet show --resource-group $SECONDARY_SPOKE_RG --name $SECONDARY_VNET --query id -o tsv

Write-Host "ACR_ID=$ACR_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Record or confirm these values:

1. Your existing ACR name from Lab 11-a
2. Registry resource group: `rg-acr-georeplication-lab` unless you changed it earlier
3. Fixed spoke resource groups: `rg-spoke-swc` and `rg-spoke-noe`
4. Fixed spoke VNets: `vnet-spoke-swc` and `vnet-spoke-noe`
5. Shared subnet names: `snet-workload` and `snet-private-endpoints`

  </div>
</div>

<div class="lab-note">
<strong>Replace the placeholder:</strong> <code>ACR_NAME</code> must point to the registry you created in Lab 11-a. The rest of the networking values intentionally reuse the fixed names from Lab 0.
</div>

---

## Step 2 — Verify the Landing Zone and Existing Registry

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet subnet show \
  --resource-group "$PRIMARY_SPOKE_RG" \
  --vnet-name "$PRIMARY_VNET" \
  --name "$PE_SUBNET" \
  --query "{Subnet:name, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" \
  --output table

az network vnet subnet show \
  --resource-group "$SECONDARY_SPOKE_RG" \
  --vnet-name "$SECONDARY_VNET" \
  --name "$PE_SUBNET" \
  --query "{Subnet:name, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" \
  --output table

az acr show \
  --name "$ACR_NAME" \
  --resource-group "$ACR_RG" \
  --query "{Name:name, SKU:sku.name, LoginServer:loginServer, PublicAccess:publicNetworkAccess}" \
  --output table

az acr replication list --registry "$ACR_NAME" --resource-group "$ACR_RG" --output table
az acr repository show-tags --name "$ACR_NAME" --repository "$IMAGE_NAME" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet subnet show `
  --resource-group $PRIMARY_SPOKE_RG `
  --vnet-name $PRIMARY_VNET `
  --name $PE_SUBNET `
  --query "{Subnet:name, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" `
  --output table

az network vnet subnet show `
  --resource-group $SECONDARY_SPOKE_RG `
  --vnet-name $SECONDARY_VNET `
  --name $PE_SUBNET `
  --query "{Subnet:name, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" `
  --output table

az acr show `
  --name $ACR_NAME `
  --resource-group $ACR_RG `
  --query "{Name:name, SKU:sku.name, LoginServer:loginServer, PublicAccess:publicNetworkAccess}" `
  --output table

az acr replication list --registry $ACR_NAME --resource-group $ACR_RG --output table
az acr repository show-tags --name $ACR_NAME --repository $IMAGE_NAME --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open both spokes and confirm `snet-private-endpoints` exists.
2. Verify **Private endpoint network policies** are disabled on that subnet in both regions.
3. Open the registry and confirm it is **Premium**.
4. Open **Geo-replications** and verify Norway East exists.
5. Open **Repositories** and confirm `hello-multiregion:v1` is already present.

  </div>
</div>

<div class="lab-note">
<strong>Note:</strong> If the repository tag check fails because you already disabled public access in a previous attempt, continue anyway. You will do the final validation from inside the private spokes later in this lab.
</div>

---

## Step 3 — Create Regional Private DNS Zones and VNet Links

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-dns zone create \
  --resource-group "$PRIMARY_SPOKE_RG" \
  --name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-dns link vnet create \
  --resource-group "$PRIMARY_SPOKE_RG" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "link-acr-swc" \
  --virtual-network "$PRIMARY_VNET_ID" \
  --registration-enabled false \
  --output table

az network private-dns zone create \
  --resource-group "$SECONDARY_SPOKE_RG" \
  --name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-dns link vnet create \
  --resource-group "$SECONDARY_SPOKE_RG" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "link-acr-noe" \
  --virtual-network "$SECONDARY_VNET_ID" \
  --registration-enabled false \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-dns zone create `
  --resource-group $PRIMARY_SPOKE_RG `
  --name $PRIVATE_DNS_ZONE `
  --output table

az network private-dns link vnet create `
  --resource-group $PRIMARY_SPOKE_RG `
  --zone-name $PRIVATE_DNS_ZONE `
  --name link-acr-swc `
  --virtual-network $PRIMARY_VNET_ID `
  --registration-enabled false `
  --output table

az network private-dns zone create `
  --resource-group $SECONDARY_SPOKE_RG `
  --name $PRIVATE_DNS_ZONE `
  --output table

az network private-dns link vnet create `
  --resource-group $SECONDARY_SPOKE_RG `
  --zone-name $PRIVATE_DNS_ZONE `
  --name link-acr-noe `
  --virtual-network $SECONDARY_VNET_ID `
  --registration-enabled false `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-spoke-swc`, create a private DNS zone named `privatelink.azurecr.io`.
2. Link it only to `vnet-spoke-swc` with **auto registration disabled**.
3. Repeat the same pattern in `rg-spoke-noe`, linking only to `vnet-spoke-noe`.
4. Keep the two zones separate even though the zone name is identical.

  </div>
</div>

---

## Step 4 — Create One Private Endpoint per Regional Spoke

A single ACR private endpoint exposes the registry IP plus one data-endpoint IP per replica on the private endpoint NIC. That is why one private endpoint per spoke is enough for this lab.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-endpoint create \
  --name "$PRIMARY_PE_NAME" \
  --resource-group "$PRIMARY_SPOKE_RG" \
  --location "$HOME_REGION" \
  --vnet-name "$PRIMARY_VNET" \
  --subnet "$PE_SUBNET" \
  --private-connection-resource-id "$ACR_ID" \
  --group-ids registry \
  --connection-name "${PRIMARY_PE_NAME}-conn" \
  --output table

az network private-endpoint create \
  --name "$SECONDARY_PE_NAME" \
  --resource-group "$SECONDARY_SPOKE_RG" \
  --location "$REPLICA_REGION" \
  --vnet-name "$SECONDARY_VNET" \
  --subnet "$PE_SUBNET" \
  --private-connection-resource-id "$ACR_ID" \
  --group-ids registry \
  --connection-name "${SECONDARY_PE_NAME}-conn" \
  --output table

az network private-endpoint show --resource-group "$PRIMARY_SPOKE_RG" --name "$PRIMARY_PE_NAME" --query "{Name:name, ProvisioningState:provisioningState}" --output table
az network private-endpoint show --resource-group "$SECONDARY_SPOKE_RG" --name "$SECONDARY_PE_NAME" --query "{Name:name, ProvisioningState:provisioningState}" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-endpoint create `
  --name $PRIMARY_PE_NAME `
  --resource-group $PRIMARY_SPOKE_RG `
  --location $HOME_REGION `
  --vnet-name $PRIMARY_VNET `
  --subnet $PE_SUBNET `
  --private-connection-resource-id $ACR_ID `
  --group-ids registry `
  --connection-name "$PRIMARY_PE_NAME-conn" `
  --output table

az network private-endpoint create `
  --name $SECONDARY_PE_NAME `
  --resource-group $SECONDARY_SPOKE_RG `
  --location $REPLICA_REGION `
  --vnet-name $SECONDARY_VNET `
  --subnet $PE_SUBNET `
  --private-connection-resource-id $ACR_ID `
  --group-ids registry `
  --connection-name "$SECONDARY_PE_NAME-conn" `
  --output table

az network private-endpoint show --resource-group $PRIMARY_SPOKE_RG --name $PRIMARY_PE_NAME --query "{Name:name, ProvisioningState:provisioningState}" --output table
az network private-endpoint show --resource-group $SECONDARY_SPOKE_RG --name $SECONDARY_PE_NAME --query "{Name:name, ProvisioningState:provisioningState}" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-spoke-swc`, create a private endpoint named `pe-acr-swc` targeting your registry.
2. Choose subresource **registry** and place it in `vnet-spoke-swc` / `snet-private-endpoints`.
3. Attach it to the existing `privatelink.azurecr.io` zone in `rg-spoke-swc` if the wizard offers DNS integration.
4. Repeat the same pattern in `rg-spoke-noe` with `pe-acr-noe`.
5. Wait for both private endpoints to show **Approved** or **Succeeded**.

  </div>
</div>

---

## Step 5 — Publish or Verify A Records for the Registry and Both Data Endpoints

For a geo-replicated registry, each private endpoint NIC carries one IP for `registry` plus one IP for every `registry_data_<region>` member. Populate all of those names in each regional DNS zone so ACR can keep private traffic private even when the global endpoint sends a pull to a different replica.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_PE_NIC_ID=$(az network private-endpoint show \
  --name "$PRIMARY_PE_NAME" \
  --resource-group "$PRIMARY_SPOKE_RG" \
  --query 'networkInterfaces[0].id' \
  --output tsv)

SECONDARY_PE_NIC_ID=$(az network private-endpoint show \
  --name "$SECONDARY_PE_NAME" \
  --resource-group "$SECONDARY_SPOKE_RG" \
  --query 'networkInterfaces[0].id' \
  --output tsv)

get_member_ip() {
  local nic_id="$1"
  local member_name="$2"

  az network nic show \
    --ids "$nic_id" \
    --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='$member_name'].privateIPAddress" \
    --output tsv
}

ensure_a_record() {
  local resource_group="$1"
  local record_name="$2"
  local ip_address="$3"
  local existing_ips

  az network private-dns record-set a show \
    --resource-group "$resource_group" \
    --zone-name "$PRIVATE_DNS_ZONE" \
    --name "$record_name" \
    --output none >/dev/null 2>&1 || \
  az network private-dns record-set a create \
    --resource-group "$resource_group" \
    --zone-name "$PRIVATE_DNS_ZONE" \
    --name "$record_name" \
    --output none

  existing_ips=$(az network private-dns record-set a show \
    --resource-group "$resource_group" \
    --zone-name "$PRIVATE_DNS_ZONE" \
    --name "$record_name" \
    --query "aRecords[].ipv4Address" \
    --output tsv)

  if ! grep -qx "$ip_address" <<<"$existing_ips"; then
    az network private-dns record-set a add-record \
      --resource-group "$resource_group" \
      --zone-name "$PRIVATE_DNS_ZONE" \
      --record-set-name "$record_name" \
      --ipv4-address "$ip_address" \
      --output none
  fi
}

PRIMARY_REGISTRY_IP=$(get_member_ip "$PRIMARY_PE_NIC_ID" "registry")
PRIMARY_HOME_DATA_IP=$(get_member_ip "$PRIMARY_PE_NIC_ID" "registry_data_$HOME_REGION")
PRIMARY_REPLICA_DATA_IP=$(get_member_ip "$PRIMARY_PE_NIC_ID" "registry_data_$REPLICA_REGION")
SECONDARY_REGISTRY_IP=$(get_member_ip "$SECONDARY_PE_NIC_ID" "registry")
SECONDARY_HOME_DATA_IP=$(get_member_ip "$SECONDARY_PE_NIC_ID" "registry_data_$HOME_REGION")
SECONDARY_REPLICA_DATA_IP=$(get_member_ip "$SECONDARY_PE_NIC_ID" "registry_data_$REPLICA_REGION")

ensure_a_record "$PRIMARY_SPOKE_RG" "$ACR_NAME" "$PRIMARY_REGISTRY_IP"
ensure_a_record "$PRIMARY_SPOKE_RG" "$ACR_NAME.$HOME_REGION.data" "$PRIMARY_HOME_DATA_IP"
ensure_a_record "$PRIMARY_SPOKE_RG" "$ACR_NAME.$REPLICA_REGION.data" "$PRIMARY_REPLICA_DATA_IP"

ensure_a_record "$SECONDARY_SPOKE_RG" "$ACR_NAME" "$SECONDARY_REGISTRY_IP"
ensure_a_record "$SECONDARY_SPOKE_RG" "$ACR_NAME.$HOME_REGION.data" "$SECONDARY_HOME_DATA_IP"
ensure_a_record "$SECONDARY_SPOKE_RG" "$ACR_NAME.$REPLICA_REGION.data" "$SECONDARY_REPLICA_DATA_IP"

az network private-dns record-set a list --resource-group "$PRIMARY_SPOKE_RG" --zone-name "$PRIVATE_DNS_ZONE" --output table
az network private-dns record-set a list --resource-group "$SECONDARY_SPOKE_RG" --zone-name "$PRIVATE_DNS_ZONE" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_PE_NIC_ID = az network private-endpoint show `
  --name $PRIMARY_PE_NAME `
  --resource-group $PRIMARY_SPOKE_RG `
  --query 'networkInterfaces[0].id' `
  --output tsv

$SECONDARY_PE_NIC_ID = az network private-endpoint show `
  --name $SECONDARY_PE_NAME `
  --resource-group $SECONDARY_SPOKE_RG `
  --query 'networkInterfaces[0].id' `
  --output tsv

function Get-MemberIp {
  param(
    [string]$NicId,
    [string]$MemberName
  )

  az network nic show `
    --ids $NicId `
    --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='$MemberName'].privateIPAddress" `
    --output tsv
}

function Ensure-ARecord {
  param(
    [string]$ResourceGroupName,
    [string]$RecordName,
    [string]$IpAddress
  )

  az network private-dns record-set a show `
    --resource-group $ResourceGroupName `
    --zone-name $PRIVATE_DNS_ZONE `
    --name $RecordName `
    --output none 2>$null | Out-Null

  if ($LASTEXITCODE -ne 0) {
    az network private-dns record-set a create `
      --resource-group $ResourceGroupName `
      --zone-name $PRIVATE_DNS_ZONE `
      --name $RecordName `
      --output none | Out-Null
  }

  $existing = az network private-dns record-set a show `
    --resource-group $ResourceGroupName `
    --zone-name $PRIVATE_DNS_ZONE `
    --name $RecordName `
    --query "aRecords[].ipv4Address" `
    --output tsv

  if ($existing -notmatch "(?m)^$([regex]::Escape($IpAddress))$") {
    az network private-dns record-set a add-record `
      --resource-group $ResourceGroupName `
      --zone-name $PRIVATE_DNS_ZONE `
      --record-set-name $RecordName `
      --ipv4-address $IpAddress `
      --output none | Out-Null
  }
}

$PRIMARY_REGISTRY_IP = Get-MemberIp -NicId $PRIMARY_PE_NIC_ID -MemberName 'registry'
$PRIMARY_HOME_DATA_IP = Get-MemberIp -NicId $PRIMARY_PE_NIC_ID -MemberName "registry_data_$HOME_REGION"
$PRIMARY_REPLICA_DATA_IP = Get-MemberIp -NicId $PRIMARY_PE_NIC_ID -MemberName "registry_data_$REPLICA_REGION"
$SECONDARY_REGISTRY_IP = Get-MemberIp -NicId $SECONDARY_PE_NIC_ID -MemberName 'registry'
$SECONDARY_HOME_DATA_IP = Get-MemberIp -NicId $SECONDARY_PE_NIC_ID -MemberName "registry_data_$HOME_REGION"
$SECONDARY_REPLICA_DATA_IP = Get-MemberIp -NicId $SECONDARY_PE_NIC_ID -MemberName "registry_data_$REPLICA_REGION"

Ensure-ARecord -ResourceGroupName $PRIMARY_SPOKE_RG -RecordName $ACR_NAME -IpAddress $PRIMARY_REGISTRY_IP
Ensure-ARecord -ResourceGroupName $PRIMARY_SPOKE_RG -RecordName "$ACR_NAME.$HOME_REGION.data" -IpAddress $PRIMARY_HOME_DATA_IP
Ensure-ARecord -ResourceGroupName $PRIMARY_SPOKE_RG -RecordName "$ACR_NAME.$REPLICA_REGION.data" -IpAddress $PRIMARY_REPLICA_DATA_IP

Ensure-ARecord -ResourceGroupName $SECONDARY_SPOKE_RG -RecordName $ACR_NAME -IpAddress $SECONDARY_REGISTRY_IP
Ensure-ARecord -ResourceGroupName $SECONDARY_SPOKE_RG -RecordName "$ACR_NAME.$HOME_REGION.data" -IpAddress $SECONDARY_HOME_DATA_IP
Ensure-ARecord -ResourceGroupName $SECONDARY_SPOKE_RG -RecordName "$ACR_NAME.$REPLICA_REGION.data" -IpAddress $SECONDARY_REPLICA_DATA_IP

az network private-dns record-set a list --resource-group $PRIMARY_SPOKE_RG --zone-name $PRIVATE_DNS_ZONE --output table
az network private-dns record-set a list --resource-group $SECONDARY_SPOKE_RG --zone-name $PRIVATE_DNS_ZONE --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `pe-acr-swc` and inspect **DNS configuration**.
2. Note the private IPs for:
   - `registry`
   - `registry_data_swedencentral`
   - `registry_data_norwayeast`
3. In the `rg-spoke-swc` private DNS zone, make sure these A records exist:
   - `<acr-name>`
   - `<acr-name>.swedencentral.data`
   - `<acr-name>.norwayeast.data`
4. Repeat the same verification for `pe-acr-noe` and the `rg-spoke-noe` DNS zone.
5. If a record is missing, add it manually using the local private endpoint IP shown in the private endpoint NIC details.

  </div>
</div>

---

## Step 6 — Disable Public Network Access on the Registry

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr update \
  --name "$ACR_NAME" \
  --resource-group "$ACR_RG" \
  --public-network-enabled false \
  --output table

az acr show \
  --name "$ACR_NAME" \
  --resource-group "$ACR_RG" \
  --query "{Name:name, PublicAccess:publicNetworkAccess}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr update `
  --name $ACR_NAME `
  --resource-group $ACR_RG `
  --public-network-enabled false `
  --output table

az acr show `
  --name $ACR_NAME `
  --resource-group $ACR_RG `
  --query "{Name:name, PublicAccess:publicNetworkAccess}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the registry.
2. Go to **Networking** → **Public access**.
3. Set **Public network access** to **Disabled**.
4. Save the change.
5. If other Azure platform services still need access, review the **trusted services** bypass setting deliberately instead of leaving the registry public.

  </div>
</div>

<div class="lab-note">
<strong>Operational consequence:</strong> external <code>az acr build</code> calls and repository browsing from outside the private network will stop working after this point unless your build agents or admin hosts have private connectivity to the registry.
</div>

---

## Step 7 — Create Private-Only Consumer VMs with System-Assigned Identity

These VMs are simple, repeatable consumers for the lab. In a real platform, the same ACR private-endpoint plus managed-identity pattern also applies to AKS, scale sets, App Service, and other private consumers.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az vm create \
  --resource-group "$PRIMARY_SPOKE_RG" \
  --name "$PRIMARY_VM_NAME" \
  --location "$HOME_REGION" \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username "$VM_ADMIN" \
  --generate-ssh-keys \
  --vnet-name "$PRIMARY_VNET" \
  --subnet "$WORKLOAD_SUBNET" \
  --public-ip-address "" \
  --assign-identity \
  --output table

az vm create \
  --resource-group "$SECONDARY_SPOKE_RG" \
  --name "$SECONDARY_VM_NAME" \
  --location "$REPLICA_REGION" \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username "$VM_ADMIN" \
  --generate-ssh-keys \
  --vnet-name "$SECONDARY_VNET" \
  --subnet "$WORKLOAD_SUBNET" \
  --public-ip-address "" \
  --assign-identity \
  --output table

az vm show --resource-group "$PRIMARY_SPOKE_RG" --name "$PRIMARY_VM_NAME" --query "{Name:name, PrincipalId:identity.principalId}" --output table
az vm show --resource-group "$SECONDARY_SPOKE_RG" --name "$SECONDARY_VM_NAME" --query "{Name:name, PrincipalId:identity.principalId}" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az vm create `
  --resource-group $PRIMARY_SPOKE_RG `
  --name $PRIMARY_VM_NAME `
  --location $HOME_REGION `
  --image Ubuntu2204 `
  --size Standard_B2s `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --vnet-name $PRIMARY_VNET `
  --subnet $WORKLOAD_SUBNET `
  --public-ip-address "" `
  --assign-identity `
  --output table

az vm create `
  --resource-group $SECONDARY_SPOKE_RG `
  --name $SECONDARY_VM_NAME `
  --location $REPLICA_REGION `
  --image Ubuntu2204 `
  --size Standard_B2s `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --vnet-name $SECONDARY_VNET `
  --subnet $WORKLOAD_SUBNET `
  --public-ip-address "" `
  --assign-identity `
  --output table

az vm show --resource-group $PRIMARY_SPOKE_RG --name $PRIMARY_VM_NAME --query "{Name:name, PrincipalId:identity.principalId}" --output table
az vm show --resource-group $SECONDARY_SPOKE_RG --name $SECONDARY_VM_NAME --query "{Name:name, PrincipalId:identity.principalId}" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create an Ubuntu VM named `vm-acr-pull-swc` in `rg-spoke-swc`.
2. Place it in `vnet-spoke-swc` / `snet-workload` with **no public IP**.
3. Enable the **system-assigned managed identity** on the VM.
4. Repeat the pattern for `vm-acr-pull-noe` in `rg-spoke-noe`.
5. If you want direct interactive admin access, use the Bastion hosts created in Lab 0 instead of exposing SSH publicly.

  </div>
</div>

---

## Step 8 — Grant AcrPull to Both Consumers

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_VM_PRINCIPAL_ID=$(az vm show \
  --resource-group "$PRIMARY_SPOKE_RG" \
  --name "$PRIMARY_VM_NAME" \
  --query identity.principalId \
  --output tsv)

SECONDARY_VM_PRINCIPAL_ID=$(az vm show \
  --resource-group "$SECONDARY_SPOKE_RG" \
  --name "$SECONDARY_VM_NAME" \
  --query identity.principalId \
  --output tsv)

az role assignment create \
  --assignee-object-id "$PRIMARY_VM_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --scope "$ACR_ID" \
  --role AcrPull \
  --output table

az role assignment create \
  --assignee-object-id "$SECONDARY_VM_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --scope "$ACR_ID" \
  --role AcrPull \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_VM_PRINCIPAL_ID = az vm show `
  --resource-group $PRIMARY_SPOKE_RG `
  --name $PRIMARY_VM_NAME `
  --query identity.principalId `
  --output tsv

$SECONDARY_VM_PRINCIPAL_ID = az vm show `
  --resource-group $SECONDARY_SPOKE_RG `
  --name $SECONDARY_VM_NAME `
  --query identity.principalId `
  --output tsv

az role assignment create `
  --assignee-object-id $PRIMARY_VM_PRINCIPAL_ID `
  --assignee-principal-type ServicePrincipal `
  --scope $ACR_ID `
  --role AcrPull `
  --output table

az role assignment create `
  --assignee-object-id $SECONDARY_VM_PRINCIPAL_ID `
  --assignee-principal-type ServicePrincipal `
  --scope $ACR_ID `
  --role AcrPull `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the registry → **Access control (IAM)**.
2. Add the **AcrPull** role for the identity on `vm-acr-pull-swc`.
3. Add the same role for `vm-acr-pull-noe`.
4. Wait about a minute for RBAC propagation before testing pulls.

  </div>
</div>

<div class="lab-note">
<strong>ABAC note:</strong> if your registry is configured for repository-level ABAC instead of the default non-ABAC model, use <code>Container Registry Repository Reader</code> instead of <code>AcrPull</code>.
</div>

---

## Step 9 — Validate DNS Resolution and Managed-Identity Pulls from Each Region

The simplest private validation path is to use **Run Command** against the two no-public-IP VMs. The script installs Docker and Azure CLI, signs in with the VM's managed identity, resolves the ACR names over private DNS, pulls the image, and curls the running container locally.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
VALIDATION_SCRIPT=$(cat <<VALIDATIONEOF
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg dnsutils docker.io
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
systemctl enable --now docker

echo "=== DNS ==="
nslookup ${ACR_NAME}.azurecr.io
nslookup ${ACR_NAME}.${HOME_REGION}.data.azurecr.io
nslookup ${ACR_NAME}.${REPLICA_REGION}.data.azurecr.io

echo "=== Managed identity login ==="
az login --identity

echo "=== ACR login ==="
az acr login --name ${ACR_NAME}

echo "=== Pull and run ==="
docker pull ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
docker run -d --rm --name acrtest -p 8080:80 ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
sleep 5
curl -fsS http://127.0.0.1:8080 | head -n 5
docker rm -f acrtest
VALIDATIONEOF
)

az vm run-command invoke \
  --resource-group "$PRIMARY_SPOKE_RG" \
  --name "$PRIMARY_VM_NAME" \
  --command-id RunShellScript \
  --scripts "$VALIDATION_SCRIPT"

az vm run-command invoke \
  --resource-group "$SECONDARY_SPOKE_RG" \
  --name "$SECONDARY_VM_NAME" \
  --command-id RunShellScript \
  --scripts "$VALIDATION_SCRIPT"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$VALIDATION_SCRIPT = @"
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg dnsutils docker.io
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
systemctl enable --now docker

echo "=== DNS ==="
nslookup ${ACR_NAME}.azurecr.io
nslookup ${ACR_NAME}.${HOME_REGION}.data.azurecr.io
nslookup ${ACR_NAME}.${REPLICA_REGION}.data.azurecr.io

echo "=== Managed identity login ==="
az login --identity

echo "=== ACR login ==="
az acr login --name ${ACR_NAME}

echo "=== Pull and run ==="
docker pull ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
docker run -d --rm --name acrtest -p 8080:80 ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
sleep 5
curl -fsS http://127.0.0.1:8080 | head -n 5
docker rm -f acrtest
"@

az vm run-command invoke `
  --resource-group $PRIMARY_SPOKE_RG `
  --name $PRIMARY_VM_NAME `
  --command-id RunShellScript `
  --scripts $VALIDATION_SCRIPT

az vm run-command invoke `
  --resource-group $SECONDARY_SPOKE_RG `
  --name $SECONDARY_VM_NAME `
  --command-id RunShellScript `
  --scripts $VALIDATION_SCRIPT
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `vm-acr-pull-swc`.
2. Use **Run command** → **RunShellScript** (or Bastion if you prefer an interactive shell).
3. Install Docker, Azure CLI, and `dnsutils`.
4. Run:
   - `nslookup <acr-name>.azurecr.io`
   - `nslookup <acr-name>.swedencentral.data.azurecr.io`
   - `nslookup <acr-name>.norwayeast.data.azurecr.io`
   - `az login --identity`
   - `az acr login --name <acr-name>`
   - `docker pull <acr-name>.azurecr.io/hello-multiregion:v1`
5. Repeat the same validation from `vm-acr-pull-noe`.
6. Successful pulls and 10.x / private-range DNS answers confirm the private path is working.

  </div>
</div>

<div class="lab-note">
<strong>If the validation fails:</strong> wait 60–90 seconds for the role assignments to propagate, then re-run the validation. If DNS still fails, inspect the private endpoint NIC IP configurations and confirm each regional zone contains the registry record plus both data-endpoint records.
</div>

---

## Validation Checklist

| # | Check | Expected |
|---|---|---|
| 1 | Private DNS zones exist | `privatelink.azurecr.io` exists in `rg-spoke-swc` and `rg-spoke-noe` |
| 2 | Zone links exist | Each zone is linked only to its local spoke VNet |
| 3 | Private endpoints exist | `pe-acr-swc` and `pe-acr-noe` are provisioned successfully |
| 4 | DNS records are present | `<acr>`, `<acr>.swedencentral.data`, and `<acr>.norwayeast.data` exist in each zone |
| 5 | Public access is disabled | `publicNetworkAccess = Disabled` |
| 6 | Consumers have identity access | Both VMs have a system-assigned identity with `AcrPull` |
| 7 | Private pull works | From each VM, `nslookup` returns private IPs and `docker pull` succeeds |

---

## Cleanup

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_VM_PRINCIPAL_ID=$(az vm show --resource-group "$PRIMARY_SPOKE_RG" --name "$PRIMARY_VM_NAME" --query identity.principalId --output tsv)
SECONDARY_VM_PRINCIPAL_ID=$(az vm show --resource-group "$SECONDARY_SPOKE_RG" --name "$SECONDARY_VM_NAME" --query identity.principalId --output tsv)

# Remove the pull grants first if you want a fully clean RBAC scope.
az role assignment delete --assignee-object-id "$PRIMARY_VM_PRINCIPAL_ID" --scope "$ACR_ID" --role AcrPull
az role assignment delete --assignee-object-id "$SECONDARY_VM_PRINCIPAL_ID" --scope "$ACR_ID" --role AcrPull

az vm delete --resource-group "$PRIMARY_SPOKE_RG" --name "$PRIMARY_VM_NAME" --yes
az vm delete --resource-group "$SECONDARY_SPOKE_RG" --name "$SECONDARY_VM_NAME" --yes

az network private-endpoint delete --resource-group "$PRIMARY_SPOKE_RG" --name "$PRIMARY_PE_NAME"
az network private-endpoint delete --resource-group "$SECONDARY_SPOKE_RG" --name "$SECONDARY_PE_NAME"

az network private-dns link vnet delete --resource-group "$PRIMARY_SPOKE_RG" --zone-name "$PRIVATE_DNS_ZONE" --name link-acr-swc --yes
az network private-dns link vnet delete --resource-group "$SECONDARY_SPOKE_RG" --zone-name "$PRIVATE_DNS_ZONE" --name link-acr-noe --yes

az network private-dns zone delete --resource-group "$PRIMARY_SPOKE_RG" --name "$PRIVATE_DNS_ZONE" --yes
az network private-dns zone delete --resource-group "$SECONDARY_SPOKE_RG" --name "$PRIVATE_DNS_ZONE" --yes

# Omit this if you want to keep the registry private-only after the lab.
az acr update --name "$ACR_NAME" --resource-group "$ACR_RG" --public-network-enabled true --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_VM_PRINCIPAL_ID = az vm show --resource-group $PRIMARY_SPOKE_RG --name $PRIMARY_VM_NAME --query identity.principalId --output tsv
$SECONDARY_VM_PRINCIPAL_ID = az vm show --resource-group $SECONDARY_SPOKE_RG --name $SECONDARY_VM_NAME --query identity.principalId --output tsv

# Remove the pull grants first if you want a fully clean RBAC scope.
az role assignment delete --assignee-object-id $PRIMARY_VM_PRINCIPAL_ID --scope $ACR_ID --role AcrPull
az role assignment delete --assignee-object-id $SECONDARY_VM_PRINCIPAL_ID --scope $ACR_ID --role AcrPull

az vm delete --resource-group $PRIMARY_SPOKE_RG --name $PRIMARY_VM_NAME --yes
az vm delete --resource-group $SECONDARY_SPOKE_RG --name $SECONDARY_VM_NAME --yes

az network private-endpoint delete --resource-group $PRIMARY_SPOKE_RG --name $PRIMARY_PE_NAME
az network private-endpoint delete --resource-group $SECONDARY_SPOKE_RG --name $SECONDARY_PE_NAME

az network private-dns link vnet delete --resource-group $PRIMARY_SPOKE_RG --zone-name $PRIVATE_DNS_ZONE --name link-acr-swc --yes
az network private-dns link vnet delete --resource-group $SECONDARY_SPOKE_RG --zone-name $PRIVATE_DNS_ZONE --name link-acr-noe --yes

az network private-dns zone delete --resource-group $PRIMARY_SPOKE_RG --name $PRIVATE_DNS_ZONE --yes
az network private-dns zone delete --resource-group $SECONDARY_SPOKE_RG --name $PRIVATE_DNS_ZONE --yes

# Omit this if you want to keep the registry private-only after the lab.
az acr update --name $ACR_NAME --resource-group $ACR_RG --public-network-enabled true --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Remove the two `AcrPull` role assignments from the registry if you want a fully clean RBAC scope.
2. Delete `vm-acr-pull-swc` and `vm-acr-pull-noe`.
3. Delete `pe-acr-swc` and `pe-acr-noe`.
4. Delete the VNet links and the two `privatelink.azurecr.io` private DNS zones.
5. If you want to return to the more open Lab 11-a state, re-enable public access on the registry. Otherwise leave it private-only.
6. If you are completely done with both lab parts, you can also delete the Lab 11-a resource group afterwards.

  </div>
</div>

---

## Discussion & Next Steps

### Why the DNS Pattern Matters

The private endpoint NIC exposes multiple member IPs: the registry control endpoint and one data endpoint per replica. If you omit one of the data-endpoint records, pulls can fail unexpectedly when ACR routes a client to a replica whose name no longer resolves privately.

### Why Managed Identity Beats Shared Secrets

Managed identity avoids storing ACR passwords on the consumer. RBAC stays visible in Azure, you can rotate nothing on the VM itself, and the pattern scales cleanly to other Azure compute services.

### What Changes for Build Pipelines

After public access is disabled, you should assume that external build agents are cut off. Move builds into the private network, use dedicated agent pools, or add self-hosted runners with network line of sight to the registry.

### Where to Reuse This Pattern

The same design translates well to AKS node pools, scale sets, App Service with VNet integration, Container Apps with managed identity, and any other private consumer that needs to pull from ACR without leaving the Azure backbone.

---

## Useful Links

- [ACR private endpoints](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-private-link)
- [Managed identity authentication for ACR](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication-managed-identity)
- [ACR geo-replication](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-geo-replication)
- [Private endpoint DNS guidance](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
- [Azure Bastion overview](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)

---

[← Lab 11-a: ACR Geo-Replication](lab-11a-acr-geo-replication.md)
