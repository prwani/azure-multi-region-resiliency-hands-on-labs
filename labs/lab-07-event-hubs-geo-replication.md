---
layout: default
title: "Lab 10: Azure Event Hubs – Geo-Replication Failover"
---

[← Back to Index](../index.md)

# Lab 10: Azure Event Hubs – Geo-Replication Failover

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

Azure Event Hubs often sits at the very front of a streaming platform. If a regional outage removes the active namespace, telemetry ingestion and downstream analytics can stop immediately.

**Geo-Disaster Recovery (Geo-DR)** for Event Hubs pairs a primary namespace with a secondary namespace in another region and places a DNS alias in front of both. Producers and consumers use the alias FQDN, so after failover they reconnect to the newly promoted namespace without changing configuration.

Event Hubs Geo-DR replicates **metadata only**:

- Event Hub entities, partition counts, retention settings, and consumer groups
- Authorization rules and namespace-level metadata
- The alias endpoint used by producers and consumers

> **Important:** Geo-DR does **not** replicate the event payloads themselves. If your resiliency goal includes data preservation, pair Geo-DR with **Event Hubs Capture** or another downstream persistence strategy.

---

## Architecture

```text
┌──────────────────────────────────────────────────────────────────────┐
│                        Geo-DR Alias                                  │
│              eh-alias-multiregion.servicebus.windows.net             │
│                                                                      │
│    Producers ──────►  Alias Endpoint  ◄────── Consumers              │
│                           │                                          │
│              ┌────────────┴────────────┐                             │
│              │                         │                             │
│              ▼                         ▼                             │
│   ┌─────────────────────┐   ┌─────────────────────┐                 │
│   │   Primary EH NS     │   │  Secondary EH NS    │                 │
│   │  (Sweden Central)   │   │  (Norway East)      │                 │
│   │                     │   │                     │                 │
│   │  events-telemetry   │──►│  events-telemetry   │                 │
│   │   (2 partitions)    │   │   (2 partitions)    │                 │
│   │  analytics-cg       │──►│  analytics-cg       │                 │
│   │                     │   │                     │                 │
│   │  SAS / Auth Rules   │──►│  SAS / Auth Rules   │                 │
│   └─────────────────────┘   └─────────────────────┘                 │
│                                                                      │
│   ──────► = Metadata replication (continuous, async)                 │
│   During failover the alias DNS swings to the secondary namespace    │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.50+ (`az --version`) |
| **Azure subscription** | Permission to create Event Hubs namespaces |
| **Tier** | **Standard** or **Premium** |
| **Python 3.10+** *(recommended)* | Used for the producer sample in the shell tabs |
| **PowerShell 7+** *(optional)* | Needed only if you follow the PowerShell path |

> **Cost note:** Event Hubs Geo-DR works on the **Standard** tier, unlike Service Bus Geo-DR. That makes it a lower-cost way to practise regional resiliency patterns.

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
<strong>Tip:</strong> Keep the alias name and the two namespace names together in your notes. In a real incident, clean naming reduces confusion during failover.
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
RANDOM_SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | head -c 5)

EH_PRIMARY="eh-dr-swc-$RANDOM_SUFFIX"
EH_SECONDARY="eh-dr-noe-$RANDOM_SUFFIX"
EH_ALIAS="eh-alias-multiregion"

EH_NAME="events-telemetry"
CG_NAME="analytics-cg"

RG_PRIMARY="rg-eh-primary-swedencentral"
RG_SECONDARY="rg-eh-secondary-norwayeast"

LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

echo "Primary namespace : $EH_PRIMARY"
echo "Secondary namespace: $EH_SECONDARY"
echo "Alias              : $EH_ALIAS"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$EH_PRIMARY = "eh-dr-swc-$RANDOM_SUFFIX"
$EH_SECONDARY = "eh-dr-noe-$RANDOM_SUFFIX"
$EH_ALIAS = "eh-alias-multiregion"

$EH_NAME = "events-telemetry"
$CG_NAME = "analytics-cg"

$RG_PRIMARY = "rg-eh-primary-swedencentral"
$RG_SECONDARY = "rg-eh-secondary-norwayeast"

$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"

Write-Host "Primary namespace : $EH_PRIMARY"
Write-Host "Secondary namespace: $EH_SECONDARY"
Write-Host "Alias              : $EH_ALIAS"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down the values you plan to use:

1. Primary namespace: `eh-dr-swc-<suffix>`
2. Secondary namespace: `eh-dr-noe-<suffix>`
3. Alias: `eh-alias-multiregion`
4. Event Hub name: `events-telemetry`
5. Consumer group: `analytics-cg`

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

1. Create `rg-eh-primary-swedencentral` in **Sweden Central**.
2. Create `rg-eh-secondary-norwayeast` in **Norway East**.

  </div>
</div>



---

## Step 3 — Create the Primary Event Hubs Namespace

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs namespace create \
  --name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku Standard \
  --capacity 1 \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs namespace create `
  --name $EH_PRIMARY `
  --resource-group $RG_PRIMARY `
  --location $LOCATION_PRIMARY `
  --sku Standard `
  --capacity 1 `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Event Hubs namespaces** → **Create**.
2. Use name `eh-dr-swc-<suffix>` in **Sweden Central**.
3. Select **Standard** with **1 throughput unit**.

  </div>
</div>



---

## Step 4 — Create the Secondary Event Hubs Namespace

Use the same tier and capacity in the recovery region.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs namespace create \
  --name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --sku Standard \
  --capacity 1 \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs namespace create `
  --name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --location $LOCATION_SECONDARY `
  --sku Standard `
  --capacity 1 `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create the second namespace in **Norway East**.
2. Match the same **Standard** tier and **1 throughput unit**.
3. Keep it empty until pairing is complete.

  </div>
</div>



---

## Step 5 — Create an Event Hub on the Primary Namespace

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs eventhub create \
  --name "$EH_NAME" \
  --namespace-name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --partition-count 2 \
  --cleanup-policy Delete \
  --retention-time-in-hours 24 \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs eventhub create `
  --name $EH_NAME `
  --namespace-name $EH_PRIMARY `
  --resource-group $RG_PRIMARY `
  --partition-count 2 `
  --cleanup-policy Delete `
  --retention-time-in-hours 24 `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **primary** Event Hubs namespace.
