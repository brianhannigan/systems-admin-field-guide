# Service Management

## Purpose
This document is a practical Linux service troubleshooting guide for administrators supporting production or production-like environments.

## Why This Matters
When services fail, users feel it immediately. The difference between a calm operator and a guesser is having a repeatable method that moves from symptom to evidence to fix to validation.

## Core systemd Commands
```bash
systemctl status <service>
systemctl restart <service>
systemctl stop <service>
systemctl start <service>
systemctl enable <service>
systemctl disable <service>
systemctl is-active <service>
systemctl list-units --type=service
systemctl --failed
```

## First-Response Workflow

### 1. Confirm the Exact Service
Avoid assumptions. Identify the exact service unit name.

### 2. Check Current Status
```bash
systemctl status <service>
```

### 3. Check Recent Logs
```bash
journalctl -u <service> -n 100 --no-pager
journalctl -xe
```

### 4. Confirm Process and Port State
```bash
ps aux | grep <service>
ss -tulpn
```

### 5. Check Config Validity if Supported
Examples:
```bash
nginx -t
sshd -t
apachectl configtest
```

### 6. Check Dependencies
Examples:
- upstream DB reachable
- mount exists
- DNS resolves
- cert/key readable
- runtime directory writable

### 7. Restart Only After Evidence Is Gathered
Then validate real functionality, not just active state.

## Common Failure Categories

### Bad Configuration
Symptoms:
- immediate exit
- syntax errors in logs
- restart fails repeatedly

### Port Conflict
Symptoms:
- bind errors
- service exits right after start
- another process already holds the port

Commands:
```bash
ss -tulpn | grep :80
lsof -i :80
```

### Permission Problem
Symptoms:
- cannot read config
- cannot write log or PID file
- permission denied in logs

Commands:
```bash
ls -l /path/to/file
namei -l /path/to/file
```

### SELinux Issue
Symptoms:
- Unix permissions look fine
- service still fails
- AVC denials appear

Commands:
```bash
getenforce
ausearch -m avc -ts recent
```

### Missing Dependency
Symptoms:
- service starts partially
- health check fails
- service relies on network, mount, or another daemon

Commands:
```bash
ping <dependency>
systemctl list-dependencies <service>
mount
```

## Validation Pattern
After a fix, validate all relevant layers:

- service active
- expected process exists
- expected port is listening
- local request succeeds
- remote request succeeds if expected
- logs are clean
- monitoring returns to normal

Examples:
```bash
systemctl is-active <service>
ss -tulpn
curl -I http://localhost
journalctl -u <service> -n 20 --no-pager
```

## Example: NGINX Failure After Config Change
```bash
systemctl status nginx
journalctl -u nginx -n 50 --no-pager
nginx -t
ss -tulpn | grep :80
curl -I http://localhost
```

## Example: SSHD Failure After Hardening
```bash
systemctl status sshd
journalctl -u sshd -n 50 --no-pager
sshd -t
ss -tulpn | grep :22
firewall-cmd --list-all
```

## Operational Rules
- never restart first and think later
- capture evidence before changing things
- validate function, not just status
- document recurring failure patterns
- build reusable runbooks from real incidents

## Quick Runbook
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
ss -tulpn
# config test if supported
systemctl restart <service>
curl -I http://localhost
journalctl -u <service> -n 20 --no-pager
```