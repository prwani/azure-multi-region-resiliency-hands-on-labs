---
layout: default
title: "Lab 10: Azure Container Registry – Geo-Replicated Registry"
---

[← Back to Index](../index.md)

# Lab 10: Azure Container Registry – Geo-Replicated Registry

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

When you run containerised workloads across multiple Azure regions, every `docker pull` that crosses a long network path adds latency, egress cost, and another operational dependency. Azure Container Registry (ACR) **geo-replication** reduces that risk by keeping replicas close to each deployment region while preserving a **single registry name**.

| Challenge | How Geo-Replication Helps |
|---|---|
| **Slow image pulls** | Images are available from a replica close to the workload. |
| **Single point of failure** | Traffic Manager routes clients to the nearest healthy replica. |
| **Operational complexity** | Developers push once to one registry name; ACR replicates behind the scenes. |
| **Egress costs** | Local pulls avoid unnecessary cross-region transfers. |

### Push Once / Pull Everywhere

1. Build or push the image into the registry's home region.
2. ACR replicates the image to every configured replica region.
3. Clients keep using the same `<registry>.azurecr.io` login server.

---

## Architecture

```text
+---------------------------------------------------------------------+
|                       Global FQDN                                   |
|               acrmultiregionXXXXX.azurecr.io                        |
|                          |                                          |
|                    +-----+-----+                                    |
|                    |  Traffic   |   health-aware                    |
|                    |  Manager   |   nearest-replica routing         |
|                    +-----+-----+                                    |
|               +----------+----------+                               |
|               |                     |                               |
|   +-----------v-----------+  +------v----------------+              |
|   |   Sweden Central      |  |   Norway East         |              |
|   |   (home replica)      |  |   (geo-replica)       |              |
|   |                       |  |                       |              |
|   |  +-----------------+  |  |  +-----------------+  |              |
|   |  | hello-multiregion| |  |  | hello-multiregion| |              |
|   |  | :v1              | |  |  | :v1              | |              |
|   |  +-----------------+  |  |  +-----------------+  |              |
|   +-----------------------+  +------------------------+              |
|                                                                     |
|   docker push --> Sweden Central --> auto-replicates --> Norway East |
|   docker pull <-- nearest healthy replica via Traffic Manager        |
+---------------------------------------------------------------------+
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.50 or later (`az --version`) |
| **Azure subscription** | Permission to create Premium ACR instances |
| **PowerShell 7+** *(optional)* | Needed only for the PowerShell path |
| **Docker** | Optional — this lab uses `az acr build`, so no local Docker daemon is required |
| **Premium SKU** | Geo-replication is available only on Premium |

> **Important:** Premium ACR is billed per replica. Clean up promptly when you are finished.

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
<strong>Tip:</strong> ACR names are globally unique and must be alphanumeric only. Decide your naming pattern before you create the registry.
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

echo "ACR Name : $ACR_NAME"
echo "RG       : $RG"
echo "Home     : $HOME_REGION"
echo "Replica  : $REPLICA_REGION"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$ACR_NAME = "acrmultiregion$RANDOM_SUFFIX"
$RG = "rg-acr-georeplication-lab"

$HOME_REGION = "swedencentral"
$REPLICA_REGION = "norwayeast"

Write-Host "ACR Name : $ACR_NAME"
Write-Host "RG       : $RG"
Write-Host "Home     : $HOME_REGION"
Write-Host "Replica  : $REPLICA_REGION"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Record these values before you begin:

1. Registry name: `acrmultiregion<suffix>`
2. Resource group: `rg-acr-georeplication-lab`
3. Home region: `swedencentral`
4. Replica region: `norwayeast`

  </div>
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
az group create --name "$RG" --location "$HOME_REGION" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG --location $HOME_REGION --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Create `rg-acr-georeplication-lab` in **Sweden Central**.

  </div>
</div>



---

## Step 3 — Create the ACR (Premium SKU)

The Premium SKU is required for geo-replication.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr create \
  --name "$ACR_NAME" \
  --resource-group "$RG" \
  --location "$HOME_REGION" \
  --sku Premium \
  --admin-enabled false \
  --output table

az acr show \
  --name "$ACR_NAME" \
  --query "{Name:name, SKU:sku.name, Location:location, LoginServer:loginServer}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr create `
  --name $ACR_NAME `
  --resource-group $RG `
  --location $HOME_REGION `
  --sku Premium `
  --admin-enabled false `
  --output table

az acr show `
  --name $ACR_NAME `
  --query "{Name:name, SKU:sku.name, Location:location, LoginServer:loginServer}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Container registries** → **Create**.
2. Use resource group `rg-acr-georeplication-lab`.
3. Name the registry `acrmultiregion<suffix>`.
4. Choose **Sweden Central** as the location.
5. Select **Premium** as the SKU.
6. Create the registry and confirm the login server ends with `.azurecr.io`.

  </div>
</div>



<div class="lab-note">
<strong>Security note:</strong> Keep <code>--admin-enabled false</code>. In real deployments, prefer Entra ID, managed identities, or workload identities over admin credentials.
</div>



---

## Step 4 — Add a Geo-Replica in Norway East

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
  --location "$REPLICA_REGION" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr replication create `
  --registry $ACR_NAME `
  --location $REPLICA_REGION `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the registry.
