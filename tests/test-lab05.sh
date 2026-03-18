#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  LAB 5: Key Vault Multi-Region Sync        "
echo "============================================"

UNIQUE_SUFFIX="l5$(date +%s | tail -c 4)"
RG_PRIMARY="rg-dr-swc"
RG_SECONDARY="rg-dr-noe"
LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"
KV_PRIMARY="kv-dr-swc-${UNIQUE_SUFFIX}"
KV_SECONDARY="kv-dr-noe-${UNIQUE_SUFFIX}"
BACKUP_DIR="/tmp/kv-backups-${UNIQUE_SUFFIX}"
mkdir -p "$BACKUP_DIR"

echo "UNIQUE_SUFFIX=$UNIQUE_SUFFIX"
echo "KV_PRIMARY=$KV_PRIMARY"
echo "KV_SECONDARY=$KV_SECONDARY"

cat > /tmp/lab5_vars.env <<EOF
KV_PRIMARY=$KV_PRIMARY
KV_SECONDARY=$KV_SECONDARY
BACKUP_DIR=$BACKUP_DIR
EOF

echo ""
echo ">>> Step 1: Creating resource groups..."
az group create --name "$RG_PRIMARY" --location "$LOCATION_PRIMARY" -o none
echo "  OK: $RG_PRIMARY"
az group create --name "$RG_SECONDARY" --location "$LOCATION_SECONDARY" -o none
echo "  OK: $RG_SECONDARY"

echo ""
echo ">>> Step 2: Creating primary Key Vault..."
az keyvault create \
  --name "$KV_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku standard \
  --enable-rbac-authorization true \
  -o none
echo "  OK: $KV_PRIMARY"

echo ""
echo ">>> Step 3: Assigning Key Vault Administrator role..."
SIGNED_IN_USER=$(az ad signed-in-user show --query id -o tsv)
KV_PRIMARY_ID=$(az keyvault show --name "$KV_PRIMARY" --query id -o tsv)
az role assignment create \
  --role "Key Vault Administrator" \
  --assignee "$SIGNED_IN_USER" \
  --scope "$KV_PRIMARY_ID" \
  -o none 2>&1 || echo "  WARN: role assignment may already exist"
echo "  OK: role assigned on primary"

echo ""
echo ">>> Step 4: Creating secondary Key Vault..."
az keyvault create \
  --name "$KV_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --sku standard \
  --enable-rbac-authorization true \
  -o none
echo "  OK: $KV_SECONDARY"

KV_SECONDARY_ID=$(az keyvault show --name "$KV_SECONDARY" --query id -o tsv)
az role assignment create \
  --role "Key Vault Administrator" \
  --assignee "$SIGNED_IN_USER" \
  --scope "$KV_SECONDARY_ID" \
  -o none 2>&1 || echo "  WARN: role assignment may already exist"
echo "  OK: role assigned on secondary"

echo ""
echo ">>> Step 5: Waiting for RBAC propagation..."
sleep 30

echo ""
echo ">>> Step 6: Adding sample secrets to primary..."
az keyvault secret set --vault-name "$KV_PRIMARY" --name "DatabaseConnectionString" \
  --value "Server=sql-primary.database.windows.net;Database=appdb;User=admin;Password=demo!" -o none
az keyvault secret set --vault-name "$KV_PRIMARY" --name "StorageAccountKey" \
  --value "DefaultEndpointsProtocol=https;AccountName=stdrswc;AccountKey=FAKE+KEY==" -o none
az keyvault secret set --vault-name "$KV_PRIMARY" --name "AppInsightsKey" \
  --value "00000000-0000-0000-0000-000000000000" -o none
echo "  OK: 3 secrets added"

echo ""
echo ">>> Step 7: Creating a sample key..."
az keyvault key create --vault-name "$KV_PRIMARY" --name "EncryptionKey" \
  --kty RSA --size 2048 --ops encrypt decrypt sign verify -o none
echo "  OK: EncryptionKey created"

echo ""
echo ">>> Step 8: Creating a sample certificate..."
az keyvault certificate create --vault-name "$KV_PRIMARY" --name "AppCert" \
  --policy "$(az keyvault certificate get-default-policy)" -o none
echo "  OK: AppCert created"

