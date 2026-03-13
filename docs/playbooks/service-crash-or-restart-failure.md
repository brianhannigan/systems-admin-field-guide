# Playbook â€” Service Crash or Repeated Restart Failure

## Symptoms
- Service fails to start
- systemd shows restart loop
- Application unavailable
- Monitoring alerts on process failure

## Initial Checks

~~~bash
systemctl status <service>
journalctl -u <service> -n 200
ps -ef | grep <service>
ss -tulpn
df -h
free -h
top
~~~

## Investigation
- Bad configuration file
- Port binding conflict
- Missing dependency
- Permission issue
- Disk full or memory pressure
- Package or library mismatch

## Resolution
Document the exact fix here.

## Verification
- Service starts successfully
- Port is listening
- Application health checks pass
- Logs show stable operation
