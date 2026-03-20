---
layout: default
title: "Lab 3: Azure SQL Database – Geo-Replication &amp; Failover"
---

[← Back to Index](../index.md)

# Lab 3: Azure SQL Database – Geo-Replication & Failover

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

Your application's compute layer may span multiple regions, but if the database
lives in a single region, a regional outage will still bring everything down.
Azure SQL Database offers two complementary features that address this risk:

| Feature | What it does |
|---|---|
| **Active Geo-Replication** | Maintains an asynchronous, readable secondary replica in another region. You control when (and whether) to failover. |
| **Failover Groups** | Wraps geo-replication with **automatic DNS endpoint switching**. Your application connects to a stable listener FQDN that follows the primary role — no connection-string changes required during failover. |

### Why does this matter?

- **Near-zero RPO** — Asynchronous replication lag is typically under 5 seconds
  in normal conditions, so very little data is at risk.
- **Automatic failover** — With a Failover Group in `Automatic` policy mode,
  Azure detects region-level failures and promotes the secondary without human
  intervention.
- **Read scale-out** — The secondary is readable, so you can offload reporting
  and analytics queries to `<fg-name>.secondary.database.windows.net`.
- **Connection transparency** — Applications keep using the same read-write
  and read-only listener endpoints before and after failover.

---

## Architecture

