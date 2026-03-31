---
layout: default
title: "Lab 12: AKS Multi-Cluster – Global Routing with Fleet, ACR, and Front Door"
---

[← Back to Index](../index.md)

# Lab 12: AKS Multi-Cluster – Global Routing with Fleet, ACR, and Front Door

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

> **Deploy two regional AKS clusters, coordinate them with Azure Kubernetes Fleet Manager, publish a geo-replicated image through ACR, and validate global routing with Azure Front Door.**

<div class="lab-note">
  <strong>Architecture simplification:</strong> The Azure Architecture Center reference uses regional ingress layers in front of AKS. To keep the lab approachable, the hands-on flow below routes Front Door directly to each cluster's public load balancer service while still preserving the multi-cluster, multi-region, and geo-replicated image patterns.
</div>

---

## Why Multi-Cluster AKS Matters

A single AKS cluster can still be a regional blast radius. The reference architecture for multi-region AKS is about more than just having another cluster — it combines:

- **Two independent regional clusters**
- **A shared image supply chain** through geo-replicated ACR
- **A coordination plane** through Azure Kubernetes Fleet Manager
- **A global entry point** through Azure Front Door

This lab walks through the same pattern in a compact form so you can see how the building blocks fit together.

---

## Architecture

```
                         ┌──────────────────────────────┐
                         │   Azure Front Door          │
                         │   Global endpoint           │
                         └────────────┬────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    │                                   │
          ┌─────────▼─────────┐               ┌─────────▼─────────┐
          │ AKS - Sweden      │               │ AKS - Norway      │
          │ Regional app      │               │ Regional app      │
          │ LoadBalancer svc  │               │ LoadBalancer svc  │
          └─────────┬─────────┘               └─────────┬─────────┘
                    │                                   │
                    └───────────────┬───────────────────┘
                                    │
                         ┌──────────▼──────────┐
                         │ Azure Kubernetes    │
                         │ Fleet Manager       │
                         └──────────┬──────────┘
                                    │
                         ┌──────────▼──────────┐
                         │ Geo-replicated ACR  │
                         │ Push once, pull     │
                         │ from both regions   │
                         └─────────────────────┘
```

---

## Prerequisites

- Azure CLI 2.61+ with permissions to create AKS, ACR, Front Door, and Fleet resources
- `kubectl` installed locally (`az aks install-cli` works well)
- Enough quota for two AKS clusters and a Premium Azure Container Registry
- Comfort with waiting for cluster, load balancer, and Front Door provisioning to complete

---
## Step 1 — Install extensions, kubectl, and set variables

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az extension add --name fleet
az aks install-cli

SUFFIX=$(openssl rand -hex 2)

LOCATION_PRIMARY=swedencentral
LOCATION_SECONDARY=norwayeast

RG_GLOBAL="rg-aks-global-$SUFFIX"
RG_PRIMARY="rg-aks-swc-$SUFFIX"
RG_SECONDARY="rg-aks-noe-$SUFFIX"

ACR_NAME="aksmr${SUFFIX}acr"
PRIMARY_CLUSTER="aks-swc-$SUFFIX"
SECONDARY_CLUSTER="aks-noe-$SUFFIX"
FLEET_NAME="fleet-aks-$SUFFIX"
AFD_PROFILE="afd-aks-$SUFFIX"
AFD_ENDPOINT="aksdr-$SUFFIX"
ORIGIN_GROUP="og-aks-app"
NAMESPACE="multiregion-demo"
APP_NAME="regional-app"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az extension add --name fleet
az aks install-cli

$Suffix = -join ((48..57 + 97..122 | Get-Random -Count 4 | ForEach-Object { [char]$_ }))

$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"

$RG_GLOBAL = "rg-aks-global-$Suffix"
$RG_PRIMARY = "rg-aks-swc-$Suffix"
$RG_SECONDARY = "rg-aks-noe-$Suffix"

