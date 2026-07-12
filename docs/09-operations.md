# Operations

## Normal administration

Use:

```text
https://192.168.1.201:8006
```

The host can run without a monitor, keyboard, or mouse.

## Safe shutdown

From the web interface:

```text
pve01 → Shutdown
```

From the shell:

```bash
shutdown -h now
```

or:

```bash
poweroff
```

Wait until the Beelink power light and fan stop before disconnecting power.

## Startup

Press the Beelink power button once.

The BIOS setting `State After G3: S0 State` also allows automatic power-on after electricity returns following a complete outage.

## Routine health check

```bash
pveversion -v
systemctl --failed
pvesm status
ip -br address
ip route
lvs -a -o lv_name,vg_name,lv_attr,lv_size,data_percent,metadata_percent
```

## Update maintenance

```bash
apt update
apt full-upgrade -y
reboot
```

Before rebooting a host with guests, shut down or migrate guests safely.

## Monitoring thresholds

Investigate before:

- thin-pool data approaches 80%,
- thin-pool metadata approaches 70%,
- the root filesystem approaches 80%,
- SMART reports media errors or critical warnings.