The following diagram shows the target topology you will build in this lab.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Failover Group                                    │
│           fg-multiregion-sql-<suffix>.database.windows.net  (read-write)   │
│ fg-multiregion-sql-<suffix>.secondary.database.windows.net  (read-only)    │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
┌────────────────────────────┐         ┌────────────────────────────┐
│  Sweden Central (Primary)  │         │  Norway East (Secondary)   │
│                            │         │                            │
│  rg-dr-swc                 │         │  rg-dr-noe                 │
│  sql-dr-swc-<suffix>       │ Async   │  sql-dr-noe-<suffix>       │
│  └─ sqldb-sample           │ Geo-Rep │  └─ sqldb-sample           │
│     (read-write)           │────────▶│     (read-only)            │
└────────────────────────────┘         └────────────────────────────┘
```

**Data flow:**

1. Applications connect to the **read-write listener**
   (`<fg-name>.database.windows.net`), which resolves to the current primary
   server.
2. Writes are asynchronously replicated to the secondary server in Norway East.
3. Read-only workloads can connect to the **read-only listener**
   (`<fg-name>.secondary.database.windows.net`).
4. On failover (manual or automatic), the DNS records swap — the read-write
   listener now resolves to whichever server currently owns the primary role.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | A subscription where you can create SQL servers and databases. |
| **Azure CLI** | Version 2.50 or later. Run `az --version` to check. |
| **Shell** | Bash, PowerShell 7+, or Azure Cloud Shell. |
| **Portal access** | Needed if you want the portal-guided path. |
| **Az PowerShell module** | For the PowerShell path: `Install-Module -Name Az -Scope CurrentUser -Force` (skip in Cloud Shell — already available) |
| **Basic SQL knowledge** | Familiarity with `CREATE TABLE`, `INSERT`, and `SELECT` statements. |
| **`sqlcmd` (optional)** | The [go-sqlcmd](https://learn.microsoft.com/sql/tools/sqlcmd/go-sqlcmd-utility) CLI, classic `sqlcmd`, or another SQL client. If you do not have one, use the Azure Portal query editor. |
| **Your public IP** | Needed for firewall rules. Bash uses `curl`; PowerShell uses `Invoke-RestMethod`. |

> **Tip:** If you completed Lab 1 or Lab 2, you already have the CLI and
> subscription ready.

---

## How These Tabs Work

This page uses a shared tab preference:

- If you click **Bash** in one step, the rest of the page switches to **Bash**
- The selection is remembered for the page in your browser
- Every code block gets a copy button in the top-right corner

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
Connect-AzAccount
Get-AzSubscription | Format-Table Name, Id, State
Set-AzContext -SubscriptionId "<YOUR_SUBSCRIPTION_ID>"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the [Azure portal](https://portal.azure.com).
2. If needed, switch to the correct directory or tenant from the account menu.
3. Open **Subscriptions** and confirm the subscription you want to use.

</div>
</div>

---

## Step 1 — Define Variables

Use a single naming pattern throughout the lab. The SQL Server names and
Failover Group name should be unique so your DNS and server names do not collide
with existing Azure resources.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"

PRIMARY_RG="rg-dr-swc"
SECONDARY_RG="rg-dr-noe"

RANDOM_SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | head -c 5)
PRIMARY_SERVER="sql-dr-swc-${RANDOM_SUFFIX}"
SECONDARY_SERVER="sql-dr-noe-${RANDOM_SUFFIX}"

SQL_ADMIN_USER="sqladmin"
SQL_ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"

DB_NAME="sqldb-sample"
FG_NAME="fg-multiregion-sql-${RANDOM_SUFFIX}"

MY_IP=$(curl -s https://ifconfig.me/ip)

echo "Primary region   : $PRIMARY_REGION"
echo "Secondary region : $SECONDARY_REGION"
echo "Primary server   : $PRIMARY_SERVER"
echo "Secondary server : $SECONDARY_SERVER"
echo "Failover group   : $FG_NAME"
echo "Admin user       : $SQL_ADMIN_USER"
echo "Admin password   : $SQL_ADMIN_PASSWORD   (save this!)"
echo "Client IP        : $MY_IP"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_REGION = "swedencentral"
$SECONDARY_REGION = "norwayeast"

$PRIMARY_RG = "rg-dr-swc"
$SECONDARY_RG = "rg-dr-noe"

$RANDOM_SUFFIX = -join ((48..57 + 97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
$PRIMARY_SERVER = "sql-dr-swc-$RANDOM_SUFFIX"
$SECONDARY_SERVER = "sql-dr-noe-$RANDOM_SUFFIX"

$SQL_ADMIN_USER = "sqladmin"
$SQL_ADMIN_PASSWORD = "P@ssw0rd-$([guid]::NewGuid().ToString('N').Substring(0, 8))"

$DB_NAME = "sqldb-sample"
$FG_NAME = "fg-multiregion-sql-$RANDOM_SUFFIX"

$MY_IP = (Invoke-RestMethod -Uri "https://ifconfig.me/ip").Trim()

Write-Host "Primary region   : $PRIMARY_REGION"
Write-Host "Secondary region : $SECONDARY_REGION"
Write-Host "Primary server   : $PRIMARY_SERVER"
Write-Host "Secondary server : $SECONDARY_SERVER"
Write-Host "Failover group   : $FG_NAME"
Write-Host "Admin user       : $SQL_ADMIN_USER"
Write-Host "Admin password   : $SQL_ADMIN_PASSWORD   (save this!)"
Write-Host "Client IP        : $MY_IP"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

Write down or choose these values before you start:

- Primary region: `swedencentral`
- Secondary region: `norwayeast`
- Resource groups: `rg-dr-swc`, `rg-dr-noe`
- Primary SQL Server: `sql-dr-swc-<suffix>`
- Secondary SQL Server: `sql-dr-noe-<suffix>`
- SQL admin login: `sqladmin`
- SQL admin password: choose a strong password and save it securely
- Database name: `sqldb-sample`
- Failover Group name: `fg-multiregion-sql-<suffix>`
- Your client public IP address

</div>
</div>

<div class="lab-note">
<strong>Caution:</strong> Use the <strong>same SQL admin login and password</strong> on both SQL Servers. Failover Groups assume the credentials line up across the paired servers.
</div>

---

## Step 2 — Create Resource Groups

Create a resource group in each region so the primary and secondary resources are
isolated and easy to clean up later.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name "$PRIMARY_RG" --location "$PRIMARY_REGION" --output table
az group create --name "$SECONDARY_RG" --location "$SECONDARY_REGION" --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzResourceGroup -Name $PRIMARY_RG -Location $PRIMARY_REGION
New-AzResourceGroup -Name $SECONDARY_RG -Location $SECONDARY_REGION
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Create `rg-dr-swc` in **Sweden Central**.
3. Create `rg-dr-noe` in **Norway East**.

</div>
</div>

Expected outcome: both resource groups show a `Succeeded` provisioning state.

---

## Step 3 — Create the Primary SQL Server

This creates the logical SQL Server in Sweden Central. The database itself comes
in the next steps.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql server create \
  --name "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --location "$PRIMARY_REGION" \
  --admin-user "$SQL_ADMIN_USER" \
  --admin-password "$SQL_ADMIN_PASSWORD" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$sqlCred = New-Object System.Management.Automation.PSCredential(
    $SQL_ADMIN_USER,
    (ConvertTo-SecureString $SQL_ADMIN_PASSWORD -AsPlainText -Force)
)

New-AzSqlServer `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -Location $PRIMARY_REGION `
    -SqlAdministratorCredentials $sqlCred
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **SQL servers** and select **Create**.
2. Use:
   - Server name: `sql-dr-swc-<suffix>`
   - Resource group: `rg-dr-swc`
   - Location: **Sweden Central**
   - Authentication method: **Use SQL authentication**
   - Server admin login: `sqladmin`
   - Password: the value you saved in Step 1
3. Keep public network access enabled so the firewall rule in the next step can work.
4. Review and create the server.

</div>
</div>

---

## Step 4 — Configure Firewall on the Primary Server

Azure SQL denies inbound connections by default. Add a rule for your client IP
so you can connect later. If you plan to use Azure Portal Query editor, Cloud
Shell, App Service, or other Azure-hosted services, add the `0.0.0.0` rule as
well.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql server firewall-rule create \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --name "AllowMyIP" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP" \
  --output table
```

