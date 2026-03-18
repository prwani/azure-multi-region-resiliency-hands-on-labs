---
layout: default
title: "Lab 10: Integrated Enterprise App – Multi-Region Prototype"
---

[← Back to Index](../index.md)

# Lab 10: Integrated Enterprise App – Multi-Region Prototype

> **Capstone Lab — Deploy a fully integrated multi-region enterprise application using the topology-driven prototype, configure every service layer for cross-region resilience, and validate coordinated failover end-to-end.**

---

## Why End-to-End Multi-Region Matters

In Labs 1–9 you learned how to make **individual** Azure services resilient across regions: web apps behind Traffic Manager, SQL with failover groups, Cosmos DB with multi-region writes, Storage with object replication, Key Vault backup and sync, Service Bus geo-DR aliases, Event Hubs geo-replication, ACR geo-replicas, and Data Factory active/passive pipelines.

Each of those labs solves one piece of the puzzle. But here is the hard truth:

> **Individual service DR is necessary but not sufficient.** A real enterprise application is a *system* — web tier, data tier, messaging tier, secrets management, container registry, networking — all wired together. If your SQL database fails over but your app's connection strings still point to the old primary, you're down. If your Service Bus alias switches but your Functions don't know about it, messages are lost. If your Front Door health probe passes but the backend is reading stale secrets from the wrong Key Vault, you have silent data corruption.

**Coordinated failover** across every layer is the real enterprise challenge. It requires:

- A **single source of truth** for topology — which subscriptions, which regions, which services, which feature flags
- An **orchestrated deployment** that provisions primary infrastructure, discovers the best secondary region, and enables cross-region replication in the right order
- A **tested failover runbook** that sequences the switchover so dependent services fail over *after* their dependencies
- A **failback plan** that is just as tested as the failover

This lab uses the **[multi-region-nonpaired-enterprise-prototype](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype)** repository as the reference implementation. The prototype implements a three-step deployment model — Primary Baseline → Discover & Recommend → Enable Secondary — driven by a topology manifest. You will deploy it, configure it, test failover, and understand how all the pieces fit together.

> **⏱ Estimated time:** 2–3 hours (shorter if you already have resources from Labs 1–9)

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
| Web / Compute | Active-passive App Service + Traffic Manager or Front Door | [Lab 1](lab-01-webapp-traffic-manager.md) |
| Blob Storage | Object Replication (async, change-feed-based) | [Lab 2](lab-02-blob-storage-replication.md) |
| SQL Database | Active Geo-Replication + Failover Group | [Lab 3](lab-03-sql-geo-replication.md) |
| Cosmos DB | Multi-region writes with automatic failover | [Lab 4](lab-04-cosmos-global-distribution.md) |
| Key Vault | Backup / restore sync to secondary vault | [Lab 5](lab-05-key-vault-multi-region.md) |
| Service Bus | Geo-DR alias (metadata replication) | [Lab 6](lab-06-service-bus-geo-dr.md) |
| Event Hubs | Geo-replication with consumer-group failover | [Lab 7](lab-07-event-hubs-geo-replication.md) |
| Container Registry | Premium geo-replicated ACR | [Lab 8](lab-08-acr-geo-replication.md) |
| Data Factory | Active/passive pipeline duplication | [Lab 9](lab-09-data-factory-dr.md) |

### Three-Step Deployment Model

The prototype decomposes multi-region enablement into three sequential steps:

