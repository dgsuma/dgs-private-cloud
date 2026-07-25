# Talos Phase 1 — Image Preparation and Control-Plane VM

**Date:** 2026-07-25  
**Proxmox node:** `pve01`  
**Repository:** `dgsuma/dgs-private-cloud`  
**Phase:** Home Lab IoT Blueprint — Phase 1

## Scope completed

This work session prepared the workstation tooling, removed the obsolete Ubuntu test VM, generated a custom Talos image, created the first Talos control-plane VM, and verified Talos maintenance-mode connectivity.

The Kubernetes cluster has not yet been bootstrapped.

## Workstation tooling

The following tools were installed or verified on the LG Gram Windows workstation:

| Tool | Version |
|---|---:|
| PowerShell | 7.6.3 |
| Git | 2.46.2 |
| GitHub CLI | 2.96.0 |
| kubectl | 1.36.3 |
| Flux CLI | 2.9.3 |
| talosctl | 1.13.6 |
| SOPS | 3.13.2 |
| age | 1.3.1 |
| age-keygen | 1.3.1 |

The GitHub CLI was authenticated as `dgsuma`.

The GitHub repository was changed back to private before introducing future GitOps secrets.

## kubectl command resolution

Docker Desktop supplied an older `kubectl` version earlier in the Windows PATH.

A PowerShell profile function was added so PowerShell dynamically selects the current WinGet-managed kubectl executable.

Verified result:

```text
Client Version: v1.36.3
Kustomize Version: v5.8.1
CommandType: Function```
