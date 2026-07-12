# ADR-003: Proxmox Repository Policy

- Status: Accepted
- Date: 2026-07-11

## Decision

Use the Proxmox `pve-no-subscription` repository for the private home lab.

Disable:

```text
pve-enterprise
ceph-enterprise
```

## Rationale

The host does not currently have a paid Proxmox subscription and is not a commercial production system.

## Consequences

- Updates are available without an enterprise subscription.
- The repository carries the expected home-lab/non-production warning.
- Major updates must still be tested and documented.
