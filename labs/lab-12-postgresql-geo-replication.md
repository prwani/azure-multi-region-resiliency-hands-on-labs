---
layout: default
title: "Lab 12: Azure Database for PostgreSQL – Cross-Region Read Replica"
---

[← Back to Index](../index.md)

# Lab 12: Azure Database for PostgreSQL – Cross-Region Read Replica

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

Azure Database for PostgreSQL Flexible Server is the recommended managed PostgreSQL service on Azure. It supports **cross-region read replicas** using PostgreSQL's native streaming replication (WAL-based), enabling disaster recovery, read scale-out, and data locality across Azure regions.

| Feature | Detail |
|---|---|
| **Read Replicas** | Up to 5 asynchronous replicas per source server |
| **Cross-Region Support** | Replicas can be placed in any supported Azure region |
| **Replication Method** | PostgreSQL WAL (Write-Ahead Log) streaming replication |
| **Promotion** | A replica can be promoted to a standalone read-write server (irreversible) |
| **Read Scale-Out** | Offload reporting, analytics, and BI queries to read replicas |
| **Virtual Endpoints** | Writer and reader virtual endpoints for simplified connection management |

### Why Cross-Region Read Replicas?

* **Disaster Recovery** — If the primary region becomes unavailable, promote the cross-region replica to a standalone server.
* **Read Latency Reduction** — Place a read replica closer to your users to reduce latency for read-heavy workloads.
* **Analytics Isolation** — Run expensive analytical queries against a replica without impacting production write performance.
* **Compliance** — Maintain a copy of data in a specific region for regulatory purposes.

### Key Differences from MySQL

| Aspect | PostgreSQL Flexible Server | MySQL Flexible Server |
|---|---|---|
| Replication mechanism | WAL streaming (physical) | Binlog (logical) |
| Max read replicas | 5 | 10 |
| Virtual endpoints | ✅ Writer + Reader endpoints | ❌ Not available |
| Tier requirement | General Purpose or Memory Optimized | General Purpose or Memory Optimized |
| Promotion | Stop replication → standalone | Stop replication → standalone |

> **Key takeaway:** PostgreSQL Flexible Server's **virtual endpoints** provide a writer endpoint that always points to the current primary — offering some of the connection-string stability that MySQL lacks. However, cross-region failover promotion is still a manual operation.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│   ┌──────────────────────────┐          ┌──────────────────────────┐    │
│   │   Sweden Central         │          │   Norway East            │    │
│   │                          │          │                          │    │
│   │  ┌────────────────────┐  │  Async   │  ┌────────────────────┐  │    │
│   │  │ pgsql-dr-swc-xxxxx │  │   WAL    │  │ pgsql-dr-noe-xxxxx │  │    │
│   │  │ (Source Server)    │──┼──Stream──►│  │ (Read Replica)     │  │    │
│   │  │                    │  │          │  │                    │  │    │
│   │  │ • Read + Write     │  │          │  │ • Read-only        │  │    │
│   │  │ • sampledb         │  │          │  │ • sampledb (copy)  │  │    │
│   │  └────────────────────┘  │          │  └────────────────────┘  │    │
│   │                          │          │                          │    │
│   │  rg-pgsql-dr-swc         │          │  rg-pgsql-dr-noe         │    │
│   └──────────────────────────┘          └──────────────────────────┘    │
│                                                                          │
│   Virtual Endpoints (optional):                                         │
│   • Writer: <account>.writer.postgres.database.azure.com                │
│   • Reader: <account>.reader.postgres.database.azure.com                │
│                                                                          │
│   On failover (manual):                                                 │
│   1. Promote replica → standalone read-write server                     │
│   2. Update application connection strings (or virtual endpoint swings) │
│   3. (Optional) Create new replica from promoted server                 │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.60 or later (`az --version`) |
| **Azure subscription** | With permissions to create PostgreSQL Flexible Servers |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash |
| **PowerShell 7+** | Recommended if you want to follow the PowerShell tabs |
| **psql client** _(optional)_ | For direct database queries. Install via `sudo apt install postgresql-client` |

