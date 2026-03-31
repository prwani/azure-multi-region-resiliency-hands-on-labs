---
layout: default
title: "Lab 8-a: Azure Key Vault – Multi-Region Backup & Sync"
---

[Lab 8-a — Key Vault Multi-Region](lab-08a-key-vault-multi-region.md) | [Next: Lab 8-b — Key Vault Private Networking →](lab-08b-key-vault-private-networking.md)

# Lab 8-a: Azure Key Vault – Multi-Region Backup & Sync

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

<div class="lab-note">
<strong>Variant note:</strong> This <code>A</code> path keeps the Key Vault data plane reachable over public endpoints and does not depend on Lab 0. If you want the same multi-region workflow with private endpoints in the spoke VNets, continue with <a href="lab-08b-key-vault-private-networking.md">Lab 8-b</a>.
</div>

> **Objective:** Deploy Azure Key Vaults in two regions over public endpoints, populate the primary vault with secrets, keys, and certificates, then seed a secondary vault by using backup artifacts for DR readiness and an optional sync script for secrets.

---

## Why Key Vault Needs Special DR Consideration

Azure Key Vault is often the dependency behind your other resilient services: web apps need secrets, databases rely on keys, and TLS certificates frequently live in the vault. The vault itself is still a **regional** resource, so your recovery plan must include it.

Standard Key Vaults do provide Microsoft-managed platform resilience, but they do **not** give you an operator-controlled active-active vault across arbitrary regions. If you need two writable vaults in locations such as **Sweden Central** and **Norway East**, you must plan the replication workflow yourself.

This lab shows two complementary patterns:

1. **Backup / Restore** for secrets, keys, and certificates — especially important when key material is not exportable.
2. **Read-and-recreate secret sync** for scenarios where your identity can read plaintext secret values and you want an easier recurring sync process.

---

## Architecture

