# Roadmap

## Phase 0 — Proxmox foundation

**Status: Complete**

- [x] Install Proxmox VE on `pve01`.
- [x] Configure static management address `192.168.1.201/24`.
- [x] Resolve Archer NX200 IPv4 routing.
- [x] Configure no-subscription repositories.
- [x] Update Proxmox.
- [x] Configure Samsung `vmdata` LVM-thin storage.
- [x] Validate host health and safe headless operation.
- [x] Add UPS hardware protection.

## Retired experiment — ASUS temporary node

**Status: Closed without cluster formation**

- [x] Install Proxmox VE temporarily on the ASUS ADATA SSD.
- [x] Preserve the WDC 1 TB HDD.
- [x] Validate wired networking and time synchronisation.
- [x] End the experiment because of old-hardware instability.
- [x] Remove the ASUS node from the active architecture.

## Phase 1A — Disposable first-guest validation

**Status: Complete**

- [x] Create Ubuntu VM `100` on `pve01`.
- [x] Validate networking, DNS, internet access, QEMU Guest Agent, and Nginx.
- [x] Delete VM `100` and its virtual disks after testing.

## Phase 1B — Core Talos Kubernetes platform

**Status: Complete**

- [x] Prepare the repository structure and workstation tooling.
- [x] Generate and upload Talos `v1.13.6` installation media.
- [x] Create control-plane VM `210`.
- [x] Create worker VMs `211` and `212`.
- [x] Reserve `192.168.1.210`, `.211`, and `.212`.
- [x] Validate `/dev/sda` and maintenance-mode connectivity on every node.
- [x] Generate and validate Talos cluster configuration.
- [x] Apply control-plane and worker configurations.
- [x] Bootstrap Kubernetes exactly once.
- [x] Retrieve kubeconfig.
- [x] Confirm all three nodes `Ready`.
- [x] Validate system pods and worker scheduling.
- [x] Detach installation media.

## Phase 1C — Recovery baseline

**Status: Backup baseline complete; restore testing remains**

- [x] Create the first off-cluster Talos etcd snapshot.
- [x] Create the second off-cluster Talos etcd snapshot.
- [x] Generate SHA-256 files for both snapshots.
- [x] Prepare the Seagate One Touch 2 TB as ext4 backup storage.
- [x] Configure `usb-backup-2tb` with `is_mountpoint 1`.
- [x] Create full backups of VMs `210`, `211`, and `212`.
- [x] Revalidate cluster health after restart.
- [x] Configure retention: last 3, weekly 2, monthly 1.
- [x] Document safe disable, unmount, and disconnect procedure.
- [ ] Perform an isolated VM restore test.
- [ ] Perform a documented Talos disaster-recovery rehearsal in an isolated environment.
- [ ] Store an encrypted second copy of critical Talos recovery material.

## Phase 1D — GitOps and private access

**Status: Operational baseline complete; SOPS remains**

- [x] Bootstrap Flux `v2.9.3` from the private `dgs-private-cloud` repository.
- [x] Configure the active Flux path as `clusters/beelink-talos`.
- [x] Use an SSH deploy key for ongoing private-repository access.
- [x] Revoke the temporary GitHub bootstrap PAT.
- [x] Deploy the Tailscale Kubernetes Operator through Flux.
- [x] Confirm `beelink-talos-operator` is connected with `tag:k8s-operator`.
- [x] Install the Tailscale IngressClass and CRDs.
- [x] Keep Proxmox and Kubernetes administration private.
- [ ] Generate an age identity and configure SOPS.
- [ ] Store only SOPS-encrypted Kubernetes Secrets in Git.
- [ ] Migrate `operator-oauth` from a manually created Secret to encrypted Git management.

## Phase 1E — Persistent storage, observability, and dashboard

**Status: Next**

- [ ] Select a Talos-compatible initial persistent-storage solution.
- [ ] Validate dynamic PersistentVolume provisioning.
- [ ] Define capacity and retention for metrics, dashboards, and logs.
- [ ] Deploy Prometheus, Grafana, and Alertmanager.
- [ ] Deploy Loki and Grafana Alloy.
- [ ] Expose selected dashboards only through authenticated Tailscale access.
- [ ] Deploy Homepage.
- [ ] Add Eaton UPS telemetry and graceful-shutdown monitoring.
- [ ] Test application and database recovery independently of etcd.

## Phase 2 — IoT and wellness data platform

**Status: Planned**

- [ ] Deploy PostgreSQL and TimescaleDB.
- [ ] Deploy MQTT.
- [ ] Deploy Node-RED or equivalent automation.
- [ ] Ingest polytunnel temperature, humidity, irrigation, pH, UPS, and camera metadata.
- [ ] Integrate supported WHOOP cloud data for wellness-pattern analysis.
- [ ] Back up persistent-volume contents independently of etcd and VM archives.

## Phase 3 — Resilience and permanent expansion

**Status: Planned**

- [ ] Add permanent second and third Proxmox nodes.
- [ ] Define an odd-vote quorum strategy or QDevice.
- [ ] Expand Kubernetes control-plane availability.
- [ ] Introduce NAS or Proxmox Backup Server.
- [ ] Configure scheduled backups and tested retention.
- [ ] Test restores regularly.
- [ ] Add VLANs and firewall policies where justified.