```
┌──────────────────────┐     ┌───────────────────────┐     ┌──────────────────────┐
│  Step 1               │     │  Step 2                │     │  Step 3               │
│  Primary Baseline     │────►│  Discover & Recommend  │────►│  Enable Secondary     │
│                       │     │                        │     │                       │
│  • Provision all      │     │  • Scan ARM for        │     │  • Deploy secondary   │
│    primary-region     │     │    service availability │     │    region resources   │
│    resources          │     │  • Score candidate      │     │  • Enable replication │
│  • Deploy app code    │     │    regions (weighted)   │     │  • Configure aliases  │
│  • Validate health    │     │  • Output per-service   │     │  • Wire up Front Door │
│                       │     │    recommendations      │     │  • Run smoke tests    │
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

This lab assumes you are comfortable with the concepts introduced in Labs 1–9. You do not need to have the resources from those labs still running, but you should understand:

- **[Lab 1](lab-01-webapp-traffic-manager.md):** Traffic Manager profiles, priority-based routing, health probes, Chaos Studio fault injection
- **[Lab 2](lab-02-blob-storage-replication.md):** Storage account versioning, change feed, object replication policies
- **[Lab 3](lab-03-sql-geo-replication.md):** SQL active geo-replication, failover groups, read-only listener endpoints
- **[Lab 4](lab-04-cosmos-global-distribution.md):** Cosmos DB multi-region writes, consistency levels, automatic failover policies
- **[Lab 5](lab-05-key-vault-multi-region.md):** Key Vault backup/restore, cross-region secret synchronization
- **[Lab 6](lab-06-service-bus-geo-dr.md):** Service Bus Premium namespaces, geo-DR pairing, alias FQDNs, metadata-only replication
- **[Lab 7](lab-07-event-hubs-geo-replication.md):** Event Hubs geo-replication, consumer group offset management
- **[Lab 8](lab-08-acr-geo-replication.md):** ACR Premium tier, geo-replication, region-local pulls
- **[Lab 9](lab-09-data-factory-dr.md):** Data Factory pipeline duplication, linked service reconfiguration

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

### Azure Requirements

- **Azure subscription** with **Contributor** or **Owner** role
- Ability to create resources in **Sweden Central** and **Norway East** (or your chosen region pair)
- For multi-subscription deployments: a second subscription for Fabric resources (see topology manifest)
- Sufficient quota for: App Service plans, SQL databases, Cosmos DB accounts, Storage accounts, Service Bus Premium namespaces, Key Vaults, and Azure Front Door

### Verify Your Environment

```bash
# Verify all required tools are installed
az version          # Azure CLI 2.60+
azd version         # Azure Developer CLI
pwsh --version      # PowerShell 7+
jq --version        # jq 1.6+
git --version       # Git 2.x

