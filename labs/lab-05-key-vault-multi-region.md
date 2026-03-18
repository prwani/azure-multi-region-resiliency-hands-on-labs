---
layout: default
title: "Lab 5: Azure Key Vault – Multi-Region Backup & Sync"
---

[← Back to Index](../index.md)

# Lab 5: Azure Key Vault – Multi-Region Backup & Sync

> **Objective:** Deploy Azure Key Vaults in two regions, populate the primary vault
> with secrets, keys, and certificates, then back up and restore (or sync) those
> items to a secondary vault so your application can survive a regional outage.

---

## Why Key Vault Needs Special DR Consideration

Azure Key Vault is a foundational service — almost every other Azure resource
depends on it for connection strings, API keys, encryption keys, and TLS
certificates. Despite its importance, **standard Key Vaults do not replicate
across regions automatically**. Each vault is a regional resource, and if the
region hosting your vault becomes unavailable, dependent services will fail to
retrieve secrets.

Microsoft does replicate vault contents to a paired region in a **read-only**
fashion for disaster recovery, but you cannot control the target region, and
failover is managed by Microsoft — not by you. If you need **active-active**
access, predictable RTOs, or vaults in non-paired regions (like Sweden Central
and Norway East), you must implement your own backup-and-sync strategy.

This lab walks through two complementary approaches:

1. **Backup / Restore** — the official mechanism that preserves key material
   that cannot be exported (HSM-backed keys, certificates with non-exportable
   private keys).
2. **Read-and-recreate** — a simpler script-based approach for secrets whose
   plaintext values can be read by your identity.

---

## Architecture

```text
┌─────────────────────────┐            ┌─────────────────────────┐
│   Sweden Central        │            │   Norway East           │
│                         │   Backup   │                         │
│  ┌───────────────────┐  │  ───────►  │  ┌───────────────────┐  │
│  │ kv-dr-swc-<uid>   │  │  Restore   │  │ kv-dr-noe-<uid>   │  │
│  │ (Primary Vault)   │  │  ◄───────  │  │ (Secondary Vault) │  │
│  │ • Secrets         │  │            │  │ • Secrets         │  │
│  │ • Keys            │  │            │  │ • Keys            │  │
│  │ • Certificates    │  │            │  │ • Certificates    │  │
│  └───────────────────┘  │            │  └───────────────────┘  │
└─────────────────────────┘            └─────────────────────────┘
              │    ┌─────────────────────┐    │
              └───►│ Automation (opt.)   │◄───┘
                   │ Az Automation /     │
                   │ Logic App / Pipeline│
                   └─────────────────────┘
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure subscription** | Owner or Contributor + Key Vault Administrator role |
| **Azure CLI ≥ 2.60** | [Install the Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) |
| **PowerShell 7+** *(optional)* | Needed only for the sync script in Step 10 |
| **Logged-in CLI session** | `az login` and `az account set --subscription <id>` |
| **Completed Lab 1** *(recommended)* | Familiarity with the two-region setup |

> **Note:** Backup and restore of Key Vault objects requires that both vaults
> belong to the **same Azure subscription** and the **same Azure geography**
> (e.g., Europe). Sweden Central and Norway East both belong to the *Europe*
> geography, so backup/restore works between them.

---

## Step 1 — Set Variables

Open a terminal and set the variables you will reuse throughout this lab.

```bash
# Unique suffix — use your initials + random digits to avoid name collisions
UNIQUE_SUFFIX="$(echo $RANDOM | head -c 5)"

# Resource groups
RG_PRIMARY="rg-dr-swc"
RG_SECONDARY="rg-dr-noe"

# Regions
LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

# Key Vault names (globally unique, 3-24 alphanumeric + hyphens)
KV_PRIMARY="kv-dr-swc-${UNIQUE_SUFFIX}"
KV_SECONDARY="kv-dr-noe-${UNIQUE_SUFFIX}"

# Backup directory
BACKUP_DIR="./kv-backups"
mkdir -p "$BACKUP_DIR"

echo "Primary vault : $KV_PRIMARY"
echo "Secondary vault: $KV_SECONDARY"
```

---

## Step 2 — Create Resource Groups

```bash
az group create --name "$RG_PRIMARY"   --location "$LOCATION_PRIMARY"   --output table
az group create --name "$RG_SECONDARY" --location "$LOCATION_SECONDARY" --output table
```

---

## Step 3 — Create the Primary Key Vault (Sweden Central)

```bash
az keyvault create \
  --name "$KV_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku standard \
  --enable-rbac-authorization true \
  --output table
