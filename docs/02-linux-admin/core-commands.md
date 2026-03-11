# Core Commands

## Purpose
Capture the Linux commands most useful for administration, troubleshooting, patching, and recovery work.

## Filesystem Navigation
```bash
pwd
ls -lah
cd /path/to/location
tree
find /etc -name "*.conf"
```

## Search and Text Processing
```bash
grep -R "listen" /etc
grep -i error /var/log/messages
awk '{print $1}'
sed -n '1,20p' /etc/ssh/sshd_config
```

## File Operations
```bash
cp source.txt backup.txt
mv oldname newname
rm -f temp.txt
mkdir -p /opt/app/logs
tar -czf backup.tar.gz /etc
```

## Permissions and Ownership
```bash
chmod 640 file.txt
chown root:root file.txt
ls -l
umask
```

## Process Inspection
```bash
ps aux
top
htop
pgrep sshd
kill -9 <pid>
```

## Package Management (RHEL)
```bash
dnf check-update
dnf update -y
dnf install vim -y
rpm -qa | sort
```

## Validation Checklist
- Confirm command output before making changes
- Document destructive commands before running them
- Verify package changes in logs after updates
