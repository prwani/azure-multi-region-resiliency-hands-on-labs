---
layout: default
title: "Lab 6-a: Azure Virtual Machines – Cross-Region DR with Site Recovery"
---

**Variant navigation:** **Lab 6-a — Standalone Site Recovery** | [Lab 6-b — Secure spoke & Bastion](lab-06b-vm-site-recovery-secure-spoke.md)

# Lab 6-a: Azure Virtual Machines – Cross-Region DR with Site Recovery

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

> **Protect a regional Azure VM with Azure Site Recovery, fail it over to a non-paired region, and prepare the environment for failback.**

<div class="lab-note">
  <strong>Preview tooling note:</strong> Azure Site Recovery's CLI extension is still preview. The Bash and PowerShell paths below follow the current command surface, while the Portal path remains the most stable experience if the extension changes.
</div>

<div class="lab-note">
  <strong>Variant note:</strong> This <code>A</code> path keeps the original standalone flow: it creates its own VNets, uses a public IP for the source VM, and does not depend on the optional hub-and-spoke foundation. If you want the VM to stay private inside fixed spoke VNets with Bastion access through the hubs, use <a href="lab-06b-vm-site-recovery-secure-spoke.md">Lab 6-b</a>.
</div>

---

## Why Multi-Region VM DR Matters

A single-region virtual machine is still a single-region failure domain. If the VM, its managed disks, or its surrounding regional control plane become unavailable, an otherwise healthy application can still go dark.

Azure Site Recovery gives you a repeatable DR workflow for virtual machines: replicate the VM to another region, run failover drills, and prepare a failback path without rebuilding everything from scratch.

In this lab you will:

- Build a source VM in **Sweden Central**
- Create a recovery environment in **Norway East**
- Configure Azure Site Recovery objects and mappings
- Trigger a failover drill and validate the recovered VM
- Prepare the reverse-protection workflow for failback

---

## Architecture

```
                          ┌──────────────────────────────┐
                          │  Recovery Services vault     │
                          │  Sweden Central              │
                          └──────────────┬───────────────┘
                                         │
                          Site Recovery replication policy
                                         │
      ┌──────────────────────────────────┼──────────────────────────────────┐
      │                                  │                                  │
┌─────▼──────────────────┐      async A2A replication      ┌────────────────▼─────┐
│ Sweden Central         │ ──────────────────────────────► │ Norway East          │
│ Source VM              │                                 │ Recovery VM          │
│ Source managed disk    │                                 │ Recovery managed disk│
│ Source VNet / subnet   │                                 │ Recovery VNet/subnet │
└────────────────────────┘                                 └──────────────────────┘
```

---

## Prerequisites

- Azure CLI 2.60+ and an authenticated `az login` session
- SSH key pair available locally (the Bash path uses `--generate-ssh-keys` if needed)
- Permission to create:
  - Azure VMs
  - Recovery Services vaults
  - Storage accounts
  - Networking resources in both regions
- Willingness to wait for asynchronous Site Recovery jobs; several steps can take multiple minutes

---
## Step 1 — Install the extension and set variables

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az extension add --name site-recovery --allow-preview true

SUFFIX=$(openssl rand -hex 2)

LOCATION_PRIMARY=swedencentral
LOCATION_SECONDARY=norwayeast

RG_PRIMARY="rg-vm-dr-swc-$SUFFIX"
RG_SECONDARY="rg-vm-dr-noe-$SUFFIX"

VM_NAME="vm-dr-swc-$SUFFIX"
VNET_PRIMARY="vnet-vm-dr-swc-$SUFFIX"
VNET_SECONDARY="vnet-vm-dr-noe-$SUFFIX"
SUBNET_PRIMARY="subnet-app"
SUBNET_SECONDARY="subnet-recovery"

VAULT_NAME="rsv-vm-dr-$SUFFIX"
CACHE_STORAGE="stcache${SUFFIX}swc"
VM_ADMIN=azureuser

FABRIC_PRIMARY="fabric-swc-$SUFFIX"
FABRIC_SECONDARY="fabric-noe-$SUFFIX"
CONTAINER_PRIMARY="pc-swc-$SUFFIX"
CONTAINER_SECONDARY="pc-noe-$SUFFIX"
POLICY_NAME="policy-a2a-$SUFFIX"
MAPPING_PRIMARY_TO_SECONDARY="map-swc-noe-$SUFFIX"
MAPPING_SECONDARY_TO_PRIMARY="map-noe-swc-$SUFFIX"
NETWORK_MAPPING_PRIMARY="netmap-swc-noe-$SUFFIX"
NETWORK_MAPPING_SECONDARY="netmap-noe-swc-$SUFFIX"
PROTECTED_ITEM="pi-$VM_NAME"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az extension add --name site-recovery --allow-preview true

