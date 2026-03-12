param(
    [string]$RepoPath = "C:\Users\BrianH\Documents\0000 - Portfolio\systems-engineer-field-guide"
)

$ErrorActionPreference = "Stop"

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

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

$first30Path   = Join-Path $RepoPath "docs\01-first-30-days"
$dailyPath     = Join-Path $RepoPath "docs\11-daily-practice"
$roadmapPath   = Join-Path $RepoPath "docs\12-six-month-roadmap"
$diagramsPath  = Join-Path $RepoPath "diagrams"
$assetsPath    = Join-Path $RepoPath "assets"

Ensure-Directory -Path $first30Path
Ensure-Directory -Path $dailyPath
Ensure-Directory -Path $roadmapPath
Ensure-Directory -Path $diagramsPath
Ensure-Directory -Path (Join-Path $diagramsPath "infrastructure")
Ensure-Directory -Path (Join-Path $diagramsPath "workflows")
Ensure-Directory -Path (Join-Path $diagramsPath "security")
Ensure-Directory -Path $assetsPath

Write-Section "Building first 30 days files"

$first30Readme = @'
# 01 - First 30 Days Survival Plan

## Purpose
This section provides a practical onboarding and infrastructure discovery framework for the first month in a new systems administration role.

## Operational Focus
- What to learn immediately
- Questions to ask
- Systems to map
- Documentation to collect
- Red flags to watch for

## Recommended Usage
Use these files as your first-month operational guide. Treat them like an active notebook for discovery, ownership mapping, and risk identification.

## Files
- `infrastructure-discovery.md`
- `questions-to-ask.md`
- `red-flags.md`
- `documentation-checklist.md`
'@

$infraDiscovery = @'
# Infrastructure Discovery

## Purpose
Capture the process for understanding a mixed infrastructure environment quickly and safely.

## Discovery Priorities
- Linux server inventory
- Windows server inventory
- Azure resources
- Terraform repositories
- Monitoring tools
- Backup systems
- Identity and access model
- Patch and vulnerability tools

## What to Map
- Critical servers and applications
- Network dependencies
- Authentication dependencies
- DNS and certificate dependencies
- External integrations
- Backup and restore paths
- Owners and support contacts

## Questions to Answer
- What systems are mission critical?
- What systems are fragile?
- What systems are poorly documented?
- What is cloud-hosted vs on-prem?
- What depends on what?

## Deliverables to Build
- simple environment map
- critical systems list
- ownership list
- known-risk list
- operational dependency notes

## Validation
- You can explain the major environment components
- You know where the most critical systems live
- You know what needs careful handling first
'@

$questionsToAsk = @'
# Questions to Ask

## Purpose
Record the most important questions to ask when inheriting an environment built or managed by others.

## Operations Questions
- What breaks most often?
- What maintenance windows already exist?
- What systems must never go down?
- What tickets repeat constantly?
- What tasks are still manual?

## Infrastructure Questions
- Where are the Terraform repositories?
- Which systems are Azure-hosted?
- Which systems are Windows vs Linux?
- What systems are mid-upgrade or overdue?
- What systems have hidden dependencies?

## Security Questions
- What STIG baselines apply here?
- What vulnerability scanner is used?
- How often are scans run?
- What findings are currently open?
- What security changes caused breakage in the past?

## Ownership Questions
- Who owns each application?
- Who approves downtime?
- Who approves patching?
- Who is the escalation point for outages?
- Who knows the most about the current environment?

## Validation
- You have identified the right people to ask
- You have captured answers in a reusable format
- You know where uncertainty still exists
'@

$redFlags = @'
# Red Flags

## Purpose
Capture warning signs that indicate operational, security, or continuity risk.

## Documentation Red Flags
- no current diagrams
- no runbooks
- no known owner
- outdated patch records
- unclear backup status

## Technical Red Flags
- unsupported OS versions
- repeated service failures
- single points of failure
- shared admin accounts
- unknown scheduled tasks or scripts
- inconsistent naming or tagging

## Security Red Flags
- excessive admin access
- public exposure not understood
- old vulnerabilities still open
- hardening applied without evidence
- monitoring gaps
- local exceptions with no documentation

## Process Red Flags
- patching with no rollback plan
- upgrades with no validation checklist
- tribal knowledge only
- no clear incident workflow
- no evidence collection for completed changes

