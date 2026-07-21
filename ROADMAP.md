# Roadmap

## Phase 0 — Main host foundation

Status: **Complete**

- [x] Install Proxmox VE on `pve01`.
- [x] Configure static management address `192.168.1.201/24`.
- [x] Resolve Archer NX200 IPv4 routing.
- [x] Configure no-subscription repositories.
- [x] Update Proxmox.
- [x] Configure Samsung `vmdata` LVM-thin storage.
- [x] Validate host health.
- [x] Confirm safe headless operation.

## Phase 1 — Temporary ASUS experiment

Status: **Closed without cluster formation**

- [x] Install Proxmox VE on the ASUS ADATA 240GB SSD.
- [x] Preserve the ASUS WDC 1TB HDD.
- [x] Assign `asus-pve.home.arpa` to `192.168.1.203/24`.
- [x] Configure no-subscription repositories and update the node.
- [x] Verify bidirectional wired connectivity.
- [x] Verify time zone and NTP synchronisation.
- [x] Connect the router and both systems to the Eaton UPS.
- [x] Evaluate the laptop as a possible temporary node.
- [x] End the experiment after instability and unreliable operation were observed.
- [x] Confirm that no Proxmox cluster had been created and no cluster-node removal was required.
- [x] Return the ASUS laptop to desktop use with Zorin OS.

Cancelled scope:

- Cross-node hostname configuration.
- Cluster creation.
- Cluster join.
- Migration tests.
- Two-node quorum exercises.
- HA and Ceph were never planned for this temporary design.

## Phase 2 — First guest validation

Status: **Core validation complete**

- [x] Upload an Ubuntu Server ISO to `local`.
- [x] Create a small test VM on `vmdata`.
- [x] Allocate 2 vCPU, 4GiB RAM, and a 32GiB virtual disk.
- [x] Verify VM networking through `vmbr0`.
- [x] Verify DNS and outbound internet access.
- [x] Install and validate QEMU Guest Agent.
- [x] Install and validate OpenSSH and Nginx.
- [x] Create and serve a static test page.
- [x] Reserve `192.168.1.205` for `web-test01`.
- [x] Verify clean shutdown and restart.
- [ ] Create a snapshot.
- [ ] Validate snapshot rollback.
- [ ] Decide whether to retain the VM, convert it to a template source, or rebuild from cloud-init.

## Phase 3 — Backup and resilience

- [ ] Select an external backup destination.
- [ ] Configure scheduled Proxmox backups.
- [ ] Test a full restore.
- [x] Add UPS hardware protection.
- [ ] Record the exact UPS model and load measurements.
- [ ] Configure UPS monitoring.
- [ ] Configure graceful shutdown on extended power loss.
- [ ] Export and protect host configuration.

## Phase 4 — Security hardening

- [ ] Create a named administrator account.
- [ ] Enable two-factor authentication.
- [ ] Configure SSH keys.
- [ ] Restrict password-based SSH.
- [ ] Define Proxmox firewall policy.
- [ ] Document private remote access through Tailscale or WireGuard.
- [ ] Keep TCP 8006 private.

## Phase 5 — Permanent multi-node private cloud

- [ ] Select permanent second and third Proxmox nodes.
- [ ] Standardise hostnames and addressing.
- [ ] Define an odd-vote quorum strategy or QDevice.
- [ ] Define shared backup/storage strategy.
- [ ] Test migration and node-failure procedures.

## Phase 6 — Kubernetes platform

- [ ] Define staging cluster VM sizes.
- [ ] Define production-like cluster VM sizes.
- [ ] Create VM templates.
- [ ] Automate VM provisioning.
- [ ] Deploy Kubernetes control-plane and worker nodes.
- [ ] Add monitoring, logging, ingress, and secrets management.