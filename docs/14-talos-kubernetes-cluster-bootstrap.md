# Talos Kubernetes Cluster Bootstrap

## Session date

2026-07-26

## Objective

Complete the first operational Kubernetes cluster on `pve01` using:

- one Talos control-plane VM,
- two Talos worker VMs,
- one Kubernetes control plane,
- two schedulable worker nodes,
- off-cluster etcd backup.

## Starting state

The previous session had completed:

```text
VM 210 talos-cp-01 created
Talos v1.13.6 maintenance mode working
Address 192.168.1.210 reserved
Installation disk /dev/sda confirmed
Kubernetes not bootstrapped
```

## Final topology

| VM ID | Name | Role | Address | vCPU | RAM | Disk |
|---:|---|---|---|---:|---:|---:|
| 210 | `talos-cp-01` | Control plane and etcd | `192.168.1.210` | 4 | 8 GiB | 64 GiB |
| 211 | `talos-worker-01` | Worker | `192.168.1.211` | 4 | 8 GiB | 64 GiB |
| 212 | `talos-worker-02` | Worker | `192.168.1.212` | 4 | 8 GiB | 64 GiB |

## Worker creation

VM `210` was shut down and cloned twice:

```text
VM 211: talos-worker-01
VM 212: talos-worker-02
Target node: pve01
Target storage: vmdata
```

Because VM `210` was a regular VM rather than a Proxmox template, the clone dialog did not display a Full Clone / Linked Clone selector. The regular-VM clone operation produced independent VM disks.

Each clone received a unique virtual NIC MAC address.

## Boot order

All three VMs were configured with:

```text
1. scsi0
2. ide2
3. net0
```

The initially blank `scsi0` disk fell through to the Talos ISO on `ide2`. After installation, the same boot order selected the installed disk automatically.

## LAN reservations and maintenance validation

| Node | Address |
|---|---|
| `talos-cp-01` | `192.168.1.210/24` |
| `talos-worker-01` | `192.168.1.211/24` |
| `talos-worker-02` | `192.168.1.212/24` |

All three nodes showed:

```text
Stage: Maintenance
Ready: True
Connectivity: OK
Gateway: 192.168.1.1
DNS: 192.168.1.1
```

Workstation validation succeeded:

```powershell
Test-Connection $CP -Count 2
Test-Connection $W1 -Count 2
Test-Connection $W2 -Count 2

talosctl version --nodes $CP --insecure
talosctl version --nodes $W1 --insecure
talosctl version --nodes $W2 --insecure

talosctl get disks --nodes $CP --insecure
talosctl get disks --nodes $W1 --insecure
talosctl get disks --nodes $W2 --insecure
```

Each node exposed:

```text
sda  writable QEMU HARDDISK  approximately 69 GB
sr0  read-only QEMU DVD-ROM approximately 338 MB
```

## Cluster configuration

The base configuration was generated under the ignored directory:

```text
talos/generated/
```

Cluster values:

```text
Cluster name: dgs-homelab
Kubernetes endpoint: https://192.168.1.210:6443
Install disk: /dev/sda
```

Generated secrets and credentials were not committed.

## Hostname configuration issue and correction

The first hostname patches used the legacy path:

```yaml
machine:
  network:
    hostname: example
```

Talos `v1.13.6` validation rejected the resulting files with:

```text
static hostname is already set in v1alpha1 config
```

The corrected node patch used the multi-document configuration model:

```yaml
apiVersion: v1alpha1
kind: HostnameConfig
hostname: talos-cp-01
auto: off
```

Equivalent patches were created for both workers. The final files then passed:

```powershell
talosctl validate --config .\talos\generated\controlplane-210.yaml --mode metal
talosctl validate --config .\talos\generated\worker-211.yaml --mode metal
talosctl validate --config .\talos\generated\worker-212.yaml --mode metal
```

All validation exit codes were `0`.

## Applying configuration

The control-plane configuration was applied first, followed by both workers:

```powershell
talosctl apply-config --insecure --nodes $CP --file .\talos\generated\controlplane-210.yaml
talosctl apply-config --insecure --nodes $W1 --file .\talos\generated\worker-211.yaml
talosctl apply-config --insecure --nodes $W2 --file .\talos\generated\worker-212.yaml
```

Before bootstrap, the nodes correctly showed `Running` with healthy kubelets but `Ready: False` because the Kubernetes control plane did not yet exist.

## Authenticated Talos access

```powershell
$env:TALOSCONFIG = (Resolve-Path ".\talos\generated\talosconfig").Path

talosctl config endpoint $CP
talosctl config node $CP
talosctl version --nodes $CP --endpoints $CP
```

## Bootstrap

The first control-plane node was bootstrapped exactly once:

```powershell
talosctl bootstrap --nodes $CP --endpoints $CP
```

After bootstrap:

```text
talos-cp-01: Running, Ready, kubelet healthy
API server: healthy
Controller manager: healthy
Scheduler: healthy

talos-worker-01: Running, Ready, kubelet healthy
talos-worker-02: Running, Ready, kubelet healthy
```

## Kubeconfig and Kubernetes verification

```powershell
talosctl kubeconfig .\talos\generated\kubeconfig `
  --nodes $CP `
  --endpoints $CP `
  --force

$env:KUBECONFIG = (Resolve-Path ".\talos\generated\kubeconfig").Path

kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A -o wide
```

Final nodes:

```text
talos-cp-01       Ready  control-plane  192.168.1.210
talos-worker-01   Ready  <none>         192.168.1.211
talos-worker-02   Ready  <none>         192.168.1.212
```

Kubernetes server version was `v1.36.2`.

## Health verification

```powershell
talosctl health `
  --control-plane-nodes $CP `
  --worker-nodes "$W1,$W2" `
  --endpoints $CP
```

Every check completed with `OK`.

Talos membership also listed the control plane and both workers correctly.

## Workload distribution test

A test deployment was created and scaled:

```powershell
kubectl create deployment nginx-test --image=nginx:stable-alpine
kubectl scale deployment nginx-test --replicas=4
kubectl get pods -o wide -w
```

Result:

```text
2 replicas on talos-worker-01
2 replicas on talos-worker-02
All replicas Running
```

The default namespace produced a Pod Security warning because the stock Nginx manifest did not set a restricted-compatible security context. The warning did not block this test.

Cleanup succeeded:

```powershell
kubectl delete deployment nginx-test
```

## Installer-media removal

The Talos ISO was detached from the CD/DVD drive of VMs `210`, `211`, and `212` by selecting **Do not use any media**.

The boot order remains:

```text
scsi0, ide2, net0
```

## First etcd snapshot

A consistent etcd snapshot was written to a directory outside the repository and outside the cluster.

Creation result:

```text
Size: 2,232,352 bytes
Revision: 7,891
Total keys: 317
SHA-256 checksum: generated
```

The exact snapshot filename, local path, and checksum are retained in local-only operator notes rather than public repository documentation.

## End-of-session state

```text
Proxmox host: healthy standalone pve01
Talos nodes: 3
Kubernetes nodes Ready: 3/3
Control planes: 1
Workers: 2
Core system pods: Running
Workload scheduling: validated
Talos ISO attachments: removed
etcd snapshot: complete
Proxmox VM backups: pending
Flux: not bootstrapped
SOPS: not configured
```

## Known limitations

- All three VMs depend on the same Beelink host.
- There is only one Kubernetes control-plane and etcd member.
- There is no external VM backup target yet.
- No persistent storage solution is deployed.
- Application data is not covered by an etcd snapshot.
- The installed QEMU guest-agent extension state requires separate verification.
