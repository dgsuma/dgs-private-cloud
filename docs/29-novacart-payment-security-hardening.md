# NovaCart Payment Security Hardening

**Status:** Completed and deployed
**Verified:** 2026-10-10

## Scope

This document records the remediation of the remaining npm security advisories in the NovaCart payment service.

The work covered dependency analysis, controlled package upgrades, unit testing, Docker validation, Jenkins CI/CD, GitOps deployment through Flux, and production runtime validation using Grafana Tempo.

The changes were limited to the payment dependency manifest and lockfile. No application source code or Kubernetes configuration changes were required for this remediation.

## Security remediation summary

| Metric | Before | After |
|---|---|---|
| Moderate npm vulnerabilities | 14 | 0 |
| High npm vulnerabilities | 0 | 0 |
| Critical npm vulnerabilities | 0 | 0 |
| Payment unit tests passing | 6/6 | 6/6 |

The remaining 14 moderate findings originated from two underlying advisories:

- `GHSA-8988-4f7v-96qf`: OpenTelemetry Core unbounded memory allocation during W3C Baggage propagation.
- `GHSA-w5hq-g745-h8pq`: uuid missing buffer bounds check for selected UUID operations.

The older Pino OpenTelemetry transport introduced vulnerable transitive dependencies through `otlp-logger`.

## Dependency upgrades

| Package | Previous | Updated |
|---|---|---|
| uuid | 13.0.0 | 13.0.2 |
| pino | 9.10.0 | 10.4.0 |
| pino-opentelemetry-transport | 1.1.0 | 4.0.2 |
| @opentelemetry/api | 1.9.0 | 1.9.1 |

The transport upgrade removed the vulnerable `otlp-logger` dependency chain.

The main OpenTelemetry instrumentation dependencies remained unchanged.

Modified files:

- `src/payment/package.json`
- `src/payment/package-lock.json`

No use of `npm audit fix --force` was required.

## Source control

| Item | Reference |
|---|---|
| Source repository | https://github.com/dgsuma/NovaCart |
| Security branch | `security/payment-moderate-advisories` |
| Security commit | `a9c44378` |
| Pull request | https://github.com/dgsuma/NovaCart/pull/12 |
| Main merge commit | `b48673fe9c7815cb75b49f73fa66c3c7e8a18c12` |
| GitOps repository | https://github.com/dgsuma/dgs-private-cloud |
| GitOps deployment commit | `5207077` |

PR #12 was merged after local validation and a successful Jenkins feature-branch build.

## Local validation

The following checks passed:

- Six payment unit tests.
- `npm audit` reporting zero vulnerabilities.
- `git diff --check`.
- Docker image build using `npm ci --omit=dev`.
- Distroless Node.js 22 runtime validation.
- OpenTelemetry console log emission using the upgraded Pino transport.

The production-style distroless image ran as a non-root user and successfully emitted structured OpenTelemetry log records.

## Jenkins CI/CD validation

Both the feature-branch and post-merge `main` pipelines completed successfully.

Validated stages included:

- Payment syntax checking.
- Payment unit testing.
- Frontend Docker image build.
- Payment Docker image build.
- Trivy CRITICAL vulnerability scanning.

The feature-branch pipeline skipped GHCR publishing and GitOps updates.

After merging PR #12, the `main` pipeline published the updated images to GHCR and updated the GitOps repository.

## GitOps and Kubernetes deployment

**Kubernetes namespace:** `novacart`

**Deployed payment image:**

`ghcr.io/dgsuma/novacart-payment:b48673fe9c7815cb75b49f73fa66c3c7e8a18c12`

Deployment evidence:

| Check | Verified result |
|---|---|
| GitOps commit | `5207077` |
| Payment deployment | Successfully rolled out |
| Pod readiness | 1/1 |
| Pod restarts | 0 |
| Worker node | `talos-worker-02` |
| Deployed image | Matches the NovaCart merge commit |

Deployment was handled through Jenkins, GHCR, GitOps and Flux. No manual production Kubernetes manifest modifications were performed.

## Functional validation

A post-deployment checkout generated the following payment log events:

- `Charge request received.`
- `Transaction complete.`

Both events contained the same trace ID:

`0d32dab04588b793b4188563fb8b6022`

No matching `ECONNREFUSED`, `UNAVAILABLE`, `TypeError`, `MODULE_NOT_FOUND`, or `OTLPExporterError` messages were returned by the targeted log inspection.

## Grafana Tempo validation

**Trace ID:** `0d32dab04588b793b4188563fb8b6022`

Observed trace results:

| Metric | Observation |
|---|---|
| Checkout HTTP response | 200 OK |
| End-to-end trace duration | 769.02 ms |
| Services represented | 12 |
| Spans displayed | 53 |
| PaymentService/Charge | 10.75 ms |
| Payment service charge span | 5.19 ms |
| Internal charge operation | 4.18 ms |
| flagd ResolveFloat gRPC operation | 2.22 ms |

The trace confirmed successful propagation across the frontend, checkout, payment and flagd services.

These timings represent one observed transaction rather than benchmark averages.

## Remaining observations

### Cloud metadata warnings

Payment startup logs included:

`MetadataLookupWarning: received unexpected error = All promises were rejected code = UNKNOWN`

The service continued to operate successfully.

Cloud resource detection in the local Talos/Proxmox environment is a possible explanation, but the exact source was not established.

### Trivy scanning scope

Jenkins currently fails builds on CRITICAL Trivy findings only.

The npm dependency audit separately reported zero vulnerabilities. Extending Trivy severity enforcement can be evaluated as a separate security improvement.

### Deprecated dependencies

Docker dependency installation reported deprecation warnings for `glob@10.5.0` and `node-domexception@1.0.0`.

These warnings did not fail the build. Any further dependency cleanup should be scoped and tested separately.

### Observability coverage

Console logging and distributed trace delivery to Tempo were verified.

End-to-end gRPC delivery of OpenTelemetry log records to a log backend was not independently established by these checks.

## Final outcome

The NovaCart payment service's 14 previously reported moderate npm vulnerabilities were resolved through controlled dependency upgrades.

Local validation, Jenkins CI/CD, container builds, Kubernetes deployment, payment transaction logging and Grafana Tempo tracing succeeded.

At verification time, npm reported zero vulnerabilities in the payment dependency tree.

This result does not imply that the entire NovaCart application or underlying infrastructure is free of vulnerabilities.
