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
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
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
        [Parameter(Mandatory = $true)][string]$ReadmePath,
        [Parameter(Mandatory = $true)][string]$Header,
        [Parameter(Mandatory = $true)][string]$SectionContent
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
    "docs/case-studies",
    "docs/labs",
    "docs/reference",
    "docs/scripts"
)

foreach ($folder in $folders) {
    Ensure-Directory -Path (Join-Path $RepoRoot $folder)
}

Write-Section "Creating case studies"

$caseStudyStig = @"
# Case Study — STIG Remediation Project

## Problem
A system baseline required STIG hardening and vulnerability remediation, but changes had to be applied carefully to avoid breaking administrative access and production functionality.

## Environment
- Government / compliance-focused environment
- Linux and/or Windows systems
- Formal validation expectations
- Security scanning and remediation workflow in place

## Goals
- Improve compliance posture
- Reduce open findings
- Preserve service availability
- Capture repeatable validation evidence

## Approach
1. Review findings and group by operational impact
2. Identify which controls affect authentication, networking, logging, and services
3. Stage changes in a safe order
4. Validate service health after each major change group
5. Capture evidence for remediation closure
6. Update documentation and exceptions as needed

## Outcome
Document the practical results:
- Reduced open findings
- Improved hardening posture
- Fewer repeated remediation issues
- Better validation process

## Lessons Learned
- Hardening must be paired with service validation
- SSH, RDP, logging, and identity-related controls deserve special care
- Evidence collection should happen during the work, not after
"@

$caseStudyUpgrade = @"
# Case Study — Server Upgrade Lifecycle

## Problem
A server required an in-place upgrade or major version uplift while maintaining operational continuity and minimizing rollback risk.

## Environment
- Enterprise or government-managed system
- Maintenance window required
- Hardening and patching dependencies present
- Monitoring and validation required after completion

## Goals
- Complete the upgrade safely
- Preserve service availability
- Validate compatibility, security posture, and logging
- Document recovery steps if rollback is needed

## Approach
1. Capture current state and backup / snapshot information
2. Validate prerequisites and package health
3. Execute upgrade in a controlled window
4. Validate services, ports, logs, and dependencies
5. Confirm monitoring and security tooling return to healthy state
6. Record findings and lessons for the next upgrade cycle

## Outcome
Document measurable improvements:
- New supported version
- Reduced operational risk
- Improved standardization
- Clearer runbook for future upgrades

## Lessons Learned
- Pre-checks reduce emergency troubleshooting
- Service dependency maps matter
- Validation should be structured, not improvised
"@

$caseStudyTerraform = @"
# Case Study — Terraform Deployment Standardization

## Problem
Cloud resources were being deployed inconsistently across environments, increasing drift and troubleshooting effort.

## Environment
- Azure resources
- Terraform-managed infrastructure
- Shared engineering ownership
- Need for repeatable deployment and validation

## Goals
- Make deployments consistent
- Reduce manual changes
- Improve auditability
- Shorten recovery and rebuild time

## Approach
1. Define reusable modules and variable structure
2. Establish naming, tagging, and environment conventions
3. Validate with terraform fmt, validate, and plan
4. Apply changes through a repeatable workflow
5. Validate deployed resources and capture evidence
6. Monitor for drift and correct process gaps

## Outcome
Document improvements such as:
- More predictable deployments
- Better consistency across environments
- Easier troubleshooting
- Improved change confidence

## Lessons Learned
- Drift control requires both tooling and process
- Clear variable naming prevents mistakes
- Post-apply validation is mandatory
"@

Ensure-File -Path (Join-Path $RepoRoot "docs/case-studies/stig-remediation-project.md") -Content $caseStudyStig
Ensure-File -Path (Join-Path $RepoRoot "docs/case-studies/server-upgrade-lifecycle.md") -Content $caseStudyUpgrade
Ensure-File -Path (Join-Path $RepoRoot "docs/case-studies/terraform-deployment-standardization.md") -Content $caseStudyTerraform

Write-Section "Creating labs"

$labStig = @"
# Lab — STIG Hardening Validation

## Objective
Practice validating whether a hardening change improves compliance without breaking access or core services.

## Environment
- RHEL lab VM or equivalent
- SSH access
- Logging enabled
- SCAP / compliance tooling if available

