# Talos Configuration

## Current state

- Talos version: `v1.13.6`
- Kubernetes version: `v1.36.2`
- Cluster name: `dgs-homelab`
- Control plane: `talos-cp-01` / VM `210` / `192.168.1.210`
- Workers: VM `211` and VM `212`
- All nodes: `Ready`
- etcd: healthy single control-plane member
- Off-cluster snapshots: two recorded generations with SHA-256 files
- Proxmox VM backup baseline: complete for all three VMs

## Directory policy

```text
talos/
├── README.md
├── image-factory-schematic.yaml
├── generated/   # ignored; contains credentials
└── patches/     # commit only reviewed non-secret patches
```

Files under `generated/` must never be committed. This includes:

- `controlplane.yaml`,
- `worker.yaml`,
- node-specific generated configurations,
- `talosconfig`,
- kubeconfig,
- generated cluster secrets.

## Snapshot policy

Talos etcd snapshots are written outside the repository under the administrator workstation backup path. Each snapshot receives a SHA-256 companion file. Neither snapshot data nor checksums are committed.

Use:

```powershell
.\scripts\workstation\New-TalosEtcdSnapshot.ps1 `
  -ControlPlane "192.168.1.210" `
  -WorkerNodes "192.168.1.211","192.168.1.212" `
  -BackupFolder "E:\home-server-backups\etcd" `
  -TalosConfig ".\talos\generated\talosconfig"
```
