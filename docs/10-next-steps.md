# Next Steps

## Immediate next task

Create a small Ubuntu test VM on `vmdata`.

Suggested first VM:

```text
Name:       ubuntu-test
vCPU:       2
RAM:        4GB
Disk:       32GB
Storage:    vmdata
Bridge:     vmbr0
Firmware:   UEFI or BIOS according to template decision
```

Validate:

- VM creation,
- console access,
- DHCP or static addressing,
- DNS,
- outbound internet,
- clean shutdown,
- restart,
- guest agent,
- snapshot,
- rollback.

## Before production-like workloads

1. Configure external backups.
2. Test a full VM restore.
3. Add UPS protection.
4. Enable named-user administration and 2FA.
5. Define firewall policy.
6. Document private remote access.
7. Create an Ubuntu VM template.
8. Record VM naming, ID, addressing, CPU, RAM, and disk conventions.

## Multi-node target

```mermaid
flowchart LR
    PVE1["pve01<br/>Beelink GTi12<br/>Complete"]
    PVE2["pve02<br/>Planned"]
    PVE3["pve03<br/>Planned"]
    Backup["NAS / Proxmox Backup Server<br/>Planned"]
    K8s["Staging and production-like Kubernetes<br/>Planned"]

    PVE1 -. cluster .- PVE2
    PVE2 -. cluster .- PVE3
    PVE1 -. backups .-> Backup
    PVE2 -. backups .-> Backup
    PVE3 -. backups .-> Backup
    PVE1 -. hosts .-> K8s
    PVE2 -. hosts .-> K8s
    PVE3 -. hosts .-> K8s
```
