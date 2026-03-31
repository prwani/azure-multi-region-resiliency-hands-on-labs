---
layout: default
title: "Lab 14-a: Integrated Enterprise App – Multi-Region Prototype"
---

[Lab 14-a — Enterprise Prototype](lab-14a-enterprise-prototype.md) | [Next: Lab 14-b — Secure Networking →](lab-14b-enterprise-prototype-secure-networking.md)

# Lab 14-a: Integrated Enterprise App – Multi-Region Prototype

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


> **Objective:** Deploy a fully integrated multi-region enterprise application by using the topology-driven prototype, configure every service layer for cross-region resilience, and validate coordinated failover end-to-end over the baseline public-edge path.

<div class="lab-note">
<strong>Variant note:</strong> This <code>A</code> path keeps the current capstone intact in spirit: the prototype drives the end-to-end deployment, the global entry point stays public, and you do <strong>not</strong> need the Lab 0 hub-and-spoke foundation first. If you want the hardened landing-zone version with private endpoints and spoke-based workload placement, continue to <a href="lab-14b-enterprise-prototype-secure-networking.md">Lab 14-b</a>.
</div>

> **⏱ Estimated time:** 2–3 hours (shorter if you already have resources from Labs 1–13)

---

## Why End-to-End Multi-Region Matters

In Labs 1–13 you learned how to make **individual** Azure services and platform patterns resilient across regions: Blob Storage with object replication, SQL with failover groups, Cosmos DB with multi-region writes, MySQL and PostgreSQL with cross-region read replicas, Azure VM disaster recovery with Site Recovery, App Service behind Traffic Manager, Key Vault backup and sync, Service Bus geo-DR aliases, Event Hubs geo-replication, ACR geo-replicas, AKS multi-cluster routing, and Data Factory active/passive pipelines.

Each of those labs solves one piece of the puzzle. But here is the hard truth:

> **Individual service DR is necessary but not sufficient.** A real enterprise application is a *system* — web tier, data tier, messaging tier, secrets management, container registry, networking — all wired together. If your SQL database fails over but your app's connection strings still point to the old primary, you're down. If your Service Bus alias switches but your Functions don't know about it, messages are lost. If your Front Door health probe passes but the backend is reading stale secrets from the wrong Key Vault, you have silent data corruption.

**Coordinated failover** across every layer is the real enterprise challenge. It requires:

- A **single source of truth** for topology — which subscriptions, which regions, which services, which feature flags
- An **orchestrated deployment** that provisions primary infrastructure, discovers the best secondary region, and enables cross-region replication in the right order
- A **tested failover runbook** that sequences the switchover so dependent services fail over *after* their dependencies
- A **failback plan** that is just as tested as the failover

This lab uses the **[multi-region-nonpaired-enterprise-prototype](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype)** repository as the reference implementation. The prototype implements a three-step deployment model — Primary Baseline → Discover & Recommend → Enable Secondary — driven by a topology manifest. You will deploy it, configure it, test failover, and understand how all the pieces fit together.

> **⏱ Estimated time:** 2–3 hours (shorter if you already have resources from Labs 1–13)

---

## Architecture

The prototype deploys a multi-tier application across two non-paired Azure regions with a global load balancer in front. Every service layer has its own cross-region resilience mechanism, coordinated through a shared topology manifest.

```
┌─────────────────────────────────────────────────────────────────┐
│                  Azure Front Door / Traffic Manager              │
│                    (Global Load Balancing)                       │
└─────────────┬───────────────────────────────────┬───────────────┘
              │                                   │
┌─────────────▼───────────────┐     ┌─────────────▼───────────────┐
│   Sweden Central (Primary)  │     │   Norway East (Secondary)   │
│  ┌───────────────────────┐  │     │  ┌───────────────────────┐  │
│  │ App Service / AKS     │  │     │  │ App Service / AKS     │  │
│  │ Azure Functions       │  │     │  │ Azure Functions       │  │
│  └───────────┬───────────┘  │     │  └───────────┬───────────┘  │
│  ┌───────────▼───────────┐  │     │  ┌───────────▼───────────┐  │
│  │ SQL (Primary)         │◄─┼──DR─┼─►│ SQL (Secondary)       │  │
│  │ Cosmos DB (Write)     │◄─┼─Repl┼─►│ Cosmos DB (Read/Write)│  │
│  │ Storage (Source)      │──┼─ObjR─┼─►│ Storage (Destination) │  │
│  │ Service Bus (Primary) │◄─┼─Alias┼─►│ Service Bus (Secondary│  │
│  │ Key Vault (Primary)   │──┼─Sync─┼─►│ Key Vault (Secondary) │  │
│  └───────────────────────┘  │     │  └───────────────────────┘  │
└─────────────────────────────┘     └─────────────────────────────┘
```

**How each layer achieves cross-region resilience:**

| Layer | Mechanism | Lab Reference |
|-------|-----------|---------------|
| Blob Storage | Object Replication (async, change-feed-based) | [Lab 1-a](lab-01a-blob-storage-replication.md) |
| SQL Database | Active Geo-Replication + Failover Group | [Lab 2-a](lab-02a-sql-geo-replication.md) |
| Cosmos DB | Multi-region writes with automatic failover | [Lab 3-a](lab-03a-cosmos-global-distribution.md) |
| MySQL Flexible Server | Cross-region read replica | [Lab 4-a](lab-04a-mysql-geo-replication.md) |
| PostgreSQL Flexible Server | Cross-region read replica | [Lab 5-a](lab-05a-postgresql-geo-replication.md) |
| Virtual Machines | Azure Site Recovery (Azure-to-Azure) | [Lab 6-a](lab-06a-vm-site-recovery.md) |
| Web / Compute | Active-passive App Service + Traffic Manager | [Lab 7-a](lab-07a-webapp-traffic-manager.md) |
| Key Vault | Backup / restore sync to secondary vault | [Lab 8-a](lab-08a-key-vault-multi-region.md) |
| Service Bus | Geo-DR alias (metadata replication) | [Lab 9-a](lab-09a-service-bus-geo-dr.md) |
| Event Hubs | Geo-replication with consumer-group failover | [Lab 10-a](lab-10a-event-hubs-geo-replication.md) |
| Container Registry | Premium geo-replicated ACR | [Lab 11-a](lab-11a-acr-geo-replication.md) |
| AKS multi-cluster | Fleet + Front Door + regional clusters | [Lab 12-a](lab-12a-aks-multi-cluster.md) |
| Data Factory | Active/passive pipeline duplication | [Lab 13-a](lab-13a-data-factory-dr.md) |

