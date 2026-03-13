[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Cyan
}

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
    else {
        Write-Host "Directory exists: $Path" -ForegroundColor DarkGray
    }
}

function Ensure-File {
    param(
        [string]$Path,
        [string]$Content
    )

    if ((Test-Path -LiteralPath $Path) -and -not $Force) {
        Write-Host "File exists, skipped: $Path" -ForegroundColor DarkGray
        return
    }

    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Directory -Path $parent
    }

    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    Write-Host "Wrote file: $Path" -ForegroundColor Green
}

function Upsert-ReadmeSection {
    param(
        [string]$ReadmePath,
        [string]$Header,
        [string]$SectionContent
    )

    $content = Get-Content -LiteralPath $ReadmePath -Raw

    $escapedHeader = [regex]::Escape($Header)
    $pattern = "(?ms)^$escapedHeader\s*$.*?(?=^##\s|\z)"

    if ([regex]::IsMatch($content, $pattern)) {
        $updated = [regex]::Replace($content, $pattern, ($SectionContent.Trim() + "`r`n"))
        Set-Content -LiteralPath $ReadmePath -Value $updated -Encoding UTF8
        Write-Host "Updated README section: $Header" -ForegroundColor Green
        return
    }

    $updated = $content.TrimEnd() + "`r`n`r`n" + $SectionContent.Trim() + "`r`n"
    Set-Content -LiteralPath $ReadmePath -Value $updated -Encoding UTF8
    Write-Host "Added README section: $Header" -ForegroundColor Green
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoRoot)) {
    throw "RepoRoot does not exist: $RepoRoot"
}

$readmePath = Join-Path $RepoRoot "README.md"
if (-not (Test-Path -LiteralPath $readmePath)) {
    throw "README.md not found at: $readmePath"
}

Write-Host "Repository root validated: $RepoRoot" -ForegroundColor Green

Write-Section "Ensuring target folders exist"

$folders = @(
    "docs/scenarios",
    "docs/playbooks",
    "docs/reference"
)

foreach ($folder in $folders) {
    Ensure-Directory -Path (Join-Path $RepoRoot $folder)
}

Write-Section "Creating scenario documents"

$scenarioAzureVmDeploy = @"
# Scenario — Azure VM Fails to Deploy

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
"@

$scenarioTerraformDrift = @"
# Scenario — Terraform Drift Detected

## Problem
The deployed infrastructure no longer matches the Terraform configuration or state.

## Environment
- Azure resources managed with Terraform
- Shared engineering environment
- State stored locally or remotely

## Symptoms
- terraform plan shows unexpected changes
- Resources differ from expected naming, tags, or settings
- Manual portal changes were made outside code

## Investigation Steps
1. Run terraform plan and capture proposed changes
2. Compare state with actual deployed resources
3. Review recent portal, CLI, or script-based changes
4. Confirm workspace and backend configuration
5. Identify whether drift should be adopted or reverted

## Common Root Causes
- Manual changes in portal
- Wrong workspace or backend
- State corruption or partial apply
- Configuration drift after hotfixes
- Resource import never completed

## Resolution
Document the chosen path:
- Reconcile code to match approved reality
- Revert manual changes to match code
- Import resources into state when needed
- Re-run plan and apply carefully

## Validation
- terraform plan returns expected output
- State matches deployed resources
- Team agrees on source of truth
- Change history is documented

## Lessons Learned
Capture how to reduce future drift through process and automation.
"@

$scenarioVulnRemediation = @"
# Scenario — Vulnerability Remediation Workflow

## Problem
A vulnerability scan identifies findings that must be remediated without breaking system functionality.

## Environment
- Hardened Linux or Windows system
- Vulnerability management workflow
- Compliance-sensitive environment

## Symptoms
- Scanner flags missing patches or insecure configuration
- Findings appear critical or high severity
- Remediation may impact services or users

## Investigation Steps
1. Validate the finding is accurate
2. Identify the asset owner and system function
3. Check patch availability or configuration guidance
4. Assess operational risk before change
5. Schedule remediation window if needed
6. Implement fix with rollback plan prepared

