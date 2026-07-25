# First Ubuntu VM Validation and Retirement

## Purpose

VM `100` was a disposable first-guest validation workload used to confirm that `pve01`, `vmdata`, `vmbr0`, DHCP, DNS, outbound networking, QEMU Guest Agent, and a simple web service worked correctly.

## Historical identity

| Property | Value |
|---|---|
| Proxmox VM ID | `100` |
| Proxmox name | `ubuntu-web-test` |
| Guest hostname | `web-test01` |
| Historical reserved address | `192.168.1.205` |
| Workload | Nginx validation page |
| Storage | `vmdata` |
| Final state | Deleted |

## Validated capabilities

- VM creation on `vmdata`.
- Boot and console access.
- LAN connectivity through `vmbr0`.
- DHCP address assignment/reservation.
- DNS resolution.
- Outbound internet access.
- QEMU Guest Agent reporting.
- Nginx installation and HTTP response.
- Clean guest shutdown.

## Retirement

The test VM was no longer needed after validation.

It was shut down and deleted with:

```bash
qm destroy 100 --purge 1 --destroy-unreferenced-disks 1
```

Deletion was verified with:

```bash
qm list
pvesm list vmdata
```

Result:

- VM `100` no longer appeared.
- No `vm-100-*` volume remained.
- `vmdata` remained active.

## Decision

The first-guest validation is complete. The repository must not describe VM `100` as an active workload.

See [ADR-005](decisions/ADR-005-single-node-first-guest-validation.md).
