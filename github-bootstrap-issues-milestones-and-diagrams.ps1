param(
    [string]$RepoPath = "C:\Users\BrianH\Documents\0000 - Portfolio\systems-admin-field-guide",
    [string]$Owner = "brianhannigan",
    [string]$Repo = "systems-admin-field-guide",
    [switch]$CreateIssues,
    [switch]$CreateLabels,
    [switch]$WriteDiagramFiles,
    [switch]$WriteLabTemplates,
    [switch]$WriteIssueSeedDocs,
    [switch]$All
)

$ErrorActionPreference = "Stop"

if ($All) {
    $CreateIssues = $true
    $CreateLabels = $true
    $WriteDiagramFiles = $true
    $WriteLabTemplates = $true
    $WriteIssueSeedDocs = $true
}

function Write-Section {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor $Color
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )
    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Directory -Path $parent
    }
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8
}

function Invoke-Gh {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & gh @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        throw "gh command failed: gh $($Arguments -join ' ')`n$output"
    }

    return $output
}

function Test-GhAvailable {
    try {
        $null = Invoke-Gh -Arguments @("auth", "status")
        return $true
    }
    catch {
        throw "GitHub CLI is not ready. Install/authenticate gh first. Error: $($_.Exception.Message)"
    }
}

function Ensure-Label {
    param(
        [string]$Name,
        [string]$Color,
        [string]$Description
    )

    $existing = & gh label list --repo "$Owner/$Repo" --limit 200 --json name 2>$null | ConvertFrom-Json
    if ($existing.name -contains $Name) {
        Write-Host "Label already exists: $Name" -ForegroundColor DarkYellow
        return
    }

    Invoke-Gh -Arguments @(
        "label", "create", $Name,
        "--repo", "$Owner/$Repo",
        "--color", $Color,
        "--description", $Description
    ) | Out-Null

    Write-Host "Created label: $Name" -ForegroundColor DarkGreen
}

function Issue-Exists {
    param([string]$Title)

    $issues = & gh issue list --repo "$Owner/$Repo" --limit 200 --state all --json title 2>$null | ConvertFrom-Json
    return ($issues.title -contains $Title)
}

