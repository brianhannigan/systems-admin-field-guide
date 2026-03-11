# STIG Troubleshooting

## Purpose
Provide a repeatable workflow for diagnosing systems that broke after hardening.

## Workflow
1. Identify what changed
2. Confirm which service or function is broken
3. Review service state
4. Review logs
5. Compare new settings to previous baseline
6. Validate permissions, auth, SELinux, and firewall behavior
7. Apply the smallest safe corrective action
8. Re-test and document evidence

## Commands to Start With
```bash
systemctl status <service>
journalctl -xe
journalctl -u <service> -n 100 --no-pager
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
ss -tulpn
ls -l /path/to/file
```

## Questions to Ask
- What exact STIG setting changed?
- Did remote access break or only app behavior?
- Did permissions change?
- Did the firewall change?
- Did authentication policy change?
- Did SELinux start blocking a valid action?

## Safe Fix Pattern
- confirm root cause
- apply minimal corrective change
- document why the change is needed
- preserve compliance where possible
- record any required exception

## Validation
- service starts cleanly
- logs are healthy
- access works as intended
- evidence is documented
