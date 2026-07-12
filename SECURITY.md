# Security Policy

## Private management plane

The Proxmox management interface must remain accessible only from trusted private networks or an approved private VPN.

Do not forward these ports from the TP-Link Archer NX200:

```text
8006/tcp  Proxmox web management
22/tcp    SSH
3128/tcp  SPICE proxy
```

## Secret-handling policy

Never commit:

- root or administrator passwords,
- SSH private keys,
- API tokens,
- recovery codes,
- router configuration exports,
- VPN private keys,
- SIM identifiers,
- public WAN details that are not intentionally documented,
- VM disk images,
- backup archives,
- files from `/etc/pve/priv/`.

## Screenshot policy

Before committing screenshots, redact:

- IMSI,
- ICCID,
- MSISDN/mobile number,
- public WAN address,
- passwords,
- tokens,
- QR codes,
- serial numbers when not operationally required,
- browser session identifiers.

## Destructive-change policy

Before wiping or repartitioning a disk:

1. Identify it by model, serial, and capacity.
2. Confirm it is not the running system disk.
3. Record the command or GUI operation.
4. Record the expected result.
5. Ensure a recovery path exists.

The Proxmox system disk is:

```text
/dev/nvme1n1
Crucial CT1000P3PSSD8 1TB
```

It must never be used as the target of a wipe command.
