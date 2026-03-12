# Rollback Planning

## Purpose
Document how to recover if an upgrade causes service failure, instability, or unexpected behavior.

## Core Rollback Questions
- What is the trigger to rollback?
- Who makes the rollback decision?
- What backup or snapshot is available?
- How long will rollback take?
- What service validation proves recovery?

## Rollback Options
- Restore snapshot
- Restore VM backup
- Reinstall prior package version if supported
- Revert application configuration
- Fail over to alternate node if available

## Decision Triggers
- Service will not start
- Application health check fails
- Network functionality is broken
- Security control or required logging is lost
- Performance degradation is unacceptable

## Validation Checklist
- Recovery path is known before change starts
- Team knows where the restore point is
- Decision thresholds are defined
- Post-rollback validation steps are documented
