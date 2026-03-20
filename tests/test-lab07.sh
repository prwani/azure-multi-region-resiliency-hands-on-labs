#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  LAB 7: Event Hubs Geo-Replication         "
echo "============================================"

RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)
EH_PRIMARY="eh-dr-swc-${RANDOM_SUFFIX}"
EH_SECONDARY="eh-dr-noe-${RANDOM_SUFFIX}"
EH_ALIAS="eh-alias-${RANDOM_SUFFIX}"
EH_NAME="events-telemetry"
CG_NAME="analytics-cg"
RG_PRIMARY="rg-eh-primary-${RANDOM_SUFFIX}"
RG_SECONDARY="rg-eh-secondary-${RANDOM_SUFFIX}"
LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

echo "RANDOM_SUFFIX=$RANDOM_SUFFIX"
echo "EH_PRIMARY=$EH_PRIMARY"
echo "EH_SECONDARY=$EH_SECONDARY"

cat > /tmp/lab7_vars.env <<EOF
EH_PRIMARY=$EH_PRIMARY
EH_SECONDARY=$EH_SECONDARY
EH_ALIAS=$EH_ALIAS
RG_PRIMARY=$RG_PRIMARY
RG_SECONDARY=$RG_SECONDARY
EOF

echo ""
echo ">>> Step 1: Creating resource groups..."
az group create --name "$RG_PRIMARY" --location "$LOCATION_PRIMARY" -o none
echo "  OK: $RG_PRIMARY"
az group create --name "$RG_SECONDARY" --location "$LOCATION_SECONDARY" -o none
echo "  OK: $RG_SECONDARY"

echo ""
echo ">>> Step 2: Creating primary Event Hubs namespace..."
az eventhubs namespace create \
  --name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku Standard \
  --capacity 1 \
  -o none
echo "  OK: $EH_PRIMARY"

echo ""
echo ">>> Step 3: Creating secondary Event Hubs namespace..."
az eventhubs namespace create \
  --name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --sku Standard \
  --capacity 1 \
  -o none
echo "  OK: $EH_SECONDARY"

echo ""
echo ">>> Step 4: Creating Event Hub on primary..."
az eventhubs eventhub create \
  --name "$EH_NAME" \
  --namespace-name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --partition-count 2 \
  --cleanup-policy Delete \
  --retention-time 24 \
  -o none
echo "  OK: $EH_NAME"

echo ""
echo ">>> Step 5: Creating consumer group..."
az eventhubs eventhub consumer-group create \
  --name "$CG_NAME" \
  --eventhub-name "$EH_NAME" \
  --namespace-name "$EH_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  -o none
echo "  OK: $CG_NAME"

echo ""
echo ">>> Step 6: Getting secondary namespace resource ID..."
SECONDARY_ID=$(az eventhubs namespace show \
  --name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query id -o tsv)
echo "  OK: $SECONDARY_ID"

echo ""
echo ">>> Step 7: Creating Geo-DR alias..."
az eventhubs georecovery-alias set \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$EH_PRIMARY" \
  --alias "$EH_ALIAS" \
  --partner-namespace "$SECONDARY_ID" \
  -o none
echo "  OK: alias $EH_ALIAS created"

echo ""
echo ">>> Step 8: Waiting for Geo-DR provisioning..."
for i in $(seq 1 30); do
  STATE=$(az eventhubs georecovery-alias show \
    --resource-group "$RG_PRIMARY" \
    --namespace-name "$EH_PRIMARY" \
    --alias "$EH_ALIAS" \
    --query "provisioningState" -o tsv 2>/dev/null || echo "pending")
  echo "  Attempt $i: $STATE"
  if [ "$STATE" == "Succeeded" ]; then
    echo "  Geo-DR alias is ready."
    break
  fi
  sleep 10
done

if [ "$STATE" != "Succeeded" ]; then
  echo "  ERROR: Geo-DR alias provisioning did not succeed (last state: $STATE)" >&2
  exit 1
fi

echo ""
echo ">>> Step 9: Verifying entities replicated to secondary..."
echo "  === Event Hubs on secondary ==="
az eventhubs eventhub list \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query "[].{Name:name, Partitions:partitionCount, Retention:messageRetentionInDays}" \
  -o table
echo "  === Consumer groups on secondary ==="
az eventhubs eventhub consumer-group list \
  --eventhub-name "$EH_NAME" \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query "[].name" -o tsv

echo ""
echo ">>> Step 10: Initiating failover..."
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
FAILOVER_LOG="/tmp/lab7-failover-${RANDOM_SUFFIX}.log"
FAILOVER_REQUESTED=0
for i in $(seq 1 12); do
  if az rest \
    --method post \
    --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_SECONDARY/providers/Microsoft.EventHub/namespaces/$EH_SECONDARY/disasterRecoveryConfigs/$EH_ALIAS/failover?api-version=2023-01-01-preview" \
    -o none >"$FAILOVER_LOG" 2>&1; then
    FAILOVER_REQUESTED=1
    break
  fi

  if grep -q "NamespaceInTransition" "$FAILOVER_LOG"; then
    echo "  Attempt $i: namespace still transitioning, retrying..."
    sleep 15
    continue
  fi

  cat "$FAILOVER_LOG" >&2
  exit 1
done

rm -f "$FAILOVER_LOG"

if [ "$FAILOVER_REQUESTED" -ne 1 ]; then
  echo "  ERROR: failover request never succeeded after retries" >&2
  exit 1
fi

echo "  OK: failover initiated"

echo ""
echo ">>> Step 11: Verifying alias points to secondary..."
FAILOVER_STATE="pending"
ROLE="unknown"
for i in $(seq 1 24); do
  ROLE=$(az eventhubs georecovery-alias show \
    --resource-group "$RG_SECONDARY" \
    --namespace-name "$EH_SECONDARY" \
    --alias "$EH_ALIAS" \
    --query "role" -o tsv 2>/dev/null || echo "unknown")
  FAILOVER_STATE=$(az eventhubs georecovery-alias show \
    --resource-group "$RG_SECONDARY" \
    --namespace-name "$EH_SECONDARY" \
    --alias "$EH_ALIAS" \
    --query "provisioningState" -o tsv 2>/dev/null || echo "pending")
  echo "  Attempt $i: role=$ROLE state=$FAILOVER_STATE"
  if [[ "$ROLE" == Primary* && "$FAILOVER_STATE" == "Succeeded" ]]; then
    break
  fi
  sleep 10
done

if [[ "$ROLE" != Primary* || "$FAILOVER_STATE" != "Succeeded" ]]; then
  echo "  ERROR: failover did not complete successfully (role=$ROLE state=$FAILOVER_STATE)" >&2
  exit 1
fi

echo "  Secondary role after failover: $ROLE"

echo ""
echo ">>> Step 12: Verifying Event Hub on new primary..."
az eventhubs eventhub show \
  --name "$EH_NAME" \
  --namespace-name "$EH_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query "{Name:name, Partitions:partitionCount, Status:status}" \
  -o table

echo ""
echo "========================================="
echo "  LAB 7 RESULTS"
echo "========================================="
echo "  Resource Groups:     PASS"
echo "  EH Namespaces:       PASS"
echo "  Event Hub:           PASS"
echo "  Consumer Group:      PASS"
echo "  Geo-DR Alias:        $STATE"
echo "  Metadata Replicated: see above"
echo "  Failover:            Role=$ROLE State=$FAILOVER_STATE"
echo "========================================="
