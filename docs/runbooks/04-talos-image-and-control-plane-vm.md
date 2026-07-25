
## 3. Create the architecture decision record

Run:

```powershell
@'
# ADR 0004: Talos Kubernetes Phase 1 Architecture

- **Status:** Accepted
- **Date:** 2026-07-25

## Context

Phase 1 of the Home Lab IoT Blueprint requires a Kubernetes platform on the existing Beelink GTi12 Proxmox node `pve01`.

The Beelink currently has:

```text
CPU: Intel Core i9-12900H, 14 cores / 20 threads
RAM: 64 GB
Primary VM storage: Samsung 990 PRO 2 TB
Proxmox storage ID: vmdata
Network bridge: vmbr0
LAN: 192.168.1.0/24