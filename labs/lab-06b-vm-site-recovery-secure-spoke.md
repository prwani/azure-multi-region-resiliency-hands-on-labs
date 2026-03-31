---
layout: default
title: "Lab 6-b: Azure Virtual Machines – Cross-Region DR with Site Recovery (Secure Spoke & Bastion)"
---

**Variant navigation:** [Lab 6-a — Standalone Site Recovery](lab-06a-vm-site-recovery.md) | **Lab 6-b — Secure spoke & Bastion**

# Lab 6-b: Azure Virtual Machines – Cross-Region DR with Site Recovery (Secure Spoke & Bastion)

<script>
document.documentElement.classList.add("lab-tabs-js");

document.addEventListener("DOMContentLoaded", () => {
  const storageKey = "azure-labs-preferred-tab";
  const validTabs = ["bash", "powershell", "portal"];
  const tabGroups = Array.from(document.querySelectorAll(".lab-tabs"));
  const copyIcon = `
    <svg viewBox="0 0 16 16" aria-hidden="true" focusable="false">
      <path d="M5.75 1A1.75 1.75 0 0 0 4 2.75v6.5C4 10.216 4.784 11 5.75 11h5.5A1.75 1.75 0 0 0 13 9.25v-6.5A1.75 1.75 0 0 0 11.25 1h-5.5Zm-.25 1.75c0-.138.112-.25.25-.25h5.5c.138 0 .25.112.25.25v6.5a.25.25 0 0 1-.25.25h-5.5a.25.25 0 0 1-.25-.25v-6.5Z"></path>
      <path d="M2.75 5A1.75 1.75 0 0 0 1 6.75v6.5C1 14.216 1.784 15 2.75 15h5.5A1.75 1.75 0 0 0 10 13.25V12H8.5v1.25a.25.25 0 0 1-.25.25h-5.5a.25.25 0 0 1-.25-.25v-6.5c0-.138.112-.25.25-.25H4V5H2.75Z"></path>
    </svg>
  `;
  const copiedIcon = `
    <svg viewBox="0 0 16 16" aria-hidden="true" focusable="false">
      <path d="M13.78 4.22a.75.75 0 0 1 0 1.06l-7.25 7.25a.75.75 0 0 1-1.06 0L2.22 9.28a.75.75 0 1 1 1.06-1.06L6 10.94l6.72-6.72a.75.75 0 0 1 1.06 0Z"></path>
    </svg>
  `;

  function setActiveTab(tabName) {
    const selectedTab = validTabs.includes(tabName) ? tabName : "bash";

    tabGroups.forEach((group) => {
      const buttons = group.querySelectorAll(".lab-tabs__button");
      const panels = group.querySelectorAll(".lab-tabs__panel");

      buttons.forEach((button) => {
        const isActive = button.dataset.tab === selectedTab;
        button.classList.toggle("is-active", isActive);
        button.setAttribute("aria-selected", String(isActive));
        button.tabIndex = isActive ? 0 : -1;
      });

      panels.forEach((panel) => {
        const isActive = panel.dataset.tabPanel === selectedTab;
        panel.classList.toggle("is-active", isActive);
        panel.hidden = !isActive;
      });
    });

    try {
      localStorage.setItem(storageKey, selectedTab);
    } catch (error) {
      console.warn("Could not persist tab preference", error);
    }
  }

  tabGroups.forEach((group) => {
    group.querySelectorAll(".lab-tabs__button").forEach((button) => {
      button.type = "button";
      button.setAttribute("role", "tab");
      button.addEventListener("click", () => setActiveTab(button.dataset.tab));
    });

    group.querySelectorAll(".lab-tabs__panel").forEach((panel) => {
      panel.setAttribute("role", "tabpanel");
    });
  });

  let preferredTab = "bash";
  try {
    const storedTab = localStorage.getItem(storageKey);
    if (validTabs.includes(storedTab)) {
      preferredTab = storedTab;
    }
  } catch (error) {
    console.warn("Could not read saved tab preference", error);
  }
  setActiveTab(preferredTab);

  const copyTargets = Array.from(
    document.querySelectorAll("div.highlighter-rouge, pre:not(.highlight)")
  );

  copyTargets.forEach((target) => {
    if (target.dataset.copyReady === "true") {
      return;
    }

    const codeElement = target.querySelector("code");
    if (!codeElement || !codeElement.innerText.trim()) {
      return;
    }

    target.dataset.copyReady = "true";
    target.classList.add("lab-copyable");

    const button = document.createElement("button");
    button.type = "button";
    button.className = "lab-copy-button";
    button.setAttribute("aria-label", "Copy code");
    button.innerHTML = copyIcon;

    button.addEventListener("click", async () => {
      const text = codeElement.innerText.replace(/\s+$/, "");

      try {
        await navigator.clipboard.writeText(text);
        button.classList.add("is-copied");
        button.innerHTML = copiedIcon;
        button.setAttribute("aria-label", "Copied");
        window.setTimeout(() => {
          button.classList.remove("is-copied");
          button.innerHTML = copyIcon;
          button.setAttribute("aria-label", "Copy code");
        }, 1500);
      } catch (error) {
        const range = document.createRange();
        const selection = window.getSelection();
        range.selectNodeContents(codeElement);
        selection.removeAllRanges();
        selection.addRange(range);
      }
    });

    target.appendChild(button);
  });
});
</script>

<style>
.lab-tabs {
  margin: 1rem 0 1.5rem;
  border: 1px solid #d0d7de;
  border-radius: 12px;
  overflow: hidden;
  background: #ffffff;
  box-shadow: 0 1px 2px rgba(16, 24, 40, 0.06);
}

.lab-tabs__list {
  display: flex;
  gap: 0.5rem;
  padding: 0.6rem;
  border-bottom: 1px solid #d0d7de;
  background: #f6f8fa;
  overflow-x: auto;
}

.lab-tabs__button {
  padding: 0.55rem 0.95rem;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: #57606a;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  white-space: nowrap;
  transition: background-color 0.15s ease, color 0.15s ease;
}

.lab-tabs__button:hover {
  background: rgba(9, 105, 218, 0.08);
  color: #0969da;
}

.lab-tabs__button.is-active {
  background: #ffffff;
  color: #0969da;
  box-shadow: inset 0 0 0 1px rgba(9, 105, 218, 0.16);
}

.lab-tabs__panel {
  padding: 1rem 1rem 0.25rem;
}

