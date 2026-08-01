# Runbook: Proxmox VM Backups to Removable USB HDD

## Purpose

Create a full compressed backup generation for Talos VMs `210`, `211`, and `212`, then disable and unmount the external HDD safely.

## Safety rules

- Identify the disk by model, capacity, and USB transport.
- Never rely only on `/dev/sda`; Linux device names can change.
- Never unplug a mounted filesystem or running backup target.
- Keep `is_mountpoint 1` configured for `usb-backup-2tb`.

## Connect and identify

Connect the Seagate directly to a USB 3.x port and run:

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,MODEL,SERIAL,TRAN
```

Confirm a Seagate One Touch device of approximately 2 TB with `TRAN` equal to `usb`.

## Mount and enable

Check the mount:

```bash
findmnt /mnt/pve/usb-backup-2tb
```

If it is not mounted:

```bash
systemctl start "$(systemd-escape -p --suffix=mount /mnt/pve/usb-backup-2tb)"
```

Verify:

```bash
df -hT /mnt/pve/usb-backup-2tb
```

Enable Proxmox storage:

```bash
pvesm set usb-backup-2tb --disable 0
pvesm status
```

Do not continue unless `usb-backup-2tb` is `active`.

## Create an etcd snapshot first

From a fresh PowerShell session on the LG Gram:

```powershell
Set-Location "E:\home-server\dgs-private-cloud"
.\scripts\workstation\New-TalosEtcdSnapshot.ps1 `
  -ControlPlane "192.168.1.210" `
  -WorkerNodes "192.168.1.211","192.168.1.212" `
  -BackupFolder "E:\home-server-backups\etcd" `
  -TalosConfig ".\talos\generated\talosconfig"
```

## Shut down the cluster

Gracefully stop:

```text
1. VM 211
2. VM 212
3. VM 210
```

Wait for each VM to show `Stopped`.

## Back up the VMs

For each VM, use **Backup now**:

```text
Storage:     usb-backup-2tb
Mode:        Stop
Compression: ZSTD
Notes:       Talos cluster baseline after bootstrap
```

Wait for `TASK OK` after every archive.

Optional shell equivalent for a single VM:

```bash
vzdump 210 --storage usb-backup-2tb --mode stop --compress zstd --notes-template 'Talos cluster baseline after bootstrap'
```

## Verify archives

```bash
pvesm list usb-backup-2tb
ls -lh /mnt/pve/usb-backup-2tb/dump/
df -h /mnt/pve/usb-backup-2tb
```

Confirm an archive exists for every intended VM ID and each backup task ended with `TASK OK`.

## Restart and validate

Start:

```text
1. VM 210
2. VM 211
3. VM 212
```

On the LG Gram:

```powershell
kubectl get nodes -o wide

talosctl health `
  --nodes $CP `
  --endpoints $CP
```

All nodes must be `Ready` and the health check must finish with `OK`.

## Disable and safely unmount

```bash
pvesm set usb-backup-2tb --disable 1
cd /root
sync
umount -R /mnt/pve/usb-backup-2tb
```

Verify:

```bash
findmnt /mnt/pve/usb-backup-2tb
pvesm status
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS,MODEL,TRAN
```

Expected:

- `findmnt` prints nothing,
- `usb-backup-2tb` is disabled,
- the Seagate partition has no mount point.

Only then disconnect the USB cable.

## Busy mount troubleshooting

```bash
fuser -vm /mnt/pve/usb-backup-2tb
```

Close any shell whose current directory is on the disk and stop any task using the mount. Retry `sync` and `umount`. Do not force-remove the cable.
