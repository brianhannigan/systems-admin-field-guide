[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Cyan
}

function Ensure-Dir {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
    else {
        Write-Host "Directory exists: $Path" -ForegroundColor DarkGray
    }
}

function Write-TextFile {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Dir -Path $parent
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
        Write-Host "Updated README section: $Header" -ForegroundColor Yellow
    }
    else {
        $updated = $content.TrimEnd() + "`r`n`r`n" + $SectionContent.Trim() + "`r`n"
        Set-Content -LiteralPath $ReadmePath -Value $updated -Encoding UTF8
        Write-Host "Added README section: $Header" -ForegroundColor Yellow
    }
}

Write-Step "Validating repo"

if (-not (Test-Path -LiteralPath $RepoRoot)) {
    throw "Repo root not found: $RepoRoot"
}

$readmePath = Join-Path $RepoRoot "README.md"
if (-not (Test-Path -LiteralPath $readmePath)) {
    throw "README.md not found: $readmePath"
}

Write-Host "Repo root: $RepoRoot" -ForegroundColor Green

Write-Step "Ensuring folders"

$dirs = @(
    "docs/case-studies",
    "docs/labs",
    "docs/scripts",
    "docs/reference"
)

foreach ($dir in $dirs) {
    Ensure-Dir -Path (Join-Path $RepoRoot $dir)
}

Write-Step "Writing case studies"

Write-TextFile -Path (Join-Path $RepoRoot "docs/case-studies/stig-remediation-project.md") -Content @"
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

Write-TextFile -Path (Join-Path $RepoRoot "docs/case-studies/server-upgrade-lifecycle.md") -Content @"
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

Write-TextFile -Path (Join-Path $RepoRoot "docs/case-studies/terraform-deployment-standardization.md") -Content @"
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

Write-Step "Writing labs"

Write-TextFile -Path (Join-Path $RepoRoot "docs/labs/stig-hardening-validation.md") -Content @"
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

Write-TextFile -Path (Join-Path $RepoRoot "docs/labs/terraform-azure-deployment-validation.md") -Content @"
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

Write-TextFile -Path (Join-Path $RepoRoot "docs/labs/linux-monitoring-and-log-validation.md") -Content @"
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

Write-TextFile -Path (Join-Path $RepoRoot "docs/labs/README.md") -Content @"
# Lab Index

- [STIG Hardening Validation](stig-hardening-validation.md)
- [Terraform Azure Deployment Validation](terraform-azure-deployment-validation.md)
- [Linux Monitoring and Log Validation](linux-monitoring-and-log-validation.md)
"@

Write-Step "Writing script docs"

Write-TextFile -Path (Join-Path $RepoRoot "docs/scripts/upgrade-readme-systems-engineer-priority-1.md") -Content @"
# Script Doc — upgrade-readme-systems-engineer-priority-1.ps1

## Purpose
Improves the README so the repository becomes easier to navigate and understand.

## Usage

~~~powershell
.\tools\upgrade-readme-systems-engineer-priority-1.ps1
~~~
"@

Write-TextFile -Path (Join-Path $RepoRoot "docs/scripts/add-scenarios-playbooks-and-reference.md") -Content @"
# Script Doc — add-scenarios-playbooks-and-reference.ps1

## Purpose
Adds scenarios, playbooks, and command reference material.

## Usage

~~~powershell
.\tools\add-scenarios-playbooks-and-reference.ps1
~~~
"@

Write-TextFile -Path (Join-Path $RepoRoot "docs/scripts/add-security-metrics-and-architecture.md") -Content @"
# Script Doc — add-security-metrics-and-architecture.ps1

## Purpose
Adds workflow, metrics, and architecture guidance.

## Usage

~~~powershell
.\tools\add-security-metrics-and-architecture.ps1
~~~
"@

Write-TextFile -Path (Join-Path $RepoRoot "docs/scripts/script-documentation-template.md") -Content @"
# Script Documentation Template

## Purpose
Describe what the script does and why it exists.

## Usage

~~~powershell
.\tools\script-name.ps1
~~~
"@

Write-Step "Writing cheat sheet"

Write-TextFile -Path (Join-Path $RepoRoot "docs/reference/systems-engineer-cheat-sheet.md") -Content @"
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

Write-Step "Updating README"

Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Case Studies" -SectionContent @"
## Case Studies

- [STIG Remediation Project](docs/case-studies/stig-remediation-project.md)
- [Server Upgrade Lifecycle](docs/case-studies/server-upgrade-lifecycle.md)
- [Terraform Deployment Standardization](docs/case-studies/terraform-deployment-standardization.md)
"@

Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Lab Walkthroughs" -SectionContent @"
## Lab Walkthroughs

- [Lab Index](docs/labs/README.md)
- [STIG Hardening Validation](docs/labs/stig-hardening-validation.md)
- [Terraform Azure Deployment Validation](docs/labs/terraform-azure-deployment-validation.md)
- [Linux Monitoring and Log Validation](docs/labs/linux-monitoring-and-log-validation.md)
"@

Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Automation Script Documentation" -SectionContent @"
## Automation Script Documentation

- [README Upgrade Script](docs/scripts/upgrade-readme-systems-engineer-priority-1.md)
- [Scenarios / Playbooks / Reference Script](docs/scripts/add-scenarios-playbooks-and-reference.md)
- [Security / Metrics / Architecture Script](docs/scripts/add-security-metrics-and-architecture.md)
- [Script Documentation Template](docs/scripts/script-documentation-template.md)
"@

Upsert-ReadmeSection -ReadmePath $readmePath -Header "## Systems Engineer Cheat Sheet" -SectionContent @"
## Systems Engineer Cheat Sheet

- [Systems Engineer Cheat Sheet](docs/reference/systems-engineer-cheat-sheet.md)
- [Systems Engineer Command Reference](docs/reference/systems-engineer-command-reference.md)
"@

Write-Step "Complete"

Write-Host "Phase 5 repair complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "git status"
Write-Host "git add README.md docs tools"
Write-Host "git commit -m `"docs: repair phase 5 case studies labs script docs and cheat sheet`""
Write-Host "git push"