.lab-tabs__panel > :first-child {
  margin-top: 0;
}

html.lab-tabs-js .lab-tabs__panel {
  display: none;
}

html.lab-tabs-js .lab-tabs__panel.is-active {
  display: block;
}

.lab-note {
  padding: 0.9rem 1rem;
  margin: 1rem 0;
  border-left: 4px solid #0969da;
  background: #eff6ff;
  border-radius: 8px;
}

.lab-copyable {
  position: relative;
}

.lab-copy-button {
  position: absolute;
  top: 0.7rem;
  right: 0.7rem;
  width: 2rem;
  height: 2rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgba(27, 31, 36, 0.15);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.92);
  color: #57606a;
  cursor: pointer;
  z-index: 2;
}

.lab-copy-button:hover {
  background: #ffffff;
  color: #0969da;
}

.lab-copy-button.is-copied {
  color: #1a7f37;
}

.lab-copy-button svg {
  width: 1rem;
  height: 1rem;
  fill: currentColor;
}

.lab-copyable pre {
  padding-top: 2.6rem;
}

@media (max-width: 767px) {
  .lab-tabs__panel {
    padding: 0.9rem 0.8rem 0.2rem;
  }
}
</style>

> **Protect a private workload VM in the Lab 0 spoke VNet with Azure Site Recovery, fail it over to the DR spoke, and validate access through regional Bastion without assigning public IPs.**

<div class="lab-note">
  <strong>Preview tooling note:</strong> Azure Site Recovery's CLI extension is still preview. The Bash and PowerShell paths below follow the current command surface, while the Portal path remains the most stable experience if the extension changes.
</div>

<div class="lab-note">
  <strong>Lab 0 required:</strong> This variant assumes the optional hub-and-spoke foundation already exists: the workload stays in <code>vnet-spoke-swc</code> / <code>vnet-spoke-noe</code>, while <code>bas-hub-swc</code>, <code>bas-hub-noe</code>, <code>afw-hub-swc</code>, and <code>afw-hub-noe</code> stay in the hubs.
</div>

<div class="lab-note">
  <strong>Hub-firewall posture:</strong> Lab 0 stages <code>rt-spoke-egress-swc</code> and <code>rt-spoke-egress-noe</code> but intentionally leaves them unattached. Keep that staged posture unless you have already added the Azure Firewall allow rules needed for package installation, Azure Site Recovery, storage access, and your validation traffic. Do <em>not</em> add a public IP to the VM just to work around management or egress.
</div>

---

## Why This Secure Variant Exists

Lab 6-a keeps the original standalone Site Recovery flow: it creates its own VNets, gives the source VM a public IP for quick validation, and isolates everything inside dedicated resource groups.

Lab 6-b keeps the same Azure Site Recovery lifecycle, but it reuses the secure networking assumptions from Lab 0:

- The source and recovery VMs live in the **spoke** workload subnet, not in the hub
- **Azure Bastion** in each hub is the management path for private-only VMs
- **Azure Firewall** stays in the hub as the regional inspection point
- The recovery VM lands in the DR spoke so failover stays aligned with the regional hub-and-spoke stamp

---

## Architecture

```text
                    ┌──────────────── Sweden Central (Primary) ────────────────┐
                    │ rg-hub-swc                                               │
                    │  vnet-hub-swc                                            │
                    │   ├─ AzureFirewallSubnet  → afw-hub-swc                  │
                    │   └─ AzureBastionSubnet   → bas-hub-swc                  │
                    │                 ▲                                         │
                    │                 │ hub-spoke peering                      │
                    │                 ▼                                         │
                    │ rg-spoke-swc                                             │
                    │  vnet-spoke-swc / snet-workload                          │
                    │   ├─ vm-dr-swc-sec-<suffix> (no public IP)               │
                    │   ├─ Recovery Services vault                             │
                    │   └─ Staging / cache storage                             │
                    └───────────────┬───────────────────────────────────────────┘
                                    │ Azure Site Recovery policy + mappings
                                    │ async A2A replication
                    ┌───────────────▼───────────────────────────────────────────┐
                    │ rg-spoke-noe                                             │
                    │  vnet-spoke-noe / snet-workload                          │
                    │   └─ recovered VM (no public IP)                         │
                    │                 ▲                                         │
                    │                 │ hub-spoke peering                      │
                    │                 ▼                                         │
                    │ rg-hub-noe                                               │
                    │  vnet-hub-noe                                            │
                    │   ├─ AzureFirewallSubnet  → afw-hub-noe                  │
                    │   └─ AzureBastionSubnet   → bas-hub-noe                  │
                    └──────────────── Norway East (Recovery) ───────────────────┘
```

---

## Prerequisites

- Lab 0 is already complete and its resources still exist
- `vnet-spoke-swc/snet-workload` and `vnet-spoke-noe/snet-workload` both have free IP capacity
- Azure CLI 2.60+ and an authenticated `az login` session
- Optional PowerShell 7+ if you follow the PowerShell path
- Permission to create:
  - Azure VMs in the shared spoke resource groups
  - Recovery Services vaults and storage accounts
  - Azure Site Recovery fabrics, mappings, and protected items
- Willingness to wait for asynchronous Site Recovery jobs

> **Private-only pattern:** This variant keeps the workload private from start to finish. Public IPs and direct SSH/RDP exposure are intentionally out of scope; Bastion is the admin path.

---
## Step 1 — Install the extension and set fixed hub/spoke variables

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az config set extension.use_dynamic_install=yes_without_prompt
az extension add --name site-recovery --allow-preview true

SUFFIX=$(openssl rand -hex 2)

LOCATION_PRIMARY=swedencentral
LOCATION_SECONDARY=norwayeast

RG_HUB_PRIMARY="rg-hub-swc"
RG_PRIMARY="rg-spoke-swc"
RG_HUB_SECONDARY="rg-hub-noe"
RG_SECONDARY="rg-spoke-noe"

VNET_PRIMARY="vnet-spoke-swc"
VNET_SECONDARY="vnet-spoke-noe"
SUBNET_PRIMARY="snet-workload"
SUBNET_SECONDARY="snet-workload"

BASTION_PRIMARY="bas-hub-swc"
BASTION_SECONDARY="bas-hub-noe"
FIREWALL_PRIMARY="afw-hub-swc"
FIREWALL_SECONDARY="afw-hub-noe"
ROUTE_TABLE_PRIMARY="rt-spoke-egress-swc"
ROUTE_TABLE_SECONDARY="rt-spoke-egress-noe"

