# Post-Upgrade Validation

## Purpose
Capture what must be checked immediately after an upgrade or major patch event.

## Immediate Checks
- System is online
- Expected services are active
- Expected ports are listening
- Application responds correctly
- No obvious new log errors
- Monitoring sees the system
- Security controls still hold

## Linux Validation Examples
```bash
hostnamectl
uptime
systemctl --failed
journalctl -p err -b
ss -tulpn
df -h
```

## Questions to Confirm
- Did all services come back?
- Did any new errors appear?
- Did firewall or SELinux behavior change?
- Did a reboot change network behavior?
- Did application owners validate functionality?

## Evidence to Capture
- Service status output
- Log excerpts
- App health result
- Monitoring screenshot or check result
- Completion note in change ticket

## Validation Checklist
- Technical checks passed
- Functional checks passed
- Security checks passed
- Evidence recorded
- Stakeholders notified
