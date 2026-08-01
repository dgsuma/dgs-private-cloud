# Validation

## Verified baseline date

The most recent complete validation was performed on **2026-08-01** after creating VM backups, restarting the Talos cluster, and creating the second etcd snapshot.

## Proxmox host and storage

```bash
pveversion -v
systemctl --failed
pvesm status
```

Verified observations:

```text
PVE Manager observed in GUI: 9.2.6
local:                       active
local-lvm:                   active
vmdata:                      active
usb-backup-2tb:              active during backup; disabled after safe unmount
```

External-drive validation while connected:

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,MODEL,TRAN
df -hT /mnt/pve/usb-backup-2tb
findmnt /mnt/pve/usb-backup-2tb
```

Verified:

```text
Model:       Seagate One Touch
Transport:   USB
Filesystem:  ext4
Mount point: /mnt/pve/usb-backup-2tb
Capacity:    approximately 1.8 TiB total / 1.7 TiB available before backups
```

## Kubernetes nodes

```powershell
kubectl get nodes -o wide
```

Verified:

```text
talos-cp-01       Ready   control-plane   192.168.1.210
talos-worker-01   Ready   <none>          192.168.1.211
talos-worker-02   Ready   <none>          192.168.1.212
```

## Talos health

```powershell
talosctl health `
  --nodes $CP `
  --endpoints $CP
```

Talos discovered all three nodes and returned `OK` for:

- etcd health and member consistency,
- apid readiness,
- memory and disk checks,
- diagnostics,
- kubelet health,
- completed boot sequence,
- Kubernetes node reporting and readiness,
- control-plane static pods and components,
- kube-proxy,
- CoreDNS,
- schedulability.

## System pods

```powershell
kubectl get pods -A -o wide
```

Verified running:

- CoreDNS,
- kube-apiserver,
- kube-controller-manager,
- kube-scheduler,
- kube-proxy on all nodes,
- Flannel on all nodes.

## Workload scheduling

Four `nginx:stable-alpine` replicas were created and scheduled two per worker. All reached `Running`, then the deployment was deleted successfully.

## etcd snapshots

Verified local files on the LG Gram:

```text
dgs-homelab-etcd-2026-07-26_192642.snapshot
dgs-homelab-etcd-2026-07-26_192642.snapshot.sha256
dgs-homelab-etcd-2026-08-01_090643.snapshot
dgs-homelab-etcd-2026-08-01_090643.snapshot.sha256
```

Both snapshot files are non-zero and have SHA-256 companion files.

## Proxmox VM backups

Verified on `usb-backup-2tb`:

| VM | Result | Archive size |
|---:|---|---:|
| 210 | Present | 432.11 MiB |
| 211 | Present | 270.95 MiB |
| 212 | Present | 251.83 MiB |

## Safe external-drive removal

After backup completion:

```bash
pvesm set usb-backup-2tb --disable 1
sync
umount -R /mnt/pve/usb-backup-2tb
findmnt /mnt/pve/usb-backup-2tb
pvesm status
```

Verified final state:

```text
usb-backup-2tb  dir  disabled
```

`findmnt` returned no active mount before physical disconnection.

## Current acceptance criteria

- [x] Proxmox host boots and web UI is reachable.
- [x] Management networking and outbound IPv4 work.
- [x] Primary storages are active.
- [x] Three Talos VMs are running.
- [x] All Kubernetes nodes are `Ready`.
- [x] Talos health passes.
- [x] Core system pods are running.
- [x] Workloads schedule across both workers.
- [x] Two etcd snapshots exist with SHA-256 files.
- [x] One full three-VM backup generation exists.
- [x] External storage can be disabled and unmounted safely.
- [ ] A VM restore has been tested.
- [ ] An etcd disaster-recovery restore has been rehearsed.
