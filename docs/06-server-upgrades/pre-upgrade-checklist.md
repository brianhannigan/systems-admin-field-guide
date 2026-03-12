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