# VM Deployment

## Purpose
Document the process for deploying, validating, and managing Azure virtual machines.

## Core Topics
- Resource group selection
- Region selection
- VM sizing
- OS image choice
- Disk type selection
- Public vs private access
- Admin access method
- Tagging and naming standards

## Portal Workflow
1. Create or select a resource group
2. Choose the VM name and region
3. Select the image and size
4. Configure admin account or SSH key
5. Configure networking
6. Review disks
7. Review management settings
8. Validate before creation
9. Deploy and confirm health

## Azure CLI Examples
```bash
az vm list -o table
az vm show --name MyVm --resource-group MyRg
az vm start --name MyVm --resource-group MyRg
az vm stop --name MyVm --resource-group MyRg
az vm restart --name MyVm --resource-group MyRg
```

## Validation Checklist
- VM exists in correct resource group
- Naming is correct
- Region is correct
- Expected IP and NIC are attached
- Access works
- Boot diagnostics or health indicators are clean

## Common Problems
- Wrong subnet or NSG attached
- Incorrect VM size
- Login method misconfigured
- Public IP assigned when it should not be
- Missing tags or naming standard