```text
┌─────────────────────────┐            ┌─────────────────────────┐
│   Sweden Central        │            │   Norway East           │
│                         │   Backup   │                         │
│  ┌───────────────────┐  │  ───────►  │  ┌───────────────────┐  │
│  │ kv-dr-swc-<uid>   │  │  Restore   │  │ kv-dr-noe-<uid>   │  │
│  │ (Primary Vault)   │  │  ◄───────  │  │ (Secondary Vault) │  │
│  │ • Secrets         │  │            │  │ • Secrets         │  │
│  │ • Keys            │  │            │  │ • Keys            │  │
│  │ • Certificates    │  │            │  │ • Certificates    │  │
│  └───────────────────┘  │            │  └───────────────────┘  │
└─────────────────────────┘            └─────────────────────────┘
              │    ┌─────────────────────┐    │
              └───►│ Automation (opt.)   │◄───┘
                   │ Az Automation /     │
                   │ Logic App / Pipeline│
                   └─────────────────────┘
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Owner or Contributor plus **Key Vault Administrator** role assignment capability |
| **Azure CLI ≥ 2.60** | [Install the Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) |
| **PowerShell 7+** *(optional)* | Needed only if you follow the PowerShell path |
| **Logged-in session** | `az login` and `az account set --subscription <id>` |
| **Same geography** | Both vaults must stay in the same Azure geography for backup/restore to work |

> **Important:** Backup blobs can be restored only within the **same tenant**, **same subscription**, and **same Azure geography**. Sweden Central and Norway East are both in the *Europe* geography, so this lab works as written.

---

## How These Tabs Work

This page uses the same interaction pattern as Lab 1:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behaviour used in Lab 1.



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
3. Open **Subscriptions** and confirm the subscription that will host both regions.
4. Keep the portal open — you will reuse it throughout the lab.

  </div>
</div>



<div class="lab-note">
<strong>Tip:</strong> If you manage multiple subscriptions, set the correct subscription now so both Key Vaults and all backup blobs land in the same billing and restore scope.
</div>



---

## Step 1 — Set Variables

Use a short unique suffix so your Key Vault names remain globally unique.

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

BACKUP_DIR="$(pwd)/kv-backups"
mkdir -p "$BACKUP_DIR"

echo "Primary vault : $KV_PRIMARY"
echo "Secondary vault: $KV_SECONDARY"
echo "Backup folder : $BACKUP_DIR"
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

$BACKUP_DIR = Join-Path (Get-Location) "kv-backups"
New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null

Write-Host "Primary vault : $KV_PRIMARY"
Write-Host "Secondary vault: $KV_SECONDARY"
Write-Host "Backup folder : $BACKUP_DIR"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Record the values you will use before creating anything:

1. Primary region: `swedencentral`
2. Secondary region: `norwayeast`
3. Resource groups: `rg-dr-swc`, `rg-dr-noe`
4. Vault names: `kv-dr-swc-<suffix>`, `kv-dr-noe-<suffix>`
5. Local backup folder or Cloud Shell working folder for the `.bak` files

  </div>
</div>



<div class="lab-note">
<strong>Naming rule:</strong> Key Vault names must be 3–24 characters, globally unique, and use only letters, numbers, and hyphens.
</div>



---

## Step 2 — Create Resource Groups

Create one resource group per region so the failover design is obvious when you inspect the portal later.

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
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $LOCATION_PRIMARY --output table
az group create --name $RG_SECONDARY --location $LOCATION_SECONDARY --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups** in the Azure portal.
2. Create `rg-dr-swc` in **Sweden Central**.
3. Create `rg-dr-noe` in **Norway East**.
4. Leave both resource groups pinned or easy to find — you will switch between them often.

  </div>
</div>



---

## Step 3 — Create the Primary Key Vault

Use RBAC-based authorization so the same access model works cleanly across both regions.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault create \
  --name "$KV_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku standard \
  --enable-rbac-authorization true \
  --output table

SIGNED_IN_USER=$(az ad signed-in-user show --query id --output tsv)
KV_PRIMARY_ID=$(az keyvault show --name "$KV_PRIMARY" --query id --output tsv)

az role assignment create \
  --role "Key Vault Administrator" \
  --assignee "$SIGNED_IN_USER" \
  --scope "$KV_PRIMARY_ID" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault create `
  --name $KV_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $LOCATION_PRIMARY `
  --sku standard `
  --enable-rbac-authorization true `
  --output table

$SIGNED_IN_USER = az ad signed-in-user show --query id --output tsv
$KV_PRIMARY_ID = az keyvault show --name $KV_PRIMARY --query id --output tsv

az role assignment create `
  --role "Key Vault Administrator" `
  --assignee $SIGNED_IN_USER `
  --scope $KV_PRIMARY_ID `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Key vaults** → **Create**.
2. On **Basics**, use:
   - Subscription: your lab subscription
   - Resource group: `rg-dr-swc`
   - Name: `kv-dr-swc-<suffix>`
   - Region: **Sweden Central**
   - Pricing tier: **Standard**
3. On **Access configuration**, choose **Azure role-based access control**.
4. Create the vault.
5. Open the new vault → **Access control (IAM)** → **Add role assignment**.
6. Assign yourself **Key Vault Administrator**.

  </div>
</div>



<div class="lab-note">
<strong>Propagation note:</strong> RBAC assignments can take several minutes to apply. If you see <code>403 Forbidden</code> in the next steps, wait a moment and retry.
</div>



---

## Step 4 — Create the Secondary Key Vault

Mirror the primary vault in the recovery region.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
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

1. Create a second Key Vault in **Norway East**.
2. Use resource group `rg-dr-noe` and a unique name such as `kv-dr-noe-<suffix>`.
3. Select **Azure role-based access control** again.
4. After deployment, assign yourself **Key Vault Administrator** on the secondary vault too.

  </div>
</div>



---

## Step 5 — Add Sample Secrets to the Primary Vault

Seed the primary vault with a few representative application secrets.

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
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **primary** vault.
2. Select **Secrets** → **Generate/Import**.
3. Create these sample secrets:
   - `DatabaseConnectionString`
   - `StorageAccountKey`
   - `AppInsightsKey`
   - `ApiKey-ExternalService`
4. Use obvious demo values so you can recognise them during validation.

  </div>
</div>



<div class="lab-note">
<strong>Caution:</strong> These are demo values only. Never paste production secrets into documentation, shell history, or source control.
</div>



---

## Step 6 — Add a Sample Key

Create a software-protected RSA key to demonstrate key backup and restore.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault key create \
  --vault-name "$KV_PRIMARY" \
  --name "EncryptionKey" \
  --kty RSA \
  --size 2048 \
  --ops encrypt decrypt sign verify \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault key create `
  --vault-name $KV_PRIMARY `
  --name "EncryptionKey" `
  --kty RSA `
  --size 2048 `
  --ops encrypt decrypt sign verify `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the primary vault, open **Keys**.
2. Select **Generate/Import**.
3. Name the key `EncryptionKey`.
4. Use **RSA** with **2048** bits.
5. Save the key and verify it appears in the key list.

  </div>
</div>



---

## Step 7 — Add a Sample Certificate

Generate a self-signed certificate so you can practise certificate backup and restore too.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault certificate create \
  --vault-name "$KV_PRIMARY" \
  --name "AppCert" \
  --policy "$(az keyvault certificate get-default-policy)" \
  --output table

az keyvault certificate show \
  --vault-name "$KV_PRIMARY" \
  --name "AppCert" \
  --query "{Name:name, Enabled:attributes.enabled, Expiry:attributes.expires}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$DefaultPolicyFile = Join-Path (Get-Location) "kv-appcert-policy.json"
az keyvault certificate get-default-policy | Set-Content -Path $DefaultPolicyFile -Encoding utf8NoBOM

az keyvault certificate create `
  --vault-name $KV_PRIMARY `
  --name "AppCert" `
  --policy "@$DefaultPolicyFile" `
  --output table

az keyvault certificate show `
  --vault-name $KV_PRIMARY `
  --name "AppCert" `
  --query "{Name:name, Enabled:attributes.enabled, Expiry:attributes.expires}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary vault → **Certificates**.
