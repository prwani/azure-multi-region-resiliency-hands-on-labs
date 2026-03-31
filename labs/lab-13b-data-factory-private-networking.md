---
layout: default
title: "Lab 13-b: Azure Data Factory – Private Networking and Spoke Connectivity"
---

[← Lab 13-a: Azure Data Factory DR](lab-13a-data-factory-dr.md)

# Lab 13-b: Azure Data Factory – Private Networking and Spoke Connectivity

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

> **Objective:** Keep the same active/passive Azure Data Factory pattern as Lab 13-a, but harden the supporting path: reuse the Lab 0 hub-and-spoke foundation, place the storage sinks behind private endpoints, and run the copy pipeline through spoke-hosted self-hosted integration runtime (SHIR) nodes in both regions.

<div class="lab-note">
<strong>Pairing note:</strong> This <code>B</code> path assumes Lab 0 is already complete. The Data Factory control plane itself remains a regional Azure service; this lab focuses on making the <strong>data path</strong> private where it is practical to do so. If you want the simpler public-endpoint walkthrough first, start with <a href="lab-13a-data-factory-dr.md">Lab 13-a</a>.
</div>

> **⚠️ Cost note:** This lab adds two Windows VMs in addition to the factories and storage accounts. Delete the dedicated lab resource groups when you finish.

---

## Overview

Lab 13-a intentionally keeps the sample simple: a public HTTP source and public blob endpoints let you focus on the **ADF active/passive DR pattern** itself.

This `B` variant keeps that DR lesson, but changes the supporting connectivity model:

| Change | Why it matters |
|---|---|
| **Reuse Lab 0 spoke VNets** | Private endpoints and SHIR nodes need deterministic subnets and naming. |
| **Replace the public HTTP sample source** | A private-path lab should not depend on `raw.githubusercontent.com` for its runtime data path. |
| **Create private-endpoint-only blob storage** | Each region gets a local sink that resolves to a private IP inside the spoke. |
| **Run the copy through SHIR** | The spoke VM becomes the runtime bridge between local/private data and Azure Storage. |
| **Keep two factories** | The DR lesson is unchanged: primary active, secondary standby, manual switchover. |

Instead of copying directly from a public URL, this lab stages a small CSV file on each SHIR VM at `C:\adfdrop\iris-private.csv`. The factory then copies that file to a **private blob endpoint** in the same region.

That gives you a realistic hybrid/private pattern:

- **Primary region:** Sweden Central (`swedencentral`, `swc`)
- **Secondary region:** Norway East (`norwayeast`, `noe`)
- **Private execution path:** SHIR VM in `snet-workload` → blob private endpoint in `snet-private-endpoints`
- **DR approach:** duplicate definitions, duplicate SHIR nodes, and region-local storage sinks

> **⏱ Estimated time:** 75–90 minutes

---

## Architecture

```text
                    ┌────────────────────────────────────────────┐
                    │ Azure Data Factory control plane           │
                    │                                            │
                    │  adf-private-swc (active)                  │
                    │  adf-private-noe (standby)                 │
                    └───────────────┬───────────────┬────────────┘
                                    │               │
                             dispatch copy    dispatch copy
                                    │               │
          ┌─────────────────────────▼───┐   ┌───────▼────────────────────────┐
          │ Sweden Central spoke         │   │ Norway East spoke              │
          │ vnet-spoke-swc               │   │ vnet-spoke-noe                │
          │                              │   │                               │
          │  snet-workload               │   │  snet-workload                │
          │   └─ vm-shir-swc-*           │   │   └─ vm-shir-noe-*            │
          │      SHIR node               │   │      SHIR node                │
          │      C:\adfdrop\iris-private │   │      C:\adfdrop\iris-private│
          │                              │   │                               │
          │  snet-private-endpoints      │   │  snet-private-endpoints       │
          │   └─ pep-blob-swc-*          │   │   └─ pep-blob-noe-*           │
          │      ▼                       │   │      ▼                        │
          │   stadfprivswc*              │   │   stadfprivnoe*               │
          │   blob.core.windows.net      │   │   blob.core.windows.net       │
          └───────────────┬──────────────┘   └───────────────┬────────────────┘
                          │                                  │
                          └──── privatelink.blob.core.windows.net ────┘
                                linked to both spoke VNets
```

**Key points:**

- Lab 0's **hub/spoke topology** and **subnet names** are reused exactly.
- The **blob private endpoints** live in `snet-private-endpoints` in each spoke.
- The **SHIR VMs** live in `snet-workload`, not in the private-endpoint subnet.
- Each factory still lives in a single Azure region; **ADF itself is not geo-replicated**.
- The lab secures the **data stores and execution path**, not the Data Factory authoring endpoint.

---

## Prerequisites

- [ ] **Lab 0 is already complete** in the same subscription.
- [ ] You still have these Lab 0 resources available:
  - `rg-spoke-swc`, `rg-spoke-noe`
  - `vnet-spoke-swc`, `vnet-spoke-noe`
  - `snet-workload`, `snet-private-endpoints`
  - optional but helpful: `bas-hub-swc`, `bas-hub-noe` for Bastion access
- [ ] **Azure subscription** with Contributor or Owner access.
- [ ] **Azure CLI** v2.60+ authenticated with `az login`.
- [ ] The **datafactory** extension available to Azure CLI.
- [ ] Permission to create **Windows VMs**, **private endpoints**, **private DNS zones**, and **role assignments**.
- [ ] You are comfortable using **Bastion or RDP** to finish SHIR registration on a Windows VM.

> **Important:** Lab 0 intentionally left the staged route tables unattached. This lab assumes that choice still stands. If you attach forced-tunnel routes later, you must allow outbound `443` from the SHIR nodes to Azure Data Factory control-plane endpoints, Azure Relay, Microsoft download endpoints during setup, and the blob private endpoints.

---

## How These Tabs Work

This page uses the same interaction pattern as the rest of the lab series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behavior used in the other labs.

---
## Step 1 — Set Variables

Use a unique suffix for the dedicated lab resources, but keep the Lab 0 network names fixed.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
UNIQUE_SUFFIX=$RANDOM
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

FOUNDATION_RG_PRIMARY="rg-spoke-swc"
FOUNDATION_RG_SECONDARY="rg-spoke-noe"
SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_SECONDARY="vnet-spoke-noe"
WORKLOAD_SUBNET_NAME="snet-workload"
PE_SUBNET_NAME="snet-private-endpoints"

RG_PRIMARY="rg-adf-private-swc"
RG_SECONDARY="rg-adf-private-noe"

ADF_PRIMARY="adf-private-swc-${UNIQUE_SUFFIX}"
ADF_SECONDARY="adf-private-noe-${UNIQUE_SUFFIX}"
IR_PRIMARY="shir-swc-${UNIQUE_SUFFIX}"
IR_SECONDARY="shir-noe-${UNIQUE_SUFFIX}"

SHIR_VM_PRIMARY="vm-shir-swc-${UNIQUE_SUFFIX}"
SHIR_VM_SECONDARY="vm-shir-noe-${UNIQUE_SUFFIX}"
VM_ADMIN_USERNAME="adfadmin"
VM_ADMIN_PASSWORD="ChangeMe-BeforeYouRun!123"

STORAGE_PRIMARY="stadfprivswc${UNIQUE_SUFFIX}"
STORAGE_SECONDARY="stadfprivnoe${UNIQUE_SUFFIX}"
CONTAINER_NAME="adf-landing"
PRIMARY_BLOB_ENDPOINT="https://${STORAGE_PRIMARY}.blob.core.windows.net/"
SECONDARY_BLOB_ENDPOINT="https://${STORAGE_SECONDARY}.blob.core.windows.net/"
PRIVATE_DNS_ZONE_BLOB="privatelink.blob.core.windows.net"
PIPELINE_NAME="CopyFileToBlob"
SOURCE_FILE_NAME="iris-private.csv"

BLOB_PE_PRIMARY="pep-blob-swc-${UNIQUE_SUFFIX}"
BLOB_PE_SECONDARY="pep-blob-noe-${UNIQUE_SUFFIX}"
BLOB_PSC_PRIMARY="psc-blob-swc-${UNIQUE_SUFFIX}"
BLOB_PSC_SECONDARY="psc-blob-noe-${UNIQUE_SUFFIX}"
DNS_LINK_PRIMARY="link-blob-swc-${UNIQUE_SUFFIX}"
DNS_LINK_SECONDARY="link-blob-noe-${UNIQUE_SUFFIX}"

echo "Primary factory      : $ADF_PRIMARY"
echo "Secondary factory    : $ADF_SECONDARY"
echo "Primary SHIR VM      : $SHIR_VM_PRIMARY"
echo "Secondary SHIR VM    : $SHIR_VM_SECONDARY"
echo "Primary blob storage : $STORAGE_PRIMARY"
echo "Secondary blob store : $STORAGE_SECONDARY"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$UNIQUE_SUFFIX = Get-Random -Minimum 1000 -Maximum 9999
$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$FOUNDATION_RG_PRIMARY = "rg-spoke-swc"
$FOUNDATION_RG_SECONDARY = "rg-spoke-noe"
$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"
$WORKLOAD_SUBNET_NAME = "snet-workload"
$PE_SUBNET_NAME = "snet-private-endpoints"

$RG_PRIMARY = "rg-adf-private-swc"
$RG_SECONDARY = "rg-adf-private-noe"

