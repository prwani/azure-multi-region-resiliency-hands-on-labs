---
layout: default
title: "Lab 11-a: Azure Container Registry – Geo-Replication"
---

[Lab 11-b: ACR Private Networking →](lab-11b-acr-private-networking.md)

# Lab 11-a: Azure Container Registry – Geo-Replication

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

.lab-copy-button svg {
  width: 1rem;
  height: 1rem;
  fill: currentColor;
}

.lab-copy-button.is-copied {
  color: #1a7f37;
}
</style>

## Introduction

Azure Container Registry (ACR) geo-replication keeps container images close to the regions that run them while preserving a **single registry name**. That means your teams still push once to one login server, but Azure keeps replicas in multiple regions and routes pulls to a healthy endpoint.

| Challenge | Why Geo-Replication Helps |
|---|---|
| **Slow cross-region pulls** | Replicas keep image data closer to each deployment region. |
| **Single-registry dependency** | ACR uses one global FQDN and routes to a healthy replica. |
| **Operational sprawl** | One registry, one set of RBAC assignments, one repository namespace. |
| **Disaster recovery** | If one region is unavailable, remaining replicas still serve pulls. |

> **Objective:** Build a Premium ACR in Sweden Central, add a Norway East replica, push a sample image once, and verify that the registry is ready for multi-region consumption.

---

## Architecture

```text
+--------------------------------------------------------------------------------+
|                          acrmultiregionxxxxx.azurecr.io                        |
|                                     |                                          |
|                         +-----------+-----------+                              |
|                         |     Global endpoint   |                              |
|                         |   health-aware route  |                              |
|                         +-----------+-----------+                              |
|                                     |                                          |
|             +-----------------------+-----------------------+                  |
|             |                                               |                  |
|   +---------v---------+                          +----------v---------+         |
|   | Sweden Central    |                          | Norway East        |         |
|   | home region       |                          | geo-replica        |         |
|   | hello-multiregion |                          | hello-multiregion  |         |
|   | :v1               |                          | :v1                |         |
|   +-------------------+                          +--------------------+         |
|                                                                                |
|   az acr build --> push once --> replicate in background --> pull everywhere   |
+--------------------------------------------------------------------------------+
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.50 or later |
| **Azure subscription** | Permission to create Premium ACR resources |
| **PowerShell 7+** *(optional)* | Needed only for the PowerShell path |
| **Docker** *(optional)* | Required only if you do the local pull test |
| **Budget awareness** | Premium ACR charges per registry plus per geo-replica |

<div class="lab-note">
<strong>Important:</strong> If you plan to continue directly into <strong>Lab 11-b</strong>, keep this registry, its replica, and the sample image. Lab 11-b assumes the image already exists before you harden the registry with private-only access.
</div>

---

## How These Tabs Work

- Pick <strong>Bash</strong>, <strong>PowerShell</strong>, or <strong>Portal</strong> once.
- Only one path stays visible at a time.
- Your preferred tab is remembered in the browser.
- Every code block includes the same copy-button behaviour used in the other labs.

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
2. Switch to the correct tenant if needed.
3. Open **Subscriptions** and confirm the subscription that will host the registry.
4. Keep the portal open for the rest of the lab.

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
RANDOM_SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | head -c 5)

ACR_NAME="acrmultiregion$RANDOM_SUFFIX"
RG="rg-acr-georeplication-lab"
HOME_REGION="swedencentral"
REPLICA_REGION="norwayeast"
IMAGE_NAME="hello-multiregion"
IMAGE_TAG="v1"

printf "ACR Name : %s\n" "$ACR_NAME"
printf "RG       : %s\n" "$RG"
printf "Home     : %s\n" "$HOME_REGION"
printf "Replica  : %s\n" "$REPLICA_REGION"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$ACR_NAME = "acrmultiregion$RANDOM_SUFFIX"
$RG = "rg-acr-georeplication-lab"
$HOME_REGION = "swedencentral"
$REPLICA_REGION = "norwayeast"
$IMAGE_NAME = "hello-multiregion"
$IMAGE_TAG = "v1"

Write-Host "ACR Name : $ACR_NAME"
Write-Host "RG       : $RG"
Write-Host "Home     : $HOME_REGION"
Write-Host "Replica  : $REPLICA_REGION"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Record these values before you create anything:

1. Registry name: `acrmultiregion<suffix>`
2. Resource group: `rg-acr-georeplication-lab`
3. Home region: `swedencentral`
4. Replica region: `norwayeast`
5. Sample repository: `hello-multiregion:v1`

  </div>
</div>

<div class="lab-note">
<strong>Tip:</strong> ACR names must be globally unique, use only lowercase letters and digits, and become part of the final login server name.
</div>

---

## Step 2 — Create the Resource Group and Premium Registry

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name "$RG" --location "$HOME_REGION" --output table

az acr create \
  --name "$ACR_NAME" \
  --resource-group "$RG" \
  --location "$HOME_REGION" \
  --sku Premium \
  --admin-enabled false \
  --output table

az acr show \
  --name "$ACR_NAME" \
  --resource-group "$RG" \
  --query "{Name:name, SKU:sku.name, Location:location, LoginServer:loginServer, PublicAccess:publicNetworkAccess}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG --location $HOME_REGION --output table

az acr create `
  --name $ACR_NAME `
  --resource-group $RG `
  --location $HOME_REGION `
  --sku Premium `
  --admin-enabled false `
  --output table

az acr show `
  --name $ACR_NAME `
  --resource-group $RG `
  --query "{Name:name, SKU:sku.name, Location:location, LoginServer:loginServer, PublicAccess:publicNetworkAccess}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create the resource group `rg-acr-georeplication-lab` in **Sweden Central**.