function Ensure-Issue {
    param(
        [string]$Title,
        [string]$Body,
        [string[]]$Labels
    )

    if (Issue-Exists -Title $Title) {
        Write-Host "Issue already exists: $Title" -ForegroundColor DarkYellow
        return
    }

    $args = @(
        "issue", "create",
        "--repo", "$Owner/$Repo",
        "--title", $Title,
        "--body", $Body
    )

    foreach ($label in $Labels) {
        $args += @("--label", $label)
    }

    Invoke-Gh -Arguments $args | Out-Null
    Write-Host "Created issue: $Title" -ForegroundColor DarkGreen
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

Set-Location -LiteralPath $RepoPath

Write-Section "Checking GitHub CLI"
Test-GhAvailable | Out-Null

$docsPath         = Join-Path $RepoPath "docs"
$diagramsPath     = Join-Path $RepoPath "diagrams"
$assetsPath       = Join-Path $RepoPath "assets"
$labsPath         = Join-Path $RepoPath "labs"
$linuxLabsPath    = Join-Path $labsPath "linux"
$azureLabsPath    = Join-Path $labsPath "azure"
$terraformLabsPath= Join-Path $labsPath "terraform"
$stigLabsPath     = Join-Path $labsPath "stig"
$planningPath     = Join-Path $RepoPath "planning"

Ensure-Directory -Path $diagramsPath
Ensure-Directory -Path (Join-Path $diagramsPath "infrastructure")
Ensure-Directory -Path (Join-Path $diagramsPath "workflows")
Ensure-Directory -Path (Join-Path $diagramsPath "security")
Ensure-Directory -Path $assetsPath
Ensure-Directory -Path $linuxLabsPath
Ensure-Directory -Path $azureLabsPath
Ensure-Directory -Path $terraformLabsPath
Ensure-Directory -Path $stigLabsPath
Ensure-Directory -Path $planningPath

if ($WriteDiagramFiles) {
    Write-Section "Writing Mermaid diagram files"

    $diagramIndex = @'
# Diagram Index

This folder contains Mermaid source diagrams for the repo.

## Priority diagrams
- infrastructure/infrastructure-discovery-workflow.md
- workflows/service-troubleshooting-workflow.md
- workflows/change-and-validation-workflow.md
- workflows/vulnerability-remediation-lifecycle.md
- security/stig-troubleshooting-workflow.md
- workflows/twelve-week-roadmap.md
'@
    Write-Utf8File -Path (Join-Path $diagramsPath "README.md") -Content $diagramIndex

    $infra = @'
# Infrastructure Discovery Workflow

```mermaid
flowchart TD
    A[Collect server and cloud inventory] --> B[Identify critical systems]
    B --> C[Map dependencies]
    C --> D[Identify owners]
    D --> E[Review monitoring backups and access]
    E --> F[Document red flags]
    F --> G[Build first-priority action list]
```
'@
    Write-Utf8File -Path (Join-Path $diagramsPath "infrastructure\infrastructure-discovery-workflow.md") -Content $infra

    $serviceFlow = @'
# Service Troubleshooting Workflow

```mermaid
flowchart TD
    A[User reports outage] --> B[Check service status]
    B --> C[Review recent logs]
    C --> D[Check ports network and disk]
    D --> E[Identify root cause]
    E --> F[Apply minimal safe fix]
    F --> G[Validate service health]
    G --> H[Capture evidence and document]
```
'@
    Write-Utf8File -Path (Join-Path $diagramsPath "workflows\service-troubleshooting-workflow.md") -Content $serviceFlow

    $changeFlow = @'
# Change and Validation Workflow

```mermaid
flowchart TD
    A[Review change] --> B[Confirm dependencies]
    B --> C[Confirm backup or rollback]
    C --> D[Execute planned change]
    D --> E[Run technical validation]
    E --> F[Run functional validation]
    F --> G[Capture evidence]
    G --> H[Close or escalate]
```
'@
    Write-Utf8File -Path (Join-Path $diagramsPath "workflows\change-and-validation-workflow.md") -Content $changeFlow

    $vulnFlow = @'
# Vulnerability Remediation Lifecycle

```mermaid
flowchart TD
    A[Scanner finding appears] --> B[Review asset context]
    B --> C[Prioritize by real risk]
    C --> D[Plan patch or mitigation]
    D --> E[Test if needed]
    E --> F[Deploy fix]
    F --> G[Validate service health]
    G --> H[Rescan and record evidence]
    H --> I[Close or document exception]
```
'@
    Write-Utf8File -Path (Join-Path $diagramsPath "workflows\vulnerability-remediation-lifecycle.md") -Content $vulnFlow

    $stigFlow = @'
# STIG Troubleshooting Workflow

```mermaid
flowchart TD
    A[Hardening change applied] --> B[Service or access issue appears]
    B --> C[Check service status]
    C --> D[Review logs and denials]
    D --> E[Identify exact control impact]
    E --> F[Apply minimal safe corrective action]
    F --> G[Retest]
    G --> H[Document evidence or exception]
```
'@
    Write-Utf8File -Path (Join-Path $diagramsPath "security\stig-troubleshooting-workflow.md") -Content $stigFlow

    $weekFlow = @'
# 12 Week Roadmap

```mermaid
flowchart LR
    W1[Weeks 1-4 Discovery] --> W2[Weeks 5-8 Execution]
    W2 --> W3[Weeks 9-12 Ownership]

    W1 --> A[Inventory Linux Azure Terraform Docs]
    W2 --> B[Terraform Azure Upgrades Vulnerabilities]
    W3 --> C[Incidents Automation Documentation]
```
'@
    Write-Utf8File -Path (Join-Path $diagramsPath "workflows\twelve-week-roadmap.md") -Content $weekFlow
}

if ($WriteLabTemplates) {
    Write-Section "Writing lab templates"

    $labTemplate = @'
# Lab Template

## Objective
State exactly what skill this lab builds.

## Prerequisites
- VM or environment needed
- access level needed
- tools required

## Setup
Describe the starting condition.

## Tasks
1. Step one
2. Step two
3. Step three

## Validation
- What proves success
- What commands confirm the result

## Failure Points
- What commonly goes wrong
- What to inspect first

## Evidence to Capture
- command output
- screenshots
- notes
'@

    Write-Utf8File -Path (Join-Path $linuxLabsPath "lab-template.md") -Content $labTemplate
    Write-Utf8File -Path (Join-Path $azureLabsPath "lab-template.md") -Content $labTemplate
    Write-Utf8File -Path (Join-Path $terraformLabsPath "lab-template.md") -Content $labTemplate
    Write-Utf8File -Path (Join-Path $stigLabsPath "lab-template.md") -Content $labTemplate

    $linuxExecution = @'
# Linux Baseline Execution Notes

## Objective
Use this file to record actual execution notes from your Linux baseline lab.

## Commands Run
```bash
hostnamectl
uptime
systemctl --failed
df -h
lsblk
ip addr
ip route
journalctl -p err -b
```

## Findings
- Add what you found
- Note anything unexpected

## Fixes Applied
- Add any corrections made

## Validation
- Record what proved the system was healthy
'@
    Write-Utf8File -Path (Join-Path $linuxLabsPath "linux-baseline-execution-notes.md") -Content $linuxExecution

    $serviceExecution = @'
# Service Failure Execution Notes

## Objective
Use this file to record the exact workflow you used to break, diagnose, and restore a service.

## Symptom
Describe the observed failure.

## Commands Run
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
journalctl -xe
ss -tulpn
```

## Root Cause
- Add the actual reason the service failed

## Fix Applied
- Add the corrective action

## Validation
- Show how you proved the service recovered
'@
    Write-Utf8File -Path (Join-Path $linuxLabsPath "service-failure-execution-notes.md") -Content $serviceExecution

    $patchExecution = @'
# Patching Execution Notes

## Objective
Track your pre-checks, patch steps, reboot behavior, and post-validation.

## Before State
- package state
- service state
- disk state
- log state

## Commands Run
```bash
dnf check-update
dnf update -y
rpm -qa | sort
systemctl --failed
journalctl -p err -b
```

## After State
- record what changed
- note unexpected behavior

## Validation
- explain what proved success
'@
    Write-Utf8File -Path (Join-Path $linuxLabsPath "patching-execution-notes.md") -Content $patchExecution
}

if ($WriteIssueSeedDocs) {
    Write-Section "Writing planning and issue seed docs"

    $issuesDoc = @'
# GitHub Issue Creation Plan

Use these titles and bodies if you want to create issues manually later.

## Polish
- polish: add repo banner and overview image
- polish: update GitHub About metadata and topics
- polish: prepare v0.1.0 release notes

## Linux
- docs: expand Linux services troubleshooting guide
- docs: expand Linux logging guide with practical scenarios
- docs: expand Linux security guide with SELinux and firewall validation
- labs: document linux baseline execution evidence
- labs: document service failure execution evidence
- labs: document patching execution evidence

## Terraform
- docs: expand Terraform fundamentals with review workflow
- docs: expand Terraform state management with drift notes
- docs: add Terraform Azure VM example with validation
- docs: expand Terraform troubleshooting with real error patterns

## Azure
- docs: expand Azure VM deployment guide
- docs: expand Azure networking troubleshooting guide
- docs: expand Azure RBAC guide with least privilege examples
- docs: expand Azure monitoring guide with actionable alert patterns

## STIG
- docs: expand why systems break after hardening with concrete examples
- docs: expand STIG troubleshooting workflow with real break-fix scenarios
- docs: add STIG evidence and exception examples

## Upgrades and Vulnerabilities
- docs: expand pre-upgrade checklist with real commands
- docs: expand rollback planning with decision thresholds
- docs: expand vulnerability prioritization with risk-based examples
- docs: expand remediation validation with before-after evidence
'@
    Write-Utf8File -Path (Join-Path $planningPath "ISSUE_CREATION_PLAN.md") -Content $issuesDoc

    $milestonesDoc = @'
# Milestone Plan

## Milestone 1 - Repo Foundation and Polish
- README polish
- About metadata
- release checklist
- issue backlog
- first screenshot or diagram export

## Milestone 2 - Core Linux and STIG Depth
- Linux services
- logging
- security
- STIG break-fix examples
- STIG evidence and exceptions

## Milestone 3 - Terraform and Azure Operations
- Terraform fundamentals
- state handling
- Azure VM workflows
- networking
- RBAC
- monitoring

## Milestone 4 - Change and Vulnerability Operations
- upgrade runbooks
- rollback planning
- patch validation
- vulnerability prioritization
- remediation validation

## Milestone 5 - Labs and Portfolio Finish
- completed labs with evidence
- screenshots
- exported diagrams
- v0.1.0 release
'@
    Write-Utf8File -Path (Join-Path $planningPath "MILESTONE_PLAN.md") -Content $milestonesDoc
}

if ($CreateLabels) {
    Write-Section "Creating labels"

    $labels = @(
        @{ Name = "documentation"; Color = "0E8A16"; Description = "Documentation improvements and content expansion" },
        @{ Name = "enhancement";   Color = "A2EEEF"; Description = "Portfolio or repo polish improvements" },
        @{ Name = "labs";          Color = "5319E7"; Description = "Hands-on labs and lab evidence" },
        @{ Name = "linux";         Color = "1D76DB"; Description = "Linux administration content" },
        @{ Name = "terraform";     Color = "7B42BC"; Description = "Terraform content and examples" },
        @{ Name = "azure";         Color = "0052CC"; Description = "Azure operations content" },
        @{ Name = "stig";          Color = "B60205"; Description = "STIG hardening and troubleshooting" },
        @{ Name = "security";      Color = "D93F0B"; Description = "Security-related content" },
        @{ Name = "operations";    Color = "FBCA04"; Description = "Operations, upgrades, and validation workflows" },
        @{ Name = "vuln-mgmt";     Color = "E99695"; Description = "Vulnerability management content" },
        @{ Name = "good first task"; Color = "7057ff"; Description = "Smaller next-step tasks" }
    )

    foreach ($label in $labels) {
        Ensure-Label -Name $label.Name -Color $label.Color -Description $label.Description
    }
}

if ($CreateIssues) {
    Write-Section "Creating backlog issues"

    $issueList = @(
        @{
            Title  = "polish: add repo banner and overview image"
            Body   = @"
Add at least one polished visual asset to the repo.

## Goals
- add `assets/repo-overview.png` or similar
- reference it from the README
- improve root repo presentation

## Completion criteria
- visual added to assets
- README updated to reference it
"@
            Labels = @("enhancement")
        },
        @{
            Title  = "polish: update GitHub About metadata and topics"
            Body   = @"
Update the GitHub About panel.

## Goals
- add description
- add topics
- optionally add website later

## Completion criteria
- About description set
- topics added
"@
            Labels = @("enhancement")
        },
        @{
            Title  = "docs: expand Linux services troubleshooting guide"
            Body   = @"
Deepen `docs/02-linux-admin/services.md`.

## Add
- more real failure patterns
- more validation commands
- example workflows for web, SSH, and app services
- service recovery notes

## Completion criteria
- document feels runbook-quality
"@
            Labels = @("documentation", "linux", "operations")
        },
        @{
            Title  = "docs: expand Linux logging guide with practical scenarios"
            Body   = @"
Improve `docs/02-linux-admin/logging.md`.

## Add
- common log review patterns
- examples for service failures
- examples for post-patch review
- examples for security validation

## Completion criteria
- includes real troubleshooting scenarios
"@
            Labels = @("documentation", "linux", "operations")
        },
        @{
            Title  = "docs: expand Linux security guide with SELinux and firewall validation"
            Body   = @"
Improve `docs/02-linux-admin/security.md`.

## Add
- SELinux troubleshooting patterns
- firewall validation examples
- SSH hardening validation
- common breakpoints after security changes

## Completion criteria
- security guide supports real admin work
"@
            Labels = @("documentation", "linux", "security")
        },
        @{
            Title  = "labs: document linux baseline execution evidence"
            Body   = @"
Complete the Linux baseline lab and record execution notes.

## Add
- commands run
- findings
- validation evidence
- lessons learned

## Completion criteria
- `labs/linux/linux-baseline-execution-notes.md` is filled out with real results
"@
            Labels = @("labs", "linux")
        },
        @{
            Title  = "labs: document service failure execution evidence"
            Body   = @"
Complete the service failure lab and record execution notes.

## Add
- service chosen
- failure introduced
- diagnosis steps
- root cause
- validation evidence

## Completion criteria
- `labs/linux/service-failure-execution-notes.md` is filled out with real results
"@
            Labels = @("labs", "linux", "operations")
        },
        @{
            Title  = "labs: document patching execution evidence"
            Body   = @"
Complete the patching lab and record execution notes.

## Add
- pre-checks
- package actions
- reboot behavior if any
- post-validation
- lessons learned

## Completion criteria
- `labs/linux/patching-execution-notes.md` is filled out with real results
"@
            Labels = @("labs", "linux", "operations")
        },
        @{
            Title  = "docs: expand Terraform fundamentals with review workflow"
            Body   = @"
Improve `docs/03-terraform/fundamentals.md`.

## Add
- safer review habits
- what to inspect before apply
- variable handling notes
- common admin mistakes

## Completion criteria
- fundamentals section supports change review discipline
"@
            Labels = @("documentation", "terraform", "operations")
        },
        @{
            Title  = "docs: expand Terraform state management with drift notes"
            Body   = @"
Improve `docs/03-terraform/state-management.md`.

## Add
- drift handling guidance
- remote state cautions
- import considerations
- state safety reminders

## Completion criteria
- state section clearly explains operational risk
"@
            Labels = @("documentation", "terraform", "operations")
        },
        @{
            Title  = "docs: add Terraform Azure VM example with validation"
            Body   = @"
Expand `docs/03-terraform/azure-examples.md`.

## Add
- VM example
- supporting resource dependencies
- validation steps
- safe cleanup notes

## Completion criteria
- document includes a complete small deployment example
"@
            Labels = @("documentation", "terraform", "azure")
        },
        @{
            Title  = "docs: expand Terraform troubleshooting with real error patterns"
            Body   = @"
Improve `docs/03-terraform/troubleshooting.md`.

## Add
- auth failure example
- provider error example
- state issue example
- plan failure example

## Completion criteria
- troubleshooting section includes real error categories
"@
            Labels = @("documentation", "terraform", "operations")
        },
        @{
            Title  = "docs: expand Azure VM deployment guide"
            Body   = @"
Improve `docs/04-azure/vm-deployment.md`.

## Add
- portal workflow notes
- CLI workflow notes
- validation checklist depth
- common deployment mistakes

## Completion criteria
- VM deployment doc is practically useful
"@
            Labels = @("documentation", "azure", "operations")
        },
        @{
            Title  = "docs: expand Azure networking troubleshooting guide"
            Body   = @"
Improve `docs/04-azure/networking.md`.

## Add
- NSG troubleshooting examples
- public/private access checks
- routing examples
- validation flow

## Completion criteria
- networking guide supports incident-style triage
"@
            Labels = @("documentation", "azure", "operations")
        },
        @{
            Title  = "docs: expand Azure RBAC guide with least privilege examples"
            Body   = @"
Improve `docs/04-azure/iam-rbac.md`.

## Add
- scope examples
- least privilege examples
- common risky assignments
- cleanup review ideas

## Completion criteria
- RBAC guide is specific and practical
"@
            Labels = @("documentation", "azure", "security")
        },
        @{
            Title  = "docs: expand Azure monitoring guide with actionable alert patterns"
            Body   = @"
Improve `docs/04-azure/monitoring.md`.

## Add
- useful signal categories
- noisy alert cleanup ideas
- activity log review examples
- validation checklist improvements

## Completion criteria
- monitoring doc supports real operations
"@
            Labels = @("documentation", "azure", "operations")
        },
        @{
            Title  = "docs: expand why systems break after hardening with concrete examples"
            Body   = @"
Improve `docs/05-stig-hardening/why-systems-break.md`.

## Add
- specific break/fix examples
- access breakpoints
- service account impact
- logging and permissions examples

## Completion criteria
- includes concrete examples rather than generic statements
"@
            Labels = @("documentation", "stig", "security")
        },
        @{
            Title  = "docs: expand STIG troubleshooting workflow with real break-fix scenarios"
            Body   = @"
Improve `docs/05-stig-hardening/troubleshooting.md`.

## Add
- SSH access issue scenario
- permission-denied service scenario
- SELinux denial scenario
- evidence capture notes

## Completion criteria
- troubleshooting guide feels operational and reusable
"@
            Labels = @("documentation", "stig", "security", "operations")
        },
        @{
            Title  = "docs: add STIG evidence and exception examples"
            Body   = @"
Improve `docs/05-stig-hardening/compliance-workflow.md`.

## Add
- evidence examples
- exception examples
- compensating control examples

## Completion criteria
- compliance notes support audit-minded documentation
"@
            Labels = @("documentation", "stig", "security")
        },
        @{
            Title  = "docs: expand pre-upgrade checklist with real commands"
            Body   = @"
Improve `docs/06-server-upgrades/pre-upgrade-checklist.md`.

## Add
- Linux validation commands
- evidence ideas
- owner communication checks
- dependency review reminders

## Completion criteria
- checklist becomes more actionable
"@
            Labels = @("documentation", "operations")
        },
        @{
            Title  = "docs: expand rollback planning with decision thresholds"
            Body   = @"
Improve `docs/06-server-upgrades/rollback-planning.md`.

## Add
- decision threshold examples
- restore evidence ideas
- communication triggers
- risk framing notes

## Completion criteria
- rollback section supports real change execution
"@
            Labels = @("documentation", "operations")
        },
        @{
            Title  = "docs: expand vulnerability prioritization with risk-based examples"
            Body   = @"
Improve `docs/07-vulnerability-management/prioritization.md`.

## Add
- real risk examples
- exposed vs internal examples
- critical asset weighting
- compensating control examples

## Completion criteria
- prioritization goes beyond scanner score alone
"@
            Labels = @("documentation", "vuln-mgmt", "security")
        },
        @{
            Title  = "docs: expand remediation validation with before-after evidence"
            Body   = @"
Improve `docs/07-vulnerability-management/remediation-validation.md`.

## Add
- before/after evidence examples
- package validation examples
- scan verification examples
- operational health checks after remediation

## Completion criteria
- validation section proves fixes, not just changes
"@
            Labels = @("documentation", "vuln-mgmt", "operations")
        },
        @{
            Title  = "polish: prepare v0.1.0 release notes"
            Body   = @"
Prepare the first repo release.

## Goals
- review `releases/v0.1.0-checklist.md`
- confirm scope
- draft release notes
- publish first release in GitHub

## Completion criteria
- v0.1.0 release created
"@
            Labels = @("enhancement")
        }
    )

    foreach ($issue in $issueList) {
        Ensure-Issue -Title $issue.Title -Body $issue.Body -Labels $issue.Labels
    }
}

Write-Section "Validation" "Green"

$expectedFiles = @()

if ($WriteDiagramFiles -or $All) {
    $expectedFiles += @(
        "diagrams\README.md",
        "diagrams\infrastructure\infrastructure-discovery-workflow.md",
        "diagrams\workflows\service-troubleshooting-workflow.md",
        "diagrams\workflows\change-and-validation-workflow.md",
        "diagrams\workflows\vulnerability-remediation-lifecycle.md",
        "diagrams\security\stig-troubleshooting-workflow.md",
        "diagrams\workflows\twelve-week-roadmap.md"
    )
}

if ($WriteLabTemplates -or $All) {
    $expectedFiles += @(
        "labs\linux\lab-template.md",
        "labs\azure\lab-template.md",
        "labs\terraform\lab-template.md",
        "labs\stig\lab-template.md",
        "labs\linux\linux-baseline-execution-notes.md",
        "labs\linux\service-failure-execution-notes.md",
        "labs\linux\patching-execution-notes.md"
    )
}

if ($WriteIssueSeedDocs -or $All) {
    $expectedFiles += @(
        "planning\ISSUE_CREATION_PLAN.md",
        "planning\MILESTONE_PLAN.md"
    )
}

$missing = @()

foreach ($relativeFile in $expectedFiles) {
    $fullPath = Join-Path $RepoPath $relativeFile
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $missing += $relativeFile
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing files detected:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    throw "Validation failed."
}

Write-Host ""
Write-Host "Validation passed." -ForegroundColor Green

Write-Host ""
Write-Host "Recommended run examples:" -ForegroundColor Yellow
Write-Host '1. Write files only:'
Write-Host '   .\github-bootstrap-issues-milestones-and-diagrams.ps1 -WriteDiagramFiles -WriteLabTemplates -WriteIssueSeedDocs'
Write-Host ""
Write-Host '2. Write files + labels + issues:'
Write-Host '   .\github-bootstrap-issues-milestones-and-diagrams.ps1 -All'
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "git status"
Write-Host "git add ."
Write-Host 'git commit -m "polish: add diagrams lab templates and bootstrap github backlog"'
Write-Host "git push"