$ADF_PRIMARY = "adf-private-swc-$UNIQUE_SUFFIX"
$ADF_SECONDARY = "adf-private-noe-$UNIQUE_SUFFIX"
$IR_PRIMARY = "shir-swc-$UNIQUE_SUFFIX"
$IR_SECONDARY = "shir-noe-$UNIQUE_SUFFIX"

$SHIR_VM_PRIMARY = "vm-shir-swc-$UNIQUE_SUFFIX"
$SHIR_VM_SECONDARY = "vm-shir-noe-$UNIQUE_SUFFIX"
$VM_ADMIN_USERNAME = "adfadmin"
$VM_ADMIN_PASSWORD = "ChangeMe-BeforeYouRun!123"

$STORAGE_PRIMARY = "stadfprivswc$UNIQUE_SUFFIX"
$STORAGE_SECONDARY = "stadfprivnoe$UNIQUE_SUFFIX"
$CONTAINER_NAME = "adf-landing"
$PRIMARY_BLOB_ENDPOINT = "https://$STORAGE_PRIMARY.blob.core.windows.net/"
$SECONDARY_BLOB_ENDPOINT = "https://$STORAGE_SECONDARY.blob.core.windows.net/"
$PRIVATE_DNS_ZONE_BLOB = "privatelink.blob.core.windows.net"
$PIPELINE_NAME = "CopyFileToBlob"
$SOURCE_FILE_NAME = "iris-private.csv"

$BLOB_PE_PRIMARY = "pep-blob-swc-$UNIQUE_SUFFIX"
$BLOB_PE_SECONDARY = "pep-blob-noe-$UNIQUE_SUFFIX"
$BLOB_PSC_PRIMARY = "psc-blob-swc-$UNIQUE_SUFFIX"
$BLOB_PSC_SECONDARY = "psc-blob-noe-$UNIQUE_SUFFIX"
$DNS_LINK_PRIMARY = "link-blob-swc-$UNIQUE_SUFFIX"
$DNS_LINK_SECONDARY = "link-blob-noe-$UNIQUE_SUFFIX"

Write-Host "Primary factory      : $ADF_PRIMARY"
Write-Host "Secondary factory    : $ADF_SECONDARY"
Write-Host "Primary SHIR VM      : $SHIR_VM_PRIMARY"
Write-Host "Secondary SHIR VM    : $SHIR_VM_SECONDARY"
Write-Host "Primary blob storage : $STORAGE_PRIMARY"
Write-Host "Secondary blob store : $STORAGE_SECONDARY"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Record these values before you continue:

- Lab 0 spoke resource groups: `rg-spoke-swc`, `rg-spoke-noe`
- Lab 0 spoke VNets: `vnet-spoke-swc`, `vnet-spoke-noe`
- Reused subnets: `snet-workload`, `snet-private-endpoints`
- Dedicated lab resource groups: `rg-adf-private-swc`, `rg-adf-private-noe`
- Two new factories: `adf-private-swc-<suffix>`, `adf-private-noe-<suffix>`
- Two new SHIR VMs: `vm-shir-swc-<suffix>`, `vm-shir-noe-<suffix>`
- Two new storage accounts: `stadfprivswc<suffix>`, `stadfprivnoe<suffix>`
- Container name: `adf-landing`
- Pipeline name: `CopyFileToBlob`
- Local seed file on each VM: `C:\adfdrop\iris-private.csv`

Pick a strong Windows admin password that you can also reuse in the File System linked-service step. Avoid quotes or backticks to keep the JSON examples simple.

  </div>
</div>

<div class="lab-note">
<strong>Security reminder:</strong> Replace the sample password before you deploy the VMs. The pipeline examples assume a throwaway lab password that you control.
</div>

---

## Step 2 — Sign In and Install the Data Factory Extension

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
az extension add --name datafactory --upgrade --yes
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az version --output table
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"