```

> **Tip:** We use `--enable-rbac-authorization true` so access is governed by
> Azure RBAC roles rather than vault access policies.

Assign yourself the **Key Vault Administrator** role on both vaults:

```bash
SIGNED_IN_USER=$(az ad signed-in-user show --query id --output tsv)
KV_PRIMARY_ID=$(az keyvault show --name "$KV_PRIMARY" --query id --output tsv)

az role assignment create \
  --role "Key Vault Administrator" \
  --assignee "$SIGNED_IN_USER" \
  --scope "$KV_PRIMARY_ID" \
  --output table
```

> **Note:** RBAC role assignments can take up to 10 minutes to propagate. If
> subsequent commands return *403 Forbidden*, wait and retry.

---

## Step 4 — Create the Secondary Key Vault (Norway East)

```bash
az keyvault create \
  --name "$KV_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --sku standard \
  --enable-rbac-authorization true \
  --output table

KV_SECONDARY_ID=$(az keyvault show --name "$KV_SECONDARY" --query id --output tsv)

az role assignment create \
  --role "Key Vault Administrator" \
  --assignee "$SIGNED_IN_USER" \
  --scope "$KV_SECONDARY_ID" \
  --output table
```

---

## Step 5 — Add Sample Secrets to the Primary Vault

```bash
az keyvault secret set \
  --vault-name "$KV_PRIMARY" \
  --name "DatabaseConnectionString" \
  --value "Server=sql-primary.database.windows.net;Database=appdb;User=appadmin;Password=P@ssw0rd!" \
  --output table

az keyvault secret set \
  --vault-name "$KV_PRIMARY" \
  --name "StorageAccountKey" \
  --value "DefaultEndpointsProtocol=https;AccountName=stdrswc;AccountKey=FAKE+KEY==" \
  --output table

az keyvault secret set \
  --vault-name "$KV_PRIMARY" \
  --name "AppInsightsKey" \
  --value "00000000-0000-0000-0000-000000000000" \
  --output table

az keyvault secret set \
  --vault-name "$KV_PRIMARY" \
  --name "ApiKey-ExternalService" \
  --value "sk-demo-external-api-key-12345" \
  --output table
```

> ⚠️ **Caution:** These are demo values. Never commit real credentials to
> scripts or source control.

---

## Step 6 — Add a Sample Key

Create an RSA key that could be used for data encryption or signing:

```bash
az keyvault key create \
  --vault-name "$KV_PRIMARY" \
  --name "EncryptionKey" \
  --kty RSA \
  --size 2048 \
  --ops encrypt decrypt sign verify \
  --output table
```

---

## Step 7 — Add a Sample Certificate

Generate a self-signed certificate for demo purposes:

```bash
az keyvault certificate create \
  --vault-name "$KV_PRIMARY" \
  --name "AppCert" \
  --policy "$(az keyvault certificate get-default-policy)" \
  --output table
```

Verify the certificate was issued:

```bash
az keyvault certificate show --vault-name "$KV_PRIMARY" --name "AppCert" \
  --query "{Name:name, Enabled:attributes.enabled, Expiry:attributes.expires}" \
  --output table
```

---

## Step 8 — Backup Secrets, Keys, and Certificates

The `az keyvault * backup` commands serialize each object to an encrypted blob
file. These blobs can only be restored to a vault in the **same subscription**
and **same Azure geography**.

### 8a — Back Up Secrets

```bash
az keyvault secret backup --vault-name "$KV_PRIMARY" \
  --name "DatabaseConnectionString" --file "$BACKUP_DIR/DatabaseConnectionString.bak"
az keyvault secret backup --vault-name "$KV_PRIMARY" \
  --name "StorageAccountKey" --file "$BACKUP_DIR/StorageAccountKey.bak"
az keyvault secret backup --vault-name "$KV_PRIMARY" \
  --name "AppInsightsKey" --file "$BACKUP_DIR/AppInsightsKey.bak"
az keyvault secret backup --vault-name "$KV_PRIMARY" \
  --name "ApiKey-ExternalService" --file "$BACKUP_DIR/ApiKey-ExternalService.bak"
```

### 8b — Back Up the Key

```bash
az keyvault key backup --vault-name "$KV_PRIMARY" \
  --name "EncryptionKey" --file "$BACKUP_DIR/EncryptionKey.bak"
```

### 8c — Back Up the Certificate

```bash
az keyvault certificate backup --vault-name "$KV_PRIMARY" \
  --name "AppCert" --file "$BACKUP_DIR/AppCert.bak"
```

Verify the backup files:

```bash
ls -la "$BACKUP_DIR"
```

> **Important:** Backup files are encrypted and tied to your Azure AD tenant and
> subscription. They cannot be restored to a different tenant or subscription.

---

## Step 9 — Restore to the Secondary Vault

### 9a — Restore Secrets

```bash
az keyvault secret restore --vault-name "$KV_SECONDARY" \
  --file "$BACKUP_DIR/DatabaseConnectionString.bak"
