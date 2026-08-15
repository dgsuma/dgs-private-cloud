# Changelog

## [0.9.0] - 2026-08-15

### Added

- Secure read-only Kubernetes access from Android Termux through Tailscale.
- GitOps-managed `tailscale-mobile-readonly` RBAC.
- Dedicated `tailscale-mobile-node-reader` ClusterRole for Node visibility.
- Detailed mobile Kubernetes access documentation in `docs/20-kubernetes-mobile-access-tailscale.md`.

### Changed

- Enabled the Tailscale Kubernetes API server proxy and impersonation.
- Extended the mobile Tailscale identity with `get`, `list`, and `watch` access to Nodes.
- Kept mobile Kubernetes access deliberately read-only.

### Verified

- `kubectl get nodes` succeeds remotely from the Moto G84.
- All three Talos nodes report `Ready`.
- `kubectl get pods -A` succeeds from Android Termux.
- `kubectl get pods -A -o wide` succeeds from Android Termux.
- `kubectl get deployments -A` succeeds from Android Termux.
- Mobile identity can list and get Nodes.
- Mobile identity cannot delete Nodes.
- Mobile identity cannot read Kubernetes Secrets.
- Flux successfully reconciled the RBAC changes.

### Security

- Kubernetes API access remains private through Tailscale.
- Mobile identity does not have `cluster-admin`.
- Talos administrator kubeconfig is not stored on the phone.
- Mobile kubeconfig and authentication material remain outside Git.

## [0.8.0] - 2026-08-13

### Added

- Flux-managed Loki `18.7.6` logging backend.
- Flux-managed Grafana Alloy `1.11.1` Kubernetes log collection.
- `AlertmanagerConfig/email-notifications` Gmail receiver.
- Detailed logging and Alertmanager email completion documentation.

### Changed

- Alertmanager matcher strategy to
  `OnNamespaceExceptForAlertmanagerNamespace`.
- `Watchdog` is routed to a null receiver to prevent repetitive email.
- Current-state, roadmap, next-steps, Kubernetes inventory, and security
  documentation updated to the 2026-08-13 checkpoint.

### Verified

- Loki and Alloy HelmReleases report `Ready=True`.
- Grafana/LogQL returns Kubernetes logs and error/warning filtered results.
- `kube-prometheus-stack` `88.2.0` reports `Ready=True`.
- Alertmanager Gmail FIRING notification delivered successfully.
- Alertmanager Gmail RESOLVED notification delivered successfully.
- Temporary Alertmanager localhost port-forward was stopped and TCP `9093`
  verified closed afterwards.

### Security

- Gmail App Password remains outside Git in the manually created
  `monitoring/alertmanager-smtp` Secret.
- The committed receiver manifest contains only the Secret reference.
- Grafana private Tailscale ingress and Homepage remain the next tasks.
## [0.8.0] - 2026-08-10

### Added

- Flux-managed Loki logging backend using chart `18.7.6`.
- Loki Monolithic deployment with a persistent `20Gi` `local-path` PVC.
- Grafana Loki datasource provisioned through a labelled ConfigMap.
- Flux-managed Grafana Alloy using chart `1.11.1`.
- Alloy DaemonSet log collection across all three Talos nodes.
- Dedicated observability implementation and validation documentation.
- Grafana local background port-forward operating procedure.

### Verified

- `kube-prometheus-stack`, `loki`, and `alloy` HelmReleases report `Ready=True`.
- Alloy DaemonSet reports `3/3` desired/current/ready/available.
- Loki application `3.7.6` build-information API responds successfully.
- Loki labels API responds successfully.
- Loki `20Gi` PVC is `Bound` through `local-path`.
- Prometheus `50Gi`, Grafana `5Gi`, and Alertmanager `2Gi` PVCs remain `Bound`.
- Controlled five-line Alloy/Loki smoke test appeared in Grafana Explore.
- Real logs from `monitoring`, `flux-system`, and `tailscale` are queryable.
- Grafana severity filtering using `detected_level` returns errors and warnings.
- Temporary smoke-test pod was removed after validation.
- Git working tree was clean and synchronized with `origin/main` after infrastructure commits.

### Notes