az config set extension.use_dynamic_install=yes_without_prompt
az extension add --name datafactory --upgrade --yes
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the [Azure portal](https://portal.azure.com).
2. Confirm the correct subscription under **Subscriptions**.
3. If you want an Azure-hosted shell, open **Cloud Shell**.
4. If you use a local shell, confirm Azure CLI is installed and current enough to add extensions on demand.

  </div>
</div>

---
## Step 3 — Confirm the Lab 0 Foundation and Capture Subnet IDs

This lab reuses Lab 0 exactly as-is. Verify the spoke networks are still present before you create any new resources.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet show \
  --resource-group $FOUNDATION_RG_PRIMARY \
  --name $SPOKE_VNET_PRIMARY \
  --query "{Name:name,AddressSpace:addressSpace.addressPrefixes[0]}" \
  -o table

az network vnet show \
  --resource-group $FOUNDATION_RG_SECONDARY \
  --name $SPOKE_VNET_SECONDARY \
  --query "{Name:name,AddressSpace:addressSpace.addressPrefixes[0]}" \
  -o table

WORKLOAD_SUBNET_PRIMARY_ID=$(az network vnet subnet show \
  --resource-group $FOUNDATION_RG_PRIMARY \
  --vnet-name $SPOKE_VNET_PRIMARY \
  --name $WORKLOAD_SUBNET_NAME \
  --query id -o tsv)

WORKLOAD_SUBNET_SECONDARY_ID=$(az network vnet subnet show \
  --resource-group $FOUNDATION_RG_SECONDARY \
  --vnet-name $SPOKE_VNET_SECONDARY \
  --name $WORKLOAD_SUBNET_NAME \
  --query id -o tsv)

PE_SUBNET_PRIMARY_ID=$(az network vnet subnet show \
  --resource-group $FOUNDATION_RG_PRIMARY \
  --vnet-name $SPOKE_VNET_PRIMARY \
  --name $PE_SUBNET_NAME \
  --query id -o tsv)

PE_SUBNET_SECONDARY_ID=$(az network vnet subnet show \
  --resource-group $FOUNDATION_RG_SECONDARY \
  --vnet-name $SPOKE_VNET_SECONDARY \
  --name $PE_SUBNET_NAME \
  --query id -o tsv)

az network vnet subnet show \
  --resource-group $FOUNDATION_RG_PRIMARY \
  --vnet-name $SPOKE_VNET_PRIMARY \
  --name $PE_SUBNET_NAME \
  --query "{Name:name,PrivateEndpointNetworkPolicies:privateEndpointNetworkPolicies}" \
  -o table

az network vnet subnet show \
  --resource-group $FOUNDATION_RG_SECONDARY \
  --vnet-name $SPOKE_VNET_SECONDARY \
  --name $PE_SUBNET_NAME \
  --query "{Name:name,PrivateEndpointNetworkPolicies:privateEndpointNetworkPolicies}" \
  -o table

echo "Primary workload subnet : $WORKLOAD_SUBNET_PRIMARY_ID"
echo "Secondary workload subnet: $WORKLOAD_SUBNET_SECONDARY_ID"
echo "Primary PE subnet       : $PE_SUBNET_PRIMARY_ID"
echo "Secondary PE subnet     : $PE_SUBNET_SECONDARY_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet show `
  --resource-group $FOUNDATION_RG_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query "{Name:name,AddressSpace:addressSpace.addressPrefixes[0]}" `
  -o table

az network vnet show `
  --resource-group $FOUNDATION_RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query "{Name:name,AddressSpace:addressSpace.addressPrefixes[0]}" `
  -o table

$WORKLOAD_SUBNET_PRIMARY_ID = az network vnet subnet show `
  --resource-group $FOUNDATION_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query id -o tsv

$WORKLOAD_SUBNET_SECONDARY_ID = az network vnet subnet show `
  --resource-group $FOUNDATION_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $WORKLOAD_SUBNET_NAME `
  --query id -o tsv

$PE_SUBNET_PRIMARY_ID = az network vnet subnet show `
  --resource-group $FOUNDATION_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PE_SUBNET_NAME `
  --query id -o tsv

$PE_SUBNET_SECONDARY_ID = az network vnet subnet show `
  --resource-group $FOUNDATION_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PE_SUBNET_NAME `
  --query id -o tsv

az network vnet subnet show `
  --resource-group $FOUNDATION_RG_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PE_SUBNET_NAME `
  --query "{Name:name,PrivateEndpointNetworkPolicies:privateEndpointNetworkPolicies}" `
  -o table

az network vnet subnet show `
  --resource-group $FOUNDATION_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PE_SUBNET_NAME `
  --query "{Name:name,PrivateEndpointNetworkPolicies:privateEndpointNetworkPolicies}" `
  -o table

Write-Host "Primary workload subnet : $WORKLOAD_SUBNET_PRIMARY_ID"
Write-Host "Secondary workload subnet: $WORKLOAD_SUBNET_SECONDARY_ID"
Write-Host "Primary PE subnet       : $PE_SUBNET_PRIMARY_ID"
Write-Host "Secondary PE subnet     : $PE_SUBNET_SECONDARY_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Virtual networks** and verify `vnet-spoke-swc` and `vnet-spoke-noe` exist.
2. In each spoke VNet, confirm these subnets are present:
   - `snet-workload`
   - `snet-private-endpoints`
3. Confirm **Private endpoint network policies** are disabled on `snet-private-endpoints` in both regions.
4. If any of those checks fail, stop and complete Lab 0 before you continue.

  </div>
</div>

<div class="lab-note">
<strong>Why this matters:</strong> Lab 13-b intentionally reuses the fixed Lab 0 names. The whole point is that later secure variants can say “deploy into <code>vnet-spoke-swc</code> / <code>snet-private-endpoints</code>” without redefining the network first.
</div>

---

## Step 4 — Create Dedicated Resource Groups and Regional Blob Storage

The factories, SHIR VMs, private endpoints, and storage accounts for this lab live in **dedicated resource groups**, while the networking stays in the Lab 0 spokes.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name $RG_PRIMARY --location $PRIMARY_REGION --tags lab=13b region=swc scenario=private-adf -o none
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --tags lab=13b region=noe scenario=private-adf -o none

az storage account create \
  --name $STORAGE_PRIMARY \
  --resource-group $RG_PRIMARY \
  --location $PRIMARY_REGION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  -o none

az storage account create \
  --name $STORAGE_SECONDARY \
  --resource-group $RG_SECONDARY \
  --location $SECONDARY_REGION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  -o none

PRIMARY_STORAGE_KEY=$(az storage account keys list \
  --resource-group $RG_PRIMARY --account-name $STORAGE_PRIMARY \
  --query "[0].value" -o tsv)

SECONDARY_STORAGE_KEY=$(az storage account keys list \
  --resource-group $RG_SECONDARY --account-name $STORAGE_SECONDARY \
  --query "[0].value" -o tsv)

az storage container create \
  --account-name $STORAGE_PRIMARY \
  --account-key $PRIMARY_STORAGE_KEY \
  --name $CONTAINER_NAME \
  -o none

az storage container create \
  --account-name $STORAGE_SECONDARY \
  --account-key $SECONDARY_STORAGE_KEY \
  --name $CONTAINER_NAME \
  -o none
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $PRIMARY_REGION --tags lab=13b region=swc scenario=private-adf -o none
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --tags lab=13b region=noe scenario=private-adf -o none

az storage account create `
  --name $STORAGE_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --sku Standard_LRS `
  --kind StorageV2 `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false `
  -o none

az storage account create `
  --name $STORAGE_SECONDARY `
  --resource-group $RG_SECONDARY `
  --location $SECONDARY_REGION `
  --sku Standard_LRS `
  --kind StorageV2 `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false `
  -o none

$PRIMARY_STORAGE_KEY = az storage account keys list `
  --resource-group $RG_PRIMARY --account-name $STORAGE_PRIMARY `
  --query "[0].value" -o tsv

$SECONDARY_STORAGE_KEY = az storage account keys list `
  --resource-group $RG_SECONDARY --account-name $STORAGE_SECONDARY `
  --query "[0].value" -o tsv

az storage container create `
  --account-name $STORAGE_PRIMARY `
  --account-key $PRIMARY_STORAGE_KEY `
  --name $CONTAINER_NAME `
  -o none

az storage container create `
  --account-name $STORAGE_SECONDARY `
  --account-key $SECONDARY_STORAGE_KEY `
  --name $CONTAINER_NAME `
  -o none
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create two new resource groups:
   - `rg-adf-private-swc` in **Sweden Central**
   - `rg-adf-private-noe` in **Norway East**
2. In each resource group, create a **StorageV2** account with public blob access disabled.
3. Create a container named `adf-landing` in each account.
4. You will make the storage accounts private in the next step; right now you are only bootstrapping the accounts and containers.

  </div>
</div>

<div class="lab-note">
<strong>Bootstrap note:</strong> The container-creation step uses the storage account key only for initial setup. The pipeline itself will later use the Data Factory managed identity over the private endpoint path.
</div>

---
## Step 5 — Create the Blob Private DNS Zone, Private Endpoints, and Lock Down Public Access

This is the point where the storage path becomes private.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SPOKE_VNET_PRIMARY_ID=$(az network vnet show \
  --resource-group $FOUNDATION_RG_PRIMARY \
  --name $SPOKE_VNET_PRIMARY \
  --query id -o tsv)

SPOKE_VNET_SECONDARY_ID=$(az network vnet show \
  --resource-group $FOUNDATION_RG_SECONDARY \
  --name $SPOKE_VNET_SECONDARY \
  --query id -o tsv)

PRIMARY_STORAGE_ID=$(az storage account show \
  --resource-group $RG_PRIMARY --name $STORAGE_PRIMARY \
  --query id -o tsv)

SECONDARY_STORAGE_ID=$(az storage account show \
  --resource-group $RG_SECONDARY --name $STORAGE_SECONDARY \
  --query id -o tsv)

az network private-dns zone create \
  --resource-group $RG_PRIMARY \
  --name $PRIVATE_DNS_ZONE_BLOB \
  -o none

PRIVATE_DNS_ZONE_ID=$(az network private-dns zone show \
  --resource-group $RG_PRIMARY \
  --name $PRIVATE_DNS_ZONE_BLOB \
  --query id -o tsv)

az network private-dns link vnet create \
  --resource-group $RG_PRIMARY \
  --zone-name $PRIVATE_DNS_ZONE_BLOB \
  --name $DNS_LINK_PRIMARY \
  --virtual-network $SPOKE_VNET_PRIMARY_ID \
  --registration-enabled false \
  -o none

az network private-dns link vnet create \
  --resource-group $RG_PRIMARY \
  --zone-name $PRIVATE_DNS_ZONE_BLOB \
  --name $DNS_LINK_SECONDARY \
  --virtual-network $SPOKE_VNET_SECONDARY_ID \
  --registration-enabled false \
  -o none

az network private-endpoint create \
  --resource-group $RG_PRIMARY \
  --name $BLOB_PE_PRIMARY \
  --location $PRIMARY_REGION \
  --subnet $PE_SUBNET_PRIMARY_ID \
  --private-connection-resource-id $PRIMARY_STORAGE_ID \
  --group-id blob \
  --connection-name $BLOB_PSC_PRIMARY \
  -o none

az network private-endpoint dns-zone-group create \
  --resource-group $RG_PRIMARY \
  --endpoint-name $BLOB_PE_PRIMARY \
  --name default \
  --private-dns-zone $PRIVATE_DNS_ZONE_ID \
  --zone-name $PRIVATE_DNS_ZONE_BLOB \
  -o none

az network private-endpoint create \
  --resource-group $RG_SECONDARY \
  --name $BLOB_PE_SECONDARY \
  --location $SECONDARY_REGION \
  --subnet $PE_SUBNET_SECONDARY_ID \
  --private-connection-resource-id $SECONDARY_STORAGE_ID \
  --group-id blob \
  --connection-name $BLOB_PSC_SECONDARY \
  -o none

az network private-endpoint dns-zone-group create \
  --resource-group $RG_SECONDARY \
  --endpoint-name $BLOB_PE_SECONDARY \
  --name default \
  --private-dns-zone $PRIVATE_DNS_ZONE_ID \
  --zone-name $PRIVATE_DNS_ZONE_BLOB \
  -o none

az storage account update \
  --resource-group $RG_PRIMARY --name $STORAGE_PRIMARY \
  --public-network-access Disabled \
  -o none

az storage account update \
  --resource-group $RG_SECONDARY --name $STORAGE_SECONDARY \
  --public-network-access Disabled \
  -o none

az network private-endpoint show \
  --resource-group $RG_PRIMARY --name $BLOB_PE_PRIMARY \
  --query "customDnsConfigs[].{Fqdn:fqdn,Ip:ipAddresses[0]}" -o table

az network private-endpoint show \
  --resource-group $RG_SECONDARY --name $BLOB_PE_SECONDARY \
  --query "customDnsConfigs[].{Fqdn:fqdn,Ip:ipAddresses[0]}" -o table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SPOKE_VNET_PRIMARY_ID = az network vnet show `
  --resource-group $FOUNDATION_RG_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query id -o tsv

$SPOKE_VNET_SECONDARY_ID = az network vnet show `
  --resource-group $FOUNDATION_RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query id -o tsv

$PRIMARY_STORAGE_ID = az storage account show `
  --resource-group $RG_PRIMARY --name $STORAGE_PRIMARY `
  --query id -o tsv

$SECONDARY_STORAGE_ID = az storage account show `
  --resource-group $RG_SECONDARY --name $STORAGE_SECONDARY `
  --query id -o tsv

az network private-dns zone create `
  --resource-group $RG_PRIMARY `
  --name $PRIVATE_DNS_ZONE_BLOB `
  -o none

$PRIVATE_DNS_ZONE_ID = az network private-dns zone show `
  --resource-group $RG_PRIMARY `
  --name $PRIVATE_DNS_ZONE_BLOB `
  --query id -o tsv

az network private-dns link vnet create `
  --resource-group $RG_PRIMARY `
  --zone-name $PRIVATE_DNS_ZONE_BLOB `
  --name $DNS_LINK_PRIMARY `
  --virtual-network $SPOKE_VNET_PRIMARY_ID `
  --registration-enabled false `
  -o none

az network private-dns link vnet create `
  --resource-group $RG_PRIMARY `
  --zone-name $PRIVATE_DNS_ZONE_BLOB `
  --name $DNS_LINK_SECONDARY `
  --virtual-network $SPOKE_VNET_SECONDARY_ID `
  --registration-enabled false `
  -o none

az network private-endpoint create `
  --resource-group $RG_PRIMARY `
  --name $BLOB_PE_PRIMARY `
  --location $PRIMARY_REGION `
  --subnet $PE_SUBNET_PRIMARY_ID `
  --private-connection-resource-id $PRIMARY_STORAGE_ID `
  --group-id blob `
  --connection-name $BLOB_PSC_PRIMARY `
  -o none

az network private-endpoint dns-zone-group create `
  --resource-group $RG_PRIMARY `
  --endpoint-name $BLOB_PE_PRIMARY `
  --name default `
  --private-dns-zone $PRIVATE_DNS_ZONE_ID `
  --zone-name $PRIVATE_DNS_ZONE_BLOB `
  -o none

az network private-endpoint create `
  --resource-group $RG_SECONDARY `
  --name $BLOB_PE_SECONDARY `
  --location $SECONDARY_REGION `
  --subnet $PE_SUBNET_SECONDARY_ID `
  --private-connection-resource-id $SECONDARY_STORAGE_ID `
  --group-id blob `
  --connection-name $BLOB_PSC_SECONDARY `
  -o none

az network private-endpoint dns-zone-group create `
  --resource-group $RG_SECONDARY `
  --endpoint-name $BLOB_PE_SECONDARY `
  --name default `
  --private-dns-zone $PRIVATE_DNS_ZONE_ID `
  --zone-name $PRIVATE_DNS_ZONE_BLOB `
  -o none

az storage account update `
  --resource-group $RG_PRIMARY --name $STORAGE_PRIMARY `
  --public-network-access Disabled `
  -o none

az storage account update `
  --resource-group $RG_SECONDARY --name $STORAGE_SECONDARY `
  --public-network-access Disabled `
  -o none

az network private-endpoint show `
  --resource-group $RG_PRIMARY --name $BLOB_PE_PRIMARY `
  --query "customDnsConfigs[].{Fqdn:fqdn,Ip:ipAddresses[0]}" -o table

az network private-endpoint show `
  --resource-group $RG_SECONDARY --name $BLOB_PE_SECONDARY `
  --query "customDnsConfigs[].{Fqdn:fqdn,Ip:ipAddresses[0]}" -o table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a **Private DNS zone** named `privatelink.blob.core.windows.net`.
2. Link that zone to **both** spoke VNets:
   - `vnet-spoke-swc`
   - `vnet-spoke-noe`
3. In each dedicated lab resource group, create a **blob** private endpoint that targets the regional storage account and uses the Lab 0 subnet `snet-private-endpoints`.
4. Add the DNS zone group so the storage account FQDN resolves to the private IP automatically.
5. After both private endpoints are created, set each storage account to **Public network access = Disabled**.

  </div>
</div>

<div class="lab-note">
<strong>Private-endpoint pattern:</strong> The private endpoint is created in the dedicated lab resource group, but its NIC lands inside the Lab 0 spoke subnet. That is exactly the split you want in many real deployments: reusable networking, workload-specific private endpoints.
</div>

---
## Step 6 — Deploy the SHIR VMs into the Spoke Workload Subnets

The VMs host the self-hosted integration runtime nodes. They do <strong>not</strong> need public IP addresses if you already have Bastion from Lab 0.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az vm create \
  --resource-group $RG_PRIMARY \
  --name $SHIR_VM_PRIMARY \
  --location $PRIMARY_REGION \
  --image MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest \
  --size Standard_B2s \
  --admin-username $VM_ADMIN_USERNAME \
  --admin-password "$VM_ADMIN_PASSWORD" \
  --subnet $WORKLOAD_SUBNET_PRIMARY_ID \
  --public-ip-address "" \
  --storage-sku StandardSSD_LRS

az vm create \
  --resource-group $RG_SECONDARY \
  --name $SHIR_VM_SECONDARY \
  --location $SECONDARY_REGION \
  --image MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest \
  --size Standard_B2s \
  --admin-username $VM_ADMIN_USERNAME \
  --admin-password "$VM_ADMIN_PASSWORD" \
  --subnet $WORKLOAD_SUBNET_SECONDARY_ID \
  --public-ip-address "" \
  --storage-sku StandardSSD_LRS
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az vm create `
  --resource-group $RG_PRIMARY `
  --name $SHIR_VM_PRIMARY `
  --location $PRIMARY_REGION `
  --image MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest `
  --size Standard_B2s `
  --admin-username $VM_ADMIN_USERNAME `
  --admin-password $VM_ADMIN_PASSWORD `
  --subnet $WORKLOAD_SUBNET_PRIMARY_ID `
  --public-ip-address "" `
  --storage-sku StandardSSD_LRS

az vm create `
  --resource-group $RG_SECONDARY `
  --name $SHIR_VM_SECONDARY `
  --location $SECONDARY_REGION `
  --image MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest `
  --size Standard_B2s `
  --admin-username $VM_ADMIN_USERNAME `
  --admin-password $VM_ADMIN_PASSWORD `
  --subnet $WORKLOAD_SUBNET_SECONDARY_ID `
  --public-ip-address "" `
  --storage-sku StandardSSD_LRS
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a Windows Server 2022 VM in each dedicated lab resource group.
2. Place each VM in the Lab 0 **spoke workload subnet** for that region:
   - Sweden Central → `vnet-spoke-swc / snet-workload`
   - Norway East → `vnet-spoke-noe / snet-workload`
3. Do not assign public IPs if you plan to use Bastion.
4. Save the local admin username and password because the File System linked service uses them later.

  </div>
</div>

<div class="lab-note">
<strong>Access tip:</strong> If Lab 0 is still in place, connect through `bas-hub-swc` and `bas-hub-noe` rather than reopening public RDP to these VMs.
</div>

---
## Step 7 — Seed a Small CSV File on Both SHIR VMs

Each region gets a local file drop. That keeps the sample data path regional and private.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cat > seed-primary.ps1 <<'PSPRIMARY'
New-Item -ItemType Directory -Path 'C:\adfdrop' -Force | Out-Null
@'
species,sepal_length,sepal_width,petal_length,petal_width,region
setosa,5.1,3.5,1.4,0.2,swc
versicolor,7.0,3.2,4.7,1.4,swc
virginica,6.3,3.3,6.0,2.5,swc
'@ | Set-Content -Encoding ASCII -Path 'C:\adfdrop\iris-private.csv'
PSPRIMARY

cat > seed-secondary.ps1 <<'PSSECONDARY'
New-Item -ItemType Directory -Path 'C:\adfdrop' -Force | Out-Null
@'
species,sepal_length,sepal_width,petal_length,petal_width,region
setosa,5.0,3.4,1.5,0.2,noe
versicolor,6.4,3.2,4.5,1.5,noe
virginica,6.9,3.1,5.4,2.1,noe
'@ | Set-Content -Encoding ASCII -Path 'C:\adfdrop\iris-private.csv'
PSSECONDARY

az vm run-command invoke \
  --resource-group $RG_PRIMARY \
  --name $SHIR_VM_PRIMARY \
  --command-id RunPowerShellScript \
  --scripts @seed-primary.ps1

az vm run-command invoke \
  --resource-group $RG_SECONDARY \
  --name $SHIR_VM_SECONDARY \
  --command-id RunPowerShellScript \
  --scripts @seed-secondary.ps1
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PrimarySeed = @(
  "New-Item -ItemType Directory -Path 'C:\adfdrop' -Force | Out-Null",
  "@'",
  "species,sepal_length,sepal_width,petal_length,petal_width,region",
  "setosa,5.1,3.5,1.4,0.2,swc",
  "versicolor,7.0,3.2,4.7,1.4,swc",
  "virginica,6.3,3.3,6.0,2.5,swc",
  "'@ | Set-Content -Encoding ASCII -Path 'C:\adfdrop\iris-private.csv'"
)
$PrimarySeed | Set-Content -Path .\seed-primary.ps1

$SecondarySeed = @(
  "New-Item -ItemType Directory -Path 'C:\adfdrop' -Force | Out-Null",
  "@'",
  "species,sepal_length,sepal_width,petal_length,petal_width,region",
  "setosa,5.0,3.4,1.5,0.2,noe",
  "versicolor,6.4,3.2,4.5,1.5,noe",
  "virginica,6.9,3.1,5.4,2.1,noe",
  "'@ | Set-Content -Encoding ASCII -Path 'C:\adfdrop\iris-private.csv'"
)
$SecondarySeed | Set-Content -Path .\seed-secondary.ps1

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $SHIR_VM_PRIMARY `
  --command-id RunPowerShellScript `
  --scripts @seed-primary.ps1

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $SHIR_VM_SECONDARY `
  --command-id RunPowerShellScript `
  --scripts @seed-secondary.ps1
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Connect to each VM through Bastion or RDP.
2. Create the folder `C:\adfdrop`.
3. Create a file named `iris-private.csv` in each VM.
4. Put a few CSV rows into the file. Using different `region` values (`swc` vs `noe`) makes later validation easier.

  </div>
</div>

---
## Step 8 — Create the Regional Data Factory Instances

Create both factories now so you can wire primary and standby in the same naming pattern.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --location $PRIMARY_REGION \
  --public-network-access Enabled \
  -o none

az datafactory create \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --location $SECONDARY_REGION \
  --public-network-access Enabled \
  -o none
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --location $PRIMARY_REGION `
  --public-network-access Enabled `
  -o none

az datafactory create `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --location $SECONDARY_REGION `
  --public-network-access Enabled `
  -o none
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create one Data Factory in **Sweden Central** and one in **Norway East**.
2. Use the dedicated resource groups from this lab, not the Lab 0 resource groups.
3. Leave Git integration for later; the hands-on focus here is networking and DR wiring.

  </div>
</div>

<div class="lab-note">
<strong>Control-plane note:</strong> This lab keeps Data Factory authoring and monitoring on the standard public control plane. If you later need private authoring endpoints, add Azure Private Link for Data Factory as a separate hardening step.
</div>

---
## Step 9 — Enable Managed Identity, Grant Blob Access, and Create the Self-Hosted IR Objects

### 9a — Enable Managed Identity and Grant Blob Access

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

az rest --method patch \
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_PRIMARY/providers/Microsoft.DataFactory/factories/$ADF_PRIMARY?api-version=2018-06-01" \
  --body "{\"name\":\"$ADF_PRIMARY\",\"location\":\"$PRIMARY_REGION\",\"identity\":{\"type\":\"SystemAssigned\"},\"properties\":{}}" \
  -o none

az rest --method patch \
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_SECONDARY/providers/Microsoft.DataFactory/factories/$ADF_SECONDARY?api-version=2018-06-01" \
  --body "{\"name\":\"$ADF_SECONDARY\",\"location\":\"$SECONDARY_REGION\",\"identity\":{\"type\":\"SystemAssigned\"},\"properties\":{}}" \
  -o none

ADF_PRIMARY_PRINCIPAL_ID=$(az datafactory show \
  --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY \
  --query identity.principalId -o tsv)

ADF_SECONDARY_PRINCIPAL_ID=$(az datafactory show \
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
  --query identity.principalId -o tsv)

PRIMARY_STORAGE_ID=$(az storage account show \
  --resource-group $RG_PRIMARY --name $STORAGE_PRIMARY \
  --query id -o tsv)

SECONDARY_STORAGE_ID=$(az storage account show \
  --resource-group $RG_SECONDARY --name $STORAGE_SECONDARY \
  --query id -o tsv)

az role assignment create \
  --assignee-object-id $ADF_PRIMARY_PRINCIPAL_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope $PRIMARY_STORAGE_ID \
  -o none

az role assignment create \
  --assignee-object-id $ADF_SECONDARY_PRINCIPAL_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope $SECONDARY_STORAGE_ID \
  -o none

echo "Waiting 60 seconds for RBAC propagation..."
sleep 60
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SUBSCRIPTION_ID = az account show --query id --output tsv

$PrimaryFactoryPatch = @{
  name = $ADF_PRIMARY
  location = $PRIMARY_REGION
  identity = @{ type = "SystemAssigned" }
  properties = @{}
} | ConvertTo-Json -Depth 5 -Compress

$SecondaryFactoryPatch = @{
  name = $ADF_SECONDARY
  location = $SECONDARY_REGION
  identity = @{ type = "SystemAssigned" }
  properties = @{}
} | ConvertTo-Json -Depth 5 -Compress

az rest --method patch `
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_PRIMARY/providers/Microsoft.DataFactory/factories/$ADF_PRIMARY?api-version=2018-06-01" `
  --body $PrimaryFactoryPatch `
  -o none

az rest --method patch `
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_SECONDARY/providers/Microsoft.DataFactory/factories/$ADF_SECONDARY?api-version=2018-06-01" `
  --body $SecondaryFactoryPatch `
  -o none

$ADF_PRIMARY_PRINCIPAL_ID = az datafactory show `
  --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY `
  --query identity.principalId -o tsv

$ADF_SECONDARY_PRINCIPAL_ID = az datafactory show `
  --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
  --query identity.principalId -o tsv

$PRIMARY_STORAGE_ID = az storage account show `
  --resource-group $RG_PRIMARY --name $STORAGE_PRIMARY `
  --query id -o tsv

$SECONDARY_STORAGE_ID = az storage account show `
  --resource-group $RG_SECONDARY --name $STORAGE_SECONDARY `
  --query id -o tsv

az role assignment create `
  --assignee-object-id $ADF_PRIMARY_PRINCIPAL_ID `
  --assignee-principal-type ServicePrincipal `
  --role "Storage Blob Data Contributor" `
  --scope $PRIMARY_STORAGE_ID `
  -o none

az role assignment create `
  --assignee-object-id $ADF_SECONDARY_PRINCIPAL_ID `
  --assignee-principal-type ServicePrincipal `
  --role "Storage Blob Data Contributor" `
  --scope $SECONDARY_STORAGE_ID `
  -o none

Write-Host "Waiting 60 seconds for RBAC propagation..."
Start-Sleep -Seconds 60
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open each Data Factory and confirm the **managed identity object ID** exists.
2. In each regional storage account, assign **Storage Blob Data Contributor** to the matching Data Factory managed identity.
3. Wait about a minute before you test the linked services.

  </div>
</div>

### 9b — Create the SHIR Objects in Both Factories

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az datafactory integration-runtime self-hosted create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --name $IR_PRIMARY \
  --description "Primary spoke SHIR" \
  -o none

az datafactory integration-runtime self-hosted create \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --name $IR_SECONDARY \
  --description "Secondary spoke SHIR" \
  -o none

PRIMARY_IR_KEY=$(az datafactory integration-runtime list-auth-key \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --name $IR_PRIMARY \
  --query authKey1 -o tsv)

SECONDARY_IR_KEY=$(az datafactory integration-runtime list-auth-key \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --name $IR_SECONDARY \
  --query authKey1 -o tsv)

echo "Primary IR key  : $PRIMARY_IR_KEY"
echo "Secondary IR key: $SECONDARY_IR_KEY"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az datafactory integration-runtime self-hosted create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --name $IR_PRIMARY `
  --description "Primary spoke SHIR" `
  -o none

az datafactory integration-runtime self-hosted create `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --name $IR_SECONDARY `
  --description "Secondary spoke SHIR" `
  -o none

$PRIMARY_IR_KEY = az datafactory integration-runtime list-auth-key `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --name $IR_PRIMARY `
  --query authKey1 -o tsv

$SECONDARY_IR_KEY = az datafactory integration-runtime list-auth-key `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --name $IR_SECONDARY `
  --query authKey1 -o tsv

Write-Host "Primary IR key  : $PRIMARY_IR_KEY"
Write-Host "Secondary IR key: $SECONDARY_IR_KEY"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Manage** → **Integration runtimes**, create a **Self-hosted** IR in each factory.
2. Keep the region-specific names, for example `shir-swc-<suffix>` and `shir-noe-<suffix>`.
3. Copy the registration key from each factory; you use it in the next step on the Windows VMs.

  </div>
</div>

<div class="lab-note">
<strong>Secret-handling reminder:</strong> Treat the IR registration keys as short-lived secrets. Do not paste them into Git or save them in a shared notes file.
</div>

---
## Step 10 — Register the SHIR Nodes on the Spoke VMs

This step bridges the Azure-side SHIR object to the actual Windows VM in each spoke.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

1. Use Lab 0 Bastion or RDP to connect to the primary VM `vm-shir-swc-<suffix>`.
2. Download and install the latest **Microsoft Integration Runtime** MSI from the [Microsoft Download Center](https://www.microsoft.com/download/details.aspx?id=39717).
3. Open an elevated **Command Prompt** on the VM and run:

```cmd
cd "C:\Program Files\Microsoft Integration Runtime\5.0\Shared"
dmgcmd -rn "<PRIMARY_IR_KEY>" "node-swc"
dmgcmd -elma
dmgcmd -DisableLocalFolderPathValidation
```

4. Repeat the same process on the Norway East VM, but use the secondary key and node name:

```cmd
cd "C:\Program Files\Microsoft Integration Runtime\5.0\Shared"
dmgcmd -rn "<SECONDARY_IR_KEY>" "node-noe"
dmgcmd -elma
dmgcmd -DisableLocalFolderPathValidation
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

1. Connect to each Windows VM.
2. Download and install the latest **Microsoft Integration Runtime** MSI from the [Microsoft Download Center](https://www.microsoft.com/download/details.aspx?id=39717).
3. Open an elevated **PowerShell** prompt and run on the primary VM:

```powershell
cd "C:\Program Files\Microsoft Integration Runtime\5.0\Shared"
.\dmgcmd.exe -rn "<PRIMARY_IR_KEY>" "node-swc"
.\dmgcmd.exe -elma
.\dmgcmd.exe -DisableLocalFolderPathValidation
```

4. Repeat on the secondary VM with the secondary key:

```powershell
cd "C:\Program Files\Microsoft Integration Runtime\5.0\Shared"
.\dmgcmd.exe -rn "<SECONDARY_IR_KEY>" "node-noe"
.\dmgcmd.exe -elma
.\dmgcmd.exe -DisableLocalFolderPathValidation
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary factory in the portal and go to **Manage** → **Integration runtimes**.
2. Open the self-hosted IR setup screen and copy the registration key.
3. Connect to the primary VM through Bastion.
4. Download and install **Microsoft Integration Runtime**.
5. In **Microsoft Integration Runtime Configuration Manager**, paste the key and register the node.
6. Still on the VM, run the local-access commands from an elevated shell so the SHIR can read `C:\adfdrop`.
7. Repeat the same sequence for the Norway East VM and secondary factory.

  </div>
</div>

<div class="lab-note">
<strong>Why the extra commands?</strong> The official SHIR defaults block local-machine file access. Because this lab intentionally reads <code>C:\adfdrop</code> on the SHIR host, you must enable local-machine access and disable the local-folder validation gate.
</div>

---

## Step 11 — Create Linked Services in the Primary Factory

### 11a — File System Source via the Primary SHIR

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cat > regional-filedrop-primary.json <<EOFJSON
{
  "type": "FileServer",
  "typeProperties": {
    "host": "C:\\\\",
    "userId": ".\\\\${VM_ADMIN_USERNAME}",
    "password": {
      "type": "SecureString",
      "value": "${VM_ADMIN_PASSWORD}"
    }
  },
  "connectVia": {
    "referenceName": "${IR_PRIMARY}",
    "type": "IntegrationRuntimeReference"
  }
}
EOFJSON

az datafactory linked-service create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --linked-service-name "RegionalFileDrop" \
  --properties @regional-filedrop-primary.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
@"
{
  "type": "FileServer",
  "typeProperties": {
    "host": "C:\\\\",
    "userId": ".\\\\$VM_ADMIN_USERNAME",
    "password": {
      "type": "SecureString",
      "value": "$VM_ADMIN_PASSWORD"
    }
  },
  "connectVia": {
    "referenceName": "$IR_PRIMARY",
    "type": "IntegrationRuntimeReference"
  }
}
"@ | Set-Content -Path .\regional-filedrop-primary.json

az datafactory linked-service create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --linked-service-name "RegionalFileDrop" `
  --properties @regional-filedrop-primary.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the primary factory, open **Manage** → **Linked services**.
2. Create a new **File System** linked service.
3. Set **Host** to `C:\`.
4. Set the username to the local VM account, for example `.\adfadmin`.
5. Use the SHIR from the primary region (`shir-swc-<suffix>`) as the integration runtime.
6. Test the connection and save it as `RegionalFileDrop`.

  </div>
</div>

### 11b — Private Blob Sink via the Primary SHIR

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cat > private-blobsink-primary.json <<EOFJSON
{
  "type": "AzureBlobStorage",
  "typeProperties": {
    "serviceEndpoint": "${PRIMARY_BLOB_ENDPOINT}",
    "accountKind": "StorageV2"
  },
  "connectVia": {
    "referenceName": "${IR_PRIMARY}",
    "type": "IntegrationRuntimeReference"
  }
}
EOFJSON

az datafactory linked-service create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --linked-service-name "PrivateBlobSink" \
  --properties @private-blobsink-primary.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
@"
{
  "type": "AzureBlobStorage",
  "typeProperties": {
    "serviceEndpoint": "$PRIMARY_BLOB_ENDPOINT",
    "accountKind": "StorageV2"
  },
  "connectVia": {
    "referenceName": "$IR_PRIMARY",
    "type": "IntegrationRuntimeReference"
  }
}
"@ | Set-Content -Path .\private-blobsink-primary.json

az datafactory linked-service create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --linked-service-name "PrivateBlobSink" `
  --properties @private-blobsink-primary.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Still in **Linked services**, create an **Azure Blob Storage** linked service.
2. Choose **Managed identity** authentication.
3. Select the primary storage account.
4. In **Connect via integration runtime**, choose the primary SHIR.
5. Save the linked service as `PrivateBlobSink`.

  </div>
</div>

> **Why `connectVia` matters:** Without it, the factory would try the default Azure integration runtime. Because the storage account now allows only private access, you want the copy to run through the regional SHIR node that sits inside the spoke VNet.

---

## Step 12 — Create the Primary Datasets and Pipeline

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cat > localcsv-primary.json <<'EOFJSON'
{
  "type": "DelimitedText",
  "linkedServiceName": {
    "referenceName": "RegionalFileDrop",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "FileServerLocation",
      "folderPath": "adfdrop",
      "fileName": "iris-private.csv"
    },
    "columnDelimiter": ",",
    "firstRowAsHeader": true
  },
  "schema": []
}
EOFJSON

cat > blobcsv-primary.json <<EOFJSON
{
  "type": "DelimitedText",
  "linkedServiceName": {
    "referenceName": "PrivateBlobSink",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "AzureBlobStorageLocation",
      "container": "${CONTAINER_NAME}",
      "fileName": "output.csv"
    },
    "columnDelimiter": ",",
    "firstRowAsHeader": true
  },
  "schema": []
}
EOFJSON

cat > pipeline-primary.json <<'EOFJSON'
{
  "activities": [
    {
      "name": "CopyPrivateFileToBlob",
      "type": "Copy",
      "typeProperties": {
        "source": {
          "type": "DelimitedTextSource",
          "storeSettings": {
            "type": "FileServerReadSettings",
            "recursive": false
          },
          "formatSettings": {
            "type": "DelimitedTextReadSettings"
          }
        },
        "sink": {
          "type": "DelimitedTextSink",
          "storeSettings": {
            "type": "AzureBlobStorageWriteSettings"
          },
          "formatSettings": {
            "type": "DelimitedTextWriteSettings",
            "quoteAllText": true,
            "fileExtension": ".csv"
          }
        }
      },
      "inputs": [
        {
          "referenceName": "LocalCsvDataset",
          "type": "DatasetReference"
        }
      ],
      "outputs": [
        {
          "referenceName": "BlobCsvDataset",
          "type": "DatasetReference"
        }
      ]
    }
  ]
}
EOFJSON

az datafactory dataset create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --dataset-name "LocalCsvDataset" \
  --properties @localcsv-primary.json

az datafactory dataset create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --dataset-name "BlobCsvDataset" \
  --properties @blobcsv-primary.json

az datafactory pipeline create \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --name $PIPELINE_NAME \
  --pipeline @pipeline-primary.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
@'
{
  "type": "DelimitedText",
  "linkedServiceName": {
    "referenceName": "RegionalFileDrop",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "FileServerLocation",
      "folderPath": "adfdrop",
      "fileName": "iris-private.csv"
    },
    "columnDelimiter": ",",
    "firstRowAsHeader": true
  },
  "schema": []
}
'@ | Set-Content -Path .\localcsv-primary.json

@"
{
  "type": "DelimitedText",
  "linkedServiceName": {
    "referenceName": "PrivateBlobSink",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "AzureBlobStorageLocation",
      "container": "$CONTAINER_NAME",
      "fileName": "output.csv"
    },
    "columnDelimiter": ",",
    "firstRowAsHeader": true
  },
  "schema": []
}
"@ | Set-Content -Path .\blobcsv-primary.json

