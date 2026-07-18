# Remove the Temporary ASUS Node

## Purpose

Use this runbook when the ASUS Proxmox experiment is complete and the laptop is ready to return to Linux Mint.

## Warning

Do **not** reinstall Linux Mint or erase the ASUS Proxmox disk while `asus-pve` is still registered in the cluster.

The WDC 1TB HDD is not part of the temporary Proxmox design and must not be erased accidentally.

## 1. Verify the cluster and workloads

On `pve01`:

```bash
pvecm status
pvecm nodes
```

In the Proxmox GUI, confirm that `asus-pve` has no required:

- VMs,
- containers,
- replication jobs,
- HA resources,
- node-specific storage content,
- backup jobs that depend on the node.

Migrate, back up, or delete all ASUS workloads before continuing.

## 2. Shut down the ASUS node

On `asus-pve`:

```bash
shutdown -h now
```

Confirm the laptop is completely powered off. Keep it off until its Proxmox installation is replaced.

## 3. Remove cluster membership

On `pve01`:

```bash
pvecm delnode asus-pve
```

If this succeeds, continue to verification.

### Quorum-loss recovery only

In a two-node cluster, `pve01` may lose quorum after `asus-pve` is powered off. Only after physically confirming the ASUS is off, temporarily set the expected votes to one and retry removal:

```bash
pvecm expected 1
pvecm delnode asus-pve
```

Do not use `pvecm expected 1` as a routine cluster setting.

## 4. Verify the remaining node

On `pve01`:

```bash
pvecm status
pvecm nodes
```

Success criteria:

```text
Nodes:       1
Total votes: 1
Quorate:     Yes
```

Confirm `asus-pve` no longer appears in the web interface after a refresh.

## 5. Reinstall Linux Mint

Boot the ASUS from the verified Linux Mint installation USB.

Select the **ADATA 240GB SSD** as the installation target. Before confirming any erase operation, identify both drives by model and capacity.

Expected storage intent:

```text
ADATA 240GB SSD  -> erase and install Linux Mint
WDC 1TB HDD      -> preserve unless separately approved
```

After Linux Mint is operational, remove or change the Archer reservation for `192.168.1.203` if the laptop will return to DHCP.

## Recovery note

If the wrong node was removed or cluster state becomes unclear, do not run additional destructive commands. Preserve both systems, collect `pvecm status`, `pvecm nodes`, and relevant Corosync logs, and diagnose before proceeding.
