# Azure Networking

## Purpose
Provide a practical guide for understanding and validating Azure network configuration.

## Core Concepts
- Virtual Networks (VNets)
- Subnets
- Network Security Groups (NSGs)
- Route tables
- Public IP addresses
- Private IP addressing
- NIC associations

## What to Check First
- What VNet is the VM in?
- What subnet is it attached to?
- Is there an NSG on the NIC, subnet, or both?
- Does it need public access?
- Are routing rules affecting reachability?

## Azure CLI Examples
```bash
az network vnet list -o table
az network vnet subnet list --resource-group MyRg --vnet-name MyVnet -o table
az network nsg list -o table
az network nic list -o table
```

## Troubleshooting Workflow
1. Confirm the VM is running
2. Confirm the NIC is attached correctly
3. Confirm IP addressing
4. Review NSG rules
5. Review subnet and route configuration
6. Test expected connectivity
7. Confirm service is listening on the VM

## Validation Checklist
- VM is attached to intended VNet/subnet
- NSG rules permit expected traffic only
- Routing is understood
- Required ports are reachable
- Unnecessary exposure is avoided

## Common Problems
- NSG blocks required traffic
- Wrong subnet assignment
- Misunderstood public/private access
- Route table causes path issue
- App is down even though network path is open
