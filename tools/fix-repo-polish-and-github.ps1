param(
    [string]$RepoPath = "C:\Users\BrianH\Documents\0000 - Portfolio\systems-engineer-field-guide",
    [string]$Owner = "brianhannigan",
    [string]$Repo = "systems-engineer-field-guide",
    [switch]$SkipGitHub
)

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message, [string]$Color = "Cyan")
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
    param([string]$Path, [string]$Content)
    $parent = Split-Path -Parent $Path
    if ($parent) { Ensure-Directory -Path $parent }
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8
}

function Move-IfExists {
    param([string]$SourcePath, [string]$DestinationPath)
    if (Test-Path -LiteralPath $SourcePath) {
        $destParent = Split-Path -Parent $DestinationPath
        Ensure-Directory -Path $destParent
        Move-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
        Write-Host "Moved: $SourcePath -> $DestinationPath" -ForegroundColor DarkGreen
    }
}

function Find-GhExe {
    $candidates = @(
        (Get-Command gh.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
        "C:\Program Files\GitHub CLI\gh.exe",
        "$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe"
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

    if ($candidates.Count -gt 0) {
        return $candidates[0]
    }

    $extra = @()
    $extra += Get-ChildItem "C:\Program Files" -Recurse -Filter gh.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    $extra += Get-ChildItem "$env:LOCALAPPDATA\Programs" -Recurse -Filter gh.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

    $extra = $extra | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    if ($extra.Count -gt 0) {
        return $extra[0]
    }

    return $null
}

function Invoke-Gh {
    param(
        [Parameter(Mandatory = $true)][string]$GhExe,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $output = & $GhExe @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        throw "gh command failed: $GhExe $($Arguments -join ' ')`n$output"
    }

    return $output
}

function Get-GhJson {
    param(
        [Parameter(Mandatory = $true)][string]$GhExe,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )
    $raw = Invoke-Gh -GhExe $GhExe -Arguments $Arguments
    if (-not $raw) { return $null }
    return ($raw | ConvertFrom-Json)
}

function Ensure-Label {
    param(
        [string]$GhExe,
        [string]$Name,
        [string]$Color,
        [string]$Description
    )

    $existing = Get-GhJson -GhExe $GhExe -Arguments @("label", "list", "--repo", "$Owner/$Repo", "--limit", "200", "--json", "name")
    if ($existing -and ($existing.name -contains $Name)) {
        Write-Host "Label already exists: $Name" -ForegroundColor DarkYellow
        return
    }

    Invoke-Gh -GhExe $GhExe -Arguments @(
        "label", "create", $Name,
        "--repo", "$Owner/$Repo",
        "--color", $Color,
        "--description", $Description
    ) | Out-Null

    Write-Host "Created label: $Name" -ForegroundColor DarkGreen
}

function Ensure-Issue {
    param(
        [string]$GhExe,
        [string]$Title,
        [string]$Body,
        [string[]]$Labels
    )

    $existing = Get-GhJson -GhExe $GhExe -Arguments @("issue", "list", "--repo", "$Owner/$Repo", "--state", "all", "--limit", "200", "--json", "title")
    if ($existing -and ($existing.title -contains $Title)) {
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

    Invoke-Gh -GhExe $GhExe -Arguments $args | Out-Null
    Write-Host "Created issue: $Title" -ForegroundColor DarkGreen
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

Set-Location -LiteralPath $RepoPath

$toolsPath      = Join-Path $RepoPath "tools"
$diagramsPath   = Join-Path $RepoPath "diagrams"
$assetsPath     = Join-Path $RepoPath "assets"
$planningPath   = Join-Path $RepoPath "planning"
$releasesPath   = Join-Path $RepoPath "releases"
$issuePath      = Join-Path $RepoPath ".github\ISSUE_TEMPLATE"
$labsPath       = Join-Path $RepoPath "labs"
$linuxLabsPath  = Join-Path $labsPath "linux"
$azureLabsPath  = Join-Path $labsPath "azure"
$terraformLabsPath = Join-Path $labsPath "terraform"
$stigLabsPath   = Join-Path $labsPath "stig"

Ensure-Directory -Path $toolsPath
Ensure-Directory -Path $diagramsPath
Ensure-Directory -Path (Join-Path $diagramsPath "infrastructure")
Ensure-Directory -Path (Join-Path $diagramsPath "workflows")
Ensure-Directory -Path (Join-Path $diagramsPath "security")
Ensure-Directory -Path $assetsPath
Ensure-Directory -Path $planningPath
Ensure-Directory -Path $releasesPath
Ensure-Directory -Path $issuePath
Ensure-Directory -Path $linuxLabsPath
Ensure-Directory -Path $azureLabsPath
Ensure-Directory -Path $terraformLabsPath
Ensure-Directory -Path $stigLabsPath

Write-Section "Moving builder scripts into tools"

$builderScripts = @(
    "build-final-files.ps1",
    "build-first-priority-files.ps1",
    "build-next-priority-files.ps1",
    "build-systems-engineer-field-guide.ps1",
    "build-training-labs-and-scripts.ps1",
    "repo-polish-pass.ps1",
    "github-bootstrap-issues-milestones-and-diagrams.ps1"
)

foreach ($scriptName in $builderScripts) {
    $source = Join-Path $RepoPath $scriptName
    $dest   = Join-Path $toolsPath $scriptName
    Move-IfExists -SourcePath $source -DestinationPath $dest
}

Write-Section "Writing polished README and repo docs"

$readme = @"
# Systems Engineer First 90 Days Field Guide

> A portfolio-grade systems administration field guide focused on Linux, Azure, Terraform, STIG hardening, patching, upgrades, vulnerability remediation, and practical single-VM lab workflows.

## What this project is

This repository is a structured operational handbook for ramping into a mixed infrastructure Systems Engineer role.

It is designed to show practical, production-minded thinking across:

- Red Hat Linux administration
- Windows/Linux mixed infrastructure support
- Azure infrastructure operations
- Terraform infrastructure as code
- STIG hardening and troubleshooting
- Server upgrades and patch validation
- Vulnerability remediation workflows
- Single-VM cyber range practice

## What this demonstrates

This project is intended to demonstrate:

- structured systems thinking
- operational troubleshooting discipline
- security-aware administration
- documentation maturity
- practical lab-driven learning
- compliance-aware infrastructure support

## Quick start

### Best place to start
- [First 30 Days Survival Plan](docs/01-first-30-days/README.md)
- [Linux Administration](docs/02-linux-admin/README.md)
- [Terraform](docs/03-terraform/README.md)
- [STIG Hardening](docs/05-stig-hardening/README.md)

### Core operational guides
- [Azure Infrastructure](docs/04-azure/README.md)
- [Server Upgrades](docs/06-server-upgrades/README.md)
- [Vulnerability Management](docs/07-vulnerability-management/README.md)
- [12 Week Plan](docs/08-12-week-plan/README.md)

### Hands-on sections
- [Cyber Range Labs](docs/09-cyber-range-labs/README.md)
- [Scripts Documentation](docs/10-scripts/README.md)
- [Daily Practice Routine](docs/11-daily-practice/30-minute-routine.md)
- [Six Month Team Expert Checklist](docs/12-six-month-roadmap/team-expert-checklist.md)

## Repository map

- `docs/` -> field guide chapters and operating notes
- `labs/` -> practical single-VM exercises
- `scripts/` -> example automation helpers
- `diagrams/` -> workflow and architecture visuals
- `assets/` -> screenshots, supporting graphics, and repo visuals
- `tools/` -> repo-building helper scripts

## Featured workflow diagrams
- [Infrastructure Discovery Workflow](diagrams/infrastructure/infrastructure-discovery-workflow.md)
- [Service Troubleshooting Workflow](diagrams/workflows/service-troubleshooting-workflow.md)
- [Change and Validation Workflow](diagrams/workflows/change-and-validation-workflow.md)
- [Vulnerability Remediation Lifecycle](diagrams/workflows/vulnerability-remediation-lifecycle.md)
- [STIG Troubleshooting Workflow](diagrams/security/stig-troubleshooting-workflow.md)

## Recommended GitHub topics

- systems-administration
- linux
- azure
- terraform
- stig
- vulnerability-management
- devops
- infrastructure
- cybersecurity
- runbooks

## Suggested About description

Portfolio-grade systems administration field guide covering Linux, Azure, Terraform, STIG hardening, upgrades, patching, and vulnerability remediation.

## Roadmap and planning
- [ROADMAP.md](ROADMAP.md)
- [PROJECT_BOARD.md](PROJECT_BOARD.md)
- [planning/ISSUE_CREATION_PLAN.md](planning/ISSUE_CREATION_PLAN.md)
- [planning/MILESTONE_PLAN.md](planning/MILESTONE_PLAN.md)
- [releases/v0.1.0-checklist.md](releases/v0.1.0-checklist.md)

## Author

Brian Hannigan  
GitHub: https://github.com/$Owner  
Repo: https://github.com/$Owner/$Repo
"@
Write-Utf8File -Path (Join-Path $RepoPath "README.md") -Content $readme

$aboutDoc = @'
# GitHub About Box

## Description
Portfolio-grade systems administration field guide covering Linux, Azure, Terraform, STIG hardening, upgrades, patching, and vulnerability remediation.

## Topics
- systems-administration
- linux
- azure
- terraform
- stig
- vulnerability-management
- devops
- infrastructure
- cybersecurity
- runbooks
'@
Write-Utf8File -Path (Join-Path $RepoPath "GITHUB_ABOUT.md") -Content $aboutDoc

$releaseChecklist = @'
# v0.1.0 Release Checklist

## Release Name
Initial Field Guide Scaffold + First Operational Content

## Required Before Release
- [ ] README polished
- [ ] builder scripts moved to `tools/`
- [ ] core docs reviewed
- [ ] diagrams present
- [ ] lab templates present
- [ ] repo metadata updated in GitHub UI
- [ ] backlog issues created
- [ ] first screenshot or exported diagram added

## Release Notes Draft
This release establishes the initial portfolio-grade scaffold and first-pass operational documentation for a systems administration field guide covering Linux, Azure, Terraform, STIG hardening, upgrades, patching, vulnerability remediation, and single-VM practice labs.
'@
Write-Utf8File -Path (Join-Path $releasesPath "v0.1.0-checklist.md") -Content $releaseChecklist

$issuesDoc = @'
# GitHub Issue Creation Plan

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

Write-Section "Writing diagrams"

$diagramIndex = @'
# Diagram Index

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
```
'@
Write-Utf8File -Path (Join-Path $diagramsPath "workflows\twelve-week-roadmap.md") -Content $weekFlow

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

Write-Section "Writing issue templates"

$docGap = @'
---
name: Documentation Gap
about: Track a missing or weak section in the field guide
title: "docs: improve [section-name]"
labels: documentation
assignees: ''
---

## Area
Which part of the repo needs improvement?

## Gap
What is missing, weak, or unclear?

## Expected result
What should this section contain when fixed?
'@
Write-Utf8File -Path (Join-Path $issuePath "documentation-gap.md") -Content $docGap

$portfolioEnhancement = @'
---
name: Portfolio Enhancement
about: Add polish, visuals, metadata, or portfolio-facing improvements
title: "polish: add [enhancement-name]"
labels: enhancement
assignees: ''
---

## Enhancement
What repo polish improvement is needed?

## Completion criteria
- [ ] implemented
- [ ] reviewed
'@
Write-Utf8File -Path (Join-Path $issuePath "portfolio-enhancement.md") -Content $portfolioEnhancement

$labEvidence = @'
---
name: Completed Lab Evidence
about: Track completion and documentation of a lab with evidence
title: "labs: document [lab-name] execution evidence"
labels: labs
assignees: ''
---

## Lab
Which lab was completed?

## Evidence captured
What output, screenshots, or notes were captured?

## Lessons learned
What broke, what worked, and what would you change next time?
'@
Write-Utf8File -Path (Join-Path $issuePath "completed-lab-evidence.md") -Content $labEvidence

Write-Section "GitHub labels and issues"

$ghExe = $null
if (-not $SkipGitHub) {
    $ghExe = Find-GhExe
    if (-not $ghExe) {
        Write-Host "gh.exe not found. Skipping GitHub labels/issues creation." -ForegroundColor Yellow
        $SkipGitHub = $true
    }
}

if (-not $SkipGitHub) {
    try {
        Invoke-Gh -GhExe $ghExe -Arguments @("auth", "status") | Out-Null

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
            @{ Name = "vuln-mgmt";     Color = "E99695"; Description = "Vulnerability management content" }
        )

        foreach ($label in $labels) {
            Ensure-Label -GhExe $ghExe -Name $label.Name -Color $label.Color -Description $label.Description
        }

        $issueList = @(
            @{ Title="polish: add repo banner and overview image"; Labels=@("enhancement"); Body="Add at least one polished visual asset to assets/ and reference it from README." },
            @{ Title="polish: update GitHub About metadata and topics"; Labels=@("enhancement"); Body="Set About description and topics from GITHUB_ABOUT.md." },
            @{ Title="docs: expand Linux services troubleshooting guide"; Labels=@("documentation","linux","operations"); Body="Deepen docs/02-linux-admin/services.md with real failure patterns and validation commands." },
            @{ Title="docs: expand Linux logging guide with practical scenarios"; Labels=@("documentation","linux","operations"); Body="Improve docs/02-linux-admin/logging.md with service failures, post-patch review, and security validation examples." },
            @{ Title="docs: expand Linux security guide with SELinux and firewall validation"; Labels=@("documentation","linux","security"); Body="Improve docs/02-linux-admin/security.md with SELinux, firewall, and SSH validation patterns." },
            @{ Title="docs: expand Terraform fundamentals with review workflow"; Labels=@("documentation","terraform","operations"); Body="Improve docs/03-terraform/fundamentals.md with review habits and admin mistakes to avoid." },
            @{ Title="docs: expand Terraform state management with drift notes"; Labels=@("documentation","terraform","operations"); Body="Improve docs/03-terraform/state-management.md with drift, import, and remote state cautions." },
            @{ Title="docs: add Terraform Azure VM example with validation"; Labels=@("documentation","terraform","azure"); Body="Expand docs/03-terraform/azure-examples.md with a complete small VM deployment example." },
            @{ Title="docs: expand Azure VM deployment guide"; Labels=@("documentation","azure","operations"); Body="Improve docs/04-azure/vm-deployment.md with portal + CLI workflow and validation steps." },
            @{ Title="docs: expand Azure networking troubleshooting guide"; Labels=@("documentation","azure","operations"); Body="Improve docs/04-azure/networking.md with NSG and routing troubleshooting examples." },
            @{ Title="docs: expand Azure RBAC guide with least privilege examples"; Labels=@("documentation","azure","security"); Body="Improve docs/04-azure/iam-rbac.md with scope and least-privilege examples." },
            @{ Title="docs: expand Azure monitoring guide with actionable alert patterns"; Labels=@("documentation","azure","operations"); Body="Improve docs/04-azure/monitoring.md with signal categories and alert hygiene." },
            @{ Title="docs: expand why systems break after hardening with concrete examples"; Labels=@("documentation","stig","security"); Body="Improve docs/05-stig-hardening/why-systems-break.md with concrete break/fix examples." },
            @{ Title="docs: expand STIG troubleshooting workflow with real break-fix scenarios"; Labels=@("documentation","stig","security","operations"); Body="Improve docs/05-stig-hardening/troubleshooting.md with SSH, permissions, and SELinux scenarios." },
            @{ Title="docs: add STIG evidence and exception examples"; Labels=@("documentation","stig","security"); Body="Improve docs/05-stig-hardening/compliance-workflow.md with evidence and exception examples." },
            @{ Title="docs: expand pre-upgrade checklist with real commands"; Labels=@("documentation","operations"); Body="Improve docs/06-server-upgrades/pre-upgrade-checklist.md with Linux validation commands and evidence ideas." },
            @{ Title="docs: expand rollback planning with decision thresholds"; Labels=@("documentation","operations"); Body="Improve docs/06-server-upgrades/rollback-planning.md with decision thresholds and restore evidence." },
            @{ Title="docs: expand vulnerability prioritization with risk-based examples"; Labels=@("documentation","vuln-mgmt","security"); Body="Improve docs/07-vulnerability-management/prioritization.md with real risk examples." },
            @{ Title="docs: expand remediation validation with before-after evidence"; Labels=@("documentation","vuln-mgmt","operations"); Body="Improve docs/07-vulnerability-management/remediation-validation.md with before/after evidence examples." },
            @{ Title="polish: prepare v0.1.0 release notes"; Labels=@("enhancement"); Body="Use releases/v0.1.0-checklist.md to prepare the first release." }
        )

        foreach ($issue in $issueList) {
            Ensure-Issue -GhExe $ghExe -Title $issue.Title -Body $issue.Body -Labels $issue.Labels
        }
    }
    catch {
        Write-Host "GitHub automation failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Local files were still written successfully." -ForegroundColor Yellow
    }
}

Write-Section "Validation" "Green"

$expectedFiles = @(
    "README.md",
    "GITHUB_ABOUT.md",
    "planning\ISSUE_CREATION_PLAN.md",
    "planning\MILESTONE_PLAN.md",
    "releases\v0.1.0-checklist.md",
    "diagrams\README.md",
    "diagrams\infrastructure\infrastructure-discovery-workflow.md",
    "diagrams\workflows\service-troubleshooting-workflow.md",
    "diagrams\workflows\change-and-validation-workflow.md",
    "diagrams\workflows\vulnerability-remediation-lifecycle.md",
    "diagrams\security\stig-troubleshooting-workflow.md",
    "diagrams\workflows\twelve-week-roadmap.md",
    ".github\ISSUE_TEMPLATE\documentation-gap.md",
    ".github\ISSUE_TEMPLATE\portfolio-enhancement.md",
    ".github\ISSUE_TEMPLATE\completed-lab-evidence.md",
    "labs\linux\lab-template.md"
)

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
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git status"
Write-Host "git add ."
Write-Host 'git commit -m "polish: fix repo presentation diagrams and github backlog"'
Write-Host "git push"
Write-Host ""
Write-Host "Then in GitHub UI, manually set About description/topics using GITHUB_ABOUT.md"