- Loki remains internal to Kubernetes; its gateway is not publicly exposed.
- Grafana Tailscale ingress, Loki retention, storage-capacity alerts, and
  external Alertmanager receivers remain pending.
- Local Grafana access currently uses a workstation port-forward to
  `127.0.0.1:3000`.

## [0.8.0] - 2026-08-09

### Added

- Flux-managed `monitoring` namespace and observability Helm repositories.
- `kube-prometheus-stack` `88.2.0` HelmRelease.
- Prometheus persistent storage: 50 GiB on `local-path`, 15-day retention, 40 GB retention-size target.
- Grafana persistent storage: 5 GiB on `local-path`.
- Alertmanager persistent storage: 2 GiB on `local-path`.
- Dedicated implementation and troubleshooting document for Prometheus, Grafana, Alertmanager, and Node Exporter.

### Security and compatibility

- Diagnosed Talos/Kubernetes Pod Security Admission blocking the Node Exporter DaemonSet under `baseline`.
- Added a targeted `monitoring` namespace exception with `pod-security.kubernetes.io/enforce=privileged`.
- Retained `restricted` Pod Security audit and warning labels for visibility.
- Kept observability endpoints private; validation used local `kubectl port-forward`.
- Kept the generated Grafana admin password out of Git.

### Recovered

- Confirmed the Node Exporter DaemonSet progressed from `3 desired / 0 current / 0 ready` to `3/3 Ready`.
- Reset exhausted Flux Helm remediation state with `flux reconcile helmrelease kube-prometheus-stack --namespace monitoring --with-source --reset`.
- Confirmed the resulting HelmRelease reports `Ready=True`.

### Verified

- Prometheus, Grafana, Alertmanager, kube-state-metrics, Prometheus Operator, and all three Node Exporter Pods are running.
- Prometheus, Grafana, and Alertmanager PVCs are `Bound`.
- Prometheus reports all three Node Exporter targets `UP`.
- `up{job=~".*node-exporter.*"}` returns three healthy series with value `1`.
- `node_uname_info` returns all three Talos nodes.
- `node_memory_MemAvailable_bytes` returns all three Talos nodes.
- Grafana login succeeds using the generated Kubernetes Secret credential.
- `Kubernetes / Compute Resources / Cluster` renders live CPU, memory, namespace, Pod, and workload data.
- Alertmanager is reconciled and available.
- Chart-provided `PrometheusRule` resources are present.

### Deferred

- Loki installation (Step 5D).
- Grafana Alloy installation and Kubernetes log collection (Step 5E).
- Loki Grafana data source and LogQL validation.
- Grafana private Tailscale ingress.
- External Alertmanager notification receivers.

## [0.7.0] - 2026-08-09

### Added

- Dedicated 300 GiB `scsi1` data disks to Talos worker VMs `211` and `212`.
- Talos XFS user volume `u-local-path-provisioner` on both workers.
- Rancher Local Path Provisioner `v0.0.37`.
- Default `local-path` StorageClass.
- Reproducible PVC/PV smoke-test manifest.
- Dedicated Talos persistent-storage implementation and validation document.

### Verified

- Both worker user volumes report `PHASE=ready`.
- Both volumes mount at `/var/mnt/local-path-provisioner`.
- Local Path Provisioner is available and healthy.
- `local-path` uses `rancher.io/local-path`, `Delete`, and `WaitForFirstConsumer`.
- A 1 GiB PVC dynamically created and bound a PV.
- The test Pod wrote and read persistent data successfully.
- The PVC remained bound after the original Pod was deleted.
- A recreated Pod mounted the same PVC and read the original data.
- Deleting the test namespace removed the PVC, PV, and physical backing directory.
- All three Kubernetes nodes remained `Ready`.

### Workstation

- Removed the PowerShell `kubectl` wrapper that interfered with `kubectl exec`.
- Disabled Docker Desktop's unused bundled `kubectl.exe`.
- Confirmed normal command resolution to WinGet `kubectl` `v1.36.3`.
- Confirmed `kubectl exec POD -- COMMAND` works normally.

### Notes

- The storage provisioner was initially applied manually from the committed
  Kustomize manifest; Flux ownership is still pending.
