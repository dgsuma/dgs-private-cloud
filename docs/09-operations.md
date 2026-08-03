# Operations

## Administration entry points

| Component | Access |
|---|---|
| Proxmox | `https://192.168.1.201:8006` on the trusted LAN |
| Kubernetes API | `https://192.168.1.210:6443` through kubeconfig |
| Talos API | Control plane `192.168.1.210` through talosconfig |
| GitOps | Git commits to `main`; Flux reconciles `clusters/beelink-talos` |
| Tailscale | Admin console and future private Kubernetes services |

Do not expose management ports directly to the internet.

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
