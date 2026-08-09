# Prometheus, Grafana and Alertmanager Baseline

## Status

**Completed on 2026-08-09:** Step 5A Prometheus, Step 5B Grafana, and Step 5C Alertmanager.

**Deferred to the next work session:** Step 5D Loki and Step 5E Grafana Alloy.

This document records the GitOps deployment, Talos Pod Security compatibility fix,
validation results, and the clean handoff point for the next observability work.

## Scope

The first observability layer is managed by Flux from:

```text
clusters/beelink-talos/monitoring/
├── helmrepository-grafana-community.yaml
├── helmrepository-grafana.yaml
├── helmrepository-prometheus-community.yaml
├── kube-prometheus-stack.yaml
├── kustomization.yaml
└── namespace.yaml
```

Only `kube-prometheus-stack` is deployed at this checkpoint. The Grafana and
Grafana Community Helm repositories are already present for the later Alloy and
Loki work.

## Implemented stack

| Component | State | Persistence / placement |
|---|---|---|
| Prometheus | Operational | 50 GiB `local-path` PVC |
| Grafana | Operational | 5 GiB `local-path` PVC |
| Alertmanager | Operational | 2 GiB `local-path` PVC |
| Prometheus Operator | Operational | Kubernetes Deployment |
| kube-state-metrics | Operational | Kubernetes Deployment |
| Node Exporter | Operational | DaemonSet, one Pod on each Talos node |
| Loki | Not deployed | Step 5D |
| Grafana Alloy | Not deployed | Step 5E |

The Flux HelmRelease uses `kube-prometheus-stack` chart `88.2.0`.

Prometheus is configured for:

```text
retention: 15d
retentionSize: 40GB
PVC: 50Gi
```

Grafana uses a 5 GiB PVC and Alertmanager uses a 2 GiB PVC.

## Initial Node Exporter failure

The first Helm installation created the main monitoring workloads, but the Node
Exporter DaemonSet remained:

```text
DESIRED   CURRENT   READY
3         0         0
```

`kubectl describe daemonset` showed Pod Security Admission rejecting every Node
Exporter Pod because the namespace was enforcing the Talos/Kubernetes
`baseline` Pod Security Standard.

The rejected Node Exporter specification requires host-level access including:

```text
hostNetwork=true
hostPID=true
hostPath mounts: /proc, /sys, /
host port: 9100
```

Those permissions are required for Node Exporter to collect node-level metrics.

## Pod Security fix

The `monitoring` namespace was changed to:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
  labels:
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
```

This is a namespace-scoped exception for trusted monitoring infrastructure. It
does not change the Talos cluster-wide Pod Security default.

After Flux reconciled the namespace labels, Node Exporter progressed to:

```text
DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE
3         3         3       3            3
```

The Pods were verified on:

```text
talos-cp-01
talos-worker-01
talos-worker-02
```

## Flux Helm remediation recovery

The Pod Security failures had already consumed the configured install remediation
attempts. The HelmRelease therefore remained failed even after all three Node
Exporter Pods were healthy.

The remediation counter was reset with:

```powershell
flux reconcile helmrelease kube-prometheus-stack `
  --namespace monitoring `
  --with-source `
  --reset
```

The resulting state was:

```text
READY: True
MESSAGE: Helm upgrade succeeded for release monitoring/kube-prometheus-stack.v2 with chart kube-prometheus-stack@88.2.0
```

## Persistent-volume validation

The monitoring PVCs were confirmed `Bound`:

| Workload | Capacity | StorageClass |
|---|---:|---|
| Prometheus | 50 GiB | `local-path` |
| Grafana | 5 GiB | `local-path` |
| Alertmanager | 2 GiB | `local-path` |

These volumes inherit the existing node-local storage limitation: they are
persistent across Pod recreation, but they are not replicated between physical
hosts or Talos workers.

## Prometheus validation

Prometheus was accessed only through a local port-forward:

```powershell
kubectl -n monitoring port-forward `
  svc/kube-prometheus-stack-prometheus `
  9090:9090
```