# Authenticate
az login
az account show     # Confirm correct subscription
```

---

## Step-by-Step Instructions

### 1. Clone the Prototype Repository

```bash
git clone https://github.com/prwani/multi-region-nonpaired-enterprise-prototype.git
cd multi-region-nonpaired-enterprise-prototype
```

Take a moment to explore the repository structure:

```bash
ls -la
```

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

```bash
cp config/topology.example.json config/topology.json
```

Open `config/topology.json` in your editor and fill in your values:

```jsonc
{
  "subscriptions": {
    "primary": "<your-primary-subscription-id>",
    "fabric": "<your-fabric-subscription-id-or-same-as-primary>"
  },
  "regions": {
    "primary": "swedencentral",
    "secondary": "norwayeast"
  },
  "domains": {
    "app": "myapp.example.com",
    "api": "api.myapp.example.com"
  },
  "featureFlags": {
    "enableFabric": false,
    "enableDatabricks": false,
    "enableEventHubs": true,
    "enableServiceBus": true,
    "multiRegionWrites": true
  }
}
```

> **💡 Multi-subscription support:** If your organization requires Fabric resources in a separate subscription, set `subscriptions.fabric` to the Fabric subscription ID. Otherwise, use the same ID as `primary`.

> **💡 Feature flags:** Disable optional services (Fabric, Databricks) if you don't have the prerequisites. The deployment scripts respect these flags and skip disabled components.

### 3. Bootstrap Upstream Samples

The prototype pulls in code from several upstream repositories. The fetch script clones them into the correct local paths:

```bash
./scripts/fetch-samples.sh
```

This fetches samples from:

| Upstream Repository | Purpose |
|---------------------|---------|
| [Azure/AI-Landing-Zones](https://github.com/Azure/AI-Landing-Zones) | AI workload landing zone patterns |
| [Azure/AzRegionSelection](https://github.com/Azure/AzRegionSelection) | Region scoring and selection tooling |
| [Azure-Samples/aks-store-demo](https://github.com/Azure-Samples/aks-store-demo) | Sample AKS store application |
| [fabric-samples-healthcare](https://github.com/microsoft/fabric-samples) | Healthcare sample for Fabric integration |

Verify the samples were fetched:

```bash
ls samples/
```

---

### 4. Step 1 — Deploy Primary Baseline

Step 1 provisions all primary-region resources: the App Service or AKS cluster, Azure Functions, SQL Database, Cosmos DB account, Storage accounts, Key Vault, Service Bus namespace, and networking infrastructure.

```bash
cd step1-primary-baseline
./scripts/deploy.sh --topology ../config/topology.json
```

> **⏱ This step takes 15–25 minutes** depending on the services enabled in your topology.

The deploy script:

1. Reads the topology manifest to determine subscriptions, primary region, and enabled features
2. Creates resource groups with consistent naming (`rg-<purpose>-<region>`)
3. Deploys infrastructure using Bicep/ARM templates
4. Deploys application code to compute resources
5. Configures networking (VNet, NSGs, Private Endpoints where applicable)
6. Outputs a summary of deployed resources

#### Verify Primary Deployment

After the deployment completes, verify all services are running:

```bash
# Check resource groups were created
az group list --query "[?location=='swedencentral'].name" -o tsv

# Verify the web app is responding
PRIMARY_APP_URL=$(az webapp show \
  -g rg-app-swedencentral \
  -n <your-app-name> \
  --query defaultHostName -o tsv)
curl -s -o /dev/null -w "%{http_code}" "https://$PRIMARY_APP_URL/health"
# Expected: 200

# Verify SQL is accessible
az sql server list -g rg-data-swedencentral -o table

# Verify Cosmos DB account
az cosmosdb show \
  -g rg-data-swedencentral \
  -n <your-cosmos-account> \
  --query "readLocations[].locationName" -o tsv

# Verify Service Bus namespace
az servicebus namespace show \
  -g rg-messaging-swedencentral \
  -n <your-sb-namespace> \
  --query status -o tsv
# Expected: Active

# Verify Key Vault
az keyvault show \
  -g rg-security-swedencentral \
  -n <your-keyvault> \
  --query "properties.provisioningState" -o tsv
# Expected: Succeeded
```

> **📝 Note:** The deploy script outputs the actual resource names. Replace the `<your-*>` placeholders above with those values.

At this point you have a fully working single-region application. This mirrors what many teams have in production — and it is exactly what needs multi-region protection.

**Cross-reference — this step combines concepts from:**
- [Lab 1 — Web App deployment](lab-01-webapp-traffic-manager.md) (App Service provisioning)
- [Lab 3 — SQL Database creation](lab-03-sql-geo-replication.md) (SQL Server + database)
- [Lab 4 — Cosmos DB setup](lab-04-cosmos-global-distribution.md) (single-region Cosmos account)
- [Lab 5 — Key Vault creation](lab-05-key-vault-multi-region.md) (primary Key Vault)
- [Lab 6 — Service Bus namespace](lab-06-service-bus-geo-dr.md) (Premium namespace)

---

### 5. Step 2 — Discover & Recommend Secondary Region

Step 2 scans the Azure Resource Manager API, evaluates candidate secondary regions, and produces a recommendation report.

```bash
cd ../step2-discover-recommend
pwsh scripts/run-discovery.ps1 -TopologyFile ../config/topology.json
```

The discovery script:

1. **Inventories deployed services** — scans your primary resource groups to catalog every resource type
2. **Queries ARM for service availability** — checks which candidate regions support each deployed service
3. **Scores candidate regions** using the weighted model:

   | Criterion | Weight |
   |-----------|--------|
   | Service coverage | 40% |
   | Availability Zone support | 25% |
   | Cost (relative pricing) | 20% |
   | Network latency | 10% |
   | Compliance / data residency | 5% |

4. **Produces three outputs:**
   - **Discovery report** — full inventory of primary resources and their replication options
   - **Region scoring matrix** — ranked list of candidate regions with composite scores
   - **Per-service recommendations** — specific replication strategy for each service

#### Review the Outputs

```bash
# View the discovery report
cat output/discovery-report.json | jq \
  '.services[] | {type: .resourceType, replicationOptions: .replicationOptions}'

