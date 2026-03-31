---
layout: default
title: "Lab 9: Azure Service Bus – Geo-Disaster Recovery"
---

[← Back to Index](../index.md)

# Lab 9: Azure Service Bus – Geo-Disaster Recovery

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

## Introduction

Azure Service Bus is a fully managed enterprise message broker that supports queues, topics, and subscriptions. A Service Bus **namespace** still lives in one Azure region, so a regional outage can take your namespace offline.

**Geo-Disaster Recovery (Geo-DR)** solves the *namespace continuity* problem by replicating **metadata** from a primary namespace to a secondary namespace and exposing both through a single DNS alias. When you fail over, clients that use the alias reconnect to the secondary without changing connection strings.

### What Geo-DR Is — and What It Is Not

| Replicated (metadata) | Not replicated |
|---|---|
| Queue definitions | Messages in queues and topics |
| Topic and subscription definitions | Dead-letter contents |
| Subscription rules and filters | Deferred, scheduled, or locked message state |
| SAS policies and keys | Sequence numbers and active sessions |
| Geo-DR alias metadata | Per-message runtime state |

> **Key takeaway:** Geo-DR protects the namespace contract and endpoint stability. It does **not** copy queued messages into the secondary namespace.

---

## Architecture

```text
                        ┌──────────────────────────────┐
                        │       Geo-DR Alias           │
                        │  sb-alias-multiregion       │
                        │  .servicebus.windows.net     │
                        └──────────┬───────────────────┘
                                   │
                          DNS resolves to
                          active namespace
                                   │
              ┌────────────────────┼────────────────────┐
              │                                         │
              ▼                                         ▼
┌───────────────────────────┐          ┌───────────────────────────┐
│    Primary Namespace      │          │   Secondary Namespace     │
│    sb-dr-swc-xxxxx        │  ──────► │   sb-dr-noe-xxxxx         │
│    Sweden Central         │ metadata │   Norway East             │
│                           │   sync   │                           │
│  ┌─────────────────────┐  │          │  ┌─────────────────────┐  │
│  │  orders-queue       │  │          │  │  orders-queue       │  │
│  │  events-topic       │  │          │  │  events-topic       │  │
│  │   └─ all-events-sub │  │          │  │   └─ all-events-sub │  │
│  └─────────────────────┘  │          │  └─────────────────────┘  │
└───────────────────────────┘          └───────────────────────────┘
              ▲                                         ▲
              │                                         │
     ┌────────┴────────┐                     (after failover,
     │ Producers and   │                      alias swings here)
     │ Consumers use   │
     │ alias FQDN      │
     └─────────────────┘
```

**Normal operation:** The alias resolves to Sweden Central and metadata is continuously synchronised to Norway East.

**After failover:** The alias swings to Norway East, the former primary is detached, and any messages that existed only in the original primary remain there.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Permission to create **Premium** Service Bus namespaces |
| **Azure CLI ≥ 2.55** | `az --version` |
| **Python 3.10+** *(recommended)* | Used for the data-plane send/receive checks in the shell tabs |
| **PowerShell 7+** *(optional)* | Needed only if you follow the PowerShell path |
| **Service Bus Premium** | Both namespaces must use **Premium** tier |

> **Cost warning:** Premium Service Bus is billed per Messaging Unit per hour. Delete these resources as soon as you complete the lab.

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
<strong>Tip:</strong> Geo-DR pairs only two namespaces at a time. Keep their names, regions, and the alias recorded together so the failover story stays easy to follow.
</div>



---

## Step 1 — Set Variables

Create a consistent naming pattern before you provision the namespaces.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RANDOM_SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | head -c 5)

SB_PRIMARY="sb-dr-swc-$RANDOM_SUFFIX"
SB_SECONDARY="sb-dr-noe-$RANDOM_SUFFIX"
SB_ALIAS="sb-alias-multiregion"

RG_PRIMARY="rg-servicebus-dr-primary"
RG_SECONDARY="rg-servicebus-dr-secondary"

LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

echo "Primary namespace : $SB_PRIMARY"
echo "Secondary namespace: $SB_SECONDARY"
echo "Alias              : $SB_ALIAS"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$SB_PRIMARY = "sb-dr-swc-$RANDOM_SUFFIX"
$SB_SECONDARY = "sb-dr-noe-$RANDOM_SUFFIX"
$SB_ALIAS = "sb-alias-multiregion"

