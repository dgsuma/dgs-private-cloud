# ADR-004: Temporary Two-Node Proxmox Experiment

- Status: Accepted
- Date: 2026-07-18

## Context

A legacy ASUS laptop is available for a short Proxmox learning exercise before it is returned to long-term Linux Mint desktop use. The permanent Beelink node `pve01` is already operational. The temporary node has limited lifecycle and storage, and a two-vote cluster cannot tolerate the loss of either vote while retaining normal quorum.

## Decision

Use the ASUS laptop as a temporary second Proxmox node named `asus-pve` at `192.168.1.203/24` for approximately one month.

The experiment may include:

- centralised two-node administration,
- disposable VM and LXC creation,
- manual migration testing,
- basic Kubernetes-node experiments,
- shutdown and recovery practice.

The experiment will not include:

- Proxmox HA,
- Ceph,
- irreplaceable workloads on the ASUS,
- treating the two-node arrangement as production-resilient infrastructure.

## Rationale

The temporary node provides practical multi-node experience without purchasing permanent hardware immediately. Wired Ethernet, static addresses, matching PVE Manager versions, and NTP synchronisation have already been verified.

## Consequences

- Both nodes normally need to remain online for quorum after the cluster is formed.
- Existing guests may continue running during quorum loss, but cluster-management writes can be blocked.
- The ASUS must be cleanly removed from cluster membership before Linux Mint is installed.
- A future permanent cluster should use three voting nodes or an explicitly designed QDevice strategy.
- The ASUS WDC 1TB HDD remains outside the temporary Proxmox storage design.
