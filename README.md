# Pi-Projects Workspace

A lightweight workspace scaffold to start Raspberry Pi projects (Python, Node, C/C++).

Quick start

- Browse `examples/` and pick a sample (`python-led` or `node-blink`).
- To run the Python example on the Pi:

```bash
# on your Pi
python3 examples/python-led/blink.py
```

- To deploy an example from your machine to a Pi (set `PI_HOST` and `PI_USER` env vars):

```bash
scripts/deploy.sh examples/python-led
# or on Windows PowerShell
.\scripts\deploy.ps1 -Path examples/python-led -PiHost <IP> -User <USER>
```

What's included

- `examples/` small starter projects
- `scripts/` deploy + helper scripts
- `.devcontainer/` devcontainer for cross-building and emulation
- `.github/workflows/` basic CI checks

See each example's README for details and hardware notes.