@'
{
  "activities": [
    {
      "name": "CopyPrivateFileToBlob",
      "type": "Copy",
      "typeProperties": {
        "source": {
          "type": "DelimitedTextSource",
          "storeSettings": {
            "type": "FileServerReadSettings",
            "recursive": false
          },
          "formatSettings": {
            "type": "DelimitedTextReadSettings"
          }
        },
        "sink": {
          "type": "DelimitedTextSink",
          "storeSettings": {
            "type": "AzureBlobStorageWriteSettings"
          },
          "formatSettings": {
            "type": "DelimitedTextWriteSettings",
            "quoteAllText": true,
            "fileExtension": ".csv"
          }
        }
      },
      "inputs": [
        {
          "referenceName": "LocalCsvDataset",
          "type": "DatasetReference"
        }
      ],
      "outputs": [
        {
          "referenceName": "BlobCsvDataset",
          "type": "DatasetReference"
        }
      ]
    }
  ]
}
'@ | Set-Content -Path .\pipeline-primary.json

az datafactory dataset create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --dataset-name "LocalCsvDataset" `
  --properties @localcsv-primary.json

az datafactory dataset create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --dataset-name "BlobCsvDataset" `
  --properties @blobcsv-primary.json

az datafactory pipeline create `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --name $PIPELINE_NAME `
  --pipeline @pipeline-primary.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a **DelimitedText** dataset named `LocalCsvDataset`.
