---
layout: default
title: "Lab 7: Multi-Region Web App with Traffic Manager & Chaos Studio"
---

[← Back to Index](../index.md)

# Lab 7: Multi-Region Web App with Traffic Manager & Chaos Studio

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

## Why Multi-Region Web Apps Matter

Azure App Service is a **regional** service. If your site only runs in one region, that region becomes a **single point of failure**. A multi-region deployment reduces that risk by running the application in two regions and using a global traffic layer to direct clients to the healthy endpoint.

In this lab, you will use:

- **App Service** in **Sweden Central** as the primary app
- **App Service** in **Norway East** as the secondary app
- **Azure Traffic Manager** with **Priority** routing for DNS-based failover
- **Azure Chaos Studio** to stop the primary app and observe failover behavior

---

## Architecture

```
                         ┌──────────────────────────────────┐
                         │      Azure Traffic Manager       │
                         │  tm-multiregion-webapp            │
                         │  .trafficmanager.net              │
                         │  Routing: Priority                │
                         └──────────┬───────────┬───────────┘
                                    │           │
                          Priority 1│           │Priority 2
                                    │           │
                    ┌───────────────▼──┐   ┌──▼────────────────┐
                    │  Sweden Central   │   │   Norway East      │
                    │  (Primary)        │   │   (Secondary)      │
                    │                   │   │                    │
                    │ ┌───────────────┐ │   │ ┌──────────────┐  │
                    │ │ App Service   │ │   │ │ App Service  │  │
                    │ │ Plan (B1)     │ │   │ │ Plan (B1)    │  │
                    │ │               │ │   │ │              │  │
                    │ │ Web App       │ │   │ │ Web App      │  │
                    │ │ app-dr-swc    │ │   │ │ app-dr-noe   │  │
                    │ └───────────────┘ │   │ └──────────────┘  │
                    │                   │   │                    │
                    │ rg-dr-swc         │   │ rg-dr-noe          │
                    └───────────────────┘   └────────────────────┘
```

Traffic Manager is **DNS-based**, not an HTTP reverse proxy. It returns the DNS answer for the highest-priority healthy endpoint.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Azure subscription | Contributor or higher on the subscription or target resource groups |
| Role assignment rights | For the Chaos Studio section, you also need permission to create role assignments on the primary app scope or resource group (**Owner** or **User Access Administrator**) |
| Azure CLI | v2.60 or later |
| Shell | Bash, PowerShell 7+, or Azure Cloud Shell |
| Portal access | Needed for the portal-only path |

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
2. If needed, switch to the correct tenant or directory from the account menu.
3. Open **Subscriptions** and confirm the subscription you want to use.

</div>
</div>

---

## Step 1 — Define Variables

Use a single naming pattern through the rest of the lab.

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

PRIMARY_RG="rg-dr-swc"
SECONDARY_RG="rg-dr-noe"

PRIMARY_PLAN="plan-dr-swc"
SECONDARY_PLAN="plan-dr-noe"

RANDOM_SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | head -c 5)
PRIMARY_APP="app-dr-swc-${RANDOM_SUFFIX}"
SECONDARY_APP="app-dr-noe-${RANDOM_SUFFIX}"

TM_PROFILE="tm-multiregion-webapp"
TM_DNS_NAME="tm-multiregion-webapp-${RANDOM_SUFFIX}"

echo "Primary app:   $PRIMARY_APP"
echo "Secondary app: $SECONDARY_APP"
echo "TM profile:    $TM_PROFILE"
echo "TM DNS label:  $TM_DNS_NAME"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$PRIMARY_RG = "rg-dr-swc"
$SECONDARY_RG = "rg-dr-noe"

$PRIMARY_PLAN = "plan-dr-swc"
$SECONDARY_PLAN = "plan-dr-noe"

$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
$PRIMARY_APP = "app-dr-swc-$RANDOM_SUFFIX"
$SECONDARY_APP = "app-dr-noe-$RANDOM_SUFFIX"

$TM_PROFILE = "tm-multiregion-webapp"
$TM_DNS_NAME = "tm-multiregion-webapp-$RANDOM_SUFFIX"

