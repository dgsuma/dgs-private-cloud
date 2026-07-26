# Operations

## Active administration endpoints

Use only the private LAN or an approved authenticated private-access path.

```text
Proxmox pve01:       https://192.168.1.201:8006
Talos API endpoint:  192.168.1.210:50000
Kubernetes API:      https://192.168.1.210:6443
```

Do not expose these services through router port forwarding.

## Start a workstation administration session

From the repository root:

```powershell
$CP = "192.168.1.210"
$W1 = "192.168.1.211"
$W2 = "192.168.1.212"

$env:TALOSCONFIG = (Resolve-Path ".\talos\generated\talosconfig").Path
$env:KUBECONFIG = (Resolve-Path ".\talos\generated\kubeconfig").Path

talosctl version --nodes $CP --endpoints $CP
kubectl cluster-info
```

The environment variables apply only to the current PowerShell process. A new terminal must set them again, or each `talosctl` command must use `--talosconfig` explicitly.

## Routine cluster checks

```powershell
talosctl health `
  --control-plane-nodes $CP `
  --worker-nodes "$W1,$W2" `
  --endpoints $CP

kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get events -A --sort-by=.lastTimestamp
```

Check Talos membership:

```powershell
talosctl get members --nodes $CP --endpoints $CP
```

## Proxmox VM operations

List and inspect VMs from the Proxmox shell:

```bash
qm list
qm config 210
qm config 211
qm config 212
```

Active mapping:

```text
210  talos-cp-01
211  talos-worker-01
212  talos-worker-02
```

Prefer graceful shutdown from Proxmox. For a planned full-cluster stop, shut down the workers first and the control plane last. For startup, start the control plane first and then both workers.

Use forced `qm stop` only if graceful shutdown cannot complete.

## Boot and media state

All three VMs must retain:

```text
Boot order: scsi0, ide2, net0
CD/DVD drive: no media
```

The Talos installation ISO can remain in Proxmox ISO storage for future recovery or node builds, but it must not remain mounted in the running cluster VMs.

## etcd snapshot

Use the reusable script:

```powershell
.\scripts\workstation\New-TalosEtcdSnapshot.ps1 `
  -ControlPlane 192.168.1.210 `
  -BackupFolder "E:\home-server-backups\etcd"
```

The script:

- verifies `talosconfig`,
- writes a timestamped snapshot,
- checks the `talosctl` exit code,
- creates a SHA-256 sidecar file,
- prints the final file metadata.

See [Talos etcd snapshot runbook](runbooks/talos-etcd-snapshot.md).

## Proxmox backup state

Proxmox VM backups are not yet configured. Do not rely on:

- a snapshot on the same `vmdata` pool,
- a backup archive stored only on the Beelink,
- the etcd snapshot as a replacement for VM or application-data backups.

The preferred next step is an external disk, NAS, or Proxmox Backup Server destination followed by a restore test.

## UPS state

The Eaton UPS actively protects:

- the TP-Link Archer NX200,
- the Beelink `pve01`.

UPS telemetry and automatic extended-outage shutdown are not configured.

## Routine Proxmox health check

```bash
pveversion -v
systemctl --failed
pvesm status
qm list
ip -br address
ip route
hostname -f
timedatectl
```

## Storage thresholds

Investigate before:

- LVM-thin data usage approaches 80%,
- LVM-thin metadata usage approaches 70%,
- a root filesystem approaches 80%,
- SMART/NVMe reports media errors or critical warnings,
- backup space becomes insufficient.

## Secret safety

Generated Talos configurations contain cluster certificates and keys. Keep them under `talos/generated/`, which is ignored by Git.

Do not paste or commit:

- Talos machine configurations,
- kubeconfig,
- `talosconfig`,
- etcd snapshots,
- SOPS age private keys,
- GitHub tokens,
- Tailscale credentials.
