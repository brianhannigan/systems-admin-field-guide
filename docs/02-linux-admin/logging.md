# Logging

## Purpose
This document provides a practical log review workflow for service failures, upgrades, security validation, and post-change troubleshooting.

## Why This Matters
Logs are where systems tell the truth. Strong administrators do not guess when something breaks. They correlate service state, recent changes, timestamps, and log evidence to move from symptom to root cause.

## Primary Log Sources on Linux

### systemd Journal
Most modern Linux distributions use the journal as the primary structured source for service and system logs.

Examples:

    journalctl
    journalctl -u sshd
    journalctl -u nginx -n 50 --no-pager
    journalctl --since "1 hour ago"
    journalctl -p err -b
    journalctl -xe

### Traditional Log Files
Common paths:
- `/var/log/messages`
- `/var/log/secure`
- `/var/log/audit/audit.log`
- application-specific log locations

Examples:

    tail -f /var/log/messages
    tail -f /var/log/secure
    grep -i error /var/log/messages
    grep -i denied /var/log/audit/audit.log

### Kernel and Boot Messages
Useful for hardware, storage, or boot-time issues.

Examples:

    dmesg
    journalctl -b
    journalctl -p err -b

## Practical Log Review Workflow

### 1. Identify the Symptom
Before reading logs, define what actually failed:
- service will not start
- service restarts repeatedly
- app is active but unhealthy
- user cannot authenticate
- port is not listening
- system slow or unstable after patching

### 2. Anchor the Time Window
Always narrow the investigation:
- when did the problem start?
- what changed recently?
- was there a reboot, patch, config edit, or policy change?

Useful examples:

    journalctl --since "2026-03-12 09:00:00"
    journalctl --since "30 minutes ago"

### 3. Review Service-Specific Logs First
Start with the service in question before widening scope.

Examples:

    journalctl -u nginx -n 100 --no-pager
    journalctl -u sshd -n 100 --no-pager
    journalctl -u firewalld -n 100 --no-pager

### 4. Widen to System Context
If the service logs are not enough, widen to:
- general errors
- boot failures
- kernel messages
- authentication activity
- audit denials

Examples:

    journalctl -p err -b
    journalctl -xe
    dmesg | tail -50

### 5. Correlate With Current State
Logs are more useful when paired with service and system state.

Examples:

    systemctl status <service>
    ss -tulpn
    df -h
    free -h

## Common Log Review Scenarios

### Scenario 1: Service Fails After Config Change
Use:

    systemctl status nginx
    journalctl -u nginx -n 100 --no-pager
    nginx -t

Look for:
- syntax error
- permission denied
- missing file
- bad certificate path
- bind error

### Scenario 2: SSH Access Stops Working
Use:

    systemctl status sshd
    journalctl -u sshd -n 100 --no-pager
    tail -f /var/log/secure

Look for:
- failed login attempts
- rejected auth methods
- invalid config lines
- host key or permission problems

### Scenario 3: Post-Patch Instability
Use:

    journalctl -p err -b
    systemctl --failed
    journalctl --since "1 hour ago"

Look for:
- failed units after reboot
- dependency failures
- package-related warnings
- new services starting incorrectly

### Scenario 4: SELinux or Security Denials
Use:

    ausearch -m avc -ts recent
    grep -i denied /var/log/audit/audit.log

Look for:
- denied file access
- blocked process behavior
- policy mismatch after app or path change

### Scenario 5: Disk or Resource Pressure
Use:

    df -h
    dmesg | tail -50
    journalctl -p err -b

Look for:
- filesystem full conditions
- write failures
- out-of-memory events
- service restart loops caused by resource starvation

## What Good Log Analysis Looks Like
Good log analysis:
- narrows time window
- starts with the affected service
- correlates with real system state
- identifies cause, not just noise
- captures evidence for documentation

Bad log analysis:
- reading everything with no time window
- restarting before checking logs
- fixing based on assumption instead of evidence
- failing to capture the relevant lines

## Evidence to Capture
For useful troubleshooting notes, record:
- exact command used
- key log lines
- relevant timestamp
- related service state
- what changed before the issue
- what fixed the problem
- how success was validated

## Minimum Validation Pattern
After a fix, check:

    systemctl status <service>
    journalctl -u <service> -n 20 --no-pager
    ss -tulpn
    curl -I http://localhost

## Quick Runbook

    systemctl status <service>
    journalctl -u <service> -n 100 --no-pager
    journalctl -xe
    journalctl -p err -b
    tail -f /var/log/messages
    tail -f /var/log/secure