Write-Host "Primary app:   $PRIMARY_APP"
Write-Host "Secondary app: $SECONDARY_APP"
Write-Host "TM profile:    $TM_PROFILE"
Write-Host "TM DNS label:  $TM_DNS_NAME"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down or choose these values before you start:

- Primary region: `swedencentral`
- Secondary region: `norwayeast`
- Resource groups: `rg-dr-swc`, `rg-dr-noe`
- App Service plans: `plan-dr-swc`, `plan-dr-noe`
- Web app names: `app-dr-swc-<suffix>`, `app-dr-noe-<suffix>`
- Traffic Manager profile name: `tm-multiregion-webapp`
- Traffic Manager DNS label: `tm-multiregion-webapp-<suffix>`

</div>
</div>

<div class="lab-note">
<strong>Tip:</strong> <code>TM_PROFILE</code> is the Traffic Manager resource name. <code>TM_DNS_NAME</code> becomes <code>&lt;dns-label&gt;.trafficmanager.net</code>.
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
az group create --name "$PRIMARY_RG" --location "$PRIMARY_REGION"
az group create --name "$SECONDARY_RG" --location "$SECONDARY_REGION"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $PRIMARY_RG --location $PRIMARY_REGION
az group create --name $SECONDARY_RG --location $SECONDARY_REGION
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Create `rg-dr-swc` in **Sweden Central**.
3. Create `rg-dr-noe` in **Norway East**.

</div>
</div>

---

## Step 3 — Create App Service Plans

Use the **B1** SKU to keep the lab inexpensive.

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
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **App Service plans**.
2. Create `plan-dr-swc` in `rg-dr-swc` using **Linux** and **B1**.
3. Create `plan-dr-noe` in `rg-dr-noe` using **Linux** and **B1**.

</div>
</div>

---

## Step 4 — Create the Web Apps

Create one Linux web app in each region.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
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

1. Open **App Services** and create a new app for the primary region.
2. Use:
   - Resource group: `rg-dr-swc`
   - Name: `app-dr-swc-<suffix>`
   - Runtime stack: **Node 20 LTS**
   - Operating system: **Linux**
   - App Service plan: `plan-dr-swc`
3. Repeat for the secondary region using `rg-dr-noe`, `app-dr-noe-<suffix>`, and `plan-dr-noe`.

</div>
</div>

---

## Step 5 — Deploy a Tiny Region-Aware App

The sample app prints the hostname, region, and current timestamp so you can tell which instance answered the request.

### Shared app files

`index.js`

```javascript
const http = require("http");
const os = require("os");

const server = http.createServer((req, res) => {
  const region = process.env.REGION || "unknown";
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Multi-Region Resiliency Lab</title>
    <style>
      body { font-family: "Segoe UI", system-ui, sans-serif; margin: 40px; background: #f6f8fa; color: #24292f; }
      .card { max-width: 720px; padding: 28px; border-radius: 16px; background: #ffffff; box-shadow: 0 12px 28px rgba(31, 35, 40, 0.08); }
      h1 { margin-top: 0; }
      .label { color: #57606a; font-size: 0.9rem; margin-top: 1rem; }
      .value { font-size: 1.2rem; font-weight: 700; }
    </style>
  </head>
  <body>
    <div class="card">
      <h1>Multi-Region Resiliency Lab</h1>
      <div class="label">Hostname</div>
      <div class="value">${os.hostname()}</div>
      <div class="label">Region</div>
      <div class="value">${region}</div>
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
  "name": "dr-webapp",
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
mkdir -p /tmp/dr-webapp

cat > /tmp/dr-webapp/index.js <<'EOF'
const http = require("http");
const os = require("os");

const server = http.createServer((req, res) => {
  const region = process.env.REGION || "unknown";
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Multi-Region Resiliency Lab</title>
  </head>
  <body>
    <h1>Multi-Region Resiliency Lab</h1>
    <p><strong>Hostname:</strong> ${os.hostname()}</p>
    <p><strong>Region:</strong> ${region}</p>
    <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
  </body>
</html>`);
});

server.listen(process.env.PORT || 8080);
EOF

cat > /tmp/dr-webapp/package.json <<'EOF'
{
  "name": "dr-webapp",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js"
  }
}
EOF

(cd /tmp/dr-webapp && zip -qr /tmp/dr-webapp.zip .)

