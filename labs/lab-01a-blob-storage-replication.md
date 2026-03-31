---
layout: default
title: "Lab 1-a: Azure Blob Storage – Object Replication across Regions"
---

[← Back to Index](../index.md) | [Next: Lab 1-b — Blob Storage Private Endpoints →](lab-01b-blob-storage-private-endpoints.md)

# Lab 1-a: Azure Blob Storage – Object Replication across Regions

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

> **Objective:** Configure Azure Blob Storage Object Replication between Sweden Central and Norway East so new or existing block blobs copy asynchronously into a second storage account that you control.

<div class="lab-note">
<strong>Choose this path when:</strong> You want the current blob storage lab experience without the Lab 0 networking dependency. The two storage accounts keep public endpoints for operator access, while anonymous blob access stays disabled from the start.
</div>

> **📝 Companion repository:** This lighter-weight `A` path keeps the same manual Object Replication flow as the existing blob storage lab. If you later want the same data pattern secured behind Private Link, continue to Lab 1-b.

---

## Why Object Replication for Non-Paired Regions?

When you enable **Geo-Redundant Storage (GRS)** on an Azure Storage account, Azure chooses the replication target for you by using the platform-defined paired region. That is convenient, but it removes architectural choice. If you need a copy in a **specific** secondary region — for latency, residency, or operational alignment — GRS is not enough.

**Object Replication** solves that gap by asynchronously copying block blobs from a source container to a destination container in any supported storage account, in any supported region. You control both the source and the destination, and you decide whether to replicate only new blobs or seed existing blobs too.

| You decide | GRS decides for you |
|---|---|
| Which region receives the copy | Fixed to the paired region |
| Which containers participate | Whole account or nothing |
| Whether to include existing blobs | Always all data |
| Whether the destination is a normal storage account | Read-only secondary endpoint |

This lab uses **Sweden Central** as the source and **Norway East** as the destination. Lab 1-b keeps the same replication workflow and adds private endpoints and private DNS on top.

---

