$ErrorActionPreference = 'Stop'

Write-Host "`n=== Phase 5 direct repair starting ===" -ForegroundColor Cyan

$dirs = @(
    "docs\case-studies",
    "docs\labs",
    "docs\scripts",
    "docs\reference"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Green
    }
    else {
        Write-Host "Directory exists: $dir" -ForegroundColor DarkGray
    }
}

Set-Content -Path "docs\case-studies\stig-remediation-project.md" -Encoding UTF8 -Value @"
# Case Study — STIG Remediation Project

## Problem
A hardened environment required security remediation without breaking administrative access, monitoring, or service health.

## Environment
- Linux and/or Windows systems
- Compliance-focused environment
- Formal validation expectations
- Vulnerability remediation workflow in place

## Goals
- Improve compliance posture
- Reduce open findings
- Preserve service availability
- Produce reusable evidence

## Approach
1. Review findings by operational risk
2. Identify controls affecting access, services, and logging
3. Sequence remediation safely
4. Validate after each change group
5. Capture closure evidence
6. Update runbooks and exceptions

## Outcome
Document results such as reduced findings, better validation discipline, and fewer repeat issues.

## Lessons Learned
Hardening must be paired with service validation and evidence collection.
"@
Write-Host "Wrote docs\case-studies\stig-remediation-project.md" -ForegroundColor Green

Set-Content -Path "docs\case-studies\server-upgrade-lifecycle.md" -Encoding UTF8 -Value @"
# Case Study — Server Upgrade Lifecycle

## Problem
A server needed a major upgrade while preserving service continuity and minimizing rollback risk.

## Environment
- Enterprise or government-managed server
- Maintenance window required
- Monitoring and validation in place

## Goals
- Complete the upgrade safely
- Preserve service availability
- Validate logs, services, and dependencies
- Improve future upgrade repeatability

## Approach
1. Capture pre-change state
2. Validate prerequisites
3. Execute upgrade in a controlled window
4. Validate service health and logs
5. Confirm monitoring and security tooling health
6. Record lessons learned

## Outcome
Document improvements in supportability, consistency, and operational confidence.

## Lessons Learned
Structured validation is more reliable than ad hoc testing.
"@
Write-Host "Wrote docs\case-studies\server-upgrade-lifecycle.md" -ForegroundColor Green

Set-Content -Path "docs\case-studies\terraform-deployment-standardization.md" -Encoding UTF8 -Value @"
# Case Study — Terraform Deployment Standardization

## Problem
Cloud deployments were inconsistent across environments, increasing drift and troubleshooting effort.

## Environment
- Azure resources
- Terraform-managed infrastructure
- Shared engineering ownership

## Goals
- Standardize deployments
- Reduce manual changes
- Improve auditability
- Strengthen validation after apply

## Approach
1. Define reusable modules
2. Standardize variables, tags, and naming
3. Run fmt, validate, and plan
4. Apply through a repeatable workflow
5. Validate deployed resources
6. Monitor for drift

## Outcome
Document gains in consistency, predictability, and troubleshooting speed.

## Lessons Learned
Drift control requires process discipline as much as tooling.
"@
Write-Host "Wrote docs\case-studies\terraform-deployment-standardization.md" -ForegroundColor Green

Set-Content -Path "docs\labs\stig-hardening-validation.md" -Encoding UTF8 -Value @"
# Lab — STIG Hardening Validation

## Objective
Practice validating whether a hardening change improves compliance without breaking access or services.

## Environment
- RHEL lab VM
- SSH access
- Logging enabled

## Steps
1. Record current access and service state
2. Apply a controlled hardening-related change
3. Validate SSH, service health, and logs
4. Review impact
5. Roll back or document final safe state

## Validation
- SSH still works
- Service remains available
- Logs are acceptable
- Compliance position improves or is clearly understood
"@
Write-Host "Wrote docs\labs\stig-hardening-validation.md" -ForegroundColor Green

Set-Content -Path "docs\labs\terraform-azure-deployment-validation.md" -Encoding UTF8 -Value @"
# Lab — Terraform Azure Deployment Validation

## Objective
Practice a clean Terraform workflow and validate deployed Azure resources.

## Environment
- Azure lab subscription
- Terraform installed
- Isolated non-production scope

## Steps
1. Authenticate to Azure
2. Run terraform fmt
3. Run terraform validate
4. Run terraform plan
5. Run terraform apply
6. Validate deployed resources
7. Re-run plan to confirm expected state

## Validation
- Resources deploy successfully
- Plan output is clean or expected
- Naming and tags are correct
"@
Write-Host "Wrote docs\labs\terraform-azure-deployment-validation.md" -ForegroundColor Green

Set-Content -Path "docs\labs\linux-monitoring-and-log-validation.md" -Encoding UTF8 -Value @"
# Lab — Linux Monitoring and Log Validation

## Objective
Practice validating service health, logs, and host state after a change or restart.

## Environment
- Linux VM
- systemd-managed service

## Steps
1. Check service status
2. Review recent logs
3. Restart the service
4. Confirm healthy recovery
5. Validate port listening and connectivity
6. Capture evidence

## Validation
- Service starts cleanly
- Logs do not show major new errors
- Required port is listening
"@
Write-Host "Wrote docs\labs\linux-monitoring-and-log-validation.md" -ForegroundColor Green

Set-Content -Path "docs\labs\README.md" -Encoding UTF8 -Value @"
# Lab Index