2. Bind it to `RegionalFileDrop`.
3. Use `adfdrop` as the folder path and `iris-private.csv` as the file name.
4. Create another **DelimitedText** dataset named `BlobCsvDataset` bound to `PrivateBlobSink`.
5. Point it at the `adf-landing` container and file `output.csv`.
6. Build a copy pipeline named `CopyFileToBlob` that reads `LocalCsvDataset` and writes `BlobCsvDataset`.

  </div>
</div>

---

## Step 13 — Run the Primary Pipeline and Validate the Private Path

A successful run is useful, but in this hardened variant you also want to prove the storage FQDN resolves to the private endpoint from inside the spoke.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RUN_ID=$(az datafactory pipeline create-run \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --pipeline-name $PIPELINE_NAME \
  --query runId --output tsv)

echo "Pipeline run started: $RUN_ID"
echo "Waiting for the primary run to complete..."
while true; do
  STATUS=$(az datafactory pipeline-run show \
    --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY \
    --run-id $RUN_ID --query status --output tsv)
  echo "  Status: $STATUS"
  if [ "$STATUS" = "Succeeded" ] || [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ]; then
    break
  fi
  sleep 10
done

az datafactory activity-run query-by-pipeline-run \
  --resource-group $RG_PRIMARY \
  --factory-name $ADF_PRIMARY \
  --run-id $RUN_ID \
  --last-updated-after 2020-01-01T00:00:00Z \
  --last-updated-before 2035-01-01T00:00:00Z \
  --query "value[].{Activity:activityName,Status:status,RowsCopied:output.rowsCopied,DataRead:output.dataRead,DataWritten:output.dataWritten}" \
  -o table

