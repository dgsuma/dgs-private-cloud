# Observability Stack — Prometheus, Grafana, Alertmanager, Loki, Alloy and Tempo

## Status

**Phase 1 baseline completed: 2026-08-10**

**Distributed tracing extension verified: 2026-09-24**

The observability stack for the `dgs-homelab` Talos Kubernetes cluster is
operational and managed through Flux.

The implementation now provides:

- Prometheus metrics collection;
- Grafana dashboards and Explore;
- Alertmanager alert routing;
- Loki log storage and querying;
- Grafana Alloy Kubernetes log collection;
- OpenTelemetry OTLP trace ingestion through Alloy;
- Grafana Tempo distributed trace storage and querying;
- Grafana Tempo datasource integration;
- persistent local-path storage for Prometheus, Grafana, Alertmanager, Loki, and Tempo.

Application tracing has been verified for the Expense Tracker API and Homepage.

## Deployed versions

| Component | Version / chart | Verified state |
|---|---|---|
| kube-prometheus-stack | Helm chart `88.2.0` | `Ready=True` |
| Loki | Helm chart `18.7.6`; Loki application `3.7.6` | `Ready=True` |
| Grafana Alloy | Helm chart `1.11.1`; Alloy application `v1.18.1` | `Ready=True` |
| Tempo | Helm chart `3.0.0` | `Ready=True` |
| Flux | Existing cluster GitOps controller | Reconciliation succeeded |

## GitOps layout

The observability resources are managed below:

```text
clusters/beelink-talos/monitoring/
├── namespace.yaml
├── helmrepository-prometheus-community.yaml
├── helmrepository-grafana.yaml
├── helmrepository-grafana-community.yaml
├── kube-prometheus-stack.yaml
├── alertmanagerconfig-email.yaml
├── prometheusrule-local-path-storage.yaml
├── grafana-tailscale-ingress.yaml
├── kustomization.yaml
├── logging/
│   ├── kustomization.yaml
│   ├── loki-helmrelease.yaml
│   ├── alloy-helmrelease.yaml
│   └── grafana-loki-datasource.yaml
└── tempo/
    ├── kustomization.yaml
    ├── tempo-helmrelease.yaml
    └── grafana-tempo-datasource.yaml
```

The parent monitoring Kustomization includes both `./logging` and `./tempo`.

## Metrics stack

The `kube-prometheus-stack` HelmRelease provides Prometheus, Grafana,
Alertmanager, kube-state-metrics, the Prometheus Operator, and node-exporter.

### Persistent storage

| Component | PVC size | StorageClass |
|---|---:|---|
| Prometheus | `50Gi` | `local-path` |
| Grafana | `5Gi` | `local-path` |
| Alertmanager | `2Gi` | `local-path` |
| Loki | `20Gi` | `local-path` |
| Tempo | `20Gi` | `local-path` |

Prometheus is configured with:

```text
retention: 15d
retentionSize: 40GB
```

All five PVCs were verified `Bound`, including the `20Gi` Tempo PVC.

### Node exporter

The node-exporter DaemonSet is healthy across all three Talos nodes:

```text
talos-cp-01
talos-worker-01
talos-worker-02
```

## Loki — Step 5D

Loki is deployed in Monolithic mode for the current small single-host
home-lab phase.

Important configuration:

```text
deploymentMode: Monolithic
singleBinary replicas: 1
replication factor: 1
storage backend: filesystem
schema: TSDB / v13
PVC: 20Gi
StorageClass: local-path
gateway: enabled
chunks cache: disabled
results cache: disabled
MinIO: disabled
Loki canary: enabled
```

The Loki gateway remains an internal Kubernetes `ClusterIP` service.

Loki authentication is disabled inside this trusted cluster and the Loki
gateway must not be exposed directly to the public internet.

### Loki validation

The HelmRelease reported:

```text
loki  18.7.6  Ready=True
```

The following workloads were verified Running:

```text
loki-0
loki-gateway
loki-canary
```

The Loki build-information API returned Loki application version `3.7.6`.

The labels API returned a successful response.

The `storage-loki-0` PVC was verified:

```text
Status:       Bound
Capacity:     20Gi
Access mode:  RWO
StorageClass: local-path
```

## Grafana Loki datasource

Grafana receives the Loki datasource through the ConfigMap:

```text
monitoring/grafana-datasource-loki
```

The datasource points to:

```text
http://loki-gateway.monitoring.svc.cluster.local
```

Grafana Explore successfully queried Loki.

