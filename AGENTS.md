# Codex Repository Instructions

These instructions apply to Codex and other automated coding assistants working in this repository.

## Repository purpose

This repository records the design, installation, validation, operation, GitOps configuration, and future build-out of the DGS private cloud and Home Lab IoT platform.

## Current verified platform

```text
Active hypervisor
Node: pve01
FQDN: pve01.home.arpa
Management IP: 192.168.1.201/24
Platform: Beelink GTi12
Proxmox VE Manager: 9.2.5 observed
Primary VM store: vmdata
Cluster membership: standalone

Talos control plane
VM ID: 210
Name: talos-cp-01
Address: 192.168.1.210
Talos version: v1.13.6
State: maintenance mode
Installation target: /dev/sda
Kubernetes: not bootstrapped

Retired items
asus-pve: temporary experiment ended; not an active node
VM 100 ubuntu-web-test: deleted with its disks
```

## Planned Talos workers

```text
VM 211 talos-wk-01 192.168.1.211
VM 212 talos-wk-02 192.168.1.212
```

## Editing rules

1. Preserve verified facts unless newer command output is supplied.
2. Mark planned or unverified work explicitly as `Planned`, `Proposed`, or `Not yet implemented`.
3. Never invent completed infrastructure.
4. Keep current state separate from future design.
5. Use Mermaid for diagrams that GitHub can render natively.
6. Record major design changes as ADRs under `docs/decisions/`.
7. Do not add destructive commands without:
   - a warning,
   - the exact target,
   - a verification command,
   - and a recovery or rollback note.
8. Shell scripts must use:

   ```bash
   set -euo pipefail
   ```

9. PowerShell scripts must use:

   ```powershell
   $ErrorActionPreference = "Stop"
   Set-StrictMode -Version Latest
   ```

10. Scripts must avoid printing secrets.
11. Do not describe `pve01` as a Kubernetes control-plane node. It is the Proxmox host. `talos-cp-01` is the Kubernetes control-plane VM.
12. Do not describe `pve01` as a Proxmox cluster master. Proxmox members are peers; `pve01` is currently standalone.
13. Do not describe `asus-pve` as active.
14. Do not describe VM `100` as existing.
15. Do not claim Kubernetes, Flux, Tailscale Operator, monitoring, logging, or Homepage is deployed until command output proves it.

## Secret-handling rules

Never commit:

- generated Talos `controlplane.yaml` or `worker.yaml`,
- Talos secrets,
- `talosconfig`,
- kubeconfig,
- age private identities,
- decrypted SOPS content,
- GitHub tokens,
- Tailscale OAuth clients or auth keys,
- passwords, private keys, VPN profiles,
- Terraform state,
- Proxmox backups or virtual disks,
- ISO images,
- unredacted router exports.

SOPS-encrypted Kubernetes Secret manifests may be committed only after `.sops.yaml` and Flux decryption are configured.

## Current storage facts

```text
pve01
/dev/nvme1n1  Crucial CT1000P3PSSD8 1 TB  Proxmox system disk
/dev/nvme0n1  Samsung SSD 990 PRO 2 TB     vg_vmdata / thin_vmdata / vmdata

VM 210
64 GiB SCSI system disk on vmdata
Talos sees the installation target as /dev/sda
```

Never generate a command that wipes the Beelink Crucial system disk.

## Documentation style

- Use precise headings.
- Prefer tables for configuration state.
- Put commands in fenced code blocks.
- Include expected output or success criteria.
- Use Australian English where natural.
- Keep IP addresses, names, VM IDs, dates, and versions consistent.
