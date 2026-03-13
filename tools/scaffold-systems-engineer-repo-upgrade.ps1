[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path,
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

function Add-Section-IfMissing {
    param(
        [string]$ReadmePath,
        [string]$Header,
        [string]$SectionContent
    )

    if (-not (Test-Path -LiteralPath $ReadmePath)) {
        throw "README not found at: $ReadmePath"
    }

    $existing = Get-Content -LiteralPath $ReadmePath -Raw

    if ($existing -match [regex]::Escape($Header)) {
        Write-Host "README already contains section: $Header" -ForegroundColor DarkGray
        return
    }

    $updated = $existing.TrimEnd() + "`r`n`r`n" + $SectionContent.Trim() + "`r`n"
    Set-Content -LiteralPath $ReadmePath -Value $updated -Encoding UTF8
    Write-Host "Added README section: $Header" -ForegroundColor Green
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoRoot)) {
    throw "RepoRoot does not exist: $RepoRoot"
}

$readmePath = Join-Path $RepoRoot "README.md"
if (-not (Test-Path -LiteralPath $readmePath)) {
    throw "README.md was not found in repo root: $RepoRoot"
}

Write-Host "Repository root validated: $RepoRoot" -ForegroundColor Green

Write-Section "Creating folders"

$folders = @(
    "docs/scenarios",
    "docs/playbooks",
    "docs/case-studies",
    "docs/metrics",
    "docs/reference",
    "docs/workflows",
    "docs/labs",
    "diagrams/placeholders"
)

foreach ($folder in $folders) {
    Ensure-Directory -Path (Join-Path $RepoRoot $folder)
}

Write-Section "Creating scaffold documents"

$cheatSheet = @"
# Systems Engineer Cheat Sheet

## Linux Quick Commands

~~~bash
hostnamectl
uname -a
ip addr
ss -tulpn
systemctl status <service>
journalctl -u <service> -n 100
df -h
free -h
top
~~~

## Windows Quick Checks

~~~powershell
Get-Service
Get-EventLog -LogName System -Newest 50
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20
Get-Volume
Test-NetConnection
~~~

## Azure Quick Commands

~~~bash
az login
az account show
az vm list -o table
az group list -o table
az resource list -o table
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

## Troubleshooting Flow

1. Confirm scope
2. Confirm recent changes
3. Check service health
4. Check logs
5. Check network reachability
6. Validate dependencies
7. Test fix
8. Document outcome
"@

$operationalModel = @"
# Systems Engineer Operational Model

Infrastructure Discovery
↓
Documentation
↓
Hardening & Compliance
↓
Automation
↓
Monitoring & Logging
↓
Vulnerability Remediation
↓
Validation & Continuous Improvement
"@

$scenario1 = @"
# Scenario — Failed RHEL Upgrade Recovery

## Problem
A Red Hat Enterprise Linux server fails after an upgrade.

## Investigation Steps
1. Confirm console access
2. Review boot logs
3. Validate filesystem
4. Review SELinux status
5. Check package consistency

## Validation
Server boots cleanly and services start.
"@

$scenario2 = @"
# Scenario — STIG Rule Breaks SSH Access

## Problem
A STIG hardening rule prevents SSH login.

## Investigation Steps
1. Confirm sshd status
2. Check firewall rules
3. Review sshd_config
4. Review SELinux policy

## Validation
SSH login restored with secure configuration.
"@

$playbook1 = @"
# Playbook — Linux Server Not Reachable

## Initial Checks

~~~bash
ping host
nslookup host
traceroute host
ip addr
ss -tulpn
~~~

## Root Causes
Network interface down  
Firewall rule  
DNS issue  
Service crash
"@

$playbook2 = @"
# Playbook — Disk Space Full

## Commands

~~~bash
df -h
du -xh / | sort -h | tail
journalctl -n 100
~~~

## Resolution
Clean logs, expand disk, or rotate files.
"@

$metrics = @"
# Engineering Metrics

MTTR  
Patch latency  
Vulnerability closure rate  
Change success rate  
System uptime
"@

Ensure-File (Join-Path $RepoRoot "docs/reference/systems-engineer-cheat-sheet.md") $cheatSheet
Ensure-File (Join-Path $RepoRoot "docs/workflows/systems-engineer-operational-model.md") $operationalModel
Ensure-File (Join-Path $RepoRoot "docs/scenarios/failed-rhel-upgrade.md") $scenario1
Ensure-File (Join-Path $RepoRoot "docs/scenarios/stig-breaks-ssh.md") $scenario2
Ensure-File (Join-Path $RepoRoot "docs/playbooks/linux-server-not-reachable.md") $playbook1
Ensure-File (Join-Path $RepoRoot "docs/playbooks/disk-space-full.md") $playbook2
Ensure-File (Join-Path $RepoRoot "docs/metrics/engineering-metrics.md") $metrics

Write-Section "Updating README"

$readmeSection = @"
## How to Use This Guide

Start with onboarding and reading order, then move through operations and labs.

- docs/reference/systems-engineer-cheat-sheet.md
- docs/scenarios
- docs/playbooks
- docs/metrics
"@

Add-Section-IfMissing $readmePath "## How to Use This Guide" $readmeSection

Write-Section "Complete"

Write-Host "Scaffold complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:"
Write-Host "git status"
Write-Host "git add ."
Write-Host "git commit -m `"docs: scaffold systems engineer guide structure`""
Write-Host "git push"