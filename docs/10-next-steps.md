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

After storage validation:

1. deploy Prometheus, Grafana, and Alertmanager;
2. deploy Loki in an appropriately small single-cluster mode;
3. deploy Grafana Alloy for Kubernetes log collection;
4. define retention and resource limits suitable for the Beelink host;
5. expose Grafana only through Tailscale;
6. verify dashboards, alert delivery, and log queries.

## Priority 3 — Homepage

1. Deploy Homepage through Flux.
2. Keep Homepage private behind Tailscale.
3. Add links for Proxmox, Grafana, Flux status, and future services.
4. Do not place plaintext credentials in Homepage configuration.
5. Add Kubernetes service discovery only with minimum required RBAC.

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
- [ ] Prometheus, Grafana, and Alertmanager are healthy.
- [ ] Loki receives logs through Alloy.
- [ ] Grafana is reachable privately through Tailscale.
- [ ] Homepage is deployed privately.
- [ ] At least one Secret is managed with SOPS.
- [ ] One isolated VM restore completes successfully.
