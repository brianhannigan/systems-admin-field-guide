# STIG Troubleshooting

## Purpose
This document provides a repeatable workflow for diagnosing systems that break after STIG hardening, baseline tightening, or security policy enforcement.

## Why This Matters
STIG changes often improve security while breaking assumptions that applications, admins, or automation previously relied on. Good troubleshooting here is not guessing. It is disciplined validation of what changed, what failed, and what minimal corrective action restores function safely.

## Primary Triage Questions
Before making any change, answer these questions:

- What STIG control or hardening action changed?
- What exact function broke?
- Did access break, did the service fail, or did the app become partially degraded?
- Is this a permissions issue, authentication issue, SELinux issue, firewall issue, or dependency issue?
- Is the break local only, remote only, or both?

## First Commands to Run
```bash
systemctl status <service>
journalctl -xe
journalctl -u <service> -n 100 --no-pager
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
ss -tulpn
ls -l /path/to/file
id <service-account>
```

## Standard Troubleshooting Workflow

### 1. Identify the Change
Determine exactly what was hardened:
- SSH config
- PAM or auth policy
- file permissions
- service account restrictions
- audit settings
- firewall rules
- SELinux context or enforcement behavior

### 2. Identify the Failed Behavior
Classify the symptom:
- remote access failure
- service fails to start
- service starts but app is broken
- app loses write access
- logs show denials or syntax errors
- expected traffic no longer reaches the host

### 3. Review Service State and Logs
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
journalctl -xe
```

### 4. Validate Access Path
Check whether the failure is local, remote, or both:
```bash
ss -tulpn
curl -I http://localhost
curl -I http://127.0.0.1
```

### 5. Validate Permissions and Service Identity
```bash
id <service-account>
ls -l /path/to/file
namei -l /path/to/file
sudo -u <service-account> test -r /path/to/file && echo readable
```

### 6. Validate SELinux and Firewall
```bash
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
```

### 7. Apply the Smallest Safe Fix
Do not weaken everything at once. Correct the actual blocking condition, then retest.

### 8. Capture Evidence
Record:
- what changed
- what broke
- what command proved it
- what fixed it
- what validated recovery
- whether an exception is needed

## Common Break/Fix Scenarios

### Scenario 1: SSH Access Breaks After Hardening

#### Symptom
Users cannot connect remotely after hardening is applied.

#### Triage
```bash
systemctl status sshd
journalctl -u sshd -n 100 --no-pager
sshd -t
ss -tulpn | grep :22
firewall-cmd --list-all
```

#### Common Causes
- invalid `sshd_config`
- root login disabled unexpectedly
- key-based auth assumptions changed
- crypto restrictions break older clients
- firewall no longer allows SSH
- SELinux denial for nonstandard config path

#### Validation
- SSH daemon is active
- config test passes
- port 22 is listening
- intended login path works
- logs are clean after restart

### Scenario 2: Service Fails After Permissions Tighten

#### Symptom
A service that previously worked now fails on restart.

#### Triage
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
ls -l /path/to/config
namei -l /path/to/config
id <service-account>
```

#### Common Causes
- service account can no longer read config
- parent directory permissions block traversal
- runtime path is not writable
- log or PID file location is too restrictive

#### Validation
- service account can access required path
- service starts cleanly
- logs no longer show permission errors

### Scenario 3: SELinux Denial After App Path Change

#### Symptom
Service starts incorrectly or application behavior fails even though Unix permissions look correct.

#### Triage
```bash
getenforce
ausearch -m avc -ts recent
restorecon -Rv /path/to/content
```

#### Common Causes
- content moved to nonstandard path
- file context not restored
- app behavior exceeds allowed type policy

#### Validation
- AVC denials stop appearing
- app behaves normally
- corrective action is documented

### Scenario 4: Service Is Active but Users Still Cannot Reach It

#### Symptom
`systemctl` shows active, but users still report outage.

#### Triage
```bash
systemctl status <service>
ss -tulpn
curl -I http://localhost
firewall-cmd --list-all
```

#### Common Causes
- firewall blocks traffic
- service bound only to localhost
- upstream dependency broken
- health path works locally but not remotely

#### Validation
- app responds locally and remotely as expected
- required ports are open
- logs show healthy requests

## Exception and Compliance Thinking
Sometimes the correct answer is not “disable the hardening.” It is:

- document the exact operational requirement
- define the security impact
- propose a narrow compensating control
- document an exception if required

Examples:
- allow a required service account path with tighter scoped permission rather than broad access
- allow one required port instead of opening a wide range
- restore correct SELinux context instead of disabling enforcement

## Minimum Evidence Checklist
For each hardening-related issue, capture:

- service status output
- key log lines
- denial evidence if present
- the corrective action
- post-fix validation output
- exception or compensating-control note if needed

## Quick Runbook
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
journalctl -xe
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
ss -tulpn
ls -l /path/to/file
id <service-account>
```