$RG_PRIMARY = "rg-servicebus-dr-primary"
$RG_SECONDARY = "rg-servicebus-dr-secondary"

$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"

Write-Host "Primary namespace : $SB_PRIMARY"
Write-Host "Secondary namespace: $SB_SECONDARY"
Write-Host "Alias              : $SB_ALIAS"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down these values before you start:

1. Primary region: `swedencentral`
2. Secondary region: `norwayeast`
3. Primary namespace: `sb-dr-swc-<suffix>`
4. Secondary namespace: `sb-dr-noe-<suffix>`
5. Geo-DR alias: `sb-alias-multiregion`

  </div>
</div>



---

## Step 2 — Create Resource Groups

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

1. Open **Resource groups**.
2. Create `rg-servicebus-dr-primary` in **Sweden Central**.
3. Create `rg-servicebus-dr-secondary` in **Norway East**.

  </div>
</div>



---

## Step 3 — Create the Primary Service Bus Namespace (Premium)

Geo-DR requires the Premium SKU, so both namespaces must be created the same way.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus namespace create \
  --name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku Premium \
  --capacity 1 \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus namespace create `
  --name $SB_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $LOCATION_PRIMARY `
  --sku Premium `
  --capacity 1 `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Service Bus namespaces** → **Create**.
2. Use resource group `rg-servicebus-dr-primary`.
3. Name the namespace `sb-dr-swc-<suffix>`.
4. Choose region **Sweden Central**.
5. Select the **Premium** pricing tier with **1 Messaging Unit**.
6. Review and create the namespace.

  </div>
</div>



<div class="lab-note">
<strong>Provisioning note:</strong> Premium namespaces take longer than Standard because they allocate dedicated capacity.
</div>



---

## Step 4 — Create the Secondary Service Bus Namespace (Premium)

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus namespace create \
  --name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --sku Premium \
  --capacity 1 \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus namespace create `
  --name $SB_SECONDARY `
  --resource-group $RG_SECONDARY `
  --location $LOCATION_SECONDARY `
  --sku Premium `
  --capacity 1 `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create the second namespace in **Norway East**.
2. Use the same **Premium** tier and **1 Messaging Unit**.
3. Keep the namespace empty — do not create entities in the secondary before pairing.

  </div>
</div>



---

## Step 5 — Create a Test Queue in the Primary Namespace

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus queue create \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --name orders-queue \
  --max-size 1024 \
  --output table

az servicebus queue list \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --query "[].name" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus queue create `
  --namespace-name $SB_PRIMARY `
  --resource-group $RG_PRIMARY `
  --name orders-queue `
  --max-size 1024 `
  --output table

az servicebus queue list `
  --namespace-name $SB_PRIMARY `
  --resource-group $RG_PRIMARY `
  --query "[].name" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **primary** Service Bus namespace.
2. Select **Queues** → **+ Queue**.
3. Name it `orders-queue`.
4. Leave the defaults unless you want to match the 1 GB max size used in the shell examples.

  </div>
</div>



---

## Step 6 — Create a Test Topic and Subscription

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus topic create \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --name events-topic \
  --max-size 1024 \
  --output table

az servicebus topic subscription create \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --topic-name events-topic \
  --name all-events-sub \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus topic create `
  --namespace-name $SB_PRIMARY `
  --resource-group $RG_PRIMARY `
  --name events-topic `
  --max-size 1024 `
  --output table

az servicebus topic subscription create `
  --namespace-name $SB_PRIMARY `
  --resource-group $RG_PRIMARY `
  --topic-name events-topic `
  --name all-events-sub `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the primary namespace, open **Topics** → **+ Topic**.
2. Create `events-topic`.
3. Open the topic, select **Subscriptions** → **+ Subscription**.
4. Create `all-events-sub`.

  </div>
</div>



---

## Step 7 — Retrieve the Secondary Namespace Resource ID

The pairing command needs the full Azure Resource Manager ID of the partner namespace.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SECONDARY_ID=$(az servicebus namespace show \
  --name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query id \
  --output tsv)

