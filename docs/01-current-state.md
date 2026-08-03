# Current State

<!-- BEGIN CURRENT STATE 2026-08-03 -->
## Current checkpoint — 2026-08-03

| Property | Verified state |
|---|---|
| Active Proxmox node | `pve01` on Beelink GTi12 |
| PVE Manager | `9.2.6` |
| Proxmox cluster | Standalone host |
| Talos VMs | `210` control plane, `211` worker 1, `212` worker 2 |
| Kubernetes | Operational |
| Flux | Operational |
| Tailscale Kubernetes Operator | Operational |
| Direct Proxmox Tailscale endpoint | Operational |
| Tailscale Serve | Operational |
| Tailscale Funnel | Disabled |
| LG Gram external test | Passed using alternate Wi-Fi |
| Moto G84 external test | Passed using mobile data |
| External VM backups | Completed for VMs `210`, `211`, and `212` |
| Talos etcd snapshots | Completed on 2026-07-26 and 2026-08-01 |
| Temporary ASUS Proxmox node | Retired from active use |

The preferred private remote-management URL is recorded locally and represented
in committed documentation as:

```text
https://mel-pve01.<tailnet-name>.ts.net/
```

The earlier sections below remain as historical records of the temporary ASUS
experiment and must not be interpreted as the current operating state.
<!-- END CURRENT STATE 2026-08-03 -->


Verified on `2026-08-02` after Kubernetes bootstrap, backup completion, Flux bootstrap, and Tailscale Operator deployment.

## Hypervisor

| Property | Value |
|---|---|
| Hostname | `pve01` |
| FQDN | `pve01.home.arpa` |
| Management address | `192.168.1.201/24` |
| PVE Manager | `9.2.5` observed in the web interface |
| Running mode | Standalone, headless |
| Primary guest storage | `vmdata` on Samsung 990 PRO 2 TB |
| UPS | Eaton hardware protection active; telemetry pending |

## Kubernetes

| Property | Value |
|---|---|
| Cluster name | `dgs-homelab` |
| Talos version | `v1.13.6` |
| Kubernetes version | `v1.36.2` |
| Kernel | `6.18.38-talos` |
| Container runtime | containerd `2.2.5` |
| CNI | Flannel |
| API endpoint | `https://192.168.1.210:6443` |
| Control-plane nodes | 1 |
| Worker nodes | 2 |
| Node readiness | All three `Ready` |
| Physical HA | No; all VMs run on one Proxmox host |

## Nodes

| Node | VM ID | Role | Address | Ready |
|---|---:|---|---|---|
| `talos-cp-01` | 210 | Control plane and etcd | `192.168.1.210` | Yes |
| `talos-worker-01` | 211 | Worker | `192.168.1.211` | Yes |
| `talos-worker-02` | 212 | Worker | `192.168.1.212` | Yes |

## GitOps

| Property | Value |
|---|---|
| Flux CLI/distribution | `v2.9.3` |
| Git source | `dgsuma/dgs-private-cloud` |
| Branch | `main` |
| Reconciliation path | `clusters/beelink-talos` |
| Git authentication | SSH deploy key |
| GitRepository | `flux-system/flux-system`, `Ready=True` |
| Kustomization | `flux-system/flux-system`, `Ready=True` |
| SOPS | Not configured |

## Tailscale Operator

| Property | Value |
|---|---|
| Namespace | `tailscale` |
| Helm chart | `tailscale-operator` `1.98.9` |
| HelmRepository | `tailscale/tailscale`, `Ready=True` |
| HelmRelease | `tailscale/tailscale-operator`, `Ready=True` |
| Deployment | `operator`, `1/1 Available` |
| Pod | `1/1 Running`, zero restarts at validation |
| IngressClass | `tailscale` |
| Operator machine | `beelink-talos-operator` |
| Operator tag | `tag:k8s-operator` |
| OAuth Secret | `tailscale/operator-oauth`, manually created and not committed |
| Kubernetes API proxy | Disabled |

## Recovery baseline

| Item | State |
|---|---|
| Off-cluster etcd snapshots | Two completed and SHA-256 verified |
| Snapshot dates | `2026-07-26`, `2026-08-01` |
| Proxmox VM backups | VMs `210`, `211`, and `212` completed on `2026-08-01` |
| Backup storage | `usb-backup-2tb` |
| Media after backup | Disabled, unmounted, and disconnected |
| VM restore test | Pending |
| Talos DR rehearsal | Pending |
| Encrypted second copy | Pending |

## Services not yet deployed

- Kubernetes persistent-storage provisioner;
- Prometheus;
- Grafana;
- Alertmanager;
- Loki;
- Grafana Alloy;
- Homepage;
- SOPS-encrypted Secret management;
- UPS telemetry and automated graceful shutdown.

## Current risk statement

The Kubernetes control plane, workers, primary VM disks, and etcd member all depend on the single physical host `pve01`. Backups reduce data-loss risk but do not provide availability. The platform remains a single-host laboratory until permanent additional nodes and tested restores are introduced.