## Validation
- Red flags are documented, not just remembered
- High-risk issues are escalated or tracked
- Hidden fragility becomes visible early
'@

$docChecklist = @'
# Documentation Checklist

## Purpose
Track the documents and reference materials that should exist in a manageable infrastructure environment.

## Documents to Collect
- architecture diagrams
- server inventory
- application inventory
- backup and restore procedures
- patching schedule
- upgrade plans
- vulnerability remediation tracker
- monitoring overview
- escalation contact list
- admin access procedures
- Terraform repo locations
- STIG or hardening baselines

## Useful Evidence
- current service status snapshots
- screenshots of dashboards
- sample change tickets
- sample incident notes
- current vulnerability scan summaries

## What to Create If Missing
- critical system list
- owner/contact map
- upgrade validation checklist
- first-response troubleshooting guide
- dependency notes for fragile systems

## Validation
- You know which docs exist
- You know which docs are missing
- You have a prioritized list of what must be created first
'@

Write-Utf8File -Path (Join-Path $first30Path "README.md") -Content $first30Readme
Write-Utf8File -Path (Join-Path $first30Path "infrastructure-discovery.md") -Content $infraDiscovery
Write-Utf8File -Path (Join-Path $first30Path "questions-to-ask.md") -Content $questionsToAsk
Write-Utf8File -Path (Join-Path $first30Path "red-flags.md") -Content $redFlags
Write-Utf8File -Path (Join-Path $first30Path "documentation-checklist.md") -Content $docChecklist

Write-Section "Building daily practice files"

$dailyRoutine = @'
# 30 Minute Practice Routine

## Purpose
Provide a simple daily improvement loop that builds operational confidence without requiring huge blocks of study time.

## Structure
- 10 minutes Linux operations
- 10 minutes Terraform or Azure
- 10 minutes troubleshooting or documentation review

## Option A - Linux Focus Day
### 10 Minutes
- practice `systemctl`
- review `journalctl`
- run `df -h`, `lsblk`, `ss -tulpn`
- review one service failure pattern

### 10 Minutes
- practice one Bash or PowerShell snippet
- capture a command note in the repo

### 10 Minutes
- update one markdown file with something learned

## Option B - Terraform / Azure Focus Day
### 10 Minutes
- review Terraform commands or resource syntax
- review one Azure concept like NSGs, RBAC, or VM config

### 10 Minutes
- run one safe CLI query
- compare expected vs actual output

### 10 Minutes
- write one operational note or checklist item

## Option C - Security / STIG Focus Day
### 10 Minutes
- review one hardening concept
- review one common break/fix scenario

### 10 Minutes
- practice log or access validation commands

### 10 Minutes
- update the STIG troubleshooting notes

## Validation
- You touched the material daily
- Your repo grows over time
- You are improving recall and confidence without burnout
'@

Write-Utf8File -Path (Join-Path $dailyPath "30-minute-routine.md") -Content $dailyRoutine

Write-Section "Building six month roadmap files"

$teamExpert = @'
# Team Expert Checklist

## Purpose
Track the progression from new systems engineer to trusted team infrastructure expert over the first six months.

## Month 1 - Understand the Environment
- know the major systems
- know the critical servers
- know where documentation lives
- know the key people and owners
- know the major risks

## Month 2 - Build Linux and Troubleshooting Confidence
- troubleshoot services methodically
- read logs with confidence
- validate networking and disk state quickly
- document recurring issues

## Month 3 - Understand Security and Hardening Impact
- explain common STIG breakpoints
- validate hardening changes more safely
- understand open vulnerability trends
- contribute useful remediation notes

## Month 4 - Contribute to Change Execution
- support upgrades with pre/post validation
- think in terms of rollback planning
- use checklists consistently
- communicate technical risk clearly

## Month 5 - Build Automation and Consistency
- improve or create safe helper scripts
- reduce repetitive manual checks
- improve documentation quality
- standardize validation steps

## Month 6 - Become a Trusted Escalation Point
- understand common failure patterns
- know where the fragile systems are
- explain dependencies clearly
- help others troubleshoot faster
- be trusted to execute and validate change safely

## Validation
- You are no longer just following tasks
- You are identifying risks before they cause outages
- You are improving team knowledge, not just your own
'@

Write-Utf8File -Path (Join-Path $roadmapPath "team-expert-checklist.md") -Content $teamExpert

