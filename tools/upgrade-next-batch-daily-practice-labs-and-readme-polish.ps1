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

    [System.IO.File]::WriteAllText(
        $Path,
        $Content,
        (New-Object System.Text.UTF8Encoding($false))
    )
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

$dailyPath   = Join-Path $RepoPath "docs\11-daily-practice"
$labsPath    = Join-Path $RepoPath "docs\09-cyber-range-labs"
$roadmapPath = Join-Path $RepoPath "docs\12-six-month-roadmap"
$assetsPath  = Join-Path $RepoPath "assets"
$repoRoot    = $RepoPath

Ensure-Directory -Path $dailyPath
Ensure-Directory -Path $labsPath
Ensure-Directory -Path $roadmapPath
Ensure-Directory -Path $assetsPath

Write-Section "Upgrading daily practice routine"

$dailyRoutine = @'
# 30 Minute Practice Routine

## Purpose
This routine is designed to make daily improvement sustainable. It is intentionally short enough to fit into a real workday while still building meaningful repetition across Linux, Azure, Terraform, security, and troubleshooting.

## Why This Matters
Skill growth for infrastructure work comes from repeated exposure, not occasional marathon study sessions. A daily rhythm builds familiarity, recall speed, and confidence.

## Core Structure
Use a simple 30-minute block:

- 10 minutes: Linux or systems fundamentals
- 10 minutes: Azure or Terraform
- 10 minutes: troubleshooting, notes, or documentation improvement

## Option A - Linux Operations Day

### 10 Minutes: Core Command Repetition
Practice commands such as:

    systemctl --failed
    systemctl status sshd
    journalctl -p err -b
    ss -tulpn
    df -h
    lsblk

### 10 Minutes: One Focus Topic
Choose one:
- service management
- log analysis
- disk troubleshooting
- SSH validation
- permissions and ownership

### 10 Minutes: Capture the Learning
Update one file in the repo:
- add a command note
- document a repeated failure pattern
- add a validation checklist
- improve a quick runbook

## Option B - Azure / Terraform Day

### 10 Minutes: Read or Review
Pick one:
- Azure VM settings
- NSG rules
- RBAC concepts
- Terraform provider/resource structure
- Terraform plan review habits

### 10 Minutes: Run a Safe Command
Examples:

    az vm list -o table
    az network nsg list -o table
    terraform fmt
    terraform validate
    terraform plan

### 10 Minutes: Write One Useful Note
Examples:
- common Azure troubleshooting path
- what a Terraform plan is really showing
- safe review checklist
- drift or scope reminder

## Option C - Security / STIG Day

### 10 Minutes: Review a Security Topic
Choose one:
- SELinux
- firewalld
- STIG break/fix scenarios
- service-account permissions
- vulnerability prioritization logic

### 10 Minutes: Run Validation Commands
Examples:

    getenforce
    ausearch -m avc -ts recent
    firewall-cmd --list-all
    ls -l /path/to/file
    sudo -l

### 10 Minutes: Capture Evidence or a Note
Examples:
- note a denial pattern
- document a compensating control idea
- improve the STIG troubleshooting guide

## Option D - Incident Thinking Day

### 10 Minutes: Pick a Failure Mode
Examples:
- service not starting
- no port listening
- disk full
- SSH access broken
- package update causes restart issue

### 10 Minutes: Write the Triage Order
Document what you would run first, second, and third.

### 10 Minutes: Improve the Runbook
Update the most relevant doc with a practical workflow.

## Weekly Rotation Example
- Monday: Linux
- Tuesday: Azure
- Wednesday: Terraform
- Thursday: Security / STIG
- Friday: Incident review and documentation

## Minimum Success Criteria
A successful practice block means:
- you touched the material
- you ran something or reviewed something concrete
- you captured one useful operational note

## How to Use This Repo With the Routine
Each session should leave a trace:
- one updated markdown file
- one lab note
- one command example
- one clarified workflow
- one validation checklist

## Quick Daily Template
Use this simple format in your head or notebook:

