# Playbook â€” Azure VM Failure

## Symptoms
- VM unavailable
- Boot failure
- Network unreachable
- Extension or provisioning error
- Guest OS appears unhealthy

## Initial Checks

~~~bash
az vm list -o table
az vm show --resource-group <rg> --name <vm> -o json
az vm get-instance-view --resource-group <rg> --name <vm>
az network nic list --resource-group <rg> -o table
az monitor activity-log list --resource-group <rg> --max-events 20
~~~

## Investigation
- Provisioning failure
- Disk attachment issue
- NSG rule blocking access
- Route table issue
- Extension failure
- Identity or permission problem

## Resolution
Document the exact fix here.

## Verification
- VM reaches healthy running state
- Access path works
- Monitoring and diagnostics are healthy
- Extensions succeed
