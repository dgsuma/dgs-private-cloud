# Current State

Verified on **2026-07-26** after completing the first Talos Kubernetes cluster, validating workload scheduling, detaching the installation media, and creating the first etcd snapshot.

## Proxmox platform

| Property | Value |
|---|---|
| Active node | `pve01` |
| Platform | Beelink GTi12 |
| FQDN | `pve01.home.arpa` |
| Management address | `192.168.1.201/24` |
| Management URL | `https://192.168.1.201:8006` |
| PVE Manager | `9.2.5` observed in the web interface |
| Cluster membership | Standalone |
| Active VM count | 3 |
| Active container count | 0 |
| Primary VM storage | `vmdata` |
| UPS hardware protection | Active |
| UPS telemetry | Not configured |

## Retired infrastructure

| Item | Final state |
|---|---|
| `asus-pve` | Experiment ended; no Proxmox cluster was formed |
| VM `100` `ubuntu-web-test` | Deleted with its owned virtual disks |
| Two-node temporary Proxmox plan | Superseded by the single-host Talos Phase 1 design |

## Talos and Kubernetes versions

| Component | Version/state |
|---|---|
| Talos Linux | `v1.13.6` |
| Kubernetes server | `v1.36.2` |
| Workstation kubectl client | `v1.36.3` |
| Kernel | `6.18.38-talos` on amd64 |
| Container runtime | `containerd 2.2.5` |
| CNI | Flannel |
| Kubernetes API endpoint | `https://192.168.1.210:6443` |
| Talos API endpoint | `192.168.1.210:50000` |
| Cluster health | Passed |

## Active virtual machines

| VM ID | Name | Role | Address | vCPU | RAM | Disk | State |
|---:|---|---|---|---:|---:|---:|---|
| 210 | `talos-cp-01` | Control plane and etcd | `192.168.1.210/24` | 4 | 8 GiB | 64 GiB | Running, Ready |
| 211 | `talos-worker-01` | Worker | `192.168.1.211/24` | 4 | 8 GiB | 64 GiB | Running, Ready |
| 212 | `talos-worker-02` | Worker | `192.168.1.212/24` | 4 | 8 GiB | 64 GiB | Running, Ready |

## Common VM configuration

| Property | Value |
|---|---|
| Machine | `q35` |
| BIOS | OVMF |
| CPU type | `host` |
| Ballooning | Disabled |
| SCSI controller | VirtIO SCSI |
| System disk | `scsi0` on `vmdata` |
| Discard | Enabled |
| SSD emulation | Enabled |
| Network | VirtIO on `vmbr0` |
| Gateway/DNS | `192.168.1.1` |
| Boot order | `scsi0`, `ide2`, `net0` |
| Installation ISO | Detached from all three VMs |
| Installation target | `/dev/sda` |

The Talos bootstrap ISO was built with the `siderolabs/qemu-guest-agent` extension selected. The installed extension state should be checked separately before relying on Proxmox guest-agent reporting.

## Kubernetes node validation

All three nodes reported `Ready`:

```text
talos-cp-01       Ready   control-plane   192.168.1.210
talos-worker-01   Ready   <none>          192.168.1.211
talos-worker-02   Ready   <none>          192.168.1.212
```

The following core workloads were confirmed running:

- CoreDNS,
- kube-apiserver,
- kube-controller-manager,
- kube-scheduler,
- kube-proxy on all nodes,
- Flannel on all nodes.

## Scheduling validation

A disposable Nginx deployment was created and scaled to four replicas. Kubernetes scheduled two replicas on `talos-worker-01` and two on `talos-worker-02`. All replicas reached `Running`, and the deployment was then deleted.

The Pod Security admission warning for the default Nginx image was non-blocking. Future application manifests should use explicit restricted-compatible security contexts.

## Backup state

| Backup item | State |
|---|---|
| First consistent etcd snapshot | Complete |
| Snapshot storage | Outside the repository and outside the cluster |
| Snapshot checksum | SHA-256 generated |
| Snapshot size | 2,232,352 bytes at creation |
| Proxmox VM backups | Not configured |
| External backup target | Pending |
| Restore test | Not performed |

The etcd snapshot contains sensitive Kubernetes state and must not be committed.

## GitOps and services

```text
Flux bootstrapped: No
SOPS age identity generated: No
Tailscale Operator deployed: No
Persistent storage deployed: No
Monitoring deployed: No
Logging deployed: No
Homepage deployed: No
PostgreSQL/TimescaleDB deployed: No
```

## Workstation tooling

| Tool | Verified version |
|---|---:|
| PowerShell | `7.6.3` |
| Git | `2.46.2` |
| GitHub CLI | `2.96.0` |
| kubectl | `1.36.3` client |
| Kustomize through kubectl | `5.8.1` |
| talosctl | `1.13.6` |
| Flux CLI | `2.9.3` |
| SOPS | `3.13.2` |
| age / age-keygen | `1.3.1` |