# View the region scoring results
cat output/region-scores.json | jq \
  '.regions | sort_by(-.compositeScore) | .[:5]'

# View per-service recommendations
cat output/recommendations.json | jq \
  '.recommendations[] | {service: .service, strategy: .recommendedStrategy, targetRegion: .targetRegion}'
```

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

If you want to use a different secondary region, update `config/topology.json` and re-run discovery.

---

### 6. Step 3 — Enable Secondary Region

Step 3 deploys secondary-region resources and configures cross-region replication for every service layer. **Always run a dry run first.**

#### 6a. Dry Run

```bash
cd ../step3-enable-secondary
./scripts/orchestrate-secondary.sh --topology ../config/topology.json --dry-run
```

The dry run:

- Shows every resource that will be created in the secondary region
- Lists every cross-region replication relationship that will be established
- Estimates deployment time and cost impact
- Validates that the secondary region supports all required services
- **Does not create any resources**

Review the dry-run output carefully. Check that:

- ✅ All expected services are listed
- ✅ The target region matches your topology
- ✅ Replication strategies are appropriate (e.g., async for Storage, failover-group for SQL)
- ✅ No service gaps due to regional availability limitations

#### 6b. Execute Secondary Enablement

When you're satisfied with the dry run, execute for real:

```bash
./scripts/orchestrate-secondary.sh --topology ../config/topology.json
```

> **⏱ This step takes 20–35 minutes.** It deploys in dependency order — infrastructure first, then data-tier replication, then compute, then networking/DNS.

The orchestration script configures each service layer in sequence:

---

### 7. Verify Cross-Region Configuration

After Step 3 completes, verify every cross-region replication relationship.

#### SQL Database — Failover Group ([Lab 3](lab-03-sql-geo-replication.md))

```bash
# Verify the failover group was created
az sql failover-group list \
  -g rg-data-swedencentral \
  -s <primary-sql-server> -o table

# Check replication state
az sql failover-group show \
  -g rg-data-swedencentral \
  -s <primary-sql-server> \
  -n <fg-name> \
  --query "replicationState" -o tsv
# Expected: CATCH_UP or SYNCHRONIZED
```

#### Cosmos DB — Multi-Region ([Lab 4](lab-04-cosmos-global-distribution.md))

```bash
# Verify both regions are active
az cosmosdb show \
  -g rg-data-swedencentral \
  -n <cosmos-account> \
  --query "readLocations[].{region: locationName, priority: failoverPriority}" -o table
```

#### Storage — Object Replication ([Lab 2](lab-02-blob-storage-replication.md))

```bash
# Verify replication policy
az storage account or-policy list \
  --account-name <primary-storage> -o table
```

#### Service Bus — Geo-DR Alias ([Lab 6](lab-06-service-bus-geo-dr.md))

```bash
# Verify alias is active
az servicebus georecovery-alias show \
  -g rg-messaging-swedencentral \
  --namespace-name <primary-sb-namespace> \
  --alias <alias-name> \
  --query "role" -o tsv
# Expected: Primary
```

#### Key Vault — Secret Sync ([Lab 5](lab-05-key-vault-multi-region.md))

```bash
# Verify secrets exist in secondary vault
az keyvault secret list \
  --vault-name <secondary-keyvault> \
  --query "[].name" -o tsv
