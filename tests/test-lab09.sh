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
EOF

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
echo ">>> Step 6: Creating linked services in primary..."
STORAGE_CONN_PRIMARY=$(az storage account show-connection-string \
  --name "$STORAGE_PRIMARY" --resource-group "$RG_PRIMARY" \
  --query connectionString -o tsv)

az datafactory linked-service create \
  --resource-group "$RG_PRIMARY" --factory-name "$ADF_PRIMARY" \
  --linked-service-name "HttpSource" \
  --properties '{
    "type": "HttpServer",
    "typeProperties": {
      "url": "https://raw.githubusercontent.com/",
      "enableServerCertificateValidation": true,
      "authenticationType": "Anonymous"
    }
  }' -o none
echo "  OK: HttpSource"

az datafactory linked-service create \
  --resource-group "$RG_PRIMARY" --factory-name "$ADF_PRIMARY" \
  --linked-service-name "BlobSink" \
  --properties "{
    \"type\": \"AzureBlobStorage\",
    \"typeProperties\": {
      \"connectionString\": \"$STORAGE_CONN_PRIMARY\"
    }
  }" -o none
echo "  OK: BlobSink"

echo ""
echo ">>> Step 7: Creating datasets in primary..."
az datafactory dataset create \
  --resource-group "$RG_PRIMARY" --factory-name "$ADF_PRIMARY" \
  --dataset-name "HttpCsvDataset" \
  --properties '{
    "type": "DelimitedText",
    "linkedServiceName": { "referenceName": "HttpSource", "type": "LinkedServiceReference" },
    "typeProperties": {
      "location": {
        "type": "HttpServerLocation",
        "relativeUrl": "Azure-Samples/azure-data-factory-runtime-app-service-environment/main/data/sample.csv"
      },
      "columnDelimiter": ",",
      "firstRowAsHeader": true
    },
    "schema": []
  }' -o none
echo "  OK: HttpCsvDataset"

az datafactory dataset create \
  --resource-group "$RG_PRIMARY" --factory-name "$ADF_PRIMARY" \
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
echo "  OK: BlobCsvDataset"

echo ""
echo ">>> Step 8: Creating pipeline in primary..."
az datafactory pipeline create \
  --resource-group "$RG_PRIMARY" --factory-name "$ADF_PRIMARY" \
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
echo "  OK: CopyHttpToBlob pipeline"

echo ""
echo ">>> Step 9: Running pipeline in primary..."
RUN_ID=$(az datafactory pipeline create-run \
  --resource-group "$RG_PRIMARY" --factory-name "$ADF_PRIMARY" \
  --pipeline-name "CopyHttpToBlob" --query runId -o tsv)
echo "  Run ID: $RUN_ID"

echo "  Waiting for pipeline to complete..."
for i in $(seq 1 30); do
  STATUS=$(az datafactory pipeline-run show \
    --resource-group "$RG_PRIMARY" --factory-name "$ADF_PRIMARY" \
    --run-id "$RUN_ID" --query status -o tsv 2>/dev/null || echo "InProgress")
  echo "  Attempt $i: $STATUS"
  if [ "$STATUS" = "Succeeded" ] || [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ]; then
    break
  fi
  sleep 10
done
PRIMARY_STATUS="$STATUS"
echo "  Primary pipeline: $PRIMARY_STATUS"

echo ""
echo ">>> Step 10: Creating secondary Data Factory..."
az datafactory create \
  --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
  --location "$SECONDARY_REGION" -o none
echo "  OK: $ADF_SECONDARY"

echo ""
echo ">>> Step 11: Deploying definitions to secondary..."
STORAGE_CONN_SECONDARY=$(az storage account show-connection-string \
  --name "$STORAGE_SECONDARY" --resource-group "$RG_SECONDARY" \
  --query connectionString -o tsv)

az datafactory linked-service create \
  --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
  --linked-service-name "HttpSource" \
  --properties '{
    "type": "HttpServer",
    "typeProperties": {
      "url": "https://raw.githubusercontent.com/",
      "enableServerCertificateValidation": true,
      "authenticationType": "Anonymous"
    }
  }' -o none

az datafactory linked-service create \
  --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
  --linked-service-name "BlobSink" \
  --properties "{
    \"type\": \"AzureBlobStorage\",
    \"typeProperties\": {
      \"connectionString\": \"$STORAGE_CONN_SECONDARY\"
    }
  }" -o none

az datafactory dataset create \
  --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
  --dataset-name "HttpCsvDataset" \
  --properties '{
    "type": "DelimitedText",
    "linkedServiceName": { "referenceName": "HttpSource", "type": "LinkedServiceReference" },
    "typeProperties": {
      "location": {
        "type": "HttpServerLocation",
        "relativeUrl": "Azure-Samples/azure-data-factory-runtime-app-service-environment/main/data/sample.csv"
      },
      "columnDelimiter": ",", "firstRowAsHeader": true
    },
    "schema": []
  }' -o none

az datafactory dataset create \
  --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
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
      \"columnDelimiter\": \",\", \"firstRowAsHeader\": true
    },
    \"schema\": []
  }" -o none

az datafactory pipeline create \
  --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
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
              "quoteAllText": true, "fileExtension": ".csv"
            }
          }
        },
        "inputs":  [{ "referenceName": "HttpCsvDataset", "type": "DatasetReference" }],
        "outputs": [{ "referenceName": "BlobCsvDataset", "type": "DatasetReference" }]
      }
    ]
  }' -o none
echo "  OK: all definitions deployed to secondary"

echo ""
echo ">>> Step 12: Running pipeline in secondary (DR test)..."
RUN_ID_SEC=$(az datafactory pipeline create-run \
  --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
  --pipeline-name "CopyHttpToBlob" --query runId -o tsv)
echo "  Run ID: $RUN_ID_SEC"

echo "  Waiting for pipeline to complete..."
for i in $(seq 1 30); do
  STATUS_SEC=$(az datafactory pipeline-run show \
    --resource-group "$RG_SECONDARY" --factory-name "$ADF_SECONDARY" \
    --run-id "$RUN_ID_SEC" --query status -o tsv 2>/dev/null || echo "InProgress")
  echo "  Attempt $i: $STATUS_SEC"
  if [ "$STATUS_SEC" = "Succeeded" ] || [ "$STATUS_SEC" = "Failed" ] || [ "$STATUS_SEC" = "Cancelled" ]; then
    break
  fi
  sleep 10
done
SECONDARY_STATUS="$STATUS_SEC"

echo ""
echo "========================================="
echo "  LAB 9 RESULTS"
echo "========================================="
echo "  Resource Groups:       PASS"
echo "  Storage Accounts:      PASS"
echo "  Primary ADF:           PASS"
echo "  Primary Pipeline Run:  $PRIMARY_STATUS"
echo "  Secondary ADF:         PASS"
echo "  Secondary Pipeline Run: $SECONDARY_STATUS"
echo "========================================="