2. Select **Event Hubs** → **+ Event Hub**.
3. Name it `events-telemetry`.
4. Set **2 partitions** and **1 day** retention.

  </div>
</div>



---

## Step 6 — Create a Consumer Group

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs eventhub consumer-group create \
  --name "$CG_NAME" \
  --eventhub-name "$EH_NAME" \
  --namespace-name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --output table

az eventhubs eventhub consumer-group list \
  --eventhub-name "$EH_NAME" \
  --namespace-name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs eventhub consumer-group create `
  --name $CG_NAME `
  --eventhub-name $EH_NAME `
  --namespace-name $EH_PRIMARY `
  --resource-group $RG_PRIMARY `
  --output table

az eventhubs eventhub consumer-group list `
  --eventhub-name $EH_NAME `
  --namespace-name $EH_PRIMARY `
  --resource-group $RG_PRIMARY `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `events-telemetry` inside the primary namespace.
2. Select **Consumer groups** → **+ Consumer group**.
3. Create `analytics-cg`.
4. Verify both `$Default` and `analytics-cg` are listed.

  </div>
</div>



---

## Step 7 — Retrieve the Secondary Namespace Resource ID

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SECONDARY_ID=$(az eventhubs namespace show \
  --name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query id \
  --output tsv)

echo "$SECONDARY_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SECONDARY_ID = az eventhubs namespace show `
  --name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --query id `
  --output tsv

Write-Host $SECONDARY_ID
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the secondary namespace.
2. Copy the **Resource ID** from **Overview** or **JSON View**.
3. Keep it handy for the pairing command.

  </div>
</div>



---

## Step 8 — Create the Geo-DR Alias (Pairing)

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs georecovery-alias set \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$EH_PRIMARY" \
  --alias "$EH_ALIAS" \
  --partner-namespace "$SECONDARY_ID"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs georecovery-alias set `
  --resource-group $RG_PRIMARY `
  --namespace-name $EH_PRIMARY `
  --alias $EH_ALIAS `
  --partner-namespace $SECONDARY_ID
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **primary** Event Hubs namespace.
2. Select **Geo recovery**.
3. Start a new pairing, enter alias `eh-alias-multiregion`, and choose the Norway East namespace.
4. Confirm the operation.

  </div>
</div>



---

## Step 9 — Check Alias Provisioning Status

Wait for the alias to finish provisioning before you test metadata or traffic.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs georecovery-alias show \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$EH_PRIMARY" \
  --alias "$EH_ALIAS" \
  --query '{alias:name, role:role, provisioningState:provisioningState, partnerNamespace:partnerNamespace}' \
  --output table

while true; do
  STATE=$(az eventhubs georecovery-alias show \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$EH_PRIMARY" \
  --alias "$EH_ALIAS" \
  --query provisioningState \
  --output tsv)

  echo "Current state: $STATE"
  [ "$STATE" = "Succeeded" ] && break
  sleep 10
done
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs georecovery-alias show `
  --resource-group $RG_PRIMARY `
  --namespace-name $EH_PRIMARY `
  --alias $EH_ALIAS `
  --query '{alias:name, role:role, provisioningState:provisioningState, partnerNamespace:partnerNamespace}' `
  --output table

