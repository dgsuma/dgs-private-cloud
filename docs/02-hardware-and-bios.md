# Hardware and BIOS

## Host hardware

| Component | Value |
|---|---|
| Model | Beelink GTi12 |
| CPU | Intel Core i9-12900H |
| CPU topology | 6 P-cores + 8 E-cores, 20 threads |
| RAM | 64GB DDR5 |
| NICs | Dual wired Ethernet plus Intel Wi-Fi |
| System SSD | Crucial CT1000P3PSSD8 1TB |
| Data SSD | Samsung SSD 990 PRO 2TB |

## Disk identities

```text
/dev/nvme1n1
Model:  CT1000P3PSSD8
Role:   Proxmox system disk
Action: Never wipe
```

```text
/dev/nvme0n1
Model:  Samsung SSD 990 PRO 2TB
Role:   Primary VM/LXC storage
VG:     vg_vmdata
Pool:   thin_vmdata
Store:  vmdata
```

## BIOS settings

| Setting | Final value |
|---|---|
| Intel VMX Virtualization Technology | Enabled |
| Intel VT-d | Enabled |
| Hyper-Threading | Enabled |
| Performance cores | All |
| Efficient cores | All |
| Secure Boot | Disabled |
| Boot mode | UEFI |
| Fast Boot | Disabled |
| State After G3 | S0 State |
| Intel TXT | Disabled |
| Total Memory Encryption | Disabled |

## Rationale

- VMX is required for hardware-assisted virtualisation.
- VT-d is retained for possible future device passthrough.
- UEFI provides the expected modern boot path.
- Secure Boot was disabled for the initial installation.
- S0 after G3 allows the host to power on when electricity returns after a full outage.
