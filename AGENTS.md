# Codex Repository Instructions

These instructions apply to Codex and other automated coding assistants working in this repository.

## Repository purpose

This repository records the design, installation, validation, operation, and future build-out of the DGS private cloud.

The current verified node is:

```text
Node:              pve01
FQDN:              pve01.home.arpa
Management IP:     192.168.1.201/24
Gateway/DNS:       192.168.1.1
Hypervisor:        Proxmox VE 9.2
PVE Manager:       9.2.4
Running kernel:    7.0.14-4-pve
Primary VM store:  vmdata
```

## Editing rules

1. Preserve verified facts unless a newer command output is supplied.
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
    - unredacted router screenshots,
    - Proxmox backup archives,
    - VM disk images,
    - Terraform state.

## Current storage facts

```text
/dev/nvme1n1  Crucial CT1000P3PSSD8 1TB  Proxmox system disk
/dev/nvme0n1  Samsung SSD 990 PRO 2TB    vg_vmdata / thin_vmdata / vmdata
```

Never generate a command that wipes `/dev/nvme1n1`.

## Documentation style

- Use precise headings.
- Prefer tables for configuration state.
- Place commands in fenced code blocks.
- Include expected output or success criteria.
- Separate verified current state from future design.
- Use Australian English where natural.
 - Use Australian English where appropriate.
