# Runbook: Talos Workers and Kubernetes Bootstrap

## Scope

Continue from this verified state:

```text
pve01: active standalone Proxmox host
VM 210 talos-cp-01: maintenance mode at 192.168.1.210
Control-plane installation disk: /dev/sda
Kubernetes: not bootstrapped
```

## Safety rules

- Keep generated Talos configurations under `talos/generated/`.
- Do not commit generated machine configurations.
- Do not commit `talosconfig` or kubeconfig.
- Confirm every disk device before applying configuration.
- Run `talosctl bootstrap` exactly once.
- Do not configure the reserved `.220` VIP yet.
- Use standard `VirtIO SCSI`, not `VirtIO SCSI Single`.

## Worker 1 specification

```text
VM ID: 211
Name: talos-wk-01
Address: 192.168.1.211
CPU: host, 1 socket, 6 cores
Memory: 14336 MiB
System disk: 64 GiB on vmdata
Data disk: 300 GiB on vmdata
```

## Worker 2 specification

```text
VM ID: 212
Name: talos-wk-02
Address: 192.168.1.212
CPU: host, 1 socket, 6 cores
Memory: 14336 MiB
System disk: 64 GiB on vmdata
Data disk: 300 GiB on vmdata
```

## Common Proxmox configuration

```text
Machine: q35
BIOS: OVMF
EFI storage: vmdata
Pre-enrolled keys: disabled
QEMU Guest Agent: enabled
SCSI controller: VirtIO SCSI
Ballooning: disabled
Network model: VirtIO
Bridge: vmbr0
VLAN: none
Firewall: disabled initially
ISO: talos-v1.13.6-qemu-agent-amd64.iso
Discard: enabled on both disks
SSD emulation: enabled on both disks
```

## Create each worker

Create the VM without selecting **Start after created**.

After creation:

1. Record its generated MAC address locally.
2. Add its DHCP reservation to the Archer NX200.
3. Put the ISO first in the temporary boot order:

   ```bash
   qm set 211 --boot 'order=ide2;scsi0;net0'
   qm set 212 --boot 'order=ide2;scsi0;net0'
   ```

4. Verify:

   ```bash
   qm config 211
   qm config 212
   ```

5. Start both VMs.

## Maintenance-mode validation

From the LG Gram:

```powershell
Test-Connection 192.168.1.211 -Count 4
Test-NetConnection 192.168.1.211 -Port 50000
talosctl get disks --insecure --nodes 192.168.1.211

Test-Connection 192.168.1.212 -Count 4
Test-NetConnection 192.168.1.212 -Port 50000
talosctl get disks --insecure --nodes 192.168.1.212
```

Record the exact system and data disk names.

Expected pattern only:

```text
system disk: writable, approximately 69 GB
data disk: writable, approximately 322 GB
ISO: read-only, approximately 338 MB
```

Do not proceed if the device identities are ambiguous.

## Generate Talos configuration

From the repository root:

```powershell
$ControlPlane = "192.168.1.210"
$Worker1 = "192.168.1.211"
$Worker2 = "192.168.1.212"
$ClusterName = "dgs-home"
$Generated = ".\talos\generated"

New-Item -ItemType Directory -Force $Generated | Out-Null
```

Generate configuration only after confirming the install disk:

```powershell
talosctl gen config `
  $ClusterName `
  "https://${ControlPlane}:6443" `
  --output-dir $Generated `
  --install-disk /dev/sda `
  --install-image "factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.13.6"
```

Inspect the generated files locally. Do not stage them with Git.

## Apply configuration

Apply the control-plane configuration:

```powershell
talosctl apply-config `
  --insecure `
  --nodes $ControlPlane `
  --file "$Generated\controlplane.yaml"
```

Apply worker configurations:

```powershell
talosctl apply-config `
  --insecure `
  --nodes $Worker1 `
  --file "$Generated\worker.yaml"

talosctl apply-config `
  --insecure `
  --nodes $Worker2 `
  --file "$Generated\worker.yaml"
```

Wait for installation and reboot.

## Configure talosctl

```powershell
$env:TALOSCONFIG = (Resolve-Path "$Generated\talosconfig").Path

talosctl config endpoint $ControlPlane
talosctl config node $ControlPlane
```

## Bootstrap once

```powershell
talosctl bootstrap --nodes $ControlPlane
```

Do not run bootstrap a second time.

## Retrieve kubeconfig

```powershell
talosctl kubeconfig "$Generated\kubeconfig" --nodes $ControlPlane
$env:KUBECONFIG = (Resolve-Path "$Generated\kubeconfig").Path
```

## Validate

```powershell
talosctl health
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

Success requires all three nodes to report `Ready`.

## After successful installation

Change each VM to boot from disk first and detach the ISO when safe:

```bash
qm set 210 --boot 'order=scsi0;net0'
qm set 211 --boot 'order=scsi0;net0'
qm set 212 --boot 'order=scsi0;net0'
```

Confirm each VM restarts from its installed system disk before removing ISO attachments.
