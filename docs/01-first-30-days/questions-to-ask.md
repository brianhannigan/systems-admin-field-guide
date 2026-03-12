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
