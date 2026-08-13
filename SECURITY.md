# Security Policy

## Private management plane

The Proxmox management interface, Talos API, Kubernetes API, SSH, and observability endpoints must remain accessible only from trusted private networks or an approved authenticated private-access solution.

Do not forward these ports from the TP-Link Archer NX200:

```text
8006/tcp   Proxmox web management
50000/tcp  Talos API
6443/tcp   Kubernetes API
22/tcp     SSH
3128/tcp   SPICE proxy
8080/tcp   Jenkins controller HTTP backend
```

The Tailscale Kubernetes Operator is the approved initial private-access mechanism for selected Kubernetes services. Its presence does not authorise direct public exposure of Proxmox, Talos, Kubernetes, Grafana, Homepage, or application administration endpoints.

## Jenkins controller boundary

Jenkins VM `220` is a private management service.

- Do not forward TCP `8080` from the Archer NX200.
- Do not expose the Jenkins administrative interface through Tailscale Funnel.
- Keep the Jenkins HTTP backend bound to `127.0.0.1:8080`.
- Use Tailscale Serve HTTPS for remote administration.
- Never commit Jenkins passwords, API tokens, credential exports, the initial unlock password, SSH private keys, or Tailscale authentication material.
- The built-in node was used only for the Phase 1 synthetic smoke test. Normal build execution should move to a dedicated agent in Phase 2.

## GitOps trust boundary

Flux reads this repository by SSH deploy key.

- The temporary GitHub PAT used for bootstrap must be revoked after bootstrap.
- The Flux deploy key must remain configured while this repository is the Git source.
- The repository should remain private except for a short, intentional review window.
- Before changing repository visibility, run a secret scan and inspect the Git history.
- GitOps manifests must be declarative and reproducible without containing plaintext credentials.

## Tailscale trust boundary

The Tailscale Operator uses:

- `tag:k8s-operator` for the operator;
- `tag:k8s` for future Kubernetes proxy devices;
- write scopes for Services, Devices/Core, and Auth Keys;
- a Kubernetes Secret named `operator-oauth` in namespace `tailscale`.

The OAuth client ID and secret must never be committed. Until SOPS is configured, the `operator-oauth` Secret is created manually and must be documented in the recovery checklist as a required out-of-band secret.

## Secret and recovery-material policy

Never commit:

- root or administrator passwords;
- SSH private keys;
- API tokens, OAuth secrets, or recovery codes;
- GitHub PATs;
- Tailscale OAuth client IDs or secrets;
- plaintext `operator-oauth` manifests;
- router configuration exports;
- VPN private keys or profiles;
- SIM identifiers;
- Talos-generated machine configurations;
- `talosconfig` or kubeconfig;
- Talos etcd snapshots or their sensitive metadata;
- age private keys or decrypted SOPS files;
- VM disk images;
- VZDump archives;
- Proxmox Backup Server archives;
- files from `/etc/pve/priv/`.

The repository `.gitignore` must continue to exclude `talos/generated/*`, `git-commands-local.txt`, generated credentials, etcd snapshots, VM archives, and virtual disks.


### Alertmanager SMTP credential

Until SOPS/age is configured, the Gmail App Password used by Alertmanager is
stored only in the manually created Kubernetes Secret
`monitoring/alertmanager-smtp`.

The Git-managed Alertmanager configuration may reference the Secret name and
key, but the credential value must never be committed. Treat this Secret as an
out-of-band recovery prerequisite and migrate it to SOPS-encrypted Git
management only after Flux decryption has been tested successfully.
## Backup confidentiality

An etcd snapshot can contain Kubernetes Secrets. A VM backup can contain operating-system configuration, service credentials, application data, and private keys. Treat both as sensitive data.

- Keep the removable backup disk physically secure.
- Keep the disk disconnected when it is not being used.
- Encrypt any second copy stored on a general-purpose workstation or cloud service.
- Do not publish backup filenames if they reveal sensitive project or customer identifiers.
- Verify SHA-256 checksums before relying on copied snapshot files.
- Test restores in isolation before declaring recovery complete.

## Screenshot policy

Before committing screenshots, redact:

- passwords and tokens;
- OAuth client IDs and secrets;
- QR codes;
- browser session identifiers;
- public WAN addresses;
- IMSI, ICCID, MSISDN, and mobile numbers;
- serial numbers when not operationally required;
- private MAC addresses when not required;
- terminal output containing credentials or private file contents.

## Destructive-change policy

Before wiping or repartitioning a disk:

1. Identify it by model, serial, transport, and capacity.
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

## Public-review checklist

Before temporarily making the repository public:

1. Confirm the working tree is clean.
2. Inspect `.gitignore`.
3. Run `git grep` for common secret formats.
4. Inspect current GitOps YAML for Secret objects or literal credentials.
5. Review screenshots and evidence files.
6. Keep the public window as short as practical.
7. Return the repository to private immediately after review.

<!-- BEGIN TAILSCALE SECURITY BOUNDARY -->
## Tailscale remote-management boundary

Proxmox remote administration uses authenticated Tailscale connectivity and
Tailscale Serve. It does not use public router forwarding.

Required controls:

- Tailscale Funnel is disabled.
- TCP `8006`, `22`, and `6443` are not forwarded on the Archer NX200.
- The Serve backend is local to `pve01`:
  `https+insecure://127.0.0.1:8006`.
- Real Tailscale IP addresses and the tailnet DNS suffix are recorded only in
  ignored local operator notes.
- Tailscale authentication URLs, auth keys, OAuth credentials, and machine keys
  are never committed.
- Unredacted screenshots are stored under `evidence/private/`.
- Proxmox two-factor authentication is required before extended overseas
  administration.
- Forced Tailscale reauthentication is never initiated through the only active
  remote-management session.

Tailscale Serve is private to authorised tailnet members. Tailscale Funnel,
which can expose a service to the broader internet, is prohibited for the
Proxmox management interface.
<!-- END TAILSCALE SECURITY BOUNDARY -->
