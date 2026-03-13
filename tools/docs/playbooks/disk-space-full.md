# Playbook â€” Disk Space Full

## Commands

~~~bash
df -h
du -xh / | sort -h | tail
journalctl -n 100
~~~

## Resolution
Clean logs, expand disk, or rotate files.
