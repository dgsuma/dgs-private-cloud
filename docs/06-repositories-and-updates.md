# Proxmox Repositories and Updates

## Scope

The same repository policy is now applied to both:

```text
pve01     192.168.1.201
asus-pve  192.168.1.203
```

## Repository policy

Enabled:

```text
Debian base repositories
Debian update repository
Debian security repository
pve-no-subscription
```

Disabled:

```text
pve-enterprise
ceph-enterprise
```

The no-subscription repository is appropriate for this non-production home-lab experiment. Ceph is not planned for the temporary two-node cluster.

## Update sequence

Run on each standalone node before cluster formation:

```bash
apt update
apt full-upgrade -y
reboot
```

If a future network fault causes unsuccessful IPv6 repository attempts, IPv4 can be forced temporarily:

```bash
apt -o Acquire::ForceIPv4=true update
apt -o Acquire::ForceIPv4=true full-upgrade -y
```

Do not keep the IPv4 override as a permanent workaround unless the underlying network issue is documented.

## Verified manager versions

```text
pve01:     PVE Manager 9.2.4
asus-pve:  PVE Manager 9.2.4
```

The ASUS enterprise and Ceph enterprise entries were disabled, and the Proxmox no-subscription repository was enabled before updating.

## Health verification

Run on both nodes:

```bash
pveversion -v
systemctl --failed
hostname -f
timedatectl
```

Before joining the cluster, also verify peer connectivity and name resolution:

```bash
ping -c 4 192.168.1.201
ping -c 4 192.168.1.203
getent hosts pve01
getent hosts asus-pve
```

Success criteria:

- both IP addresses respond without packet loss,
- both clocks are synchronised,
- both short names and FQDNs resolve to the correct management addresses,
- both nodes remain free of VMs and containers before the ASUS joins.
