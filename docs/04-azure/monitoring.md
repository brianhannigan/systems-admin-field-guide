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