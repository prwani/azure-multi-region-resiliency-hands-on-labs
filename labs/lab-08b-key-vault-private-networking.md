---
layout: default
title: "Lab 8-b: Azure Key Vault – Private Endpoints & Multi-Region Sync"
---

[← Lab 8-a — Key Vault Multi-Region](lab-08a-key-vault-multi-region.md) | [Lab 8-b — Key Vault Private Networking](lab-08b-key-vault-private-networking.md)

# Lab 8-b: Azure Key Vault – Private Endpoints & Multi-Region Sync

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

> **Objective:** Deploy paired Azure Key Vaults in Sweden Central and Norway East, seed the recovery vault, then secure both vaults behind private endpoints in the Lab 0 spoke VNets and validate private-only access.

<div class="lab-note">
<strong>Lab 0 required:</strong> This <code>B</code> path assumes you already completed Lab 0 and kept the fixed network names <code>rg-spoke-swc</code>, <code>rg-spoke-noe</code>, <code>vnet-spoke-swc</code>, <code>vnet-spoke-noe</code>, and <code>snet-private-endpoints</code>.
</div>

<div class="lab-note">
<strong>Operator path:</strong> Complete the content-seeding steps while public access is still enabled. After you disable public network access, perform data-plane validation from a host that already lives inside one of the spoke VNets.
</div>

---

## Why Key Vault Needs Both DR and Network Planning

Azure Key Vault is often the dependency behind your other resilient services: web apps need secrets, databases rely on keys, and TLS certificates frequently live in the vault. The vault itself is still a **regional** resource, so your recovery plan must include both **content replication** and **network reachability**.

The original Key Vault lab focuses on multi-region content handling. This secured `B` variant adds a second operational concern: once you disable public access, the Key Vault data plane is reachable only through approved private endpoints. If you create the vaults but forget the private DNS path or an in-VNet validation path, you can lock yourself out of your own recovery workflow.

This lab therefore combines three complementary ideas:

1. **Backup artifacts** for secrets, keys, and certificates so you keep operator-controlled recovery blobs.
2. **Read-and-recreate secret sync** for the Sweden Central / Norway East lab pair used in this repo.
3. **Private endpoints + private DNS** so both vaults end in a private-only posture that lines up with the Lab 0 hub-and-spoke foundation.

---

## Architecture

