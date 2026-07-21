# Operations

## Normal administration

Use the private management URL:

```text
pve01: https://192.168.1.201:8006
```

The environment is a standalone Proxmox node. VM `100` is retained as a test workload and does not start automatically.

## First VM access

```text
Web page: http://192.168.1.205
SSH:      duminda@192.168.1.205
```

Quick checks inside the VM:

```bash
hostname -I
systemctl is-active nginx
systemctl is-active qemu-guest-agent
curl -I http://localhost
```

## Start VM 100

From the Proxmox GUI:

1. Select `100 (ubuntu-web-test)`.
2. Select **Start**.
3. Wait for QEMU Guest Agent and the guest IP to appear.

From the Proxmox shell:

```bash
qm start 100
qm status 100
```

## Safe guest shutdown

Preferred from inside Ubuntu:

```bash
sudo shutdown -h now
```

Or from the Proxmox GUI, select VM `100` and choose **Shutdown**.

From the Proxmox shell:

```bash
qm shutdown 100
```

Use **Stop** only for an unresponsive guest because it is comparable to cutting power.

## Safe host shutdown

Before shutting down `pve01`, confirm that VM `100` and any future guests are stopped or safely shut down:

```bash
qm list
```

From the web interface, select `pve01` and choose **Shutdown**.

From the shell:

```bash
shutdown -h now
```

or:

```bash
poweroff
```

The Proxmox web interface becoming unreachable is expected during host shutdown.

## Nginx content

The test page is stored at:

```text
/var/www/html/index.html
```

Nginx serves static file changes immediately; a restart is normally unnecessary.

Validate:

```bash
sudo nginx -t
curl http://localhost
curl -I http://localhost
```

## Windows-to-VM file copy

Example:

```powershell
scp "$HOME\Downloads\index.html" duminda@192.168.1.205:/home/duminda/index.html
```

Then inside Ubuntu:

```bash
sudo install -m 644 /home/duminda/index.html /var/www/html/index.html
```

If an SSH host-key warning appears after rebuilding a guest at the same IP, verify the new fingerprint in the console before removing the old Windows entry:

```powershell
ssh-keygen -R 192.168.1.205
```

## Eaton UPS state

The Eaton UPS currently supplies:

- the TP-Link Archer NX200 router,
- the Beelink `pve01`.

This provides hardware ride-through and surge protection, but no USB/network monitoring or automatic shutdown has been configured. A power-loss test must not be treated as complete until UPS telemetry and graceful shutdown have been implemented and verified.

## Routine health check

```bash
pveversion -v
systemctl --failed
pvesm status
qm list
qm status 100
ip -br address
ip route
hostname -f
timedatectl
```

## Monitoring thresholds

Investigate before:

- thin-pool data approaches 80%,
- thin-pool metadata approaches 70%,
- a root filesystem approaches 80%,
- SMART reports media errors or critical warnings,
- a guest repeatedly fails clean shutdown,
- QEMU Guest Agent stops reporting,
- the reserved guest IP is assigned to another device.