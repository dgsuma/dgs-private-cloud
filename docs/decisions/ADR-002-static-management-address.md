# ADR-002: Static Proxmox Management Address

- Status: Accepted
- Date: 2026-07-11

## Decision

Use:

```text
pve01.home.arpa
192.168.1.201/24
Gateway: 192.168.1.1
DNS: 192.168.1.1
```

Reserve the address against MAC `B0:41:6F:12:9A:69` on the Archer NX200.

## Rationale

- Stable administration URL.
- Predictable automation target.
- Suitable for later cluster planning.
- Avoids dependence on a changing DHCP lease.

## Consequences

- Address conflicts must be prevented.
- Router and host documentation must stay aligned.
