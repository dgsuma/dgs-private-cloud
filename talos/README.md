# Talos Configuration

## Current state

- Cluster name: `dgs-homelab`
- Talos version: `v1.13.6`
- Kubernetes version: `v1.36.2`
- Control-plane VM: `talos-cp-01` / VM `210` / `192.168.1.210`
- Worker VM: `talos-worker-01` / VM `211` / `192.168.1.211`
- Worker VM: `talos-worker-02` / VM `212` / `192.168.1.212`
- Kubernetes: bootstrapped and healthy
- Nodes: all three `Ready`
- First etcd snapshot: complete and stored outside the repository

## Image Factory record

- Schematic ID: `ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515`
- Selected extension: `siderolabs/qemu-guest-agent`
- ISO: Talos `v1.13.6`, amd64, metal

The selected bootstrap ISO included the QEMU guest-agent extension. Verify the installed extension list before relying on guest-agent functionality because the installed image must use the same Image Factory schematic to retain extensions.

## Directory policy

```text
talos/
├── README.md
├── image-factory-schematic.yaml
├── generated/   # ignored; contains credentials and generated configs
└── patches/     # reviewed non-secret configuration patches
```

Files under `generated/` must never be committed.

This includes:

- base and node-specific control-plane configurations,
- base and node-specific worker configurations,
- `talosconfig`,
- kubeconfig,
- generated secrets,
- temporary decrypted outputs.

## Hostname patch format

Talos `v1.13.6` node-specific hostnames use a `HostnameConfig` document:

```yaml
apiVersion: v1alpha1
kind: HostnameConfig
hostname: talos-worker-01
auto: off
```

The legacy `machine.network.hostname` patch caused validation conflicts and must not be used for this configuration.

## Routine checks

```powershell
$CP = "192.168.1.210"
$W1 = "192.168.1.211"
$W2 = "192.168.1.212"

$env:TALOSCONFIG = (Resolve-Path ".\talos\generated\talosconfig").Path

talosctl health `
  --control-plane-nodes $CP `
  --worker-nodes "$W1,$W2" `
  --endpoints $CP

talosctl get members --nodes $CP --endpoints $CP
```

## Backup

Use `scripts/workstation/New-TalosEtcdSnapshot.ps1` and keep snapshots outside the repository and cluster.
