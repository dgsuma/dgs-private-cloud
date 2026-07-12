#!/usr/bin/env bash
set -euo pipefail

echo "== Physical devices =="
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS

echo
echo "== Volume groups =="
vgs

echo
echo "== Logical volumes =="
lvs -a -o lv_name,vg_name,lv_attr,lv_size,data_percent,metadata_percent,seg_monitor

echo
echo "== Proxmox storage =="
pvesm status

echo
echo "== vmdata definition =="
pvesm config vmdata