2. Choose **Generate/Import**.
3. Name the certificate `AppCert`.
4. Use a **self-signed** certificate with the default policy.
5. After creation, open the certificate and confirm it is enabled.

  </div>
</div>



---

## Step 8 — Back Up Secrets, Keys, and Certificates

Backup files are encrypted blobs that Azure can restore only to a compatible vault in the same tenant, subscription, and geography.

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

Get-ChildItem -Path $BACKUP_DIR -Force
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary vault and confirm the secrets, key, and certificate exist.
2. For the actual `.bak` export, open **Cloud Shell** from the Azure portal.
3. Choose **Bash** or **PowerShell** in Cloud Shell.
4. Run the commands from the matching tab to create the encrypted backup files.

> The Azure portal can inspect objects, but Key Vault backup blobs are created through CLI/PowerShell workflows rather than a portal download button.

  </div>
</div>



<div class="lab-note">
<strong>Important:</strong> Treat the <code>.bak</code> files as sensitive operational data. They are encrypted, but they still represent recoverable vault contents.
</div>



---

## Step 9 — Seed the Secondary Vault for This Lab Topology

The Sweden Central → Norway East lab pair lets you create backup blobs, but restoring those blobs into the secondary vault returns `Malformed backup blob`. For this lab, copy readable secret values into the recovery vault and generate fresh regional key/certificate material there.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
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
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$DefaultPolicyFile = Join-Path (Get-Location) "kv-secondary-appcert-policy.json"

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

az keyvault certificate get-default-policy | Set-Content -Path $DefaultPolicyFile -Encoding utf8NoBOM

