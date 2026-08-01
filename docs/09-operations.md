# Operations

## Administration endpoints

Use only the private LAN or an approved authenticated private-access path.

```text
Proxmox pve01:       https://192.168.1.201:8006
Talos API endpoint:  192.168.1.210:50000
Kubernetes API:      https://192.168.1.210:6443
```

Do not expose these services through router port forwarding.

## Fresh PowerShell session

A new PowerShell window does not retain `$CP`, `$W1`, `$W2`, `TALOSCONFIG`, or `KUBECONFIG`.

```powershell
$CP = "192.168.1.210"
$W1 = "192.168.1.211"
$W2 = "192.168.1.212"
$RepoPath = "E:\home-server\dgs-private-cloud"

$env:TALOSCONFIG = Join-Path $RepoPath "talos\generated\talosconfig"
$env:KUBECONFIG = Join-Path $RepoPath "talos\generated\kubeconfig"

talosctl version --nodes $CP --endpoints $CP --talosconfig $env:TALOSCONFIG
kubectl get nodes -o wide
```

Workers are target nodes. The control plane remains the Talos API endpoint:

```powershell
talosctl version --nodes $W1 --endpoints $CP --talosconfig $env:TALOSCONFIG
talosctl version --nodes $W2 --endpoints $CP --talosconfig $env:TALOSCONFIG
```

## Cluster health

```powershell
talosctl health `
  --control-plane-nodes $CP `
  --worker-nodes "$W1,$W2" `
  --endpoints $CP `
  --talosconfig $env:TALOSCONFIG

kubectl get nodes -o wide
kubectl get pods -A -o wide
```

## VM lifecycle

List VMs:

```bash
qm list
```

Inspect a VM:

```bash
qm config 210
qm status 210
```

Graceful cluster shutdown order:

```text
1. VM 211 — talos-worker-01
2. VM 212 — talos-worker-02
3. VM 210 — talos-cp-01
```

Startup order:

```text
1. VM 210 — talos-cp-01
2. VM 211 — talos-worker-01
3. VM 212 — talos-worker-02
```

Use `qm stop` only when graceful shutdown cannot complete.

## Talos etcd snapshot

From the repository root:

```powershell
.\scripts\workstation\New-TalosEtcdSnapshot.ps1 `
  -ControlPlane "192.168.1.210" `
  -WorkerNodes "192.168.1.211","192.168.1.212" `
  -BackupFolder "E:\home-server-backups\etcd" `
  -TalosConfig ".\talos\generated\talosconfig"
```

See [Talos etcd snapshot runbook](runbooks/talos-etcd-snapshot.md).

## Connect and enable the USB backup drive

1. Connect the Seagate directly to a USB 3.x port.
2. Confirm it by model and transport:

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,MODEL,TRAN
```

3. Verify or start the mount:

```bash
findmnt /mnt/pve/usb-backup-2tb
systemctl start "$(systemd-escape -p --suffix=mount /mnt/pve/usb-backup-2tb)"
```

4. Enable Proxmox storage:

```bash
pvesm set usb-backup-2tb --disable 0
pvesm status
```

Do not continue until it reports `active` and `df -hT` shows `/dev/sda1` or the currently assigned Seagate partition mounted at the expected path.

## Create VM backups

For a clean baseline, shut down the cluster in worker-first order and use:

```text
Storage:     usb-backup-2tb
Mode:        Stop
Compression: ZSTD
Notes:       Talos cluster baseline after bootstrap
```

Back up VMs `210`, `211`, and `212`, and wait for `TASK OK` after each job.

Verify:

```bash
pvesm list usb-backup-2tb
ls -lh /mnt/pve/usb-backup-2tb/dump/
df -h /mnt/pve/usb-backup-2tb
```

## Safe USB disconnect

1. Confirm no backup, restore, upload, or copy task is running.
2. Disable storage:

```bash
pvesm set usb-backup-2tb --disable 1
```

3. Flush writes and unmount:

```bash
cd /root
sync
umount -R /mnt/pve/usb-backup-2tb
```

4. Verify:

```bash
findmnt /mnt/pve/usb-backup-2tb
pvesm status
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS,MODEL,TRAN
```

Only disconnect the cable when `findmnt` returns no output and the Proxmox storage is disabled.

If unmount reports `target is busy`:

```bash
fuser -vm /mnt/pve/usb-backup-2tb
```

Stop the process using the mount, then retry. Never unplug a busy or mounted filesystem.
