# Playbook â€” SSH Access Failure

## Symptoms
- SSH connection refused
- Timeout during connection
- Authentication fails unexpectedly
- Administrative access lost after hardening or change

## Initial Checks
1. Confirm hostname and target IP
2. Confirm system is powered on and reachable
3. Validate DNS resolution
4. Confirm no active maintenance window
5. Confirm jump host or VPN path is healthy

## Commands

~~~bash
ping <host>
nslookup <host>
traceroute <host>
nc -zv <host> 22
systemctl status sshd
journalctl -u sshd -n 100
ss -tulpn | grep :22
cat /etc/ssh/sshd_config
getenforce
firewall-cmd --list-all
~~~

## Investigation
- sshd service stopped
- Port 22 blocked by firewall or NSG
- Invalid sshd_config change
- SELinux blocking access
- Broken PAM or auth settings
- Network path issue

## Resolution
Document the exact fix here.

## Verification
- SSH login works with approved methods
- Logs show successful authentication
- Security posture remains intact
- Monitoring returns to normal