### Three-Step Deployment Model

The prototype decomposes multi-region enablement into three sequential steps:

```
┌──────────────────────┐     ┌───────────────────────┐     ┌──────────────────────┐
│  Step 1               │     │  Step 2                │     │  Step 3               │
│  Primary Baseline     │────►│  Discover & Recommend  │────►│  Enable Secondary     │
│                       │     │                        │     │                       │
│  • Provision all      │     │  • Scan ARM for        │     │  • Deploy secondary   │
│    primary-region     │     │    service availability│     │    region resources   │
│    resources          │     │  • Score candidate     │     │  • Enable replication │
│  • Deploy app code    │     │    regions (weighted)  │     │  • Configure aliases  │
│  • Validate health    │     │  • Output per-service  │     │  • Wire up Front Door │
│                       │     │    recommendations     │     │  • Run smoke tests    │
└──────────────────────┘     └───────────────────────┘     └──────────────────────┘
```

### Region Selection — Weighted Scoring

The prototype uses a weighted scoring model (from [`docs/REGION-SELECTION.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/REGION-SELECTION.md)) to recommend the best secondary region:

| Criterion | Weight | Sweden Central → Norway East Score |
|-----------|--------|------------------------------------|
| Service coverage | 40% | 91.5% of required services available |
| Availability Zone support | 25% | 3 AZs in both regions |
| Cost (relative) | 20% | Comparable pricing tier |
| Network latency | 10% | Sub-10 ms inter-region |
| Compliance / data residency | 5% | Both in EU/EEA |

The default region pair **Sweden Central → Norway East** achieves the highest composite score for EU-centric workloads. You can override this by editing the topology manifest.

---

## Prerequisites

### Concepts from Previous Labs

This lab assumes you are comfortable with the concepts introduced in Labs 1–13. You do not need to have the resources from those labs still running, but you should understand:

- **[Lab 1-a](lab-01a-blob-storage-replication.md):** Storage account versioning, change feed, object replication policies
- **[Lab 2-a](lab-02a-sql-geo-replication.md):** SQL active geo-replication, failover groups, read-only listener endpoints
- **[Lab 3-a](lab-03a-cosmos-global-distribution.md):** Cosmos DB multi-region writes, consistency levels, automatic failover policies
- **[Lab 4-a](lab-04a-mysql-geo-replication.md):** MySQL Flexible Server cross-region read replicas, replica promotion, and endpoint cutover planning
- **[Lab 5-a](lab-05a-postgresql-geo-replication.md):** PostgreSQL Flexible Server cross-region read replicas, virtual endpoints, and replica promotion
- **[Lab 6-a](lab-06a-vm-site-recovery.md):** Azure Site Recovery fabrics, mappings, failover drills, and failback preparation for VMs
- **[Lab 7-a](lab-07a-webapp-traffic-manager.md):** Traffic Manager profiles, priority-based routing, health probes, Chaos Studio fault injection
- **[Lab 8-a](lab-08a-key-vault-multi-region.md):** Key Vault backup/restore, cross-region secret synchronization
- **[Lab 9-a](lab-09a-service-bus-geo-dr.md):** Service Bus Premium namespaces, geo-DR pairing, alias FQDNs, metadata-only replication
- **[Lab 10-a](lab-10a-event-hubs-geo-replication.md):** Event Hubs geo-replication, consumer group offset management
- **[Lab 11-a](lab-11a-acr-geo-replication.md):** ACR Premium tier, geo-replication, region-local pulls
- **[Lab 12-a](lab-12a-aks-multi-cluster.md):** Multi-cluster AKS operations, Fleet membership, and Front Door routing patterns
- **[Lab 13-a](lab-13a-data-factory-dr.md):** Data Factory pipeline duplication, linked service reconfiguration

### Tools Required

| Tool | Version | Required? | Installation |
|------|---------|-----------|--------------|
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | 2.60+ | ✅ Yes | `winget install Microsoft.AzureCLI` |
| [Azure Developer CLI (`azd`)](https://learn.microsoft.com/azure/developer/azure-developer-cli/) | Latest | ✅ Yes | `winget install Microsoft.Azd` |
| [PowerShell 7+](https://learn.microsoft.com/powershell/scripting/install/installing-powershell) | 7.0+ | ✅ Yes | `winget install Microsoft.PowerShell` |
| [jq](https://jqlang.github.io/jq/) | 1.6+ | ✅ Yes | `winget install jqlang.jq` |
| [Git](https://git-scm.com/) | 2.x | ✅ Yes | `winget install Git.Git` |
| [Databricks CLI](https://docs.databricks.com/dev-tools/cli/index.html) | Latest | ⬜ Optional | For Databricks workspace domains |
| [Microsoft Fabric workspace](https://learn.microsoft.com/fabric/) | — | ⬜ Optional | For Fabric integration features |

> **PowerShell note:** The prototype repository uses Bash entrypoints for baseline deployment, secondary enablement, cost controls, and cleanup. The PowerShell tabs stay PowerShell-native and invoke those scripts through `bash`, so keep Azure Cloud Shell, WSL, or Git Bash available.

### Azure Requirements

- **Azure subscription** with **Contributor** or **Owner** role
- Ability to create resources in **Sweden Central** and **Norway East** (or your chosen region pair)
- For multi-subscription deployments: a second subscription for Fabric resources (see topology manifest)
- Sufficient quota for: App Service plans, SQL databases, Cosmos DB accounts, Storage accounts, Service Bus Premium namespaces, Key Vaults, and Azure Front Door

---

## How These Tabs Work

This page uses a shared tab preference:

- If you click **Bash** in one step, the rest of the page switches to **Bash**
- The selection is remembered for the page in your browser
- Every code block gets a copy button in the top-right corner

<div class="lab-note">
<strong>Prototype note:</strong> Several orchestration entry points in the external prototype repository are currently published as Bash scripts. In those places, the PowerShell tabs call the same entry points through <code>bash</code> so you can stay in the same shell while following the lab.
</div>

---

### Verify Your Environment

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az version
azd version
pwsh --version
jq --version
git --version

az login
az account show
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az version
azd version
$PSVersionTable.PSVersion.ToString()
jq --version
git --version

az login
az account show
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Azure Cloud Shell** from the portal toolbar if you want an Azure-hosted terminal.
2. Confirm you are signed in to the correct tenant and subscription under **Subscriptions**.
3. If you plan to run the prototype from your workstation, verify `az`, `azd`, PowerShell, Git, and `jq` locally before you start.
4. Review quotas in **Usage + quotas** for the resource types this lab provisions.

      </div>
    </div>

---

## Step-by-Step Instructions

### 1. Clone the Prototype Repository

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
git clone https://github.com/prwani/multi-region-nonpaired-enterprise-prototype.git
cd multi-region-nonpaired-enterprise-prototype
ls -la
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
git clone https://github.com/prwani/multi-region-nonpaired-enterprise-prototype.git
Set-Location .\multi-region-nonpaired-enterprise-prototype
Get-ChildItem -Force
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the prototype repository in GitHub so you can skim the README and docs alongside the lab.
2. Use Azure Cloud Shell or your local workstation to clone the repository; the portal itself does not clone Git repositories for you.
3. Keep the repository open in an editor because you will modify `config/topology.json` and inspect generated outputs as you progress.

      </div>
    </div>

Take a moment to explore the repository structure:

```
├── config/
│   ├── topology.example.json    # Template topology manifest
│   └── topology.json            # Your configured manifest (you create this)
├── docs/
│   ├── architecture.md          # Detailed architecture documentation
│   ├── OPERATIONS.md            # Day-2 operational procedures
│   ├── REGION-SELECTION.md      # Region scoring methodology
│   ├── failover-runbook.md      # Step-by-step failover/failback procedures
│   └── service-matrix.md        # Per-service availability matrix
├── scripts/
│   ├── fetch-samples.sh         # Bootstrap upstream sample code
│   ├── pause-all.sh             # Pause/deallocate resources to save costs
│   ├── resume-all.sh            # Resume paused resources
│   ├── cleanup-all.sh           # Full resource cleanup
│   └── decouple-secondary.sh    # Decouple secondary for independent operation
├── step1-primary-baseline/      # Step 1: Deploy primary region
├── step2-discover-recommend/    # Step 2: Discover & score regions
└── step3-enable-secondary/      # Step 3: Enable secondary region
```

### 2. Configure the Topology Manifest

The topology manifest (`config/topology.json`) is the **single source of truth** for the entire deployment. It defines subscriptions, regions, domain configurations, and feature flags.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cp config/topology.example.json config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Copy-Item ./config/topology.example.json ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `config/topology.example.json` in the Cloud Shell editor, VS Code, or your preferred editor.
2. Save a working copy as `config/topology.json`.
3. Update subscription IDs, primary and secondary regions, domains, and feature flags before you deploy anything.

      </div>
    </div>

Open `config/topology.json` in your editor and fill in your values:

```jsonc
{
  "$schema": "./topology.schema.json",
  "version": "1.0.0",
  "subscriptions": {
    "main": {
      "id": "<your-primary-subscription-id>",
      "name": "main-subscription"
    },
    "fabric": {
      "id": "<your-fabric-subscription-id-or-same-as-primary>",
      "name": "fabric-subscription"
    }
  },
  "primaryRegion": "swedencentral",
  "secondaryRegion": "norwayeast",
  "regionProfile": "./region-profiles/swedencentral-norwayeast.json",
  "featureFlags": {
    "enableCrossSubscription": false,
    "enablePrivateEndpoints": false,
    "enableCMK": false,
    "enableFabric": false,
    "enableActiveActive": false
  },
  "domains": {
    "app-workloads": {
      "subscription": "main",
      "description": "Application workload samples.",
      "samples": ["A-aks-store"],
      "resourceGroups": ["rg-contoso-app-workloads-swedencentral"]
    }
  },
  "sampleManifest": "./samples-manifest.json"
}
```

> **💡 Multi-subscription support:** If your organization requires Fabric resources in a separate subscription, set `subscriptions.fabric.id` to the Fabric subscription ID. Otherwise, use the same ID as `subscriptions.main.id`.

> **💡 Domain mapping:** Each `domains.<name>.subscription` value must reference a key under `subscriptions`, and each sample ID must exist in `config/samples-manifest.json`. Start with a single sample such as `A-aks-store` while you validate the workflow.

> **💡 Feature flags:** Use the flags that exist in the prototype schema (`enableCrossSubscription`, `enablePrivateEndpoints`, `enableCMK`, `enableFabric`, `enableActiveActive`). Disable optional capabilities if you do not have the required prerequisites.

### 3. Bootstrap Upstream Samples

The prototype pulls in code from several upstream repositories. The fetch script clones them into the correct local paths.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
bash ./scripts/fetch-samples.sh
ls samples/
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/fetch-samples.sh
Get-ChildItem .\samples
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the bootstrap script from Cloud Shell or your workstation.
2. Use the portal primarily for verification here: once the script finishes, inspect the cloned `samples/` folder in your editor.
3. If the script fails, correct the local prerequisites before you move on to infrastructure deployment.

      </div>
    </div>

This fetches samples from:

| Upstream Repository | Purpose |
|---------------------|---------|
| [Azure/AI-Landing-Zones](https://github.com/Azure/AI-Landing-Zones) | AI workload landing zone patterns |
| [Azure/AzRegionSelection](https://github.com/Azure/AzRegionSelection) | Region scoring and selection tooling |
| [Azure-Samples/aks-store-demo](https://github.com/Azure-Samples/aks-store-demo) | Sample AKS store application |
| [fabric-samples-healthcare](https://github.com/microsoft/fabric-samples) | Healthcare sample for Fabric integration |

---

### 4. Step 1 — Deploy Primary Baseline

Step 1 provisions all primary-region resources: the App Service or AKS cluster, Azure Functions, SQL Database, Cosmos DB account, Storage accounts, Key Vault, Service Bus namespace, and networking infrastructure.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd step1-primary-baseline
bash ./scripts/deploy.sh --topology ../config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location (Join-Path $RepoRoot "step1-primary-baseline")

bash ./scripts/deploy.sh --topology ../config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Start the Step 1 deployment from Cloud Shell or your workstation.
2. In the Azure portal, monitor **Resource groups** and **Deployments** as resources appear in the primary region.
3. Do not proceed until the baseline deployment finishes successfully and outputs the actual resource names you will reuse later.

      </div>
    </div>

> **⏱ This step takes 15–25 minutes** depending on the services enabled in your topology.

> **💡 Readiness-check note:** The prototype's current readiness checker evaluates some optional services even when your topology disables them. If you intentionally turned off capabilities such as Databricks, Front Door/CDN, or Redis and the pre-check still flags those providers, rerun the command with `--skip-checks`.

The deploy script:

1. Reads the topology manifest to determine subscriptions, primary region, and enabled features
2. Creates resource groups with consistent naming (`rg-<purpose>-<region>`)
3. Deploys infrastructure using Bicep/ARM templates
4. Deploys application code to compute resources
5. Configures networking (VNet, NSGs, Private Endpoints where applicable)
6. Outputs a summary of deployed resources

#### Verify Primary Deployment

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group list --query "[?location=='swedencentral'].name" -o tsv

PRIMARY_APP_URL=$(az webapp show -g rg-app-swedencentral -n <your-app-name> --query defaultHostName -o tsv)
curl -s -o /dev/null -w "%{http_code}" "https://$PRIMARY_APP_URL/health"

az sql server list -g rg-data-swedencentral -o table
az cosmosdb show -g rg-data-swedencentral -n <your-cosmos-account> --query "readLocations[].locationName" -o tsv
az servicebus namespace show -g rg-messaging-swedencentral -n <your-sb-namespace> --query status -o tsv
az keyvault show -g rg-security-swedencentral -n <your-keyvault> --query "properties.provisioningState" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group list --query "[?location=='swedencentral'].name" -o tsv

$PRIMARY_APP_URL = az webapp show -g rg-app-swedencentral -n <your-app-name> --query defaultHostName -o tsv
(Invoke-WebRequest -UseBasicParsing -Uri "https://$PRIMARY_APP_URL/health").StatusCode

az sql server list -g rg-data-swedencentral -o table
az cosmosdb show -g rg-data-swedencentral -n <your-cosmos-account> --query "readLocations[].locationName" -o tsv
az servicebus namespace show -g rg-messaging-swedencentral -n <your-sb-namespace> --query status -o tsv
az keyvault show -g rg-security-swedencentral -n <your-keyvault> --query "properties.provisioningState" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open each primary-region resource group and verify the expected services exist.
2. Browse to the primary web app or API health endpoint from the **Overview** page.
3. Confirm the SQL server, Cosmos DB account, Service Bus namespace, and Key Vault each show healthy provisioning state in their overview blades.
4. Replace the placeholder names in the CLI tabs with the actual names the deployment produced.

      </div>
    </div>

> **📝 Note:** The deploy script outputs the actual resource names. Replace the `<your-*>` placeholders above with those values.

At this point you have a fully working single-region application. This mirrors what many teams have in production — and it is exactly what needs multi-region protection.

**Cross-reference — this step combines concepts from:**
- [Lab 7-a — Web App deployment](lab-07a-webapp-traffic-manager.md) (App Service provisioning)
- [Lab 2-a — SQL Database creation](lab-02a-sql-geo-replication.md) (SQL Server + database)
- [Lab 3-a — Cosmos DB setup](lab-03a-cosmos-global-distribution.md) (single-region Cosmos account)
- [Lab 8-a — Key Vault creation](lab-08a-key-vault-multi-region.md) (primary Key Vault)
- [Lab 9-a — Service Bus namespace](lab-09a-service-bus-geo-dr.md) (Premium namespace)

---

### 5. Step 2 — Discover & Recommend Secondary Region

Step 2 scans the Azure Resource Manager API, evaluates candidate secondary regions, and produces a recommendation report.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd ../step2-discover-recommend
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
pwsh scripts/run-discovery.ps1 -SubscriptionId $SUBSCRIPTION_ID -TopologyFile ../config/topology.json

jq '{primaryRegion, recommendedSecondaryRegion, totalRecommendations: (.recommendations | length)}' outputs/recommendations.json
jq '.candidates | sort_by(-.compositeScore) | .[:5] | map({region, compositeScore})' outputs/region-scorecard.json
jq '.recommendations[] | {resourceType, targetRegion, action: (.step3Action.script // .step3Action.blockReason // "manual")}' outputs/recommendations.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Set-Location ..\step2-discover-recommend
$SubscriptionId = az account show --query id -o tsv
pwsh ./scripts/run-discovery.ps1 -SubscriptionId $SubscriptionId -TopologyFile ../config/topology.json

(Get-Content .\outputs\recommendations.json -Raw | ConvertFrom-Json) |
  Select-Object primaryRegion, recommendedSecondaryRegion, @{Name='totalRecommendations';Expression={$_.recommendations.Count}}

(Get-Content .\outputs\region-scorecard.json -Raw | ConvertFrom-Json).candidates |
  Sort-Object -Property compositeScore -Descending |
  Select-Object -First 5 region, compositeScore

(Get-Content .\outputs\recommendations.json -Raw | ConvertFrom-Json).recommendations |
  Select-Object resourceType, targetRegion, @{Name='action';Expression={$_.step3Action.script ?? $_.step3Action.blockReason ?? 'manual'}}
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the discovery step from your terminal or Cloud Shell.
2. Use the Azure portal to spot-check that the discovered primary resources match what was actually deployed.
3. Open the generated JSON files in your editor and confirm the recommended region aligns with your compliance, service coverage, and cost expectations.
4. If you need a different secondary region, update `config/topology.json` before you proceed to Step 3.

      </div>
    </div>

**Expected output for the default Sweden Central → Norway East configuration:**

```json
{
  "topScoringRegion": "norwayeast",
  "compositeScore": 0.915,
  "breakdown": {
    "serviceCoverage": 0.915,
    "availabilityZones": 3,
    "costIndex": 1.02,
    "latencyMs": 8.3,
    "complianceMatch": true
  }
}
```

> **💡 Why Norway East?** It scores highest for EU workloads: 91.5% service coverage of your deployed resource types, full 3-AZ support, comparable pricing, sub-10 ms network latency from Sweden Central, and both regions fall within EU/EEA data residency boundaries. See [`docs/REGION-SELECTION.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/REGION-SELECTION.md) for the full methodology.

---

### 6. Step 3 — Enable Secondary Region

Step 3 deploys secondary-region resources and configures cross-region replication for every service layer. **Always run a dry run first.**

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd ../step3-enable-secondary
bash ./scripts/orchestrate-secondary.sh --topology ../config/topology.json --dry-run

# After reviewing the plan, run the real deployment:
bash ./scripts/orchestrate-secondary.sh --topology ../config/topology.json --yes
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location (Join-Path $RepoRoot "step3-enable-secondary")

bash ./scripts/orchestrate-secondary.sh --topology ../config/topology.json --dry-run

# After reviewing the plan, run the real deployment:
bash ./scripts/orchestrate-secondary.sh --topology ../config/topology.json --yes
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the dry run first and review the output carefully.
2. In the Azure portal, watch secondary-region resource groups and deployment operations appear only after you launch the real enablement step.
3. Verify the target region shown in the dry run matches your topology manifest.
4. Do not continue until the orchestration completes and the secondary resources finish provisioning.

      </div>
    </div>

> **⏱ This step takes 20–35 minutes.** It deploys in dependency order — infrastructure first, then data-tier replication, then compute, then networking/DNS.

The dry run should confirm that:

- ✅ All expected services are listed
- ✅ The target region matches your topology
- ✅ Replication strategies are appropriate (for example, async for Storage and failover groups for SQL)
- ✅ No service gaps exist because of regional availability limitations

---

### 7. Verify Cross-Region Configuration

After Step 3 completes, verify every cross-region replication relationship.

#### SQL Database — Failover Group ([Lab 2-a](lab-02a-sql-geo-replication.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group list -g rg-data-swedencentral -s <primary-sql-server> -o table
az sql failover-group show -g rg-data-swedencentral -s <primary-sql-server> -n <fg-name> --query "replicationState" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az sql failover-group list -g rg-data-swedencentral -s <primary-sql-server> -o table
az sql failover-group show -g rg-data-swedencentral -s <primary-sql-server> -n <fg-name> --query "replicationState" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary SQL server.
2. Go to **Failover groups**.
3. Confirm the failover group exists and the secondary server is attached.
4. Verify the replication state is healthy (`CATCH_UP` or `SYNCHRONIZED`).

      </div>
    </div>

#### Cosmos DB — Multi-Region ([Lab 3-a](lab-03a-cosmos-global-distribution.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az cosmosdb show -g rg-data-swedencentral -n <cosmos-account> --query "readLocations[].{region: locationName, priority: failoverPriority}" -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az cosmosdb show -g rg-data-swedencentral -n <cosmos-account> --query "readLocations[].{region: locationName, priority: failoverPriority}" -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Cosmos DB account.
2. Go to **Replicate data globally**.
3. Confirm both **Sweden Central** and **Norway East** appear in the regional map and the priorities match your design.

      </div>
    </div>

#### Storage — Object Replication ([Lab 1-a](lab-01a-blob-storage-replication.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az storage account or-policy list --account-name <primary-storage> -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az storage account or-policy list --account-name <primary-storage> -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary storage account.
2. Go to **Data management** → **Object replication**.
3. Confirm the replication policy targets the secondary account and reports a healthy state.

      </div>
    </div>

#### Service Bus — Geo-DR Alias ([Lab 9-a](lab-09a-service-bus-geo-dr.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az servicebus georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-sb-namespace> --alias <alias-name> --query "role" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az servicebus georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-sb-namespace> --alias <alias-name> --query "role" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary Service Bus namespace.
2. Go to **Geo-recovery**.
3. Confirm the alias exists and the namespace reports the **Primary** role.

      </div>
    </div>

#### Key Vault — Secret Sync ([Lab 8-a](lab-08a-key-vault-multi-region.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az keyvault secret list --vault-name <secondary-keyvault> --query "[].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az keyvault secret list --vault-name <secondary-keyvault> --query "[].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the secondary Key Vault.
2. Go to **Secrets**.
3. Confirm the expected application secrets exist in the secondary vault.

      </div>
    </div>

#### Event Hubs — Geo-Replication ([Lab 10-a](lab-10a-event-hubs-geo-replication.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az eventhubs georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-eh-namespace> --alias <eh-alias-name> --query "role" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az eventhubs georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-eh-namespace> --alias <eh-alias-name> --query "role" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary Event Hubs namespace.
2. Go to **Geo-recovery**.
3. Confirm the alias exists and the namespace role is healthy.

      </div>
    </div>

#### Container Registry — Geo-Replica ([Lab 11-a](lab-11a-acr-geo-replication.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az acr replication list -r <acr-name> -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az acr replication list -r <acr-name> -o table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Azure Container Registry.
2. Go to **Replications**.
3. Confirm a Norway East replication exists and is healthy.

      </div>
    </div>

#### Front Door / Traffic Manager — Global Endpoint ([Lab 7-a](lab-07a-webapp-traffic-manager.md))

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network front-door show -g rg-global -n <frontdoor-name> --query "backendPools[0].backends[].address" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network front-door show -g rg-global -n <frontdoor-name> --query "backendPools[0].backends[].address" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open Azure Front Door or Traffic Manager.
2. Confirm both primary and secondary backends/origins are configured.
3. Verify health probes show the expected backend as healthy before you test failover.

      </div>
    </div>

---

### 8. Test the Running Application

With both regions fully deployed and all replication configured, access the application through the global endpoint.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
GLOBAL_URL=$(az network front-door show -g rg-global -n <frontdoor-name> --query "frontendEndpoints[0].hostName" -o tsv)

echo "Application URL: https://$GLOBAL_URL"
curl -s "https://$GLOBAL_URL/health"
curl -s "https://$GLOBAL_URL/api/status" | jq .
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$GLOBAL_URL = az network front-door show -g rg-global -n <frontdoor-name> --query "frontendEndpoints[0].hostName" -o tsv

Write-Host "Application URL: https://$GLOBAL_URL"
Invoke-RestMethod "https://$GLOBAL_URL/health" | ConvertTo-Json -Depth 10
Invoke-RestMethod "https://$GLOBAL_URL/api/status" | ConvertTo-Json -Depth 10
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open Azure Front Door / Traffic Manager and copy the public frontend hostname.
2. Browse to the application URL.
3. Confirm the health or status endpoint reports the primary region (`swedencentral`).
4. Verify the application is healthy before you simulate a failure.

      </div>
    </div>

You should see a healthy response served from Sweden Central (the primary). Front Door / Traffic Manager directs all traffic to the primary while it is healthy.

---

### 9. Simulate a Disaster

Now test that coordinated failover actually works. There are two approaches.

#### Trigger the Failure

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
# Option A: stop primary compute
az webapp stop -g rg-app-swedencentral -n <primary-app-name>
az functionapp stop -g rg-app-swedencentral -n <primary-functions-name>

# Option B: start a Chaos Studio experiment instead
az rest --method POST --url "https://management.azure.com/subscriptions/<sub-id>/resourceGroups/rg-chaos/providers/Microsoft.Chaos/experiments/<experiment-name>/start?api-version=2024-01-01"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Option A: stop primary compute
az webapp stop -g rg-app-swedencentral -n <primary-app-name>
az functionapp stop -g rg-app-swedencentral -n <primary-functions-name>

# Option B: start a Chaos Studio experiment instead
az rest --method POST --url "https://management.azure.com/subscriptions/<sub-id>/resourceGroups/rg-chaos/providers/Microsoft.Chaos/experiments/<experiment-name>/start?api-version=2024-01-01"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. For a simple test, open the primary **Web App** and **Function App** and use **Stop**.
2. For a more realistic drill, open **Chaos Studio** and start the experiment that targets the primary compute tier.
3. Record the time you initiated the fault so you can compare it with the observed failover time.

      </div>
    </div>

#### Monitor the Failover

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
for i in $(seq 1 20); do
  RESPONSE=$(curl -s "https://$GLOBAL_URL/health" 2>/dev/null)
  REGION=$(echo "$RESPONSE" | jq -r '.region // "unreachable"')
  echo "$(date +%H:%M:%S) — Region: $REGION"
  sleep 15
done

curl -s "https://$GLOBAL_URL/health"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
for ($i = 1; $i -le 20; $i++) {
  try {
    $Response = Invoke-RestMethod "https://$GLOBAL_URL/health"
    $Region = $Response.region
  } catch {
    $Region = 'unreachable'
  }
  Write-Host "$(Get-Date -Format HH:mm:ss) — Region: $Region"
  Start-Sleep -Seconds 15
}

Invoke-RestMethod "https://$GLOBAL_URL/health" | ConvertTo-Json -Depth 10
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Watch the global endpoint from a browser or the Front Door / Traffic Manager monitoring views.
2. Confirm the primary backend starts failing health probes.
3. Within the expected health probe and DNS interval, verify requests begin landing in **Norway East**.
4. Keep notes on the observed failover time so you can compare it with your target RTO.

      </div>
    </div>

After 30–90 seconds (depending on health probe interval and DNS TTL), the health response should come from `norwayeast`.

The key observation: **the global endpoint URL did not change.** Front Door / Traffic Manager detected the primary failure through health probes and automatically routed traffic to the secondary in Norway East.

---

### 10. Verify Failover — All Layers

Failover is not just about compute. Verify that every service layer is operating correctly from the secondary region.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
curl -s "https://$GLOBAL_URL/api/status" | jq '.region'
az sql failover-group show -g rg-data-swedencentral -s <primary-sql-server> -n <fg-name> --query "{primary: replicationRole, state: replicationState}" -o json
curl -s "https://$GLOBAL_URL/api/data/test" | jq '.source'
az servicebus georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-sb-namespace> --alias <alias-name> --query "pendingReplicationOperationsCount" -o tsv
az keyvault secret show --vault-name <secondary-keyvault> -n app-connection-string --query "id" -o tsv
az storage blob list --account-name <secondary-storage> -c app-data --query "[].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
(Invoke-RestMethod "https://$GLOBAL_URL/api/status").region
az sql failover-group show -g rg-data-swedencentral -s <primary-sql-server> -n <fg-name> --query "{primary: replicationRole, state: replicationState}" -o json
(Invoke-RestMethod "https://$GLOBAL_URL/api/data/test").source
az servicebus georecovery-alias show -g rg-messaging-swedencentral --namespace-name <primary-sb-namespace> --alias <alias-name> --query "pendingReplicationOperationsCount" -o tsv
az keyvault secret show --vault-name <secondary-keyvault> -n app-connection-string --query "id" -o tsv
az storage blob list --account-name <secondary-storage> -c app-data --query "[].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm the application now reports **Norway East** in its status endpoint or UI.
2. Check the SQL failover group, Cosmos DB regional map, Service Bus alias, and storage replication state in the portal.
3. Verify the secondary Key Vault contains the expected application secrets without exposing secret values unnecessarily.
4. Confirm the storage account in the secondary region contains the expected application data.

      </div>
    </div>

> **🔑 Key insight:** In a production scenario, SQL Failover Group failover is **automatic** (when configured in auto-failover mode). Service Bus and Event Hubs alias failover must be **manually initiated** (or automated via runbook). Cosmos DB handles failover **automatically** when automatic failover is enabled. Understanding which services fail over automatically vs. manually is critical for your RTO.

---

### 11. Discuss Failback

Failover gets the headlines, but **failback** is often more complex and less tested. Review the prototype's failover runbook:

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
cat docs/failover-runbook.md
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Set-Location (git rev-parse --show-toplevel)
Get-Content ./docs/failover-runbook.md
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open `docs/failover-runbook.md` in your editor or in the repository browser.
2. Review the documented failback sequencing before you restore primary traffic.
3. Make sure the on-call and operations assumptions in the runbook match your environment.

      </div>
    </div>

Key failback considerations:

1. **Data synchronization direction reversal** — after failover, the secondary becomes the new primary for writes. Before failing back, you need to ensure data written to the (former) secondary is replicated back to the original primary.
2. **SQL Failover Group failback** — reverse the failover group so the original primary becomes primary again. This requires the original primary to be healthy and caught up.
3. **Service Bus re-pairing** — after a geo-DR failover, the pairing is **broken**. You must delete the old pairing and re-create it in the original direction. This is not instantaneous.
4. **Cosmos DB region priority** — update the failover priority list to restore the original primary as the preferred write region.
5. **DNS TTL propagation** — Front Door / Traffic Manager DNS changes take time to propagate. Monitor TTL expiration to confirm all clients are routing correctly.
6. **Application state** — clear caches, reset circuit breakers, and verify connection pools have reconnected to the restored primary.

> **⚠️ Warning:** Never fail back without verifying that the original primary region is fully healthy and all data replication has caught up. A premature failback can cause data loss or split-brain scenarios.

For detailed step-by-step failback procedures, see: [`docs/failover-runbook.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/failover-runbook.md)

---

### 12. Restore Primary Services

If you used Option A (manual stoppage), restart the primary services.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az webapp start -g rg-app-swedencentral -n <primary-app-name>
az functionapp start -g rg-app-swedencentral -n <primary-functions-name>

PRIMARY_APP_URL=$(az webapp show -g rg-app-swedencentral -n <primary-app-name> --query defaultHostName -o tsv)
curl -s "https://$PRIMARY_APP_URL/health"

for i in $(seq 1 10); do
  REGION=$(curl -s "https://$GLOBAL_URL/health" | jq -r '.region // "unknown"')
  echo "$(date +%H:%M:%S) — Serving from: $REGION"
  sleep 15
done
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az webapp start -g rg-app-swedencentral -n <primary-app-name>
az functionapp start -g rg-app-swedencentral -n <primary-functions-name>

$PRIMARY_APP_URL = az webapp show -g rg-app-swedencentral -n <primary-app-name> --query defaultHostName -o tsv
Invoke-RestMethod "https://$PRIMARY_APP_URL/health" | ConvertTo-Json -Depth 10

for ($i = 1; $i -le 10; $i++) {
  $Region = (Invoke-RestMethod "https://$GLOBAL_URL/health").region
  Write-Host "$(Get-Date -Format HH:mm:ss) — Serving from: $Region"
  Start-Sleep -Seconds 15
}
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Start the primary web app and function app from their **Overview** blades.
2. Watch Front Door / Traffic Manager health probes turn green again for the primary backend.
3. Confirm the application eventually serves from **Sweden Central** again if your design supports automatic failback.
4. Record the recovery time and any operational surprises.

      </div>
    </div>

Within a few minutes, Front Door / Traffic Manager should detect the primary is healthy again and route traffic back if your configuration supports it.

---

### 13. Cost Management

Multi-region deployments double (or more) your resource costs. The prototype includes scripts to manage costs effectively.

#### Pause All Resources

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
bash ./scripts/pause-all.sh --topology ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/pause-all.sh --topology ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the pause script from Cloud Shell or your workstation.
2. In the portal, verify compute resources show **Stopped** or scaled down afterward.
3. Confirm databases or clusters that should remain allocated are still reachable according to the script's behavior.

      </div>
    </div>

This script:

- Stops App Service plans (or scales to zero)
- Deallocates VMs / AKS node pools
- Pauses SQL databases (if using serverless tier)
- Does **not** delete data or break replication — resources remain deployed but idle

#### Resume All Resources

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
bash ./scripts/resume-all.sh --topology ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/resume-all.sh --topology ./config/topology.json
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the resume script from Cloud Shell or your workstation.
2. In the portal, confirm the paused resources return to a healthy running state.
3. Recheck the application health endpoint after resume completes.

      </div>
    </div>

Restarts all paused resources and verifies health across both regions.

#### Decouple Secondary

If you want to keep the primary running but remove the secondary to save costs:

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
bash ./scripts/decouple-secondary.sh --topology ./config/topology.json --yes
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/decouple-secondary.sh --topology ./config/topology.json --yes
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Use this option only when you intentionally want to break secondary-region protection.
2. Run the script from Cloud Shell or your workstation.
3. In the portal, verify the replication relationships are removed cleanly before any secondary resources are deleted.

      </div>
    </div>

This cleanly breaks all cross-region replication relationships before removing secondary resources. It is preferable to directly deleting secondary resource groups, which could leave orphaned replication configurations on the primary side.

---

### 14. Cleanup

When you are done with the lab, remove all deployed resources.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
cd "$(git rev-parse --show-toplevel)"
bash ./scripts/cleanup-all.sh --topology ./config/topology.json --yes

az group list --query "[?starts_with(name, 'rg-contoso-') || starts_with(name, 'MC_rg-contoso-')].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

bash ./scripts/cleanup-all.sh --topology ./config/topology.json --yes

az group list --query "[?starts_with(name, 'rg-contoso-') || starts_with(name, 'MC_rg-contoso-')].name" -o tsv
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Run the cleanup script from Cloud Shell or your workstation.
2. In the Azure portal, refresh **Resource groups** and confirm the lab groups disappear as the cleanup progresses.
3. If you use soft-delete features such as Key Vault recovery, verify any optional purge steps before you walk away.

      </div>
    </div>

The cleanup script:

1. Breaks all replication relationships (geo-DR pairings, failover groups, object replication policies)
2. Removes Front Door / Traffic Manager global endpoint
3. Deletes secondary region resource groups
4. Deletes primary region resource groups
5. Removes the global resource group
6. Purges soft-deleted Key Vaults (optional — prompts for confirmation)

> **⚠️ This is destructive and irreversible.** Verify you want to remove everything before confirming.

---

## End-to-End Validation Checklist

Before considering this lab complete, verify each item:

| # | Check | Status |
|---|-------|--------|
| 1 | Prototype repo cloned and topology configured | ☐ |
| 2 | Upstream samples bootstrapped via `fetch-samples.sh` | ☐ |
| 3 | Step 1: primary baseline deployed and all services healthy | ☐ |
| 4 | Step 2: discovery completed with Norway East as top recommendation | ☐ |
| 5 | Step 3: dry run reviewed, then secondary region enabled | ☐ |
| 6 | SQL failover group created and synchronized | ☐ |
| 7 | Cosmos DB shows both regions as read locations | ☐ |
| 8 | Storage object replication policy active | ☐ |
| 9 | Service Bus geo-DR alias resolving correctly | ☐ |
| 10 | Key Vault secrets synced to secondary vault | ☐ |
| 11 | Front Door / Traffic Manager routing to primary | ☐ |
| 12 | Application accessible via global endpoint | ☐ |
| 13 | Disaster simulation: primary stopped or chaos injected | ☐ |
| 14 | Application continued serving from secondary region | ☐ |
| 15 | Primary restored and traffic resumed | ☐ |
| 16 | Failback discussion reviewed (`docs/failover-runbook.md`) | ☐ |
| 17 | Cleanup completed (or resources paused for cost savings) | ☐ |

---

## Discussion Questions

Use these questions to deepen your understanding of enterprise multi-region resilience.

### Coordinated Failover Sequencing

> In what order should services fail over? Does it matter?

Yes — ordering matters critically. A recommended failover sequence:

1. **DNS / Global Load Balancer** — stop routing new requests to the primary
2. **Data tier** (SQL, Cosmos DB) — ensure writes go to the secondary
3. **Messaging tier** (Service Bus, Event Hubs) — switch aliases so producers/consumers reconnect
4. **Secrets / Config** (Key Vault, App Configuration) — ensure secondary compute reads from secondary vault
5. **Compute tier** (App Service, Functions, AKS) — secondary starts processing requests
6. **Monitoring & Alerting** — update dashboards and alert routing to reflect the new active region

The data tier must fail over *before* compute to avoid the secondary app writing to a stale or unreachable primary database. Messaging must fail over before compute starts processing to avoid message loss.

### RTO and RPO at the Application Level

> Your SQL database has RPO < 5 seconds and RTO < 30 seconds. Your Service Bus has RPO = 0 for metadata but potentially loses in-flight messages. What is your *application-level* RTO and RPO?

Application-level RTO/RPO is determined by the **slowest / most-lossy** component, not the best one:

| Service | RPO | RTO |
|---------|-----|-----|
| SQL Failover Group | < 5 seconds | ~30 seconds |
| Cosmos DB (multi-region) | ~0 (strong consistency) or seconds (session) | ~0 (automatic) |
| Service Bus (geo-DR) | Metadata: 0; Messages: **unbounded** | 1–2 minutes |
| Storage (object replication) | Minutes (async) | N/A (read-only destination) |
| Key Vault (backup/sync) | Last sync interval | Manual restore time |

Your effective application RPO includes any in-flight Service Bus messages. Your application RTO is the time for *all* layers to fail over and the global endpoint to re-route — typically **2–5 minutes** with Front Door.

### Operational Readiness Checklist

An operational readiness checklist for multi-region applications should include:

- [ ] Failover runbook documented and reviewed quarterly
- [ ] Failover tested in production (or production-like environment) at least twice per year
- [ ] Monitoring alerts configured for replication lag on every cross-region link
- [ ] On-call team trained on manual failover steps for services that don't auto-failover
- [ ] DNS TTL values set appropriately (low enough for fast failover, high enough to avoid DNS storms)
- [ ] Cost model includes secondary region resources (even when idle)
- [ ] Data residency and compliance implications of each candidate region documented
- [ ] Chaos Studio experiments defined for all critical failure scenarios
- [ ] Runbook for partial failures (single service down, not entire region)

### Failback Complexity

> Why is failback harder than failover?

During failover, the direction of data flow is clear: primary → secondary. During failback, data may have been written to both the secondary (during the outage) and the primary (if it partially recovered). Reconciling these writes — especially for services like Service Bus that don't replicate messages — requires application-specific logic.

Additional complications:

- **Service Bus geo-DR pairing is broken** after failover and must be re-established from scratch
- **SQL failover group** requires the original primary to be fully caught up before reversing roles
- **Object replication** is one-directional — objects written to the destination during failover are not automatically replicated back
- **Key Vault** secrets created on the secondary during failover must be manually synced back
- **DNS caching** means some clients may continue hitting the secondary even after failback completes

---

## Key Reference Documents

The prototype repository contains detailed documentation for day-2 operations:

| Document | Description |
|----------|-------------|
| [`docs/architecture.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/architecture.md) | Full architecture documentation with component diagrams |
| [`docs/OPERATIONS.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/OPERATIONS.md) | Day-2 operational procedures, monitoring, and maintenance |
| [`docs/REGION-SELECTION.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/REGION-SELECTION.md) | Region scoring methodology and selection criteria |
| [`docs/failover-runbook.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/failover-runbook.md) | Step-by-step failover and failback procedures |
| [`docs/service-matrix.md`](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype/blob/main/docs/service-matrix.md) | Per-service availability and feature matrix across regions |

---


## Discussion & Next Steps

If you want to harden this capstone after you finish the baseline path, continue with [Lab 14-b](lab-14b-enterprise-prototype-secure-networking.md). The secure variant keeps the same three-step prototype workflow, but assumes Lab 0, reuses the fixed hub-and-spoke landing zone, and pushes supported dependencies behind private endpoints.

| Variant | Best fit | Network posture |
|---|---|---|
| **Lab 14-a** | You want the original capstone experience with the fewest prerequisites | Public/global entry point with service-native replication |
| **Lab 14-b** | You want the same capstone inside a reusable secure landing zone | Hub-and-spoke networking, private endpoints, spoke-based workload placement |

[Lab 14-a — Enterprise Prototype](lab-14a-enterprise-prototype.md) | [Next: Lab 14-b — Secure Networking →](lab-14b-enterprise-prototype-secure-networking.md)