2. Select **Replications**.
3. Choose **Add** and select **Norway East**.
4. Create the replica and wait for it to provision.

  </div>
</div>



---

## Step 5 — Optional: Recreate the Replica with Zone Redundancy

Zone redundancy must be chosen when the replica is created. If you need it, recreate the replica now.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr replication delete \
  --registry "$ACR_NAME" \
  --name "$REPLICA_REGION" \
  --yes

az acr replication create \
  --registry "$ACR_NAME" \
  --location "$REPLICA_REGION" \
  --zone-redundancy Enabled \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr replication delete `
  --registry $ACR_NAME `
  --name $REPLICA_REGION `
  --yes

az acr replication create `
  --registry $ACR_NAME `
  --location $REPLICA_REGION `
  --zone-redundancy Enabled `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In **Replications**, delete the Norway East replica if you created it without zone redundancy.
2. Add it again.
3. Turn on **Zone redundancy** during creation.
4. Save the replica and wait for the status to return to healthy.

  </div>
</div>



---

## Step 6 — List All Replications

You should now see the home region plus the Norway East geo-replica.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr replication list --registry "$ACR_NAME" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr replication list --registry $ACR_NAME --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Replications** on the registry.
2. Confirm both **Sweden Central** and **Norway East** are listed.
3. Verify the status shows the replica as ready or healthy.

  </div>
</div>



---

## Step 7 — Build and Push a Sample Image with ACR Tasks

ACR Tasks lets you build in Azure, so you do not need a local Docker daemon.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
WORK_DIR="$(mktemp -d)"
cd "$WORK_DIR"

cat > Dockerfile <<'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

cat > index.html <<'EOF'
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
EOF

az acr build \
  --registry "$ACR_NAME" \
  --image hello-multiregion:v1 \
  .
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$WORK_DIR = Join-Path ([System.IO.Path]::GetTempPath()) "acr-lab"
New-Item -ItemType Directory -Path $WORK_DIR -Force | Out-Null
Set-Location $WORK_DIR

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
  --image hello-multiregion:v1 `
  .
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the registry in the Azure portal.
2. For a pure portal workflow, open **Cloud Shell** and run the Bash or PowerShell commands from this step — that is the quickest way to provide a multi-file build context.
3. After the build starts, return to the registry and inspect **Tasks** or **Repositories** to watch the result appear.

  </div>
</div>



<div class="lab-note">
<strong>Behind the scenes:</strong> <code>az acr build</code> uploads the build context, runs the build in Azure, pushes the resulting image to the home region, and lets ACR replicate the artifact to the other regions.
</div>



---

## Step 8 — Verify the Repository Exists

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr repository list --name "$ACR_NAME" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr repository list --name $ACR_NAME --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Repositories** in the registry.
2. Confirm `hello-multiregion` appears.

  </div>
</div>



---

## Step 9 — Inspect Image Manifest Metadata

The manifest view confirms the tag, digest, and timestamps for the image you just built.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr manifest list-metadata \
  --registry "$ACR_NAME" \
  --name hello-multiregion \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr manifest list-metadata `
  --registry $ACR_NAME `
  --name hello-multiregion `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Repositories** → `hello-multiregion`.
2. Open tag `v1`.
3. Review the digest and push timestamp in the portal details pane.

  </div>
</div>



---

## Step 10 — Check Replication Status

Wait until the Norway East replica is healthy before you rely on it.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr replication show \
  --registry "$ACR_NAME" \
  --name "$REPLICA_REGION" \
  --query "{Name:name, Location:location, ProvisioningState:provisioningState, Status:status.displayStatus}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr replication show `
  --registry $ACR_NAME `
  --name $REPLICA_REGION `
  --query "{Name:name, Location:location, ProvisioningState:provisioningState, Status:status.displayStatus}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Return to **Replications** in the registry.
2. Open the Norway East replica.
3. Confirm the status is **Ready**.

  </div>
</div>

---

## Step 11 — Understand Traffic Manager Routing

ACR uses Azure Traffic Manager behind the scenes to route pulls to the nearest healthy replica. You do not change the image reference when regions fail or recover.

```text
Client: docker pull <acr>.azurecr.io/hello-multiregion:v1
    |
    v
DNS resolves <acr>.azurecr.io
    |
    v
Traffic Manager evaluates:
    +-- client location
    +-- replica health probes
    +-- latency-based routing
    |
    v
Request routed to nearest healthy replica
```



---

## Step 12 — Optional: Pull the Image

