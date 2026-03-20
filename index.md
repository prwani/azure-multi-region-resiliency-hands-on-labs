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

---

## 🌐 Web & Compute

| Lab | Services | Description |
|-----|----------|-------------|
| [Lab 1: Multi-Region Web App with Traffic Manager & Chaos Studio](labs/lab-01-webapp-traffic-manager.md) | App Service, Functions, Traffic Manager, Chaos Studio | Deploy a web app to two regions, configure Traffic Manager for priority-based failover, and inject faults with Chaos Studio to validate DR. |

## 💾 Data & Storage

| Lab | Services | Description |
|-----|----------|-------------|
| [Lab 2: Azure Blob Storage – Object Replication](labs/lab-02-blob-storage-replication.md) | Azure Storage (Blob) | Replicate blobs between non-paired regions using Object Replication with change feed and versioning. |
| [Lab 3: Azure SQL Database – Geo-Replication & Failover](labs/lab-03-sql-geo-replication.md) | Azure SQL Database | Set up Active Geo-Replication, create a Failover Group, and test manual failover with zero data loss. |
| [Lab 4: Azure Cosmos DB – Global Distribution](labs/lab-04-cosmos-global-distribution.md) | Azure Cosmos DB | Add secondary regions and enable multi-region writes for continuous global availability. |
| [Lab 5: Azure Database for MySQL – Cross-Region Read Replica](labs/lab-11-mysql-geo-replication.md) | Azure Database for MySQL | Create a cross-region read replica, validate replication, and promote it during a failover drill. |
| [Lab 6: Azure Database for PostgreSQL – Cross-Region Read Replica](labs/lab-12-postgresql-geo-replication.md) | Azure Database for PostgreSQL | Build a cross-region read replica, validate WAL replication, and promote it to a standalone primary. |

## 🔐 Security & Identity

| Lab | Services | Description |
|-----|----------|-------------|
| [Lab 7: Azure Key Vault – Multi-Region Backup & Sync](labs/lab-05-key-vault-multi-region.md) | Azure Key Vault | Back up and sync secrets, keys, and certificates to a secondary Key Vault for cross-region resilience. |

## 📨 Messaging & Eventing

| Lab | Services | Description |
|-----|----------|-------------|
| [Lab 8: Azure Service Bus – Geo-Disaster Recovery](labs/lab-06-service-bus-geo-dr.md) | Azure Service Bus | Create a geo-DR alias between namespaces in two regions and test failover of the messaging tier. |
| [Lab 9: Azure Event Hubs – Geo-Replication Failover](labs/lab-07-event-hubs-geo-replication.md) | Azure Event Hubs | Set up geo-replication for Event Hubs namespaces and validate failover for streaming workloads. |

## 📦 Containers & DevOps

| Lab | Services | Description |
|-----|----------|-------------|
| [Lab 10: Azure Container Registry – Geo-Replicated Registry](labs/lab-08-acr-geo-replication.md) | Azure Container Registry | Create a Premium ACR with geo-replicas so container images are close to every deployment region. |

## ⚙️ Data Integration

| Lab | Services | Description |
|-----|----------|-------------|
| [Lab 11: Azure Data Factory – Active/Passive Pipelines](labs/lab-09-data-factory-dr.md) | Azure Data Factory | Maintain duplicate pipelines across regions for data integration resilience. |

## 🏢 Capstone

| Lab | Services | Description |
|-----|----------|-------------|
| [Lab 12: Integrated Enterprise App – Multi-Region Prototype](labs/lab-10-enterprise-prototype.md) | App Service, Functions, SQL, Cosmos DB, Storage, Key Vault, Service Bus, Front Door | Bring it all together: deploy a full multi-region enterprise application, configure every layer for resilience, and test coordinated failover. |

---

## Getting Started

1. **Choose your regions.** These labs default to **Sweden Central** (primary) and **Norway East** (secondary) — a validated non-paired combination with 91.5% service coverage and sub-10 ms latency. You can substitute any two non-paired regions.

2. **Set up your environment.** Ensure you have:
   - [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (v2.60+)
   - An authenticated session (`az login`)
   - Contributor or Owner access on your target subscription

3. **Work through the labs in order** (recommended) or jump to a specific service that interests you. Labs 1–11 each focus on one service; Lab 12 integrates everything.

## Naming Conventions

Throughout these labs, resources use names that include purpose and region codes for clarity:

| Pattern | Example | Meaning |
|---------|---------|---------|
| `rg-<purpose>-<region>` | `rg-dr-swc` | Resource group in Sweden Central |
| `<service>-dr-<region>` | `webapp-dr-noe` | Web app DR instance in Norway East |
| `<service>-multiregion` | `cosmos-multiregion` | Multi-region enabled resource |

## Related Repositories

| Repository | Used In |
|------------|---------|
| [prwani/multi-region-nonpaired-azurestorage](https://github.com/prwani/multi-region-nonpaired-azurestorage) | Lab 2 — Blob Storage Object Replication scripts & Bicep templates |
| [prwani/multi-region-nonpaired-enterprise-prototype](https://github.com/prwani/multi-region-nonpaired-enterprise-prototype) | Lab 12 — Enterprise prototype with topology-driven deployment |

## Further Reading

- [Azure reliability documentation — Multi-region with non-paired regions](https://learn.microsoft.com/azure/reliability/regions-multi-region-nonpaired)
- [Azure region pairs](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure)
- [Azure business continuity management](https://learn.microsoft.com/azure/reliability/business-continuity-management-program)

---

*Built with ❤️ for the Azure community. Contributions welcome!*
