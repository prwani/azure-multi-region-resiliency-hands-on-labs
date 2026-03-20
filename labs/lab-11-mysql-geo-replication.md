---
layout: default
title: "Lab 11: Azure Database for MySQL – Cross-Region Read Replica"
---

[← Back to Index](../index.md)

# Lab 11: Azure Database for MySQL – Cross-Region Read Replica

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

Azure Database for MySQL Flexible Server is the recommended deployment option for MySQL workloads on Azure. Unlike Azure SQL Database, MySQL Flexible Server does not offer built-in Failover Groups with automatic DNS switching. Instead, it provides **cross-region read replicas** using MySQL's native asynchronous binary log (binlog) replication.

| Feature | Detail |
|---|---|
| **Read Replicas** | Up to 10 asynchronous replicas per source server |
| **Cross-Region Support** | Replicas can be placed in any supported Azure region |
| **Replication Method** | MySQL binlog-based asynchronous replication |
| **Promotion** | A replica can be promoted to a standalone read-write server (irreversible) |
| **Read Scale-Out** | Offload reporting, analytics, and BI queries to read replicas |

### Why Cross-Region Read Replicas?

* **Disaster Recovery** — If the primary region becomes unavailable, promote the cross-region replica to a standalone server and redirect application traffic.
* **Read Latency Reduction** — Place a read replica near your users in another geography to reduce query latency for read-heavy workloads.
* **Compliance** — Keep a copy of data in a specific geographic region for regulatory requirements.

### What Read Replicas Are — and What They Are Not

| Replicated | **Not** replicated |
|---|---|
| All databases on the source server | Server parameters (must be set independently) |
| All tables, rows, and schema changes | Firewall rules |
| User accounts and privileges | Scheduled events |
| Binary log position | Server-level configuration changes |

> **Key takeaway:** Read replicas provide _data continuity_ across regions, but promotion to primary is a **manual, one-way operation**. There is no automatic failover or DNS alias switching — your application must handle the endpoint change.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│   ┌──────────────────────────┐          ┌──────────────────────────┐    │
│   │   Sweden Central         │          │   Norway East            │    │
│   │                          │          │                          │    │
│   │  ┌────────────────────┐  │  Async   │  ┌────────────────────┐  │    │
│   │  │ mysql-dr-swc-xxxxx │  │  Binlog  │  │ mysql-dr-noe-xxxxx │  │    │
│   │  │ (Source Server)    │──┼──Repl───►│  │ (Read Replica)     │  │    │
│   │  │                    │  │          │  │                    │  │    │
│   │  │ • Read + Write     │  │          │  │ • Read-only        │  │    │
│   │  │ • sampledb         │  │          │  │ • sampledb (copy)  │  │    │
│   │  └────────────────────┘  │          │  └────────────────────┘  │    │
│   │                          │          │                          │    │
│   │  rg-mysql-dr-swc         │          │  rg-mysql-dr-noe         │    │
│   └──────────────────────────┘          └──────────────────────────┘    │
│                                                                          │
│   On failover (manual):                                                 │
│   1. Promote replica → standalone read-write server                     │
│   2. Update application connection strings                              │
│   3. (Optional) Create new replica from promoted server                 │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

**Data flow:**

1. Applications connect to the **source server** in Sweden Central for read-write operations.
2. All writes are asynchronously replicated via MySQL binlog to the read replica in Norway East.
3. Read-only workloads can connect directly to the replica endpoint.
4. During a disaster, you **promote** the replica (one-way operation) and update your application's connection string.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | Version 2.60 or later (`az --version`) |
| **Azure subscription** | With permissions to create MySQL Flexible Servers |
| **Bash shell** | Azure Cloud Shell, WSL, macOS Terminal, or Git Bash |
| **PowerShell 7+** | Recommended if you want to follow the PowerShell tabs |
| **mysql client** _(optional)_ | For direct database queries. Install via `sudo apt install mysql-client` |

> **Tip:** If you completed Lab 3 (Azure SQL), the workflow is similar — but MySQL uses read replicas instead of Failover Groups.

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

RG_PRIMARY="rg-mysql-dr-swc"
RG_SECONDARY="rg-mysql-dr-noe"

PRIMARY_SERVER="mysql-dr-swc-${RANDOM_SUFFIX}"
REPLICA_SERVER="mysql-dr-noe-${RANDOM_SUFFIX}"

ADMIN_USER="mysqladmin"
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

$RG_PRIMARY = "rg-mysql-dr-swc"
$RG_SECONDARY = "rg-mysql-dr-noe"

