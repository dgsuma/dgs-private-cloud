# Operations

## Active administration endpoints

Use only the private LAN or a future authenticated private-access path.

```text
Proxmox pve01: https://192.168.1.201:8006
Talos control plane: 192.168.1.210 TCP 50000
Future Kubernetes API: https://192.168.1.210:6443
```

Do not expose these services through router port forwarding.

## Current VM operations

List VMs:

```bash
qm list
```

Inspect the Talos control-plane VM:

```bash
qm config 210
qm status 210
```

Start or stop VM `210`:

```bash
qm start 210
qm shutdown 210
```

Use `qm stop 210` only when graceful shutdown cannot complete.

## Talos maintenance-mode checks

From the LG Gram:

```powershell
Test-Connection 192.168.1.210 -Count 4
Test-NetConnection 192.168.1.210 -Port 50000

talosctl get disks `
  --insecure `
  --nodes 192.168.1.210
```

Expected important disk mapping:

```text
sda  QEMU HARDDISK  writable  Talos installation target
sr0  QEMU DVD-ROM   read-only Talos boot ISO
```

Never select `/dev/sr0` as the installation target.

## Safe shutdown

From the Proxmox web interface, select the guest or node and choose **Shutdown**.

For the Proxmox host:

```bash
shutdown -h now
```

Before shutting down `pve01`, gracefully stop all VMs.

## Eaton UPS state

The UPS actively protects:

- the TP-Link Archer NX200,
- the Beelink `pve01`.

The ASUS laptop is no longer part of the active server topology.

UPS telemetry and automatic extended-outage shutdown are not configured.

## Routine Proxmox health check

```bash
pveversion -v
systemctl --failed
pvesm status
qm list
ip -br address
ip route
hostname -f
timedatectl
```

## Storage thresholds

Investigate before:

- LVM-thin data usage approaches 80%,
- LVM-thin metadata usage approaches 70%,
- a root filesystem approaches 80%,
- SMART/NVMe reports media errors or critical warnings,
- backup space becomes insufficient.

## Secret safety

Generated Talos configurations contain cluster certificates and keys. Keep them under `talos/generated/`, which is ignored by Git.

Do not paste or commit:

- Talos secrets,
- kubeconfig,
- `talosconfig`,
- SOPS age private keys,
- GitHub tokens,
- Tailscale credentials.
