# Systems Engineer First 90 Days Field Guide

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

## Suggested Reading Order

Follow this sequence to get the most value from the guide.

### Step 1 â€” Start Here
- [How to Use This Guide](docs/reference/how-to-use-this-guide.md)
- [Suggested Reading Order](docs/reference/suggested-reading-order.md)

### Step 2 â€” Understand the Operational Model
- [Systems Engineer Operational Model](docs/workflows/systems-engineer-operational-model.md)

### Step 3 â€” Build Core Operations Muscle
Review your Linux, Windows, networking, service validation, and troubleshooting documentation.

### Step 4 â€” Review Cloud and Automation
Study your Azure and Terraform material together so the cloud and IaC workflows feel connected.

### Step 5 â€” Study Hardening and Compliance
Work through STIG, patching, and remediation topics with operational impact in mind.

### Step 6 â€” Practice Real Scenarios
- [Scenarios](docs/scenarios/)
- [Playbooks](docs/playbooks/)

### Step 7 â€” Review Portfolio-Grade Evidence
- [Case Studies](docs/case-studies/)
- [Labs](docs/labs/)
- [Reference](docs/reference/)

## Systems Engineer Operational Model

The repository follows a practical systems engineering lifecycle:

~~~text
Infrastructure Discovery
        â†“
Documentation
        â†“
Hardening & Compliance
        â†“
Automation (Terraform / Scripts)
        â†“
Monitoring & Logging
        â†“
Vulnerability Remediation
        â†“
Validation & Continuous Improvement
~~~

Supporting documentation:

- [Operational Model](docs/workflows/systems-engineer-operational-model.md)
- [Security Incident Workflow](docs/workflows/security-incident-workflow.md)
- [Engineering Metrics](docs/metrics/engineering-metrics.md)
- [Diagram Placeholder](diagrams/placeholders/systems-engineer-operational-model.md)

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

## Repository Map

~~~text
docs/
â”œâ”€â”€ case-studies/   # portfolio-grade implementation writeups
â”œâ”€â”€ labs/           # hands-on practice walkthroughs
â”œâ”€â”€ metrics/        # operational measurement guidance
â”œâ”€â”€ playbooks/      # repeatable troubleshooting procedures
â”œâ”€â”€ reference/      # quick reference and navigation docs
â”œâ”€â”€ scenarios/      # real-world issue simulations
â””â”€â”€ workflows/      # lifecycle and security workflow docs

diagrams/
â””â”€â”€ placeholders/   # planned visual assets to convert into polished diagrams
~~~

## Improvement Roadmap

This repository is being upgraded in phases to become a more intuitive, operational, and portfolio-grade systems engineering guide.

### Phase 1 â€” Foundation
- Scaffold missing sections
- Improve README navigation
- Add learning path and lifecycle model

### Phase 2 â€” Operational Depth
- Add scenarios
- Add playbooks
- Add command references

### Phase 3 â€” Senior-Level Engineering Signals
- Add security incident workflow
- Add metrics
- Add architecture diagrams

### Phase 4 â€” Flagship Polish
- Add case studies
- Add lab walkthroughs
- Add script documentation


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

- docs/ -> field guide chapters and operating notes
- labs/ -> practical single-VM exercises
- scripts/ -> example automation helpers
- diagrams/ -> workflow and architecture visuals
- ssets/ -> screenshots, supporting graphics, and repo visuals
- tools/ -> repo-building helper scripts

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

## Real Infrastructure Scenarios

These scenarios are designed to show how practical systems engineering problems unfold in enterprise and government-style environments.

- [Scenario Index](docs/scenarios/README.md)
- [Azure VM Fails to Deploy](docs/scenarios/azure-vm-fails-to-deploy.md)
- [Terraform Drift Detected](docs/scenarios/terraform-drift-detected.md)
- [Vulnerability Remediation Workflow](docs/scenarios/vulnerability-remediation-workflow.md)

## Troubleshooting Playbooks

These playbooks provide repeatable operational procedures for common failures and recovery workflows.

- [Playbook Index](docs/playbooks/README.md)
- [SSH Access Failure](docs/playbooks/ssh-access-failure.md)
- [Service Crash or Restart Failure](docs/playbooks/service-crash-or-restart-failure.md)
- [Azure VM Failure](docs/playbooks/azure-vm-failure.md)

## Example Command Reference

Use this command reference as a quick operational aid during live troubleshooting, validation, and remediation work.

- [Systems Engineer Command Reference](docs/reference/systems-engineer-command-reference.md)
- [Systems Engineer Cheat Sheet](docs/reference/systems-engineer-cheat-sheet.md)

