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

**Status: Operational baseline and travel administration complete; SOPS remains**

- [x] Bootstrap Flux `v2.9.3` from the private `dgs-private-cloud` repository.
- [x] Configure the active Flux path as `clusters/beelink-talos`.
- [x] Use an SSH deploy key for ongoing private-repository access.
- [x] Revoke the temporary GitHub bootstrap PAT.
- [x] Deploy the Tailscale Kubernetes Operator through Flux.
- [x] Confirm `beelink-talos-operator` is connected with `tag:k8s-operator`.
- [x] Install the Tailscale IngressClass and CRDs.
- [x] Keep Proxmox and Kubernetes administration private.
- [x] Validate LG Gram travel administration through WSL2 mirrored networking and Windows Tailscale.
- [x] Validate Kubernetes administration through the Tailscale Kubernetes API proxy from external networks.
- [x] Configure `mel-pve01` as the `192.168.1.0/24` Tailscale subnet router.
- [x] Validate remote `talosctl health` and multi-node `talosctl service` through TCP `50000`.
- [x] Validate direct remote Proxmox SSH and TCP `8006` recovery access.
- [ ] Generate an age identity and configure SOPS.
- [ ] Store only SOPS-encrypted Kubernetes Secrets in Git.
- [ ] Migrate `operator-oauth` from a manually created Secret to encrypted Git management.

## Phase 1E — Persistent storage, observability, and dashboard
**Status: In progress — storage, metrics, logging, Alertmanager email, private Grafana, and Homepage are operational; Flux-managed storage, encrypted secrets, and recovery testing remain**
- [x] Select a Talos-compatible initial persistent-storage solution.
- [x] Add dedicated worker data disks and Talos XFS user volumes.
- [x] Deploy and validate Rancher Local Path Provisioner.
- [x] Validate dynamic PersistentVolume provisioning.
- [x] Prove data persistence across Pod deletion/recreation.
- [x] Validate `Delete` reclaim cleanup for the disposable test.
- [ ] Bring the provisioner under Flux reconciliation.
- [x] Define initial capacity and retention for Prometheus, Grafana, and Alertmanager.
- [x] Deploy Prometheus, Grafana, and Alertmanager through Flux.
- [x] Deploy Loki `18.7.6` and Grafana Alloy `1.11.1`.
- [x] Verify Kubernetes logs in Grafana through Loki/LogQL.
- [x] Configure Alertmanager Gmail email notifications.
- [x] Verify Alertmanager FIRING and RESOLVED delivery.
- [x] Expose Grafana only through authenticated Tailscale access.
- [x] Deploy Homepage and keep it private through Tailscale.
- [x] Add Eaton UPS telemetry and graceful-shutdown monitoring.
- [ ] Test application and database recovery independently of etcd.
## Phase 1F — Jenkins controller and private CI access

**Status: Complete**

- [x] Create Ubuntu Server VM `220` `jenkins-ci`.
- [x] Configure 4 vCPU, 8 GiB RAM, 100 GiB `vmdata` disk, QEMU Guest Agent, and start-at-boot.
- [x] Reserve `192.168.1.213`.
- [x] Install OpenJDK 21, Git, and Jenkins LTS.
- [x] Complete Jenkins administrator setup.
- [x] Join the VM directly to Tailscale.
- [x] Configure Tailscale Serve private HTTPS access.
- [x] Bind Jenkins to loopback-only TCP `8080`.
- [x] Confirm direct LAN access to TCP `8080` is refused.
- [x] Complete `jenkins-learning-smoke` Build `#1`.
- [x] Validate remote mobile-data access through Tailscale.
- [x] Create the `jenkins-baseline-tailscale` Proxmox snapshot.

## Phase 1G — Jenkins build agent and CI-to-GitOps workflow

**Status: Deferred**

- [ ] Create VM `221` `jenkins-agent01`.
- [ ] Install Java, Git, Docker/BuildKit, and CI/security tooling.
- [ ] Connect the agent to the Jenkins controller.
- [ ] Set built-in controller executors to `0`.
- [ ] Move the test Pipeline into a repository `Jenkinsfile`.
- [ ] Build and scan a container image.
- [ ] Push the image to GHCR.
- [ ] Integrate image release with the GitOps source.
- [ ] Let Flux perform Kubernetes continuous delivery.

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

<!-- BEGIN TAILSCALE ROADMAP 2026-08-03 -->
## Phase 4A — Tailscale remote administration

Status: **Implemented and externally verified**

- [x] Install Tailscale directly on `pve01`.
- [x] Register the host as `mel-pve01`.
- [x] Enable and validate the `tailscaled` system service.
- [x] Enable HTTPS certificates for Serve.
- [x] Keep Tailscale Funnel disabled.
- [x] Configure Serve for the Proxmox HTTPS backend.
- [x] Validate Tailscale ping from the LG Gram.
- [x] Validate Proxmox TCP port `8006` from the LG Gram.
- [x] Validate the private Serve URL from the LG Gram on alternate Wi-Fi.
- [x] Validate the private Serve URL from the Moto G84 over mobile data.
- [ ] Enable and test Proxmox two-factor authentication.
- [ ] Verify key-expiry settings for remote infrastructure devices.
- [x] Complete full reboot and power-recovery testing.
- [x] Use `mel-pve01` as the active `192.168.1.0/24` subnet router; a separate Raspberry Pi router is no longer required for the current travel-access design.
<!-- END TAILSCALE ROADMAP 2026-08-03 -->

## 2026-08-16 checkpoint

Completed:

- [x] Alertmanager Gmail FIRING and RESOLVED notification verification.
- [x] Private Grafana HTTPS access through the Tailscale Kubernetes Operator.
- [x] Grafana access without local port-forwarding and remote Android mobile-data validation.
- [x] Flux/GitOps management of the Grafana Tailscale Ingress.
- [x] Homepage `v1.13.2` deployment through Flux.
- [x] Homepage internal `ClusterIP` Service and private Tailscale Ingress.
- [x] Homepage validation from the LG Gram and Moto G84 over mobile data.
- [x] Homepage `CrashLoopBackOff` root-cause analysis and recovery after `/app/config/proxmox.yaml` permission failure.
- [x] Homepage writable log path and allowed-host health-probe configuration.
- [x] Stable Homepage Pod with zero restarts and 20 consecutive HTTP `200` checks.
- [x] Real `KubePodCrashLooping` Alertmanager email observed during the incident.

Next:

- [ ] Bring Local Path Provisioner configuration fully under Flux.
- [ ] Configure SOPS with age and migrate manual Secret workflows, including `operator-oauth`, `alertmanager-smtp`, and `homepage-runtime`.
- [ ] Perform an isolated VM restore test.
- [x] Add Eaton UPS telemetry and graceful-shutdown monitoring.
- [ ] Enrich Homepage with least-privilege service links/widgets without committing credentials.