VM_NAME="vm-dr-swc-sec-$SUFFIX"
VAULT_NAME="rsv-vm-dr-sec-$SUFFIX"
CACHE_STORAGE="stc06b${SUFFIX}swc"
VM_ADMIN=azureuser

FABRIC_PRIMARY="fabric-swc-sec-$SUFFIX"
FABRIC_SECONDARY="fabric-noe-sec-$SUFFIX"
CONTAINER_PRIMARY="pc-swc-sec-$SUFFIX"
CONTAINER_SECONDARY="pc-noe-sec-$SUFFIX"
POLICY_NAME="policy-a2a-sec-$SUFFIX"
MAPPING_PRIMARY_TO_SECONDARY="map-swc-noe-sec-$SUFFIX"
MAPPING_SECONDARY_TO_PRIMARY="map-noe-swc-sec-$SUFFIX"
NETWORK_MAPPING_PRIMARY="netmap-swc-noe-sec-$SUFFIX"
NETWORK_MAPPING_SECONDARY="netmap-noe-swc-sec-$SUFFIX"
PROTECTED_ITEM="pi-$VM_NAME"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az config set extension.use_dynamic_install=yes_without_prompt
az extension add --name site-recovery --allow-preview true

$Suffix = -join ((48..57 + 97..122 | Get-Random -Count 4 | ForEach-Object { [char]$_ }))

$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"

$RG_HUB_PRIMARY = "rg-hub-swc"
$RG_PRIMARY = "rg-spoke-swc"
$RG_HUB_SECONDARY = "rg-hub-noe"
$RG_SECONDARY = "rg-spoke-noe"

$VNET_PRIMARY = "vnet-spoke-swc"
$VNET_SECONDARY = "vnet-spoke-noe"
$SUBNET_PRIMARY = "snet-workload"
$SUBNET_SECONDARY = "snet-workload"

$BASTION_PRIMARY = "bas-hub-swc"
$BASTION_SECONDARY = "bas-hub-noe"
$FIREWALL_PRIMARY = "afw-hub-swc"
$FIREWALL_SECONDARY = "afw-hub-noe"
$ROUTE_TABLE_PRIMARY = "rt-spoke-egress-swc"
$ROUTE_TABLE_SECONDARY = "rt-spoke-egress-noe"

$VM_NAME = "vm-dr-swc-sec-$Suffix"
$VAULT_NAME = "rsv-vm-dr-sec-$Suffix"
$CACHE_STORAGE = "stc06b${Suffix}swc"
$VM_ADMIN = "azureuser"

$FABRIC_PRIMARY = "fabric-swc-sec-$Suffix"
$FABRIC_SECONDARY = "fabric-noe-sec-$Suffix"
$CONTAINER_PRIMARY = "pc-swc-sec-$Suffix"
$CONTAINER_SECONDARY = "pc-noe-sec-$Suffix"
$POLICY_NAME = "policy-a2a-sec-$Suffix"
$MAPPING_PRIMARY_TO_SECONDARY = "map-swc-noe-sec-$Suffix"
$MAPPING_SECONDARY_TO_PRIMARY = "map-noe-swc-sec-$Suffix"
$NETWORK_MAPPING_PRIMARY = "netmap-swc-noe-sec-$Suffix"
$NETWORK_MAPPING_SECONDARY = "netmap-noe-swc-sec-$Suffix"
$PROTECTED_ITEM = "pi-$VM_NAME"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Cloud Shell** or your preferred terminal.
2. If prompted, allow Azure CLI to install the **site-recovery** and **bastion** extensions as needed.
3. Keep the Lab 0 foundation names fixed:
   - `rg-hub-swc`, `rg-spoke-swc`, `rg-hub-noe`, `rg-spoke-noe`
   - `vnet-spoke-swc`, `vnet-spoke-noe`
   - `snet-workload`
   - `bas-hub-swc`, `bas-hub-noe`
   - `afw-hub-swc`, `afw-hub-noe`
4. Pick a short unique suffix for the new workload-specific resources so the VM, vault, storage account, and ASR object names do not collide with earlier runs.

  </div>
</div>

## Step 2 — Validate the Lab 0 foundation and confirm the firewall posture

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az network bastion show \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$BASTION_PRIMARY" \
  --query "{Name:name,State:provisioningState}" \
  --output table

az network bastion show \
  --resource-group "$RG_HUB_SECONDARY" \
  --name "$BASTION_SECONDARY" \
  --query "{Name:name,State:provisioningState}" \
  --output table

az network firewall show \
  --resource-group "$RG_HUB_PRIMARY" \
  --name "$FIREWALL_PRIMARY" \
  --query "{Name:name,PrivateIP:ipConfigurations[0].privateIPAddress,Policy:firewallPolicy.id}" \
  --output table

az network firewall show \
  --resource-group "$RG_HUB_SECONDARY" \
  --name "$FIREWALL_SECONDARY" \
  --query "{Name:name,PrivateIP:ipConfigurations[0].privateIPAddress,Policy:firewallPolicy.id}" \
  --output table

az network route-table show \
  --resource-group "$RG_PRIMARY" \
  --name "$ROUTE_TABLE_PRIMARY" \
  --query "{Name:name,AssociatedSubnets:subnets[].id,DefaultNextHop:routes[?name=='default-to-regional-firewall'].nextHopIpAddress | [0]}" \
  --output json

az network route-table show \
  --resource-group "$RG_SECONDARY" \
  --name "$ROUTE_TABLE_SECONDARY" \
  --query "{Name:name,AssociatedSubnets:subnets[].id,DefaultNextHop:routes[?name=='default-to-regional-firewall'].nextHopIpAddress | [0]}" \
  --output json

az network vnet subnet show \
  --resource-group "$RG_PRIMARY" \
  --vnet-name "$VNET_PRIMARY" \
  --name "$SUBNET_PRIMARY" \
  --query "{Name:name,Prefix:addressPrefix}" \
  --output table

