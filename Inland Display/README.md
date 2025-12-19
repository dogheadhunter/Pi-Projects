# Inland Display

A starter project for an Inland Display prototype (Raspberry Pi).

## Quick Start

Run locally:

```bash
python3 main.py
```

Deploy to your Pi (note path quoting because of the space in the folder name):

```powershell
.\scripts\deploy.ps1 -Path "Inland Display" -PiHost <PI_IP> -User <USERNAME>
```

## What’s included

- `main.py` — minimal starter script
- `requirements.txt` — dependency list (empty by default)
- `.gitignore` — common Python ignores

When you're ready I can deploy this demo to your Pi and run it for verification.

If you have an Inland 3.5" TFT connected and need the drivers installed, use the helper scripts in `scripts/`:

- `scripts/install-inland-display.sh` (Linux/macOS)
- `scripts/install-inland-display.ps1` (Windows PowerShell)

These scripts will SSH to your Pi, install the recommended driver (LCD-show), and reboot the device if required. If you'd like, I can run the installer for you — provide the Pi's host and a username that can SSH in (SSH key recommended).