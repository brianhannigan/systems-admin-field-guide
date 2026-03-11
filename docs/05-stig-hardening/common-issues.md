# Common STIG Issues

## Purpose
Track the most frequent breakpoints seen after hardening.

## SSH Access Problems
- remote login fails
- root login blocked
- key-based auth misconfigured
- approved crypto settings break older clients

## Service Account Problems
- app runs under an account that no longer has required privileges
- scheduled jobs stop working
- automation scripts fail silently

## File Permission Problems
- app cannot read config file
- web service cannot write logs or temp files
- startup scripts fail due to restricted permissions

## Logging and Auditing Problems
- app fills disk with logs
- audit rules create noise
- required log paths are inaccessible

## Application Breakage
- daemon starts but app fails
- service appears active but endpoint is dead
- dependencies were not considered before hardening

## Validation
- failed behavior mapped to actual control changes
- log evidence captured
- service retested after fix
