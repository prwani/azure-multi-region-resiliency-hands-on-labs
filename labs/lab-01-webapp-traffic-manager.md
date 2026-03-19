---
layout: default
title: "Lab 1: Multi-Region Web App with Traffic Manager & Chaos Studio"
---

[← Back to Index](../index.md)

# Lab 1: Multi-Region Web App with Traffic Manager & Chaos Studio

<style>
.path-strip {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin: 0.75rem 0 1rem;
}

.path-strip span {
  display: inline-block;
  padding: 0.3rem 0.8rem;
  border-radius: 999px;
  font-size: 0.85rem;
  font-weight: 600;
}

.path-strip .bash {
  background: #e8f5e9;
  color: #1b5e20;
}

.path-strip .powershell {
  background: #e8f0fe;
  color: #174ea6;
}

.path-strip .portal {
  background: #fff4e5;
  color: #9a6700;
}
</style>

## Why Multi-Region Web Apps Matter

Azure App Service is a **regional** service. When you create a web app, it lives in a single Azure datacenter. That is fine for dev/test, but for production workloads it creates a **single point of failure**: if that region goes down, your application goes down with it.

Multi-region deployment solves this by running your application in two Azure regions at the same time, fronted by a **global traffic router** that can detect failures and redirect clients automatically. In this lab, you will use **Azure Traffic Manager** with **priority routing** to implement active-passive failover between **Sweden Central** and **Norway East**.

By the end of this lab you will have:

- A web app deployed to **two non-paired Azure regions**
- A **Traffic Manager profile** that prefers the primary region and fails over to the secondary
- A **Chaos Studio experiment** that stops the primary app so you can observe failover behavior

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

**How it works:** clients resolve the Traffic Manager DNS name. Traffic Manager health-checks both endpoints and returns the DNS answer for the highest-priority **healthy** endpoint. If the primary app becomes unhealthy, Traffic Manager starts returning the secondary app instead.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Contributor or higher on the subscription or resource groups |
| **Role assignment rights** | For the Chaos Studio section, you also need permission to create role assignments on the primary app scope or resource group (**Owner** or **User Access Administrator**) |
| **Azure CLI** | v2.60 or later (`az version`) |
| **Bash or PowerShell 7+** | Use Bash for Cloud Shell/WSL/macOS/Linux, or PowerShell 7+ on Windows |
| **Azure portal access** | Needed if you prefer the Portal path |
| **Two regions chosen** | This lab defaults to **Sweden Central** and **Norway East** |

> **Tip:** If you are not sure which regions to use, run `az account list-locations --query "[?metadata.regionCategory=='Recommended'].{Name:name, DisplayName:displayName}" -o table`.

---

## How to Use This Lab

Each actionable step below is split into the same three paths:

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

- **Bash** works best in Azure Cloud Shell, WSL, Linux, or macOS
- **PowerShell** works best in Windows Terminal or PowerShell 7+
- **Portal** gives you the same setup through the Azure UI

Use **one path per step**. Do not mix Bash syntax into PowerShell or vice versa.

---

## Sign in and Select Your Subscription

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

```bash
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

### PowerShell

```powershell
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

### Portal

