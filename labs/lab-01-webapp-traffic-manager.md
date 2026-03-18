---
layout: default
title: "Lab 1: Multi-Region Web App with Traffic Manager & Chaos Studio"
---

[← Back to Index](../index.md)

# Lab 1: Multi-Region Web App with Traffic Manager & Chaos Studio

## Why Multi-Region Web Apps Matter

Azure App Service is a **regional** service. When you create a web app, it lives in a single Azure datacenter. That's fine for dev/test, but for production workloads it creates a **single point of failure**: if that region goes down — whether due to a datacenter outage, a networking issue, or a platform incident — your application goes down with it.

Multi-region deployment solves this by running your application in two or more Azure regions simultaneously, fronted by a **global load balancer** that can detect failures and redirect traffic automatically. In this lab, you'll use **Azure Traffic Manager** — a DNS-based traffic router — to implement **priority-based failover** between two regions.

By the end of this lab you will have:

- A web app deployed to **two non-paired Azure regions** (Sweden Central and Norway East)
- A **Traffic Manager profile** that routes all traffic to the primary region and automatically fails over to the secondary
- A **Chaos Studio experiment** that deliberately stops your primary app so you can see failover in action

> **Tip:** This pattern is the foundation of most Azure disaster-recovery architectures. Master this, and you'll be well-prepared for more advanced scenarios in the later labs.

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

**How it works:** Users resolve the Traffic Manager DNS name. Traffic Manager health-checks both endpoints and returns the IP of the highest-priority **healthy** endpoint. If the primary goes down, Traffic Manager automatically returns the secondary.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.60 or later. Run `az version` to check. [Install or update](https://learn.microsoft.com/cli/azure/install-azure-cli). |
| **Azure subscription** | With **Contributor** role (or higher) on the subscription or a resource group. |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash on Windows. |
| **Two regions chosen** | This lab defaults to **Sweden Central** and **Norway East**. You can substitute any two regions that support App Service and Traffic Manager. |

> **Tip:** If you're unsure which regions to use, run `az account list-locations --query "[?metadata.regionCategory=='Recommended'].{Name:name, DisplayName:displayName}" -o table` to see recommended regions.

Log in to Azure before you begin:

```azurecli
az login
```

If you have multiple subscriptions, set the one you want to use:

```azurecli
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

---

## Step 1 — Set Shell Variables

Define all the names and regions up front so the rest of the lab is copy-paste friendly.

```azurecli
# Regions
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

# Resource groups
PRIMARY_RG="rg-dr-swc"
SECONDARY_RG="rg-dr-noe"

# App Service plans
PRIMARY_PLAN="plan-dr-swc"
SECONDARY_PLAN="plan-dr-noe"

# Web apps — must be globally unique; add a random suffix if needed
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)
PRIMARY_APP="app-dr-swc-${RANDOM_SUFFIX}"
SECONDARY_APP="app-dr-noe-${RANDOM_SUFFIX}"

# Traffic Manager
TM_PROFILE="tm-multiregion-webapp"
TM_DNS_NAME="tm-multiregion-webapp-${RANDOM_SUFFIX}"

echo "Primary app:   $PRIMARY_APP"
echo "Secondary app: $SECONDARY_APP"
echo "TM DNS name:   $TM_DNS_NAME.trafficmanager.net"
```

> **Tip:** Web app names must be globally unique across all of Azure. The random suffix helps avoid naming collisions. Write down the value of `$RANDOM_SUFFIX` in case your shell session is interrupted.

---

## Step 2 — Create Resource Groups

Create one resource group in each region. Using separate resource groups per region makes cleanup easier and mirrors a real-world isolation pattern.

```azurecli
az group create --name "$PRIMARY_RG"   --location "$PRIMARY_REGION"
az group create --name "$SECONDARY_RG" --location "$SECONDARY_REGION"
```

Verify:

```azurecli
az group list --query "[?starts_with(name,'rg-dr-')].{Name:name, Location:location}" -o table
```

You should see both resource groups listed with their respective regions.

---

## Step 3 — Create App Service Plans

Each region needs its own App Service plan. We'll use the **B1** (Basic) SKU, which is inexpensive but supports custom domains and Traffic Manager integration.

```azurecli
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

