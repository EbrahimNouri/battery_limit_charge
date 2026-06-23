# battery_limit_charge

# ASUS TUF Battery Charge Limit Control

A lightweight, robust Bash utility designed to limit the maximum battery charge percentage on Linux laptops (optimized for **ASUS TUF Gaming** and universal devices). This tool prevents your battery from constantly staying at 100% when plugged into AC power, significantly extending its overall lifespan.

It features a **persistent background service** that remembers and reapplies your last chosen limit automatically every time the operating system boots up.

---

## Features

- ⚡ **Instant Application:** Changes your charging threshold on the fly without system reboots.
- 💾 **Boot Persistence:** Automatically recovers your configuration on system start.
- 🔄 **Default Restore:** Easily resets your laptop to normal behavior (100% full charge).
- 🔍 **Smart Hardware Detection:** Auto-detects custom ASUS paths, `BAT0`, `BAT1`, and `BATT` paths natively.
- ❓ **Help Menu:** Includes a built-in clean English CLI manual.

---

## Quick Installation & Setup

Open your terminal (`Ctrl` + `Alt` + `T`) and run this single command to automatically download, install, and enable the system boot persistence service:

```bash
curl -sSL https://githubusercontent.com | sudo bash
```

*(Note: Don't forget to replace `YOUR_GITHUB_USERNAME` with your actual GitHub account handle after creating the repo).*

---

## How To Use

Once installed, use the global command `set-battery-limit` with `sudo` anywhere in your terminal.

### 1. Show Current Limit State
Run the command without parameters to view your active threshold configuration:
```bash
sudo set-battery-limit
```

### 2. Set Custom Limit (e.g., 60% or 80%)
Type your preferred capping percentage value directly:
```bash
sudo set-battery-limit 60
```

### 3. Reset Back to Default (Full 100% Charge)
Return your hardware to its natural state by passing `default` or `100`:
```bash
sudo set-battery-limit default
```

### 4. Open Help Menu
```bash
set-battery-limit --help
```

---

## How It Works

1. **The CLI Core:** Modifies the specific kernel ACPI battery registers under `/sys/class/` in real-time.
2. **The Cache:** Saves your selected threshold inside `/etc/battery_limit.conf`.
3. **The Systemd Service:** Triggers a fast `oneshot` daemon at boot time to read your cached setting and feed it back to your hardware.


#!/usr/bin/env bash
set -e

echo "Installing ASUS TUF Battery CLI..."

# Download or create the files locally
sudo curl -sSL https://githubusercontent.com -o /usr/local/bin/set-battery-limit
sudo curl -sSL https://githubusercontent.com-apply -o /usr/local/bin/set-battery-limit-apply
sudo curl -sSL https://githubusercontent.com -o /etc/systemd/system/battery-limit.service

# Give permissions
sudo chmod +x /usr/local/bin/set-battery-limit
sudo chmod +x /usr/local/bin/set-battery-limit-apply

# Enable background service
sudo systemctl daemon-reload
sudo systemctl enable battery-limit.service

echo "Installation complete! Type 'sudo set-battery-limit --help' to start."