1. Open the [Azure portal](https://portal.azure.com).
2. If needed, switch to the correct tenant/directory from your account menu.
3. Confirm the subscription you want to use from **Subscriptions**.

---

## Step 1 — Define Variables

Use the same naming pattern throughout the lab so later steps are copy/paste friendly.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

Decide these values before you start clicking:

- Primary region: `swedencentral`
- Secondary region: `norwayeast`
- Resource groups: `rg-dr-swc`, `rg-dr-noe`
- App Service plans: `plan-dr-swc`, `plan-dr-noe`
- Web apps: `app-dr-swc-<suffix>`, `app-dr-noe-<suffix>`
- Traffic Manager profile resource name: `tm-multiregion-webapp`
- Traffic Manager DNS label: `tm-multiregion-webapp-<suffix>`

> **Tip:** `TM_PROFILE` is the Traffic Manager **resource name**. `TM_DNS_NAME` is the public DNS label that becomes `tm-multiregion-webapp-<suffix>.trafficmanager.net`.

---

## Step 2 — Create Resource Groups

Create one resource group per region. This mirrors a real-world isolation pattern and makes cleanup easier.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

```bash
az group create --name "$PRIMARY_RG" --location "$PRIMARY_REGION"
az group create --name "$SECONDARY_RG" --location "$SECONDARY_REGION"
```

### PowerShell

```powershell
az group create --name $PRIMARY_RG --location $PRIMARY_REGION
az group create --name $SECONDARY_RG --location $SECONDARY_REGION
```

### Portal

1. Go to **Resource groups**.
2. Create `rg-dr-swc` in **Sweden Central**.
3. Create `rg-dr-noe` in **Norway East**.

---

## Step 3 — Create App Service Plans

Each region needs its own App Service plan. This lab uses the **B1** SKU to keep costs low.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

1. Go to **App Service plans**.
2. Create `plan-dr-swc` in **rg-dr-swc** and **Sweden Central**.
3. Choose **Linux** and **B1 Basic**.
4. Repeat for `plan-dr-noe` in **rg-dr-noe** and **Norway East**.

---

## Step 4 — Create the Web Apps

Create one Linux web app in each region and attach each one to its matching plan.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

1. Go to **App Services** and create a new app for the primary region.
2. Use:
   - Resource group: `rg-dr-swc`
   - Name: `app-dr-swc-<suffix>`
   - Runtime stack: **Node 20 LTS**
   - Operating system: **Linux**
   - App Service plan: `plan-dr-swc`
3. Repeat for the secondary region using `rg-dr-noe`, `app-dr-noe-<suffix>`, and `plan-dr-noe`.

---

## Step 5 — Deploy a Tiny Region-Aware App

The sample app is a minimal Node.js site that returns the app hostname, the configured region, and a timestamp.

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
      body { font-family: Segoe UI, sans-serif; margin: 40px; background: #f5f9ff; color: #102a43; }
      .card { max-width: 720px; padding: 24px 28px; border-radius: 16px; background: #ffffff; box-shadow: 0 8px 24px rgba(16, 42, 67, 0.12); }
      h1 { margin-top: 0; }
      .label { color: #486581; font-size: 0.9rem; }
      .value { font-size: 1.25rem; font-weight: 700; margin-bottom: 16px; }
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

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

1. In each web app, go to **Settings > Configuration** and add an application setting named `REGION`.
   - Primary app value: `swedencentral`
   - Secondary app value: `norwayeast`
2. In each web app, open **Development Tools > Advanced Tools** and select **Go**.
3. In Kudu, open **Debug console > CMD** and browse to `site/wwwroot`.
4. Upload `index.js` and `package.json` using the shared file contents above.
5. Restart each app from **Overview > Restart**.

---

## Step 6 — Verify Both App URLs Directly

Before adding Traffic Manager, make sure both apps respond on their native `azurewebsites.net` URLs.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

```bash
echo "Primary:   https://${PRIMARY_APP}.azurewebsites.net"
echo "Secondary: https://${SECONDARY_APP}.azurewebsites.net"

curl -s "https://${PRIMARY_APP}.azurewebsites.net" | head -20
curl -s "https://${SECONDARY_APP}.azurewebsites.net" | head -20
```

### PowerShell

```powershell
Write-Host "Primary:   https://$PRIMARY_APP.azurewebsites.net"
Write-Host "Secondary: https://$SECONDARY_APP.azurewebsites.net"

(Invoke-WebRequest "https://$PRIMARY_APP.azurewebsites.net").Content
(Invoke-WebRequest "https://$SECONDARY_APP.azurewebsites.net").Content
```

### Portal

1. Open each web app in the portal.
2. Select **Browse**.
3. Confirm each app shows its own hostname and region.

> **Tip:** If you see the default App Service page, wait 30-60 seconds and try again.

---

## Step 7 — Create the Traffic Manager Profile

Traffic Manager is a **DNS-based** traffic router. In this lab, it will health-check both apps and return the highest-priority healthy endpoint.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

1. Go to **Traffic Manager profiles** and create a new profile.
2. Use:
   - Name: `tm-multiregion-webapp`
   - Resource group: `rg-dr-swc`
   - Routing method: **Priority**
   - Relative DNS name: `tm-multiregion-webapp-<suffix>`
3. After creation, open **Configuration** and set:
   - Protocol: **HTTPS**
   - Port: `443`
   - Path: `/`
   - TTL: `30`

---

## Step 8 — Add the Web Apps as Traffic Manager Endpoints

The primary app gets priority **1**. The secondary app gets priority **2**.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

1. Open the Traffic Manager profile.
2. Go to **Endpoints > Add**.
3. Add an **Azure endpoint** pointing to the primary web app with priority `1`.
4. Add another **Azure endpoint** pointing to the secondary web app with priority `2`.

---

## Step 9 — Check Normal Routing

> **Important:** Traffic Manager is **DNS only**. In this lab, the `*.trafficmanager.net` hostname is **not** bound as a custom domain on either App Service. That means opening the Traffic Manager hostname directly in a browser can show `404 Web Site not found` even when routing is working correctly. Use **DNS resolution** to verify failover, or bind a custom domain to both apps if you want one browser-friendly hostname.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

1. Open the Traffic Manager profile.
2. Confirm both endpoints are **Enabled** and healthy.
3. Copy the Traffic Manager DNS name from **Overview**.
4. Use `nslookup` from your local shell to confirm it resolves to the **primary** app's `azurewebsites.net` hostname.

At this stage, DNS should point at the **primary** app.

---

## Step 10 — Use Chaos Studio to Stop the Primary App

This step intentionally stops the primary app so you can watch Traffic Manager fail over.

> **Permission note:** creating the experiment is not enough. The experiment's system-assigned identity must also receive the **Website Contributor** role on the primary app. That role assignment requires **Owner** or **User Access Administrator** on the scope.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

> **Important:** `$PRIMARY_APP_ID` must be the full App Service **resource ID** from Step 8, not just the app name.

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

### Portal

1. Go to **Subscriptions > Resource providers** and register **Microsoft.Chaos** if it is not already registered.
2. Open **Chaos Studio > Targets** and enable the primary App Service as a target.
3. Enable the **Stop 1.0** capability for that target.
4. Go to **Chaos Studio > Experiments > Create**.
5. Create an experiment named `chaos-stop-primary-app` in the primary region with a **system-assigned identity**.
6. Add the onboarded App Service target and the **App Service Stop 1.0** fault with a duration of **5 minutes**.
7. Before starting the experiment, go to the primary web app's **Access control (IAM)** and grant the experiment identity the **Website Contributor** role.
8. Start the experiment.

---

## Step 11 — Verify Failover to the Secondary App

Traffic Manager failover is not instant. DNS can switch before the endpoint monitor view in the portal catches up.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

1. Open the Chaos experiment and confirm it is running.
2. Open the primary App Service and confirm it is stopped or unhealthy.
3. Open the Traffic Manager profile and watch the endpoint view.
4. Use `nslookup` from a shell to confirm the Traffic Manager DNS name resolves to the **secondary** app.

> **Note:** the Traffic Manager endpoint monitor can remain `Online` for a short time even after DNS has already switched. Treat DNS resolution as the source of truth for this lab.

> **Tip:** If you want a deterministic demo instead of waiting on health probes, temporarily disable the primary endpoint:
>
> ```azurecli
> az network traffic-manager endpoint update \
>   --resource-group "$PRIMARY_RG" \
>   --profile-name "$TM_PROFILE" \
>   --name "primary-swedencentral" \
>   --type azureEndpoints \
>   --endpoint-status Disabled
> ```

---

## Step 12 — Verify Recovery

After the Chaos experiment completes, the primary app should recover and Traffic Manager should return to the primary route.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

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

### PowerShell

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

### Portal

1. Wait for the experiment status to become **Success** or **Completed**.
2. Confirm the primary web app is running again. Start it manually if necessary.
3. Open the Traffic Manager profile and verify both endpoints return to a healthy state.
4. Confirm DNS resolution points back to the **primary** app.

---

## Troubleshooting Notes

- **Traffic Manager URL shows `404 Web Site not found`**  
  That is expected in this lab unless you bind a custom domain on both App Services. Traffic Manager returns DNS answers; it does not rewrite the HTTP host header.

- **PowerShell variables are not Bash variables**  
  Bash uses `PRIMARY_APP_ID=...`. PowerShell uses `$PRIMARY_APP_ID = ...`.

- **`PRIMARY_APP_ID` must be a resource ID**  
  It must look like `/subscriptions/.../resourceGroups/.../providers/Microsoft.Web/sites/<app-name>`, not just `app-dr-swc-xxxxx`.

- **`UnsupportedMediaType` from `az rest`**  
  Add `--headers "Content-Type=application/json"` to the Chaos target and experiment creation calls.

- **Traffic Manager endpoint monitor still says `Online`**  
  Portal and CLI monitor status can lag. If `nslookup` resolves the Traffic Manager DNS name to the secondary app, failover is already working from a client perspective.

- **No manual health-check trigger exists**  
  Traffic Manager probes on its own cadence. For an instant demo, disable the primary endpoint manually.

---

## Validation Checklist

Before moving on, confirm the following:

- [ ] Two App Service plans and two web apps exist in Sweden Central and Norway East
- [ ] Each direct `azurewebsites.net` URL shows hostname and region
- [ ] Traffic Manager profile exists with Priority routing
- [ ] The Traffic Manager DNS name resolves to the primary app during normal operation
- [ ] Chaos Studio successfully stops the primary app, or you simulate the same effect by disabling the primary endpoint
- [ ] During failover, the Traffic Manager DNS name resolves to the secondary app
- [ ] After recovery, the Traffic Manager DNS name resolves back to the primary app

---

## Cleanup

When you are done, delete the lab resources to avoid ongoing charges.

<div class="path-strip">
  <span class="bash">Bash</span>
  <span class="powershell">PowerShell</span>
  <span class="portal">Portal</span>
</div>

### Bash

```bash
az group delete --name "$PRIMARY_RG" --yes --no-wait
az group delete --name "$SECONDARY_RG" --yes --no-wait

rm -rf /tmp/dr-webapp /tmp/dr-webapp.zip /tmp/chaos-experiment.json
```

### PowerShell

```powershell
az group delete --name $PRIMARY_RG --yes --no-wait
az group delete --name $SECONDARY_RG --yes --no-wait

Remove-Item (Join-Path $env:TEMP "dr-webapp") -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $env:TEMP "dr-webapp.zip") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $env:TEMP "chaos-experiment.json") -Force -ErrorAction SilentlyContinue
```

### Portal

1. Go to **Resource groups**.
2. Delete `rg-dr-swc`.
3. Delete `rg-dr-noe`.

---

## Discussion: Design Choices

### Why Traffic Manager and not Azure Front Door?

**Traffic Manager** operates at the DNS layer. It is simple, inexpensive, and a good fit for active-passive failover. **Azure Front Door** operates as an HTTP reverse proxy and adds features like WAF, caching, and SSL offload, but it is more complex and usually costs more.

| Feature | Traffic Manager | Azure Front Door |
|---|---|---|
| Layer | DNS | HTTP |
| Failover speed | 30s-3 min | Near-instant |
| WAF | No | Yes |
| Caching | No | Yes |
| SSL termination | No | Yes |
| Best for | Simple failover | Global reverse proxy |

### Why non-paired regions?

This lab uses **Sweden Central** and **Norway East** to show that multi-region resiliency is not limited to Azure's default region pairs. The same design works with other region combinations that meet your latency, compliance, and capacity requirements.

### Why B1 SKU?

B1 is inexpensive and sufficient for a small lab. For production, you would normally use **S1** or higher for better performance, scaling features, and deployment flexibility.

### Why Chaos Studio?

Stopping the primary app through Chaos Studio lets you test the full failover path in a repeatable way. It is more realistic than manually guessing how an outage might look, and it gives you a foundation for future fault-injection scenarios.

[Next: Lab 2 — Azure Blob Storage Object Replication →](lab-02-blob-storage-replication.md)
