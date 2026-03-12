param(
    [string]$RepoPath = "C:\Users\BrianH\Documents\0000 - Portfolio\systems-admin-field-guide"
)

$ErrorActionPreference = "Stop"

function Write-Section {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor $Color
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Directory -Path $parent
    }

    [System.IO.File]::WriteAllText(
        $Path,
        $Content,
        (New-Object System.Text.UTF8Encoding($false))
    )
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

$linuxPath   = Join-Path $RepoPath "docs\02-linux-admin"
$azurePath   = Join-Path $RepoPath "docs\04-azure"
$upgradePath = Join-Path $RepoPath "docs\06-server-upgrades"
$vulnPath    = Join-Path $RepoPath "docs\07-vulnerability-management"

Ensure-Directory -Path $linuxPath
Ensure-Directory -Path $azurePath
Ensure-Directory -Path $upgradePath
Ensure-Directory -Path $vulnPath

Write-Section "Upgrading Linux logging"

$linuxLogging = @'
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
'@

Write-Utf8File -Path (Join-Path $linuxPath "logging.md") -Content $linuxLogging

Write-Section "Upgrading Linux security"

$linuxSecurity = @'
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
'@

Write-Utf8File -Path (Join-Path $linuxPath "security.md") -Content $linuxSecurity

Write-Section "Upgrading Azure monitoring"

$azureMonitoring = @'
# Monitoring

## Purpose
This document provides a practical Azure monitoring guide for infrastructure administrators who need to detect change, validate health, and reduce troubleshooting time.

## Why This Matters
Monitoring is not just alerting. It is how administrators answer:
- is the resource healthy?
- what changed?
- when did it start?
- is this performance, configuration, or access related?
- what evidence supports the conclusion?

## Core Azure Monitoring Components

### Azure Monitor
Central platform for metrics, alerts, and resource monitoring.

### Activity Log
Tracks management-plane events such as:
- resource creation
- deletion
- update operations
- access or policy-related changes

### Metrics
Useful for:
- CPU
- disk operations
- network traffic
- VM health trends

### Alerts
Used to trigger attention when thresholds or states are crossed.

### Log Analytics
Supports deeper query-driven troubleshooting and operational investigation.

### Diagnostic Settings
Control what data is sent to monitoring destinations.

## What to Monitor

### VM Health
- running state
- restart events
- performance trends
- availability behavior

### Administrative Change
- who changed a resource
- what was changed
- when it happened

### Performance Signals
- CPU saturation
- disk latency or throughput issues
- network spikes
- unusual restart patterns

### Security-Relevant Operations
- unexpected configuration changes
- access assignment changes
- policy or monitoring disablement
- internet exposure changes

## Useful CLI Examples

    az monitor activity-log list --max-events 20
    az monitor metrics list --resource <resource-id> --metric "Percentage CPU"
    az monitor log-analytics workspace list -o table

## Practical Monitoring Workflow

### 1. Confirm What Telemetry Exists
Before troubleshooting, know:
- are metrics enabled?
- are diagnostic settings configured?
- where do logs go?
- which alerts already exist?

### 2. Check Activity Log for Recent Changes
Useful when a working system suddenly changes behavior.

Questions:
- was the resource updated?
- was it restarted?
- did networking change?
- did IAM change?

### 3. Check Metrics for Trend or Spike
Look for:
- CPU sustained high usage
- sudden traffic drop
- performance anomalies after patching or changes

### 4. Correlate With Guest OS State
Azure monitoring is powerful, but still pair it with in-guest validation.

Examples inside the VM:

    systemctl --failed
    ss -tulpn
    df -h
    journalctl -p err -b

### 5. Review Alert Quality
An alert is only useful if it is:
- actionable
- not too noisy
- tied to meaningful behavior
- routed to the right people

## Common Monitoring Failure Patterns

### Monitoring Exists but Nobody Uses It
Symptoms:
- logs and metrics present
- team still troubleshoots blindly
- no one knows where to look first

