# Current State

Verified on **2026-07-11** after installation, updates, network recovery, and storage configuration.

## Hypervisor

| Property | Value |
|---|---|
| Hostname | `pve01` |
| FQDN | `pve01.home.arpa` |
| Proxmox VE package | `9.2.0` |
| PVE Manager | `9.2.4` |
| Running kernel | `7.0.14-4-pve` |
| Failed systemd units | `0` |
| Administration mode | Headless |
| Web URL | `https://192.168.1.201:8006` |

## Network

| Property | Value |
|---|---|
| LAN | `192.168.1.0/24` |
| Proxmox management IP | `192.168.1.201/24` |
| Gateway | `192.168.1.1` |
| DNS | `192.168.1.1` |
| Bridge | `vmbr0` |
| Bridge port | `nic0` |
| Management NIC MAC | `B0:41:6F:12:9A:69` |
| Router | TP-Link Archer NX200 |
| Router WAN profile | `Vodafone-IPv4` |
| WAN APN | `live.vodafone.com` |
| WAN PDP type | IPv4 |
| WAN authentication | None |

## Storage

| Storage ID | Type | Approximate usable capacity | Device/use |
|---|---:|---:|---|
| `local` | Directory | 94 GiB | ISOs, templates, snippets, temporary files |
| `local-lvm` | LVM-thin | 793.8 GiB | Secondary/test guest disks |
| `vmdata` | LVM-thin | 1.73 TiB | Primary VM/LXC disks |

## Guest state

```text
VMs:        0
Containers: 0
Templates:  0
```

## Validation output

```text
pvesm status:
local       active
local-lvm   active
vmdata      active
```

```text
thin_vmdata:
Data%:       0.00
Meta%:       1.46
Metadata:    approximately 1.11 GiB
Monitoring:  enabled
```