```

#### Event Hubs — Geo-Replication ([Lab 7](lab-07-event-hubs-geo-replication.md))

```bash
# Verify geo-replication status (if Event Hubs enabled)
az eventhubs georecovery-alias show \
  -g rg-messaging-swedencentral \
  --namespace-name <primary-eh-namespace> \
  --alias <eh-alias-name> \
  --query "role" -o tsv
```

#### Container Registry — Geo-Replica ([Lab 8](lab-08-acr-geo-replication.md))

```bash
# Verify replications (if ACR is used)
az acr replication list -r <acr-name> -o table
```

#### Front Door / Traffic Manager — Global Endpoint ([Lab 1](lab-01-webapp-traffic-manager.md))

```bash
# Verify both backends are configured
az network front-door show \
  -g rg-global \
  -n <frontdoor-name> \
  --query "backendPools[0].backends[].address" -o tsv
# Should show both primary and secondary app URLs
```

---

### 8. Test the Running Application

With both regions fully deployed and all replication configured, access the application through the global endpoint:

```bash
# Get the global endpoint URL
GLOBAL_URL=$(az network front-door show \
  -g rg-global \
  -n <frontdoor-name> \
  --query "frontendEndpoints[0].hostName" -o tsv)

echo "Application URL: https://$GLOBAL_URL"

# Test the health endpoint
curl -s "https://$GLOBAL_URL/health"
# Expected: {"status":"healthy","region":"swedencentral","timestamp":"..."}

# Verify data flows end-to-end
curl -s "https://$GLOBAL_URL/api/status" | jq .
```

You should see a healthy response served from Sweden Central (the primary). Traffic Manager / Front Door directs all traffic to the primary while it is healthy.

---

### 9. Simulate a Disaster

Now test that coordinated failover actually works. There are two approaches:

#### Option A: Manual Service Stoppage

Stop the primary-region compute resources to simulate a regional outage:

```bash
# Stop the primary web app
az webapp stop -g rg-app-swedencentral -n <primary-app-name>

# Stop primary Functions (if applicable)
az functionapp stop -g rg-app-swedencentral -n <primary-functions-name>
```

#### Option B: Azure Chaos Studio (Recommended)

Use Chaos Studio to inject faults — this is more realistic and tests the full failover path including health probe detection. See [Lab 1](lab-01-webapp-traffic-manager.md) for detailed Chaos Studio experiment setup.

```bash
# Start a chaos experiment targeting primary compute
az rest --method POST \
  --url "https://management.azure.com/subscriptions/<sub-id>/resourceGroups/rg-chaos/providers/Microsoft.Chaos/experiments/<experiment-name>/start?api-version=2024-01-01"
```

#### Monitor the Failover

After stopping primary services (or starting the chaos experiment), monitor the transition:

```bash
# Poll the global endpoint — watch for region change
for i in $(seq 1 20); do
  RESPONSE=$(curl -s "https://$GLOBAL_URL/health" 2>/dev/null)
  REGION=$(echo "$RESPONSE" | jq -r '.region // "unreachable"')
  echo "$(date +%H:%M:%S) — Region: $REGION"
  sleep 15
done
```

After 30–90 seconds (depending on health probe interval and DNS TTL):

```bash
curl -s "https://$GLOBAL_URL/health"
# Expected: {"status":"healthy","region":"norwayeast","timestamp":"..."}
```

The key observation: **the global endpoint URL did not change.** Front Door / Traffic Manager detected the primary failure through health probes and automatically routed traffic to the secondary in Norway East.

---

### 10. Verify Failover — All Layers

Failover is not just about compute. Verify that every service layer is operating correctly from the secondary region:

```bash
# 1. Web tier — application is serving from Norway East
curl -s "https://$GLOBAL_URL/api/status" | jq '.region'
# Expected: "norwayeast"

