#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-reports}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_FILE="${OUT_DIR}/pve01-state-${STAMP}.txt"

mkdir -p "$OUT_DIR"

{
  echo "DGS Private Cloud host state"
  echo "Generated: $(date --iso-8601=seconds)"
  echo

  echo "== Hostname =="
  hostnamectl --static
  echo

  echo "== Kernel =="
  uname -a
  echo

  echo "== Proxmox versions =="
  pveversion -v
  echo

  echo "== Failed units =="
  systemctl --failed || true
  echo

  echo "== Network =="
  ip -br address
  ip route
  echo

  echo "== Storage =="
  pvesm status
  vgs
  lvs -a -o lv_name,vg_name,lv_attr,lv_size,data_percent,metadata_percent,seg_monitor
  echo

  echo "== Block devices =="
  lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
} > "$OUT_FILE"

echo "State report written to: $OUT_FILE"
echo "Review and redact the report before committing it."