- What am I focusing on today?
- What command or concept did I review?
- What did I learn?
- What doc should I update?

## Quick Runbook
- 10 minutes on commands or platform review
- 10 minutes on one focused topic
- 10 minutes documenting what matters
'@
Write-Utf8File -Path (Join-Path $dailyPath "30-minute-routine.md") -Content $dailyRoutine

Write-Section "Upgrading cyber range labs README"

$labsReadme = @'
# Cyber Range Labs

## Purpose
This section provides practical single-VM exercises that simulate the kinds of infrastructure issues a systems engineer is likely to face in a mixed Linux, Azure, Terraform, and security-conscious environment.

## Design Constraint
These labs are designed around a one-VM-at-a-time model. That means the focus is on:
- disciplined troubleshooting
- validation steps
- evidence capture
- realistic admin workflows
- safe failure simulation

## Lab Philosophy
A good lab should do more than show that a command works. It should help you practice:
- identifying symptoms
- narrowing scope
- validating assumptions
- restoring function safely
- documenting what happened

## Recommended Lab Execution Pattern

### 1. Define the Starting State
Record:
- hostname
- uptime
- network state
- disk state
- current service health

### 2. Introduce or Identify a Problem
Examples:
- stop a service
- break a config file
- consume disk space in a safe area
- change a firewall rule
- simulate a patch cycle
- review Terraform plan behavior

### 3. Triage Methodically
Use:
- service status
- logs
- ports
- permissions
- system health
- access path validation

### 4. Apply the Smallest Safe Fix
Do not â€œfix everything.â€ Correct the actual cause and validate.

### 5. Capture Evidence
Every lab should record:
- commands run
- what proved the issue
- what fixed the issue
- how success was validated

## Recommended Lab Categories

### Linux Operations
- baseline validation
- service recovery
- disk pressure
- patching
- logging review

### Security / STIG
- access break after hardening
- SELinux denial review
- firewall misconfiguration
- service account permission issue

### Terraform / Azure
- plan review
- state awareness
- VM deployment review
- RBAC review
- NSG validation

## How to Get the Most Value
Do not just execute commands. Ask:
- what was the symptom?
- what evidence narrowed it down?
- what alternative causes did I rule out?
- what would I document if this happened at work?

## Minimum Lab Output
At the end of each lab, you should have:
- a short narrative of the problem
- command evidence
- the recovery step
- the validation result
- one lesson learned

## Suggested Next Step
As you complete labs, update the corresponding docs in this repo so your field guide becomes richer over time.
'@
Write-Utf8File -Path (Join-Path $labsPath "README.md") -Content $labsReadme

Write-Section "Upgrading six month roadmap"

$teamExpertChecklist = @'
# Team Expert Checklist

## Purpose
This roadmap tracks the transition from new team member to trusted infrastructure operator over six months.

## What "Team Expert" Means
It does not mean knowing everything. It means you become someone who:
- understands the environment structure
- troubleshoots methodically
- sees risk before it becomes outage
- executes changes safely
- documents what others can reuse

## Month 1 - Understand the Environment
Focus:
- inventory major systems
- identify Linux, Windows, Azure, and Terraform touchpoints
- identify critical services and dependencies
- learn who owns what
- identify weak documentation and red flags

Success looks like:
- you can explain the environment at a high level
- you know where the fragile systems are
- you know where to look first during a problem

## Month 2 - Build Linux Confidence
Focus:
- service troubleshooting
- log analysis
- disk and network checks
- file permissions and access validation
- repeated command fluency

Success looks like:
- you are not guessing when a Linux system misbehaves
- you have repeatable triage habits
- your notes and docs are growing

## Month 3 - Understand Security and Hardening Impact
Focus:
- STIG break/fix patterns
- SELinux and firewall behavior
- service account and access issues
- vulnerability risk context

Success looks like:
- you can explain why hardening broke something
- you know how to validate secure function instead of just secure configuration
- you contribute useful risk-aware notes

## Month 4 - Contribute to Change Execution
Focus:
- pre-upgrade preparation
- rollback thinking
- post-change validation
- patching discipline
- evidence capture

