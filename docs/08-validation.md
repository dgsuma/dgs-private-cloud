# Validation

## Host validation

```bash
pveversion -v
systemctl --failed
```

Verified:

```text
PVE Manager:          9.2.4
Running kernel:       7.0.14-4-pve
Failed systemd units: 0
```

## Network validation

```bash
ping -c 4 192.168.1.1
curl -4 --connect-timeout 10 -I https://deb.debian.org
```

Verified:

```text
Gateway reachable
HTTP/2 200
```

## Storage validation

```bash
pvesm status
```

Verified:

```text
local      active
local-lvm  active
vmdata     active
```

```bash
lvs -a -o lv_name,vg_name,lv_attr,lv_size,data_percent,metadata_percent
```

Verified:

```text
thin_vmdata  vg_vmdata  approximately 1.73 TiB
Data%:       0.00
Meta%:       1.46
```

```bash
lvs -o lv_name,vg_name,seg_monitor vg_vmdata/thin_vmdata
```

Verified:

```text
thin_vmdata  vg_vmdata  monitored
```

## Current acceptance criteria

- [x] Host boots successfully.
- [x] Web UI is reachable.
- [x] Static management address is correct.
- [x] IPv4 outbound HTTPS works.
- [x] Repositories update successfully.
- [x] Current kernel is active.
- [x] No failed systemd units.
- [x] All three storage IDs are active.
- [x] `vmdata` is empty and ready.
- [x] Thin metadata is appropriately sized.
- [x] Thin-pool monitoring is enabled.
- [x] Host can be operated headlessly.
- [ ] A guest VM has been created and validated.