$ACR_NAME = "aksmr${Suffix}acr"
$PRIMARY_CLUSTER = "aks-swc-$Suffix"
$SECONDARY_CLUSTER = "aks-noe-$Suffix"
$FLEET_NAME = "fleet-aks-$Suffix"
$AFD_PROFILE = "afd-aks-$Suffix"
$AFD_ENDPOINT = "aksdr-$Suffix"
$ORIGIN_GROUP = "og-aks-app"
$NAMESPACE = "multiregion-demo"
$APP_NAME = "regional-app"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Install the **fleet** extension and confirm `kubectl` is available.
2. Pick a short suffix so your ACR, Fleet, Front Door, and cluster names remain unique.
3. Use **Sweden Central** as the primary region and **Norway East** as the secondary region to match the rest of the lab series.

  </div>
</div>

## Step 2 — Create resource groups, ACR, and the regional app image

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name "$RG_GLOBAL" --location "$LOCATION_PRIMARY"
az group create --name "$RG_PRIMARY" --location "$LOCATION_PRIMARY"
az group create --name "$RG_SECONDARY" --location "$LOCATION_SECONDARY"

az acr create   --name "$ACR_NAME"   --resource-group "$RG_GLOBAL"   --location "$LOCATION_PRIMARY"   --sku Premium

az acr replication create   --registry "$ACR_NAME"   --location "$LOCATION_SECONDARY"

mkdir -p /tmp/aks-multiregion-app
cat > /tmp/aks-multiregion-app/Dockerfile <<'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
EOF

cat > /tmp/aks-multiregion-app/app.py <<'EOF'
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

APP_REGION = os.getenv("APP_REGION", "unknown")

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"Hello from {APP_REGION}\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body.encode())

HTTPServer(("", 8080), Handler).serve_forever()
EOF

az acr build   --registry "$ACR_NAME"   --image regional-app:v1   /tmp/aks-multiregion-app

rm -rf /tmp/aks-multiregion-app
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_GLOBAL --location $LOCATION_PRIMARY | Out-Null
az group create --name $RG_PRIMARY --location $LOCATION_PRIMARY | Out-Null
az group create --name $RG_SECONDARY --location $LOCATION_SECONDARY | Out-Null

az acr create `
  --name $ACR_NAME `
  --resource-group $RG_GLOBAL `
  --location $LOCATION_PRIMARY `
  --sku Premium | Out-Null

az acr replication create `
  --registry $ACR_NAME `
  --location $LOCATION_SECONDARY | Out-Null

$BuildPath = Join-Path $env:TEMP "aks-multiregion-app"
New-Item -ItemType Directory -Path $BuildPath -Force | Out-Null

@'
FROM python:3.12-alpine
WORKDIR /app
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
'@ | Set-Content -Path (Join-Path $BuildPath 'Dockerfile') -NoNewline

@'
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

APP_REGION = os.getenv("APP_REGION", "unknown")

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"Hello from {APP_REGION}\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body.encode())

HTTPServer(("", 8080), Handler).serve_forever()
'@ | Set-Content -Path (Join-Path $BuildPath 'app.py') -NoNewline