# 2. SQL Database — failover group switched
az sql failover-group show \
  -g rg-data-swedencentral \
  -s <primary-sql-server> \
  -n <fg-name> \
  --query "{primary: replicationRole, state: replicationState}" -o json

# 3. Cosmos DB — reads/writes succeeding in secondary
curl -s "https://$GLOBAL_URL/api/data/test" | jq '.source'
# Expected: data served from norwayeast replica

# 4. Service Bus — alias pointing to secondary
az servicebus georecovery-alias show \
  -g rg-messaging-swedencentral \
  --namespace-name <primary-sb-namespace> \
  --alias <alias-name> \
  --query "pendingReplicationOperationsCount" -o tsv

# 5. Key Vault — secrets accessible from secondary
az keyvault secret show \
  --vault-name <secondary-keyvault> \
  -n app-connection-string \
  --query "value" -o tsv

# 6. Storage — blobs accessible from secondary account
az storage blob list \
  --account-name <secondary-storage> \
  -c app-data \
  --query "[].name" -o tsv
```

> **🔑 Key insight:** In a production scenario, SQL Failover Group failover is **automatic** (when configured in auto-failover mode). Service Bus and Event Hubs alias failover must be **manually initiated** (or automated via runbook). Cosmos DB handles failover **automatically** when automatic failover is enabled. Understanding which services fail over automatically vs. manually is critical for your RTO.

---

### 11. Discuss Failback

Failover gets the headlines, but **failback** is often more complex and less tested. Review the prototype's failover runbook:

```bash
cat docs/failover-runbook.md
```

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

If you used Option A (manual stoppage), restart the primary services:

```bash
# Restart primary web app
az webapp start -g rg-app-swedencentral -n <primary-app-name>

# Restart primary Functions
az functionapp start -g rg-app-swedencentral -n <primary-functions-name>

# Verify primary is healthy again
PRIMARY_APP_URL=$(az webapp show \
  -g rg-app-swedencentral \
  -n <primary-app-name> \
  --query defaultHostName -o tsv)
curl -s "https://$PRIMARY_APP_URL/health"
# Expected: 200 OK with region: swedencentral
```

Within a few minutes, Front Door / Traffic Manager will detect the primary is healthy again and route traffic back (if configured for automatic failback). Monitor:

```bash
# Watch traffic shift back to primary
for i in $(seq 1 10); do
  REGION=$(curl -s "https://$GLOBAL_URL/health" | jq -r '.region // "unknown"')
  echo "$(date +%H:%M:%S) — Serving from: $REGION"
  sleep 15
