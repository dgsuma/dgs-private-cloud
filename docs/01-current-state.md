# Current State

<!-- BEGIN CURRENT STATE 2026-08-23 -->
## Current checkpoint — 2026-08-23

| Property | Verified state |
|---|---|
| Active Proxmox node | `pve01` on Beelink GTi12 |
| Talos Kubernetes | Operational; one control plane and two workers |
| Flux | Operational; Kustomization `Ready=True` |
| Tailscale Kubernetes Operator | Operational |
| Remote Kubernetes administration | Operational through the Tailscale Kubernetes API proxy from LG Gram WSL2 |
| Remote Talos administration | Operational through `mel-pve01` advertising `192.168.1.0/24` |
| Remote Proxmox administration | Operational through direct Tailscale SSH and TCP `8006` |
| Travel validation | Passed from alternate Wi-Fi and Moto G84 mobile-data hotspot |
| Local persistent storage | Operational; `local-path` default StorageClass |
| Metrics API | Operational |
| Prometheus / Grafana / Alertmanager | Operational |
| Loki / Grafana Alloy | Operational |
| Grafana private access | Operational through Tailscale |
| Homepage | Operational; `1/1` Deployment |
| Homepage private access | Operational through Tailscale Ingress |
| Homepage background | `homepage-background` ConfigMap mounted at `/app/public/images/background.jpg` |
| Homepage responsive validation | Desktop, narrow-browser, and mobile/portrait passed |
| Jenkins Controller Phase 1 | Complete |
| Tailscale Funnel | Disabled |
| SOPS | Not configured |
| Isolated VM restore test | Pending |
| UPS telemetry and graceful shutdown | Operational — Eaton 5E USB telemetry + NUT + 600-second automation production-tested |

Exact private tailnet hostnames remain in local operator notes rather than Git.
<!-- END CURRENT STATE 2026-08-23 -->


Verified on `2026-08-23` after storage, observability, Metrics API, private Grafana, Homepage, responsive-dashboard, GitOps, WSL2 travel-workstation, remote Kubernetes API proxy, Tailscale subnet routing, remote Talos administration, and Proxmox recovery-access validation.

## Remote travel administration

The LG Gram is validated for remote administration outside the Melbourne LAN.

| Layer | Verified path |
|---|---|
| Kubernetes | MobaXterm / WSL2 -> Windows Tailscale -> Kubernetes API proxy -> `kubectl` |
| Talos | MobaXterm / WSL2 -> Windows Tailscale -> `mel-pve01` subnet router -> `192.168.1.0/24` -> TCP `50000` -> `talosctl` |
| Proxmox | LG Gram -> Windows Tailscale -> `mel-pve01` -> SSH / TCP `8006` |

`pve01` has persistent IPv4/IPv6 forwarding enabled and advertises only `192.168.1.0/24`. It is not an exit node.

The full path was validated from both alternate Wi-Fi and the Moto G84 mobile-data hotspot. Exact Tailscale addresses and private DNS suffixes remain outside Git.

See [Remote Travel Administration Through Tailscale](23-remote-travel-administration.md).

## Hypervisor

| Property | Value |
|---|---|
| Hostname | `pve01` |
| FQDN | `pve01.home.arpa` |
| Management address | `192.168.1.201/24` |
| PVE Manager | `9.2.10` observed in the web interface |
| Running mode | Standalone, headless |
| Primary guest storage | `vmdata` on Samsung 990 PRO 2 TB |
| UPS | Eaton 5E 1200 AU G2; USB NUT telemetry and automated graceful shutdown operational |

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
| Grafana Tailscale ingress | Operational — Flux-managed private access verified |

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

## Homepage private application dashboard

| Property | Value |
|---|---|
| Namespace | `homepage` |
| Delivery | Flux Kustomize from `clusters/beelink-talos/homepage/` |
| Application | Homepage `v1.13.2` |
| Deployment | `homepage`, `1/1` Ready after recovery |
| Service | `homepage`, internal `ClusterIP`, TCP `3000` |
| Private ingress | `homepage-tailscale`, `ingressClassName: tailscale` |
| Public exposure | None; Tailscale Funnel not enabled |
| Pod security | Non-root UID/GID `1000`, privilege escalation disabled, all Linux capabilities dropped, RuntimeDefault seccomp |
| Configuration | Git-managed ConfigMap with Homepage YAML/config files |
| Runtime Secret | `homepage/homepage-runtime`, created out-of-band and not committed |
| Runtime Secret keys | `HOMEPAGE_EXTERNAL_HOST`, `HOMEPAGE_VAR_GRAFANA_URL` |
| Health endpoint | `/api/healthcheck` for readiness and liveness |
| Post-fix Pod state | `1/1 Running`, zero restarts during validation |
| Repeated HTTPS validation | 20 consecutive HTTP `200` responses |
| Workstation validation | LG Gram through private Tailscale HTTPS — passed |
| Mobile validation | Moto G84 over mobile data through Tailscale — passed |

### CrashLoopBackOff incident and fix

The first Homepage rollout initially rendered successfully, then became
intermittently unavailable through the Tailscale ingress with HTTP `502`.
Kubernetes showed the Homepage Pod in `CrashLoopBackOff` after 12 restarts while
Grafana continued to work through its independent private Tailscale ingress.

Previous-container logs provided the root-cause evidence:

```text
Failed to initialize required config: /app/config/proxmox.yaml
Reason: EACCES: permission denied, copyfile '/app/src/skeleton/proxmox.yaml' -> '/app/config/proxmox.yaml'
Hint: Make /app/config writable or manually place the config file.
```

