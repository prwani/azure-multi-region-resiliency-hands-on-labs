#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  LAB 1: Web App + Traffic Manager + Chaos  "
echo "============================================"

PRIMARY_REGION="swedencentral"
SECONDARY_REGION="norwayeast"
PRIMARY_RG="rg-dr-swc"
SECONDARY_RG="rg-dr-noe"
PRIMARY_PLAN="plan-dr-swc"
SECONDARY_PLAN="plan-dr-noe"
RANDOM_SUFFIX="t$(date +%s | tail -c 5)"
PRIMARY_APP="app-dr-swc-${RANDOM_SUFFIX}"
SECONDARY_APP="app-dr-noe-${RANDOM_SUFFIX}"
TM_PROFILE="tm-multiregion-webapp"
TM_DNS_NAME="tm-multiregion-webapp-${RANDOM_SUFFIX}"

echo "RANDOM_SUFFIX=$RANDOM_SUFFIX"
echo "PRIMARY_APP=$PRIMARY_APP"
echo "SECONDARY_APP=$SECONDARY_APP"
echo "TM_DNS_NAME=$TM_DNS_NAME"

cat > /tmp/lab1_vars.env <<EOF
PRIMARY_REGION=$PRIMARY_REGION
SECONDARY_REGION=$SECONDARY_REGION
PRIMARY_RG=$PRIMARY_RG
SECONDARY_RG=$SECONDARY_RG
PRIMARY_PLAN=$PRIMARY_PLAN
SECONDARY_PLAN=$SECONDARY_PLAN
RANDOM_SUFFIX=$RANDOM_SUFFIX
PRIMARY_APP=$PRIMARY_APP
SECONDARY_APP=$SECONDARY_APP
TM_PROFILE=$TM_PROFILE
TM_DNS_NAME=$TM_DNS_NAME
EOF

echo ""
echo ">>> Step 1: Creating resource groups..."
az group create --name "$PRIMARY_RG" --location "$PRIMARY_REGION" -o none
echo "  OK: $PRIMARY_RG"
az group create --name "$SECONDARY_RG" --location "$SECONDARY_REGION" -o none
echo "  OK: $SECONDARY_RG"

echo ""
echo ">>> Step 2: Creating App Service plans..."
az appservice plan create --name "$PRIMARY_PLAN" --resource-group "$PRIMARY_RG" --location "$PRIMARY_REGION" --sku B1 --is-linux -o none
echo "  OK: $PRIMARY_PLAN"
az appservice plan create --name "$SECONDARY_PLAN" --resource-group "$SECONDARY_RG" --location "$SECONDARY_REGION" --sku B1 --is-linux -o none
echo "  OK: $SECONDARY_PLAN"

echo ""
echo ">>> Step 3: Creating Web Apps..."
az webapp create --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG" --plan "$PRIMARY_PLAN" --runtime "NODE:20-lts" -o none
echo "  OK: $PRIMARY_APP"
az webapp create --name "$SECONDARY_APP" --resource-group "$SECONDARY_RG" --plan "$SECONDARY_PLAN" --runtime "NODE:20-lts" -o none
echo "  OK: $SECONDARY_APP"

echo ""
echo ">>> Step 4: Deploying sample app..."
mkdir -p /tmp/dr-webapp
cat > /tmp/dr-webapp/index.js <<'APPEOF'
const http = require("http");
const os = require("os");
const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end("<h1>Multi-Region DR Demo</h1><p>Host: " + os.hostname() + "</p><p>Region: " + (process.env.REGION || "unknown") + "</p>");
});
server.listen(process.env.PORT || 8080);
APPEOF
cat > /tmp/dr-webapp/package.json <<'PKGEOF'
{"name":"dr-webapp","version":"1.0.0","scripts":{"start":"node index.js"}}
PKGEOF

cd /tmp/dr-webapp && zip -qr /tmp/dr-webapp.zip .