2. Open **Container registries** → **Create**.
3. Choose **Premium** for the pricing tier.
4. Keep **Admin user** disabled.
5. Create the registry and confirm the login server ends with `.azurecr.io`.

  </div>
</div>

<div class="lab-note">
<strong>Security note:</strong> Keep <code>--admin-enabled false</code>. Real workloads should use Microsoft Entra ID, managed identities, service principals, or workload identities instead of shared admin credentials.
</div>

---

## Step 3 — Add the Norway East Geo-Replica

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr replication create \
  --registry "$ACR_NAME" \
  --resource-group "$RG" \
  --location "$REPLICA_REGION" \
  --output table

az acr replication list \
  --registry "$ACR_NAME" \
  --resource-group "$RG" \
  --query "[].{Location:location, ProvisioningState:provisioningState, RegionEndpointEnabled:regionEndpointEnabled}" \
  --output table
```

> Optional: if you want zone redundancy on the replica, delete and recreate it with `--zone-redundancy Enabled` before you move on.

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr replication create `
  --registry $ACR_NAME `
  --resource-group $RG `
  --location $REPLICA_REGION `
  --output table

az acr replication list `
  --registry $ACR_NAME `
  --resource-group $RG `
  --query "[].{Location:location, ProvisioningState:provisioningState, RegionEndpointEnabled:regionEndpointEnabled}" `
  --output table
```

> Optional: if you want zone redundancy on the replica, delete and recreate it with `--zone-redundancy Enabled` before you move on.

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the registry.
2. Go to **Geo-replications**.
3. Add **Norway East**.
4. If you want zone redundancy, turn it on during replica creation because that choice is made at create time.
5. Wait until the replica returns to a healthy or ready state.

  </div>
</div>

---

## Step 4 — Build and Push a Sample Image with ACR Tasks

ACR Tasks builds the image inside Azure, so you do not need a local Docker daemon for the push path.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
WORK_DIR="$(pwd)/acr-geo-lab-$RANDOM_SUFFIX"
mkdir -p "$WORK_DIR"

cat > "$WORK_DIR/Dockerfile" <<'DOCKERFILE'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

cat > "$WORK_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Multi-Region ACR</title>
</head>
<body>
    <h1>Hello from Multi-Region ACR!</h1>
    <p>This image is served from the nearest geo-replica.</p>
    <p>Push once, pull everywhere.</p>