do {
    $STATE = az eventhubs georecovery-alias show `
      --resource-group $RG_PRIMARY `
      --namespace-name $EH_PRIMARY `
      --alias $EH_ALIAS `
      --query provisioningState `
      --output tsv

    Write-Host "Current state: $STATE"
    if ($STATE -ne "Succeeded") { Start-Sleep -Seconds 10 }
} while ($STATE -ne "Succeeded")
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Refresh the **Geo recovery** blade.
2. Wait until the alias shows **Succeeded**.
3. Confirm the primary role is still on Sweden Central.

  </div>
</div>



---

## Step 10 — Verify Entities Replicated to the Secondary

The secondary namespace should now reflect the Event Hub and consumer group metadata from the primary.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs eventhub list \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --output table

az eventhubs eventhub consumer-group list \
  --eventhub-name "$EH_NAME" \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs eventhub list `
  --namespace-name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --output table

az eventhubs eventhub consumer-group list `
  --eventhub-name $EH_NAME `
  --namespace-name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **secondary** namespace.
2. Verify `events-telemetry` exists under **Event Hubs**.
3. Open the Event Hub and confirm `analytics-cg` exists under **Consumer groups**.

  </div>
</div>



<div class="lab-note">
<strong>Replication scope:</strong> Event Hub configuration is replicated, but event data and consumer checkpoints are not.
</div>



<div class="lab-note">
<strong>If local auth is disabled:</strong> Some subscriptions enforce <code>disableLocalAuth=true</code> on Event Hubs namespaces. In that case the connection-string producer snippets fail with authentication errors. Assign yourself <code>Azure Event Hubs Data Owner</code> on both namespaces and use <code>AzureCliCredential</code> or <code>DefaultAzureCredential</code> with the alias FQDN instead.
</div>



---

## Step 11 — Send Test Events to the Alias Endpoint

Use a small producer script that connects to the alias. This mirrors the way real applications should connect.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
python -m pip install --quiet azure-eventhub

EVENTHUB_ALIAS_CONNECTION_STRING=$(az eventhubs georecovery-alias authorization-rule keys list \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$EH_PRIMARY" \
  --alias "$EH_ALIAS" \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString \
  --output tsv)

export EVENTHUB_ALIAS_CONNECTION_STRING

cat > /tmp/send_events.py <<'PY'
import os
from azure.eventhub import EventHubProducerClient, EventData

connection_string = os.environ["EVENTHUB_ALIAS_CONNECTION_STRING"]
producer = EventHubProducerClient.from_connection_string(
    conn_str=connection_string,
    eventhub_name="events-telemetry",
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"Pre-failover event {i}"))
    producer.send_batch(batch)
    print("Sent 10 pre-failover events through the alias")
PY

python /tmp/send_events.py
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
python -m pip install --quiet azure-eventhub

$EVENTHUB_ALIAS_CONNECTION_STRING = az eventhubs georecovery-alias authorization-rule keys list `
  --resource-group $RG_PRIMARY `
  --namespace-name $EH_PRIMARY `
  --alias $EH_ALIAS `
  --name RootManageSharedAccessKey `
  --query primaryConnectionString `
  --output tsv

$env:EVENTHUB_ALIAS_CONNECTION_STRING = $EVENTHUB_ALIAS_CONNECTION_STRING

@'
import os
from azure.eventhub import EventHubProducerClient, EventData

connection_string = os.environ["EVENTHUB_ALIAS_CONNECTION_STRING"]
producer = EventHubProducerClient.from_connection_string(
    conn_str=connection_string,
    eventhub_name="events-telemetry",
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"Pre-failover event {i}"))
    producer.send_batch(batch)
    print("Sent 10 pre-failover events through the alias")
