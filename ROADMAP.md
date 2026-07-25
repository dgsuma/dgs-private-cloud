# Roadmap

## Phase 0 — Proxmox foundation

Status: **Complete**

- [x] Install Proxmox VE on `pve01`.
- [x] Configure static management address `192.168.1.201/24`.
- [x] Resolve Archer NX200 IPv4 routing.
- [x] Configure no-subscription repositories.
- [x] Update Proxmox.
- [x] Configure Samsung `vmdata` LVM-thin storage.
- [x] Validate host health.
- [x] Confirm safe headless operation.
- [x] Add UPS hardware protection.

## Retired experiment — ASUS temporary node

Status: **Closed without cluster formation**

- [x] Install Proxmox VE temporarily on the ASUS ADATA SSD.
- [x] Preserve the WDC 1 TB HDD.
- [x] Validate wired networking and time synchronisation.
- [x] Decide not to continue because of old-hardware instability.
- [x] Shut down the ASUS node.
- [x] Remove the ASUS node from the active architecture.
- [ ] Reinstall a desktop Linux distribution only if the laptop is reused.

## Phase 1A — Disposable first-guest validation

Status: **Complete**

- [x] Create Ubuntu VM `100` on `pve01`.
- [x] Validate VM networking.
- [x] Validate DNS and outbound internet.
- [x] Validate QEMU Guest Agent.
- [x] Validate Nginx as a simple workload.
- [x] Shut down the VM.
- [x] Delete VM `100` and its virtual disks after testing.

## Phase 1B — Core Talos platform

Status: **In progress**

- [x] Prepare the GitOps repository structure.
- [x] Install and verify workstation tooling.
- [x] Generate Talos `v1.13.6` custom ISO with QEMU guest agent.
- [x] Upload and transfer-check the Talos ISO.
- [x] Create `talos-cp-01` as VM `210`.
- [x] Reserve `192.168.1.210`.
- [x] Verify Talos maintenance mode and `/dev/sda`.
- [ ] Create `talos-wk-01` as VM `211`.
- [ ] Create `talos-wk-02` as VM `212`.
- [ ] Reserve `192.168.1.211` and `192.168.1.212`.
- [ ] Confirm all worker disk device names.
- [ ] Generate Talos cluster configuration.
- [ ] Apply control-plane and worker configurations.
- [ ] Bootstrap Kubernetes exactly once.
- [ ] Retrieve kubeconfig.
- [ ] Confirm all three nodes are `Ready`.

## Phase 1C — GitOps and private access

Status: **Planned**

- [ ] Bootstrap Flux from the private `dgs-private-cloud` repository.
- [ ] Generate an age identity and configure SOPS.
- [ ] Store only encrypted Kubernetes secrets in Git.
- [ ] Deploy the Tailscale Kubernetes Operator.
- [ ] Keep Proxmox and Kubernetes administration private.

## Phase 1D — Observability and dashboard

Status: **Planned**

- [ ] Deploy local persistent storage.
- [ ] Deploy Prometheus.
- [ ] Deploy Grafana.
- [ ] Deploy Alertmanager.
- [ ] Deploy Loki.
- [ ] Deploy Grafana Alloy for log collection.
- [ ] Deploy Homepage.
- [ ] Expose selected services only through authenticated private access.

## Phase 2 — IoT data platform

Status: **Planned**

- [ ] Deploy PostgreSQL and TimescaleDB.
- [ ] Deploy MQTT.
- [ ] Deploy Node-RED or equivalent automation.
- [ ] Ingest polytunnel temperature, humidity, irrigation, pH, UPS, and camera metadata.
- [ ] Add wellness-only WHOOP notifications through an appropriate integration.
- [ ] Define backup and retention policies.

## Phase 3 — Resilience and permanent expansion

Status: **Planned**

- [ ] Add permanent second and third Proxmox nodes.
- [ ] Define an odd-vote quorum strategy or QDevice.
- [ ] Expand Kubernetes control-plane availability.
- [ ] Introduce NAS or Proxmox Backup Server.
- [ ] Configure scheduled backups.
- [ ] Test restores.
- [ ] Configure UPS telemetry and graceful shutdown.
- [ ] Add VLANs and firewall policies where justified.
