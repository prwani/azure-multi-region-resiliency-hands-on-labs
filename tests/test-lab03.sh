#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  LAB 3: Azure SQL Geo-Replication          "
echo "============================================"

PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"
PRIMARY_RG="rg-dr-swc"
SECONDARY_RG="rg-dr-noe"
RANDOM_SUFFIX="l3$(date +%s | tail -c 4)"
PRIMARY_SERVER="sql-dr-swc-${RANDOM_SUFFIX}"
SECONDARY_SERVER="sql-dr-noe-${RANDOM_SUFFIX}"
DB_NAME="sqldb-sample"
FG_NAME="fg-multiregion-${RANDOM_SUFFIX}"

# Get signed-in user info for AAD-only auth (required by policy)
AAD_ADMIN_USER=$(az ad signed-in-user show --query userPrincipalName -o tsv)
AAD_ADMIN_SID=$(az ad signed-in-user show --query id -o tsv)

echo "RANDOM_SUFFIX=$RANDOM_SUFFIX"
echo "PRIMARY_SERVER=$PRIMARY_SERVER"
echo "SECONDARY_SERVER=$SECONDARY_SERVER"
echo "FG_NAME=$FG_NAME"
echo "AAD_ADMIN=$AAD_ADMIN_USER"

cat > /tmp/lab3_vars.env <<EOF
PRIMARY_SERVER=$PRIMARY_SERVER
SECONDARY_SERVER=$SECONDARY_SERVER
AAD_ADMIN_USER=$AAD_ADMIN_USER
DB_NAME=$DB_NAME
FG_NAME=$FG_NAME
EOF

echo ""
echo ">>> Step 1: Creating resource groups..."
az group create --name "$PRIMARY_RG" --location "$PRIMARY_REGION" -o none
echo "  OK: $PRIMARY_RG"
az group create --name "$SECONDARY_RG" --location "$SECONDARY_REGION" -o none
echo "  OK: $SECONDARY_RG"

echo ""
echo ">>> Step 2: Creating primary SQL server (AAD-only auth)..."
az sql server create \
  --name "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --location "$PRIMARY_REGION" \
  --enable-ad-only-auth \
  --external-admin-principal-type User \
  --external-admin-name "$AAD_ADMIN_USER" \
  --external-admin-sid "$AAD_ADMIN_SID" \
  -o none
echo "  OK: $PRIMARY_SERVER"

echo ""
echo ">>> Step 3: Configuring firewall on primary..."
MY_IP=$(curl -s https://ifconfig.me || echo "0.0.0.0")
az sql server firewall-rule create \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --name "AllowMyIP" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP" \
  -o none
az sql server firewall-rule create \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --name "AllowAzureServices" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  -o none
echo "  OK: firewall rules on $PRIMARY_SERVER"

echo ""
echo ">>> Step 4: Creating sample database..."
az sql db create \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --service-objective S0 \
  -o none
echo "  OK: $DB_NAME on $PRIMARY_SERVER"

DB_STATUS=$(az sql db show --name "$DB_NAME" --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" --query "status" -o tsv)
echo "  Database status: $DB_STATUS"

echo ""
echo ">>> Step 5: Creating secondary SQL server (AAD-only auth)..."
az sql server create \
  --name "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --location "$SECONDARY_REGION" \
  --enable-ad-only-auth \
  --external-admin-principal-type User \
  --external-admin-name "$AAD_ADMIN_USER" \
  --external-admin-sid "$AAD_ADMIN_SID" \
  -o none
echo "  OK: $SECONDARY_SERVER"

echo ""
echo ">>> Step 6: Configuring firewall on secondary..."
az sql server firewall-rule create \
  --server "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --name "AllowMyIP" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP" \
  -o none
az sql server firewall-rule create \
  --server "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --name "AllowAzureServices" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  -o none
echo "  OK: firewall rules on $SECONDARY_SERVER"

echo ""
echo ">>> Step 7: Setting up Active Geo-Replication..."
az sql db replica create \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --partner-server "$SECONDARY_SERVER" \
  --partner-resource-group "$SECONDARY_RG" \
  -o none
echo "  OK: geo-replica created"

echo ""
echo ">>> Step 8: Verifying replication link..."
az sql db replica list-links \
  --name "$DB_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --query "[].{Partner:partnerServer, Location:partnerLocation, Role:role, PartnerRole:partnerRole, State:replicationState}" \
  -o table

echo ""
echo ">>> Step 9: Creating Failover Group..."
az sql failover-group create \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --partner-server "$SECONDARY_SERVER" \
  --partner-resource-group "$SECONDARY_RG" \
  --add-db "$DB_NAME" \
  --failover-policy Automatic \
  --grace-period 1 \
  -o none
echo "  OK: failover group $FG_NAME"

echo ""
echo ">>> Step 10: Showing Failover Group status..."
az sql failover-group show \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --query "{Name:name, Role:replicationRole, FailoverPolicy:readWriteEndpoint.failoverPolicy}" \
  -o table

echo ""
echo ">>> Step 11: Testing manual failover..."
az sql failover-group set-primary \
  --name "$FG_NAME" \
  --server "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  -o none
echo "  OK: failover to $SECONDARY_SERVER"

echo ""
echo ">>> Step 12: Verifying roles swapped..."
ROLE=$(az sql failover-group show \
  --name "$FG_NAME" \
  --server "$SECONDARY_SERVER" \
  --resource-group "$SECONDARY_RG" \
  --query "replicationRole" -o tsv)
echo "  Secondary server role: $ROLE"

echo ""
echo ">>> Step 13: Failing back to primary..."
az sql failover-group set-primary \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  -o none
echo "  OK: failback to $PRIMARY_SERVER"

ROLE_BACK=$(az sql failover-group show \
  --name "$FG_NAME" \
  --server "$PRIMARY_SERVER" \
  --resource-group "$PRIMARY_RG" \
  --query "replicationRole" -o tsv)
echo "  Primary server role: $ROLE_BACK"

echo ""
echo "========================================="
echo "  LAB 3 RESULTS"
echo "========================================="
echo "  Resource Groups:     PASS"
echo "  SQL Servers:         PASS"
echo "  Database ($DB_NAME): $DB_STATUS"
echo "  Geo-Replication:     PASS"
echo "  Failover Group:      PASS"
echo "  Manual Failover:     Role=$ROLE"
echo "  Failback:            Role=$ROLE_BACK"
echo "========================================="