$PRIMARY_SERVER = "mysql-dr-swc-$RANDOM_SUFFIX"
$REPLICA_SERVER = "mysql-dr-noe-$RANDOM_SUFFIX"

$ADMIN_USER = "mysqladmin"
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
   - Resource groups: `rg-mysql-dr-swc`, `rg-mysql-dr-noe`
   - Server names: `mysql-dr-swc-<suffix>`, `mysql-dr-noe-<suffix>`
   - Database name: `sampledb`
3. Create or store an admin username and password in a password manager so you can reuse them in the verification steps.

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

1. Open the [Azure portal](https://portal.azure.com) and search for **Resource groups**.
2. Select **Create** and create `rg-mysql-dr-swc` in **Sweden Central**.
3. Create a second resource group named `rg-mysql-dr-noe` in **Norway East**.
4. Confirm both groups appear in the resource group list before you continue.

      </div>
    </div>

---

## Step 3 — Create the Source MySQL Flexible Server

Create a General Purpose tier server in Sweden Central. Cross-region read replicas require **General Purpose** or **Memory Optimized** tiers.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az mysql flexible-server create   --name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --location $PRIMARY_REGION   --admin-user $ADMIN_USER   --admin-password $ADMIN_PASSWORD   --sku-name Standard_D2ads_v5   --tier GeneralPurpose   --storage-size 32   --version 8.0.21   --public-access 0.0.0.0   --output table

az mysql flexible-server show   --name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --query '{Name:name, State:state, Location:location, SKU:sku.name, Version:version}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server create `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --location $PRIMARY_REGION `
  --admin-user $ADMIN_USER `
  --admin-password $ADMIN_PASSWORD `
  --sku-name Standard_D2ads_v5 `
  --tier GeneralPurpose `
  --storage-size 32 `
  --version 8.0.21 `
  --public-access 0.0.0.0 `
  --output table

az mysql flexible-server show `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '{Name:name, State:state, Location:location, SKU:sku.name, Version:version}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Search for **Azure Database for MySQL flexible servers** and select **Create**.
2. On **Basics**, choose:
   - Resource group: `rg-mysql-dr-swc`
   - Server name: your `mysql-dr-swc-<suffix>` value
   - Region: **Sweden Central**
   - Workload type: any lab-friendly option that lets you choose **General Purpose**
   - Admin username/password: the values you saved earlier
3. In **Compute + storage**, select a **General Purpose** SKU such as `Standard_D2ads_v5`.
4. In **Networking**, allow the connectivity option you need for the lab. If you want to match the CLI path, allow public access from Azure-hosted tools and your client IP.
5. Create the server, then open its **Overview** page and verify the server is **Ready** and running in **Sweden Central**.

      </div>
    </div>

<div class="lab-note">
<strong>Networking note:</strong> <code>--public-access 0.0.0.0</code> is convenient for a short lab because Azure-hosted tools can reach the server. In production, use private access or tightly scoped firewall rules.
</div>

<div class="lab-note">
<strong>Direct client note:</strong> If you plan to run <code>mysql</code> from your own terminal instead of Cloud Shell, add a firewall rule for your public IP on the source server now, then repeat the same firewall rule step for the replica after Step 5.
</div>

---

## Step 4 — Create a Sample Database and Table

Create a database on the source server. If you have the <code>mysql</code> client installed, add a small dataset so you can validate replication later.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az mysql flexible-server db create   --server-name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --database-name $DB_NAME   --output table

mysql -h "${PRIMARY_SERVER}.mysql.database.azure.com"   -u $ADMIN_USER   --password="$ADMIN_PASSWORD"   --ssl-mode=REQUIRED   $DB_NAME <<'SQL'
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name, price) VALUES
    ('Widget A', 9.99),
    ('Widget B', 19.99),
    ('Widget C', 29.99),
    ('Widget D', 39.99),
    ('Widget E', 49.99);

SELECT * FROM products;
SQL
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server db create `
  --server-name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --database-name $DB_NAME `
  --output table

@"
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name, price) VALUES
    ('Widget A', 9.99),
    ('Widget B', 19.99),
    ('Widget C', 29.99),
    ('Widget D', 39.99),
    ('Widget E', 49.99);