Success looks like:
- you can help plan a change, not just watch it happen
- you know what must be validated before and after
- you think in terms of recovery as well as deployment

## Month 5 - Build Consistency and Automation
Focus:
- safer helper scripts
- repeated health checks
- improved runbooks
- reduced manual guesswork
- cleaner validation patterns

Success looks like:
- your scripts save time without hiding truth
- your notes look more like operational documentation than raw study notes
- others can follow what you wrote

## Month 6 - Become a Trusted Escalation Point
Focus:
- recognizing failure patterns quickly
- understanding common dependencies
- communicating technical risk clearly
- being trusted during incidents or changes
- knowing when to escalate and when to act

Success looks like:
- teammates ask you because you are reliable, not because you are loud
- your troubleshooting is evidence-based
- your documentation improves team capability

## Ongoing Habits
Across all six months:
- keep updating the repo
- turn incidents into reusable notes
- prefer validation over assumption
- prefer clarity over cleverness
- document what future-you will need

## Final Check
By the end of six months, aim to be able to answer:
- what are the critical systems?
- what breaks most often?
- what are the riskiest changes?
- how do we validate health after change?
- what do we do first when something fails?
'@
Write-Utf8File -Path (Join-Path $roadmapPath "team-expert-checklist.md") -Content $teamExpertChecklist

Write-Section "Adding asset planning notes"

$assetNotes = @'
# Asset and Screenshot Plan

## Purpose
Use this file to plan the visuals that will make the repo feel more like a flagship infrastructure portfolio project.

## Highest Priority Assets
- repo overview image
- infrastructure discovery workflow export
- change and validation workflow export
- STIG troubleshooting workflow export
- one screenshot of completed lab notes
- one screenshot of a polished doc section

## Recommended Naming
- `repo-overview.png`
- `infrastructure-discovery-workflow.png`
- `change-validation-workflow.png`
- `stig-troubleshooting-workflow.png`
- `linux-lab-evidence.png`

## Visual Goals
Each visual should support one of these:
- explain the system
- show workflow maturity
- show lab evidence
- make the repo easier to skim
- improve portfolio presentation
'@
Write-Utf8File -Path (Join-Path $assetsPath "ASSET_PLAN.md") -Content $assetNotes

Write-Section "Polishing root README"

$readme = @'
# Systems Engineer First 90 Days Field Guide

> A portfolio-grade systems administration field guide focused on Linux, Azure, Terraform, STIG hardening, patching, upgrades, vulnerability remediation, and practical single-VM lab workflows.

## What this project is
This repository is a structured operational handbook for ramping into a mixed infrastructure Systems Engineer role.

It is designed to demonstrate practical, production-minded thinking across:
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

## Featured areas
If you are reviewing this repo quickly, start here:
- Linux service troubleshooting
- STIG troubleshooting and hardening impact
- Terraform operator review workflow
- Azure monitoring and networking validation
- vulnerability prioritization and remediation validation

## Repository map
- `docs/` -> field guide chapters and operational notes
- `labs/` -> practical single-VM exercises
- `scripts/` -> example automation helpers
- `diagrams/` -> workflow and architecture visuals
- `assets/` -> screenshots, planning notes, and supporting graphics
- `planning/` -> issue and milestone planning
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
GitHub: https://github.com/brianhannigan  
Repo: https://github.com/brianhannigan/systems-engineer-field-guide
'@
Write-Utf8File -Path (Join-Path $repoRoot "README.md") -Content $readme

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\11-daily-practice\30-minute-routine.md",
    "docs\09-cyber-range-labs\README.md",
    "docs\12-six-month-roadmap\team-expert-checklist.md",
    "assets\ASSET_PLAN.md",
    "README.md"
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
Write-Host "Validation passed. Daily practice, labs, roadmap, asset plan, and README polish were applied successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git status"
Write-Host "git add ."
Write-Host 'git commit -m "docs: upgrade daily practice labs roadmap and readme polish docs"'
Write-Host "git push"

