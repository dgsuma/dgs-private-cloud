# Runbook: Internet Connectivity

## Proxmox tests

```bash
ping -c 4 192.168.1.1
getent ahostsv4 deb.debian.org
curl -4 --connect-timeout 10 -I https://deb.debian.org
```

## Windows comparison tests

```powershell
Test-NetConnection 1.1.1.1 -Port 443
curl.exe --ssl-no-revoke -4 -I https://deb.debian.org
```

## Known working router profile

```text
Profile:        Vodafone-IPv4
PDP Type:       IPv4
APN:            live.vodafone.com
Authentication: NONE
```

## Diagnostic interpretation

| Result | Meaning |
|---|---|
| Cannot reach `192.168.1.1` | Local bridge, cable, VLAN, IP, or interface issue |
| Gateway works; DNS fails | DNS configuration issue |
| DNS works; IPv4 curl fails | Router/WAN IPv4 issue |
| Laptop IPv6 works, IPv4 fails | Dual-stack profile lacks usable IPv4 |
| HTTP 200 from Proxmox | Outbound HTTPS is healthy |
