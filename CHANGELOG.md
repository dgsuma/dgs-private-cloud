# Changelog

All notable documentation and infrastructure-state changes are recorded here.

## [0.6.0] - 2026-08-01

### Added

- External USB backup lifecycle and Proxmox VM-backup runbook.
- Complete backup-and-recovery baseline record.
- Fresh-PowerShell Talos authentication and etcd-snapshot procedure.
- Updated host, guest, Kubernetes, network, and storage inventories.

### Completed infrastructure

- Updated Proxmox VE Manager to `9.2.6` as observed in the web interface.
- Connected and identified a Seagate One Touch 2 TB USB HDD.
- Removed the factory exFAT layout and created an ext4 filesystem.
- Mounted the drive at `/mnt/pve/usb-backup-2tb`.
- Registered Proxmox directory storage `usb-backup-2tb` with content type `backup`.
- Enabled mount-point protection with `is_mountpoint 1`.
- Configured retention: keep last 3, weekly 2, monthly 1.
- Created compressed full backups of Talos VMs `210`, `211`, and `212`.
- Restarted the Talos cluster and reconfirmed every node `Ready`.
- Re-ran `talosctl health` successfully after the backup cycle.
- Created a second off-cluster Talos etcd snapshot and SHA-256 file.
- Disabled the USB storage, flushed pending writes, unmounted it, and disconnected it safely.

### Backup artefacts recorded

- `vzdump-qemu-210-2026_08_01-10_29_43.vma.zst` — 432.11 MiB.
- `vzdump-qemu-211-2026_08_01-10_31_58.vma.zst` — 270.95 MiB.
- `vzdump-qemu-212-2026_08_01-10_33_27.vma.zst` — 251.83 MiB.
- `dgs-homelab-etcd-2026-07-26_192642.snapshot` with SHA-256 file.
- `dgs-homelab-etcd-2026-08-01_090643.snapshot` with SHA-256 file.

### Pending

- Perform and document an isolated restore test.
- Add a second encrypted copy of Talos recovery material on separate physical storage.
- Automate snapshot and backup scheduling only after the removable-disk operating model is finalised.
- Bootstrap Flux and configure SOPS.

## [0.5.0] - 2026-07-26

### Added

- Operational three-node Talos Kubernetes topology documentation.
- Detailed Talos cluster-bootstrap implementation record.
- Talos etcd snapshot runbook and reusable workstation script.
- Kubernetes, guest, host, and network inventory updates.

### Completed infrastructure

- Created Talos worker VMs `211` and `212` by full cloning VM `210`.
- Configured 4 vCPU, 8 GiB RAM, 64 GiB disks, VirtIO networking, and disk-first boot order.
- Reserved `192.168.1.211` and `192.168.1.212`.
- Validated maintenance-mode connectivity and `/dev/sda` on all nodes.
- Generated and validated node-specific Talos configurations.
- Applied control-plane and worker configurations.
- Bootstrapped the first control-plane node exactly once.
- Retrieved kubeconfig and confirmed all nodes `Ready`.
- Confirmed CoreDNS, Flannel, kube-proxy, API server, controller manager, and scheduler running.
- Validated workload distribution using four Nginx replicas.
- Detached the Talos ISO from all three VMs.
- Created and SHA-256-verified the first off-cluster etcd snapshot.

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
- Installed and verified current workstation tooling.
- Generated Talos `v1.13.6` custom ISO with QEMU guest-agent support.
- Verified the ISO SHA-256 remained identical after upload to `pve01`.
- Created control-plane VM `210` as `talos-cp-01`.
- Reserved `192.168.1.210`.
- Booted Talos into maintenance mode.
- Verified Talos API connectivity on TCP `50000`.
- Confirmed `/dev/sda` is the 64 GiB installation disk.

## [0.3.0] - 2026-07-18

### Added

- Temporary ASUS Proxmox node documentation.
- ADR for the short-lived two-node experiment.
- Safe temporary-node removal runbook.
- UPS hardware inventory and updated two-host topology.

### Outcome

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

## [0.1.0] - 2026-07-11

### Added

- Initial README.
- Proprietary licence.
- First Proxmox node installed and operational.
