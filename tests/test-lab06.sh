#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  LAB 6: Service Bus Geo-DR                 "
echo "============================================"

RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)
SB_PRIMARY="sb-dr-swc-${RANDOM_SUFFIX}"
SB_SECONDARY="sb-dr-noe-${RANDOM_SUFFIX}"
SB_ALIAS="sb-alias-${RANDOM_SUFFIX}"
RG_PRIMARY="rg-servicebus-dr-primary-${RANDOM_SUFFIX}"
RG_SECONDARY="rg-servicebus-dr-secondary-${RANDOM_SUFFIX}"
LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"

echo "RANDOM_SUFFIX=$RANDOM_SUFFIX"
echo "SB_PRIMARY=$SB_PRIMARY"
echo "SB_SECONDARY=$SB_SECONDARY"

cat > /tmp/lab6_vars.env <<EOF
SB_PRIMARY=$SB_PRIMARY
SB_SECONDARY=$SB_SECONDARY
SB_ALIAS=$SB_ALIAS
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
echo ">>> Step 2: Creating primary Service Bus namespace (Premium)..."
az servicebus namespace create \
  --name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --location "$LOCATION_PRIMARY" \
  --sku Premium \
  --capacity 1 \
  -o none
echo "  OK: $SB_PRIMARY"

echo ""
echo ">>> Step 3: Creating secondary Service Bus namespace (Premium)..."
az servicebus namespace create \
  --name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --location "$LOCATION_SECONDARY" \
  --sku Premium \
  --capacity 1 \
  -o none
echo "  OK: $SB_SECONDARY"

echo ""
echo ">>> Step 4: Creating test queue on primary..."
az servicebus queue create \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --name orders-queue \
  --max-size 1024 \
  -o none
echo "  OK: orders-queue"

echo ""
echo ">>> Step 5: Creating test topic and subscription..."
az servicebus topic create \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --name events-topic \
  --max-size 1024 \
  -o none
az servicebus topic subscription create \
  --namespace-name "$SB_PRIMARY" \
  --resource-group "$RG_PRIMARY" \
  --topic-name events-topic \
  --name all-events-sub \
  -o none
echo "  OK: events-topic + all-events-sub"

echo ""
echo ">>> Step 6: Retrieving secondary namespace resource ID..."
SECONDARY_ID=$(az servicebus namespace show \
  --name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query id -o tsv)
echo "  OK: $SECONDARY_ID"

echo ""
echo ">>> Step 7: Creating Geo-DR alias..."
az servicebus georecovery-alias create \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$SB_PRIMARY" \
  --alias "$SB_ALIAS" \
  --partner-namespace "$SECONDARY_ID" \
  -o none
echo "  OK: alias $SB_ALIAS created"

echo ""
echo ">>> Step 8: Waiting for Geo-DR provisioning..."
for i in $(seq 1 30); do
  STATE=$(az servicebus georecovery-alias show \
    --resource-group "$RG_PRIMARY" \
    --namespace-name "$SB_PRIMARY" \
    --alias "$SB_ALIAS" \
    --query "provisioningState" -o tsv 2>/dev/null || echo "pending")
  echo "  Attempt $i: $STATE"
  if [ "$STATE" == "Succeeded" ]; then
    echo "  Geo-DR pairing is ready."
    break
  fi
  sleep 10
done

if [ "$STATE" != "Succeeded" ]; then
  echo "  ERROR: Geo-DR alias provisioning did not succeed (last state: $STATE)" >&2
  exit 1
fi

echo ""
echo ">>> Step 9: Verifying metadata replicated to secondary..."
echo "  === Queues on secondary ==="
az servicebus queue list \
  --namespace-name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query "[].name" -o tsv
echo "  === Topics on secondary ==="
az servicebus topic list \
  --namespace-name "$SB_SECONDARY" \
  --resource-group "$RG_SECONDARY" \
  --query "[].name" -o tsv

echo ""
echo ">>> Step 10: Showing alias configuration..."
az servicebus georecovery-alias show \
  --resource-group "$RG_PRIMARY" \
  --namespace-name "$SB_PRIMARY" \
  --alias "$SB_ALIAS" \
  --query "{Alias:name, Role:role, State:provisioningState, PendingOps:pendingReplicationOperationsCount}" \
  -o table

echo ""
echo ">>> Step 11: Initiating failover..."
az servicebus georecovery-alias fail-over \
  --resource-group "$RG_SECONDARY" \
  --namespace-name "$SB_SECONDARY" \
  --alias "$SB_ALIAS" \
  --is-safe-failover false \
  -o none
echo "  OK: failover initiated"

echo ""
echo ">>> Step 12: Verifying alias points to secondary..."
FAILOVER_STATE="pending"
ROLE="unknown"
for i in $(seq 1 24); do
  ROLE=$(az servicebus georecovery-alias show \
    --resource-group "$RG_SECONDARY" \
    --namespace-name "$SB_SECONDARY" \
    --alias "$SB_ALIAS" \
    --query "role" -o tsv 2>/dev/null || echo "unknown")
  FAILOVER_STATE=$(az servicebus georecovery-alias show \
    --resource-group "$RG_SECONDARY" \
    --namespace-name "$SB_SECONDARY" \
    --alias "$SB_ALIAS" \
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
echo "========================================="
echo "  LAB 6 RESULTS"
echo "========================================="
echo "  Resource Groups:     PASS"
echo "  SB Namespaces:       PASS (Premium)"
echo "  Queue + Topic:       PASS"
echo "  Geo-DR Alias:        $STATE"
echo "  Metadata Replicated: see above"
echo "  Failover:            Role=$ROLE State=$FAILOVER_STATE"
echo "========================================="
