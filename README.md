# DGS Private Cloud

<!-- BEGIN CURRENT CHECKPOINT 2026-08-09 -->
> **Current checkpoint — 2026-08-09**
>
> The active platform is the Beelink `pve01` Proxmox host. It runs three Talos
> Kubernetes virtual machines (`210`, `211`, and `212`) plus Ubuntu Server VM
> `220` (`jenkins-ci`) as the Jenkins controller. Flux, Tailscale private
> access, Jenkins Controller Phase 1, and the Talos persistent-storage
> prerequisite are operational.
>
> Each Talos worker now has a dedicated 300 GiB `scsi1` data disk. Talos
> provisions it as XFS user volume `u-local-path-provisioner`, mounted at
> `/var/mnt/local-path-provisioner`. Rancher Local Path Provisioner `v0.0.37`
> exposes the default `local-path` StorageClass.
>
> Dynamic PVC/PV provisioning, write/read access, persistence across Pod
> deletion/recreation, and `Delete` reclaim cleanup were verified on
> 2026-08-09.
>
> Exact private tailnet hostnames and Tailscale addresses are intentionally kept
> out of Git. Tailscale Funnel remains disabled.
>
> Persistent-storage documentation:
> - [Talos persistent storage prerequisite](docs/17-talos-persistent-storage.md)
<!-- END CURRENT CHECKPOINT 2026-08-09 -->


Infrastructure-as-code, GitOps configuration, architecture decisions, inventories, recovery procedures, and operating documentation for the DGS home-lab/private-cloud platform.

> **Current stage:** Talos Kubernetes, Flux GitOps, Tailscale private access, recovery baseline, Jenkins Controller Phase 1, and the Talos persistent-storage prerequisite are operational on the standalone `pve01` host.

## Current verified state

| Item | Current value |
|---|---|
| Last verified | `2026-08-09` |
| Active Proxmox node | `pve01` on Beelink GTi12 |
| Proxmox management address | `192.168.1.201/24` |
| Proxmox VE Manager | `9.2.10` observed in the web interface |
| Proxmox topology | One standalone physical host |
| Primary guest storage | Samsung 990 PRO 2 TB as `vmdata` |
| Talos version | `v1.13.6` |
| Kubernetes version | `v1.36.2` |
| Kubernetes topology | One control plane and two workers |
| Kubernetes node state | All three nodes `Ready` |
| CNI | Flannel |
| etcd | Healthy, single control-plane member |
| etcd recovery baseline | Two off-cluster snapshots with SHA-256 verification |
| Proxmox VM backups | VMs `210`, `211`, and `212` backed up on `2026-08-01` |
| Backup media state | `usb-backup-2tb` safely disabled, unmounted, and disconnected |
| GitOps | Flux `v2.9.3` bootstrapped from `clusters/beelink-talos` |
| Private access | Tailscale Operator chart `1.98.9` connected and healthy |
| Secret encryption | SOPS with age not yet configured |
| Kubernetes persistent storage | Operational — Talos user volumes + Rancher Local Path Provisioner |
| Observability and Homepage | Not yet deployed |

## Jenkins Controller Phase 1

| Item | Verified state |
|---|---|
| VM | `220` `jenkins-ci` |
| OS | Ubuntu Server 26.04 LTS |
| Compute | 4 vCPU, 8 GiB RAM |
| Disk | 100 GiB on `vmdata` |
| LAN address | `192.168.1.213/24` |
| Java | OpenJDK `21.0.11` |
| Git | `2.53.0` |
| Jenkins | `2.568.2` |
| Jenkins service | Enabled and active |
| Tailscale | Enabled and active |
| Jenkins listener | Loopback-only TCP `8080` |
| Private access | Tailscale Serve HTTPS |
| Direct LAN `:8080` | Refused by design |
| Smoke Pipeline | `jenkins-learning-smoke` Build `#1` `SUCCESS` |
| Remote mobile-data test | Passed |
| Proxmox snapshot | `jenkins-baseline-tailscale` |
| Phase 1 | Complete |
| Phase 2 | Deferred |

