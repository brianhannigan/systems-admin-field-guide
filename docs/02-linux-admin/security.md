# Security

## Purpose
This document captures Linux security controls most relevant to system engineers working in enterprise and compliance-aware environments.

## Why This Matters
Security settings are not separate from operations. They directly affect service behavior, access, automation, patching, and recoverability. Strong administrators understand both security intent and operational impact.

## Core Areas

### User and Identity Basics
Examples:

    id username
    getent passwd username
    getent group groupname
    sudo -l
    visudo

Questions to ask:
- who owns this service or process?
- who has sudo access?
- are shared admin accounts being used?
- are service accounts documented?

### File Permissions and Ownership
Examples:

    ls -l /path/to/file
    chmod 600 /path/to/file
    chown root:root /path/to/file
    namei -l /path/to/file
    umask

Common failure points:
- config unreadable by service account
- key or cert too open or too locked down
- parent path traversal denied
- runtime directory not writable

### SSH Validation
Examples:

    cat /etc/ssh/sshd_config
    sshd -t
    systemctl status sshd
    systemctl restart sshd
    ss -tulpn | grep :22

Validate:
- intended auth path works
- daemon is active
- port is listening
- config test passes
- access restrictions are intentional

### SELinux
Examples:

    getenforce
    sestatus
    ausearch -m avc -ts recent
    restorecon -Rv /var/www/html

What to remember:
- SELinux denials often look like permission issues
- disabling SELinux is usually the wrong first move
- file context and service behavior matter

### firewalld
Examples:

    firewall-cmd --state
    firewall-cmd --list-all
    firewall-cmd --list-ports
    firewall-cmd --add-service=https --permanent
    firewall-cmd --reload

Validate:
- only required ports are open
- the correct zone is in use
- access expectations match actual rules

## Security Review Workflow

### 1. Identify the Access or Service Need
What should this user, service, or system actually be allowed to do?

### 2. Validate Current State
Check:
- account identity
- file permissions
- service ownership
- listening ports
- firewall exposure
- SELinux status

### 3. Check for Over-Permission or Under-Permission
Examples:
- overly broad sudo access
- world-readable sensitive config
- app user cannot write required path
- unnecessary public exposure

### 4. Validate Function After Security Changes
After a hardening change, confirm:
- service still starts
- user access still works as intended
- logs show no new denials
- required traffic still flows

## Common Security Failure Patterns

### SSH Hardening Breaks Access
- config syntax error
- auth method removed unexpectedly
- firewall no longer allows SSH
- key permissions invalid

### Permission Tightening Breaks Service
- config unreadable
- log path unwritable
- PID path blocked
- cert file ownership wrong

### SELinux Blocks Legitimate App Behavior
- content moved to nonstandard path
- app writes to unexpected location
- service context mismatch

### Firewall Configuration Blocks Needed Traffic
- NSG or guest firewall assumptions do not match
- allowed service not reloaded
- wrong zone used

## Security Validation Checklist
- users have only needed access
- sudo use is justified
- service files have correct ownership and mode
- required ports are open, unnecessary ports are closed
- SELinux and firewall behavior are understood
- changes are documented

## Quick Runbook

    id username
    sudo -l
    ls -l /path/to/file
    namei -l /path/to/file
    cat /etc/ssh/sshd_config
    sshd -t
    getenforce
    ausearch -m avc -ts recent
    firewall-cmd --list-all
    ss -tulpn