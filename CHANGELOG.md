# Changelog

All notable documentation and infrastructure-state changes are recorded here.

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
