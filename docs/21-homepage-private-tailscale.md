# Homepage through Flux and private Tailscale access

## Checkpoint

Completed and verified on `2026-08-16`.

This document records the first application-dashboard deployment on the DGS
private cloud, its private Tailscale exposure, the `CrashLoopBackOff` incident
encountered during the initial rollout, and the final recovery/validation state.

## Outcome

Homepage `v1.13.2` is now operational as a Flux-managed Kubernetes application.
The dashboard is reachable by authorised tailnet clients without `kubectl
port-forward` and is not exposed directly to the public internet.

Final path:

```text
Git repository
    |
    v
Flux reconciliation
    |
    v
homepage Deployment
    |
    v
homepage ClusterIP Service :3000
    |
    v
Tailscale Ingress proxy
    |
    v
private HTTPS for authorised tailnet clients
```

Verified clients:

- LG Gram administration workstation;
- Moto G84 over mobile data with Tailscale connected.

Exact private `.ts.net` names are intentionally omitted from this repository.

## GitOps layout

Homepage is reconciled from:

```text
clusters/beelink-talos/homepage/
├── namespace.yaml
├── homepage.yaml
├── homepage-tailscale-ingress.yaml
└── kustomization.yaml
```

The cluster root `clusters/beelink-talos/kustomization.yaml` includes
`./homepage`, so Flux owns the committed application resources.

## Kubernetes design

| Component | Design |
|---|---|
| Namespace | `homepage` |
| Image | `ghcr.io/gethomepage/homepage:v1.13.2` |
| Deployment replicas | `1` |
| Service | `homepage` |
| Service type | `ClusterIP` |
| Service port | `3000/TCP` |
| Ingress | `homepage-tailscale` |
| Ingress class | `tailscale` |
| Public exposure | None |
| Tailscale Funnel | Disabled/not configured |

The Kubernetes Service remains internal. Private HTTPS is provided by the
Tailscale Kubernetes Operator through the committed Ingress resource.

## Security controls

The Homepage container retains a restrictive security context:

- `runAsNonRoot: true`;
- UID/GID `1000`;
- `allowPrivilegeEscalation: false`;
- all Linux capabilities dropped;
- `RuntimeDefault` seccomp profile.

The Homepage Kubernetes identity is read-only. It can inspect the resources
required for dashboard discovery and metrics but receives no Kubernetes write
verbs.

No Homepage application credential or private tailnet hostname is stored in
Git.

## Runtime Secret

Until SOPS/age is operational, runtime values are supplied by a manually created
Secret:

```text
namespace: homepage
name:      homepage-runtime
```

Documented key names:

```text
HOMEPAGE_EXTERNAL_HOST
HOMEPAGE_VAR_GRAFANA_URL
```

The actual values must remain outside Git.

Recovery template using placeholders only:

```powershell
kubectl -n homepage create secret generic homepage-runtime `
  --from-literal=HOMEPAGE_EXTERNAL_HOST="<PRIVATE-HOMEPAGE-HOSTNAME>" `
  --from-literal=HOMEPAGE_VAR_GRAFANA_URL="https://<PRIVATE-GRAFANA-HOSTNAME>" `
  --dry-run=client `
  -o yaml |
  kubectl apply -f -
```

After SOPS/age and Flux decryption are proven, migrate this Secret to encrypted
Git management.

## Health-probe host handling

Homepage validates incoming hosts. Kubernetes health probes reach the container
using the Pod IP, while authorised users reach it through the private Tailscale
hostname. The Deployment therefore derives the allowed-host setting from both
runtime values:

```yaml
env:
  - name: MY_POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP

  - name: HOMEPAGE_EXTERNAL_HOST
    valueFrom:
      secretKeyRef:
        name: homepage-runtime
        key: HOMEPAGE_EXTERNAL_HOST

  - name: HOMEPAGE_ALLOWED_HOSTS
    value: "$(MY_POD_IP):3000,$(HOMEPAGE_EXTERNAL_HOST)"
```

This avoids committing the private hostname while allowing Kubernetes probes
and private client requests.

Readiness and liveness probes use:

```text
/api/healthcheck
```

with explicit timeout and failure thresholds.

## Initial symptom

The first rollout appeared healthy briefly and Homepage rendered successfully.
Later the private URL returned HTTP `502`, while the independently exposed
Grafana private URL continued to work.

Kubernetes then showed:

```text
READY   STATUS             RESTARTS
0/1     CrashLoopBackOff   12
```

The `502` therefore represented the Tailscale ingress proxy having no stable
Homepage backend, rather than a general Tailscale or MagicDNS outage.

Alertmanager also delivered a real `KubePodCrashLooping` warning for the
`homepage` namespace.

## Root-cause evidence

The previous-container log identified the actual startup failure:

```text
Failed to initialize required config: /app/config/proxmox.yaml
Reason: EACCES: permission denied, copyfile '/app/src/skeleton/proxmox.yaml' -> '/app/config/proxmox.yaml'
Hint: Make /app/config writable or manually place the config file.
```

The application expected `proxmox.yaml`. Because `/app/config` was being
provided with ConfigMap-backed files and the container was intentionally running
non-root, Homepage could not create the missing file and exited. Kubernetes
restarted it repeatedly, producing `CrashLoopBackOff` and intermittent Tailscale
`502` responses.

## CrashLoopBackOff recovery

The solution retained the non-root security design and made all required paths
explicit.

### 1. Supply `proxmox.yaml`

The Homepage ConfigMap now includes:

