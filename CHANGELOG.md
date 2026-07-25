# Changelog

All notable documentation and infrastructure-state changes are recorded here.

## [0.4.0] - 2026-07-25

### Added

- Phase 1 GitOps repository structure for Talos, Kubernetes infrastructure, applications, and the home cluster.
- Workstation verification script for Git, GitHub CLI, kubectl, talosctl, Flux, SOPS, and age.
- Talos Image Factory schematic using `siderolabs/qemu-guest-agent`.
- Talos Kubernetes Phase 1 implementation record.
- ADR for the disposable first-guest validation.
- ADR for the initial Talos Kubernetes architecture.
- Worker-creation and Kubernetes-bootstrap runbook.

### Completed infrastructure

- Removed obsolete Ubuntu validation VM `100` and confirmed no `vm-100-*` disks remained.
- Confirmed `vmdata` remained active and healthy after VM deletion.
- Updated the administration workstation toolset:
  - GitHub CLI `2.96.0`,
  - kubectl `1.36.3`,
  - Flux CLI `2.9.3`,
  - talosctl `1.13.6`,
  - SOPS `3.13.2`,
  - age `1.3.1`.
- Generated Talos `v1.13.6` custom ISO with QEMU guest-agent support.
- Verified the ISO’s SHA-256 remained identical after upload to `pve01`.
- Created control-plane VM `210` as `talos-cp-01`.
- Reserved `192.168.1.210`.
- Booted Talos into maintenance mode.
- Verified Talos API connectivity on TCP `50000`.
- Confirmed `/dev/sda` is the 64 GiB installation disk.

### Architecture changes

- Retired the temporary ASUS node from the active topology.
- Confirmed the ASUS experiment ended without forming a Proxmox cluster.
- Changed the immediate platform direction from a temporary two-host Proxmox experiment to a three-VM Talos Kubernetes cluster on standalone `pve01`.
- Reserved `192.168.1.220` for a future highly available Kubernetes API endpoint; it is not currently used.

### Pending

- Create workers VM `211` and VM `212`.
- Generate and apply Talos machine configurations.
- Bootstrap Kubernetes.
- Bootstrap Flux.
- Configure SOPS with age.
- Deploy Tailscale Operator, observability, logging, and Homepage.

## [0.3.0] - 2026-07-18

### Added

- Temporary ASUS Proxmox node documentation.
- ADR for the short-lived two-node experiment.
- Safe temporary-node removal runbook for the later Linux reinstall.
- UPS hardware inventory and updated two-host topology.
- Sanitised pre-cluster hostname and connectivity evidence.

### Completed infrastructure

- Installed Proxmox VE on the ASUS 240 GB ADATA SSD while preserving the WDC 1 TB HDD.
- Assigned `asus-pve.home.arpa` the static management address `192.168.1.203/24`.
- Configured the Proxmox no-subscription repository policy on the ASUS node.
- Updated both nodes to PVE Manager `9.2.4`.
- Verified bidirectional wired connectivity with zero packet loss.
- Verified NTP synchronisation and the `Australia/Melbourne` time zone on both nodes.
- Confirmed the Archer LAN 3/WAN port is functioning as a LAN connection for the ASUS node.
- Connected the router, Beelink, and ASUS laptop to the Eaton UPS.

### Outcome recorded later

- The temporary ASUS experiment was abandoned because the old hardware was unstable.
- The ASUS node was shut down.
- No Proxmox cluster was formed.

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
