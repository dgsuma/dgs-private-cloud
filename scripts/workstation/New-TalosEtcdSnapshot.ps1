[CmdletBinding()]
param(
    [Parameter()]
    [ValidatePattern('^(?:\d{1,3}\.){3}\d{1,3}$')]
    [string]$ControlPlane = '192.168.1.210',

    [Parameter()]
    [string[]]$WorkerNodes = @('192.168.1.211', '192.168.1.212'),

    [Parameter()]
    [string]$BackupFolder = 'E:\home-server-backups\etcd',

    [Parameter()]
    [string]$TalosConfig
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command talosctl -ErrorAction SilentlyContinue)) {
    throw 'talosctl was not found in PATH.'
}

if ([string]::IsNullOrWhiteSpace($TalosConfig)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $TalosConfig = Join-Path $RepoRoot 'talos\generated\talosconfig'
}

if (-not (Test-Path -LiteralPath $TalosConfig -PathType Leaf)) {
    throw "Talos configuration file was not found: $TalosConfig"
}

$TalosConfigItem = Get-Item -LiteralPath $TalosConfig
if ($TalosConfigItem.Length -le 0) {
    throw "Talos configuration file is empty: $TalosConfig"
}

$env:TALOSCONFIG = $TalosConfig
New-Item -ItemType Directory -Force -Path $BackupFolder | Out-Null
$BackupFolder = (Resolve-Path -LiteralPath $BackupFolder).Path

Write-Host 'Testing authenticated control-plane access...'
& talosctl version `
    --nodes $ControlPlane `
    --endpoints $ControlPlane `
    --talosconfig $TalosConfig
if ($LASTEXITCODE -ne 0) {
    throw "Authenticated access to control plane $ControlPlane failed."
}

foreach ($Worker in @($WorkerNodes)) {
    if ([string]::IsNullOrWhiteSpace($Worker)) {
        continue
    }

    Write-Host "Testing authenticated worker access: $Worker"
    & talosctl version `
        --nodes $Worker `
        --endpoints $ControlPlane `
        --talosconfig $TalosConfig
    if ($LASTEXITCODE -ne 0) {
        throw "Authenticated access to worker $Worker failed."
    }
}

$WorkerArgument = (@($WorkerNodes) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join ','

Write-Host 'Checking Talos cluster health...'
$HealthArgs = @(
    'health',
    '--control-plane-nodes', $ControlPlane,
    '--endpoints', $ControlPlane,
    '--talosconfig', $TalosConfig
)

if (-not [string]::IsNullOrWhiteSpace($WorkerArgument)) {
    $HealthArgs += @('--worker-nodes', $WorkerArgument)
}

& talosctl @HealthArgs
if ($LASTEXITCODE -ne 0) {
    throw 'Talos health check failed. Snapshot was not attempted.'
}

$Timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$Snapshot = Join-Path $BackupFolder "dgs-homelab-etcd-$Timestamp.snapshot"

Write-Host "Creating etcd snapshot from $ControlPlane..."
& talosctl etcd snapshot $Snapshot `
    --nodes $ControlPlane `
    --endpoints $ControlPlane `
    --talosconfig $TalosConfig
if ($LASTEXITCODE -ne 0) {
    throw "talosctl etcd snapshot failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $Snapshot -PathType Leaf)) {
    throw "Snapshot command completed but no file was found: $Snapshot"
}

$SnapshotItem = Get-Item -LiteralPath $Snapshot
if ($SnapshotItem.Length -le 0) {
    throw "The snapshot file exists but is empty: $Snapshot"
}

$Hash = Get-FileHash -LiteralPath $Snapshot -Algorithm SHA256
$HashPath = "$Snapshot.sha256"
"$($Hash.Hash)  $($SnapshotItem.Name)" |
    Set-Content -LiteralPath $HashPath -Encoding ascii

$ExpectedHash = (Get-Content -LiteralPath $HashPath).Split()[0].Trim()
$ActualHash = (Get-FileHash -LiteralPath $Snapshot -Algorithm SHA256).Hash
if ($ExpectedHash -ne $ActualHash) {
    throw 'SHA-256 verification failed.'
}

[pscustomobject]@{
    Snapshot          = $SnapshotItem.FullName
    SnapshotBytes     = $SnapshotItem.Length
    Sha256            = $ActualHash
    HashFile          = (Get-Item -LiteralPath $HashPath).FullName
    ChecksumVerified  = $true
    Created           = $SnapshotItem.LastWriteTime
}
