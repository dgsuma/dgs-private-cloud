# Secure Mobile Kubernetes Access Through Tailscale



> Status: COMPLETE

> Completed: 2026-08-15

> Platform: Talos Kubernetes + Tailscale Kubernetes Operator

> Client: Android + Termux

> Access model: authenticated read-only Kubernetes access



## Objective



Provide secure remote read-only access to the Talos Kubernetes cluster from an Android phone over mobile data without exposing the Kubernetes API directly to the public Internet.



## Architecture



```text

Android Moto G84

&#x20;   |

&#x20;   | Mobile data

&#x20;   v

Tailscale Android client

&#x20;   |

&#x20;   | Encrypted tailnet

&#x20;   v

Tailscale Kubernetes Operator

&#x20;   |

&#x20;   | Kubernetes API proxy

&#x20;   v

Talos Kubernetes API

&#x20;   |

&#x20;   | Kubernetes RBAC

&#x20;   v

Read-only cluster access

```



## Tailscale API Server Proxy



The existing Tailscale Kubernetes Operator was configured through Flux to enable the Kubernetes API server proxy.



The HelmRelease configuration uses:



```yaml

apiServerProxyConfig:

&#x20; allowImpersonation: "true"

&#x20; mode: "true"

```



The configuration is managed through GitOps.



## Android and Termux



Termux was installed on the Moto G84.



The phone architecture was confirmed as ARM64/AArch64.



kubectl was installed from the Termux repository:



```bash

pkg install kubectl

```



The kubeconfig directory was created with:



```bash

mkdir -p \~/.kube

chmod 700 \~/.kube

```



The mobile kubeconfig is stored at:



```text

\~/.kube/config

```



The mobile kubeconfig is not committed to Git.



## Tailscale Authentication



The Tailscale Kubernetes API endpoint was successfully reached from the phone over mobile data.



Kubernetes correctly identified the authenticated Tailscale user.



A Tailscale-compatible kubeconfig structure was generated using:



```powershell

tailscale configure kubeconfig <tailscale-kubernetes-endpoint>

```



No Talos administrator kubeconfig was copied to the phone.



## Read-Only Kubernetes RBAC



The mobile Tailscale identity uses Kubernetes' built-in `view` role for normal read-only workload access.



The Git-managed RBAC configuration is:



```text

clusters/beelink-talos/tailscale/mobile-readonly-rbac.yaml

```



The initial permissions allowed:



```text

list pods:        yes

list deployments: yes

delete pods:      no

get secrets:      no

```



## Node Read Access



`kubectl get nodes` initially returned `Forbidden` because the built-in `view` role did not allow access to cluster-scoped Node resources.



A dedicated ClusterRole was therefore added:



```yaml

apiVersion: rbac.authorization.k8s.io/v1

kind: ClusterRole

metadata:

&#x20; name: tailscale-mobile-node-reader

rules:

&#x20; - apiGroups: \[""]

&#x20;   resources:

&#x20;     - nodes

&#x20;   verbs:

&#x20;     - get

&#x20;     - list

&#x20;     - watch

```



A corresponding ClusterRoleBinding grants this role to the authenticated mobile Tailscale identity.



Final authorization tests confirmed:



```text

list nodes:     yes

get nodes:      yes

delete nodes:   no

get secrets -A: no

```



The mobile account deliberately does not have `cluster-admin`.



## GitOps Deployment



All permanent RBAC changes are managed through Git and Flux.



Flux reconciliation completed successfully:



```powershell

flux reconcile source git flux-system -n flux-system



flux reconcile kustomization flux-system `

&#x20; -n flux-system `

&#x20; --with-source

```



## Administrative Kubeconfig



During troubleshooting, Windows temporarily used the restricted Tailscale kubeconfig.



After removing that temporary configuration, kubectl fell back to an unrelated context:



```text

vcluster-docker\_my-first-cluster

```



The correct Talos administrative kubeconfig was located at:



```text

talos/generated/kubeconfig

```



The correct administrative context is:



```text

admin@dgs-homelab

```



Before administrative Kubernetes or Flux operations, always verify:



```powershell

kubectl config current-context

kubectl config get-contexts

```



## Final Mobile Verification



The following commands successfully ran from the Moto G84 through Termux:



```bash

kubectl get nodes

kubectl get pods -A

kubectl get pods -A -o wide

kubectl get deployments -A

```



All three Talos nodes were visible and Ready:



```text

talos-cp-01       Ready

talos-worker-01   Ready

talos-worker-02   Ready

```



Cluster workloads including Flux, Kubernetes system components, Local Path Provisioner, Prometheus, Grafana, Alertmanager, Loki, Alloy and the Tailscale Operator were visible remotely.



## Security



The mobile identity:



- can inspect workloads

- can inspect Nodes

- cannot delete Nodes

- cannot read Kubernetes Secrets

- does not have cluster-admin access

- does not contain Talos administrator credentials

- accesses Kubernetes privately through Tailscale



Never commit:



- mobile kubeconfig

- generated Talos kubeconfig

- talosconfig

- Tailscale authentication credentials

- OAuth secrets

- Kubernetes Secret values

- private keys



## Routine Mobile Commands



```bash

kubectl get nodes

kubectl get pods -A

kubectl get pods -A -o wide

kubectl get deployments -A

kubectl get services -A

kubectl get pvc -A

```



## Result



Secure remote read-only Kubernetes access from Android Termux through Tailscale is operational.



**Secure Android/Termux Kubernetes access through Tailscale: COMPLETE.**
