# Storage

## Purpose
Document disk, filesystem, and LVM operations needed by a systems administrator.

## Disk and Filesystem Inventory
```bash
lsblk
blkid
df -h
du -sh /var/*
mount
cat /etc/fstab
```

## Disk Usage Troubleshooting
```bash
df -h
du -sh /*
find /var/log -type f -size +100M
find / -xdev -type f -size +500M 2>/dev/null
```

## LVM Commands
```bash
pvs
vgs
lvs
pvcreate /dev/sdb
vgcreate data_vg /dev/sdb
lvcreate -L 10G -n app_lv data_vg
mkfs.xfs /dev/data_vg/app_lv
mount /dev/data_vg/app_lv /mnt/app
```

## Expansion Example
```bash
lvextend -r -L +5G /dev/data_vg/app_lv
```

## Common Problems
- Filesystem full
- Log growth consuming space
- Mount missing after reboot
- Wrong fstab entry
- LVM not extended after disk growth

## Validation
```bash
df -h
mount | grep /mnt/app
lsblk
```
