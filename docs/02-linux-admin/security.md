# Security

## Purpose
Track Linux security controls most relevant to admin work in enterprise and regulated environments.

## User and sudo Basics
```bash
id username
getent passwd username
sudo -l
visudo
```

## Permissions
```bash
ls -l
chmod 600 /path/to/file
chown root:root /path/to/file
```

## SSH Hardening Checks
```bash
cat /etc/ssh/sshd_config
sshd -t
systemctl restart sshd
```

## SELinux Basics
```bash
getenforce
sestatus
ausearch -m avc -ts recent
restorecon -Rv /var/www/html
```

## firewalld Basics
```bash
firewall-cmd --state
firewall-cmd --list-all
firewall-cmd --add-service=https --permanent
firewall-cmd --reload
```

## Common Security Failure Points
- SSH config breaks remote access
- Wrong file permissions stop service startup
- SELinux denies app behavior
- Firewall rule blocks application traffic
- Overly broad sudo access

## Validation
- Access works as intended
- Logs show no new denials
- Ports are reachable only as expected
- Permissions match policy