- [STIG Hardening Validation](stig-hardening-validation.md)
- [Terraform Azure Deployment Validation](terraform-azure-deployment-validation.md)
- [Linux Monitoring and Log Validation](linux-monitoring-and-log-validation.md)
"@
Write-Host "Wrote docs\labs\README.md" -ForegroundColor Green

Set-Content -Path "docs\scripts\upgrade-readme-systems-engineer-priority-1.md" -Encoding UTF8 -Value @"
# Script Doc — upgrade-readme-systems-engineer-priority-1.ps1

## Purpose
Improves the README so the repository becomes easier to navigate and understand.

## Usage

~~~powershell
.\tools\upgrade-readme-systems-engineer-priority-1.ps1
~~~
"@
Write-Host "Wrote docs\scripts\upgrade-readme-systems-engineer-priority-1.md" -ForegroundColor Green

Set-Content -Path "docs\scripts\add-scenarios-playbooks-and-reference.md" -Encoding UTF8 -Value @"
# Script Doc — add-scenarios-playbooks-and-reference.ps1

## Purpose
Adds scenarios, playbooks, and command reference material.

## Usage

~~~powershell
.\tools\add-scenarios-playbooks-and-reference.ps1
~~~
"@
Write-Host "Wrote docs\scripts\add-scenarios-playbooks-and-reference.md" -ForegroundColor Green

Set-Content -Path "docs\scripts\add-security-metrics-and-architecture.md" -Encoding UTF8 -Value @"
# Script Doc — add-security-metrics-and-architecture.ps1

## Purpose
Adds workflow, metrics, and architecture guidance.

## Usage

~~~powershell
.\tools\add-security-metrics-and-architecture.ps1
~~~
"@
Write-Host "Wrote docs\scripts\add-security-metrics-and-architecture.md" -ForegroundColor Green

Set-Content -Path "docs\scripts\script-documentation-template.md" -Encoding UTF8 -Value @"
# Script Documentation Template

## Purpose
Describe what the script does and why it exists.

## Usage

~~~powershell
.\tools\script-name.ps1
~~~
"@
Write-Host "Wrote docs\scripts\script-documentation-template.md" -ForegroundColor Green

Set-Content -Path "docs\reference\systems-engineer-cheat-sheet.md" -Encoding UTF8 -Value @"
# Systems Engineer Cheat Sheet

## Linux Quick Commands

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

## Windows Quick Checks

~~~powershell
Get-Service
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20
Get-Volume
Get-EventLog -LogName System -Newest 50
Test-NetConnection <host> -Port 3389
~~~

## Azure Quick Commands

~~~bash
az login
az account show
az group list -o table
az vm list -o table
az vm show --resource-group <rg> --name <vm> -o json
~~~

## Terraform Quick Commands

~~~bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
~~~
"@
Write-Host "Wrote docs\reference\systems-engineer-cheat-sheet.md" -ForegroundColor Green

$readme = Get-Content -Path "README.md" -Raw

function Upsert-Section {
    param(
        [string]$Content,
        [string]$Header,
        [string]$Body
    )
    $escaped = [regex]::Escape($Header)
    $pattern = "(?ms)^$escaped\s*$.*?(?=^##\s|\z)"
    if ([regex]::IsMatch($Content, $pattern)) {
        return [regex]::Replace($Content, $pattern, ($Body.Trim() + "`r`n"))
    }
    return ($Content.TrimEnd() + "`r`n`r`n" + $Body.Trim() + "`r`n")
}

$readme = Upsert-Section -Content $readme -Header "## Case Studies" -Body @"
## Case Studies

- [STIG Remediation Project](docs/case-studies/stig-remediation-project.md)
- [Server Upgrade Lifecycle](docs/case-studies/server-upgrade-lifecycle.md)
- [Terraform Deployment Standardization](docs/case-studies/terraform-deployment-standardization.md)
"@

$readme = Upsert-Section -Content $readme -Header "## Lab Walkthroughs" -Body @"
## Lab Walkthroughs

- [Lab Index](docs/labs/README.md)
- [STIG Hardening Validation](docs/labs/stig-hardening-validation.md)
- [Terraform Azure Deployment Validation](docs/labs/terraform-azure-deployment-validation.md)
- [Linux Monitoring and Log Validation](docs/labs/linux-monitoring-and-log-validation.md)
"@

$readme = Upsert-Section -Content $readme -Header "## Automation Script Documentation" -Body @"
## Automation Script Documentation

- [README Upgrade Script](docs/scripts/upgrade-readme-systems-engineer-priority-1.md)
- [Scenarios / Playbooks / Reference Script](docs/scripts/add-scenarios-playbooks-and-reference.md)
- [Security / Metrics / Architecture Script](docs/scripts/add-security-metrics-and-architecture.md)
- [Script Documentation Template](docs/scripts/script-documentation-template.md)
"@

$readme = Upsert-Section -Content $readme -Header "## Systems Engineer Cheat Sheet" -Body @"
## Systems Engineer Cheat Sheet

- [Systems Engineer Cheat Sheet](docs/reference/systems-engineer-cheat-sheet.md)
- [Systems Engineer Command Reference](docs/reference/systems-engineer-command-reference.md)
"@

Set-Content -Path "README.md" -Encoding UTF8 -Value $readme
Write-Host "Updated README.md" -ForegroundColor Green

Write-Host "`n=== Phase 5 direct repair complete ===" -ForegroundColor Cyan
git status