## Common Root Causes
- Missing security patches
- Weak service configuration
- Unapproved legacy settings
- Drift from baseline
- Incomplete hardening after upgrades

## Resolution
Document the remediation path:
- Patch
- Reconfigure
- Compensating control
- Risk acceptance through formal process

## Validation
- Service functionality remains intact
- Follow-up scan confirms closure
- Documentation and evidence are updated

## Lessons Learned
Capture how the finding could have been prevented earlier.
"@

Ensure-File -Path (Join-Path $RepoRoot "docs/scenarios/azure-vm-fails-to-deploy.md") -Content $scenarioAzureVmDeploy
Ensure-File -Path (Join-Path $RepoRoot "docs/scenarios/terraform-drift-detected.md") -Content $scenarioTerraformDrift
Ensure-File -Path (Join-Path $RepoRoot "docs/scenarios/vulnerability-remediation-workflow.md") -Content $scenarioVulnRemediation

Write-Section "Creating playbook documents"

$playbookSshFailure = @"
# Playbook — SSH Access Failure

## Symptoms
- SSH connection refused
- Timeout during connection
- Authentication fails unexpectedly
- Administrative access lost after hardening or change

## Initial Checks
1. Confirm hostname and target IP
2. Confirm system is powered on and reachable
3. Validate DNS resolution
4. Confirm no active maintenance window
5. Confirm jump host or VPN path is healthy

## Commands

~~~bash
ping <host>
nslookup <host>
traceroute <host>
nc -zv <host> 22
systemctl status sshd
journalctl -u sshd -n 100
ss -tulpn | grep :22
cat /etc/ssh/sshd_config
getenforce
firewall-cmd --list-all
~~~

## Investigation
- sshd service stopped
- Port 22 blocked by firewall or NSG
- Invalid sshd_config change
- SELinux blocking access
- Broken PAM or auth settings
- Network path issue

## Resolution
Document the exact fix here.

## Verification
- SSH login works with approved methods
- Logs show successful authentication
- Security posture remains intact
- Monitoring returns to normal
"@

$playbookServiceCrash = @"
# Playbook — Service Crash or Repeated Restart Failure

## Symptoms
- Service fails to start
- systemd shows restart loop
- Application unavailable
- Monitoring alerts on process failure

## Initial Checks

~~~bash
systemctl status <service>
journalctl -u <service> -n 200
ps -ef | grep <service>
ss -tulpn
df -h
free -h
top
~~~

## Investigation
- Bad configuration file
- Port binding conflict
- Missing dependency
- Permission issue
- Disk full or memory pressure
- Package or library mismatch

## Resolution
Document the exact fix here.

## Verification
- Service starts successfully
- Port is listening
- Application health checks pass
- Logs show stable operation
"@

$playbookAzureVmFailure = @"
# Playbook — Azure VM Failure

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
"@

Ensure-File -Path (Join-Path $RepoRoot "docs/playbooks/ssh-access-failure.md") -Content $playbookSshFailure
Ensure-File -Path (Join-Path $RepoRoot "docs/playbooks/service-crash-or-restart-failure.md") -Content $playbookServiceCrash
Ensure-File -Path (Join-Path $RepoRoot "docs/playbooks/azure-vm-failure.md") -Content $playbookAzureVmFailure

Write-Section "Creating reference documents"

$commandReference = @"
# Systems Engineer Command Reference

This document collects high-value commands for everyday systems engineering work.

## Linux Service and Health Checks

~~~bash
hostnamectl
uname -a
ip addr
ip route
ss -tulpn
systemctl status <service>
journalctl -u <service> -n 100
df -h
free -h
top
ps -ef
~~~

## Linux Troubleshooting

~~~bash
ping <host>
nslookup <host>
traceroute <host>
curl -v http://<host>:<port>
nc -zv <host> <port>
getenforce
firewall-cmd --list-all
last
who
~~~

## Windows Operations

