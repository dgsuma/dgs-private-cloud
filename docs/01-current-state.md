# Current State

Verified on **2026-07-25** after creating and booting the first Talos control-plane VM.

## Proxmox platform

| Property | Value |
|---|---|
| Active node | `pve01` |
| Platform | Beelink GTi12 |
| FQDN | `pve01.home.arpa` |
| Management address | `192.168.1.201/24` |
| Management URL | `https://192.168.1.201:8006` |
| PVE Manager | `9.2.5` observed in the web interface |
| Cluster membership | Standalone |
| Active temporary second node | None |
| Failed-systemd-unit baseline | Previously validated as zero |
| Primary VM storage | `vmdata` |
| UPS hardware protection | Active |
| UPS telemetry | Not configured |

## Retired infrastructure

| Item | Final state |
|---|---|
| `asus-pve` | Experiment ended; old laptop shut down; no cluster was formed |
| VM `100` `ubuntu-web-test` | Deleted with owned virtual disks |
| Two-node Proxmox plan | Superseded by the single-host Talos Phase 1 plan |

## Talos image

| Property | Value |
|---|---|
| Talos version | `v1.13.6` |
| Architecture | `amd64` |
| Platform/model | `metal` ISO |
| Secure Boot | Disabled |
| Bootloader | Auto |
| System extension | `siderolabs/qemu-guest-agent` |
| Schematic ID | `ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515` |
| ISO name in Proxmox | `talos-v1.13.6-qemu-agent-amd64.iso` |
| Local/upload SHA-256 | `5e3d395a6f55b5394e91ad3d31639e3df02b2a0907e6034f82797de98145eeb7` |
| Transfer-integrity result | LG Gram and `pve01` hashes matched |

The community Image Factory did not expose a publisher checksum. The recorded hash proves transfer integrity between the downloaded copy and the Proxmox copy; it is not a publisher-authentication claim.

## Talos control-plane VM

| Property | Value |
|---|---|
| VM ID | `210` |
| Name | `talos-cp-01` |
| Address | `192.168.1.210/24` |
| Gateway/DNS | `192.168.1.1` |
| CPU | 4 cores, type `host` |
| Memory | 8192 MiB |
| Ballooning | Disabled |
| Machine | `q35` |
| BIOS | OVMF |
| EFI storage | `vmdata` |
| Secure Boot pre-enrolled keys | Disabled |
| SCSI controller | VirtIO SCSI |
| QEMU Guest Agent setting | Enabled |
| System disk | 64 GiB on `vmdata` |
| Discard | Enabled |
| SSD emulation | Enabled |
| Network | VirtIO on `vmbr0` |
| Proxmox firewall | Disabled initially |
| Talos state | Maintenance |
| Talos ready | True |
| Connectivity | OK |
| Talos API TCP `50000` | Reachable |
| Installation target | `/dev/sda` |
| ISO device | `/dev/sr0` |

## Verified connectivity

From `pve01`:

```text
4 packets transmitted
4 packets received
0% packet loss
```

From the LG Gram:

- ICMP to `192.168.1.210` succeeded.
- TCP `50000` succeeded.
- `talosctl get disks --insecure --nodes 192.168.1.210` succeeded.

## Planned workers

| VM | VM ID | Address | vCPU | RAM | Disk layout | State |
|---|---:|---|---:|---:|---|---|
| `talos-wk-01` | 211 | `192.168.1.211` | 6 | 14 GiB | 64 GiB system + 300 GiB data | Not created |
| `talos-wk-02` | 212 | `192.168.1.212` | 6 | 14 GiB | 64 GiB system + 300 GiB data | Not created |

## Kubernetes and GitOps

```text
Kubernetes installed: No
Talos machine configuration applied: No
Control plane bootstrapped: No
kubeconfig generated: No
Flux bootstrapped: No
SOPS age identity generated: No
Tailscale Operator deployed: No
Monitoring deployed: No
Logging deployed: No
Homepage deployed: No
```

## Workstation tooling

| Tool | Verified version |
|---|---:|
| PowerShell | `7.6.3` |
| Git | `2.46.2` |
| GitHub CLI | `2.96.0` |
| kubectl | `1.36.3` |
| Kustomize through kubectl | `5.8.1` |
| talosctl | `1.13.6` |
| Flux CLI | `2.9.3` |
| SOPS | `3.13.2` |
| age / age-keygen | `1.3.1` |