See [docs/16-jenkins-controller-phase1.md](docs/16-jenkins-controller-phase1.md) for the complete implementation and recovery record.

## Active Talos Kubernetes topology

| VM | VM ID | Role | Address | vCPU | RAM | System disk | Data disk |
|---|---:|---|---|---:|---:|---:|---:|
| `talos-cp-01` | 210 | Control plane and etcd | `192.168.1.210` | 4 | 8 GiB | 64 GiB | — |
| `talos-worker-01` | 211 | Worker | `192.168.1.211` | 4 | 8 GiB | 64 GiB | 300 GiB |
| `talos-worker-02` | 212 | Worker | `192.168.1.212` | 4 | 8 GiB | 64 GiB | 300 GiB |
All Talos VM disks are on `vmdata`, all network interfaces use VirtIO on `vmbr0`, and all three VMs boot from `scsi0`. Workers `211` and `212` also have a dedicated `scsi1` data disk for Talos local persistent storage. The Talos installation ISO is detached from every VM.

## Platform architecture

```mermaid
flowchart TB
    Internet["Vodafone 5G / IPv4 WAN"]
    UPS["Eaton UPS<br/>hardware protection active<br/>telemetry pending"]
    Router["TP-Link Archer NX200<br/>192.168.1.1<br/>LAN 192.168.1.0/24"]
    Admin["LG Gram<br/>administration workstation<br/>kubectl / talosctl / flux"]
    PVE["Beelink GTi12<br/>pve01.home.arpa<br/>192.168.1.201<br/>Proxmox VE"]
    Storage["Samsung 990 PRO 2 TB<br/>vmdata LVM-thin"]
    CP["VM 210<br/>talos-cp-01<br/>192.168.1.210<br/>control plane + etcd"]
    W1["VM 211<br/>talos-worker-01<br/>192.168.1.211"]
    W2["VM 212<br/>talos-worker-02<br/>192.168.1.212"]
    Git["GitHub repository<br/>Flux Git source<br/>clusters/beelink-talos"]
    Flux["Flux controllers<br/>flux-system namespace"]
    TS["Tailscale Kubernetes Operator<br/>tailscale namespace<br/>private-service ingress"]
    Backup["Seagate One Touch 2 TB<br/>VM backups + off-cluster etcd snapshots<br/>normally disconnected"]
    Next["Next platform layer<br/>Prometheus / Grafana / Alertmanager<br/>Loki / Alloy / Homepage"]

    Internet --> Router
    UPS --> Router
    UPS --> PVE
    Admin --> Router
    Router --> PVE
    PVE --> Storage
    Storage --> CP
    Storage --> W1
    Storage --> W2
    CP --> W1
    CP --> W2
    Git --> Flux
    Flux --> CP
    Flux --> W1
    Flux --> W2
    TS --> W1
    TS --> W2
    CP -. etcd snapshot .-> Backup
    PVE -. VZDump backups .-> Backup
    W1 -. future workloads .-> Next
    W2 -. future workloads .-> Next
```

## Completed milestones