The Prometheus Target health page showed:

```text
serviceMonitor/monitoring/kube-prometheus-stack-prometheus-node-exporter/0
3 / 3 up
```

The following PromQL query returned three series, each with value `1`:

```promql
up{job=~".*node-exporter.*"}
```

The following queries also returned metrics for all three Talos nodes:

```promql
node_uname_info
```

```promql
node_memory_MemAvailable_bytes
```

This proves that Prometheus is scraping real host-level Node Exporter metrics
from the control plane and both workers.

## Grafana validation

Grafana was accessed through:

```powershell
kubectl -n monitoring port-forward `
  svc/kube-prometheus-stack-grafana `
  3000:80
```

The chart-generated administrator password was read from the Kubernetes Secret.
The credential itself must never be committed.

PowerShell retrieval pattern:

```powershell
$GrafanaUserB64 = kubectl get secret `
  kube-prometheus-stack-grafana `
  -n monitoring `
  -o jsonpath='{.data.admin-user}'

$GrafanaPasswordB64 = kubectl get secret `
  kube-prometheus-stack-grafana `
  -n monitoring `
  -o jsonpath='{.data.admin-password}'

$GrafanaUser = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String($GrafanaUserB64)
)

$GrafanaPassword = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String($GrafanaPasswordB64)
)
```

Successful login was verified, and the built-in dashboard:

```text
Kubernetes / Compute Resources / Cluster
```

showed live CPU, memory, namespace, Pod, and workload data.

## Alertmanager validation

Alertmanager was accessed only through a local port-forward:

```powershell
kubectl -n monitoring port-forward `
  svc/kube-prometheus-stack-alertmanager `
  9093:9093
```

The Alertmanager UI loaded successfully.

Cluster-side validation:

```powershell
kubectl get alertmanager -n monitoring
kubectl get prometheusrules -n monitoring
```

The Alertmanager custom resource reported one replica ready/reconciled/available,
and the chart-provided PrometheusRule objects were present.

External email/chat/mobile alert delivery is **not configured yet**. Receiver
credentials should not be added to plaintext Git. Configure external receivers
after the SOPS/secret-management workflow is ready.

## Current validation commands

```powershell
kubectl get pods -n monitoring -o wide
kubectl get daemonsets -n monitoring -o wide
kubectl get pvc -n monitoring -o wide

flux get helmreleases -n monitoring

kubectl get alertmanager -n monitoring
kubectl get prometheusrules -n monitoring
```

Expected core state:

```text
kube-prometheus-stack HelmRelease: Ready=True
Node Exporter DaemonSet: 3 desired / 3 current / 3 ready
Prometheus: Running
Grafana: Running
Alertmanager: Running
Prometheus PVC: Bound
Grafana PVC: Bound
Alertmanager PVC: Bound
```

## Security notes

- Do not commit the generated Grafana password.
- Do not expose Prometheus, Grafana, or Alertmanager directly to the public Internet.
- Keep the `monitoring` namespace privileged exception scoped to trusted infrastructure.
- Keep Talos/Kubernetes default Pod Security behaviour unchanged outside the namespace.
- Use Tailscale for future private Grafana access.
- Use SOPS or another approved secret-management workflow before Git-managing external alert receiver credentials.

## Handoff for the next work session

Continue in this order:

1. **Step 5D — Loki**
   - deploy a small single-cluster/single-binary Loki configuration;
   - use `local-path` persistence;
   - set conservative retention and memory limits;
   - verify the Loki API and PVC.

2. **Step 5E — Grafana Alloy**
   - collect Kubernetes Pod logs and Kubernetes events;
   - forward them to Loki;
   - verify Alloy has no repeated Loki connection errors.

3. Add Loki as a Grafana data source.

4. Verify LogQL queries for namespaces such as:

```logql
{namespace="flux-system"}
```

```logql
{namespace="monitoring"}
```

5. Expose Grafana privately through the existing Tailscale Kubernetes Operator.

Do not begin Step 5D by deleting or reinstalling the healthy
`kube-prometheus-stack` release.