az network vnet subnet show \
  --resource-group "$RG_SECONDARY" \
  --vnet-name "$VNET_SECONDARY" \
  --name "$SUBNET_SECONDARY" \
  --query "{Name:name,Prefix:addressPrefix}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az network bastion show `
  --resource-group $RG_HUB_PRIMARY `
  --name $BASTION_PRIMARY `
  --query "{Name:name,State:provisioningState}" `
  --output table

az network bastion show `
  --resource-group $RG_HUB_SECONDARY `
  --name $BASTION_SECONDARY `
  --query "{Name:name,State:provisioningState}" `
  --output table

az network firewall show `
  --resource-group $RG_HUB_PRIMARY `
  --name $FIREWALL_PRIMARY `
  --query "{Name:name,PrivateIP:ipConfigurations[0].privateIPAddress,Policy:firewallPolicy.id}" `
  --output table

az network firewall show `
  --resource-group $RG_HUB_SECONDARY `
  --name $FIREWALL_SECONDARY `
  --query "{Name:name,PrivateIP:ipConfigurations[0].privateIPAddress,Policy:firewallPolicy.id}" `
  --output table

az network route-table show `
  --resource-group $RG_PRIMARY `
  --name $ROUTE_TABLE_PRIMARY `
  --query "{Name:name,AssociatedSubnets:subnets[].id,DefaultNextHop:routes[?name=='default-to-regional-firewall'].nextHopIpAddress | [0]}" `
  --output json

az network route-table show `
  --resource-group $RG_SECONDARY `
  --name $ROUTE_TABLE_SECONDARY `
  --query "{Name:name,AssociatedSubnets:subnets[].id,DefaultNextHop:routes[?name=='default-to-regional-firewall'].nextHopIpAddress | [0]}" `
  --output json

az network vnet subnet show `
  --resource-group $RG_PRIMARY `
  --vnet-name $VNET_PRIMARY `
  --name $SUBNET_PRIMARY `
  --query "{Name:name,Prefix:addressPrefix}" `
  --output table

az network vnet subnet show `
  --resource-group $RG_SECONDARY `
  --vnet-name $VNET_SECONDARY `
  --name $SUBNET_SECONDARY `
  --query "{Name:name,Prefix:addressPrefix}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Confirm the four Lab 0 resource groups still exist: `rg-hub-swc`, `rg-spoke-swc`, `rg-hub-noe`, and `rg-spoke-noe`.
2. Open `bas-hub-swc` and `bas-hub-noe` and verify both Bastion hosts are healthy.
3. Open `afw-hub-swc` and `afw-hub-noe` and note that each firewall has a private IP and an attached policy.
4. Open `vnet-spoke-swc` and `vnet-spoke-noe` and confirm both still contain `snet-workload`.
5. Open `rt-spoke-egress-swc` and `rt-spoke-egress-noe` and check whether they are still unattached. If you already attached them, confirm the firewall policy already allows the outbound traffic this lab needs before you continue.

  </div>
</div>

<div class="lab-note">
  <strong>Interpret the route-table output carefully:</strong> An empty <code>AssociatedSubnets</code> value means you are still on Lab 0's default staged posture. If either route table is already associated to <code>snet-workload</code>, make sure the firewall policy is ready before you deploy or replicate the VM.
</div>

## Step 3 — Create the source VM in the primary spoke without a public IP

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az vm create \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_NAME" \
  --location "$LOCATION_PRIMARY" \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username "$VM_ADMIN" \
  --generate-ssh-keys \
  --vnet-name "$VNET_PRIMARY" \
  --subnet "$SUBNET_PRIMARY" \
  --public-ip-address "" \
  --nsg "" \
  --tags lab=06b variant=secure role=source

az vm run-command invoke \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "sudo apt-get update && sudo apt-get install -y nginx && echo 'Primary region: Sweden Central (secure spoke)' | sudo tee /var/www/html/index.html"

az vm show -d \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_NAME" \
  --query "{Name:name,PrivateIPs:privateIps,PublicIPs:publicIps,PowerState:powerState}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az vm create `
  --resource-group $RG_PRIMARY `
  --name $VM_NAME `
  --location $LOCATION_PRIMARY `
  --image Ubuntu2204 `
  --size Standard_B2s `
  --admin-username $VM_ADMIN `
  --generate-ssh-keys `
  --vnet-name $VNET_PRIMARY `
  --subnet $SUBNET_PRIMARY `
  --public-ip-address "" `
  --nsg "" `
  --tags lab=06b variant=secure role=source | Out-Null

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts "sudo apt-get update && sudo apt-get install -y nginx && echo 'Primary region: Sweden Central (secure spoke)' | sudo tee /var/www/html/index.html" | Out-Null

az vm show -d `
  --resource-group $RG_PRIMARY `
  --name $VM_NAME `
  --query "{Name:name,PrivateIPs:privateIps,PublicIPs:publicIps,PowerState:powerState}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-spoke-swc`, create a Linux VM in **Sweden Central**.
2. Place it in the existing VNet and subnet: `vnet-spoke-swc` / `snet-workload`.
3. On the networking tab, set **Public IP = None** and do not open SSH or HTTP directly from the internet.
4. Install a simple web page by using **Run command** or the guest shell, then confirm the VM still has **no public IP**.
5. Use **Connect > Bastion** and the existing `bas-hub-swc` host if you want an interactive session to the VM.

  </div>
</div>

<div class="lab-note">
  <strong>Bastion access pattern:</strong> Keep the VM private. Use the hub Bastion for interactive access now and after failover. Azure CLI also supports <code>az network bastion ssh</code> and <code>az network bastion tunnel</code> if you prefer a native client.
</div>

## Step 4 — Create the Recovery Services vault and staging storage in the primary spoke RG

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az backup vault create \
  --resource-group "$RG_PRIMARY" \
  --name "$VAULT_NAME" \
  --location "$LOCATION_PRIMARY"

az storage account create \
  --resource-group "$RG_PRIMARY" \
  --name "$CACHE_STORAGE" \
  --location "$LOCATION_PRIMARY" \
  --sku Standard_LRS \
  --kind StorageV2

