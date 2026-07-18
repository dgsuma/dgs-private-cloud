# Changelog

All notable documentation and infrastructure-state changes are recorded here.

## [0.3.0] - 2026-07-18

### Added

- Temporary ASUS Proxmox node documentation.
- ADR for the short-lived two-node experiment.
- Safe temporary-node removal runbook for the later Linux Mint reinstall.
- UPS hardware inventory and updated two-host topology.
- Sanitised pre-cluster hostname and connectivity evidence.

### Completed infrastructure

- Installed Proxmox VE on the ASUS 240GB ADATA SSD while preserving the WDC 1TB HDD.
- Assigned `asus-pve.home.arpa` the static management address `192.168.1.203/24`.
- Configured the Proxmox no-subscription repository policy on the ASUS node.
- Updated both nodes to PVE Manager `9.2.4`.
- Verified bidirectional wired connectivity with zero packet loss.
- Verified NTP synchronisation and the `Australia/Melbourne` time zone on both nodes.
- Confirmed the Archer LAN 3/WAN port is functioning as a LAN connection for the ASUS node.
- Connected the router, Beelink, and ASUS laptop to the Eaton UPS.

### Pending

- Cross-node hostname resolution is not yet configured.
- The Proxmox cluster has not yet been created.
- UPS monitoring and automated shutdown are not yet configured.

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

- Proxmox VE 9.2 installation on the Crucial 1TB SSD.
- Archer NX200 IPv4 recovery through a custom Vodafone IPv4 profile.
- Samsung 990 PRO 2TB LVM-thin configuration.
- Thin metadata extension and monitoring.
- Final validation state with zero failed systemd units.

## [0.1.0] - 2026-07-11

### Added

- Initial README.
- Proprietary licence.

### Completed infrastructure

- First Proxmox node installed and operational.
- No VMs or containers deployed.
