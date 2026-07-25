# Retired ASUS Proxmox Experiment

## Status

**Retired from the active design.**

The ASUS laptop was temporarily prepared as `asus-pve` for a possible two-node Proxmox learning experiment. The old hardware later showed instability, including unreliable web-session behaviour and unusable monitoring data. The experiment was stopped before a Proxmox cluster was formed.

## Historical configuration

| Property | Historical value |
|---|---|
| Node name | `asus-pve` |
| FQDN | `asus-pve.home.arpa` |
| Management address | `192.168.1.203/24` |
| Connection | Wired Cat 5e Ethernet |
| PVE Manager | `9.2.4` |
| System disk | ADATA 240 GB SSD |
| Preserved disk | WDC 1 TB HDD |
| Cluster membership | Standalone; never joined |
| Guests | None |

## Completed experiment

- Installed Proxmox VE on the ADATA SSD.
- Preserved the WDC HDD.
- Configured a static management address.
- Enabled the no-subscription repository policy.
- Verified bidirectional network connectivity.
- Verified NTP synchronisation.
- Connected the laptop to UPS-protected power.

## Reason for retirement

The old laptop was not considered reliable enough for continued Proxmox or Kubernetes use.

The active project therefore returned to:

```text
pve01 as the only Proxmox host
Talos VMs hosted on pve01 for Phase 1
Permanent second and third nodes deferred
```

## Important clarification

No Proxmox cluster was created. Therefore:

- no Corosync membership removal was required,
- no quorum repair was required,
- no guest migration was required,
- no HA or Ceph configuration existed.

## Future use

The laptop may be reinstalled with a desktop Linux distribution if it is reused. Its WDC 1 TB HDD must remain protected unless a later task explicitly identifies and verifies it.
