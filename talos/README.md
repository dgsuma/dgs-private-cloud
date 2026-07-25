# Talos Configuration

## Current state

- Talos version: `v1.13.6`
- Schematic ID: `ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515`
- Extension: `siderolabs/qemu-guest-agent`
- Control-plane VM: `talos-cp-01` / VM `210`
- Kubernetes: not bootstrapped

## Directory policy

```text
talos/
├── README.md
├── image-factory-schematic.yaml
├── generated/   # ignored; contains credentials
└── patches/     # non-secret machine configuration patches
```

Files under `generated/` must never be committed.

This includes:

- `controlplane.yaml`,
- `worker.yaml`,
- `talosconfig`,
- kubeconfig,
- generated secrets.

Non-secret patches may be committed after review.