Write-Section "Building diagram and polish files"

$diagramsReadme = @'
# Diagrams

## Purpose
This folder holds visual assets that explain the environment, workflows, and operational decision paths.

## Suggested Diagram Types
- infrastructure discovery workflow
- service troubleshooting workflow
- patch / upgrade workflow
- vulnerability remediation lifecycle
- STIG break / validate / fix flow
- 12-week training roadmap

## Folder Structure
- `infrastructure/`
- `workflows/`
- `security/`

## Recommended Format
- Mermaid in markdown for fast iteration
- PNG or SVG exports for polished portfolio visuals
'@

$infraMermaid = @'
# Infrastructure Discovery Workflow

```mermaid
flowchart TD
    A[Collect system inventory] --> B[Identify critical systems]
    B --> C[Map dependencies]
    C --> D[Identify owners]
    D --> E[Review monitoring and backups]
    E --> F[Document red flags]
    F --> G[Build first priority action list]
```
'@

$workflowMermaid = @'
# Change and Validation Workflow

```mermaid
flowchart TD
    A[Review change request] --> B[Confirm dependencies]
    B --> C[Confirm backup or rollback]
    C --> D[Execute planned change]
    D --> E[Run technical validation]
    E --> F[Run functional validation]
    F --> G[Capture evidence]
    G --> H[Close or escalate]
```
'@

$securityMermaid = @'
# STIG Troubleshooting Workflow

```mermaid
flowchart TD
    A[Hardening change applied] --> B[Service or access issue appears]
    B --> C[Check service status]
    C --> D[Review logs and denials]
    D --> E[Identify exact control impact]
    E --> F[Apply minimal safe fix]
    F --> G[Re-test]
    G --> H[Document evidence or exception]
```
'@

$assetsReadme = @'
# Assets

## Purpose
This folder stores visual materials used to make the repo more professional and easier to navigate.

## Suggested Assets
- repo banner
- overview image
- workflow screenshots
- exported diagrams
- architecture visuals

## Portfolio Tip
Use consistent naming and keep source files if you plan to refine the visuals later.
'@

$repoOverview = @'
# Repo Overview Notes

## Purpose
Use this file to track how the repo should present itself as a portfolio-grade infrastructure project.

## Messaging Themes
- operational field guide
- enterprise infrastructure support
- secure systems operations
- compliance-aware administration
- practical lab-driven learning
- single-VM training architecture

## README Improvement Ideas
- add badges
- add quick navigation links
- add repo map
- add highlighted learning paths
- add diagram previews

## Portfolio Angle
This repository should show:
- structured systems thinking
- disciplined troubleshooting
- security awareness
- documentation maturity
- practical operational readiness
'@

Write-Utf8File -Path (Join-Path $diagramsPath "README.md") -Content $diagramsReadme
Write-Utf8File -Path (Join-Path $diagramsPath "infrastructure\infrastructure-discovery-workflow.md") -Content $infraMermaid
Write-Utf8File -Path (Join-Path $diagramsPath "workflows\change-and-validation-workflow.md") -Content $workflowMermaid
Write-Utf8File -Path (Join-Path $diagramsPath "security\stig-troubleshooting-workflow.md") -Content $securityMermaid
Write-Utf8File -Path (Join-Path $assetsPath "README.md") -Content $assetsReadme
Write-Utf8File -Path (Join-Path $assetsPath "repo-overview-notes.md") -Content $repoOverview

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\01-first-30-days\README.md",
    "docs\01-first-30-days\infrastructure-discovery.md",
    "docs\01-first-30-days\questions-to-ask.md",
    "docs\01-first-30-days\red-flags.md",
    "docs\01-first-30-days\documentation-checklist.md",
    "docs\11-daily-practice\30-minute-routine.md",
    "docs\12-six-month-roadmap\team-expert-checklist.md",
    "diagrams\README.md",
    "diagrams\infrastructure\infrastructure-discovery-workflow.md",
    "diagrams\workflows\change-and-validation-workflow.md",
    "diagrams\security\stig-troubleshooting-workflow.md",
    "assets\README.md",
    "assets\repo-overview-notes.md"
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
Write-Host "Validation passed. All remaining first-phase documents and polish files were created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git add ."
Write-Host 'git commit -m "docs: build first 30 days daily practice roadmap and diagram docs"'
Write-Host "git push"