## Architecture

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                        Azure Subscription                              │
│                                                                        │
│   Sweden Central                           Norway East                 │
│  ┌──────────────────────┐                ┌──────────────────────┐      │
│  │  stlab1asrc<suffix>  │  Object        │  stlab1adst<suffix>  │      │
│  │  (Source Account)    │  Replication   │  (Destination Acct)  │      │
│  │                      │ ─────────────► │                      │      │
│  │  ┌────────────────┐  │  async copy    │  ┌────────────────┐  │      │
│  │  │  source-01     │  │  (block blobs) │  │  dest-01       │  │      │
│  │  │  ┌──────────┐  │  │                │  │  ┌──────────┐  │  │      │
│  │  │  │ hello.txt│──┼──┼───────────────►│──┼─►│ hello.txt│  │  │      │
│  │  │  └──────────┘  │  │                │  │  └──────────┘  │  │      │
│  │  └────────────────┘  │                │  └────────────────┘  │      │
│  │                      │                │       (read-only     │      │
│  │  • Versioning   ✓    │                │        once policy   │      │
│  │  • Change Feed  ✓    │                │        is active)    │      │
│  └──────────────────────┘                │  • Versioning   ✓    │      │
│                                          └──────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
```

**Data flow:** when a blob is created or updated in `source-01`, the source account's change feed records the event. Azure Storage then copies the blob, its versions, and selected metadata to the destination container asynchronously.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Contributor or Owner on the resource group you will create |
| **Azure CLI** | Version 2.60 or later (`az --version`) |
| **Shell** | Bash (Cloud Shell, WSL, macOS Terminal, Git Bash) or PowerShell 7+ |
| **Logged-in session** | `az login` and the correct subscription selected |
| **Data-plane RBAC** | **Storage Blob Data Contributor** on both storage accounts for the identity you use with `--auth-mode login` |
| **Lab 0** | **Not required** for this `A` path |

> **💡 Tip:** Azure Cloud Shell is a convenient option for Lab 1-a because the Azure CLI is already installed and public endpoints remain available throughout the exercise.

---

## Object Replication — Limits to Know

| Limit | Value |
|---|---|
| Max destination accounts per source account | **2** |
| Max replication policies per account | **2** (one as source, one as destination) |
| Supported blob types | **Block blobs only** |
| Required features | **Blob versioning** on both accounts, **change feed** on the source account |
| Destination container behavior | **Read-only** after the policy becomes active |
| Minimum TLS version in this lab | **TLS 1.2** |

> **⚠️ Caution:** Once the replication policy targets `dest-01`, you can no longer upload directly to that destination container. All writes must enter through the source account.

---

## How These Tabs Work

This page uses the same tab behavior as the rest of the lab series:

- Pick **Bash**, **PowerShell**, or **Portal** once and the rest of the page follows that choice.
- Only one instruction path is visible at a time.
- Your tab selection is remembered in the browser.
- Every code block keeps the same copy-button behavior used in the other labs.

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

Define the values you will reuse throughout the lab. Replace the generated suffix only if you prefer your own globally unique names.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
UNIQUE_SUFFIX=$(openssl rand -hex 3)
RESOURCE_GROUP="rg-objrepl-lab01a"
LOCATION_SRC="swedencentral"
LOCATION_DST="norwayeast"
SRC_ACCOUNT="stlab1asrc${UNIQUE_SUFFIX}"
DST_ACCOUNT="stlab1adst${UNIQUE_SUFFIX}"
SRC_CONTAINER="source-01"
DST_CONTAINER="dest-01"
TEST_BLOB="hello.txt"
LOCAL_FILE="./hello.txt"
DOWNLOADED_FILE="./hello-destination.txt"

echo "Source account:      $SRC_ACCOUNT  ($LOCATION_SRC)"
echo "Destination account: $DST_ACCOUNT  ($LOCATION_DST)"
echo "Source container:    $SRC_CONTAINER"
echo "Destination container: $DST_CONTAINER"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$UNIQUE_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 6 | ForEach-Object { [char]$_ })
$RESOURCE_GROUP = "rg-objrepl-lab01a"
$LOCATION_SRC = "swedencentral"
$LOCATION_DST = "norwayeast"
$SRC_ACCOUNT = "stlab1asrc$UNIQUE_SUFFIX"
$DST_ACCOUNT = "stlab1adst$UNIQUE_SUFFIX"
$SRC_CONTAINER = "source-01"
$DST_CONTAINER = "dest-01"
$TEST_BLOB = "hello.txt"
$LOCAL_FILE = Join-Path (Get-Location) "hello.txt"
$DOWNLOADED_FILE = Join-Path (Get-Location) "hello-destination.txt"

Write-Host "Source account:      $SRC_ACCOUNT  ($LOCATION_SRC)"
Write-Host "Destination account: $DST_ACCOUNT  ($LOCATION_DST)"
Write-Host "Source container:    $SRC_CONTAINER"
Write-Host "Destination container: $DST_CONTAINER"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down or choose these values before you start:

- Resource group: `rg-objrepl-lab01a`
- Source region: `Sweden Central`
- Destination region: `Norway East`
- Source account name: `stlab1asrc<suffix>`
- Destination account name: `stlab1adst<suffix>`
- Source container: `source-01`
- Destination container: `dest-01`
- Test blob: `hello.txt`

  </div>
</div>

<div class="lab-note">
<strong>Tip:</strong> Keep the terminal session open after this step. The later commands reuse the same variable names without redefining them.
</div>

---

## Step 2 — Create the Resource Group

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION_SRC" \
  --tags lab=01a purpose=object-replication \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create `
  --name $RESOURCE_GROUP `
  --location $LOCATION_SRC `
  --tags lab=01a purpose=object-replication `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups** in the portal.
2. Click **+ Create**.
3. Use `rg-objrepl-lab01a` as the resource group name.
4. Select **Sweden Central** as the region.
5. Click **Review + create**, then **Create**.

  </div>
</div>

---

## Step 3 — Create the Source Storage Account (Sweden Central)

Use **Standard_LRS** because Object Replication is what gives you the cross-region copy in this lab.

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
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION_SRC" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags role=source lab=01a \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account create `
  --name $SRC_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION_SRC `
  --sku Standard_LRS `
  --kind StorageV2 `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false `
  --tags role=source lab=01a `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Storage accounts** and click **+ Create**.
2. On **Basics**, set:
   - Resource group: `rg-objrepl-lab01a`
   - Storage account name: `stlab1asrc<suffix>`
   - Region: **Sweden Central**
   - Performance: **Standard**
   - Redundancy: **Locally-redundant storage (LRS)**
3. On **Advanced**, set **Minimum TLS version = TLS 1.2** and **Allow Blob public access = Disabled**.
4. Create the storage account.

  </div>
</div>

---

## Step 4 — Create the Destination Storage Account (Norway East)

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account create \
  --name "$DST_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION_DST" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags role=destination lab=01a \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account create `
  --name $DST_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION_DST `
  --sku Standard_LRS `
  --kind StorageV2 `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false `
  --tags role=destination lab=01a `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Storage accounts** and click **+ Create** again.
2. On **Basics**, set:
   - Resource group: `rg-objrepl-lab01a`
   - Storage account name: `stlab1adst<suffix>`
   - Region: **Norway East**
   - Performance: **Standard**
   - Redundancy: **Locally-redundant storage (LRS)**
3. On **Advanced**, keep **Allow Blob public access = Disabled**.
4. Create the storage account.

  </div>
</div>

---

## Step 5 — Enable Blob Versioning on Both Accounts

Object Replication will not activate until blob versioning is turned on for both the source and the destination accounts.

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
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true

az storage account blob-service-properties update \
  --account-name "$DST_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account blob-service-properties update `
  --account-name $SRC_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --enable-versioning true