```text
┌──────────────────────── Sweden Central ────────────────────────┐
│ rg-dr-swc                                  rg-spoke-swc        │
│  kv-dr-swc-<suffix>                        vnet-spoke-swc      │
│  public access: enabled during seeding     snet-private-endpoints
│  public access: disabled after Step 8      pep-kv-swc-<suffix> │
└──────────────────────────────┬─────────────────────────────────┘
                               │
                               │  shared private DNS zone
                               │  privatelink.vaultcore.azure.net
                               │  linked to both spoke VNets
                               ▼
┌───────────────────────── Norway East ──────────────────────────┐
│ rg-dr-noe                                  rg-spoke-noe        │
│  kv-dr-noe-<suffix>                        vnet-spoke-noe      │
│  seeded from primary vault                 snet-private-endpoints
│  public access: disabled after Step 8      pep-kv-noe-<suffix> │
└────────────────────────────────────────────────────────────────┘

Optional validation path: any workload or temporary VM in snet-workload,
reached through the Lab 0 Bastion hosts if you want browser-based access.
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Contributor or Owner on the lab resource groups plus permission to create role assignments, private endpoints, and private DNS links |
| **Azure CLI ≥ 2.60** | [Install the Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) |
| **PowerShell 7+** *(optional)* | Needed only if you follow the PowerShell path |
| **Logged-in session** | `az login` and `az account set --subscription <id>` |
| **Lab 0 complete** | `vnet-spoke-swc`, `vnet-spoke-noe`, and `snet-private-endpoints` already exist with private endpoint network policies disabled |
| **Validation host** | Any existing workload or temporary VM inside either spoke if you want an end-to-end private data-plane test after public access is disabled |
| **Same geography** | Both vaults must remain in the same Azure geography for backup artifacts and restore compatibility |

> **Important:** Sweden Central and Norway East are both in the *Europe* geography, so the backup-creation portion of this lab is valid as written.

---

## How These Tabs Work

This page uses the same interaction pattern as Lab 1:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behaviour used in Lab 1.

> **Private access note:** Portal and Cloud Shell remain convenient while public access is enabled. After Step 8, use a host that already lives in one of the spoke VNets for any direct data-plane validation.

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
2. Switch to the correct tenant or directory if needed.
3. Open **Subscriptions** and confirm the subscription that will host both vaults and the private networking resources.
4. Keep the portal open — you will reuse it throughout the lab.

  </div>
</div>

---

## Step 1 — Set Variables

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
UNIQUE_SUFFIX=$(printf '%05d' $((RANDOM % 100000)))

RG_PRIMARY="rg-dr-swc"
RG_SECONDARY="rg-dr-noe"

LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

KV_PRIMARY="kv-dr-swc-$UNIQUE_SUFFIX"
KV_SECONDARY="kv-dr-noe-$UNIQUE_SUFFIX"

RG_SPOKE_PRIMARY="rg-spoke-swc"
RG_SPOKE_SECONDARY="rg-spoke-noe"

SPOKE_VNET_PRIMARY="vnet-spoke-swc"
SPOKE_VNET_SECONDARY="vnet-spoke-noe"
PE_SUBNET_NAME="snet-private-endpoints"

PRIVATE_DNS_RG="$RG_PRIMARY"
PRIVATE_DNS_ZONE="privatelink.vaultcore.azure.net"

PE_PRIMARY="pep-kv-swc-$UNIQUE_SUFFIX"
PE_SECONDARY="pep-kv-noe-$UNIQUE_SUFFIX"

BACKUP_DIR="$(pwd)/kv-backups-$UNIQUE_SUFFIX"
CERT_POLICY_FILE="$(pwd)/kv-appcert-policy.json"
SECONDARY_CERT_POLICY_FILE="$(pwd)/kv-secondary-appcert-policy.json"

mkdir -p "$BACKUP_DIR"

echo "Primary vault       : $KV_PRIMARY"
echo "Secondary vault     : $KV_SECONDARY"
echo "Primary private EP  : $PE_PRIMARY"
echo "Secondary private EP: $PE_SECONDARY"
echo "Private DNS zone    : $PRIVATE_DNS_ZONE"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$UNIQUE_SUFFIX = Get-Random -Minimum 10000 -Maximum 99999

$RG_PRIMARY = "rg-dr-swc"
$RG_SECONDARY = "rg-dr-noe"

$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"

$KV_PRIMARY = "kv-dr-swc-$UNIQUE_SUFFIX"
$KV_SECONDARY = "kv-dr-noe-$UNIQUE_SUFFIX"

$RG_SPOKE_PRIMARY = "rg-spoke-swc"
$RG_SPOKE_SECONDARY = "rg-spoke-noe"

$SPOKE_VNET_PRIMARY = "vnet-spoke-swc"
$SPOKE_VNET_SECONDARY = "vnet-spoke-noe"
$PE_SUBNET_NAME = "snet-private-endpoints"

$PRIVATE_DNS_RG = $RG_PRIMARY
$PRIVATE_DNS_ZONE = "privatelink.vaultcore.azure.net"

$PE_PRIMARY = "pep-kv-swc-$UNIQUE_SUFFIX"
$PE_SECONDARY = "pep-kv-noe-$UNIQUE_SUFFIX"

$BACKUP_DIR = Join-Path (Get-Location) "kv-backups-$UNIQUE_SUFFIX"
$CERT_POLICY_FILE = Join-Path (Get-Location) "kv-appcert-policy.json"
$SECONDARY_CERT_POLICY_FILE = Join-Path (Get-Location) "kv-secondary-appcert-policy.json"

New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null

Write-Host "Primary vault       : $KV_PRIMARY"
Write-Host "Secondary vault     : $KV_SECONDARY"
Write-Host "Primary private EP  : $PE_PRIMARY"
Write-Host "Secondary private EP: $PE_SECONDARY"
Write-Host "Private DNS zone    : $PRIVATE_DNS_ZONE"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Record the values you will use before creating anything:

1. Primary region: `swedencentral`
2. Secondary region: `norwayeast`
3. Vault resource groups: `rg-dr-swc`, `rg-dr-noe`
4. Lab 0 spoke resource groups: `rg-spoke-swc`, `rg-spoke-noe`
5. Spoke VNets: `vnet-spoke-swc`, `vnet-spoke-noe`
6. Private endpoint subnet in each spoke: `snet-private-endpoints`
7. Vault names: `kv-dr-swc-<suffix>`, `kv-dr-noe-<suffix>`
8. Private endpoint names: `pep-kv-swc-<suffix>`, `pep-kv-noe-<suffix>`
9. Private DNS zone: `privatelink.vaultcore.azure.net`

  </div>
</div>

<div class="lab-note">
<strong>Naming rule:</strong> Key Vault names must be 3–24 characters, globally unique, and use only letters, numbers, and hyphens. Private endpoint names can be longer, but keeping the same suffix makes it easier to inspect the topology later.
</div>

---

## Step 2 — Verify the Lab 0 Network Assets

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network vnet show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query "{Name:name, AddressPrefixes:addressSpace.addressPrefixes}" \
  --output table

az network vnet show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query "{Name:name, AddressPrefixes:addressSpace.addressPrefixes}" \
  --output table

az network vnet subnet show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --name "$PE_SUBNET_NAME" \
  --query "{Name:name, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" \
  --output table

az network vnet subnet show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --name "$PE_SUBNET_NAME" \
  --query "{Name:name, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network vnet show `
  --resource-group $RG_SPOKE_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query "{Name:name, AddressPrefixes:addressSpace.addressPrefixes}" `
  --output table

az network vnet show `
  --resource-group $RG_SPOKE_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query "{Name:name, AddressPrefixes:addressSpace.addressPrefixes}" `
  --output table

az network vnet subnet show `
  --resource-group $RG_SPOKE_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --name $PE_SUBNET_NAME `
  --query "{Name:name, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" `
  --output table

