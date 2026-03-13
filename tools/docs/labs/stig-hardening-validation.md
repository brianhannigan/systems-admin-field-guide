# Lab — STIG Hardening Validation

## Objective
Practice validating whether a hardening change improves compliance without breaking access or services.

## Environment
- RHEL lab VM
- SSH access
- Logging enabled

## Steps
1. Record current access and service state
2. Apply a controlled hardening-related change
3. Validate SSH, service health, and logs
4. Review impact
5. Roll back or document final safe state

## Validation
- SSH still works
- Service remains available
- Logs are acceptable
- Compliance position improves or is clearly understood