> **Why Linux?** Linux App Service plans are generally cheaper and start faster. You can use Windows (`--hyper-v` or omit `--is-linux`) if your workload requires it — the rest of the lab works the same way.

---

## Step 4 — Deploy a Sample Web App to Both Regions

### 4a — Create the web apps

```azurecli
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

### 4b — Deploy an inline HTML page

We'll create a simple HTML page that displays the **region** and **hostname** so you can tell which instance Traffic Manager is routing to.

Create a temporary directory and write the HTML file:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Multi-Region Resiliency Lab</title>
  <style>
    body {
      font-family: 'Segoe UI', system-ui, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #0078d4 0%, #005a9e 100%);
      color: #fff;
    }
    .card {
      background: rgba(255,255,255,0.15);
      backdrop-filter: blur(10px);
      border-radius: 16px;
      padding: 3rem;
      text-align: center;
      max-width: 600px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.2);
    }
    h1 { margin-top: 0; font-size: 1.8rem; }
    .info { font-size: 1.2rem; margin: 1rem 0; }
    .label { opacity: 0.8; font-size: 0.9rem; }
    .value { font-weight: bold; font-size: 1.4rem; }
    .status { color: #7fff7f; font-weight: bold; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🌍 Multi-Region Resiliency Lab</h1>
    <div class="info">
      <div class="label">Hostname</div>
      <div class="value" id="hostname">Loading...</div>
    </div>
    <div class="info">
      <div class="label">Region (from WEBSITE_SITE_NAME)</div>
      <div class="value" id="region">Loading...</div>
    </div>
    <div class="info">
      <div class="label">Timestamp</div>
      <div class="value" id="timestamp">Loading...</div>
    </div>
    <p class="status">✅ This instance is healthy</p>
  </div>
  <script>
    document.getElementById('hostname').textContent = location.hostname;
    document.getElementById('region').textContent =
      location.hostname.includes('swc') ? 'Sweden Central (Primary)' :
      location.hostname.includes('noe') ? 'Norway East (Secondary)' :
      location.hostname;
    document.getElementById('timestamp').textContent = new Date().toISOString();
  </script>
</body>
</html>
```

Save this as `index.html`, then package and deploy to **both** apps:

```azurecli
mkdir -p /tmp/dr-webapp
# (paste the HTML above into /tmp/dr-webapp/index.html, or use cat << 'EOF' > ... EOF)

cd /tmp/dr-webapp
zip -r /tmp/dr-webapp.zip .

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

---

## Step 5 — Verify Both Apps Respond

Check that each app is running independently before wiring them up to Traffic Manager.

```azurecli
echo "--- Primary (Sweden Central) ---"
curl -s "https://${PRIMARY_APP}.azurewebsites.net" | head -5

echo ""
echo "--- Secondary (Norway East) ---"
curl -s "https://${SECONDARY_APP}.azurewebsites.net" | head -5
```

You should see the HTML from your `index.html` returned by each app. You can also open the URLs in a browser:

```azurecli
echo "Primary:   https://${PRIMARY_APP}.azurewebsites.net"
echo "Secondary: https://${SECONDARY_APP}.azurewebsites.net"
```

> **Tip:** If you get a `403` or a default Azure page, wait 30–60 seconds for the deployment to propagate and try again.

---

## Step 6 — Create a Traffic Manager Profile

[Azure Traffic Manager](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-overview) is a DNS-based global traffic router. We'll configure it with **Priority** routing, which always sends traffic to the highest-priority healthy endpoint.

```azurecli
az network traffic-manager profile create \
  --name "$TM_PROFILE" \
  --resource-group "$PRIMARY_RG" \
  --routing-method Priority \
  --unique-dns-name "$TM_DNS_NAME" \
  --monitor-protocol HTTPS \
  --monitor-port 443 \
  --monitor-path "/" \
  --ttl 30
