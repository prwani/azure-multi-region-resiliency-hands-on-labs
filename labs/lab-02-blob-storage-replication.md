---
layout: default
title: "Lab 2: Azure Blob Storage – Object Replication across Regions"
---

[← Back to Index](../index.md)

# Lab 2: Azure Blob Storage – Object Replication across Regions

> **Replicate block blobs between two non-paired Azure regions using Object Replication, so your data is available close to users — and safe from a regional outage — without being forced into Azure's default paired region.**

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

## Why Object Replication for Non-Paired Regions?

When you enable **Geo-Redundant Storage (GRS)** on an Azure Storage account, your data is automatically replicated to the [paired region](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure) — you don't get to choose which region receives the copy. For many organisations, that is fine. But if you need data in a *specific* secondary region — for latency, compliance, or sovereignty reasons — GRS won't help.

**Object Replication** solves this by asynchronously copying block blobs from a *source* container to a *destination* container in **any** other storage account, in **any** region. You control:

| You decide | GRS decides for you |
|---|---|
| Which region(s) receive the copy | Fixed to the paired region |
| Which containers and prefix filters replicate | Everything or nothing |
| When replication starts (new blobs only, or include existing blobs) | Always all data |
| Whether the destination is read-only or a full account | Read-only secondary endpoint |

In this lab you will configure Object Replication between **Sweden Central** (source) and **Norway East** (destination) — a validated non-paired combination.