$Suffix = -join ((48..57 + 97..122 | Get-Random -Count 4 | ForEach-Object { [char]$_ }))

$LOCATION_PRIMARY = "swedencentral"
$LOCATION_SECONDARY = "norwayeast"

$RG_PRIMARY = "rg-vm-dr-swc-$Suffix"
$RG_SECONDARY = "rg-vm-dr-noe-$Suffix"

$VM_NAME = "vm-dr-swc-$Suffix"
$VNET_PRIMARY = "vnet-vm-dr-swc-$Suffix"
$VNET_SECONDARY = "vnet-vm-dr-noe-$Suffix"
$SUBNET_PRIMARY = "subnet-app"
$SUBNET_SECONDARY = "subnet-recovery"

$VAULT_NAME = "rsv-vm-dr-$Suffix"
$CACHE_STORAGE = "stcache${Suffix}swc"
$VM_ADMIN = "azureuser"

$FABRIC_PRIMARY = "fabric-swc-$Suffix"
$FABRIC_SECONDARY = "fabric-noe-$Suffix"
$CONTAINER_PRIMARY = "pc-swc-$Suffix"
$CONTAINER_SECONDARY = "pc-noe-$Suffix"
$POLICY_NAME = "policy-a2a-$Suffix"
$MAPPING_PRIMARY_TO_SECONDARY = "map-swc-noe-$Suffix"
$MAPPING_SECONDARY_TO_PRIMARY = "map-noe-swc-$Suffix"
$NETWORK_MAPPING_PRIMARY = "netmap-swc-noe-$Suffix"
$NETWORK_MAPPING_SECONDARY = "netmap-noe-swc-$Suffix"
$PROTECTED_ITEM = "pi-$VM_NAME"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Open **Cloud Shell** or your preferred terminal.
2. If prompted, allow Azure CLI to install the **site-recovery** extension.
3. Choose your two regions. This lab uses **Sweden Central** and **Norway East**.
4. Pick a short unique suffix so the storage account, vault, and VM names do not collide with earlier runs.

  </div>
</div>

## Step 2 — Create the source VM and both virtual networks

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group create --name "$RG_PRIMARY" --location "$LOCATION_PRIMARY"
az group create --name "$RG_SECONDARY" --location "$LOCATION_SECONDARY"

az network vnet create   --resource-group "$RG_PRIMARY"   --name "$VNET_PRIMARY"   --location "$LOCATION_PRIMARY"   --address-prefix 10.10.0.0/16   --subnet-name "$SUBNET_PRIMARY"   --subnet-prefix 10.10.1.0/24

az network vnet create   --resource-group "$RG_SECONDARY"   --name "$VNET_SECONDARY"   --location "$LOCATION_SECONDARY"   --address-prefix 10.20.0.0/16   --subnet-name "$SUBNET_SECONDARY"   --subnet-prefix 10.20.1.0/24

az vm create   --resource-group "$RG_PRIMARY"   --name "$VM_NAME"   --location "$LOCATION_PRIMARY"   --image Ubuntu2204   --size Standard_B2s   --admin-username "$VM_ADMIN"   --generate-ssh-keys   --vnet-name "$VNET_PRIMARY"   --subnet "$SUBNET_PRIMARY"   --public-ip-sku Standard

az vm open-port --resource-group "$RG_PRIMARY" --name "$VM_NAME" --port 80 --priority 1010

az vm run-command invoke   --resource-group "$RG_PRIMARY"   --name "$VM_NAME"   --command-id RunShellScript   --scripts "sudo apt-get update && sudo apt-get install -y nginx && echo 'Primary region: Sweden Central' | sudo tee /var/www/html/index.html"

