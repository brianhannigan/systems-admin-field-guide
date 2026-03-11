# Why Systems Break After Hardening

## Purpose
Document why STIG implementation often creates outages or unexpected behavior.

## Common Reasons
1. **Permissions get tighter**
   - apps lose access to files, paths, or sockets

2. **Authentication rules change**
   - service accounts or remote automation stop working

3. **Services are disabled**
   - required but insecure-by-default services may be turned off

4. **SSH settings change**
   - root login, ciphers, or auth methods may be restricted

5. **Auditing increases overhead**
   - logging or auditing changes can affect performance or app behavior

6. **SELinux or firewall rules become stricter**
   - legitimate traffic or actions may be denied

## Operational Lesson
A secure baseline is not just a checkbox. It must be validated against the real workload.

## Validation
- each control change is understood
- dependencies were reviewed
- service behavior is tested after change