### Too Much Noise
Symptoms:
- alerts ignored
- important signals buried
- thresholds poorly tuned

### Missing Activity Visibility
Symptoms:
- change occurred
- no one knows who did it
- no audit trail reviewed

### Health Looks Fine in Azure but App Is Broken
Symptoms:
- VM appears healthy
- service inside guest is not
- platform metrics alone are insufficient

## Validation Checklist
After adding or improving monitoring, verify:
- metrics are visible
- activity log is usable
- critical alerts are configured
- logs are retained appropriately
- the team knows how to interpret signals
- monitoring supports troubleshooting, not just dashboards

## Useful Questions During an Incident
- did something change?
- when did the issue start?
- is the resource healthy at the platform layer?
- do the metrics support the symptom?
- does the guest OS confirm the same story?

## Quick Runbook

    az monitor activity-log list --max-events 20
    az monitor metrics list --resource <resource-id> --metric "Percentage CPU"
    az monitor log-analytics workspace list -o table

    # then validate inside the VM
    systemctl --failed
    journalctl -p err -b
    ss -tulpn
    df -h
'@

Write-Utf8File -Path (Join-Path $azurePath "monitoring.md") -Content $azureMonitoring

Write-Section "Upgrading pre-upgrade checklist"

$preUpgrade = @'
# Pre-Upgrade Checklist

## Purpose
This document defines the minimum planning and validation steps that should happen before a server upgrade or major patch event.

## Why This Matters
Upgrades fail most often when hidden dependencies, ownership gaps, missing backups, or weak validation planning are ignored. A good pre-upgrade process reduces avoidable outages and makes rollback decisions easier.

## Core Questions
Before any upgrade, answer:
- what system is changing?
- what depends on it?
- who owns it?
- what is the maintenance window?
- what is the rollback path?
- how will success be validated?

## Pre-Upgrade Checklist

### Change Scope
- identify current version
- identify target version
- identify whether reboot is expected
- identify whether config changes are included
- identify whether downtime is expected

### Ownership and Communication
- confirm technical owner
- confirm business owner if needed
- notify affected stakeholders
- confirm escalation contacts
- confirm support coverage during change window

### Dependency Review
- application dependencies identified
- DNS or cert dependencies reviewed
- mount or storage dependencies reviewed
- network dependencies reviewed
- external integrations reviewed

### Backup and Recovery
- backup or snapshot confirmed
- restore point timestamp recorded
- rollback path documented
- recovery decision threshold defined

### Validation Planning
- technical validation commands prepared
- application validation steps prepared
- monitoring checks prepared
- log review plan prepared

## Linux Baseline Commands
Capture pre-change state with commands like:

    hostnamectl
    uptime
    systemctl --failed
    systemctl status <critical-service>
    journalctl -p err -b
    ss -tulpn
    df -h
    lsblk
    free -h

## Service-Specific Evidence to Capture
For critical services, record:
- service status
- process state
- bound ports
- health endpoint response
- recent logs
- package version if relevant

Examples:

    systemctl status nginx
    journalctl -u nginx -n 50 --no-pager
    curl -I http://localhost
    rpm -qa | sort | grep <package-name>

## Release Note Review
Before upgrade:
- review vendor or platform notes
- identify removed features
- identify known upgrade risks
- identify required sequencing steps

## Common Pre-Upgrade Failures
- no one identified app dependencies
- reboot impact not discussed
- backup assumed but not verified
- no baseline evidence captured
- validation steps invented after the outage begins

## Minimum Evidence Checklist
Capture:
- system name
- current version
- current service health
- backup confirmation
- maintenance window reference
- validation commands
- rollback path

## Go / No-Go Check
Do not proceed if:
- backup is unverified
- ownership is unclear
- rollback path is unknown
- validation plan is missing
- major dependencies are still unknown