az network vnet subnet show `
  --resource-group $RG_SPOKE_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --name $PE_SUBNET_NAME `
  --query "{Name:name, PrivateEndpointPolicies:privateEndpointNetworkPolicies}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `rg-spoke-swc` and verify `vnet-spoke-swc` exists.
2. Confirm that `snet-private-endpoints` is present in `vnet-spoke-swc`.
3. Repeat the same check in `rg-spoke-noe` for `vnet-spoke-noe`.
4. In each private-endpoint subnet, confirm **Private endpoint network policies** are disabled.
5. If any of those items are missing, return to Lab 0 before continuing.

  </div>
</div>

<div class="lab-note">
<strong>Expected Lab 0 ranges:</strong> <code>snet-private-endpoints</code> should sit inside <code>10.10.5.64/26</code> in Sweden Central and <code>10.20.5.64/26</code> in Norway East.
</div>

---

## Step 3 — Create the Regional Key Vaults

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

SIGNED_IN_USER=$(az ad signed-in-user show --query id --output tsv)

az keyvault create \
  --name "$KV_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku standard \
  --enable-rbac-authorization true \
  --output table

KV_PRIMARY_ID=$(az keyvault show --name "$KV_PRIMARY" --query id --output tsv)

az role assignment create \
  --role "Key Vault Administrator" \
  --assignee "$SIGNED_IN_USER" \
  --scope "$KV_PRIMARY_ID" \
  --output table

az keyvault create \
  --name "$KV_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --sku standard \
  --enable-rbac-authorization true \
  --output table

KV_SECONDARY_ID=$(az keyvault show --name "$KV_SECONDARY" --query id --output tsv)

az role assignment create \
  --role "Key Vault Administrator" \
  --assignee "$SIGNED_IN_USER" \
  --scope "$KV_SECONDARY_ID" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $LOCATION_PRIMARY --output table
az group create --name $RG_SECONDARY --location $LOCATION_SECONDARY --output table

$SIGNED_IN_USER = az ad signed-in-user show --query id --output tsv

az keyvault create `
  --name $KV_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $LOCATION_PRIMARY `
  --sku standard `
  --enable-rbac-authorization true `
  --output table

$KV_PRIMARY_ID = az keyvault show --name $KV_PRIMARY --query id --output tsv

az role assignment create `
  --role "Key Vault Administrator" `
  --assignee $SIGNED_IN_USER `
  --scope $KV_PRIMARY_ID `
  --output table

az keyvault create `
  --name $KV_SECONDARY `
  --resource-group $RG_SECONDARY `
  --location $LOCATION_SECONDARY `
  --sku standard `
  --enable-rbac-authorization true `
  --output table

$KV_SECONDARY_ID = az keyvault show --name $KV_SECONDARY --query id --output tsv

az role assignment create `
  --role "Key Vault Administrator" `
  --assignee $SIGNED_IN_USER `
  --scope $KV_SECONDARY_ID `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create `rg-dr-swc` in **Sweden Central** and `rg-dr-noe` in **Norway East** if they do not already exist.
2. Create the primary vault in `rg-dr-swc` and the secondary vault in `rg-dr-noe`.
3. On **Access configuration**, choose **Azure role-based access control** for both vaults.
4. After deployment, assign yourself **Key Vault Administrator** on each vault.
5. Leave public access enabled for now — you will lock the vaults down after the private endpoints are ready.

  </div>
</div>

<div class="lab-note">
<strong>Propagation note:</strong> RBAC assignments can take several minutes to apply. If the next step returns <code>403 Forbidden</code>, wait a moment and retry.
</div>

---

## Step 4 — Populate the Primary Vault

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault secret set \
  --vault-name "$KV_PRIMARY" \
  --name "DatabaseConnectionString" \
  --value "Server=sql-primary.database.windows.net;Database=appdb;User=appadmin;Password=P@ssw0rd!" \
  --output table

az keyvault secret set \
  --vault-name "$KV_PRIMARY" \
  --name "StorageAccountKey" \
  --value "DefaultEndpointsProtocol=https;AccountName=stdrswc;AccountKey=FAKE+KEY==" \
  --output table

az keyvault secret set \
  --vault-name "$KV_PRIMARY" \
  --name "AppInsightsKey" \
  --value "00000000-0000-0000-0000-000000000000" \
  --output table