</body>
</html>
HTML

az acr build \
  --registry "$ACR_NAME" \
  --image "$IMAGE_NAME:$IMAGE_TAG" \
  "$WORK_DIR"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$WORK_DIR = Join-Path (Get-Location) "acr-geo-lab-$RANDOM_SUFFIX"
New-Item -ItemType Directory -Path $WORK_DIR -Force | Out-Null

@'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
'@ | Set-Content -Path (Join-Path $WORK_DIR "Dockerfile")

@'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Multi-Region ACR</title>
</head>
<body>
    <h1>Hello from Multi-Region ACR!</h1>
    <p>This image is served from the nearest geo-replica.</p>
    <p>Push once, pull everywhere.</p>
</body>
</html>
'@ | Set-Content -Path (Join-Path $WORK_DIR "index.html")

az acr build `
  --registry $ACR_NAME `
  --image "$IMAGE_NAME`:$IMAGE_TAG" `
  $WORK_DIR
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Cloud Shell** from the Azure portal.
2. Use the Bash or PowerShell commands from this step to create the two local files and run `az acr build`.
3. Return to the registry and inspect **Repositories** or **Tasks** as the image appears.

  </div>
</div>

<div class="lab-note">
<strong>Behind the scenes:</strong> <code>az acr build</code> uploads the build context, runs the build in Azure, pushes the image to the registry, and then lets ACR replicate the resulting artifact in the background.
</div>

---

## Step 5 — Verify the Repository, Manifest Metadata, and Replica Health

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr repository list --name "$ACR_NAME" --output table

az acr manifest list-metadata \
  --registry "$ACR_NAME" \
  --name "$IMAGE_NAME" \
  --output table

az acr replication show \
  --registry "$ACR_NAME" \
  --resource-group "$RG" \
  --name "$REPLICA_REGION" \
  --query "{Location:location, ProvisioningState:provisioningState, Status:status.displayStatus}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr repository list --name $ACR_NAME --output table

az acr manifest list-metadata `
  --registry $ACR_NAME `
  --name $IMAGE_NAME `
  --output table

az acr replication show `
  --registry $ACR_NAME `
  --resource-group $RG `
  --name $REPLICA_REGION `
  --query "{Location:location, ProvisioningState:provisioningState, Status:status.displayStatus}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Repositories** and confirm `hello-multiregion` exists.
2. Open tag `v1` and review the digest and timestamps.
3. Return to **Geo-replications** and verify that **Norway East** shows a healthy or ready state.

  </div>
</div>

---

## Step 6 — Understand Routing and Optionally Pull the Image

When a client pulls `acrmultiregionxxxxx.azurecr.io/hello-multiregion:v1`, Azure resolves the global registry endpoint and routes the request to a healthy geo-replica.

```text
Client pull --> <registry>.azurecr.io --> ACR routing decision --> nearest healthy replica
```

ACR also supports **regional endpoints** for advanced cases where you want predictable replica affinity or custom client-side failover. The standard lab flow keeps the simpler global endpoint model.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr login --name "$ACR_NAME"
docker pull "$ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
docker run --rm -d -p 8080:80 "$ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
curl http://127.0.0.1:8080
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr login --name $ACR_NAME
docker pull "$ACR_NAME.azurecr.io/$IMAGE_NAME`:$IMAGE_TAG"
docker run --rm -d -p 8080:80 "$ACR_NAME.azurecr.io/$IMAGE_NAME`:$IMAGE_TAG"
Invoke-WebRequest http://127.0.0.1:8080 | Select-Object -ExpandProperty Content
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. The Azure portal does not include a built-in Docker daemon.
2. Use **Cloud Shell** or your local workstation if you want a real pull test.
3. If you are heading straight to Lab 11-b, you can skip the local pull and keep the registry intact for private-access validation.

  </div>
</div>

---

## Step 7 — Optional: Add Region-Scoped Webhooks

