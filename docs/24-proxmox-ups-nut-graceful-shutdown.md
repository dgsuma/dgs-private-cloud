# Proxmox UPS and NUT Graceful Shutdown

## Status

**Completed and production-tested on 2026-08-23.**

The Eaton 5E 1200 AU G2 protecting `pve01` is connected to the Proxmox host
by USB and monitored with Network UPS Tools (NUT).

The completed design provides:

- live UPS state, battery charge, runtime, voltage, load, and related telemetry;
- mains-failure and mains-restoration detection;
- a 600-second grace period for sustained outages;
- cancellation of the pending shutdown when line power returns;
- immediate shutdown handling when the UPS reports low battery;
- orderly Proxmox guest shutdown before host shutdown;
- recovery of configured production VMs after the host boots again.

## Hardware and NUT configuration

| Item | Verified state |
|---|---|
| UPS | Eaton 5E 1200 AU G2 |
| Protected host | `pve01` on Beelink GTi12 |
| Monitoring link | USB |
| NUT mode | `standalone` |
| Driver | `usbhid-ups` |
| NUT device | `eaton5e` |
| USB vendor/product | `0463:ffff` |

Required services:

``text
nut-driver@eaton5e.service
nut-server.service
nut-monitor.service
``

All three were verified active after the final shutdown/recovery test.

The driver configuration uses `port = auto` with the Eaton USB vendor and
product IDs. The real NUT monitor password is host-local and must never be
committed.

Sanitised `upsmon` policy:

``text
MONITOR eaton5e@localhost 1 upsmon <redacted> primary
MINSUPPLIES 1
SHUTDOWNCMD "/sbin/shutdown -h now"
POWERDOWNFLAG /etc/killpower
POLLFREQ 5
POLLFREQALERT 5
HOSTSYNC 15
DEADTIME 15
FINALDELAY 5
NOTIFYCMD /sbin/upssched
NOTIFYFLAG ONBATT SYSLOG+EXEC
NOTIFYFLAG ONLINE SYSLOG+EXEC
NOTIFYFLAG LOWBATT SYSLOG+EXEC
``

## Power-failure policy

Production `/etc/nut/upssched.conf`:

``text
CMDSCRIPT /usr/local/sbin/nut-upssched-handler
PIPEFN /run/nut/upssched.pipe
LOCKFN /run/nut/upssched.lock
AT ONBATT * START-TIMER powerfail 600
AT ONLINE * CANCEL-TIMER powerfail
AT LOWBATT * EXECUTE lowbattery
``

Behaviour:

1. `ONBATT` starts a 600-second grace timer.
2. `ONLINE` cancels the pending timer if utility power returns.
3. `LOWBATT` executes the shutdown path immediately.
4. A sustained 600-second outage invokes `upsmon -c fsd`.
5. `upsmon` invokes the configured host shutdown command.
6. Proxmox uses its normal guest-stop process before the host shuts down.

The production handler is owned by `root:nut` with mode `750`. An early
safe test exposed exit status `126` when the handler was `root:root` with
mode `750`; changing the group to `nut` corrected execution by upssched.

## Safe timer validation

Before enabling a real shutdown, the handler was temporarily replaced by a
harmless logger and the timer reduced to 30 seconds.

A physical mains-loss test proved the complete path:

``text
Eaton UPS -> NUT USB driver -> upsmon -> upssched -> timer -> handler
``

The test handler logged successful expiry after 30 seconds, and mains
restoration returned the UPS to line power without shutting down the host.
The production handler and 600-second timer were then restored.

## Proxmox guest policy

At final validation:

| VM | Name | Startup order | Up delay | Down timeout | On boot |
|---|---|---:|---:|---:|---|
| `210` | `talos-cp-01` | 10 | 60 s | 120 s | Yes |
| `211` | `talos-worker-01` | 20 | 60 s | 120 s | Yes |
| `212` | `talos-worker-02` | 30 | 60 s | 120 s | Yes |
| `220` | `jenkins-ci` | 40 | 30 s | 60 s | Yes |

Test LXC `230` participated in the shutdown test but is not configured for
automatic production startup.

`pve-guests.service` was verified to use Proxmox `stopall` during host
shutdown, so the NUT-triggered system shutdown follows the normal Proxmox guest
shutdown path.

## Production mains-failure test

A real sustained outage was completed on 2026-08-23.

Observed result:

1. NUT detected the UPS on battery.
2. The 600-second grace period completed.
3. The production handler initiated NUT forced shutdown.
4. Proxmox stopped Jenkins, the Talos workers, test LXC `230`, and finally
   the Talos control-plane VM.
5. Proxmox reported all VMs and CTs stopped.
6. `pve01` completed shutdown and filesystem synchronisation.

This proves:

``text
mains failure
  -> Eaton UPS battery
  -> NUT ONBATT
  -> 600-second timer
  -> upssched handler
  -> upsmon FSD
  -> Proxmox guest shutdown
  -> pve01 shutdown
``

## Recovery validation

After power restoration and host recovery, the production VMs returned:

``text
210  talos-cp-01       running
211  talos-worker-01   running
212  talos-worker-02   running
220  jenkins-ci        running
230  test-lxc          stopped
``

The NUT driver, server, and monitor were active again and the UPS returned to
`OL` (on line). The test LXC remaining stopped is expected because it is not
part of the automatic production startup set.

QEMU Guest Agent timeout messages were observed while Proxmox shut down the
Talos VMs. They did not prevent the shutdown: Proxmox subsequently confirmed
all VMs and CTs stopped. Keep this observation for future Talos/Proxmox
optimisation.

## Operational checks

``bash
upsc eaton5e@localhost ups.status
upsc eaton5e@localhost battery.charge
upsc eaton5e@localhost battery.runtime

systemctl is-active nut-driver@eaton5e.service
systemctl is-active nut-server
systemctl is-active nut-monitor

qm list
pct list
``

## Security

Never commit the NUT `upsmon` password, private tailnet information,
credentials, tokens, or recovery secrets. Repository examples use
`<redacted>` for the NUT credential.

## Completion criteria

- [x] USB UPS telemetry operational.
- [x] Mains failure and restoration detected.
- [x] Safe 30-second timer/handler test passed.
- [x] Handler execution permissions corrected and verified.
- [x] 600-second production grace period operational.
- [x] Timer cancellation on restored line power configured.
- [x] Immediate low-battery shutdown path configured.
- [x] Sustained real mains failure triggered automatic shutdown.
- [x] Proxmox stopped all running VMs and CTs before host shutdown.
- [x] Host completed shutdown cleanly.
- [x] Production VMs returned after recovery.
- [x] NUT returned to healthy line-power monitoring.

The UPS graceful-shutdown task is complete.