SELECT * FROM products;
"@ | mysql -h "$PRIMARY_SERVER.mysql.database.azure.com" `
  -u $ADMIN_USER `
  --password="$ADMIN_PASSWORD" `
  --ssl-mode=REQUIRED `
  $DB_NAME
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary MySQL flexible server in the portal.
2. In the left navigation, open **Databases** and create `sampledb`.
3. To add sample rows, use one of these options:
   - **Query editor** in the portal, if it is available in your environment.
   - **Azure Cloud Shell** or a local MySQL client using the connection details from the server overview.
4. Run the table and insert statements from the Bash or PowerShell tab, then verify you can query the five sample rows.

      </div>
    </div>

<div class="lab-note">
<strong>Client note:</strong> If your MySQL client complains about TLS, keep <code>--ssl-mode=REQUIRED</code> in place. Azure Database for MySQL Flexible Server expects encrypted connections.
</div>

---

## Step 5 — Create a Cross-Region Read Replica

Create an asynchronous read replica in Norway East.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
SOURCE_ID=$(az mysql flexible-server show --name $PRIMARY_SERVER --resource-group $RG_PRIMARY --query id -o tsv)
az mysql flexible-server replica create   --replica-name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --source-server $SOURCE_ID   --location $SECONDARY_REGION   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$SOURCE_ID = az mysql flexible-server show --name $PRIMARY_SERVER --resource-group $RG_PRIMARY --query id -o tsv
az mysql flexible-server replica create `
  --replica-name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --source-server $SOURCE_ID `
  --location $SECONDARY_REGION `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary MySQL flexible server.
2. Go to **Replication** or **Read replicas**.
3. Select **Add replica**.
4. Choose the secondary resource group, set the replica name to your `mysql-dr-noe-<suffix>` value, and choose **Norway East**.
5. Submit the create operation and expect the seeding process to take several minutes.

      </div>
    </div>

> **Note:** This command may take 10–15 minutes. The replica is seeded with a full snapshot of the source server, then binlog replication begins.

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
az mysql flexible-server show   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --query '{Name:name, State:state, Location:location, ReplicationRole:replicationRole, SourceServer:sourceServerResourceId}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, State:state, Location:location, ReplicationRole:replicationRole, SourceServer:sourceServerResourceId}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the replica server in **Norway East**.
2. Confirm the **Overview** page shows the server in the expected region and that provisioning is complete.
3. Open **Replication** and verify the server is listed as a replica of the Sweden Central source server.
4. Confirm the server is read-only before moving on.

      </div>
    </div>

Expected output:

| Name | State | Location | ReplicationRole | SourceServer |
|---|---|---|---|---|
| mysql-dr-noe-xxxxx | Ready | Norway East | Replica | /subscriptions/.../mysql-dr-swc-xxxxx |

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
az mysql flexible-server replica list   --name $PRIMARY_SERVER   --resource-group $RG_PRIMARY   --query '[].{Name:name, Location:location, State:state, Role:replicationRole}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server replica list `
  --name $PRIMARY_SERVER `
  --resource-group $RG_PRIMARY `
  --query '[].{Name:name, Location:location, State:state, Role:replicationRole}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Return to the primary MySQL flexible server.
2. Open **Replication**.
3. Confirm the Norway East server appears as the only read replica and that its status is healthy.

      </div>
    </div>

---

## Step 8 — Verify Data Replication

