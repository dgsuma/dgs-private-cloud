# Current State

<!-- BEGIN CURRENT STATE 2026-08-15 -->
## Current checkpoint — 2026-08-15
| Property | Verified state |
|---|---|
| Active Proxmox node | `pve01` on Beelink GTi12 |
| Talos Kubernetes | Operational; all three nodes `Ready` |
| Flux | Operational |
| Tailscale Kubernetes Operator | Operational; Kubernetes API proxy enabled |
| Kubernetes persistent storage | Operational |
| kube-prometheus-stack | `88.2.0`, Flux `Ready=True` |
| Prometheus | Operational; 50 GiB `local-path` PVC |
| Grafana | Operational; 5 GiB `local-path` PVC |
| Alertmanager | Operational; 2 GiB `local-path` PVC |
| Loki | `18.7.6`, Flux `Ready=True`; LogQL validation passed |
| Grafana Alloy | `1.11.1`, Flux `Ready=True`; Kubernetes log collection operational |
| LogQL validation | Passed for Kubernetes logs including error/warning filtering |
| Alertmanager email receiver | Gmail SMTP configured and operational |
| Alertmanager FIRING delivery | Passed |
| Alertmanager RESOLVED delivery | Passed |
| SMTP credential storage | Manual Secret `monitoring/alertmanager-smtp`; not committed |
| Mobile Kubernetes access | Operational — Android Termux + Tailscale + read-only RBAC |
| Grafana Tailscale ingress | Pending — next task |
| Homepage | Pending after Grafana private access |
| Direct Proxmox Tailscale endpoint | Operational |
| Jenkins Tailscale Serve endpoint | Operational |
| External VM backups | Completed for VMs `210`, `211`, and `212` |
| Talos etcd snapshots | Completed on 2026-07-26 and 2026-08-01 |

Exact private tailnet hostnames and credentials remain in local operator notes
rather than Git.
<!-- END CURRENT STATE 2026-08-15 -->


Verified on `2026-08-13` after logging-stack validation and successful Alertmanager Gmail FIRING/RESOLVED delivery.

## Hypervisor

| Property | Value |
|---|---|
| Hostname | `pve01` |
| FQDN | `pve01.home.arpa` |
| Management address | `192.168.1.201/24` |
| PVE Manager | `9.2.10` observed in the web interface |
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
| Kubernetes API proxy | Enabled through Tailscale; impersonation enabled |

## Persistent storage

| Property | Value |
|---|---|
| Worker data disks | 300 GiB `scsi1` on VMs `211` and `212` |
| Talos device | `/dev/sdb` provisioned as `/dev/sdb1` |
| User volume | `u-local-path-provisioner` |
| Filesystem | XFS |
| Mount | `/var/mnt/local-path-provisioner` |
| Provisioner | Rancher Local Path Provisioner `v0.0.37` |
| Namespace | `local-path-storage` |
| StorageClass | `local-path` (default) |
| Reclaim policy | `Delete` |
| Volume binding | `WaitForFirstConsumer` |
| Dynamic provisioning | Verified |
| Data across Pod recreation | Verified |
| Disposable test cleanup | Verified |
| Physical HA | No; storage remains local to worker VMs on the single `pve01` host |

The initial provisioner deployment was applied manually from the committed
Kustomize manifest. Flux reconciliation for this component has not yet been
configured.


## Observability — metrics and alerting baseline

| Property | Value |
|---|---|
| Namespace | `monitoring` |
| Delivery | Flux HelmRelease |
| Chart | `kube-prometheus-stack` `88.2.0` |
| HelmRelease | `monitoring/kube-prometheus-stack`, `Ready=True` |
| Prometheus persistence | 50 GiB `local-path`, retention `15d`, retention size `40GB` |
| Grafana persistence | 5 GiB `local-path` |
| Alertmanager persistence | 2 GiB `local-path` |
| Node Exporter | DaemonSet `3/3 Ready`; control plane + both workers |
| kube-state-metrics | Running |
| Prometheus Operator | Running |
| Prometheus scrape validation | All three Node Exporter targets `UP` |
| Host metric validation | `node_uname_info` and `node_memory_MemAvailable_bytes` return all three nodes |
| Grafana validation | `Kubernetes / Compute Resources / Cluster` populated with live data |
| Alertmanager | One replica reconciled and available; Gmail receiver configured |
| Prometheus rules | Chart-provided PrometheusRule resources present |
| External alert receivers | Gmail SMTP operational; FIRING and RESOLVED notifications verified |
| Loki | `18.7.6`, Flux `Ready=True`; LogQL validation passed |
| Grafana Alloy | `1.11.1`, Flux `Ready=True`; Kubernetes log collection operational |
| Grafana Tailscale ingress | Pending |

