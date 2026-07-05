## Licence

Copyright © 2026 Duminda Sumanasinghe. All rights reserved.

This is a private and proprietary repository. Its contents may not be
copied, distributed, disclosed, modified, or reused without prior
written permission. See [LICENSE.md](LICENSE.md) for details.

# Proxmox VE Installation Plan — Beelink GTi12

This private repository documents the complete process for converting a **Beelink GTi12 mini PC** into a Proxmox VE virtualization host.

> **Important:** This procedure permanently erases the existing Ubuntu 24.04 installation on the 1TB Crucial SSD. The Samsung 990 PRO 2TB SSD is preserved during the Proxmox installation and configured afterward as the primary VM/LXC storage device.

---

## Table of Contents

1. [Current Hardware](#current-hardware)
2. [Recommended Final Storage Layout](#recommended-final-storage-layout)
3. [Critical Safety Rules](#critical-safety-rules)
4. [Phase 1 — Record Disk Identities](#phase-1--record-disk-identities)
5. [Phase 2 — Prepare Network Information](#phase-2--prepare-network-information)
6. [Phase 3 — Download and Verify Proxmox VE](#phase-3--download-and-verify-proxmox-ve)
7. [Phase 4 — Create the Installation USB](#phase-4--create-the-installation-usb)
8. [Phase 5 — Prepare the Beelink BIOS](#phase-5--prepare-the-beelink-bios)
9. [Phase 6 — Install Proxmox VE](#phase-6--install-proxmox-ve)
10. [Phase 7 — Configure Location and Administrator Account](#phase-7--configure-location-and-administrator-account)
11. [Phase 8 — Configure Management Networking](#phase-8--configure-management-networking)
12. [Phase 9 — First Login](#phase-9--first-login)
13. [Phase 10 — Configure Repositories and Updates](#phase-10--configure-repositories-and-updates)
14. [Phase 11 — Verify Networking](#phase-11--verify-networking)
15. [Phase 12 — Verify Both SSDs](#phase-12--verify-both-ssds)
16. [Phase 13 — Configure the Samsung 990 PRO](#phase-13--configure-the-samsung-990-pro)
17. [Phase 14 — Confirm the Final Storage Arrangement](#phase-14--confirm-the-final-storage-arrangement)
18. [Phase 15 — Apply Essential Security Settings](#phase-15--apply-essential-security-settings)
19. [Phase 16 — Run Health Checks](#phase-16--run-health-checks)
20. [Phase 17 — Prepare for Kubernetes](#phase-17--prepare-for-kubernetes)
21. [Installation Checklist](#installation-checklist)
22. [Suggested Repository Structure](#suggested-repository-structure)
23. [Create and Push the Private Git Repository](#create-and-push-the-private-git-repository)
24. [Maintenance Notes](#maintenance-notes)

---

## Current Hardware

### Beelink GTi12

- Intel Core i9-12900H
- 64GB RAM
- Two internal NVMe SSDs
- Dual wired network interfaces
- UEFI firmware
- Intel VT-x/VMX virtualization support
- Intel VT-d/IOMMU support

### Installed SSDs

| SSD | Current Linux device | Current state | Planned use |
|---|---|---|---|
| Crucial `CT1000P3PSSD8` 1TB | `/dev/nvme1n1` | Ubuntu 24.04 installed | Proxmox VE system disk |
| Samsung SSD 990 PRO 2TB | `/dev/nvme0n1` | Unallocated/unknown | Primary VM and LXC storage |

> Linux device names such as `/dev/nvme0n1` and `/dev/nvme1n1` can change after rebooting or reinstalling. Always identify disks by **manufacturer, model and capacity**, not only by the Linux device name.

---

## Recommended Final Storage Layout

| Proxmox storage | Physical SSD | Recommended use |
|---|---|---|
| `local` | Crucial 1TB | ISO images, container templates, snippets and temporary backups |
| `local-lvm` | Crucial 1TB | Test VMs, temporary workloads and secondary VM storage |
| `vmdata` | Samsung 990 PRO 2TB | Main VM disks, LXC containers and Kubernetes node disks |

### Storage design decision

Install Proxmox VE only on the **1TB Crucial SSD**.

Do not combine the 1TB and 2TB SSDs in RAID0 or RAID1 because:

- The drives have different capacities.
- RAID0 provides no fault tolerance.
- RAID1 would waste approximately 1TB of the larger SSD.
- Local RAID is not a replacement for a proper external backup.
- Separate system and workload disks make maintenance and recovery easier.

---

## Critical Safety Rules

1. The 1TB Crucial SSD will be completely erased.
2. Do not select the Samsung 990 PRO during the Proxmox installation.
3. Identify drives by model and capacity before every destructive operation.
4. Keep Proxmox management ports private.
5. Do not expose TCP port `8006` directly to the public internet.
6. Do not store passwords, private keys, tokens or API credentials in this repository.
7. Keep a separate backup outside both internal SSDs.

---

# Installation Procedure

## Phase 1 — Record Disk Identities

### Proxmox installation target

```text
Model: CT1000P3PSSD8
Capacity: 1TB
Current device: /dev/nvme1n1
Current contents: Ubuntu 24.04
Action: Completely erase and install Proxmox VE
```

### Disk to preserve during installation

```text
Model: Samsung SSD 990 PRO 2TB
Capacity: 2TB
Current device: /dev/nvme0n1
Current contents: Unallocated/unknown
Action: Leave untouched until Proxmox is installed
```

Take a photograph or screenshot of both model names before starting.

---

## Phase 2 — Prepare Network Information

The following values are suitable for the existing `192.168.1.0/24` home network plan.

| Setting | Planned value |
|---|---|
| Proxmox hostname | `pve01.home.arpa` |
| Management IP | `192.168.1.201/24` |
| Subnet mask | `255.255.255.0` |
| Default gateway | `192.168.1.1` |
| DNS server | `192.168.1.1` |
| Web management URL | `https://192.168.1.201:8006` |
| Management connection | Wired Ethernet |

Before using `192.168.1.201`, confirm that:

- No other device is using it.
- It is outside the router's automatic DHCP pool, or
- A reservation/exclusion has been configured for it.

Connect the Beelink directly to the router or network switch using Ethernet. Do not depend on Wi-Fi for the Proxmox management interface.

---

## Phase 3 — Download and Verify Proxmox VE

Download the current stable Proxmox VE ISO only from the official Proxmox website:

- <https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso>

The original plan used Proxmox VE `9.2-1`. Before installation, confirm the latest available stable release and use the SHA-256 checksum displayed on the official download page.

### Verify the ISO on Windows PowerShell

```powershell
Get-FileHash "$env:USERPROFILE\Downloads\proxmox-ve_9.2-1.iso" -Algorithm SHA256
```

Compare the result character-for-character with the official SHA-256 value.

Example verification workflow:

```powershell
$Iso = "$env:USERPROFILE\Downloads\proxmox-ve_9.2-1.iso"
Get-FileHash $Iso -Algorithm SHA256
```

Do not continue when the checksum does not match.

---

## Phase 4 — Create the Installation USB

Use an 8GB or larger USB flash drive.

### Recommended Windows method: Rufus

1. Download and open Rufus.
2. Select the correct USB flash drive.
3. Select the Proxmox VE ISO.
4. Start the write process.
5. When prompted, select **DD Image mode**.
6. Confirm that the USB drive can be erased.
7. Wait until the operation completes.
8. Safely eject the USB drive.

Official installation media guidance:

- <https://pve.proxmox.com/wiki/Prepare_Installation_Media>

---

## Phase 5 — Prepare the Beelink BIOS

Shut down the Beelink completely.

Connect:

- Proxmox installation USB
- Monitor
- Keyboard
- Ethernet cable
- Power supply

Power on the Beelink and press:

- `Delete` or `F2` to enter BIOS
- `F7` for the one-time boot menu

### BIOS settings

Confirm or configure the following:

| BIOS option | Required value |
|---|---|
| Boot mode | UEFI |
| Intel Virtualization Technology / VMX | Enabled |
| Intel VT-d | Enabled |
| Secure Boot | Disabled initially |
| Fast Boot | Disabled |
| CSM / Legacy Boot | Disabled where available |

Save the BIOS settings and reboot.

Open the one-time boot menu and select the **UEFI entry** for the Proxmox USB drive.

---

## Phase 6 — Install Proxmox VE

At the installer menu, select:

```text
Install Proxmox VE (Graphical)
```

Accept the licence agreement.

### Select the correct target disk

Select only:

```text
CT1000P3PSSD8 — 1TB Crucial SSD
```

Do not select:

```text
Samsung SSD 990 PRO — 2TB
```

The existing Ubuntu partitions on the Crucial SSD will be erased, including:

- Existing EFI System Partition
- Existing ext4 root partition
- All Ubuntu files and settings

### Filesystem selection

Use:

```text
ext4
```

Leave advanced storage parameters at their defaults unless there is a documented reason to change them.

The default ext4 installation normally creates:

- `local`
- `local-lvm`

Do not select:

- ZFS RAID0
- ZFS RAID1
- Btrfs RAID
- Both internal SSDs

Review the target disk one final time before starting installation.

---

## Phase 7 — Configure Location and Administrator Account

Use the following values:

| Installer field | Value |
|---|---|
| Country | Australia |
| Time zone | Australia/Melbourne |
| Keyboard | English US or preferred English layout |
| Administrator account | `root` |
| Root password | Strong, unique password |
| Email | Active administrator email address |

Store the root password in a proper password manager.

Never commit the password to Git.

---

## Phase 8 — Configure Management Networking

Select the Ethernet interface physically connected to the router or switch.

Possible interface names include:

```text
enp1s0
enp2s0
eno1
eno2
```

Use:

```text
Hostname:   pve01.home.arpa
IP address: 192.168.1.201/24
Gateway:    192.168.1.1
DNS server: 192.168.1.1
```

### Final installer review

Before starting the installation, confirm:

```text
Target disk: CT1000P3PSSD8 — 1TB
```

Confirm that the Samsung 990 PRO is not included in the installation target.

Start the installation.

When installation completes:

1. Remove the USB drive.
2. Reboot the Beelink.
3. Allow the machine to boot from the Crucial SSD.

---

## Phase 9 — First Login

After booting, the local console should display the management address:

```text
https://192.168.1.201:8006/
```

From another computer on the same LAN, open:

```text
https://192.168.1.201:8006
```

The browser will show a certificate warning because Proxmox initially uses a self-signed certificate. Continue only after confirming that the address is the intended local Proxmox host.

Log in with:

```text
Username: root
Password: <root-password>
Realm: Linux PAM standard authentication
```

The no-subscription warning is normal for a home-lab installation.

---

## Phase 10 — Configure Repositories and Updates

In the Proxmox web interface:

1. Select `pve01`.
2. Open **Updates**.
3. Open **Repositories**.
4. Disable the `pve-enterprise` repository unless a paid subscription is available.
5. Add the **No-Subscription** repository.
6. Reload the package lists.

Open:

```text
pve01 → Shell
```

Run:

```bash
apt update
apt full-upgrade -y
reboot
```

After rebooting, verify the installed version:

```bash
pveversion -v
```

Official package repository documentation:

- <https://pve.proxmox.com/pve-docs/pve-package-repos-plain.html>

---

## Phase 11 — Verify Networking

Run:

```bash
ip -br address
ip route
ping -c 4 192.168.1.1
ping -c 4 debian.org
```

Expected results:

- `vmbr0` has `192.168.1.201/24`.
- The default route uses `192.168.1.1`.
- The router responds to ping.
- DNS resolution and internet connectivity work.

Proxmox normally places the management IP on the Linux bridge `vmbr0`. The physical Ethernet interface becomes a bridge port so VMs can communicate through the physical network.

Leave the second Ethernet interface unused initially. It can later be used for:

- Cluster traffic
- Storage traffic
- A dedicated management network
- VLAN trunks
- A separate internal lab network

---

## Phase 12 — Verify Both SSDs

Open the Proxmox shell and run:

```bash
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
```

Then run:

```bash
nvme list
```

Confirm that both physical disks are visible:

```text
CT1000P3PSSD8       1TB
Samsung SSD 990 PRO 2TB
```

Do not assume that the device names are unchanged from Ubuntu.

Use model name, serial number and capacity to identify each disk.

---

## Phase 13 — Configure the Samsung 990 PRO

The Samsung 990 PRO will become the primary high-performance VM and LXC storage device.

### 13.1 Wipe and initialize the Samsung SSD

Navigate to:

```text
pve01 → Disks → Disks
```

Select:

```text
Samsung SSD 990 PRO 2TB
```

Confirm the model and capacity again.

Then:

1. Select **Wipe Disk**.
2. Confirm the destructive operation.
3. Select **Initialize Disk with GPT**.
4. Confirm.

Do not perform these actions on the Crucial system SSD.

### 13.2 Create an LVM volume group

Navigate to:

```text
pve01 → Disks → LVM
```

Select:

```text
Create: Volume Group
```

Use:

```text
Volume group name: vg_vmdata
Disk: Samsung SSD 990 PRO 2TB
```

Create the volume group.

### 13.3 Create an LVM-thin pool

Navigate to:

```text
pve01 → Disks → LVM-Thin
```

Select:

```text
Create: Thinpool
```

Use:

```text
Volume group: vg_vmdata
Thin pool name: thin_vmdata
Storage ID: vmdata
Add Storage: enabled
```

Use most or all of the available capacity.

### 13.4 Confirm storage content types

Navigate to:

```text
Datacenter → Storage → vmdata
```

Confirm that the following content types are enabled:

```text
Disk image
Container
```

LVM-thin provides:

- Thin provisioning
- VM snapshots
- Container snapshots
- Linked clones
- Efficient allocation of local block storage

It remains local to this Proxmox node and is not shared storage.

---

## Phase 14 — Confirm the Final Storage Arrangement

The final layout should resemble:

| Storage ID | Physical disk | Content |
|---|---|---|
| `local` | Crucial 1TB | ISO images, templates, snippets and optional temporary backup files |
| `local-lvm` | Crucial 1TB | Test and temporary VM/LXC disks |
| `vmdata` | Samsung 990 PRO 2TB | Primary VM, LXC and Kubernetes virtual disks |

When creating important VMs, select:

```text
Storage: vmdata
```

There is no immediate need to delete or resize `local-lvm`.

Check storage status:

```bash
pvesm status
```

Expected storage IDs:

```text
local
local-lvm
vmdata
```

---

## Phase 15 — Apply Essential Security Settings

### Keep management ports private

Do not create router port-forwarding rules for:

```text
TCP 8006  Proxmox web interface
TCP 22    SSH
TCP 3128  SPICE proxy
```

Access Proxmox only through:

- The trusted home LAN
- A private WireGuard VPN
- A private management VLAN
- A secure bastion or tunnel

Never expose the Proxmox web interface directly to the internet.

### Additional security recommendations

- Use a strong unique root password.
- Create a named administrator account later.
- Enable Proxmox two-factor authentication.
- Restrict SSH access.
- Use SSH keys instead of password authentication where practical.
- Keep the host fully updated.
- Configure a firewall at Datacenter, node and VM levels.
- Back up `/etc/pve` and critical configuration.
- Do not store secrets in this repository.

### Router recommendation

Where supported, reserve or exclude `192.168.1.201` for the Beelink management interface MAC address.

A reservation is useful even though Proxmox uses a static address because it documents the address allocation and reduces the chance of address conflicts.

---

## Phase 16 — Run Health Checks

### Proxmox version

```bash
pveversion -v
```

### Block devices

```bash
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
```

### Proxmox storage

```bash
pvesm status
```

### Memory

```bash
free -h
```

### CPU virtualization support

```bash
lscpu | grep -E 'Model name|Virtualization'
```

### Failed services

```bash
systemctl --failed
```

### Network

```bash
ip -br address
ip route
```

### NVMe devices

```bash
nvme list
```

### Kernel and IOMMU checks

```bash
dmesg | grep -Ei 'DMAR|IOMMU'
```

### SMART and SSD health

In the Proxmox web interface:

```text
pve01 → Disks → Disks → Select Disk → SMART
```

Check both:

- Crucial 1TB SSD
- Samsung 990 PRO 2TB SSD

Look for:

- Media errors
- Critical warnings
- Excessive temperatures
- Percentage used
- Unsafe shutdown count
- Data integrity errors

---

## Phase 17 — Prepare for Kubernetes

Before creating staging or production-like Kubernetes clusters:

1. Reboot the Proxmox host at least twice.
2. Confirm that `https://192.168.1.201:8006` is available after every reboot.
3. Confirm that `vmdata` activates automatically.
4. Upload an Ubuntu Server ISO or cloud image to `local`.
5. Create one small test VM on `vmdata`.
6. Verify DHCP or static networking inside the VM.
7. Verify internet and DNS access.
8. Create a VM snapshot.
9. Restore or roll back the snapshot.
10. Test VM migration only after additional Proxmox nodes are available.
11. Configure external backup storage before hosting important workloads.
12. Document VM IDs, IP addresses, roles and resource allocations.

### Suggested first test VM

```text
Name: ubuntu-test
vCPU: 2
RAM: 4GB
Disk: 32GB
Storage: vmdata
Network bridge: vmbr0
Operating system: Ubuntu Server
```

### Suggested Kubernetes planning

The Beelink can later host multiple VMs such as:

```text
k8s-stage-cp01
k8s-stage-worker01
k8s-stage-worker02
k8s-prod-cp01
k8s-prod-worker01
k8s-prod-worker02
```

Resource allocation must account for:

- Proxmox host overhead
- Kubernetes control-plane overhead
- Workload memory
- Storage performance
- Backup capacity
- Failure scenarios

---

## Installation Checklist

### Before installation

- [ ] Confirm no required data remains on the Crucial 1TB SSD.
- [ ] Record the model and serial number of both SSDs.
- [ ] Confirm the Samsung 990 PRO must not be erased during installation.
- [ ] Download the official Proxmox VE ISO.
- [ ] Verify the SHA-256 checksum.
- [ ] Create the USB installer in DD mode.
- [ ] Confirm the planned static IP is available.
- [ ] Connect the Beelink using Ethernet.
- [ ] Enable VMX and VT-d.
- [ ] Disable Secure Boot initially.
- [ ] Disable Fast Boot.

### During installation

- [ ] Select the graphical installer.
- [ ] Select only the Crucial `CT1000P3PSSD8` 1TB SSD.
- [ ] Use ext4.
- [ ] Configure the correct time zone.
- [ ] Set a strong root password.
- [ ] Configure `pve01.home.arpa`.
- [ ] Configure `192.168.1.201/24`.
- [ ] Configure gateway `192.168.1.1`.
- [ ] Configure DNS `192.168.1.1`.
- [ ] Review the target disk before confirming.

### After installation

- [ ] Log in at `https://192.168.1.201:8006`.
- [ ] Disable the enterprise repository if no subscription is used.
- [ ] Add the no-subscription repository.
- [ ] Run the complete update.
- [ ] Reboot.
- [ ] Verify network connectivity.
- [ ] Verify both NVMe SSDs.
- [ ] Wipe only the Samsung 990 PRO.
- [ ] Create `vg_vmdata`.
- [ ] Create `thin_vmdata`.
- [ ] Add storage ID `vmdata`.
- [ ] Run SSD health checks.
- [ ] Create a test VM.
- [ ] Test snapshots.
- [ ] Configure external backups.
- [ ] Keep port `8006` private.

---

## Suggested Repository Structure

```text
beelink-gti12-proxmox/
├── README.md
├── docs/
│   ├── network-plan.md
│   ├── storage-plan.md
│   ├── backup-plan.md
│   ├── security-hardening.md
│   └── kubernetes-vm-plan.md
├── images/
│   ├── 1tb-crucial-before-install.png
│   └── 2tb-samsung-before-install.png
├── scripts/
│   ├── host-health-check.sh
│   └── backup-config.sh
├── inventory/
│   └── example-host-inventory.yaml
└── .gitignore
```

### Suggested `.gitignore`

```gitignore
# Secrets and credentials
.env
.env.*
*.key
*.pem
*.p12
*.pfx
*.kubeconfig
credentials*
secrets*
private*

# Terraform and automation secrets
*.tfstate
*.tfstate.*
.terraform/
terraform.tfvars
*.auto.tfvars

# Ansible
*.retry
vault-password*

# Backups and disk images
*.bak
*.backup
*.vma
*.vma.zst
*.raw
*.qcow2
*.img
*.iso

# Logs and temporary files
*.log
*.tmp
*.swp
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
```

> Do not commit actual passwords, private keys, VPN configurations, API tokens, backup archives or full Proxmox configuration exports containing sensitive information.

---

## Create and Push the Private Git Repository

The following example assumes Git is installed and a new empty **private** remote repository has already been created.

### 1. Create the local project directory

```bash
mkdir beelink-gti12-proxmox
cd beelink-gti12-proxmox
```

Place this `README.md` inside the directory.

### 2. Create supporting directories

```bash
mkdir -p docs images scripts inventory
```

### 3. Initialize Git

```bash
git init
```

### 4. Rename the default branch to `main`

```bash
git branch -M main
```

### 5. Add a `.gitignore`

Create `.gitignore` using the example in this README.

### 6. Review files before committing

```bash
git status
```

Confirm that no secret, password, private key or large disk image is present.

### 7. Create the first commit

```bash
git add README.md .gitignore docs images scripts inventory
git commit -m "docs: add Beelink GTi12 Proxmox installation plan"
```

### 8. Add the private remote repository

HTTPS example:

```bash
git remote add origin https://github.com/<username>/<private-repository>.git
```

SSH example:

```bash
git remote add origin git@github.com:<username>/<private-repository>.git
```

### 9. Confirm the remote

```bash
git remote -v
```

### 10. Push the repository

```bash
git push -u origin main
```

### 11. Confirm privacy

Open the repository settings on the Git hosting platform and verify that repository visibility is:

```text
Private
```

---

## Maintenance Notes

### After every major Proxmox update

Run:

```bash
pveversion -v
systemctl --failed
pvesm status
nvme list
```

### Monthly checks

- Review Proxmox updates.
- Review SSD SMART data.
- Verify backup jobs.
- Test restoration of at least one non-critical VM or container.
- Review failed login attempts.
- Review storage usage.
- Review temperatures.
- Confirm the UPS is operating correctly once installed.

### Backup principle

Backups stored on either internal SSD do not protect against:

- Complete Beelink failure
- Theft
- Fire or water damage
- Electrical damage
- Accidental destruction of both disks
- Malware or administrator error

Use a separate NAS, Proxmox Backup Server or another external destination for important backups.

A suitable future arrangement is:

```text
Proxmox host
    ├── Crucial 1TB: Proxmox system and secondary storage
    ├── Samsung 2TB: Main VM/LXC storage
    └── External NAS/PBS: Versioned backups
```

---

## Final Warning

At the Proxmox installer target-disk screen, install only to:

```text
CT1000P3PSSD8 — 1TB Crucial SSD
```

Leave this disk out of the installer target selection:

```text
Samsung SSD 990 PRO — 2TB
```

Configure the Samsung SSD only after Proxmox VE is successfully installed and both physical drives have been identified again by model and capacity.

---

## Status

```text
Planning: Complete
Installation USB: Pending
Proxmox installation: Pending
Samsung VM storage configuration: Pending
Test VM validation: Pending
External backup configuration: Pending
Kubernetes deployment: Pending
```

---

## Documentation References

- Proxmox VE ISO downloads: <https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso>
- Proxmox installation media: <https://pve.proxmox.com/wiki/Prepare_Installation_Media>
- Proxmox package repositories: <https://pve.proxmox.com/pve-docs/pve-package-repos-plain.html>
- Proxmox VE administration guide: <https://pve.proxmox.com/pve-docs/pve-admin-guide.pdf>