az keyvault secret set \
  --vault-name "$KV_PRIMARY" \
  --name "ApiKey-ExternalService" \
  --value "sk-demo-external-api-key-12345" \
  --output table

az keyvault key create \
  --vault-name "$KV_PRIMARY" \
  --name "EncryptionKey" \
  --kty RSA \
  --size 2048 \
  --ops encrypt decrypt sign verify \
  --output table

az keyvault certificate create \
  --vault-name "$KV_PRIMARY" \
  --name "AppCert" \
  --policy "$(az keyvault certificate get-default-policy)" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault secret set `
  --vault-name $KV_PRIMARY `
  --name "DatabaseConnectionString" `
  --value "Server=sql-primary.database.windows.net;Database=appdb;User=appadmin;Password=P@ssw0rd!" `
  --output table

az keyvault secret set `
  --vault-name $KV_PRIMARY `
  --name "StorageAccountKey" `
  --value "DefaultEndpointsProtocol=https;AccountName=stdrswc;AccountKey=FAKE+KEY==" `
  --output table

az keyvault secret set `
  --vault-name $KV_PRIMARY `
  --name "AppInsightsKey" `
  --value "00000000-0000-0000-0000-000000000000" `
  --output table

az keyvault secret set `
  --vault-name $KV_PRIMARY `
  --name "ApiKey-ExternalService" `
  --value "sk-demo-external-api-key-12345" `
  --output table

az keyvault key create `
  --vault-name $KV_PRIMARY `
  --name "EncryptionKey" `
  --kty RSA `
  --size 2048 `
  --ops encrypt decrypt sign verify `
  --output table

az keyvault certificate get-default-policy | Set-Content -Path $CERT_POLICY_FILE -Encoding utf8NoBOM

