# Runbook: Talos etcd Snapshot

## Purpose

Create and verify a consistent off-cluster backup of the Kubernetes API state stored in etcd.

An etcd snapshot can contain Kubernetes Secrets. Treat it as sensitive backup material and never commit it.

## Current recorded snapshots

```text
dgs-homelab-etcd-2026-07-26_192642.snapshot
dgs-homelab-etcd-2026-08-01_090643.snapshot
```

Both have corresponding `.sha256` files and are stored outside the repository.

## What the snapshot protects

- namespaces,
- deployments and services,
- ConfigMaps and Secrets,
- RBAC objects,
- custom resources,
- persistent-volume metadata.

It does not back up application persistent-volume contents.

## Fresh PowerShell session

```powershell
$CP = "192.168.1.210"
$W1 = "192.168.1.211"
$W2 = "192.168.1.212"
$RepoPath = "E:\home-server\dgs-private-cloud"
$TalosConfig = Join-Path $RepoPath "talos\generated\talosconfig"
$BackupFolder = "E:\home-server-backups\etcd"

if (-not (Test-Path -LiteralPath $TalosConfig -PathType Leaf)) {
    throw "Talos configuration was not found: $TalosConfig"
}

if ((Get-Item -LiteralPath $TalosConfig).Length -le 0) {
    throw "Talos configuration is empty: $TalosConfig"
}

$env:TALOSCONFIG = $TalosConfig
```

## Authenticate to every node

```powershell
talosctl version --nodes $CP --endpoints $CP --talosconfig $TalosConfig
talosctl version --nodes $W1 --endpoints $CP --talosconfig $TalosConfig
talosctl version --nodes $W2 --endpoints $CP --talosconfig $TalosConfig
```

Do not use `--insecure` on the configured cluster.

## Health check

```powershell
talosctl health `
  --control-plane-nodes $CP `
  --worker-nodes "$W1,$W2" `
  --endpoints $CP `
  --talosconfig $TalosConfig
```

Do not proceed unless etcd, control-plane components, kubelets, CoreDNS, and node readiness complete with `OK`.

## Reusable script

From the repository root:

```powershell
.\scripts\workstation\New-TalosEtcdSnapshot.ps1 `
  -ControlPlane $CP `
  -WorkerNodes $W1,$W2 `
  -BackupFolder $BackupFolder `
  -TalosConfig $TalosConfig
```

The script:

- verifies `talosctl`,
- verifies the client configuration,
- authenticates to the control plane and workers,
- checks Talos health,
- creates a timestamped snapshot,
- generates a SHA-256 file,
- verifies the checksum,
- displays the resulting paths and sizes.

## Manual snapshot command

```powershell
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
```

## Verify

```powershell
Get-Item -LiteralPath $Snapshot, "$Snapshot.sha256" |
  Select-Object FullName, Length, LastWriteTime

$Expected = (Get-Content -LiteralPath "$Snapshot.sha256").Split()[0]
$Actual = (Get-FileHash -LiteralPath $Snapshot -Algorithm SHA256).Hash

if ($Expected -ne $Actual) {
    throw "SHA-256 verification failed"
}
```

## Empty-folder failure

If `talosctl` reports `talos config file is empty`, the current PowerShell session does not have a valid cluster-specific client configuration. Set `$env:TALOSCONFIG` again or pass `--talosconfig` explicitly. The destination folder may exist even though no snapshot was created.

## Retention guidance

- Keep multiple dated snapshots.
- Take a snapshot before Talos, Kubernetes, CNI, or major application changes.
- Keep at least one encrypted copy on another physical device.
- Verify checksums after copying.
- Do not attempt a restore on the only working cluster.
