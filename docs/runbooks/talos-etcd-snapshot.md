# Runbook: Talos etcd Snapshot

## Purpose

Create and verify a consistent backup of the Kubernetes API state stored in etcd.

An etcd snapshot can contain Kubernetes Secrets. Treat it as sensitive backup material and never commit it.

## What the snapshot protects

The snapshot captures Kubernetes API objects such as:

- namespaces,
- deployments,
- services,
- ConfigMaps,
- Secrets,
- RBAC objects,
- custom resources,
- persistent-volume metadata.

It does not back up the actual contents of application persistent volumes.

## Prerequisites

- The control-plane node is healthy.
- `talosctl` matches the cluster version.
- The cluster-specific `talosconfig` exists and is non-empty.
- The destination is outside the Git repository and preferably outside the cluster.

## Reusable script

From the repository root:

```powershell
.\scripts\workstation\New-TalosEtcdSnapshot.ps1 `
  -ControlPlane "192.168.1.210" `
  -BackupFolder "E:\home-server-backups\etcd"
```

To provide an explicit Talos client configuration:

```powershell
.\scripts\workstation\New-TalosEtcdSnapshot.ps1 `
  -ControlPlane "192.168.1.210" `
  -BackupFolder "E:\home-server-backups\etcd" `
  -TalosConfig ".\talos\generated\talosconfig"
```

## Manual procedure

```powershell
$CP = "192.168.1.210"
$TalosConfig = "E:\home-server\dgs-private-cloud\talos\generated\talosconfig"
$BackupFolder = "E:\home-server-backups\etcd"

if (-not (Test-Path -LiteralPath $TalosConfig -PathType Leaf)) {
    throw "Talos configuration was not found: $TalosConfig"
}

if ((Get-Item -LiteralPath $TalosConfig).Length -eq 0) {
    throw "Talos configuration is empty: $TalosConfig"
}

New-Item -ItemType Directory -Force -Path $BackupFolder | Out-Null

$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$Snapshot = Join-Path $BackupFolder "dgs-homelab-etcd-$Timestamp.snapshot"

talosctl etcd snapshot $Snapshot `
  --nodes $CP `
  --endpoints $CP `
  --talosconfig $TalosConfig

if ($LASTEXITCODE -ne 0) {
    throw "The etcd snapshot command failed with exit code $LASTEXITCODE"
}

$Hash = Get-FileHash -LiteralPath $Snapshot -Algorithm SHA256
"$($Hash.Hash)  $([IO.Path]::GetFileName($Snapshot))" |
  Set-Content -LiteralPath "$Snapshot.sha256" -Encoding ascii

Get-Item -LiteralPath $Snapshot, "$Snapshot.sha256" |
  Select-Object FullName, Length, LastWriteTime
```

## Expected success evidence

The command should report:

```text
etcd snapshot saved to "<path>" (<non-zero bytes>)
snapshot info: hash <value>, revision <value>, total keys <value>, total size <value>
```

Verify:

- the snapshot exists,
- its length is greater than zero,
- the `.sha256` file exists,
- the destination is not inside the repository.

## Why an empty folder can occur

If `talosctl` reports:

```text
talos config file is empty
```

then the terminal does not have a valid cluster-specific Talos client configuration. Set `$env:TALOSCONFIG` again or provide `--talosconfig` explicitly. The destination folder may still be created, but no snapshot file is written because the client fails before contacting etcd.

## Retention guidance

For the current home lab:

- keep multiple dated snapshots,
- retain at least one known-good snapshot on a separate physical device,
- copy snapshots before major Kubernetes or Talos upgrades,
- periodically verify checksums,
- test recovery in an isolated and documented exercise.

## Restore warning

Restoring etcd is a disaster-recovery operation that can replace current cluster state. Do not attempt it casually or on the only working copy of the cluster.

Follow the Talos documentation for the exact installed version:

- https://docs.siderolabs.com/talos/v1.13/build-and-extend-talos/cluster-operations-and-maintenance/disaster-recovery
- https://docs.siderolabs.com/talos/v1.13/build-and-extend-talos/cluster-operations-and-maintenance/etcd-maintenance
