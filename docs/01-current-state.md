# Current State

Verified on **2026-07-18** after preparing the ASUS laptop as a temporary second Proxmox host.

## Cluster state

| Property | Value |
|---|---|
| Cluster created | No |
| Current topology | Two standalone Proxmox hosts |
| Main operational node | `pve01` |
| Temporary candidate node | `asus-pve` |
| Cross-node IP connectivity | Verified in both directions |
| Time synchronisation | Active on both nodes |
| Cross-node hostname resolution | Not yet configured |
| Guests | None on either node |

## Proxmox hosts

| Property | `pve01` | `asus-pve` |
|---|---|---|
| Platform | Beelink GTi12 | ASUS legacy laptop |
| FQDN | `pve01.home.arpa` | `asus-pve.home.arpa` |
| Web URL | `https://192.168.1.201:8006` | `https://192.168.1.203:8006` |
| PVE Manager | `9.2.4` | `9.2.4` |
| Running kernel | `7.0.14-4-pve` from previous validation | Not recorded in this update |
| Administration mode | Headless | Temporary laptop server |
| Cluster membership | Standalone | Standalone; join pending |

## Network

| Property | Value |
|---|---|
| LAN | `192.168.1.0/24` |
| Router | TP-Link Archer NX200 |
| Gateway | `192.168.1.1` |
| DNS | `192.168.1.1` |
| `pve01` address | `192.168.1.201/24` |
| `asus-pve` address | `192.168.1.203/24` |
| Connection type | Wired Cat 5e Ethernet |
| ASUS router port | LAN 3/WAN port operating as LAN |
| `pve01` to `asus-pve` ping | 4 transmitted, 4 received, 0% loss |
| `asus-pve` to `pve01` ping | 4 transmitted, 4 received, 0% loss |
| Observed LAN latency | Below 1 ms in the recorded checks |

## Hostname validation

Verified:

```text
pve01 hostname:       pve01
pve01 hostname -f:    pve01.home.arpa
asus-pve hostname:    asus-pve
asus-pve hostname -f: asus-pve.home.arpa
```

Current limitation:

- `pve01` resolves its own hostname but did not return a result for `asus-pve`.
- `asus-pve` resolves its own hostname but did not return a result for `pve01`.
- Both peer mappings must be added to `/etc/hosts` on both nodes before cluster creation.

Required mappings:

```text
192.168.1.201  pve01.home.arpa     pve01
192.168.1.203  asus-pve.home.arpa  asus-pve
```

## Time

| Property | `pve01` | `asus-pve` |
|---|---|---|
| Time zone | `Australia/Melbourne` | `Australia/Melbourne` |
| System clock synchronised | Yes | Yes |
| NTP service | Active | Active |
| RTC in local time | No | No |

## Storage

| Node | Storage | Purpose/status |
|---|---|---|
| `pve01` | Crucial 1TB | Proxmox system disk, `local`, and `local-lvm` |
| `pve01` | Samsung 990 PRO 2TB | Primary guest LVM-thin storage ID `vmdata` |
| `asus-pve` | ADATA 240GB SSD | Temporary Proxmox system disk |
| `asus-pve` | WDC 1TB HDD | Preserved and not configured for Proxmox |

## Power protection

| Property | Value |
|---|---|
| UPS vendor | Eaton |
| Connected devices | Archer router, Beelink `pve01`, ASUS `asus-pve` |
| Hardware power protection | Active |
| UPS monitoring | Not configured |
| Automated graceful shutdown | Not configured |

## Guest state

```text
pve01 VMs:        0
pve01 containers: 0
asus-pve VMs:     0
asus-pve containers: 0
```