## Grafana Alloy — Step 5E

Alloy is deployed as a DaemonSet.

Verified DaemonSet state:

```text
Desired:   3
Current:   3
Ready:     3
Available: 3
```

One Alloy pod runs on each Kubernetes node:

```text
talos-cp-01
talos-worker-01
talos-worker-02
```

The Alloy configuration uses Kubernetes API discovery and
`loki.source.kubernetes`. Each DaemonSet instance selects pods assigned to its
own node and forwards log streams to Loki through:

```text
http://loki-gateway.monitoring.svc.cluster.local/loki/api/v1/push
```

Useful stream labels include:

```text
cluster
namespace
pod
container
node
app
job
container_runtime
```

A static cluster label is added:

```text
cluster=beelink-talos
```

## End-to-end logging validation

A temporary BusyBox pod named `loki-alloy-smoke` produced five controlled log
messages:

```text
DGS-LOKI-ALLOY-SMOKE line=1
DGS-LOKI-ALLOY-SMOKE line=2
DGS-LOKI-ALLOY-SMOKE line=3
DGS-LOKI-ALLOY-SMOKE line=4
DGS-LOKI-ALLOY-SMOKE line=5
```

Grafana Explore returned all five lines with:

```logql
{cluster="beelink-talos", namespace="default", pod="loki-alloy-smoke"}
```

and:

```logql
{cluster="beelink-talos", namespace="default"}
|= "DGS-LOKI-ALLOY-SMOKE"
```

The temporary smoke-test pod was deleted after validation.

Real workload collection was then verified from multiple namespaces.

### Monitoring logs

```logql
{cluster="beelink-talos", namespace="monitoring"}
```

### Flux logs

```logql
{cluster="beelink-talos", namespace="flux-system"}
```

### Tailscale logs

```logql
{cluster="beelink-talos", namespace="tailscale"}
```

### Detected errors

```logql
{cluster="beelink-talos", namespace="monitoring"}
| detected_level="error"
```

### Detected errors and warnings

```logql
{cluster="beelink-talos", namespace="monitoring"}
| detected_level="error" or detected_level="warn"
```

This proved the complete path:

```text
Kubernetes pod
    |
    v
Grafana Alloy
    |
    v
Loki gateway
    |
    v
Loki
    |
    v
20 GiB local-path persistent storage
    |
    v
Grafana / Loki datasource / Explore
```

## Tempo distributed tracing

Grafana Tempo extends the existing metrics and logging stack with
OpenTelemetry distributed tracing.

Tempo is Flux-managed using Helm chart `3.0.0` with:

```text
replicas: 1
multitenancy: disabled
trace retention: 168h / 7 days
StorageClass: local-path
PVC: 20Gi
ServiceMonitor: enabled
```

Tempo accepts OpenTelemetry traces on:

```text
OTLP/gRPC :4317
OTLP/HTTP :4318
```

The Tempo query API is available internally on TCP `3200`.

### OpenTelemetry trace path

The application trace path is:

```text
Application
    |
    | OTLP/HTTP :4318
    v
Grafana Alloy
    |
    | OTLP/gRPC :4317
    v
Grafana Tempo
    |
    | Tempo query API :3200
    v
Grafana Tempo datasource / Explore
```

Alloy accepts OTLP traces on ports `4317` and `4318` and forwards them to:

```text
tempo.monitoring.svc.cluster.local:4317
```

### Grafana Tempo datasource

Grafana discovers the Tempo datasource from the ConfigMap:

```text
monitoring/grafana-datasource-tempo
```

The datasource uses:

```text
name: Tempo
uid: tempo
type: tempo
url: http://tempo.monitoring.svc.cluster.local:3200
access: proxy
default: false
editable: false
```

Tempo remains internal to the Kubernetes cluster and is not exposed directly
to the public internet.

### Verified application tracing

End-to-end tracing has been verified for both the Expense Tracker API and
Homepage.

#### Expense Tracker API

The API exports traces to Alloy using:

```text
OTEL_SERVICE_NAME=expense-tracker-api
OTEL_TRACES_EXPORTER=otlp
OTEL_EXPORTER_OTLP_ENDPOINT=http://alloy.monitoring.svc.cluster.local:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_METRICS_EXPORTER=none
OTEL_LOGS_EXPORTER=none
```

Expense Tracker traces were successfully returned by Tempo and displayed in
Grafana Explore.

#### Homepage

Homepage exports HTTP traces through the same Alloy OTLP endpoint.

