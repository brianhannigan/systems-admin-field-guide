# Scenario â€” Azure VM Fails to Deploy

## Problem
An Azure virtual machine deployment fails during provisioning or never reaches a healthy running state.

## Environment
- Azure subscription with role-based access control
- Resource group with networking dependencies
- VM deployment performed through portal, CLI, or Terraform

## Symptoms
- Deployment fails in the portal
- Provisioning state shows failed
- Extension install errors
- VM starts but is unreachable

## Investigation Steps
1. Review deployment error details in Azure Activity Log
2. Confirm subscription and resource group permissions
3. Validate VNet, subnet, NSG, and route dependencies
4. Review boot diagnostics and extension status
5. Confirm image, size, quota, and region availability
6. Validate identity, disks, and NIC configuration

## Common Root Causes
- Missing permissions
- Invalid subnet or NSG rules
- Region or SKU capacity issue
- Quota limits
- Bad image reference
- Extension failure
- Misconfigured Terraform variables

## Resolution
Document the exact fix:
- Correct the dependency or permission issue
- Re-run deployment
- Validate network and diagnostics
- Confirm VM health after deployment

## Validation
- VM reaches running state
- RDP or SSH works as expected
- Extensions show healthy
- Monitoring and backup attach successfully

## Lessons Learned
Capture what pre-checks should be added before future deployments.