PRIMARY_VM_PUBLIC_IP=$(az vm list-ip-addresses   --resource-group "$RG_PRIMARY"   --name "$VM_NAME"   --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress"   --output tsv)

curl -s "http://$PRIMARY_VM_PUBLIC_IP"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group create --name $RG_PRIMARY --location $LOCATION_PRIMARY | Out-Null
az group create --name $RG_SECONDARY --location $LOCATION_SECONDARY | Out-Null

az network vnet create `
  --resource-group $RG_PRIMARY `
  --name $VNET_PRIMARY `
  --location $LOCATION_PRIMARY `
  --address-prefix 10.10.0.0/16 `
  --subnet-name $SUBNET_PRIMARY `
  --subnet-prefix 10.10.1.0/24 | Out-Null

az network vnet create `
  --resource-group $RG_SECONDARY `
  --name $VNET_SECONDARY `
  --location $LOCATION_SECONDARY `
  --address-prefix 10.20.0.0/16 `
  --subnet-name $SUBNET_SECONDARY `
  --subnet-prefix 10.20.1.0/24 | Out-Null

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
  --public-ip-sku Standard | Out-Null

az vm open-port --resource-group $RG_PRIMARY --name $VM_NAME --port 80 --priority 1010 | Out-Null

az vm run-command invoke `
  --resource-group $RG_PRIMARY `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts "sudo apt-get update && sudo apt-get install -y nginx && echo 'Primary region: Sweden Central' | sudo tee /var/www/html/index.html" | Out-Null

$PRIMARY_VM_PUBLIC_IP = az vm list-ip-addresses `
  --resource-group $RG_PRIMARY `
  --name $VM_NAME `
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" `
  --output tsv

(Invoke-WebRequest -Uri "http://$PRIMARY_VM_PUBLIC_IP" -UseBasicParsing).Content
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Create two resource groups: one in **Sweden Central** and one in **Norway East**.
2. In each group, create a VNet with one subnet.
3. In the primary resource group, create a Linux VM.
4. Open port **80** and install a simple web page so you can recognize the source workload before failover.
5. Browse to the VM's public IP and verify you see a Sweden Central response.

  </div>
</div>

## Step 3 — Create the Recovery Services vault and staging storage

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az backup vault create   --resource-group "$RG_PRIMARY"   --name "$VAULT_NAME"   --location "$LOCATION_PRIMARY"

az storage account create   --resource-group "$RG_PRIMARY"   --name "$CACHE_STORAGE"   --location "$LOCATION_PRIMARY"   --sku Standard_LRS   --kind StorageV2

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

1. In the primary region, create a **Recovery Services vault**.
2. Create a standard storage account in the primary region to act as the Site Recovery staging/cache account.
3. Capture the VM ID, managed-disk ID, VNet IDs, and resource-group IDs. You will reuse them in the replication payload later in the lab.

  </div>
</div>

## Step 4 — Create Site Recovery fabrics, containers, and the A2A policy

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az site-recovery fabric create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --name "$FABRIC_PRIMARY"   --custom-details "{azure:{location:$LOCATION_PRIMARY}}"

az site-recovery fabric create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --name "$FABRIC_SECONDARY"   --custom-details "{azure:{location:$LOCATION_SECONDARY}}"

az site-recovery protection-container create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_PRIMARY"   --name "$CONTAINER_PRIMARY"   --provider-input '[{instance-type:A2A}]'

az site-recovery protection-container create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_SECONDARY"   --name "$CONTAINER_SECONDARY"   --provider-input '[{instance-type:A2A}]'

az site-recovery policy create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --name "$POLICY_NAME"   --provider-specific-input '{a2a:{multi-vm-sync-status:Enable}}'

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
5. Note the resulting policy and container identifiers for the next step.

  </div>
</div>

## Step 5 — Create container mappings and network mappings

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
PRIMARY_ASR_NETWORK=$(az site-recovery network list   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_PRIMARY"   --query "[0].name"   --output tsv)

SECONDARY_ASR_NETWORK=$(az site-recovery network list   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_SECONDARY"   --query "[0].name"   --output tsv)

az site-recovery protection-container mapping create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_PRIMARY"   --protection-container "$CONTAINER_PRIMARY"   --name "$MAPPING_PRIMARY_TO_SECONDARY"   --policy-id "$POLICY_ID"   --provider-input '{a2a:{agent-auto-update-status:Disabled}}'   --target-container "$CONTAINER_SECONDARY_ID"

az site-recovery protection-container mapping create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_SECONDARY"   --protection-container "$CONTAINER_SECONDARY"   --name "$MAPPING_SECONDARY_TO_PRIMARY"   --policy-id "$POLICY_ID"   --provider-input '{a2a:{agent-auto-update-status:Disabled}}'   --target-container "$CONTAINER_PRIMARY_ID"

az site-recovery network mapping create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_PRIMARY"   --network-name "$PRIMARY_ASR_NETWORK"   --name "$NETWORK_MAPPING_PRIMARY"   --recovery-fabric-name "$FABRIC_SECONDARY"   --recovery-network-id "$VNET_SECONDARY_ID"   --fabric-details "{azure-to-azure:{primary-network-id:$VNET_PRIMARY_ID}}"

az site-recovery network mapping create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_SECONDARY"   --network-name "$SECONDARY_ASR_NETWORK"   --name "$NETWORK_MAPPING_SECONDARY"   --recovery-fabric-name "$FABRIC_PRIMARY"   --recovery-network-id "$VNET_PRIMARY_ID"   --fabric-details "{azure-to-azure:{primary-network-id:$VNET_SECONDARY_ID}}"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$PRIMARY_ASR_NETWORK = az site-recovery network list `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_PRIMARY `
  --query "[0].name" `
  --output tsv

$SECONDARY_ASR_NETWORK = az site-recovery network list `
  --resource-group $RG_PRIMARY `
  --vault-name $VAULT_NAME `
  --fabric-name $FABRIC_SECONDARY `
  --query "[0].name" `
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

1. In the vault, pair the primary and secondary protection containers.
2. Pair the Sweden Central VNet to the Norway East VNet.
3. Create the reverse network mapping as well so failback has a prepared path.
4. If the CLI returns an empty network list, wait a minute for discovery and re-run the command.

  </div>
</div>

## Step 6 — Enable replication for the VM

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

az site-recovery protected-item create   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_PRIMARY"   --protection-container "$CONTAINER_PRIMARY"   --name "$PROTECTED_ITEM"   --policy-id "$POLICY_ID"   --provider-details "$A2A_PROVIDER_DETAILS"
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

1. Open the source VM in the portal.
2. In **Operations**, choose **Disaster recovery**.
3. Select the target region, target resource group, target VNet, and staging storage account.
4. Start replication and wait for the protection state to move from initialization into healthy replication.

  </div>
</div>

## Step 7 — Wait for healthy replication and inspect the protected item

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
while true; do
  STATE=$(az site-recovery protected-item show     --resource-group "$RG_PRIMARY"     --vault-name "$VAULT_NAME"     --fabric-name "$FABRIC_PRIMARY"     --protection-container "$CONTAINER_PRIMARY"     --name "$PROTECTED_ITEM"     --query "properties.protectionState"     --output tsv)

  echo "Protection state: $STATE"
  [[ "$STATE" == "Protected" ]] && break
  sleep 30
done

az site-recovery protected-item show   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_PRIMARY"   --protection-container "$CONTAINER_PRIMARY"   --name "$PROTECTED_ITEM"   --query "{State:properties.protectionState,Health:properties.replicationHealth,ActiveLocation:properties.activeLocation}"   --output table
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

1. In the source VM's **Disaster recovery** blade, wait until **Replication health** is healthy.
2. Review the replication state, target region, and last synchronization timestamp.
3. Do not start failover until the VM shows healthy protection and recovery-point generation has started.

  </div>
</div>

## Step 8 — Run a failover drill to Norway East

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az site-recovery protected-item unplanned-failover   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_PRIMARY"   --protection-container "$CONTAINER_PRIMARY"   --name "$PROTECTED_ITEM"   --failover-direction PrimaryToRecovery   --provider-details '{a2a:{}}'   --source-site-operations NotRequired

while true; do
  ACTIVE_LOCATION=$(az site-recovery protected-item show     --resource-group "$RG_PRIMARY"     --vault-name "$VAULT_NAME"     --fabric-name "$FABRIC_PRIMARY"     --protection-container "$CONTAINER_PRIMARY"     --name "$PROTECTED_ITEM"     --query "properties.activeLocation"     --output tsv)

  echo "Active location: $ACTIVE_LOCATION"
  [[ "$ACTIVE_LOCATION" == "Recovery" ]] && break
  sleep 30
done

az site-recovery protected-item failover-commit   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_PRIMARY"   --protection-container "$CONTAINER_PRIMARY"   --name "$PROTECTED_ITEM"

RECOVERY_VM=$(az vm list --resource-group "$RG_SECONDARY" --query "[0].name" --output tsv)
az vm list -d --resource-group "$RG_SECONDARY" --output table
az vm run-command invoke --resource-group "$RG_SECONDARY" --name "$RECOVERY_VM" --command-id RunShellScript --scripts "hostname && curl -s http://localhost"
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

$RECOVERY_VM = az vm list --resource-group $RG_SECONDARY --query "[0].name" --output tsv
az vm list -d --resource-group $RG_SECONDARY --output table
az vm run-command invoke --resource-group $RG_SECONDARY --name $RECOVERY_VM --command-id RunShellScript --scripts "hostname && curl -s http://localhost"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. On the protected VM, choose **Failover** from the **Disaster recovery** blade.
2. Select the latest recovery point and start the failover drill to **Norway East**.
3. After the recovery VM boots successfully, choose **Commit**.
4. Open the recovered VM or run a command inside it to confirm you now see the application from the recovery region.

  </div>
</div>

## Step 9 — Prepare the reverse-protection path for failback (optional)

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
RECOVERY_VM=$(az vm list --resource-group "$RG_SECONDARY" --query "[0].name" --output tsv)
RECOVERY_VM_OS_DISK_ID=$(az vm show --resource-group "$RG_SECONDARY" --name "$RECOVERY_VM" --query storageProfile.osDisk.managedDisk.id --output tsv)

SWITCH_PROVIDER_DETAILS=$(cat <<EOF
{a2a:{policy-id:$POLICY_ID,recovery-container-id:$CONTAINER_PRIMARY_ID,recovery-resource-group-id:$RG_PRIMARY_ID,vm-managed-disks:[{disk-id:$RECOVERY_VM_OS_DISK_ID,primary-staging-azure-storage-account-id:$CACHE_STORAGE_ID,recovery-resource-group-id:$RG_PRIMARY_ID}]}}
EOF
)

az site-recovery protection-container switch-protection   --resource-group "$RG_PRIMARY"   --vault-name "$VAULT_NAME"   --fabric-name "$FABRIC_SECONDARY"   --protection-container-name "$CONTAINER_SECONDARY"   --protected-item "$PROTECTED_ITEM"   --provider-details "$SWITCH_PROVIDER_DETAILS"
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
$RECOVERY_VM = az vm list --resource-group $RG_SECONDARY --query "[0].name" --output tsv
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

1. In the portal, open the failed-over VM's **Disaster recovery** blade.
2. Choose **Re-protect** so replication starts in the reverse direction.
3. After reverse protection completes, run a planned failback during a maintenance window.
4. Use this step if you want to practice a full return to the original region; otherwise you can go straight to cleanup.

  </div>
</div>

## Step 10 — Cleanup

If the vault blocks deletion because a failover or reprotect job is still in progress, finish or cancel the workflow in the **Disaster recovery** blade first and then delete both resource groups.

<div class="lab-tabs">
  <div class="lab-tabs__list" role="tablist" aria-label="Choose instruction path">
    <button class="lab-tabs__button is-active" data-tab="bash" aria-selected="true">Bash</button>
    <button class="lab-tabs__button" data-tab="powershell" aria-selected="false">PowerShell</button>
    <button class="lab-tabs__button" data-tab="portal" aria-selected="false">Portal</button>
  </div>

  <div class="lab-tabs__panel is-active" data-tab-panel="bash" markdown="1">

```bash
az group delete --name "$RG_PRIMARY" --yes --no-wait
az group delete --name "$RG_SECONDARY" --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="powershell" markdown="1">

```powershell
az group delete --name $RG_PRIMARY --yes --no-wait
az group delete --name $RG_SECONDARY --yes --no-wait
```

  </div>

  <div class="lab-tabs__panel" data-tab-panel="portal" markdown="1">

1. Disable replication if it is still enabled.
2. Delete both resource groups.
3. Wait for the Recovery Services vault and the recovered VM to disappear before reusing the names.

  </div>
</div>
---

## Key Takeaways

1. **Azure Site Recovery is orchestration, not magic.** The vault, policy, container mappings, network mappings, and protected item all have to align.
2. **Recovery networking matters as much as recovery compute.** Pre-creating the target VNet and subnet makes failover predictable.
3. **Failback needs preparation.** Reverse protection is a separate workflow; don't assume it is implicit.
4. **Portal remains the smoothest experience.** The CLI is powerful but still preview for several Site Recovery flows.

---

## Further Reading

- [Azure-to-Azure disaster recovery quickstart](https://learn.microsoft.com/azure/site-recovery/azure-to-azure-quickstart)
- [Azure Site Recovery overview](https://learn.microsoft.com/azure/site-recovery/site-recovery-overview)
- [Azure CLI — Site Recovery protected items](https://learn.microsoft.com/cli/azure/site-recovery/protected-item)
- [Azure CLI — Site Recovery protection container mappings](https://learn.microsoft.com/cli/azure/site-recovery/protection-container/mapping)
- [Business continuity for Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/disaster-recovery-guidance)

---

**Lab 6-a — Standalone Site Recovery** | [Lab 6-b — Secure spoke & Bastion →](lab-06b-vm-site-recovery-secure-spoke.md)
