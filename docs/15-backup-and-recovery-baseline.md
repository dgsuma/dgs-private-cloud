# Backup and Recovery Baseline

## Scope

This record captures the first complete recovery baseline for the Phase 1 Talos Kubernetes cluster as of **2026-08-01**.

It includes:

- off-cluster Talos etcd snapshots,
- full compressed Proxmox VM backups,
- post-backup cluster-health validation,
- external-drive retention and safe-removal state.

## Why both backup types are required

### Talos etcd snapshot

Protects Kubernetes API state, including deployments, services, namespaces, ConfigMaps, Secrets, RBAC, custom resources, and persistent-volume metadata.

It does **not** contain the actual data stored inside application persistent volumes.

### Proxmox VM backup

Protects VM configuration and virtual disks. It provides a faster path to recreate the exact Talos VM layer but does not replace a current etcd snapshot or application-data backup.

## Talos etcd recovery points

Stored outside the Git repository on the LG Gram:

| Date | Snapshot |
|---|---|
| 2026-07-26 | `dgs-homelab-etcd-2026-07-26_192642.snapshot` |
| 2026-08-01 | `dgs-homelab-etcd-2026-08-01_090643.snapshot` |

Each has a `.sha256` companion file. The files can contain sensitive Kubernetes state and are not committed.

## Proxmox VM backup generation

Backup destination:

```text
Device:       Seagate One Touch 2 TB USB HDD
Filesystem:   ext4
Storage ID:   usb-backup-2tb
Mount point:  /mnt/pve/usb-backup-2tb
Compression:  ZSTD
Backup note:  Talos cluster baseline after bootstrap
```

Archives:

| VM | Role | Archive | Size |
|---:|---|---|---:|
| 210 | Control plane / etcd | `vzdump-qemu-210-2026_08_01-10_29_43.vma.zst` | 432.11 MiB |
| 211 | Worker 1 | `vzdump-qemu-211-2026_08_01-10_31_58.vma.zst` | 270.95 MiB |
| 212 | Worker 2 | `vzdump-qemu-212-2026_08_01-10_33_27.vma.zst` | 251.83 MiB |

The small archive sizes relative to the 64 GiB virtual disks are expected because empty disk blocks compress efficiently.

## Retention

```text
Keep Last:    3
Keep Weekly:  2
Keep Monthly: 1
```

No backup is marked protected in the recorded baseline. A protected known-good generation can be considered after a restore test.

## Cluster shutdown and restart

The backup session used a controlled cluster lifecycle.

Shutdown order:

```text
211 worker 1
212 worker 2
210 control plane
```

Restart order:

```text
210 control plane
211 worker 1
212 worker 2
```

## Post-backup validation

After restart:

- all Talos consoles reported `Running` and `Ready`,
- all three Kubernetes nodes reported `Ready`,
- `talosctl health` completed every check with `OK`,
- control-plane components and worker kubelets were healthy.

## External-drive final state

After verification:

1. `usb-backup-2tb` was disabled.
2. `sync` flushed pending writes.
3. `/mnt/pve/usb-backup-2tb` was unmounted.
4. `findmnt` showed no active mount.
5. `pvesm status` reported `usb-backup-2tb` as disabled.
6. The HDD was disconnected safely.

## Recovery limitations

The following remain untested:

- restore of a VZDump archive to a new VM ID,
- complete control-plane recovery using an etcd snapshot,
- application persistent-volume restore,
- recovery after total loss of `pve01`.

## Next recovery test

The safest next exercise is to restore one worker archive to an unused VM ID with its virtual NIC disconnected. Confirm the restored VM configuration and disk bootability, then delete the test VM. Do not connect a duplicated Talos node to the production LAN because it would have the same machine identity and network configuration as the original.
