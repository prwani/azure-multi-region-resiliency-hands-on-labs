---
layout: default
title: "Lab 8: Azure Container Registry – Geo-Replicated Registry"
---

[← Back to Index](../index.md)

# Lab 8: Azure Container Registry – Geo-Replicated Registry

## Introduction

When you run containerised workloads across multiple Azure regions, every
`docker pull` that crosses a continental backbone adds **latency, egress cost,
and a single point of failure**. Azure Container Registry (ACR) with
**geo-replication** solves all three problems at once:

| Challenge | How Geo-Replication Helps |
|---|---|
| **Slow image pulls** | Container images are stored in a replica **local** to each deployment region -- pulls are fast and stay on the Azure backbone. |
| **Single point of failure** | If one replica goes down, Traffic Manager routes pulls to the **next closest healthy replica** automatically. |
| **Operational complexity** | You maintain a **single registry FQDN** (`<name>.azurecr.io`). Developers push once; ACR replicates behind the scenes. |
| **Egress costs** | Pulls from a local replica avoid cross-region data transfer charges. |

### Push Once / Pull Everywhere

The geo-replication model is elegantly simple:

1. A developer (or CI pipeline) **pushes** an image to the registry's home
   region.
2. ACR **automatically replicates** that image to every configured replica
   region.
3. Nodes in each region **pull** from their nearest replica via the global
   FQDN -- no configuration change needed on the cluster side.

This lab walks you through creating a Premium ACR, adding a geo-replica,
building a sample image with ACR Tasks (no local Docker required), and
verifying that the image is available in both regions.

---

## Architecture

```
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
|   |   Sweden Central      |  |   Norway East          |             |
|   |   (home replica)      |  |   (geo-replica)        |             |
|   |                       |  |                        |             |
|   |  +-----------------+  |  |  +-----------------+   |             |
|   |  | hello-multiregion|  |  |  | hello-multiregion|  |             |
|   |  | :v1              |  |  |  | :v1              |  |             |
|   |  +-----------------+  |  |  +-----------------+   |             |
|   +-----------------------+  +------------------------+             |
|                                                                     |
|   docker push --> Sweden Central --> auto-replicates --> Norway East |
|   docker pull <-- nearest healthy replica via Traffic Manager        |
+---------------------------------------------------------------------+
```

**Key points from the diagram:**

- A single `docker push` to the home replica automatically fans out to all
  geo-replicas.
- `docker pull` from any location resolves via Traffic Manager to the
  **closest healthy** replica.
- If Norway East becomes unhealthy, pulls are transparently served from
  Sweden Central (and vice-versa).

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.50 or later (`az --version`) |
| **Azure subscription** | With permissions to create ACR (Premium SKU) |
| **Docker** | _Optional_ -- we use `az acr build` (ACR Tasks) so no local Docker engine is needed |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash on Windows |