az keyvault certificate create `
  --vault-name $KV_PRIMARY `
  --name "AppCert" `
  --policy "@$CERT_POLICY_FILE" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **primary** vault.
2. Create four demo secrets: `DatabaseConnectionString`, `StorageAccountKey`, `AppInsightsKey`, and `ApiKey-ExternalService`.
3. Create a software-protected RSA key named `EncryptionKey`.
4. Create a self-signed certificate named `AppCert`.
5. Keep the values obviously fake — the point is to recognise them during validation, not to store anything sensitive.

  </div>
</div>

<div class="lab-note">
<strong>Caution:</strong> These are demo values only. Never paste production secrets into documentation, shell history, or source control.
</div>

---

## Step 5 — Back Up the Primary Vault and Seed the Secondary Vault

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault secret backup --vault-name "$KV_PRIMARY" --name "DatabaseConnectionString" --file "$BACKUP_DIR/DatabaseConnectionString.bak"
az keyvault secret backup --vault-name "$KV_PRIMARY" --name "StorageAccountKey" --file "$BACKUP_DIR/StorageAccountKey.bak"
az keyvault secret backup --vault-name "$KV_PRIMARY" --name "AppInsightsKey" --file "$BACKUP_DIR/AppInsightsKey.bak"
az keyvault secret backup --vault-name "$KV_PRIMARY" --name "ApiKey-ExternalService" --file "$BACKUP_DIR/ApiKey-ExternalService.bak"

az keyvault key backup --vault-name "$KV_PRIMARY" --name "EncryptionKey" --file "$BACKUP_DIR/EncryptionKey.bak"
az keyvault certificate backup --vault-name "$KV_PRIMARY" --name "AppCert" --file "$BACKUP_DIR/AppCert.bak"

for SECRET_NAME in $(az keyvault secret list --vault-name "$KV_PRIMARY" --query "[].name" --output tsv); do
  SECRET_VALUE=$(az keyvault secret show \
    --vault-name "$KV_PRIMARY" \
    --name "$SECRET_NAME" \
    --query value \
    --output tsv)

  az keyvault secret set \
    --vault-name "$KV_SECONDARY" \
    --name "$SECRET_NAME" \
    --value "$SECRET_VALUE" \
    --output table
done

az keyvault key create \
  --vault-name "$KV_SECONDARY" \
  --name "EncryptionKey" \
  --kty RSA \
  --size 2048 \
  --ops encrypt decrypt sign verify \
  --output table

az keyvault certificate create \
  --vault-name "$KV_SECONDARY" \
  --name "AppCert" \
  --policy "$(az keyvault certificate get-default-policy)" \
  --output table

ls -la "$BACKUP_DIR"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault secret backup --vault-name $KV_PRIMARY --name "DatabaseConnectionString" --file (Join-Path $BACKUP_DIR "DatabaseConnectionString.bak")
az keyvault secret backup --vault-name $KV_PRIMARY --name "StorageAccountKey" --file (Join-Path $BACKUP_DIR "StorageAccountKey.bak")
az keyvault secret backup --vault-name $KV_PRIMARY --name "AppInsightsKey" --file (Join-Path $BACKUP_DIR "AppInsightsKey.bak")
az keyvault secret backup --vault-name $KV_PRIMARY --name "ApiKey-ExternalService" --file (Join-Path $BACKUP_DIR "ApiKey-ExternalService.bak")

az keyvault key backup --vault-name $KV_PRIMARY --name "EncryptionKey" --file (Join-Path $BACKUP_DIR "EncryptionKey.bak")
az keyvault certificate backup --vault-name $KV_PRIMARY --name "AppCert" --file (Join-Path $BACKUP_DIR "AppCert.bak")

foreach ($SECRET_NAME in (az keyvault secret list --vault-name $KV_PRIMARY --query "[].name" --output tsv)) {
    if (-not $SECRET_NAME) { continue }

    $SECRET_VALUE = az keyvault secret show `
      --vault-name $KV_PRIMARY `
      --name $SECRET_NAME `
      --query value `
      --output tsv

    az keyvault secret set `
      --vault-name $KV_SECONDARY `
      --name $SECRET_NAME `
      --value $SECRET_VALUE `
      --output table
}

az keyvault key create `
  --vault-name $KV_SECONDARY `
  --name "EncryptionKey" `
  --kty RSA `
  --size 2048 `
  --ops encrypt decrypt sign verify `
  --output table

az keyvault certificate get-default-policy | Set-Content -Path $SECONDARY_CERT_POLICY_FILE -Encoding utf8NoBOM

az keyvault certificate create `
  --vault-name $KV_SECONDARY `
  --name "AppCert" `
  --policy "@$SECONDARY_CERT_POLICY_FILE" `
  --output table

Get-ChildItem -Path $BACKUP_DIR -Force
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Use **Cloud Shell** or your local shell while public access is still enabled.
2. Create backup blobs for the four secrets, the key, and the certificate.
3. Seed the secondary vault by copying readable secret values from the primary vault.
4. Create a fresh `EncryptionKey` and `AppCert` in the secondary vault.
5. Keep the `.bak` files as DR artifacts even though this Sweden Central / Norway East lab pair is seeded by secret sync plus region-local key and certificate creation.

  </div>
</div>

<div class="lab-note">
<strong>Topology note:</strong> The backup blobs are still valuable operator-controlled artifacts, but this repo's Sweden Central → Norway East flow uses secret sync plus fresh regional key/certificate material for the secondary vault.
</div>

---

## Step 6 — Create the Private DNS Zone and Link Both Spokes

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-dns zone create \
  --resource-group "$PRIVATE_DNS_RG" \
  --name "$PRIVATE_DNS_ZONE" \
  --output table

SPOKE_VNET_PRIMARY_ID=$(az network vnet show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --name "$SPOKE_VNET_PRIMARY" \
  --query id \
  --output tsv)

SPOKE_VNET_SECONDARY_ID=$(az network vnet show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --name "$SPOKE_VNET_SECONDARY" \
  --query id \
  --output tsv)

az network private-dns link vnet create \
  --resource-group "$PRIVATE_DNS_RG" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "link-vnet-spoke-swc-kv" \
  --virtual-network "$SPOKE_VNET_PRIMARY_ID" \
  --registration-enabled false \
  --output table

az network private-dns link vnet create \
  --resource-group "$PRIVATE_DNS_RG" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --name "link-vnet-spoke-noe-kv" \
  --virtual-network "$SPOKE_VNET_SECONDARY_ID" \
  --registration-enabled false \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-dns zone create `
  --resource-group $PRIVATE_DNS_RG `
  --name $PRIVATE_DNS_ZONE `
  --output table

$SPOKE_VNET_PRIMARY_ID = az network vnet show `
  --resource-group $RG_SPOKE_PRIMARY `
  --name $SPOKE_VNET_PRIMARY `
  --query id `
  --output tsv

$SPOKE_VNET_SECONDARY_ID = az network vnet show `
  --resource-group $RG_SPOKE_SECONDARY `
  --name $SPOKE_VNET_SECONDARY `
  --query id `
  --output tsv

az network private-dns link vnet create `
  --resource-group $PRIVATE_DNS_RG `
  --zone-name $PRIVATE_DNS_ZONE `
  --name "link-vnet-spoke-swc-kv" `
  --virtual-network $SPOKE_VNET_PRIMARY_ID `
  --registration-enabled false `
  --output table

az network private-dns link vnet create `
  --resource-group $PRIVATE_DNS_RG `
  --zone-name $PRIVATE_DNS_ZONE `
  --name "link-vnet-spoke-noe-kv" `
  --virtual-network $SPOKE_VNET_SECONDARY_ID `
  --registration-enabled false `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a Private DNS zone named `privatelink.vaultcore.azure.net`.
