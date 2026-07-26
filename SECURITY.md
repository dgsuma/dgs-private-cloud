# Security Policy

## Private management plane

The Proxmox management interface, Talos API, and Kubernetes API must remain accessible only from trusted private networks or an approved authenticated private-access solution.

Do not forward these ports from the TP-Link Archer NX200:

```text
8006/tcp  Proxmox web management
22/tcp    SSH
3128/tcp  SPICE proxy
50000/tcp Talos API
6443/tcp  Kubernetes API
```

Monitoring systems, dashboards, databases, and storage management interfaces must also remain private unless they are deliberately published through a reviewed authentication and access-control layer.

## Secret-handling policy

Never commit:

- root or administrator passwords,
- SSH private keys,
- API tokens,
- recovery codes,
- router configuration exports,
- VPN private keys,
- SIM identifiers,
- public WAN details that are not intentionally documented,
- Talos-generated machine configurations,
- `talosconfig`,
- kubeconfig,
- age private keys,
- decrypted SOPS files,
- etcd snapshots,
- Kubernetes Secret exports,
- VM disk images,
- Proxmox or PBS backup archives,
- files from `/etc/pve/priv/`.

The repository `.gitignore` protects the local `talos/generated/` directory except for `.gitkeep`. Before every push, confirm that generated credentials are not tracked.

```powershell
git check-ignore -v .\talos\generated\talosconfig
git check-ignore -v .\talos\generated\kubeconfig
git ls-files -- .\talos\generated
```

The final command must return no generated credential files.

## Backup security

An etcd snapshot contains the Kubernetes API state and can include Kubernetes Secrets. Treat it as sensitive backup material.

- Store snapshots outside the Git repository.
- Restrict filesystem access.
- Copy important snapshots to a separate physical device or protected backup service.
- Maintain checksums.
- Do not publish snapshot filenames, contents, or private restoration material unnecessarily.

## Screenshot policy

Before committing screenshots, redact:

- IMSI,
- ICCID,
- MSISDN/mobile number,
- public WAN address,
- passwords,
- tokens,
- certificate material,
- QR codes,
- serial numbers when not operationally required,
- browser session identifiers.

## Destructive-change policy

Before wiping or repartitioning a disk:

1. Identify it by model, serial, and capacity.
2. Confirm it is not the running system disk.
3. Record the command or GUI operation.
4. Record the expected result.
5. Ensure a recovery path exists.

The Proxmox system disk is:

```text
/dev/nvme1n1
Crucial CT1000P3PSSD8 1 TB
```

It must never be used as the target of a wipe command.

For Talos VM installation, the verified system disk is `/dev/sda`; `/dev/sr0` is the installer CD/DVD device and must never be selected as the installation target.
