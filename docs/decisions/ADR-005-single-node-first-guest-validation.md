# ADR-005: Disposable First-Guest Validation

- **Status:** Accepted and completed
- **Decision date:** 2026-07-21
- **Retirement verified:** 2026-07-25

## Context

Before building Kubernetes, `pve01` needed a simple disposable guest to prove that:

- VM creation worked,
- `vmdata` stored guest disks correctly,
- `vmbr0` provided LAN connectivity,
- DNS and outbound internet worked,
- QEMU Guest Agent worked,
- a basic service could run.

## Decision

Create Ubuntu VM `100` as `ubuntu-web-test`, validate the platform, and retire the VM when it no longer provides value.

## Outcome

The VM validated the required Proxmox guest functions and Nginx workload.

It was later shut down and deleted with its owned disks.

## Consequences

### Positive

- Proxmox guest provisioning was proven before Kubernetes work.
- The test left no long-term resource consumption.
- `vmdata` was verified both before and after deletion.

### Negative

- The VM was not retained as a template.
- A new Ubuntu template will need to be built later if required.

## Current rule

Documentation must treat VM `100` as historical and deleted.