az keyvault secret restore --vault-name "$KV_SECONDARY" \
  --file "$BACKUP_DIR/StorageAccountKey.bak"
az keyvault secret restore --vault-name "$KV_SECONDARY" \
  --file "$BACKUP_DIR/AppInsightsKey.bak"
az keyvault secret restore --vault-name "$KV_SECONDARY" \
  --file "$BACKUP_DIR/ApiKey-ExternalService.bak"
```

### 9b — Restore the Key

```bash
az keyvault key restore --vault-name "$KV_SECONDARY" \
  --file "$BACKUP_DIR/EncryptionKey.bak"
```

### 9c — Restore the Certificate

```bash
az keyvault certificate restore --vault-name "$KV_SECONDARY" \
  --file "$BACKUP_DIR/AppCert.bak"
```

> **Tip:** If you receive an error stating the object already exists in the
> target vault, the restore will be rejected. Backup/restore is designed for
> initial seeding, not incremental sync. For ongoing sync, see Step 10.

---

## Step 10 — Alternative: Secret Sync Script

For **secrets** whose plaintext values your identity can read, a simpler
approach is to enumerate them in the primary vault and re-create them in the
secondary vault. This avoids backup-file geography restrictions entirely.

### Bash Version

```bash
#!/usr/bin/env bash
# sync-secrets.sh <source-vault> <target-vault>
SOURCE_VAULT="${1:?Usage: $0 <source-vault> <target-vault>}"
TARGET_VAULT="${2:?Usage: $0 <source-vault> <target-vault>}"

echo "Syncing secrets: $SOURCE_VAULT → $TARGET_VAULT"
for SECRET_NAME in $(az keyvault secret list --vault-name "$SOURCE_VAULT" \
    --query "[].name" --output tsv); do
  echo "  Syncing: $SECRET_NAME"
  SECRET_VALUE=$(az keyvault secret show --vault-name "$SOURCE_VAULT" \
    --name "$SECRET_NAME" --query "value" --output tsv)
  az keyvault secret set --vault-name "$TARGET_VAULT" \
    --name "$SECRET_NAME" --value "$SECRET_VALUE" --output none
done
echo "Secret sync complete."
```

```bash
chmod +x sync-secrets.sh
./sync-secrets.sh "$KV_PRIMARY" "$KV_SECONDARY"
```

### PowerShell Version

```powershell
# Sync-KeyVaultSecrets.ps1
param(
    [Parameter(Mandatory)] [string] $SourceVault,
    [Parameter(Mandatory)] [string] $TargetVault
)

$secrets = az keyvault secret list --vault-name $SourceVault `
    --query "[].name" --output tsv

foreach ($name in $secrets) {
    Write-Host "  Syncing: $name"
    $val = az keyvault secret show --vault-name $SourceVault `
        --name $name --query "value" --output tsv
    az keyvault secret set --vault-name $TargetVault `
        --name $name --value $val --output none | Out-Null
}
Write-Host "Secret sync complete." -ForegroundColor Green
```

```powershell
.\Sync-KeyVaultSecrets.ps1 -SourceVault $KV_PRIMARY -TargetVault $KV_SECONDARY
```

> **Note:** This script-based approach works **only for secrets**. Keys and
> certificates with non-exportable private key material cannot be read as
> plaintext — you must use the backup/restore method for those.

---

## Step 11 — Validate: Retrieve Items from Both Vaults

Confirm that both vaults contain the same data.

### Compare Secrets

```bash
echo "=== Primary Vault ==="
az keyvault secret list --vault-name "$KV_PRIMARY" \
  --query "[].{Name:name}" --output table

echo "=== Secondary Vault ==="
az keyvault secret list --vault-name "$KV_SECONDARY" \
  --query "[].{Name:name}" --output table
```

### Verify a Secret Value Matches

```bash
PRIMARY_VAL=$(az keyvault secret show --vault-name "$KV_PRIMARY" \
  --name "DatabaseConnectionString" --query value --output tsv)

SECONDARY_VAL=$(az keyvault secret show --vault-name "$KV_SECONDARY" \
  --name "DatabaseConnectionString" --query value --output tsv)

if [ "$PRIMARY_VAL" == "$SECONDARY_VAL" ]; then
  echo "✅ Secret values match across both vaults."
else
  echo "❌ Secret values DO NOT match — investigate."
fi
```

### Compare Keys and Certificates