az webapp config appsettings set \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --settings REGION="$PRIMARY_REGION"

az webapp config appsettings set \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --settings REGION="$SECONDARY_REGION"

az webapp deploy \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --src-path /tmp/dr-webapp.zip \
  --type zip

az webapp deploy \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --src-path /tmp/dr-webapp.zip \
  --type zip
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$TempRoot = Join-Path $env:TEMP "dr-webapp"
$ZipPath = Join-Path $env:TEMP "dr-webapp.zip"

New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null

@'
const http = require("http");
const os = require("os");

const server = http.createServer((req, res) => {
  const region = process.env.REGION || "unknown";
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Multi-Region Resiliency Lab</title>
  </head>
  <body>
    <h1>Multi-Region Resiliency Lab</h1>
    <p><strong>Hostname:</strong> ${os.hostname()}</p>
    <p><strong>Region:</strong> ${region}</p>
    <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
  </body>
</html>`);
});

server.listen(process.env.PORT || 8080);
'@ | Set-Content -Path (Join-Path $TempRoot "index.js")

@'
{
  "name": "dr-webapp",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js"
  }
}
'@ | Set-Content -Path (Join-Path $TempRoot "package.json")

if (Test-Path $ZipPath) {
  Remove-Item $ZipPath -Force
}

Compress-Archive -Path (Join-Path $TempRoot "*") -DestinationPath $ZipPath

az webapp config appsettings set --name $PRIMARY_APP --resource-group $PRIMARY_RG --settings REGION=$PRIMARY_REGION
az webapp config appsettings set --name $SECONDARY_APP --resource-group $SECONDARY_RG --settings REGION=$SECONDARY_REGION

az webapp deploy --name $PRIMARY_APP --resource-group $PRIMARY_RG --src-path $ZipPath --type zip
az webapp deploy --name $SECONDARY_APP --resource-group $SECONDARY_RG --src-path $ZipPath --type zip
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In each web app, open **Settings > Environment variables** and add `REGION`.
   - Primary value: `swedencentral`
   - Secondary value: `norwayeast`
2. Open **Development Tools > Advanced Tools** and launch Kudu.
3. In Kudu, browse to `site/wwwroot`.
4. Upload `index.js` and `package.json` using the shared file contents above.
5. Restart each app from **Overview**.

</div>
</div>

---

## Step 6 — Verify Both App URLs Directly

Before adding Traffic Manager, verify each app on its own `azurewebsites.net` address.

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

curl -s "https://${PRIMARY_APP}.azurewebsites.net" | head -20
curl -s "https://${SECONDARY_APP}.azurewebsites.net" | head -20
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Write-Host "Primary:   https://$PRIMARY_APP.azurewebsites.net"
Write-Host "Secondary: https://$SECONDARY_APP.azurewebsites.net"

(Invoke-WebRequest "https://$PRIMARY_APP.azurewebsites.net").Content
(Invoke-WebRequest "https://$SECONDARY_APP.azurewebsites.net").Content
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open each App Service in the portal.
2. Select **Browse**.
3. Confirm each app shows its own hostname and region.

</div>
</div>

<div class="lab-note">
<strong>Tip:</strong> If you still see the default App Service page, wait 30-60 seconds and refresh.
</div>

---

## Step 7 — Create the Traffic Manager Profile

Traffic Manager is a **DNS-based** traffic router. It monitors each endpoint and returns the highest-priority healthy answer.

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
   - Name: `tm-multiregion-webapp`
   - Resource group: `rg-dr-swc`
   - Routing method: **Priority**
   - Relative DNS name: `tm-multiregion-webapp-<suffix>`
3. In **Configuration**, set:
   - Protocol: **HTTPS**
   - Port: `443`
   - Path: `/`
   - TTL: `30`

</div>
</div>

---

## Step 8 — Add Both Web Apps as Endpoints

Primary gets priority **1** and secondary gets priority **2**.

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
3. Add the primary web app as an **Azure endpoint** with priority `1`.
4. Add the secondary web app as an **Azure endpoint** with priority `2`.

</div>
</div>

---

## Step 9 — Check Normal Routing

<div class="lab-note">
<strong>Important:</strong> Traffic Manager is <strong>DNS only</strong>. In this lab, the <code>*.trafficmanager.net</code> hostname is <strong>not</strong> bound as a custom domain on either App Service. That means opening the Traffic Manager hostname directly in a browser can show <code>404 Web Site not found</code> even when routing is working correctly. Use <strong>DNS resolution</strong> to verify failover, or bind a custom domain on both apps if you want a browser-friendly shared hostname.
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
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Traffic Manager profile.
2. Confirm both endpoints are enabled.
3. Copy the Traffic Manager DNS name from **Overview**.
4. Use `nslookup` from a shell to confirm it resolves to the **primary** app's `azurewebsites.net` hostname.

</div>
</div>

---

## Step 10 — Use Chaos Studio to Stop the Primary App

This intentionally stops the primary app so you can observe Traffic Manager failover.

<div class="lab-note">
<strong>Permission note:</strong> creating the experiment is not enough. The experiment's system-assigned identity must also receive the <strong>Website Contributor</strong> role on the primary app. Creating that role assignment requires <strong>Owner</strong> or <strong>User Access Administrator</strong> on the scope.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az provider register --namespace Microsoft.Chaos --wait
az provider show --namespace Microsoft.Chaos --query "registrationState" -o tsv

az rest --method put \
  --headers "Content-Type=application/json" \
  --url "https://management.azure.com${PRIMARY_APP_ID}/providers/Microsoft.Chaos/targets/Microsoft-AppService?api-version=2024-01-01" \
  --body '{"properties":{}}'

az rest --method put \
  --headers "Content-Type=application/json" \
  --url "https://management.azure.com${PRIMARY_APP_ID}/providers/Microsoft.Chaos/targets/Microsoft-AppService/capabilities/Stop-1.0?api-version=2024-01-01" \
  --body '{"properties":{}}'

SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
EXPERIMENT_NAME="chaos-stop-primary-app"

cat > /tmp/chaos-experiment.json <<JSONEOF
{
  "location": "${PRIMARY_REGION}",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "selectors": [
      {
        "type": "List",
        "id": "selector1",
        "targets": [
          {
            "type": "ChaosTarget",
            "id": "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Web/sites/${PRIMARY_APP}/providers/Microsoft.Chaos/targets/Microsoft-AppService"
          }
        ]
      }
    ],
    "steps": [
      {
        "name": "Step 1 - Stop Primary App",
        "branches": [
          {
            "name": "Branch 1",
            "actions": [
              {
                "type": "continuous",
                "name": "urn:csci:microsoft:appService:stop/1.0",
                "duration": "PT5M",
                "parameters": [],
                "selectorId": "selector1"
              }
            ]
          }
        ]
      }
    ]
  }
}
JSONEOF

az rest --method put \
  --headers "Content-Type=application/json" \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Chaos/experiments/${EXPERIMENT_NAME}?api-version=2024-01-01" \
  --body @/tmp/chaos-experiment.json

EXPERIMENT_PRINCIPAL_ID=$(az rest --method get \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Chaos/experiments/${EXPERIMENT_NAME}?api-version=2024-01-01" \
  --query "identity.principalId" -o tsv)

az role assignment create \
  --assignee-object-id "$EXPERIMENT_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Website Contributor" \
  --scope "$PRIMARY_APP_ID"

az rest --method post \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Chaos/experiments/${EXPERIMENT_NAME}/start?api-version=2024-01-01"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az provider register --namespace Microsoft.Chaos --wait
az provider show --namespace Microsoft.Chaos --query "registrationState" -o tsv

az rest --method put `
  --headers "Content-Type=application/json" `
  --url "https://management.azure.com$PRIMARY_APP_ID/providers/Microsoft.Chaos/targets/Microsoft-AppService?api-version=2024-01-01" `
  --body '{"properties":{}}'

az rest --method put `
  --headers "Content-Type=application/json" `
  --url "https://management.azure.com$PRIMARY_APP_ID/providers/Microsoft.Chaos/targets/Microsoft-AppService/capabilities/Stop-1.0?api-version=2024-01-01" `
  --body '{"properties":{}}'

$SUBSCRIPTION_ID = az account show --query "id" -o tsv
$EXPERIMENT_NAME = "chaos-stop-primary-app"
$ChaosJsonPath = Join-Path $env:TEMP "chaos-experiment.json"

@"
{
  "location": "$PRIMARY_REGION",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "selectors": [
      {
        "type": "List",
        "id": "selector1",
        "targets": [
          {
            "type": "ChaosTarget",
            "id": "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$PRIMARY_RG/providers/Microsoft.Web/sites/$PRIMARY_APP/providers/Microsoft.Chaos/targets/Microsoft-AppService"
          }
        ]
      }
    ],
    "steps": [
      {
        "name": "Step 1 - Stop Primary App",
        "branches": [
          {
            "name": "Branch 1",
            "actions": [
              {
                "type": "continuous",
                "name": "urn:csci:microsoft:appService:stop/1.0",
                "duration": "PT5M",
                "parameters": [],
                "selectorId": "selector1"
              }
            ]
          }
        ]
      }
    ]
  }
}
"@ | Set-Content -Path $ChaosJsonPath

az rest --method put `
  --headers "Content-Type=application/json" `
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$PRIMARY_RG/providers/Microsoft.Chaos/experiments/$EXPERIMENT_NAME?api-version=2024-01-01" `
  --body (Get-Content -Raw $ChaosJsonPath)

$EXPERIMENT_PRINCIPAL_ID = az rest --method get `
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$PRIMARY_RG/providers/Microsoft.Chaos/experiments/$EXPERIMENT_NAME?api-version=2024-01-01" `
  --query "identity.principalId" -o tsv

az role assignment create `
  --assignee-object-id $EXPERIMENT_PRINCIPAL_ID `
  --assignee-principal-type ServicePrincipal `
  --role "Website Contributor" `
  --scope $PRIMARY_APP_ID

az rest --method post `
  --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$PRIMARY_RG/providers/Microsoft.Chaos/experiments/$EXPERIMENT_NAME/start?api-version=2024-01-01"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Subscriptions > Resource providers** and register **Microsoft.Chaos**.
2. Open **Chaos Studio > Targets** and onboard the primary App Service as a target.
3. Enable the **Stop 1.0** capability.
4. Create a new experiment named `chaos-stop-primary-app` in the primary region with a system-assigned identity.
5. Add the primary App Service target and the **App Service Stop 1.0** fault with a duration of **5 minutes**.
6. Before starting the experiment, go to the primary web app's **Access control (IAM)** and grant the experiment identity the **Website Contributor** role.
7. Start the experiment.

</div>
</div>

<div class="lab-note">
<strong>Important:</strong> In PowerShell, <code>$PRIMARY_APP_ID</code> must be the full App Service <strong>resource ID</strong>, not just the app name.
</div>

---

## Step 11 — Verify Failover to the Secondary App

Failover is not instant. DNS can switch before the portal endpoint health view catches up.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
TM_FQDN="${TM_DNS_NAME}.trafficmanager.net"

nslookup "$TM_FQDN"

az webapp show \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --query "state" -o tsv

az network traffic-manager endpoint list \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" \
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$TM_FQDN = "$TM_DNS_NAME.trafficmanager.net"

nslookup $TM_FQDN

az webapp show `
  --name $PRIMARY_APP `
  --resource-group $PRIMARY_RG `
  --query "state" -o tsv

az network traffic-manager endpoint list `
  --resource-group $PRIMARY_RG `
  --profile-name $TM_PROFILE `
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" `
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm the Chaos experiment is running.
2. Open the primary App Service and confirm it is stopped or unhealthy.
3. Open the Traffic Manager profile and watch the endpoint health view.
4. Use `nslookup` from a shell to confirm the Traffic Manager DNS name resolves to the **secondary** app.

</div>
</div>

<div class="lab-note">
<strong>Note:</strong> the Traffic Manager endpoint monitor can remain <code>Online</code> for a short time even after DNS has already switched. In this lab, treat <strong>DNS resolution</strong> as the source of truth.
</div>

<div class="lab-note" markdown="1">
<strong>Tip:</strong> if you want a deterministic demo instead of waiting on health probes, temporarily disable the primary endpoint:

```azurecli
az network traffic-manager endpoint update \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --name "primary-swedencentral" \
  --type azureEndpoints \
  --endpoint-status Disabled
```
</div>

---

## Step 12 — Verify Recovery

After the Chaos experiment completes, the primary app should recover and Traffic Manager should return to the primary route.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az webapp start --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG"
sleep 30

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
Start-Sleep -Seconds 30

nslookup "$TM_DNS_NAME.trafficmanager.net"

az network traffic-manager endpoint list `
  --resource-group $PRIMARY_RG `
  --profile-name $TM_PROFILE `
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" `
  -o table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Wait for the experiment to finish successfully.
2. Confirm the primary web app is running again. Start it manually if necessary.
3. Open the Traffic Manager profile and confirm both endpoints return to a healthy state.
4. Use `nslookup` to confirm the Traffic Manager DNS name points back to the **primary** app.

</div>
</div>

---

## Troubleshooting Notes

- **Traffic Manager shows the App Service 404 page**  
  That is expected unless you bind a custom domain on both web apps. Traffic Manager returns DNS answers; it does not rewrite the HTTP host header for App Service.

- **PowerShell variables are not Bash variables**  
  Bash uses `PRIMARY_APP_ID=...`. PowerShell uses `$PRIMARY_APP_ID = ...`.

- **`PRIMARY_APP_ID` must be a resource ID**  
  It must look like `/subscriptions/.../resourceGroups/.../providers/Microsoft.Web/sites/<app-name>`, not just `app-dr-swc-xxxxx`.

- **`UnsupportedMediaType` from `az rest`**  
  Add `--headers "Content-Type=application/json"` to the Chaos target and experiment creation commands.

- **There is no manual Traffic Manager health check button**  
  Traffic Manager probes on its own cadence. If you want immediate failover for the demo, disable the primary endpoint manually.

---

## Validation Checklist

- [ ] Two App Service plans and two web apps exist in Sweden Central and Norway East
- [ ] Each direct `azurewebsites.net` URL shows hostname and region
- [ ] Traffic Manager profile exists with Priority routing
- [ ] The Traffic Manager DNS name resolves to the primary app during normal operation
- [ ] Chaos Studio successfully stops the primary app, or you simulate the same effect by disabling the primary endpoint
- [ ] During failover, the Traffic Manager DNS name resolves to the secondary app
- [ ] After recovery, the Traffic Manager DNS name resolves back to the primary app

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
az group delete --name "$PRIMARY_RG" --yes --no-wait
az group delete --name "$SECONDARY_RG" --yes --no-wait

rm -rf /tmp/dr-webapp /tmp/dr-webapp.zip /tmp/chaos-experiment.json
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $PRIMARY_RG --yes --no-wait
az group delete --name $SECONDARY_RG --yes --no-wait

Remove-Item (Join-Path $env:TEMP "dr-webapp") -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $env:TEMP "dr-webapp.zip") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $env:TEMP "chaos-experiment.json") -Force -ErrorAction SilentlyContinue
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Delete `rg-dr-swc`.
3. Delete `rg-dr-noe`.

