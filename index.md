---
layout: default
title: Azure Multi-Region Resiliency Hands-on Labs
---

# Azure Multi-Region Resiliency Hands-on Labs

> **Learn how to architect, deploy, and test multi-region disaster recovery and active-active resiliency for Azure services — using non-paired regions of your choice.**

These self-paced labs walk you through implementing multi-region strategies for individual Azure services and then bringing them all together in an integrated enterprise deployment. Every lab uses **non-paired Azure regions** (default: **Sweden Central** + **Norway East**) to emphasize region-of-choice architecture rather than relying on Azure's default regional pairs.

## Who Is This For?

- **Cloud Architects** designing resilient multi-region deployments
- **DevOps Engineers** implementing DR automation and failover testing
- **Azure Developers** who need to understand cross-region data replication and service continuity

**Prerequisites:** Azure subscription with Contributor or Owner access, Azure CLI installed, and basic familiarity with Azure services.

## How the `A` / `B` Variants Work

- **`Lab X-a`** keeps the simpler baseline or public-edge flow for that scenario.
- **`Lab X-b`** assumes [Lab 0](labs/lab-00-security-prereqs.md) is already complete and adapts the scenario to the secure hub-and-spoke foundation by using spoke placement, private endpoints, delegated subnets, or other private-networking patterns where the service supports them.
- You can work the labs **strictly in order** or do an `a` lab first and then repeat the same scenario with the corresponding `b` variant.

---

## 🛡️ Optional Foundation

| Entry | What it sets up | Used by |
|------|------------------|---------|
| [Lab 0: Security Pre-Reqs – Optional Hub-and-Spoke Foundation](labs/lab-00-security-prereqs.md) | Builds the reusable dual-region hub-and-spoke landing zone with hub VNets, spoke VNets, Azure Firewall, Azure Bastion, staged route tables, and shared subnet conventions. | Every `Lab X-b` variant |

## 💾 Data & Storage

| Lab | Baseline (`a`) | Secure (`b`) | Focus |
|-----|----------------|--------------|-------|
| 1 | [Lab 1-a: Azure Blob Storage – Object Replication across Regions](labs/lab-01a-blob-storage-replication.md) | [Lab 1-b: Azure Blob Storage – Object Replication with Private Endpoints](labs/lab-01b-blob-storage-private-endpoints.md) | Blob object replication with optional private endpoints in the regional spokes. |
| 2 | [Lab 2-a: Azure SQL Database – Geo-Replication & Failover](labs/lab-02a-sql-geo-replication.md) | [Lab 2-b: Azure SQL Database – Private Geo-Replication & Failover](labs/lab-02b-sql-private-geo-replication.md) | SQL geo-replication, failover groups, and private SQL access from spoke VNets. |
| 3 | [Lab 3-a: Azure Cosmos DB – Global Distribution](labs/lab-03a-cosmos-global-distribution.md) | [Lab 3-b: Azure Cosmos DB – Private Global Distribution](labs/lab-03b-cosmos-private-global-distribution.md) | Cosmos global distribution with optional private endpoints and regional validation paths. |
| 4 | [Lab 4-a: Azure Database for MySQL – Public Cross-Region Read Replica](labs/lab-04a-mysql-geo-replication.md) | [Lab 4-b: Azure Database for MySQL – Private Cross-Region Read Replica](labs/lab-04b-mysql-private-geo-replication.md) | MySQL read replicas, promotion drills, and secure private-access networking. |
| 5 | [Lab 5-a: Azure Database for PostgreSQL – Cross-Region Read Replica](labs/lab-05a-postgresql-geo-replication.md) | [Lab 5-b: Azure Database for PostgreSQL – Private Geo-Replication with Private Endpoints](labs/lab-05b-postgresql-private-geo-replication.md) | PostgreSQL read replicas with a private-endpoint-based secure path. |

## 🖥️ Compute

| Lab | Baseline (`a`) | Secure (`b`) | Focus |
|-----|----------------|--------------|-------|
| 6 | [Lab 6-a: Azure Virtual Machines – Cross-Region DR with Site Recovery](labs/lab-06a-vm-site-recovery.md) | [Lab 6-b: Azure Virtual Machines – Cross-Region DR with Site Recovery (Secure Spoke & Bastion)](labs/lab-06b-vm-site-recovery-secure-spoke.md) | VM disaster recovery with Azure Site Recovery, then the spoke/Bastion-secured variant. |
| 7 | [Lab 7-a: Baseline Multi-Region Web App with Traffic Manager & Chaos Studio](labs/lab-07a-webapp-traffic-manager.md) | [Lab 7-b: Multi-Region Web App with Traffic Manager, VNet Integration & Private Endpoints](labs/lab-07b-webapp-traffic-manager-private-networking.md) | Active-passive App Service failover with optional spoke integration and private dependencies. |

## 🔐 Security & Identity