---

## How These Tabs Work

This page uses a shared tab preference:

- If you click **Bash** in one step, the rest of the page switches to **Bash**
- The selection is remembered for the page in your browser
- Every code block gets a copy button in the top-right corner

---

## Step 1 — Set Variables

Choose globally unique server names before you create the servers. Save the generated admin password somewhere secure; you will reuse it when you test replication and promotion.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)

PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

RG_PRIMARY="rg-pgsql-dr-swc"
RG_SECONDARY="rg-pgsql-dr-noe"

PRIMARY_SERVER="pgsql-dr-swc-${RANDOM_SUFFIX}"
REPLICA_SERVER="pgsql-dr-noe-${RANDOM_SUFFIX}"

ADMIN_USER="pgadmin"
ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"

DB_NAME="sampledb"

echo "Primary server : $PRIMARY_SERVER"
echo "Replica server : $REPLICA_SERVER"
echo "Admin user     : $ADMIN_USER"
echo "Admin password : $ADMIN_PASSWORD  (save this!)"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$RG_PRIMARY = "rg-pgsql-dr-swc"
$RG_SECONDARY = "rg-pgsql-dr-noe"

$PRIMARY_SERVER = "pgsql-dr-swc-$RANDOM_SUFFIX"
$REPLICA_SERVER = "pgsql-dr-noe-$RANDOM_SUFFIX"

$ADMIN_USER = "pgadmin"
$ADMIN_PASSWORD = "P@ssw0rd-$([guid]::NewGuid().ToString('N').Substring(0,8))"

$DB_NAME = "sampledb"

Write-Host "Primary server : $PRIMARY_SERVER"
Write-Host "Replica server : $REPLICA_SERVER"
Write-Host "Admin user     : $ADMIN_USER"
Write-Host "Admin password : $ADMIN_PASSWORD  (save this!)"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Decide on a short unique suffix for the two servers.
2. Write down these values before you create anything:
   - Primary region: `swedencentral`
   - Secondary region: `norwayeast`
   - Resource groups: `rg-pgsql-dr-swc`, `rg-pgsql-dr-noe`
   - Server names: `pgsql-dr-swc-<suffix>`, `pgsql-dr-noe-<suffix>`
   - Database name: `sampledb`
3. Save the administrator credentials in a password manager so you can reuse them during verification.

      </div>
    </div>

---

## Step 2 — Create Resource Groups

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name $RG_PRIMARY   --location $PRIMARY_REGION   --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $PRIMARY_REGION --output table
az group create --name $RG_SECONDARY --location $SECONDARY_REGION --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups** in the Azure portal.
2. Create `rg-pgsql-dr-swc` in **Sweden Central**.
3. Create `rg-pgsql-dr-noe` in **Norway East**.
4. Confirm both resource groups appear before you continue.

      </div>
    </div>

---

## Step 3 — Create the Source PostgreSQL Flexible Server

Create a General Purpose tier server in Sweden Central.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server create   --name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --location $PRIMARY_REGION   --admin-user $ADMIN_USER   --admin-password $ADMIN_PASSWORD   --sku-name Standard_D2ads_v5   --tier GeneralPurpose   --storage-size 32   --version 16   --public-access 0.0.0.0   --output table

az postgres flexible-server show   --name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --query '{Name:name, State:state, Location:location, SKU:sku.name, Version:version}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server create `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --admin-user $ADMIN_USER `
  --admin-password $ADMIN_PASSWORD `
  --sku-name Standard_D2ads_v5 `
  --tier GeneralPurpose `
  --storage-size 32 `
  --version 16 `
  --public-access 0.0.0.0 `
  --output table

