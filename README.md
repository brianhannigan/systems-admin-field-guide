# Systems Admin First 90 Days Field Guide

Repo-ready outline and development tracker for a 12-week ramp-up plan covering:

- Red Hat Linux administration
- Windows server operations
- Azure infrastructure
- Terraform automation
- STIG hardening and compliance
- Server upgrades and patching
- Vulnerability remediation
- DevOps-style infrastructure management

## Purpose

This repository is structured to help turn a rough training guide into a living operational manual. Each major component has its own outline, scope, deliverables, and tracking checklist so it can be expanded iteratively.

## Suggested workflow

1. Start with `PROJECT_BOARD.md`
2. Expand one component at a time under `docs/components/`
3. Open GitHub issues for missing sections, labs, screenshots, and scripts
4. Track improvements weekly using the 12-week plan
5. Convert validated sections into polished PDF/Docx later

## Repository structure

```text
systems-admin-field-guide-repo/
├── README.md
├── PROJECT_BOARD.md
├── ROADMAP.md
├── CONTRIBUTING.md
├── .github/
│   └── ISSUE_TEMPLATE/
├── docs/
│   ├── MASTER_OUTLINE.md
│   └── components/
│       ├── 01-first-30-days-survival-plan.md
│       ├── 02-red-hat-linux-admin-skills.md
│       ├── 03-terraform-learning-path.md
│       ├── 04-azure-infrastructure-skills.md
│       ├── 05-stig-hardening-guide.md
│       ├── 06-server-upgrade-strategy.md
│       ├── 07-vulnerability-management-workflow.md
│       ├── 08-weekly-training-schedule.md
│       ├── 09-cyber-range-lab-exercises.md
│       ├── 10-scripts-to-learn-early.md
│       ├── 11-daily-30-minute-practice-routine.md
│       └── 12-six-month-team-expert-checklist.md
└── scripts/
    └── create_issue_list.ps1
```

## Recommended next development order

1. First 30 Days Survival Plan
2. Red Hat Linux Admin Skills
3. STIG Hardening Guide
4. Vulnerability Management Workflow
5. Server Upgrade Strategy
6. Terraform Learning Path
7. Azure Infrastructure Skills
8. Cyber Range Labs
9. Scripts to Learn Early
10. Weekly Training Schedule
11. Daily Practice Routine
12. Six-Month Expert Checklist
