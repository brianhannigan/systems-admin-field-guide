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

function Get-FileContent {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw
}

function Set-FileContent {
    param(
        [string]$Path,
        [string]$Content
    )

    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    Write-Host "Updated file: $Path" -ForegroundColor Green
}

function Ensure-Contains {
    param(
        [string]$Content,
        [string]$Marker,
        [string]$Block,
        [switch]$ReplaceIfExists
    )

    if ($Content -match [regex]::Escape($Marker)) {
        if ($ReplaceIfExists) {
            return $Content
        }

        Write-Host "Section already present: $Marker" -ForegroundColor DarkGray
        return $Content
    }

    return ($Content.TrimEnd() + "`r`n`r`n" + $Block.Trim() + "`r`n")
}

function Insert-After-FirstMatch {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$InsertionBlock
    )

    $match = [regex]::Match($Content, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if (-not $match.Success) {
        return ($Content.TrimEnd() + "`r`n`r`n" + $InsertionBlock.Trim() + "`r`n")
    }

    $insertAt = $match.Index + $match.Length
    return $Content.Substring(0, $insertAt) + "`r`n`r`n" + $InsertionBlock.Trim() + "`r`n" + $Content.Substring($insertAt)
}

function Remove-SectionByHeader {
    param(
        [string]$Content,
        [string]$Header
    )

    $escapedHeader = [regex]::Escape($Header)
    $pattern = "(?ms)^\Q$Header\E\s*$.*?(?=^\#\#\s|\z)"
    return [regex]::Replace($Content, $pattern, '').TrimEnd() + "`r`n"
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

Write-Section "Loading README"

$readme = Get-FileContent -Path $readmePath

Write-Section "Preparing README upgrade blocks"

$howToUseBlock = @"
## How to Use This Guide

This field guide is designed to help a systems engineer ramp quickly, operate confidently, and document work in a way that is useful in real enterprise and government environments.

### Best Way to Use This Repository

1. Start with the reading order below.
2. Learn the operational lifecycle used throughout the guide.
3. Review the scenarios and playbooks before touching production systems.
4. Use the reference docs and cheat sheets during live work.
5. Practice regularly in the labs so the workflows become natural.

### Who This Guide Is For

- Systems Engineers
- Systems Administrators
- Infrastructure Engineers
- Platform / Operations Engineers
- Security-minded administrators supporting hardened environments

### Core Navigation

- [Suggested Reading Order](docs/reference/suggested-reading-order.md)
- [Systems Engineer Cheat Sheet](docs/reference/systems-engineer-cheat-sheet.md)
- [Operational Model](docs/workflows/systems-engineer-operational-model.md)
- [Security Incident Workflow](docs/workflows/security-incident-workflow.md)
- [Engineering Metrics](docs/metrics/engineering-metrics.md)
"@

$readingOrderBlock = @"
## Suggested Reading Order

Follow this sequence to get the most value from the guide.

### Step 1 — Start Here
- [How to Use This Guide](docs/reference/how-to-use-this-guide.md)
- [Suggested Reading Order](docs/reference/suggested-reading-order.md)

### Step 2 — Understand the Operational Model
- [Systems Engineer Operational Model](docs/workflows/systems-engineer-operational-model.md)

### Step 3 — Build Core Operations Muscle
Review your Linux, Windows, networking, service validation, and troubleshooting documentation.

### Step 4 — Review Cloud and Automation
Study your Azure and Terraform material together so the cloud and IaC workflows feel connected.

### Step 5 — Study Hardening and Compliance
Work through STIG, patching, and remediation topics with operational impact in mind.

### Step 6 — Practice Real Scenarios
- [Scenarios](docs/scenarios/)
- [Playbooks](docs/playbooks/)

### Step 7 — Review Portfolio-Grade Evidence
- [Case Studies](docs/case-studies/)
- [Labs](docs/labs/)
- [Reference](docs/reference/)
"@

$operationalModelBlock = @"
## Systems Engineer Operational Model

The repository follows a practical systems engineering lifecycle:

~~~text
Infrastructure Discovery
        ↓
Documentation
        ↓
Hardening & Compliance
        ↓
Automation (Terraform / Scripts)
        ↓
Monitoring & Logging
        ↓
Vulnerability Remediation
        ↓
Validation & Continuous Improvement
~~~

Supporting documentation:

- [Operational Model](docs/workflows/systems-engineer-operational-model.md)
- [Security Incident Workflow](docs/workflows/security-incident-workflow.md)
- [Engineering Metrics](docs/metrics/engineering-metrics.md)
- [Diagram Placeholder](diagrams/placeholders/systems-engineer-operational-model.md)
"@

$practiceBlock = @"
## Practice and Real-World Operations

These sections turn the repo from notes into an operational field guide.

### Scenarios
Use scenarios to understand how real issues unfold in hardened and change-controlled environments.

- [Scenarios Folder](docs/scenarios/)

### Playbooks
Use playbooks for repeatable troubleshooting and recovery steps.

- [Playbooks Folder](docs/playbooks/)

### Case Studies
Use case studies to document real implementations, outcomes, and lessons learned.

- [Case Studies Folder](docs/case-studies/)

### Labs
Use labs to rehearse workflows before you need them in production.

- [Labs Folder](docs/labs/)

### Quick Reference
Use the reference section during day-to-day engineering work.

- [Reference Folder](docs/reference/)
- [Systems Engineer Cheat Sheet](docs/reference/systems-engineer-cheat-sheet.md)
"@

$repoMapBlock = @"
## Repository Map

~~~text
docs/
├── case-studies/   # portfolio-grade implementation writeups
├── labs/           # hands-on practice walkthroughs
├── metrics/        # operational measurement guidance
├── playbooks/      # repeatable troubleshooting procedures
├── reference/      # quick reference and navigation docs
├── scenarios/      # real-world issue simulations
└── workflows/      # lifecycle and security workflow docs

diagrams/
└── placeholders/   # planned visual assets to convert into polished diagrams
~~~
"@

$priorityRoadmapBlock = @"
## Improvement Roadmap

This repository is being upgraded in phases to become a more intuitive, operational, and portfolio-grade systems engineering guide.

### Phase 1 — Foundation
- Scaffold missing sections
- Improve README navigation
- Add learning path and lifecycle model

### Phase 2 — Operational Depth
- Add scenarios
- Add playbooks
- Add command references

### Phase 3 — Senior-Level Engineering Signals
- Add security incident workflow
- Add metrics
- Add architecture diagrams

### Phase 4 — Flagship Polish
- Add case studies
- Add lab walkthroughs
- Add script documentation
"@

Write-Section "Removing older scaffold sections if present"

$headersToReplace = @(
    "## How to Use This Guide",
    "## Suggested Reading Order",
    "## Systems Engineer Operational Model",
    "## Practice and Real-World Operations",
    "## Repository Map",
    "## Improvement Roadmap"
)

foreach ($header in $headersToReplace) {
    $readme = Remove-SectionByHeader -Content $readme -Header $header
}

Write-Section "Inserting upgraded README sections"

$inserted = $false

if ($readme -match '(?m)^# .+$') {
    $readme = Insert-After-FirstMatch -Content $readme -Pattern '^(# .+)$' -InsertionBlock @"
$howToUseBlock

$readingOrderBlock

$operationalModelBlock

$practiceBlock

$repoMapBlock

$priorityRoadmapBlock
"@
    $inserted = $true
}

if (-not $inserted) {
    $readme = $readme.TrimEnd() + "`r`n`r`n" + @"
$howToUseBlock

$readingOrderBlock

$operationalModelBlock

$practiceBlock

$repoMapBlock

$priorityRoadmapBlock
"@.Trim() + "`r`n"
}

Write-Section "Saving README"

Set-FileContent -Path $readmePath -Content $readme

Write-Section "Complete"

Write-Host "README priority upgrade complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoRoot`""
Write-Host "git status"
Write-Host "git add README.md"
Write-Host "git commit -m `"docs: upgrade README learning path and operational model`""
Write-Host "git push"