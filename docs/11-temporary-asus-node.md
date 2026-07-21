# Temporary ASUS Proxmox Experiment

> **Status: Retired.** This page is retained as historical documentation. The ASUS laptop is not an active Proxmox node.

## Original purpose

The ASUS laptop was evaluated as a short-term Proxmox VE node for learning and possible controlled clustering experiments. The Beelink `pve01` remained the main operational host.

## Verified temporary configuration

| Property | Historical value |
|---|---|
| Node name | `asus-pve` |
| FQDN | `asus-pve.home.arpa` |
| Management address | `192.168.1.203/24` |
| Gateway / DNS | `192.168.1.1` |
| Connection | Wired Cat 5e Ethernet |
| PVE Manager | `9.2.4` |
| System disk | ADATA 240GB SSD |
| Preserved disk | WDC 1TB HDD |
| Repository | `pve-no-subscription` |
| Time zone | `Australia/Melbourne` |
| NTP | Active and synchronised |
| Cluster membership | Never joined |
| Guests | None |

## Outcome

The laptop showed unreliable behaviour during the evaluation, including repeated web-session problems and incomplete monitoring data. The user decided not to continue using the old hardware as a Proxmox node.

The experiment ended before:

- peer hostname configuration,
- cluster creation,
- cluster join,
- quorum testing,
- VM migration,
- HA or Ceph deployment.

Because no cluster was created, `pvecm delnode` was not required.

## Current ASUS state

The ADATA SSD was reused for Zorin OS. The laptop now serves as a desktop Linux system and is outside the private-cloud topology.

The previous address `192.168.1.203` is no longer reserved for an active Proxmox node and may be reused only after confirming the router configuration.

## Historical safety boundary

During the temporary installation, the ADATA 240GB SSD was the Proxmox target and the WDC 1TB HDD was preserved. This note remains useful when reviewing the experiment, but no current Proxmox operation should target the ASUS disks.