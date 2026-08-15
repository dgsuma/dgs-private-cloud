# Private Grafana Access Through Tailscale

## Status

**Completed: 2026-08-15**

Grafana is privately accessible through the Tailscale Kubernetes Operator without requiring `kubectl port-forward`, public router port forwarding, a Kubernetes NodePort, or a public LoadBalancer.

The Grafana Tailscale Ingress is stored in Git and reconciled by Flux.

## Architecture

```text
Authorised tailnet client
        |
        | Tailscale encrypted tailnet
        | HTTPS
        v
Tailscale MagicDNS Grafana endpoint
        |
        v
Tailscale Kubernetes Ingress proxy
        |
        v
kube-prometheus-stack-grafana
ClusterIP :80
        |
        v
Grafana Pod :3000
```

The exact tailnet hostname and Tailscale addresses are intentionally not stored in Git.

## Git-managed Kubernetes resource

The Ingress manifest is:

```text
clusters/beelink-talos/monitoring/grafana-tailscale-ingress.yaml
```

and it is referenced by:

```text
clusters/beelink-talos/monitoring/kustomization.yaml
```

The Ingress uses `ingressClassName: tailscale`, requests the machine name `grafana`, and forwards `/` to the internal `kube-prometheus-stack-grafana` Service on port 80.

## Service exposure

Grafana remains exposed inside Kubernetes as:

```text
Service: kube-prometheus-stack-grafana
Namespace: monitoring
Type: ClusterIP
Port: 80
```

Grafana was not changed to `NodePort` or `LoadBalancer`.

Tailscale Funnel was not enabled.

No internet-facing router port was opened for Grafana.

## Validation

The Tailscale operator assigned the Grafana Ingress a private `.ts.net` address.

The operator created a dedicated Grafana proxy StatefulSet and Pod in the `tailscale` namespace. The proxy Pod reached `1/1 Running`.

The proxy configuration was checked with:

```powershell
kubectl -n tailscale exec <grafana-proxy-pod> -- tailscale serve status
```

The important result was:

```text
(tailnet only)
```

The proxy target matched the internal Grafana ClusterIP Service on TCP port 80.

## HTTPS validation

From the administration workstation:

```powershell
curl.exe -I https://<grafana-tailnet-hostname>
```

returned:

```text
HTTP/1.1 302 Found
Location: /login
```

Grafana also loaded successfully in a browser without `kubectl port-forward`.

## Remote mobile validation

Remote access was tested from an authorised Android phone using mobile data rather than the home Wi-Fi network.

Test sequence:

1. Wi-Fi disabled.
2. Mobile data enabled.
3. Tailscale connected.
4. Private Grafana URL opened successfully.
5. Tailscale disconnected.
6. The private Grafana hostname stopped resolving.
7. Tailscale reconnected.
8. Grafana became accessible again.

This verified that the Grafana endpoint is available to authorised tailnet clients and is not operating as a public internet endpoint.

## Flux GitOps adoption

The working Ingress was added to Git and included in the monitoring Kustomization.

Before committing, the complete monitoring Kustomization was rendered and server-side dry-run validation reported the Grafana Ingress as unchanged.

After the commit was pushed, Flux reconciliation completed successfully and the `flux-system` Kustomization remained `READY=True`.

Flux ownership was confirmed by checking Kubernetes managed fields with:

```powershell
kubectl -n monitoring get ingress grafana-tailscale `
  -o yaml `
  --show-managed-fields=true |
  Select-String "manager:" -Context 0,1
```

The result included:

```text
manager: kustomize-controller
operation: Apply
```

The resource also appeared in:

```powershell
flux tree kustomization flux-system --namespace flux-system
```

## Final state

As of 2026-08-15:

- Grafana private HTTPS access through Tailscale is operational.
- Grafana does not require `kubectl port-forward` for normal remote administration.
- Administration-workstation tailnet access was verified.
- Android mobile-data tailnet access was verified.
- Tailscale-disconnected access failed as expected.
- Tailscale Serve reported `tailnet only`.
- Grafana remains a Kubernetes `ClusterIP` Service.
- No public router forwarding is configured for Grafana.
- Tailscale Funnel is not enabled.
- The Grafana Ingress is managed declaratively through Flux/GitOps.

**Private Grafana access through Tailscale: COMPLETE.**