VM_ID=$(az vm show --resource-group "$RG_PRIMARY" --name "$VM_NAME" --query id --output tsv)
OS_DISK_ID=$(az vm show --resource-group "$RG_PRIMARY" --name "$VM_NAME" --query storageProfile.osDisk.managedDisk.id --output tsv)
VNET_PRIMARY_ID=$(az network vnet show --resource-group "$RG_PRIMARY" --name "$VNET_PRIMARY" --query id --output tsv)
VNET_SECONDARY_ID=$(az network vnet show --resource-group "$RG_SECONDARY" --name "$VNET_SECONDARY" --query id --output tsv)
CACHE_STORAGE_ID=$(az storage account show --resource-group "$RG_PRIMARY" --name "$CACHE_STORAGE" --query id --output tsv)
RG_PRIMARY_ID=$(az group show --name "$RG_PRIMARY" --query id --output tsv)
RG_SECONDARY_ID=$(az group show --name "$RG_SECONDARY" --query id --output tsv)
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az backup vault create `
  --resource-group $RG_PRIMARY `
  --name $VAULT_NAME `
  --location $LOCATION_PRIMARY | Out-Null

az storage account create `
  --resource-group $RG_PRIMARY `
  --name $CACHE_STORAGE `
  --location $LOCATION_PRIMARY `
  --sku Standard_LRS `
  --kind StorageV2 | Out-Null

$VM_ID = az vm show --resource-group $RG_PRIMARY --name $VM_NAME --query id --output tsv
$OS_DISK_ID = az vm show --resource-group $RG_PRIMARY --name $VM_NAME --query storageProfile.osDisk.managedDisk.id --output tsv
$VNET_PRIMARY_ID = az network vnet show --resource-group $RG_PRIMARY --name $VNET_PRIMARY --query id --output tsv
$VNET_SECONDARY_ID = az network vnet show --resource-group $RG_SECONDARY --name $VNET_SECONDARY --query id --output tsv
$CACHE_STORAGE_ID = az storage account show --resource-group $RG_PRIMARY --name $CACHE_STORAGE --query id --output tsv
$RG_PRIMARY_ID = az group show --name $RG_PRIMARY --query id --output tsv
$RG_SECONDARY_ID = az group show --name $RG_SECONDARY --query id --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In `rg-spoke-swc`, create a **Recovery Services vault** in **Sweden Central**.
2. Create a standard storage account in the same resource group to act as the Site Recovery cache/staging account.
3. If you stay on the Portal path, you can continue from the VM and vault blades without capturing raw IDs.
4. If you want to switch back to CLI later, capture the VM ID, OS disk ID, VNet IDs, and resource-group IDs from the resource JSON or properties views.

  </div>
</div>

## Step 5 — Create Site Recovery fabrics, containers, and the A2A policy

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az site-recovery fabric create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --name "$FABRIC_PRIMARY" \
  --custom-details "{azure:{location:$LOCATION_PRIMARY}}"

az site-recovery fabric create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --name "$FABRIC_SECONDARY" \
  --custom-details "{azure:{location:$LOCATION_SECONDARY}}"

az site-recovery protection-container create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --name "$CONTAINER_PRIMARY" \
  --provider-input '[{instance-type:A2A}]'

az site-recovery protection-container create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_SECONDARY" \
  --name "$CONTAINER_SECONDARY" \
  --provider-input '[{instance-type:A2A}]'

az site-recovery policy create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --name "$POLICY_NAME" \
  --provider-specific-input '{a2a:{multi-vm-sync-status:Enable}}'

POLICY_ID=$(az site-recovery policy show --resource-group "$RG_PRIMARY" --vault-name "$VAULT_NAME" --name "$POLICY_NAME" --query id --output tsv)
CONTAINER_PRIMARY_ID=$(az site-recovery protection-container show --resource-group "$RG_PRIMARY" --vault-name "$VAULT_NAME" --fabric-name "$FABRIC_PRIMARY" --name "$CONTAINER_PRIMARY" --query id --output tsv)
CONTAINER_SECONDARY_ID=$(az site-recovery protection-container show --resource-group "$RG_PRIMARY" --vault-name "$VAULT_NAME" --fabric-name "$FABRIC_SECONDARY" --name "$CONTAINER_SECONDARY" --query id --output tsv)
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az site-recovery fabric create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --name $FABRIC_PRIMARY `
  --custom-details "{azure:{location:$LOCATION_PRIMARY}}" | Out-Null

az site-recovery fabric create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --name $FABRIC_SECONDARY `
  --custom-details "{azure:{location:$LOCATION_SECONDARY}}" | Out-Null

az site-recovery protection-container create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --name $CONTAINER_PRIMARY `
  --provider-input '[{instance-type:A2A}]' | Out-Null

az site-recovery protection-container create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_SECONDARY `
  --name $CONTAINER_SECONDARY `
  --provider-input '[{instance-type:A2A}]' | Out-Null

az site-recovery policy create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --name $POLICY_NAME `
  --provider-specific-input '{a2a:{multi-vm-sync-status:Enable}}' | Out-Null

$POLICY_ID = az site-recovery policy show --resource-group $RG_PRIMARY --vault-name $VAULT_NAME --name $POLICY_NAME --query id --output tsv
$CONTAINER_PRIMARY_ID = az site-recovery protection-container show --resource-group $RG_PRIMARY --vault-name $VAULT_NAME --fabric-name $FABRIC_PRIMARY --name $CONTAINER_PRIMARY --query id --output tsv
$CONTAINER_SECONDARY_ID = az site-recovery protection-container show --resource-group $RG_PRIMARY --vault-name $VAULT_NAME --fabric-name $FABRIC_SECONDARY --name $CONTAINER_SECONDARY --query id --output tsv
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the Recovery Services vault.
2. In **Site Recovery infrastructure**, confirm both Azure regions appear as replication scopes/fabrics.
3. Create or review the protection containers for the primary and secondary regions.
4. Create an **Azure-to-Azure** replication policy.
5. Keep the focus on the workload stamp: the Site Recovery target is the recovery spoke, not the hub.

  </div>
</div>

## Step 6 — Create container mappings and spoke network mappings

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_ASR_NETWORK=$(az site-recovery network list \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --query "[?friendlyName=='$VNET_PRIMARY'].name | [0]" \
  --output tsv)

