# Runbook: Host Health Check

Run:

```bash
bash scripts/health-check.sh
```

Manual checks:

```bash
pveversion -v
systemctl --failed
free -h
df -hT
pvesm status
ip -br address
ip route
lvs -a -o lv_name,vg_name,lv_attr,lv_size,data_percent,metadata_percent
```

Success criteria:

- No failed systemd units.
- `vmbr0` has `192.168.1.201/24`.
- Default route uses `192.168.1.1`.
- `local`, `local-lvm`, and `vmdata` are active.
- Thin-pool data and metadata usage are below alert thresholds.
