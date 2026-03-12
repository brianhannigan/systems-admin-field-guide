# Monitoring

## Purpose
Document the Azure monitoring tools and workflows most relevant to infrastructure administration.

## Core Components
- Azure Monitor
- Activity Log
- Metrics
- Alerts
- Log Analytics
- Diagnostic settings

## What to Monitor
- VM health
- CPU and memory trends
- Disk performance
- Network metrics
- Restart events
- Administrative changes
- Failed login or access anomalies where applicable

## Azure CLI Examples
```bash
az monitor metrics list --resource <resource-id> --metric "Percentage CPU"
az monitor activity-log list --max-events 20
az monitor log-analytics workspace list -o table
```

## Operational Workflow
1. Confirm what telemetry is enabled
2. Review recent alerts
3. Review activity logs for admin changes
4. Review performance data
5. Correlate system symptoms with Azure events
6. Capture findings and next actions

## Validation Checklist
- Monitoring is enabled where needed
- Alerts are actionable
- Noise is reduced
- Logs are retained appropriately
- Ops team knows where to look first

## Common Problems
- Monitoring not enabled
- Too many noisy alerts
- Metrics available but unused
- No retention or unclear ownership
