# Azure Networking

## Purpose
This document provides a practical troubleshooting and validation guide for Azure networking as used by systems engineers supporting virtual machines and connected services.

## Why This Matters
Many â€œserver problemsâ€ are really network path problems. Azure networking issues often come down to one of these layers:

- wrong VNet or subnet
- NSG rule mismatch
- route table behavior
- NIC or public IP assumptions
- app binding issue inside the VM

## Core Azure Networking Components

### Virtual Network (VNet)
Defines the address space and logical network boundary.

### Subnet
A segment inside a VNet where resources are placed.

### Network Security Group (NSG)
Controls inbound and outbound traffic using rules.

### Network Interface (NIC)
Connects a VM to the network.

### Public IP
Provides public reachability when intentionally assigned.

### Route Table
Controls traffic flow beyond default routing.

## First Questions to Ask
- What VNet is the VM in?
- What subnet is the VM in?
- Is there an NSG on the NIC, subnet, or both?
- Does the VM need public access?
- Is the application actually listening inside the guest?
- Is there a custom route table affecting traffic?

## Useful CLI Commands
```bash
az network vnet list -o table
az network vnet subnet list --resource-group MyRg --vnet-name MyVnet -o table
az network nsg list -o table
az network nic list -o table
az vm list -o table
```

## Practical Troubleshooting Workflow

### 1. Confirm the VM Is Running
If the VM itself is down, network troubleshooting is secondary.

```bash
az vm list -o table
```

### 2. Confirm the NIC and IP Assignment
Validate:
- NIC exists
- correct subnet
- expected private IP
- public IP only if intended

### 3. Review NSG Rules
Check whether the required port is actually allowed.

Questions:
- Is inbound allowed from the correct source?
- Is outbound blocked unexpectedly?
- Are you troubleshooting the NIC NSG, subnet NSG, or both?

### 4. Review Routing
If custom route tables exist, make sure traffic is not being redirected unexpectedly.

### 5. Validate Guest OS Listening State
Even if Azure is open, the service still must be listening.

Inside the VM:
```bash
ss -tulpn
firewall-cmd --list-all
curl -I http://localhost
```

### 6. Distinguish Azure Network Issue vs Guest Issue
A common mistake is blaming Azure for a service that is not actually listening or is blocked by the guest firewall.

## Common Failure Patterns

### NSG Blocks Expected Traffic
Symptoms:
- VM reachable internally but not from expected source
- health checks fail from outside
- service works locally

### Wrong Subnet or VNet
Symptoms:
- expected peers cannot reach the VM
- route assumptions are wrong
- DNS or dependency reachability fails

### Public Exposure Assumption Error
Symptoms:
- admin expects public access but no public IP exists
- public IP exists but should not

### Guest Service Not Listening
Symptoms:
- Azure path is open
- app still unavailable
- local checks show no bound port

### Guest Firewall Blocks Traffic
Symptoms:
- NSG looks correct
- port is listening
- guest OS firewall blocks access

## Validation Checklist
After a fix, validate:
- correct VNet and subnet
- correct NIC and IP configuration
- correct NSG rules
- expected route behavior
- service listening in guest
- intended local and remote path works

## Example Investigation Pattern
1. Check VM state
2. Check NIC and IP
3. Check NSGs
4. Check routing
5. Check guest OS listener
6. Check guest firewall
7. Validate actual application response

## Quick Runbook
```bash
az vm list -o table
az network nic list -o table
az network nsg list -o table
# inside VM
ss -tulpn
firewall-cmd --list-all
curl -I http://localhost
```
