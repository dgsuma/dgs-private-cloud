# Current State

Verified on **2026-08-01** after completing the first full Proxmox VM-backup generation, creating the second Talos etcd snapshot, restarting the cluster, and safely unmounting the external backup HDD.

## Proxmox platform

| Property | Value |
|---|---|
| Active node | `pve01` |
| Platform | Beelink GTi12 |
| FQDN | `pve01.home.arpa` |
| Management address | `192.168.1.201/24` |
| Management URL | `https://192.168.1.201:8006` |
| PVE Manager | `9.2.6` observed in the web interface |
| Cluster membership | Standalone |
| Primary VM storage | `vmdata` |
| Active VM count | 3 |
| Active container count | 0 |
| UPS hardware protection | Active |
| UPS telemetry | Not configured |

## Active VMs

| VM ID | Name | Role | Address | vCPU | RAM | Disk | State |
|---:|---|---|---|---:|---:|---:|---|
| 210 | `talos-cp-01` | Control plane and etcd | `192.168.1.210` | 4 | 8 GiB | 64 GiB | Running / Ready |
| 211 | `talos-worker-01` | Worker | `192.168.1.211` | 4 | 8 GiB | 64 GiB | Running / Ready |
| 212 | `talos-worker-02` | Worker | `192.168.1.212` | 4 | 8 GiB | 64 GiB | Running / Ready |

All disks are on `vmdata`. Networking is VirtIO on `vmbr0`. Boot order is `scsi0`, `ide2`, `net0`. The Talos ISO is detached.

## Kubernetes platform

| Property | Value |
|---|---|
| Cluster name | `dgs-homelab` |
| Talos | `v1.13.6` |
| Kubernetes | `v1.36.2` |
| Kernel | `6.18.38-talos` |
| Runtime | containerd `2.2.5` |
| CNI | Flannel |
| API endpoint | `https://192.168.1.210:6443` |
| Control planes | 1 |
| Workers | 2 |
| All nodes Ready | Yes |
| etcd | Healthy single member |
| Physically highly available | No; all VMs run on `pve01` |

System workloads verified running include CoreDNS, kube-apiserver, kube-controller-manager, kube-scheduler, kube-proxy, and Flannel.

## Recovery baseline

### Talos etcd

Two off-cluster snapshots are stored on the LG Gram under `E:\home-server-backups\etcd`:

```text
dgs-homelab-etcd-2026-07-26_192642.snapshot
dgs-homelab-etcd-2026-08-01_090643.snapshot
```

Each has a corresponding `.sha256` file. Snapshot files are intentionally excluded from Git.

### Proxmox VM archives

The Seagate One Touch 2 TB HDD contains one complete backup generation:

| VM ID | Archive | Size |
|---:|---|---:|
| 210 | `vzdump-qemu-210-2026_08_01-10_29_43.vma.zst` | 432.11 MiB |
| 211 | `vzdump-qemu-211-2026_08_01-10_31_58.vma.zst` | 270.95 MiB |
| 212 | `vzdump-qemu-212-2026_08_01-10_33_27.vma.zst` | 251.83 MiB |

Storage configuration:

```text
Storage ID:       usb-backup-2tb
Filesystem:       ext4
Mount point:      /mnt/pve/usb-backup-2tb
Content:          backup
Mountpoint guard: is_mountpoint 1
Retention:        keep-last 3, keep-weekly 2, keep-monthly 1
```

The storage is normally disabled and the filesystem unmounted when the drive is disconnected.

## Post-backup validation

After backing up and restarting the VMs:

- all three Talos consoles reported `Running` and `Ready`,
- `kubectl get nodes -o wide` showed all three nodes `Ready`,
- `talosctl health` completed all checks with `OK`,
- the external storage was disabled and unmounted safely.

## Retired infrastructure

| Item | Final state |
|---|---|
| `asus-pve` | Experiment ended; old laptop shut down; no cluster was formed |
| VM `100` `ubuntu-web-test` | Deleted with owned virtual disks |
| Two-node Proxmox plan | Superseded by the single-host Talos Phase 1 design |

## Current gaps

```text
Restore test completed: No
Flux bootstrapped: No
SOPS age identity configured: No
Tailscale Operator deployed: No
Persistent application storage selected: No
Monitoring deployed: No
Logging deployed: No
Homepage deployed: No
UPS telemetry configured: No
```
