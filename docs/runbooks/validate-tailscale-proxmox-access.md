# Validate Tailscale Remote Proxmox Access

## Purpose

Confirm that Proxmox remains reachable privately through Tailscale after client,
router, Proxmox, or Tailscale service changes.

## Safety rules

- Keep Tailscale Funnel disabled.
- Do not publish the real tailnet suffix or Tailscale IP in evidence.
- Do not reboot Proxmox until a non-disruptive connectivity test succeeds.
- Do not run forced Tailscale reauthentication from the only remote session.

## Proxmox-side validation

```bash
systemctl is-enabled tailscaled
systemctl is-active tailscaled
tailscale status
tailscale serve status
systemctl is-active pveproxy
ss -lntp | grep 8006
```

Expected conditions:

- `tailscaled` is enabled and active.
- `pveproxy` is active.
- Serve proxies to `https+insecure://127.0.0.1:8006`.
- TCP port `8006` is listening locally.
- `mel-pve01` is connected to the tailnet.

## LG Gram validation

```powershell
tailscale status
tailscale ping mel-pve01
Test-NetConnection mel-pve01 -Port 8006
```

Acceptance criteria:

```text
TcpTestSucceeded : True
```

Open:

```text
https://mel-pve01.<tailnet-name>.ts.net/
```

Confirm that the Proxmox login page or authenticated dashboard loads.

## Moto G84 validation

1. Disable Wi-Fi.
2. Confirm the phone is using mobile data.
3. Connect Tailscale.
4. Keep the exit node set to `None`.
5. Open the private Serve URL.
6. Confirm the Proxmox node summary loads.

## Alternate-network validation

Connect the LG Gram to a network other than the Melbourne Archer NX200 LAN,
then repeat the browser and PowerShell tests.

## Reboot validation

Perform while physically present in Melbourne:

1. Reboot Proxmox.
2. Wait for the host and `tailscaled` to start.
3. Test through mobile data.
4. Reboot the Archer NX200.
5. Confirm Tailscale reconnects.
6. Repeat the LG Gram alternate-network test.

## Evidence

Record only:

- date and local time;
- client type;
- external network type;
- pass or fail;
- whether the path was direct or relayed;
- TCP `8006` result;
- Serve URL result.

Store unredacted screenshots in `evidence/private/`, which must remain ignored.
