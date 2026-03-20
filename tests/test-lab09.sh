#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  LAB 9: Data Factory Active/Passive DR     "
echo "============================================"

UNIQUE_SUFFIX="l9$(date +%s | tail -c 4)"
PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"
RG_PRIMARY="rg-adf-dr-swc"
RG_SECONDARY="rg-adf-dr-noe"
ADF_PRIMARY="adf-dr-swc-${UNIQUE_SUFFIX}"
ADF_SECONDARY="adf-dr-noe-${UNIQUE_SUFFIX}"
STORAGE_PRIMARY="stgadfdrswc${UNIQUE_SUFFIX}"
STORAGE_SECONDARY="stgadfdrnoe${UNIQUE_SUFFIX}"
CONTAINER_NAME="adf-landing"
HTTP_BASE_URL="https://raw.githubusercontent.com/"
HTTP_RELATIVE_URL="mwaskom/seaborn-data/master/iris.csv"
RBAC_WAIT_SECONDS=60

echo "UNIQUE_SUFFIX=$UNIQUE_SUFFIX"
echo "ADF_PRIMARY=$ADF_PRIMARY"
echo "ADF_SECONDARY=$ADF_SECONDARY"
echo "STORAGE_PRIMARY=$STORAGE_PRIMARY"
echo "STORAGE_SECONDARY=$STORAGE_SECONDARY"

cat > /tmp/lab9_vars.env <<EOF
ADF_PRIMARY=$ADF_PRIMARY
ADF_SECONDARY=$ADF_SECONDARY
STORAGE_PRIMARY=$STORAGE_PRIMARY
STORAGE_SECONDARY=$STORAGE_SECONDARY
RG_PRIMARY=$RG_PRIMARY
RG_SECONDARY=$RG_SECONDARY
PRIMARY_REGION=$PRIMARY_REGION
SECONDARY_REGION=$SECONDARY_REGION
HTTP_RELATIVE_URL=$HTTP_RELATIVE_URL
EOF

LAST_STATUS=""
LAST_RUN_ID=""

show_pipeline_failure() {
  local rg="$1"
  local factory="$2"
  local run_id="$3"

  echo "  ERROR: Pipeline run $run_id in $factory did not succeed." >&2
  az datafactory pipeline-run show \
    --resource-group "$rg" --factory-name "$factory" \
    --run-id "$run_id" \
    --query "{Status:status, Message:message}" \
    -o jsonc >&2 || true
  az datafactory activity-run query-by-pipeline-run \
    --resource-group "$rg" --factory-name "$factory" \
    --run-id "$run_id" \
    --last-updated-after 2020-01-01T00:00:00Z \
    --last-updated-before 2035-01-01T00:00:00Z \
    --query "value[].{Activity:activityName,Status:status,Error:error.message}" \
    -o table >&2 || true
}

enable_factory_identity() {
  local rg="$1"
  local factory="$2"
  local region="$3"
  local storage="$4"
  local sub_id body principal_id storage_id role_count

  sub_id=$(az account show --query id -o tsv)
  printf -v body '{"name":"%s","location":"%s","identity":{"type":"SystemAssigned"},"properties":{}}' "$factory" "$region"

  az rest --method patch \
    --url "https://management.azure.com/subscriptions/${sub_id}/resourceGroups/${rg}/providers/Microsoft.DataFactory/factories/${factory}?api-version=2018-06-01" \
    --body "$body" \
    -o none

  principal_id=$(az datafactory show \
    --resource-group "$rg" --factory-name "$factory" \
    --query identity.principalId -o tsv)
  storage_id=$(az storage account show \
    --name "$storage" --resource-group "$rg" \
    --query id -o tsv)

  role_count=$(az role assignment list \
    --assignee-object-id "$principal_id" \
    --role "Storage Blob Data Contributor" \
    --scope "$storage_id" \
    --query "length(@)" -o tsv)

  if [[ "$role_count" == "0" ]]; then
    az role assignment create \
      --assignee-object-id "$principal_id" \
      --assignee-principal-type ServicePrincipal \
      --role "Storage Blob Data Contributor" \
      --scope "$storage_id" \
      -o none
  fi

  echo "  OK: system-assigned identity enabled for $factory"
  echo "  Waiting ${RBAC_WAIT_SECONDS}s for RBAC propagation..."
  sleep "$RBAC_WAIT_SECONDS"
}