az vm run-command invoke \
  --resource-group $RG_PRIMARY \
  --name $SHIR_VM_PRIMARY \
  --command-id RunPowerShellScript \
  --scripts "Resolve-DnsName ${STORAGE_PRIMARY}.blob.core.windows.net | Select-Object Name,IPAddress" \
            "Test-NetConnection ${STORAGE_PRIMARY}.blob.core.windows.net -Port 443 | Select-Object ComputerName,RemoteAddress,TcpTestSucceeded"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RUN_ID = az datafactory pipeline create-run `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --pipeline-name $PIPELINE_NAME `
  --query runId --output tsv

Write-Host "Pipeline run started: $RUN_ID"
Write-Host "Waiting for the primary run to complete..."
while ($true) {
  $STATUS = az datafactory pipeline-run show `
    --resource-group $RG_PRIMARY --factory-name $ADF_PRIMARY `
    --run-id $RUN_ID --query status --output tsv
  Write-Host "  Status: $STATUS"
  if ($STATUS -in @('Succeeded', 'Failed', 'Cancelled')) {
    break
  }
  Start-Sleep -Seconds 10
}

az datafactory activity-run query-by-pipeline-run `
  --resource-group $RG_PRIMARY `
  --factory-name $ADF_PRIMARY `
  --run-id $RUN_ID `
  --last-updated-after 2020-01-01T00:00:00Z `
  --last-updated-before 2035-01-01T00:00:00Z `
  --query "value[].{Activity:activityName,Status:status,RowsCopied:output.rowsCopied,DataRead:output.dataRead,DataWritten:output.dataWritten}" `
  -o table

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $SHIR_VM_PRIMARY `
  --command-id RunPowerShellScript `
  --scripts "Resolve-DnsName $STORAGE_PRIMARY.blob.core.windows.net | Select-Object Name,IPAddress" `
            "Test-NetConnection $STORAGE_PRIMARY.blob.core.windows.net -Port 443 | Select-Object ComputerName,RemoteAddress,TcpTestSucceeded"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the primary factory, trigger the pipeline manually.