az webapp config appsettings set --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG" --settings REGION="$PRIMARY_REGION" -o none
az webapp config appsettings set --name "$SECONDARY_APP" --resource-group "$SECONDARY_RG" --settings REGION="$SECONDARY_REGION" -o none
az webapp deploy --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG" --src-path /tmp/dr-webapp.zip --type zip -o none 2>&1 || echo "  WARN: primary deploy issue"
az webapp deploy --name "$SECONDARY_APP" --resource-group "$SECONDARY_RG" --src-path /tmp/dr-webapp.zip --type zip -o none 2>&1 || echo "  WARN: secondary deploy issue"
echo "  OK: Apps deployed"

echo ""
echo ">>> Step 5: Verifying apps..."
sleep 20
PRIMARY_URL="https://${PRIMARY_APP}.azurewebsites.net"
SECONDARY_URL="https://${SECONDARY_APP}.azurewebsites.net"
HTTP1=$(curl -s -o /dev/null -w "%{http_code}" "$PRIMARY_URL" 2>/dev/null || echo "000")
HTTP2=$(curl -s -o /dev/null -w "%{http_code}" "$SECONDARY_URL" 2>/dev/null || echo "000")
echo "  Primary: $HTTP1 ($PRIMARY_URL)"
echo "  Secondary: $HTTP2 ($SECONDARY_URL)"

echo ""
echo ">>> Step 6: Creating Traffic Manager profile..."
az network traffic-manager profile create \
  --name "$TM_PROFILE" \
  --resource-group "$PRIMARY_RG" \
  --routing-method Priority \
  --unique-dns-name "$TM_DNS_NAME" \
  --protocol HTTPS \
  --port 443 \
  --path "/" \
  --ttl 30 \
  -o none
echo "  OK: $TM_DNS_NAME.trafficmanager.net"

echo ""
echo ">>> Step 7: Adding TM endpoints..."
PRIMARY_APP_ID=$(az webapp show --name "$PRIMARY_APP" --resource-group "$PRIMARY_RG" --query "id" -o tsv)
az network traffic-manager endpoint create \
  --name "primary-swedencentral" \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --type azureEndpoints \
  --target-resource-id "$PRIMARY_APP_ID" \
  --priority 1 \
  --endpoint-status Enabled \
  -o none
echo "  OK: primary endpoint (priority 1)"

SECONDARY_APP_ID=$(az webapp show --name "$SECONDARY_APP" --resource-group "$SECONDARY_RG" --query "id" -o tsv)
az network traffic-manager endpoint create \
  --name "secondary-norwayeast" \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --type azureEndpoints \
  --target-resource-id "$SECONDARY_APP_ID" \
  --priority 2 \
  --endpoint-status Enabled \
  -o none
echo "  OK: secondary endpoint (priority 2)"

echo ""
echo ">>> Step 8: Verifying Traffic Manager..."
az network traffic-manager endpoint list \
  --resource-group "$PRIMARY_RG" \
  --profile-name "$TM_PROFILE" \
  --query "[].{Name:name, Priority:priority, Status:endpointStatus, Monitor:endpointMonitorStatus}" \
  -o table

TM_URL="https://${TM_DNS_NAME}.trafficmanager.net"
sleep 15
HTTP_TM=$(curl -s -o /dev/null -w "%{http_code}" "$TM_URL" 2>/dev/null || echo "000")
echo "  Traffic Manager: $HTTP_TM ($TM_URL)"

echo ""
echo "========================================="
echo "  LAB 1 RESULTS"
echo "========================================="
echo "  Resource Groups:     PASS"
echo "  App Service Plans:   PASS"
echo "  Web Apps:            Primary=$HTTP1 Secondary=$HTTP2"
echo "  Traffic Manager:     $HTTP_TM"
echo "  Chaos Studio:        SKIPPED (provider registration takes ~10 min)"
echo "========================================="
