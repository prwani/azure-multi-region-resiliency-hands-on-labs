#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  LAB 4: Cosmos DB Global Distribution      "
echo "============================================"

RANDOM_SUFFIX="l4$(date +%s | tail -c 4)"
RG="rg-cosmos-global-${RANDOM_SUFFIX}"
LOCATION_PRIMARY="swedencentral"
LOCATION_SECONDARY="norwayeast"
COSMOS_ACCOUNT="cosmos-multiregion-${RANDOM_SUFFIX}"
DATABASE_NAME="db-sample"
CONTAINER_NAME="container-orders"
PARTITION_KEY="/customerId"
COSMOS_API_VERSION="2018-12-31"
COSMOS_DOCS_RESOURCE_LINK="dbs/${DATABASE_NAME}/colls/${CONTAINER_NAME}"
COSMOS_DOCS_PATH="dbs/${DATABASE_NAME}/colls/${CONTAINER_NAME}/docs"

echo "RANDOM_SUFFIX=$RANDOM_SUFFIX"
echo "COSMOS_ACCOUNT=$COSMOS_ACCOUNT"

cat > /tmp/lab4_vars.env <<EOF
RG=$RG
COSMOS_ACCOUNT=$COSMOS_ACCOUNT
DATABASE_NAME=$DATABASE_NAME
CONTAINER_NAME=$CONTAINER_NAME
EOF

cosmos_auth_token() {
  local access_token="$1"

  python3 - "$access_token" <<'PY'
import sys
import urllib.parse

print(urllib.parse.quote(f"type=aad&ver=1.0&sig={sys.argv[1]}", safe=""))
PY
}

cosmos_request() {
  local method="$1"
  local resource_type="$2"
  local resource_link="$3"
  local resource_path="$4"
  local content_type="$5"
  local body="$6"
  shift 6

  local request_date
  request_date="$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S GMT')"

  local access_token
  access_token="$(az account get-access-token --resource https://cosmos.azure.com/ --query accessToken -o tsv)"

  local auth_token
  auth_token="$(cosmos_auth_token "$access_token")"

  local curl_args=(
    --silent
    --show-error
    --fail
    --request "$method"
    --url "${COSMOS_ENDPOINT}${resource_path}"
    --header "authorization: $auth_token"
    --header "x-ms-date: $request_date"
    --header "x-ms-version: ${COSMOS_API_VERSION}"
    --header "Content-Type: $content_type"
  )

  while (($#)); do
    curl_args+=(--header "$1")
    shift
  done

  curl_args+=(--data "$body")
  curl "${curl_args[@]}"
}

print_query_results() {
  local response="$1"
  python3 - "$response" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])
docs = sorted(data.get("Documents", []), key=lambda doc: doc.get("id", ""))
if docs and "customerId" in docs[0]:
    print(f"{'Id':<12} {'CustomerId':<14} {'Product':<36} Status")
    print(f"{'-' * 12} {'-' * 14} {'-' * 36} {'-' * 10}")
    for doc in docs:
        print(f"{doc['id']:<12} {doc['customerId']:<14} {doc['product']:<36} {doc['status']}")
else:
    print(f"{'Id':<12} {'Product':<36} Status")
    print(f"{'-' * 12} {'-' * 36} {'-' * 10}")
    for doc in docs:
        print(f"{doc['id']:<12} {doc['product']:<36} {doc['status']}")
print(f"\nCount: {data.get('_count', len(docs))}")
PY
}

query_count() {
  local response="$1"
  python3 - "$response" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])
docs = data.get("Documents", [])
print(data.get("_count", len(docs)))
PY
}

wait_for_write_region() {
  local expected_region="$1"
  local retries="${2:-60}"
  local delay_seconds="${3:-10}"

  for i in $(seq 1 "$retries"); do
    local actual_region
    actual_region=$(az cosmosdb show \
      --name "$COSMOS_ACCOUNT" \
      --resource-group "$RG" \
      --query "writeLocations[0].locationName" \
      -o tsv)
    echo "  Write region [$i/$retries]: $actual_region"
    if [ "$actual_region" = "$expected_region" ]; then
      return 0
    fi
    sleep "$delay_seconds"
  done

  echo "  ERROR: write region did not switch to $expected_region"
  return 1
}