```yaml
proxmox.yaml: ""
```

and the Deployment mounts it explicitly:

```yaml
- name: homepage-config
  mountPath: /app/config/proxmox.yaml
  subPath: proxmox.yaml
```

It is intentionally empty until a least-privilege Proxmox integration is
designed.

### 2. Provide a writable log path

The Deployment mounts:

```yaml
- mountPath: /app/config/logs
  name: logs
```

from:

```yaml
- name: logs
  emptyDir: {}
```

This gives Homepage a writable log directory without making the complete
configuration directory writable.

### 3. Correct allowed-host and probe handling

The Pod IP is obtained through the Kubernetes downward API, the external private
hostname remains in `homepage-runtime`, and `HOMEPAGE_ALLOWED_HOSTS` combines
them at runtime.

The custom `Host: localhost:3000` headers were removed from the HTTP probes, and
probe timeout/failure thresholds were made explicit.

### 4. Retain least-privilege identity

The ServiceAccount token Secret is associated with the Homepage ServiceAccount.
RBAC remains read-only; `metrics.k8s.io` read access is included for future
resource widgets.

## Flux rollout validation

After committing and pushing the recovery change:

```powershell
flux reconcile kustomization flux-system --with-source
flux get kustomizations -A
kubectl -n homepage rollout status deployment/homepage --timeout=5m
kubectl -n homepage get pods -o wide
```

Verified result:

```text
Deployment: 1/1 Ready, 1 Up-to-date, 1 Available
Pod:        1/1 Running, 0 restarts
```

The runtime allowed-host value was also inspected from the Pod. It contained the
current Pod IP with port `3000` and the private external hostname. The actual
private hostname is not reproduced here.

## Repeated HTTPS validation

A single successful page load was not considered sufficient because the original
failure was intermittent. Twenty private HTTPS requests were issued five seconds
apart:

```powershell
$HomepageFqdn = (
    kubectl -n homepage get ingress homepage-tailscale `
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
).Trim()

1..20 | ForEach-Object {
    $Time = Get-Date -Format "HH:mm:ss"

    curl.exe `
        -sS `
        -o NUL `
        -w "$Time  HTTP %{http_code}`n" `
        "https://$HomepageFqdn/"

    Start-Sleep -Seconds 5
}
```

Result: all 20 requests returned HTTP `200`. No `502` response occurred, and the
Homepage Pod still reported zero restarts afterwards.

## Workstation and mobile validation

### LG Gram

- Homepage loaded over its private Tailscale HTTPS endpoint.
- The Grafana service card rendered correctly and linked to the separately
  protected private Grafana endpoint.
- No local `kubectl port-forward` was required.

### Moto G84

- Wi-Fi was not required for the validation; the phone used mobile data.
- Tailscale was connected.
- Homepage loaded successfully in the mobile browser.

This verifies that Homepage is usable as a private remote application dashboard,
not merely as a LAN-local page.

## Alerting lesson from the incident

The failure provided a real validation of the monitoring path:

```text
Homepage CrashLoopBackOff
        |
        v
kube-state-metrics
        |
        v
Prometheus alert evaluation
        |
        v
Alertmanager
        |
        v
Gmail warning
```

The `KubePodCrashLooping` email confirmed that the existing alerting stack can
surface an application failure outside the monitoring namespace.

## Troubleshooting rule captured from this incident

When one private Tailscale-backed application returns `502` while another
Tailscale-backed application remains healthy:

1. check the failing application's Deployment and Pod state first;
2. inspect current and `--previous` container logs;
3. check readiness/liveness events and Service EndpointSlices;
4. only then investigate the application-specific Tailscale proxy.

A healthy Grafana path during the Homepage outage was strong evidence that the
general tailnet, MagicDNS, certificate path, and operator were not the primary
failure domain.

Useful commands:

```powershell
kubectl -n homepage get deployment,pods,svc,ingress -o wide
kubectl -n homepage logs deployment/homepage --tail=100
kubectl -n homepage get endpointslice -l kubernetes.io/service-name=homepage -o wide
kubectl -n tailscale get pods -o wide
```

For a restarted Pod, capture the previous container log before rollout replaces
it:

```powershell
$HomepagePod = (
    kubectl -n homepage get pod `
        -l app.kubernetes.io/name=homepage `
        -o jsonpath='{.items[0].metadata.name}'
).Trim()

kubectl -n homepage logs $HomepagePod --previous --tail=100
```

## Recovery checklist

After rebuilding the cluster or namespace:

1. restore/create the out-of-band `homepage-runtime` Secret with the two required values;
2. verify Flux can reconcile `clusters/beelink-talos/homepage/`;
3. wait for the Homepage Deployment to become `1/1` Available;
4. confirm the Pod restart count remains zero;
5. verify `HOMEPAGE_ALLOWED_HOSTS` includes the current Pod IP/port and private external host;
6. confirm the `homepage` Service remains `ClusterIP`;
7. confirm `homepage-tailscale` has a private Tailscale address;
8. perform repeated HTTPS tests rather than relying on a single successful request;
9. verify access from at least one authorised device outside the local LAN.

## Remaining Homepage work

The baseline application is complete. Future enhancements should be incremental:

- add a Proxmox card/integration only with a documented least-privilege API token design;
- add Jenkins and GitOps/Flux links;
- add Kubernetes resource widgets after confirming metrics API behaviour;
- add storage and future IoT services;
- migrate `homepage-runtime` to SOPS-encrypted Git management;
- continue to keep private tailnet hostnames and credentials out of plaintext Git.