> **Important:** Geo-replication is a **Premium SKU** feature. Basic and
> Standard SKUs do not support replicas. See the
> [cost discussion](#discussion) at the end of this lab.

---

## Step-by-Step Instructions

### Step 1 -- Set Variables

Generate a globally unique registry name. ACR names must be **alphanumeric
only** (no hyphens or underscores), 5-50 characters, and globally unique.

```azurecli
# Random suffix to ensure global uniqueness
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)

# Registry name -- no hyphens allowed
ACR_NAME="acrmultiregion${RANDOM_SUFFIX}"

# Resource group
RG="rg-acr-georeplication-lab"

# Regions
HOME_REGION="swedencentral"
REPLICA_REGION="norwayeast"

echo "ACR Name  : $ACR_NAME"
echo "RG        : $RG"
echo "Home      : $HOME_REGION"
echo "Replica   : $REPLICA_REGION"
```

### Step 2 -- Create the Resource Group

```azurecli
az group create \
  --name $RG \
  --location $HOME_REGION \
  --output table
```

Expected output:

```
Location       Name
-------------  --------------------------------
swedencentral  rg-acr-georeplication-lab
```

### Step 3 -- Create the ACR (Premium SKU)

The Premium SKU is required for geo-replication, content trust, private
endpoints, and customer-managed keys.

```azurecli
az acr create \
  --name $ACR_NAME \
  --resource-group $RG \
  --location $HOME_REGION \
  --sku Premium \
  --admin-enabled false \
  --output table
```

> **Note:** `--admin-enabled false` is the default and recommended for
> production. Use managed identities or Azure AD tokens for authentication
> instead of admin credentials.

Verify the registry was created:

```azurecli
az acr show \
  --name $ACR_NAME \
  --query "{Name:name, SKU:sku.name, Location:location, LoginServer:loginServer}" \
  --output table
```

You should see the login server as `<acrname>.azurecr.io` and SKU as
`Premium`.

### Step 4 -- Add a Geo-Replica in Norway East

```azurecli
az acr replication create \
  --registry $ACR_NAME \
  --location $REPLICA_REGION \
  --output table
```

This command tells ACR to create a full read-write replica of your registry
in Norway East. Existing images are automatically synchronised.

### Step 5 -- (Optional) Enable Zone Redundancy on the Replica

Zone redundancy distributes replica storage across **three availability
zones** within the region, providing resilience against a single zone failure.

> **Note:** Zone redundancy can only be set at replica **creation time** and
> cannot be changed afterward. If you already created the replica in Step 4
> without zone redundancy, you would need to delete it and recreate it.

If you want zone redundancy, delete the replica from Step 4 first, then
recreate:

```azurecli
# Delete the existing replica (if recreating with zone redundancy)
az acr replication delete \
  --registry $ACR_NAME \
  --name $REPLICA_REGION \
  --yes

# Recreate with zone redundancy enabled
az acr replication create \
  --registry $ACR_NAME \
  --location $REPLICA_REGION \
  --zone-redundancy enabled \
  --output table
```

### Step 6 -- List All Replications

Every ACR has at least one replication entry -- the **home** region. After
adding the geo-replica, you should see two entries.

```azurecli
az acr replication list \
  --registry $ACR_NAME \
  --output table
```

Expected output (columns may vary):

```
NAME            LOCATION       PROVISIONING STATE    STATUS    ZONE REDUNDANCY
--------------  -------------  --------------------  --------  ----------------
swedencentral   swedencentral  Succeeded             Ready     Disabled
norwayeast      norwayeast     Succeeded             Ready     Enabled
```

---

### Step 7 -- Build a Sample Image Using ACR Tasks

ACR Tasks lets you build container images **in the cloud** -- no local Docker
engine required. This is ideal for CI/CD pipelines and environments where
Docker is not installed.

#### 7a -- Create a Working Directory

```azurecli
mkdir -p ~/acr-lab && cd ~/acr-lab
```

#### 7b -- Create a Simple Dockerfile

```azurecli
cat > Dockerfile << 'EOF'
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF
```

#### 7c -- Create the HTML Page

```azurecli
cat > index.html << 'EOF'
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
```

#### 7d -- Build and Push with ACR Tasks

```azurecli
az acr build \
  --registry $ACR_NAME \
  --image hello-multiregion:v1 \
  . \
  --no-logs
```

> **What happens behind the scenes:**
>
> 1. The CLI packages the build context (Dockerfile + index.html) and uploads
>    it to ACR.
> 2. ACR Tasks builds the image on a managed compute instance.
> 3. The resulting image is pushed to the home replica (Sweden Central).
> 4. ACR automatically replicates the image to Norway East.

Remove the `--no-logs` flag if you want to see the full build output
streamed to your terminal.

---

### Step 8 -- Verify the Image Exists

```azurecli
az acr repository list \
  --name $ACR_NAME \
  --output table
```

Expected output:

```
Result
-------------------
hello-multiregion
```

### Step 9 -- Show Image Manifest Metadata

The manifest metadata confirms the image digest, architecture, and
timestamps.

```azurecli
az acr manifest list-metadata \
  --registry $ACR_NAME \
  --name hello-multiregion \
  --output table
```

You should see one entry for `v1` with the creation timestamp and digest.

### Step 10 -- Check Replication Status

Confirm that the Norway East replica is healthy and synchronised:

```azurecli
az acr replication show \
  --registry $ACR_NAME \
  --name norwayeast \
  --query "{Name:name, Location:location, ProvisioningState:provisioningState, Status:status.displayStatus}" \
  --output table
```

Expected output:

```
Name        Location    ProvisioningState    Status
----------  ----------  -------------------  --------
norwayeast  norwayeast  Succeeded            Ready
```

A status of **Ready** means the replica is healthy and serving traffic.

---

### Step 11 -- Understand Traffic Manager Routing

ACR uses **Azure Traffic Manager** internally to route requests to the
nearest healthy replica. Here is how it works:

```
Client: docker pull acrmultiregionXXXXX.azurecr.io/hello-multiregion:v1
    |
    v
DNS resolves acrmultiregionXXXXX.azurecr.io
    |
    v
Traffic Manager evaluates:
    +-- Client location
    +-- Replica health probes
    +-- Latency-based routing
    |
    v
Request routed to nearest healthy replica
    +-- Client in Stockholm  -->  Sweden Central replica
    +-- Client in Oslo       -->  Norway East replica
```

**You do not need to change any pull URLs.** The same FQDN
(`$ACR_NAME.azurecr.io`) works everywhere -- Traffic Manager handles routing
transparently.

### Step 12 -- (Optional) Pull the Image

If you have Docker installed locally or on a VM, you can test pulling:

```azurecli
# Log in to ACR
az acr login --name $ACR_NAME

# Pull the image
docker pull $ACR_NAME.azurecr.io/hello-multiregion:v1

# Run it locally
docker run -d -p 8080:80 $ACR_NAME.azurecr.io/hello-multiregion:v1

# Test
curl http://localhost:8080
```

> **Tip:** To see which replica served your pull, compare the IP address
> returned by DNS resolution of `$ACR_NAME.azurecr.io` from different
> regions. You can also check ACR diagnostic logs in Azure Monitor.

### Step 13 -- (Optional) Create a Webhook for Replication Events

Webhooks notify external services when events occur in your registry --
pushes, deletes, quarantine changes, and chart pushes.

```azurecli
# Create a webhook that fires on push events in the home region
az acr webhook create \
  --name webhookPushNotify \
  --registry $ACR_NAME \
  --location $HOME_REGION \
  --actions push delete \
  --uri https://example.com/acr-webhook \
  --status enabled \
  --output table
```

You can create **separate webhooks per replica region** to get granular
notifications about replication events:

```azurecli
# Webhook scoped to the Norway East replica
az acr webhook create \
  --name webhookNorwayPush \
  --registry $ACR_NAME \
  --location $REPLICA_REGION \
  --actions push \
  --uri https://example.com/norway-webhook \
  --status enabled \
  --output table
```

List all configured webhooks:

```azurecli
az acr webhook list \
  --registry $ACR_NAME \
  --output table
```

---

## Validation Checklist

Run through this checklist to confirm your lab is complete:

| # | Check | Command | Expected |
|---|---|---|---|
| 1 | ACR exists with Premium SKU | `az acr show --name $ACR_NAME --query sku.name -o tsv` | `Premium` |
| 2 | Two replications listed | `az acr replication list --registry $ACR_NAME -o table` | Sweden Central + Norway East |
| 3 | Image exists in repository | `az acr repository list --name $ACR_NAME -o tsv` | `hello-multiregion` |
| 4 | Image tag is available | `az acr manifest list-metadata --registry $ACR_NAME --name hello-multiregion -o table` | `v1` row present |
| 5 | Norway East replica is Ready | `az acr replication show --registry $ACR_NAME --name norwayeast --query status.displayStatus -o tsv` | `Ready` |

---

## Cleanup

> **Caution:** Premium ACR is billed per day per replica. Clean up when you
> are done to avoid ongoing charges.

### Option A -- Delete Everything

Delete the resource group and all resources within it:

```azurecli
az group delete \
  --name $RG \
  --yes \
  --no-wait
```

### Option B -- Remove Only the Geo-Replica

If you want to keep the registry but remove the extra replica:

```azurecli
az acr replication delete \
  --registry $ACR_NAME \
  --name norwayeast \
  --yes
```

### Clean Up Local Files

```azurecli
rm -rf ~/acr-lab
```

---

## Discussion

### Premium Tier -- Cost Justification

| SKU | Geo-Replication | Storage Included | Approx. Daily Cost |
|---|---|---|---|
| Basic | No | 10 GiB | ~$0.167/day |
| Standard | No | 100 GiB | ~$0.667/day |
| Premium | **Yes** | 500 GiB | ~$1.667/day per replica |

The Premium SKU costs roughly **10x Basic**, but for production multi-region
workloads the benefits outweigh the cost:

- **Faster pulls** reduce container start-up time (critical for scaling
  events and disaster recovery).
- **Reduced egress** -- pulling from a local replica avoids cross-region
  data transfer charges that can add up quickly with large images.
- **High availability** -- health-aware routing means a regional outage does
  not block image pulls.

**Recommendation:** Use Basic or Standard for dev/test. Upgrade to Premium
only for staging/production environments that span multiple regions.

### Zone Redundancy Per Replica

Each replica can independently have zone redundancy enabled. This
distributes the replica's storage across **three availability zones** within
that region.

- Zone redundancy is set at **creation time only** -- you cannot toggle it
  on an existing replica.
- Provides resilience against a single availability zone failure within
  the replica region.
- Combines with geo-replication for defence in depth: zone failures are
  handled by zone redundancy, regional failures by geo-replication.

### Webhook Notifications on Replication

Webhooks in ACR fire on these events:

| Event | Trigger |
|---|---|
| `push` | Image or Helm chart pushed (or replicated) |
| `delete` | Image or manifest deleted |
| `quarantine` | Image quarantine status changed |
| `chart_push` | Helm chart pushed |
| `chart_delete` | Helm chart deleted |

You can create **region-scoped webhooks** -- a webhook created with
`--location norwayeast` fires only when events occur in that specific
replica. This enables per-region monitoring and alerting.

### Health-Aware Failover

ACR's internal Traffic Manager continuously monitors replica health. If a
replica becomes unhealthy:

1. Traffic Manager detects the failure via health probes.
2. DNS responses are updated to route clients to the **next closest
   healthy replica**.
3. When the failed replica recovers, traffic is gradually shifted back.

This failover is **automatic and transparent** -- clients do not need to
change their pull URLs or take any action.

### When NOT to Use Geo-Replication

- **Single-region deployments** -- no benefit; stick with Standard SKU.
- **Dev/test environments** -- the Premium cost is rarely justified.
- **Very small images** -- cross-region pull latency may be negligible.
- **Budget-constrained projects** -- consider using `az acr import` to
  manually copy critical images to a second registry instead.

---

## Key Takeaways

1. **Premium SKU required** -- geo-replication is exclusively a Premium
   feature.
2. **Single FQDN** -- `<registry>.azurecr.io` routes to the nearest healthy
   replica automatically.
3. **Push once, pull everywhere** -- images replicate asynchronously to all
   configured replicas.
4. **Zone redundancy** can be layered on top of geo-replication for maximum
   resilience within each region.
5. **ACR Tasks** eliminate the need for a local Docker engine -- build
   directly in the cloud.
6. **Webhooks** provide observability into push, delete, and replication
   events per region.

---

## Further Reading

- [Azure Container Registry geo-replication](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [ACR Tasks overview](https://learn.microsoft.com/azure/container-registry/container-registry-tasks-overview)
- [ACR pricing](https://azure.microsoft.com/pricing/details/container-registry/)
- [Zone redundancy in ACR](https://learn.microsoft.com/azure/container-registry/zone-redundancy)
- [ACR webhook reference](https://learn.microsoft.com/azure/container-registry/container-registry-webhook-reference)

---

[← Back to Index](../index.md) | [Next: Lab 9 — Azure Data Factory DR →](lab-09-data-factory-dr.md)