Webhooks are useful if you want automation or observability when pushes reach the home region or a specific geo-replica.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr webhook create \
  --name webhookPushNotify \
  --registry "$ACR_NAME" \
  --resource-group "$RG" \
  --location "$HOME_REGION" \
  --actions push delete \
  --uri https://example.com/acr-home-webhook \
  --status enabled \
  --output table

az acr webhook create \
  --name webhookReplicaNotify \
  --registry "$ACR_NAME" \
  --resource-group "$RG" \
  --location "$REPLICA_REGION" \
  --actions push \
  --uri https://example.com/acr-replica-webhook \
  --status enabled \
  --output table

az acr webhook list --registry "$ACR_NAME" --resource-group "$RG" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr webhook create `
  --name webhookPushNotify `
  --registry $ACR_NAME `
  --resource-group $RG `
  --location $HOME_REGION `
  --actions push delete `
  --uri https://example.com/acr-home-webhook `
  --status enabled `
  --output table

az acr webhook create `
  --name webhookReplicaNotify `
  --registry $ACR_NAME `
  --resource-group $RG `
  --location $REPLICA_REGION `
  --actions push `
  --uri https://example.com/acr-replica-webhook `
  --status enabled `
  --output table

az acr webhook list --registry $ACR_NAME --resource-group $RG --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Webhooks** on the registry.
2. Create one webhook in the home region for `push` and `delete`.
3. Optionally create another in **Norway East** for replica-specific notifications.
4. Use placeholder URLs only for lab learning; production webhooks should target controlled HTTPS receivers.

  </div>
</div>

---

## Validation Checklist

| # | Check | Expected |
|---|---|---|
| 1 | Registry SKU | `Premium` |
| 2 | Geo-replica exists | Norway East listed in `az acr replication list` |
| 3 | Repository exists | `hello-multiregion` appears |
| 4 | Image tag exists | `v1` appears in manifest metadata |
| 5 | Replica health | Norway East status is healthy or ready |

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
# If you plan to continue to Lab 11-b, keep the registry and replica.
[ -n "$WORK_DIR" ] && rm -rf "$WORK_DIR"

# Full teardown when you are completely finished:
az acr replication delete --registry "$ACR_NAME" --resource-group "$RG" --name "$REPLICA_REGION" --yes
az group delete --name "$RG" --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# If you plan to continue to Lab 11-b, keep the registry and replica.
if ($WORK_DIR) { Remove-Item -Path $WORK_DIR -Recurse -Force -ErrorAction SilentlyContinue }

# Full teardown when you are completely finished:
az acr replication delete --registry $ACR_NAME --resource-group $RG --name $REPLICA_REGION --yes
az group delete --name $RG --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. If you are proceeding to Lab 11-b, keep the registry and the Norway East replica.
2. If you are done, remove the replica from **Geo-replications** and then delete the resource group `rg-acr-georeplication-lab`.
3. Clean up any local or Cloud Shell build files you created.

  </div>
</div>

---

## Discussion & Next Steps

### Why Premium Matters

Premium is the ACR tier that unlocks geo-replication, private endpoints, customer-managed keys, and the broader enterprise networking feature set.

### Zone Redundancy vs Geo-Replication

Zone redundancy protects a replica from a single availability-zone failure inside one region. Geo-replication protects you from a regional failure. They solve different failure domains and can be layered together.

### Global Endpoint vs Regional Endpoints

The global endpoint is the simplest option and is the right default for most labs and platform teams. Regional endpoints are useful when you need deterministic routing, push-pull consistency, or client-managed failover logic.

### Prepare for Lab 11-b

Lab 11-b takes this same registry and adds private endpoints, regional private DNS, and managed-identity-based image pulls from private-only consumers. Complete your `az acr build` work before you disable public access.

---

## Useful Links

- [Azure Container Registry geo-replication](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-geo-replication)
- [ACR Tasks overview](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview)
- [ACR pricing](https://azure.microsoft.com/pricing/details/container-registry/)
- [Zone redundancy in ACR](https://learn.microsoft.com/en-us/azure/container-registry/zone-redundancy)
- [ACR webhooks](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-webhook)

---

[Lab 11-b: ACR Private Networking →](lab-11b-acr-private-networking.md)