~~~powershell
Get-Service
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20
Get-Volume
Get-EventLog -LogName System -Newest 100
Get-WinEvent -LogName Security -MaxEvents 50
Test-NetConnection <host> -Port 3389
Get-NetIPAddress
Get-NetRoute
Restart-Service -Name <service>
~~~

## Azure CLI

~~~bash
az login
az account show
az group list -o table
az vm list -o table
az vm show --resource-group <rg> --name <vm> -o json
az vm get-instance-view --resource-group <rg> --name <vm>
az resource list -o table
az monitor activity-log list --max-events 20
~~~

## Terraform

~~~bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform show
terraform output
terraform state list
terraform refresh
~~~

## Security and Compliance

~~~bash
oscap xccdf eval ...
oscap xccdf generate report ...
nessuscli ...
rpm -qa
yum check-update
dnf check-update
~~~

## Usage Notes
- Capture outputs during incident review and change validation
- Prefer approved bastions, jump hosts, and admin workstations
- Document command usage when a fix is applied in production
"@

$scenarioIndex = @"
# Scenario Index

Use these scenario documents to practice real-world issue investigation and resolution.

## Current Scenarios
- [Azure VM Fails to Deploy](azure-vm-fails-to-deploy.md)
- [Terraform Drift Detected](terraform-drift-detected.md)
- [Vulnerability Remediation Workflow](vulnerability-remediation-workflow.md)

## Existing / Earlier Scenarios
Add links here for any earlier scenario files already present in this folder.
"@

$playbookIndex = @"
# Playbook Index

Use these playbooks for repeatable troubleshooting and recovery workflows.

## Current Playbooks
- [SSH Access Failure](ssh-access-failure.md)
- [Service Crash or Restart Failure](service-crash-or-restart-failure.md)
- [Azure VM Failure](azure-vm-failure.md)

## Existing / Earlier Playbooks
Add links here for any earlier playbook files already present in this folder.
"@

Ensure-File -Path (Join-Path $RepoRoot "docs/reference/systems-engineer-command-reference.md") -Content $commandReference
Ensure-File -Path (Join-Path $RepoRoot "docs/scenarios/README.md") -Content $scenarioIndex
Ensure-File -Path (Join-Path $RepoRoot "docs/playbooks/README.md") -Content $playbookIndex

Write-Section "Updating README navigation"

$scenarioReadmeSection = @"
## Real Infrastructure Scenarios

These scenarios are designed to show how practical systems engineering problems unfold in enterprise and government-style environments.

- [Scenario Index](docs/scenarios/README.md)
- [Azure VM Fails to Deploy](docs/scenarios/azure-vm-fails-to-deploy.md)
- [Terraform Drift Detected](docs/scenarios/terraform-drift-detected.md)
- [Vulnerability Remediation Workflow](docs/scenarios/vulnerability-remediation-workflow.md)
"@

$playbookReadmeSection = @"
## Troubleshooting Playbooks

These playbooks provide repeatable operational procedures for common failures and recovery workflows.

- [Playbook Index](docs/playbooks/README.md)
- [SSH Access Failure](docs/playbooks/ssh-access-failure.md)
- [Service Crash or Restart Failure](docs/playbooks/service-crash-or-restart-failure.md)
- [Azure VM Failure](docs/playbooks/azure-vm-failure.md)
"@

$referenceReadmeSection = @"
## Example Command Reference

Use this command reference as a quick operational aid during live troubleshooting, validation, and remediation work.

- [Systems Engineer Command Reference](docs/reference/systems-engineer-command-reference.md)
- [Systems Engineer Cheat Sheet](docs/reference/systems-engineer-cheat-sheet.md)
"@

Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Real Infrastructure Scenarios" -SectionContent $scenarioReadmeSection
Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Troubleshooting Playbooks" -SectionContent $playbookReadmeSection
Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Example Command Reference" -SectionContent $referenceReadmeSection

Write-Section "Complete"

Write-Host "Scenarios, playbooks, and reference docs added." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoRoot`""
Write-Host "git status"
Write-Host "git add README.md docs tools"
Write-Host "git commit -m `"docs: add scenarios playbooks and command reference`""
Write-Host "git push"