configure_factory() {
  local rg="$1"
  local factory="$2"
  local storage="$3"

  az datafactory linked-service create \
    --resource-group "$rg" --factory-name "$factory" \
    --linked-service-name "HttpSource" \
    --properties "{
      \"type\": \"HttpServer\",
      \"typeProperties\": {
        \"url\": \"$HTTP_BASE_URL\",
        \"enableServerCertificateValidation\": true,
        \"authenticationType\": \"Anonymous\"
      }
    }" -o none

  az datafactory linked-service create \
    --resource-group "$rg" --factory-name "$factory" \
    --linked-service-name "BlobSink" \
    --properties "{
      \"type\": \"AzureBlobStorage\",
      \"typeProperties\": {
        \"serviceEndpoint\": \"https://${storage}.blob.core.windows.net/\",
        \"accountKind\": \"StorageV2\"
      }
    }" -o none

  az datafactory dataset create \
    --resource-group "$rg" --factory-name "$factory" \
    --dataset-name "HttpCsvDataset" \
    --properties "{
      \"type\": \"DelimitedText\",
      \"linkedServiceName\": { \"referenceName\": \"HttpSource\", \"type\": \"LinkedServiceReference\" },
      \"typeProperties\": {
        \"location\": {
          \"type\": \"HttpServerLocation\",
          \"relativeUrl\": \"$HTTP_RELATIVE_URL\"
        },
        \"columnDelimiter\": \",\",
        \"firstRowAsHeader\": true
      },
      \"schema\": []
    }" -o none

  az datafactory dataset create \
    --resource-group "$rg" --factory-name "$factory" \
    --dataset-name "BlobCsvDataset" \
    --properties "{
      \"type\": \"DelimitedText\",
      \"linkedServiceName\": { \"referenceName\": \"BlobSink\", \"type\": \"LinkedServiceReference\" },
      \"typeProperties\": {
        \"location\": {
          \"type\": \"AzureBlobStorageLocation\",
          \"container\": \"$CONTAINER_NAME\",
          \"fileName\": \"output.csv\"
        },
        \"columnDelimiter\": \",\",
        \"firstRowAsHeader\": true
      },
      \"schema\": []
    }" -o none

  az datafactory pipeline create \
    --resource-group "$rg" --factory-name "$factory" \
    --pipeline-name "CopyHttpToBlob" \
    --pipeline '{
      "activities": [
        {
          "name": "CopyFromHttpToBlob",
          "type": "Copy",
          "typeProperties": {
            "source": {
              "type": "DelimitedTextSource",
              "storeSettings": { "type": "HttpReadSettings", "requestMethod": "GET" },
              "formatSettings": { "type": "DelimitedTextReadSettings" }
            },
            "sink": {
              "type": "DelimitedTextSink",
              "storeSettings": { "type": "AzureBlobStorageWriteSettings" },
              "formatSettings": {
                "type": "DelimitedTextWriteSettings",
                "quoteAllText": true,
                "fileExtension": ".csv"
              }
            }
          },
          "inputs":  [{ "referenceName": "HttpCsvDataset", "type": "DatasetReference" }],
          "outputs": [{ "referenceName": "BlobCsvDataset", "type": "DatasetReference" }]
        }
      ]
    }' -o none
}

run_pipeline() {
  local rg="$1"
  local factory="$2"
  local label="$3"
  local status

  LAST_RUN_ID=$(az datafactory pipeline create-run \
    --resource-group "$rg" --factory-name "$factory" \
    --pipeline-name "CopyHttpToBlob" --query runId -o tsv)
  echo "  Run ID: $LAST_RUN_ID"

  echo "  Waiting for pipeline to complete..."
  for i in $(seq 1 30); do
    status=$(az datafactory pipeline-run show \
      --resource-group "$rg" --factory-name "$factory" \
      --run-id "$LAST_RUN_ID" --query status -o tsv 2>/dev/null || echo "InProgress")
    echo "  Attempt $i: $status"
    if [[ "$status" == "Succeeded" || "$status" == "Failed" || "$status" == "Cancelled" ]]; then
      break
    fi
    sleep 10
  done

  LAST_STATUS="$status"
  echo "  $label pipeline: $LAST_STATUS"

  if [[ "$LAST_STATUS" != "Succeeded" ]]; then
    show_pipeline_failure "$rg" "$factory" "$LAST_RUN_ID"
    return 1
  fi
}

