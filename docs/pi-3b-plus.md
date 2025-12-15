# Raspberry Pi 3 Model B+ (summary)

Short, useful reference for the Pi 3B+ (useful when working from Raspbian Bookworm).

## Quick Specs
- SoC: Broadcom BCM2837B0 — Cortex‑A53 (ARMv8-A) quad‑core, 1.4 GHz (64‑bit capable)
- RAM: 1 GB LPDDR2
- Wireless: Cypress CYW43455 — dual‑band 2.4/5 GHz Wi‑Fi (802.11ac) + Bluetooth 4.2/BLE
- Ethernet: Gigabit Ethernet over USB2 (≈300 Mbps max)
- Power: 5 V via Micro USB, recommended 2.5 A supply
- Headers: 40‑pin GPIO header (standard Raspberry Pi pinout)
- Ports: 4× USB 2.0, full‑size HDMI, CSI (camera), DSI (display), microSD

## Useful Hardware Links
- Product page: https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/
- Reduced schematics & datasheets: https://datasheets.raspberrypi.com/rpi3/raspberry-pi-3-b-plus-reduced-schematics.pdf
- Pinout reference (interactive): https://pinout.xyz/

## GPIO & Peripherals
- GPIO header: 40 pins supporting GPIO (BCM), 3.3 V power, 5 V, GND
- I2C, SPI, UART, PWM, PCM available on header pins — use BCM numbering for code
- HAT EEPROM ID pins: ID_SD/ID_SC (for EEPROM/HAT detection)

GPIO libraries and docs
- GPIO Zero (high‑level Python): https://gpiozero.readthedocs.io/
- RPi.GPIO (low‑level Python C extension): https://pypi.org/project/RPi.GPIO/
- pigpio (daemon + socket API, good for remote/precise PWM): http://abyz.me.uk/rpi/pigpio/

Example (LED blink with GPIO Zero):
```python
from gpiozero import LED
from time import sleep
led = LED(17)
while True:
    led.on()
    sleep(1)
    led.off()
    sleep(1)
```

## Software Notes (Bookworm / Debian 12)
- OS: Raspberry Pi OS (Bookworm) is a Debian derivative. See https://www.raspberrypi.com/documentation/
- Keep packages updated: `sudo apt update && sudo apt full-upgrade`
- Pip/venv: Bookworm requires `pip` installs to use virtual environments or `apt` packages (see PEP 668 / "externally-managed-environment"). Use `python3 -m venv env` then `source env/bin/activate`.
- For GPIO libraries use `sudo apt install python3-gpiozero pigpio` (or install per‑project with `pip` inside venv).
- To run pigpio-based code, enable and start the daemon: `sudo systemctl enable --now pigpiod`.

## Useful Commands & Tools
- Check firmware/kernel: `vcgencmd version`
- Get throttled state: `vcgencmd get_throttled`
- Measure temperature: `vcgencmd measure_temp`
- Show memory split: `vcgencmd get_mem arm` / `vcgencmd get_mem gpu`
- Display pin state helper: `raspi-gpio get`

## Installation & Setup Links
- Getting started (images & imager): https://www.raspberrypi.com/documentation/computers/getting-started.html
- GPIO docs: https://www.raspberrypi.com/documentation/usage/gpio/
- gpiozero docs: https://gpiozero.readthedocs.io/

## Notes & Tips
- The SoC supports 64‑bit, but the default image might be 32‑bit; choose the OS image that fits your needs.
- Avoid running `pip` system‑wide; prefer `apt` for system packages and `venv` for project packages.
- Power supply quality matters — undervoltage can cause throttling and instability (`vcgencmd get_throttled`).

---
If you'd like, I can:
- Expand any section (SoC internals, power management, thermal/power tuning),
- Add a printable GPIO cheat sheet to `docs/`, or
- Add sample `gpiozero`/`pigpio` test scripts under `examples/`.

