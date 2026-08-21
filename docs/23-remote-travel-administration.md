# Remote Travel Administration Through Tailscale

> Status: COMPLETE
>
> Completed: 2026-08-21
>
> Scope: LG Gram travel workstation, Kubernetes administration, Talos OS administration, and Proxmox recovery access
>
> Security model: authenticated private Tailscale access only; no public management-port exposure

## Objective

Provide a tested administration path from an external internet connection so the Melbourne homelab can be operated while travelling without exposing Kubernetes, Talos, SSH, or Proxmox management ports to the public internet.

The completed design provides three independent management layers:

1. Kubernetes administration with `kubectl` through the Tailscale Kubernetes API proxy.
2. Talos OS administration with `talosctl` through a Tailscale subnet route to the Melbourne LAN.
3. Proxmox recovery access directly to the Tailscale-connected `mel-pve01` host.

## Verified architecture

```text
External Wi-Fi / mobile hotspot
             |
             v
          LG Gram
             |
      MobaXterm + WSL2
             |
      Windows Tailscale
        /           \
       /             \
      v               v
Tailscale K8s       mel-pve01
API proxy           subnet router
      |               |
      v               v
Kubernetes API    192.168.1.0/24
      |               |
   kubectl        Talos API :50000
                      |
               .210 / .211 / .212
                      |
                  talosctl

Direct Proxmox recovery:
LG Gram -> Tailscale -> mel-pve01 -> SSH / TCP 8006
```

Exact tailnet DNS suffixes and Tailscale IP addresses are intentionally not recorded in Git.

## LG Gram travel workstation

The workstation uses:

- Windows Tailscale as the only Tailscale client;
- MobaXterm as the terminal application;
- Ubuntu WSL2 for Linux `kubectl` and `talosctl`;
- a dedicated travel kubeconfig stored outside Git;
- a local Talos configuration copied from ignored/generated recovery material and stored outside Git.

Do not run a second Tailscale daemon inside WSL2 while Windows Tailscale is active.

## WSL2 mirrored networking

WSL2 originally used NAT networking. During external-network testing, Linux `kubectl` temporarily returned:

```text
dial tcp <tailscale-address>:443: connect: no route to host
```

The LG Gram was changed to WSL2 mirrored networking through `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
networkingMode=mirrored
dnsTunneling=true
firewall=true
autoProxy=true
```

WSL was then restarted:

```powershell
wsl --shutdown
```

After the restart, WSL inherited Windows Tailscale routes correctly.

## Kubernetes remote administration

The normal Talos-generated kubeconfig points to the LAN Kubernetes endpoint and is not used as the travel kubeconfig.

A separate travel kubeconfig was created outside Git and configured against the Tailscale Kubernetes API proxy.

Validated commands:

```bash
KUBECONFIG="$HOME/.kube/dgs-travel-kubeconfig" kubectl get nodes
KUBECONFIG="$HOME/.kube/dgs-travel-kubeconfig" kubectl get pods -A
KUBECONFIG="$HOME/.kube/dgs-travel-kubeconfig" kubectl top nodes
```

All three Kubernetes nodes reported `Ready`.

If WSL networking is unavailable, Windows `kubectl` can be used directly with the Windows copy of the travel kubeconfig.

## `mel-pve01` as the Tailscale subnet router

`pve01`, represented in Tailscale as `mel-pve01`, is the always-on subnet router for the Melbourne LAN.

Advertised route:

```text
192.168.1.0/24
```

It is not configured as an exit node.

Persistent forwarding is configured on `pve01` in:

```text
/etc/sysctl.d/99-tailscale.conf
```

with:

```text
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

The route was advertised with:

```bash
tailscale set --advertise-routes=192.168.1.0/24
```

and approved in the Tailscale administration console.

## Talos remote administration

Talos administration uses `talosctl` over TCP `50000`.

The subnet route provides authenticated reachability to:

- `192.168.1.210` — `talos-cp-01`;
- `192.168.1.211` — `talos-worker-01`;
- `192.168.1.212` — `talos-worker-02`.

Validated commands:

```bash
talosctl --endpoints 192.168.1.210 health

talosctl \
  --endpoints 192.168.1.210 \
  --nodes 192.168.1.210,192.168.1.211,192.168.1.212 \
  service
```

`talosctl health` completed all checks with `OK`, and `talosctl service` successfully queried all three nodes.

## Proxmox remote recovery

Direct Tailscale access to `mel-pve01` was validated independently of Kubernetes.

Validated checks:

```text
tailscale ping mel-pve01
SSH to mel-pve01
TCP 8006 to mel-pve01
```

Remote SSH succeeded and TCP `8006` returned a successful connectivity test.

## External-network validation

The complete design was tested away from the Melbourne home LAN using:

1. an alternate Wi-Fi/internet connection; and
2. a Moto G84 mobile-data hotspot.

Both networks successfully supported Kubernetes, Talos, and Proxmox administration.

## Security controls

- Do not publicly forward TCP `22`, `6443`, `50000`, or `8006`.
- Keep Tailscale Funnel disabled for management services.
- Advertise only `192.168.1.0/24`; do not advertise `0.0.0.0/0`.
- Keep kubeconfig, talosconfig, exact tailnet DNS suffixes, Tailscale IP addresses, credentials, and private screenshots outside Git.
- Continue ignoring `talos/generated/*`, `git-commands-local.txt`, and private Tailscale evidence.

## Troubleshooting

### Kubernetes reports `no route to host`

```bash
powershell.exe -NoProfile -Command "tailscale status"
powershell.exe -NoProfile -Command "tailscale ping beelink-talos-operator"
```

If Windows Tailscale works but WSL does not:

```bash
powershell.exe -NoProfile -Command "wsl --shutdown"
```

Reopen MobaXterm after WSL stops.

### Talos LAN addresses are unreachable

Check TCP `50000` from Windows:

```powershell
Test-NetConnection 192.168.1.210 -Port 50000
```

On `pve01`, verify:

```bash
sysctl net.ipv4.ip_forward
sysctl net.ipv6.conf.all.forwarding
tailscale status
```

Also confirm that the `192.168.1.0/24` route remains approved in Tailscale.

### Overlapping remote LAN

The Melbourne LAN is `192.168.1.0/24`. If a hotel or remote LAN uses the same subnet, use a mobile hotspot or another non-overlapping network.

## Completion status

Remote travel administration is complete and externally validated:

- Kubernetes API proxy access: PASS.
- WSL2 travel kubeconfig: PASS.
- All three Kubernetes nodes `Ready`: PASS.
- `mel-pve01` subnet route: PASS.
- Talos TCP `50000`: PASS.
- `talosctl health`: PASS.
- multi-node `talosctl service`: PASS.
- remote Proxmox SSH: PASS.
- Proxmox TCP `8006`: PASS.
- Moto G84 mobile-data validation: PASS.