az acr build `
  --registry $ACR_NAME `
  --image regional-app:v1 `
  $BuildPath | Out-Null

Remove-Item -Path $BuildPath -Recurse -Force
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create one global resource group plus one regional resource group for each cluster.
2. Create a **Premium** Azure Container Registry in the global resource group.
3. Add a Norway East geo-replica to the registry.
4. Build a tiny HTTP image through **ACR Tasks** so both clusters can pull the same artifact from the same registry name.

  </div>
</div>

## Step 3 — Create the two AKS clusters and attach ACR

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
ACR_ID=$(az acr show --resource-group "$RG_GLOBAL" --name "$ACR_NAME" --query id --output tsv)

az aks create   --resource-group "$RG_PRIMARY"   --name "$PRIMARY_CLUSTER"   --location "$LOCATION_PRIMARY"   --node-count 1   --node-vm-size Standard_B2s   --enable-managed-identity   --attach-acr "$ACR_ID"   --generate-ssh-keys

az aks create   --resource-group "$RG_SECONDARY"   --name "$SECONDARY_CLUSTER"   --location "$LOCATION_SECONDARY"   --node-count 1   --node-vm-size Standard_B2s   --enable-managed-identity   --attach-acr "$ACR_ID"   --generate-ssh-keys
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$ACR_ID = az acr show --resource-group $RG_GLOBAL --name $ACR_NAME --query id --output tsv

az aks create `
  --resource-group $RG_PRIMARY `
  --name $PRIMARY_CLUSTER `
  --location $LOCATION_PRIMARY `
  --node-count 1 `
  --node-vm-size Standard_B2s `
  --enable-managed-identity `
  --attach-acr $ACR_ID `
  --generate-ssh-keys | Out-Null

az aks create `
  --resource-group $RG_SECONDARY `
  --name $SECONDARY_CLUSTER `
  --location $LOCATION_SECONDARY `
  --node-count 1 `
  --node-vm-size Standard_B2s `
  --enable-managed-identity `
  --attach-acr $ACR_ID `
  --generate-ssh-keys | Out-Null
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create one AKS cluster in **Sweden Central** and one in **Norway East**.
2. Attach the same Premium ACR to both clusters.
3. This lab uses compact single-node clusters to keep the hands-on flow approachable. In production, use zone-spanning node pools and multiple replicas per region.

  </div>
</div>

## Step 4 — Create a Fleet and join both clusters

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_CLUSTER_ID=$(az aks show --resource-group "$RG_PRIMARY" --name "$PRIMARY_CLUSTER" --query id --output tsv)
SECONDARY_CLUSTER_ID=$(az aks show --resource-group "$RG_SECONDARY" --name "$SECONDARY_CLUSTER" --query id --output tsv)

az fleet create   --resource-group "$RG_GLOBAL"   --location "$LOCATION_PRIMARY"   --name "$FLEET_NAME"   --enable-managed-identity

az fleet member create   --resource-group "$RG_GLOBAL"   --fleet-name "$FLEET_NAME"   --name "$PRIMARY_CLUSTER"   --member-cluster-id "$PRIMARY_CLUSTER_ID"   --labels region=swc role=primary   --update-group blue

az fleet member create   --resource-group "$RG_GLOBAL"   --fleet-name "$FLEET_NAME"   --name "$SECONDARY_CLUSTER"   --member-cluster-id "$SECONDARY_CLUSTER_ID"   --labels region=noe role=secondary   --update-group green

az fleet member list   --resource-group "$RG_GLOBAL"   --fleet-name "$FLEET_NAME"   --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_CLUSTER_ID = az aks show --resource-group $RG_PRIMARY --name $PRIMARY_CLUSTER --query id --output tsv
$SECONDARY_CLUSTER_ID = az aks show --resource-group $RG_SECONDARY --name $SECONDARY_CLUSTER --query id --output tsv

az fleet create `
  --resource-group $RG_GLOBAL `
  --location $LOCATION_PRIMARY `
  --name $FLEET_NAME `
  --enable-managed-identity | Out-Null

az fleet member create `
  --resource-group $RG_GLOBAL `
  --fleet-name $FLEET_NAME `
  --name $PRIMARY_CLUSTER `
  --member-cluster-id $PRIMARY_CLUSTER_ID `
  --labels region=swc role=primary `
  --update-group blue | Out-Null

az fleet member create `
  --resource-group $RG_GLOBAL `
  --fleet-name $FLEET_NAME `
  --name $SECONDARY_CLUSTER `
  --member-cluster-id $SECONDARY_CLUSTER_ID `
  --labels region=noe role=secondary `
  --update-group green | Out-Null

az fleet member list `
  --resource-group $RG_GLOBAL `
  --fleet-name $FLEET_NAME `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create a Fleet resource in the global resource group.
2. Add both AKS clusters as fleet members.
3. Label the members so you can reason about region and role later.
4. Confirm the fleet sees both members before you deploy the workload.

  </div>
</div>