SECONDARY_ASR_NETWORK=$(az site-recovery network list \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_SECONDARY" \
  --query "[?friendlyName=='$VNET_SECONDARY'].name | [0]" \
  --output tsv)

az site-recovery protection-container mapping create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --protection-container "$CONTAINER_PRIMARY" \
  --name "$MAPPING_PRIMARY_TO_SECONDARY" \
  --policy-id "$POLICY_ID" \
  --provider-input '{a2a:{agent-auto-update-status:Disabled}}' \
  --target-container "$CONTAINER_SECONDARY_ID"

az site-recovery protection-container mapping create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_SECONDARY" \
  --protection-container "$CONTAINER_SECONDARY" \
  --name "$MAPPING_SECONDARY_TO_PRIMARY" \
  --policy-id "$POLICY_ID" \
  --provider-input '{a2a:{agent-auto-update-status:Disabled}}' \
  --target-container "$CONTAINER_PRIMARY_ID"

az site-recovery network mapping create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --network-name "$PRIMARY_ASR_NETWORK" \
  --name "$NETWORK_MAPPING_PRIMARY" \
  --recovery-fabric-name "$FABRIC_SECONDARY" \
  --recovery-network-id "$VNET_SECONDARY_ID" \
  --fabric-details "{azure-to-azure:{primary-network-id:$VNET_PRIMARY_ID}}"

az site-recovery network mapping create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_SECONDARY" \
  --network-name "$SECONDARY_ASR_NETWORK" \
  --name "$NETWORK_MAPPING_SECONDARY" \
  --recovery-fabric-name "$FABRIC_PRIMARY" \
  --recovery-network-id "$VNET_PRIMARY_ID" \
  --fabric-details "{azure-to-azure:{primary-network-id:$VNET_SECONDARY_ID}}"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_ASR_NETWORK = az site-recovery network list `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --query "[?friendlyName=='$VNET_PRIMARY'].name | [0]" `
  --output tsv

$SECONDARY_ASR_NETWORK = az site-recovery network list `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_SECONDARY `
  --query "[?friendlyName=='$VNET_SECONDARY'].name | [0]" `
  --output tsv

az site-recovery protection-container mapping create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --protection-container $CONTAINER_PRIMARY `
  --name $MAPPING_PRIMARY_TO_SECONDARY `
  --policy-id $POLICY_ID `
  --provider-input '{a2a:{agent-auto-update-status:Disabled}}' `
  --target-container $CONTAINER_SECONDARY_ID | Out-Null

az site-recovery protection-container mapping create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_SECONDARY `
  --protection-container $CONTAINER_SECONDARY `
  --name $MAPPING_SECONDARY_TO_PRIMARY `
  --policy-id $POLICY_ID `
  --provider-input '{a2a:{agent-auto-update-status:Disabled}}' `
  --target-container $CONTAINER_PRIMARY_ID | Out-Null

az site-recovery network mapping create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --network-name $PRIMARY_ASR_NETWORK `
  --name $NETWORK_MAPPING_PRIMARY `
  --recovery-fabric-name $FABRIC_SECONDARY `
  --recovery-network-id $VNET_SECONDARY_ID `
  --fabric-details "{azure-to-azure:{primary-network-id:$VNET_PRIMARY_ID}}" | Out-Null

az site-recovery network mapping create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_SECONDARY `
  --network-name $SECONDARY_ASR_NETWORK `
  --name $NETWORK_MAPPING_SECONDARY `
  --recovery-fabric-name $FABRIC_PRIMARY `
  --recovery-network-id $VNET_PRIMARY_ID `
  --fabric-details "{azure-to-azure:{primary-network-id:$VNET_SECONDARY_ID}}" | Out-Null
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Pair the primary and secondary protection containers.
2. Map the **spoke** VNets, not the hub VNets.
3. Use `vnet-spoke-swc` as the source network and `vnet-spoke-noe` as the recovery network.
4. Create the reverse mapping as well so failback has a prepared path.
5. If the network list is empty, wait a minute for discovery and try again.

  </div>
</div>

<div class="lab-note">
  <strong>Choose the spoke networks deliberately:</strong> Lab 0 creates both hub and spoke VNets in each region, so the correct Site Recovery network is the one whose <code>friendlyName</code> matches <code>vnet-spoke-swc</code> or <code>vnet-spoke-noe</code>. Do not map the hub VNets for this workload.
</div>

## Step 7 — Enable replication for the VM into the Norway East spoke

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
A2A_PROVIDER_DETAILS=$(cat <<EOF
{a2a:{fabric-object-id:$VM_ID,vm-managed-disks:[{disk-id:$OS_DISK_ID,primary-staging-azure-storage-account-id:$CACHE_STORAGE_ID,recovery-resource-group-id:$RG_SECONDARY_ID}],recovery-azure-network-id:$VNET_SECONDARY_ID,recovery-container-id:$CONTAINER_SECONDARY_ID,recovery-resource-group-id:$RG_SECONDARY_ID,recovery-subnet-name:$SUBNET_SECONDARY}}
EOF
)

az site-recovery protected-item create \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --protection-container "$CONTAINER_PRIMARY" \
  --name "$PROTECTED_ITEM" \
  --policy-id "$POLICY_ID" \
  --provider-details "$A2A_PROVIDER_DETAILS"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$A2A_PROVIDER_DETAILS = @"
{a2a:{fabric-object-id:$VM_ID,vm-managed-disks:[{disk-id:$OS_DISK_ID,primary-staging-azure-storage-account-id:$CACHE_STORAGE_ID,recovery-resource-group-id:$RG_SECONDARY_ID}],recovery-azure-network-id:$VNET_SECONDARY_ID,recovery-container-id:$CONTAINER_SECONDARY_ID,recovery-resource-group-id:$RG_SECONDARY_ID,recovery-subnet-name:$SUBNET_SECONDARY}}
"@

az site-recovery protected-item create `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --protection-container $CONTAINER_PRIMARY `
  --name $PROTECTED_ITEM `
  --policy-id $POLICY_ID `
  --provider-details $A2A_PROVIDER_DETAILS
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the source VM and choose **Disaster recovery**.
2. Select **Norway East** as the target region.
3. Choose `rg-spoke-noe`, `vnet-spoke-noe`, and `snet-workload` as the target landing zone.
4. Start replication and keep the VM private; the recovery VM should not need a public IP either.

  </div>
</div>

## Step 8 — Wait for healthy replication and inspect the protected item

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
while true; do
  STATE=$(az site-recovery protected-item show \
    --resource-group "$RG_PRIMARY" \
    --vault-name "$VAULT_NAME" \
    --fabric-name "$FABRIC_PRIMARY" \
    --protection-container "$CONTAINER_PRIMARY" \
    --name "$PROTECTED_ITEM" \
    --query "properties.protectionState" \
    --output tsv)

  echo "Protection state: $STATE"
  [[ "$STATE" == "Protected" ]] && break
  sleep 30
done

az site-recovery protected-item show \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --protection-container "$CONTAINER_PRIMARY" \
  --name "$PROTECTED_ITEM" \
  --query "{State:properties.protectionState,Health:properties.replicationHealth,ActiveLocation:properties.activeLocation}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
do {
  $STATE = az site-recovery protected-item show `
    --resource-group $RG_PRIMARY `
    --vault-name $VAULT_NAME `
    --fabric-name $FABRIC_PRIMARY `
    --protection-container $CONTAINER_PRIMARY `
    --name $PROTECTED_ITEM `
    --query "properties.protectionState" `
    --output tsv

  Write-Host "Protection state: $STATE"
  if ($STATE -eq "Protected") { break }
  Start-Sleep -Seconds 30
} while ($true)

