#!/usr/bin/env bash
set -euo pipefail

# Masking helpers 
HOST="$(hostname)"
MASK_IP="X.X.X.X"
mask() {
  # Masking private IPv4 + IPv6 link-local + local hostname
  sed -E \
    -e "s/([0-9]{1,3}\.){3}[0-9]{1,3}/$MASK_IP/g" \
    -e 's/fe80::[0-9a-f:]+/fe80::xxxx/gI' \
    -e "s/$HOST/HOSTNAME/g"
}

can_sudo() { sudo -n true 2>/dev/null; }

echo "=== Time ==="; date
echo "=== Host ==="; hostnamectl | mask
echo "=== Uptime/Load ==="; uptime

echo "=== Users ==="; who | mask

echo "=== IP / Routes ==="
{ ip a; echo; ip r; } | mask

echo "=== DNS (resolv.conf) ==="
( sed -E 's/(nameserver )[0-9a-f:\.]+/\1X.X.X.X/g' /etc/resolv.conf 2>/dev/null || true )

echo "=== UFW ==="
( sudo ufw status verbose 2>/dev/null || ufw status verbose 2>/dev/null || true ) | mask

echo "=== Fail2Ban sshd ==="
( sudo fail2ban-client status sshd 2>/dev/null || true )

echo "=== Services (ssh, smbd) ==="
systemctl --no-pager --type=service | egrep 'ssh|smbd' || true

echo "=== Samba testparm ==="
testparm -s 2>&1 | sed -E 's/(password = ).+/\1********/g'

echo "=== Disks ==="
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT

echo "=== Mounts (df -h) ==="
df -h | sort -k5 -h

echo "=== fstab (masked) ==="
sed -E 's/UUID=[^ ]+/UUID=****/g' /etc/fstab

echo "=== SMART quick ==="
( sudo smartctl -H /dev/sda 2>/dev/null || true )
( sudo smartctl -H /dev/sdb 2>/dev/null || true )

echo "=== Temps ==="
if command -v vcgencmd >/dev/null; then vcgencmd measure_temp; else echo "vcgencmd N/A"; fi

echo "=== Last boots ==="
last -x | head -n 20 | mask

echo "=== Journal ssh (last 2h) ==="
if can_sudo; then sudo journalctl -u ssh --since "2 hours ago" --no-pager | tail -n 200 | mask; fi

echo "=== Journal smbd (last 2h) ==="
if can_sudo; then sudo journalctl -u smbd --since "2 hours ago" --no-pager | tail -n 200 | mask; fi

echo "=== Dmesg disk/errors (tail) ==="
dmesg | egrep -i 'error|fail|sda|sdb|usb|nvme' | tail -n 200 | mask || true

echo "=== Listening sockets ==="
ss -tulpn 2>/dev/null | mask || true

echo "=== Done ==="