```

Key parameters explained:

| Parameter | Value | Why |
|---|---|---|
| `--routing-method Priority` | Priority-based | Always routes to the highest-priority healthy endpoint |
| `--monitor-protocol HTTPS` | HTTPS | Health checks use HTTPS for realistic probing |
| `--monitor-path "/"` | Root path | Traffic Manager will `GET /` to check health |
| `--ttl 30` | 30 seconds | Low TTL for faster failover during the lab (production might use 60–300) |

Verify the profile:

```azurecli
az network traffic-manager profile show \
  --name "$TM_PROFILE" \
  --resource-group "$PRIMARY_RG" \
  --query "{Name:name, DNS:dnsConfig.fqdn, Routing:trafficRoutingMethod, Status:profileStatus}" \
  -o table
```

---

## Step 7 — Add the Primary Endpoint (Priority 1)

Get the resource ID of the primary web app, then add it as a Traffic Manager endpoint with priority **1** (highest).

```azurecli
PRIMARY_APP_ID=$(az webapp show \
  --name "$PRIMARY_APP" \
  --resource-group "$PRIMARY_RG" \
  --query "id" -o tsv)

az network traffic-manager endpoint create \
  --name "primary-swedencentral" \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --type azureEndpoints \
  --target-resource-id "$PRIMARY_APP_ID" \
  --priority 1 \
  --endpoint-status Enabled
```

---

## Step 8 — Add the Secondary Endpoint (Priority 2)

Repeat for the secondary web app with priority **2**.

```azurecli
SECONDARY_APP_ID=$(az webapp show \
  --name "$SECONDARY_APP" \
  --resource-group "$SECONDARY_RG" \
  --query "id" -o tsv)

az network traffic-manager endpoint create \
  --name "secondary-norwayeast" \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --type azureEndpoints \
  --target-resource-id "$SECONDARY_APP_ID" \
  --priority 2 \
  --endpoint-status Enabled
```

Verify both endpoints are online:

```azurecli
az network traffic-manager endpoint list \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --query "[].{Name:name, Priority:priority, Status:endpointStatus, Monitor:endpointMonitorStatus}" \
  -o table
```

You should see both endpoints with status **Enabled** and monitor status **Online**.

---

## Step 9 — Test Traffic Manager Routing

Open the Traffic Manager URL in your browser or use `curl`:

```azurecli
TM_FQDN="${TM_DNS_NAME}.trafficmanager.net"
echo "Traffic Manager URL: https://${TM_FQDN}"

curl -s "https://${TM_FQDN}" | head -20
```

The page should show **Sweden Central (Primary)** as the region, because priority 1 is healthy.

You can also check which endpoint Traffic Manager is resolving to via DNS:

```azurecli
nslookup "$TM_FQDN"
```

> **Tip:** DNS results may be cached by your local resolver. If you see stale results, try `dig` with `+trace` or use a different DNS resolver (e.g., `nslookup $TM_FQDN 8.8.8.8`).

---

## Step 10 — Chaos Studio: Simulate a Regional Failure

Now the fun part! We'll use [Azure Chaos Studio](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-overview) to deliberately **stop** the primary web app and watch Traffic Manager fail over to the secondary.

> ⚠️ **Caution:** Running Chaos experiments will actually stop your web app — ensure you're okay with the app being offline for a few minutes. This is a lab environment, so it's expected!

### 10a — Register the Chaos Studio provider

If you haven't used Chaos Studio before, register the provider:

```azurecli
az provider register --namespace Microsoft.Chaos --wait
```

Check registration status:

```azurecli
az provider show --namespace Microsoft.Chaos --query "registrationState" -o tsv
```

Wait until it shows `Registered` (this can take 1–2 minutes).

### 10b — Onboard the primary App Service as a Chaos target

Chaos Studio needs to know which resources it can inject faults into. We onboard the primary web app as a **target** and enable the **Stop** capability.

```azurecli
# Enable the Chaos target on the primary web app
az rest --method put \
  --url "https://management.azure.com${PRIMARY_APP_ID}/providers/Microsoft.Chaos/targets/Microsoft-AppService?api-version=2024-01-01" \
  --body '{"properties":{}}'
```

Now enable the **Stop** capability on that target:

```azurecli
az rest --method put \
  --url "https://management.azure.com${PRIMARY_APP_ID}/providers/Microsoft.Chaos/targets/Microsoft-AppService/capabilities/Stop-1.0?api-version=2024-01-01" \
  --body '{"properties":{}}'
