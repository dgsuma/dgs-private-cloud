# Runbook: Talos Workers and Kubernetes Bootstrap

## Purpose

Reproduce the implemented single-host Talos cluster:

```text
pve01 / Proxmox VE
VM 210 talos-cp-01       192.168.1.210
VM 211 talos-worker-01   192.168.1.211
VM 212 talos-worker-02   192.168.1.212
```

## Safety rules

- Keep generated Talos configurations under `talos/generated/`.
- Never commit machine configurations, `talosconfig`, kubeconfig, or etcd snapshots.
- Confirm `/dev/sda` independently on every VM before applying configuration.
- Run `talosctl bootstrap` exactly once.
- Do not bootstrap a worker.
- Keep the Proxmox, Talos, and Kubernetes management interfaces private.
- Do not use the future `.220` virtual IP in this single-control-plane build.

## VM specification

Use this configuration for all three nodes unless a deliberate resource change is documented:

```text
Machine: q35
BIOS: OVMF
CPU type: host
Sockets: 1
Cores: 4
Memory: 8192 MiB
Ballooning: disabled
SCSI controller: VirtIO SCSI
System disk: 64 GiB on vmdata
Discard: enabled
SSD emulation: enabled
Network model: VirtIO
Bridge: vmbr0
VLAN: none
Firewall: disabled during initial build
```

## Clone the workers

1. Shut down VM `210`.
2. Clone VM `210` to:

```text
VM 211: talos-worker-01
VM 212: talos-worker-02
Target node: pve01
Target storage: vmdata
```

A regular Proxmox VM clone does not show the Full Clone / Linked Clone mode selector that appears for templates. Verify that each clone owns its own virtual disk and has a unique MAC address.

## Configure boot order

For VMs `210`, `211`, and `212`:

```text
1. scsi0
2. ide2
3. net0
```

Keep the Talos ISO mounted during installation. A blank `scsi0` falls through to the ISO; after installation, the disk becomes bootable and remains first.

## Reserve addresses

Create router DHCP reservations:

```text
talos-cp-01       192.168.1.210
talos-worker-01   192.168.1.211
talos-worker-02   192.168.1.212
```

## Maintenance-mode validation

```powershell
$CP = "192.168.1.210"
$W1 = "192.168.1.211"
$W2 = "192.168.1.212"

Test-Connection $CP -Count 2
Test-Connection $W1 -Count 2
Test-Connection $W2 -Count 2

talosctl version --nodes $CP --insecure
talosctl version --nodes $W1 --insecure
talosctl version --nodes $W2 --insecure

talosctl get disks --nodes $CP --insecure
talosctl get disks --nodes $W1 --insecure
talosctl get disks --nodes $W2 --insecure
```

Proceed only if every node shows a writable `/dev/sda` of the expected size and `sr0` is the read-only installer media.

## Generate base configuration

From the repository root:

```powershell
$Generated = ".\talos\generated"
New-Item -ItemType Directory -Force -Path $Generated | Out-Null

talosctl gen config `
  dgs-homelab `
  "https://192.168.1.210:6443" `
  --install-disk /dev/sda `
  --output-dir $Generated `
  --force
```

For a future rebuild that must retain a custom Image Factory extension, explicitly configure the matching schematic installer image in the generated machine configuration or with the supported `gen config` installer-image option.

## Create hostname patches

Control plane:

```yaml
apiVersion: v1alpha1
kind: HostnameConfig
hostname: talos-cp-01
auto: off
```

Worker 1:

```yaml
apiVersion: v1alpha1
kind: HostnameConfig
hostname: talos-worker-01
auto: off
```

Worker 2:

```yaml
apiVersion: v1alpha1
kind: HostnameConfig
hostname: talos-worker-02
auto: off
```

Do not use `machine.network.hostname` with this Talos configuration version.

## Generate node-specific files

```powershell
talosctl machineconfig patch `
  "$Generated\controlplane.yaml" `
  --patch "@$Generated\cp-hostname.patch.yaml" `
  --output "$Generated\controlplane-210.yaml"

talosctl machineconfig patch `
  "$Generated\worker.yaml" `
  --patch "@$Generated\worker-01-hostname.patch.yaml" `
  --output "$Generated\worker-211.yaml"

talosctl machineconfig patch `
  "$Generated\worker.yaml" `
  --patch "@$Generated\worker-02-hostname.patch.yaml" `
  --output "$Generated\worker-212.yaml"
```

## Validate configurations

```powershell
talosctl validate --config "$Generated\controlplane-210.yaml" --mode metal
talosctl validate --config "$Generated\worker-211.yaml" --mode metal
talosctl validate --config "$Generated\worker-212.yaml" --mode metal
```

All commands must succeed before applying any configuration.

## Apply configurations

```powershell
talosctl apply-config `
  --insecure `
  --nodes $CP `
  --file "$Generated\controlplane-210.yaml"

talosctl apply-config `
  --insecure `
  --nodes $W1 `
  --file "$Generated\worker-211.yaml"

talosctl apply-config `
  --insecure `
  --nodes $W2 `
  --file "$Generated\worker-212.yaml"
```

Before bootstrap, `Ready: False` is expected even when the stage is `Running` and kubelet is healthy.

## Configure authenticated access

```powershell
$env:TALOSCONFIG = (Resolve-Path "$Generated\talosconfig").Path

talosctl config endpoint $CP
talosctl config node $CP
talosctl version --nodes $CP --endpoints $CP
```

## Bootstrap exactly once

```powershell
talosctl bootstrap --nodes $CP --endpoints $CP
```

Do not repeat the command and do not target a worker.

## Retrieve kubeconfig

```powershell
talosctl kubeconfig "$Generated\kubeconfig" `
  --nodes $CP `
  --endpoints $CP `
  --force

$env:KUBECONFIG = (Resolve-Path "$Generated\kubeconfig").Path
```

## Validate cluster health

```powershell
talosctl health `
  --control-plane-nodes $CP `
  --worker-nodes "$W1,$W2" `
  --endpoints $CP

kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A -o wide

talosctl get members --nodes $CP --endpoints $CP
```

Success requires all three Kubernetes nodes to report `Ready`.

## Workload scheduling test

```powershell
kubectl create deployment nginx-test --image=nginx:stable-alpine
kubectl scale deployment nginx-test --replicas=4
kubectl get pods -o wide -w
```

Confirm that pods run on both workers, then remove the test:

```powershell
kubectl delete deployment nginx-test
```

## Detach the ISO

After all nodes boot successfully from their installed disks:

```text
VM -> Hardware -> CD/DVD Drive -> Edit -> Do not use any media
```

Perform this on VMs `210`, `211`, and `212`.

Keep the boot order:

```text
scsi0, ide2, net0
```

## Create the first etcd snapshot

Follow [Talos etcd snapshot](talos-etcd-snapshot.md) and store the file outside the repository and cluster.
