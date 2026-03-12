# Pre-Upgrade Checklist

## Purpose
Document the checks that should be completed before any server upgrade or major patch activity.

## Core Checklist
- Confirm maintenance window
- Identify system owner
- Confirm business impact
- Review dependencies
- Confirm backup or snapshot status
- Review current version and target version
- Review vendor or platform release notes
- Review known compatibility concerns
- Confirm validation plan exists
- Confirm rollback plan exists

## Questions to Answer
- What depends on this system?
- What will be unavailable during the change?
- Is a reboot expected?
- Is the application owner aware?
- What is the recovery point if this fails?

## Evidence to Capture
- Current version
- Current service state
- Backup confirmation
- Screenshot or command outputs showing baseline condition
- Ticket / change reference

## Validation Checklist
- All dependencies identified
- Owners notified
- Backup confirmed
- Test and rollback plans written down
- Change can be executed in a controlled way