az storage account blob-service-properties update `
  --account-name $DST_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --enable-versioning true
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Repeat the following for **both** storage accounts:

1. Open the storage account.
2. Under **Data management**, select **Data protection**.
3. Under **Tracking**, enable **Versioning for blobs**.
4. Click **Save**.

  </div>
</div>

---

## Step 6 — Enable Change Feed on the Source Account

The change feed records the blob create, update, and delete events that Object Replication reads from the source side.

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
  --resource-group "$RESOURCE_GROUP" \
  --enable-change-feed true
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account blob-service-properties update `
  --account-name $SRC_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --enable-change-feed true
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account (`stlab1asrc<suffix>`).
2. Under **Data management**, open **Data protection**.
3. Enable **Blob change feed**.
4. Click **Save**.

  </div>
</div>

<div class="lab-note">
<strong>Note:</strong> Change feed is required only on the source account. Enabling it on the destination is optional and does not change replication behavior.
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

1. In the **source** storage account, create a private container named `source-01`.
2. In the **destination** storage account, create a private container named `dest-01`.
3. Do not enable anonymous access on either container.

  </div>
</div>

---

## Step 8 — Create the Object Replication Policy

The Azure CLI creates Object Replication in two phases: create the policy on the destination first to get the generated IDs, then apply the same policy ID and rule ID on the source account to activate replication.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

**8a — Create the destination-side policy and capture the policy ID:**

```bash
DST_POLICY=$(az storage account or-policy create \
  --account-name "$DST_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
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
  --resource-group "$RESOURCE_GROUP" \
  --policy-id "$DST_POLICY" \
  --query "[0].ruleId" -o tsv)

echo "Rule ID: $RULE_ID"
```

**8c — Create the matching source-side policy:**

```bash
az storage account or-policy create \
  --account-name "$SRC_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
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

**8a — Create the destination-side policy and capture the policy ID:**

```powershell
$DST_POLICY = az storage account or-policy create `
  --account-name $DST_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
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
  --resource-group $RESOURCE_GROUP `
  --policy-id $DST_POLICY `
  --query "[0].ruleId" -o tsv

Write-Host "Rule ID: $RULE_ID"
```

**8c — Create the matching source-side policy:**

```powershell
az storage account or-policy create `
  --account-name $SRC_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
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

1. Open the **source** storage account in the portal.
2. Under **Data management**, select **Object replication**.
3. Click **Set up replication rules**.
4. Choose the destination storage account `stlab1adst<suffix>`.
5. Add one rule:
   - **Source container**: `source-01`
   - **Destination container**: `dest-01`
   - **Copy blobs created before**: choose a date earlier than the account creation date so existing blobs are included
6. Save the rule.

The portal creates the destination-side and source-side policy entries automatically.

  </div>
</div>

<div class="lab-note">
<strong>Why use <code>1601-01-01T00:00:00Z</code>?</strong> That value tells Azure Storage to include all existing blobs, not just blobs uploaded after the policy becomes active.
</div>

<div class="lab-note">
<strong>Read-only destination:</strong> As soon as the policy is active, `dest-01` becomes a replicated destination container. Uploading directly into it returns `409 Conflict` by design.
</div>

---

## Step 9 — Upload a Test Blob

Create a small file locally and upload it into the source container.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
printf 'Hello from Sweden Central — %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" > "$LOCAL_FILE"

az storage blob upload \
  --account-name "$SRC_ACCOUNT" \
  --container-name "$SRC_CONTAINER" \
  --name "$TEST_BLOB" \
  --file "$LOCAL_FILE" \
  --auth-mode login \
  --overwrite
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
"Hello from Sweden Central — $(Get-Date -Format 'u')" | Set-Content -Path $LOCAL_FILE

az storage blob upload `
  --account-name $SRC_ACCOUNT `
  --container-name $SRC_CONTAINER `
  --name $TEST_BLOB `
  --file $LOCAL_FILE `
  --auth-mode login `
  --overwrite
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account.
2. Browse to **Containers** > **source-01**.
3. Upload any small text file.
4. Keep the blob name simple so you can spot it easily during validation.

  </div>
</div>

---

## Step 10 — Monitor Replication Status