The GitOps recovery made the container layout explicit rather than weakening the
security context:

- added an empty `proxmox.yaml` entry to the Homepage ConfigMap and mounted it at `/app/config/proxmox.yaml`;
- mounted `/app/config/logs` from a writable `emptyDir`;
- kept the container non-root with privilege escalation disabled and capabilities dropped;
- changed runtime host handling so `HOMEPAGE_ALLOWED_HOSTS` contains the Pod IP/port used by Kubernetes health probes plus the private external hostname supplied from `homepage-runtime`;
- retained readiness and liveness checks on `/api/healthcheck` with explicit timeout/failure thresholds;
- associated the service-account token Secret explicitly with the Homepage ServiceAccount;
- retained read-only RBAC and added `metrics.k8s.io` read access for future dashboard metrics.

After Flux reconciliation, the replacement Pod remained stable with zero
restarts and repeated private HTTPS access returned HTTP `200`. The earlier
`502` was therefore a downstream symptom of an unavailable Homepage backend,
not a general Tailscale failure.

The incident also generated a real `KubePodCrashLooping` alert and Gmail warning,
which validated the chain from kube-state-metrics through Prometheus and
Alertmanager to the external email receiver.

See [21-homepage-private-tailscale.md](21-homepage-private-tailscale.md) for the
complete implementation, incident, validation, and recovery record.

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
| Grafana Tailscale ingress | Operational — Flux-managed private access verified |
| External Alertmanager receivers | Gmail SMTP operational; FIRING and RESOLVED delivery verified |
| Loki retention policy | Pending |

See [18-observability-stack.md](18-observability-stack.md) for the implementation
and validation record.
<!-- BEGIN JENKINS PHASE 1G CURRENT STATE -->
## Jenkins build agent and CI-to-GitOps — verified 2026-08-24

| Property | Verified state |
|---|---|
| Build-agent VM | `221` `jenkins-agent-01` |
| Agent address | `192.168.1.214/24` |
| Agent OS | Ubuntu Server 26.04 LTS |
| Agent compute | 4 vCPU, 8 GiB RAM |
| Agent disk | 80 GiB on `vmdata` |
| Java | OpenJDK `21.0.11` |
| Git | `2.53.0` |
| Docker | `29.1.3` |
| Jenkins OS account | `jenkins`, password locked |
| Jenkins node | Online |
| Agent executors | `2` |
| Agent labels | `linux docker gitops` |
| Controller executors | `0` |
| Controller-to-agent transport | SSH with Known Hosts verification |
| GitHub Jenkins credential | Dedicated repository-scoped SSH write credential |
| Temporary write-test branch | Deleted after successful validation |
| End-to-end Jenkins commit | `77bc93b` |
| Flux reconciliation | Automatically applied `main@sha1:77bc93b` |
| Kubernetes proof | `ci-gitops-smoke` ConfigMap updated by Flux |
| Responsibility split | Jenkins changes Git; Flux changes Kubernetes |
| Phase 1G baseline | Complete |

No kubeconfig, `talosconfig`, Flux private key, or Kubernetes administrator
credential is required on the Jenkins build agent for the normal GitOps path.
<!-- END JENKINS PHASE 1G CURRENT STATE -->

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

## Services and controls still pending

- Local Path Provisioner configuration fully reconciled by Flux;
- SOPS/age encrypted Secret management and migration of manual Secrets;
- isolated VM restore and Talos recovery rehearsal;
- additional least-privilege Homepage integrations/widgets.
## UPS power-failure automation

The Eaton 5E 1200 AU G2 protecting `pve01` is monitored by NUT over USB.
`ONBATT` starts a 600-second grace timer, `ONLINE` cancels it, and
`LOWBATT` invokes the shutdown path immediately. A safe 30-second test proved
the timer/handler chain before a sustained real mains-failure test proved
orderly Proxmox guest shutdown, host shutdown, and production VM recovery.

See [24-proxmox-ups-nut-graceful-shutdown.md](24-proxmox-ups-nut-graceful-shutdown.md).
## Current risk statement

The Kubernetes control plane, workers, primary VM disks, and etcd member all depend on the single physical host `pve01`. Backups reduce data-loss risk but do not provide availability. The platform remains a single-host laboratory until permanent additional nodes and tested restores are introduced.

## 2026-08-16 update — Homepage private application access

The private application layer now includes a Flux-managed Homepage dashboard.

- Private Grafana Tailscale Ingress: operational.
- Homepage `v1.13.2`: operational through Flux.
- Homepage Kubernetes Service: internal `ClusterIP` only.
- Homepage private Tailscale Ingress: operational.
- LG Gram access through Tailscale: verified.
- Moto G84 mobile-data access through Tailscale: verified.
- Initial Homepage `CrashLoopBackOff`: resolved.
- Root cause: `EACCES` while the application attempted to create `/app/config/proxmox.yaml` on a read-only ConfigMap-backed path.
- Corrective action: explicit `proxmox.yaml`, writable log `emptyDir`, and corrected allowed-host/health-probe environment handling.
- Post-fix Pod state: `1/1 Running`, zero restarts during validation.
- Repeated private HTTPS test: 20 consecutive HTTP `200` responses.
- Alertmanager `KubePodCrashLooping` Gmail warning: observed during the incident.
- Exact private tailnet hostnames and runtime Secret values: kept outside Git.