- Local Path Provisioner is node-local and does not provide replicated storage
  or physical high availability.
## [0.6.0] - 2026-08-07

### Added

- Ubuntu Server 26.04 LTS Jenkins controller VM `220` (`jenkins-ci`).
- Jenkins LTS `2.568.2` on OpenJDK `21.0.11`.
- Direct Tailscale integration for the Jenkins VM.
- Tailscale Serve private HTTPS reverse proxy to Jenkins loopback TCP `8080`.
- Synthetic Pipeline `jenkins-learning-smoke`.
- Proxmox snapshot `jenkins-baseline-tailscale`.
- Dedicated Jenkins Controller Phase 1 documentation.

### Changed

- Updated the verified Proxmox Manager version to `9.2.9`.
- Added VM `220` to active guest and network inventories.
- Restricted Jenkins from all-interface TCP `8080` to loopback-only access.
- Established Tailscale Serve HTTPS as the Jenkins remote-administration path.

### Verified

- Jenkins, Tailscale, and QEMU Guest Agent services are active.
- Direct LAN access to `192.168.1.213:8080` is refused.
- Tailscale Serve proxies private HTTPS to `127.0.0.1:8080`.
- `jenkins-learning-smoke` Build `#1` completed with `Finished: SUCCESS`.
- Jenkins remote access succeeded from a phone over mobile data through Tailscale.
- Proxmox snapshot `jenkins-baseline-tailscale` exists.

### Deferred

- Jenkins build-agent VM and distributed-build configuration are deferred to Phase 2.
<!-- BEGIN CHANGELOG 0.4.0 -->
## [0.4.0] - 2026-08-03

### Added

- End-to-end Tailscale Serve implementation guide for private Proxmox access.
- Remote-access validation runbook.
- Sanitised Tailscale inventory.
- Current-state and operations checkpoints for remote administration.

### Implemented

- Installed Tailscale directly on `pve01`.
- Registered the Proxmox host as `mel-pve01`.
- Enabled the `tailscaled` system service.
- Enabled private HTTPS certificates for Tailscale Serve.
- Configured a background Serve proxy to
  `https+insecure://127.0.0.1:8006`.
- Kept Tailscale Funnel disabled.
- Verified Tailscale ping and TCP `8006` connectivity from the LG Gram.
- Verified the private Serve URL from the LG Gram on alternate Wi-Fi.
- Verified the private Serve URL from the Moto G84 over mobile data.

### Security

- Kept Proxmox management ports closed to the public internet.
- Excluded real tailnet addresses, authentication links, keys, and unredacted
  screenshots from committed documentation.
<!-- END CHANGELOG 0.4.0 -->

All notable documentation and infrastructure-state changes are recorded here.

## [0.5.0] - 2026-08-02

### Added

- Flux `v2.9.3` bootstrap against the private `dgs-private-cloud` repository.
- Active GitOps cluster path at `clusters/beelink-talos`.
- Flux-generated controller and synchronization manifests.
- Tailscale HelmRepository and HelmRelease managed by Flux.
- Tailscale Kubernetes Operator chart `1.98.9`.
- `tailscale` IngressClass and Tailscale custom-resource definitions.
- Documentation and validation runbook for Flux and Tailscale.
- Kubernetes inventory entries for GitOps, private access, and remaining platform services.

### Changed

- Updated the verified platform date to `2026-08-02`.
- Updated the README, current-state document, roadmap, operations guide, next steps, security policy, and Kubernetes inventory.
- Marked Proxmox VM backups of `210`, `211`, and `212` as completed.
- Marked the removable backup disk as safely disabled, unmounted, and disconnected after backup.
- Marked Flux bootstrap and Tailscale Operator deployment as completed.
- Set persistent storage and observability as the immediate next platform work.
- Removed the obsolete empty `clusters/home` placeholder.

### Security

- Kept the Tailscale `operator-oauth` Secret outside Git.
- Documented required Tailscale tag ownership and OAuth scopes without recording credentials.
- Confirmed the Flux deploy key remains the repository authentication method after revoking the temporary bootstrap PAT.
- Added explicit guidance for moving the manually created OAuth Secret to SOPS-encrypted Git management later.

### Verified

