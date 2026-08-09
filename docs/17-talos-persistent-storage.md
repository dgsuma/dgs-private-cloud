# Talos Persistent Storage Prerequisite

## Status

**Completed and end-to-end verified on 2026-08-09.**

This phase established the initial persistent Kubernetes storage layer before
deploying Prometheus, Grafana, Alertmanager and Loki.

The implemented chain is:

```text
Proxmox vmdata
  -> 300 GiB scsi1 on each Talos worker
  -> Talos /dev/sdb
  -> Talos UserVolumeConfig
  -> XFS /dev/sdb1
  -> /var/mnt/local-path-provisioner
  -> Rancher Local Path Provisioner
  -> default StorageClass local-path
  -> dynamically provisioned PVC/PV
```

This is node-local persistent storage. It is not replicated and is not
physically highly available because both Talos workers still run on the single
physical Proxmox host `pve01`.

## Verified platform state

| Item | Verified value |
|---|---|
| Proxmox host | `pve01` |
| Proxmox Manager observed | `9.2.10` |
| Talos | `v1.13.6` |
| Kubernetes server | `v1.36.2` |
| Administration kubectl | WinGet `v1.36.3` |
| Worker 1 | VM `211`, `talos-worker-01`, `192.168.1.211` |
| Worker 2 | VM `212`, `talos-worker-02`, `192.168.1.212` |
| Worker system disk | 64 GiB `scsi0`, Talos `/dev/sda` |
| Worker data disk | 300 GiB `scsi1`, Talos `/dev/sdb` |
| Talos user volume | `u-local-path-provisioner` |
| Filesystem | XFS |
| Talos mount | `/var/mnt/local-path-provisioner` |
| Provisioner | Rancher Local Path Provisioner `v0.0.37` |
| StorageClass | `local-path` (default) |
| Provisioner name | `rancher.io/local-path` |
| Reclaim policy | `Delete` |
| Volume binding | `WaitForFirstConsumer` |
| Dynamic PVC/PV test | Passed |
| Persistence across Pod deletion/recreation | Passed |
| Reclaim cleanup test | Passed |

## 1. Dedicated worker disks

Before this phase each Talos worker had only the 64 GiB system disk.

A separate 300 GiB `scsi1` disk was added to each worker from Proxmox
`vmdata`.

```text
VM 211 talos-worker-01
  scsi0  64 GiB   Talos system disk
  scsi1  300 GiB  Kubernetes persistent data

VM 212 talos-worker-02
  scsi0  64 GiB   Talos system disk
  scsi1  300 GiB  Kubernetes persistent data
```

Talos discovered the new virtual disks as approximately 322 GB `/dev/sdb`.
The 300 GiB / 322 GB difference is only binary-versus-decimal capacity
representation.

## 2. Talos user volume

The committed Talos configuration is:

```text
talos/patches/60-local-path-provisioner-volume.yaml
```

```yaml
apiVersion: v1alpha1
kind: UserVolumeConfig
name: local-path-provisioner
provisioning:
  diskSelector:
    match: "!system_disk && disk.size > 250u * GiB"
  minSize: 250GiB
  grow: true
filesystem:
  type: xfs
```

The selector excludes the system disk and selects only the dedicated large
data disk.

The configuration was applied one worker at a time and both workers reported:

```text
ID        u-local-path-provisioner
TYPE      partition
PHASE     ready
LOCATION  /dev/sdb1
SIZE      322 GB
FS        xfs
MOUNT     /var/mnt/local-path-provisioner
```

## 3. Rancher Local Path Provisioner

The Kustomize definition is stored at:

```text
kubernetes/infrastructure/local-path-provisioner/kustomization.yaml
```

The initial deployment was applied manually for validation:

```powershell
kubectl kustomize `
  ".\kubernetes\infrastructure\local-path-provisioner"

kubectl apply -k `
  ".\kubernetes\infrastructure\local-path-provisioner"
```

Verified state:

```text
Namespace:          local-path-storage
Deployment:         local-path-provisioner
Deployment:         1/1 Available
StorageClass:       local-path (default)
Provisioner:        rancher.io/local-path
ReclaimPolicy:      Delete
VolumeBindingMode:  WaitForFirstConsumer
Backing path:       /var/mnt/local-path-provisioner
```

### GitOps status

The manifest is committed to Git, but the initial storage deployment was
performed manually and is **not yet part of the active Flux reconciliation
path**. Do not describe it as Flux-managed until a Flux Kustomization or
equivalent reconciliation resource is added and verified.

