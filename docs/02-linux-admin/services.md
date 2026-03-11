# Service Management

## Purpose
Document how to manage and troubleshoot services using `systemd`.

## Core Commands
```bash
systemctl status sshd
systemctl restart sshd
systemctl stop firewalld
systemctl start firewalld
systemctl enable chronyd
systemctl disable telnet.socket
systemctl list-units --type=service
systemctl --failed
```

## Failed Service Workflow
1. Check service state:
   ```bash
   systemctl status <service>
   ```
2. Review recent logs:
   ```bash
   journalctl -u <service> -n 100 --no-pager
   ```
3. Check full boot/session failures:
   ```bash
   journalctl -xe
   ```
4. Confirm config syntax if the service supports it
5. Restart the service
6. Re-check status and validate the port or application response

## Common Failure Causes
- Invalid configuration file
- Missing dependency
- Port already in use
- Permission denied
- SELinux blocking action
- Service account issue

## Validation
```bash
systemctl is-active <service>
ss -tulpn
curl -I http://localhost
```

## Example: NGINX Recovery
```bash
systemctl status nginx
journalctl -u nginx -n 50 --no-pager
nginx -t
systemctl restart nginx
ss -tulpn | grep :80
curl -I http://localhost
```