az site-recovery protected-item show `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --protection-container $CONTAINER_PRIMARY `
  --name $PROTECTED_ITEM `
  --query "{State:properties.protectionState,Health:properties.replicationHealth,ActiveLocation:properties.activeLocation}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the VM's **Disaster recovery** blade, wait until **Replication health** is healthy.
2. Review the target region, target VNet, and last synchronization timestamp.
3. Do not start failover until the VM shows healthy protection and recovery-point generation has started.

  </div>
</div>

## Step 9 — Run a failover drill to the Norway East spoke and validate private access

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az site-recovery protected-item unplanned-failover \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --protection-container "$CONTAINER_PRIMARY" \
  --name "$PROTECTED_ITEM" \
  --failover-direction PrimaryToRecovery \
  --provider-details '{a2a:{}}' \
  --source-site-operations NotRequired

while true; do
  ACTIVE_LOCATION=$(az site-recovery protected-item show \
    --resource-group "$RG_PRIMARY" \
    --vault-name "$VAULT_NAME" \
    --fabric-name "$FABRIC_PRIMARY" \
    --protection-container "$CONTAINER_PRIMARY" \
    --name "$PROTECTED_ITEM" \
    --query "properties.activeLocation" \
    --output tsv)

  echo "Active location: $ACTIVE_LOCATION"
  [[ "$ACTIVE_LOCATION" == "Recovery" ]] && break
  sleep 30
done

az site-recovery protected-item failover-commit \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --protection-container "$CONTAINER_PRIMARY" \
  --name "$PROTECTED_ITEM"

RECOVERY_VM=$(az vm list \
  --resource-group "$RG_SECONDARY" \
  --query "[?contains(name, '$SUFFIX')].name | [0]" \
  --output tsv)

az vm show -d \
  --resource-group "$RG_SECONDARY" \
  --name "$RECOVERY_VM" \
  --query "{Name:name,PrivateIPs:privateIps,PublicIPs:publicIps,PowerState:powerState}" \
  --output table

az vm run-command invoke \
  --resource-group "$RG_SECONDARY" \
  --name "$RECOVERY_VM" \
  --command-id RunShellScript \
  --scripts "hostname && curl -s http://localhost"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az site-recovery protected-item unplanned-failover `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --protection-container $CONTAINER_PRIMARY `
  --name $PROTECTED_ITEM `
  --failover-direction PrimaryToRecovery `
  --provider-details '{a2a:{}}' `
  --source-site-operations NotRequired | Out-Null