## Step 5 — Deploy the regional workload to both clusters

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
REGISTRY_FQDN=$(az acr show --resource-group "$RG_GLOBAL" --name "$ACR_NAME" --query loginServer --output tsv)
PRIMARY_CONTEXT="$PRIMARY_CLUSTER-ctx"
SECONDARY_CONTEXT="$SECONDARY_CLUSTER-ctx"

az aks get-credentials --resource-group "$RG_PRIMARY" --name "$PRIMARY_CLUSTER" --context "$PRIMARY_CONTEXT" --overwrite-existing
az aks get-credentials --resource-group "$RG_SECONDARY" --name "$SECONDARY_CLUSTER" --context "$SECONDARY_CONTEXT" --overwrite-existing

cat <<EOF | kubectl --context "$PRIMARY_CONTEXT" apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: web
        image: $REGISTRY_FQDN/regional-app:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        env:
        - name: APP_REGION
          value: Sweden Central
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  type: LoadBalancer
  selector:
    app: $APP_NAME
  ports:
  - port: 80
    targetPort: 8080
EOF

cat <<EOF | kubectl --context "$SECONDARY_CONTEXT" apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: web
        image: $REGISTRY_FQDN/regional-app:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        env:
        - name: APP_REGION
          value: Norway East
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  type: LoadBalancer
  selector:
    app: $APP_NAME
  ports:
  - port: 80
    targetPort: 8080
EOF

