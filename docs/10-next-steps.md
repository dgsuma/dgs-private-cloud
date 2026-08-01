# Next Steps

## Priority 1 — Prove recovery

The platform now has backups, but a backup is not fully trusted until restore has been tested.

1. Connect, mount, and enable `usb-backup-2tb`.
2. Choose one worker backup for a controlled restore test.
3. Restore to a different VM ID with networking initially disconnected or isolated.
4. Confirm VM configuration and bootability without affecting the production cluster.
5. Remove the test VM after documenting results.
6. Do not attempt an etcd restore on the only working cluster; rehearse it only in an isolated recovery exercise.

## Priority 2 — Protect recovery credentials

Create an encrypted second copy of:

- `talosconfig`,
- kubeconfig,
- generated Talos machine configurations,
- etcd snapshots and `.sha256` files,
- the documentation required to rebuild the VMs.

Store the copy on a second physical device or encrypted off-site location. Never commit it.

## Priority 3 — Automate safe backups

- Decide whether the external HDD remains disconnected except during manual backup sessions.
- If it remains removable, prefer a documented manual checklist over unattended schedules.
- If it remains connected, create scheduled Proxmox backups and alerts for failures.
- Schedule regular etcd snapshots from the LG Gram or a secure management host.
- Define snapshot and VM-backup retention independently.

## Priority 4 — GitOps and private access

- Bootstrap Flux.
- Configure SOPS with age.
- Commit only encrypted Kubernetes secrets.
- Deploy Tailscale Operator or another approved private-access method.
- Keep Proxmox, Talos, Kubernetes, and monitoring endpoints private.

## Priority 5 — Persistent storage and observability

- Select initial Kubernetes persistent storage.
- Deploy Prometheus, Grafana, Alertmanager, Loki, and Alloy.
- Deploy Homepage.
- Add Eaton UPS telemetry and graceful shutdown.

## Priority 6 — Application platforms

- Deploy PostgreSQL plus TimescaleDB.
- Add MQTT and automation for polytunnel sensors.
- Add supported WHOOP cloud data for wellness-pattern analytics.
- Define application-data backups; etcd does not contain persistent-volume contents.

## Exit criteria for the next milestone

- [ ] One VM restore completes successfully in isolation.
- [ ] Recovery instructions are verified by following them from a clean session.
- [ ] Critical Talos credentials and snapshots have an encrypted second copy.
- [ ] Flux reconciles the home cluster.
- [ ] SOPS-encrypted secrets are used.
- [ ] Private remote access is operational.
