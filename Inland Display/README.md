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