</div>
</div>

---

## Discussion: Design Choices

### Why Traffic Manager and not Azure Front Door?

Traffic Manager works at the **DNS** layer. It is simple, inexpensive, and fits an active-passive failover lab well. Azure Front Door works as an HTTP reverse proxy and adds WAF, caching, and SSL termination, but it is more complex and typically costs more.

| Feature | Traffic Manager | Azure Front Door |
|---|---|---|
| Layer | DNS | HTTP |
| Failover speed | 30s-3 min | Near-instant |
| WAF | No | Yes |
| Caching | No | Yes |
| SSL termination | No | Yes |
| Best for | Simple failover | Global reverse proxy |

### Why non-paired regions?

This lab uses **Sweden Central** and **Norway East** to show that multi-region resiliency is not limited to Azure's default region pairs. The same design works with other region combinations that fit your latency, compliance, and capacity requirements.

### Why Chaos Studio?

Chaos Studio lets you test the full failover path in a repeatable, explicit way instead of guessing how an outage might behave. It is a good foundation for more advanced fault-injection scenarios later.

[← Lab 6: Azure Virtual Machines DR with Site Recovery](lab-13-vm-site-recovery.md) | [Back to Index](../index.md) | [Next: Lab 8 — Azure Key Vault Multi-Region →](lab-05-key-vault-multi-region.md)