az postgres flexible-server show `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '{Name:name, State:state, Location:location, SKU:sku.name, Version:version}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Search for **Azure Database for PostgreSQL flexible servers** and select **Create**.
2. On **Basics**, choose:
   - Resource group: `rg-pgsql-dr-swc`
   - Server name: your `pgsql-dr-swc-<suffix>` value
   - Region: **Sweden Central**
   - Compute tier: **General Purpose**
   - Admin username/password: the values you saved earlier
3. In **Networking**, allow the connectivity you need for the lab. If you want to mirror the CLI flow, allow public access from Azure-hosted tools and your client IP.
4. Create the server, then confirm on **Overview** that it is **Ready** and running in **Sweden Central**.

      </div>
    </div>

<div class="lab-note">
<strong>Networking note:</strong> <code>--public-access 0.0.0.0</code> is a convenient lab shortcut. For production, prefer private access or tightly scoped firewall rules.
</div>

<div class="lab-note">
<strong>Direct client note:</strong> If you plan to run <code>psql</code> from your own terminal instead of Cloud Shell, add a firewall rule for your public IP on the source server now, then repeat the same firewall rule step for the replica after Step 5.
</div>

---

## Step 4 — Create a Sample Database and Table

Create a database on the source server. If you have the <code>psql</code> client installed, add a small dataset so you can validate replication later.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server db create   --server-name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --database-name $DB_NAME   --output table

export PGPASSWORD="$ADMIN_PASSWORD"
psql "host=${PRIMARY_SERVER}.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" <<'SQL'
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    region VARCHAR(50) DEFAULT 'swedencentral',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO orders (customer_name, product, amount) VALUES
    ('Alice',   'Azure VM',           149.99),
    ('Bob',     'Azure Storage',       29.99),
    ('Charlie', 'Azure Functions',     49.99),
    ('Diana',   'Azure Cosmos DB',    199.99),
    ('Eve',     'Azure Key Vault',     19.99);

SELECT * FROM orders;
SQL
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server db create `
  --server-name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --database-name $DB_NAME `
  --output table

$env:PGPASSWORD = $ADMIN_PASSWORD
@"
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    region VARCHAR(50) DEFAULT 'swedencentral',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO orders (customer_name, product, amount) VALUES
    ('Alice',   'Azure VM',           149.99),
    ('Bob',     'Azure Storage',       29.99),
    ('Charlie', 'Azure Functions',     49.99),
    ('Diana',   'Azure Cosmos DB',    199.99),
    ('Eve',     'Azure Key Vault',     19.99);

SELECT * FROM orders;
"@ | psql "host=$PRIMARY_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary PostgreSQL flexible server.
2. In the left navigation, open **Databases** and create `sampledb`.
3. To add sample rows, use one of these options:
   - **Query editor** in the portal, if it is enabled in your environment.
   - **Azure Cloud Shell** or a local `psql` client using the server connection details.
4. Run the table and insert statements from the Bash or PowerShell tab, then verify you can query the five sample rows.

      </div>
    </div>

---

## Step 5 — Create a Cross-Region Read Replica

Create an asynchronous read replica in Norway East using PostgreSQL WAL streaming.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SOURCE_ID=$(az postgres flexible-server show --name $PRIMARY_SERVER --resource-group $RG_PRIMARY --query id -o tsv)
az postgres flexible-server replica create   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --source-server $SOURCE_ID   --location $SECONDARY_REGION   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SOURCE_ID = az postgres flexible-server show --name $PRIMARY_SERVER --resource-group $RG_PRIMARY --query id -o tsv
az postgres flexible-server replica create `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --source-server $SOURCE_ID `
  --location $SECONDARY_REGION `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary PostgreSQL flexible server.
2. Go to **Replication** or **Read replicas**.
3. Select **Add replica**.
4. Choose `rg-pgsql-dr-noe` as the target resource group and **Norway East** as the region.
5. Create the replica and wait for the initial base backup to finish.

      </div>
    </div>

> **Note:** This command may take 15–20 minutes. PostgreSQL performs a base backup of the source server, transfers it to the replica region, and then begins WAL streaming replication.

