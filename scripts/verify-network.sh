#!/usr/bin/env bash
set -euo pipefail

GATEWAY="${1:-192.168.1.1}"
HTTPS_TARGET="${2:-https://deb.debian.org}"

echo "== Addresses =="
ip -br address

echo
echo "== Routes =="
ip route

echo
echo "== Gateway test =="
ping -c 4 "$GATEWAY"

echo
echo "== DNS IPv4 resolution =="
getent ahostsv4 deb.debian.org

echo
echo "== Outbound IPv4 HTTPS =="
curl -4 --connect-timeout 10 -I "$HTTPS_TARGET"