do {
  $ACTIVE_LOCATION = az site-recovery protected-item show `
    --resource-group $RG_PRIMARY `
    --vault-name $VAULT_NAME `
    --fabric-name $FABRIC_PRIMARY `
    --protection-container $CONTAINER_PRIMARY `
    --name $PROTECTED_ITEM `
    --query "properties.activeLocation" `
    --output tsv

  Write-Host "Active location: $ACTIVE_LOCATION"
  if ($ACTIVE_LOCATION -eq "Recovery") { break }
  Start-Sleep -Seconds 30
} while ($true)

az site-recovery protected-item failover-commit `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --protection-container $CONTAINER_PRIMARY `
  --name $PROTECTED_ITEM | Out-Null

$RECOVERY_VM = az vm list `
  --resource-group $RG_SECONDARY `
  --query "[?contains(name, '$Suffix')].name | [0]" `
  --output tsv

az vm show -d `
  --resource-group $RG_SECONDARY `
  --name $RECOVERY_VM `
  --query "{Name:name,PrivateIPs:privateIps,PublicIPs:publicIps,PowerState:powerState}" `
  --output table

az vm run-command invoke `
  --resource-group $RG_SECONDARY `
  --name $RECOVERY_VM `
  --command-id RunShellScript `
  --scripts "hostname && curl -s http://localhost"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. On the protected VM, choose **Failover** from the **Disaster recovery** blade.
2. Select the latest recovery point and start the failover drill to **Norway East**.
3. After the recovery VM boots successfully, choose **Commit**.
4. Open the recovered VM in `rg-spoke-noe` and confirm it landed in `vnet-spoke-noe` / `snet-workload` with **no public IP**.
5. Use **Connect > Bastion** with `bas-hub-noe` to validate the recovered workload privately.

  </div>
</div>

<div class="lab-note">
  <strong>Recovery access path:</strong> After failover, keep the recovered VM private in the Norway East spoke. Use <code>bas-hub-noe</code> for interactive validation instead of assigning a public IP.
</div>

## Step 10 — Prepare the reverse-protection path for failback (optional)

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RECOVERY_VM=$(az vm list \
  --resource-group "$RG_SECONDARY" \
  --query "[?contains(name, '$SUFFIX')].name | [0]" \
  --output tsv)
RECOVERY_VM_OS_DISK_ID=$(az vm show --resource-group "$RG_SECONDARY" --name "$RECOVERY_VM" --query storageProfile.osDisk.managedDisk.id --output tsv)

SWITCH_PROVIDER_DETAILS=$(cat <<EOF
{a2a:{policy-id:$POLICY_ID,recovery-container-id:$CONTAINER_PRIMARY_ID,recovery-resource-group-id:$RG_PRIMARY_ID,vm-managed-disks:[{disk-id:$RECOVERY_VM_OS_DISK_ID,primary-staging-azure-storage-account-id:$CACHE_STORAGE_ID,recovery-resource-group-id:$RG_PRIMARY_ID}]}}
EOF
)

az site-recovery protection-container switch-protection \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_SECONDARY" \
  --protection-container-name "$CONTAINER_SECONDARY" \
  --protected-item "$PROTECTED_ITEM" \
  --provider-details "$SWITCH_PROVIDER_DETAILS"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RECOVERY_VM = az vm list `
  --resource-group $RG_SECONDARY `
  --query "[?contains(name, '$Suffix')].name | [0]" `
  --output tsv
$RECOVERY_VM_OS_DISK_ID = az vm show --resource-group $RG_SECONDARY --name $RECOVERY_VM --query storageProfile.osDisk.managedDisk.id --output tsv

$SWITCH_PROVIDER_DETAILS = @"
{a2a:{policy-id:$POLICY_ID,recovery-container-id:$CONTAINER_PRIMARY_ID,recovery-resource-group-id:$RG_PRIMARY_ID,vm-managed-disks:[{disk-id:$RECOVERY_VM_OS_DISK_ID,primary-staging-azure-storage-account-id:$CACHE_STORAGE_ID,recovery-resource-group-id:$RG_PRIMARY_ID}]}}
"@

az site-recovery protection-container switch-protection `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_SECONDARY `
  --protection-container-name $CONTAINER_SECONDARY `
  --protected-item $PROTECTED_ITEM `
  --provider-details $SWITCH_PROVIDER_DETAILS
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open the recovered VM's **Disaster recovery** blade.
2. Choose **Re-protect** so replication starts in the reverse direction back toward Sweden Central.
3. Keep the target on the original primary spoke and workload subnet.
4. Use this step only if you want to practice a full failback later; otherwise you can go straight to cleanup.

  </div>
</div>

## Step 11 — Cleanup only the workload resources, not the shared Lab 0 foundation

If you already completed the reverse-protection step, remove or finish that workflow from the active protection direction before you delete the vault.

<div class="lab-note">
  <strong>Shared foundation warning:</strong> Unlike Lab 6-a, do <em>not</em> delete <code>rg-spoke-swc</code>, <code>rg-spoke-noe</code>, <code>rg-hub-swc</code>, or <code>rg-hub-noe</code>. Delete only the workload resources that use your suffix and leave the Lab 0 networking foundation intact.
</div>

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RECOVERY_VM=$(az vm list \
  --resource-group "$RG_SECONDARY" \
  --query "[?contains(name, '$SUFFIX')].name | [0]" \
  --output tsv)

az site-recovery protected-item remove \
  --resource-group "$RG_PRIMARY" \
  --vault-name "$VAULT_NAME" \
  --fabric-name "$FABRIC_PRIMARY" \
  --protection-container "$CONTAINER_PRIMARY" \
  --name "$PROTECTED_ITEM"

if [[ -n "$RECOVERY_VM" ]]; then
  az vm delete --resource-group "$RG_SECONDARY" --name "$RECOVERY_VM" --yes
fi

az vm delete --resource-group "$RG_PRIMARY" --name "$VM_NAME" --yes
az storage account delete --resource-group "$RG_PRIMARY" --name "$CACHE_STORAGE" --yes
az backup vault delete --resource-group "$RG_PRIMARY" --name "$VAULT_NAME" --yes --force

az resource list \
  --resource-group "$RG_PRIMARY" \
  --query "[?contains(name, '$SUFFIX')].{Name:name,Type:type}" \
  --output table

az resource list \
  --resource-group "$RG_SECONDARY" \
  --query "[?contains(name, '$SUFFIX')].{Name:name,Type:type}" \
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RECOVERY_VM = az vm list `
  --resource-group $RG_SECONDARY `
  --query "[?contains(name, '$Suffix')].name | [0]" `
  --output tsv

az site-recovery protected-item remove `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --protection-container $CONTAINER_PRIMARY `
  --name $PROTECTED_ITEM | Out-Null

if ($RECOVERY_VM) {
  az vm delete --resource-group $RG_SECONDARY --name $RECOVERY_VM --yes | Out-Null
}

az vm delete --resource-group $RG_PRIMARY --name $VM_NAME --yes | Out-Null
az storage account delete --resource-group $RG_PRIMARY --name $CACHE_STORAGE --yes | Out-Null
az backup vault delete --resource-group $RG_PRIMARY --name $VAULT_NAME --yes --force | Out-Null

az resource list `
  --resource-group $RG_PRIMARY `
  --query "[?contains(name, '$Suffix')].{Name:name,Type:type}" `
  --output table

az resource list `
  --resource-group $RG_SECONDARY `
  --query "[?contains(name, '$Suffix')].{Name:name,Type:type}" `
  --output table
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. In the Recovery Services vault, disable replication / remove the protected item. If you completed reverse protection, remove it from the current active direction first.
2. Delete the vault and the cache storage account that use your suffix.
3. Delete the source VM in `rg-spoke-swc` and the recovered VM in `rg-spoke-noe`.
4. If NICs or managed disks with your suffix remain in either spoke resource group, delete only those leftover workload resources.
5. Leave the shared Lab 0 resource groups, VNets, Bastions, Firewalls, and route tables intact.

  </div>
</div>

<div class="lab-note">
  <strong>Post-cleanup check:</strong> If the final resource-list tables still show resources with your suffix, remove only those leftover workload objects. Shared hub/spoke infrastructure should remain untouched.
</div>

---

## Key Takeaways

1. **Azure Site Recovery works with private-only VMs.** The protected workload can stay inside the spoke with no public IP.
2. **Hub and spoke each keep their job.** The workload lives in the spoke; Bastion and Firewall stay in the hub as shared controls.
3. **Bastion replaces public management exposure.** Use the regional Bastion before and after failover instead of adding ad-hoc public IPs.
4. **Map the spoke VNets deliberately.** In the secure variant, the ASR network whose friendly name matches the spoke VNet is the one you want.
5. **Treat firewall routing as a deliberate control.** Attach the staged route tables only when the Azure Firewall policy is ready for the traffic you need.

---

## Further Reading

- [Azure-to-Azure disaster recovery quickstart](https://learn.microsoft.com/azure/site-recovery/azure-to-azure-quickstart)
- [Azure Site Recovery overview](https://learn.microsoft.com/azure/site-recovery/site-recovery-overview)
- [Azure Bastion overview](https://learn.microsoft.com/azure/bastion/bastion-overview)
- [Azure CLI — Site Recovery protected items](https://learn.microsoft.com/cli/azure/site-recovery/protected-item)
- [Business continuity for Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/disaster-recovery-guidance)

---

[← Lab 6-a — Standalone Site Recovery](lab-06a-vm-site-recovery.md) | **Lab 6-b — Secure spoke & Bastion**
