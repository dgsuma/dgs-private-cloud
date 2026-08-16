# Next Steps


## Jenkins Phase 2 — deferred

Jenkins Controller Phase 1 is complete. The next Jenkins exercise will use a separate build agent rather than placing normal build workloads on the controller.

1. Create VM `221` `jenkins-agent01`.
2. Install Java, Git, Docker/BuildKit, and CI/security tooling.
3. Connect the agent to Jenkins.
4. Run a Pipeline on the agent.
5. Set the built-in controller executor count to `0`.
6. Create a disposable GitHub application repository with a `Jenkinsfile`.
7. Build and scan a container image.
8. Push the image to GHCR.
9. Update the GitOps source.
10. Let Flux reconcile the Kubernetes deployment.

Target responsibility split:

```text
Jenkins -> CI
Flux    -> GitOps CD
```
## Priority 1 — Persistent storage

**Prerequisite completed on 2026-08-09.**

- [x] Selected Rancher Local Path Provisioner for the current single-host phase.
- [x] Added a dedicated 300 GiB data disk to each Talos worker.
- [x] Provisioned XFS Talos user volumes at `/var/mnt/local-path-provisioner`.
- [x] Created and verified the default `local-path` StorageClass.
- [x] Confirmed `ReclaimPolicy=Delete`.
- [x] Confirmed `VolumeBindingMode=WaitForFirstConsumer`.
- [x] Dynamically provisioned a 1 GiB PVC/PV.
- [x] Verified successful write/read through the PVC.
- [x] Deleted and recreated the Pod while keeping the PVC bound.
- [x] Verified the original data survived Pod recreation.
- [x] Deleted the test namespace and confirmed PVC, PV, and backing-directory cleanup.
- [x] Documented the node-local/non-replicated storage limitation.
- [ ] Add Local Path Provisioner to the active Flux reconciliation path.

## Priority 2 — Observability

**Metrics, logging, Alertmanager email delivery, private Grafana, and the first private Homepage application are operational through 2026-08-16.**
- [x] Create the Flux-managed `monitoring` namespace and Helm repositories.
- [x] Deploy `kube-prometheus-stack` `88.2.0`.
- [x] Persist Prometheus on a 50 GiB `local-path` PVC.
- [x] Persist Grafana on a 5 GiB `local-path` PVC.
- [x] Persist Alertmanager on a 2 GiB `local-path` PVC.
- [x] Resolve Node Exporter Pod Security Admission requirements with a targeted `monitoring` namespace policy.
- [x] Confirm the Node Exporter DaemonSet is `3/3 Ready`.
- [x] Confirm the Flux HelmRelease is `Ready=True`.
- [x] Confirm all three Node Exporter scrape targets are `UP`.
- [x] Confirm real host metrics from all three Talos nodes.
- [x] Log in to Grafana and verify the Kubernetes compute-resources dashboard.
- [x] Deploy Loki `18.7.6`.
- [x] Deploy Grafana Alloy `1.11.1`.
- [x] Verify Kubernetes logs in Grafana through Loki/LogQL.
- [x] Verify error and warning log filtering.
- [x] Configure `AlertmanagerConfig/email-notifications`.
- [x] Keep the Gmail App Password outside Git in `monitoring/alertmanager-smtp`.
- [x] Route `Watchdog` to a null receiver.
- [x] Verify Gmail FIRING notification delivery.
- [x] Verify Gmail RESOLVED notification delivery.
- [x] Configure secure read-only Android/Termux Kubernetes access through the Tailscale API proxy.
- [x] Verify mobile access to Nodes, Pods, and Deployments while denying Node deletion and Secret access.
- [x] Expose Grafana only through authenticated Tailscale access.
- [x] Deploy Homepage through Flux and keep it private behind Tailscale.
- [ ] Migrate manually managed secrets to SOPS/age after encrypted secret management is configured.
## Priority 3 — Homepage

**Baseline completed on 2026-08-16.**

