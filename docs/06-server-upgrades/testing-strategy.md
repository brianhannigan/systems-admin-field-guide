# Testing Strategy

## Purpose
Provide a structured way to test upgrades before and after implementation.

## Pre-Change Testing
- Test in lab or staging if possible
- Review compatibility with application stack
- Confirm startup behavior after reboot
- Confirm required services remain enabled
- Confirm logging and monitoring still work

## Functional Test Categories
- Service starts
- Port is listening
- App responds correctly
- Authentication works
- Scheduled tasks work
- Logging works
- Monitoring still receives data

## Suggested Validation Commands
```bash
systemctl --failed
systemctl status <service>
journalctl -xe
ss -tulpn
df -h
```

## Post-Upgrade Test Pattern
1. Confirm system boots correctly
2. Confirm required services are active
3. Confirm application functionality
4. Confirm network connectivity
5. Confirm logs are healthy
6. Confirm monitoring is normal

## Validation Checklist
- Test plan exists before change
- Same checks are used consistently
- Results are documented
- Failures are captured with evidence
