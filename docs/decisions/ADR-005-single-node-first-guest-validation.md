# ADR-005: Single-Node First Guest Validation

- Status: Accepted
- Date: 2026-07-21

## Context

The temporary ASUS Proxmox experiment ended without cluster formation. The Beelink `pve01` remained healthy, standalone, and had dedicated `vmdata` storage available.

Waiting for permanent cluster hardware would delay practical VM learning. A small disposable guest could validate the essential Proxmox workflow without changing the standalone topology.

## Decision

Create the first test VM on `pve01` with:

```text
VM ID: 100
Name: ubuntu-web-test
OS: Ubuntu Server 26.04 LTS
vCPU: 2
RAM: 4GiB
Disk: 32GiB on vmdata
Bridge: vmbr0
Guest IP: 192.168.1.205 through router DHCP reservation
```

Install QEMU Guest Agent, OpenSSH, curl, and Nginx. Validate local and LAN web access, SSH/SCP, clean shutdown, restart, and safe host shutdown.

Keep guest autostart disabled during the learning phase.

## Rationale

- Uses the dedicated Samsung guest-storage pool.
- Exercises the core VM lifecycle without requiring a cluster.
- Provides a simple observable service through Nginx.
- Uses router-managed address reservation to avoid duplicate static network configuration.
- Keeps the workload small and reversible.

## Consequences

- The repository now records one provisioned VM.
- The guest address remains stable while its virtual MAC remains unchanged.
- Rebuilding the VM with a new virtual NIC requires updating the router reservation.
- Snapshots and backups remain separate follow-up tasks.
- The test VM must not be treated as a production workload.