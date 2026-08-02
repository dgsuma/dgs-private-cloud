# Flux and Tailscale Validation Runbook

Use this runbook after a reboot, GitOps change, Flux upgrade, Tailscale upgrade, or recovery event.

## 1. Select the correct Kubernetes context

```powershell
Set-Location "E:\home-server\dgs-private-cloud"

$env:KUBECONFIG = (Resolve-Path ".\talos\generated\kubeconfig").Path

kubectl config current-context
kubectl cluster-info
```

Expected:

```text
admin@dgs-homelab
https://192.168.1.210:6443
```

## 2. Check Kubernetes first

```powershell
kubectl get nodes -o wide
kubectl get pods -A
```

Do not troubleshoot Flux or Tailscale until all nodes and core cluster services are healthy.

## 3. Validate Flux

```powershell
flux check
flux get sources git -A
flux get kustomizations -A
kubectl get pods -n flux-system
```

Expected:

- all checks passed;
- GitRepository `Ready=True`;
- Kustomization `Ready=True`;
- four Flux controller Deployments running.

## 4. Validate the Tailscale Helm resources

```powershell
flux get sources helm -A
flux get helmreleases -A
```

Expected:

- HelmRepository `tailscale` is `Ready=True`;
- HelmRelease `tailscale-operator` is `Ready=True`.

## 5. Validate the Tailscale workload

```powershell
kubectl get deployment -n tailscale
kubectl get pods -n tailscale
kubectl get ingressclass tailscale
kubectl get secret operator-oauth -n tailscale
```

Expected:

- Deployment `operator` is available;
- operator pod is running;
- IngressClass `tailscale` exists;
- Secret `operator-oauth` has `DATA 2`.

## 6. Inspect logs safely

```powershell
kubectl logs -n tailscale deployment/operator --tail=100
```

Investigate repeated instances of:

```text
unauthorized
authentication failed
invalid tag
forbidden
fatal
panic
```

The following informational message is not a failure when a Service is not configured for a ProxyGroup:

```text
no ProxyGroup annotation, skipping Tailscale Service provisioning
```

## 7. Reconcile GitOps

```powershell
flux reconcile source git flux-system --namespace flux-system

flux reconcile kustomization flux-system `
  --namespace flux-system `
  --with-source
```

For the Tailscale chart:

```powershell
flux reconcile source helm tailscale --namespace tailscale

flux reconcile helmrelease tailscale-operator `
  --namespace tailscale `
  --with-source
```

## 8. Verify in the Tailscale console

Confirm:

- machine `beelink-talos-operator` exists;
- state is Connected;
- tag is `tag:k8s-operator`;
- device expiry remains disabled if that is the intended operating policy.

## 9. Recovery failure cases

### Git source not ready

Check:

```powershell
kubectl describe gitrepository flux-system -n flux-system
kubectl get secret flux-system -n flux-system
```

Do not print Secret values. Confirm the repository is private and the deploy key still exists in GitHub.

### HelmRelease not ready

Check:

```powershell
kubectl describe helmrelease tailscale-operator -n tailscale
kubectl get events -n tailscale --sort-by=.lastTimestamp
```

### Operator authentication failure

Confirm the OAuth credential still exists in Tailscale and that `operator-oauth` contains both required keys. Rotate the OAuth credential if compromise is suspected, recreate the Kubernetes Secret, and reconcile the HelmRelease.

## 10. Completion record

Record:

- date and time;
- Git revision reconciled;
- Flux readiness;
- HelmRelease readiness;
- operator pod status and restart count;
- Tailscale console connection state;
- any remediation performed.

Do not record credentials or decoded Secret values.
