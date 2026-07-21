# First Ubuntu VM Validation

## Purpose

Validate the complete first-guest workflow on the standalone Beelink Proxmox node:

- ISO upload,
- VM creation,
- Ubuntu installation,
- bridged networking,
- guest-agent integration,
- SSH and SCP,
- Nginx deployment,
- DHCP reservation,
- clean shutdown and restart.

## Verified VM configuration

| Property | Value |
|---|---|
| Node | `pve01` |
| VM ID | `100` |
| Proxmox name | `ubuntu-web-test` |
| Guest hostname | `web-test01` |
| OS | Ubuntu Server 26.04 LTS |
| vCPU | 2 |
| Memory | 4GiB |
| Disk | 32GiB |
| Disk storage | `vmdata` |
| Disk bus | SCSI |
| Network model | VirtIO |
| Bridge | `vmbr0` |
| QEMU Guest Agent option | Enabled |
| Guest autostart | Disabled |

## Storage placement

```text
Ubuntu ISO       -> local
VM virtual disk  -> vmdata
```

No physical disk was initialised or wiped during guest creation.

## Ubuntu installation

The guided installer used the complete 32GiB virtual disk with LVM. This operation affected only the VM disk.

Installed packages:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y nginx curl qemu-guest-agent openssh-server
sudo systemctl enable --now nginx
sudo systemctl enable --now qemu-guest-agent
sudo systemctl enable --now ssh
```

Validation:

```bash
systemctl is-active nginx
systemctl is-active qemu-guest-agent
systemctl is-active ssh
```

Expected result for each service:

```text
active
```

## Test web page

Nginx document root:

```text
/var/www/html
```

Test page:

```text
/var/www/html/index.html
```

File installation pattern:

```bash
sudo install -m 644 /home/duminda/index.html /var/www/html/index.html
```

Validation:

```bash
sudo nginx -t
curl http://localhost
curl -I http://localhost
```

Expected HTTP result:

```text
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html
```

## Windows file transfer

The HTML file was created on the Windows admin laptop and copied to the guest:

```powershell
scp "$HOME\Downloads\index.html" duminda@192.168.1.205:/home/duminda/index.html
```

SSH access:

```powershell
ssh duminda@192.168.1.205
```

If Windows reports a changed host key after a legitimate guest rebuild, first verify the guest fingerprint through the Proxmox console, then remove the stale entry:

```powershell
ssh-keygen -R 192.168.1.205
```

## Network reservation

The VM initially received a dynamic address. The Archer NX200 was then configured to reserve:

```text
Guest hostname: web-test01
Reserved IPv4:  192.168.1.205
Address method: DHCP reservation
```

The guest remains configured for DHCP. The router assigns the stable address based on the VM's virtual NIC.

Verified browser URL:

```text
http://192.168.1.205
```

## Shutdown and restart

Safe guest shutdown:

```bash
sudo shutdown -h now
```

Proxmox shell alternative:

```bash
qm shutdown 100
```

Start and verify:

```bash
qm start 100
qm status 100
```

Before shutting down `pve01`, confirm the VM is stopped:

```bash
qm list
```

Then shut down the host through the Proxmox GUI or:

```bash
shutdown -h now
```

## Validation result

Successful:

- VM creation,
- Ubuntu installation,
- console login,
- package updates,
- bridged LAN access,
- DHCP reservation,
- SSH and SCP,
- QEMU Guest Agent,
- Nginx service,
- static web page,
- local and remote HTTP response,
- clean guest shutdown,
- guest restart,
- safe host shutdown.

Not yet tested:

- snapshot and rollback,
- backup and restore,
- clone and template conversion,
- firewall policy,
- automated provisioning.