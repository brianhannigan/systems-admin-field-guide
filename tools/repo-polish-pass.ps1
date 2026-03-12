param(
    [string]$RepoPath = "C:\Users\BrianH\Documents\0000 - Portfolio\systems-engineer-field-guide",
    [string]$RepoName = "systems-engineer-field-guide",
    [string]$GitHubUser = "brianhannigan",
    [string]$AuthorName = "Brian Hannigan",
    [switch]$InitializeGitkeepFiles
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

function Move-IfExists {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    if (Test-Path -LiteralPath $SourcePath) {
        $destParent = Split-Path -Parent $DestinationPath
        Ensure-Directory -Path $destParent
        Move-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
        Write-Host "Moved: $SourcePath -> $DestinationPath" -ForegroundColor DarkGreen
    }
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

$toolsPath       = Join-Path $RepoPath "tools"
$githubPath      = Join-Path $RepoPath ".github"
$issuePath       = Join-Path $githubPath "ISSUE_TEMPLATE"
$workflowsPath   = Join-Path $githubPath "workflows"
$releasesPath    = Join-Path $RepoPath "releases"
$docsPath        = Join-Path $RepoPath "docs"
$diagramsPath    = Join-Path $RepoPath "diagrams"
$assetsPath      = Join-Path $RepoPath "assets"

Ensure-Directory -Path $toolsPath
Ensure-Directory -Path $issuePath
Ensure-Directory -Path $workflowsPath
Ensure-Directory -Path $releasesPath
Ensure-Directory -Path $docsPath
Ensure-Directory -Path $diagramsPath
Ensure-Directory -Path $assetsPath

if ($InitializeGitkeepFiles) {
    foreach ($folder in @($toolsPath, $releasesPath, $issuePath, $workflowsPath)) {
        $gitkeep = Join-Path $folder ".gitkeep"
        if (-not (Test-Path -LiteralPath $gitkeep)) {
            New-Item -ItemType File -Path $gitkeep -Force | Out-Null
        }
    }
}

Write-Section "Moving builder scripts out of repo root"

$builderScripts = @(
    "build-first-priority-files.ps1",
    "build-next-priority-files.ps1",
    "build-training-labs-and-scripts.ps1",
    "build-systems-engineer-field-guide.ps1",
    "build-last-phase-files.ps1",
    "repo-polish-pass.ps1"
)

foreach ($scriptName in $builderScripts) {
    $source = Join-Path $RepoPath $scriptName
    $dest   = Join-Path $toolsPath $scriptName
    if ($scriptName -ne "repo-polish-pass.ps1") {
        Move-IfExists -SourcePath $source -DestinationPath $dest
    }
}

Write-Section "Writing improved root README"

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
- [Change and Validation Workflow](diagrams/workflows/change-and-validation-workflow.md)
- [STIG Troubleshooting Workflow](diagrams/security/stig-troubleshooting-workflow.md)

## Recommended development order

1. Finish the STIG troubleshooting section
2. Deepen Linux service and logging docs
3. Expand Terraform fundamentals and Azure examples
4. Add polished lab evidence and screenshots
5. Add issue-driven backlog and milestone tracking
6. Polish diagrams and release the first repo version

## Recommended GitHub topics

Add these manually in the GitHub UI:

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

Use this in the GitHub About box:

`Portfolio-grade systems administration field guide covering Linux, Azure, Terraform, STIG hardening, upgrades, patching, and vulnerability remediation.`

## Roadmap and planning
- [ROADMAP.md](ROADMAP.md)
- [PROJECT_BOARD.md](PROJECT_BOARD.md)
- [docs/MASTER_OUTLINE.md](docs/MASTER_OUTLINE.md)
- [releases/v0.1.0-checklist.md](releases/v0.1.0-checklist.md)

## Author

$AuthorName  
GitHub: https://github.com/$GitHubUser  
Repo: https://github.com/$GitHubUser/$RepoName
"@

Write-Utf8File -Path (Join-Path $RepoPath "README.md") -Content $readme

Write-Section "Writing repo polish helper documents"

$aboutDoc = @"
# GitHub About Box

## Suggested Description
Portfolio-grade systems administration field guide covering Linux, Azure, Terraform, STIG hardening, upgrades, patching, and vulnerability remediation.

## Suggested Topics
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

## Suggested Website
Leave blank for now, or point to the repo itself until you have a project landing page.

## Suggested Pinned Repo Positioning
Use this repository as a documentation-heavy infrastructure and operations showcase that complements your code-centric projects.
"@
Write-Utf8File -Path (Join-Path $RepoPath "GITHUB_ABOUT.md") -Content $aboutDoc

$releaseChecklist = @'
# v0.1.0 Release Checklist

## Release Name
Initial Field Guide Scaffold + First Operational Content

## Goal
Publish the first clean, portfolio-ready version of the repository.

## Required Before Release
- [ ] README polished
- [ ] builder scripts moved to `tools/`
- [ ] first 30 days docs reviewed
- [ ] Linux docs reviewed
- [ ] Terraform docs reviewed
- [ ] STIG docs reviewed
- [ ] Azure docs present
- [ ] upgrade docs present
- [ ] vulnerability docs present
- [ ] training plan docs present
- [ ] cyber range labs present
- [ ] diagrams present
- [ ] repo metadata updated in GitHub UI
- [ ] at least 10 backlog issues created
- [ ] one screenshot or exported diagram added to `assets/`

## Release Notes Draft
This release establishes the initial portfolio-grade scaffold and first-pass operational documentation for a systems administration field guide covering Linux, Azure, Terraform, STIG hardening, upgrades, patching, vulnerability remediation, and single-VM practice labs.
'@
Write-Utf8File -Path (Join-Path $releasesPath "v0.1.0-checklist.md") -Content $releaseChecklist

$issueSeedList = @'
# Seed Issue List

Create these as GitHub issues and assign milestones later.

## README / Polish
- Improve README with final featured sections
- Add repo banner or overview image
- Add screenshot or exported diagram to assets
- Update GitHub About metadata and topics
- Cut first release v0.1.0

## Linux
- Expand Linux services troubleshooting guide
- Expand Linux logging guide with practical scenarios
- Expand Linux security guide with SELinux and firewall validation
- Add Linux automation examples with safer validation patterns

## Terraform
- Expand Terraform fundamentals with real admin review notes
- Expand Terraform state management with drift handling notes
- Add Azure VM deployment Terraform example with validation flow
- Add Terraform troubleshooting examples from real plan/apply errors

## Azure
- Expand Azure VM deployment guide with portal + CLI workflow
- Expand Azure networking troubleshooting guide
- Expand Azure RBAC guide with least-privilege examples
- Expand Azure monitoring guide with actionable alert patterns

## STIG
- Expand why systems break after hardening with concrete examples
- Expand STIG troubleshooting with repeatable workflow examples
- Add STIG evidence and exception handling examples

## Upgrades / Vulnerabilities
- Expand pre-upgrade checklist with real validation commands
- Expand rollback planning with decision thresholds
- Expand vulnerability prioritization with risk-based examples
- Expand remediation validation with before/after evidence examples

## Labs / Diagrams
- Add completed Linux baseline lab execution notes
- Add completed service failure lab execution notes
- Add completed patching lab execution notes
- Add exported diagram images to assets
'@
Write-Utf8File -Path (Join-Path $RepoPath "ISSUE_SEED_LIST.md") -Content $issueSeedList

Write-Section "Writing GitHub issue templates"

$bugTemplate = @'
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

## Notes
Add real-world examples, commands, or evidence ideas here.
'@
Write-Utf8File -Path (Join-Path $issuePath "documentation-gap.md") -Content $bugTemplate

$featureTemplate = @'
---
name: Portfolio Enhancement
about: Add polish, visuals, metadata, or portfolio-facing improvements
title: "polish: add [enhancement-name]"
labels: enhancement
assignees: ''
---

## Enhancement
What portfolio or repo polish improvement is needed?

## Why it matters
How does this improve presentation, clarity, or credibility?

## Completion criteria
- [ ] implemented
- [ ] reviewed
- [ ] visible from root repo experience
'@
Write-Utf8File -Path (Join-Path $issuePath "portfolio-enhancement.md") -Content $featureTemplate

$labTemplate = @'
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
What command output, screenshots, or notes were captured?

## Lessons learned
What broke, what worked, and what would you change next time?

## Completion criteria
- [ ] execution documented
- [ ] validation documented
- [ ] follow-up notes added to docs
'@
Write-Utf8File -Path (Join-Path $issuePath "completed-lab-evidence.md") -Content $labTemplate

Write-Section "Writing optional milestone planner"

$milestones = @'
# Suggested Milestones

## Milestone 1 - Repo Foundation and Polish
- README upgrade
- About metadata
- Topics
- release checklist
- issue backlog
- move builder scripts to tools

## Milestone 2 - Core Linux + STIG Depth
- Linux services
- logging
- security
- STIG break/fix examples
- STIG evidence and exceptions

## Milestone 3 - Terraform + Azure Operations
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
- first release
'@
Write-Utf8File -Path (Join-Path $RepoPath "MILESTONES.md") -Content $milestones

Write-Section "Writing polished diagram notes"

$diagramPlan = @'
# Diagram Build Plan

## Highest Priority Diagrams
1. Infrastructure discovery workflow
2. Service troubleshooting workflow
3. Patch / upgrade workflow
4. Vulnerability remediation lifecycle
5. STIG break / validate / fix flow
6. 12-week training roadmap

## Recommended Output Strategy
- draft in Mermaid first
- export polished PNG or SVG later
- store final exports in `assets/`
- keep editable markdown in `diagrams/`

## Recommended First Asset Names
- assets/repo-overview.png
- assets/infrastructure-discovery-workflow.png
- assets/change-validation-workflow.png
- assets/stig-troubleshooting-workflow.png
'@
Write-Utf8File -Path (Join-Path $diagramsPath "DIAGRAM_BUILD_PLAN.md") -Content $diagramPlan

Write-Section "Writing tools README"

$toolsReadme = @'
# Tools

This folder contains helper scripts used to scaffold, expand, and polish the repository.

These scripts support repo development, but they are intentionally separated from the root so the main project presentation emphasizes the field guide itself rather than scaffolding utilities.

## Suggested usage
- run builders intentionally
- review file changes before commit
- keep generated documentation aligned with real-world notes
'@
Write-Utf8File -Path (Join-Path $toolsPath "README.md") -Content $toolsReadme

Write-Section "Validation"

$expectedFiles = @(
    "README.md",
    "GITHUB_ABOUT.md",
    "ISSUE_SEED_LIST.md",
    "MILESTONES.md",
    "releases\v0.1.0-checklist.md",
    "diagrams\DIAGRAM_BUILD_PLAN.md",
    "tools\README.md",
    ".github\ISSUE_TEMPLATE\documentation-gap.md",
    ".github\ISSUE_TEMPLATE\portfolio-enhancement.md",
    ".github\ISSUE_TEMPLATE\completed-lab-evidence.md"
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
Write-Host "Validation passed. Repo polish files were created successfully." -ForegroundColor Green

Write-Host ""
Write-Host "Manual GitHub UI tasks still needed:" -ForegroundColor Yellow
Write-Host "1. Set repo description from GITHUB_ABOUT.md"
Write-Host "2. Add repo topics from GITHUB_ABOUT.md"
Write-Host "3. Create milestone entries from MILESTONES.md"
Write-Host "4. Create issues using ISSUE_SEED_LIST.md"
Write-Host "5. Create first release using releases\v0.1.0-checklist.md"

Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git status"
Write-Host "git add ."
Write-Host 'git commit -m "polish: improve repo presentation add planning and move builder scripts"'
Write-Host "git push"