- Flux GitRepository and Kustomization report `Ready=True`.
- Flux HelmRepository and Tailscale HelmRelease report `Ready=True`.
- Tailscale operator Deployment is available.
- Tailscale operator pod is `1/1 Running` with zero restarts.
- `beelink-talos-operator` is connected in the Tailscale admin console with `tag:k8s-operator`.

## [0.4.0] - 2026-07-26

### Added

- Talos worker VMs `211` and `212`.
- Node-specific Talos hostname patches using `HostnameConfig`.
- Completed Kubernetes bootstrap documentation.
- Kubernetes cluster inventory.
- etcd snapshot runbook and reusable PowerShell snapshot script.

### Changed

- Updated the verified state from one Talos maintenance-mode VM to an operational three-node cluster.
- Corrected the worker specifications to the implemented 4 vCPU, 8 GiB RAM, and 64 GiB disk configuration.
- Corrected the active worker names to `talos-worker-01` and `talos-worker-02`.
- Updated the Talos runbook with the actual clone, boot-order, configuration-patching, validation, bootstrap, and ISO-detachment workflow.
- Updated operations, security, roadmap, inventories, and next steps.

### Completed infrastructure

- Applied Talos `v1.13.6` machine configurations to all three nodes.
- Bootstrapped the control plane exactly once.
- Confirmed Kubernetes `v1.36.2` and all three nodes `Ready`.
- Confirmed CoreDNS, Flannel, kube-proxy, API server, controller manager, and scheduler running.
- Validated workload scheduling with four Nginx replicas across both workers.
- Detached the installation ISO from all three VMs.
- Created and SHA-256-verified the first off-cluster etcd snapshot.

## [0.3.0] - 2026-07-25

### Added

- GitOps-oriented repository structure for Talos, Kubernetes infrastructure, applications, clusters, and runbooks.
- Talos `v1.13.6` Image Factory schematic with the QEMU guest-agent extension selected.
- Talos control-plane VM `210`.
- Talos Phase 1 prerequisite documentation.

### Verified

- Talos maintenance mode on `192.168.1.210`.
- Talos API reachability.
- Writable installation disk `/dev/sda`.
- Matching workstation and uploaded ISO hashes.

## [0.2.0] - 2026-07-12

### Added

- Structured repository architecture.
- Installation, networking, router-recovery, storage, validation, and operations documentation.
- Mermaid architecture and workflow diagrams.
- Host, network, and storage inventory.
- Health, network, storage, and state-collection scripts.
- Codex instructions through `AGENTS.md`.
- ADRs for storage separation, static management networking, and repository policy.

### Documented

- Proxmox VE installation on the Crucial 1 TB SSD.
- Archer NX200 IPv4 recovery through a custom Vodafone IPv4 profile.
- Samsung 990 PRO 2 TB LVM-thin configuration.
- Thin metadata extension and monitoring.
- Final validation state with zero failed systemd units.

## [0.1.0] - 2026-07-11

### Added

- Initial README.
- Proprietary licence.

### Completed infrastructure

- First Proxmox node installed and operational.
- No VMs or containers deployed.

## 2026-08-15 — Alertmanager completion and private Grafana access

- Verified Alertmanager Gmail FIRING notification delivery end-to-end.
- Verified Alertmanager Gmail RESOLVED notification delivery end-to-end.
- Deployed a private Grafana Ingress through the Tailscale Kubernetes Operator.
- Confirmed Grafana remains behind its internal Kubernetes `ClusterIP` Service.
- Verified HTTPS Grafana access from the administration workstation without `kubectl port-forward`.
- Verified Grafana access from an authorised Android device over mobile data.
- Verified the Grafana hostname is unavailable when the Android device disconnects from Tailscale.
- Confirmed the Tailscale proxy reports `tailnet only`.
- Added the Grafana Ingress to the monitoring Kustomization and reconciled it through Flux.
- Confirmed `kustomize-controller` manages the Grafana Ingress.
- Confirmed the Grafana Ingress appears in the Flux resource tree.
- Added `docs/20-grafana-private-tailscale-access.md`.
- No tailnet hostname, Tailscale address, credential, Gmail App Password, or other secret was intentionally added to Git.
