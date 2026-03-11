# 06 - Server Upgrade Strategy

## Purpose
Provide a repeatable, low-risk approach to upgrading servers in inherited environments.

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
### A. Pre-Upgrade Discovery\n- OS version\n- Application dependencies\n- Service owners\n- Maintenance windows\n\n### B. Safety Controls\n- Backups\n- Snapshots\n- Rollback points\n- Test environment\n\n### C. Execution\n- Change plan\n- Step order\n- Validation checkpoints\n\n### D. Rollback Planning\n- Triggers to abort\n- Recovery steps\n- Verification after rollback\n\n### E. Post-Upgrade Validation\n- Service checks\n- Log review\n- User acceptance\n- Monitoring confirmation

## Suggested Deliverables
- Upgrade checklist\n- Rollback template\n- Validation worksheet\n- Stakeholder communication template\n- Post-upgrade signoff checklist

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
Add examples for Linux patching, Windows patching, and Azure VM update workflows later.