echo ""
echo ">>> Step 1: Installing datafactory extension..."
az extension add --name datafactory --upgrade --yes 2>/dev/null
echo "  OK: $(az extension show --name datafactory --query version -o tsv)"

echo ""
echo ">>> Step 2: Creating resource groups..."
az group create --name "$RG_PRIMARY" --location "$PRIMARY_REGION" -o none
echo "  OK: $RG_PRIMARY"
az group create --name "$RG_SECONDARY" --location "$SECONDARY_REGION" -o none
echo "  OK: $RG_SECONDARY"

echo ""
echo ">>> Step 3: Creating storage accounts..."
az storage account create --name "$STORAGE_PRIMARY" --resource-group "$RG_PRIMARY" \
  --location "$PRIMARY_REGION" --sku Standard_LRS --kind StorageV2 -o none
echo "  OK: $STORAGE_PRIMARY"
az storage account create --name "$STORAGE_SECONDARY" --resource-group "$RG_SECONDARY" \
  --location "$SECONDARY_REGION" --sku Standard_LRS --kind StorageV2 -o none
echo "  OK: $STORAGE_SECONDARY"

echo ""
echo ">>> Step 4: Creating landing containers..."
az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_PRIMARY" --auth-mode login -o none
az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_SECONDARY" --auth-mode login -o none
echo "  OK: $CONTAINER_NAME in both accounts"

echo ""
echo ">>> Step 5: Creating primary Data Factory..."
az datafactory create \
  --resource-group "$RG_PRIMARY" \
  --factory-name "$ADF_PRIMARY" \
  --location "$PRIMARY_REGION" \
  -o none
echo "  OK: $ADF_PRIMARY"

echo ""
echo ">>> Step 6: Enabling managed identity for primary..."
enable_factory_identity "$RG_PRIMARY" "$ADF_PRIMARY" "$PRIMARY_REGION" "$STORAGE_PRIMARY"

echo ""
echo ">>> Step 7: Deploying definitions to primary..."
configure_factory "$RG_PRIMARY" "$ADF_PRIMARY" "$STORAGE_PRIMARY"
echo "  OK: primary linked services, datasets, and pipeline"

echo ""
echo ">>> Step 8: Running pipeline in primary..."
run_pipeline "$RG_PRIMARY" "$ADF_PRIMARY" "Primary"
PRIMARY_STATUS="$LAST_STATUS"

echo ""
echo ">>> Step 9: Creating secondary Data Factory..."
az datafactory create \
  --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
  --location "$SECONDARY_REGION" -o none
echo "  OK: $ADF_SECONDARY"

echo ""
echo ">>> Step 10: Enabling managed identity for secondary..."
enable_factory_identity "$RG_SECONDARY" "$ADF_SECONDARY" "$SECONDARY_REGION" "$STORAGE_SECONDARY"

echo ""
echo ">>> Step 11: Deploying definitions to secondary..."
configure_factory "$RG_SECONDARY" "$ADF_SECONDARY" "$STORAGE_SECONDARY"
echo "  OK: all definitions deployed to secondary"

echo ""
echo ">>> Step 12: Running pipeline in secondary (DR test)..."
run_pipeline "$RG_SECONDARY" "$ADF_SECONDARY" "Secondary"
SECONDARY_STATUS="$LAST_STATUS"

echo ""
echo "========================================="
echo "  LAB 9 RESULTS"
echo "========================================="
echo "  Resource Groups:        PASS"
echo "  Storage Accounts:       PASS"
echo "  Primary ADF:            PASS"
echo "  Primary Pipeline Run:   $PRIMARY_STATUS"
echo "  Secondary ADF:          PASS"
echo "  Secondary Pipeline Run: $SECONDARY_STATUS"
echo "========================================="