- [x] Deploy Homepage `v1.13.2` through Flux.
- [x] Keep the Kubernetes Service internal as `ClusterIP` on port `3000`.
- [x] Expose Homepage only through a private Tailscale Ingress.
- [x] Verify access from the LG Gram without local port-forwarding.
- [x] Verify access from the Moto G84 over mobile data through Tailscale.
- [x] Resolve the initial `CrashLoopBackOff` caused by the read-only `/app/config/proxmox.yaml` path.
- [x] Provide a writable `/app/config/logs` `emptyDir` while retaining the non-root security context.
- [x] Configure Pod-IP plus external-host validation for Kubernetes probes and private Tailscale access.
- [x] Keep exact tailnet hostnames and Homepage runtime values out of Git.
- [x] Keep `homepage-runtime` as an out-of-band Secret until SOPS/age is ready.
- [x] Keep Kubernetes permissions read-only and limited to dashboard discovery/metrics needs.
- [ ] Add Proxmox integration only after a least-privilege API credential design is documented; never commit the credential.
- [ ] Add Flux/Kubernetes status and future service links/widgets incrementally.
- [ ] Enable resource widgets only after confirming the required Kubernetes metrics API and RBAC behaviour.

## Priority 4 — SOPS and secret lifecycle

1. Generate an age identity on a secure administration device.
2. Back up the age private key outside Git.
3. Add `.sops.yaml`.
4. Configure Flux decryption.
5. Encrypt a test Secret and validate reconciliation.
6. Migrate `tailscale/operator-oauth` to an encrypted manifest.
7. Remove the manually created Secret only after the encrypted replacement is proven.

## Priority 5 — Prove recovery

1. Connect, mount, and enable `usb-backup-2tb`.
2. Choose one worker backup for a controlled restore test.
3. Restore to a different VM ID with networking initially disconnected or isolated.
4. Confirm VM configuration and bootability without affecting the active cluster.
5. Remove the test VM after documenting results.
6. Rehearse Talos disaster recovery only in an isolated environment.

## Priority 6 — Protect recovery credentials

Create an encrypted second copy of:

- `talosconfig`;
- kubeconfig;
- generated Talos machine configurations;
- etcd snapshots and SHA-256 files;
- Tailscale OAuth recovery details;
- the documentation required to rebuild the VMs and GitOps controllers.

Store the copy on a second physical device or encrypted off-site location. Never commit it.

## Priority 7 — UPS telemetry and graceful shutdown

- Add Eaton UPS telemetry.
- Alert on mains failure, low battery, communication loss, and runtime threshold.
- Define the guest shutdown order.
- Shut down `pve01` only after Kubernetes workloads and Talos VMs are handled safely.
- Test the procedure without risking data corruption.

## Exit criteria for the next milestone

- [x] Dynamic PVC provisioning works.
- [x] Data survives a pod deletion/recreation cycle.
- [x] Prometheus, Grafana, and Alertmanager are healthy.
- [x] Loki receives logs through Alloy.
- [x] Grafana is reachable privately through Tailscale.
- [x] Homepage is deployed privately.
- [ ] At least one Secret is managed with SOPS.
- [ ] One isolated VM restore completes successfully.

## 2026-08-16 reprioritisation

Completed:

- Alertmanager FIRING and RESOLVED notification verification.
- Private Grafana exposure through the Tailscale Kubernetes Operator.
- Remote Grafana validation without `kubectl port-forward`.
- Homepage `v1.13.2` deployment through Flux.
- Homepage private Tailscale ingress and mobile-data validation.
- Homepage `CrashLoopBackOff` root-cause analysis and recovery.
- Stable Homepage validation with zero restarts and 20 consecutive HTTP `200` responses.
- Real `KubePodCrashLooping` Alertmanager email observed during the Homepage incident.

Immediate next priorities:

1. Bring the Local Path Provisioner manifest fully under Flux reconciliation.
2. Configure SOPS with age and validate Flux decryption.
3. Migrate manually created Secrets, including `tailscale/operator-oauth`, `monitoring/alertmanager-smtp`, and `homepage/homepage-runtime`, to encrypted Git-managed resources.
4. Perform an isolated VM restore test.
5. Add Eaton UPS telemetry and graceful-shutdown monitoring.
6. Enrich Homepage with least-privilege service links/widgets without adding plaintext credentials.
