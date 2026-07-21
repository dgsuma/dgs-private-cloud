# Current State

Verified on **2026-07-21** after completing the first Ubuntu VM and Nginx validation.

## Proxmox topology

| Property | Value |
|---|---|
| Cluster created | No |
| Current topology | One standalone Proxmox host |
| Main operational node | `pve01` |
| Active temporary node | None |
| Provisioned VMs | 1 |
| Provisioned containers | 0 |

## Proxmox host

| Property | `pve01` |
|---|---|
| Platform | Beelink GTi12 |
| FQDN | `pve01.home.arpa` |
| Web URL | `https://192.168.1.201:8006` |
| Management address | `192.168.1.201/24` |
| PVE Manager | `9.2.4` |
| Running kernel | `7.0.14-4-pve` from the latest recorded validation |
| Administration mode | Headless |
| Cluster membership | Standalone |
| Guest count | One VM, no containers |

## First guest

| Property | Value |
|---|---|
| VM ID | `100` |
| Proxmox name | `ubuntu-web-test` |
| Guest hostname | `web-test01` |
| OS | Ubuntu Server 26.04 LTS |
| vCPU | 2 |
| Memory | 4GiB |
| Disk | 32GiB on `vmdata` |
| Bridge | `vmbr0` |
| Reserved IPv4 address | `192.168.1.205` |
| Address method | DHCP with router reservation |
| QEMU Guest Agent | Installed and active |
| OpenSSH | Installed and active |
| Nginx | Installed and active |
| Test content | `/var/www/html/index.html` |
| Validation URL | `http://192.168.1.205` |
| Autostart | Disabled |

## Network

| Property | Value |
|---|---|
| LAN | `192.168.1.0/24` |
| Router | TP-Link Archer NX200 |
| Gateway | `192.168.1.1` |
| DNS | `192.168.1.1` |
| `pve01` address | `192.168.1.201/24` |
| `web-test01` address | `192.168.1.205/24` |
| Connection type | Wired Ethernet for `pve01`; bridged virtual NIC for the VM |
| Proxmox bridge | `vmbr0` |
| Guest address reservation | Active on the Archer NX200 |

The router sees `pve01` and `web-test01` as separate wired clients because the VM has its own virtual NIC and MAC address behind the Proxmox bridge.

## Storage

| Node | Storage | Purpose/status |
|---|---|---|
| `pve01` | Crucial 1TB | Proxmox system disk, `local`, and `local-lvm` |
| `pve01` | Samsung 990 PRO 2TB | Primary guest LVM-thin storage ID `vmdata` |
| VM `100` | 32GiB virtual disk | Thin-provisioned on `vmdata` |
| `local` | Directory storage | Ubuntu ISO and supported file content |

## Power protection

| Property | Value |
|---|---|
| UPS vendor | Eaton |
| Connected devices | Archer router and Beelink `pve01` |
| Hardware power protection | Active |
| UPS monitoring | Not configured |
| Automated graceful shutdown | Not configured |

## Historical ASUS experiment

The ASUS laptop was evaluated as `asus-pve` at `192.168.1.203`. It was never joined to a Proxmox cluster. The experiment was ended after unreliable behaviour was observed, so no cluster-node removal command was required. The laptop now runs Zorin OS and is not part of the private-cloud topology.

## Validation summary

Verified:

- Proxmox VM creation on `vmdata`,
- Ubuntu installation and console access,
- DHCP networking through `vmbr0`,
- router reservation at `192.168.1.205`,
- DNS and outbound package access,
- QEMU Guest Agent communication,
- SSH and SCP from Windows,
- Nginx local response through `curl`,
- browser access from the LAN,
- clean guest shutdown and restart,
- safe Proxmox host shutdown after the guest was stopped.