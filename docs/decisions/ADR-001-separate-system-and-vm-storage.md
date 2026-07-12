# ADR-001: Separate System and VM Storage

- Status: Accepted
- Date: 2026-07-11

## Context

The Beelink GTi12 has a 1TB Crucial SSD and a 2TB Samsung 990 PRO SSD.

## Decision

Install Proxmox on the Crucial SSD and use the Samsung SSD as primary guest storage.

## Consequences

Positive:

- Hypervisor and workload storage are separated.
- Guest I/O is placed on the faster/larger drive.
- Reinstalling the host can be planned without automatically destroying primary guest storage.
- The storage layout remains simple.

Negative:

- The design does not provide disk redundancy.
- External backups are still required.

## Rejected alternatives

- RAID0: rejected because it adds failure risk.
- RAID1 across different capacities: rejected because it wastes capacity and does not replace backups.