2. Watch **Monitor** until the run finishes.
3. Open the SHIR VM through Bastion and run `Resolve-DnsName <storage>.blob.core.windows.net`.
4. Confirm the name resolves to the private IP from the private-endpoint subnet, not to a public IP.
5. Use **Test-NetConnection** or **nslookup** from the VM if you want an extra connectivity check.

  </div>
</div>

**Expected signals:**

- The pipeline finishes with **Succeeded**.
- The activity output shows non-zero `RowsCopied` and `DataWritten`.
- From the SHIR VM, `<storage>.blob.core.windows.net` resolves to a **10.x** private IP from the spoke private-endpoint subnet.

> ✅ **Success:** The primary factory is now copying through a spoke-hosted SHIR node to a storage account that no longer accepts public network access.

---

## Step 14 — Deploy the Equivalent Definitions to the Secondary Factory

The DR principle is unchanged: the standby region keeps the same design, but points to the Norway East VM, SHIR, and blob storage account.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cat > regional-filedrop-secondary.json <<EOFJSON
{
  "type": "FileServer",
  "typeProperties": {
    "host": "C:\\\\",
    "userId": ".\\\\${VM_ADMIN_USERNAME}",
    "password": {
      "type": "SecureString",
      "value": "${VM_ADMIN_PASSWORD}"
    }
  },
  "connectVia": {
    "referenceName": "${IR_SECONDARY}",
    "type": "IntegrationRuntimeReference"
  }
}
EOFJSON

cat > private-blobsink-secondary.json <<EOFJSON
{
  "type": "AzureBlobStorage",
  "typeProperties": {
    "serviceEndpoint": "${SECONDARY_BLOB_ENDPOINT}",
    "accountKind": "StorageV2"
  },
  "connectVia": {
    "referenceName": "${IR_SECONDARY}",
    "type": "IntegrationRuntimeReference"
  }
}
EOFJSON

cat > localcsv-secondary.json <<'EOFJSON'
{
  "type": "DelimitedText",
  "linkedServiceName": {
    "referenceName": "RegionalFileDrop",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "FileServerLocation",
      "folderPath": "adfdrop",
      "fileName": "iris-private.csv"
    },
    "columnDelimiter": ",",
    "firstRowAsHeader": true
  },
  "schema": []
}
EOFJSON

cat > blobcsv-secondary.json <<EOFJSON
{
  "type": "DelimitedText",
  "linkedServiceName": {
    "referenceName": "PrivateBlobSink",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "AzureBlobStorageLocation",
      "container": "${CONTAINER_NAME}",
      "fileName": "output.csv"
    },
    "columnDelimiter": ",",
    "firstRowAsHeader": true
  },
  "schema": []
}
EOFJSON

cat > pipeline-secondary.json <<'EOFJSON'
{
  "activities": [
    {
      "name": "CopyPrivateFileToBlob",
      "type": "Copy",
      "typeProperties": {
        "source": {
          "type": "DelimitedTextSource",
          "storeSettings": {
            "type": "FileServerReadSettings",
            "recursive": false
          },
          "formatSettings": {
            "type": "DelimitedTextReadSettings"
          }
        },
        "sink": {
          "type": "DelimitedTextSink",
          "storeSettings": {
            "type": "AzureBlobStorageWriteSettings"
          },
          "formatSettings": {
            "type": "DelimitedTextWriteSettings",
            "quoteAllText": true,
            "fileExtension": ".csv"
          }
        }
      },
      "inputs": [
        {
          "referenceName": "LocalCsvDataset",
          "type": "DatasetReference"
        }
      ],
      "outputs": [
        {
          "referenceName": "BlobCsvDataset",
          "type": "DatasetReference"
        }
      ]
    }
  ]
}
EOFJSON

az datafactory linked-service create \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --linked-service-name "RegionalFileDrop" \
  --properties @regional-filedrop-secondary.json

az datafactory linked-service create \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --linked-service-name "PrivateBlobSink" \
  --properties @private-blobsink-secondary.json

az datafactory dataset create \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --dataset-name "LocalCsvDataset" \
  --properties @localcsv-secondary.json

az datafactory dataset create \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --dataset-name "BlobCsvDataset" \
  --properties @blobcsv-secondary.json

az datafactory pipeline create \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --name $PIPELINE_NAME \
  --pipeline @pipeline-secondary.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
@"
{
  "type": "FileServer",
  "typeProperties": {
    "host": "C:\\\\",
    "userId": ".\\\\$VM_ADMIN_USERNAME",
    "password": {
      "type": "SecureString",
      "value": "$VM_ADMIN_PASSWORD"
    }
  },
  "connectVia": {
    "referenceName": "$IR_SECONDARY",
    "type": "IntegrationRuntimeReference"
  }
}
"@ | Set-Content -Path .\regional-filedrop-secondary.json

@"
{
  "type": "AzureBlobStorage",
  "typeProperties": {
    "serviceEndpoint": "$SECONDARY_BLOB_ENDPOINT",
    "accountKind": "StorageV2"
  },
  "connectVia": {
    "referenceName": "$IR_SECONDARY",
    "type": "IntegrationRuntimeReference"
  }
}
"@ | Set-Content -Path .\private-blobsink-secondary.json

@'
{
  "type": "DelimitedText",
  "linkedServiceName": {
    "referenceName": "RegionalFileDrop",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "FileServerLocation",
      "folderPath": "adfdrop",
      "fileName": "iris-private.csv"
    },
    "columnDelimiter": ",",
    "firstRowAsHeader": true
  },
  "schema": []
}
'@ | Set-Content -Path .\localcsv-secondary.json

@"
{
  "type": "DelimitedText",
  "linkedServiceName": {
    "referenceName": "PrivateBlobSink",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "AzureBlobStorageLocation",
      "container": "$CONTAINER_NAME",
      "fileName": "output.csv"
    },
    "columnDelimiter": ",",
    "firstRowAsHeader": true
  },
  "schema": []
}
"@ | Set-Content -Path .\blobcsv-secondary.json

@'
{
  "activities": [
    {
      "name": "CopyPrivateFileToBlob",
      "type": "Copy",
      "typeProperties": {
        "source": {
          "type": "DelimitedTextSource",
          "storeSettings": {
            "type": "FileServerReadSettings",
            "recursive": false
          },
          "formatSettings": {
            "type": "DelimitedTextReadSettings"
          }
        },
        "sink": {
          "type": "DelimitedTextSink",
          "storeSettings": {
            "type": "AzureBlobStorageWriteSettings"
          },
          "formatSettings": {
            "type": "DelimitedTextWriteSettings",
            "quoteAllText": true,
            "fileExtension": ".csv"
          }
        }
      },
      "inputs": [
        {
          "referenceName": "LocalCsvDataset",
          "type": "DatasetReference"
        }
      ],
      "outputs": [
        {
          "referenceName": "BlobCsvDataset",
          "type": "DatasetReference"
        }
      ]
    }
  ]
}
'@ | Set-Content -Path .\pipeline-secondary.json

az datafactory linked-service create `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --linked-service-name "RegionalFileDrop" `
  --properties @regional-filedrop-secondary.json

az datafactory linked-service create `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --linked-service-name "PrivateBlobSink" `
  --properties @private-blobsink-secondary.json

az datafactory dataset create `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --dataset-name "LocalCsvDataset" `
  --properties @localcsv-secondary.json

az datafactory dataset create `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --dataset-name "BlobCsvDataset" `
  --properties @blobcsv-secondary.json

az datafactory pipeline create `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --name $PIPELINE_NAME `
  --pipeline @pipeline-secondary.json
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Repeat the primary design in the Norway East factory.
2. Recreate `RegionalFileDrop`, but bind it to the **secondary** SHIR.
3. Recreate `PrivateBlobSink`, but bind it to the **secondary** storage account and SHIR.
4. Recreate the same two datasets and the same `CopyFileToBlob` pipeline.
5. Keep the definitions symmetrical so failover is operationally boring.

  </div>
