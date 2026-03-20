#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  LAB 11: MySQL Flexible Server Geo-Repl    "
echo "============================================"

RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"
RG_PRIMARY="rg-mysql-dr-swc-${RANDOM_SUFFIX}"
RG_SECONDARY="rg-mysql-dr-noe-${RANDOM_SUFFIX}"
PRIMARY_SERVER="mysql-dr-swc-${RANDOM_SUFFIX}"
REPLICA_SERVER="mysql-dr-noe-${RANDOM_SUFFIX}"
ADMIN_USER="mysqladmin"
ADMIN_PASSWORD="P@ssw0rd-$(openssl rand -hex 4)"
DB_NAME="sampledb"
VARS_FILE="${LAB11_VARS_FILE:-$(mktemp /tmp/lab11_vars.XXXXXX.env)}"

echo "RANDOM_SUFFIX=$RANDOM_SUFFIX"
echo "PRIMARY_SERVER=$PRIMARY_SERVER"
echo "REPLICA_SERVER=$REPLICA_SERVER"
echo "ADMIN_PASSWORD=$ADMIN_PASSWORD"
echo "VARS_FILE=$VARS_FILE"

cat > "$VARS_FILE" <<EOF
RG_PRIMARY=$RG_PRIMARY
RG_SECONDARY=$RG_SECONDARY
PRIMARY_SERVER=$PRIMARY_SERVER
REPLICA_SERVER=$REPLICA_SERVER
ADMIN_USER=$ADMIN_USER
ADMIN_PASSWORD=$ADMIN_PASSWORD
DB_NAME=$DB_NAME
EOF

echo ""
echo ">>> Step 1: Creating resource groups..."
az group create --name "$RG_PRIMARY" --location "$PRIMARY_REGION" -o none
echo "  OK: $RG_PRIMARY"
az group create --name "$RG_SECONDARY" --location "$SECONDARY_REGION" -o none
echo "  OK: $RG_SECONDARY"

echo ""
echo ">>> Step 2: Creating source MySQL Flexible Server..."
az mysql flexible-server create \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --location "$PRIMARY_REGION" \
  --admin-user "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  --sku-name Standard_D2ads_v5 \
  --tier GeneralPurpose \
  --storage-size 32 \
  --version 8.0.21 \
  --public-access 0.0.0.0 \
  -o none
echo "  OK: $PRIMARY_SERVER"

echo ""
echo ">>> Step 3: Verifying source server..."
az mysql flexible-server show \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --query "{Name:name, State:state, Location:location, SKU:sku.name, Version:version}" \
  -o table

echo ""
echo ">>> Step 4: Creating sample database..."
az mysql flexible-server db create \
  --server-name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --database-name "$DB_NAME" \
  -o none
echo "  OK: $DB_NAME"

echo ""
echo ">>> Step 5: Creating cross-region read replica..."
SOURCE_ID=$(az mysql flexible-server show --name "$PRIMARY_SERVER" --resource-group "$RG_PRIMARY" --query id -o tsv)
az mysql flexible-server replica create \
  --replica-name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --source-server "$SOURCE_ID" \
  --location "$SECONDARY_REGION" \
  -o none
echo "  OK: $REPLICA_SERVER"

echo ""
echo ">>> Step 6: Verifying replica..."
REPLICA_ROLE=$(az mysql flexible-server show \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --query "replicationRole" -o tsv 2>/dev/null || echo "unknown")
az mysql flexible-server show \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --query "{Name:name, State:state, Location:location, ReplicationRole:replicationRole}" \
  -o table
echo "  Replica role: $REPLICA_ROLE"

echo ""
echo ">>> Step 7: Listing replicas..."
az mysql flexible-server replica list \
  --name "$PRIMARY_SERVER" \
  --resource-group "$RG_PRIMARY" \
  --query "[].{Name:name, Location:location, State:state, Role:replicationRole}" \
  -o table

echo ""
echo ">>> Step 8: Promoting replica (simulate failover)..."
az mysql flexible-server replica stop-replication \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --yes \
  -o none
echo "  OK: replication stopped"

echo ""
echo ">>> Step 9: Verifying promoted server..."
PROMOTED_ROLE=$(az mysql flexible-server show \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --query "replicationRole" -o tsv 2>/dev/null || echo "unknown")
az mysql flexible-server show \
  --name "$REPLICA_SERVER" \
  --resource-group "$RG_SECONDARY" \
  --query "{Name:name, State:state, Location:location, ReplicationRole:replicationRole}" \
  -o table
echo "  Promoted role: $PROMOTED_ROLE"

echo ""
echo "========================================="
echo "  LAB 11 RESULTS"
echo "========================================="
echo "  Resource Groups:     PASS"
echo "  Source Server:        PASS ($PRIMARY_SERVER)"
echo "  Database:            PASS ($DB_NAME)"
echo "  Cross-Region Replica: $REPLICA_ROLE"
echo "  Promotion (Failover): $PROMOTED_ROLE"
echo "========================================="