Recommended if you plan to use Portal Query editor, Cloud Shell, or other Azure-hosted services.

```bash
az sql server firewall-rule create \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --name "AllowAzureServices" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzSqlServerFirewallRule `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -FirewallRuleName "AllowMyIP" `
    -StartIpAddress $MY_IP `
    -EndIpAddress $MY_IP
```

Recommended if you plan to use Portal Query editor, Cloud Shell, or other Azure-hosted services.

```powershell
New-AzSqlServerFirewallRule `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -AllowAllAzureIPs
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary SQL Server.
2. Go to **Networking**.
3. Under **Firewall rules**, choose **Add your client IPv4 address**.
4. Save the rule.
5. If you will use **Query editor (preview)** or **Cloud Shell** later in this lab, also enable **Allow Azure services and resources to access this server**.

</div>
</div>

---

## Step 5 — Create the Sample Database

Use the **S0** tier to keep the lab inexpensive while still supporting
geo-replication.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql db create \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --service-objective S0 \
  --output table

az sql db show \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --query "{Name:name, Status:status, Location:location, Tier:currentServiceObjectiveName}" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzSqlDatabase `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -DatabaseName $DB_NAME `
    -RequestedServiceObjectiveName "S0"

Get-AzSqlDatabase `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -DatabaseName $DB_NAME |
    Select-Object DatabaseName, Status, Location, CurrentServiceObjectiveName
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **SQL databases** and create a new database.
2. Use:
   - Database name: `sqldb-sample`
   - Server: your primary server from Step 3
   - Resource group: `rg-dr-swc`
3. In **Compute + storage**, choose the **Standard** tier and set the service objective to **S0**.
4. Create the database.
5. After deployment, open the database overview and confirm the status is **Online**.

</div>
</div>

---

## Step 6 — Populate with Sample Data

Create a small table and insert a few rows. These rows will replicate to the
secondary and help you prove the replication path is working.

### Shared SQL script

Save or copy this SQL script. Both the `sqlcmd` and portal paths below use the
same statements.

```sql
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO

CREATE TABLE dbo.Products (
    ProductId   INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

INSERT INTO dbo.Products (ProductName, Price) VALUES
    (N'Widget A',  9.99),
    (N'Widget B', 19.99),
    (N'Widget C', 29.99),
    (N'Widget D', 39.99),
    (N'Widget E', 49.99);
GO

SELECT * FROM dbo.Products;
```

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

Save the shared SQL above as `/tmp/lab3-setup.sql`, then run:

