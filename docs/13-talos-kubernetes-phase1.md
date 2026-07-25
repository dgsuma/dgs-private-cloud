# Talos Kubernetes Phase 1

## Session date

2026-07-25

## Objective

Begin Phase 1 of the Home Lab IoT Blueprint:

1. Create Talos control-plane and worker VMs.
2. Install Kubernetes.
3. Bootstrap Flux.
4. Deploy Tailscale Operator.
5. Deploy Prometheus, Grafana, Alertmanager, and Loki.
6. Deploy Homepage.

This session completed the workstation, image, and first-control-plane prerequisites. Kubernetes was not bootstrapped.

## Repository decision

The existing repository remains the infrastructure and GitOps monorepo:

```text
E:\home-server\dgs-private-cloud
```

A separate repository is not required for the platform configuration.

Application source repositories may remain separate later, while their deployment manifests can be reconciled from this repository.

## Workstation tooling

| Tool | Version |
|---|---:|
| PowerShell | `7.6.3` |
| Git | `2.46.2` |
| GitHub CLI | `2.96.0` |
| kubectl | `1.36.3` |
| Kustomize | `5.8.1` |
| talosctl | `1.13.6` |
| Flux CLI | `2.9.3` |
| SOPS | `3.13.2` |
| age | `1.3.1` |

### kubectl PATH correction

Docker Desktop exposed an older kubectl executable first in PATH.

A PowerShell profile function was added to select the current WinGet-managed executable dynamically.

Verified state:

```text
CommandType: Function
Client Version: v1.36.3
Kustomize Version: v5.8.1
```

## Repository preparation

The following structure was prepared:

```text
clusters/home/
talos/generated/
talos/patches/
kubernetes/infrastructure/storage/local-path/
kubernetes/infrastructure/tailscale-operator/
kubernetes/infrastructure/monitoring/
kubernetes/infrastructure/logging/
kubernetes/apps/homepage/
scripts/proxmox/
scripts/workstation/
docs/decisions/
docs/runbooks/
```

Talos-generated credentials, kubeconfig, talosconfig, age private keys, and decrypted secret files are ignored.

## Obsolete VM removal

VM `100` was deleted because its validation purpose was complete.

Verification showed:

```text
qm list: VM 100 absent
pvesm list vmdata: no vm-100 volumes
vmdata: active
```

## Image Factory selection

```text
Talos version: v1.13.6
Hardware type: bare-metal/generic virtual machine
Architecture: amd64
Secure Boot: disabled
System extension: siderolabs/qemu-guest-agent
Bootloader: auto
```

Schematic:

```yaml
customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/qemu-guest-agent
```

Schematic ID:

```text
ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515
```

ISO:

```text
https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.13.6/metal-amd64.iso
```

Installer:

```text
factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.13.6
```

The installer image must use the same schematic as the ISO so the installed system retains the selected extension.

## ISO transfer check

The ISO was renamed:

```text
talos-v1.13.6-qemu-agent-amd64.iso
```

SHA-256:

```text
5e3d395a6f55b5394e91ad3d31639e3df02b2a0907e6034f82797de98145eeb7
```

The same hash was calculated on the LG Gram and after upload to `pve01`.

This proves upload integrity. The community Image Factory did not provide a publisher checksum.

## Control-plane VM

| Setting | Value |
|---|---|
| VM ID | `210` |
| Name | `talos-cp-01` |
| Machine | `q35` |
| BIOS | OVMF |
| EFI storage | `vmdata` |
| Secure Boot keys | Not pre-enrolled |
| CPU | `host`, 4 cores |
| Memory | 8192 MiB |
| Ballooning | Disabled |
| SCSI controller | VirtIO SCSI |
| QEMU Agent option | Enabled |
| Disk | SCSI0, 64 GiB, `vmdata` |
| Discard | Enabled |
| SSD emulation | Enabled |
| Network | VirtIO on `vmbr0` |
| Address | `192.168.1.210` |

Sanitised configuration:

```text
agent: 1
balloon: 0
bios: ovmf
boot: order=ide2;scsi0;net0
cores: 4
cpu: host
machine: q35
memory: 8192
name: talos-cp-01
net0: virtio=<recorded-privately>,bridge=vmbr0
ostype: l26
scsi0: vmdata:vm-210-disk-1,discard=on,size=64G,ssd=1
scsihw: virtio-scsi-pci
sockets: 1
```

## Maintenance-mode validation

Talos console:

```text
Talos: v1.13.6
Stage: Maintenance
Ready: True
IP: 192.168.1.210/24
Gateway: 192.168.1.1
Connectivity: OK
```

From `pve01`:

```text
4 transmitted
4 received
0% packet loss
```

From the LG Gram:

```text
ICMP: success
TCP 50000: success
```

Disk discovery:

```text
sda  approximately 69 GB  writable  virtio  QEMU HARDDISK
sr0 approximately 338 MB read-only sata    QEMU DVD-ROM
```

Installation target:

```text
/dev/sda
```

## End-of-session state

```text
VM 210: created
Talos control plane: maintenance mode
Worker VMs: not created
Talos configuration: not applied
Kubernetes: not bootstrapped
Flux: not bootstrapped
```

## Next checkpoint

Follow [the worker and bootstrap runbook](runbooks/talos-phase1-workers-and-bootstrap.md).