## 4. Pod Security Admission warning

Applying the upstream provisioner produced a `restricted:latest` Pod Security
warning.

Talos showed the cluster defaults:

```text
enforce: baseline
audit: restricted
warn: restricted
```

The `local-path-storage` namespace has:

```text
pod-security.kubernetes.io/enforce=privileged
```

The warning was informational for the stricter warning/audit profile; the
provisioner Deployment was accepted and became healthy.

## 5. Dynamic PVC/PV smoke test

The reproducible smoke-test manifest is stored at:

```text
kubernetes/infrastructure/local-path-provisioner/tests/storage-smoke-test.yaml
```

The test used:

```text
Namespace:     storage-test
PVC:           local-path-test
Requested:     1 GiB
Access mode:   ReadWriteOnce
StorageClass:  local-path
```

The Local Path Provisioner dynamically created and bound a PV.

Observed test allocation:

```text
PV:
pvc-ef4426a1-0357-4f24-b1e0-5e500935f289

Node:
talos-worker-02

Physical path:
/var/mnt/local-path-provisioner/
pvc-ef4426a1-0357-4f24-b1e0-5e500935f289_storage-test_local-path-test
```

The generated PV UUID is test evidence only and is not a stable identifier.

## 6. Write/read and persistence proof

The test Pod wrote:

```text
/data/persistence-proof.txt
/data/created-at.txt
```

The proof file contained:

```text
Talos persistent storage test - SUCCESS
```

The original timestamp was:

```text
Sun Aug 9 01:40:58 UTC 2026
```

The files were also visible through Talos at the physical backing path.

The original Pod was then deleted while the PVC remained `Bound`. A new Pod
was created from the same manifest using the same PVC. The recreated Pod read
the pre-existing proof file and original timestamp successfully.

This proves persistence across Pod deletion/recreation while the same PVC/PV
remains bound.

## 7. Reclaim-policy cleanup

After testing:

```powershell
kubectl delete namespace storage-test
```

Validation showed:

```text
kubectl get pvc -A
No resources found

kubectl get pv
No resources found
```

Talos inspection confirmed the generated PVC directory was removed from:

```text
/var/mnt/local-path-provisioner
```

This validates cleanup for the `Delete` reclaim policy.

## 8. kubectl command-resolution repair

During testing, `kubectl exec POD -- COMMAND` initially failed even though the
syntax was correct.

PowerShell command discovery showed a custom `function global:kubectl` was
shadowing the real executable. Docker Desktop also supplied an older bundled
`kubectl.exe`.

The PowerShell wrapper was removed, the unused Docker Desktop bundled
`kubectl.exe` was disabled, and a fresh shell was opened.

Final command resolution:

```text
kubectl
  -> WinGet kubectl.exe v1.36.3
```

The normal syntax was then verified with a disposable BusyBox Pod:

```powershell
kubectl exec kubectl-exec-test -- `
  echo "kubectl exec works correctly"
```

Observed:

```text
kubectl exec works correctly
```

The disposable Pod was removed after the test.

## 9. Routine validation

```powershell
$CP = "192.168.1.210"
$W1 = "192.168.1.211"
$W2 = "192.168.1.212"

kubectl get storageclass
kubectl get deployment -n local-path-storage
kubectl get pods -n local-path-storage -o wide
kubectl get pvc -A
kubectl get pv

talosctl -e $CP -n $W1 `
  get volumestatus u-local-path-provisioner

talosctl -e $CP -n $W2 `
  get volumestatus u-local-path-provisioner
```

Healthy baseline:

- `local-path` is the default StorageClass;
- `local-path-provisioner` is `1/1 Available`;
- both Talos user volumes are `ready`;
- no disposable test PVC/PV remains.

## 10. Operational limitations

- Volumes are node-local.
- Data is not replicated between the two Talos workers.
- A local PV carries node affinity to its storage-owning node.
- Both worker virtual disks are backed by the same physical Proxmox host.
- Physical `pve01` failure is therefore an availability failure.
- etcd snapshots do not back up application PV contents.
- Stateful-application backup and recovery must be designed separately.

## 11. Next task

The Talos persistent-storage prerequisite is complete.

Next:

1. define retention and resource limits;
2. deploy Prometheus, Grafana and Alertmanager;
3. deploy Loki and Grafana Alloy;
4. expose selected dashboards only through authenticated Tailscale access.