# 05 - STIG Hardening Guide

## Purpose
Explain STIG hardening in operational terms so systems can be secured without blindly breaking services.

## Objectives
- Define what “good” looks like for this area
- Capture the minimum viable knowledge needed early
- Break the topic into trackable sub-sections
- Identify where labs, checklists, and scripts belong

## Core Questions to Answer
- What does this component cover operationally?
- What usually goes wrong here?
- What should be learned first vs later?
- What should be documented for repeatable team use?
- What can be automated?

## Outline
### A. STIG Fundamentals\n- What STIGs are\n- Why they exist\n- Difference between compliance and operational health\n\n### B. Why Systems Break\n- Permissions changes\n- Disabled services\n- Authentication policy changes\n- Firewall changes\n- Logging/auditing side effects\n\n### C. Common Failure Modes\n- SSH lockouts\n- Service account failures\n- Application startup failures\n- Unexpected port blocking\n\n### D. Troubleshooting Strategy\n- Review what changed\n- Compare pre/post state\n- Test by layer\n- Restore only what is necessary\n\n### E. Compliance Workflow\n- Baseline\n- Apply\n- Test\n- Remediate\n- Document\n- Re-scan

## Suggested Deliverables
- STIG break/fix matrix\n- Common issues reference\n- Validation workflow\n- Evidence checklist\n- Change management notes

## Dependencies / Related Components
- Review adjacent chapters for overlap
- Cross-link scripts, labs, and validation checklists
- Tie this component to the 12-week training schedule where relevant

## Validation Checklist
- [ ] Scope is clearly defined
- [ ] Contains practical commands or workflows
- [ ] Includes troubleshooting guidance
- [ ] Includes hands-on practice ideas
- [ ] Avoids filler and repeated content
- [ ] Ready for chapter expansion

## Notes for Future Development
Add real examples mapped to Linux, Windows, and Azure-adjacent controls later.
