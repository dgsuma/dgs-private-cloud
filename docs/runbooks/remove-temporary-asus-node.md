# Remove the Temporary ASUS Node

> **Historical status:** the ASUS experiment ended before any Proxmox cluster was created. The node-removal section below was therefore not executed.

## Actual completed path

1. Confirmed that `asus-pve` had no VMs or containers.
2. Confirmed that no Proxmox cluster had been created.
3. Shut down the ASUS Proxmox installation.
4. Stopped using the laptop as a Proxmox node.
5. Installed Zorin OS on the ADATA SSD.
6. Left the laptop outside the private-cloud topology.

Because `asus-pve` was never a cluster member, these commands were **not required**:

```bash
pvecm expected 1
pvecm delnode asus-pve
```

## Generic warning for future temporary nodes

Do not reinstall or erase a Proxmox node while it is still registered in a cluster.

Before removing any future cluster member:

- verify VMs and containers,
- verify replication and HA resources,
- migrate or back up workloads,
- shut down the departing node,
- inspect quorum,
- remove the node from a remaining healthy member,
- verify the final cluster state.

Do not use `pvecm expected 1` as a routine setting. It is an exceptional recovery measure and must only be considered after physically confirming the missing node is off and understanding the quorum consequences.

## Recovery note

If cluster state becomes unclear, do not run additional destructive commands. Preserve all systems, collect `pvecm status`, `pvecm nodes`, and relevant Corosync logs, and diagnose before proceeding.