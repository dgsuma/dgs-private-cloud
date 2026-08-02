# Flux and Tailscale Kubernetes Operator

## Purpose

This document records the completed GitOps and private-access baseline for the Beelink-hosted Talos Kubernetes cluster.

Verified date: `2026-08-02`.

## Implemented components

| Component | Implemented state |
|---|---|
| Flux CLI/distribution | `v2.9.3` |
| Flux namespace | `flux-system` |
| Git repository | `dgsuma/dgs-private-cloud` |
| Branch | `main` |
| Reconciliation path | `clusters/beelink-talos` |
| Ongoing repository authentication | SSH deploy key |
| Tailscale namespace | `tailscale` |
| Tailscale Helm chart | `tailscale-operator` `1.98.9` |
| Tailscale operator hostname | `beelink-talos-operator` |
| Tailscale IngressClass | `tailscale` |
| Kubernetes API proxy | Disabled |
| SOPS | Not yet configured |

## Flux bootstrap result

Flux bootstrap created:

```text
clusters/beelink-talos/
├── flux-system/
│   ├── gotk-components.yaml
│   ├── gotk-sync.yaml
│   └── kustomization.yaml
├── tailscale/
│   ├── helmrelease.yaml
│   ├── helmrepository.yaml
│   ├── kustomization.yaml
│   └── namespace.yaml
└── kustomization.yaml
```

The bootstrap process:

1. used a temporary fine-grained GitHub PAT;
2. installed Flux controllers in namespace `flux-system`;
3. committed the generated synchronization manifests;
4. configured an SSH deploy key for ongoing access;
5. reconciled the `main` branch and `clusters/beelink-talos` path;
6. revoked the temporary PAT after successful validation.

## Flux validation

```powershell
flux check
flux get sources git -A
flux get kustomizations -A
kubectl get pods -n flux-system -o wide
```

Verified result:

- all Flux checks passed;
- GitRepository `flux-system` reported `Ready=True`;
- Kustomization `flux-system` reported `Ready=True`;
- `helm-controller`, `kustomize-controller`, `notification-controller`, and `source-controller` were running.

## Tailscale access-control tags

The Tailscale policy contains:

```json
"tagOwners": {
  "tag:k8s-operator": [],
  "tag:k8s": ["tag:k8s-operator"]
}
```

Meaning:

- the operator registers with `tag:k8s-operator`;
- the operator is allowed to create proxy devices using `tag:k8s`.

## Tailscale OAuth scopes

The OAuth client description is:

```text
beelink-talos-operator
```

Required write scopes:

- Services;
- Devices/Core;
- Auth Keys.

Each scope is restricted to `tag:k8s-operator`.

The OAuth client ID and secret are not stored in this repository.

## Kubernetes OAuth Secret

The operator uses:

```text
Namespace: tailscale
Secret:    operator-oauth
Keys:      client_id, client_secret
```

The Secret was created directly in Kubernetes and is intentionally absent from Git until SOPS is implemented.

Do not print, decode, screenshot, or commit its values.

## GitOps deployment

The Tailscale chart is declared through:

- `clusters/beelink-talos/tailscale/helmrepository.yaml`;
- `clusters/beelink-talos/tailscale/helmrelease.yaml`;
- `clusters/beelink-talos/tailscale/namespace.yaml`;
- `clusters/beelink-talos/tailscale/kustomization.yaml`.

The HelmRelease:

- pins chart version `1.98.9`;
- sets hostname `beelink-talos-operator`;
- applies `tag:k8s-operator` to the operator;
- applies `tag:k8s` to future proxy devices;
- enables the `tailscale` IngressClass;
- disables Kubernetes API proxy mode.

## Tailscale validation

```powershell
flux get sources helm -A
flux get helmreleases -A

kubectl wait `
  --namespace tailscale `
  --for=condition=Available `
  deployment/operator `
  --timeout=10m

kubectl get deployment -n tailscale
kubectl get pods -n tailscale
kubectl get ingressclass tailscale
kubectl get secret operator-oauth -n tailscale
kubectl logs -n tailscale deployment/operator --tail=100
```

Verified result:

- HelmRepository `tailscale` reported `Ready=True`;
- HelmRelease `tailscale-operator` reported `Ready=True`;
- Deployment `operator` was `1/1 Available`;
- operator pod was `1/1 Running` with zero restarts;
- IngressClass `tailscale` existed;
- required Tailscale CRDs existed;
- `beelink-talos-operator` appeared connected in the Tailscale admin console.

## Known PowerShell behaviour

Use separate commands rather than an unquoted comma expression:

```powershell
kubectl get deployment -n tailscale
kubectl get pods -n tailscale
```

On this workstation, native-command pipelines such as generated YAML piped into `kubectl apply -f -` have sometimes waited indefinitely for stdin. Prefer direct resource creation or a temporary manifest file.

## Recovery considerations

A rebuilt cluster needs:

1. repository access for Flux;
2. Flux bootstrap or restoration of the Flux manifests;
3. recreation of `tailscale/operator-oauth` from the password manager;
4. reconciliation of the Tailscale HelmRelease;
5. validation that the operator machine reconnects.

After SOPS is configured, replace the manually created OAuth Secret with an encrypted Git-managed Secret.