2. Link that zone to `vnet-spoke-swc`.
3. Link the same zone to `vnet-spoke-noe`.
4. Leave auto-registration disabled — Key Vault private endpoints add the required A records through their DNS zone groups.
5. Keep the zone ready before creating the private endpoints so name resolution works as soon as the endpoints are approved.

  </div>
</div>

<div class="lab-note">
<strong>Why one shared zone is enough:</strong> Each vault gets its own A record inside the same <code>privatelink.vaultcore.azure.net</code> zone, and both spokes can resolve both names once the zone is linked.
</div>

---

## Step 7 — Create Private Endpoints for Both Vaults

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
KV_PRIMARY_ID=$(az keyvault show --name "$KV_PRIMARY" --query id --output tsv)
KV_SECONDARY_ID=$(az keyvault show --name "$KV_SECONDARY" --query id --output tsv)
PRIVATE_DNS_ZONE_ID=$(az network private-dns zone show \
  --resource-group "$PRIVATE_DNS_RG" \
  --name "$PRIVATE_DNS_ZONE" \
  --query id \
  --output tsv)

az network private-endpoint create \
  --name "$PE_PRIMARY" \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --vnet-name "$SPOKE_VNET_PRIMARY" \
  --subnet "$PE_SUBNET_NAME" \
  --private-connection-resource-id "$KV_PRIMARY_ID" \
  --group-id vault \
  --connection-name "${PE_PRIMARY}-conn" \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --endpoint-name "$PE_PRIMARY" \
  --name "default" \
  --private-dns-zone "$PRIVATE_DNS_ZONE_ID" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --output table

az network private-endpoint create \
  --name "$PE_SECONDARY" \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --vnet-name "$SPOKE_VNET_SECONDARY" \
  --subnet "$PE_SUBNET_NAME" \
  --private-connection-resource-id "$KV_SECONDARY_ID" \
  --group-id vault \
  --connection-name "${PE_SECONDARY}-conn" \
  --output table

az network private-endpoint dns-zone-group create \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --endpoint-name "$PE_SECONDARY" \
  --name "default" \
  --private-dns-zone "$PRIVATE_DNS_ZONE_ID" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$KV_PRIMARY_ID = az keyvault show --name $KV_PRIMARY --query id --output tsv
$KV_SECONDARY_ID = az keyvault show --name $KV_SECONDARY --query id --output tsv
$PRIVATE_DNS_ZONE_ID = az network private-dns zone show `
  --resource-group $PRIVATE_DNS_RG `
  --name $PRIVATE_DNS_ZONE `
  --query id `
  --output tsv

az network private-endpoint create `
  --name $PE_PRIMARY `
  --resource-group $RG_SPOKE_PRIMARY `
  --location $LOCATION_PRIMARY `
  --vnet-name $SPOKE_VNET_PRIMARY `
  --subnet $PE_SUBNET_NAME `
  --private-connection-resource-id $KV_PRIMARY_ID `
  --group-id vault `
  --connection-name "$PE_PRIMARY-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $RG_SPOKE_PRIMARY `
  --endpoint-name $PE_PRIMARY `
  --name "default" `
  --private-dns-zone $PRIVATE_DNS_ZONE_ID `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table

az network private-endpoint create `
  --name $PE_SECONDARY `
  --resource-group $RG_SPOKE_SECONDARY `
  --location $LOCATION_SECONDARY `
  --vnet-name $SPOKE_VNET_SECONDARY `
  --subnet $PE_SUBNET_NAME `
  --private-connection-resource-id $KV_SECONDARY_ID `
  --group-id vault `
  --connection-name "$PE_SECONDARY-conn" `
  --output table

az network private-endpoint dns-zone-group create `
  --resource-group $RG_SPOKE_SECONDARY `
  --endpoint-name $PE_SECONDARY `
  --name "default" `
  --private-dns-zone $PRIVATE_DNS_ZONE_ID `
  --zone-name $PRIVATE_DNS_ZONE `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In Sweden Central, create a private endpoint for the primary vault inside `rg-spoke-swc` / `vnet-spoke-swc` / `snet-private-endpoints`.
2. Attach it to the `privatelink.vaultcore.azure.net` Private DNS zone.
3. In Norway East, create a second private endpoint for the secondary vault inside `rg-spoke-noe` / `vnet-spoke-noe` / `snet-private-endpoints`.
4. Attach that endpoint to the same Private DNS zone.
5. Wait for both endpoint connections to show **Approved** before you continue.

  </div>
</div>

<div class="lab-note">
<strong>Approval behaviour:</strong> When the same subscription owns both the vault and the private endpoint, approval is typically automatic. If either endpoint remains pending, inspect the vault's **Private endpoint connections** blade and approve it manually.
</div>

---

## Step 8 — Disable Public Network Access on Both Vaults

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault update \
  --name "$KV_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --public-network-access Disabled \
  --output table

az keyvault update \
  --name "$KV_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --public-network-access Disabled \
  --output table