Query the **replica** and verify the sample rows are present. The replica should reject write operations while replication is still active.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
mysql -h "${REPLICA_SERVER}.mysql.database.azure.com"   -u $ADMIN_USER   --password="$ADMIN_PASSWORD"   --ssl-mode=REQUIRED   $DB_NAME   -e "SELECT * FROM products;"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
mysql -h "$REPLICA_SERVER.mysql.database.azure.com" `
  -u $ADMIN_USER `
  --password="$ADMIN_PASSWORD" `
  --ssl-mode=REQUIRED `
  $DB_NAME `
  -e "SELECT * FROM products;"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the replica server.
2. Use **Query editor** if it is available, or connect with Azure Cloud Shell / a local MySQL client.
3. Run `SELECT * FROM products;` against `sampledb`.
4. Confirm the five rows from the source server are present.
5. Optionally test a write to confirm the replica is still read-only before promotion.

      </div>
    </div>

You should see all 5 rows from the source server. The replica is **read-only** — any write attempt will fail with an error.

---

## Step 9 — Monitor Replication Lag

The CLI check below confirms the server is still acting as a replica. For actual lag values, use Azure Monitor metrics.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az mysql flexible-server show   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --query '{Name:name, ReplicationRole:replicationRole, State:state}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, ReplicationRole:replicationRole, State:state}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the replica server in the portal.
2. Go to **Monitoring** → **Metrics**.
3. Chart **Replication Lag In Seconds** over the last 30 minutes.
4. Confirm the lag stays low and trends back toward zero after the initial seeding completes.

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
az mysql flexible-server replica stop-replication   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --yes   --output table

az mysql flexible-server show   --name $REPLICA_SERVER   --resource-group $RG_SECONDARY   --query '{Name:name, State:state, ReplicationRole:replicationRole}'   --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az mysql flexible-server replica stop-replication `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --yes `
  --output table

az mysql flexible-server show `
  --name $REPLICA_SERVER `
  --resource-group $RG_SECONDARY `
  --query '{Name:name, State:state, ReplicationRole:replicationRole}' `
  --output table
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the replica server in **Norway East**.
2. Go to **Replication**.
3. Choose **Stop replication** or **Promote**.
4. Confirm the warning dialog; this breaks the replication relationship permanently.
5. After the operation completes, return to **Overview** and verify the server is now a standalone writable server.

      </div>
    </div>

Expected: `ReplicationRole` should now be `None` — the server is an independent, writable MySQL instance.

---

## Step 11 — Validate Write Access on Promoted Server

After promotion, the former replica should accept writes.

<div class="lab-tabs">
      <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
        <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
        <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
        <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
      </div>

      <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
mysql -h "${REPLICA_SERVER}.mysql.database.azure.com"   -u $ADMIN_USER   --password="$ADMIN_PASSWORD"   --ssl-mode=REQUIRED   $DB_NAME   -e "INSERT INTO products (name, price) VALUES ('Failover Widget', 59.99); SELECT * FROM products;"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
mysql -h "$REPLICA_SERVER.mysql.database.azure.com" `
  -u $ADMIN_USER `
  --password="$ADMIN_PASSWORD" `
  --ssl-mode=REQUIRED `
  $DB_NAME `
  -e "INSERT INTO products (name, price) VALUES ('Failover Widget', 59.99); SELECT * FROM products;"
```

      </div>

      <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Stay on the promoted server in the portal.
2. Open **Query editor** if it is available, or connect from Cloud Shell / your client.
3. Run an `INSERT` against `sampledb.products`, then query the table again.
4. Confirm the new row appears. That proves the promoted replica is now the active writable server.

      </div>
    </div>

---

## Step 12 — Cleanup

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

1. Search for **Resource groups**.
2. Open `rg-mysql-dr-swc` and select **Delete resource group**.
3. Repeat for `rg-mysql-dr-noe`.
4. Confirm both deletions only after you are done testing or capturing screenshots.

      </div>
    </div>

---

## Discussion & Next Steps

### Failover Strategy

Unlike Azure SQL Failover Groups, MySQL Flexible Server does not provide automatic DNS switching. Your application-level failover strategy should include:

1. **Health monitoring** — Use Azure Monitor alerts on the source server's availability metric.
2. **Promote replica** — When a regional outage is detected, promote the cross-region replica.
3. **DNS / connection string update** — Update your application's connection string to point to the promoted server. Consider using Azure Traffic Manager or Azure DNS with low TTLs.
4. **Re-establish replication** — Create a new read replica from the promoted server for continued DR coverage.

### Cost Considerations

| Component | Approximate Monthly Cost |
|---|---|
| Source: General Purpose D2ads_v5 (2 vCores) | Check Azure pricing calculator |
| Replica: General Purpose D2ads_v5 (2 vCores) | Check Azure pricing calculator |
| Storage: 32 GiB × 2 servers | Additional |
| **Total** | **Depends on region and retention settings** |

### Comparison with Azure SQL

| Feature | Azure SQL | MySQL Flexible Server |
|---|---|---|
| Automatic failover | ✅ Failover Groups | ❌ Manual promotion |
| DNS alias switching | ✅ Listener endpoints | ❌ Must update connection strings |
| Read replicas | ✅ (via geo-replication) | ✅ (binlog replication) |
| Max replicas | 4 geo-replicas | 10 read replicas |
| RPO | Near-zero | Depends on replication lag |

---

## Useful Links

* 📖 [Read replicas in Azure Database for MySQL – Flexible Server](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-read-replicas)
* 📖 [Manage read replicas – Azure CLI](https://learn.microsoft.com/cli/azure/mysql/flexible-server/replica)
* 📖 [Geo-replication for MySQL Flexible Server](https://techcommunity.microsoft.com/blog/adformysql/read-replica-in-geo-paired-regions---general-availability/3834224)
* 📖 [High availability concepts](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-high-availability)

---