PRIMARY_IP=""
until [[ -n "$PRIMARY_IP" ]]; do
  PRIMARY_IP=$(kubectl --context "$PRIMARY_CONTEXT" --namespace "$NAMESPACE" get svc "$APP_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  sleep 10
done

SECONDARY_IP=""
until [[ -n "$SECONDARY_IP" ]]; do
  SECONDARY_IP=$(kubectl --context "$SECONDARY_CONTEXT" --namespace "$NAMESPACE" get svc "$APP_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  sleep 10
done

curl -s "http://$PRIMARY_IP"
curl -s "http://$SECONDARY_IP"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$REGISTRY_FQDN = az acr show --resource-group $RG_GLOBAL --name $ACR_NAME --query loginServer --output tsv
$PRIMARY_CONTEXT = "$PRIMARY_CLUSTER-ctx"
$SECONDARY_CONTEXT = "$SECONDARY_CLUSTER-ctx"

az aks get-credentials --resource-group $RG_PRIMARY --name $PRIMARY_CLUSTER --context $PRIMARY_CONTEXT --overwrite-existing | Out-Null
az aks get-credentials --resource-group $RG_SECONDARY --name $SECONDARY_CLUSTER --context $SECONDARY_CONTEXT --overwrite-existing | Out-Null

$PrimaryManifest = @"
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: web
        image: $REGISTRY_FQDN/regional-app:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        env:
        - name: APP_REGION
          value: Sweden Central
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  type: LoadBalancer
  selector:
    app: $APP_NAME
  ports:
  - port: 80
    targetPort: 8080
"@

$SecondaryManifest = $PrimaryManifest -replace 'Sweden Central', 'Norway East'

$PrimaryFile = Join-Path $env:TEMP 'aks-primary.yaml'
$SecondaryFile = Join-Path $env:TEMP 'aks-secondary.yaml'
$PrimaryManifest | Set-Content -Path $PrimaryFile
$SecondaryManifest | Set-Content -Path $SecondaryFile

kubectl --context $PRIMARY_CONTEXT apply -f $PrimaryFile
kubectl --context $SECONDARY_CONTEXT apply -f $SecondaryFile

$PRIMARY_IP = ''
while (-not $PRIMARY_IP) {
  $PRIMARY_IP = kubectl --context $PRIMARY_CONTEXT --namespace $NAMESPACE get svc $APP_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
  Start-Sleep -Seconds 10
}

$SECONDARY_IP = ''
while (-not $SECONDARY_IP) {
  $SECONDARY_IP = kubectl --context $SECONDARY_CONTEXT --namespace $NAMESPACE get svc $APP_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
  Start-Sleep -Seconds 10
}

(Invoke-WebRequest -Uri "http://$PRIMARY_IP" -UseBasicParsing).Content
(Invoke-WebRequest -Uri "http://$SECONDARY_IP" -UseBasicParsing).Content

Remove-Item $PrimaryFile, $SecondaryFile -Force
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open each AKS cluster in the portal.
2. Use **Run command** or your preferred Kubernetes management tool to deploy the same application to both clusters.
3. Set the environment variable to **Sweden Central** in one cluster and **Norway East** in the other.
4. Expose the app through a public **LoadBalancer** service in each region.
5. Confirm both public IPs respond before you add the global entry point.

  </div>
</div>

## Step 6 — Put Azure Front Door in front of both regions

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az afd profile create   --resource-group "$RG_GLOBAL"   --profile-name "$AFD_PROFILE"   --sku Standard_AzureFrontDoor

az afd endpoint create   --resource-group "$RG_GLOBAL"   --profile-name "$AFD_PROFILE"   --endpoint-name "$AFD_ENDPOINT"   --enabled-state Enabled

az afd origin-group create   --resource-group "$RG_GLOBAL"   --profile-name "$AFD_PROFILE"   --origin-group-name "$ORIGIN_GROUP"   --enable-health-probe true   --probe-path /   --probe-request-type GET   --probe-protocol Http   --probe-interval-in-seconds 30   --sample-size 4   --successful-samples-required 3

az afd origin create   --resource-group "$RG_GLOBAL"   --profile-name "$AFD_PROFILE"   --origin-group-name "$ORIGIN_GROUP"   --origin-name origin-swc   --host-name "$PRIMARY_IP"   --origin-host-header "$PRIMARY_IP"   --http-port 80   --priority 1   --weight 500   --enabled-state Enabled

az afd origin create   --resource-group "$RG_GLOBAL"   --profile-name "$AFD_PROFILE"   --origin-group-name "$ORIGIN_GROUP"   --origin-name origin-noe   --host-name "$SECONDARY_IP"   --origin-host-header "$SECONDARY_IP"   --http-port 80   --priority 1   --weight 500   --enabled-state Enabled

az afd route create   --resource-group "$RG_GLOBAL"   --profile-name "$AFD_PROFILE"   --endpoint-name "$AFD_ENDPOINT"   --route-name route-default   --origin-group "$ORIGIN_GROUP"   --patterns-to-match '/*'   --supported-protocols Http Https   --forwarding-protocol HttpOnly   --https-redirect Disabled   --link-to-default-domain Enabled

AFD_HOST=$(az afd endpoint show   --resource-group "$RG_GLOBAL"   --profile-name "$AFD_PROFILE"   --endpoint-name "$AFD_ENDPOINT"   --query hostName   --output tsv)

curl -s "http://$AFD_HOST"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az afd profile create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --sku Standard_AzureFrontDoor | Out-Null

az afd endpoint create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --endpoint-name $AFD_ENDPOINT `
  --enabled-state Enabled | Out-Null

az afd origin-group create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --origin-group-name $ORIGIN_GROUP `
  --enable-health-probe true `
  --probe-path / `
  --probe-request-type GET `
  --probe-protocol Http `
  --probe-interval-in-seconds 30 `
  --sample-size 4 `
  --successful-samples-required 3 | Out-Null

az afd origin create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --origin-group-name $ORIGIN_GROUP `
  --origin-name origin-swc `
  --host-name $PRIMARY_IP `
  --origin-host-header $PRIMARY_IP `
  --http-port 80 `
  --priority 1 `
  --weight 500 `
  --enabled-state Enabled | Out-Null

az afd origin create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --origin-group-name $ORIGIN_GROUP `
  --origin-name origin-noe `
  --host-name $SECONDARY_IP `
  --origin-host-header $SECONDARY_IP `
  --http-port 80 `
  --priority 1 `
  --weight 500 `
  --enabled-state Enabled | Out-Null

az afd route create `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --endpoint-name $AFD_ENDPOINT `
  --route-name route-default `
  --origin-group $ORIGIN_GROUP `
  --patterns-to-match '/*' `
  --supported-protocols Http Https `
  --forwarding-protocol HttpOnly `
  --https-redirect Disabled `
  --link-to-default-domain Enabled | Out-Null

$AFD_HOST = az afd endpoint show `
  --resource-group $RG_GLOBAL `
  --profile-name $AFD_PROFILE `
  --endpoint-name $AFD_ENDPOINT `
  --query hostName `
  --output tsv

(Invoke-WebRequest -Uri "http://$AFD_HOST" -UseBasicParsing).Content
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create an **Azure Front Door Standard** profile and endpoint.
2. Add one origin group with health probes against `/`.
3. Add the Sweden Central and Norway East service IPs as origins with equal priority and weight.
4. Create a route that links the default Front Door domain to the origin group.
5. Validate that the Front Door hostname returns one of the regional responses.

  </div>
</div>

## Step 7 — Simulate a regional failure and watch global routing react

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
kubectl --context "$PRIMARY_CONTEXT" --namespace "$NAMESPACE" scale deployment "$APP_NAME" --replicas=0

for attempt in {1..12}; do
  echo "Attempt $attempt"
  curl -s "http://$AFD_HOST"
  sleep 20
done

kubectl --context "$PRIMARY_CONTEXT" --namespace "$NAMESPACE" scale deployment "$APP_NAME" --replicas=2
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
kubectl --context $PRIMARY_CONTEXT --namespace $NAMESPACE scale deployment $APP_NAME --replicas=0

1..12 | ForEach-Object {
  Write-Host "Attempt $_"
  (Invoke-WebRequest -Uri "http://$AFD_HOST" -UseBasicParsing).Content
  Start-Sleep -Seconds 20
}

kubectl --context $PRIMARY_CONTEXT --namespace $NAMESPACE scale deployment $APP_NAME --replicas=2
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Scale the Sweden Central deployment down to zero replicas or mark that origin unhealthy.
2. Refresh the Front Door hostname until the response shifts to **Norway East**.
3. Restore the primary deployment after the drill so both regions are healthy again.
4. In a production design, Front Door would typically route to a regional ingress layer rather than directly to the service IP.

  </div>
</div>

## Step 8 — Cleanup

Deleting the AKS resource groups will also remove the managed `MC_*` infrastructure groups after the cluster delete operation completes.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name "$RG_GLOBAL" --yes --no-wait
az group delete --name "$RG_PRIMARY" --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_GLOBAL --yes --no-wait
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Delete the global resource group that contains Front Door, Fleet, and ACR.
2. Delete both AKS regional resource groups.
3. Wait for the managed cluster cleanup to remove the related `MC_*` resource groups automatically.

  </div>
</div>
---

## Key Takeaways

1. **Multi-region AKS is a platform pattern, not a single resource toggle.** You need independent clusters, image distribution, and global routing together.
2. **Fleet gives you coordination, not shared fate.** Each cluster still fails and recovers independently.
3. **Geo-replicated ACR keeps the image supply chain simple.** You push once, then both regions pull from the same registry name.
4. **Front Door closes the loop.** Without a global entry point, clients still need regional knowledge.

---

## Further Reading

- [AKS multi-cluster multi-region reference architecture](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks-multi-region/aks-multi-cluster)
- [Azure Kubernetes Fleet Manager CLI reference](https://learn.microsoft.com/cli/azure/fleet)
- [Azure Front Door CLI reference](https://learn.microsoft.com/cli/azure/afd)
- [AKS CLI reference](https://learn.microsoft.com/cli/azure/aks)
- [Azure Container Registry geo-replication](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)

---

[← Lab 11: Azure Container Registry Geo-Replication](lab-08-acr-geo-replication.md) | [Back to Index](../index.md) | [Next: Lab 13 — Azure Data Factory Active/Passive Pipelines →](lab-09-data-factory-dr.md)
