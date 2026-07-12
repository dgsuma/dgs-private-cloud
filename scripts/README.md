# Scripts

Run these scripts on the Proxmox host as root.

They are read-only unless explicitly stated otherwise.

```bash
chmod +x ./scripts/*.sh
```

## Scripts

- `health-check.sh` — consolidated host health check.
- `verify-network.sh` — management-network and outbound-HTTPS checks.
- `verify-storage.sh` — storage, VG, and thin-pool checks.
- `collect-host-state.sh` — writes a timestamped, non-secret state report.
