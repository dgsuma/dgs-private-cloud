# Codex Repository Instructions

These instructions apply to Codex and other automated coding assistants working in this repository.

## Repository purpose

This repository records the design, installation, validation, operation, and future build-out of the DGS private cloud.

The currently verified hosts are:

```text
Main node
Node:              pve01
FQDN:              pve01.home.arpa
Management IP:     192.168.1.201/24
Hypervisor:        Proxmox VE 9.2
PVE Manager:       9.2.4
Primary VM store:  vmdata

Temporary node
Node:              asus-pve
FQDN:              asus-pve.home.arpa
Management IP:     192.168.1.203/24
Hypervisor:        Proxmox VE 9.2
PVE Manager:       9.2.4
System disk:       ADATA 240GB SSD
Preserved disk:    WDC 1TB HDD
Cluster state:     Not yet joined
```

Both nodes use gateway and DNS address `192.168.1.1`.

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
11. Do not describe the Beelink as a technical cluster master. `pve01` is the operational main node; Proxmox cluster members are peers.
12. Until cluster creation is verified, document both hosts as standalone and do not invent quorum output.

## Current storage facts

```text
pve01
/dev/nvme1n1  Crucial CT1000P3PSSD8 1TB  Proxmox system disk
/dev/nvme0n1  Samsung SSD 990 PRO 2TB    vg_vmdata / thin_vmdata / vmdata

asus-pve
ADATA 240GB SSD  Proxmox system disk
WDC 1TB HDD      Preserved and not configured for Proxmox
```

Never generate a command that wipes the Beelink Crucial system disk or the ASUS WDC 1TB HDD.

## Documentation style

- Use precise headings.
- Prefer tables for configuration state.
- Place commands in fenced code blocks.
- Include expected output or success criteria.
- Separate verified current state from future design.
- Use Australian English where natural.
