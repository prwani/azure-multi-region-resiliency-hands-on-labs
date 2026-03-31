---
layout: default
title: "Lab 1-b: Azure Blob Storage – Object Replication with Private Endpoints"
---

[← Lab 1-a — Blob Storage Replication](lab-01a-blob-storage-replication.md) | [Back to Index](../index.md)

# Lab 1-b: Azure Blob Storage – Object Replication with Private Endpoints

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
      <path d="M13.78 4.22a.75.75 0 0 1 0 1.06l-7.25 7.25a.75.75 0 0 1-1.06 0L2.22 9.28a.75.75 1 1 1 1.06-1.06L6 10.94l6.72-6.72a.75.75 0 0 1 1.06 0Z"></path>
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

> **Objective:** Re-create the blob object replication workflow with the Lab 0 hub-and-spoke foundation, using a private endpoint for the source storage account in the primary spoke and a private endpoint for the destination account in the DR spoke.

<div class="lab-note">
<strong>Lab 0 required:</strong> This <code>B</code> path assumes the fixed Lab 0 resource names already exist, including <code>rg-spoke-swc</code>, <code>rg-spoke-noe</code>, <code>vnet-spoke-swc</code>, <code>vnet-spoke-noe</code>, and <code>snet-private-endpoints</code> in both regions.
</div>

<div class="lab-note">
<strong>Operator path:</strong> Finish the container creation, Object Replication policy setup, and first test upload while public network access is still enabled. After the private endpoints and private DNS records are ready, disable public network access and validate the private-only path from hosts that already live inside the spokes.
</div>

> **⚠️ Cost note:** This secured path adds two private endpoints and a shared private DNS zone. If you spin up temporary validation hosts inside the spokes, remember to delete them when you finish.

---

## Why Add Private Endpoints to Object Replication?

Object Replication itself is **service-managed**. Azure Storage still handles the asynchronous copy from the source container to the destination container. What changes in Lab 1-b is the **client access path**: operators and applications should reach the storage accounts through **Private Link** instead of through public endpoints.

This variant therefore combines three ideas:

1. **The same two-region Object Replication flow** used in Lab 1-a.
2. **Private endpoints** placed in the Lab 0 spoke VNets, one per regional storage account.
3. **A shared private DNS zone** so the normal blob FQDN resolves to a private IP from inside the approved VNets.

| Layer | Design in Lab 1-b |
|---|---|
| **Source account** | Sweden Central storage account with Object Replication source container |
| **Destination account** | Norway East storage account with replicated, read-only destination container |
| **Private connectivity** | One `blob` private endpoint in each Lab 0 spoke VNet |
| **DNS** | `privatelink.blob.core.windows.net` linked to both spokes |
| **Operator workflow** | Configure and seed while public access is enabled, then disable it after Private Link is ready |
| **Validation path** | Hosts already inside the matching regional spoke VNet |

<div class="lab-note">
<strong>Design note:</strong> Lab 0 does not create cross-region peering between <code>vnet-spoke-swc</code> and <code>vnet-spoke-noe</code>. After you disable public network access, validate the Sweden Central account from a host in the Sweden Central spoke and the Norway East account from a host in the Norway East spoke. If you need a single host to reach both accounts privately, add extra private endpoints or connect the VNets.
</div>

---

## Architecture

