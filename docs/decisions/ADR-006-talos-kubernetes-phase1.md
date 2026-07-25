# ADR-006: Talos Kubernetes Phase 1 on pve01

- **Status:** Accepted
- **Date:** 2026-07-25

## Context

The Home Lab IoT Blueprint requires a reproducible Kubernetes platform for GitOps, private access, observability, logging, dashboards, databases, and IoT services.

The active physical platform currently consists of one reliable Proxmox node:

```text
pve01
Beelink GTi12
Intel Core i9-12900H
64 GiB RAM
Samsung 990 PRO 2 TB vmdata
```

The temporary ASUS experiment was retired because the old hardware was unstable.

## Decision

Use Talos Linux for the initial Kubernetes nodes.

Deploy three VMs on `pve01`:

| VM | VM ID | Role | Address | vCPU | RAM |
|---|---:|---|---|---:|---:|
| `talos-cp-01` | 210 | Control plane | `192.168.1.210` | 4 | 8 GiB |
| `talos-wk-01` | 211 | Worker | `192.168.1.211` | 6 | 14 GiB |
| `talos-wk-02` | 212 | Worker | `192.168.1.212` | 6 | 14 GiB |

Use:

- OVMF and `q35`,
- CPU type `host`,
- disabled ballooning,
- VirtIO networking,
- standard VirtIO SCSI,
- `vmdata` for VM disks,
- discard and SSD emulation,
- a custom Talos ISO with `siderolabs/qemu-guest-agent`.

The initial Kubernetes endpoint is:

```text
https://192.168.1.210:6443
```

Reserve `192.168.1.220` for a future API virtual IP, but do not configure it while only one control plane exists.

## Storage decision

```text
talos-cp-01:
  64 GiB system disk

talos-wk-01:
  64 GiB system disk
  300 GiB local Kubernetes data disk

talos-wk-02:
  64 GiB system disk
  300 GiB local Kubernetes data disk
```

Phase 1 uses local persistent storage. Ceph and highly available storage are deferred.

## GitOps decision

Continue using `dgs-private-cloud` as the infrastructure monorepo.

- Flux will reconcile the cluster from the private GitHub repository.
- SOPS and age will protect committed Kubernetes secrets.
- Raw credentials will never be committed.

## Consequences

### Positive

- Minimal immutable node operating system.
- API-driven lifecycle.
- Reproducible GitOps architecture.
- Sufficient resources remain for Proxmox and future utility workloads.
- Straightforward expansion to permanent physical nodes later.

### Limitations

- All VMs depend on one physical host.
- The control plane is not highly available.
- Local persistent volumes are node-bound.
- Failure of `pve01` stops the entire Phase 1 cluster.

## Future review

Review this ADR when permanent second and third Proxmox nodes are available.