- Installed and validated Proxmox VE on `pve01`.
- Configured the management bridge at `192.168.1.201/24`.
- Prepared the Samsung 990 PRO as `vmdata` LVM-thin storage.
- Corrected the Archer NX200 IPv4 WAN configuration.
- Completed and retired the temporary ASUS Proxmox experiment without forming a cluster.
- Created and retired disposable Ubuntu validation VM `100`.
- Installed and verified workstation tooling including `kubectl`, `talosctl`, and `flux`.
- Created Talos VMs `210`, `211`, and `212`.
- Applied Talos machine configurations and bootstrapped Kubernetes exactly once.
- Confirmed all three Kubernetes nodes are `Ready`.
- Validated CoreDNS, Flannel, kube-proxy, control-plane components, and worker scheduling.
- Created and SHA-256-verified off-cluster etcd snapshots on `2026-07-26` and `2026-08-01`.
- Configured the Seagate One Touch 2 TB as `usb-backup-2tb`.
- Completed full Proxmox backups of VMs `210`, `211`, and `212`.
- Safely disabled, unmounted, and disconnected the removable backup disk.
- Bootstrapped Flux `v2.9.3` against the private GitHub repository by SSH deploy key.
- Added the active GitOps cluster path at `clusters/beelink-talos`.
- Deployed the Tailscale Kubernetes Operator through Flux using chart `1.98.9`.
- Confirmed the operator Deployment and pod are healthy with zero restarts.
- Confirmed the `tailscale` IngressClass and Tailscale CRDs are installed.
- Confirmed `beelink-talos-operator` is connected in the Tailscale admin console with `tag:k8s-operator`.
- Added dedicated 300 GiB data disks to Talos worker VMs `211` and `212`.
- Provisioned XFS Talos user volumes at `/var/mnt/local-path-provisioner`.
- Deployed and validated Rancher Local Path Provisioner `v0.0.37`.
- Confirmed `local-path` is the default StorageClass with `Delete` reclaim policy and `WaitForFirstConsumer` binding.
- Proved dynamic PVC/PV creation, persistence across Pod recreation, and automatic cleanup after test namespace deletion.

## Quick validation

```powershell
$CP = "192.168.1.210"
$W1 = "192.168.1.211"
$W2 = "192.168.1.212"

$env:TALOSCONFIG = (Resolve-Path ".\talos\generated\talosconfig").Path
$env:KUBECONFIG = (Resolve-Path ".\talos\generated\kubeconfig").Path

talosctl health `
  --control-plane-nodes $CP `
  --worker-nodes "$W1,$W2" `
  --endpoints $CP

kubectl get nodes -o wide
kubectl get pods -A -o wide

flux check
flux get sources git -A
flux get kustomizations -A
flux get sources helm -A
flux get helmreleases -A