az keyvault certificate create `
  --vault-name $KV_SECONDARY `
  --name "AppCert" `
  --policy "@$DefaultPolicyFile" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

 1. Open both vaults side by side in the portal.
 2. Recreate the same secret names in the secondary vault by copying the demo values from the primary vault.
 3. Generate a new `EncryptionKey` and `AppCert` in the secondary vault.
 4. Keep the `.bak` files from Step 8 for supported same-boundary restore scenarios, but do not expect a direct restore into Norway East for this lab.

  </div>
</div>



<div class="lab-note">
<strong>Why this differs from the backup step:</strong> The backup files are still useful artifacts to keep, but this Sweden Central/Norway East lab flow is seeded by secret value sync plus region-local key/certificate recreation.
</div>



---

## Step 10 — Optional: Use a Secret Sync Script for Ongoing Updates

For secrets whose plaintext values are readable by your identity, a simple sync script is often easier to automate than repeated backup/restore cycles.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cat > ./sync-secrets.sh <<'EOF'
#!/usr/bin/env bash
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source-vault> <target-vault>"
  exit 1
fi

SOURCE_VAULT="$1"
TARGET_VAULT="$2"

echo "Syncing secrets: $SOURCE_VAULT -> $TARGET_VAULT"
while IFS= read -r SECRET_NAME; do
  echo "  Syncing: $SECRET_NAME"
  SECRET_VALUE=$(az keyvault secret show \
  --vault-name "$SOURCE_VAULT" \
  --name "$SECRET_NAME" \
  --query value \
  --output tsv)

  az keyvault secret set \
  --vault-name "$TARGET_VAULT" \
  --name "$SECRET_NAME" \
  --value "$SECRET_VALUE" \
  --output none
done < <(az keyvault secret list --vault-name "$SOURCE_VAULT" --query "[].name" --output tsv)

echo "Secret sync complete."
EOF

chmod +x ./sync-secrets.sh
./sync-secrets.sh "$KV_PRIMARY" "$KV_SECONDARY"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
@'
param(
    [Parameter(Mandatory)] [string] $SourceVault,
    [Parameter(Mandatory)] [string] $TargetVault
)

$Secrets = az keyvault secret list --vault-name $SourceVault --query "[].name" --output tsv

foreach ($Name in $Secrets) {
    Write-Host "  Syncing: $Name"
    $Value = az keyvault secret show --vault-name $SourceVault --name $Name --query value --output tsv
    az keyvault secret set --vault-name $TargetVault --name $Name --value $Value --output none | Out-Null
}

Write-Host "Secret sync complete." -ForegroundColor Green
'@ | Set-Content -Path ./Sync-KeyVaultSecrets.ps1

./Sync-KeyVaultSecrets.ps1 -SourceVault $KV_PRIMARY -TargetVault $KV_SECONDARY
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. For an operator-driven sync, open **Cloud Shell** and run either script from the matching shell tab.
2. For a scheduled sync, create an **Azure Automation** account.
3. Add a PowerShell runbook, paste the PowerShell script, and authenticate with a managed identity that has **Key Vault Administrator** on both vaults.
4. Schedule the runbook for the cadence your application needs.

  </div>
</div>



<div class="lab-note">
<strong>Scope limitation:</strong> The sync-script approach works well for secrets, but not for non-exportable key material. Keep backup/restore in your playbook for keys and certificates.
</div>



---

## Step 11 — Validate the Secondary Vault

Confirm that the recovery vault contains the same objects and that at least one secret value matches exactly.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "=== Primary Vault Secrets ==="
az keyvault secret list --vault-name "$KV_PRIMARY" --query "[].{Name:name}" --output table

echo "=== Secondary Vault Secrets ==="
az keyvault secret list --vault-name "$KV_SECONDARY" --query "[].{Name:name}" --output table

echo "=== Primary Vault Keys ==="
az keyvault key list --vault-name "$KV_PRIMARY" --query "[].{Name:name, KeyType:keyType}" --output table

echo "=== Secondary Vault Keys ==="
az keyvault key list --vault-name "$KV_SECONDARY" --query "[].{Name:name, KeyType:keyType}" --output table

echo "=== Primary Vault Certificates ==="
az keyvault certificate list --vault-name "$KV_PRIMARY" --query "[].{Name:name}" --output table

echo "=== Secondary Vault Certificates ==="
az keyvault certificate list --vault-name "$KV_SECONDARY" --query "[].{Name:name}" --output table

PRIMARY_VAL=$(az keyvault secret show --vault-name "$KV_PRIMARY" --name "DatabaseConnectionString" --query value --output tsv)
SECONDARY_VAL=$(az keyvault secret show --vault-name "$KV_SECONDARY" --name "DatabaseConnectionString" --query value --output tsv)

if [ "$PRIMARY_VAL" = "$SECONDARY_VAL" ]; then
  echo "✅ Secret values match across both vaults."
else
  echo "❌ Secret values do not match."
fi
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "=== Primary Vault Secrets ==="
az keyvault secret list --vault-name $KV_PRIMARY --query "[].{Name:name}" --output table

Write-Host "=== Secondary Vault Secrets ==="
az keyvault secret list --vault-name $KV_SECONDARY --query "[].{Name:name}" --output table

Write-Host "=== Primary Vault Keys ==="
az keyvault key list --vault-name $KV_PRIMARY --query "[].{Name:name, KeyType:keyType}" --output table

Write-Host "=== Secondary Vault Keys ==="
az keyvault key list --vault-name $KV_SECONDARY --query "[].{Name:name, KeyType:keyType}" --output table

Write-Host "=== Primary Vault Certificates ==="
az keyvault certificate list --vault-name $KV_PRIMARY --query "[].{Name:name}" --output table

Write-Host "=== Secondary Vault Certificates ==="
az keyvault certificate list --vault-name $KV_SECONDARY --query "[].{Name:name}" --output table

$PrimaryVal = az keyvault secret show --vault-name $KV_PRIMARY --name "DatabaseConnectionString" --query value --output tsv
$SecondaryVal = az keyvault secret show --vault-name $KV_SECONDARY --name "DatabaseConnectionString" --query value --output tsv

if ($PrimaryVal -eq $SecondaryVal) {
    Write-Host "✅ Secret values match across both vaults." -ForegroundColor Green
}
else {
    Write-Host "❌ Secret values do not match." -ForegroundColor Red
}
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary and secondary Key Vaults in separate browser tabs.
2. Compare **Secrets**, **Keys**, and **Certificates** in both vaults.
3. Open `DatabaseConnectionString` in each vault and compare the current version value.
4. You should see matching object names in both regions.

  </div>
</div>



---

## Step 12 — Cleanup

Delete the lab resources when you are done, especially if you do not want the Key Vault names held by soft-delete.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault delete --name "$KV_PRIMARY" --resource-group "$RG_PRIMARY"
az keyvault delete --name "$KV_SECONDARY" --resource-group "$RG_SECONDARY"

az keyvault purge --name "$KV_PRIMARY" --location "$LOCATION_PRIMARY"
az keyvault purge --name "$KV_SECONDARY" --location "$LOCATION_SECONDARY"

az group delete --name "$RG_PRIMARY" --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait

rm -rf "$BACKUP_DIR"
rm -f ./kv-appcert-policy.json ./kv-secondary-appcert-policy.json ./sync-secrets.sh ./Sync-KeyVaultSecrets.ps1
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault delete --name $KV_PRIMARY --resource-group $RG_PRIMARY
az keyvault delete --name $KV_SECONDARY --resource-group $RG_SECONDARY

az keyvault purge --name $KV_PRIMARY --location $LOCATION_PRIMARY
az keyvault purge --name $KV_SECONDARY --location $LOCATION_SECONDARY

az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait

Remove-Item -Path $BACKUP_DIR -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ./kv-appcert-policy.json, ./kv-secondary-appcert-policy.json, ./sync-secrets.sh, ./Sync-KeyVaultSecrets.ps1 -Force -ErrorAction SilentlyContinue
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Key vaults** and delete both lab vaults.
2. Open **Deleted vaults** if you want to purge them immediately and release the names.
3. Open **Resource groups** and delete `rg-dr-swc` and `rg-dr-noe`.
4. Remove any local or Cloud Shell backup files that contain the exported `.bak` blobs.

  </div>
</div>



<div class="lab-note">
<strong>Soft-delete reminder:</strong> New Key Vaults always use soft delete. If you skip the purge step, the names remain reserved until the retention window expires.
</div>

---

## Discussion & Next Steps

### Backup/Restore Restrictions — Key Points

| Restriction | Detail |
|---|---|
| **Same subscription** | A backup blob cannot be restored to a vault in another subscription. |
| **Same Azure geography** | A backup created in Europe cannot be restored to a vault in another geography. |
| **Object versioning** | Restore brings every backed-up version. Existing conflicting versions can block the restore. |
| **Soft-delete conflicts** | A previously deleted object in the target vault can prevent restore until it is purged. |

### Automation Approaches

In production, this workflow is usually automated rather than performed by hand:

1. **Azure Automation Runbook** — schedule the PowerShell sync script from Step 10.
2. **Event Grid + Azure Function** — react to secret-version creation events for near-real-time sync.
3. **Azure DevOps or GitHub Actions** — run periodic backup/restore or secret sync in a controlled pipeline.
4. **Logic Apps** — orchestrate simple vault-to-vault sync steps with portal-driven workflows.

### Managed HSM — Native Multi-Region Replication

If your use case is primarily about key material and compliance, **Azure Key Vault Managed HSM** offers multi-region replication capabilities. It is more expensive and operationally heavier than standard Key Vault, but it reduces the amount of custom replication logic you must own.

### When to Use Which Approach

| Scenario | Recommended Approach |
|---|---|
| Secrets (connection strings, API keys) | Sync script or automation pipeline |
| Software-protected keys | Backup/restore |
| HSM-backed keys | Backup/restore or Managed HSM |
| Certificates with non-exportable private keys | Backup/restore |
| Strict compliance with central key custody | Managed HSM multi-region design |

---

## Useful Links

- [Key Vault backup and restore](https://learn.microsoft.com/azure/key-vault/general/backup?tabs=azure-cli)
- [Key Vault soft-delete overview](https://learn.microsoft.com/azure/key-vault/general/soft-delete-overview)
- [Managed HSM multi-region replication](https://learn.microsoft.com/azure/key-vault/managed-hsm/multi-region-replication)
- [Key Vault Event Grid integration](https://learn.microsoft.com/azure/key-vault/general/event-grid-overview)
- [Azure geographies and paired regions](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure#azure-cross-region-replication-pairings-for-all-geographies)

---

[Lab 8-a — Key Vault Multi-Region](lab-08a-key-vault-multi-region.md) | [Next: Lab 8-b — Key Vault Private Networking →](lab-08b-key-vault-private-networking.md)
