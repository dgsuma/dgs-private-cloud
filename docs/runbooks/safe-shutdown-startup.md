# Runbook: Safe Shutdown and Startup

## Shutdown

Preferred GUI method:

```text
pve01 → Shutdown
```

Shell method:

```bash
shutdown -h now
```

Before shutting down a host with guests:

1. Confirm backups are not running.
2. Shut down or migrate guests.
3. Confirm no critical storage task is active.
4. Shut down the host.
5. Wait for the power LED and fan to stop.

## Startup

1. Press the Beelink power button once.
2. Wait approximately one to three minutes.
3. Open `https://192.168.1.201:8006`.
4. Confirm all storage is active:

```bash
pvesm status
```

5. Confirm no failed units:

```bash
systemctl --failed
```
