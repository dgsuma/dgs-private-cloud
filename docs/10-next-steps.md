# Next Steps

## Immediate task: create Talos workers

Create:

```text
VM 211 talos-wk-01 192.168.1.211
VM 212 talos-wk-02 192.168.1.212
```

Use the detailed [worker and bootstrap runbook](runbooks/talos-phase1-workers-and-bootstrap.md).

## Required VM baseline

```text
Machine: q35
BIOS: OVMF
EFI storage: vmdata
Pre-enrolled Secure Boot keys: disabled
CPU type: host
Memory ballooning: disabled
SCSI controller: VirtIO SCSI
QEMU Guest Agent: enabled
Network: VirtIO on vmbr0
Proxmox firewall: disabled initially
Talos ISO: talos-v1.13.6-qemu-agent-amd64.iso
```

Each worker needs:

```text
6 vCPU
14336 MiB RAM
64 GiB SCSI system disk on vmdata
300 GiB SCSI data disk on vmdata
discard enabled
SSD emulation enabled
```

## Worker validation gate

Before generating the cluster configuration, verify:

```powershell
Test-Connection 192.168.1.211 -Count 4
Test-NetConnection 192.168.1.211 -Port 50000
talosctl get disks --insecure --nodes 192.168.1.211

Test-Connection 192.168.1.212 -Count 4
Test-NetConnection 192.168.1.212 -Port 50000
talosctl get disks --insecure --nodes 192.168.1.212
```

Record the exact device names for:

- the 64 GiB system disk,
- the 300 GiB data disk,
- the ISO device.

Do not assume the worker data disk device name.

## Talos configuration sequence

After all three maintenance-mode nodes and disk names are verified:

1. Generate one cluster configuration.
2. Use `/dev/sda` only after each node confirms it is the system disk.
3. Configure the matching Image Factory installer:

   ```text
   factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.13.6
   ```

4. Apply the control-plane configuration to `192.168.1.210`.
5. Apply worker configurations to `192.168.1.211` and `192.168.1.212`.
6. Bootstrap exactly once against the control plane.
7. Retrieve kubeconfig.
8. Verify all nodes.

## Kubernetes success criteria

```powershell
talosctl health
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

Required result:

```text
talos-cp-01 Ready
talos-wk-01 Ready
talos-wk-02 Ready
```

## Post-Kubernetes sequence

1. Bootstrap Flux.
2. Configure SOPS with age.
3. Deploy local persistent storage.
4. Deploy Tailscale Operator.
5. Deploy Prometheus, Grafana, and Alertmanager.
6. Deploy Loki and Alloy.
7. Deploy Homepage.

## Safety constraints

- Run `talosctl bootstrap` only once.
- Never commit files under `talos/generated/`.
- Never commit `talosconfig` or kubeconfig.
- Never commit an age private key.
- Do not configure `192.168.1.220` as an API VIP while only one control plane exists.
- Do not introduce Ceph or Proxmox HA into this single-host phase.