## Quick Runbook

    hostnamectl
    uptime
    systemctl --failed
    systemctl status <critical-service>
    journalctl -p err -b
    ss -tulpn
    df -h
    lsblk
    free -h
'@

Write-Utf8File -Path (Join-Path $upgradePath "pre-upgrade-checklist.md") -Content $preUpgrade

Write-Section "Upgrading remediation validation"

$remediationValidation = @'
# Remediation Validation

## Purpose
This document explains how to prove that a vulnerability was actually remediated and that the remediation did not create new operational problems.

## Why This Matters
Applying a patch is not the same as validating a fix. Real remediation validation answers two questions:

1. Is the vulnerability actually fixed?
2. Did the system remain operational after the fix?

## Validation Methods

### Re-Scan
Use the scanner again where possible to confirm the finding no longer appears.

### Package or Version Validation
Confirm that the vulnerable component version changed or the vulnerable configuration is gone.

Examples:

    rpm -qa | sort
    dnf history

### Service and Functional Validation
Confirm:
- critical services still start
- expected ports are listening
- app behavior still works
- logs remain healthy

Examples:

    systemctl --failed
    systemctl status <service>
    journalctl -p err -b
    ss -tulpn
    curl -I http://localhost

### Configuration Validation
If the remediation was configuration-based rather than package-based, confirm the exact setting now matches the intended secure state.

## Practical Validation Workflow

### 1. Record the Original Finding
Capture:
- asset name
- finding identifier
- affected component
- original severity
- original evidence

### 2. Apply Patch or Mitigation
Examples:
- package update
- config hardening
- port exposure removal
- service disablement
- compensating control

### 3. Validate Technical Fix
Examples:
- package version changed
- service no longer exposed
- weak config removed
- scanner evidence changed

### 4. Validate Operational Health
Check:
- system boots cleanly
- services are healthy
- logs are clean
- app works as expected
- no new outages created

### 5. Capture Before / After Evidence
Examples:
- scan result before and after
- package version before and after
- service status output
- log output
- change ticket reference

## Linux Validation Commands

    rpm -qa | sort
    dnf history
    systemctl --failed
    systemctl status <service>
    journalctl -p err -b
    ss -tulpn
    df -h

## Common Validation Failures
- patch applied but not confirmed
- service broke after patch and no one checked
- scanner still flags issue but ticket closed anyway
- version changed but vulnerable exposure remains
- evidence not captured

## Good Validation Example
A strong remediation note should show:
- what was wrong
- what was changed
- what command proved the fix
- what command proved the system still worked
- whether the scanner confirmed closure

## Questions to Answer
- Did the finding disappear on re-scan?
- Did the version or config actually change?
- Did the service stay healthy?
- Did monitoring remain normal?
- Was evidence saved in the ticket or repo?

## Evidence Checklist
- before scan or finding details
- after scan or validation details
- package/version output
- service health output
- log review output
- ticket or change reference

## Quick Runbook

    rpm -qa | sort
    dnf history
    systemctl --failed
    systemctl status <service>
    journalctl -p err -b
    ss -tulpn
    curl -I http://localhost
'@

Write-Utf8File -Path (Join-Path $vulnPath "remediation-validation.md") -Content $remediationValidation

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\02-linux-admin\logging.md",
    "docs\02-linux-admin\security.md",
    "docs\04-azure\monitoring.md",
    "docs\06-server-upgrades\pre-upgrade-checklist.md",
    "docs\07-vulnerability-management\remediation-validation.md"
)

$missing = @()

foreach ($relativeFile in $expectedFiles) {
    $fullPath = Join-Path $RepoPath $relativeFile
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $missing += $relativeFile
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing files detected:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    throw "Validation failed."
}

Write-Host ""
Write-Host "Validation passed. The next 5 portfolio docs were upgraded successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git status"
Write-Host "git add ."
Write-Host 'git commit -m "docs: upgrade logging security monitoring pre-upgrade and remediation validation docs"'
Write-Host "git push"
