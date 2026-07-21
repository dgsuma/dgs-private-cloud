# Codex Repository Instructions

These instructions apply to Codex and other automated coding assistants working in this repository.

## Repository purpose

This repository records the design, installation, validation, operation, and future build-out of the DGS private cloud.

## Current verified infrastructure

```text
Active Proxmox node
Node: pve01
FQDN: pve01.home.arpa
Management IP: 192.168.1.201/24
Hypervisor: Proxmox VE 9.2
PVE Manager: 9.2.4
Primary VM store: vmdata
Cluster state: Standalone; no cluster created

First guest
VM ID: 100
Proxmox name: ubuntu-web-test
Guest hostname: web-test01
OS: Ubuntu Server 26.04 LTS
Reserved IP: 192.168.1.205
Disk: 32GiB on vmdata
Services validated: QEMU Guest Agent, OpenSSH, Nginx
```

The legacy ASUS laptop is no longer an active Proxmox node. Its short experiment ended without cluster formation, and it now runs Zorin OS. Historical ASUS documentation must be clearly labelled as retired or historical.

## Editing rules

1. Preserve verified facts unless newer command output is supplied.
2. Mark planned or unverified work explicitly as `Planned`, `Proposed`, or `Not yet implemented`.
3. Never invent completed infrastructure.
4. Keep documentation ordered by lifecycle: design, installation, networking, storage, validation, operations, next steps.
5. Use Mermaid for diagrams so GitHub renders them natively.
6. Record major design changes as Architecture Decision Records under `docs/decisions/`.
7. Do not add destructive commands without:
   - a warning,
   - the exact target device,
   - a verification command,
   - and a recovery note.
8. Shell scripts must use:

```bash
set -euo pipefail
```

9. Scripts must avoid printing secrets.
10. Do not commit:
    - passwords,
    - private keys,
    - API tokens,
    - Tailscale/WireGuard keys,
    - SIM IMSI/ICCID/MSISDN,
    - public WAN addresses,
    - unredacted router screenshots,
    - Proxmox backup archives,
    - VM disk images,
    - Terraform state,
    - uniquely identifying hardware details unless required and intentionally sanitised.
11. Do not describe the Beelink as a technical cluster master. `pve01` is the operational main node; future Proxmox cluster members will be peers.
12. Until cluster creation is verified, document the environment as standalone and do not invent quorum output.
13. Treat `git-commands-local.txt` as local operator notes. It is ignored and must not be committed.

## Current storage facts

```text
pve01
/dev/nvme1n1  Crucial CT1000P3PSSD8 1TB
               Proxmox system disk

/dev/nvme0n1  Samsung SSD 990 PRO 2TB
               vg_vmdata / thin_vmdata / vmdata

VM 100
32GiB thin-provisioned virtual disk on vmdata
```

Never generate a command that wipes the Beelink Crucial system disk.

## Documentation style

- Use precise headings.
- Prefer tables for configuration state.
- Place commands in fenced code blocks.
- Include expected output or success criteria.
- Separate verified current state from future design.
- Use Australian English where natural.