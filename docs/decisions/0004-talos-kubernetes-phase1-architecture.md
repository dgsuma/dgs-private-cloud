
## 4. Create tomorrow’s checklist

Run:

```powershell
@'
# Next Session — Talos Workers and Kubernetes Bootstrap

## Starting state

- `talos-cp-01` exists as VM 210.
- Control-plane IP is `192.168.1.210`.
- Talos is in maintenance mode.
- Control-plane installation disk is `/dev/sda`.
- Kubernetes has not been bootstrapped.

## Worker 1

```text
VM ID: 211
Name: talos-wk-01
IP: 192.168.1.211
CPU: host, 6 cores
Memory: 14336 MiB
System disk: 64 GiB on vmdata
Data disk: 300 GiB on vmdata

VM ID: 212
Name: talos-wk-02
IP: 192.168.1.212
CPU: host, 6 cores
Memory: 14336 MiB
System disk: 64 GiB on vmdata
Data disk: 300 GiB on vmdata

Machine: q35
BIOS: OVMF
EFI storage: vmdata
Pre-enrol keys: disabled
SCSI controller: VirtIO SCSI
QEMU guest agent: enabled
Ballooning: disabled
Network model: VirtIO
Bridge: vmbr0
Firewall: disabled initially
Discard: enabled
SSD emulation: enabled
ISO: talos-v1.13.6-qemu-agent-amd64.iso