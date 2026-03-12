# Security Controls

## Purpose
Capture the Azure security controls most important for secure systems administration.

## Core Areas
- Network Security Groups
- Azure Policy
- Defender for Cloud
- Identity controls
- Resource exposure review
- Baseline configuration standards

## Questions to Ask
- What resources are internet-exposed?
- Are policies enforcing standards?
- Is Defender enabled?
- Are NSGs restrictive enough?
- Are admin accounts protected?
- Are there configuration drifts from standard?

## Azure CLI Examples
```bash
az policy assignment list -o table
az security pricing list -o table
az resource list --query "[].{Name:name,Type:type,Group:resourceGroup}" -o table
```

## Validation Checklist
- Security controls are enabled and understood
- Internet exposure is intentional
- Policies align with standards
- High-risk findings are tracked
- Admin access is controlled

## Common Problems
- Unrestricted NSG rules
- Resources deployed outside standard policy
- Defender recommendations ignored
- Public exposure not documented
