# Self-hosted NAS

## Overview

This project documents the setup of a self-hosted NAS (Network Attached Storage) on a Raspberry Pi 4.  
The goal: build a secure, private, and maintainable home cloud to replace commercial services such as iCloud.

---

## Hardware

- Raspberry Pi 4 (4 GB RAM) + microSD (Debian 12, 64-bit)
- 2x HDDs (2 TB for media, 3 TB for personal cloud)
- Powered USB hub for storage
- Cooling fan + ventilated enclosure
- Surge-protected power strip

---

## System

- OS: Debian GNU/Linux 12 (Bookworm, arm64)
- Core services:
  - SSH (with keys only)
  - Samba (file shares)
  - UFW firewall
  - Fail2Ban
  - Unattended security upgrades

---

## Storage

- `/srv/media` → 2 TB (ext4) for media library
- `/srv/cloud` → 3 TB (ext4) for personal files & backups
- Mounted via UUID in `/etc/fstab` (with `noatime`)

---

## Security & Remote Access

- SSH hardened (key-based, no password login)
- UFW firewall restricting services
- Fail2Ban on SSH
- WireGuard VPN:
  - Server running on the Pi
  - Clients: iPhone, macOS, Windows/Linux laptop
  - Split-tunnel configuration (only LAN/NAS traffic goes through VPN)

---

## Services

- **Samba** → File sharing across local devices
- **Nextcloud** → Private cloud for:
  - Files
  - Photos
  - Contacts
  - Calendar
- **Vaultwarden** → Self-hosted Bitwarden password manager

---

## Maintenance

**Monitoring**

- CPU temp: `vcgencmd measure_temp`
- Throttling: `vcgencmd get_throttled`
- SMART: `smartctl -a /dev/sdX`
- Logs: `journalctl -u ssh/smbd -f`, `fail2ban-client status sshd`

**Backup**

- 3-2-1 rule: 3 copies, 2 media, 1 offsite
- Monthly external HDD backup or encrypted cloud backup

**Support script (see `scripts/nas-support.sh`)**

- Script that collects a full system health report:
  - Load, IP, routes
  - Firewall / Fail2Ban status
  - Samba config check
  - SMART disk health
  - Last logs (SSH/Samba/disk errors)

To run (local only) :
`~/bin/nas-support.sh > support.txt`

⚠️ Run locally and share only with trusted parties. The generated report may contain host- and network-specific details (masked where possible).

---

## Roadmap

- Automate SMART monitoring & alerts
- Automated backup jobs (rclone or external HDD rotation)

---

### 🚀 Key Learnings

- Securely exposing local infrastructure via VPN
- Managing multi-disk setup on Raspberry Pi
- Documentation & reproducibility (all steps versioned here)