done
```

---

### 13. Cost Management

Multi-region deployments double (or more) your resource costs. The prototype includes scripts to manage costs effectively.

#### Pause All Resources

```bash
./scripts/pause-all.sh
```

This script:

- Stops App Service plans (or scales to zero)
- Deallocates VMs / AKS node pools
- Pauses SQL databases (if using serverless tier)
- Does **not** delete data or break replication — resources remain deployed but idle

#### Resume All Resources

```bash
./scripts/resume-all.sh
```

Restarts all paused resources and verifies health across both regions.

#### Decouple Secondary

If you want to keep the primary running but remove the secondary to save costs:

```bash
./scripts/decouple-secondary.sh
```

This cleanly breaks all cross-region replication relationships before removing secondary resources. It is preferable to directly deleting secondary resource groups, which could leave orphaned replication configurations on the primary side.

---

### 14. Cleanup

When you are done with the lab, remove all deployed resources:

```bash
./scripts/cleanup-all.sh
```

The cleanup script:

1. Breaks all replication relationships (geo-DR pairings, failover groups, object replication policies)
2. Removes Front Door / Traffic Manager global endpoint
3. Deletes secondary region resource groups
4. Deletes primary region resource groups
5. Removes the global resource group
6. Purges soft-deleted Key Vaults (optional — prompts for confirmation)

> **⚠️ This is destructive and irreversible.** Verify you want to remove everything before confirming.

```bash
# Verify all resource groups are deleted
az group list --query "[?contains(name, 'rg-')].name" -o tsv
# Expected: no results (or only unrelated resource groups)
```

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

## Lab Series Summary

🎉 **Congratulations!** You have completed all 10 labs in the Azure Multi-Region Resiliency Hands-on Labs series.

Here is what you accomplished across the entire series:

| Lab | What You Built | Key Skills |
|-----|----------------|------------|
| [Lab 1](lab-01-webapp-traffic-manager.md) | Multi-region web app with Traffic Manager | Priority-based routing, health probes, Chaos Studio |
| [Lab 2](lab-02-blob-storage-replication.md) | Cross-region blob storage replication | Object replication, change feed, versioning |
| [Lab 3](lab-03-sql-geo-replication.md) | Azure SQL geo-replication with failover groups | Active geo-replication, automatic failover |
| [Lab 4](lab-04-cosmos-global-distribution.md) | Globally distributed Cosmos DB | Multi-region writes, consistency levels |
| [Lab 5](lab-05-key-vault-multi-region.md) | Multi-region Key Vault sync | Backup/restore, cross-region secret management |
| [Lab 6](lab-06-service-bus-geo-dr.md) | Service Bus geo-disaster recovery | Geo-DR alias, metadata replication |
| [Lab 7](lab-07-event-hubs-geo-replication.md) | Event Hubs geo-replication | Geo-replication, consumer group failover |
| [Lab 8](lab-08-acr-geo-replication.md) | Geo-replicated container registry | Premium ACR, region-local image pulls |
| [Lab 9](lab-09-data-factory-dr.md) | Active/passive Data Factory pipelines | Pipeline duplication, linked service DR |
| **Lab 10** (this lab) | **Integrated enterprise prototype** | **Coordinated multi-layer failover, topology-driven deployment** |

### Key Takeaways

1. **Multi-region is a system property, not a service property.** Each service has its own DR mechanism, but resilience only emerges from coordinating all of them together.

2. **Topology-driven deployment** — a single manifest (`config/topology.json`) ensures consistency across every resource, region, and subscription.

3. **Region selection is data-driven** — weighted scoring across service coverage (40%), AZ support (25%), cost (20%), latency (10%), and compliance (5%) gives you a defensible, repeatable choice.

4. **Test failover regularly** — an untested DR plan is just a document. Use Chaos Studio, game days, and tabletop exercises to validate your runbooks.

5. **Failback is harder than failover** — plan for it, script it, test it. Don't assume it's just "failover in reverse."

6. **Cost management matters** — use `pause-all.sh` and `resume-all.sh` to control secondary region costs. Right-size secondary resources: they don't need to match primary capacity until failover occurs.

7. **The three-step model scales** — Primary Baseline → Discover & Recommend → Enable Secondary works whether you have 3 services or 30.

### Further Reading

- [Azure reliability documentation — Multi-region with non-paired regions](https://learn.microsoft.com/azure/reliability/regions-multi-region-nonpaired)
- [Azure region pairs and cross-region replication](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure)
- [Azure business continuity management](https://learn.microsoft.com/azure/reliability/business-continuity-management-program)
- [Azure Well-Architected Framework — Reliability pillar](https://learn.microsoft.com/azure/well-architected/reliability/)
- [Azure Chaos Studio documentation](https://learn.microsoft.com/azure/chaos-studio/)
- [Enterprise prototype repository — prwani/multi-region-nonpaired-enterprise-prototype](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype)

---

*You now have the knowledge and hands-on experience to design, deploy, and operate multi-region resilient applications on Azure — using non-paired regions of your choice. Go build something resilient! 🚀*

*This capstone lab is part of the [Azure Multi-Region Resiliency Hands-on Labs](../index.md). Built with ❤️ for the Azure community.*