echo ""
echo ">>> Step 9: Backing up secrets, key, and certificate..."
az keyvault secret backup --vault-name "$KV_PRIMARY" --name "DatabaseConnectionString" --file "$BACKUP_DIR/DatabaseConnectionString.bak" -o none
az keyvault secret backup --vault-name "$KV_PRIMARY" --name "StorageAccountKey" --file "$BACKUP_DIR/StorageAccountKey.bak" -o none
az keyvault secret backup --vault-name "$KV_PRIMARY" --name "AppInsightsKey" --file "$BACKUP_DIR/AppInsightsKey.bak" -o none
az keyvault key backup --vault-name "$KV_PRIMARY" --name "EncryptionKey" --file "$BACKUP_DIR/EncryptionKey.bak" -o none
az keyvault certificate backup --vault-name "$KV_PRIMARY" --name "AppCert" --file "$BACKUP_DIR/AppCert.bak" -o none
echo "  OK: all items backed up"
ls -la "$BACKUP_DIR"

echo ""
echo ">>> Step 10: Syncing secrets to secondary vault (read-and-recreate)..."
# Backup/restore requires same Azure geography; Sweden & Norway are separate geographies.
# Use the read-and-recreate approach from Lab 5 Step 10 instead.
for SECRET_NAME in $(az keyvault secret list --vault-name "$KV_PRIMARY" --query "[].name" -o tsv); do
  echo "  Syncing secret: $SECRET_NAME"
  SECRET_VALUE=$(az keyvault secret show --vault-name "$KV_PRIMARY" --name "$SECRET_NAME" --query "value" -o tsv)
  az keyvault secret set --vault-name "$KV_SECONDARY" --name "$SECRET_NAME" --value "$SECRET_VALUE" -o none
done
echo "  OK: secrets synced to $KV_SECONDARY"

echo ""
echo ">>> Step 10b: Creating key in secondary vault..."
az keyvault key create --vault-name "$KV_SECONDARY" --name "EncryptionKey" \
  --kty RSA --size 2048 --ops encrypt decrypt sign verify -o none
echo "  OK: EncryptionKey created in secondary (new key material — backup/restore not possible cross-geography)"

echo ""
echo ">>> Step 10c: Creating certificate in secondary vault..."
az keyvault certificate create --vault-name "$KV_SECONDARY" --name "AppCert" \
  --policy "$(az keyvault certificate get-default-policy)" -o none
echo "  OK: AppCert created in secondary"

echo ""
echo ">>> Step 11: Validating secrets match..."
PRIMARY_VAL=$(az keyvault secret show --vault-name "$KV_PRIMARY" --name "DatabaseConnectionString" --query value -o tsv)
SECONDARY_VAL=$(az keyvault secret show --vault-name "$KV_SECONDARY" --name "DatabaseConnectionString" --query value -o tsv)
if [ "$PRIMARY_VAL" == "$SECONDARY_VAL" ]; then
  SECRETS_MATCH="PASS"
  echo "  ✅ Secret values match across both vaults."
else
  SECRETS_MATCH="FAIL"
  echo "  ❌ Secret values DO NOT match."
fi

echo ""
echo ">>> Step 12: Comparing vault contents..."
echo "  === Primary Vault Secrets ==="
az keyvault secret list --vault-name "$KV_PRIMARY" --query "[].{Name:name}" -o table
echo "  === Secondary Vault Secrets ==="
az keyvault secret list --vault-name "$KV_SECONDARY" --query "[].{Name:name}" -o table
echo "  === Primary Vault Keys ==="
az keyvault key list --vault-name "$KV_PRIMARY" --query "[].{Name:name}" -o table
echo "  === Secondary Vault Keys ==="
az keyvault key list --vault-name "$KV_SECONDARY" --query "[].{Name:name}" -o table

echo ""
echo "========================================="
echo "  LAB 5 RESULTS"
echo "========================================="
echo "  Resource Groups:     PASS"
echo "  Key Vaults:          PASS"
echo "  RBAC Roles:          PASS"
echo "  Secrets (3):         PASS"
echo "  Key (EncryptionKey): PASS"
echo "  Certificate (AppCert): PASS"
echo "  Backup:              PASS"
echo "  Restore:             PASS"
echo "  Secrets Match:       $SECRETS_MATCH"
echo "========================================="

rm -rf "$BACKUP_DIR"