| Lab | Baseline (`a`) | Secure (`b`) | Focus |
|-----|----------------|--------------|-------|
| 8 | [Lab 8-a: Azure Key Vault – Multi-Region Backup & Sync](labs/lab-08a-key-vault-multi-region.md) | [Lab 8-b: Azure Key Vault – Private Endpoints & Multi-Region Sync](labs/lab-08b-key-vault-private-networking.md) | Key Vault backup/sync with a secure private-endpoint variant. |

## 📨 Messaging & Eventing

| Lab | Baseline (`a`) | Secure (`b`) | Focus |
|-----|----------------|--------------|-------|
| 9 | [Lab 9-a: Azure Service Bus – Geo-Disaster Recovery](labs/lab-09a-service-bus-geo-dr.md) | [Lab 9-b: Azure Service Bus – Private Networking](labs/lab-09b-service-bus-private-networking.md) | Service Bus Geo-DR aliasing with a private-endpoint messaging path. |
| 10 | [Lab 10-a: Azure Event Hubs – Geo-Replication Failover](labs/lab-10a-event-hubs-geo-replication.md) | [Lab 10-b: Azure Event Hubs – Private Networking](labs/lab-10b-event-hubs-private-networking.md) | Event Hubs geo-replication with private endpoints, private DNS, and regional validation VMs. |

## 📦 Containers & DevOps

| Lab | Baseline (`a`) | Secure (`b`) | Focus |
|-----|----------------|--------------|-------|
| 11 | [Lab 11-a: Azure Container Registry – Geo-Replication](labs/lab-11a-acr-geo-replication.md) | [Lab 11-b: Azure Container Registry – Private Networking](labs/lab-11b-acr-private-networking.md) | ACR geo-replication with managed-identity pulls from a private-networked registry. |
| 12 | [Lab 12-a: Baseline AKS Multi-Cluster – Global Routing with Fleet, ACR, and Front Door](labs/lab-12a-aks-multi-cluster.md) | [Lab 12-b: AKS Multi-Cluster – Hub-and-Spoke with Fleet, ACR, Application Gateway, and Front Door](labs/lab-12b-aks-multi-cluster-hub-spoke.md) | AKS multi-cluster routing, then the secure hub-and-spoke/App Gateway variant. |

## ⚙️ Data Integration

| Lab | Baseline (`a`) | Secure (`b`) | Focus |
|-----|----------------|--------------|-------|
| 13 | [Lab 13-a: Azure Data Factory – Active/Passive Data Pipelines](labs/lab-13a-data-factory-dr.md) | [Lab 13-b: Azure Data Factory – Private Networking and Spoke Connectivity](labs/lab-13b-data-factory-private-networking.md) | Data Factory DR with a private SHIR + private-endpoint data path. |

## 🏢 Capstone

| Lab | Baseline (`a`) | Secure (`b`) | Focus |
|-----|----------------|--------------|-------|
| 14 | [Lab 14-a: Integrated Enterprise App – Multi-Region Prototype](labs/lab-14a-enterprise-prototype.md) | [Lab 14-b: Integrated Enterprise App – Secure Networking](labs/lab-14b-enterprise-prototype-secure-networking.md) | End-to-end enterprise deployment in the baseline path or the secure hub-and-spoke landing zone. |

---

## Getting Started

1. **Choose your regions.** These labs default to **Sweden Central** (primary) and **Norway East** (secondary) — a validated non-paired combination with 91.5% service coverage and sub-10 ms latency. You can substitute any two non-paired regions.

2. **Choose your track.** If you want the secure/private path, start with **Lab 0** and then use the `b` variants. If you want the simpler path first, start with the `a` variants.

3. **Set up your environment.** Ensure you have:
   - [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (v2.60+)
   - An authenticated session (`az login`)
   - Contributor or Owner access on your target subscription

4. **Work through the labs in order** (recommended) or jump to a specific service that interests you. The sequence stays the same across both tracks; only the networking posture changes.

## Naming Conventions

Throughout these labs, resources use names that include purpose and region codes for clarity:

| Pattern | Example | Meaning |
|---------|---------|---------|
| `rg-<role>-<region>` | `rg-spoke-swc` | Resource group in Sweden Central |
| `vnet-<role>-<region>` | `vnet-hub-noe` | Hub or spoke virtual network in Norway East |
| `<service>-<purpose>-<region>` | `webapp-dr-noe` | Workload resource in a specific region |

## Related Repositories

| Repository | Used In |
|------------|---------|
| [prwani/multi-region-nonpaired-azurestorage](https://github.com/prwani/multi-region-nonpaired-azurestorage) | Lab 1-a / Lab 1-b — Blob Storage object replication scripts & templates |
| [prwani/multi-region-nonpaired-enterprise-prototype](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype) | Lab 14-a / Lab 14-b — Enterprise prototype with topology-driven deployment |

## Further Reading

- [Azure reliability documentation — Multi-region with non-paired regions](https://learn.microsoft.com/azure/reliability/regions-multi-region-nonpaired)
- [Azure region pairs](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure)
- [Azure business continuity management](https://learn.microsoft.com/azure/reliability/business-continuity-management-program)

---

*Built with ❤️ for the Azure community. Contributions welcome!*