```bash
sqlcmd \
  -S "${PRIMARY_SERVER}.database.windows.net" \
  -d "$DB_NAME" \
  -U "$SQL_ADMIN_USER" \
  -P "$SQL_ADMIN_PASSWORD" \
  -i /tmp/lab3-setup.sql
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

Save the shared SQL script from above to a temp file and run it:

```powershell
$SetupSqlPath = Join-Path $env:TEMP "lab3-setup.sql"

@'
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO
CREATE TABLE dbo.Products (
    ProductId   INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
INSERT INTO dbo.Products (ProductName, Price) VALUES
    (N'Widget A',  9.99),
    (N'Widget B', 19.99),
    (N'Widget C', 29.99),
    (N'Widget D', 39.99),
    (N'Widget E', 49.99);
GO
SELECT * FROM dbo.Products;
'@ | Set-Content -Path $SetupSqlPath -Encoding UTF8

sqlcmd `
    -S "${PRIMARY_SERVER}.database.windows.net" `
    -d $DB_NAME `
    -U $SQL_ADMIN_USER `
    -P $SQL_ADMIN_PASSWORD `
    -i $SetupSqlPath
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary database.
2. Select **Query editor (preview)**.
3. Sign in with the SQL admin login and password from Step 1.
4. Paste the shared SQL script above and run it.
5. If Query editor cannot connect, return to Step 4 and enable **Allow Azure services and resources to access this server** on the primary server.

</div>
</div>

You should see five rows returned.

---

## Step 7 — Create the Secondary SQL Server

Create the second logical SQL Server in **Norway East**. The admin credentials
must match the primary server so the failover configuration remains consistent.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql server create \
  --name "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --location "$SECONDARY_REGION" \
  --admin-user "$SQL_ADMIN_USER" \
  --admin-password "$SQL_ADMIN_PASSWORD" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
# Recreate the credential object if this is a new session:
$sqlCred = New-Object System.Management.Automation.PSCredential(
    $SQL_ADMIN_USER,
    (ConvertTo-SecureString $SQL_ADMIN_PASSWORD -AsPlainText -Force)
)

New-AzSqlServer `
    -ResourceGroupName $SECONDARY_RG `
    -ServerName $SECONDARY_SERVER `
    -Location $SECONDARY_REGION `
    -SqlAdministratorCredentials $sqlCred
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **SQL servers** and select **Create** again.
2. Use:
   - Server name: `sql-dr-noe-<suffix>`
   - Resource group: `rg-dr-noe`
   - Location: **Norway East**
   - Authentication method: **Use SQL authentication**
   - Server admin login: `sqladmin`
   - Password: the exact same password from Step 1
3. Review and create the server.

</div>
</div>

---

## Step 8 — Configure Firewall on the Secondary Server

Firewall rules are **per server** and are not copied by geo-replication. Add the
same client-IP rule to the secondary so you can query it after failover.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql server firewall-rule create \
  --server "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --name "AllowMyIP" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP" \
  --output table
```

Recommended if you plan to use Portal Query editor, Cloud Shell, or other Azure-hosted services.

```bash
az sql server firewall-rule create \
  --server "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --name "AllowAzureServices" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzSqlServerFirewallRule `
    -ResourceGroupName $SECONDARY_RG `
    -ServerName $SECONDARY_SERVER `
    -FirewallRuleName "AllowMyIP" `
    -StartIpAddress $MY_IP `
    -EndIpAddress $MY_IP
```

Recommended if you plan to use Portal Query editor, Cloud Shell, or other Azure-hosted services.

```powershell
New-AzSqlServerFirewallRule `
    -ResourceGroupName $SECONDARY_RG `
    -ServerName $SECONDARY_SERVER `
    -AllowAllAzureIPs
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the secondary SQL Server.
2. Go to **Networking**.
3. Add the same client IPv4 firewall rule that you used on the primary server.
4. Save the rule.
5. If you will use portal-based validation later, also enable **Allow Azure services and resources to access this server** here.

</div>
</div>

---

## Step 9 — Set Up Active Geo-Replication

Create a geo-replica of the sample database on the secondary server. Azure will
seed the secondary asynchronously from the primary.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql db replica create \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --partner-server "$SECONDARY_SERVER" \
  --partner-resource-group "$SECONDARY_RG" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
New-AzSqlDatabaseSecondary `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -DatabaseName $DB_NAME `
    -PartnerResourceGroupName $SECONDARY_RG `
    -PartnerServerName $SECONDARY_SERVER `
    -AllowConnections "All"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary database.
2. Go to **Geo-Replication**.
3. Select the secondary server in **Norway East** as the target.
4. Create the replica and wait for the seeding operation to begin.

</div>
</div>

This command can take a few minutes while the initial seeding completes.

---

## Step 10 — Verify the Replication Link

Check that the replication link is established and in a `CATCH_UP` or `SEEDING`
state.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql db replica list-links \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --query "[].{Partner:partnerServer, Location:partnerLocation, Role:role, PartnerRole:partnerRole, State:replicationState}" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Get-AzSqlDatabaseReplicationLink `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -DatabaseName $DB_NAME `
    -PartnerResourceGroupName $SECONDARY_RG `
    -PartnerServerName $SECONDARY_SERVER |
    Select-Object PartnerServer, PartnerLocation, Role, PartnerRole, ReplicationState
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary database.
2. Go to **Geo-Replication**.
3. Confirm the secondary server appears in **Norway East**.
4. Check that the replication state is progressing toward **CATCH_UP**.

</div>
</div>

Expected output includes:

| Column | Value |
|---|---|
| `Partner` | your secondary server name |
| `Location` | `Norway East` |
| `Role` | `Primary` |
| `PartnerRole` | `Secondary` |
| `State` | `CATCH_UP` |

> **Tip:** If the state shows `SEEDING`, wait a minute and re-run the command.
> The link will transition to `CATCH_UP` once initial seeding is complete.

---

## Step 11 — Create a Failover Group

A Failover Group wraps one or more geo-replicated databases with automatic DNS
endpoint switching. This is the recommended approach for production because
applications use stable listener endpoints and do not need connection-string
changes during failover.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group create \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --partner-server "$SECONDARY_SERVER" \
  --partner-resource-group "$SECONDARY_RG" \
  --add-db "$DB_NAME" \
  --failover-policy Automatic \
  --grace-period 60 \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$db = Get-AzSqlDatabase `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -DatabaseName $DB_NAME

New-AzSqlDatabaseFailoverGroup `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -PartnerResourceGroupName $SECONDARY_RG `
    -PartnerServerName $SECONDARY_SERVER `
    -FailoverGroupName $FG_NAME `
    -FailoverPolicy "Automatic" `
    -GracePeriodWithDataLossHours 1 |
    Add-AzSqlDatabaseToFailoverGroup -Database $db
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the primary SQL Server.
2. Go to **Failover groups** and select **Add group**.
3. Use your Failover Group name from Step 1.
4. Choose the secondary server in **Norway East**.
5. Add `sqldb-sample` to the group.
6. Set the read-write failover policy to **Automatic** with a **60-minute** grace period.
7. Create the failover group.

</div>
</div>

**Parameters explained:**

| Parameter | Purpose |
|---|---|
| `--failover-policy Automatic` | Azure will automatically fail over if the primary region is unavailable. Use `Manual` if you want full control. |
| `--grace-period 60` | Wait 60 minutes before triggering auto-failover. This avoids false positives from transient outages. Minimum is 1 hour for automatic policy. |
| `--add-db` | Databases to include in the group. You can add more later with `az sql failover-group update`. |

---

## Step 12 — Show Failover Group Endpoints

Retrieve the listener endpoints that your application should use.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group show \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --query "{Name:name, ReplicationRole:replicationRole, FailoverPolicy:readWriteEndpoint.failoverPolicy, GracePeriodMinutes:readWriteEndpoint.failoverWithDataLossGracePeriodMinutes}" \
  --output table

echo "Read-write listener: ${FG_NAME}.database.windows.net"
echo "Read-only listener:  ${FG_NAME}.secondary.database.windows.net"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$fg = Get-AzSqlDatabaseFailoverGroup `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -FailoverGroupName $FG_NAME

$fg | Select-Object FailoverGroupName, ReplicationRole,
    @{N='FailoverPolicy';E={$_.ReadWriteFailoverPolicy}},
    @{N='GracePeriodHours';E={$_.FailoverWithDataLossGracePeriodHours}}

Write-Host "Read-write listener: $FG_NAME.database.windows.net"
Write-Host "Read-only  listener: $FG_NAME.secondary.database.windows.net"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Failover Group.
2. On **Overview**, note the **Read-write listener** and **Read-only listener** values.
3. Confirm the current role still shows the Sweden Central server as **Primary**.

</div>
</div>

The listener FQDNs follow this pattern:

| Listener | FQDN |
|---|---|
| **Read-write** | `<fg-name>.database.windows.net` |
| **Read-only** | `<fg-name>.secondary.database.windows.net` |

> **Key insight:** These FQDNs are **role based**, not server based. After a
> failover, the read-write FQDN still looks the same, but it resolves to
> whichever server is currently primary.

---

## Step 13 — Validate: Query the Read-Write Endpoint

Connect through the **Failover Group read-write listener** to confirm that it
routes to the current primary server.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
sqlcmd \
  -S "${FG_NAME}.database.windows.net" \
  -d "$DB_NAME" \
  -U "$SQL_ADMIN_USER" \
  -P "$SQL_ADMIN_PASSWORD" \
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount;"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
sqlcmd `
  -S "${FG_NAME}.database.windows.net" `
  -d $DB_NAME `
  -U $SQL_ADMIN_USER `
  -P $SQL_ADMIN_PASSWORD `
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount;"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Failover Group overview and confirm the primary region is still **Sweden Central**.
2. If you want to validate the listener end-to-end from the portal, open **Cloud Shell** and run the Bash or PowerShell command from this step.
3. For a portal-only data check, open the current primary database and run the same `SELECT` statement in **Query editor (preview)**.

</div>
</div>

Expected result: `CurrentServer` is your Sweden Central server name and
`ProductCount` is `5`.

---

## Step 14 — Validate: Query the Read-Only Endpoint

Connect through the **read-only listener** to confirm the secondary is readable
and the data has replicated.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
sqlcmd \
  -S "${FG_NAME}.secondary.database.windows.net" \
  -d "$DB_NAME" \
  -U "$SQL_ADMIN_USER" \
  -P "$SQL_ADMIN_PASSWORD" \
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount;"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
sqlcmd `
  -S "${FG_NAME}.secondary.database.windows.net" `
  -d $DB_NAME `
  -U $SQL_ADMIN_USER `
  -P $SQL_ADMIN_PASSWORD `
  -Q "SELECT @@SERVERNAME AS CurrentServer, DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM dbo.Products) AS ProductCount;"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. The portal does not expose the `.secondary` listener as a separate blade.
2. For an exact listener test, open **Cloud Shell** from the portal and run the Bash or PowerShell command from this step.
3. For a portal-only validation, open the replicated database on the secondary server and run the same `SELECT` statement in **Query editor (preview)**.

</div>
</div>

Expected result: `CurrentServer` is your Norway East server name and
`ProductCount` is `5`.

<div class="lab-note">
<strong>Congratulations!</strong> Both listener endpoints are working and your sample data is now available across two Azure regions.
</div>

---

## Step 15 — Initiate Manual Failover

Simulate a regional failover by promoting the secondary server in Norway East to
primary.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group set-primary \
  --name "$FG_NAME" \
  --server "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Switch-AzSqlDatabaseFailoverGroup `
    -ResourceGroupName $SECONDARY_RG `
    -ServerName $SECONDARY_SERVER `
    -FailoverGroupName $FG_NAME
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Failover Group.
2. Choose the action to switch the primary to the Norway East server.
3. Use the planned failover option, not forced failover with data loss.
4. Confirm the operation and wait for Azure to finish the role change.

</div>
</div>

This performs a **planned failover** — Azure waits for pending transactions to
replicate before switching roles, so there is **zero data loss**.

> **Note:** A planned failover typically completes in under 30 seconds. A forced
> failover with `--allow-data-loss` is only for disaster conditions where the
> primary is unreachable and you accept potential data loss.

---

## Step 16 — Verify Roles Have Swapped

After failover, confirm that Norway East is now the primary and that the
read-write listener follows the new role.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group show \
  --name "$FG_NAME" \
  --server "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --query "{Name:name, ReplicationRole:replicationRole, PartnerRole:partnerServers[0].replicationRole}" \
  --output table

sqlcmd \
  -S "${FG_NAME}.database.windows.net" \
  -d "$DB_NAME" \
  -U "$SQL_ADMIN_USER" \
  -P "$SQL_ADMIN_PASSWORD" \
  -Q "SELECT @@SERVERNAME AS CurrentServer;"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Get-AzSqlDatabaseFailoverGroup `
    -ResourceGroupName $SECONDARY_RG `
    -ServerName $SECONDARY_SERVER `
    -FailoverGroupName $FG_NAME |
    Select-Object FailoverGroupName, ReplicationRole,
        @{N='PartnerRole';E={$_.PartnerServers[0].ReplicationRole}}

sqlcmd `
    -S "${FG_NAME}.database.windows.net" `
    -d $DB_NAME `
    -U $SQL_ADMIN_USER `
    -P $SQL_ADMIN_PASSWORD `
    -Q "SELECT @@SERVERNAME AS CurrentServer;"
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Failover Group overview.
2. Confirm the Norway East server now shows **Primary**.
3. To verify the listener itself, use **Cloud Shell** from the portal and run the command from this step.
4. For a portal-only check, open the database now marked primary and run `SELECT @@SERVERNAME AS CurrentServer;` in **Query editor (preview)**.

</div>
</div>

You should now see:

| Field | Value |
|---|---|
| `ReplicationRole` | `Primary` |
| `PartnerRole` | `Secondary` |

The `CurrentServer` result should now be your Norway East server name.

---

## Step 17 — (Optional) Fail Back to Sweden Central

If you want to restore the original topology, fail back by targeting the
original primary server.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az sql failover-group set-primary \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --output table

az sql failover-group show \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --query "{ReplicationRole:replicationRole}" \
  --output table
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Switch-AzSqlDatabaseFailoverGroup `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -FailoverGroupName $FG_NAME

Get-AzSqlDatabaseFailoverGroup `
    -ResourceGroupName $PRIMARY_RG `
    -ServerName $PRIMARY_SERVER `
    -FailoverGroupName $FG_NAME |
    Select-Object ReplicationRole
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Failover Group again.
2. Switch the primary back to the Sweden Central server.
3. Confirm the overview shows Sweden Central as **Primary**.

</div>
</div>

`ReplicationRole` should be `Primary` again.

---

## Cleanup

Delete the resource groups to remove everything created in this lab. Deleting
the groups also removes the SQL Servers, databases, firewall rules, and the
Failover Group.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
</div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name "$PRIMARY_RG" --yes --no-wait
az group delete --name "$SECONDARY_RG" --yes --no-wait

echo "Cleanup initiated. Resource deletion will continue in the background."
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
Remove-AzResourceGroup -Name $PRIMARY_RG -Force -AsJob
Remove-AzResourceGroup -Name $SECONDARY_RG -Force -AsJob

Write-Host "Cleanup initiated. Resource deletion will continue in the background."
```

</div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Resource groups**.
2. Delete `rg-dr-swc`.
3. Delete `rg-dr-noe`.
4. Confirm the deletions and wait for Azure to finish the cleanup.

</div>
</div>

> **Tip:** `--no-wait` returns immediately. Actual deletion may take a few
> minutes.

---

## Discussion

### Active Geo-Replication vs. Failover Groups

| Aspect | Active Geo-Replication | Failover Groups |
|---|---|---|
| **DNS management** | Manual — you update connection strings | Automatic — listener FQDNs follow the primary role |
| **Failover trigger** | Manual only (`az sql db replica set-primary`) | Manual or Automatic (policy based) |
| **Multiple databases** | Managed individually | Grouped — all databases fail over together |
| **Read-only endpoint** | Yes (connect directly to secondary) | Yes (via `.secondary` listener) |
| **Recommended for** | Fine-grained control, non-critical workloads | Production workloads needing automatic failover |

**Recommendation:** Use **Failover Groups** for most production scenarios. Use
standalone Active Geo-Replication only when you need per-database failover
control or when Failover Groups are not supported (for example, certain
Hyperscale configurations).

### RPO & RTO expectations

| Metric | Typical value | Notes |
|---|---|---|
| **RPO (Recovery Point Objective)** | ~5 seconds | Async replication; under heavy write load the lag can increase |
| **RTO (Recovery Time Objective)** | < 30 seconds (planned) | Automatic failover may take up to the grace period before Azure initiates it |
| **Automatic failover grace period** | 1–360 minutes | Controls how long Azure waits to confirm the outage is sustained before promoting the secondary |

> **Caution:** The grace period for automatic failover is measured in
> **minutes**, not seconds. A 60-minute grace period means Azure waits up to one
> hour before triggering automatic failover. Set this value based on your
> application's tolerance for downtime versus the risk of false positives.

### Azure SQL Managed Instance differences

Failover Groups are also available for **Azure SQL Managed Instance**, but with
some differences:

- The secondary instance must be in a different region and a different virtual
  network.
- A VNet peering or VPN/ExpressRoute connection is required between the two
  virtual networks.
- The failover group manages **all** user databases on the instance; you cannot
  select individual databases.
- The listener endpoint pattern is similar, but private endpoints and network
  routing often change the operational setup.

### Auto-failover policy considerations

| Policy | Behavior | Use when |
|---|---|---|
| `Automatic` | Azure promotes the secondary after the grace period expires | You want hands-off DR for sustained regional outages |
| `Manual` | No automatic failover; you must run `az sql failover-group set-primary` | You need human-in-the-loop decision making, or the application has complex failover orchestration |

**Best practice for production:**

1. Set `--failover-policy Automatic` with a grace period between 60 and 120
   minutes.
2. Ensure firewall rules, logins, and users are synchronized on both servers.
3. Test failover regularly (quarterly at minimum) during maintenance windows.
4. Monitor replication lag with `sys.dm_geo_replication_link_status` or Azure
   Monitor alerts.

### Monitoring replication health

You can query the replication status directly from the primary database:

```sql
SELECT
    partner_server,
    partner_database,
    replication_state_desc,
    last_replication,
    replication_lag_sec
FROM sys.dm_geo_replication_link_status;
```

Set up Azure Monitor alerts on the `replication_lag_sec` metric to get notified
when lag exceeds your RPO threshold.

---

## Key takeaways

1. **Active Geo-Replication** provides a readable secondary with near-zero RPO.
2. **Failover Groups** add automatic DNS management and policy-based failover on
   top of geo-replication.
3. SQL admin credentials must match on both servers if you use SQL authentication
   in this lab.
4. Firewall rules are **per server** — remember to configure both servers.
5. The **grace period** for automatic failover is your trade-off between
   minimizing downtime and avoiding false positives.
6. Always **test failover** before you need it in a real outage.

---

## Additional resources

- [Active Geo-Replication overview](https://learn.microsoft.com/azure/azure-sql/database/active-geo-replication-overview)
- [Failover Groups overview](https://learn.microsoft.com/azure/azure-sql/database/failover-group-sql-db)
- [Configure Failover Group — Tutorial](https://learn.microsoft.com/azure/azure-sql/database/failover-group-configure-sql-db)
- [Business continuity overview](https://learn.microsoft.com/azure/azure-sql/database/business-continuity-high-availability-disaster-recover-hadr-overview)
- [sys.dm_geo_replication_link_status](https://learn.microsoft.com/sql/relational-databases/system-dynamic-management-views/sys-dm-geo-replication-link-status-azure-sql-database)

---

[← Back to Index](../index.md) · [Next: Lab 4 — Azure Cosmos DB Global Distribution →](lab-04-cosmos-global-distribution.md)
