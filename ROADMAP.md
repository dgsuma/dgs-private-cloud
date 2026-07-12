# Roadmap

## Phase 0 — Host foundation

Status: **Complete**

- [x] Install Proxmox VE.
- [x] Configure static management address.
- [x] Resolve Archer NX200 IPv4 routing.
- [x] Configure no-subscription repositories.
- [x] Update Proxmox.
- [x] Configure Samsung `vmdata` LVM-thin storage.
- [x] Validate host health.
- [x] Confirm safe headless operation.

## Phase 1 — First guest validation

Status: **Next**

- [ ] Upload an Ubuntu Server ISO or cloud image to `local`.
- [ ] Create a small test VM on `vmdata`.
- [ ] Verify VM networking through `vmbr0`.
- [ ] Verify DNS and outbound internet access.
- [ ] Test guest-agent reporting.
- [ ] Test snapshot and rollback.
- [ ] Delete the test VM after validation or retain it as a template source.

## Phase 2 — Backup and resilience

- [ ] Select an external backup destination.
- [ ] Configure scheduled Proxmox backups.
- [ ] Test a full restore.
- [ ] Add UPS hardware.
- [ ] Configure graceful shutdown on extended power loss.
- [ ] Export and protect host configuration.

## Phase 3 — Security hardening

- [ ] Create a named administrator account.
- [ ] Enable two-factor authentication.
- [ ] Configure SSH keys.
- [ ] Restrict password-based SSH.
- [ ] Define Proxmox firewall policy.
- [ ] Document private remote access through Tailscale or WireGuard.
- [ ] Keep TCP 8006 private.

## Phase 4 — Multi-node private cloud

- [ ] Prepare second and third Proxmox nodes.
- [ ] Standardise hostnames and addressing.
- [ ] Validate time synchronisation.
- [ ] Form the Proxmox cluster.
- [ ] Define quorum strategy.
- [ ] Define shared backup/storage strategy.
- [ ] Test migration and node-failure procedures.

## Phase 5 — Kubernetes platform

- [ ] Define staging cluster VM sizes.
- [ ] Define production-like cluster VM sizes.
- [ ] Create VM templates.
- [ ] Automate VM provisioning.
- [ ] Deploy Kubernetes control-plane and worker nodes.
- [ ] Add monitoring, logging, ingress, and secrets management.
