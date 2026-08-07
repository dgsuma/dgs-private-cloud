# Changelog


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
