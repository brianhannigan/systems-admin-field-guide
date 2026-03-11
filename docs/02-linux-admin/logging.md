# Logging

## Purpose
Provide a practical log review workflow for service failures, upgrades, and security validation.

## Primary Log Tools
```bash
journalctl
tail -f /var/log/messages
tail -f /var/log/secure
dmesg
```

## journalctl Examples
```bash
journalctl -u sshd
journalctl -u nginx -n 50 --no-pager
journalctl --since "1 hour ago"
journalctl -p err -b
```

## Log Review Workflow
1. Identify the affected service or subsystem
2. Pull recent service logs
3. Review boot or kernel errors if needed
4. Check authentication logs for access failures
5. Correlate timestamps with user actions or patch events

## Useful Logs
- `/var/log/messages`
- `/var/log/secure`
- `/var/log/audit/audit.log`
- Application-specific log paths

## Validation
- Error source identified
- Event timeline documented
- Fix applied
- Healthy logs confirmed after change
