# Security Compliance Scanner

An interactive terminal-based security audit tool for Linux systems using `dialog`. It helps you scan and assess critical compliance parameters such as open ports, firewall status, file permissions, and more.

## 🔧 Features
- Check open ports (`ss`)
- Detect unowned files
- Identify users with empty passwords
- Validate `/etc/` file permissions
- View firewall (UFW) and AppArmor status
- Logs output to `/var/log/security_compliance_scanner.log`

## 📦 Requirements
- `bash`
- `dialog`
- `ufw` (for firewall check)
- `apparmor-utils` (for AppArmor status)

Install requirements on Ubuntu/Debian:
```bash
sudo apt update
sudo apt install dialog ufw apparmor-utils