az keyvault show \
  --name "$KV_PRIMARY" \
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" \
  --output table

az keyvault show \
  --name "$KV_SECONDARY" \
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault update `
  --name $KV_PRIMARY `
  --resource-group $RG_PRIMARY `
  --public-network-access Disabled `
  --output table

az keyvault update `
  --name $KV_SECONDARY `
  --resource-group $RG_SECONDARY `
  --public-network-access Disabled `
  --output table

az keyvault show `
  --name $KV_PRIMARY `
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" `
  --output table

az keyvault show `
  --name $KV_SECONDARY `
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary vault → **Networking**.
2. Switch the data-plane setting to **Disable public access and use private access**.
3. Confirm that the private endpoint for the primary vault is still listed and approved.
4. Repeat the same change for the secondary vault.
5. Save both changes before moving to validation.

  </div>
</div>

<div class="lab-note">
<strong>Ordering matters:</strong> Do not disable public access before the private endpoints and DNS zone groups are ready. From this point onward, direct data-plane operations should come from inside the approved private path.
</div>

---

## Step 9 — Validate Private-Only Access

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
# Control-plane checks you can run from anywhere
az network private-endpoint show \
  --resource-group "$RG_SPOKE_PRIMARY" \
  --name "$PE_PRIMARY" \
  --query "{Name:name, ProvisioningState:provisioningState, CustomDns:customDnsConfigs}" \
  --output jsonc

az network private-endpoint show \
  --resource-group "$RG_SPOKE_SECONDARY" \
  --name "$PE_SECONDARY" \
  --query "{Name:name, ProvisioningState:provisioningState, CustomDns:customDnsConfigs}" \
  --output jsonc

az network private-dns record-set a list \
  --resource-group "$PRIVATE_DNS_RG" \
  --zone-name "$PRIVATE_DNS_ZONE" \
  --query "[].{Record:name, IPs:arecords[].ipv4Address}" \
  --output table

az keyvault show \
  --name "$KV_PRIMARY" \
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" \
  --output table

az keyvault show \
  --name "$KV_SECONDARY" \
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" \
  --output table

# Then run the next commands on any Linux host that already lives in vnet-spoke-swc or vnet-spoke-noe.
getent hosts "$KV_PRIMARY.vault.azure.net"
getent hosts "$KV_SECONDARY.vault.azure.net"
curl -I "https://$KV_PRIMARY.vault.azure.net/"
curl -I "https://$KV_SECONDARY.vault.azure.net/"

# Optional negative test from Cloud Shell or a client outside the spoke VNets.
az keyvault secret list --vault-name "$KV_PRIMARY" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Control-plane checks you can run from anywhere
az network private-endpoint show `
  --resource-group $RG_SPOKE_PRIMARY `
  --name $PE_PRIMARY `
  --query "{Name:name, ProvisioningState:provisioningState, CustomDns:customDnsConfigs}" `
  --output jsonc

az network private-endpoint show `
  --resource-group $RG_SPOKE_SECONDARY `
  --name $PE_SECONDARY `
  --query "{Name:name, ProvisioningState:provisioningState, CustomDns:customDnsConfigs}" `
  --output jsonc

az network private-dns record-set a list `
  --resource-group $PRIVATE_DNS_RG `
  --zone-name $PRIVATE_DNS_ZONE `
  --query "[].{Record:name, IPs:arecords[].ipv4Address}" `
  --output table

az keyvault show `
  --name $KV_PRIMARY `
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" `
  --output table

az keyvault show `
  --name $KV_SECONDARY `
  --query "{Vault:name, PublicNetworkAccess:properties.publicNetworkAccess}" `
  --output table

# Then run the next commands on any host that already lives in vnet-spoke-swc or vnet-spoke-noe.
nslookup "$KV_PRIMARY.vault.azure.net"
nslookup "$KV_SECONDARY.vault.azure.net"
(Invoke-WebRequest -Uri "https://$KV_PRIMARY.vault.azure.net/" -Method Head -SkipHttpErrorCheck).StatusCode
(Invoke-WebRequest -Uri "https://$KV_SECONDARY.vault.azure.net/" -Method Head -SkipHttpErrorCheck).StatusCode

# Optional negative test from a client outside the spoke VNets.
az keyvault secret list --vault-name $KV_PRIMARY --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm each vault now shows **Public network access = Disabled**.
2. Open the Private DNS zone and verify there is an A record for each vault name.
3. From any workload or temporary VM that already lives in `vnet-spoke-swc` or `vnet-spoke-noe`, run DNS and HTTPS checks against `https://<vault-name>.vault.azure.net/`.
4. A successful private-path probe often returns **401 Unauthorized** until you send a token — that is still a good result because it proves the vault is reachable over the private endpoint.
5. From Cloud Shell or another client outside the spokes, expect secret-list or secret-show calls to fail once public access is disabled.
6. If you do not have a spoke-hosted host yet, create a temporary VM in `snet-workload` and use the Lab 0 Bastion hosts to reach it.

  </div>