The verified runtime configuration includes:

```text
OTEL_SERVICE_NAME=homepage
OTEL_TRACES_EXPORTER=otlp
OTEL_EXPORTER_OTLP_ENDPOINT=http://alloy.monitoring.svc.cluster.local:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_METRICS_EXPORTER=none
OTEL_LOGS_EXPORTER=none
OTEL_NODE_ENABLED_INSTRUMENTATIONS=http
NODE_PATH=/otel/node_modules
NODE_OPTIONS=--require @opentelemetry/auto-instrumentations-node/register
```

Kubernetes readiness and liveness probes call:

```text
/api/healthcheck
```

Tempo returned spans containing both:

```text
service.name = homepage
http.target = /api/healthcheck
```

The verified Grafana TraceQL query is:

```traceql
{ resource.service.name = "homepage" && span.http.target = "/api/healthcheck" }
```

Grafana Explore displayed live Homepage `GET` traces with millisecond
durations on `2026-09-24`.

## Routine health validation

```powershell
flux get helmreleases -n monitoring

kubectl get daemonset alloy -n monitoring -o wide

kubectl get pods -n monitoring -o wide |
    Select-String "alloy"

kubectl get pods -n monitoring -o wide |
    Select-String "loki|tempo"

kubectl get pvc -n monitoring

kubectl get svc -n monitoring |
    Select-String "loki|tempo"
```

Expected HelmRelease state:

```text
alloy                   Ready=True
kube-prometheus-stack   Ready=True
loki                    Ready=True
tempo                   Ready=True
```

## Grafana local access

Foreground port-forward:

```powershell
kubectl -n monitoring port-forward `
    svc/kube-prometheus-stack-grafana `
    3000:80
```

Open:

```text
http://localhost:3000/
```

### Background port-forward on the Windows workstation

This keeps `kubectl.exe` running after the launching PowerShell window is
closed:

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

Validate:

```powershell
$GrafanaPid = Get-Content "$env:TEMP\grafana-port-forward.pid"
Get-Process -Id $GrafanaPid

Get-NetTCPConnection `
    -LocalPort 3000 `
    -State Listen
```

Stop the background port-forward:

```powershell
$GrafanaPid = Get-Content "$env:TEMP\grafana-port-forward.pid"
Stop-Process -Id $GrafanaPid
Remove-Item "$env:TEMP\grafana-port-forward.pid" -ErrorAction SilentlyContinue
```

The background port-forward is workstation-local. It does not survive a
Windows reboot/logoff or termination of the `kubectl` process.

## Validation notes

Temporary `kubectl run` smoke-test pods produced PodSecurity warnings because
the `restricted:latest` policy recommends explicit non-root and seccomp
settings. The disposable test pods still ran successfully and were deleted
afterward. These warnings were not Loki or Alloy failures.

A plain LogQL text filter such as:

```logql
|= "error"
```

matches any line containing that word and can therefore include informational
records. Use `detected_level` when the intention is to filter by detected log
severity.

## Security boundary

- Grafana is available privately through the Tailscale ingress.
- Local `127.0.0.1:3000` port-forward access remains available for administration.
- Loki and Tempo remain internal Kubernetes services.
- Tempo OTLP ingestion and query endpoints are not directly exposed to the public internet.
- Do not expose Prometheus, Alertmanager, Loki, Tempo, the Kubernetes API, or
  the Talos API directly to the public internet.
- Do not commit credentials, Grafana passwords, tokens, kubeconfig,
  `talosconfig`, private tailnet hostnames, or unredacted private screenshots.

## Remaining observability work

1. Define Loki retention suitable for the `20Gi` PVC.
2. Add a small Kubernetes/logging dashboard if useful.
3. Continue monitoring resource consumption on the single `pve01` host.
4. Monitor Tempo storage growth against its `20Gi` PVC and seven-day retention.

## Completion statement

The Phase 1 metrics and Kubernetes logging baseline was completed on
`2026-08-10`. Distributed tracing through Grafana Tempo was added and
verified on `2026-09-24`.

Prometheus, Grafana, Alertmanager, Loki, Grafana Alloy, and Tempo are
Flux-managed. All five observability PVCs are `Bound`. Kubernetes logs are
queryable through Loki, and OpenTelemetry traces from the Expense Tracker API
and Homepage are queryable through Tempo in Grafana Explore.

Grafana private Tailscale access, Alertmanager email notifications, and
local-path storage-capacity alerting are also operational.