If you have Docker available, confirm the same image reference works exactly as expected.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr login --name "$ACR_NAME"
docker pull "$ACR_NAME.azurecr.io/hello-multiregion:v1"
docker run -d -p 8080:80 "$ACR_NAME.azurecr.io/hello-multiregion:v1"
curl http://localhost:8080
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr login --name $ACR_NAME
docker pull "$ACR_NAME.azurecr.io/hello-multiregion:v1"
docker run -d -p 8080:80 "$ACR_NAME.azurecr.io/hello-multiregion:v1"
Invoke-WebRequest http://localhost:8080 | Select-Object -ExpandProperty Content
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. The Azure portal does not include a built-in Docker engine.
2. Use **Cloud Shell** or your local machine if you want to run a real pull test.
3. In the portal, you can still validate replication health and repository presence without pulling the image locally.

  </div>
</div>



---

## Step 13 — Optional: Create a Webhook

Webhooks help you observe image pushes and deletes per region.

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
  --location "$HOME_REGION" \
  --actions push delete \
  --uri https://example.com/acr-webhook \
  --status enabled \
  --output table

az acr webhook create \
  --name webhookNorwayPush \
  --registry "$ACR_NAME" \
  --location "$REPLICA_REGION" \
  --actions push \
  --uri https://example.com/norway-webhook \
  --status enabled \
  --output table

az acr webhook list --registry "$ACR_NAME" --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr webhook create `
  --name webhookPushNotify `
  --registry $ACR_NAME `
  --location $HOME_REGION `
  --actions push delete `
  --uri https://example.com/acr-webhook `
  --status enabled `
  --output table

az acr webhook create `
  --name webhookNorwayPush `
  --registry $ACR_NAME `
  --location $REPLICA_REGION `
  --actions push `
  --uri https://example.com/norway-webhook `
  --status enabled `
  --output table

az acr webhook list --registry $ACR_NAME --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the registry → **Webhooks**.
2. Create a webhook in the home region for `push` and `delete` events.
3. Optionally add a second webhook scoped to the Norway East replica.
4. Use placeholder endpoints only for testing; production webhooks should target a controlled HTTPS receiver.

  </div>
</div>

---

## Validation Checklist

| # | Check | Expected |
|---|---|---|
| 1 | Registry exists with Premium SKU | `Premium` |
| 2 | Two replications listed | Sweden Central and Norway East |
| 3 | Repository exists | `hello-multiregion` |
| 4 | Image tag exists | `v1` appears in manifest metadata |
| 5 | Norway East replica is ready | `Status = Ready` |

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
az acr replication delete --registry "$ACR_NAME" --name "$REPLICA_REGION" --yes
az group delete --name "$RG" --yes --no-wait
[ -n "$WORK_DIR" ] && rm -rf "$WORK_DIR"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr replication delete --registry $ACR_NAME --name $REPLICA_REGION --yes
az group delete --name $RG --yes --no-wait
if ($WORK_DIR) { Remove-Item -Path $WORK_DIR -Recurse -Force -ErrorAction SilentlyContinue }
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. If you want to keep the registry but reduce cost, remove the Norway East replica from **Replications**.
2. To delete everything, remove the full resource group `rg-acr-georeplication-lab`.
3. Clean up any temporary build files in Cloud Shell or on your workstation.

  </div>
</div>

---

## Discussion

### Premium Tier — Cost Justification

| SKU | Geo-Replication | Storage Included | Relative Cost |
|---|---|---|---|
| Basic | No | 10 GiB | Lowest |
| Standard | No | 100 GiB | Medium |
| Premium | **Yes** | 500 GiB | Highest |

Premium costs more, but it is the tier that unlocks geo-replication, private endpoints, customer-managed keys, and other enterprise controls.

### Zone Redundancy per Replica

Zone redundancy protects the replica from a single availability-zone failure within its region. Geo-replication protects you from a **regional** failure. Together they provide layered resilience.

### Webhook Notifications on Replication

Region-scoped webhooks let you trigger automation or monitoring when push events occur in a specific replica location.

### Health-Aware Failover

ACR uses health-aware routing. If a replica becomes unhealthy, Traffic Manager moves pull traffic to the next closest healthy replica without requiring a new image reference.

### When NOT to Use Geo-Replication

- Single-region deployments
- Small dev/test environments where Premium cost is not justified
- Workloads where manual image copy to a second registry is sufficient

---

## Key Takeaways

1. **Premium SKU is required** for ACR geo-replication.
2. **One registry FQDN** serves all healthy replicas.
3. **Push once, pull everywhere** is the operating model.
4. **Zone redundancy** and **geo-replication** can be layered together.
5. **ACR Tasks** lets you build in Azure instead of relying on a local Docker daemon.

---

## Further Reading

- [Azure Container Registry geo-replication](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [ACR Tasks overview](https://learn.microsoft.com/azure/container-registry/container-registry-tasks-overview)
- [ACR pricing](https://azure.microsoft.com/pricing/details/container-registry/)
- [Zone redundancy in ACR](https://learn.microsoft.com/azure/container-registry/zone-redundancy)
- [ACR webhook reference](https://learn.microsoft.com/azure/container-registry/container-registry-webhook-reference)

---

[← Back to Index](../index.md) | [Next: Lab 11 — Azure Data Factory DR →](lab-09-data-factory-dr.md)
