# Automation

## Purpose
Document basic Linux automation patterns that save time and improve consistency.

## Bash Script Structure
```bash
#!/usr/bin/env bash
set -euo pipefail
```

## Common Use Cases
- Service health checks
- Disk usage reporting
- Package update checks
- Log collection
- Backup verification

## Example: Health Check Script
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Hostname ==="
hostname

echo "=== Uptime ==="
uptime

echo "=== Disk Usage ==="
df -h

echo "=== Failed Services ==="
systemctl --failed || true
```

## Cron Basics
```bash
crontab -l
crontab -e
```

## Automation Rules
- Log all meaningful actions
- Fail safely
- Validate before changing production settings
- Prefer idempotent checks when possible

## Validation
- Script runs without syntax errors
- Output is readable
- Failure conditions are obvious
- Results are logged or visible