</div>

---

## Step 15 — Run the Secondary Pipeline and Validate the Standby Region

Now prove the standby region can run independently with its own VM, SHIR, and private storage endpoint.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RUN_ID_SECONDARY=$(az datafactory pipeline create-run \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --pipeline-name $PIPELINE_NAME \
  --query runId --output tsv)

echo "Secondary pipeline run started: $RUN_ID_SECONDARY"
echo "Waiting for the standby run to complete..."
while true; do
  STATUS_SECONDARY=$(az datafactory pipeline-run show \
    --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY \
    --run-id $RUN_ID_SECONDARY --query status --output tsv)
  echo "  Status: $STATUS_SECONDARY"
  if [ "$STATUS_SECONDARY" = "Succeeded" ] || [ "$STATUS_SECONDARY" = "Failed" ] || [ "$STATUS_SECONDARY" = "Cancelled" ]; then
    break
  fi
  sleep 10
done

az datafactory activity-run query-by-pipeline-run \
  --resource-group $RG_SECONDARY \
  --factory-name $ADF_SECONDARY \
  --run-id $RUN_ID_SECONDARY \
  --last-updated-after 2020-01-01T00:00:00Z \
  --last-updated-before 2035-01-01T00:00:00Z \
  --query "value[].{Activity:activityName,Status:status,RowsCopied:output.rowsCopied,DataRead:output.dataRead,DataWritten:output.dataWritten}" \
  -o table

az vm run-command invoke \
  --resource-group $RG_SECONDARY \
  --name $SHIR_VM_SECONDARY \
  --command-id RunPowerShellScript \
  --scripts "Resolve-DnsName ${STORAGE_SECONDARY}.blob.core.windows.net | Select-Object Name,IPAddress" \
            "Test-NetConnection ${STORAGE_SECONDARY}.blob.core.windows.net -Port 443 | Select-Object ComputerName,RemoteAddress,TcpTestSucceeded"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RUN_ID_SECONDARY = az datafactory pipeline create-run `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --pipeline-name $PIPELINE_NAME `
  --query runId --output tsv

Write-Host "Secondary pipeline run started: $RUN_ID_SECONDARY"
Write-Host "Waiting for the standby run to complete..."
while ($true) {
  $STATUS_SECONDARY = az datafactory pipeline-run show `
    --resource-group $RG_SECONDARY --factory-name $ADF_SECONDARY `
    --run-id $RUN_ID_SECONDARY --query status --output tsv
  Write-Host "  Status: $STATUS_SECONDARY"
  if ($STATUS_SECONDARY -in @('Succeeded', 'Failed', 'Cancelled')) {
    break
  }
  Start-Sleep -Seconds 10
}

az datafactory activity-run query-by-pipeline-run `
  --resource-group $RG_SECONDARY `
  --factory-name $ADF_SECONDARY `
  --run-id $RUN_ID_SECONDARY `
  --last-updated-after 2020-01-01T00:00:00Z `
  --last-updated-before 2035-01-01T00:00:00Z `
  --query "value[].{Activity:activityName,Status:status,RowsCopied:output.rowsCopied,DataRead:output.dataRead,DataWritten:output.dataWritten}" `
  -o table

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $SHIR_VM_SECONDARY `
  --command-id RunPowerShellScript `
  --scripts "Resolve-DnsName $STORAGE_SECONDARY.blob.core.windows.net | Select-Object Name,IPAddress" `
            "Test-NetConnection $STORAGE_SECONDARY.blob.core.windows.net -Port 443 | Select-Object ComputerName,RemoteAddress,TcpTestSucceeded"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Trigger the secondary pipeline manually.
2. Confirm the run finishes with **Succeeded**.
3. Check the secondary SHIR VM and confirm the Norway East storage account name resolves to a private IP.
4. This is your DR proof point: the standby region can run independently without flipping the primary storage account back to public access.

  </div>
</div>

> ✅ **Success:** Both regions can execute the same private-path pattern. Failover is still a runbook exercise, but now the supporting storage path is aligned with the Lab 0 spoke-network posture.

---

## Cleanup

Delete only the resources created by this lab. Leave Lab 0 intact if you plan to reuse it.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

rm -f seed-primary.ps1 seed-secondary.ps1 \
  regional-filedrop-primary.json regional-filedrop-secondary.json \
  private-blobsink-primary.json private-blobsink-secondary.json \
  localcsv-primary.json localcsv-secondary.json \
  blobcsv-primary.json blobcsv-secondary.json \
  pipeline-primary.json pipeline-secondary.json

echo "Cleanup initiated for the dedicated Lab 13-b resource groups."
echo "Lab 0 hub/spoke resource groups are intentionally left alone."
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

Remove-Item -ErrorAction SilentlyContinue `
  .\seed-primary.ps1,
  .\seed-secondary.ps1,
  .\regional-filedrop-primary.json,
  .\regional-filedrop-secondary.json,
  .\private-blobsink-primary.json,
  .\private-blobsink-secondary.json,
  .\localcsv-primary.json,
  .\localcsv-secondary.json,
  .\blobcsv-primary.json,
  .\blobcsv-secondary.json,
  .\pipeline-primary.json,
  .\pipeline-secondary.json

Write-Host "Cleanup initiated for the dedicated Lab 13-b resource groups."
Write-Host "Lab 0 hub/spoke resource groups are intentionally left alone."
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete `rg-adf-private-swc` and `rg-adf-private-noe` when you finish the lab.
2. Do <strong>not</strong> delete the Lab 0 resource groups unless you are also done with the secure `B` variants.
3. Remove any local JSON or PowerShell helper files you created during the exercise.

  </div>
</div>

After a few minutes, verify:

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group show --name $RG_PRIMARY 2>&1 | head -1
az group show --name $RG_SECONDARY 2>&1 | head -1
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group show --name $RG_PRIMARY --output none 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Primary lab resource group deleted" }

az group show --name $RG_SECONDARY --output none 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Secondary lab resource group deleted" }
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Refresh the **Resource groups** list in the portal.
2. Confirm the two **dedicated Lab 13-b** resource groups disappear or show as deleting.
3. Leave Lab 0 resources in place if you plan to reuse the secure network foundation later.

  </div>
</div>

---

## Discussion — Making Private ADF DR Production-Ready

### Keep Definitions in Git and Parameterize the Regional Differences

The secure variant should still follow the same DR rule as Lab 13-a: **one source of truth, two regional deployments**.

At minimum, parameterize:

- factory name
- SHIR name
- storage endpoint
- VM name or file-share path
- target container and file path

The more symmetrical your primary and secondary definitions are, the less work your failover runbook needs to do.

### Replace the Local File Drop with a Real Private Source

The local `C:\adfdrop` file is a deliberate lab simplification. In a real design, the same pattern usually fronts one of these sources instead:

- an on-premises file share over ExpressRoute or VPN
- Azure SQL or SQL MI behind private connectivity
- Azure Files or Blob Storage with private endpoints
- an internal application export dropped on a file share that the SHIR can reach

The important lesson is not “use a local file forever.” The lesson is “the standby region must have an equivalent private path to the source.”

### Add High Availability to the SHIR Layer

In production, a single VM per region is usually not enough.

Recommended hardening steps:

- add at least two SHIR nodes per region
- join both nodes to the same regional IR
- keep the node versions aligned
- monitor queue length, CPU, and concurrent copy load
- pre-register the standby region instead of waiting for a disaster to do it

### Consider Azure Private Link for Data Factory Authoring and Monitoring

This lab hardened the <strong>data path</strong>, but not the Data Factory authoring endpoint.

If your security policy requires private access to the factory UI and monitoring APIs as well, evaluate:

- Azure Private Link for Azure Data Factory
- corporate DNS updates for the authoring endpoint
- browser or jump-host access that stays inside the trusted network boundary

### Revisit the Lab 0 Firewall Story Before Forced Tunneling

Lab 0 intentionally left the staged route tables unattached so later labs could stay focused.

Before you force all workload egress through Azure Firewall, make sure you account for:

- SHIR outbound `443` to Azure Relay / ADF control-plane dependencies
- Windows Update and Microsoft download access during VM setup
- DNS resolution for the private-link zones
- any package feeds or operational tooling you use on the SHIR nodes

### Key Takeaways

1. **ADF DR is still active/passive** — you duplicate factories, definitions, and operational runbooks.
2. **Private endpoints belong in the spoke PE subnet**, not on the compute subnet.
3. **SHIR is the private execution bridge** when your source or sink is reachable only inside the trusted network.
4. **Lab 0 gives you the reusable network landing zones**; later `B` labs should plug into them instead of redefining them.
5. **The standby region is only useful if its private path is already built and tested.**

---

## Further Reading

- [Azure Data Factory — BCDR](https://learn.microsoft.com/azure/data-factory/data-factory-bcdr)
- [Create and configure a self-hosted integration runtime](https://learn.microsoft.com/azure/data-factory/create-self-hosted-integration-runtime)
- [Copy data from/to a file system](https://learn.microsoft.com/azure/data-factory/connector-file-system)
- [Copy and transform data in Azure Blob Storage](https://learn.microsoft.com/azure/data-factory/connector-azure-blob-storage)
- [Azure Private Link for Azure Data Factory](https://learn.microsoft.com/azure/data-factory/data-factory-private-link)

---

[← Lab 13-a: Azure Data Factory DR](lab-13a-data-factory-dr.md)