```text
┌──────────────────────────── Sweden Central (Primary) ───────────────────────────┐
│ rg-blob-private-swc                                                             │
│  stblobswc<suffix>  (source account)                                            │
│                                                                                 │
│ rg-spoke-swc / vnet-spoke-swc                                                   │
│  └─ snet-private-endpoints → pe-blob-swc-<suffix> ───────► blob subresource    │
└─────────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     │ Object Replication (service-managed)
                                     ▼
┌───────────────────────────── Norway East (DR) ──────────────────────────────────┐
│ rg-blob-private-noe                                                             │
│  stblobnoe<suffix>  (destination account / read-only replicated container)      │
│                                                                                 │
│ rg-spoke-noe / vnet-spoke-noe                                                   │
│  └─ snet-private-endpoints → pe-blob-noe-<suffix> ───────► blob subresource    │
└─────────────────────────────────────────────────────────────────────────────────┘

Shared private DNS zone:
  privatelink.blob.core.windows.net
  linked to vnet-spoke-swc and vnet-spoke-noe

Public network access:
  enabled during setup
  disabled after the private endpoints are ready
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Lab 0 completed** | The fixed spoke VNets and `snet-private-endpoints` already exist in both regions |
| **Azure subscription** | Contributor or Owner on the new lab resource groups plus permission to create private endpoints and private DNS links |
| **Azure CLI** | Version 2.60 or later recommended (`az --version`) |
| **PowerShell 7+** *(optional)* | Needed only if you follow the PowerShell path |
| **Logged-in session** | `az login` and the correct subscription selected |
| **Data-plane RBAC** | Your operator identity must be able to use `az storage ... --auth-mode login` on both accounts while public access is still enabled |
| **Validation hosts** | Optional but recommended: one existing or temporary host inside each spoke if you want to prove private-only DNS/TLS after lock-down |

> **Private Link reminder:** creating a private endpoint does **not** automatically disable the public endpoint. You will do that explicitly later in the lab after the private path is ready.

---

## How These Tabs Work

This page uses the same interaction pattern as the rest of the series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behavior used in the other labs.

> **Private access note:** After you disable public network access, direct blob data-plane checks should come from hosts already inside the spoke VNets — not from Cloud Shell or a laptop on the public internet.

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
2. If needed, switch to the correct tenant or directory.
3. Open **Subscriptions** and confirm the subscription that will host the lab resources.
4. Keep the portal open — you will reuse it throughout the lab.

  </div>
</div>

---

## Step 1 — Set Variables

Reuse the fixed Lab 0 network names, but generate unique names for the new storage accounts and private endpoints.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
UNIQUE_SUFFIX=$(printf '%05d' $((RANDOM % 100000)))

PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

LAB0_SPOKE_RG_PRIMARY="rg-spoke-swc"
LAB0_SPOKE_RG_SECONDARY="rg-spoke-noe"
SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_SECONDARY="vnet-spoke-noe"
PE_SUBNET_NAME="snet-private-endpoints"

RG_PRIMARY="rg-blob-private-swc"
RG_SECONDARY="rg-blob-private-noe"

SRC_ACCOUNT="stblobswc${UNIQUE_SUFFIX}"
DST_ACCOUNT="stblobnoe${UNIQUE_SUFFIX}"
SRC_PE="pe-blob-swc-${UNIQUE_SUFFIX}"
DST_PE="pe-blob-noe-${UNIQUE_SUFFIX}"

PRIVATE_DNS_ZONE="privatelink.blob.core.windows.net"
SRC_CONTAINER="source-01"
DST_CONTAINER="dest-01"
TEST_BLOB="hello-private.txt"
LOCAL_FILE="./${TEST_BLOB}"

echo "Source account:      $SRC_ACCOUNT"
echo "Destination account: $DST_ACCOUNT"
echo "Source PE:           $SRC_PE"
echo "Destination PE:      $DST_PE"
echo "Private DNS zone:    $PRIVATE_DNS_ZONE"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$UNIQUE_SUFFIX = '{0:d5}' -f (Get-Random -Minimum 0 -Maximum 100000)

$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$LAB0_SPOKE_RG_PRIMARY = "rg-spoke-swc"
$LAB0_SPOKE_RG_SECONDARY = "rg-spoke-noe"
$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"
$PE_SUBNET_NAME = "snet-private-endpoints"

$RG_PRIMARY = "rg-blob-private-swc"
$RG_SECONDARY = "rg-blob-private-noe"

$SRC_ACCOUNT = "stblobswc$UNIQUE_SUFFIX"
$DST_ACCOUNT = "stblobnoe$UNIQUE_SUFFIX"
$SRC_PE = "pe-blob-swc-$UNIQUE_SUFFIX"
$DST_PE = "pe-blob-noe-$UNIQUE_SUFFIX"

$PRIVATE_DNS_ZONE = "privatelink.blob.core.windows.net"
$SRC_CONTAINER = "source-01"
$DST_CONTAINER = "dest-01"
$TEST_BLOB = "hello-private.txt"
$LOCAL_FILE = Join-Path (Get-Location) $TEST_BLOB

Write-Host "Source account:      $SRC_ACCOUNT"
Write-Host "Destination account: $DST_ACCOUNT"
Write-Host "Source PE:           $SRC_PE"
Write-Host "Destination PE:      $DST_PE"
Write-Host "Private DNS zone:    $PRIVATE_DNS_ZONE"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Reuse these fixed Lab 0 names:

- Spoke resource groups: `rg-spoke-swc`, `rg-spoke-noe`
- Spoke VNets: `vnet-spoke-swc`, `vnet-spoke-noe`
- Private endpoint subnet in each spoke: `snet-private-endpoints`

Create or note these new lab values:

- Resource groups: `rg-blob-private-swc`, `rg-blob-private-noe`
- Source account: `stblobswc<suffix>`
- Destination account: `stblobnoe<suffix>`
- Source private endpoint: `pe-blob-swc-<suffix>`
- Destination private endpoint: `pe-blob-noe-<suffix>`
- Private DNS zone: `privatelink.blob.core.windows.net`
- Containers: `source-01`, `dest-01`
- Test blob: `hello-private.txt`

  </div>
</div>

---

## Step 2 — Validate the Lab 0 Spoke Foundation

Stop here and complete Lab 0 first if either spoke VNet or either private-endpoint subnet is missing.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet show \
  --resource-group "$LAB0_SPOKE_RG_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query '{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}' \
  --output table

az network vnet subnet show \
  --resource-group "$LAB0_SPOKE_RG_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$PE_SUBNET_NAME" \
  --query '{Name:name, Prefix:addressPrefix, PENetworkPolicies:privateEndpointNetworkPolicies}' \
  --output table

az network vnet show \
  --resource-group "$LAB0_SPOKE_RG_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query '{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}' \
  --output table

az network vnet subnet show \
  --resource-group "$LAB0_SPOKE_RG_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$PE_SUBNET_NAME" \
  --query '{Name:name, Prefix:addressPrefix, PENetworkPolicies:privateEndpointNetworkPolicies}' \
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
  --name $PE_SUBNET_NAME `
  --query '{Name:name, Prefix:addressPrefix, PENetworkPolicies:privateEndpointNetworkPolicies}' `
  --output table

az network vnet show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query '{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}' `
  --output table