```

### 10c — Create the Chaos experiment

First, get your current subscription ID:

```azurecli
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
```

Create the experiment definition JSON:

```json
{
  "location": "<PRIMARY_REGION>",
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
            "id": "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<PRIMARY_RG>/providers/Microsoft.Web/sites/<PRIMARY_APP>/providers/Microsoft.Chaos/targets/Microsoft-AppService"
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
```

Save the file with variable substitution and create the experiment:

```azurecli
cat > /tmp/chaos-experiment.json << JSONEOF
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

EXPERIMENT_NAME="chaos-stop-primary-app"

az rest --method put \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Chaos/experiments/${EXPERIMENT_NAME}?api-version=2024-01-01" \
  --body @/tmp/chaos-experiment.json
```

This experiment will stop the primary App Service for **5 minutes** (`PT5M`).

### 10d — Assign permissions to the experiment

The experiment's managed identity needs **Website Contributor** access to the primary web app so it can stop it.

```azurecli
# Get the experiment's managed identity principal ID
EXPERIMENT_PRINCIPAL_ID=$(az rest --method get \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Chaos/experiments/${EXPERIMENT_NAME}?api-version=2024-01-01" \
  --query "identity.principalId" -o tsv)

echo "Experiment Principal ID: $EXPERIMENT_PRINCIPAL_ID"

# Assign the Website Contributor role on the primary web app
az role assignment create \
  --assignee-object-id "$EXPERIMENT_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Website Contributor" \
  --scope "$PRIMARY_APP_ID"
```

> **Tip:** It can take 1–2 minutes for the role assignment to propagate. If the experiment fails immediately, wait a moment and try starting it again.

### 10e — Start the Chaos experiment

```azurecli
az rest --method post \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Chaos/experiments/${EXPERIMENT_NAME}/start?api-version=2024-01-01"
```

Monitor the experiment status:

```azurecli
az rest --method get \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Chaos/experiments/${EXPERIMENT_NAME}/statuses?api-version=2024-01-01" \
  --query "value[0].{Status:properties.status, CreatedAt:properties.createdDateUtc}" \
  -o table
```

---

## Step 11 — Verify Failover to Secondary

Once the experiment starts and the primary app is stopped, Traffic Manager will detect the health check failure and begin routing to the secondary endpoint.

> **Note:** Failover is not instant. Traffic Manager needs to detect the failure (based on its probing interval) and DNS caches need to expire (we set TTL to 30 seconds). Allow **1–3 minutes** for full failover.

### 11a — Check endpoint health

```azurecli
az network traffic-manager endpoint list \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" \
  -o table
```

You should see:

| Name | Priority | MonitorStatus |
|---|---|---|
| primary-swedencentral | 1 | **Degraded** |
| secondary-norwayeast | 2 | Online |

### 11b — Test the Traffic Manager URL

```azurecli
curl -s "https://${TM_FQDN}" | grep -i "norway\|secondary\|hostname"
```

The page should now show **Norway East (Secondary)** — Traffic Manager has failed over! 🎉

### 11c — Watch the primary app directly

```azurecli
curl -s -o /dev/null -w "%{http_code}" "https://${PRIMARY_APP}.azurewebsites.net"
```

You should get a `403` or connection error, confirming the primary is stopped.

---

## Step 12 — Verify Recovery

After the 5-minute experiment completes, the primary App Service will automatically restart. Traffic Manager will detect it as healthy again and route traffic back.

### 12a — Check experiment status

```azurecli
az rest --method get \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PRIMARY_RG}/providers/Microsoft.Chaos/experiments/${EXPERIMENT_NAME}/statuses?api-version=2024-01-01" \
  --query "value[0].properties.status" -o tsv
```

Wait until status is `Success`.

### 12b — Verify the primary is back

```azurecli
# You may need to start the app manually if it doesn't auto-restart
az webapp start --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG"

# Wait a moment, then check
sleep 30

curl -s -o /dev/null -w "%{http_code}" "https://${PRIMARY_APP}.azurewebsites.net"
```

You should get a `200`.

### 12c — Confirm Traffic Manager re-routes to primary

```azurecli
az network traffic-manager endpoint list \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --query "[].{Name:name, Priority:priority, MonitorStatus:endpointMonitorStatus}" \
  -o table
```

Both endpoints should be **Online** again. Curl the Traffic Manager URL:

```azurecli
curl -s "https://${TM_FQDN}" | grep -i "sweden\|primary\|hostname"
```

Traffic should be back on **Sweden Central (Primary)**. The full cycle — normal operation → failure → failover → recovery — is complete! ✅

---

## Validation Checklist

Before moving on, confirm you've achieved the following:

- [ ] Two web apps are deployed in separate regions (Sweden Central and Norway East)
- [ ] Both apps return a page showing their region and hostname
- [ ] Traffic Manager profile is created with Priority routing
- [ ] Traffic Manager routes to the primary (Sweden Central) under normal conditions
- [ ] Chaos Studio experiment successfully stopped the primary app
- [ ] During the outage, Traffic Manager routed to the secondary (Norway East)
- [ ] After recovery, Traffic Manager returned to the primary

---

## Cleanup

When you're done with the lab, delete all resources to avoid ongoing charges.

```azurecli
# Delete resource groups (this deletes everything inside them)
az group delete --name "$PRIMARY_RG" --yes --no-wait
az group delete --name "$SECONDARY_RG" --yes --no-wait
```

> **Tip:** The `--no-wait` flag returns immediately while deletion happens in the background. Full cleanup can take 5–10 minutes.

Verify deletion is in progress:

```azurecli
az group list --query "[?starts_with(name,'rg-dr-')].{Name:name, State:properties.provisioningState}" -o table
```

Clean up local temp files:

```azurecli
rm -rf /tmp/dr-webapp /tmp/dr-webapp.zip /tmp/chaos-experiment.json
```

---

## Discussion: Design Choices

### Why Traffic Manager and not Azure Front Door?

**Traffic Manager** operates at the DNS layer (Layer 7 DNS resolution). It's simple, cheap, and works well for active-passive failover. **Azure Front Door** operates at Layer 7 (HTTP) and provides additional features like WAF, caching, and SSL offloading — but it's more complex and more expensive. For a basic failover scenario, Traffic Manager is often the right choice.

| Feature | Traffic Manager | Azure Front Door |
|---|---|---|
| Layer | DNS (L7 DNS) | HTTP (L7) |
| Failover speed | 30s–3 min (DNS TTL) | Near-instant |
| WAF | ❌ | ✅ |
| Caching | ❌ | ✅ |
| SSL termination | ❌ | ✅ |
| Cost | Low | Higher |
| Best for | Simple failover | Full reverse proxy |

### Why non-paired regions?

Azure has [paired regions](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure#azure-paired-regions) that receive coordinated platform updates and recovery priority. However, **not all regions have pairs**, and Azure is moving toward a model where customers choose their own region combinations. This lab deliberately uses **non-paired regions** (Sweden Central and Norway East) to demonstrate that multi-region resiliency works regardless of pairing.

### Why B1 SKU?

The B1 (Basic) tier is the cheapest SKU that supports:
- Custom domains
- Traffic Manager integration
- Always-on (optional)

For production, you'd typically use **S1** or **P1v3** for better performance and features like deployment slots.

### Why Chaos Studio?

Manual testing of disaster recovery is unreliable — people forget, skip steps, or test in unrealistic conditions. **Chaos engineering** (also called fault injection) deliberately introduces failures so you can observe how your system responds under controlled conditions. Azure Chaos Studio is a managed service that integrates directly with Azure resources, making it easy to run repeatable experiments.

> **Feel free to try adding a third region!** You could add a West Europe or UK South web app as a Priority 3 endpoint and see how Traffic Manager handles a two-region failure. The commands are the same — just add another resource group, plan, app, and Traffic Manager endpoint.

---

## Further Reading

- [Azure Traffic Manager Overview — Microsoft Learn](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-overview)
- [Azure Chaos Studio Overview — Microsoft Learn](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-overview)
- [Traffic Manager Routing Methods](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-routing-methods)
- [Chaos Studio Fault Library](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library)
- [Azure App Service Overview](https://learn.microsoft.com/azure/app-service/overview)
- [Azure Reliability — Cross-Region Replication](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure)

---

[Next: Lab 2 — Azure Blob Storage Object Replication →](lab-02-blob-storage-replication.md)