echo "$SECONDARY_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SECONDARY_ID = az servicebus namespace show `
  --name $SB_SECONDARY `
  --resource-group $RG_SECONDARY `
  --query id `
  --output tsv

Write-Host $SECONDARY_ID
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **secondary** Service Bus namespace.
2. On **Overview**, locate **Resource ID** (or use **JSON View** if your portal layout differs).
3. Copy that full resource ID — you need it for the Geo-DR pairing step.

  </div>
</div>



---

## Step 8 — Create the Geo-DR Alias (Pairing)

This is the control-plane step that ties both namespaces together and starts metadata replication.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus georecovery-alias create \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$SB_PRIMARY" \
  --alias "$SB_ALIAS" \
  --partner-namespace "$SECONDARY_ID" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus georecovery-alias create `
  --resource-group $RG_PRIMARY `
  --namespace-name $SB_PRIMARY `
  --alias $SB_ALIAS `
  --partner-namespace $SECONDARY_ID `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **primary** namespace.
2. Select **Geo recovery**.
3. Choose **Pair namespaces**.
4. Enter alias `sb-alias-multiregion`.
5. Select the Norway East namespace as the secondary partner.
6. Confirm the pairing.

  </div>
</div>



---

## Step 9 — Wait for Provisioning to Complete

Do not continue until the alias reports a healthy, successful state.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
while true; do
  STATE=$(az servicebus georecovery-alias show \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$SB_PRIMARY" \
  --alias "$SB_ALIAS" \
  --query provisioningState \
  --output tsv)

  ROLE=$(az servicebus georecovery-alias show \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$SB_PRIMARY" \
  --alias "$SB_ALIAS" \
  --query role \
  --output tsv)

  echo "State: $STATE | Role: $ROLE"
  [ "$STATE" = "Succeeded" ] && break
  sleep 10
done

az servicebus georecovery-alias show \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$SB_PRIMARY" \
  --alias "$SB_ALIAS" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
do {
    $STATE = az servicebus georecovery-alias show `
      --resource-group $RG_PRIMARY `
      --namespace-name $SB_PRIMARY `
      --alias $SB_ALIAS `
      --query provisioningState `
      --output tsv

    $ROLE = az servicebus georecovery-alias show `
      --resource-group $RG_PRIMARY `
      --namespace-name $SB_PRIMARY `
      --alias $SB_ALIAS `
      --query role `
      --output tsv

    Write-Host "State: $STATE | Role: $ROLE"
    if ($STATE -ne "Succeeded") { Start-Sleep -Seconds 10 }
} while ($STATE -ne "Succeeded")

az servicebus georecovery-alias show `
  --resource-group $RG_PRIMARY `
  --namespace-name $SB_PRIMARY `
  --alias $SB_ALIAS `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Stay on the **Geo recovery** blade of the primary namespace.
2. Refresh until the alias shows:
   - Provisioning state: **Succeeded**
   - Role: **Primary**
3. Confirm the secondary partner is listed and healthy.

  </div>
</div>



---

## Step 10 — Confirm the Alias FQDN and Alias Connection String

Applications should connect through the alias endpoint rather than the regional namespace names.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "Alias FQDN: $SB_ALIAS.servicebus.windows.net"

SB_ALIAS_CONNECTION_STRING=$(az servicebus georecovery-alias authorization-rule keys list \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$SB_PRIMARY" \
  --alias "$SB_ALIAS" \
  --name RootManageSharedAccessKey \
  --query aliasPrimaryConnectionString \
  --output tsv)

echo "$SB_ALIAS_CONNECTION_STRING"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "Alias FQDN: $SB_ALIAS.servicebus.windows.net"

$SB_ALIAS_CONNECTION_STRING = az servicebus georecovery-alias authorization-rule keys list `
  --resource-group $RG_PRIMARY `
  --namespace-name $SB_PRIMARY `
  --alias $SB_ALIAS `
  --name RootManageSharedAccessKey `
  --query aliasPrimaryConnectionString `
  --output tsv

Write-Host $SB_ALIAS_CONNECTION_STRING
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. On the **Geo recovery** blade, note the alias name `sb-alias-multiregion`.
2. Treat the effective endpoint as `sb-alias-multiregion.servicebus.windows.net`.
3. If you want the exact alias connection string, open **Cloud Shell** and run the Bash or PowerShell command from this step. Portal layouts do not always expose the alias key view directly.

  </div>
</div>



<div class="lab-note">
<strong>Application guidance:</strong> Store the alias connection string in your app configuration. That is the whole point of Geo-DR — the endpoint stays stable even when the active namespace changes.
</div>



<div class="lab-note">
<strong>If local auth is disabled:</strong> Some subscriptions enforce <code>disableLocalAuth=true</code> on Service Bus namespaces. In that case the SAS connection-string examples in Steps 12-18 fail with authentication errors. Assign yourself <code>Azure Service Bus Data Owner</code> on both namespaces and use <code>AzureCliCredential</code> or <code>DefaultAzureCredential</code> with the alias FQDN instead.
</div>



---

## Step 11 — Verify Metadata Was Replicated to the Secondary

The queue, topic, and subscription should appear in Norway East without you creating them there manually.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "=== Queues on secondary ==="
az servicebus queue list \
  --namespace-name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query "[].name" \
  --output tsv

echo
echo "=== Topics on secondary ==="
az servicebus topic list \
  --namespace-name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query "[].name" \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "=== Queues on secondary ==="
az servicebus queue list `
  --namespace-name $SB_SECONDARY `
  --resource-group $RG_SECONDARY `
  --query "[].name" `
  --output tsv

Write-Host ""
Write-Host "=== Topics on secondary ==="
az servicebus topic list `
  --namespace-name $SB_SECONDARY `
  --resource-group $RG_SECONDARY `
  --query "[].name" `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **secondary** namespace.
2. Check **Queues** — `orders-queue` should be present.
3. Check **Topics** — `events-topic` should be present.
4. Open `events-topic` → **Subscriptions** and confirm `all-events-sub` exists.

  </div>
</div>



---

## Step 12 — Send Test Messages Using the Alias Connection String

Azure CLI is great for the control plane, but it does not send queue messages directly. For the data-plane check, use a tiny SDK helper that connects with the alias connection string from Step 10.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
python -m pip install --quiet azure-servicebus

if [ -z "$SB_ALIAS_CONNECTION_STRING" ]; then
  SB_ALIAS_CONNECTION_STRING=$(az servicebus georecovery-alias authorization-rule keys list \
    --resource-group "$RG_PRIMARY" \
    --namespace-name "$SB_PRIMARY" \
    --alias "$SB_ALIAS" \
    --name RootManageSharedAccessKey \
    --query aliasPrimaryConnectionString \
    --output tsv)
fi

export SB_ALIAS_CONNECTION_STRING

cat > /tmp/servicebus_send.py <<'PY'
import json
import os
from azure.servicebus import ServiceBusClient, ServiceBusMessage

connection_string = os.environ["SB_ALIAS_CONNECTION_STRING"]
queue_name = "orders-queue"
payloads = [
    {"orderId": "ORD-001", "item": "Widget", "qty": 5},
    {"orderId": "ORD-002", "item": "Gadget", "qty": 3},
]

with ServiceBusClient.from_connection_string(connection_string) as client:
    sender = client.get_queue_sender(queue_name=queue_name)
    with sender:
        for payload in payloads:
            sender.send_messages(ServiceBusMessage(json.dumps(payload)))
            print(f"Sent {payload['orderId']}")
PY

python /tmp/servicebus_send.py
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
python -m pip install --quiet azure-servicebus

if (-not $SB_ALIAS_CONNECTION_STRING) {
    $SB_ALIAS_CONNECTION_STRING = az servicebus georecovery-alias authorization-rule keys list `
      --resource-group $RG_PRIMARY `
      --namespace-name $SB_PRIMARY `
      --alias $SB_ALIAS `
      --name RootManageSharedAccessKey `
      --query aliasPrimaryConnectionString `
      --output tsv
}

$env:SB_ALIAS_CONNECTION_STRING = $SB_ALIAS_CONNECTION_STRING

@'
import json
import os
from azure.servicebus import ServiceBusClient, ServiceBusMessage

connection_string = os.environ["SB_ALIAS_CONNECTION_STRING"]
queue_name = "orders-queue"
payloads = [
    {"orderId": "ORD-001", "item": "Widget", "qty": 5},
    {"orderId": "ORD-002", "item": "Gadget", "qty": 3},
]

with ServiceBusClient.from_connection_string(connection_string) as client:
    sender = client.get_queue_sender(queue_name=queue_name)
    with sender:
        for payload in payloads:
            sender.send_messages(ServiceBusMessage(json.dumps(payload)))
            print(f"Sent {payload['orderId']}")
'@ | Set-Content -Path (Join-Path ([System.IO.Path]::GetTempPath()) "servicebus_send.py")

python (Join-Path ([System.IO.Path]::GetTempPath()) "servicebus_send.py")
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **primary** namespace.
2. Select **Queues** → `orders-queue` → **Service Bus Explorer**.
3. Send two messages such as `ORD-001` and `ORD-002`.
4. Remember that the portal explorer is namespace-scoped. For a true alias-based client test, use the shell tabs with the alias connection string from Step 10.

  </div>
</div>



---

## Step 13 — Peek and Receive Messages

First look at the queue non-destructively, then consume a message to confirm the namespace is working end to end.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
if [ -z "$SB_ALIAS_CONNECTION_STRING" ]; then
  SB_ALIAS_CONNECTION_STRING=$(az servicebus georecovery-alias authorization-rule keys list \
    --resource-group "$RG_PRIMARY" \
    --namespace-name "$SB_PRIMARY" \
    --alias "$SB_ALIAS" \
    --name RootManageSharedAccessKey \
    --query aliasPrimaryConnectionString \
    --output tsv)
fi

export SB_ALIAS_CONNECTION_STRING

cat > /tmp/servicebus_receive.py <<'PY'
import os
from azure.servicebus import ServiceBusClient

connection_string = os.environ["SB_ALIAS_CONNECTION_STRING"]
queue_name = "orders-queue"

with ServiceBusClient.from_connection_string(connection_string) as client:
    receiver = client.get_queue_receiver(queue_name=queue_name, max_wait_time=5)
    with receiver:
        peeked = receiver.peek_messages(max_message_count=5)
        print("Peeked messages:")
        for message in peeked:
            print(str(message))

        received = receiver.receive_messages(max_message_count=1, max_wait_time=5)
        print("Received messages:")
        for message in received:
            print(str(message))
            receiver.complete_message(message)
PY

python /tmp/servicebus_receive.py
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
if (-not $SB_ALIAS_CONNECTION_STRING) {
    $SB_ALIAS_CONNECTION_STRING = az servicebus georecovery-alias authorization-rule keys list `
      --resource-group $RG_PRIMARY `
      --namespace-name $SB_PRIMARY `
      --alias $SB_ALIAS `
      --name RootManageSharedAccessKey `
      --query aliasPrimaryConnectionString `
      --output tsv
}

$env:SB_ALIAS_CONNECTION_STRING = $SB_ALIAS_CONNECTION_STRING

@'
import os
from azure.servicebus import ServiceBusClient

connection_string = os.environ["SB_ALIAS_CONNECTION_STRING"]
queue_name = "orders-queue"

with ServiceBusClient.from_connection_string(connection_string) as client:
    receiver = client.get_queue_receiver(queue_name=queue_name, max_wait_time=5)
    with receiver:
        peeked = receiver.peek_messages(max_message_count=5)
        print("Peeked messages:")
        for message in peeked:
            print(str(message))

        received = receiver.receive_messages(max_message_count=1, max_wait_time=5)
        print("Received messages:")
        for message in received:
            print(str(message))
            receiver.complete_message(message)
'@ | Set-Content -Path (Join-Path ([System.IO.Path]::GetTempPath()) "servicebus_receive.py")

python (Join-Path ([System.IO.Path]::GetTempPath()) "servicebus_receive.py")
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Service Bus Explorer**, use **Peek from start** to view the messages without removing them.
2. Then use **Receive mode** to consume one message.
3. The queue should now show one fewer active message than before.

  </div>
</div>



---

## Step 14 — Send Additional Messages Before Failover

Queue up a few more messages so you can observe that Geo-DR does not transfer them into the secondary during failover.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
if [ -z "$SB_ALIAS_CONNECTION_STRING" ]; then
  SB_ALIAS_CONNECTION_STRING=$(az servicebus georecovery-alias authorization-rule keys list \
    --resource-group "$RG_PRIMARY" \
    --namespace-name "$SB_PRIMARY" \
    --alias "$SB_ALIAS" \
    --name RootManageSharedAccessKey \
    --query aliasPrimaryConnectionString \
    --output tsv)
fi

export SB_ALIAS_CONNECTION_STRING

python - <<'PY'
import json
import os
from azure.servicebus import ServiceBusClient, ServiceBusMessage

connection_string = os.environ["SB_ALIAS_CONNECTION_STRING"]
with ServiceBusClient.from_connection_string(connection_string) as client:
    sender = client.get_queue_sender(queue_name="orders-queue")
    with sender:
        for i in range(100, 106):
            body = json.dumps({"orderId": f"ORD-{i}", "item": "Pre-failover-item", "qty": i})
            sender.send_messages(ServiceBusMessage(body))
            print(f"Sent ORD-{i}")
PY

az servicebus queue show \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --name orders-queue \
  --query countDetails.activeMessageCount \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
if (-not $SB_ALIAS_CONNECTION_STRING) {
    $SB_ALIAS_CONNECTION_STRING = az servicebus georecovery-alias authorization-rule keys list `
      --resource-group $RG_PRIMARY `
      --namespace-name $SB_PRIMARY `
      --alias $SB_ALIAS `
      --name RootManageSharedAccessKey `
      --query aliasPrimaryConnectionString `
      --output tsv
}

$env:SB_ALIAS_CONNECTION_STRING = $SB_ALIAS_CONNECTION_STRING

@'
import json
import os
from azure.servicebus import ServiceBusClient, ServiceBusMessage

connection_string = os.environ["SB_ALIAS_CONNECTION_STRING"]
with ServiceBusClient.from_connection_string(connection_string) as client:
    sender = client.get_queue_sender(queue_name="orders-queue")
    with sender:
        for i in range(100, 106):
            body = json.dumps({"orderId": f"ORD-{i}", "item": "Pre-failover-item", "qty": i})
            sender.send_messages(ServiceBusMessage(body))
            print(f"Sent ORD-{i}")
'@ | Set-Content -Path (Join-Path ([System.IO.Path]::GetTempPath()) "servicebus_send_many.py")

python (Join-Path ([System.IO.Path]::GetTempPath()) "servicebus_send_many.py")

az servicebus queue show `
  --namespace-name $SB_PRIMARY `
  --resource-group $RG_PRIMARY `
  --name orders-queue `
  --query countDetails.activeMessageCount `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Use **Service Bus Explorer** again to send several extra messages.
2. Refresh the queue overview and note the active message count.
3. Keep that number in mind — it should not appear in Norway East after failover.

  </div>
</div>



<div class="lab-note">
<strong>Expected behaviour:</strong> These messages exist only in the active primary namespace. Geo-DR does not replicate queue contents.
</div>



---

## Step 15 — Initiate Failover

The failover command is issued against the current secondary namespace. This breaks the pairing and promotes Norway East.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus georecovery-alias fail-over \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$SB_SECONDARY" \
  --alias "$SB_ALIAS" \
  --is-safe-failover false
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus georecovery-alias fail-over `
  --resource-group $RG_SECONDARY `
  --namespace-name $SB_SECONDARY `
  --alias $SB_ALIAS `
  --is-safe-failover false
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **secondary** namespace in Norway East.
2. Select **Geo recovery**.
3. Choose the alias and select **Fail over**.
4. Read the warning carefully and confirm the operation.

  </div>
</div>



<div class="lab-note">
<strong>Failover is one-way:</strong> After failover, the original primary is no longer paired. To regain DR protection later, you must create a new secondary and pair again.
</div>



---

## Step 16 — Wait for Failover to Complete

Monitor the alias until Norway East reports itself as the primary.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
while true; do
  STATE=$(az servicebus georecovery-alias show \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$SB_SECONDARY" \
  --alias "$SB_ALIAS" \
  --query provisioningState \
  --output tsv 2>/dev/null)

  echo "Failover state: $STATE"
  if [ "$STATE" = "Succeeded" ] || [ -z "$STATE" ]; then
    break
  fi
  sleep 15
done

az servicebus georecovery-alias show \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$SB_SECONDARY" \
  --alias "$SB_ALIAS" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
do {
    $STATE = az servicebus georecovery-alias show `
      --resource-group $RG_SECONDARY `
      --namespace-name $SB_SECONDARY `
      --alias $SB_ALIAS `
      --query provisioningState `
      --output tsv 2>$null

    Write-Host "Failover state: $STATE"
    if ($STATE -and $STATE -ne "Succeeded") { Start-Sleep -Seconds 15 }
} while ($STATE -and $STATE -ne "Succeeded")

az servicebus georecovery-alias show `
  --resource-group $RG_SECONDARY `
  --namespace-name $SB_SECONDARY `
  --alias $SB_ALIAS `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Refresh the **Geo recovery** blade on the secondary namespace.
2. Wait until the alias shows **Primary** or **PrimaryNotReplicating** in Norway East.
3. The partner namespace reference should be gone or marked as detached.

  </div>
</div>



---

## Step 17 — Verify the Alias Now Points to the Secondary

Confirm the control plane and DNS both reflect the new active region.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
echo "Alias FQDN: $SB_ALIAS.servicebus.windows.net"

nslookup "$SB_ALIAS.servicebus.windows.net"

az servicebus queue show \
  --namespace-name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --name orders-queue \
  --query countDetails.activeMessageCount \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "Alias FQDN: $SB_ALIAS.servicebus.windows.net"

nslookup "$SB_ALIAS.servicebus.windows.net"

az servicebus queue show `
  --namespace-name $SB_SECONDARY `
  --resource-group $RG_SECONDARY `
  --name orders-queue `
  --query countDetails.activeMessageCount `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. On the secondary namespace, confirm **Geo recovery** now shows it as the active primary (often reported as **PrimaryNotReplicating** after a forced failover).
2. Open `orders-queue` and inspect the active message count.
3. It should be **0** or much lower than the pre-failover count, which proves the queued messages were not replicated.

  </div>
</div>



---

## Step 18 — Send and Receive After Failover

Use the same alias connection string again. The client code should not change.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
if [ -z "$SB_ALIAS_CONNECTION_STRING" ]; then
  SB_ALIAS_CONNECTION_STRING=$(az servicebus georecovery-alias authorization-rule keys list \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$SB_SECONDARY" \
  --alias "$SB_ALIAS" \
  --name RootManageSharedAccessKey \
  --query aliasPrimaryConnectionString \
  --output tsv)
  export SB_ALIAS_CONNECTION_STRING
fi

python - <<'PY'
import json
import os
from azure.servicebus import ServiceBusClient, ServiceBusMessage

connection_string = os.environ["SB_ALIAS_CONNECTION_STRING"]
queue_name = "orders-queue"

with ServiceBusClient.from_connection_string(connection_string) as client:
    sender = client.get_queue_sender(queue_name=queue_name)
    with sender:
        sender.send_messages(ServiceBusMessage(json.dumps({"orderId": "ORD-POST-001", "item": "Post-failover-item", "qty": 1})))
        print("Sent ORD-POST-001")

    receiver = client.get_queue_receiver(queue_name=queue_name, max_wait_time=5)
    with receiver:
        for message in receiver.receive_messages(max_message_count=1, max_wait_time=5):
            print(str(message))
            receiver.complete_message(message)
PY
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
if (-not $SB_ALIAS_CONNECTION_STRING) {
    $SB_ALIAS_CONNECTION_STRING = az servicebus georecovery-alias authorization-rule keys list `
      --resource-group $RG_SECONDARY `
      --namespace-name $SB_SECONDARY `
      --alias $SB_ALIAS `
      --name RootManageSharedAccessKey `
      --query aliasPrimaryConnectionString `
      --output tsv
}

$env:SB_ALIAS_CONNECTION_STRING = $SB_ALIAS_CONNECTION_STRING

@'
import json
import os
from azure.servicebus import ServiceBusClient, ServiceBusMessage

connection_string = os.environ["SB_ALIAS_CONNECTION_STRING"]
queue_name = "orders-queue"

with ServiceBusClient.from_connection_string(connection_string) as client:
    sender = client.get_queue_sender(queue_name=queue_name)
    with sender:
        sender.send_messages(ServiceBusMessage(json.dumps({"orderId": "ORD-POST-001", "item": "Post-failover-item", "qty": 1})))
        print("Sent ORD-POST-001")

    receiver = client.get_queue_receiver(queue_name=queue_name, max_wait_time=5)
    with receiver:
        for message in receiver.receive_messages(max_message_count=1, max_wait_time=5):
            print(str(message))
            receiver.complete_message(message)
'@ | Set-Content -Path (Join-Path ([System.IO.Path]::GetTempPath()) "servicebus_post_failover.py")

python (Join-Path ([System.IO.Path]::GetTempPath()) "servicebus_post_failover.py")
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **promoted** namespace in Norway East.
2. Use **Service Bus Explorer** on `orders-queue` to send a new message such as `ORD-POST-001`.
3. Immediately receive it from the same queue.
4. This validates the namespace is healthy after failover; your real applications would keep using the alias connection string rather than the portal explorer.

  </div>
</div>



---

## Step 19 — Inspect the Former Primary

If the original region is still reachable, you can see the orphaned messages that never moved to the secondary.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus queue show \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --name orders-queue \
  --query countDetails.activeMessageCount \
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus queue show `
  --namespace-name $SB_PRIMARY `
  --resource-group $RG_PRIMARY `
  --name orders-queue `
  --query countDetails.activeMessageCount `
  --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Return to the original Sweden Central namespace.
2. Open `orders-queue`.
3. If the namespace is still available, you should see the pre-failover messages still there.

  </div>
</div>

---

## Validation Checklist

| # | Check | Expected Result |
|---|---|---|
| 1 | Alias created and provisioned | `provisioningState = Succeeded` |
| 2 | Queue and topic visible on secondary | `orders-queue` and `events-topic` appear in Norway East |
| 3 | Alias connection string obtained | Endpoint uses `sb-alias-multiregion.servicebus.windows.net` |
| 4 | Pre-failover messages sent | Messages appear only in the primary namespace |
| 5 | Failover completed | Norway East reports `role = Primary*` (for example `PrimaryNotReplicating`) |
| 6 | Post-failover message succeeds | Same alias connection string still works |

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
az servicebus georecovery-alias delete \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$SB_SECONDARY" \
  --alias "$SB_ALIAS" \
  --output none 2>/dev/null || true

az group delete --name "$RG_PRIMARY" --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus georecovery-alias delete `
  --resource-group $RG_SECONDARY `
  --namespace-name $SB_SECONDARY `
  --alias $SB_ALIAS `
  --output none 2>$null

az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. If the alias still appears on the promoted namespace, delete it from **Geo recovery**.
2. Delete both resource groups.
3. Wait a few minutes and confirm the namespaces are gone.

  </div>
</div>

---

## Discussion

### What Geo-DR Gives You

1. **Namespace continuity** — the alias survives a regional failure.
2. **Metadata replication** — queues, topics, subscriptions, filters, and SAS policies follow the active namespace.
3. **Transparent reconnection** — apps that use the alias can reconnect without new configuration.

### What Geo-DR Does NOT Give You

1. **Message replication** — queued messages are not copied into the secondary namespace.
2. **Dead-letter continuity** — dead-letter contents stay where they were created.
3. **Deferred, scheduled, and locked state** — runtime state is not part of the replication contract.
4. **Automatic re-pairing** — after failover, you must build a new DR pair yourself.

### After Failover: Re-establishing DR

Once failover completes, the pairing is broken. To restore regional protection, create a **new** secondary namespace and pair the active namespace with it.

### Active-Active Alternatives (Application Level)

If message durability matters more than endpoint continuity, consider an active-active application pattern with dual writes or a forwarder service. That pattern is more complex, but it is the one that addresses message loss rather than just namespace recovery.

### When to Use Which Pattern

| Scenario | Recommended Pattern |
|---|---|
| Namespace continuity; messages are ephemeral | Geo-DR |
| Zero message loss required | Application-level active-active |
| Regional write locality in both regions | Application-level active-active |
| Same connection string before and after failover | Geo-DR |

---

## Summary

In this lab you created paired Premium namespaces, replicated queue/topic metadata, validated the alias endpoint, failed over to Norway East, and confirmed that the alias still worked afterward. The critical lesson is simple: **Geo-DR protects namespace metadata and connection strings, not queued messages**.

---

[← Back to Index](../index.md) | [Next: Lab 10 — Azure Event Hubs Geo-Replication →](lab-07-event-hubs-geo-replication.md)