wait_for_data_plane_access() {
  local retries="${1:-30}"
  local delay_seconds="${2:-10}"
  local query_body='{"query":"SELECT VALUE 1","parameters":[]}'

  for i in $(seq 1 "$retries"); do
    if cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/query+json" \
      "$query_body" \
      'x-ms-documentdb-isquery: True' \
      'x-ms-documentdb-query-enablecrosspartition: True' \
      'x-ms-max-item-count: 1' >/dev/null 2>&1; then
      echo "  Data-plane access [$i/$retries]: ready"
      return 0
    fi

    echo "  Data-plane access [$i/$retries]: waiting"
    sleep "$delay_seconds"
  done

  echo "  ERROR: data-plane access did not become ready"
  return 1
}

echo ""
echo ">>> Step 1: Creating resource group..."
az group create --name "$RG" --location "$LOCATION_PRIMARY" -o none
echo "  OK: $RG"

echo ""
echo ">>> Step 2: Creating Cosmos DB account (single region)..."
az cosmosdb create \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --locations regionName=$LOCATION_PRIMARY failoverPriority=0 isZoneRedundant=false \
  --default-consistency-level Session \
  -o none
echo "  OK: $COSMOS_ACCOUNT"

echo ""
echo ">>> Step 3: Verifying account..."
az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "{Name:name, Status:provisioningState, Consistency:consistencyPolicy.defaultConsistencyLevel, Locations:readLocations[].locationName}" \
  -o table

echo ""
echo ">>> Step 4: Adding Norway East as secondary region..."
az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --locations regionName=$LOCATION_PRIMARY failoverPriority=0 isZoneRedundant=false \
  --locations regionName=$LOCATION_SECONDARY failoverPriority=1 isZoneRedundant=false \
  -o none
echo "  OK: added $LOCATION_SECONDARY"

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "readLocations[].{Region:locationName, Priority:failoverPriority}" \
  -o table

echo ""
echo ">>> Step 5: Enabling multi-region writes..."
az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --enable-multiple-write-locations true \
  -o none
MULTI_WRITE=$(az cosmosdb show --name "$COSMOS_ACCOUNT" --resource-group "$RG" \
  --query "enableMultipleWriteLocations" -o tsv)
echo "  Multi-region writes: $MULTI_WRITE"

echo ""
echo ">>> Step 6: Creating database..."
az cosmosdb sql database create \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --name "$DATABASE_NAME" \
  -o none
echo "  OK: $DATABASE_NAME"

echo ""
echo ">>> Step 7: Creating container..."
az cosmosdb sql container create \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --database-name "$DATABASE_NAME" \
  --name "$CONTAINER_NAME" \
  --partition-key-path "$PARTITION_KEY" \
  --throughput 400 \
  -o none
echo "  OK: $CONTAINER_NAME"

echo ""
echo ">>> Step 8: Inserting sample documents..."
AAD_PRINCIPAL_ID=$(az rest \
  --resource https://graph.microsoft.com \
  --url https://graph.microsoft.com/v1.0/me \
  --query id \
  -o tsv 2>/dev/null || true)

if [ -z "$AAD_PRINCIPAL_ID" ]; then
  AAD_PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
fi

DATA_CONTRIBUTOR_ROLE_ID=$(az cosmosdb sql role definition list \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "[?roleName=='Cosmos DB Built-in Data Contributor'].id | [0]" \
  -o tsv)

az cosmosdb sql role assignment create \
  --account-name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --scope "/" \
  --principal-id "$AAD_PRINCIPAL_ID" \
  --role-definition-id "$DATA_CONTRIBUTOR_ROLE_ID" \
  -o none
echo "  OK: assigned Cosmos DB Built-in Data Contributor"

COSMOS_ENDPOINT=$(az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "documentEndpoint" \
  -o tsv)
wait_for_data_plane_access

cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/json" \
  '{"id":"order-001","customerId":"customer-100","product":"Azure Reserved VM Instance","quantity":3,"region":"swedencentral","status":"confirmed","createdAt":"2024-06-15T10:30:00Z"}' \
  'x-ms-documentdb-is-upsert: True' \
  'x-ms-documentdb-partitionkey: ["customer-100"]' >/dev/null
