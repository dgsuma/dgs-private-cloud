# Project Overview

## Purpose

The DGS private-cloud project is a staged home-lab platform for production-like experience with:

- Proxmox VE,
- Talos Linux and Kubernetes,
- GitOps with Flux,
- SOPS-encrypted secrets,
- authenticated private access,
- monitoring, logging, and dashboards,
- PostgreSQL and TimescaleDB,
- IoT sensor collection and automation,
- backups and disaster recovery,
- future multi-node expansion.

## Active scope

The active implementation uses one physical Proxmox host:

```text
Node: pve01
Platform: Beelink GTi12
CPU: Intel Core i9-12900H
RAM: 64 GiB
Hypervisor: Proxmox VE 9.2
Primary VM storage: vmdata on Samsung 990 PRO 2 TB
```

The old ASUS laptop is no longer part of the active architecture.

## Current implementation milestone

The first Talos control-plane VM is operational in maintenance mode:

```text
VM ID: 210
Name: talos-cp-01
Address: 192.168.1.210
Talos: v1.13.6
Install disk: /dev/sda
Kubernetes: not yet bootstrapped
```

The immediate target is one control-plane VM and two worker VMs on `pve01`.

## Design principles

1. Keep the hypervisor and cluster management planes private.
2. Separate the Proxmox system disk from primary guest storage.
3. Treat the Git repository as the declarative source of truth after Flux bootstrap.
4. Never commit unencrypted secrets or Talos-generated credentials.
5. Record every important change and validation result.
6. Validate each layer before deploying the next.
7. Prefer repeatable commands and runbooks.
8. Keep verified current state separate from plans.
9. Accept that Phase 1 is not highly available because every VM uses one physical host.
10. Add permanent nodes, backup infrastructure, and network segmentation incrementally.

## Phase 1 service sequence

```mermaid
flowchart LR
    TalosVMs["Talos VMs"]
    K8s["Kubernetes"]
    Flux["Flux GitOps"]
    SOPS["SOPS + age"]
    TS["Tailscale Operator"]
    Storage["Local persistent storage"]
    Metrics["Prometheus<br/>Grafana<br/>Alertmanager"]
    Logs["Loki<br/>Alloy"]
    Home["Homepage"]

    TalosVMs --> K8s
    K8s --> Flux
    Flux --> SOPS
    Flux --> Storage
    SOPS --> TS
    Storage --> Metrics
    Storage --> Logs
    TS --> Home
    Metrics --> Home
    Logs --> Home
```