---

## Step 6 — Verify the Replica

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server show   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --query '{Name:name, State:state, Location:location, ReplicationRole:replicationRole, SourceServer:sourceServerResourceId}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, State:state, Location:location, ReplicationRole:replicationRole, SourceServer:sourceServerResourceId}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Norway East replica server.
2. Confirm the **Overview** page shows the expected region and that provisioning is complete.
3. Open **Replication** and verify the server is listed as a replica of the Sweden Central source server.
4. Confirm the replica remains read-only before you continue.

      </div>
    </div>

Expected output:

| Name | State | Location | ReplicationRole | SourceServer |
|---|---|---|---|---|
| pgsql-dr-noe-xxxxx | Ready | Norway East | AsyncReplica | /subscriptions/.../pgsql-dr-swc-xxxxx |

---

## Step 7 — List All Replicas

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server replica list   --name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --query '[].{Name:name, Location:location, State:state, Role:replicationRole}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server replica list `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '[].{Name:name, Location:location, State:state, Role:replicationRole}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Return to the primary PostgreSQL flexible server.
2. Open **Replication**.
3. Confirm the Norway East replica appears and reports a healthy replication state.

      </div>
    </div>

---

## Step 8 — Verify Data Replication

Connect to the **replica** and verify the sample rows were replicated.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
export PGPASSWORD="$ADMIN_PASSWORD"
psql "host=${REPLICA_SERVER}.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require"   -c "SELECT * FROM orders;"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$env:PGPASSWORD = $ADMIN_PASSWORD
psql "host=$REPLICA_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" `
  -c "SELECT * FROM orders;"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the replica server.
2. Use **Query editor** if available, or connect with Azure Cloud Shell / a local `psql` client.
3. Run `SELECT * FROM orders;` against `sampledb`.
4. Confirm the five rows from the source server are present.
5. Optionally test an `INSERT` to confirm the replica is still read-only before promotion.

      </div>
    </div>

You should see all 5 rows. The replica is **read-only** — any write attempt will fail.

---

## Step 9 — Monitor Replication Lag

The CLI check below confirms the server is still acting as a replica. Azure Monitor metrics expose the lag details.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server show   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --query '{Name:name, ReplicationRole:replicationRole, State:state}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, ReplicationRole:replicationRole, State:state}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the replica server.
2. Go to **Monitoring** → **Metrics**.
3. Chart **Max Physical Replication Lag** and **Read Replica Lag** over the last 30 minutes.
4. Confirm lag trends back toward zero after the initial seeding phase completes.

      </div>
    </div>

---

## Step 10 — Promote the Replica (Simulate Failover)

Promoting a replica disconnects it from the source and converts it to a standalone read-write server. **This action is irreversible.**

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server replica promote   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --yes   --output table

az postgres flexible-server show   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --query '{Name:name, State:state, ReplicationRole:replicationRole}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server replica promote `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --yes `
  --output table

az postgres flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, State:state, ReplicationRole:replicationRole}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Norway East replica server.
2. Go to **Replication**.
3. Choose **Promote**.
4. Confirm the warning that promotion is irreversible.
5. After the operation finishes, verify from **Overview** that the server is now standalone and writable.

      </div>
    </div>

Expected: `ReplicationRole` should now be `None`.

---

## Step 11 — Validate Write Access on Promoted Server

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
export PGPASSWORD="$ADMIN_PASSWORD"
psql "host=${REPLICA_SERVER}.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require"   -c "INSERT INTO orders (customer_name, product, amount, region) VALUES ('Frank', 'Failover Test', 99.99, 'norwayeast'); SELECT * FROM orders;"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$env:PGPASSWORD = $ADMIN_PASSWORD
psql "host=$REPLICA_SERVER.postgres.database.azure.com dbname=$DB_NAME user=$ADMIN_USER sslmode=require" `
  -c "INSERT INTO orders (customer_name, product, amount, region) VALUES ('Frank', 'Failover Test', 99.99, 'norwayeast'); SELECT * FROM orders;"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Use **Query editor** on the promoted server if it is available, or connect with Azure Cloud Shell / a local `psql` client.