## Prerequisites
- Admin access
- Snapshot or rollback plan
- Basic service baseline captured before changes

## Steps
1. Record current service and access state
2. Apply a controlled hardening-related change
3. Validate SSH, service health, and logging
4. Review whether the change introduces operational issues
5. Roll back or document the safe final state

## Validation
- SSH still works
- Service remains available
- Logs are clean enough for follow-up review
- Compliance position improves or is clearly understood

## Cleanup
Revert the lab change or restore the snapshot if needed.
"@

$labTerraform = @"
# Lab — Terraform Azure Deployment Validation

## Objective
Practice running a clean Terraform workflow and validating deployed Azure resources.

## Environment
- Azure lab subscription
- Terraform installed
- Test resource group or isolated environment

## Prerequisites
- Azure CLI access
- Terraform project files
- Safe non-production target scope

## Steps
1. Authenticate to Azure
2. Run terraform fmt
3. Run terraform validate
4. Run terraform plan
5. Run terraform apply
6. Validate deployed resources with Azure CLI
7. Run terraform plan again to confirm expected state

## Validation
- Resources deploy successfully
- terraform plan behaves as expected after apply
- Naming and tags are correct
- Resource health is visible in Azure

## Cleanup
Destroy or remove test resources if they are no longer needed.
"@

$labMonitoring = @"
# Lab — Linux Monitoring and Log Validation

## Objective
Practice validating service health, logs, and host state after a change or restart.

## Environment
- Linux VM
- systemd-managed service
- Local logs or journal available

## Prerequisites
- Administrative access
- Test service or known daemon to inspect

## Steps
1. Check current service status
2. Review recent logs
3. Restart the service
4. Confirm the service returns healthy
5. Validate listening ports and basic connectivity
6. Capture output as evidence

## Validation
- Service starts cleanly
- No major errors appear in logs
- Required port is listening
- Basic connectivity checks succeed

## Cleanup
Return the lab system to its baseline if any configuration was changed.
"@

$labIndex = @"
# Lab Index

## Current Labs
- [STIG Hardening Validation](stig-hardening-validation.md)
- [Terraform Azure Deployment Validation](terraform-azure-deployment-validation.md)
- [Linux Monitoring and Log Validation](linux-monitoring-and-log-validation.md)
"@

Ensure-File -Path (Join-Path $RepoRoot "docs/labs/stig-hardening-validation.md") -Content $labStig
Ensure-File -Path (Join-Path $RepoRoot "docs/labs/terraform-azure-deployment-validation.md") -Content $labTerraform
Ensure-File -Path (Join-Path $RepoRoot "docs/labs/linux-monitoring-and-log-validation.md") -Content $labMonitoring
Ensure-File -Path (Join-Path $RepoRoot "docs/labs/README.md") -Content $labIndex

Write-Section "Creating script documentation"

$scriptDocScaffold = @"
# Script Doc — upgrade-readme-systems-engineer-priority-1.ps1

## Purpose
Improves the README so the repository becomes easier to navigate and understand quickly.

## What It Adds
- How to Use This Guide
- Suggested Reading Order
- Systems Engineer Operational Model
- Practice and navigation sections

## Usage

~~~powershell
.\tools\upgrade-readme-systems-engineer-priority-1.ps1
~~~

## Expected Result
README is upgraded with clearer learning path and operational structure.
"@

$scriptDocScenarios = @"
# Script Doc — add-scenarios-playbooks-and-reference.ps1

## Purpose
Adds operational scenarios, troubleshooting playbooks, and example command reference material.

## What It Adds
- Scenario docs
- Playbook docs
- Command reference
- README links to those sections

## Usage

~~~powershell
.\tools\add-scenarios-playbooks-and-reference.ps1
~~~

## Expected Result
The repository gains practical operational depth and more portfolio evidence.
"@

$scriptDocSecurity = @"
# Script Doc — add-security-metrics-and-architecture.ps1

## Purpose
Adds senior-level systems engineering guidance around workflow, metrics, and architecture.

## What It Adds
- Security incident workflow
- Change validation workflow
- Engineering metrics
- Architecture overview
- Diagram placeholders

## Usage