The initial Helm install was blocked because Talos/Kubernetes Pod Security Admission
enforced `baseline` in the new namespace while Node Exporter requires host-level
access (`hostNetwork`, `hostPID`, hostPath mounts, and host port `9100`). The
trusted `monitoring` namespace now enforces `privileged` while continuing to
audit and warn against `restricted`. After the policy fix, the Node Exporter
DaemonSet reached `3/3 Ready`.

The failed install had already exhausted the configured Helm remediation retries.
The recovery command used `flux reconcile helmrelease ... --reset`, after which
the release reconciled successfully and reported `Ready=True`.

See [18-observability-prometheus-grafana-alertmanager.md](18-observability-prometheus-grafana-alertmanager.md)
for the implementation, validation, troubleshooting, and next-session handoff.

See [19-observability-logging-alertmanager-email.md](19-observability-logging-alertmanager-email.md) for the logging and external email receiver completion record.

See [20-kubernetes-mobile-access-tailscale.md](20-kubernetes-mobile-access-tailscale.md) for the secure Android/Termux Kubernetes access implementation.

## Jenkins controller

| Property | Value |
|---|---|
| VM | `220` `jenkins-ci` |
| OS | Ubuntu Server 26.04 LTS |
| CPU | 1 socket / 4 vCPU, type `host` |
| Memory | 8 GiB; ballooning disabled |
| System disk | 100 GiB `scsi0` on `vmdata`; discard, IO thread, and SSD emulation enabled |
| Start at boot | Enabled |
| QEMU Guest Agent | Active |
| LAN address | `192.168.1.213/24` |
| Java | OpenJDK `21.0.11` |
| Git | `2.53.0` |
| Jenkins | `2.568.2` |
| Jenkins service | Enabled and active |
| Tailscale | Enabled and active |
| Jenkins listener | Loopback-only TCP `8080` |
| Private access | Tailscale Serve HTTPS |
| Direct LAN `192.168.1.213:8080` | Refused by design |
| Smoke Pipeline | `jenkins-learning-smoke` Build `#1` `SUCCESS` |
| Remote mobile-data validation | Passed |
| Proxmox snapshot | `jenkins-baseline-tailscale` |
| Phase 1 | Complete |
| Phase 2 | Deferred |

## Observability

| Property | Value |
|---|---|
| Namespace | `monitoring` |
| Delivery | Flux HelmRelease |
| kube-prometheus-stack chart | `88.2.0` |
| Prometheus | Operational |
| Prometheus retention | `15d` / `40GB` size limit |
| Prometheus PVC | `50Gi`, `local-path`, Bound |
| Grafana | Operational |
| Grafana PVC | `5Gi`, `local-path`, Bound |
| Alertmanager | Operational |
| Alertmanager PVC | `2Gi`, `local-path`, Bound |
| Loki chart | `18.7.6` |
| Loki application | `3.7.6` |
| Loki deployment mode | Monolithic, single replica |
| Loki PVC | `20Gi`, `local-path`, Bound |
| Loki gateway | Internal ClusterIP |
| Alloy chart | `1.11.1` |
| Alloy application | `v1.18.1` |
| Alloy controller | DaemonSet |
| Alloy readiness | `3/3` |
| Log collection | Kubernetes API via `loki.source.kubernetes` |
| End-to-end smoke test | Passed |
| Real namespace queries | `monitoring`, `flux-system`, `tailscale` verified |
| Grafana Tailscale ingress | Pending |
| External Alertmanager receivers | Pending |
| Loki retention policy | Pending |

See [18-observability-stack.md](18-observability-stack.md) for the implementation
and validation record.
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

- Grafana private ingress through Tailscale;
- Homepage;
- SOPS-encrypted Secret management;
- UPS telemetry and automated graceful shutdown.
## Current risk statement

The Kubernetes control plane, workers, primary VM disks, and etcd member all depend on the single physical host `pve01`. Backups reduce data-loss risk but do not provide availability. The platform remains a single-host laboratory until permanent additional nodes and tested restores are introduced.