> **📝 Companion repository:** This lab is based on the CLI-first demo track in [**prwani/multi-region-nonpaired-azurestorage**](https://github.com/prwani/multi-region-nonpaired-azurestorage), which provides Bash and PowerShell scripts, benchmark tooling, and an AVM/Bicep companion track for production use.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Azure Subscription                              │
│                                                                        │
│   Sweden Central                           Norway East                 │
│  ┌──────────────────────┐                ┌──────────────────────┐      │
│  │  stobjreplsrc<uid>   │  Object        │  stobjrepldst<uid>   │      │
│  │  (Source Account)    │  Replication   │  (Destination Acct)  │      │
│  │                      │ ─────────────► │                      │      │
│  │  ┌────────────────┐  │  async copy    │  ┌────────────────┐  │      │
│  │  │  source-01     │  │  (block blobs) │  │  dest-01       │  │      │
│  │  │  ┌──────────┐  │  │                │  │  ┌──────────┐  │  │      │
│  │  │  │ myblob   │──┼──┼───────────────►│──┼─►│ myblob   │  │  │      │
│  │  │  └──────────┘  │  │                │  │  └──────────┘  │  │      │
│  │  └────────────────┘  │                │  └────────────────┘  │      │
│  │                      │                │       (read-only     │      │
│  │  • Versioning   ✓    │                │        once policy   │      │
│  │  • Change Feed  ✓    │                │        is active)    │      │
│  └──────────────────────┘                │  • Versioning   ✓    │      │
│                                          └──────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
```

**Data flow:** When a blob is created or updated in `source-01`, the change feed records the event. Azure's Object Replication fabric picks up the change and asynchronously copies the blob (and its version) to `dest-01`.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Contributor or Owner role |
| **Azure CLI** | v2.60 or later (`az --version`) |
| **Shell** | Bash (Cloud Shell, WSL, macOS Terminal, Git Bash) or PowerShell 7+ |
| **Logged in** | `az login` with the correct subscription selected |
| **Data-plane RBAC** | **Storage Blob Data Contributor** on both the source and destination storage accounts |
| **Lab 1 completed** | Recommended but not required |

> **💡 Tip:** If you want to run this lab without installing anything locally, open [Azure Cloud Shell](https://shell.azure.com) — the CLI and Bash are pre-installed.

> **🔒 Security note:** This lab uses `az login` (Azure AD) for all data-plane access. No shared keys are needed. The scripts use `--auth-mode login` throughout, so ensure your identity has the **Storage Blob Data Contributor** role on both storage accounts (or their containers).

---

## Object Replication — Limits to Know

Before you start, be aware of the service limits. These rarely block a hands-on lab, but they matter for production designs.

| Limit | Value |
|---|---|
| Max destination accounts per source account | **2** |
| Max replication policies per storage account | **2** (one as source, one as destination) |
| Max rules per replication policy | **1,000** (use a [JSON policy definition file](https://learn.microsoft.com/azure/storage/blobs/object-replication-configure?tabs=azure-cli#configure-object-replication-using-a-json-file) for more than 10 rules via CLI) |
| Priority replication policies per source account | **1** |
| Supported blob types | **Block blobs only** (page blobs, append blobs, and Data Lake Storage Gen2 with hierarchical namespace are not supported) |
| Destination container access | **Read-only** once a replication policy is active |
| Minimum TLS version required | 1.2 |
| Supported account kinds | General-purpose v2, Premium block blob |

> **⚠️ Caution:** Once a replication policy targets a destination container, that container becomes **read-only**. You cannot upload blobs directly to it. Complete any seeding, review, or approval steps before enabling the policy.

---

## How These Tabs Work

This page uses a shared tab preference:

- If you click **Bash** in one step, the rest of the page switches to **Bash**
- The selection is remembered for the page in your browser
- Every code block gets a copy button in the top-right corner

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
2. If needed, switch to the correct tenant or directory from the account menu (top-right corner).
3. Open **Subscriptions** and confirm the subscription you want to use is listed and active.

</div>
</div>

---

## Step 1 — Set Variables

Define the variables you will use throughout the lab. Replace `<unique>` with a short random suffix — storage account names must be globally unique and lowercase.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
UNIQUE_SUFFIX=$(openssl rand -hex 3)          # e.g. "a1b2c3"
RESOURCE_GROUP="rg-objrepl-lab02"
LOCATION_SRC="swedencentral"                  # Primary region
LOCATION_DST="norwayeast"                     # Secondary (non-paired) region
SRC_ACCOUNT="stobjreplsrc${UNIQUE_SUFFIX}"
DST_ACCOUNT="stobjrepldst${UNIQUE_SUFFIX}"
SRC_CONTAINER="source-01"
DST_CONTAINER="dest-01"

echo "Source account:      $SRC_ACCOUNT  ($LOCATION_SRC)"
echo "Destination account: $DST_ACCOUNT  ($LOCATION_DST)"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$UNIQUE_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 6 | ForEach-Object { [char]$_ })
$RESOURCE_GROUP = "rg-objrepl-lab02"
$LOCATION_SRC = "swedencentral"               # Primary region
$LOCATION_DST = "norwayeast"                  # Secondary (non-paired) region
$SRC_ACCOUNT = "stobjreplsrc$UNIQUE_SUFFIX"
$DST_ACCOUNT = "stobjrepldst$UNIQUE_SUFFIX"
$SRC_CONTAINER = "source-01"
$DST_CONTAINER = "dest-01"

Write-Host "Source account:      $SRC_ACCOUNT  ($LOCATION_SRC)"
Write-Host "Destination account: $DST_ACCOUNT  ($LOCATION_DST)"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down or choose these values before you start. You will type them into portal forms in the steps below.

- Resource group: `rg-objrepl-lab02`
- Source region: `Sweden Central`
- Destination region: `Norway East`
- Source account name: `stobjreplsrc<suffix>` (6-character random suffix, all lowercase)
- Destination account name: `stobjrepldst<suffix>` (same suffix)
- Source container: `source-01`
- Destination container: `dest-01`

</div>
</div>

<div class="lab-note">
<strong>Tip:</strong> Write these values down or keep the terminal open — you will need them in every step.
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
  --name     "$RESOURCE_GROUP" \
  --location "$LOCATION_SRC" \
  --tags     lab=02 purpose=object-replication
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create `
  --name     $RESOURCE_GROUP `
  --location $LOCATION_SRC `
  --tags     lab=02 purpose=object-replication
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups** in the portal.
2. Click **+ Create**.
3. Fill in:
   - **Subscription**: your subscription
   - **Resource group**: `rg-objrepl-lab02`
   - **Region**: `Sweden Central`
4. Click **Review + create**, then **Create**.

</div>
</div>

---

## Step 3 — Create the Source Storage Account (Sweden Central)

We use **Standard_LRS** (locally redundant) because Object Replication provides the cross-region copy — there is no need to pay for GRS on top.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account create \
  --name              "$SRC_ACCOUNT" \
  --resource-group    "$RESOURCE_GROUP" \
  --location          "$LOCATION_SRC" \
  --sku               Standard_LRS \
  --kind              StorageV2 \
  --min-tls-version   TLS1_2 \
  --allow-blob-public-access false \
  --tags              role=source lab=02
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account create `
  --name              $SRC_ACCOUNT `
  --resource-group    $RESOURCE_GROUP `
  --location          $LOCATION_SRC `
  --sku               Standard_LRS `
  --kind              StorageV2 `
  --min-tls-version   TLS1_2 `
  --allow-blob-public-access false `
  --tags              role=source lab=02
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Storage accounts** and click **+ Create**.
2. On the **Basics** tab:
   - **Subscription** and **Resource group**: `rg-objrepl-lab02`
   - **Storage account name**: `stobjreplsrc<suffix>`
   - **Region**: `Sweden Central`
   - **Performance**: Standard
   - **Redundancy**: Locally-redundant storage (LRS)
3. On the **Advanced** tab:
   - **Minimum TLS version**: TLS 1.2
   - **Allow Blob public access**: Disabled
4. Click **Review + create**, then **Create**.

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
  --name              "$DST_ACCOUNT" \
  --resource-group    "$RESOURCE_GROUP" \
  --location          "$LOCATION_DST" \
  --sku               Standard_LRS \
  --kind              StorageV2 \
  --min-tls-version   TLS1_2 \
  --allow-blob-public-access false \
  --tags              role=destination lab=02
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account create `
  --name              $DST_ACCOUNT `
  --resource-group    $RESOURCE_GROUP `
  --location          $LOCATION_DST `
  --sku               Standard_LRS `
  --kind              StorageV2 `
  --min-tls-version   TLS1_2 `
  --allow-blob-public-access false `
  --tags              role=destination lab=02
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Storage accounts** and click **+ Create**.
2. On the **Basics** tab:
   - **Subscription** and **Resource group**: `rg-objrepl-lab02`
   - **Storage account name**: `stobjrepldst<suffix>`
   - **Region**: `Norway East`
   - **Performance**: Standard
   - **Redundancy**: Locally-redundant storage (LRS)
3. On the **Advanced** tab:
   - **Minimum TLS version**: TLS 1.2
   - **Allow Blob public access**: Disabled
4. Click **Review + create**, then **Create**.

</div>
</div>

---

## Step 5 — Enable Blob Versioning on Both Accounts

Object Replication **requires** blob versioning on both the source and destination accounts. Without it, the replication policy creation will fail.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
# Source account
az storage account blob-service-properties update \
  --account-name   "$SRC_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true

# Destination account
az storage account blob-service-properties update \
  --account-name   "$DST_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Source account
az storage account blob-service-properties update `
  --account-name   $SRC_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --enable-versioning true

# Destination account
az storage account blob-service-properties update `
  --account-name   $DST_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --enable-versioning true
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Repeat the following for **both** storage accounts:

1. Open the storage account in the portal.
2. Under **Data management**, select **Data protection**.
3. Under **Tracking**, check **Enable versioning for blobs**.
4. Click **Save**.

</div>
</div>

---

## Step 6 — Enable Change Feed on the Source Account

The change feed records all blob create, update, and delete events. Object Replication reads this feed to discover which blobs need to be copied.

> **📝 Note:** Change feed is only required on the **source** account. Enabling it on the destination is optional and has no effect on replication.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account blob-service-properties update \
  --account-name   "$SRC_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-change-feed true
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account blob-service-properties update `
  --account-name   $SRC_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --enable-change-feed true
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account (`stobjreplsrc<suffix>`) in the portal.
2. Under **Data management**, select **Data protection**.
3. Under **Tracking**, check **Enable blob change feed**.
4. Click **Save**.

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
# Source container
az storage container create \
  --name           "$SRC_CONTAINER" \
  --account-name   "$SRC_ACCOUNT" \
  --auth-mode      login

# Destination container
az storage container create \
  --name           "$DST_CONTAINER" \
  --account-name   "$DST_ACCOUNT" \
  --auth-mode      login
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Source container
az storage container create `
  --name           $SRC_CONTAINER `
  --account-name   $SRC_ACCOUNT `
  --auth-mode      login

# Destination container
az storage container create `
  --name           $DST_CONTAINER `
  --account-name   $DST_ACCOUNT `
  --auth-mode      login
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account (`stobjreplsrc<suffix>`).
2. Under **Data storage**, select **Containers**.
3. Click **+ Container**, enter `source-01`, leave access level as **Private**, and click **Create**.
4. Open the **destination** storage account (`stobjrepldst<suffix>`).
5. Under **Data storage**, select **Containers**.
6. Click **+ Container**, enter `dest-01`, leave access level as **Private**, and click **Create**.

</div>
</div>

---

## Step 8 — Create the Object Replication Policy

Object Replication policies are created in a two-step process:

1. **Create the policy on the destination account first** — this generates a policy ID.
2. **Apply the same policy (with the generated ID) on the source account** — this activates replication.

The portal handles this two-step process transparently. The CLI steps below follow the explicit sequence.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

**8a — Define the policy on the destination (generates the policy ID):**

```bash
DST_POLICY=$(az storage account or-policy create \
  --account-name          "$DST_ACCOUNT" \
  --resource-group        "$RESOURCE_GROUP" \
  --source-account        "$SRC_ACCOUNT" \
  --destination-account   "$DST_ACCOUNT" \
  --source-container      "$SRC_CONTAINER" \
  --destination-container "$DST_CONTAINER" \
  --min-creation-time     "1601-01-01T00:00:00Z" \
  --query "policyId" -o tsv)

echo "Destination-side policy ID: $DST_POLICY"
```

**8b — Retrieve the rule ID generated for the policy:**

```bash
RULE_ID=$(az storage account or-policy rule list \
  --account-name      "$DST_ACCOUNT" \
  --resource-group    "$RESOURCE_GROUP" \
  --policy-id         "$DST_POLICY" \
  --query "[0].ruleId" -o tsv)

echo "Rule ID: $RULE_ID"
```

**8c — Apply the same policy on the source to activate replication:**

```bash
az storage account or-policy create \
  --account-name          "$SRC_ACCOUNT" \
  --resource-group        "$RESOURCE_GROUP" \
  --source-account        "$SRC_ACCOUNT" \
  --destination-account   "$DST_ACCOUNT" \
  --policy-id             "$DST_POLICY" \
  --source-container      "$SRC_CONTAINER" \
  --destination-container "$DST_CONTAINER" \
  --rule-id               "$RULE_ID" \
  --min-creation-time     "1601-01-01T00:00:00Z"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

**8a — Define the policy on the destination (generates the policy ID):**

```powershell
$DST_POLICY = az storage account or-policy create `
  --account-name          $DST_ACCOUNT `
  --resource-group        $RESOURCE_GROUP `
  --source-account        $SRC_ACCOUNT `
  --destination-account   $DST_ACCOUNT `
  --source-container      $SRC_CONTAINER `
  --destination-container $DST_CONTAINER `
  --min-creation-time     "1601-01-01T00:00:00Z" `
  --query "policyId" -o tsv

Write-Host "Destination-side policy ID: $DST_POLICY"
```

**8b — Retrieve the rule ID generated for the policy:**

```powershell
$RULE_ID = az storage account or-policy rule list `
  --account-name      $DST_ACCOUNT `
  --resource-group    $RESOURCE_GROUP `
  --policy-id         $DST_POLICY `
  --query "[0].ruleId" -o tsv

Write-Host "Rule ID: $RULE_ID"
```

**8c — Apply the same policy on the source to activate replication:**

```powershell
az storage account or-policy create `
  --account-name          $SRC_ACCOUNT `
  --resource-group        $RESOURCE_GROUP `
  --source-account        $SRC_ACCOUNT `
  --destination-account   $DST_ACCOUNT `
  --policy-id             $DST_POLICY `
  --source-container      $SRC_CONTAINER `
  --destination-container $DST_CONTAINER `
  --rule-id               $RULE_ID `
  --min-creation-time     "1601-01-01T00:00:00Z"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

The portal creates the destination-side and source-side policies in a single flow:

1. Open the **source** storage account (`stobjreplsrc<suffix>`) in the portal.
2. Under **Data management**, select **Object replication**.
3. Click **Set up replication rules**.
4. Under **Destination storage account**, select `stobjrepldst<suffix>`.
5. Under **Replication rules**, click **Add rule**:
   - **Source container**: `source-01`
   - **Destination container**: `dest-01`
   - **Copy blobs created before**: set to a date before your account was created (e.g., `1/1/2000`) to replicate all existing blobs.
6. Click **Save rules**.

The portal automatically creates matching policies on both accounts and links them with the same policy ID.

</div>
</div>

<div class="lab-note">
<strong>Note:</strong> <code>--min-creation-time '1601-01-01T00:00:00Z'</code> tells Object Replication to replicate <strong>all existing blobs</strong> in addition to future ones. Omit this flag if you only want blobs uploaded <em>after</em> the policy is active to be replicated.
</div>

<div class="lab-note">
<strong>⚠️ Caution:</strong> The destination container <code>dest-01</code> is now <strong>read-only</strong>. Attempting to upload directly to it will return a <code>409 Conflict</code> error.
</div>

---

## Step 9 — Upload a Test Blob

Create a small test file and upload it to the source container.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "Hello from Sweden Central — $(date -u)" > /tmp/hello.txt

az storage blob upload \
  --account-name   "$SRC_ACCOUNT" \
  --container-name "$SRC_CONTAINER" \
  --name           "hello.txt" \
  --file           /tmp/hello.txt \
  --auth-mode      login \
  --overwrite
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$HelloFile = Join-Path $env:TEMP "hello.txt"
"Hello from Sweden Central — $(Get-Date -Format 'u')" | Set-Content -Path $HelloFile

az storage blob upload `
  --account-name   $SRC_ACCOUNT `
  --container-name $SRC_CONTAINER `
  --name           "hello.txt" `
  --file           $HelloFile `
  --auth-mode      login `
  --overwrite
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account (`stobjreplsrc<suffix>`).
2. Under **Data storage**, select **Containers**, then click **source-01**.
3. Click **Upload**.
4. In the upload pane, click the folder icon and select a local file (any small text file works).
5. Click **Upload**.

</div>
</div>

---

## Step 10 — Monitor Replication Status

Object Replication is **asynchronous** — the blob won't appear in the destination instantly. Poll the replication status on the **source** blob.

**Possible status values:**

| Status | Meaning |
|---|---|
| `complete` | Blob has been successfully replicated to the destination |
| `pending` | Replication is in progress or queued |
| `failed` | Replication failed — check blob size and type |

> **💡 Tip:** For a freshly created policy, initial replication of existing blobs can take several minutes. New blobs typically replicate within seconds to a few minutes depending on size.

**Check status once:**

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage blob show \
  --account-name   "$SRC_ACCOUNT" \
  --container-name "$SRC_CONTAINER" \
  --name           "hello.txt" \
  --auth-mode      login \
  --query          "objectReplicationSourceProperties" \
  -o jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage blob show `
  --account-name   $SRC_ACCOUNT `
  --container-name $SRC_CONTAINER `
  --name           "hello.txt" `
  --auth-mode      login `
  --query          "objectReplicationSourceProperties" `
  -o jsonc
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account (`stobjreplsrc<suffix>`).
2. Under **Data storage**, select **Containers**, then click **source-01**.
3. Click on **hello.txt** to open the blob detail pane.
4. Scroll down to the **Object replication** section and review the replication status for each policy rule.

</div>
</div>

**Poll until complete:**

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "Waiting for replication to complete..."
while true; do
  STATUS=$(az storage blob show \
    --account-name   "$SRC_ACCOUNT" \
    --container-name "$SRC_CONTAINER" \
    --name           "hello.txt" \
    --auth-mode      login \
    --query          "objectReplicationSourceProperties[0].rules[0].status" \
    -o tsv 2>/dev/null)
  echo "  Status: ${STATUS:-not yet available}"
  [ "$STATUS" = "complete" ] && break
  sleep 10
done
echo "✅ Replication complete!"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "Waiting for replication to complete..."
do {
  $STATUS = az storage blob show `
    --account-name   $SRC_ACCOUNT `
    --container-name $SRC_CONTAINER `
    --name           "hello.txt" `
    --auth-mode      login `
    --query          "objectReplicationSourceProperties[0].rules[0].status" `
    -o tsv 2>$null
  Write-Host "  Status: $(if ($STATUS) { $STATUS } else { 'not yet available' })"
  if ($STATUS -eq "complete") { break }
  Start-Sleep -Seconds 10
} while ($true)
Write-Host "✅ Replication complete!"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Refresh the blob detail pane every 30 seconds until the **Object replication** status shows **Complete**. There is no auto-refresh; you need to navigate away and back to the blob to see updated status.

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
# List blobs in the destination container
az storage blob list \
  --account-name   "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --auth-mode      login \
  --query          "[].{name:name, size:properties.contentLength, lastModified:properties.lastModified}" \
  -o table

# Download the replicated blob and compare content
az storage blob download \
  --account-name   "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --name           "hello.txt" \
  --file           /tmp/hello-destination.txt \
  --auth-mode      login

echo "── Source blob content ──"
cat /tmp/hello.txt
echo "── Destination blob content ──"
cat /tmp/hello-destination.txt
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# List blobs in the destination container
az storage blob list `
  --account-name   $DST_ACCOUNT `
  --container-name $DST_CONTAINER `
  --auth-mode      login `
  --query          "[].{name:name, size:properties.contentLength, lastModified:properties.lastModified}" `
  -o table

# Download the replicated blob and compare content
$DestFile = Join-Path $env:TEMP "hello-destination.txt"
az storage blob download `
  --account-name   $DST_ACCOUNT `
  --container-name $DST_CONTAINER `
  --name           "hello.txt" `
  --file           $DestFile `
  --auth-mode      login

Write-Host "── Source blob content ──"
Get-Content $HelloFile
Write-Host "── Destination blob content ──"
Get-Content $DestFile
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **destination** storage account (`stobjrepldst<suffix>`).
2. Under **Data storage**, select **Containers**, then click **dest-01**.
3. Confirm **hello.txt** appears in the container listing.
4. Click on the blob and select **Download** to verify its contents match the file you uploaded to the source.

You should see identical content. 🎉

</div>
</div>

---

## Alternative: Using the Companion Repository Scripts

If you prefer a **one-command** path — or want a production-ready starting point — the companion repository [**prwani/multi-region-nonpaired-azurestorage**](https://github.com/prwani/multi-region-nonpaired-azurestorage) automates everything you just did manually. It provides both **Bash** and **PowerShell** scripts with full parity.

### Clone the Repository

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
git clone https://github.com/prwani/multi-region-nonpaired-azurestorage.git
cd multi-region-nonpaired-azurestorage
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
git clone https://github.com/prwani/multi-region-nonpaired-azurestorage.git
Set-Location multi-region-nonpaired-azurestorage
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Visit [**prwani/multi-region-nonpaired-azurestorage**](https://github.com/prwani/multi-region-nonpaired-azurestorage) on GitHub and either clone the repository or explore the scripts in your browser.

</div>
</div>

### Run the Full Setup

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

Core setup only (no benchmarking):

```bash
./scripts/setup-all.sh --skip-benchmark
```

Full setup with benchmarking:

```bash
./scripts/setup-all.sh
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

Core setup only (no benchmarking):

```powershell
./scripts/setup-all.ps1 -SkipBenchmark
```

Full setup with benchmarking:

```powershell
./scripts/setup-all.ps1
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

The companion repository is CLI-first. For a portal-based walkthrough, follow Steps 1–11 above. The AVM/Bicep track described below is the recommended portal-adjacent path for infrastructure deployment.

</div>
</div>

This single command runs the underlying scripts in order:

| Step | Bash | PowerShell | What it does |
|---|---|---|---|
| 1 | `01-create-storage.sh` | `01-create-storage.ps1` | Creates the resource group, source account, and destination account |
| 2 | `02-enable-prereqs.sh` | `02-enable-prereqs.ps1` | Enables change feed, versioning, and creates source containers |
| 3 *(optional)* | `bench-01-ingest-data.sh` | `bench-01-ingest-data.ps1` | Seeds data before replication for historical catchup measurement |
| 4 | `03-setup-replication.sh` | `03-setup-replication.ps1` | Creates destination containers and activates object replication |
| 5 *(optional)* | `bench-02-continue-ingestion.sh` | `bench-02-continue-ingestion.ps1` | Adds new data after replication starts for ongoing latency measurement |
| 6 *(optional)* | `bench-03-monitor-replication.sh` | `bench-03-monitor-replication.ps1` | Reads blob status and Azure Monitor metrics |

### Configuration — `config.env`

All settings are centralised in **`config.env`** at the repository root. Key defaults:

```bash
# config.env (excerpt)
SOURCE_REGION="swedencentral"        # Source storage account region
DEST_REGION="norwayeast"             # Destination region (non-paired)
RESOURCE_GROUP="rg-objrepl-demo"     # Resource group name
SOURCE_STORAGE="objreplsrc736208"    # Source account name (auto-generated if blank)
DEST_STORAGE="objrepldst736208"      # Destination account name (auto-generated if blank)
CONTAINER_COUNT="5"                  # Number of blob containers (default: 5 pairs)
SOURCE_CONTAINER_PREFIX="source"     # Container names: source-01 … source-05
DEST_CONTAINER_PREFIX="dest"         # Container names: dest-01 … dest-05
REPLICATION_MODE="default"           # "default" (async) or "priority" (SLA-backed)
```

> **📝 Note:** If `SOURCE_STORAGE` and `DEST_STORAGE` are blank, the scripts derive stable names from the resource group hash — e.g. `objreplsrc736208` and `objrepldst736208`. Precedence: CLI flags > environment variables > config.env > built-in defaults.

### AVM / Bicep Companion Track

For **production deployments**, the repository includes an Infrastructure-as-Code track under **`infra/avm/`** that uses [Azure Verified Modules (AVM)](https://aka.ms/avm) with Bicep. This gives you:

- Repeatable, auditable deployments with `main.bicep` and parameter files
- Secure defaults: `allowSharedKeyAccess=false`, blob public access disabled, HTTPS-only, TLS 1.2
- Optional monitoring, CMK (customer-managed keys), and private endpoints
- Replication activated as a separate CLI step via `infra/avm/create-object-replication.sh`

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name rg-objrepl-companion --location swedencentral

az deployment group create \
  --resource-group  rg-objrepl-companion \
  --name            avm-companion \
  --template-file   infra/avm/main.bicep \
  --parameters      infra/avm/main.bicepparam

# Activate replication after deployment completes
./infra/avm/create-object-replication.sh \
  --resource-group    rg-objrepl-companion \
  --deployment-name   avm-companion
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name rg-objrepl-companion --location swedencentral

az deployment group create `
  --resource-group  rg-objrepl-companion `
  --name            avm-companion `
  --template-file   infra/avm/main.bicep `
  --parameters      infra/avm/main.bicepparam

# Activate replication after deployment completes
./infra/avm/create-object-replication.ps1 `
  --resource-group    rg-objrepl-companion `
  --deployment-name   avm-companion
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

The AVM/Bicep track is deployed via CLI. After `az deployment group create` completes, you can view all created resources in `rg-objrepl-companion` through the portal. See [`Blog2.md`](https://github.com/prwani/multi-region-nonpaired-azurestorage/blob/main/Blog2.md) for the full AVM companion narrative and design trade-offs.

</div>
</div>

> **💡 Tip:** Use the CLI scripts for learning and experimentation; use the AVM/Bicep templates when deploying to shared or production environments. See [`Blog2.md`](https://github.com/prwani/multi-region-nonpaired-azurestorage/blob/main/Blog2.md) for the full AVM companion narrative and design trade-offs.

---

## Monitoring Replication

Azure exposes Object Replication metrics through Azure Monitor. You can query them with the CLI or view them in the portal under **Storage account → Monitoring → Metrics**.

### Key Metrics

| Signal | Why it matters |
|---|---|
| `ObjectReplicationSourceBytesReplicated` | Confirms bytes are actually flowing from source to destination |
| `ObjectReplicationSourceOperationsReplicated` | Shows replicated write activity and helps validate throughput |
| `Operations pending for replication` *(priority mode)* | Shows backlog by time bucket and helps detect SLA risk |
| `Bytes pending for replication` *(priority mode)* | Data backlog by age bucket in priority replication mode |
| Blob `replicationStatus` samples | Useful spot-check for `complete`, `pending`, or `failed` blobs |
| Storage account metrics and blob service logs | Helpful for troubleshooting access, network, or policy issues |

### Query Replicated Bytes (Last 1 Hour)

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az monitor metrics list \
  --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$SRC_ACCOUNT" \
  --metric "ObjectReplicationSourceBytesReplicated" \
  --interval PT1H \
  --query "value[0].timeseries[0].data[-1].total" \
  -o tsv
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SUBSCRIPTION_ID = az account show --query id -o tsv
$RESOURCE_ID = "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$SRC_ACCOUNT"

az monitor metrics list `
  --resource $RESOURCE_ID `
  --metric "ObjectReplicationSourceBytesReplicated" `
  --interval PT1H `
  --query "value[0].timeseries[0].data[-1].total" `
  -o tsv
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account in the portal.
2. Under **Monitoring**, select **Metrics**.
3. In the metric selector, choose **Blob** as the namespace and search for `ObjectReplicationSourceBytesReplicated`.
4. Set the time range to **Last hour** and the aggregation to **Sum**.

</div>
</div>

### Setting Up Replication Lag Alerts

For production workloads, create an alert rule that fires when pending blobs exceed a threshold:

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az monitor metrics alert create \
  --name               "high-replication-lag" \
  --resource-group     "$RESOURCE_GROUP" \
  --scopes             "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$SRC_ACCOUNT" \
  --condition          "total ObjectReplicationSourceBlobsPending > 1000" \
  --window-size        5m \
  --evaluation-frequency 1m \
  --description        "Object Replication backlog exceeds 1000 pending blobs"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SUBSCRIPTION_ID = az account show --query id -o tsv
$RESOURCE_ID = "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$SRC_ACCOUNT"

az monitor metrics alert create `
  --name               "high-replication-lag" `
  --resource-group     $RESOURCE_GROUP `
  --scopes             $RESOURCE_ID `
  --condition          "total ObjectReplicationSourceBlobsPending > 1000" `
  --window-size        5m `
  --evaluation-frequency 1m `
  --description        "Object Replication backlog exceeds 1000 pending blobs"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **source** storage account in the portal.
2. Under **Monitoring**, select **Alerts**, then click **+ Create > Alert rule**.
3. The resource scope is pre-selected as the storage account. Click **Next: Condition**.
4. Search for `ObjectReplicationSourceBlobsPending`, select it, and set the threshold to `1000` with **Total** aggregation over a **5-minute** window.
5. Click **Next: Actions** and optionally add an action group for notifications.
6. Name the alert `high-replication-lag` and click **Review + create**.

</div>
</div>

---

## Validation Checklist

Before moving on, confirm each item:

- [ ] Source storage account exists in **Sweden Central** with versioning and change feed enabled
- [ ] Destination storage account exists in **Norway East** with versioning enabled
- [ ] Object Replication policy is active on both accounts (same policy ID)
- [ ] Test blob uploaded to `source-01` appears in `dest-01`
- [ ] Replication status shows `complete` on the source blob
- [ ] Content of the replicated blob matches the original
- [ ] Destination container is read-only (optional: test by attempting an upload)

### Quick Validation Script

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "── Validation ──────────────────────────────────────────"

SRC_VER=$(az storage account blob-service-properties show \
  --account-name "$SRC_ACCOUNT" -g "$RESOURCE_GROUP" \
  --query "isVersioningEnabled" -o tsv)
echo "Source versioning:    $SRC_VER"

DST_VER=$(az storage account blob-service-properties show \
  --account-name "$DST_ACCOUNT" -g "$RESOURCE_GROUP" \
  --query "isVersioningEnabled" -o tsv)
echo "Dest versioning:      $DST_VER"

CF=$(az storage account blob-service-properties show \
  --account-name "$SRC_ACCOUNT" -g "$RESOURCE_GROUP" \
  --query "changeFeed.enabled" -o tsv)
echo "Source change feed:   $CF"

POLICY_COUNT=$(az storage account or-policy list \
  --account-name "$SRC_ACCOUNT" -g "$RESOURCE_GROUP" \
  --query "length(@)" -o tsv)
echo "Replication policies: $POLICY_COUNT"

BLOB_COUNT=$(az storage blob list \
  --account-name "$DST_ACCOUNT" --container-name "$DST_CONTAINER" \
  --auth-mode login --query "length(@)" -o tsv)
echo "Blobs in dest:        $BLOB_COUNT"

echo ""
echo "Testing read-only on destination container..."
echo "test" > /tmp/readonly-test.txt
az storage blob upload \
  --account-name "$DST_ACCOUNT" \
  --container-name "$DST_CONTAINER" \
  --name "readonly-test.txt" \
  --file /tmp/readonly-test.txt \
  --auth-mode login 2>&1 | grep -q "Conflict" \
  && echo "✅ Destination is read-only (409 Conflict)" \
  || echo "⚠️  Destination accepted the upload — check policy status"

echo "─────────────────────────────────────────────────────────"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "── Validation ──────────────────────────────────────────"

$SRC_VER = az storage account blob-service-properties show `
  --account-name $SRC_ACCOUNT -g $RESOURCE_GROUP `
  --query "isVersioningEnabled" -o tsv
Write-Host "Source versioning:    $SRC_VER"

$DST_VER = az storage account blob-service-properties show `
  --account-name $DST_ACCOUNT -g $RESOURCE_GROUP `
  --query "isVersioningEnabled" -o tsv
Write-Host "Dest versioning:      $DST_VER"

$CF = az storage account blob-service-properties show `
  --account-name $SRC_ACCOUNT -g $RESOURCE_GROUP `
  --query "changeFeed.enabled" -o tsv
Write-Host "Source change feed:   $CF"

$POLICY_COUNT = az storage account or-policy list `
  --account-name $SRC_ACCOUNT -g $RESOURCE_GROUP `
  --query "length(@)" -o tsv
Write-Host "Replication policies: $POLICY_COUNT"

$BLOB_COUNT = az storage blob list `
  --account-name $DST_ACCOUNT --container-name $DST_CONTAINER `
  --auth-mode login --query "length(@)" -o tsv
Write-Host "Blobs in dest:        $BLOB_COUNT"

Write-Host ""
Write-Host "Testing read-only on destination container..."
$TestFile = Join-Path $env:TEMP "readonly-test.txt"
"test" | Set-Content -Path $TestFile
$UploadResult = az storage blob upload `
  --account-name $DST_ACCOUNT `
  --container-name $DST_CONTAINER `
  --name "readonly-test.txt" `
  --file $TestFile `
  --auth-mode login 2>&1
if ($UploadResult -match "Conflict") {
  Write-Host "✅ Destination is read-only (409 Conflict)"
} else {
  Write-Host "⚠️  Destination accepted the upload — check policy status"
}

Write-Host "─────────────────────────────────────────────────────────"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Check each item in the portal:

1. **Versioning** — Open each storage account → Data management → Data protection → confirm **Versioning** is enabled.
2. **Change feed** — Open the source storage account → Data management → Data protection → confirm **Change feed** is enabled.
3. **Replication policy** — Open the source storage account → Data management → Object replication → confirm a policy is listed with status **Active**.
4. **Blob in destination** — Open the destination storage account → Containers → dest-01 → confirm **hello.txt** appears.
5. **Read-only destination** — Try to upload a file directly to **dest-01**. The portal should show a `409 Conflict` error or indicate the container is locked.

</div>
</div>

---

## Cleanup

When you are finished with the lab, delete all resources to avoid ongoing charges.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
echo "Resource group '$RESOURCE_GROUP' deletion initiated."

# Clean up local temp files
rm -f /tmp/hello.txt /tmp/hello-destination.txt /tmp/readonly-test.txt
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RESOURCE_GROUP --yes --no-wait
Write-Host "Resource group '$RESOURCE_GROUP' deletion initiated."

# Clean up local temp files
Remove-Item (Join-Path $env:TEMP "hello.txt") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $env:TEMP "hello-destination.txt") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $env:TEMP "readonly-test.txt") -Force -ErrorAction SilentlyContinue
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups** in the portal.
2. Click on `rg-objrepl-lab02`.
3. Click **Delete resource group**, type the resource group name to confirm, and click **Delete**.

</div>
</div>

> **📝 Note:** The `--no-wait` flag returns immediately. The resource group and all its resources will be deleted in the background within a few minutes.

### Companion Repository Cleanup

If you used the companion repository, clean up with:

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd multi-region-nonpaired-azurestorage
./scripts/cleanup.sh
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Set-Location multi-region-nonpaired-azurestorage
./scripts/cleanup.ps1
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Locate all resource groups created by the companion scripts (typically `rg-objrepl-demo` or the name set in `config.env`) and delete them from the portal via **Resource groups → Delete resource group**.

</div>
</div>

---

## Discussion: GRS vs Object Replication

### When to Use Each

| Factor | GRS / RA-GRS | Object Replication |
|---|---|---|
| **Region choice** | Paired region only (no choice) | Any region you choose |
| **Granularity** | Entire storage account | Per-container, with optional prefix filters |
| **Replication target** | Read-only secondary endpoint | Separate storage account (full or read-only) |
| **RPO** | ~15 minutes (best effort) | Varies — typically seconds to minutes |
| **Failover** | Account failover (DNS swap) | Application-level failover (change connection string) |
| **Blob types** | All (block, append, page) | Block blobs only |
| **Cost** | Higher storage SKU (GRS/RA-GRS) | LRS + bandwidth + transactions |
| **Data residency** | May conflict if paired region is outside your jurisdiction | Full control over data residency |
| **Benchmark visibility** | Limited | Better operational visibility via metrics and blob status |

### Priority Replication

For time-sensitive workloads, you can enable **priority replication** on the Object Replication policy. Priority replication provides a **99% SLA to replicate within 15 minutes** for same-continent region pairs. Key considerations:

- Only **one** priority replication policy per source account is allowed.
- Priority replication adds a **per-GB ingress surcharge**.
- **Billing continues for 30 days after disabling priority replication** — plan accordingly.
- Use the `REPLICATION_MODE="priority"` setting in `config.env` when using the companion repo.

### Cost Components

Object Replication charges include:

| Component | Applies to |
|---|---|
| **Change feed** | Source account (must be enabled for replication) |
| **Blob versioning storage** | Both source and destination accounts |
| **Source reads and destination writes** | Replicated blob traffic |
| **Cross-region data transfer** | Standard Azure egress between regions |
| **Priority replication surcharge** | Per-GB charge; billing continues for **30 days after disabling** |
| **Destination storage** | Standard LRS rates in the destination region |
| **ACR + ACI** *(optional)* | Only when using the AzDataMaker benchmark path |

> **💡 Tip:** For large-scale replication, egress bandwidth is typically the dominant cost. Use the [Azure Storage pricing calculator](https://azure.microsoft.com/pricing/details/storage/) to estimate costs based on your data volume and regions.

### Multi-Destination Replication

You can replicate from one source to **up to two** destination accounts. Each destination can be in a different region, giving you a "one-to-many" topology:

```
                ┌─► Destination A  (Norway East)
Source ─────────┤
(Sweden Central)└─► Destination B  (UK South)
```

Each destination requires its own replication policy and rule set. The per-account limit of 2 policies means you can have at most 2 destinations per source.

### Failover and Cutover Caveats

Object Replication supports regional resilience, but it does **not** deliver a turnkey application failover workflow on its own. It does not automatically:

- Switch application endpoints or DNS
- Move your application secrets or identities
- Make the destination writeable while the policy remains active
- Provide a full failback workflow after a cutover

Treat object replication as one building block inside a broader DR or cutover plan, not the entire runbook.

---

## Troubleshooting

If replication does not behave as expected, check these first:

| Symptom | What to check |
|---|---|
| Historical data not replicating | Confirm the policy was created with `--min-creation-time '1601-01-01T00:00:00Z'` |
| Uploads or blob inspection failing | Check Azure AD login state, data-plane RBAC, and storage firewall settings |
| Replication policy creation errors | Verify change feed is enabled on the source and versioning is enabled on both accounts |
| `409 Conflict` writing to destination | Expected — destination containers are read-only while the policy is active |
| Post-hardening regressions | After CMK, private endpoint, DNS, or firewall changes, re-test replication |

---

## Key Takeaways

1. **Object Replication gives you region choice** — essential for non-paired region architectures.
2. **Versioning + change feed are mandatory prerequisites** — enable them before creating a policy.
3. **Destination containers become read-only** — plan your application architecture accordingly.
4. **Replication is asynchronous** — monitor the `objectReplicationSourceProperties` for status.
5. **Use `--min-creation-time '1601-01-01T00:00:00Z'`** to replicate existing blobs, not just new ones.
6. **Use the companion repo** for automated setup, benchmarking, and production-grade AVM/Bicep templates.

---

## Further Reading

- 📖 [Object Replication overview](https://learn.microsoft.com/azure/storage/blobs/object-replication-overview)
- 📖 [Configure Object Replication](https://learn.microsoft.com/azure/storage/blobs/object-replication-configure)
- 📖 [Priority replication](https://learn.microsoft.com/azure/storage/blobs/object-replication-priority-replication)
- 📖 [Blob versioning](https://learn.microsoft.com/azure/storage/blobs/versioning-overview)
- 📖 [Change feed support](https://learn.microsoft.com/azure/storage/blobs/storage-blob-change-feed)
- 📖 [Azure Storage redundancy](https://learn.microsoft.com/azure/storage/common/storage-redundancy)
- 📖 [Azure Storage pricing](https://azure.microsoft.com/pricing/details/storage/)
- 🔧 [Companion repo: prwani/multi-region-nonpaired-azurestorage](https://github.com/prwani/multi-region-nonpaired-azurestorage)

---

## Navigation

| Previous | Home | Next |
|---|---|---|
| [Lab 1: Multi-Region Web App](lab-01-webapp-traffic-manager.md) | [All Labs](../index.md) | [Lab 3: Azure SQL Geo-Replication](lab-03-sql-geo-replication.md) |

[Next: Lab 3 — Azure SQL Database Geo-Replication →](lab-03-sql-geo-replication.md)