2. Run an `INSERT` against `sampledb.orders`, then query the table again.
3. Confirm the new row appears. That proves the promoted replica is now the active writable server.

      </div>
    </div>

---

## Step 12 — (Optional) Virtual Endpoints

PostgreSQL Flexible Server supports **virtual endpoints** that provide stable connection points:

| Endpoint Type | Purpose | Behavior |
|---|---|---|
| **Writer** | Always routes to current primary | Follows promotions |
| **Reader** | Routes to read replicas | Load-balances across replicas |

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az postgres flexible-server virtual-endpoint create   --name writer-endpoint   --server-name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --endpoint-type ReadWrite   --members $REPLICA_SERVER   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az postgres flexible-server virtual-endpoint create `
  --name writer-endpoint `
  --server-name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --endpoint-type ReadWrite `
  --members $REPLICA_SERVER `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the source PostgreSQL flexible server.
2. Look for **Virtual endpoints** or the related replication blade in the left navigation.
3. If the feature is available in your region and subscription, create a **Writer** endpoint and review its members.
4. Record the virtual endpoint FQDN so you can compare it with the direct server name approach.

      </div>
    </div>

> **Note:** Virtual endpoints are a newer feature and may have limited availability. Check the Azure documentation for current region support.

---

## Step 13 — Cleanup

> ⚠️ **Skip this step if you want to keep resources for portal verification.**

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name $RG_PRIMARY   --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups** in the Azure portal.
2. Delete `rg-pgsql-dr-swc` once you are done with the source server.
3. Delete `rg-pgsql-dr-noe` once you are done with the replica.
4. Confirm both deletions only after you have finished any portal verification you need.

      </div>
    </div>

---

## Discussion & Next Steps

### Failover Strategy

PostgreSQL Flexible Server's cross-region failover is similar to MySQL's approach:

1. **Monitor** — Set up Azure Monitor alerts on server availability and replication lag.
2. **Promote** — Promote the cross-region replica to make it writable.
3. **Redirect** — Update application connection strings (or rely on virtual endpoints if configured).
4. **Re-protect** — Create a new read replica from the promoted server for continued DR coverage.

### Cost Considerations

| Component | Approximate Monthly Cost |
|---|---|
| Source: General Purpose D2ads_v5 (2 vCores) | Check Azure pricing calculator |
| Replica: General Purpose D2ads_v5 (2 vCores) | Check Azure pricing calculator |
| Storage: 32 GiB × 2 servers | Additional |
| **Total** | **Depends on region and retention settings** |

### Comparison: PostgreSQL vs MySQL vs Azure SQL

| Feature | Azure SQL | MySQL Flexible | PostgreSQL Flexible |
|---|---|---|---|
| Automatic failover | ✅ Failover Groups | ❌ Manual | ❌ Manual |
| DNS alias switching | ✅ Listener endpoints | ❌ | ⚠️ Virtual endpoints |
| Replication | Synchronous + async | Async (binlog) | Async (WAL streaming) |
| Max replicas | 4 geo-replicas | 10 | 5 |
| RPO | Near-zero | Replication lag | Replication lag |
| Promotion | Automatic or manual | Manual (irreversible) | Manual (irreversible) |

---

## Useful Links

* 📖 [Read replicas in Azure Database for PostgreSQL – Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-read-replicas)
* 📖 [Geo-replication concepts](https://learn.microsoft.com/azure/postgresql/read-replica/concepts-read-replicas-geo)
* 📖 [Manage read replicas – Azure CLI](https://learn.microsoft.com/cli/azure/postgres/flexible-server/replica)
* 📖 [Virtual endpoints](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-read-replicas-virtual-endpoints)
* 📖 [High availability overview](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-high-availability)

---