kubectl get deployment -n tailscale
kubectl get pods -n tailscale
kubectl get ingressclass tailscale
```

## Backup and recovery state

The recovery baseline currently contains:

- two off-cluster Talos etcd snapshots with SHA-256 files;
- full Proxmox backups of VMs `210`, `211`, and `212`;
- removable backup storage that is normally disconnected after a completed backup session.

Remaining recovery work:

1. perform an isolated VM restore test;
2. rehearse Talos disaster recovery only in an isolated environment;
3. maintain an encrypted second copy of critical Talos recovery material;
4. automate or formally schedule future snapshots and backups.

Generated Talos machine configurations, `talosconfig`, kubeconfig, etcd snapshots, VM backup archives, private keys, OAuth secrets, and decrypted secret files must never be committed.

## Immediate next work

1. Deploy Prometheus, Grafana, Alertmanager, Loki, and Grafana Alloy.
2. Define metrics/log retention and resource limits suitable for `pve01`.
3. Expose selected dashboards privately through Tailscale.
4. Deploy Homepage.
5. Bring the Local Path Provisioner manifest under Flux reconciliation.
6. Configure SOPS with age and migrate manually created Kubernetes Secrets to encrypted Git-managed resources.
7. Perform an isolated VM restore test.
8. Add Eaton UPS telemetry and graceful-shutdown monitoring.
## Repository map

```text
dgs-private-cloud/
├── README.md
├── LICENSE.md
├── AGENTS.md
├── CHANGELOG.md
├── ROADMAP.md
├── SECURITY.md
├── .gitignore
├── clusters/
│   └── beelink-talos/
│       ├── flux-system/
│       ├── tailscale/
│       └── kustomization.yaml
├── talos/
│   ├── README.md
│   ├── image-factory-schematic.yaml
│   ├── generated/              # ignored except .gitkeep
│   └── patches/
├── kubernetes/
│   ├── infrastructure/
│   └── apps/
├── docs/
│   ├── 00-project-overview.md
│   ├── 01-current-state.md
│   ├── 02-hardware-and-bios.md
│   ├── 03-proxmox-installation.md
│   ├── 04-networking.md
│   ├── 05-router-ipv4-recovery.md
│   ├── 06-repositories-and-updates.md
│   ├── 07-storage-configuration.md
│   ├── 08-validation.md
│   ├── 09-operations.md
│   ├── 10-next-steps.md
│   ├── 11-temporary-asus-node.md
│   ├── 12-first-ubuntu-vm.md
│   ├── 13-talos-kubernetes-phase1.md
│   ├── 14-talos-kubernetes-cluster-bootstrap.md
│   ├── 15-flux-and-tailscale-operator.md
│   ├── 16-jenkins-controller-phase1.md
│   ├── 17-talos-persistent-storage.md
│   ├── decisions/
│   └── runbooks/
│       ├── flux-and-tailscale-validation.md
│       ├── talos-phase1-workers-and-bootstrap.md
│       └── talos-etcd-snapshot.md
├── inventory/
│   ├── host.yaml
│   ├── network.yaml
│   ├── storage.yaml
│   ├── power.yaml
│   ├── guests.yaml
│   └── kubernetes.yaml
├── scripts/
│   └── workstation/
│       └── New-TalosEtcdSnapshot.ps1
└── evidence/
```

## Documentation index

1. [Project overview](docs/00-project-overview.md)
2. [Current state](docs/01-current-state.md)
3. [Hardware and BIOS](docs/02-hardware-and-bios.md)
4. [Proxmox installation](docs/03-proxmox-installation.md)
5. [Management networking](docs/04-networking.md)
6. [Archer NX200 IPv4 recovery](docs/05-router-ipv4-recovery.md)
7. [Repositories and updates](docs/06-repositories-and-updates.md)
8. [Samsung storage configuration](docs/07-storage-configuration.md)
9. [Validation evidence](docs/08-validation.md)
10. [Operations](docs/09-operations.md)
11. [Next steps](docs/10-next-steps.md)
12. [Retired ASUS experiment](docs/11-temporary-asus-node.md)
13. [First Ubuntu VM lifecycle](docs/12-first-ubuntu-vm.md)
14. [Talos Phase 1 prerequisites](docs/13-talos-kubernetes-phase1.md)
15. [Talos Kubernetes cluster bootstrap](docs/14-talos-kubernetes-cluster-bootstrap.md)
16. [Flux and Tailscale Operator](docs/15-flux-and-tailscale-operator.md)
17. [Jenkins Controller Phase 1](docs/16-jenkins-controller-phase1.md)
18. [Talos persistent storage prerequisite](docs/17-talos-persistent-storage.md)
19. [Flux and Tailscale validation runbook](docs/runbooks/flux-and-tailscale-validation.md)
20. [Talos workers and bootstrap runbook](docs/runbooks/talos-phase1-workers-and-bootstrap.md)
21. [Talos etcd snapshot runbook](docs/runbooks/talos-etcd-snapshot.md)

## Security boundary

Proxmox management, the Talos API, the Kubernetes API, and observability endpoints remain private. Do not expose TCP `8006`, TCP `50000`, TCP `6443`, Jenkins TCP `8080`, SSH, or dashboards directly to the public internet.

Never commit:

- Talos-generated machine configurations;
- `talosconfig` or kubeconfig;
- etcd snapshots;
- age private keys;
- decrypted SOPS files;
- Tailscale OAuth client IDs or secrets;
- the `operator-oauth` Secret manifest in plaintext;
- passwords, tokens, private keys, or VPN profiles;
- VM backup archives, virtual disks, ISO images, or router exports.

## Licence

Copyright © 2026 Duminda Sumanasinghe. All rights reserved.

This is proprietary project documentation. See [LICENSE.md](LICENSE.md).
