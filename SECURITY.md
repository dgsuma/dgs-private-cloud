# Security Policy

## Private management plane

The Proxmox management interface, Talos API, Kubernetes API, SSH, and future observability endpoints must remain accessible only from trusted private networks or an approved authenticated private-access solution.

Do not forward these ports from the TP-Link Archer NX200:

```text
8006/tcp  Proxmox web management
50000/tcp Talos API
6443/tcp  Kubernetes API
22/tcp    SSH
3128/tcp  SPICE proxy
```

## Secret and recovery-material policy

Never commit:

- root or administrator passwords,
- SSH private keys,
- API tokens or recovery codes,
- router configuration exports,
- VPN private keys or profiles,
- SIM identifiers,
- public WAN details that are not intentionally documented,
- Talos-generated machine configurations,
- `talosconfig` or kubeconfig,
- Talos etcd snapshots or their sensitive metadata,
- age private keys or decrypted SOPS files,
- VM disk images,
- VZDump archives,
- Proxmox Backup Server archives,
- files from `/etc/pve/priv/`.

The repository `.gitignore` must continue to exclude `talos/generated/*`, `git-commands-local.txt`, generated credentials, etcd snapshots, VM archives, and virtual disks.

## Backup confidentiality

An etcd snapshot can contain Kubernetes Secrets. A VM backup can contain operating-system configuration, service credentials, application data, and private keys. Treat both as sensitive data.

- Keep the removable backup disk physically secure.
- Encrypt any second copy stored on a general-purpose workstation or cloud service.
- Do not publish backup filenames if they reveal sensitive project or customer identifiers.
- Verify SHA-256 checksums before relying on copied snapshot files.

## Screenshot policy

Before committing screenshots, redact:

- passwords and tokens,
- QR codes,
- browser session identifiers,
- public WAN addresses,
- IMSI, ICCID, MSISDN, and mobile numbers,
- serial numbers when not operationally required,
- private MAC addresses when not required,
- terminal output containing credentials or private file contents.

## Destructive-change policy

Before wiping or repartitioning a disk:

1. Identify it by **model, serial, transport, and capacity**.
2. Confirm it is not the running system disk or primary guest-storage disk.
3. Record the intended operation and expected result.
4. Ensure a recovery path exists.
5. Re-check the device immediately before confirmation.

Linux device names such as `/dev/nvme0n1`, `/dev/nvme1n1`, and `/dev/sda` can change between boots or when devices are added. Never authorise a destructive operation from the device name alone.

Stable model identities in this environment are:

```text
Crucial CT1000P3PSSD8       Proxmox system storage
Samsung SSD 990 PRO 2TB     Primary VM storage
Seagate One Touch 2 TB      Removable backup storage
```

## Removable-backup operating rule

Before unplugging the Seagate HDD:

1. Confirm no VZDump, restore, upload, or file-copy task is active.
2. Disable `usb-backup-2tb` in Proxmox.
3. Run `sync`.
4. Unmount `/mnt/pve/usb-backup-2tb`.
5. Verify `findmnt` returns no mount.
6. Disconnect the USB cable only after unmount succeeds.
