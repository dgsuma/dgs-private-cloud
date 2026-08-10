# Operations

## Administration entry points

| Component | Access |
|---|---|
| Proxmox | `https://192.168.1.201:8006` on the trusted LAN |
| Kubernetes API | `https://192.168.1.210:6443` through kubeconfig |
| Talos API | Control plane `192.168.1.210` through talosconfig |
| GitOps | Git commits to `main`; Flux reconciles `clusters/beelink-talos` |
| Tailscale | Admin console and future private Kubernetes services |
| Jenkins | Private Tailscale Serve HTTPS; backend 127.0.0.1:8080 |

Do not expose management ports directly to the internet.

## Jenkins controller operations

Jenkins runs on VM `220` (`jenkins-ci`) at `192.168.1.213`. The browser interface is intentionally not exposed directly on LAN TCP `8080`.

Routine checks inside the VM:

```bash
hostname
ip -br address
systemctl is-enabled jenkins
systemctl is-active jenkins
systemctl is-enabled tailscaled
systemctl is-active tailscaled
systemctl is-active qemu-guest-agent
sudo ss -lntp | grep ':8080'
curl -I http://127.0.0.1:8080/login
sudo tailscale serve status
```

Expected state:

- Jenkins, Tailscale, and QEMU Guest Agent are active.
- Jenkins TCP `8080` is loopback-only.
- Local `curl` to `127.0.0.1:8080/login` succeeds.
- Tailscale Serve reports private HTTPS proxying to `127.0.0.1:8080`.
- Direct browser access to `http://192.168.1.213:8080` fails.

Service recovery:

```bash
sudo systemctl restart jenkins
sudo systemctl status jenkins --no-pager
sudo journalctl -u jenkins -n 100 --no-pager

sudo systemctl restart tailscaled
sudo tailscale serve status
```

Known-good Proxmox snapshot:

```text
jenkins-baseline-tailscale
```

A Proxmox snapshot is a rollback point, not an external backup.

See [Jenkins Controller Phase 1](16-jenkins-controller-phase1.md).

## Workstation session setup

```powershell
Set-Location "E:\home-server\dgs-private-cloud"

$env:TALOSCONFIG = (Resolve-Path ".\talos\generated\talosconfig").Path
$env:KUBECONFIG = (Resolve-Path ".\talos\generated\kubeconfig").Path

kubectl config current-context
kubectl cluster-info
```

Expected context:

```text
admin@dgs-homelab
```

## Routine Kubernetes and Talos health check

```powershell
kubectl get nodes -o wide
kubectl get pods -A -o wide

talosctl health `
  --control-plane-nodes 192.168.1.210 `
  --worker-nodes "192.168.1.211,192.168.1.212" `
  --endpoints 192.168.1.210
```

## Routine persistent-storage check

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

- `local-path` exists and is the default StorageClass.
- `local-path-provisioner` is `1/1 Available`.
- Both Talos user volumes report `ready`.
- No unexpected disposable-test PVC/PV remains.
- `/var/mnt/local-path-provisioner` remains mounted on both workers.

The current storage is node-local and not replicated. A workload using a
local PV remains dependent on the worker that owns that PV and, ultimately,
on the single physical `pve01` host.
## Routine Flux check

```powershell
flux check
flux get sources git -A
flux get kustomizations -A
flux get sources helm -A
flux get helmreleases -A
```

Healthy state:

- GitRepository `Ready=True`;
- Kustomization `Ready=True`;
- Tailscale HelmRepository `Ready=True`;
- Tailscale HelmRelease `Ready=True`.

Force reconciliation after a Git push:

```powershell
flux reconcile source git flux-system --namespace flux-system

flux reconcile kustomization flux-system `
  --namespace flux-system `
  --with-source
```

## Routine Tailscale Operator check

```powershell
kubectl get deployment -n tailscale
kubectl get pods -n tailscale
kubectl get ingressclass tailscale
kubectl get secret operator-oauth -n tailscale
kubectl logs -n tailscale deployment/operator --tail=100
```

Expected state:

- Deployment `operator` is `1/1 Available`;
- pod is `1/1 Running`;
- restart count is normally zero;
- IngressClass `tailscale` exists;
- Secret `operator-oauth` contains two data entries;
- no continuing authentication, invalid-tag, fatal, or crash errors.

The log message below is informational when a Service is not configured for a ProxyGroup:

```text
no ProxyGroup annotation, skipping Tailscale Service provisioning
```

<!-- BEGIN OBSERVABILITY OPERATIONS 2026-08-10 -->
## Observability operations

Routine HelmRelease health:

```powershell
flux get helmreleases -n monitoring
```

Expected:

```text
alloy                   Ready=True
kube-prometheus-stack   Ready=True
loki                    Ready=True
```

Workload and storage checks:

```powershell
kubectl get daemonset alloy -n monitoring -o wide

kubectl get pods -n monitoring -o wide |
    Select-String "alloy"

kubectl get pods -n monitoring -o wide |
    Select-String "loki"

kubectl get pvc -n monitoring

kubectl get svc -n monitoring |
    Select-String "loki"
```

Grafana foreground access:

```powershell
kubectl -n monitoring port-forward `
    svc/kube-prometheus-stack-grafana `
    3000:80
