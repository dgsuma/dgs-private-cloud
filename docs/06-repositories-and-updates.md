# Proxmox Repositories and Updates

## Repository policy

Enabled:

```text
Debian base repositories
Debian security repository
pve-no-subscription
```

Disabled:

```text
pve-enterprise
ceph-enterprise
```

The no-subscription repository is appropriate for this private home-lab environment.

## Update sequence

```bash
apt -o Acquire::ForceIPv4=true update
apt -o Acquire::ForceIPv4=true full-upgrade -y
reboot
```

IPv4 was forced during the recovery period to avoid unsuccessful IPv6 attempts.

## Final versions

```text
proxmox-ve:   9.2.0
pve-manager:  9.2.4
kernel:       7.0.14-4-pve
```

## Health verification

```bash
pveversion -v
systemctl --failed
```

Final result:

```text
0 loaded units listed.
```

The previous kernel remains installed as a fallback. It should not be removed immediately after an upgrade.