az network vnet subnet show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PE_SUBNET_NAME `
  --query '{Name:name, Prefix:addressPrefix, PENetworkPolicies:privateEndpointNetworkPolicies}' `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `vnet-spoke-swc` and `vnet-spoke-noe` in the Azure portal.
2. In each VNet, verify that `snet-private-endpoints` exists.
3. Confirm **Private endpoint network policies** are disabled on that subnet in both regions.
4. If any of those checks fail, stop and complete Lab 0 before continuing.

  </div>
</div>

---

## Step 3 — Create the Resource Groups and the Private DNS Zone

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
  --name "$PRIVATE_DNS_ZONE" \
  --output table
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
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create `rg-blob-private-swc` in **Sweden Central**.
2. Create `rg-blob-private-noe` in **Norway East**.
3. Create a Private DNS zone named `privatelink.blob.core.windows.net` in `rg-blob-private-swc`.
4. Leave the zone empty for now; the private endpoints will add the A records later.

  </div>
</div>

---

## Step 4 — Link the DNS Zone to Both Spoke VNets

Link the shared Private DNS zone to both spoke VNets before you create the private endpoints, so DNS records resolve as soon as the endpoints are approved.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_VNET_ID=$(az network vnet show \
  --resource-group "$LAB0_SPOKE_RG_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query id -o tsv)

SECONDARY_VNET_ID=$(az network vnet show \
  --resource-group "$LAB0_SPOKE_RG_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query id -o tsv)

az network private-dns link vnet create \
  --resource-group "$RG_PRIMARY" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name link-vnet-spoke-swc \
  --virtual-network "$PRIMARY_VNET_ID" \
  --registration-enabled false \
  --output table

az network private-dns link vnet create \
  --resource-group "$RG_PRIMARY" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name link-vnet-spoke-noe \
  --virtual-network "$SECONDARY_VNET_ID" \
  --registration-enabled false \
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
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the `privatelink.blob.core.windows.net` Private DNS zone.
2. Go to **Virtual network links**.
3. Add one link for `vnet-spoke-swc` and a second link for `vnet-spoke-noe`.
4. Leave **auto registration** disabled for both links.

  </div>
</div>

---

## Step 5 — Create the Source and Destination Storage Accounts

At this stage, keep public network access available so you can finish the Object Replication setup from your current terminal. Anonymous blob access stays disabled the entire time.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account create \
  --name "$SRC_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags role=source lab=01b \
  --output table

az storage account create \
  --name "$DST_ACCOUNT" \
  --resource-group "$RG_SECONDARY" \
  --location "$SECONDARY_REGION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags role=destination lab=01b \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account create `
  --name $SRC_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --sku Standard_LRS `
  --kind StorageV2 `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false `
  --tags role=source lab=01b `
  --output table

az storage account create `
  --name $DST_ACCOUNT `
  --resource-group $RG_SECONDARY `
  --location $SECONDARY_REGION `
  --sku Standard_LRS `
  --kind StorageV2 `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false `
  --tags role=destination lab=01b `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create `stblobswc<suffix>` in `rg-blob-private-swc` / **Sweden Central**.
2. Create `stblobnoe<suffix>` in `rg-blob-private-noe` / **Norway East**.
3. For both accounts:
   - Use **LRS** redundancy.
   - Set **Minimum TLS version = 1.2**.
   - Set **Allow Blob public access = Disabled**.
   - Leave the **public network endpoint enabled** for now.

  </div>
</div>

<div class="lab-note">
<strong>Important distinction:</strong> <code>Allow Blob public access = Disabled</code> blocks anonymous blob reads. It does <em>not</em> disable the account's public network endpoint. You will disable public network access explicitly later.
</div>

---

## Step 6 — Enable Versioning and Change Feed

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account blob-service-properties update \
  --account-name "$SRC_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --enable-versioning true \
  --enable-change-feed true

az storage account blob-service-properties update \
  --account-name "$DST_ACCOUNT" \
  --resource-group "$RG_SECONDARY" \
  --enable-versioning true
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account blob-service-properties update `
  --account-name $SRC_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --enable-versioning true `
  --enable-change-feed true

az storage account blob-service-properties update `
  --account-name $DST_ACCOUNT `
  --resource-group $RG_SECONDARY `
  --enable-versioning true
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. On the **source** account, enable **Versioning for blobs** and **Blob change feed**.
2. On the **destination** account, enable **Versioning for blobs**.
3. Save the changes on both accounts.

  </div>
</div>

---

## Step 7 — Create the Containers

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage container create \
  --name "$SRC_CONTAINER" \
  --account-name "$SRC_ACCOUNT" \
  --auth-mode login

az storage container create \
  --name "$DST_CONTAINER" \
  --account-name "$DST_ACCOUNT" \
  --auth-mode login
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage container create `
  --name $SRC_CONTAINER `
  --account-name $SRC_ACCOUNT `
  --auth-mode login

az storage container create `
  --name $DST_CONTAINER `
  --account-name $DST_ACCOUNT `
  --auth-mode login
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the source account, create a private container named `source-01`.
2. In the destination account, create a private container named `dest-01`.
3. Do not upload anything into `dest-01` directly after the replication policy is active.

  </div>
</div>

---

## Step 8 — Create the Object Replication Policy

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

**8a — Create the destination-side policy:**

```bash
DST_POLICY=$(az storage account or-policy create \
  --account-name "$DST_ACCOUNT" \
  --resource-group "$RG_SECONDARY" \
  --source-account "$SRC_ACCOUNT" \
  --destination-account "$DST_ACCOUNT" \
  --source-container "$SRC_CONTAINER" \
  --destination-container "$DST_CONTAINER" \
  --min-creation-time "1601-01-01T00:00:00Z" \
  --query policyId -o tsv)

echo "Destination-side policy ID: $DST_POLICY"
```

**8b — Retrieve the generated rule ID:**

```bash
RULE_ID=$(az storage account or-policy rule list \
  --account-name "$DST_ACCOUNT" \
  --resource-group "$RG_SECONDARY" \
  --policy-id "$DST_POLICY" \
  --query "[0].ruleId" -o tsv)

echo "Rule ID: $RULE_ID"
```

**8c — Apply the matching source-side policy:**

```bash
az storage account or-policy create \
  --account-name "$SRC_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --source-account "$SRC_ACCOUNT" \
  --destination-account "$DST_ACCOUNT" \
  --policy-id "$DST_POLICY" \
  --source-container "$SRC_CONTAINER" \
  --destination-container "$DST_CONTAINER" \
  --rule-id "$RULE_ID" \
  --min-creation-time "1601-01-01T00:00:00Z"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

**8a — Create the destination-side policy:**

```powershell
$DST_POLICY = az storage account or-policy create `
  --account-name $DST_ACCOUNT `
  --resource-group $RG_SECONDARY `
  --source-account $SRC_ACCOUNT `
  --destination-account $DST_ACCOUNT `
  --source-container $SRC_CONTAINER `
  --destination-container $DST_CONTAINER `
  --min-creation-time "1601-01-01T00:00:00Z" `
  --query policyId -o tsv

Write-Host "Destination-side policy ID: $DST_POLICY"
```

**8b — Retrieve the generated rule ID:**

```powershell
$RULE_ID = az storage account or-policy rule list `
  --account-name $DST_ACCOUNT `
  --resource-group $RG_SECONDARY `
  --policy-id $DST_POLICY `
  --query "[0].ruleId" -o tsv

Write-Host "Rule ID: $RULE_ID"
```

**8c — Apply the matching source-side policy:**

```powershell
az storage account or-policy create `
  --account-name $SRC_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --source-account $SRC_ACCOUNT `
  --destination-account $DST_ACCOUNT `
  --policy-id $DST_POLICY `
  --source-container $SRC_CONTAINER `
  --destination-container $DST_CONTAINER `
  --rule-id $RULE_ID `
  --min-creation-time "1601-01-01T00:00:00Z"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account.
2. Under **Data management**, open **Object replication**.
3. Create one rule that maps `source-01` to `dest-01`.
4. Set **Copy blobs created before** to a date earlier than the account creation date so the seed blob will be included.
5. Save the rule.

  </div>
</div>

<div class="lab-note">
<strong>Same core behavior as Lab 1-a:</strong> once the policy is active, `dest-01` becomes a read-only replicated container and future writes must enter through the source account.
</div>

---

## Step 9 — Seed the Policy and Confirm Replication Before Lockdown

Upload one test blob while public network access is still enabled. This proves the storage replication workflow works before you tighten the network posture.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
printf 'Hello from Sweden Central over the setup path — %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" > "$LOCAL_FILE"

az storage blob upload \
  --account-name "$SRC_ACCOUNT" \
  --container-name "$SRC_CONTAINER" \
  --name "$TEST_BLOB" \
  --file "$LOCAL_FILE" \
  --auth-mode login \
  --overwrite

echo "Waiting for replication to complete..."
while true; do
  STATUS=$(az storage blob show \
    --account-name "$SRC_ACCOUNT" \
    --container-name "$SRC_CONTAINER" \
    --name "$TEST_BLOB" \
    --auth-mode login \
    --query "objectReplicationSourceProperties[0].rules[0].status" \
    -o tsv 2>/dev/null)
  echo "  Status: ${STATUS:-not yet available}"
  [ "$STATUS" = "complete" ] && break
  sleep 10
done

az storage blob list \
  --account-name "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --auth-mode login \
  --query "[].{Name:name, LastModified:properties.lastModified}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
"Hello from Sweden Central over the setup path — $(Get-Date -Format 'u')" | Set-Content -Path $LOCAL_FILE

az storage blob upload `
  --account-name $SRC_ACCOUNT `
  --container-name $SRC_CONTAINER `
  --name $TEST_BLOB `
  --file $LOCAL_FILE `
  --auth-mode login `
  --overwrite

Write-Host "Waiting for replication to complete..."
do {
  $STATUS = az storage blob show `
    --account-name $SRC_ACCOUNT `
    --container-name $SRC_CONTAINER `
    --name $TEST_BLOB `
    --auth-mode login `
    --query "objectReplicationSourceProperties[0].rules[0].status" `
    -o tsv 2>$null
  Write-Host "  Status: $(if ($STATUS) { $STATUS } else { 'not yet available' })"
  if ($STATUS -eq 'complete') { break }
  Start-Sleep -Seconds 10
} while ($true)

az storage blob list `
  --account-name $DST_ACCOUNT `
  --container-name $DST_CONTAINER `
  --auth-mode login `
  --query "[].{Name:name, LastModified:properties.lastModified}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Upload a small file into **source-01** on the source account.
2. Wait until the **Object replication** status on that blob shows **Complete**.
3. Confirm the blob appears in `dest-01` on the destination account.

This is your last convenient public-endpoint data-plane check before the private-only cutover.

  </div>
</div>

<div class="lab-note">
<strong>Checkpoint:</strong> Once the seeded blob shows up in `dest-01`, the remaining steps change only the client access path. The service-managed replication flow itself is already working.
</div>

---

## Step 10 — Create the Private Endpoints in the Spokes

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SRC_ACCOUNT_ID=$(az storage account show \
  --name "$SRC_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --query id -o tsv)

DST_ACCOUNT_ID=$(az storage account show \
  --name "$DST_ACCOUNT" \
  --resource-group "$RG_SECONDARY" \
  --query id -o tsv)

az network private-endpoint create \
  --name "$SRC_PE" \
  --resource-group "$LAB0_SPOKE_RG_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --subnet "$PE_SUBNET_NAME" \
  --private-connection-resource-id "$SRC_ACCOUNT_ID" \
  --group-id blob \
  --connection-name "${SRC_PE}-conn" \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group "$LAB0_SPOKE_RG_PRIMARY" \
  --endpoint-name "$SRC_PE" \
  --name default \
  --private-dns-zone "$PRIVATE_DNS_ZONE" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-endpoint create \
  --name "$DST_PE" \
  --resource-group "$LAB0_SPOKE_RG_SECONDARY" \
  --location "$SECONDARY_REGION" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --subnet "$PE_SUBNET_NAME" \
  --private-connection-resource-id "$DST_ACCOUNT_ID" \
  --group-id blob \
  --connection-name "${DST_PE}-conn" \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group "$LAB0_SPOKE_RG_SECONDARY" \
  --endpoint-name "$DST_PE" \
  --name default \
  --private-dns-zone "$PRIVATE_DNS_ZONE" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SRC_ACCOUNT_ID = az storage account show `
  --name $SRC_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --query id -o tsv

$DST_ACCOUNT_ID = az storage account show `
  --name $DST_ACCOUNT `
  --resource-group $RG_SECONDARY `
  --query id -o tsv

az network private-endpoint create `
  --name $SRC_PE `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --location $PRIMARY_REGION `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --subnet $PE_SUBNET_NAME `
  --private-connection-resource-id $SRC_ACCOUNT_ID `
  --group-id blob `
  --connection-name "$SRC_PE-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --endpoint-name $SRC_PE `
  --name default `
  --private-dns-zone $PRIVATE_DNS_ZONE `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table

az network private-endpoint create `
  --name $DST_PE `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --location $SECONDARY_REGION `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --subnet $PE_SUBNET_NAME `
  --private-connection-resource-id $DST_ACCOUNT_ID `
  --group-id blob `
  --connection-name "$DST_PE-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --endpoint-name $DST_PE `
  --name default `
  --private-dns-zone $PRIVATE_DNS_ZONE `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Sweden Central**, create a private endpoint for `stblobswc<suffix>` inside `rg-spoke-swc` / `vnet-spoke-swc` / `snet-private-endpoints`.
2. Target the **blob** subresource and integrate it with the existing `privatelink.blob.core.windows.net` Private DNS zone.
3. In **Norway East**, repeat the same process for `stblobnoe<suffix>` inside `rg-spoke-noe` / `vnet-spoke-noe` / `snet-private-endpoints`.
4. Confirm both endpoint connections reach the **Approved** state.

  </div>
</div>

<div class="lab-note">
<strong>Approval behavior:</strong> When the same subscription owns both the storage account and the private endpoint, approval is usually automatic. If either endpoint stays pending, open the storage account's <strong>Private endpoint connections</strong> blade and approve it manually.
</div>

---

## Step 11 — Verify Private DNS Records and Endpoint State

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-endpoint show \
  --resource-group "$LAB0_SPOKE_RG_PRIMARY" \
  --name "$SRC_PE" \
  --query '{Name:name, Provisioning:provisioningState, Subnet:subnet.id}' \
  --output table

az network private-endpoint show \
  --resource-group "$LAB0_SPOKE_RG_SECONDARY" \
  --name "$DST_PE" \
  --query '{Name:name, Provisioning:provisioningState, Subnet:subnet.id}' \
  --output table

az network private-dns record-set a list \
  --resource-group "$RG_PRIMARY" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --query "[].{Name:name, IP:arecords[0].ipv4Address}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-endpoint show `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --name $SRC_PE `
  --query '{Name:name, Provisioning:provisioningState, Subnet:subnet.id}' `
  --output table

az network private-endpoint show `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --name $DST_PE `
  --query '{Name:name, Provisioning:provisioningState, Subnet:subnet.id}' `
  --output table

az network private-dns record-set a list `
  --resource-group $RG_PRIMARY `
  --zone-name $PRIVATE_DNS_ZONE `
  --query "[].{Name:name, IP:arecords[0].ipv4Address}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the `privatelink.blob.core.windows.net` Private DNS zone and confirm two A records exist — one for each storage account name.
2. Open the private endpoint for the source account and confirm it shows **Approved** / **Succeeded**.
3. Repeat for the destination private endpoint.

  </div>
</div>

<div class="lab-note">
<strong>Keep this check simple:</strong> if both private endpoints are provisioned and the DNS zone shows both storage account names, the private path is ready for the cutover step.
</div>

---

## Step 12 — Disable Public Network Access on Both Storage Accounts

Only do this after the private endpoints and DNS zone records are in place.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account update \
  --name "$SRC_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --public-network-access Disabled \
  --default-action Deny \
  --output table

az storage account update \
  --name "$DST_ACCOUNT" \
  --resource-group "$RG_SECONDARY" \
  --public-network-access Disabled \
  --default-action Deny \
  --output table

az storage account show \
  --name "$SRC_ACCOUNT" \
  --resource-group "$RG_PRIMARY" \
  --query '{Name:name, PublicNetworkAccess:publicNetworkAccess}' \
  --output table

az storage account show \
  --name "$DST_ACCOUNT" \
  --resource-group "$RG_SECONDARY" \
  --query '{Name:name, PublicNetworkAccess:publicNetworkAccess}' \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account update `
  --name $SRC_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --public-network-access Disabled `
  --default-action Deny `
  --output table

az storage account update `
  --name $DST_ACCOUNT `
  --resource-group $RG_SECONDARY `
  --public-network-access Disabled `
  --default-action Deny `
  --output table

az storage account show `
  --name $SRC_ACCOUNT `
  --resource-group $RG_PRIMARY `
  --query '{Name:name, PublicNetworkAccess:publicNetworkAccess}' `
  --output table

az storage account show `
  --name $DST_ACCOUNT `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, PublicNetworkAccess:publicNetworkAccess}' `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the source storage account and go to **Networking**.
2. Change **Public network access** to **Disabled**.
3. Repeat the same change on the destination storage account.
4. Confirm both accounts still show their approved private endpoint connections before you close the blade.

  </div>
</div>

<div class="lab-note">
<strong>From this point forward:</strong> your local terminal, Cloud Shell, or portal data-plane blades may fail to browse blob contents unless they are running from an approved private path. That is expected.
</div>

---

## Step 13 — Validate Private-Only DNS and TLS from Matching Regional Hosts

Use any host that already lives inside each spoke network — for example a temporary VM, a later-lab workload VM, or another approved compute host. You do **not** run these checks from Cloud Shell unless Cloud Shell itself is inside the spoke network.

| Host location | Validate this account | Expected private range |
|---|---|---|
| `vnet-spoke-swc` | `stblobswc<suffix>.blob.core.windows.net` | `10.10.5.64/26` |
| `vnet-spoke-noe` | `stblobnoe<suffix>.blob.core.windows.net` | `10.20.5.64/26` |

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
# Run on a Linux host inside vnet-spoke-swc
SRC_FQDN="<your-source-account>.blob.core.windows.net"
nslookup "$SRC_FQDN"
curl -I "https://$SRC_FQDN/"

# Run on a Linux host inside vnet-spoke-noe
DST_FQDN="<your-destination-account>.blob.core.windows.net"
nslookup "$DST_FQDN"
curl -I "https://$DST_FQDN/"
```

A `curl -I` response such as **400** or **403** is fine here — it still proves DNS resolution and the TLS handshake reached the Blob service over the private endpoint instead of timing out on the public path.

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Run on a Windows or PowerShell host inside vnet-spoke-swc
$SrcFqdn = "<your-source-account>.blob.core.windows.net"
Resolve-DnsName $SrcFqdn
Test-NetConnection -ComputerName $SrcFqdn -Port 443

# Run on a matching host inside vnet-spoke-noe
$DstFqdn = "<your-destination-account>.blob.core.windows.net"
Resolve-DnsName $DstFqdn
Test-NetConnection -ComputerName $DstFqdn -Port 443
```

Look for a private IP address in the expected Lab 0 range and a successful TCP connection on port 443.

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open a host that already lives in `vnet-spoke-swc` by using your normal access path (for example Bastion, SSH, or RDP).
2. Resolve the source storage account FQDN and confirm it returns a private IP from the Sweden Central private-endpoint subnet range.
3. Repeat from a host in `vnet-spoke-noe` for the destination storage account.
4. If you need one admin host to reach both storage accounts after this cutover, add extra private endpoints in the consumer VNet or connect the VNets first.

  </div>
</div>

<div class="lab-note">
<strong>Success criteria:</strong> the seed blob replicated before the cutover, both storage accounts now show <code>Public network access = Disabled</code>, and hosts inside the spokes resolve the blob FQDNs to private IP addresses instead of public ones.
</div>

---

## Validation Checklist

- [ ] The source and destination accounts exist in the intended regions
- [ ] Blob versioning is enabled on both accounts and change feed is enabled on the source account
- [ ] The seeded test blob replicated from `source-01` to `dest-01` before the cutover
- [ ] `privatelink.blob.core.windows.net` is linked to both spoke VNets
- [ ] The source and destination private endpoints are provisioned successfully in `snet-private-endpoints`
- [ ] `Public network access` is **Disabled** on both storage accounts
- [ ] An in-spoke host resolves the matching blob FQDN to a private IP and reaches TCP 443 privately

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
az network private-endpoint delete \
  --resource-group "$LAB0_SPOKE_RG_PRIMARY" \
  --name "$SRC_PE"

az network private-endpoint delete \
  --resource-group "$LAB0_SPOKE_RG_SECONDARY" \
  --name "$DST_PE"

az group delete --name "$RG_PRIMARY" --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait

rm -f "$LOCAL_FILE"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-endpoint delete `
  --resource-group $LAB0_SPOKE_RG_PRIMARY `
  --name $SRC_PE

az network private-endpoint delete `
  --resource-group $LAB0_SPOKE_RG_SECONDARY `
  --name $DST_PE

az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

Remove-Item -Path $LOCAL_FILE -Force -ErrorAction SilentlyContinue
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete the source and destination private endpoints from `rg-spoke-swc` and `rg-spoke-noe`.
2. Delete `rg-blob-private-swc` and `rg-blob-private-noe`.
3. If you created temporary validation hosts, delete them too.
4. Keep the Lab 0 hub-and-spoke foundation if you plan to continue into other secure `B` variants.

  </div>
</div>

<div class="lab-note">
<strong>Cleanup scope:</strong> Lab 1-b deletes only the storage lab resources and the private endpoints created in the spokes. It does <em>not</em> remove the shared Lab 0 networking foundation.
</div>

---

## Key Takeaways

1. **Private endpoints change the client access path, not the Object Replication engine itself.**
2. **Private DNS is mandatory** if you want the normal storage FQDN to resolve to the private endpoint IPs.
3. **Public network access is a separate control** from anonymous blob access. Disable both where appropriate, but understand the difference.
4. **One private endpoint per regional account is enough for the paired validation flow in this lab**, but a single host will not privately reach both accounts unless you add more Private Link connectivity.
5. **Run the final validation from inside the spokes** after you disable public network access.

---

## Further Reading

- [Object Replication overview](https://learn.microsoft.com/azure/storage/blobs/object-replication-overview)
- [Configure Object Replication](https://learn.microsoft.com/azure/storage/blobs/object-replication-configure)
- [Use private endpoints for Azure Storage](https://learn.microsoft.com/azure/storage/common/storage-private-endpoints)
- [Private endpoint DNS configuration](https://learn.microsoft.com/azure/private-link/private-endpoint-dns)
- [Configure Azure Storage firewalls and virtual networks](https://learn.microsoft.com/azure/storage/common/storage-network-security)
- [Companion repository: prwani/multi-region-nonpaired-azurestorage](https://github.com/prwani/multi-region-nonpaired-azurestorage)

---

[← Lab 1-a — Blob Storage Replication](lab-01a-blob-storage-replication.md) | [Back to Index](../index.md)