Object Replication is asynchronous, so the source and destination are not immediately in sync. Poll the replication status on the source blob until it becomes `complete`.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage blob show \
  --account-name "$SRC_ACCOUNT" \
  --container-name "$SRC_CONTAINER" \
  --name "$TEST_BLOB" \
  --auth-mode login \
  --query objectReplicationSourceProperties \
  -o jsonc

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

echo "✅ Replication complete"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage blob show `
  --account-name $SRC_ACCOUNT `
  --container-name $SRC_CONTAINER `
  --name $TEST_BLOB `
  --auth-mode login `
  --query objectReplicationSourceProperties `
  -o jsonc

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

Write-Host "✅ Replication complete"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the uploaded blob in the **source** container.
2. Refresh the blob detail pane until the **Object replication** section reports **Complete**.
3. Then open the destination container and confirm the blob appears there too.

  </div>
</div>

---

## Step 11 — Verify the Blob in the Destination

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage blob list \
  --account-name "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --auth-mode login \
  --query "[].{Name:name, Size:properties.contentLength, LastModified:properties.lastModified}" \
  --output table

az storage blob download \
  --account-name "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --name "$TEST_BLOB" \
  --file "$DOWNLOADED_FILE" \
  --auth-mode login

echo '── Source blob content ──'
cat "$LOCAL_FILE"
echo '── Destination blob content ──'
cat "$DOWNLOADED_FILE"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage blob list `
  --account-name $DST_ACCOUNT `
  --container-name $DST_CONTAINER `
  --auth-mode login `
  --query "[].{Name:name, Size:properties.contentLength, LastModified:properties.lastModified}" `
  --output table

az storage blob download `
  --account-name $DST_ACCOUNT `
  --container-name $DST_CONTAINER `
  --name $TEST_BLOB `
  --file $DOWNLOADED_FILE `
  --auth-mode login

Write-Host '── Source blob content ──'
Get-Content $LOCAL_FILE
Write-Host '── Destination blob content ──'
Get-Content $DOWNLOADED_FILE
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **destination** storage account.
2. Browse to **Containers** > **dest-01**.
3. Confirm the replicated blob appears.
4. Download it and compare the contents with the source file.

  </div>
</div>

---

## Validation Checklist

Before you move on, confirm all of the following:

- [ ] The source account exists in **Sweden Central** and the destination account exists in **Norway East**
- [ ] Blob versioning is enabled on **both** accounts
- [ ] Change feed is enabled on the **source** account
- [ ] The Object Replication policy is active on both accounts
- [ ] The blob uploaded to `source-01` appears in `dest-01`
- [ ] The downloaded destination blob matches the source file contents

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
rm -f "$LOCAL_FILE" "$DOWNLOADED_FILE"

az group delete \
  --name "$RESOURCE_GROUP" \
  --yes \
  --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Remove-Item -Path $LOCAL_FILE, $DOWNLOADED_FILE -Force -ErrorAction SilentlyContinue

az group delete `
  --name $RESOURCE_GROUP `
  --yes `
  --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete the resource group `rg-objrepl-lab01a` when you are done with the lab.
2. Confirm the deletion only after you finish any portal verification you need.

  </div>
</div>

<div class="lab-note">
<strong>Cleanup scope:</strong> Lab 1-a uses only the single resource group created in Step 2. Deleting that resource group removes both storage accounts and the replication policy together.
</div>

---

## Key Takeaways

1. **Object Replication gives you region choice** — ideal when the paired-region model is not what your design needs.
2. **Blob versioning and source change feed are mandatory prerequisites** for Object Replication.
3. **Destination containers become read-only** after the policy is active.
4. **Replication is asynchronous** — always check the blob status instead of assuming the copy is instant.
5. **Lab 1-b adds private endpoints** without changing the core replication mechanics you used here.

---

## Further Reading

- [Object Replication overview](https://learn.microsoft.com/azure/storage/blobs/object-replication-overview)
- [Configure Object Replication](https://learn.microsoft.com/azure/storage/blobs/object-replication-configure)
- [Blob versioning overview](https://learn.microsoft.com/azure/storage/blobs/versioning-overview)
- [Change feed overview](https://learn.microsoft.com/azure/storage/blobs/storage-blob-change-feed)
- [Azure Storage redundancy options](https://learn.microsoft.com/azure/storage/common/storage-redundancy)
- [Companion repository: prwani/multi-region-nonpaired-azurestorage](https://github.com/prwani/multi-region-nonpaired-azurestorage)

---

[← Back to Index](../index.md) | [Next: Lab 1-b — Blob Storage Private Endpoints →](lab-01b-blob-storage-private-endpoints.md)