~~~powershell
.\tools\add-security-metrics-and-architecture.ps1
~~~

## Expected Result
The repository gains stronger engineering credibility and clearer system-level framing.
"@

$scriptDocTemplate = @"
# Script Documentation Template

## Purpose
What the script does and why it exists.

## Inputs
List parameters, required files, and assumptions.

## Usage

~~~powershell
.\tools\script-name.ps1
~~~

## Expected Result
Describe what files or repo sections are created or updated.

## Safety Notes
Call out backups, overwrite behavior, or validation steps.
"@

Ensure-File -Path (Join-Path $RepoRoot "docs/scripts/upgrade-readme-systems-engineer-priority-1.md") -Content $scriptDocScaffold
Ensure-File -Path (Join-Path $RepoRoot "docs/scripts/add-scenarios-playbooks-and-reference.md") -Content $scriptDocScenarios
Ensure-File -Path (Join-Path $RepoRoot "docs/scripts/add-security-metrics-and-architecture.md") -Content $scriptDocSecurity
Ensure-File -Path (Join-Path $RepoRoot "docs/scripts/script-documentation-template.md") -Content $scriptDocTemplate

Write-Section "Creating cheat sheet"

$cheatSheet = @"
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
Get-WinEvent -LogName Security -MaxEvents 50
Test-NetConnection <host> -Port 3389
~~~

## Azure Quick Commands

~~~bash
az login
az account show
az group list -o table
az vm list -o table
az vm show --resource-group <rg> --name <vm> -o json
az monitor activity-log list --max-events 20
~~~

## Terraform Quick Commands

~~~bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform show
terraform state list
~~~

## Fast Troubleshooting Flow

1. Confirm scope
2. Confirm recent changes
3. Validate service health
4. Review logs
5. Check network reachability
6. Validate dependencies
7. Test recovery
8. Document evidence
"@

Ensure-File -Path (Join-Path $RepoRoot "docs/reference/systems-engineer-cheat-sheet.md") -Content $cheatSheet

Write-Section "Updating README"

$caseStudiesSection = @"
## Case Studies

These case studies make the repository feel more like real engineering work and less like notes.

- [STIG Remediation Project](docs/case-studies/stig-remediation-project.md)
- [Server Upgrade Lifecycle](docs/case-studies/server-upgrade-lifecycle.md)
- [Terraform Deployment Standardization](docs/case-studies/terraform-deployment-standardization.md)
"@

$labsSection = @"
## Lab Walkthroughs

Use these labs to rehearse repeatable operational workflows in safe environments.

- [Lab Index](docs/labs/README.md)
- [STIG Hardening Validation](docs/labs/stig-hardening-validation.md)
- [Terraform Azure Deployment Validation](docs/labs/terraform-azure-deployment-validation.md)
- [Linux Monitoring and Log Validation](docs/labs/linux-monitoring-and-log-validation.md)
"@

$scriptsSection = @"
## Automation Script Documentation

These docs explain what the repo automation scripts do and how to use them safely.

- [README Upgrade Script](docs/scripts/upgrade-readme-systems-engineer-priority-1.md)
- [Scenarios / Playbooks / Reference Script](docs/scripts/add-scenarios-playbooks-and-reference.md)
- [Security / Metrics / Architecture Script](docs/scripts/add-security-metrics-and-architecture.md)
- [Script Documentation Template](docs/scripts/script-documentation-template.md)
"@

$cheatSheetSection = @"
## Systems Engineer Cheat Sheet

Use this page as a quick operational reference during live work or lab practice.

- [Systems Engineer Cheat Sheet](docs/reference/systems-engineer-cheat-sheet.md)
- [Systems Engineer Command Reference](docs/reference/systems-engineer-command-reference.md)
"@

Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Case Studies" -SectionContent $caseStudiesSection
Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Lab Walkthroughs" -SectionContent $labsSection
Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Automation Script Documentation" -SectionContent $scriptsSection
Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Systems Engineer Cheat Sheet" -SectionContent $cheatSheetSection

Write-Section "Complete"

Write-Host "Case studies, labs, script docs, and cheat sheet added." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "git status"
Write-Host "git add README.md docs tools"
Write-Host "git commit -m `"docs: add case studies labs script docs and cheat sheet`""
Write-Host "git push"