```bash
echo "=== Primary Vault Keys ==="
az keyvault key list --vault-name "$KV_PRIMARY" \
  --query "[].{Name:name, KeyType:keyType}" --output table

echo "=== Secondary Vault Keys ==="
az keyvault key list --vault-name "$KV_SECONDARY" \
  --query "[].{Name:name, KeyType:keyType}" --output table

echo "=== Primary Vault Certificates ==="
az keyvault certificate list --vault-name "$KV_PRIMARY" \
  --query "[].{Name:name}" --output table

echo "=== Secondary Vault Certificates ==="
az keyvault certificate list --vault-name "$KV_SECONDARY" \
  --query "[].{Name:name}" --output table
```

---

## Step 12 — Cleanup

> ⚠️ **Soft-delete behavior:** Since Azure CLI 2.42+, soft-delete is enabled by
> default on all Key Vaults and **cannot be disabled**. When you delete a vault,
> it enters a soft-deleted state for 7–90 days (default 90). During that period
> the vault name remains reserved and you cannot create a new vault with the
> same name.

### Delete the Vaults

```bash
az keyvault delete --name "$KV_PRIMARY"  --resource-group "$RG_PRIMARY"
az keyvault delete --name "$KV_SECONDARY" --resource-group "$RG_SECONDARY"
```

### Purge Soft-Deleted Vaults (Optional)

If you want to immediately free up the vault names, purge them. **This is
irreversible.**

```bash
az keyvault purge --name "$KV_PRIMARY"  --location "$LOCATION_PRIMARY"
az keyvault purge --name "$KV_SECONDARY" --location "$LOCATION_SECONDARY"
```

### Delete Resource Groups

If these resource groups are not shared with other labs:

```bash
az group delete --name "$RG_PRIMARY"   --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait
```

### Clean Up Local Backup Files

```bash
rm -rf "$BACKUP_DIR"
```

---

## Discussion & Next Steps

### Backup/Restore Restrictions — Key Points

| Restriction | Detail |
|---|---|
| **Same subscription** | You cannot restore a backup blob to a vault in a different subscription. |
| **Same Azure geography** | Both vaults must be in the same geography (e.g., *Europe*). You cannot restore a backup taken in *Europe* to a vault in *US*. |
| **Object versioning** | Restore brings all versions of the object. If a version already exists in the target vault, the restore will fail. |
| **Soft-delete conflicts** | If a secret was previously soft-deleted in the target vault, restore will fail until you purge it. |

### Automation Approaches

In production you would not run backup/restore manually. Consider:

1. **Azure Automation Runbook** — Schedule a PowerShell runbook using the sync
   script from Step 10. Use a Managed Identity with *Key Vault Administrator*.

2. **Event Grid + Azure Function** — Subscribe to
   `Microsoft.KeyVault.SecretNewVersionCreated` events and replicate in near
   real-time.

3. **Azure DevOps / GitHub Actions Pipeline** — Add a scheduled stage that runs
   the sync script, keeping your DR vault in lockstep with production.

4. **Azure Logic App** — Use the Key Vault connector with Event Grid triggers.

### Managed HSM — Native Multi-Region Replication

For organizations with strict compliance requirements, **Azure Key Vault
Managed HSM** offers **multi-region replication** (preview). Managed HSM vaults
replicate key material across regions automatically — no manual backup/restore.

Key advantages:
- **Near real-time replication** of key material across regions
- **FIPS 140-2 Level 3** validated HSMs
- **Active-active reads** — no cross-region latency for key operations

> **Note:** Managed HSM is significantly more expensive than standard Key Vault
> (billed hourly per HSM pool). For most workloads, the backup/restore +
> automation approach in this lab is more practical and cost-effective.

### When to Use Which Approach

| Scenario | Recommended Approach |
|---|---|
| Secrets (connection strings, API keys) | Read-and-recreate sync script (Step 10) |
| Software-protected keys (RSA, EC) | Backup/restore (Steps 8–9) |
| HSM-protected keys | Backup/restore (only option — keys cannot be exported) |
| Certificates with exportable keys | Either approach works |
| Certificates with non-exportable keys | Backup/restore only |
| Enterprise with strict compliance | Managed HSM multi-region replication |

---

## Useful Links

- 📖 [Key Vault backup and restore](https://learn.microsoft.com/azure/key-vault/general/backup?tabs=azure-cli)
- 📖 [Key Vault soft-delete overview](https://learn.microsoft.com/azure/key-vault/general/soft-delete-overview)
- 📖 [Managed HSM multi-region replication](https://learn.microsoft.com/azure/key-vault/managed-hsm/multi-region-replication)
- 📖 [Key Vault Event Grid integration](https://learn.microsoft.com/azure/key-vault/general/event-grid-overview)
- 📖 [Azure geographies](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure#azure-cross-region-replication-pairings-for-all-geographies)

---

[← Back to Index](../index.md) | [Next: Lab 6 — Azure Service Bus Geo-DR →](lab-06-service-bus-geo-dr.md)
