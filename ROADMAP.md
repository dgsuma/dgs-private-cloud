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

## Phase 1 — Temporary second-node experiment

Status: **In progress**

- [x] Install Proxmox VE on the ASUS ADATA 240GB SSD.
- [x] Preserve the ASUS WDC 1TB HDD.
- [x] Assign `asus-pve.home.arpa` to `192.168.1.203/24`.
- [x] Configure no-subscription repositories and update the node.
- [x] Verify bidirectional wired connectivity.
- [x] Verify time zone and NTP synchronisation.
- [x] Connect the router and both Proxmox hosts to the Eaton UPS.
- [ ] Add peer mappings to `/etc/hosts` on both nodes.
- [ ] Verify cross-node hostname and FQDN resolution.
- [ ] Create the cluster on `pve01`.
- [ ] Join `asus-pve` as a temporary node.
- [ ] Disable laptop sleep, hibernation, and lid-triggered suspend.
- [ ] Record the two-node quorum operating procedure.
- [ ] Test a disposable VM or LXC on `asus-pve`.
- [ ] Test migration without introducing HA or Ceph.
- [ ] Remove `asus-pve` cleanly after the experiment.
- [ ] Reinstall Linux Mint on the ASUS ADATA SSD.

## Phase 2 — First guest validation

Status: **After temporary cluster formation**

- [ ] Upload an Ubuntu Server ISO or cloud image to `local`.
- [ ] Create a small test VM on `vmdata`.
- [ ] Verify VM networking through `vmbr0`.
- [ ] Verify DNS and outbound internet access.
- [ ] Test guest-agent reporting.
- [ ] Test snapshot and rollback.
- [ ] Delete the test VM after validation or retain it as a template source.

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