```

Then open:

```text
http://localhost:3000/
```

Grafana background access from Windows:

```powershell
$Kubectl = (Get-Command kubectl).Source

$GrafanaPF = Start-Process `
    -FilePath $Kubectl `
    -ArgumentList @(
        "port-forward",
        "-n", "monitoring",
        "svc/kube-prometheus-stack-grafana",
        "3000:80",
        "--address", "127.0.0.1"
    ) `
    -WindowStyle Hidden `
    -RedirectStandardOutput "$env:TEMP\grafana-port-forward.out.log" `
    -RedirectStandardError "$env:TEMP\grafana-port-forward.err.log" `
    -PassThru

$GrafanaPF.Id | Set-Content "$env:TEMP\grafana-port-forward.pid"
```

Check the background process:

```powershell
$GrafanaPid = Get-Content "$env:TEMP\grafana-port-forward.pid"
Get-Process -Id $GrafanaPid

Get-NetTCPConnection `
    -LocalPort 3000 `
    -State Listen
```

Stop it:

```powershell
$GrafanaPid = Get-Content "$env:TEMP\grafana-port-forward.pid"
Stop-Process -Id $GrafanaPid
Remove-Item "$env:TEMP\grafana-port-forward.pid" -ErrorAction SilentlyContinue
```

Useful Loki queries:

```logql
{cluster="beelink-talos", namespace="monitoring"}
```

```logql
{cluster="beelink-talos", namespace="flux-system"}
```

```logql
{cluster="beelink-talos", namespace="tailscale"}
```

```logql
{cluster="beelink-talos", namespace="monitoring"}
| detected_level="error"
```

```logql
{cluster="beelink-talos", namespace="monitoring"}
| detected_level="error" or detected_level="warn"
```

The background port-forward binds only to `127.0.0.1`. It survives closing the
launching PowerShell window but not Windows reboot/logoff or termination of the
`kubectl` process.

See [18-observability-stack.md](18-observability-stack.md) for the complete
implementation record.
<!-- END OBSERVABILITY OPERATIONS 2026-08-10 -->
## PowerShell command notes

PowerShell may treat an unquoted comma-separated kubectl resource expression unexpectedly. Prefer separate commands:

```powershell
kubectl get deployment -n tailscale
kubectl get pods -n tailscale
```

For commands that pipe generated YAML into `kubectl apply -f -`, this workstation has shown stdin hangs. Prefer direct creation commands or write the manifest to a file first.

## GitOps change workflow

```powershell
git status
git pull --ff-only origin main

# Edit and validate files.

kubectl kustomize ".\clusters\beelink-talos" | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Kustomize validation failed."
}

git diff --check
git diff
git add <specific-files>
git diff --cached --check
git diff --cached
git commit -m "<type(scope): description>"
git push origin main
```

Never stage the whole repository blindly when credentials, screenshots, or generated files may be present.

## Safe Proxmox shutdown

From the web interface:

```text
pve01 → Shutdown
```

From the shell:

```bash
shutdown -h now
```

Wait until the Beelink power light and fan stop before disconnecting power.

## Startup

Press the Beelink power button once. The BIOS setting `State After G3: S0 State` allows automatic power-on after electricity returns following a complete outage.

## Backup session closing procedure

Before disconnecting the Seagate backup disk:

1. Confirm every backup task has completed successfully.
2. Confirm no restore, upload, or copy task is active.
3. Disable `usb-backup-2tb` in Proxmox.
4. Run `sync`.
5. Unmount `/mnt/pve/usb-backup-2tb`.
6. Confirm `findmnt` returns no mount.
7. Disconnect the USB cable.

## Secret recovery note

The Tailscale `operator-oauth` Secret is not currently stored in Git. A cluster rebuild requires recreating it from the OAuth credentials stored in the password manager before the Tailscale HelmRelease can become fully operational. Move this Secret to SOPS-encrypted Git management in a later milestone.

<!-- BEGIN TAILSCALE REMOTE OPERATIONS -->
## Tailscale remote administration

The preferred remote Proxmox entry point is:

```text
https://mel-pve01.<tailnet-name>.ts.net/
```

The exact URL is kept in `git-commands-local.txt`, which is ignored by Git.

The Serve backend on `pve01` is:

```bash
tailscale serve --bg https+insecure://127.0.0.1:8006
```

Routine validation:

```bash
systemctl is-active tailscaled
tailscale status
tailscale serve status
systemctl is-active pveproxy
```

Windows client validation:

```powershell
tailscale ping mel-pve01
Test-NetConnection mel-pve01 -Port 8006
```

Operational requirements:

- Tailscale Funnel remains disabled.
- No public forwarding of TCP `8006`, `22`, or `6443`.
- The direct Tailscale endpoint on `mel-pve01` remains available even after a
  separate Raspberry Pi subnet router is added.
- Major network changes are not performed while Tailscale is the only
  administrative path.
- Reboot and recovery tests are performed while physically present in
  Melbourne.

See [the implementation guide](12-tailscale-reverse-proxy.md) and
[the validation runbook](runbooks/validate-tailscale-proxmox-access.md).
<!-- END TAILSCALE REMOTE OPERATIONS -->
