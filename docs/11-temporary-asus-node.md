# Temporary ASUS Proxmox Node

## Purpose

The ASUS laptop is a short-term Proxmox VE node for learning and controlled experiments. The Beelink `pve01` remains the main operational host. After approximately one month, the ASUS node will be removed from the cluster and the laptop will be reinstalled with Linux Mint for long-term desktop use.

## Verified configuration

| Property | Value |
|---|---|
| Node name | `asus-pve` |
| FQDN | `asus-pve.home.arpa` |
| Management address | `192.168.1.203/24` |
| Management URL | `https://192.168.1.203:8006` |
| Gateway / DNS | `192.168.1.1` |
| Connection | Wired Cat 5e Ethernet through Archer LAN 3 |
| PVE Manager | `9.2.4` |
| System disk | ADATA 240GB SSD |
| Preserved disk | WDC 1TB HDD |
| Repository | `pve-no-subscription` |
| Enterprise repositories | Disabled |
| Time zone | `Australia/Melbourne` |
| NTP | Active and synchronised |
| Cluster membership | Not yet joined |
| Guests | None |

## Disk-safety boundary

The temporary Proxmox installation uses the **ADATA 240GB SSD**. The **WDC 1TB HDD must remain untouched** unless a later task explicitly identifies and verifies it.

Before any destructive storage command, verify the target with:

```bash
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
```

Do not assume Linux device names remain constant between boots.

## Completed validation

From `pve01`:

```bash
ping -c 4 192.168.1.203
```

Result: four replies and zero packet loss.

From `asus-pve`:

```bash
ping -c 4 192.168.1.201
```

Result: four replies and zero packet loss.

Both systems reported:

```text
Time zone: Australia/Melbourne
System clock synchronised: yes
NTP service: active
RTC in local TZ: no
```

## Current blocker

The peer names do not yet resolve across nodes. Add the following mappings to `/etc/hosts` on both systems:

```text
192.168.1.201  pve01.home.arpa     pve01
192.168.1.203  asus-pve.home.arpa  asus-pve
```

Validate before cluster creation:

```bash
getent hosts pve01
getent hosts pve01.home.arpa
getent hosts asus-pve
getent hosts asus-pve.home.arpa
```

## Cluster-join sequence

1. Verify both nodes are fully updated and rebooted.
2. Verify the ASUS contains no VMs or containers.
3. Create cluster `homelab` on `pve01` using `192.168.1.201` for Link 0.
4. Copy join information from `pve01`.
5. Join `asus-pve` using `192.168.1.203` for its cluster link.
6. Verify:

```bash
pvecm status
pvecm nodes
```

Success criteria:

```text
Nodes:          2
Expected votes: 2
Total votes:    2
Quorate:        Yes
```

## Operating restrictions

This two-node design is temporary and intended for experiments only.

- Do not enable HA.
- Do not deploy Ceph.
- Do not place the only copy of important data on `asus-pve`.
- Keep both nodes online while performing cluster configuration changes.
- Back up or delete every ASUS guest before removal.
- Do not routinely force expected votes to one.

## Laptop-specific configuration

Prevent suspend and hibernation:

```bash
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Set in `/etc/systemd/logind.conf`:

```ini
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

Apply:

```bash
systemctl restart systemd-logind
```

Confirm cooling vents remain unobstructed and monitor temperatures during the experiment.

## Power protection

The ASUS laptop, Beelink, and Archer router are connected to the Eaton UPS. This currently provides only hardware power protection. UPS monitoring and automatic Proxmox shutdown are separate future tasks.

## Planned retirement

When the experiment ends, use [the removal runbook](runbooks/remove-temporary-asus-node.md). The correct sequence is:

1. remove or migrate all ASUS workloads,
2. shut down the ASUS,
3. remove `asus-pve` from cluster membership on `pve01`,
4. verify the one-node cluster is healthy,
5. reinstall Linux Mint on the ADATA 240GB SSD,
6. preserve the WDC 1TB HDD unless its future use is explicitly decided.
