# Validation

## Proxmox host baseline

```bash
pveversion -v
systemctl --failed
pvesm status
qm list
```

Verified platform state:

```text
PVE Manager: pve-manager/9.2.5 observed in the web interface
Active node: pve01
Active VM count: 3
Storage IDs: local, local-lvm, and vmdata active
```

## Talos maintenance-mode validation

Before configuration was applied, every node passed:

```powershell
Test-Connection <node-address> -Count 2
talosctl version --nodes <node-address> --insecure
talosctl get disks --nodes <node-address> --insecure
```

Verified on all three nodes:

```text
Talos: v1.13.6
Stage: Maintenance
Ready: True
Connectivity: OK
Installation disk: sda, writable, approximately 69 GB
Installer media: sr0, read-only, approximately 338 MB
```

## Machine-configuration validation

The three node-specific configuration files passed metal-mode validation:

```powershell
talosctl validate --config .\talos\generated\controlplane-210.yaml --mode metal
talosctl validate --config .\talos\generated\worker-211.yaml --mode metal
talosctl validate --config .\talos\generated\worker-212.yaml --mode metal
```

Each command returned exit code `0`.

### Hostname patch correction

Talos `v1.13.6` rejected a legacy `machine.network.hostname` patch because the generated configuration already contained the new hostname configuration document.

The corrected strategic-merge patch was:

```yaml
apiVersion: v1alpha1
kind: HostnameConfig
hostname: talos-worker-01
auto: off
```

Equivalent patches were used for the control plane and second worker.

## Talos cluster health

```powershell
$CP = "192.168.1.210"
$W1 = "192.168.1.211"
$W2 = "192.168.1.212"

talosctl health `
  --control-plane-nodes $CP `
  --worker-nodes "$W1,$W2" `
  --endpoints $CP
```

Every reported check completed with `OK`, including:

- etcd health,
- etcd membership consistency,
- apid readiness,
- memory and disk sizing,
- diagnostics,
- kubelet health,
- boot-sequence completion,
- Kubernetes node reporting,
- control-plane static pods,
- control-plane components,
- Kubernetes node readiness,
- kube-proxy readiness,
- CoreDNS readiness,
- node schedulability.

## Kubernetes nodes

```powershell
kubectl get nodes -o wide
```

Verified:

```text
NAME              STATUS   ROLES           VERSION   INTERNAL-IP
talos-cp-01       Ready    control-plane   v1.36.2   192.168.1.210
talos-worker-01   Ready    <none>          v1.36.2   192.168.1.211
talos-worker-02   Ready    <none>          v1.36.2   192.168.1.212
```

## Kubernetes system pods

```powershell
kubectl get pods -A -o wide
```

Verified running:

- two CoreDNS replicas,
- kube-apiserver on `talos-cp-01`,
- kube-controller-manager on `talos-cp-01`,
- kube-scheduler on `talos-cp-01`,
- Flannel on all three nodes,
- kube-proxy on all three nodes.

The controller-manager and scheduler had early bootstrap restarts but were running successfully at final verification.

## Talos membership

```powershell
talosctl get members --nodes $CP --endpoints $CP
```

Verified members:

```text
talos-cp-01       controlplane   192.168.1.210
talos-worker-01   worker         192.168.1.211
talos-worker-02   worker         192.168.1.212
```

## Workload scheduling test

```powershell
kubectl create deployment nginx-test --image=nginx:stable-alpine
kubectl scale deployment nginx-test --replicas=4
kubectl get pods -o wide -w
```

Result:

```text
Two replicas scheduled on talos-worker-01
Two replicas scheduled on talos-worker-02
All four replicas reached 1/1 Running
```

Cleanup:

```powershell
kubectl delete deployment nginx-test
```

## Installation-media validation

For VMs `210`, `211`, and `212`:

```text
Boot order: scsi0, ide2, net0
CD/DVD media: none / Do not use any media
```

## etcd snapshot validation

A consistent snapshot was created with:

```powershell
talosctl etcd snapshot <off-cluster-path> `
  --nodes $CP `
  --endpoints $CP `
  --talosconfig <path-to-talosconfig>
```

Creation output confirmed:

```text
Snapshot saved
Size: 2,232,352 bytes
Revision: 7,891
Total keys: 317
SHA-256: generated successfully
```

## Current acceptance criteria

- [x] Proxmox host boots and is reachable.
- [x] Static management address is correct.
- [x] IPv4 outbound connectivity works.
- [x] Required storage is active.
- [x] Three Talos VMs are running.
- [x] Every Talos VM has a unique hostname and address.
- [x] All Talos machine configurations validate.
- [x] Kubernetes was bootstrapped exactly once.
- [x] All three Kubernetes nodes are `Ready`.
- [x] Core system pods are running.
- [x] Workloads schedule across both workers.
- [x] Talos installation media is detached.
- [x] First off-cluster etcd snapshot exists and has a checksum.
- [ ] Proxmox VM backups are stored off-host.
- [ ] A full restore has been tested.