'@ | Set-Content -Path (Join-Path ([System.IO.Path]::GetTempPath()) "send_events.py")

python (Join-Path ([System.IO.Path]::GetTempPath()) "send_events.py")
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. If your portal tenant exposes **Data Explorer** for Event Hubs, open `events-telemetry` and publish a small batch of test events.
2. If that experience is not available, open **Cloud Shell** from the portal and run the Bash or PowerShell producer script.
3. The important detail is to use the **alias** connection string, not the regional namespace directly.

  </div>
</div>



---

## Step 12 — Initiate Failover

This promotes the Norway East namespace and breaks the existing pairing.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs georecovery-alias fail-over \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$EH_SECONDARY" \
  --alias "$EH_ALIAS"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs georecovery-alias fail-over `
  --resource-group $RG_SECONDARY `
  --namespace-name $EH_SECONDARY `
  --alias $EH_ALIAS
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the **secondary** namespace.
2. Select **Geo recovery**.
3. Choose the alias and click **Fail over**.
4. Confirm the warning dialog.

  </div>
</div>



<div class="lab-note">
<strong>One-way operation:</strong> After failover, the alias points to the new primary and the old pairing is dissolved. To restore DR protection, create a fresh partner namespace and pair again.
</div>



---

## Step 13 — Verify the Alias Points to the Secondary

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs georecovery-alias show \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$EH_SECONDARY" \
  --alias "$EH_ALIAS" \
  --query '{alias:name, role:role, provisioningState:provisioningState}' \
  --output table