echo "  OK: inserted order-001"

cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/json" \
  '{"id":"order-002","customerId":"customer-200","product":"Azure Cosmos DB Reserved Capacity","quantity":1,"region":"norwayeast","status":"pending","createdAt":"2024-06-15T11:00:00Z"}' \
  'x-ms-documentdb-is-upsert: True' \
  'x-ms-documentdb-partitionkey: ["customer-200"]' >/dev/null
echo "  OK: inserted order-002"

cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/json" \
  '{"id":"order-003","customerId":"customer-100","product":"Azure Front Door Premium","quantity":1,"region":"swedencentral","status":"shipped","createdAt":"2024-06-15T14:45:00Z"}' \
  'x-ms-documentdb-is-upsert: True' \
  'x-ms-documentdb-partitionkey: ["customer-100"]' >/dev/null
echo "  OK: inserted order-003"

echo ""
echo ">>> Step 9: Querying data..."
QUERY_RESPONSE=$(cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/query+json" \
  '{"query":"SELECT c.id, c.customerId, c.product, c.status FROM c","parameters":[]}' \
  'x-ms-documentdb-isquery: True' \
  'x-ms-documentdb-query-enablecrosspartition: True' \
  'x-ms-max-item-count: -1')
print_query_results "$QUERY_RESPONSE"
DOC_COUNT=$(query_count "$QUERY_RESPONSE")
[ "$DOC_COUNT" -eq 3 ]

PARTITION_QUERY=$(cosmos_request "POST" "docs" "$COSMOS_DOCS_RESOURCE_LINK" "$COSMOS_DOCS_PATH" "application/query+json" \
  '{"query":"SELECT c.id, c.product, c.status FROM c WHERE c.customerId = @customerId","parameters":[{"name":"@customerId","value":"customer-100"}]}' \
  'x-ms-documentdb-isquery: True' \
  'x-ms-documentdb-partitionkey: ["customer-100"]')
print_query_results "$PARTITION_QUERY"
CUSTOMER_COUNT=$(query_count "$PARTITION_QUERY")
[ "$CUSTOMER_COUNT" -eq 2 ]

echo ""
echo ">>> Step 10: Enabling automatic failover..."
az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --enable-automatic-failover true \
  -o none
AUTO_FO=$(az cosmosdb show --name "$COSMOS_ACCOUNT" --resource-group "$RG" \
  --query "enableAutomaticFailover" -o tsv)
echo "  Automatic failover: $AUTO_FO"

echo ""
echo ">>> Step 11: Testing manual failover..."
# Disable multi-region writes first (required for manual failover)
az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --enable-multiple-write-locations false \
  -o none
echo "  Disabled multi-region writes for failover test"

az cosmosdb failover-priority-change \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --failover-policies "$LOCATION_SECONDARY=0" "$LOCATION_PRIMARY=1" \
  -o none
wait_for_write_region "Norway East"
echo "  OK: failover completed"

echo ""
echo ">>> Step 12: Verifying failover..."
az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "readLocations[].{Region:locationName, Priority:failoverPriority}" \
  -o table

echo ""
echo ">>> Step 13: Failing back..."
az cosmosdb failover-priority-change \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --failover-policies "$LOCATION_PRIMARY=0" "$LOCATION_SECONDARY=1" \
  -o none
wait_for_write_region "Sweden Central"
echo "  OK: failback completed"

az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RG" \
  --query "readLocations[].{Region:locationName, Priority:failoverPriority}" \
  -o table

echo ""
echo "========================================="
echo "  LAB 4 RESULTS"
echo "========================================="
echo "  Resource Group:      PASS"
echo "  Cosmos Account:      PASS"
echo "  Multi-Region:        PASS"
echo "  Multi-Region Writes: $MULTI_WRITE"
echo "  Database/Container:  PASS"
echo "  Documents Inserted:  $DOC_COUNT"
echo "  Automatic Failover:  $AUTO_FO"
echo "  Manual Failover:     PASS (see above)"
echo "========================================="
