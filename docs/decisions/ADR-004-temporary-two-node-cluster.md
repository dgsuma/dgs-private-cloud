# ADR-004: Temporary Two-Node Proxmox Experiment

- Status: **Superseded / experiment abandoned before cluster creation**
- Original date: 2026-07-18
- Closed: 2026-07-19

## Context

A legacy ASUS laptop was available for a short Proxmox learning exercise. The permanent Beelink node `pve01` was already operational.

## Original decision

Evaluate the ASUS laptop as a temporary second Proxmox node named `asus-pve` at `192.168.1.203/24`. The proposed experiment excluded HA, Ceph, and irreplaceable workloads.

## Outcome

The laptop was installed and basic wired connectivity, repositories, time synchronisation, and management access were validated. However, unreliable behaviour was observed during the evaluation. The user chose not to continue using the old hardware for Proxmox.

The proposed cluster was never created. `asus-pve` was never joined, no quorum state existed, and no migration test was performed.

## Consequences

- The active environment remains a standalone `pve01` node.
- No cluster-removal command was required.
- The ASUS laptop now runs Zorin OS.
- Future clustering will use permanent, suitable hardware.
- The future target remains three voting nodes or another explicitly designed odd-vote strategy.
- Historical ASUS configuration remains documented for traceability but must not be presented as active infrastructure.

## Superseded by

[ADR-005: Single-Node First Guest Validation](ADR-005-single-node-first-guest-validation.md)