nslookup "$EH_ALIAS.servicebus.windows.net"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs georecovery-alias show `
  --resource-group $RG_SECONDARY `
  --namespace-name $EH_SECONDARY `
  --alias $EH_ALIAS `
  --query '{alias:name, role:role, provisioningState:provisioningState}' `
  --output table

nslookup "$EH_ALIAS.servicebus.windows.net"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Refresh the **Geo recovery** blade on the secondary namespace.
2. Confirm the alias now shows the Norway East namespace as **Primary** or **PrimaryNotReplicating**.
3. Optionally run the DNS check in Cloud Shell to see the alias resolve toward the promoted namespace.

  </div>
</div>



---

## Step 14 — Send Events After Failover

Reuse the same alias endpoint. Client configuration should stay unchanged.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
if [ -z "$EVENTHUB_ALIAS_CONNECTION_STRING" ]; then
  EVENTHUB_ALIAS_CONNECTION_STRING=$(az eventhubs georecovery-alias authorization-rule keys list \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$EH_SECONDARY" \
  --alias "$EH_ALIAS" \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString \
  --output tsv)
  export EVENTHUB_ALIAS_CONNECTION_STRING
fi

python - <<'PY'
import os
from azure.eventhub import EventHubProducerClient, EventData

connection_string = os.environ["EVENTHUB_ALIAS_CONNECTION_STRING"]
producer = EventHubProducerClient.from_connection_string(
    conn_str=connection_string,
    eventhub_name="events-telemetry",
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"Post-failover event {i}"))
    producer.send_batch(batch)
    print("Sent 10 post-failover events through the same alias")
PY
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
if (-not $EVENTHUB_ALIAS_CONNECTION_STRING) {
    $EVENTHUB_ALIAS_CONNECTION_STRING = az eventhubs georecovery-alias authorization-rule keys list `
      --resource-group $RG_SECONDARY `
      --namespace-name $EH_SECONDARY `
      --alias $EH_ALIAS `
      --name RootManageSharedAccessKey `
      --query primaryConnectionString `
      --output tsv
}

$env:EVENTHUB_ALIAS_CONNECTION_STRING = $EVENTHUB_ALIAS_CONNECTION_STRING

@'
import os
from azure.eventhub import EventHubProducerClient, EventData

connection_string = os.environ["EVENTHUB_ALIAS_CONNECTION_STRING"]
producer = EventHubProducerClient.from_connection_string(
    conn_str=connection_string,
    eventhub_name="events-telemetry",
)

with producer:
    batch = producer.create_batch()
    for i in range(10):
        batch.add(EventData(f"Post-failover event {i}"))
    producer.send_batch(batch)
    print("Sent 10 post-failover events through the same alias")
'@ | Set-Content -Path (Join-Path ([System.IO.Path]::GetTempPath()) "send_events_post_failover.py")

python (Join-Path ([System.IO.Path]::GetTempPath()) "send_events_post_failover.py")
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Use **Data Explorer** again if available, or rerun the producer from **Cloud Shell**.
2. Keep the same alias connection string.
3. The send operation should now land on the promoted namespace in Norway East.

  </div>
</div>



---

## Step 15 — Verify the New Primary Is Active

Confirm the Event Hub definition and consumer groups are still present on the promoted namespace.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs eventhub show \
  --name "$EH_NAME" \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --output table

az eventhubs eventhub consumer-group list \
  --eventhub-name "$EH_NAME" \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs eventhub show `
  --name $EH_NAME `
  --namespace-name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --output table

az eventhubs eventhub consumer-group list `
  --eventhub-name $EH_NAME `
  --namespace-name $EH_SECONDARY `
  --resource-group $RG_SECONDARY `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the promoted namespace in Norway East.
2. Confirm `events-telemetry` is still present.
3. Open **Consumer groups** and verify `analytics-cg` still exists.
4. If your portal offers charts or metrics, check that incoming requests are now being recorded in Norway East.

  </div>
</div>

---

## Validation Checklist

| # | Check | Expected Result |
|---|---|---|
| 1 | Alias created and provisioned | `provisioningState = Succeeded` |
| 2 | Event Hub replicated | `events-telemetry` visible on the secondary namespace |
| 3 | Consumer group replicated | `analytics-cg` visible on the secondary namespace |
| 4 | Pre-failover producer works | Events are accepted through the alias |
| 5 | Failover completed | Norway East shows `role = Primary*` (for example `PrimaryNotReplicating`) |
| 6 | Post-failover producer works | Same alias connection string still sends successfully |

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
az eventhubs georecovery-alias delete \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$EH_SECONDARY" \
  --alias "$EH_ALIAS" \
  2>/dev/null || true

az group delete --name "$RG_PRIMARY" --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs georecovery-alias delete `
  --resource-group $RG_SECONDARY `
  --namespace-name $EH_SECONDARY `
  --alias $EH_ALIAS `
  2>$null

az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete the alias if it still appears on the promoted namespace.
2. Delete both resource groups.
3. Wait for the namespaces to disappear before reusing the names.

  </div>
</div>

---

## Discussion

### Geo-DR vs. Full Geo-Replication

| Aspect | Geo-DR | Full geo-replication |
|---|---|---|
| **What replicates** | Metadata only | Metadata and event data |
| **Data availability** | Events exist only on the active primary | Events are available cross-region |
| **Failover type** | Manual, one-way | Broader replication model |
| **Consumer offsets** | Not replicated | Addressed in fuller replication offerings |
| **Tier requirement** | Standard or Premium | Higher-cost feature set |

### Differences from Service Bus Geo-DR

Event Hubs Geo-DR follows the same alias-and-metadata pattern as Service Bus, but Event Hubs can start on the Standard tier and is designed for append-only streaming workloads rather than brokered queue semantics.

### Event Hubs Capture — Independent Data Preservation

Geo-DR keeps the namespace definition alive, but **Capture** is what preserves actual event data. If event replay matters, enable Capture to write events into Blob Storage or Data Lake.

### Consumer Group Behaviour After Failover

Consumer groups replicate, but **checkpoints do not**. Plan for consumers to reconnect and decide how they should behave when the checkpoint store no longer matches the active namespace.

### Partition Count and Entity Configuration

Partition count, retention, SAS rules, and consumer groups all replicate to the secondary. That is why producers and consumers can reconnect without re-provisioning the Event Hub itself.

---

## Summary

In this lab you created paired Event Hubs namespaces, replicated Event Hub metadata, sent events through the alias, failed over to Norway East, and verified that the alias still worked afterward. The core lesson is that **Geo-DR protects the namespace contract, not the event stream history**.

---

## Key Takeaways

- **Geo-DR is metadata-only** — use Event Hubs Capture or another sink for event preservation.
- **Standard tier is enough** for the lab scenario.
- **Always use the alias endpoint** so failover does not require client reconfiguration.
- **Consumer checkpoints do not move** with the alias.
- **Failover is one-way** until you establish a new pairing.

---

[← Back to Index](../index.md) | [Next: Lab 11 — Azure Container Registry Geo-Replication →](lab-08-acr-geo-replication.md)
