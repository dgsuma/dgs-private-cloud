#!/usr/bin/env bash
set -euo pipefail

echo "== Host =="
hostnamectl --static
uname -a

echo
echo "== Proxmox =="
pveversion -v

echo
echo "== Failed services =="
systemctl --failed || true

echo
echo "== Memory =="
free -h

echo
echo "== Filesystems =="
df -hT

echo
echo "== Network =="
ip -br address
ip route

echo
echo "== Proxmox storage =="
pvesm status

echo
echo "== LVM thin pools =="
lvs -a -o lv_name,vg_name,lv_attr,lv_size,data_percent,metadata_percent,seg_monitor

echo
echo "== Block devices =="
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
