# Observability Logging and Alertmanager Email Notifications

## Completion checkpoint — 2026-08-13

This document records the observability work completed after the original
Prometheus/Grafana/Alertmanager baseline.

Status at this checkpoint:

- Loki logging backend: **operational**.
- Grafana Alloy log collector: **operational**.
- Grafana LogQL validation: **passed**.
- Alertmanager external email receiver: **operational**.
- Alert firing email delivery: **passed**.
- Alert resolved email delivery: **passed**.
- Grafana private access through Tailscale: **next task**.
- Homepage deployment/private access: **pending after Grafana**.

## Logging stack

The `monitoring` namespace contains the Flux-managed logging stack alongside
`kube-prometheus-stack`.

Verified Helm releases:

| Component | Version | Verified state |
|---|---:|---|
| Loki | `18.7.6` | Flux `Ready=True` |
| Grafana Alloy | `1.11.1` | Flux `Ready=True` |
| kube-prometheus-stack | `88.2.0` | Flux `Ready=True` |

Grafana was successfully used to query Kubernetes log data through Loki.
Validation included queries that returned detected error-level messages and
combined error/warning results.

The logging services remain private. No public router port-forwarding was
introduced.

## Alertmanager email receiver

Alertmanager remains part of `kube-prometheus-stack` and runs as a private
ClusterIP service.

Verified Alertmanager state:

- Alertmanager version observed: `v0.33.1`.
- Replica count: `1`.
- Resource reconciled and available.
- AlertmanagerConfig API served by the cluster:
  `monitoring.coreos.com/v1alpha1`.
- Flux HelmRelease `monitoring/kube-prometheus-stack`: `Ready=True`.

### Git-managed receiver configuration

The receiver configuration is stored in:

```text
clusters/beelink-talos/monitoring/alertmanagerconfig-email.yaml
```

The monitoring Kustomization includes this resource.

The Alertmanager custom resource uses:

```yaml
alertmanagerConfigMatcherStrategy:
  type: OnNamespaceExceptForAlertmanagerNamespace
```

This allows the `AlertmanagerConfig` placed in the Alertmanager namespace to
process cluster alerts rather than restricting the route to alerts originating
only from the `monitoring` namespace.

The route configuration uses:

- default receiver: Gmail email;
- `Watchdog` child route: null receiver;
- `groupWait`: `30s`;
- `groupInterval`: `5m`;
- `repeatInterval`: `4h`;
- `sendResolved`: `true`.

Routing `Watchdog` to a null receiver prevents the permanently firing watchdog
alert from generating repetitive email.

## SMTP secret handling

The Gmail App Password is **not stored in Git**.

A manually created Kubernetes Secret is used:

```text
namespace: monitoring
name: alertmanager-smtp
key: gmail-app-password
```

The Git-managed `AlertmanagerConfig` contains only a SecretKeySelector
reference to this Secret.

At this checkpoint SOPS/age is not configured, therefore
`monitoring/alertmanager-smtp` remains an out-of-band recovery prerequisite.
If the cluster is rebuilt before encrypted secret management is introduced,
this Secret must be recreated manually.

Never commit:

- the Gmail App Password;
- a plaintext Secret manifest containing it;
- terminal output that decodes the Secret;
- screenshots showing credentials.

## Flux reconciliation verification

The receiver change was committed and pushed on `2026-08-13`.

Observed Git revision after reconciliation:

```text
9db4906
```

Flux verification showed:

- `flux-system/flux-system` GitRepository: `Ready=True`;
- `flux-system/flux-system` Kustomization: `Ready=True`;
- `monitoring/kube-prometheus-stack`: `Ready=True`;
- `monitoring/loki`: `Ready=True`;
- `monitoring/alloy`: `Ready=True`;
- `AlertmanagerConfig/email-notifications`: present.

The live Alertmanager resource returned:

```text
OnNamespaceExceptForAlertmanagerNamespace
```

for `.spec.alertmanagerConfigMatcherStrategy.type`.

## End-to-end email test

A harmless synthetic alert was posted through the Alertmanager v2 API:

```text
alertname = DGSAlertmanagerEmailTest
namespace = monitoring
severity  = warning
```

The test proved both notification states.

### Firing result

A Gmail notification with the firing state was received successfully.

The message contained:

- alert name `DGSAlertmanagerEmailTest`;
- namespace `monitoring`;
- severity `warning`;
- the expected test summary and description.

### Resolved result

The same alert was explicitly updated with an `endsAt` value.

A second Gmail notification with the resolved state was received successfully,
proving that `sendResolved: true` works.

## Temporary validation access cleanup

Alertmanager was accessed locally only through a temporary `kubectl
port-forward` to TCP `9093`.

After testing, the background port-forward process was stopped.

Verification:

```text
Test-NetConnection 127.0.0.1 -Port 9093
Result: False
```

Therefore TCP `9093` was no longer exposed on the administration workstation
after testing.

## Security state

The following remain true:

- Alertmanager is not exposed publicly.
- Grafana is not exposed publicly.
- Tailscale Funnel is not required for observability.
- SMTP credentials are not committed.
- The manually created SMTP Secret is a temporary secret-lifecycle exception
  until SOPS/age is implemented.
- Evidence screenshots containing personal addresses or credential-related
  information should remain outside the public Git history.

## Handoff

Completed:

1. Prometheus/Grafana/Alertmanager metrics baseline.
2. Loki deployment.
3. Grafana Alloy deployment.
4. Loki/Grafana log-query validation.
5. Alertmanager Gmail receiver configuration.
6. Firing notification validation.
7. Resolved notification validation.
8. Temporary Alertmanager port-forward cleanup.

Next work session:

1. expose Grafana privately through the Tailscale Kubernetes Operator;
2. validate Grafana from an authorised tailnet client without a local
   port-forward;
3. deploy Homepage through Flux;
4. keep Homepage private through Tailscale;
5. later configure SOPS/age and migrate manually managed Secrets.