</div>

<div class="lab-note">
<strong>Success criteria:</strong> The private DNS zone contains both vault names, each private endpoint is approved, each vault reports <code>Public network access = Disabled</code>, and an in-spoke host resolves the vault FQDNs to IPs from the private-endpoint subnets instead of the public endpoint.
</div>

---

## Step 10 — Cleanup

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network private-endpoint delete --name "$PE_PRIMARY" --resource-group "$RG_SPOKE_PRIMARY"
az network private-endpoint delete --name "$PE_SECONDARY" --resource-group "$RG_SPOKE_SECONDARY"

az network private-dns zone delete \
  --name "$PRIVATE_DNS_ZONE" \
  --resource-group "$PRIVATE_DNS_RG" \
  --yes

az keyvault delete --name "$KV_PRIMARY" --resource-group "$RG_PRIMARY"
az keyvault delete --name "$KV_SECONDARY" --resource-group "$RG_SECONDARY"

az keyvault purge --name "$KV_PRIMARY" --location "$LOCATION_PRIMARY"
az keyvault purge --name "$KV_SECONDARY" --location "$LOCATION_SECONDARY"

az group delete --name "$RG_PRIMARY" --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait

rm -rf "$BACKUP_DIR"
rm -f "$CERT_POLICY_FILE" "$SECONDARY_CERT_POLICY_FILE" ./sync-secrets.sh ./Sync-KeyVaultSecrets.ps1
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network private-endpoint delete --name $PE_PRIMARY --resource-group $RG_SPOKE_PRIMARY
az network private-endpoint delete --name $PE_SECONDARY --resource-group $RG_SPOKE_SECONDARY

az network private-dns zone delete `
  --name $PRIVATE_DNS_ZONE `
  --resource-group $PRIVATE_DNS_RG `
  --yes

az keyvault delete --name $KV_PRIMARY --resource-group $RG_PRIMARY
az keyvault delete --name $KV_SECONDARY --resource-group $RG_SECONDARY

az keyvault purge --name $KV_PRIMARY --location $LOCATION_PRIMARY
az keyvault purge --name $KV_SECONDARY --location $LOCATION_SECONDARY

az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

Remove-Item -Path $BACKUP_DIR -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $CERT_POLICY_FILE, $SECONDARY_CERT_POLICY_FILE, ./sync-secrets.sh, ./Sync-KeyVaultSecrets.ps1 -Force -ErrorAction SilentlyContinue
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete the two private endpoints from `rg-spoke-swc` and `rg-spoke-noe`.
2. Delete the `privatelink.vaultcore.azure.net` Private DNS zone if you do not plan to reuse it immediately.
3. Delete and optionally purge both vaults so the names are released.
4. Delete `rg-dr-swc` and `rg-dr-noe`.
5. Keep the Lab 0 hub-and-spoke foundation if you plan to continue into other secure `B` variants.

  </div>
</div>

<div class="lab-note">
<strong>Scope reminder:</strong> This cleanup removes the Key Vault lab resources only. It does <em>not</em> delete the Lab 0 hubs, spokes, Bastions, or firewalls.
</div>

---

## Discussion & Next Steps

### Backup / Restore Restrictions Still Apply

| Restriction | Detail |
|---|---|
| **Same subscription** | A backup blob cannot be restored to a vault in another subscription. |
| **Same Azure geography** | Backup artifacts stay within one geography. |
| **Soft-delete conflicts** | Existing deleted objects in the target vault can block restore until they are purged. |
| **Network reachability** | Once public access is disabled, every future data-plane sync or validation step must run through an approved private path. |

### Automation Direction for the Secure Variant

If you later automate this pattern, run the sync from a host that already has private reachability to the vaults — for example:

1. An Azure Automation Hybrid Worker in a spoke network.
2. A self-hosted GitHub Actions runner or Azure DevOps agent inside the hub-and-spoke environment.
3. A workload VM or container job with managed identity and private DNS resolution.

### Useful Links

- [Key Vault backup and restore](https://learn.microsoft.com/azure/key-vault/general/backup?tabs=azure-cli)
- [Key Vault private link](https://learn.microsoft.com/azure/key-vault/general/private-link-service)
- [Private DNS for private endpoints](https://learn.microsoft.com/azure/private-link/private-endpoint-dns)
- [Key Vault soft-delete overview](https://learn.microsoft.com/azure/key-vault/general/soft-delete-overview)
- [Managed HSM multi-region replication](https://learn.microsoft.com/azure/key-vault/managed-hsm/multi-region-replication)

---

[← Lab 8-a — Key Vault Multi-Region](lab-08a-key-vault-multi-region.md) | [Lab 8-b — Key Vault Private Networking](lab-08b-key-vault-private-networking.md)
