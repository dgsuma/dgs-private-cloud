# Operations

## Normal administration

Use the private management URLs:

```text
pve01:     https://192.168.1.201:8006
asus-pve:  https://192.168.1.203:8006
```

Both nodes are currently standalone. After cluster formation, use `pve01` as the normal operational entry point, while remembering that Proxmox cluster members are peers rather than master and worker nodes.

## Safe shutdown

From the web interface, select the required node and choose **Shutdown**.

From the shell:

```bash
shutdown -h now
```

or:

```bash
poweroff
```

Before rebooting or shutting down a node with guests, shut down or migrate those guests safely.

## Eaton UPS state

The Eaton UPS currently supplies:

- the TP-Link Archer NX200 router,
- the Beelink `pve01`,
- the ASUS `asus-pve`.

This provides hardware ride-through and surge protection, but no USB/network monitoring or automatic shutdown has been configured. A power-loss test must not be treated as complete until UPS telemetry and graceful shutdown have been implemented and verified.

## Temporary ASUS laptop operation

Before leaving `asus-pve` unattended, prevent suspend, hibernation, and lid-close sleep:

```bash
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Then set these values in `/etc/systemd/logind.conf`:

```ini
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

Apply the change:

```bash
systemctl restart systemd-logind
```

Success criteria:

- closing the lid does not suspend the node,
- wired networking remains active,
- temperatures remain within a safe range,
- cooling vents are not obstructed.

## Two-node quorum warning

After `asus-pve` joins, the cluster will have two voting nodes. This is acceptable for controlled experiments but is not a resilient HA design.

Operational rules:

- keep both nodes online during normal cluster changes,
- do not enable Proxmox HA,
- do not deploy Ceph,
- keep important workloads on `pve01`,
- treat the ASUS workloads as disposable or fully backed up,
- do not use `pvecm expected 1` as a routine operating mode.

If one node is unexpectedly unavailable, existing guests may continue running, but cluster-management writes can be blocked because quorum is lost.

## Routine health check

```bash
pveversion -v
systemctl --failed
pvesm status
ip -br address
ip route
hostname -f
timedatectl
```

After cluster formation:

```bash
pvecm status
pvecm nodes
```

## Monitoring thresholds

Investigate before:

- thin-pool data approaches 80%,
- thin-pool metadata approaches 70%,
- a root filesystem approaches 80%,
- SMART reports media errors or critical warnings,
- the ASUS laptop repeatedly thermal-throttles,
- Corosync reports packet loss or unstable membership.
